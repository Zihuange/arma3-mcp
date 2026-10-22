# 部署

## P0（当前可用）：纯离线知识层

不需要游戏、不需要任何游戏侧组件。

```bash
# 1) 生成自带命令库（从编辑器扩展的官方命令定义）
python3 tools/build_commands.py

# 2) 生成能力矩阵（核对依据命令后写入 data/capabilities.json）
python3 tools/build_capabilities.py

# 3) 自检
python3 -m unittest discover -s tests -t .
python3 tools/check_independence.py
```

### 接到 DSH

本机 DSH 的用户 patch 层是 `$DSH_HOME/profiles/web/cordis.patch.yml`
（顶层为 YAML 数组；新增条目用 `insert`，追加到 loader 配置树末尾）。
**不要改 `cordis.yml`**——它是空条目表，实际配置由各 bundle 与 patch 层叠加而成。

以下配置已在本机实测写入（`~/.dsh/profiles/web/cordis.patch.yml`）：

```yaml
- insert:
    - id: mcp-arma3-engine
      name: 'file:///home/<user>/.dsh/profiles/node_modules/@deepseek-ai/dsh-mcp-client/lib/index.js'
      config:
        serverName: arma3_engine
        transport: stdio
        command: /usr/bin/python3
        args: ['-m', 'servers.engine']
        cwd: <repo>
        env:
          A3MCP_ENGINE_READ: '1'
          A3MCP_ENGINE_WRITE: '1'
          A3MCP_ENGINE_EXOTIC: '0'
          A3MCP_INPUT_INJECT: '0'
          A3MCP_UI_CONTROL: '1'
          A3MCP_AUDIT_LOG: <repo>/audit.jsonl
        toolCallTimeoutMs: 30000
        failOnStartupError: false
```

工具名形如 `mcp__arma3_engine__cmd_info`。

**两个必须按本机实际情况写的字段**（都不是风格问题，写错就起不来）：

| 字段 | 必须写成 | 原因 |
|---|---|---|
| `name` | `file://` 绝对路径 | 该插件包不在 profile 依赖里，只在 `$DSH_HOME/profiles/node_modules` 安装闭包镜像中；Cordis loader 对不以 `.` 开头的名字**直接 `import()`**，裸绝对路径会被当包名而失败 |
| `command` | `/usr/bin/python3` | MCP 子进程 env 被清洗（凭形状剔除凭据与陈旧变量），PATH 不保证与交互 shell 一致 |

**生效方式**：profile 的 `patchReload` 为 `live` 时会监视 patch 文件，但运行中的实例是否
立即应用取决于其实现。**若工具未出现，重启 DSH**（本机为 `~/dsh-start.sh`，
它会在 WSL 内启动 `dsh web --port 3001` 并起 socat 前端，同时清理 3001/3080 等端口）。

**验证方法**（不需要重启也能做的部分）：用最小环境复刻 MCP 客户端的启动方式，
确认服务器能被拉起并列出工具：

```bash
cd /tmp && env -i A3MCP_ENGINE_WRITE=1 /usr/bin/python3 -m servers.engine  # 需 cwd 指向仓库
```
（`env -i` 模拟"没有 PATH"的清洗环境；能起来说明启动条件不依赖交互 shell 的环境。）

⚠ 若在受限沙箱（bwrap `--unshare-pid`）里操作，`ps` 看不到宿主的 DSH 进程，
只能靠日志文件、端口探测与该复刻启动来间接确认。

### 环境变量一览

| 变量 | 默认 | 作用 |
|---|---|---|
| `A3MCP_ENGINE_READ` | `1` | 只读查询 |
| `A3MCP_ENGINE_WRITE` | `1` | 改变游戏世界 |
| `A3MCP_ENGINE_EXOTIC` | `0` | 生成资源 / 网络协调 / 调试后门 |
| `A3MCP_ENGINE_CALL` | `0` | `call`（有条件放行：目标函数名仍要过 `CALL_DENY`） |
| `A3MCP_PROFILE` | 空 | `debug` = 只打开 `EXOTIC` 与 `ENGINE_CALL` 的默认值（不动写闸门与输入注入，解不开硬禁）；**`unrestricted` = 无门控模式**，所有命令与校验全部放开，见 [safety.md](safety.md) |
| `A3MCP_UNRESTRICTED` | `0` | `1` 等价于 `A3MCP_PROFILE=unrestricted`（更直白的写法）。**它会让硬禁命令、CALL_DENY、表达式白名单全部失效**，且审计会标记 `mode=unrestricted` |
| `A3MCP_ALLOW_CHEAT` | `0` | 调试类命令（`attrit` 等）单独开关 |
| `A3MCP_ALLOW_COMMANDS` | 空 | 显式放行的命令名（逗号分隔，**解不开硬禁，也放不开 `call`**） |
| `A3MCP_UI_CONTROL` | `1` | UI 控件操作 |
| `A3MCP_INPUT_INJECT` | `0` | 原生输入注入 |
| `A3MCP_INPUT_FOREGROUND_ONLY` | `1` | 仅前台注入 |
| `A3MCP_INPUT_TEXT` | `1` | 文本输入（不支持输入法） |
| `A3MCP_CHANNEL` | `null` | 执行通道类型（P1 起支持 `pipe` / `tcp`） |
| `A3MCP_AUDIT_LOG` | 空 | 审计 JSONL 落点 |
| `ARMA3_MCP_CMD_SOURCE` | 空 | 命令定义来源路径（覆盖自动探测） |

## 方式二：Windows 侧手动启动 + HTTP 传输（推荐用于本机单机）

**为什么需要这种方式**：本机 DSH 是跑在 WSL 里的 Node 进程，而
**WSL 的 Node 无法执行 Windows 程序**（`spawn` 返回 ENOENT，实测见
`docs/decisions.md` D14）。所以 DSH 无法用 stdio 自动拉起 Windows 侧的 MCP 进程。
改用 HTTP：**用户手动启动**服务端，DSH 作为 HTTP 客户端连过来。

**收益**：MCP 与游戏同处 Windows 网络栈 —— 游戏侧可 `127.0.0.1` 直连，
不需要"反连进 WSL"那套绕行（WSL IP 变动、只能绑 0.0.0.0 等问题随之消失）。

### 启动（Windows 侧）

```bat
<repo>\start_windows.bat          :: 默认端口 32128
<repo>\start_windows.bat 32130    :: 指定端口
```

启动器会打印两行关键信息：

```
  本机地址   : http://127.0.0.1:32128/mcp
  ★ DSH 填这个: http://192.168.160.1:32128/mcp
```

**那个带星号的就是 DSH 要填的 url** —— 它是 Windows 上 `vEthernet (WSL)`
网卡的 IPv4，WSL 经它访问 Windows。

### 两个硬约束（都是实测结论）

| 约束 | 后果 |
|---|---|
| 服务端必须绑 `0.0.0.0` | 只绑 `127.0.0.1` 时 **WSL 连不进来**（NAT 隔离） |
| DSH 必须填**网关地址**，不能填 `127.0.0.1` | WSL 的 `127.0.0.1` 是它自己的回环 |

⚠ `vEthernet (WSL)` 的 IP 在 WSL 重启后**可能变化**。若 DSH 报连不上，
重跑启动器取新的带星号地址并更新 DSH 配置里的 `url`。

### DSH 侧配置

```yaml
- id: mcp-arma3-engine-http
  name: 'file:///<DSH_HOME>/profiles/node_modules/@deepseek-ai/dsh-mcp-client/lib/index.js'
  config:
    serverName: arma3_engine
    transport: streamable-http
    url: http://192.168.160.1:32128/mcp
    toolCallTimeoutMs: 30000
    failOnStartupError: false
```

### 验证（不依赖 DSH）

```bash
# 在 WSL 里；GW 取 WSL 的默认网关（即 Windows 的 vEthernet (WSL) 地址）
GW=$(ip route | awk '/default/{print $3}')
curl -s http://$GW:32128/health                      # {"ok":true,"server":"arma3-mcp"}
curl -s -X POST http://$GW:32128/mcp \
     -H 'Content-Type: application/json' \
     -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}'
```

### HTTP 传输的实现取舍

采用 **无状态 JSON 响应**模式：一个 POST 进来、一个 JSON 出去，不开 SSE 流。
理由：本服务器的工具没有跨请求会话状态（执行通道是进程级的），无状态实现更简单、
出错时看到的就是一个普通 HTTP 请求，好排查。

- `POST /mcp` —— JSON-RPC 请求回 JSON；通知回 `202` 无正文
- `GET /mcp` —— 返回 `405` 并说明本服务器不推送（**不挂住连接**：挂住会让客户端
  以为服务端支持 SSE，从而一直等）
- `DELETE /mcp` —— `204`
- `GET /health` —— 存活探测（运维用，非 MCP 协议）
- 工具失败返回 `200` + `isError`，**不是** HTTP 错误码 —— 部分客户端会把非 2xx
  当传输故障并断开，那会把"工具报错"升级成"服务器不可用"

---

## P1（待实现）：游戏内执行通道

> ⚠ 以下为设计，**尚未实现**。落地时须按本机既有工程的分支与合并流程走。

### 本地单机形态（主形态）

```
DSH ──stdio──> servers.engine
                 └─ PipeChannel ──命名管道──> arma3_mcp_x64.dll（游戏进程内）
                                                  └─ SQF 执行器（-init= 注入）
```

**为什么用命名管道而不是 TCP**：同机通信无需监听端口，不受防火墙与端口占用影响，
且管道名可带进程 id（`\\.\pipe\arma3-mcp-<pid>`），多开游戏实例天然隔离。

**为什么要 DLL 而不是纯 SQF + 文件交换**：DLL 在游戏进程内，可以直接完成
引擎做不到的原生输入注入（能力矩阵中的 `inject_mouse_click` / `inject_keyboard` /
`drag_pointer` 三条），不必再引入一个外部注入进程——省掉窗口焦点竞态与跨进程坐标换算。

**DLL 硬约束**（来自既有工程的实测结论，见 `provenance.md`）：
- 导出函数在游戏逻辑线程内执行，**内部绝不阻塞**：管道读写、输入注入全部交给后台线程，
  导出函数只做队列交换；
- 下行队列设上限，**满时丢弃最老**并把丢弃计数回报给 MCP（否则会出现"命令静默消失"）；
- 返回缓冲有长度上限，大结果需分块或多段 poll 取；
- 管道名必须带进程 id，否则两个游戏实例会抢同一管道。

**启动方式**（沿用既有工程验证过的参数形态）：

```bat
arma3_x64.exe -mod=<本仓库 addon 路径> -init=<本仓库 init.sqf> -profiles=<专用目录>
```

DLL 需放在可加载目录（mod 根，引擎优先探测 `<name>_x64.dll`），并加 `-filePatching`。

**SQF 执行器的职责**（保持极薄）：短周期 `callExtension "poll"` 取命令 →
白名单与类型校验 → 执行 → 结果序列化回推。它不做业务判断。

### 专用服务器形态（次形态）

同一 DLL 走 TCP 模式即可复用（既有工程已验证该路径）。此形态下：

- 世界/单位层命令可用（`exec` / `config_*`；执行器照常由模组的 preInit/postInit 拉起）；
- **UI 与输入注入层不可用**（locale effect，需要进程内有玩家）——
  服务器形态下这些工具要**明确拒绝并说明原因**，而不是超时或静默失败。

**已实现**：形态判定与拒绝逻辑（`adapters/health.py` 的 `has_ui` / `require_ui`）。

判据是两条一起看：**DLL 答得出 `status`**（证明扩展确实加载在游戏进程里），
**但 `window_info` 找不到窗口** —— 这个前提下无窗口就是服务器的预期状态。
只有第一条成立而第二条失败时才判为无头；DLL 没答、或查询超时，都如实报"无法
判断"，绝不猜成服务器（那会把故障说成形态度）。

`window_info` 自身不走这个检查：它是"看"的工具，把"找不到窗口"如实报出来本身
就是有用信息，也正是本判据的依据。判定结果按进程缓存（`forget_ui_cache()` 在
换连接后清）。

**已在真实专用服务器上跑通**（2026-09-25，`arma3server_x64.exe` + `server/` 测试环境）：

| 项 | 结果 |
|---|---|
| 形态判定 | ✅ 判为无头；`screenshot` / `ui_locate` 明确拒绝并说明原因 |
| `exec` / `config_*` | ✅ 正常（`worldName` → "Altis"，100 ms；`config_tree` 返回 8392 个子类） |
| 执行器 | ✅ 由任务 `initServer.sqf` 拉起，心跳"运行中" |

**跑通它需要的四个前提**（每个都踩过，缺一不可）：

1. **`persistent = 1`** —— 否则 `-autoInit` 被跳过，服务器会明说
   "Autolnit is supported only for persistent missions!"。
2. **任务必须放在 `<游戏目录>/mpmissions/`** —— `-profiles=` 只改 profile 位置，
   **不改任务搜索路径**（实测报错原文：`Can't find mission template: ... in 'mpmissions\'`）。
   `手动启动专用服务器（见 README）` 现在每次启动都会自动把 `server/mpmissions/` 里的任务拷过去。
3. **任务不能声明过时的 addon** —— 模板里的 `A3_Characters_F` 在现代版本对应不到
   pbo（现名 `characters_f.pbo`），引擎会以"依赖已删除的 DLC"为由拒绝加载。
   空场景不需要任何 addon 声明。
4. **`server.cfg` 的 `class Missions`** 与 `-autoInit` 配合；用命令行 `-mission=`
   代替是行不通的（同样受 persistent 限制）。

另外：任务骨架取自 `arma_llm_commander` 的空场景（已确认其中引用 alc 函数 0 次，
无代码耦合），来源记在 provenance.md。BattlEye 已按 `BattlEye = 0;` 关闭。



## 模组部署与签名（每次改模组都要走一遍）

**改完 SQF 一定要重打包 + 重签 + 重新部署。** 三步少一步，都有一个**静默**失败：

| 漏了哪步 | 现象 |
|---|---|
| 没重打包 | 游戏跑的还是旧 PBO —— 新函数不存在（Undefined variable），日志里不一定有提示 |
| 重打包了但没重签 | `.bisign` 描述的是**旧内容**；`-verifySignatures` 环境下加载失败/被踢，而单机编辑器里**完全正常** |
| 签了但只拷 PBO | 游戏目录里是「新 PBO + 旧签名」—— 同上，而且更难看出来（文件名都对） |

所以这两步现在都固化成脚本，不要手工做：

```bash
bash tools/modkit.py pack --out build/pbo_out   # 打包 + 自动签名 + 官方复核
bash tools/modkit.py deploy                     # 拷 PBO 与 bisign + 比对哈希 + 复核签名
```

### 打包时自动签名（`pack_mod.sh` 的 4.5/5 步）

- 签名工具：`<Arma 3 Tools>/DSSignFile/DSSignFile.exe`
- 私钥：默认 `<Arma 3 Tools>/DSSignFile/BTA.biprivatekey`，可用 `ARMA3_SIGN_KEY` 指定
- **私钥不在仓库里**（也不该在）。缺私钥时脚本**直接失败**——出一个未签名包
  比不出包更糟，因为它看起来是成功的。
- 签完会做两道防呆：`bisign` 必须比 PBO 新；再用 `DSCheckSignatures.exe` 复核
  （它判断的是**内容是否匹配**，不只看文件在不在）。
- 确实不需要签名时：`--no-sign`（显示警告，请确认环境不校验签名再用）。

### 部署（`deploy_mod.sh`）

它做三件事，正好堵住手工拷贝的两个坑：

1. **游戏在运行就拒绝** —— PBO 被占用时拷贝会失败；
2. **PBO 与 `.bisign` 一起拷**，并**逐个**检查结果、拷完**比对哈希**；
   （手工拷多个文件时 `$?` 只反映最后一条命令，实测 PBO 失败、bisign 成功，
   脚本照样打印成功 —— 于是留下「旧 PBO + 新签名」）
3. 用 `DSCheckSignatures.exe` 复核签名。

`--check-only` 只校验当前部署状态，不拷贝。

### 签名校验的判据（实测）

`DSCheckSignatures.exe <被检查目录> <keys 目录>`：

| 情况 | 输出 |
|---|---|
| 通过 | **无输出** |
| 文件没签名 | `No signature found for <pbo>` |
| 签名与内容不匹配 | `Signature <pbo>.<key>.bisign is wrong` |

**判据用"有没有输出"，不要猜错误措辞** —— 本仓库的部署脚本最初只匹配 `invalid`，
于是 `is wrong` 被漏掉、把失败报成了成功。

### 公钥分发

- 客户端：`.bikey` 放进游戏的 `keys/`（本仓库在 `game/mod/keys/BTA.bikey`）；
- 专用服务器：放进服务器的 `keys/`，并在 `server.cfg` 里 `verifySignatures = 2`;
- **客户端与服务器必须用同一个密钥对**，否则客户端会被踢。

## 故障排查

| 现象 | 检查 |
|---|---|
| 工具未出现在 DSH 里 | `python3 -m servers.engine` 能否启动；`cwd` 是否为本仓库根 |
| `exec` 报"未接通" | P0 的正常行为（无执行通道）；P1 起检查游戏是否加载了 DLL |
| 命令库缺失 | 运行 `python3 tools/build_commands.py` |
| 能力矩阵缺失 | 运行 `python3 tools/build_capabilities.py` |
| 数据重建校验失败 | 命令定义来源已更新，重跑 `build_commands.py` 并提交新产物 |
