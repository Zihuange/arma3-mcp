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

**排查这类问题的第一动作**：`grep -n "Error" <最新 RPT>`（路径见 `docs/onmachine.md`）。
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
| **环境变量前缀 `A3MCP_*`** | 刚改完。独立性自检会**主动拦截** `ALC_`，写回去会失败 |
| **`args` 是扁平列表** | `{"args": ["classes"]}` ✓；写成嵌套 `[["classes"]]` 会让 SQF 侧 `param [0, "", [""]]` 拿到数组，报"类型 数组，预期为 字符串" |
| **`reply.result` 就是负载** | 外面**没有** `{"ok":...}` 包装。`config_tools` 里 `data = reply.result` 直接用；我加过一次多余的 ok 检查，导致 SQF 明明 `ack ok=true`、MCP 侧却报"被拒绝：未知原因" |
| **`@reg.tool` 与 `def` 之间不能插东西** | 插了会让装饰器套到别的函数上，症状是 `xxx() takes 0 positional arguments but 1 was given` |
| **DLL 有两条入口** | MCP 直连（`run_native`，走 JSON）与 SQF 转发（`RVExtension` 的字符串形式）。**改签名两处都要同步** |
| **改完 SQF 必须重跑检查** | `python3 .dsh/skills/arma3-sqf/scripts/sqfcheck.py <file>` 与 `sqfapi.py check-file <file>`。⚠ **SQFLint 抓不到**：`then { exitWith {...} }` 的"缺少 ;"、两侧切分不一致、`_wl` 空/非空语义。这些只能靠离线契约测试或引擎日志 |
| **改 SQF 校验逻辑前先跑离线镜像** | `tests/test_expr_guard.py::TestSqfCallTargetContract` 是 SQF `_targetSlotOf` 的 Python 照抄版。改了 SQF 那段就同步改它并先跑测试，**对不上就别上机** |
| **切分规则只有一处定义** | `knowledge/expr.py::split_tokens`。SQF 的 `_splitExpr` 必须与它逐字符等价（分隔符全部丢弃，不留 token） |
| **部署要用 Windows 侧 copy** | WSL 的 `cp` 对游戏目录会失败（沙箱或 drvfs） |

## 三、环境状态（开新会话时可先复核）

```
游戏        : 运行中（本轮验证完留在编辑器里）
MCP 服务    : 运行中，带 A3MCP_ENGINE_CALL=1（用 start_windows.bat 启动）
专用服务器  : 已关闭
测试        : 305 项通过
部署的 PBO  : 与 game/mod/addons/a3mcp/ 源码一致（64813 字节那一版）
```

⚠ 部署到 `game/mod/addons/a3mcp.pbo` 时游戏会占用它。`pack_mod.sh` 会自动检测并报错；
要先把游戏完全退掉再拷（`taskkill` 未必够——游戏常以更高权限运行，那时只能请人来关）。

启动命令：`<repo>\start_windows.bat`（MCP）、`start_game.bat`（游戏）。
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
2. **`start_game.bat` 返回码 127**：游戏能正常启动，但脚本退出码异常。
3. **`fn_validate` 的纵深防御只是"能跑"**：它现在加载正常、会拒绝被拒的东西（已实测），
   但**没有针对它的验证用例**——它的判据在 SQF 里，MCP 侧的测试覆盖不到。
   要补的话，思路同 `TestSqfCallTargetContract`：离线镜像它的判据。
4. `docs/backlog.md` 里另有两条受阻项（视觉验证、下行队列上限）。
