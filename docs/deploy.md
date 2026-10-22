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
          ALC_ENGINE_READ: '1'
          ALC_ENGINE_WRITE: '1'
          ALC_ENGINE_EXOTIC: '0'
          ALC_INPUT_INJECT: '0'
          ALC_UI_CONTROL: '1'
          ALC_AUDIT_LOG: <repo>/audit.jsonl
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
cd /tmp && env -i ALC_ENGINE_WRITE=1 /usr/bin/python3 -m servers.engine  # 需 cwd 指向仓库
```
（`env -i` 模拟"没有 PATH"的清洗环境；能起来说明启动条件不依赖交互 shell 的环境。）

⚠ 若在受限沙箱（bwrap `--unshare-pid`）里操作，`ps` 看不到宿主的 DSH 进程，
只能靠日志文件、端口探测与该复刻启动来间接确认。

### 环境变量一览

| 变量 | 默认 | 作用 |
|---|---|---|
| `ALC_ENGINE_READ` | `1` | 只读查询 |
| `ALC_ENGINE_WRITE` | `1` | 改变游戏世界 |
| `ALC_ENGINE_EXOTIC` | `0` | 生成资源 / 网络协调 / 调试后门 |
| `ALC_ALLOW_CHEAT` | `0` | 调试类命令（`attrit` 等）单独开关 |
| `ALC_ALLOW_COMMANDS` | 空 | 显式放行的命令名（逗号分隔，**解不开硬禁**） |
| `ALC_UI_CONTROL` | `1` | UI 控件操作 |
| `ALC_INPUT_INJECT` | `0` | 原生输入注入 |
| `ALC_INPUT_FOREGROUND_ONLY` | `1` | 仅前台注入 |
| `ALC_INPUT_TEXT` | `1` | 文本输入（不支持输入法） |
| `ALC_CHANNEL` | `null` | 执行通道类型（P1 起支持 `pipe` / `tcp`） |
| `ALC_AUDIT_LOG` | 空 | 审计 JSONL 落点 |
| `ARMA3_MCP_CMD_SOURCE` | 空 | 命令定义来源路径（覆盖自动探测） |

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

- 世界/单位层命令可用；
- **UI 与输入注入层不可用**（locale effect，需要进程内有玩家）——
  服务器形态下这些工具要**明确拒绝并说明原因**，而不是超时或静默失败。

## 故障排查

| 现象 | 检查 |
|---|---|
| 工具未出现在 DSH 里 | `python3 -m servers.engine` 能否启动；`cwd` 是否为本仓库根 |
| `exec` 报"未接通" | P0 的正常行为（无执行通道）；P1 起检查游戏是否加载了 DLL |
| 命令库缺失 | 运行 `python3 tools/build_commands.py` |
| 能力矩阵缺失 | 运行 `python3 tools/build_capabilities.py` |
| 数据重建校验失败 | 命令定义来源已更新，重跑 `build_commands.py` 并提交新产物 |
