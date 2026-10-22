# arma3-mcp

把 **Arma 3（Real Virtuality 引擎）的能力面**暴露给 AI Agent 的 MCP 服务器：
5000+ 条引擎命令与官方函数，可用**结构化调用**在游戏内执行。

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

**本仓库完全自持**——不 import、不调用、不依赖其它 Arma 代码库，运行时只用
Python 标准库。这条约束由 `tools/check_independence.py` 作为可执行断言守护，
而不是写在文档里当承诺。

---

## 安装

需要 **Python 3.9+**。没有第三方依赖——不用 `pip install` 任何东西。

```bash
git clone <你的仓库地址> arma3-mcp
cd arma3-mcp

# 1) 复制配置模板（之后按需修改）
cp a3mcp.example.json a3mcp.json

# 2) 生成自带命令库（第一次必须做；数据从本机的 SQFLint 编辑器扩展读取）
python tools/build_commands.py

# 3) 自检（可选，但建议）：345 项测试 + 独立性断言
python -m unittest discover -s tests -t .
python tools/check_independence.py
```

游戏侧还需要一个模组（PBO + DLL），见下面的「打包与部署」与「挂载模组」。

## 连接方式

两条**独立**的链路，各自可配：

```
MCP 客户端  ──(stdio 或 HTTP)──▶  arma3-mcp 服务器  ──(TCP)──▶  游戏内 DLL
                                ^ start.py                       ^ 主动连入
```

### 客户端 ↔ MCP 服务器

| 方式 | 何时用 | 怎么做 |
|---|---|---|
| **stdio（默认，推荐）** | 客户端与服务器同机 | 客户端配置里让 `command` 指向 `start.py`，它自己拉起进程 |
| `http` | 客户端无法执行本进程（典型：客户端在 WSL，服务器在 Windows） | 手动 `python start.py --http`，客户端填 `url` |

stdio 的客户端配置示例（以支持 `command`/`args` 的 MCP 客户端为例）：

```json
{
  "mcpServers": {
    "arma3_engine": {
      "command": "python",
      "args": ["<repo>/start.py"]
    }
  }
}
```

HTTP 方式：

```bash
python start.py --http            # 默认 0.0.0.0:32128
python start.py --http --http-port 32130
```

> **为什么 HTTP 只绑 `127.0.0.1` 会不通**：WSL2 是 NAT，客户端要从**网关地址**
> 访问才可达。所以默认绑 `0.0.0.0`，`start.py` 在 HTTP 模式下会打印可用的网关地址。
> 若客户端在 WSL 且**同样访问不了**，可用仓库里的 `wsl_forward.py` 做本机回环转发。

### MCP 服务器 ↔ 游戏 DLL

服务器监听 `server.tcp_port`（默认 **32132**），由游戏内的扩展 DLL **主动连入**
（引擎不提供"从外部推送"的机制，只能由游戏侧轮询取命令）。

`32132` 必须与 `arma3_mcp_extension.cpp` 里的默认端口一致——不一致时游戏侧连不上，
而且**没有明显提示**。`gates_status` 会显示通道是否接通、执行器是否在取命令。

## 挂载模组

本仓库**不提供**启动游戏的脚本：安装路径、其它模组、启动参数每个人都不同，
脚本最后只会变成"又一个要改的东西"。手动挂载只需要一个参数：

```bat
:: 最小启动：挂上模组、跳过开场
"<Arma3 安装目录>\Arma3_x64.exe" -mod="<repo>\game\mod" -skipIntro -noSplash
```

要点：

- `-mod=` 指向**模组根目录**（含 `addons\`、`keys\` 的那一层），不是 `addons` 本身；
- 路径含空格时**必须加引号**；多个模组用分号分隔：`-mod="<mod1>;<mod2>"`；
- 模组目录里必须有：`addons\a3mcp.pbo`、`arma3_mcp_x64.dll`、`keys\<name>.bikey`；
- DLL 有两个名字（`arma3_mcp.dll` / `arma3_mcp_x64.dll`），x64 进程优先找后者；
- **签名**：若游戏或服务器启用 `-verifySignatures`，客户端的 `keys/` 里需要有
  **同一个** `.bikey`，否则模组会被拒绝加载。

### 执行器什么时候启动（最容易误解的一点）

**停在主菜单时，`exec` / `config_*` 不可用**——这不是配置问题，是引擎行为：

| 时机 | 能做 |
|---|---|
| 游戏启动（`-init=`） | 加载 DLL；`screenshot`/`input_*`/`window_info` 可用 |
| **任务加载后** | 模组 CfgFunctions 才编译，执行器启动，`exec`/`config_*` 才可用 |

原因：CfgFunctions 的编译由 preInit/postInit 驱动，而那是**任务作用域**的事件；
`-init=` 又跑在调度器起来之前，连 `spawn` 都不执行。详见
[`docs/decisions.md`](docs/decisions.md) D20。

## 打包与部署

改了 SQF 之后，**打包 → 重签 → 部署**三步都不能省（漏一步都是静默失败：

| 漏了哪步 | 现象 |
|---|---|
| 没重打包 | 游戏跑旧 PBO，新函数不存在 |
| 重打包没重签 | `.bisign` 描述旧内容；校验签名的环境加载失败，而单机编辑器正常 |
| 签了但只拷 PBO | 「新 PBO + 旧签名」，文件名全对、更难发现 |

用同一个入口做完：

```bash
python tools/modkit.py pack      # SQF 检查 → rapify → 打包 → PBO 校验 → 签名 → 官方复核
python tools/modkit.py deploy    # 游戏在跑就拒绝 → PBO+签名一起拷 → 哈希比对 → 签名复核
python tools/modkit.py check     # 只校验当前部署的签名
```

首次打包需要**一对签名密钥**（`pack` 会告诉你缺什么）：

```bat
:: 在 Arma 3 Tools 的 DSSignFile 目录下
DSCreateKey <你的名字>
:: 产生 <名字>.biprivatekey（私钥，绝不要提交）与 <名字>.bikey（公钥，随发布分发）
```

私钥放 `~/.arma3-mcp/<名字>.biprivatekey`，或在 `a3mcp.json` 的 `toolkit.sign_key`
指定。公钥放 `game/mod/keys/`。

## 配置

所有启动参数都在 `a3mcp.json`（从 `a3mcp.example.json` 复制）。优先级：

**命令行 > 环境变量 > `a3mcp.json` > 内置默认**

关键项（完整说明见模板里的 `_help_*` 字段）：

| 键 | 默认 | 说明 |
|---|---|---|
| `server.transport` | `stdio` | `stdio` / `http` |
| `server.tcp_port` | `32132` | **必须与 DLL 默认端口一致** |
| `server.channel` | `tcp` | `tcp` / `null`（不监听） |
| `gates.*` | 见模板 | 命令分级闸门，默认最保守但仍可用 |
| `gates.profile` | 空 | `debug` / `unrestricted`（后者无门控，见 [`docs/safety.md`](docs/safety.md)） |
| `toolkit.*` | — | 仅供 `tools/modkit.py` 使用 |

## 当前状态

| 阶段 | 内容 | 状态 |
|---|---|---|
| **P0** | MCP 协议骨架、自带命令库、知识/校验/闸门、全量自检、独立性验证 | ✅ 已完成 |
| **P1** | 游戏内执行通道（扩展 DLL + SQF 执行器），实机闭环 | ✅ 已完成 |
| **P2** | 用户操作模拟（UI 控件、原生输入注入、坐标校准） | ✅ 已完成 |
| **P3** | 专用服务器形态（TCP 通道） | ✅ 已完成 |

P2 的坐标校准（`ui_locate`）已真机闭环；UI **写入**只对自建控件可靠，引擎内建 UI
会静默忽略——那是能力边界而非缺陷（D24）。P3 已在真实 `arma3server_x64.exe` 上打通
（`exec`/`config` 可用、UI 工具明确拒绝）。未验证项逐条列在
[`docs/local-setup.md`](docs/local-setup.md)。

### 现在到底能做什么（按"要不要游戏世界"分）

**通道接通 ≠ 命令有人执行**：

| 能力 | 需要什么 | 说明 |
|---|---|---|
| 全部知识工具（`cmd_*`／`capability_matrix`） | 什么都不需要 | 纯离线：查签名、校验参数、预演 |
| `screenshot`／`window_info`／`focus_game`／`input_*` | 只要 DLL 加载 | 由 DLL 直接处理，**停在主菜单也能用** |
| `game_link`／`gates_status` | 只要 DLL 加载 | 用来判断执行器到底在不在跑 |
| `exec`／`exec_batch`／`config_*` | **SQF 执行器在运行** | 需要游戏世界（任务加载后） |
| UI 与输入注入类 | **有界面**的进程 | 专用服务器上是 locale effect；这类工具会**明确拒绝并说明原因**，不会静默失败 |

`exec` 超时或未接通时，错误里会附带诊断，不再让人对着"超时"猜。

## 数据来源与致谢

命令库包含 **5181 条**命令与官方函数的结构性信息（命令名、类型、调用签名、
版本兼容、来源）。这些是**事实性数据**。

> 本仓库**不包含** BI wiki 的描述正文。需要说明时，`cmd_info` 会给出对应
> wiki 页面的链接（由命令名直接拼出）。原因见 [`NOTICE`](NOTICE)。

来源与致谢：

- 命令定义来自 §**SQFLint**（`skacekachna.sqflint`，MIT）的 `definitions/documentation.json`，
  其内容源自 **Bohemia Interactive 官方 wiki**；
- DIK 扫描码表来自 **Windows SDK** 的 `dinput.h`；
- 从其它工程学到的**结论**（非代码）逐条记在 [`docs/provenance.md`](docs/provenance.md)。

## 文档

| 文件 | 内容 |
|---|---|
| [`docs/deploy.md`](docs/deploy.md) | 部署细节、两种连接方式的环境变量、故障排查 |
| [`docs/safety.md`](docs/safety.md) | 安全模型：分级、闸门、白名单、无门控模式 |
| [`docs/decisions.md`](docs/decisions.md) | 决策记录（D1–D40），每条都有当时的依据与代价 |
| [`docs/engine-traps.md`](docs/engine-traps.md) | 引擎行为陷阱（静默失败清单） |
| [`docs/local-setup.md`](docs/local-setup.md) | 作者本机的实测环境（供对照，非安装指南） |
| [`docs/history.md`](docs/history.md) | 开发复盘：转折点与代价最高的教训 |

## 许可

代码以 **MIT** 发布，见 [`LICENSE`](LICENSE)。
第三方内容与来源见 [`NOTICE`](NOTICE)。

"Arma"、"Arma 3"、"Bohemia Interactive" 等为 Bohemia Interactive a.s. 的商标。
本仓库不是 BI 官方产品，也未获其背书。
