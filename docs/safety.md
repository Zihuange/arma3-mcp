# 安全模型

本服务器面向**使用者自控的环境**，设计前提是：工具调用方的意图由使用者负责，
但**能力边界必须由服务器强制**——因为参数来自 LLM，不能假设它总是写对。

## 无门控模式（`A3MCP_PROFILE=unrestricted`）

**这是本文件其余内容的例外，也是唯一一个：它让所有门控失效。**

开启方式（二选一）：

```bat
set A3MCP_PROFILE=unrestricted
rem 或
set A3MCP_UNRESTRICTED=1
```

开启后实际发生的事：

| 层级 | 默认 | 无门控模式 |
|---|---|---|
| 命令分级（read/write/exotic/call_gated/**forbidden**） | 逐级把关 | **全部放行**，连硬禁命令也放行 |
| `CALL_DENY`（`BIS_fnc_execVM` 等） | 无条件拒绝 | **不再拒绝** |
| 表达式白名单 / 永久禁区 | 强制 | **跳过** |
| 分号（多语句）、字符串字面量 | 禁止 | **允许** |
| 表达式长度上限 | 400 字符 | 8000 字符 |
| 游戏侧第二道防线（`fn_validate.sqf`） | 强制 | **跳过**（MCP 会带 `skipValidate`） |
| 输入注入 / 作弊类命令 | 默认关 | **默认开** |

等价于：`exec` 变成"任意 SQF 代码执行"，`call` 变成"任意函数调用"。

### 为什么仍然保留这个开关（而不是删掉检查）

删掉检查之后，"**现在是什么模式**"就不再可观测。而这个模式的代价恰恰是
"事后要能说清当时发生了什么"。所以：

- 开关**默认关**，且只在显式设置时生效；
- `gates_status` 里会醒目地显示 `⚠⚠ 无门控模式已开启`；
- **每条 `exec` 的审计记录都会带 `mode: "unrestricted"`** —— 这是事后复盘时
  区分"当时被校验过"与"当时谁也没挡"的唯一依据；
- 显式设 0 仍可单独关掉某一项（`A3MCP_INPUT_INJECT=0` 等）。

### 风险（使用者自担，这里只如实列出）

- 本模式**推翻**了 D2 与 D37 的结论（"硬禁命令不接受任何开关"）。放行
  `compile`/`execVM`/`callExtension` 之后，本仓库全部的类型校验与参数校验
  都不再构成阻碍——**LLM 能做的就是你在这台机器上能做的**。
- 输入注入默认打开：LLM 可以移动真实鼠标、点击任意前台窗口（仍受
  "仅本进程窗口"限制，但那个限制在无门控模式下也不该被指望）。
- **不要在启用 BattlEye 的环境、共享机器或含敏感数据的桌面上开启它。**

### 它没有撤销的东西

- **审计照旧**（每次调用都记，含完整表达式）——审计不是门控，是记录；
- `exec` 的**参数展开与回执序列化**照旧（那是功能，不是安全）；
- 默认路径**一丝不变**：`unrestricted=False` 时所有行为与本文其余章节描述一致
  （有回归测试钉住这件事）。

## 五级分级

| 级别 | 含义 | 默认 | 放行条件 |
|---|---|---|---|
| `read` | 只读查询与本地纯计算 | 放行 | `A3MCP_ENGINE_READ=1`（默认 1） |
| `write` | 改变游戏世界（含 UI 改动） | 放行 | `A3MCP_ENGINE_WRITE=1`（默认 1） |
| `exotic` | 凭空生成资源 / 网络协调 / 调试后门 | **拒绝** | `A3MCP_ENGINE_EXOTIC=1`；作弊类另需 `A3MCP_ALLOW_CHEAT=1` |
| `call_gated` | `call`：**风险由参数决定**的那一条 | **拒绝** | `A3MCP_ENGINE_CALL=1`，且目标函数名不在 `CALL_DENY` 里 |
| `forbidden` | 动态代码执行面 | **永远拒绝** | 无——任何开关都放不开 |

分级对每条命令**逐一**判定，规则实现在 `guard/gates.py::classify`，
依据是命令名前缀与显式清单；未列入清单的命令按保守方向归类（CBA/ACE 函数默认按 `write`，
因为它们的副作用无法静态判断）。

## 硬禁清单（没有例外）

```
动态代码执行：compile / compileFinal / spawn / exec / execVM / execFSM
              preprocessFile / preprocessFileLineNumbers / preprocessConfigFile
              loadFile / callExtension
跨机执行：    remoteExec / remoteExecCall / BIS_fnc_MP
官方封装：    BIS_fnc_exec* / BIS_fnc_spawn* / BIS_fnc_dbg_* / BIS_fnc_codePerformance
```

**为什么没有例外**：这些命令的存在意味着"命令名可以是任意的、代码可以是任意的"。
一旦放行，本仓库全部的类型校验、参数校验、风险分级同时失效——
安全模型会从"结构化调用"塌回"任意代码执行"。这是架构的根基，不是一条可调的策略。

`A3MCP_ALLOW_COMMANDS` 显式白名单**同样无法**解开硬禁（有专门用例守住这条线）。

## `call` 为什么单独一级（它与硬禁的区别）

判据不是"这条命令危不危险"，而是**参数能不能结构化校验**：

| | 参数是什么 | 能否逐条核对 | 结论 |
|---|---|---|---|
| `compile` / `spawn` / `execVM` | **任意字符串** | 不能——字符串内容是代码 | 硬禁 |
| `call` | **函数引用** | 能——函数名来自有限集合，可逐个比对 | 有条件放行 |

引擎定义支持这一点：BI 命令库对 `call code` 的 `code` 参数注明
"also accepts datatype String"——传字符串时按**函数名**解析，不建新的代码对象。

放行它要三层同时成立，缺一不可：

1. **目标必须走数据**。表达式里禁止字符串字面量，所以函数名只能是调用方传进来的
   数据（`_p0 call _p1`，args 里给名字）。写进表达式文本 → 拒绝。
2. **形状必须是函数名**。只允许 `[A-Za-z_][A-Za-z0-9_]{0,127}`——路径、含空格、
   带点号的一律拒绝。
3. **不在 `CALL_DENY` 里**。这一类把字符串编译成代码，`call` 它们等于把 `call`
   变回 `compile`：

```
BIS_fnc_exec* / BIS_fnc_spawn / BIS_fnc_dbg_* / BIS_fnc_codePerformance / BIS_fnc_callSQF
BIS_fnc_MP / compile / compileFinal / spawn / execVM / execFSM / callExtension / remoteExec*
```

**`CALL_DENY` 的优先级高于白名单**：`A3MCP_ALLOW_COMMANDS` 也放不开。
`A3MCP_ALLOW_COMMANDS=call` 同样**无效**——它要核对的是"调用哪个函数"，
一个命令名级别的开关绕不过那次核对，那就是留后门。

所以最重要的一条反向用例是：**`BIS_fnc_execVM` 经 `call` 仍必须被拒**，
且该请求不能出现在游戏侧。

## 执行链路的四道闸门

```
查库（命令必须存在，不猜名字）
  → 参数校验（个数 + 类型；识别不出的类型如实标注"未校验"）
    → 风险分级（read/write/exotic/call_gated/forbidden）
      → 通道（未接通则明确报错，不假装成功）
```

任何一步不过，命令**都不会**被发送。`exec` 的 `dry_run=true` 可以走到第三步为止，
把最终负载摊开给人看。

`call` 的"参数校验"比其它命令多一步：**要看实参的值**（目标函数名），
而不是只看形状。这是本框架里唯一一处这样的判定，实现在
`knowledge/expr.py::check_call_target`。它与 SQF 侧的 `fn_validate.sqf`
是**独立实现**——同样两道防线、同样互不依赖。

## 输入注入的额外约束（P2）

原生输入注入（鼠标点击、键盘按键）动的是操作系统输入队列，影响范围**超出游戏**：

- 默认关闭（`A3MCP_INPUT_INJECT=0`）；
- 默认仅前台注入（`A3MCP_INPUT_FOREGROUND_ONLY=1`）：目标窗口不是本进程窗口时拒绝；
- 只允许作用于**本进程自己的窗口**——这比维护一张窗口标题白名单更硬；
- 文本输入不支持输入法（中文输入不可行），能力矩阵中已如实标注。

## 审计

每次执行与预演写入 JSONL：

```json
{"ts":1757991234.123,"tool":"exec","cid":"c3f9a1b2","cmd":"setPosATL",
 "level":"write","ok":true,"elapsed_ms":41,"channel":"pipe"}
```

落点由 `A3MCP_AUDIT_LOG` 指定。**审计失败不阻断操作**，但返回值里仍带该行内容，
不会静默丢失。

## 与 BattlEye 的关系

使用者明确：本服务器只在 **BattlEye 不启用**的环境使用（自控单机/自建服务器）。
这一点必须在两类操作上被尊重：

| 操作 | BattlEye 启用时 | 本仓库的处理 |
|---|---|---|
| 引擎层命令（SQF） | 沙盒类命令可能被判异常 | 靠 EXOTIC 闸门与分级控制 |
| 原生输入注入 | 外部输入注入属典型敏感行为 | 默认关闭；启用前需使用者明确知悉环境 |

**若要用于启用 BattlEye 的环境**：必须整套禁用 UI 与输入层（`A3MCP_UI_CONTROL=0`、
`A3MCP_INPUT_INJECT=0`），并且只保留只读或低风险写操作。这一点写在 `README.md` 首段，
不依赖使用者自觉。
