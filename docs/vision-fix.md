# 让 Agent 看到图片：provider 补丁说明

## 问题

MCP 的 `screenshot` 返回图片（MCP image content），但模型**收不到**：
模型只看到一行元数据 `image/png image, 1360x768 px, ...`。

## 根因（三层，逐层排除）

1. **不是模型问题**：模型是 `deepseek-v4-flash-vision-exp`，且用户直接贴图时
   模型**能正常看到**。
2. **不是 attachment 问题**：`read_image` 确实产出了带 `attachment` 的 image 块
   （探针实测 `innerTypes=[text,image] innerKeys=[type|text ; type|attachment]`）。
3. **是 provider 的问题**：`dsh-commandcode-provider` 在把消息转成 wire 格式时，
   **工具结果的 output 只能承载文本**：

   ```js
   out.push({ role: "tool", ..., content: toolResultText(block) });  // 只有文本
   ```

   图片块在此被静默丢弃。

## 修复

在 provider 的 `messagesToOpenAI`（实际被调用的那个；`messagesToCC` 同样打了补丁
作为双保险）里，**把工具结果里的图片提升为紧随其后的一条 user 消息**，
复用该函数对 user 消息图片的既有支持：

```js
const imageBlocks = (block.content || []).filter(b => b?.type === "image" && b.attachment);
if (imageBlocks.length > 0 && readImage) {
    const imageParts = [];
    for (const ib of imageBlocks) imageParts.push(await imageToOpenAI(ib.attachment, readImage));
    out.push({
        role: "user",
        // ⚠ 必须带一个 text 块：实测"纯 image"的 user 消息会被网关丢弃，
        // 加上 text 后立刻生效。这与 DeepSeek 文档一致——所有图片示例
        // 都是 text 与 image 配对出现。
        content: [{ type: "text", text: "[image returned by tool: ...]" }, ...imageParts]
    });
}
```

## 验证（控制实验）

生成内容已知的测试图（蓝底 + 左侧红圆 + 右下绿矩形），让模型描述：

| 步骤 | 结果 |
|---|---|
| 打补丁前 | 只能报出文件尺寸/字节数，看不到画面 |
| 补丁（纯 image） | 仍看不到 —— 网关丢弃了纯图片消息 |
| **补丁（text + image）** | ✅ **正确报出：蓝底、左侧红圆、右下绿矩形** |

**控制实验是关键**：此前仅凭子代理"描述得挺像"就采信过结论，事后证明那是
幻觉（它没看到图，按文件名编的）。有真值的对照图才能区分"真看到"与"编造"。

## 维护须知

- 改的是**第三方包**：`~/.dsh/profiles/web/node_modules/@mars-sea/dsh-commandcode-provider/lib/index.js`
- 备份：同目录 `lib/index.js.backup-visual-fix`
- **DSH 升级或重装依赖会覆盖此改动**，届时需按本文档重新打补丁
- 补丁是纯增量的：工具不返回图片时行为与原来完全一致
