# 交接：新会话从这里接上

> 写给**下一个会话**。当前工作区干净，110 个提交，305 项测试通过。

## 零、最重要的一课（上一轮用七次重启换来的）

**SQF 侧的逻辑，先在离线照抄一份测住契约，再上机确认。**

上一轮所有代价都出在同一件事上：SQF 与 MCP 各有一份实现，两边悄悄不一致，
而症状全都表现为"引擎里静默出错但回执 ok=true"。具体是这些：

| 坑 | 症状 | 现在的防线 |
|---|---|---|
| SQF 切分把括号留成 token，MCP `re.split` 丢弃 | 报"call 目标形态无法识别"——**看起来像安全策略在拒绝** | 切分只有一处定义（`knowledge/expr.py::split_tokens`），SQF 照它实现；`TestTokenSplitContract` 锁住 |
| `if (c) then { exitWith {…} }` 引擎报"缺少 ;" | `fn_validate` 加载期即坏 → **第二道防线整个失效**，而回执照样 ok | 改单语句形式 `if (c) exitWith {…};` |
| 给 SQF 白名单 push 一个元素 | 列表从"空"变"非空" → **意外启用全量白名单校验**，全部命令被拒 | 名单的空/非空是有意开关，豁免写在检查处 |
| `_p0` 当变量用 | 带参表达式全部返回 `nil`（回执 ok=true） | MCP 侧展开成 `(_this select N)` |

**排查这类问题的第一动作**：`grep -n "Error" <最新 RPT>`（路径见 `docs/local-setup.md`）。
顶层错误信息通常在游戏侧，不在 MCP 回执里。

## 零之二、文档就是接口：过时描述会把别的会话带偏

两份外部会话的反馈里，**误判都不是它们自己的错**：

| 它们说的 | 真相 |
|---|---|
| "`config_search` 未实现，游戏侧还没做" | 文档里确实写着"实现方式待定"——而它当时**已经实现**（只是有 bug）。读到那句，自然把观察到的异常都归成"没做" |
| "中文注释会造成伪语法错误，SQFLint 却干净" | 我们自己的 `then { exitWith }` 形态问题会造出一模一样的症状。归因到注释，是因为没人告诉他们这个形态坑 |
| "`nearestObjects` 的 types 必须是对象数组" | 命令库原文是 "List of **class name**"；错误表述会让人把对象塞进数组，同样返回 0 |

**所以改行为时，顺手检查有没有文档还在描述旧行为**——尤其：
`docs/config-query.md`（工具能力）、`docs/safety.md`（闸门与白名单）、
`docs/deploy.md`（环境变量）、本文件。留着过时描述，下个会话会照它误判，
而它误判的成本由**你**在下一轮承担（重新解释、重新排查）。

**引擎命令的行为陷阱**（静默返回 nil / 返回错东西 / 命令名根本不存在）见
[`engine-traps.md`](engine-traps.md)——那里逐条标注了来源（【库】= 离线命令库可复现，
【报告】= 外部会话实测、本项目未验证）。查命令行为先看它，别重新踩。

## 零之三、怎么从命令行调 MCP：`tools/mcp_call.py`

**要调 MCP，不一定非得等它出现在你的工具列表里。** 仓库自带一个命令行入口：

```bash
python3 tools/mcp_call.py --list                      # 列出全部工具及描述
python3 tools/mcp_call.py gates_status                # 调一条工具
python3 tools/mcp_call.py exec --args '{"expr": "worldName"}'
python3 tools/mcp_call.py exec --args '{"expr": "_p0 setPosATL _p1", "args": [["u_17"], [1,2,3]]}'
python3 tools/mcp_call.py config_tree --args '{"root": "CfgFunctions"}'
```

**为什么必须知道它**：MCP 工具**可能没注册到当前会话**（外部会话就遇到过），
而 DSH 的 MCP 客户端**连不上时不报错**——只表现为"工具不存在"，于是人根本不知道
该去查什么。这个脚本把那层拿掉：一个 POST 进去，结果直接印出来。

它自己处理了两件容易踩的事：

- **地址不写死**：从 `ip route` 取 WSL 网关（写死 IP 会在重启后失效）；
- **经代理到达 Windows**：`urllib` 会读 `HTTP_PROXY`，而 Node 的 `undici` **默认不读**
  ——这正是 `wsl_forward.py` 存在的理由。所以同一台机器上"curl/本脚本能通、
  DSH 客户端超时"是**正常现象**，不是网络坏了。

退出码：`0` 成功 / `1` 工具返回了错误（业务失败，回执照样打印）/ `2` 连不上或协议错。

**批量场景写脚本调它**，不要手工敲几十次工具调用（外部会话导出 99 个班组时
吃过这个苦头）。`exec_batch` 一次能带 8 条（可提到 32），也优先用它。

---

## 零之四、开源分发重构（2026-10-22）

为公开发布（GitHub + 分发）做的一轮改造。**入口与脚本形态变了，读旧文档时注意**。

### 现在的入口（只有两个）

```bash
python start.py                  # 启动 MCP（stdio 默认；--http 用于跨系统）
python tools/modkit.py pack      # 打包 + 签名 + 校验
python tools/modkit.py deploy    # 部署（PBO 与 .bisign 一起，含签名复核）
```

- **`start.py`** 读 `a3mcp.json`（从 `a3mcp.example.json` 复制）→ 映射成环境变量 →
  启动服务。服务端代码没改：环境变量仍是唯一接口。
- **`start_windows.bat`** 已缩成 3 行封装（只找 python + 转调 `start.py --http`）。
- **已删除**：`start_game.bat`、`server/start_server.bat`（挂载模组改为 README 说明）、
  `pack_mod.sh`、`deploy_mod.sh`（被 `modkit.py` 取代）、`gen_dispatch.py`
  （静态分发方案已被动态表达式取代）、`check_exports.py`、`downgrade_annotations.py`、
  `verify_windows.py`、`dll_smoke.py`、`sqf_syntax_check.py`、`.wslsrv.out`。

### 连接方式（两条独立链路）

| 链路 | 支持 | 默认 |
|---|---|---|
| 客户端 ↔ MCP | `stdio` / `http` | **stdio**（同机时客户端直接拉起，零配置） |
| MCP ↔ 游戏 DLL | `tcp` / `null` | `tcp`（DLL 主动连 32132） |

`pipe` 只存在于历史注释，**没有实现**——旧文档提到它的一律以本表为准。

### 许可与数据（重要）

- 代码 **MIT**（`LICENSE`）；第三方来源见 `NOTICE`。
- **命令库不再包含 BI wiki 的描述正文**（`d` 字段已删，schema 2）。
  `cmd_info` 改为给 wiki 链接（`https://community.bistudio.com/wiki/<命令名>`）。
  **别把它加回去**：`tests/test_data.py` 有反向断言，加了就红。
- 数据体积因此从 309KB 降到 161KB。

### 签名密钥换了

- 现在是 **`arma3-mcp`** 密钥对（旧的是 `BTA`，已移除）。
- 公钥入库：`game/mod/keys/arma3-mcp.bikey`；私钥在本机（`build/keys/`，已 gitignore）。
- 分发者**应生成自己的密钥**：`DSCreateKey <名字>`，然后公钥随发布、私钥不外传。

### 本机信息

- `docs/onmachine.md` → **`docs/local-setup.md`**（开头已声明"作者本机环境，非安装指南"）。
- 现状文档里的本机路径已占位化（`<repo>` / `<user>` / `<Anaconda>` 等）。
- **`docs/decisions.md` 与 `history.md` 保持原样**：它们是历史记录，出现旧文件名与
  旧路径是事实，改了就失真。

### 一个刻意的决定：**没有重写 git 历史**

历史里能看到作者本机用户名与少量二进制（旧 PBO/DLL）。评估后选择不清理：

- `.git` 只有 5.8MB，体积不是问题；
- 历史里**没有真实凭据**（`biprivatekey` 的命中来自 `.gitignore` 规则与文档提及）；
- 重写会改变全部 commit hash，而 `decisions.md` 里大量"见 D 系列/某提交"的引用靠
  的是**内容**不是 hash，但审计与追溯的连续性会受影响；
- `git filter-repo` 在本机不可用。

如果将来确实要清，步骤是：备份 `.git` → `pip install git-filter-repo` →
`git filter-repo --path-glob '*.pbo' --path-glob '*.dll' --invert-paths` →
`--replace-text` 替换用户名 → 全量测试 + 自检验证。

---

## 一、手上的活儿：哪几件已完成、哪件没做

方案：「独立性整改 + 安全模型：把 `call` 从硬禁改为结构化白名单」（已批准）。

### 已完成

| 提交 | 内容 |
|---|---|
| `ea6031e` | `ALC_*` → `A3MCP_*` 全量重命名 + 独立性自检新增"命名层面" |
| `ab2abf8` | bat 自定位（`%~dp0`）+ 自检"启动脚本不得硬编码本仓库路径"（含反向验证） |
| `d2b53df` | 安全模型主体：`call` → `call_gated` + `A3MCP_ENGINE_CALL` + `CALL_DENY`（优先级高于白名单）+ SQF 侧独立实现 + `A3MCP_PROFILE=debug` |
| `6b812b8` | 占位符展开修复（`_p0` 从未绑定）+ 打通 `call` 真引擎执行 + 切分契约统一 + 8 处 SQF 语义修复 |
| 本轮 | `config_search` 的 glob 修复 + `path` 参数；放行引擎隐式变量；启动脚本补通道默认值；`function_list` 实现（第 27 个工具） |

### 还没做

方案里的三件（bat 自定位、安全模型主体、`function_list`）**都已完成**。

**`function_list`（第 27 个工具）已实现**（`game/mod/addons/a3mcp/fnc/fn_fnList.sqf`
+ `adapters/config_tools.py`）。拼接规则是**上机实测**出来的，不是推断——
见 `decisions.md` D39，要点：

  · 函数名 = `<tag>` + `"_fnc_"` + `<叶子类名>`；二级分类（Core/Arrays）**不进名字**
  · `tag` 读**直接子类**的 tag 字段；**没有该字段时用类名**
  · ⚠ `A3` / `A2PMC` 的 tag 也是 **`BIS`**（不是"缺失"）；`Ares` 才是真的没有 tag
  · 函数名查询**大小写不敏感**（D38 里"必须全小写"的说法已就地纠正）
  · 端到端验证过：拼出的 `BIS_fnc_sortBy` 等能 cast 到 CODE，故意拼错的取到 nil

工具不打 tag 时返回**各 tag 的概览**（名字 + 函数数），打 tag 才列函数名——
BIS 的函数有几千个，全量倾泻会把回执撑爆。

## 二、这个项目里容易踩的约定（都是实测踩出来的）

| 约定 | 说明 |
|---|---|
| **`A3MCP_PROFILE=unrestricted` 是"全开"** | 它让硬禁命令 / `CALL_DENY` / 表达式白名单全部失效（`exec` 等于任意 SQF 执行）。**默认关**；开着时 `gates_status` 顶部有 `⚠⚠` 提示、审计每条带 `mode=unrestricted`。排查"为什么这条命令没被拦"时先看它有没有开着 |
| **环境变量前缀 `A3MCP_*`** | 刚改完。独立性自检会**主动拦截** `ALC_`，写回去会失败 |
| **`args` 是扁平列表** | `{"args": ["classes"]}` ✓；写成嵌套 `[["classes"]]` 会让 SQF 侧 `param [0, "", [""]]` 拿到数组，报"类型 数组，预期为 字符串" |
| **`reply.result` 就是负载** | 外面**没有** `{"ok":...}` 包装。`config_tools` 里 `data = reply.result` 直接用；我加过一次多余的 ok 检查，导致 SQF 明明 `ack ok=true`、MCP 侧却报"被拒绝：未知原因" |
| **`@reg.tool` 与 `def` 之间不能插东西** | 插了会让装饰器套到别的函数上，症状是 `xxx() takes 0 positional arguments but 1 was given` |
| **DLL 有两条入口** | MCP 直连（`run_native`，走 JSON）与 SQF 转发（`RVExtension` 的字符串形式）。**改签名两处都要同步** |
| **改完模组要"打包→重签→部署"三件套** | `tools/modkit.py pack --out build/pbo_out`（自动签名）→ `tools/modkit.py deploy`（PBO+bisign 一起拷并复核）。漏任一步都是**静默**失败：PBO 没换=新函数不存在；没重签或只拷 PBO=签名与内容对不上（单机正常、服务器炸）。详见 `deploy.md` |
| **改完 SQF 必须重跑检查** | `python3 .dsh/skills/arma3-sqf/scripts/sqfcheck.py <file>` 与 `sqfapi.py check-file <file>`。⚠ **SQFLint 抓不到**：`then { exitWith {...} }` 的"缺少 ;"、两侧切分不一致、`_wl` 空/非空语义。这些只能靠离线契约测试或引擎日志 |
| **改 SQF 校验逻辑前先跑离线镜像** | `tests/test_expr_guard.py::TestSqfCallTargetContract` 是 SQF `_targetSlotOf` 的 Python 照抄版。改了 SQF 那段就同步改它并先跑测试，**对不上就别上机** |
| **切分规则只有一处定义** | `knowledge/expr.py::split_tokens`。SQF 的 `_splitExpr` 必须与它逐字符等价（分隔符全部丢弃，不留 token） |
| **部署要用 Windows 侧 copy** | WSL 的 `cp` 对游戏目录会失败（沙箱或 drvfs） |

## 三、环境状态（开新会话时可先复核）

```
游戏        : 未运行
MCP 服务    : 未运行（启动方式：python start.py  或  start_windows.bat）
专用服务器  : 已关闭
测试        : 345 项通过
部署的 PBO  : 由 tools/modkit.py pack 产出并签名（密钥 arma3-mcp）
```

⚠ 部署到 `game/mod/addons/a3mcp.pbo` 时游戏会占用它。`pack_mod.sh` 会自动检测并报错；
要先把游戏完全退掉再拷（`taskkill` 未必够——游戏常以更高权限运行，那时只能请人来关）。

启动命令：`<repo>\start_windows.bat`（MCP）、`手动挂载（见 README「挂载模组」）`（游戏）。
游戏进编辑器可以用宏一步做完（见下），不必手动点。

## 四、最近做完的能力（可能对调试有用）

- **`input_macro`**：一次调用执行一串输入操作（`move`/`click`/`dblclick`/`down`/`up`/
  `drag`/`key`/`combo`/`sleep`）。修饰键+鼠标必须用它——分次调用间隔 ~100ms，
  前台与编辑器状态都会变，实测失败过两次。
- **`ui_locate` 的 `list_classes`**：先列控件类名、再按类名精确定位。
  用它拿到了 Eden 工具栏三个变换控件：`WidgetTranslation`(70,41) /
  `WidgetRotation`(117,41) / `WidgetScaling`(164,41)。
- **DIK 表**：`docs/dik.md` + `data/dik.json`（144 个码，取自 Windows SDK 的 `dinput.h`）。

## 五、未闭合的点（诚实记录）

1. **视觉验证仍不可靠**：截图工具能返回 PNG、`read_image` 也能读进来，但**我读不出图中内容**
   （无法从中提取文字或坐标）。所以"点击后画面变成什么样"仍无法确认；
   Eden 的轴拖动 / Scaling / Vertical Mode 三项仍记为未测。
2. **`手动挂载（见 README「挂载模组」）` 返回码 127**：游戏能正常启动，但脚本退出码异常。
3. **`fn_validate` 的纵深防御只是"能跑"**：它现在加载正常、会拒绝被拒的东西（已实测），
   但**没有针对它的验证用例**——它的判据在 SQF 里，MCP 侧的测试覆盖不到。
   要补的话，思路同 `TestSqfCallTargetContract`：离线镜像它的判据。
4. `docs/backlog.md` 里另有两条受阻项（视觉验证、下行队列上限）。
