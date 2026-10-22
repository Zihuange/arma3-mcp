# 上机清单（游戏侧联调）

> ⚠ **2026-10-18 端口变更**：游戏连接通道的默认端口已由 `32131` 改为 **`32132`**
> （原 32131 被 `mcp-rimworld-bridge` 经 `wslrelay.exe` 占用，会导致本通道静默退回 `null`）。
> 已同步修改并重新编译：`game/extension/src/arma3_mcp_extension.cpp` 默认值、`start_windows.bat`、
> `serve_http.py --game-port`、`tools/dll_smoke.py`（DLL 冒烟测试 6/6 通过）。
> **下文凡以 `32131` 表述「当前默认端口」之处，请读作 `32132`**；
> 历史实测与决策记录（本文件第 57-58 行、`decisions.md`）保留原样，未作篡改。

当前状态：**模组与 DLL 均已就绪，并通过离线验证**（见下）。以下按顺序做，
每步都有判据——通过了再进下一步。

| 交付物 | 状态 |
|---|---|
| `game/mod/addons/a3mcp.pbo` | 已打包（30591 字节），含 config.bin + 15 个 .sqf，结构校验通过 |
| `game/mod/arma3_mcp.dll`（及副本 `arma3_mcp_x64.dll`） | 已编译（87552 字节，PE32+ x86-64），三个导出符号齐全 |
| DLL 行为 | 离线冒烟测试 5 项全过——`tools/dll_smoke.py`（见下） |

### 离线冒烟测试（不需要游戏，改过 DLL 就该重跑）

```bat
cd /d <repo>
"H:\Program Files\Anaconda3\python.exe" tools\dll_smoke.py game\mod\arma3_mcp.dll 32199
```

它验证的不只是"能加载、能握手"，还有两条最容易搞混的**路由**：

| 断言 | 为什么重要 |
|---|---|
| `status` 由 DLL 直连回答（且带心跳字段） | 诊断工具不能依赖它要诊断的执行器（`decisions.md` D17） |
| 需要游戏世界的命令**不**回执，只能被 `poll` 取走 | 证明两条路径确实分开，而不是"DLL 什么都自己答" |
| 任何 poll 之前 `poll_ms_ago == -1`，poll 之后被刷新 | 心跳能区分"没跑"与"在跑" |

**端口必须传一个未被占用的**（示例用 32199，别用默认的 32131）。DLL 一加载就从
`DllMain` 开始拨默认端口，而 MCP 只保留一个活跃连接——照默认值跑会把正在运行的
游戏踢下线。脚本会自动复制一份并改写默认端口，所以真实服务不受影响（D18）。

本机使用的工具链：**Visual Studio Community 2022**（`H:\Program Files\Microsoft Visual Studio\2022\Community`，
MSVC 14.34）＋ CMake 3.25。

---

## 0. 前置：MCP 侧开好游戏连接端口

游戏侧 DLL 会主动连 **`127.0.0.1:32131`**（MCP 与游戏同机，走本机回环）。

在**Windows** 上启动 MCP 服务（同时开 HTTP 入口与游戏连接端口）：

```bat
<repo>\start_windows.bat
```

脚本里已把两个**必需**的默认值设好。缺任意一个，通道就是 `null`，
**一切碰游戏的操作（exec / config_*）都不工作**，而 HTTP 侧看起来完全正常：

| 变量 | 默认 | 说明 |
|---|---|---|
| `A3MCP_CHANNEL` | `tcp` | 不开就不会监听游戏连接端口（早先的脚本漏了这句，实测踩到） |
| `A3MCP_TCP_PORT` | `32131` | **必须与 DLL 的默认端口一致**（`arma3_mcp_extension.cpp` 里 `std::string port = "32131"`）。不一致时游戏侧连不上，且没有明显提示 |

启动横幅会打印 `channel : tcp on port 32131` —— **看到 `null` 就说明通道没开**。

⚠ **`32131` 被占用时，通道会静默退回 `null`**，`gates_status` 只显示"未接通"。
本机实测遇到过一种**残留占用**：上一轮的 MCP 绑过 32131 → WSL2 为它建立
localhost 转发（`wslrelay.exe`）→ MCP 被杀后**转发进程残留**，继续占着 32131，
于是新 MCP 绑不上。诊断与清理：

```bash
# 谁占着 32131
/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe -NoProfile -Command \
  "Get-NetTCPConnection -LocalPort 32131 -State Listen | Select-Object LocalAddress,OwningProcess"
# 占用者是 wslrelay.exe（WSL2 机制进程）→ 清掉它即可释放
/mnt/c/Windows/System32/cmd.exe /c "taskkill /F /PID <那个 PID>"
```

**判据**：`gates_status` 的通道是 `null` 还是 `tcp` ——
`null` = 端口没开起来（查上面的占用）；`tcp／未接通` = 端口好的，是游戏侧没连上来。

---

## 1. 编译扩展 DLL（**已完成**，此节留作重编译参考）

> 当前 DLL 已编译并通过校验，可跳过本节直接进第 2 步。
> 改动 DLL 源码后按下面任一方式重新编译。

需要 Windows 的 C++ 编译工具。三种途径任选：

### A. Visual Studio Build Tools（推荐，最省事）

```bat
winget install Microsoft.VisualStudio.2022.BuildTools ^
  --override "--quiet --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"
```

装完在新终端里：

```bat
cd /d <repo>
cmake -S game\extension -B build\ext -A x64
cmake --build build\ext --config Release
```

### B. 便携版 MinGW-w64（不想装 VS 时）

从 <https://winlibs.com/> 下载 UCRT 版 zip，解压后：

```bat
cd /d <repo>
cmake -S game\extension -B build\ext -G "MinGW Makefiles" ^
      -DCMAKE_CXX_COMPILER=<解压目录>\bin\g++.exe
cmake --build build\ext
```

### C. 已有 VS 但没装 C++ 工作负载

打开 Visual Studio Installer → 修改 → 勾选「使用 C++ 的桌面开发」。

**判据**：`game\mod\arma3_mcp_x64.dll` 存在，且大小在 20–200 KB 之间。
CMakeLists 会自动把它复制到模组根，并把同一份复制为 `arma3_mcp.dll`。

---

## 2. 确认模组形态

```
game/mod/
  arma3_mcp_x64.dll        <- 扩展（第 1 步产物）
  arma3_mcp.dll            <- 同一份的另一名字（x64 进程优先探测 _x64）
  addons/a3mcp.pbo         <- 模组（已打包，30591 字节）
```

**判据**：三个文件都在。PBO 可用 `python3 tools/pbo_verify.py <pbo>` 复核。

---

## 3. 启动游戏并挂载

用仓库自带的启动器（它总会挂上模组，并已处理好 `-init=`）：

```bat
<repo>\start_game.bat
```

需要把 MCP 地址告诉 DLL 时，在游戏启动后、进任务前执行一次：

```sqf
"arma3_mcp" callExtension ["configure", ["127.0.0.1", "32131"]]
```

（默认值就是 `127.0.0.1:32131`，端口没改过就不必执行。）

### 执行器什么时候启动（最容易误解的一点）

两个入口的作用域不同：

| 入口 | 何时运行 | 能做什么 |
|---|---|---|
| `-init=`（启动参数） | 游戏启动时，主菜单阶段 | 加载 DLL；**尝试**拉起执行器 |
| `preInit` / `postInit`（模组 CfgFunctions） | **任务加载时**才触发 | 启动执行器 |

`start_game.bat` 的 `-init=` 做两件事：

1. **加载 DLL**——截图／输入／窗口信息立刻可用，不需要任务；
2. **发一组同步探针**，把"主菜单阶段到底有什么可用"问清楚，结果经
   DLL 的 `push` 通道送回，用 MCP 的 `game_events` 读取：

| 探针 | 含义 |
|---|---|
| `P1` | `-init=` 的同步部分确实执行了（push 通道可用） |
| `P2Y` / `P2N` | `a3mcp_fnc_init` 在这一刻**是否**定义 |
| `P3` | `call` 返回（`fn_init` 跑完了） |
| `P4` | spawn 的代码块是否被调度 |

**实测结论（2026-09-25，见 `decisions.md` D20）**：拿到的是 **P1 + P2N**。

也就是说：

- `-init=` 的同步代码能跑，`callExtension` 可用；
- **模组的 CfgFunctions 在主菜单阶段没有编译**，`a3mcp_fnc_init` 不存在；
- `spawn`（P4）**不执行**——`-init=` 跑在调度器起来之前，异步代码块在这里
  静默失效，不报错也不延迟。

所以：**主菜单下执行器起不来**，这不是配置问题，是引擎行为
（CfgFunctions 由 preInit/postInit 驱动，而那两个是任务作用域的事件）。
进任务后 preInit/postInit 会照常把执行器拉起来（`fn_init` 有 `A3MCP_STARTED`
守卫，重复调用会被忽略）。

这套探针**留在启动器里**：它很便宜，而且将来引擎或 CBA 行为若有变化，
启动时立刻就能看出来。

**为什么不写引号**：`-init=` 的字符串要经过 cmd.exe 与引擎两轮参数解析，
里面出现的引号会被吃掉（实测 RPT 报 `Error: missing '`）。因此 `start_game.bat`
里所有字符串（扩展名、函数名、探针标记）都用 `toString [字符码]` 构造，
字符码集中定义在文件里并逐条注释。改这段代码前先读
[`decisions.md`](decisions.md) 的 D19 与 D20。

---

## 4. 验证链路

在 DSH 里让 Agent 调用：

| 工具 | 期望结果 |
|---|---|
| `gates_status` | 通道显示 tcp 已接通，**并显示执行器状态**（运行中／从未启动／心跳停滞） |
| `game_link` | DLL 的收件/发件计数与心跳；执行器没跑时它会把这一点直说出来 |
| `window_info` / `screenshot` | 主菜单下就该可用（DLL 直连，不需要任务） |
| `exec`（`dry_run` 先来一次） | 预演通过 |
| `exec`（真执行） | 例如 `getPos` 读自己位置，返回结构化结果 |
| `config_tree`（不带参数） | 列出常用顶层类 |
| `config_class(CfgVehicles, [某载具])` | 显示该载具的关键属性 |

**判据分两层，别混为一谈**：

1. **通道接通**——`gates_status` 里通道是 tcp 且已接通。
   这只说明 DLL 连上了 MCP，**不**说明游戏里有人执行命令。
2. **执行器在跑**——`gates_status`／`game_link` 的心跳显示"运行中"。
   `exec`／`config_*` 只有在这一层成立时才会执行；否则命令会堆在 DLL 队列里
   一路超时。执行器**只在任务加载之后**启动。

第 1 条成立而第 2 条不成立，是**正常且常见**的状态（例如停在主菜单），
不是故障——先按第 2 条的说明处理，再谈别的。

---

## 5. 出错时的排查顺序

| 现象 | 先查 |
|---|---|
| DLL 一直连不上 | MCP 是否在跑、端口是否被占；DLL 的 `configure` 地址是否对；Windows 防火墙对本机回环一般无影响，但若改过策略需放行 |
| 执行器没启动 | RPT 里有没有 `[A3MCP]` 字样；模组是否真的加载（`CfgPatches` 里应有 `a3mcp`） |
| 工具报「未接通」 | 先看 `gates_status` 的**通道**是 `tcp` 还是 `null`：`null` = 端口没开起来（见第 0 节的占用排查）；`tcp` 但未接通 = 游戏侧没连上来 |
| **状态自相矛盾**（一会儿 `tcp／已接通`、一会儿 `null／未接通`） | 几乎一定是**跑着多个 MCP 实例**。旧代码用标准库默认的 `allow_reuse_address=1`，而**Windows 上这个选项允许完全重复绑定**同一地址端口 —— 多个实例同时绑 `0.0.0.0:32128`，请求被不同实例接走。**每个响应单独看都自洽**，所以极难察觉。诊断：数 `serve_http` 进程个数（见下）。已修：现在显式 `allow_reuse_address = False`，第二个实例会在 bind 阶段直接失败并打印"监听失败：端口被占用" |
| 命令发出去没回执 | `game_events` 看有没有 `evt:cmd_error`；RPT 里搜 `[A3MCP][ERR]` |
| 表达式被拒 | 回执里会带原因（白名单外标识符 / 含分号 / 占位符越界），按原因改调用 |
| PBO 加载了但函数不存在 | 用 `tools/pbo_verify.py` 复核 PBO 是否含 config.bin 与全部 .sqf |

---

### 排查"多实例"的具体命令

```bash
PS=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe
# 有几个 MCP 实例（应恒为 1）
$PS -NoProfile -Command '@(Get-CimInstance Win32_Process | Where-Object { $_.CommandLine -like "*serve_http*" }).Count'
# 谁绑着端口
$PS -NoProfile -Command 'Get-NetTCPConnection -State Listen | Where-Object { $_.LocalPort -in 32128,32131 } | Select-Object LocalAddress,LocalPort,OwningProcess'
```

⚠ 清理时**不能只按"32128 的 owner"找**：多实例共存时，端口查询只返回其中一个，
按它杀会漏掉其余实例（我就这样漏杀了旧的，结果一直连的是那个 `null` 通道的实例）。
判据用"进程数是否为 1"。

## 已知的、尚未验证的部分

诚实列出——这些**必须**在上机时确认，本机无法验证：

1. ~~**引擎侧的 config 查询行为**~~ **已实测（2026-09-25）**：`configClasses`
   没有分页参数，我们对它的"分页"就是自己的 `limit`（**只影响收集，遍历仍是全量**）。
   而全量遍历的代价**很小** —— 最大的子树 `CfgVehicles`（8568 个子类）端到端 **0.21 s**，
   其中固定往返约 0.11 s，遍历本身只占约 0.1 s。**结论：不需要分页。**
   剩下未测的是 `configProperties` 的 `inherit` 参数（当前实现没用到它）与
   "子类未定义而父类有"的报错表现。
2. ~~**`configClasses` 的性能**~~ **已实测（2026-09-25）**：`CfgVehicles` 有
   8568 个子类，完整遍历一次**能在 MCP 的 5 秒超时内返回**，故"游戏侧一次
   遍历、结果给 MCP 缓存"的设计成立，暂不需改成分页。
3. **compile 的实际开销与缓存收益**：编译缓存按表达式文本作键，收益未量化。
4. **poll 周期 0.1s 的实际影响**：占游戏逻辑线程的时间未测，若偏高可调
   `a3mcp_fnc_init` 的参数。
5. **队列容量**：DLL 侧下行队列上限 256，是按"命令突发"估计的，实测后可能要调。
6. **心跳阈值的实机取值**：离线冒烟测试已确认心跳按预期工作（poll 前为 -1、
   poll 后立即刷新），但 `STALE_MS = 3000` 是按"SQF 轮询周期 0.1s、留 30 个周期
   余量"推出来的。实机上若加载卡顿、或某条命令执行很久，心跳会短暂超阈值，
   表现为**误报**"心跳停滞"——需实测后调整（见 `adapters/health.py`）。

---

## 附：把新构建拷进游戏目录时的坑

即使游戏**已经关闭**，WSL 侧的 `cp` / `mv` 仍会对 `game/mod/*.dll` 与
`game/mod/addons/*.pbo` 报 `Permission denied`。这不是文件真被锁：
`attrib` 显示只有 archive 位，`tasklist` 里游戏进程也已退出。是 drvfs 层面的问题。

用 **Windows 侧**的 copy 一次就成功：

```bat
copy /y <repo>\build\pbo_out\a3mcp.pbo <repo>\game\mod\addons\a3mcp.pbo
copy /y <repo>\game\mod\arma3_mcp.dll <repo>\game\mod\arma3_mcp_x64.dll
```

拷完用 sha256 对比确认一致 —— `_x64` 那个副本最容易漏（引擎优先加载它，
漏了就等于改动根本没生效），而 CMake 的后置复制在游戏运行时必然失败。
