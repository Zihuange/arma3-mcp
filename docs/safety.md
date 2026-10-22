# 安全模型

本服务器面向**使用者自控的环境**，设计前提是：工具调用方的意图由使用者负责，
但**能力边界必须由服务器强制**——因为参数来自 LLM，不能假设它总是写对。

## 四级分级

| 级别 | 含义 | 默认 | 放行条件 |
|---|---|---|---|
| `read` | 只读查询与本地纯计算 | 放行 | `ALC_ENGINE_READ=1`（默认 1） |
| `write` | 改变游戏世界（含 UI 改动） | 放行 | `ALC_ENGINE_WRITE=1`（默认 1） |
| `exotic` | 凭空生成资源 / 网络协调 / 调试后门 | **拒绝** | `ALC_ENGINE_EXOTIC=1`；作弊类另需 `ALC_ALLOW_CHEAT=1` |
| `forbidden` | 动态代码执行面 | **永远拒绝** | 无——任何开关都放不开 |

分级对每条命令**逐一**判定，规则实现在 `guard/gates.py::classify`，
依据是命令名前缀与显式清单；未列入清单的命令按保守方向归类（CBA/ACE 函数默认按 `write`，
因为它们的副作用无法静态判断）。

## 硬禁清单（没有例外）

```
动态代码执行：compile / compileFinal / call / spawn / exec / execVM / execFSM
              preprocessFile / preprocessFileLineNumbers / preprocessConfigFile
              loadFile / callExtension
跨机执行：    remoteExec / remoteExecCall / BIS_fnc_MP
官方封装：    BIS_fnc_exec* / BIS_fnc_spawn* / BIS_fnc_dbg_* / BIS_fnc_codePerformance
```

**为什么没有例外**：这些命令的存在意味着"命令名可以是任意的、代码可以是任意的"。
一旦放行，本仓库全部的类型校验、参数校验、风险分级同时失效——
安全模型会从"结构化调用"塌回"任意代码执行"。这是架构的根基，不是一条可调的策略。

`ALC_ALLOW_COMMANDS` 显式白名单**同样无法**解开硬禁（有专门用例守住这条线）。

## 执行链路的四道闸门

```
查库（命令必须存在，不猜名字）
  → 参数校验（个数 + 类型；识别不出的类型如实标注"未校验"）
    → 风险分级（read/write/exotic/forbidden）
      → 通道（未接通则明确报错，不假装成功）
```

任何一步不过，命令**都不会**被发送。`exec` 的 `dry_run=true` 可以走到第三步为止，
把最终负载摊开给人看。

## 输入注入的额外约束（P2）

原生输入注入（鼠标点击、键盘按键）动的是操作系统输入队列，影响范围**超出游戏**：

- 默认关闭（`ALC_INPUT_INJECT=0`）；
- 默认仅前台注入（`ALC_INPUT_FOREGROUND_ONLY=1`）：目标窗口不是本进程窗口时拒绝；
- 只允许作用于**本进程自己的窗口**——这比维护一张窗口标题白名单更硬；
- 文本输入不支持输入法（中文输入不可行），能力矩阵中已如实标注。

## 审计

每次执行与预演写入 JSONL：

```json
{"ts":1757991234.123,"tool":"exec","cid":"c3f9a1b2","cmd":"setPosATL",
 "level":"write","ok":true,"elapsed_ms":41,"channel":"pipe"}
```

落点由 `ALC_AUDIT_LOG` 指定。**审计失败不阻断操作**，但返回值里仍带该行内容，
不会静默丢失。

## 与 BattlEye 的关系

使用者明确：本服务器只在 **BattlEye 不启用**的环境使用（自控单机/自建服务器）。
这一点必须在两类操作上被尊重：

| 操作 | BattlEye 启用时 | 本仓库的处理 |
|---|---|---|
| 引擎层命令（SQF） | 沙盒类命令可能被判异常 | 靠 EXOTIC 闸门与分级控制 |
| 原生输入注入 | 外部输入注入属典型敏感行为 | 默认关闭；启用前需使用者明确知悉环境 |

**若要用于启用 BattlEye 的环境**：必须整套禁用 UI 与输入层（`ALC_UI_CONTROL=0`、
`ALC_INPUT_INJECT=0`），并且只保留只读或低风险写操作。这一点写在 `README.md` 首段，
不依赖使用者自觉。
