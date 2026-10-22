# 上机清单（游戏侧首次联调）

当前状态：**模组与 DLL 均已就绪并通过验证**（见下）。以下按顺序做，
每步都有判据——通过了再进下一步。

| 交付物 | 状态 |
|---|---|
| `game/mod/addons/a3mcp.pbo` | 已打包（30591 字节），含 config.bin + 15 个 .sqf，结构校验通过 |
| `game/mod/arma3_mcp_x64.dll` | 已编译（41984 字节，PE32+ x86-64），三个导出符号齐全 |
| DLL 功能 | 冒烟测试通过（能连 MCP、握手、poll 取到命令）——`tools/dll_smoke.py` |

本机使用的工具链：**Visual Studio Community 2022**（`H:\Program Files\Microsoft Visual Studio\2022\Community`，
MSVC 14.34）＋ CMake 3.25。

---

## 0. 前置：MCP 侧开好游戏连接端口

游戏侧 DLL 会主动连 **`127.0.0.1:32131`**（MCP 与游戏同机，走本机回环）。

在**Windows** 上重启 MCP 服务（会同时开 HTTP 与游戏连接端口）：

```bat
<repo>\start_windows.bat
```

启动横幅里应出现两行关键信息：

```
* DSH 填这个      : http://<vEthernet(WSL) 地址>:32128/mcp
* 游戏侧扩展连这个 : 127.0.0.1:32131
```

**判据**：看到 `游戏侧扩展连这个` 那行。没看到说明游戏端口没开起来
（可能被占用；换 `--game-port` 并通过环境变量告诉 DLL，见第 3 步）。

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

用启动器或命令行挂载模组目录 `<repo>\game\mod`。

需要把 MCP 地址告诉 DLL 时，在游戏启动后、进任务前执行一次：

```sqf
"arma3_mcp" callExtension ["configure", ["127.0.0.1", "32131"]]
```

（默认值就是 `127.0.0.1:32131`，端口没改过就不必执行。）

**在游戏内跑起执行器**（二选一）：

- 编辑器里放一行 `call a3mcp_fnc_init;`（或放进 `init.sqf`）；
- 或给游戏加启动参数 `-init=<某个只含这一行的 sqf 的路径>`。

**判据**：RPT 里出现

```
[A3MCP] 执行器已启动（poll 周期 0.1s）
```

没出现说明函数没被调用或 PBO 没加载（检查模组是否真的挂上了）。

---

## 4. 验证链路

在 DSH 里让 Agent 调用：

| 工具 | 期望结果 |
|---|---|
| `gates_status` | 执行通道显示 **tcp 已接通**，并给出游戏进程 pid |
| `game_events` | 能看到游戏侧事件（初始可能为空） |
| `exec`（`dry_run` 先来一次） | 预演通过 |
| `exec`（真执行） | 例如 `getPos` 读自己位置，返回结构化结果 |
| `config_tree`（不带参数） | 列出常用顶层类 |
| `config_class(CfgVehicles, [某载具])` | 显示该载具的关键属性 |

**判据**：`gates_status` 里 `connected: true` 且 `game.pid` 有值。
到这里说明 DLL ↔ MCP ↔ 工具三层全通。

---

## 5. 出错时的排查顺序

| 现象 | 先查 |
|---|---|
| DLL 一直连不上 | MCP 是否在跑、端口是否被占；DLL 的 `configure` 地址是否对；Windows 防火墙对本机回环一般无影响，但若改过策略需放行 |
| 执行器没启动 | RPT 里有没有 `[A3MCP]` 字样；模组是否真的加载（`CfgPatches` 里应有 `a3mcp`） |
| 工具报「未接通」 | `gates_status` 看通道状态；MCP 侧 `start_windows.bat` 的横幅里游戏端口那行是否出现 |
| 命令发出去没回执 | `game_events` 看有没有 `evt:cmd_error`；RPT 里搜 `[A3MCP][ERR]` |
| 表达式被拒 | 回执里会带原因（白名单外标识符 / 含分号 / 占位符越界），按原因改调用 |
| PBO 加载了但函数不存在 | 用 `tools/pbo_verify.py` 复核 PBO 是否含 config.bin 与全部 .sqf |

---

## 已知的、尚未验证的部分

诚实列出——这些**必须**在上机时确认，本机无法验证：

1. **引擎侧的 config 查询行为**：`configClasses` 的分页语义、`configProperties`
   的 `inherit` 参数表现、以及"子类未定义而父类有"时该报什么，都待实测。
2. **`configClasses` 的性能**：对 `CfgVehicles` 这类大子树调用一次的开销。
   目前设计是"游戏侧一次遍历、结果给 MCP 缓存"，实测若太慢需改成按需分页。
3. **compile 的实际开销与缓存收益**：编译缓存按表达式文本作键，收益未量化。
4. **poll 周期 0.1s 的实际影响**：占游戏逻辑线程的时间未测，若偏高可调
   `a3mcp_fnc_init` 的参数。
5. **队列容量**：DLL 侧下行队列上限 256，是按"命令突发"估计的，实测后可能要调。
