#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""input_macro 的校验测试（不需要游戏）。

## 为什么这些用例重要

宏是"一次调用发一串操作"，所以**校验必须在 MCP 侧就拦住明显的错误** ——
DLL 侧虽然也会校验，但错误信息只能指到"第几步"，不如这里精确。

更要紧的是最后一条用例：**文档里列出的操作类型必须真的被接受**。
这个项目已经栽过"schema 声明了 auto_focus 却没实现"（D29），
所以文档与实现的一致性要有测试盯着，不能只靠人眼。
"""

from __future__ import annotations

import os
import sys
import unittest

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, REPO)


class RecordingChan:
    def __init__(self):
        self.sent = []
        self.timeouts = []

    def send(self, payload, timeout_s=5.0):  # noqa: ANN001
        from adapters.channel import Reply
        cmd = payload.get("cmd")
        self.sent.append(cmd)
        self.timeouts.append(timeout_s)
        if cmd == "status":
            return Reply(ok=True, cid="s", channel="tcp",
                         result={"ok": True, "connected": True, "connects": 1})
        if cmd == "window_info":
            return Reply(ok=True, cid="w", channel="tcp",
                         result={"ok": True, "client": [1360, 768],
                                 "client_origin": [0, 23]})
        if cmd == "input_macro":
            n = len(payload.get("args", [[]])[0])
            return Reply(ok=True, cid="m", channel="tcp",
                         result={"ok": True, "steps": n})
        return Reply(ok=True, cid="x", channel="tcp", result={"ok": True})

    def info(self) -> dict:
        return {"channel": "tcp", "connected": True}


def _reg(chan):  # noqa: ANN001
    from mcpcore.registry import Registry
    from adapters import input_tools, health
    from guard import Gates

    health.forget_ui_cache()
    gates = Gates()
    gates.input_inject = True
    reg = Registry()
    input_tools.register(reg, chan, gates)
    return reg


class TestMacroValidation(unittest.TestCase):
    def test_rejects_empty_steps(self):
        res = _reg(RecordingChan()).call("input_macro", {"steps": []})
        self.assertTrue(res.is_error)
        self.assertIn("非空数组", res.text)

    def test_rejects_step_without_type(self):
        res = _reg(RecordingChan()).call("input_macro",
                                        {"steps": [{"x": 1, "y": 2}]})
        self.assertTrue(res.is_error)
        self.assertIn("第 1 步", res.text)
        self.assertIn("t", res.text)

    def test_rejects_unknown_op_and_names_the_step(self):
        res = _reg(RecordingChan()).call(
            "input_macro", {"steps": [{"t": "click", "x": 1, "y": 1},
                                      {"t": "teleport", "x": 1, "y": 1}]})
        self.assertTrue(res.is_error)
        self.assertIn("第 2 步", res.text)
        self.assertIn("teleport", res.text)

    def test_rejects_too_many_steps(self):
        steps = [{"t": "move", "x": 1, "y": 1} for _ in range(201)]
        res = _reg(RecordingChan()).call("input_macro", {"steps": steps})
        self.assertTrue(res.is_error)
        self.assertIn("200", res.text)

    def test_all_documented_ops_are_accepted(self):
        """文档里列的类型必须真的被接受 —— 防"文档与实现脱节"。

        D29 那个 bug（schema 声明 auto_focus、实现里没有）就是这么漏出去的。
        """
        ops = [
            {"t": "move", "x": 1, "y": 1},
            {"t": "click", "x": 1, "y": 1, "button": 0},
            {"t": "dblclick", "x": 1, "y": 1},
            {"t": "down", "button": 1},
            {"t": "up", "button": 1},
            {"t": "drag", "x1": 1, "y1": 1, "x2": 2, "y2": 2, "button": 2},
            {"t": "key", "scan": 28, "down": True},
            {"t": "combo", "keys": [29, 42], "scan": 28},
            {"t": "sleep", "ms": 100},
        ]
        chan = RecordingChan()
        res = _reg(chan).call("input_macro", {"steps": ops})
        self.assertFalse(res.is_error, res.text)
        self.assertIn("input_macro", chan.sent)

    def test_timeout_budget_accounts_for_sleep(self):
        """显式 sleep 必须计入超时预算，否则长宏会被误判为超时。"""
        chan = RecordingChan()
        res = _reg(chan).call("input_macro", {"steps": [
            {"t": "sleep", "ms": 30000},
            {"t": "click", "x": 1, "y": 1}]})
        self.assertFalse(res.is_error, res.text)
        macro_timeout = chan.timeouts[chan.sent.index("input_macro")]
        self.assertGreater(macro_timeout, 30.0)

    def test_success_text_does_not_overclaim(self):
        """返回文本要提醒"注入成功 ≠ 游戏按预期响应"。"""
        res = _reg(RecordingChan()).call(
            "input_macro", {"steps": [{"t": "click", "x": 1, "y": 1}]})
        self.assertFalse(res.is_error, res.text)
        self.assertIn("不保证", res.text)
        self.assertIn("screenshot", res.text)


if __name__ == "__main__":
    unittest.main()
