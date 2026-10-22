# arma3-mcp

把 **Arma 3（Real Virtuality 引擎）的能力面**暴露给 AI Agent 的 MCP 服务器：
5000+ 条引擎命令与官方函数，可用**结构化调用**在游戏内执行。

**本仓库完全自持**——不 import、不调用、不依赖本机其它 Arma 代码库，运行时只用
Python 标准库。这条约束由 `tools/check_independence.py` 作为可执行断言守护，
而不是写在文档里当承诺。

---

## 当前状态

| 阶段 | 内容 | 状态 |
|---|---|---|
| **P0** | MCP 协议骨架、自带命令库、知识/校验/闸门、全量自检、独立性验证 | ✅ 已完成 |
| **P1** | 游戏内执行通道（扩展 DLL + SQF 执行器），实机闭环 | ✅ 已完成 |
| **P2** | 用户操作模拟（UI 控件、原生输入注入、坐标校准） | ✅ 已完成 |
| **P3** | 专用服务器形态（TCP 通道） | ✅ 已完成 |

P2 的坐标校准（`ui_locate`）已真机闭环；UI **写入**只对自建控件可靠，引擎内建 UI
会静默忽略 —— 那是能力边界而非缺陷，见 [`docs/decisions.md`](docs/decisions.md) D24。
P3 已在真实 `arma3server_x64.exe` 上打通（`exec` / `config` 可用、UI 工具明确拒绝）。
两边都还剩若干**未验证项**，逐条列在 [`docs/onmachine.md`](docs/onmachine.md)。

想先了解这个项目怎么一步步走到现在的，看 [`docs/history.md`](docs/history.md)
—— 按阶段梳理，重点记转折点与代价最高的教训。
还剩哪些没做、以及每一项怎么判，看 [`docs/backlog.md`](docs/backlog.md)。

### 现在到底能做什么（按"要不要游戏世界"分）

这是用之前最该先搞清楚的一件事：**通道接通 ≠ 命令有人执行**。

| 能力 | 需要什么 | 说明 |
|---|---|---|
| 全部知识工具（`cmd_*`／`capability_matrix`） | 什么都不需要 | 纯离线，查签名、校验参数、预演 |
| `screenshot`／`window_info`／`focus_game`／`input_*` | 只要 DLL 加载 | 由 DLL 直接处理，**停在主菜单也能用** |
| `game_link`／`gates_status` | 只要 DLL 加载 | 同上；用来判断执行器到底在不在跑 |
| `exec`／`exec_batch`／`config_*` | **SQF 执行器在运行** | 需要游戏世界；执行器目前只在**任务加载后**才启动 |
| UI 与输入注入类（`screenshot`／`input_*`／`ui_locate`…） | **有界面**的进程 | 专用服务器上是 locale effect，需要进程内有玩家；这类工具会**明确拒绝并说明原因**，而不是超时或静默失败 |

上面这一档划分不是猜的：**主菜单下执行器确实起不来**，已在实机上确认
（`decisions.md` D20）。原因是模组的 CfgFunctions 在主菜单阶段**没有编译**，
`a3mcp_fnc_init` 不存在；而 CfgFunctions 的编译由 preInit/postInit 驱动，
那两个是**任务作用域**的事件。想用 `-init=` 抢跑也不行：那个时机跑在调度器
起来之前，连 `spawn` 都不执行。

此时 `exec` 不会执行，命令会堆在 DLL 队列里直到超时——`gates_status` 会把
这一点直接说出来，`exec` 超时的错误里也会附上原因，不再让人对着"超时"猜。

**P0 可独立使用**：Agent 能查证任意引擎命令的签名、校验参数、预演将要发送的
内容；`exec` 在通道未接通时**明确报错**，不会假装执行成功。

## 快速开始

```bash
# 1) 生成自带命令库（从编辑器扩展的官方命令定义，第一次必须做）
python3 tools/build_commands.py

# 2) 跑测试
python3 -m unittest discover -s tests -t .

# 3) 独立性自检（含"在隔离副本中跑全部测试"）
python3 tools/check_independence.py

# 4) 启动 MCP 服务器（stdio）
python3 -m servers.engine
```

### 接到 DSH

在插件配置里加一条 `mcp-client` 条目：

```yaml
- id: mcp-arma3-engine
  name: '@deepseek-ai/dsh-mcp-client'
  config:
    serverName: arma3_engine
    transport: stdio
    command: python3
    args: ['-m', 'servers.engine']
    cwd: <repo>
    env:
      A3MCP_ENGINE_WRITE: '1'      # 改游戏世界
      A3MCP_ENGINE_EXOTIC: '0'     # 生成资源/网络协调（默认关）
      A3MCP_INPUT_INJECT: '0'      # 原生输入注入（默认关）
```

工具名形如 `mcp__arma3_engine__cmd_info`。

**在本机 DSH 上接入时的两个实测注意点**（写在
`~/.dsh/profiles/web/cordis.patch.yml` 里）：

1. **插件名必须写 `file://` 绝对路径，不能写包名。**
   该插件包不在 profile 的依赖里（只在 `$DSH_HOME/profiles/node_modules`
   的安装闭包镜像中）。Cordis loader 对不以 `.` 开头的名字**直接交给 `import()`**，
   裸绝对路径会被当成包名而解析失败。可用路径：

   ```yaml
   name: 'file:///home/<user>/.dsh/profiles/node_modules/@deepseek-ai/dsh-mcp-client/lib/index.js'
   ```

2. **`command` 写 `/usr/bin/python3` 绝对路径。**
   MCP 子进程的环境变量会被清洗（凭形状剔除凭据与陈旧变量），PATH 不保证与
   交互 shell 一致。本仓库只用标准库，故不依赖虚拟环境。

接入后需让 DSH 重新加载配置（profile 的 `patchReload: live` 会监视 patch 文件，
但**是否立即生效取决于运行中的实例**；若工具未出现则重启 DSH）。

## 工具

**知识（离线，不需要游戏）**

| 工具 | 用途 |
|---|---|
| `capability_matrix` | **先问它**：某项操作引擎能不能做、该在哪一层做（如"能不能注入鼠标点击"） |
| `cmd_families` | 命令族目录（set/get/create/ctrl/…共 40+ 族） |
| `cmd_search` | 按关键词检索命令与官方函数 |
| `cmd_info` | 完整签名：所有调用形式、参数类型与说明、返回类型、Arma 3 引入版本 |
| `cmd_check` | 用实际参数试校验（不执行） |
| `cmd_gate` | 某条命令当前是否放行、属于哪一级、需要哪个开关 |

**执行（需要 SQF 执行器）**

| 工具 | 用途 |
|---|---|
| `exec` | 执行一条命令（查库 → 校验 → 过闸门 → 发送）。建议先 `dry_run=true` |
| `exec_batch` | 按顺序执行多条（默认上限 8 条，规避引擎侧队列丢弃） |

**配置查询（需要 SQF 执行器）**

| 工具 | 用途 |
|---|---|
| `config_tree` | 浏览游戏内 config 树的子类 |
| `config_class` | 读一个类的摘要（父类、继承链、关键属性） |
| `config_value` | 精确读若干个属性值 |
| `config_search` | 按通配符搜类名（`B_MRAP*`） |
| `config_of` | 从游戏内实体跳到它的 config |
| `config_cache` | 查看／清空 config 查询缓存 |

**控制与视觉（只要 DLL 加载，主菜单即可用）**

| 工具 | 用途 |
|---|---|
| `gates_status` | 闸门状态、通道连通性，**以及执行器是否真的在跑** |
| `game_link` | DLL 内部状态（收件/发件/丢弃、心跳），排查"发了没反应"的第一步 |
| `game_events` | 取回游戏侧主动上报的事件（命令错误、队列水位） |
| `window_info` | 窗口几何与客户区原点（坐标换算用） |
| `focus_game` | 把游戏窗口切到前台（输入注入前提） |
| `screenshot` | 截取游戏画面并**直接返回图片**给模型 |
| `input_click` / `input_drag` / `input_key` / `input_move` | 原生输入注入（鼠标/键盘） |
| `ui_locate` | 在 UI 里查找控件并换算出**可点击的屏幕坐标**（坐标校准） |

**两条约定**

1. 参数一律用位置数组：`args=[["u_17"], [100, 200, 0]]`
2. 游戏实体用**单元素数组**承载：`["u_17"]` 是字符串，`[["u_17"]]` 才是实体

## 安全模型

| 级别 | 含义 | 默认 |
|---|---|---|
| `read` | 只读查询与纯计算 | 放行 |
| `write` | 改变游戏世界 | 放行（可关） |
| `exotic` | 凭空生成资源 / 网络协调 / 调试后门 | **拒绝** |
| `forbidden` | 动态代码执行面（`execVM`/`compile`/`callExtension`/`remoteExec`…） | **永远拒绝** |

硬禁命令**没有任何开关能放行**，包括显式白名单 `A3MCP_ALLOW_COMMANDS`——这是刻意
的设计：MCP 工具的参数来自 LLM，一旦命令名可以来自任意字符串，全部类型校验与
白名单都会退化为装饰。详见 [`docs/safety.md`](docs/safety.md)。

## 独立的含义

| 维度 | 做法 |
|---|---|
| 代码 | 不 import、不 subprocess 调用其它 Arma 代码库；**经验可以移植，代码不复制** |
| 数据 | 自带 `data/commands.json.xz`；来源是编辑器扩展的官方命令定义（与本机代码库无关），可由 `tools/build_commands.py` 重建 |
| 依赖 | 运行时只用 Python 标准库 |
| 验证 | `tools/check_independence.py`：静态扫描 + 数据重建比对 + **隔离副本内跑全套测试** |

## 目录

```
mcpcore/      零依赖 MCP stdio 骨架（jsonrpc / schema / registry / server）
servers/      engine.py —— 单机形态入口
knowledge/    命令库读取、族分类、签名解析、参数校验、结构化调用序列化
guard/        闸门与风险分级、审计
adapters/     执行通道抽象（P0 为 NullChannel）+ 执行/控制面工具
data/         commands.json.xz（自带命令库）、capabilities.json（实测能力边界）
tools/        build_commands.py（生成数据）、check_independence.py（独立性）
tests/        111 个用例，含对全部 5181 条命令的自检
docs/         history（复盘）/ backlog（待办）/ server-capabilities / decisions / deploy / safety / provenance
```

## 数据来源与致谢

命令定义来自 **SQFLint** 编辑器扩展（`skacekachna.sqflint`）的
`definitions/documentation.json`，其内容源自 Bohemia Interactive 官方 wiki。
本仓库只读取该文件生成自己的数据副本，运行期不再访问它。

移植自其它项目的**结论**（非代码）逐条记录在 [`docs/provenance.md`](docs/provenance.md)。
