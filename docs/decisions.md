# 设计决策记录

按时间顺序记录**为什么这样做**。凡是"看起来可以更简单"的地方，这里都应有答案；
没有答案的简化就是欠债。

---

## D1 为什么手写 MCP 协议骨架，而不用官方 SDK

**决定**：`mcpcore/` 自己实现 JSON-RPC over stdio（约 200 行）。

**理由**：本仓库的硬约束是"仅标准库"——要能在任何只装了 Python 的机器上跑
（包括 Windows 侧的 Anaconda）。引 SDK 就多一条 pip 依赖链。而本仓库需要的
MCP 面很小：`initialize` / `tools/list` / `tools/call` / 通知收尾。

**代价**：需要自己维护协议细节（帧格式、错误码）。已用 24 个协议层用例覆盖，
且同时支持换行分隔与 `Content-Length` 两种帧格式，对客户端更宽容。

**明确不做**：MCP 的 resources 与 prompts。DSH 的 MCP 客户端只处理
`ToolListChanged`（已核实其源码），实现它们没有消费者，只增加出错面。
`resources/list` 与 `prompts/list` 返回空表而不是错误——部分客户端会无条件探测。

## D2 硬禁命令不接受任何开关

**决定**：`execVM`/`compile`/`call`/`callExtension`/`loadFile`/`remoteExec` 等
一律拒绝，`A3MCP_ALLOW_COMMANDS` 显式白名单也放不开。

**理由**：MCP 工具的参数来自 LLM。一旦命令名可以来自任意字符串，本仓库全部的
类型校验、参数校验、风险分级都会退化为装饰——安全模型会从"结构化调用"塌回
"任意代码执行"。这不是洁癖，是这个架构存在的意义。

**验证**：`tests/test_guard.py::TestGates::test_forbidden_never_allowed_even_with_everything_on`
与 `test_override_cannot_unlock_forbidden` 两个用例守住这条线。

## D3 实体参数用单元素数组承载

**决定**：`[["u_17"]]` 表示实体 u_17；`["u_17"]` 是普通字符串数组。

**理由**：SQF 命令的对象参数都是**位置参数**。让实体写成数组，模型只需记一种语法
（`args=[[实体],[坐标],...]`）。改用对象形式 `{"entity": "u_17"}` 会让同一组参数
里出现两种风格，模型更容易写错。

**代价**：长度为 1 的数组在类型上有歧义（实体还是单元素数组？）。处理方式：
校验层让"长度为 1 的数组"同时满足 `object` 与 `array` 两种期望——只放宽"能不能传进去"，
不放宽参数个数；序列化层再按签名期望的类型决定语义。

## D4 参数校验宽容，但必须如实说"未校验"

**决定**：类型识别不出时**不阻止**执行，但在结果里明确写"该参数未做类型校验"。

**理由**：真实数据里参数类型字段很脏——2072 个参数类型为空串，大小写混用
（`Number`/`NUMBER`），还有拼写错误（`NUMVER`）。假装校验过比不校验更危险：
使用者会以为参数被检查过。

**代价**：可能放过类型错的参数。但下游还有引擎的类型错误（`evt:cmd_error` 类事件）
兜底，比误拒合法调用更可接受——误拒会让工具整体不可用。

## D5 不做"整串扫描找类型词"的兜底

**决定**：类型归一化按"整串 → 别名 → 首词 → 全词匹配"逐级尝试，**但不做**
"字符串里出现类型词就算命中"的模糊扫描。

**理由**：真实数据里有参数名字段被灌进整张 wiki 表格的情形
（`a:\n{! classwikitable …`）。模糊扫描会从表格文本里"认"出一个类型，
把本该"未识别"的参数误标成已知类型——那会让校验误报，还会掩盖数据缺陷。

**这条决策是在测试抓出 790 例误报之后定的**，不是预想的。

## D6 数据文件里的中文一律用「」，不用英文双引号

**决定**：Python 源码内的中文字符串用 `「」` 而非 `""`。

**理由**：`"中文"说"中文"` 会截断 Python 字符串字面量。`tools/build_capabilities.py`
初版因此反复编译失败，我为此浪费了多轮反复修补（试过正则、试过词法扫描，
都因为引号配对跨越相邻字面量而失败）。**正确做法是一开始就别写英文引号**。

**教训**：与其写修补脚本猜字面量边界，不如重写文件。修补的边际收益为负。

## D7 `since` 自动推导，不手写

**决定**：能力矩阵里"所需最低 Arma 3 版本"由依据命令**算出来**（取最晚引入者），
不允许手写。

**理由**：初版手写了 17 条 `since`，核对时被自己的数据抓出 **8 处错误**
（例如 `move_pointer` 写 0.50，但 `ctrlSetMousePosition` 需要 2.02）。
这条信息本来就能从数据算出来，手写只会引入漂移。

**推广**：凡是"能算出来的元数据"都不该手写——手写等于承诺人工同步，
而人工同步一定会过期。

## D8 测试的候选值从类型的允许集合反推

**决定**：全量自检里给参数造候选值，从 `_TYPE_MAP` 的允许 JSON 类型集合反推，
而不是手写"类型 → 值"映射表。

**理由**：手写表必漏。第一版漏掉了 `control`/`waypoint`/`task`/`hashmap` 这些
同样属于"对象引用"的类型，于是测试自己造出整数去要求它们通过，
一次产生 690 例"误报"——测出来的是测试的偏见，不是校验器的缺陷。

**现在的状态**：4337 个有参数的签名，**全部**能找到至少一组通过校验的调用；
这条断言是零容忍的，出现新失败即视为真回归。

## D9 空参数签名与数据缺陷白名单

**决定**：不对数据源自身的缺陷做白名单掩盖，而是**修到零**再收紧断言。

**理由**：开发中曾出现 524 条命令"找不到合法调用"，看似需要白名单。
逐个查下去全是真缺陷：`NIL`/`HashMap` 未映射类型、`null` 不在主类型表、
"类型词写在参数名里"（`(optional) defaultValue - Anything`）未剥离、
复合类型串（`Group, Object or Side`）识别失败。修完之后白名单为空——
**白名单是掩盖问题的工具，能用修解决就不要用它**。

## D10 P0 不接执行通道，且失败必须响亮

**决定**：P0 阶段 `exec` 走 `NullChannel`，返回明确的"未接通、没有发送、没有执行"。

**理由**：一个会静默失败的执行通道比没有更糟——使用者会据此认为游戏内已生效。
同理，`exec` 支持 `dry_run`，把"最终会发给引擎的东西"摊开，让参数错误在通道之前
暴露。

## D11 批量执行默认上限 8 条

**决定**：`exec_batch` 默认最多 8 条，硬上限 32，超限**拒绝**而不是截断。

**理由**：游戏侧下行队列有容量上限且**满时丢弃最老的命令**（其它项目的实测结论，
见 `provenance.md`）。超量下发会导致旧命令静默消失且**无任何回报**——
那会让上层得出完全错误的结论。宁可拒绝并解释，也不制造"命令凭空丢失"。

（该上限值待 P1 上机实测后按真实队列容量调整。）


## D12 通道方向反转：MCP 当 TCP 服务端，游戏连回来（推翻原"命名管道"设计）

**背景**：原计划（见 `docs/deploy.md` 早期版本）是命名管道 + DLL 做服务端。
落地前先做了连通性实测，结果推翻了它。

**实测结果**（WSL2 NAT 模式，本机）：

| 方向 | 结果 |
|---|---|
| WSL → Windows 的 `127.0.0.1` | **连不上**（Connection refused） |
| Windows → WSL 的 IP | **能连**（源地址是网关 `192.168.160.1`） |

**决定**：MCP 侧（跑在 WSL）做 TCP **服务端**，游戏进程内的扩展 DLL 主动连回来。

**两条被否掉的方案及其原因**：
1. **命名管道**：除了方向问题（管道同样必须由游戏侧发起），还有一条硬事实——
   WSL 侧的 Python **根本访问不到 Windows 命名管道**
   （`multiprocessing.connection` 的管道地址只在 Windows 上有效，而 MCP 服务器不在 Windows 上）。
2. **MCP 做客户端连游戏**：方向被 NAT 堵死，实测已排除。

**代价与缓解**：
- 服务端必须监听 `0.0.0.0`（只绑 `127.0.0.1` 则 Windows 连不进来）；
- 缓解：协议里有 token 握手（默认 `arma3-mcp-local`，可配 `A3MCP_TCP_TOKEN`），
  且 WSL2 NAT 本身不把该端口暴露给局域网；
- 真实 DLL 上机时需再确认一次 Windows 防火墙是否放行（连出方向通常无碍）。

**方法论收获**：涉及跨系统边界的架构决策，先花 5 分钟做连通性实测，
比写完代码再发现方向不对便宜得多。这次的实测把一个"看起来优雅"的方案
（命名管道、同机无端口）换成了"确实可行"的方案（TCP）。


## D13 把 MCP 移到 Windows 侧运行——彻底消除跨系统连接问题

**问题**（由 D12 引出）：MCP 跑在 WSL、游戏跑在 Windows，于是必须依赖
"Windows 能连 WSL"这条单向通路，代价是一串绕行：WSL IP 会变、服务端只能绑
`0.0.0.0`、用不了 Windows 命名管道、多一层 NAT 转发。

**决定**：MCP 服务器改在 **Windows 侧**运行（`<Anaconda>\python.exe`）。
游戏与 MCP 于是处在同一个网络栈：`127.0.0.1` 直连，命名管道也可用，
不需要任何跨系统绕行。

**为此刻意付出的两处改动**：

1. **源码降到 Python 3.9 语法**。Windows 侧只有 Anaconda 的 3.9.7，而仓库原本
   用了 42 处 `X | None`（PEP 604，3.10+）。用 `tools/downgrade_annotations.py`
   基于 **ast 定位注解区间**做改写（不是全文正则——`|` 在布尔表达式与字符串里
   都会出现，全文替换会改坏代码），改写为 `Optional[X]` / `Union[...]`。
   代价：少了一点语法糖。收益：同一套代码在两个平台各 150 个测试全绿。
2. **`SO_EXCLUSIVEADDRUSE`**。Windows 上 `SO_REUSEADDR` 的语义与 Unix **相反**：
   它允许另一个进程绑定同一端口并静默抢走连接。测试抓到了这点（"端口被占用应
   报错"在 Windows 上失败），故 Windows 用独占绑定、Unix 用 `SO_REUSEADDR`。
   → 这类差异只有真在目标平台跑测试才会暴露，靠读文档想不到。

**为什么不干脆两边都支持**：现在是两边都支持（代码跨平台、测试两平台全绿），
只是**部署位置**选了 Windows。若哪天要在 WSL 侧部署，`A3MCP_CHANNEL=tcp` 配 D12 的
方向即可，无需改代码。

**验证**：`tools/verify_windows.py` —— 一条命令自检 Windows 侧环境
（解释器版本、xz 解压 5181 条、中文渲染、MCP 启动与工具注册、TCP 通道本机
`127.0.0.1` 可连、握手拿到 `hello_ack`）。


## D14 撤回 D13：MCP 不能跑在 Windows 侧（WSL 内的 Node 无法执行 .exe）

**背景**：D13 为了消除跨系统连接问题，把 MCP 部署到 Windows 侧（与游戏同网络栈）。
部署后 DSH 重启，**工具全部消失**。

**根因（实测，非推断）**：本机 DSH 是**跑在 WSL 里的 Node 进程**，而
**WSL 里的 Node 无法执行 Windows 程序**。用 Node 的 `child_process.spawn`
逐个变体实测：

| 变体 | 结果 |
|---|---|
| `spawn('H:\\Program Files\\Anaconda3\\python.exe')` | **ENOENT**（路径确实存在） |
| `spawn('/mnt/c/Windows/System32/cmd.exe', ['/c', ...])` | 启动后无任何输出（超时） |
| `spawn('/mnt/c/Windows/py.exe', ...)` | 同上，无输出 |
| `spawn('/usr/bin/python3', ...)` | **正常**（exit=0，输出正确） |

关键区分：在**交互 shell** 里 `py.exe` 能跑（WSL interop 经 binfmt_misc 生效），
但在 WSL Node 进程的 `spawn` 里走不通——**interop 不是 Node 子进程继承的能力**。
这条差异极易误判：同一个命令在终端里试是通的，在 DSH 里就是起不来。

**决定**：撤回 D13，MCP 回到 **WSL 侧**运行；跨系统连通性按 D12 的方案解决——
**游戏侧 DLL 主动反连 WSL 的 IP**（实测 Windows → WSL 可达）。

**代价（比 D13 方案多出来的部分）**：
- 游戏侧需要知道 WSL 的 IP，且该 IP 会随 WSL 重启变化 → MCP 在监听时把
  当前地址写到一个游戏侧可读的文件，由 `-init=` 注入的脚本读取（P1 落地）；
- 服务端需绑 `0.0.0.0` 而非 `127.0.0.1`（Windows 侧要能连进来）→ 用 token 握手兜底。

**保留的成果**：D13 期间做的**跨平台兼容工作不撤**——
- 源码仍是 Python 3.9 可解析（`tools/downgrade_annotations.py`）；
- `SO_EXCLUSIVEADDRUSE` 的平台分支保留；
- `tools/verify_windows.py` 保留（Windows 侧的健康自检仍有价值，
  例如将来用 PyInstaller 打成独立 exe、或以别的方式在 Windows 侧跑时能直接用）；
- 两个平台各 150 个测试全绿的状态保持。

**方法论收获（比结论更值钱）**：改部署位置这类改动，**先验证目标运行时能否被启动**，
再动配置。这次的教训是——"某命令在终端里能跑"与"它能被我们的宿主进程启动"
是两件事，差距就在 interop / 解释器解析这类边界上。


## D15 恢复 Windows 侧部署——改用 HTTP 传输（D14 的出路）

**问题的出路**：D14 确认"DSH 用 stdio 启动 Windows 进程"不可行（WSL 的 Node
无法执行 .exe）。但 MCP 客户端还支持另一种传输：**`streamable-http`**。
把它用起来，就不需要 DSH 启动任何进程——**用户手动启动服务端，DSH 连过来**。

**先做连通性实测（吸取 D14 的教训：部署前先验证目标运行时/网络）**：

| 方向与绑法 | 结果 |
|---|---|
| Windows 服务绑 `127.0.0.1`，WSL 访问 | **不可达** |
| Windows 服务绑 `0.0.0.0`，WSL 经**网关地址**访问 | **可达**（`curl` 成功） |

**端到端验证**（WSL 侧对 Windows 侧运行的 MCP）：
`initialize` 200 且协议版本回显正确、`tools/list` 返回 10 个工具、
`tools/call` 正常返回 —— 全部通过。

**决定**：
- MCP 以 `--transport http` 运行在 Windows 侧，绑 `0.0.0.0`；
- DSH 侧用 `transport: streamable-http` + `url: http://<Windows的vEthernet(WSL)地址>:32128/mcp`；
- 新增 `serve_http.py`（打印 DSH 该填的地址）与 `start_windows.bat`（双击即启动）。

**HTTP 传输的实现取舍**：采用**无状态 JSON 响应**模式（POST 进、JSON 出，不开 SSE）。
MCP 的 Streamable HTTP 允许服务端直接回 JSON；本服务器的工具无跨请求会话状态，
无状态实现更简单、也更好排查。另有两个刻意的行为：
- `GET /mcp` 返回 **405 并说明不推送**，而不是挂住连接——挂住会让客户端误以为
  支持 SSE 而一直等待；
- 工具失败返回 **200 + isError**，不是 HTTP 错误码——部分客户端把非 2xx 当传输
  故障并断开，那会把"工具报错"升级成"服务器不可用"。

**代价与残留风险**：
- 需要用户**手动启动**（一次双击），不像 stdio 那样自动拉起；
- DSH 配置里的 IP 在 WSL 重启后**可能变化** → 重跑启动器取新地址；启动器会明确打印；
- Windows 防火墙可能对新监听的端口弹窗，需允许（首次）。

**两种方式都保留**：WSL stdio 方式（D12）在配置里以注释形式保留，随时可切回。


## D16 最终打通：直连失败的真凶是 Windows 防火墙（不是代理、不是 Node）

**现象**：D15 之后 DSH 仍连不上 Windows 侧的 MCP（工具不出现）。
逐层排查的结果**推翻了几次中间结论**，值得完整记录：

| 探测 | 结果 |
|---|---|
| `curl http://192.168.160.1:32128/health` | **200**（看起来"通了"） |
| `curl --noproxy '*' 同一地址` | **超时** |
| Python `socket.connect` 同一地址 | **超时** |
| Node（`net` / `http` / `fetch`）同一地址 | **超时** |
| Python 经代理 `192.168.160.1:7897` 用 `CONNECT` | **200 Connection established** |

由此曾误判为"WSL 只能经代理到达 Windows"，并据此写了 WSL 内转发器方案。
**真正的差异是那次 curl 走了代理**——代理在 Windows 本机上，它转回本机
`32128` 自然通；而直连被 **Windows 防火墙丢弃**（防火墙丢弃的特征是
**超时而非拒绝**，这一点极具误导性：看起来像网络不通，其实是策略拦截）。

**决定性实验**：用 `netsh advfirewall firewall add rule name=arma3-mcp
dir=in action=allow protocol=TCP localport=32128` 放行后，
WSL 直连**立刻成功**，且 **Node 的 fetch（undici，即 DSH 的处境）也成功**。

**最终方案**（比 D15 的转发器干净得多）：
- Windows 侧跑 MCP（`start_windows.bat` → `serve_http.py`, HTTP 传输）；
- 为该端口加一条 Windows 防火墙入站放行规则；
- DSH 直接 `transport: streamable-http` + `url: http://<vEthernet(WSL)地址>:32128/mcp`；
- **转发器（`wsl_forward.py`）保留但不再需要** —— 它仍有价值：换端口且不方便
  改防火墙时，可用它经代理转发；代码与用法保留在仓库中。

**方法论收获（这一轮最大的教训）**：
1. **不要用 `curl` 判断"网络是否直连可达"**——它会读 `HTTP_PROXY`，而
   `Node` 的 `undici` 默认不读。两者行为不同，用 curl 的"成功"推断 Node 的
   可达性，会把结论带偏一整轮。判断直连必须用 `--noproxy '*'` 或直接用
   与目标运行时相同的栈（本例用 Node）验证。
2. **超时 ≠ 网络不通**。防火墙丢弃（DROP）表现为超时，与路由不可达难以区分；
   而 `refused` 才是"没有监听"。遇到"curl 通但 Node 不通"这类矛盾，
   先怀疑**路径不同**（代理、IPv4/IPv6、绑定地址），再怀疑策略层。
3. 涉及系统策略（防火墙/权限）的改动，**先做一次实证再写代码**——
   这次的转发器方案就是没实证到最后一步的产物（虽然它作为备选仍有价值）。

---

## D17 诊断工具不能依赖它要诊断的东西（status 直连 + 执行器心跳）

**现象**：`game_link` 是排查"命令为什么不通"的工具，但它自己**永远超时**，
而且失败方向指向 DLL（`inbox` 堆积被读成"TCP 送不到"）。现场证据：
`game/mod/arma3_mcp_diag.txt` 里 `inbox=3`，而 `last=` 正是那条 status。

**根因**：DLL 有两条命令路径，由 `is_native_command()` 白名单决定走哪条：

- 在名单里 → DLL 自己处理（输入、截图、窗口），不看游戏世界里有没有人；
- 不在名单里 → 进 `g_inq`，等 SQF 执行器取走。

`status` **漏在名单外**。于是它排队等执行器——而执行器没跑，恰恰是它最该派上
用场的时候。**要查不通的原因，得先用一个不通的工具。**

**决定**：

1. `status` 加入直连白名单：DLL 自己的状态自己答。
2. 新增**执行器心跳**：SQF 每轮 `poll` 刷新一个时间戳，`status` 返回
   `poll_ms_ago`（`-1` 表示从未 poll 过）。

**为什么必须有心跳**：`connected=true` 只说 DLL 连上了 MCP，**不**说游戏里有人
在执行命令。两者混为一谈时，状态页显示"已接通"而 `exec` 一路超时，两端日志都
看不出问题。心跳把"有没有人接电话"从猜测变成可观测量：

| poll_ms_ago | 含义 | 处置 |
|---|---|---|
| 小于阈值 | 执行器正常 | 无 |
| `-1` | 从未 poll：执行器从未启动（主菜单／未加载任务） | 确认是否符合预期，再进任务 |
| 大于阈值 | 心跳停滞：启动过但卡住或已退出 | 查 RPT 与 supervisor 日志 |

旧版 DLL 不返回该字段时，`adapters/health.py` 如实报"未知"而**不拿 inbox 猜**——
`inbox=0` 既可能是"刚取完"，也可能是"从来没有过执行器"。

**顺带**：`exec` 超时的错误信息里现在直接附上诊断结论。失败要响亮，也要可解释。

---

## D18 冒烟测试必须与真实服务隔离：改写默认端口，而不是"小心一点"

**现象**：`tools/dll_smoke.py` 要加载 DLL，而 DLL 在 `DllMain` 里就开始连
`127.0.0.1:32131`；同时 MCP 的 TCP 通道**只保留一个活跃连接，新连接顶掉旧的**
（`adapters/tcp_channel.py`）。

**后果**：照原样跑冒烟测试，会把**正在运行的游戏**踢下线。而且它不报错，
表现为游戏忽然失联——极难联想到是"跑了个测试"。

**被否掉的方案**：先加载再 `configure` 改地址。不行——连接在 `DllMain` 里就发起，
调用 `configure` 时握手可能已经完成，这个竞态窗口消不掉。

**决定**：加载一份**改写了默认端口**的副本。默认端口是 `.rdata` 里的 5 位 ASCII
字面量，做**等宽**替换（`32131` → `32199`）不破坏二进制布局；脚本先断言该字面量
恰好出现 1 次，避免误替换。

**结果**：测试跑在自己的私有端口上，真实服务不受影响——实测跑完后
`connects` 仍为 1，即游戏的连接从未被替换过。

**方法论**：破坏性的测试不该靠"记得先关掉什么"来保证安全，要让它在设计上
**碰不到**生产资源。

---

## D19 主菜单启动执行器：用 toString 绕开引号，用重试绕过编译时机

**背景**：`-init=` 能把代码提前到游戏启动阶段运行，于是"主菜单下也能截图/注入输入"
成为可能。但执行器（SQF 轮询循环）此前只在**任务加载后**由 preInit/postInit 拉起，
主菜单下 `exec`／`config_*` 一律不可用——而这恰恰是 `config` 查询与 UI 控件操作
本来有意义的地方。

**两道拦路虎**：

1. **引号**。`-init=` 的字符串要经过 cmd.exe 与引擎两轮参数解析，其中出现的引号
   会被吃掉（实测 RPT 报 `Error: missing '`）。于是任何需要字符串字面量的代码——
   包括调用 `a3mcp_fnc_init`——都写不出来。
2. **时机**。`-init=` 跑得极早（CBA PreStart 之后、UI 存在之前），此刻模组的
   CfgFunctions 可能尚未编译，`a3mcp_fnc_init` 可能根本不存在。

**决定**：

1. 所有字符串用 `toString [字符码]` 构造，`-init=` 里**一个引号都不出现**：
   扩展名、函数名、日志标记全是字符码数组，集中定义在 `start_game.bat` 并逐条注释。
2. 用 `spawn` 起一个**带重试的启动器**：每秒查一次 `missionNamespace`，最多等 60 秒，
   拿到就 `call`，拿不到就写日志。
   重试必须放在 `spawn` 里——`sleep` 的文档明确要求可中断上下文
   （"Must be called inside of a context which is interruptible, i.e. a script
   executed by execVM or spawn"）。

**为什么结果要写进 RPT**：这两种拦路虎的失败都是**静默**的，靠猜没有意义。
启动器写下 `A3MCP-BOOT`／`A3MCP-FN-OK`／`A3MCP-NOFN`，一次重启就能回答
"主菜单阶段到底拿不拿得到模组函数"，而不是继续猜。

**语言层面的两个坑（已查证，不是凭记忆）**：

- `isNil "a3mcp_fnc_init"` 这种写法用不了了（引号会被吃掉），而 `isNil` 直接吃
  `getVariable` 的返回值又有语法歧义——它有两个签名，分别吃 String 与 Code。
  最终用 `isNil { missionNamespace getVariable _fn }` 的 Code 形式，语义无歧义。
- `exitWith` 的语义按文档是"exits the current code scope … used for exiting do"，
  在 `while` 的 `do` 块里用它跳出循环是正确用法。

**检查**：`-init=` 的实际取值是从 `start_game.bat` **展开**出来后送去静态检查的
（而不是检查一份手写副本），确保"检查的就是要部署的那一行"：
SQFLint 无 error/warning，`sqfapi.py check-file` 未发现未知命令名。

---

## D20 实测结论：主菜单阶段拿不到模组 CfgFunctions（-init= 路线到此为止）

D19 决定用 `-init=` 在主菜单拉起执行器，并用同步探针把答案取回来。实测结果
（`game_events` 读到，经 DLL 的 `push` 通道送回）：

| 探针 | 结果 | 含义 |
|---|---|---|
| P1 | **出现** | `-init=` 的同步部分确实执行了，push 通道可用 |
| P2N | **出现** | **`a3mcp_fnc_init` 在主菜单阶段不存在** |
| P3 | 未出现 | 走了 P2N 分支，没有可调用的函数 |
| P4 | **未出现** | `spawn` 的代码块确实不会在这里被执行 |

RPT 时间线印证：`CallExtension loaded: arma3_mcp`（15:04:24）就在 `-init=` 执行
的那一刻，而引擎此时仍在加载动画资源，**调度器尚未运行**。

**结论（硬事实，不再是猜测）**：

1. **主菜单下模组的 CfgFunctions 没有编译**，`a3mcp_fnc_init` 之类的符号不存在。
   所以"用 -init= 在主菜单启动 SQF 执行器"这条路**走不通**——不是写法问题，
   而是引擎行为：CfgFunctions 的编译由 preInit/postInit 驱动，而那两个是
   **任务作用域**的事件。
2. `spawn` 在 `-init=` 阶段**静默失效**：不报错、不延迟执行，就是不发生。
   任何依赖调度器（`sleep`／`waitUntil`／异步代码块）的写法都不能放在这里。
3. `-init=` 里**确实可用**的是：同步表达式与 `callExtension`——也就是 DLL 直连
   能力（截图／输入／窗口）以及 `push` 上行通道。

**探针保留**：`start_game.bat` 里的探针留在原地。它很便宜，而且将来若引擎或
CBA 行为变化（或有人给模组补上 preStart 机制），启动时立刻就能看出来，
不必再猜一次。

**下一步方向**：执行器只在任务加载后可用，而"进入任务"这一步本身可以用**已经
可用的 DLL 直连输入注入**来完成——不必再跟 `-init=` 较劲。

---

## D21 执行器首次真机跑通后暴露的两个 bug

进编辑器（用输入注入点进去的，见 D20 的后续）让执行器第一次真正跑起来，
于是两个**一直存在、但在执行器不跑时永远看不见**的 bug 立刻现形。

### 1. 表达式校验的收尾分支漏了白名单守卫（功能级，影响最大）

`fn_validate.sqf` 里，循环内那条检查有 `(count _wl) > 0` 守卫：

```sqf
if ((count _wl) > 0 && { !(_low in _wl) }) then { ... }
```

而循环后的**收尾分支**（处理"表达式以标识符结尾"的情况）漏了同一个守卫：

```sqf
if ((!((_low select [0, 2]) == "_p")) && { !(_low in _wl) }) then { ... }   // 旧
```

MCP 侧不传白名单（`exec` 的 args 只有 `[expr, args]`），所以 `_wl` 是空数组，
`_low in []` 恒为 false、`!false` 恒为 true —— **任何以词字符结尾的表达式都被
误判成"标识符不在白名单内"**。

破坏面比看起来大：词法切分把数字也算作词的一部分（这是为了 `_p0` 不被切成
`_p`，见该文件注释），于是 `(allUnits) select 0` 末尾那个 `0` 会被当成
"标识符 0"。实测两条表达式都倒在这里：

| 表达式 | 实际报错 |
|---|---|
| `worldName` | 标识符 worldName 不在白名单内 |
| `(allUnits) select 0` | 标识符 0 不在白名单内 |

**结论：动态表达式功能在该配置下几乎整体不可用。** 修复即补上守卫。

### 2. 协议层消息被当成命令塞进了 SQF 队列

`handle_server_line` 原先的逻辑是"不是直连命令就入队"，于是 MCP 的
`hello_ack`（握手回复）也进了队列。表现：

```
[A3MCP] cmd <- {"t":"hello_ack",...}
[A3MCP] ack -> cid= ok=false          ← cid 为空
```

每次连接必然发生一次：浪费一轮执行、产出一条 cid 为空的失败回执，而空 cid
的 ack 还会去撞 MCP 侧的回执配对。症状离原因很远，所以修复处留了注释说明
它为什么必须留着。

顺带解释了此前反复出现的 `inbox=1`／`inbox=2`——那两条"神秘命令"就是
`hello_ack`，每次连接一条。

两条修复都已加回归断言：DLL 侧用 `dll_smoke.py`（"protocol message not
queued"，第二次 poll 必须为空），SQF 侧靠实际执行验证。

---

## D22 exec 全链路真机闭环；config 查询路径另行卡住

修完 D21 的两个 bug、并同步了 `_x64` 副本（此前引擎一直加载着旧 DLL）之后，
重新走了一遍：主菜单 → 点"编辑器" → Enter → 进编辑器。

**结果**：

| 检查项 | 结果 |
|---|---|
| 执行器启动 | ✅ `[A3MCP] 执行器已启动（poll 周期 0.1s）` |
| `hello_ack` 噪音 | ✅ 消失（此前每次连接必现；`inbox` 也首次稳定为 0） |
| `exec` 表达式校验 | ✅ `worldName` 不再被误拒 |
| **`exec` 全链路** | ✅ **`已执行（cid=…，100 ms）结果：{"v":"Stratis","t":"text"}`** |
| 回执解析 | ✅ 正常（此前那次"看起来是合法 JSON 却解析失败"未复现） |

**至此 P1 主线（MCP → DLL → SQF → 引擎 → 回执 → MCP）在真机上完整走通。**

**但 `configQuery` 是另一条路，它卡住了**：游戏侧日志显示命令已收到
（15:57:28 `cmd <- …configQuery…`），此后**既没有 ack、也没有错误**，
`已执行` 计数也没有增加。也就是说它既没走通、也没抛到能被 catch 的地方 ——
与 `exec` 那条路（有 `ack ->` + `push ->` 日志）形成鲜明对比。

这条路径**尚未排查**，属于已知未完成的独立问题。

> **后续（D23）**：已排查并修复 —— 是两层 bug（MCP 侧参数位置错位 +
> `configClasses` 少传 condition），现已全线通过。

---

## D23 config 查询卡住：两层 bug，都只在真机显形

D22 记下"configQuery 收到命令后毫无反应"。排查发现是**两层**独立缺陷叠在一起，
而两层的失败模式完全一样（没有 ack、没有 `[ERR]`、计数器不动），所以第一次
看到时误以为是"configClasses 太慢"。

### 第一层：MCP 侧参数位置错位

`config_tools.py` 构造 args 时写的是"有 keys 才 append(keys)，有 limit 才
append(limit)"，而 SQF 侧按**固定位置**读 `[root, 路径, op, keys, limit]`。
keys 为空、limit 有值时 args 只有四个元素，limit 落进了 keys 的位置；
`param [3, [], [[]]]` 期望数组却收到数字，直接抛异常。

修：无条件占满五个位置。

### 第二层：SQF 侧 configClasses 少传 condition

修完第一层后 args 正确到达（`["CfgVehicles","","tree",[],8]`），但查询依旧失败。
RPT 给出：

```
Error configclasses: 类型 Config entry，预期为 数组
File a3mcp\fnc\fn_configQuery.sqf..., line 47
```

line 47 是 `} forEach (configClasses _cfg);`。查离线命令库，签名是**双参数**：

```
condition configClasses config   (condition: String, config: Config) -> Array
```

少传 condition，第一个位置收到 config，类型不符。两处（tree / search）都补上
`"true"`。

### 教训：被 catch 吞掉的异常会伪装成"慢"

fn_loop 用 try/catch 包住每条命令，这是对的（一条坏命令不该杀死循环）。但
catch 里只 diag_log 了 `[A3MCP][ERR]`——而这两层缺陷都发生在**能被引擎报错但
不一定进到 catch** 的路径上，于是外部观察到的现象是"命令收到了、然后什么都没
发生"。**下次遇到"无响应"，先翻 RPT 的 SQF 错误堆栈**，不要先假设是性能问题：
两者在客户端看起来一模一样。

另外值得记的是测试为什么没抓到第一层：假游戏端的 handler 对 keys 做了
`isinstance(..., list)` 容错，而真端会抛异常——**假端比真端宽容，恰好掩盖了
真端会炸的东西**。已补一个直接断言负载形状的测试类。

**D23 后续：修复后的实测结果（2026-09-25）**

两层修完、PBO 重新部署后，config 查询全线通过：

| 工具 | 结果 |
|---|---|
| `config_tree(CfgVehicles)` | ✅ 返回子类列表，**共 8568 项** |
| `config_class(CfgVehicles, [B_MRAP_01_F])` | ✅ 父类 + 继承链 + 17 项属性，并如实列出不存在的属性 |
| `config_search(CfgVehicles, "B_MRAP*")` | ✅ 匹配 3 项（遍历基数 8568） |
| `config_value(…, displayName/armor/maxSpeed)` | ✅ 三个值都正确 |
| `exec("worldName")` | ✅ 回归通过（101 ms，返回 "Stratis"） |

**顺带回答了 `onmachine.md` 里挂了很久的那个性能疑问**：`configClasses` 对
`CfgVehicles` 这样的大子树（8568 个子类）遍历一次**能在 MCP 的 5 秒超时内完成**，
所以"DLL 侧一次遍历、结果给 MCP 缓存"的设计成立，暂不需要改成分页。

---

## D24 P2 的 UI 能力边界：读得到，写不动引擎内建 UI

执行器跑起来之后，终于有条件实测 P2 的 UI 控件操作。结论与能力矩阵的指引一致，
但补上了矩阵里没有的**实测边界**。

**读 UI：可行。** 编辑器里 `allDisplays` 返回 2 个 display（分别 321 / 144 个控件），
控件树读得出来：

```
[ctrlClassName … select 0..4] -> ["Map", "MouseArea", "ScrollBlockTop",
                                  "ScrollBlockLeft", "ScrollBlockRight"]
```

即编辑器中间那块地图及其滚动块。`ctrlText` / `ctrlClassName` 都能正常取到值。

**写 UI：对引擎内建控件无效。** 对 `ScrollBlockTop` 调 `ctrlSetText` 返回正常
（nil，无报错），但读回仍是空字符串——**写入被引擎忽略，且不报错**。这正是
能力矩阵把 `activate_control` 标为"半支持"的同一类问题：编辑器 UI 是引擎原生
的，不是 SQF 建的控件。

**由此定下 P2 的策略**：

| 目标 | 手段 |
|---|---|
| 操作**已有** UI（含插件/mission 的对话框） | **坐标点击**（`input_click`，已可用）+ 用 `ctrlClassName`/`ctrlText` 读控件辅助定位 |
| **读** UI 结构与状态 | `allDisplays` / `allControls` / `ctrl*` 读命令，可用 |
| 改控件值 | 只对**自己创建的**控件可靠（`createDisplay`/`createDialog`，见能力矩阵 open_ui） |
| 触发按钮 | **不要**指望 `ctrlActivate`：它只触发引擎内建动作（ok/cancel），不触发自定义按钮的事件处理器 |

**一条方法论**：写类操作"不报错但没生效"这种失败模式，只能靠**读回校验**发现。
所以 P2 的每个写操作都应该配对一次读回——否则会得到"看起来成功了"的假象。

---

## D25 P2 收尾实测：坐标校准闭环，失败回执不再丢失

三件事在真机上验完（编辑器内，执行器运行中）：

| 验证项 | 结果 |
|---|---|
| **失败回执（MCP 侧拒绝）** | ✅ `表达式校验未通过：表达式过长（507 字符，上限 400）` **62 ms** 送达（此前必然超时 8 秒） |
| **失败回执（游戏侧拒绝）** | ✅ `config 查询失败：config 路径不存在…` **104 ms** 送达 |
| **坐标校准** | ✅ `ui_locate` 返回 `Map` 控件屏幕中心 **(680, 407)**，与离线按公式算出的数字完全一致 |

坐标那一条是关键：`(680, 407)` 是纯计算得来、没见过真机的数字，真机对上就说明
`ctrlPosition` 的归一化→屏幕换算（含客户区原点）是对的。

**附带修掉一个配额语义错误**：`ui_locate` 的 `max_scan` 原本是**全局**配额，
第一个 display（编辑器有 321 个控件）会一次吃光 40 的额度，后面的 display 一个
控件都扫不到——目标是 `Map` 却在第二个 display 里，表现为"明明存在却报没有匹配"。
改成**每个 display 独立配额**。

至此 P2 的能力面确定下来：输入注入、截图、坐标校准（`ui_locate`）都可用；
UI 写入仅对自建控件可靠（D24）。

---

## D26 P3 起步实测：形态判定不误判，配额按 display 生效

| 验证项 | 结果 |
|---|---|
| 客户端**不被误判**为无头 | ✅ `screenshot` / `ui_locate` 都正常工作（有窗口 → 允许 UI 操作） |
| `ui_locate` 配额按 display | ✅ `scanned: 80`（40 + 40），并找到 display 1 里的 `Map` |
| 坐标校准（复测） | ✅ 仍是 **(680, 407)**，与离线计算一致 |
| 耗时 | 2.43 s（扫 80 个控件） |

**教训（同一个地方栽了两次）**：配额从全局改成"每个 display 独立"之后，我漏删了
外层循环里那个 `if truncated: break` —— 改了配额，行为却没变，真机上
`scanned` 仍是 40 才现形。所以"改对了"和"改到位了"是两件事，中间还隔着一处
没删干净的分支。**把验证判据写成具体数字**（这里是 80）比"看它能不能跑"可靠
得多：数字对不上时能立刻定位，不必从现象反推。

配合新增的 5 条扫描范围测试（含反向验证），这类"改坏也不报错"的缺陷现在有了
守门人。

---

## D27 专用服务器实测：两个"猜出来的判据"都错了

P3 在真实 `arma3server_x64.exe` 上跑起来后，形态判定连着栽了两次，两次都是
**我按经验猜、而没先去问真实环境**。

### 1. 服务器控制台不是 `ConsoleWindowClass`

原先 `find_game_window()` 只按"属于本进程 + 可见 + 客户区最大"挑窗口。服务器
上唯一可见的窗口是控制台，于是它当选：截图**拍到了控制台**（402x154 的
"Arma 3 Console"），`window_info` 报告控制台尺寸，而形态判定依赖的"找不到游戏
窗口"永远不成立 —— 整条 P3 判据随之失效。

我先按类名排除 `ConsoleWindowClass`（标准控制台），**猜错了**。实测它的真实类名：

```
class='#32770'  client=402x154  title='Arma 3 Console version 2.22.154045 x64 :'
```

`#32770` 是 Windows 的**对话框类** —— Arma 3 把服务器控制台做成了对话框。
最终改用**进程名**（`arma3server*`）判断：进程叫什么就是什么，不会骗人。

### 2. 形态缓存按通道对象做键，重连后不失效

修好 DLL 后截图仍被旧逻辑放行，因为 `_UI_CACHE` 用的是 `id(chan)`：游戏从客户端
换成服务器时 DLL 重连了、但通道对象没变，缓存里仍是"有 UI"。

改成 `(id(chan), connects)`，其中 `connects` 来自 `status` —— **重连即自动失效**，
不需要谁记得手动清。（`forget_ui_cache()` 保留，用于显式刷新。）

### 顺带解决的

`-autoInit` 在服务器上被跳过（控制台原话："Autolnit is supported only for
persistent missions!"），所以任务没有自动加载、执行器没起来。这不影响形态判定
（它只用 DLL 直连命令），但意味着**服务器上的 `exec` / `config` 尚未验证** ——
> **后续（D28）**：已在真实专用服务器上跑通 —— `exec` 返回 `worldName="Altis"`，
> `config_tree` 返回 8392 个子类。

**教训（同一轮里栽两次，值得单列）**：两次都是"我以为我知道"，一次猜窗口类名、
一次漏了缓存维度。真机在几秒内就把两个都驳倒了。凡是**关于外部环境的事实**
（窗口类名、路径、参数语义），先问环境再写代码 —— 猜对了省几分钟，猜错了要
赔上好几轮排查。

**D27 后续：形态判定的服务器侧实测通过（2026-09-25）**

在两个判据都修好之后，真实 `arma3server_x64.exe` 上验证：

| 工具 | 结果 |
|---|---|
| `screenshot` | ✅ 返回 MCP 侧的**形态拒绝说明**（此前是 DLL 层"找不到游戏窗口"，更早是拍到控制台） |
| `ui_locate` | ✅ 同样拒绝，**1.8 ms** 返回（没有在空控件树里空转） |

拒绝文本讲清了两件事：**这不是故障**（"扩展已加载，但找不到游戏窗口"），以及
**服务器上仍然可用什么**（exec / config_* / 知识类工具）。

**顺手修掉一处自相矛盾**：说明里原本拼进了 DLL 的原始错误
`（扩展尚未在游戏进程内加载？）` —— 而我们**刚刚**用 `status` 确认了扩展就在游戏
进程里。把那句已被排除的猜测重新递给读者，比不写还糟。现在 MCP 侧自己给结论，
不再引用它。

**仍未验证**：服务器上的 `exec` / `config_*`。`-autoInit` 在服务器上会被跳过
（"supported only for persistent missions"），任务没有自动加载、执行器没起来。
形态判定不依赖执行器（只用 DLL 直连命令），所以这一条可以独立通过 —— 但也意味着
> **后续（D28）**：已经在服务器上跑过并通过。

---

## D29 P2 输入族补验：三个工具此前只验过一个

P2 的输入能力此前**只验证过 `input_click` 的左键**，其余没逐个验过就被当成一致的了。
补验结果：

| 工具 | 验证方式 | 结果 |
|---|---|---|
| `input_click` button=1（右键） | 编辑器里右键点击地图 | ✅ 预览窗口消失（=取消当前操作），与左键的"**选中**"行为不同 → 证明 `button` 确实被传递到游戏 |
| `input_move` | 指针移到"玩弄游戏场景"按钮 | ✅ 按钮出现 **hover 高亮** |
| `input_key` | 早前用 Enter 进入编辑器 | ✅ 可用 |
| `input_drag` | 编辑器里框选 | ✅ 可用（但只发左键，地图平移做不到，见 backlog） |

### 过程中修掉一个系统性缺陷

三处 schema 都声明了 `auto_focus`，而 **DLL 侧只有 `input_click` 实现了它**：

```
input_click  ✓ 已实现（DLL 读 args[4] 并聚焦）
input_drag   ✗ 声明了没实现
input_key    ✗ 声明了没实现
```

这类"声明了却没实现"的参数最坑：**传了不报错，只是不生效**，而症状（被前台校验
拒掉，报"前台窗口不属于游戏进程"）看起来像环境问题，不像参数问题。已抽出
`_maybe_focus(args)` 让 drag 与 key 共用，避免第三个工具再犯。

### 教训

我测了**唯一实现了 `auto_focus` 的那个工具**，就把整个输入族当成一致的了 ——
**没有逐个验证就做了归纳**。与前面几次（猜窗口类名、以为 `-autoInit` 能用、
以为任务在 `-profiles` 下）**同源**：把"某个样本成立"当成"整类成立"。

---

## D30 Eden 摄像机可以靠数字键盘移动（拖拽做不到）

**目标**：把 Eden 地图视野往东移，直到"空军基地"字样移出屏幕。

**拖拽行不通**。`input_drag` 在 DLL 侧只发左键，而左键在 Eden 里是**框选选中实体**，
不是平移视野；摄像机控制要**右键** —— Steam 那条 "Right Click Eden Editor Camera"
的讨论亦是旁证。`input_click` 虽有 `button` 参数，但它只点击、不拖拽。

**数字键盘可以**。同一条讨论提到 "numpad to rotate the camera"。按住 `Numpad6`
（DIK 77）约 1.2 秒后松开，视野**转向东侧**：画面变成大片海面，"Stratis 空军基地"
字样随之消失 —— 与 Stratis 东侧是海的地理一致。

**顺带验证的两件事**（都是此前没试过的形式）：

- `input_key` 的**按住/抬起**（`down=true` → 等待 → `down=false`）工作正常；
  此前只用过"按一下"（Enter 进编辑器、Esc）。
- 数字键盘的 DIK 码可用（Numpad6 = 77）。

**对 backlog 的影响**：`input_drag` 缺右键那条依然成立，但**严重性下降** —— 需要
真拖拽的场景（拖放、框选菜单）仍做不到，而"移动摄像机"已有键盘这条替代路径，
不必为它单独改 DLL。

**一个没查成的点**：想用 `keyName`（签名 `keyName dikCode`）反查 DIK 码，但它在
编辑器环境下对 Enter=28 这类确定的码也返回 nil —— 这条取证路走不通，改用直接
实验（按下去看图变没变）更有效。

---

## D31 用 Eden 教程驱动测试：放置单位链路打通，旋转没测成

按官方 wiki 的操作说明对照测试 `input_*`。页面本身被 Cloudflare 挡着
（技能的两条取数路径都只拿到挑战页），但**搜索摘要给到了关键原文**，够用。

### 打通了

| 操作 | 手段 | 结果 |
|---|---|---|
| **从资源树放置单位** | `input_click` **连续两次**（被正确识别为双击） | ✅ 左侧实体列表出现 "Alpha 1-1"，地图出现单位标记并高亮 |
| **控制摄像机（转向东）** | `input_key` 按住 `Numpad6`(DIK 77) 1.2 秒再抬起 | ✅ 视野转向海面，"空军基地"字样移出屏幕 |
| **按住/抬起形式** | `input_key`：down → 等待 → 抬起 | ✅ 同上（此前只用过"按一下"：Enter、Esc） |

**双击那条尤其值得记**：`input_click` 连发两次被 Eden 正确识别为双击，而"双击资源
树"正是 Eden 里放置单位最常用的方式 —— 这条链路此前没验证过。

### 没测成

**Shift + 拖拽 = 旋转实体朝向**（官方 `Entity Transforming` 页明确写的操作）。
两次尝试都失败，但**失败原因值得记**：

1. **第一次拖的是空白处**。教程原文是 "hold Shift and drag **it**" —— "it" 指
   实体，前提不成立，所以本来就不该有反应。
2. **第二次时编辑器仍在"放置模式"**：资源树里那个单位类还选中着，于是 Shift+拖拽
   变成了**又放一个单位**（左侧出现 "Alpha 1-2"）。点"取消"退出后再去点单位图标，
   又没能选中（坐标或图标精度问题）。

所以这条**仍是未验证**，而且原因不在工具，而在**编辑器交互状态的判断**：Eden 的
"放置模式"会延续到后续点击，实际操作前必须先确认当前处于哪种模式 —— 这和
D29 里那个教训同源：**先确认前提，再断言结果**。

### 教程获取的实况

官方 wiki（`Eden_Editor:_Controls`、`Eden_Editor:_Entity_Transforming`）**直接取不到**：
Cloudflare 挑战挡着，`sqfwiki.py` 的 Wayback 与真实浏览器两条路都失败，本机也没有
可用的浏览器 provider。**最终靠搜索摘要拿到了需要的那两句原文。**

---

## D32 操作序列（宏）实测：三个用例全过，包括 D31 那条没测成的

`input_macro` 上线后立刻用它做实测 —— 它自己就是被测对象，也是测试手段。

| 用例 | 宏内容 | 结果 |
|---|---|---|
| **进编辑器** | `click`（编辑器卡片）→ `sleep 2500` → `key`(Enter) | ✅ 执行器随之启动（`执行器已启动（poll 周期 0.1s）`）|
| **放置载具** | `dblclick`（资源树里的单位）→ `sleep 900` | ✅ 左侧出现 "Alpha 1-1" + "HEMTT 加油车"，3D 场景里出现卡车 |
| **Shift + 拖拽旋转** | `key`(LSHIFT 按住) → `drag` → `key`(松开) → `sleep` | ✅ **卡车朝向确实改变** |

**第三条是 D31 里没能测成的那个官方教程操作**（`Entity Transforming` 页写的
"hold Shift and drag it"）。它此前失败两次：第一次拖的是空白处（教程的 "it" 指实体，
前提不成立），第二次编辑器仍在放置模式、分次调用之间的间隔让拖拽变成了"再放一个
单位"。

**宏直接消掉了那个失败原因**：修饰键与鼠标操作在**同一串**里、间隔毫秒级，
中间没有网络往返，前台也不会被抢走。三类输入（键盘、鼠标、时间）因此能组成
一个原子操作。

**执行耗时**也印证了粒度差异：进编辑器那个宏 3 步总耗时 2.65 秒，其中 `sleep`
占 2.5 秒 —— **另外两步加起来只有约 145ms**。同样的事用三次独立调用做，
光往返就是数百毫秒，而且中间状态不可控。

**顺带确认了一件设计上的事**：`dblclick` 的 `gap_ms` 有意义 —— 第一次双击落在
"汽车"这个**类别**上时，编辑器做的是**展开**（类别不可放置），第二次落在具体
单位上才进入放置流程。两次都被正确识别为双击。

---

## D33 教程驱动的更多场景：补齐"基础变换"的另一半（移动）

按 `Eden Editor: Entity Transforming` 与 `Transformation Widget` 两页的说明继续测。
前者把**基础变换**定义为"移动 + 旋转"——旋转此前已测（Shift+拖拽，D32），这里补移动。

| 操作 | 手段 | 结果 |
|---|---|---|
| **拖拽移动实体** | 不带修饰键的 `drag` | ✅ 卡车位置明显改变（画面里更近、更大） |
| **选中实体** | `click` 落在实体上 | ✅ 左侧列表高亮、"取消"按钮出现，说明进入了操作流程 |
| **放置载具** | `dblclick` 资源树条目 | ✅ 场景中出现 HEMTT 加油车 |

**`Transformation Widget` 页给出的框架**（对后续有用）：左上菜单有三类控件 ——
**Translation Widget / Rotate / Scaling**；其中平移控件"沿**各轴**移动实体，
**垂直模式被忽略**，但沿 Z 轴移动时**仍尊重贴地设置**"。

**尚未测**的部分（也一并记清楚，避免下次以为都覆盖了）：

- **变换控件的轴拖动**（点中某个轴再拖）—— 需要把 3D 控件在屏幕上的位置认出来，
  比"直接拖实体"更细一层的交互；
- **Scaling（缩放）**；
- `Eden Editor: Controls` 页里按修饰键分类的完整操作表 —— 该页始终取不到
  （Cloudflare），只能靠搜索摘要零散获得。

**方法上的结论**：这一轮全部用 `input_macro` 驱动，**没有一次失败**。作为对比，
D31 用分次调用做同样性质的操作时失败了两次。差别不在操作本身，而在**粒度** ——
宏把键盘、鼠标与等待合成一个原子操作，中间没有网络往返，前台也不会被抢走。

---

## D34 教程驱动：Alt + 拖拽 = 上下移动，至此变换操作基本覆盖

来源是 BI 官方论坛的 Eden controls 帖（"**Alt+left click to move unit up/down**"），
配合官方 `Entity Transforming` 页对 **Vertical Mode** 的说明：**默认拖拽时保持离地
高度、且不能移到地下**；切换 Vertical Mode 后才跟随海面。

用宏一次做完（`LMENU` 按住 → `drag` → 松开 → 等待）：

✅ **卡车明显升空，而阴影留在地面上** —— 高度确实改变了。阴影是关键证据：它把
"升高了"和"只是镜头角度变了"区分开来。

**`LMENU = 56` 取自 `docs/dik.md`**（Windows SDK 的 `dinput.h`），不是猜的 ——
这一轮正好检验了那份表的用处：组合键测试需要可靠的修饰键码，而 `keyName` 那条
查证路早已确认走不通（对 Enter=28 也返回 nil）。

### 至此的覆盖情况

| 变换操作 | 手段 | 状态 |
|---|---|---|
| 旋转朝向 | `Shift` + 拖拽 | ✅ D32 |
| 水平移动 | 拖拽 | ✅ D33 |
| **上下移动** | **`Alt` + 拖拽** | ✅ **本次** |
| 用变换控件沿轴拖动 | 需识别工具栏第 8 个（十字形）控件 | ⬜ 未测 |
| Scaling（缩放） | 同上，另一类控件 | ⬜ 未测 |
| 切换 Vertical Mode | 未找到快捷键/按钮位置 | ⬜ 未测 |

**方法侧的一致结论**（三轮都成立）：这些操作全部靠 `input_macro` 一次完成，
**没有一次失败**。凡是"修饰键 + 鼠标"的组合，分次调用都会失败（D31 有两次
实例），因为间隔里前台与编辑器状态都可能变。

---

## D35 Eden 控件定位：机制可用，但工具栏图标定位不了

想接着测"变换控件的轴拖动"，前提是**先找到那个按钮**（教程说在工具栏第 8 个，
十字形）。结果分两半。

**机制本身可用** —— `ui_locate` 在 Eden 里确实能找到控件：

```
display=0 index=49 class=Scenarios
  text   : '场景'
  rel    : [0.0000, 0.1669, 0.2759, 0.0536]
  屏幕中心: (188, 172)
```

**但有两个障碍**：

1. **Eden 用自定义类名**（`Scenarios`，而不是 `Rsc*`）。我试了五个常见的 `Rsc*`
   类名，**一个都没匹配**（期间扫描了 160 个控件）。类名不能靠猜 —— 而猜错的
   表现恰好是"扫了很多、什么都没找到"，看起来像功能坏了。
2. **工具栏图标没有文本**，所以 `match_text` 那条路也走不通：它能找到菜单文本
   （"场景"、"编辑"），但图标只有图形。

**结论**：变换控件的轴拖动、Scaling 两项**保持未测**。原因不是工具不可用，而是
**缺少"发现控件类名"的手段** —— 这与 D29/D31 的教训同源：**前提没确认就不要发操作**，
宁可记成未测，也不要靠猜坐标去点。

**由此产生一条 backlog**：`ui_locate` 值得加"列出扫描到的控件类名"的能力
（或支持按屏幕区域过滤）。否则在这个界面里它只能找到**已经知道名字**的控件，
而"我不知道它叫什么"恰恰是最常见的起点。

---

## D36 控件定位死结解开：列类名 → 精确定位三个变换控件

D35 记录的死结是"**我不知道它叫什么**"：`ui_locate` 只能按已知的类名/文本/IDC 去找，
而 Eden 的工具栏图标既没有文本、用的又是自定义类名。补上"列类名"能力后，一步到位。

**列出的类名里直接就有答案**（按数量降序，节选）：

```
WidgetTranslation x1
WidgetScaling     x1
WidgetRotation    x1
WidgetNone / WidgetCoord / WidgetArea / Widget x1
```

**正是教程说的三类控件**（`Translation Widget / Rotate / Scaling`）。

**再用 `match_class` 拿到可点击坐标**：

| 控件 | display | 屏幕中心 |
|---|---|---|
| `WidgetTranslation` | 1 | **(70, 41)** |
| `WidgetRotation` | 1 | **(117, 41)** |
| `WidgetScaling` | 1 | **(164, 41)** |

三个坐标相邻、间隔 47 像素，与"工具栏上一排按钮"的布局吻合 —— 这也是对定位结果
的一个旁证。

### 这条链路本身的价值

它把"探索未知界面"变成了两步：**先列类名 → 再按类名精确定位**。此前只能靠截图
目测坐标，而那正是我在 Eden 里反复点错的地方（点"标签"而不是"标记"）。

### 两次失败都源于同一件事

实现这条链路时踩了两个坑，都是**我按想象写接口、而没有先看项目里的同类调用**：

1. `args` 写成了嵌套的 `[["classes"]]`，而约定是**扁平列表** —— 引擎报
   "类型 数组，预期为 字符串"。
2. 给 `reply.result` 套了一层 `{"ok":...}` 检查，而约定是**它就是 SQF 回的负载**
   （`config_tools` 里 `data = reply.result` 直接用）。后果特别误导：SQF 侧明明
   `ack -> ok=true`、回执 3619 字节，MCP 侧却报"被拒绝：未知原因"。

两个约定就在同一个包、同一个功能族里（`config_tools.py`），看一眼就能避免。

### 尚未完成

**视觉验证受阻**：点击 `(70, 41)` 后想截图确认"三轴箭头出现了"，但截图内容没能
进入模型上下文（应是此前记录过的 provider 视觉补丁问题：工具返回的图片需要提升为
带 text 的 user 消息）。所以**"点击是否真的切换了控件"还没有视觉证据** ——
坐标是对的（控件确实在那里），但点击后的状态变化未确认。

因此 `Transformation Widget` 的轴拖动、`Scaling`、`Vertical Mode` 三项**仍记为未测**，
不能因为拿到了坐标就当作测过了。

---

## D37 `call` 移出硬禁：判据从"命令危不危险"改成"参数能不能结构化校验"

方案标题是"独立性整改 + 安全模型：把 `call` 从硬禁改为结构化白名单"。
实施前按流程先实测，期间**推翻过一次我自己的推断**，记在最前面。

### 我先推错了什么

读 `cmd_info` 的摘要时看到 `call` 的形式 1/2 的参数类型都是 `Code`，于是判断
"要么有 code、要么 call 没意义"，正准备把方案原文（"call 的参数是函数引用，
可以来自已知表"）作为错误结论驳回。

**错在只看类型名、没读全那行描述。** 离线命令库的原文是：

```
1) call code
   - code : Code  — Compiled instructions. In  this command also accepts datatype String
```

"also accepts datatype String" —— 字符串形态是官方认可的。命令库摘要里类型缩写
成 `Code`，把这条限定条件吞掉了。**教训：命令库的类型栏是提要，限定条件在说明
正文里；要判断"某个形态能不能用"，必须读全**。

### 实测数据（2026-09-27，编辑器 + Stratis）

| 探针 | 结果 |
|---|---|
| `worldName` | `Stratis` —— 确认执行器在任务里跑（不是主菜单） |
| `config_tree root=CfgFunctions` | **49 个顶层类**，含 `a3mcp`、`BIS`、`CBA`、`Ares` |
| `allVariables missionNamespace` | 函数以**全小写**名字存在于命名空间（`bis_fnc_loop`、`cba_fnc_vectadd`），总数 2991 |
| `_p0 call _p1`（改前） | 被 `DENY_NAMES` 拒绝 —— 这是**表达式校验**拦的，不是语法错 |
| `isNil { missionNamespace getVariable "cba_fnc_vectadd" }` | 返回 `true`，**不可用于判断函数是否存在**（对任意值都为真） |

`CfgFunctions` 可枚举这一条很重要：D20 只证明了"主菜单下未编译"，没测过任务里。
现在可以确认**任务/编辑器里能枚举**，`function_list` 这类能力有落地基础。

### 决定

1. **`call` 移出 `FORBIDDEN_EXACT`，新增 `call_gated` 级**，由 `A3MCP_ENGINE_CALL`
   控制（默认关）。
2. **新增 `CALL_DENY`**（`guard/gates.py`）：`bis_fnc_exec*` / `bis_fnc_spawn` /
   `bis_fnc_dbg_*` / `bis_fnc_codePerformance` / `bis_fnc_callSQF` / `bis_fnc_MP`，
   以及 `compile` / `spawn` / `execVM` / `callExtension` / `remoteExec*` 这些名字本身。
   它们把字符串编译成代码，**call 它们等于把 call 变回 compile**。
3. **`CALL_DENY` 优先级高于白名单**。`A3MCP_ALLOW_COMMANDS` 放不开它——
   包括 `A3MCP_ALLOW_COMMANDS=call` 这种写法（它有专门用例守着）。
4. **目标必须走数据**。表达式禁止字符串字面量，所以函数名只能是
   `_p0 call _p1` 里的 `_p1`。写进表达式文本 → 拒绝。
5. **纵深防御同步**：`fn_validate.sqf` 独立实现同一份拒绝清单（不共用代码，
   两边同时漏才算漏）。为此给 `fn_validate` 加了第 4 个参数（实参表）——
   函数名在数据里，不看数据无法核对。

### 一处实现细节值得记下

`_CALL_TARGET_RE.match(42)` 抛的是 **TypeError 而不是返回 False**。调用方只捕获
`ExprError`，于是那个 TypeError 会一路冒到 MCP 工具层，变成一条与安全无关的内部
错误。是测试（传数字那个用例）把它抓出来的——**"类型先显式判断，再交给正则"**
这条本该写在代码里，而不是等测试来发现。

### 尚未验证（诚实记录）

- `_p0 call _p1` 在**真引擎**里调用一个已编译函数（如 `a3mcp_fnc_validate`）
  还没跑过 —— 需要重新打包 PBO 并重启游戏。
- 上述闭环的 Python 侧已由 `tests/test_exec_e2e.py::TestCallGateE2E` 覆盖
  （4 条，含"execVM 不得到达游戏侧"）。
- `function_list`（方案里点名的第 27 个工具）**未实现**：CfgFunctions 可枚举已
  实测，但函数名的拼接要按 `<tag>_fnc_<className>` 遍历子树，还没写。

---

## D38 带参表达式从来没生效过：`_p0` 不是 SQF 变量

这一条是**在真引擎验证 `call` 的过程中撞出来的**，而且它比 `call` 本身更严重。

### 症状与发现过程

测 `_p0 call _p1` 时它超时，查 RPT 看到：

```
Error in expression <_p0 call _p1>
Error 表达式中未定义的变量：_p0
```

顺着查下去发现**凡是带参数的表达式都这样**，而**无参表达式一切正常**：

| 表达式 | 实测结果 |
|---|---|
| `worldName` | `"Stratis"` ✅ |
| `count allUnits` | `0` ✅ |
| `getPos _p0` | `nil` ❌ |
| `_p0 setPosATL _p1` | `nil` ❌ |

关键点：**失败是静默的**——执行器仍回 `ok=true`，结果 `nil`。调用方看到的是
"成功地什么都没做"。项目此前所有"exec 跑通"的验证用的都是无参命令，所以这个
缺口一直没暴露。

### 根因

`_p0` 是**我们自己引入的占位符约定**，不是 SQF 语法。引擎里没有任何东西把
`_p0` 绑到实参上；`fn_run` 把原表达式 `compile` 之后就执行了，于是引擎报
"未定义的变量"。

### 决定

在 **MCP 侧**展开成 `(_this select N)`：`_this` 正是 `fn_run` 里
`_resolved call _code` 传给被调代码的实参数组。

为什么放 MCP 侧而不是 SQF 侧：SQF 侧也写了一版（同样的字符串扫描），
引擎里跑出来是 `raw=typeName _p0 -> typeName _p0`——即那个实现没识别出占位符。
不追究它为什么（成本更高、收益更低），只保留**一处实现**，放在能用测试
逐条覆盖的那一侧。展开规则有 11 条离线用例，含误替换边界
（`_p0abc` / `_plimit` / `x_p0` / `_p_0` / 越界下标）。

### 顺带打通了 `call` 的真引擎执行

`call` 的右操作数**必须编译期可确定**：`call (_this select 1)` 被引擎直接拒
（`Error position: <call (_this select 1)>`）。改为先经 getVariable 取回函数：

```
(_this select 0) call (missionNamespace getVariable (_this select 1))
```

函数名仍然是**数据**，没有被编译成代码。实测结果：

| 调用 | 结果 |
|---|---|
| `a3mcp_fnc_resolve` | `"u_1"` —— 参数真的传进函数了 |
| `a3mcp_fnc_validate` | `[true, ["worldname"], ""]` —— 函数执行并返回 |
| `BIS_fnc_execVM` | 拒绝（CALL_DENY，优先级高于白名单） |

命令库把 `call code` 的 code 参数注明 "also accepts datatype String"，字符串形态
是官方认可的；而 `missionNamespace getVariable "名字"` 能取到 CODE 类型。

**后续纠正（2026-10-09，实测）**：本条原写"名字必须全小写"，**那是错的**。
函数名**大小写不敏感**——`a3mcp_fnc_configQuery`（驼峰）、`a3mcp_fnc_configquery`
（全小写）都能取到 CODE。当初得出"必须小写"的结论，用的是**执行器还没启动时**
的测试（那时所有 `getVariable` 都返回 nil，与大小写无关）。
`allVariables` 里显示全小写只是它的存储形式，不是查询要求。

教训与前面那次"只看类型栏不看说明正文"同源：**结论要建立在有效实验上**——
执行器没跑时的 nil 不代表"这个名字取不到"。

### 代价：为"两处实现漂移"重启了七次游戏

这一轮最贵的不是任何单个 bug，而是**SQF 侧与 MCP 侧各有一份实现、两边悄悄不一致**：

1. SQF 的 `_splitExpr` 把括号留成 token，MCP 的 `re.split` 丢弃括号 →
   `call (missionNamespace …)` 的目标位置偏移，SQF 报"形态无法识别"。
   这个报错**看起来像安全策略在正常拒绝**，最容易被当成"安全生效了"。
2. 我给 SQF 白名单 `pushBackUnique "_this"`，把这个列表从"空"变成"非空"，
   **意外启用了全量白名单校验**（该侧的语义是"空 = 只挡禁区"）→ 全部命令被拒。
   名单的"空/非空"是**有意的开关**，不能当集合用。

**落进代码的教训**：切分规则改为只有一处定义（`knowledge/expr.py::split_tokens`），
SQF 侧照它实现并写明等价关系；同时把 SQF 的 `_targetSlotOf` 用 Python 照抄一份
放进测试（`TestSqfCallTargetContract`），**以后改那段 SQF 先跑离线用例，对不上就不上机**。

### 还有一处同源缺陷：SQF 侧第二道防线从未生效

`fn_validate` 在**加载期**就报"缺少 ;"——写成了
`if (cond) then { exitWith {…}; };`，引擎要的是单语句形式 `if (cond) exitWith {…};`。
后果：该函数全程返回 `nil`，而 `fn_run` 里的 `!(_v select 0)` 出错后**不阻断执行**，
于是**校验被整个跳过**，没人发现（回执照样 ok=true）。SQFLint 不报这一条。

同源的小坑还有两个，都是"校验器认不出自己人的合法输出"：
展开形态的 `_this`/`select` 不在白名单、下标 `0`/`1` 被当成标识符。

---

## D39 `function_list` 的前提实测：函数名的拼接规则

D37 把 `function_list` 列为"前提已成立但未实现"，指的是 `CfgFunctions` 可枚举。
真正要落地还差**拼接规则**——而那不能靠推断（D20 的教训）。本次上机逐条实测：

### 规则（实测确认）

```
函数名 = <tag> + "_fnc_" + <叶子类名>

CfgFunctions
  └── <T>            ← 直接子类，**在这里读 tag 字段**
        └── <C>      ← 二级分类（如 Core、Arrays），**不进名字**
              └── <F> ← 函数类名，进名字
```

| 实测项 | 结果 |
|---|---|
| `CfgFunctions >> a3mcp >> tag` | `a3mcp` |
| `a3mcp` 下结构 | 只有 1 个分类 `Core`，其下 **22 个**函数类（与 `.sqf` 文件数一致） |
| 类名大小写 | **保留原样**（`configQuery`、`jsonParse`、`ackName`…） |
| `CfgFunctions >> BIS >> tag` | `BIS` |
| **`A3` / `A2PMC` 的 tag** | 也是 **`BIS`**（不是"缺失"，它们的函数同样叫 `BIS_fnc_*`） |
| `Ares` 的 tag | **不存在** → 此时用**类名**当 tag（`Ares_fnc_*`） |
| `A3` 下的结构 | 59 个分类（Actions/Ambient/Arrays/…），函数在第三层 |

### 端到端验证（拼出的名字能否真的 cast 到函数）

| 拼出的名字 | `typeName (missionNamespace getVariable …)` |
|---|---|
| `BIS_fnc_sortBy`（来自 `A3 >> Arrays >> sortBy`） | **CODE** |
| `BIS_fnc_arrayShuffle`（同上） | **CODE** |
| `BIS_fnc_findInPairs`（同上） | **CODE** |
| `a3mcp_fnc_uiQuery` / `a3mcp_fnc_cfgValue` | **CODE** |
| `BIS_fnc_noSuchFunction`（故意拼错，对照） | `nil` |

对照成立，说明拼接规则正确，而不是"随便拼都能中"。

### 顺带纠正一个错误结论

D38 曾写"名字必须全小写"。**错**：函数名大小写**不敏感**，
`a3mcp_fnc_configQuery`（驼峰）与全小写都能取到 CODE。当初的结论来自
**执行器尚未启动时**的测试（那时一切 `getVariable` 都是 nil）。
已在 D38 就地纠正——结论必须建立在有效实验上。

---

## D40 无门控模式：按使用者要求放开全部执行门控（推翻 D2）

使用者的原话："我需要一个完全让 LLM 接管模式，放开所有执行门控，
可能的副作用用户自行处理。"

这条要求直接推翻 D2 与 D37 里那句"**硬禁命令不接受任何开关**"。记录在这里，
是因为它改变了本仓库最根本的一条假设——以后再读到 D2/D37 关于"硬禁没有例外"
的论述时，要知道那后面多了一个显式例外。

### 决定：做成开关，而不是删掉检查

三种做法，选了第三种：

| 做法 | 问题 |
|---|---|
| 删掉所有闸门代码 | **"现在是什么模式"不可观测**。出事后无法回答"当时被拦过吗"，而"副作用自行处理"的前提恰恰是事后能查 |
| 把默认值改成全开 | 一次误配就是全开；且与"自控环境要保守默认"的设计相反 |
| **加显式模式开关，默认关** | 多写一点代码，换来模式可观测、可审计、可回归 |

所以：`A3MCP_PROFILE=unrestricted`（或 `A3MCP_UNRESTRICTED=1`），默认永远是关。

### 四层同时让路（缺一层就是"半开"，比全关更难排查）

| 层 | 改法 |
|---|---|
| 命令闸门 `guard/gates.py` | 新增 `unrestricted` 字段；`check()` **最前面**短路，连硬禁与 `CALL_DENY` 一起放行；`input_inject` / `allow_cheat` / `engine_exotic` / `engine_call` 的默认值一并打开 |
| 表达式校验 `knowledge/expr.py` | `validate(..., unrestricted=True)` 跳过白名单/永久禁区/字符串字面量/分号/占位符，只留"非空 + 8000 字符" |
| MCP 执行链 `adapters/exec_tools.py` | 把模式传给上两层；给游戏侧的 payload 加第 4 项 `skipValidate`；审计带 `mode=unrestricted` |
| 游戏侧 `fn_run.sqf` | 收到 `skipValidate=true` 就跳过 `fn_validate` |

**为什么 payload 也要带标志**：游戏侧那道防线是独立实现的纵深防御。如果只放开
MCP 侧、游戏侧仍拒，用户会看到"MCP 说放行了、命令就是没生效"——
半开状态最难排查，所以必须一起放。

### 一个实现细节（差点写错）

`exitWith` 退出的是**当前代码块**，不是函数。所以校验判断不能写成：

```sqf
if (!_skipValidate) then {
    private _v = ... call a3mcp_fnc_validate;
    if !(_v select 0) exitWith { ... };   // ← 只退出 then 块，函数继续往下走！
};
```

那样校验失败后仍会执行表达式 —— **校验静默失效**。正确写法是把"是否跳过"与
"是否失败"拆成两条**顶层** `if`（见 `fn_run.sqf` 里的注释）。这个坑 D38 已经
踩过一次，这次是同一族的另一个形态。

### 保留了什么

- **审计照旧**，且每条 `exec` 带 `mode: "unrestricted"`。审计不是门控，是记录；
  它恰好是这个模式能"自担后果"的前提。
- **显式 `=0` 仍可单独关**某一项（如 `A3MCP_INPUT_INJECT=0`）——全开不等于不可控。
- **默认路径一丝不变**：`unrestricted=False` 时行为与 D2/D37 描述完全一致，
  有回归测试钉住（`test_default_path_unchanged` 等）。

### 责任边界

使用者已明确"副作用自行处理"。文档（`safety.md`）里如实列出风险，
并由使用者承担：本模式下 LLM 能做的等于操作者在这台机器上能做的。
**不应在启用 BattlEye 的环境、共享机器或含敏感数据的桌面上开启。**

---

## D41 "UI 元素指向哪个功能"：config 才是主路，两种运行时 getter 只覆盖一小半

这轮把 P2 遗留的那个问题问清楚了：**点了这个控件，到底会执行什么？**
在 Eden 上逐项实测，结论和最初的假设不完全一样，而且我中途错过一次方向。

### 一条链，四次取值，全在真机跑通

以工具栏 Undo（display 1、索引 20）为例：

| 步 | 表达式 | 结果 |
|---|---|---|
| 1 | `ctrlParent ctrl` → display | — |
| 2 | `display getVariable ["BIS_fnc_initDisplay_configClass", ""]` | `"Display3DEN"` |
| 3 | `ctrlClassName ctrl` / `ctrlIDC ctrl` | `"Undo"` / `1010` |
| 4 | `buttonAction ctrl` | `"do3DENAction 'Undo';"` |

第 4 步拿到的**就是可执行代码本身**，`do3DENAction` 的闸门分级是 `write`
（放行）。也就是说"追到功能"之后直接执行等价于点击，不需要拦事件、不需要
反编译。第 2、3 步是给**没有运行时 getter** 的那一半用的坐标。

### 数量：config 里 97 个类带处理器文本

用新接口 `ui_snapshot(mode=handlers)` 遍历整棵子树（不是只走 `controls` 一层）：

| display | 遍历节点 | 带处理器的类 | 其中 `action` | 其中 `onButtonClick` |
|---|---|---|---|---|
| `Display3DEN` | 365 | **81** | 62 | 19 |
| `RscDisplayMain` | 162 | **16** | 0 | 16 |

`Display3DEN` 的 81 个里，64 个在 `Controls/`（含 60 个菜单条项）、17 个在
`ContextMenu/`（右键菜单）。运行时 `buttonAction` 只对**真正的按钮控件**有效
（Eden 里 32 个，主菜单里 54 个），但 config 侧的代码文本覆盖得更多。

### 三条被证伪的假设

1. **`buttonAction` 不是通用入口。** 它读的是 config 的 `action` 属性；
   Eden 有一半按钮把代码写在 `onButtonClick` 里，`buttonAction` 对它们返回 `""`
   （`ButtonExit` 就是这种，代码在 `onButtonClick = "do3DENAction '3DENExit';"`）。
2. **`menuAction`（运行时）不可用，但菜单 config 里有 `action`。**
   `MenuStrip` 控件（idc 120、`type=47`）的 `menuAction [idc, path]` 三个路径
   全返回 `""`。我据此写下"菜单项 config 里连 action 都没有"——**这句是错的**：
   当时只走了 `controls` 一层并跳过了 `Items` 子树，抽查的 `MissionNew` 恰好
   是个没有 action 的项。走完 `MenuStrip/Items` 后看到 60 项里有 `action`
   （如 `do3DENAction 'OpenSteamPublishDialog'`、`[] call bis_fnc_3DENExportSQF`），
   `ContextMenu/Items` 的 17 项也都有。**教训：从一个样本推全局，且样本来自
   被裁剪过的遍历，得到的结论会既错又像真的。**
3. **uinamespace 派发表是空的。** `Display3DEN.onLoad` 的值是
   `["onLoad",_this,"Display3DEN",'3DENDisplays'] call (uinamespace getvariable 'BIS_fnc_initDisplay')`，
   看起来 dispatch 表在 `3DENDisplays` 里；实测
   `count (uinamespace getVariable "3DENDisplays")` = **0**。这条路走不通。

所以能追到底的只有三种元素：**带 `action` 的按钮**（运行时 getter + config 双份）、
**带 `onButtonClick` 的按钮**（只有 config）、**菜单项**（只有 config，且要靠
路径区分同名类）。其余控件（列表/树/滑条/复选/3D 视口）运行时没有 getter，
`ctrlAddEventHandler` 只写不读，只能坐标点击。

### 新接口：一次遍历、一次回执

`a3mcp_fnc_uiQuery` 加三个分支（`snapshot` / `actions` / `handlers`），MCP 侧
对应 `ui_snapshot` 工具。为什么不是"多调几次 exec"：

- MCP 侧动态表达式**每条 400 字符上限**，一个控件要 4 次往返；
- 每次 `ctrlClassName` 都重新全量求值 `allControls`，成本正比于控件数 —— 448 个
  控件时 `ui_locate` 只扫得动前 40 个（D25/D26 的老问题）；
- 而"整棵树一次回"又受 DLL 的**上行单行 16 KB**限制（`kMaxLineOut`）：Eden 一个
  display 就有 304 个控件，整棵树约 50 KB，超出的部分会被**静默截断**。

于是 `snapshot` 用"条数配额 + 12 KB 字节预算"双保险分页，`next` 随回执返回，
MCP 侧自动续取（实测一次取回 448 行、与 `total` 完全一致，未截断）。
`actions` 的记录里带 display 的 config 类名，MCP 侧据此把 `handlers` 的结果
按类名合表 —— "这个按钮点击后执行什么"因此是一次调用的结论。

### 这一轮踩到的三个坑（都是"改对了才看得出来"）

1. **`[_fn, [参数]] call _fn` 是错的调用形态。** 正确写法是 `[参数] call _fn`。
   前者把函数自己当成第一个参数，`params` 的类型校验把整个入参拒掉、变量取默认值，
   函数**静默返回空串**——现象是"所有 onButtonClick 都读成空"，没有一行报错。
2. **`configClasses` 是双参数命令**：`condition configClasses config`。写单参数
   报 `类型 Config entry，预期为 数组`。同一个坑 `fn_configQuery.sqf` 里已经记过。
3. **SQF 的 `str` 对大整数会输出科学计数法**（实测某控件 idc 变成 `6.9e+06`），
   MCP 侧直接 `int()` 解析会把工具打挂。数字解析必须容错（先 int 再 float）。

另外一条影响开发节奏：**CfgFunctions 的函数是 `compileFinal`，运行时覆盖会被拒**
（RPT: `Attempt to override final function - a3mcp_fnc_uiquery`），所以每改一次
SQF 都必须重启游戏才能验；"热替换"这条路不通。

### 一个把数字算错的教训：`\s*` 吞了换行

用 `config_value` 读属性时，我的解析正则写成 `^\s*键\s*=\s*(.*)$`。当属性
**存在但为空**时，输出是 `  onButtonClick = `（行尾什么都没有），而 `\s`
在 Python 里**包含换行** —— 于是 `(.*)` 吃到了下一行的 `text = ...`，
"空值"被当成了"值为下一行"。

后果：`Display3DEN` 的 `onButtonClick` 从 19 虚高到 33，且虚高的那些恰好是
本来该记 0 的项。改成 `[ \t]*` 后数字才对上。**这类错误的形状是"看起来完全
正常"**：没有异常、没有空值、表格照常打印，只有和另一种途径（真机
`buttonAction`）交叉验证才会露馅。所以 D41 里的数字都同时有两种来源。
