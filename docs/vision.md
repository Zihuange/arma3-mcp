# 视觉理解：让 Agent 看到游戏画面

## 链路

```
游戏进程(DLL) ──PrintWindow──> PNG 文件 ──> MCP 读文件 ──> image content
                                                              │
                                              ┌───────────────┘
                                              ▼
                                    支持视觉的模型（Agent 侧）
```

三段的职责：
1. **DLL**：`capture` 用 `PrintWindow` + `PW_RENDERFULLCONTENT` 抓 D3D 画面，
   存 PNG 到磁盘。**不要求游戏在前台**（截图在后台可行；只有输入注入才必须前台）。
2. **MCP**：`screenshot` 工具读回 PNG、base64 编码，作为 **MCP image content**
   返回（`{"type":"image","data":...,"mimeType":"image/png"}`）。
   注意：DLL 与 MCP **同在 Windows**，DLL 返回的 Windows 路径可直接用，
   不要换算成 WSL 形式。
3. **Agent 侧**：模型必须**支持图片输入**才能看到内容。

## 当前模型的限制与本机可用选项

本机默认模型 `deepseek/deepseek-v4.1-flash` **不支持图片输入**。
CommandCode（`provider: commandcode`）档位从高到低为 `provider > pro > goat > go`，
视觉能力由硬编码集合 `KNOWN_IMAGE_MODELS`（49 项）判定。

**同系列最省事的选择**：
```
deepseek/deepseek-v4-flash-vision-exp     # Go 档位，支持图片输入
```
**GOAT 档位的视觉模型**：`google/gemini-3.8-flash`、`google/gemini-3.7-flash`、
`xai/grok-4.6`、`gpt-5.6-sol`、`meta/muse-spark-1.3`、`meta/muse-spark-1.2`。

## 用法一：切换当前模型（最直接）

在 DSH 里把模型切到上面任一视觉模型，然后直接调 `screenshot` 工具即可。

## 用法二：不开子代理，用 workflow 临时借一个视觉模型

当前模型不支持图片时，可以用 `workflow` 的 `agent()` —— 它是唯一支持
按需覆盖 provider/model 的入口（`subagent` 工具没有 model 参数）：

```javascript
const desc = await agent(
  "用 read_image 读取 <png 路径>，然后详细描述画面；不确定的明说不确定。",
  { provider: "commandcode", model: "deepseek/deepseek-v4-flash-vision-exp" }
);
return { description: desc };
```

## 验证画面有效性（不依赖视觉模型）

视觉模型可能不可用，但"截图是不是黑屏"这个问题必须能独立回答——
`PrintWindow` 抓 D3D 有时会**成功返回一张全黑图**，那样"截图成功"的报告是假的。

```bash
py.exe build/verify_png.py <png 的 Windows 路径>
```
纯标准库解码 PNG 并统计像素：平均亮度、字节方差、不同字节值数量。
实测有效画面：平均亮度 190/255、方差 2997、255/256 种字节值；
全黑或纯色画面的方差会接近 0。

## 已实测记录（2026-09-17）

| 项 | 结果 |
|---|---|
| `window_info` | 通过：窗口几何 / 客户区原点 / DPI / 前台状态 |
| `screenshot` | 通过：1024x575 RGBA，PrintWindow 方式，1565 KB |
| 画面内容 | 有效（像素统计 + 视觉模型独立确认一致） |
| 画面类型 | Eden 编辑器俯视视角，无 HUD（取景使然，非渲染故障） |
| `input_move` | 通过 |
| `input_click` / `input_key` | 待测（需游戏在前台） |
