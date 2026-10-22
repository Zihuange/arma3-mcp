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

    def _require_ui() -> ToolResult | None:
        """无头形态（专用服务器）下明确拒绝 UI/输入类操作。

        判据见 adapters/health.py 的 has_ui：**DLL 答得出 status，但找不到窗口**。
        不这样拦的话，这些工具在服务器上会各自以不同方式失败 —— 有的超时、有的
        不报错却什么也没发生 —— 而调用方很难从中读出"这是形态不对，不是故障"。

        注意 window_info 自身**不**走这个检查：它是"看"的工具，把"找不到窗口"
        如实报出来本身就是有用的信息，也是本判据的依据。
        """
        from adapters import health as _health
        why = _health.require_ui(chan)
        if why is None:
            return None
        return ToolResult.fail(why, {"headless": True})

    def _maybe_focus(args: dict) -> None:
        """按 auto_focus 先把游戏窗口切到前台。

        为什么需要它：DLL 侧**只给 input_click 实现了 auto_focus**，而
        input_drag / input_key 的 schema 里也声明了这个参数 —— 声明了却不实现，
        传进来会被静默忽略。而"用户在看 Agent 输出"时前台正是浏览器，不先聚焦
        就会被前台校验直接拒掉（实测："前台窗口不属于游戏进程"）。

        靠调用方自己先 focus 再注入也不可靠：两者之间隔着一次工具往返，焦点随时
        可能被抢回去（实测：focus_game 刚报"原本就是前台"，下一次调用就被拒）。
        """
        if args.get("auto_focus"):
            chan.send({"cmd": "focus_game", "args": []}, timeout_s=8.0)

    # ------------------------------------------------------------ 操作序列

    # 与 DLL 侧一致。两边都校验是刻意的：MCP 侧能给出更友好的错误信息，
    # 而 DLL 侧是最后一道（它不能假设调用方都守规矩）。
    _MACRO_OPS = ("move", "click", "dblclick", "down", "up",
                  "drag", "key", "combo", "sleep")
    _MACRO_MAX = 200

    @reg.tool(
        name="input_macro",
        description=(
            "**一次调用执行一串输入操作**（鼠标宏）。用于需要精确时序的组合："
            "双击、按住修饰键再拖拽、拖放。这些用多次独立调用做不到 —— 调用之间"
            "隔着网络往返（约 100 ms），而且前台随时可能被抢走；DLL 侧是同一线程"
            "顺序执行，间隔只有毫秒级，焦点也只在开头检查一次。\n\n"
            'steps 是操作序列，每项形如 {"t":"click","x":100,"y":200}。\n'
            '鼠标 button 一律 0=左 1=右 2=中。可用类型：\n'
            '  · move     {x, y}                             移动指针\n'
            '  · click    {x, y, button?, hold_ms?}          单击\n'
            '  · dblclick {x, y, button?, gap_ms?}           双击（间隔可控，默认 120ms）\n'
            '  · down/up  {x?, y?, button?}                  按住/松开鼠标键（可分开控制）\n'
            '  · drag     {x1,y1,x2,y2, button?, steps?}     拖拽（三键都可）\n'
            '  · key      {scan, down, hold_ms?}             键盘（scan 是 DIK 码）\n'
            '  · combo    {keys:[scan,...], scan?, hold_ms?} 组合键：按住 keys，'
            '按一次 scan，再**反向**松开\n'
            '  · sleep    {ms}                               等待\n\n'
            "失败即停，错误会指明**是第几步、哪个操作**失败。"),
        input_schema={
            "type": "object",
            "properties": {
                "steps": {
                    "type": "array",
                    "description": "操作序列（最多 200 步）",
                    "items": {"type": "object"},
                },
                "auto_focus": {"type": "boolean",
                               "description": "整串操作前先聚焦一次（默认 false）"},
            },
            "required": ["steps"],
        },
        phase="input",
    )
    def _macro(args: dict) -> ToolResult:
        gate_err = _require_inject()
        if gate_err is not None:
            return gate_err
        ui_err = _require_ui()
        if ui_err is not None:
            return ui_err

        steps = args.get("steps")
        if not isinstance(steps, list) or not steps:
            return ToolResult.fail("steps 必须是非空数组")
        if len(steps) > _MACRO_MAX:
            return ToolResult.fail(
                "一次最多 %d 步（收到 %d 步）。拆成多次调用即可 —— "
                "但要注意：拆开之后，两段之间的间隔是网络往返量级（约 100 ms），"
                "需要紧密时序的操作不要跨调用拆。"
                % (_MACRO_MAX, len(steps)))

        # 逐项校验：错误信息能指到具体第几步，比让 DLL 返回更清楚
        for i, st in enumerate(steps, 1):
            if not isinstance(st, dict):
                return ToolResult.fail("第 %d 步不是对象" % i)
            op = st.get("t")
            if not op:
                return ToolResult.fail("第 %d 步缺少 t（操作类型）" % i)
            if op not in _MACRO_OPS:
                return ToolResult.fail(
                    "第 %d 步的操作类型未知：%r（可用：%s）"
                    % (i, op, "、".join(_MACRO_OPS)))

        _maybe_focus(args)
        # 超时按步数估算：sleep 是显式等待，必须算进去；其余每步几百毫秒足够。
        waits = sum(int(st.get("ms") or 0) for st in steps
                    if st.get("t") == "sleep")
        budget = max(15.0, waits / 1000.0 + len(steps) * 0.5 + 10.0)
        reply = chan.send({"cmd": "input_macro", "args": [steps]},
                          timeout_s=budget)
        audit("input_macro", {"steps": len(steps), "ok": reply.ok})
        if not reply.ok:
            return ToolResult.fail("操作序列执行失败：%s" % reply.error)
        data = reply.result if isinstance(reply.result, dict) else {}
        if not data.get("ok"):
            return ToolResult.fail("操作序列被拒绝：%s"
                                   % (data.get("error") or "未知原因"))
        return ToolResult.ok(
            "操作序列完成（%d 步）。\n"
            "注意：这只表示注入成功，**不保证游戏按预期响应** —— "
            "需要视觉确认时用 screenshot 核对。"
            % data.get("steps", len(steps)), data)

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

    @reg.tool(
        name="focus_game",
        description=("把游戏窗口切到前台。输入注入要求游戏在前台，而你查看 Agent "
                     "输出时前台通常是浏览器 —— 用它在注入前抢回焦点。"
                     "（Windows 只允许前台进程设置前台窗口，DLL 内部用 "
                     "AttachThreadInput 绕过该限制。）"),
        input_schema={"type": "object", "properties": {}},
        phase="input",
    )
    def _focus(_args: dict) -> ToolResult:
        ui_err = _require_ui()
        if ui_err is not None:
            return ui_err
        reply = chan.send({"cmd": "focus_game", "args": []}, timeout_s=8.0)
        if not reply.ok:
            return ToolResult.fail("聚焦失败：%s" % reply.error)
        data = reply.result if isinstance(reply.result, dict) else {}
        if not data.get("ok"):
            return ToolResult.fail("聚焦被拒绝：%s"
                                   % (data.get("error") or "未知原因"))
        if data.get("foreground"):
            note = "（原本就是前台）" if data.get("already") else ""
            return ToolResult.ok("游戏窗口已切到前台%s" % note, data)
        return ToolResult.fail(
            "已尝试切换，但游戏仍不是前台窗口。可能原因：屏幕锁定、"
            "或系统拒绝了焦点切换（可再调一次）。", data)

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
                "auto_focus": {"type": "boolean",
                               "description": "注入前自动把游戏窗口切到前台（默认 false）"},
            },
            "required": ["x", "y"],
        },
        phase="input",
    )
    def _click(args: dict) -> ToolResult:
        gate_err = _require_inject()
        if gate_err is not None:
            return gate_err
        ui_err = _require_ui()
        if ui_err is not None:
            return ui_err
        reply = chan.send({
            "cmd": "input_click",
            "args": [args["x"], args["y"], args.get("button", 0),
                     args.get("hold_ms", 30),
                     1 if args.get("auto_focus") else 0]}, timeout_s=12.0)
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
                "auto_focus": {"type": "boolean",
                               "description": "注入前自动把游戏窗口切到前台（默认 false）"},
            },
            "required": ["x1", "y1", "x2", "y2"],
        },
        phase="input",
    )
    def _drag(args: dict) -> ToolResult:
        gate_err = _require_inject()
        if gate_err is not None:
            return gate_err
        ui_err = _require_ui()
        if ui_err is not None:
            return ui_err
        _maybe_focus(args)
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
                     "等待再抬起。**完整表见 docs/dik.md**（从 Windows SDK 的 "
                     "dinput.h 提取，不是手写的）。常用：ESC=1 Tab=15 Enter=28 "
                     "空格=57 LSHIFT=42 LCONTROL=29 LMENU(Alt)=56 W=17 A=30 "
                     "S=31 D=32；数字键盘 NUMPAD4=75 NUMPAD6=77 NUMPAD8=72 "
                     "NUMPAD2=80。"),
        input_schema={
            "type": "object",
            "properties": {
                "scan": {"type": "integer", "minimum": 1, "maximum": 255},
                "down": {"type": "boolean"},
                "hold_ms": {"type": "integer", "minimum": 0, "maximum": 5000},
                "auto_focus": {"type": "boolean",
                               "description": "注入前自动把游戏窗口切到前台（默认 false）"},
            },
            "required": ["scan", "down"],
        },
        phase="input",
    )
    def _key(args: dict) -> ToolResult:
        gate_err = _require_inject()
        if gate_err is not None:
            return gate_err
        ui_err = _require_ui()
        if ui_err is not None:
            return ui_err
        _maybe_focus(args)
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
        ui_err = _require_ui()
        if ui_err is not None:
            return ui_err
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
        ui_err = _require_ui()
        if ui_err is not None:
            return ui_err
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
