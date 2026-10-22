#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""用户操作模拟与视觉捕捉工具。

两块能力都由**游戏进程内的 DLL** 执行（见 game/extension）：

## 为什么在进程内

  · 输入注入需要判定"前台窗口是否属于本进程"——只有进程内才能可靠判定，
    否则一次误注入就会点到别的程序上（这不是"可能出错"，是必然会打错）。
  · 截图需要抓取本进程的 DirectX 画面，跨进程抓取通常只能得到黑屏。
  · 进程内还省掉了跨进程坐标换算的误差。

## 坐标约定（最容易出错的地方）

输入类工具一律使用**屏幕坐标**。游戏内常用的坐标有两套，不能混用：
  · 客户区坐标：左上角为 (0,0)，来自 window_info 的 client
  · 屏幕坐标：整个桌面，输入注入用这套
换算：屏幕 = 客户区 + client_origin（window_info 会给出来）
另外还要考虑 dpi/scale —— window_info 也一并返回。

## 闸门

输入注入默认**关闭**（ALC_INPUT_INJECT=0）：它作用于系统输入队列，
影响范围超出游戏本身。截图只读画面，不受该闸门限制。
"""

from __future__ import annotations

import base64
import json
import os
import time

from mcpcore.registry import Registry, ToolResult
from adapters.channel import Channel
from guard import audit

DEFAULT_SHOT_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "build", "shots")


def _shot_dir() -> str:
    return os.environ.get("ALC_SHOT_DIR") or DEFAULT_SHOT_DIR


def register(reg: Registry, chan: Channel, gates) -> None:  # noqa: ANN001
    def _require_inject() -> ToolResult | None:
        if not gates.input_inject:
            return ToolResult.fail(
                "输入注入未开启（ALC_INPUT_INJECT 未启用）。\n"
                "这是刻意的默认值：注入作用于**系统输入队列**，影响范围超出游戏"
                "本身。确认要在当前环境使用后，设置 ALC_INPUT_INJECT=1 并重启 "
                "MCP 服务。\n"
                "（也可以先用输入无关的能力：单位动作可用 exec 的 action/playMove，"
                "UI 控件可用 ctrlSetText/ctrlActivate。）")
        return None

    # ------------------------------------------------------------ 窗口信息

    @reg.tool(
        name="window_info",
        description=("获取游戏窗口的几何信息：窗口矩形、客户区尺寸、客户区在屏幕上的"
                     "原点、DPI、以及前台窗口是否属于游戏进程。"
                     "**所有输入类工具的坐标换算都要用它**："
                     "屏幕坐标 = 客户区坐标 + client_origin。"),
        input_schema={"type": "object", "properties": {}},
        phase="input",
    )
    def _window_info(_args: dict) -> ToolResult:
        reply = chan.send({"cmd": "window_info", "args": []}, timeout_s=5.0)
        if not reply.ok:
            return ToolResult.fail("取窗口信息失败：%s" % reply.error)
        data = reply.result if isinstance(reply.result, dict) else {}
        if not data.get("ok"):
            return ToolResult.fail("窗口信息不可用：%s"
                                   % (data.get("error") or reply.error or "未知"))
        lines = [
            "游戏窗口信息：",
            "  前台属于本进程：%s" % data.get("is_self"),
            "  窗口矩形（屏幕坐标）：%s" % (data.get("window"),),
            "  客户区尺寸：%s" % (data.get("client"),),
            "  客户区原点（屏幕坐标）：%s  ← 换算用这个" % (data.get("client_origin"),),
            "  DPI / 缩放：%s / %s" % (data.get("dpi"), data.get("scale")),
            "",
            "输入坐标 = 客户区坐标 + 客户区原点。",
        ]
        if not data.get("is_self"):
            lines.append("")
            lines.append("⚠ 当前前台不是游戏窗口 —— 输入注入会被拒绝（这是保护，"
                         "避免误操作其它程序）。请先切到游戏。")
        return ToolResult.ok("\n".join(lines), data)

    # ------------------------------------------------------------ 输入注入

    @reg.tool(
        name="input_click",
        description=("在**屏幕坐标** (x,y) 点击鼠标。button: 0=左键(默认) 1=右键 "
                     "2=中键。坐标用 window_info 的 client_origin 换算得到。"
                     "仅当游戏窗口在前台时才生效。"),
        input_schema={
            "type": "object",
            "properties": {
                "x": {"type": "integer"},
                "y": {"type": "integer"},
                "button": {"type": "integer", "minimum": 0, "maximum": 2},
                "hold_ms": {"type": "integer", "minimum": 0, "maximum": 5000,
                            "description": "按住时长，默认 30ms"},
            },
            "required": ["x", "y"],
        },
        phase="input",
    )
    def _click(args: dict) -> ToolResult:
        gate_err = _require_inject()
        if gate_err is not None:
            return gate_err
        reply = chan.send({
            "cmd": "input_click",
            "args": [args["x"], args["y"], args.get("button", 0),
                     args.get("hold_ms", 30)]}, timeout_s=8.0)
        audit("input_click", {"x": args["x"], "y": args["y"],
                              "button": args.get("button", 0), "ok": reply.ok})
        if not reply.ok:
            return ToolResult.fail("点击失败：%s" % reply.error)
        data = reply.result if isinstance(reply.result, dict) else {}
        if not data.get("ok"):
            return ToolResult.fail("点击被拒绝：%s"
                                   % (data.get("error") or "未知原因"))
        return ToolResult.ok("已点击 (%s, %s) button=%s"
                             % (args["x"], args["y"], args.get("button", 0)), data)

    @reg.tool(
        name="input_drag",
        description=("从屏幕坐标 (x1,y1) 拖拽到 (x2,y2)（按住左键、分步移动、抬起）。"
                     "地图拖拽、装具拖放这类操作需要它 —— 单纯移动指针不产生拖拽。"),
        input_schema={
            "type": "object",
            "properties": {
                "x1": {"type": "integer"}, "y1": {"type": "integer"},
                "x2": {"type": "integer"}, "y2": {"type": "integer"},
                "steps": {"type": "integer", "minimum": 1, "maximum": 100,
                          "description": "中间步数，默认 20（步数太少会被当作没拖拽）"},
            },
            "required": ["x1", "y1", "x2", "y2"],
        },
        phase="input",
    )
    def _drag(args: dict) -> ToolResult:
        gate_err = _require_inject()
        if gate_err is not None:
            return gate_err
        reply = chan.send({
            "cmd": "input_drag",
            "args": [args["x1"], args["y1"], args["x2"], args["y2"],
                     args.get("steps", 20)]}, timeout_s=15.0)
        audit("input_drag", {"from": [args["x1"], args["y1"]],
                             "to": [args["x2"], args["y2"]], "ok": reply.ok})
        if not reply.ok:
            return ToolResult.fail("拖拽失败：%s" % reply.error)
        data = reply.result if isinstance(reply.result, dict) else {}
        if not data.get("ok"):
            return ToolResult.fail("拖拽被拒绝：%s"
                                   % (data.get("error") or "未知原因"))
        return ToolResult.ok("已拖拽 (%s,%s) → (%s,%s)"
                             % (args["x1"], args["y1"], args["x2"], args["y2"]), data)

    @reg.tool(
        name="input_key",
        description=("按键：scan 是 **DIK 扫描码**（不是虚拟键码，游戏普遍按扫描码读"
                     "键盘）。down=true 按下、false 抬起；给 hold_ms 则自动按下后"
                     "等待再抬起。常用码：W=17 A=30 S=31 D=32 空格=57 ESC=1 "
                     "Enter=28 Tab=15。也可先用 exec 的 actionKeys 反查某个功能"
                     "绑定了哪些键。"),
        input_schema={
            "type": "object",
            "properties": {
                "scan": {"type": "integer", "minimum": 1, "maximum": 255},
                "down": {"type": "boolean"},
                "hold_ms": {"type": "integer", "minimum": 0, "maximum": 5000},
            },
            "required": ["scan", "down"],
        },
        phase="input",
    )
    def _key(args: dict) -> ToolResult:
        gate_err = _require_inject()
        if gate_err is not None:
            return gate_err
        reply = chan.send({
            "cmd": "input_key",
            "args": [args["scan"], 1 if args["down"] else 0,
                     args.get("hold_ms", 0)]}, timeout_s=10.0)
        audit("input_key", {"scan": args["scan"], "down": args["down"],
                            "ok": reply.ok})
        if not reply.ok:
            return ToolResult.fail("按键失败：%s" % reply.error)
        data = reply.result if isinstance(reply.result, dict) else {}
        if not data.get("ok"):
            return ToolResult.fail("按键被拒绝：%s"
                                   % (data.get("error") or "未知原因"))
        return ToolResult.ok("已按键 scan=%s %s"
                             % (args["scan"], "按下" if args["down"] else "抬起"), data)

    @reg.tool(
        name="input_move",
        description="把鼠标指针移到屏幕坐标 (x,y)（不点击）。",
        input_schema={
            "type": "object",
            "properties": {"x": {"type": "integer"}, "y": {"type": "integer"}},
            "required": ["x", "y"],
        },
        phase="input",
    )
    def _move(args: dict) -> ToolResult:
        gate_err = _require_inject()
        if gate_err is not None:
            return gate_err
        reply = chan.send({"cmd": "input_move",
                           "args": [args["x"], args["y"]]}, timeout_s=8.0)
        if not reply.ok:
            return ToolResult.fail("移动失败：%s" % reply.error)
        data = reply.result if isinstance(reply.result, dict) else {}
        if not data.get("ok"):
            return ToolResult.fail("移动被拒绝：%s"
                                   % (data.get("error") or "未知原因"))
        return ToolResult.ok("指针已移到 (%s, %s)" % (args["x"], args["y"]), data)

    # ------------------------------------------------------------ 视觉捕捉

    @reg.tool(
        name="screenshot",
        description=("截取游戏窗口画面并**直接返回图片**（你可以看到画面内容）。"
                     "默认缩放到 1280 宽以控制体积；画面很大时可调小 max_width。"
                     "仅当前台窗口属于游戏进程时有效。"),
        input_schema={
            "type": "object",
            "properties": {
                "max_width": {"type": "integer", "minimum": 160, "maximum": 3840,
                              "description": "缩放目标宽度，默认 1280；0=不缩放"},
                "keep_file": {"type": "boolean",
                              "description": "是否保留 PNG 文件（默认保留，便于复核）"},
            },
        },
        phase="vision",
    )
    def _screenshot(args: dict) -> ToolResult:
        out_dir = _shot_dir()
        try:
            os.makedirs(out_dir, exist_ok=True)
        except OSError as exc:
            return ToolResult.fail("截图目录不可写：%s（%s）" % (out_dir, exc))

        name = "shot_%s.png" % time.strftime("%H%M%S")
        path = os.path.join(out_dir, name)
        # DLL 在游戏进程内，用的是 Windows 路径
        win_path = path.replace("/mnt/h/", "H:\\").replace("/", "\\")

        max_width = args.get("max_width", 1280)
        reply = chan.send({"cmd": "capture", "args": [win_path, max_width]},
                          timeout_s=20.0)
        audit("screenshot", {"path": win_path, "ok": reply.ok})
        if not reply.ok:
            return ToolResult.fail("截图失败：%s" % reply.error)
        data = reply.result if isinstance(reply.result, dict) else {}
        if not data.get("ok"):
            return ToolResult.fail("截图被拒绝：%s"
                                   % (data.get("error") or "未知原因"))

        # 读回 PNG。
        #
        # ⚠ DLL 与 MCP **都在 Windows**，DLL 返回的 Windows 路径可以直接用。
        # 之前这里把它换算成 WSL 形式（/mnt/h/...），而 MCP 是 Windows 进程、
        # 根本不认识那个形式 —— 于是"文件明明生成了却读不回来"。
        # 教训：只有真正跨系统的路径才需要换算；这里的"两台机器"其实是同一台。
        local = data.get("path") or win_path
        try:
            with open(local, "rb") as fh:
                blob = fh.read()
        except OSError as exc:
            return ToolResult.fail(
                "截图已生成但读不回来：%s（%s）\nDLL 报的路径是 %s"
                % (local, exc, data.get("path")))

        b64 = base64.b64encode(blob).decode("ascii")
        text = ("游戏画面 %sx%s（原始 %sx%s，方式 %s，%.0f KB）"
                % (data.get("width"), data.get("height"),
                   data.get("source_width"), data.get("source_height"),
                   data.get("method"), len(blob) / 1024.0))
        if not args.get("keep_file", True):
            try:
                os.unlink(local)
                text += "\n（已删除临时文件）"
            except OSError:
                pass
        return ToolResult.ok(text, data, images=[("image/png", b64)])
