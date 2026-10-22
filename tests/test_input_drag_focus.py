#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""input_drag 的 auto_focus 测试（不需要游戏）。

## 为什么单列

`input_click` 有 auto_focus，而 `input_drag` 在 **DLL 侧没有实现它** —— 参数传了
也会被忽略。实测症状：从"用户在看 Agent 输出"的状态调用拖拽，会被前台校验直接
拒掉（"前台窗口不属于游戏进程"）；而调用方自己先 focus 再 drag 也不可靠，
因为两者之间隔着一次工具往返，焦点随时可能被抢回去。

所以 MCP 侧在发拖拽之前自己聚焦一次。这条测试盯住"这次聚焦确实发生了"。
"""

from __future__ import annotations

import os
import sys
import unittest

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, REPO)


class RecordingChan:
    """记录收到的命令，并对 status/window_info/focus_game 给出成功回执。"""

    def __init__(self):
        self.sent = []

    def send(self, payload, timeout_s=5.0):  # noqa: ANN001
        from adapters.channel import Reply

        cmd = payload.get("cmd")
        self.sent.append(cmd)
        if cmd == "status":
            return Reply(ok=True, cid="s", channel="tcp",
                         result={"ok": True, "connected": True, "connects": 1})
        if cmd == "window_info":
            return Reply(ok=True, cid="w", channel="tcp",
                         result={"ok": True, "client": [1360, 768],
                                 "client_origin": [0, 23]})
        return Reply(ok=True, cid="x", channel="tcp", result={"ok": True})

    def info(self) -> dict:
        return {"channel": "tcp", "connected": True}


class TestDragAutoFocus(unittest.TestCase):
    def _reg(self, chan):  # noqa: ANN001
        from mcpcore.registry import Registry
        from adapters import input_tools, health
        from guard import Gates

        health.forget_ui_cache()
        gates = Gates()
        gates.input_inject = True          # 测试聚焦行为，不是闸门
        reg = Registry()
        input_tools.register(reg, chan, gates)
        return reg

    def test_auto_focus_focuses_before_dragging(self):
        chan = RecordingChan()
        reg = self._reg(chan)
        res = reg.call("input_drag", {"x1": 100, "y1": 100, "x2": 200,
                                      "y2": 200, "auto_focus": True})
        self.assertFalse(res.is_error, res.text)
        self.assertIn("focus_game", chan.sent)
        # 顺序也要对：聚焦必须发生在拖拽**之前**
        self.assertLess(chan.sent.index("focus_game"), chan.sent.index("input_drag"))

    def test_input_key_also_focuses(self):
        """input_key 有同样的问题：schema 声明了 auto_focus，实现里没发出去。

        这类"声明了却没实现"的参数最坑 —— 传了没报错，只是不生效。
        """
        chan = RecordingChan()
        reg = self._reg(chan)
        res = reg.call("input_key", {"scan": 28, "down": True, "auto_focus": True})
        self.assertFalse(res.is_error, res.text)
        self.assertIn("focus_game", chan.sent)
        self.assertLess(chan.sent.index("focus_game"), chan.sent.index("input_key"))

    def test_no_focus_when_auto_focus_absent(self):
        """不给 auto_focus 就不该多一次聚焦 —— 那是调用方的选择。"""
        chan = RecordingChan()
        reg = self._reg(chan)
        reg.call("input_drag", {"x1": 100, "y1": 100, "x2": 200, "y2": 200})
        self.assertNotIn("focus_game", chan.sent)
        self.assertIn("input_drag", chan.sent)


if __name__ == "__main__":
    unittest.main()
