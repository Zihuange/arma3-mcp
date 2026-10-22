#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""无头环境警告的测试（不需要游戏）。

## 这些用例防的是什么

专用服务器上有一类表达式**不报错、却什么都不会发生**（见
docs/server-capabilities.md 的实测普查）：

  · `hint` / `systemChat` → 返回 nil，屏幕上没有任何东西；
  · 引用 `player` 的表达式 → 返回**看似合理的假值**（`getPos player → [0,0,0]`）。

这种失败最难发现，因为调用方拿到的不是错误而是一个数字。

但更要紧的是**别误报**：客户端上这些命令完全正常，那里给出警告只会训练调用方
忽略警告 —— 那比没有警告更糟。所以两个方向的用例都有。
"""

from __future__ import annotations

import os
import sys
import unittest

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, REPO)

from adapters.exec_tools import headless_caveat  # noqa: E402
from tests.test_health import FakeChan  # noqa: E402


class TestNoFalsePositives(unittest.TestCase):
    """客户端（有界面）不该收到任何提示。"""

    def test_client_gets_no_caveat_for_hint(self):
        self.assertEqual(headless_caveat("hint _p0", FakeChan(has_window=True)), "")

    def test_client_gets_no_caveat_for_player(self):
        self.assertEqual(
            headless_caveat("getPos player", FakeChan(has_window=True)), "")

    def test_ordinary_expression_never_warns(self):
        """没命中清单的表达式，无论哪种形态都不提示。"""
        for has_window in (True, False):
            self.assertEqual(
                headless_caveat("worldName", FakeChan(has_window=has_window)), "")

    def test_no_probe_when_not_matching(self):
        """不命中清单就不该探测形态 —— 那是每次 exec 的额外往返。

        用会抛异常的假通道盯住这一点：一旦实现改成"先探测再看清单"，这条会炸。
        """

        class BoomChan:
            def send(self, payload, timeout_s=5.0):  # noqa: ANN001
                raise AssertionError("不该发起探测：表达式并未命中清单")

        self.assertEqual(headless_caveat("worldName", BoomChan()), "")
        self.assertEqual(headless_caveat("count allDisplays", BoomChan()), "")


class TestHeadlessWarnings(unittest.TestCase):
    """无头环境下命中清单的要提示，且要讲清"这不是报错，是假值/无效果"。"""

    def test_hint_warns_about_no_effect(self):
        text = headless_caveat("hint _p0", FakeChan(has_window=False))
        self.assertIn("无头环境提示", text)
        self.assertIn("hint", text)
        self.assertIn("返回 nil", text)

    def test_systemchat_also_warns(self):
        text = headless_caveat("systemChat _p0", FakeChan(has_window=False))
        self.assertIn("systemchat", text.lower())

    def test_forcemap_and_openmap_warn(self):
        """地图类命令也是给玩家看的 —— 服务器上没有屏幕。"""
        for expr in ("forceMap _p0", "openMap _p0"):
            text = headless_caveat(expr, FakeChan(has_window=False))
            self.assertIn("无头环境提示", text, expr)

    def test_player_warns_about_fake_values(self):
        text = headless_caveat("getPos player", FakeChan(has_window=False))
        self.assertIn("没有玩家", text)
        self.assertIn("[0,0,0]", text)
        self.assertIn("不要把这类结果当成真实数据", text)

    def test_both_kinds_can_fire_together(self):
        text = headless_caveat("hint str (getPos player)", FakeChan(has_window=False))
        self.assertIn("无头环境提示", text)
        self.assertIn("hint", text)
        self.assertIn("player", text)

    def test_token_match_is_case_insensitive(self):
        """命令名大小写不该影响判定。"""
        self.assertNotEqual(
            headless_caveat("SystemChat _p0", FakeChan(has_window=False)), "")
        self.assertNotEqual(
            headless_caveat("HINT _p0", FakeChan(has_window=False)), "")

    def test_player_inside_a_longer_identifier_does_not_fire(self):
        """`playerName` 之类不该被当成 `player` —— 词法边界要正确。

        误报在这里代价特别高：一个常见词被错判，会让大批正常表达式都带警告。
        """
        self.assertEqual(
            headless_caveat("getVariable playerSideVar", FakeChan(has_window=False)),
            "")


if __name__ == "__main__":
    unittest.main()
