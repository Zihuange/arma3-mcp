#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""执行器健康探测的测试（用假游戏，不需要 Arma 3）。

## 这些用例防的是什么

真实故障是这样的：DLL 连上了 MCP，于是状态页显示"已接通"；但游戏停在主菜单，
SQF 执行器根本没跑，exec 命令堆在 DLL 的 inbox 里一路超时。**两端日志都看不出
问题**，调用方只能靠猜。

所以这里逐个钉死"什么情况下该报什么"，尤其是三条：
  · 从未启动（poll_ms_ago == -1）
  · 心跳停滞（poll_ms_ago 超过阈值）
  · 旧版 DLL 没有心跳字段（不能猜，要说不知道）

最后一条用例守住"失败必须响亮"：exec 超时时，诊断结论要**直接写进错误信息**，
而不是让调用方自己知道去查 game_link。

链路是**进程内**的真实组合：真 TcpChannel + 假游戏 + 真注册表，
只有"引擎语义"是假的——与其它测试的分工一致。
"""

from __future__ import annotations

import os
import socket
import sys
import time
import unittest

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, REPO)

from adapters import health  # noqa: E402
from adapters.tcp_channel import DEFAULT_TOKEN, TcpChannel  # noqa: E402
from servers.engine import build_registry  # noqa: E402
from tests.fake_game import FakeGame  # noqa: E402


def free_port() -> int:
    sock = socket.socket()
    sock.bind(("127.0.0.1", 0))
    port = sock.getsockname()[1]
    sock.close()
    return port


def status_handler(poll_ms_ago: object = 120, **extra) -> object:  # noqa: ANN003
    """造一个 status 处理器。传 poll_ms_ago=None 表示**不带该字段**（旧版 DLL）。"""
    payload: dict = {
        "ok": True, "connected": True, "addr": "127.0.0.1:32132",
        "ver": "0.1.0", "inbox": 0, "outbox": 0, "dropped": 0,
        "rx": 10, "tx": 9, "connects": 1, "error": "",
    }
    if poll_ms_ago is not None:
        payload["poll_ms_ago"] = poll_ms_ago
    payload.update(extra)

    def handler(_msg: dict) -> dict:
        return {"ok": True, "result": payload}

    return handler


class HealthCase(unittest.TestCase):
    def setUp(self):
        self.port = free_port()
        self.chan = TcpChannel(host="127.0.0.1", port=self.port,
                               token=DEFAULT_TOKEN, default_timeout=1.0)
        self.assertTrue(self.chan.start(), self.chan.start_error)
        self.reg = build_registry(self.chan)
        self.game: FakeGame | None = None

    def tearDown(self):
        if self.game:
            self.game.close()
        self.chan.stop()

    def connect_game(self, handler) -> FakeGame:  # noqa: ANN001
        for _ in range(40):
            game = FakeGame(host="127.0.0.1", port=self.port)
            if game.connect():
                self.game = game
                if handler is not None:
                    game.handlers["status"] = handler
                deadline = time.time() + 2
                while time.time() < deadline and not self.chan.connected():
                    time.sleep(0.02)
                return game
            time.sleep(0.1)
        raise AssertionError("假游戏无法连接")

    def probe(self) -> dict:
        return health.probe(self.chan, timeout_s=1.0)

    def tool_text(self, name: str, args: dict | None = None) -> str:
        return self.reg.call(name, args or {}).text


class TestProbeVerdicts(HealthCase):
    """判定逻辑：每种心跳值对应哪个结论。"""

    def test_running(self):
        self.connect_game(status_handler(120))
        h = self.probe()
        self.assertTrue(h["available"])
        self.assertEqual(h["executor"], "running")
        self.assertIn("运行中", h["summary"])

    def test_never_started(self):
        self.connect_game(status_handler(-1))
        h = self.probe()
        self.assertEqual(h["executor"], "never_started")
        self.assertIn("从未启动", h["summary"])

    def test_stalled(self):
        self.connect_game(status_handler(health.STALE_MS + 5000))
        h = self.probe()
        self.assertEqual(h["executor"], "stalled")
        self.assertIn("停滞", h["summary"])

    def test_threshold_boundary(self):
        """刚好在阈值内算运行中，超出才算停滞。"""
        self.connect_game(status_handler(health.STALE_MS))
        self.assertEqual(self.probe()["executor"], "running")
        self.game.close()
        self.game = None
        self.connect_game(status_handler(health.STALE_MS + 1))
        self.assertEqual(self.probe()["executor"], "stalled")

    def test_legacy_dll_without_heartbeat_is_unknown_not_guessed(self):
        """旧版 DLL 没有心跳字段时，必须说"不知道"。

        这是刻意的：此时若拿 inbox 去猜，inbox=0 会被当成"执行器正常"，
        而它同样可能意味着"执行器从未存在过"。宁可说不知道。
        """
        self.connect_game(status_handler(None))
        h = self.probe()
        self.assertTrue(h["available"], "拿到回执了，只是字段缺失")
        self.assertEqual(h["executor"], "unknown")
        self.assertIn("旧版", h["summary"])


class TestProbeFailures(HealthCase):
    """探测本身失败时也不能抛异常，且要分清是哪一层的问题。"""

    def test_status_not_answered_points_at_channel_layer(self):
        self.connect_game(lambda _m: None)          # 故意不回应
        h = self.probe()
        self.assertFalse(h["available"])
        self.assertIn("通道层", h["summary"])
        self.assertIn("不在执行器", h["summary"])

    def test_no_game_connected_is_honest(self):
        h = self.probe()
        self.assertFalse(h["available"])
        self.assertIn("无法判定", h["summary"])


class TestToolOutput(HealthCase):
    """工具层：结论要出现在人/模型看得到的地方。"""

    def test_gates_status_shows_executor_state(self):
        self.connect_game(status_handler(-1))
        text = self.tool_text("gates_status")
        self.assertIn("执行器", text)
        self.assertIn("从未启动", text)
        self.assertIn("不会被处理", text)

    def test_gates_status_says_running_when_healthy(self):
        self.connect_game(status_handler(80))
        text = self.tool_text("gates_status")
        self.assertIn("运行中", text)
        self.assertNotIn("不会被处理", text)

    def test_game_link_reports_heartbeat(self):
        self.connect_game(status_handler(20))
        text = self.tool_text("game_link")
        self.assertIn("运行中", text)

    def test_game_link_flags_commands_that_will_never_run(self):
        """执行器没跑而 inbox 有货时，必须明说这些命令不会被执行。"""
        self.connect_game(status_handler(-1, inbox=3))
        text = self.tool_text("game_link")
        self.assertIn("从未启动", text)
        self.assertIn("不会", text)


class TestExecTimeoutDiagnosis(HealthCase):
    def test_exec_timeout_carries_the_diagnosis(self):
        """exec 超时的错误里要直接带结论——失败必须响亮，且可解释。"""
        game = self.connect_game(status_handler(-1))
        game.handlers["exec"] = lambda _m: None      # 故意不回应 → 超时

        res = self.reg.call("exec", {"expr": "getPos _p0", "args": [["u_1"]],
                                     "timeout_s": 0.5})
        self.assertTrue(res.is_error, "超时必须标记为错误")
        self.assertIn("执行失败", res.text)
        self.assertIn("诊断", res.text)
        self.assertIn("从未启动", res.text)

    def test_exec_timeout_with_healthy_executor_says_so(self):
        """执行器活着却仍超时时，不能说成"执行器没跑"——那是误导。"""
        game = self.connect_game(status_handler(50))
        game.handlers["exec"] = lambda _m: None

        res = self.reg.call("exec", {"expr": "getPos _p0", "args": [["u_1"]],
                                     "timeout_s": 0.5})
        self.assertTrue(res.is_error)
        self.assertIn("诊断", res.text)
        self.assertIn("运行中", res.text)
        self.assertNotIn("从未启动", res.text)


if __name__ == "__main__":
    unittest.main()


class FakeChan:
    """按脚本回答 status / window_info 的假通道（形态判定只依赖这两条直连命令）。"""

    def __init__(self, status_ok=True, has_window=True, status_timeout=False,
                 win_timeout=False, connects=1):  # noqa: ANN001
        self.status_ok = status_ok
        self.has_window = has_window
        self.status_timeout = status_timeout
        self.win_timeout = win_timeout
        self.connects = connects

    def send(self, payload, timeout_s=5.0):  # noqa: ANN001
        from adapters.channel import Reply

        class R:
            def __init__(self, ok, result=None, error=""):  # noqa: ANN001
                self.ok, self.result, self.error = ok, result, error

        cmd = payload.get("cmd")
        if cmd == "status":
            if self.status_timeout:
                raise OSError("模拟超时")
            if not self.status_ok:
                return R(False, error="DLL 未应答")
            return R(True, {"ok": True, "connected": True, "inbox": 0,
                            "connects": self.connects})
        if cmd == "window_info":
            if self.win_timeout:
                raise OSError("模拟超时")
            if self.has_window:
                return R(True, {"ok": True, "client": [1360, 768],
                                "client_origin": [0, 23]})
            return R(True, {"ok": False,
                            "error": "找不到游戏窗口（扩展尚未在游戏进程内加载？）"})
        return R(False, error="未预期的命令")


class TestProcessKind(unittest.TestCase):
    """P3：分清客户端与无头服务器 —— 误判会让正常客户端也被拦。"""

    def setUp(self):
        from adapters import health
        health.forget_ui_cache()

    def test_client_with_window_has_ui(self):
        from adapters import health
        ok, why = health.has_ui(FakeChan(has_window=True))
        self.assertTrue(ok, why)
        self.assertEqual(why, "")
        self.assertIsNone(health.require_ui(FakeChan(has_window=True)))

    def test_no_window_is_headless(self):
        from adapters import health
        ok, why = health.has_ui(FakeChan(has_window=False))
        self.assertFalse(ok)
        self.assertIn("无头形态", why)

    def test_dll_not_answering_is_unknown_not_headless(self):
        """DLL 都没答上来时**不能**判成服务器 —— 那是把故障说成形态度。

        这条是这个判据的核心：只有"DLL 在、但没窗口"才等于无头。
        """
        from adapters import health
        ok, why = health.has_ui(FakeChan(status_ok=False))
        self.assertFalse(ok)
        self.assertNotIn("无头形态", why)
        self.assertIn("无法判断", why)

    def test_status_timeout_is_unknown_not_headless(self):
        from adapters import health
        ok, why = health.has_ui(FakeChan(status_timeout=True))
        self.assertFalse(ok)
        self.assertNotIn("无头形态", why)

    def test_window_timeout_is_unknown_not_headless(self):
        """window_info 超时 ≠ 没窗口：超时可能是别的原因，不能当形态结论。"""
        from adapters import health
        ok, why = health.has_ui(FakeChan(win_timeout=True))
        self.assertFalse(ok)
        self.assertNotIn("无头形态", why)

    def test_refusal_text_says_what_still_works(self):
        """拒绝说明要讲清"这不是故障"，并指出服务器上还能做什么。"""
        from adapters import health
        text = health.require_ui(FakeChan(has_window=False))
        self.assertIsNotNone(text)
        self.assertIn("locale effect", text)
        self.assertIn("exec", text)
        self.assertIn("config_", text)
        self.assertIn("专用服务器", text)

    def test_result_is_cached_per_channel(self):
        """形态按进程算，缓存它免得每次点击都往返两趟 DLL。"""
        from adapters import health
        chan = FakeChan(has_window=False)
        self.assertFalse(health.has_ui(chan)[0])
        chan.has_window = True           # 改掉也不该影响已缓存的结果
        self.assertFalse(health.has_ui(chan)[0])
        self.assertTrue(health.has_ui(chan, refresh=True)[0])

    def test_cache_invalidated_on_reconnect(self):
        """重连后必须重新判定 —— 客户端换成专用服务器就是靠这条生效的。

        实测踩过：缓存只按通道对象做键时，游戏从客户端换成服务器（DLL 重连、
        通道对象不变）之后仍沿用"有 UI"的旧判定，UI 工具照旧放行，修复明明
        生效却看不出效果。key 里带上 connects 就自动解决了。
        """
        from adapters import health
        chan = FakeChan(has_window=True, connects=1)      # 客户端
        self.assertTrue(health.has_ui(chan)[0])
        chan.has_window = False                            # 同一通道，换成服务器
        chan.connects = 2                                  # 重连发生
        self.assertFalse(health.has_ui(chan)[0])

    def test_forget_cache_clears(self):
        from adapters import health
        chan = FakeChan(has_window=False)
        health.has_ui(chan)
        health.forget_ui_cache()
        chan.has_window = True
        self.assertTrue(health.has_ui(chan)[0])
