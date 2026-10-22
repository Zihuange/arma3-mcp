#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""TCP 执行通道测试（不需要游戏）。

用假游戏客户端验证通道层的全部关键行为：握手与鉴权、回执配对、超时、
断线、静默、事件转发、连接替换。真实 DLL 上机时只需再验证"引擎语义"，
网络与协议这一层的风险已经在这里排掉。
"""

from __future__ import annotations

import os
import socket
import sys
import time
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from adapters.tcp_channel import DEFAULT_TOKEN, TcpChannel  # noqa: E402
from tests.fake_game import (  # noqa: E402
    FakeGame, fail_handler, ok_handler, silent_handler,
)


def free_port() -> int:
    sock = socket.socket()
    sock.bind(("127.0.0.1", 0))
    port = sock.getsockname()[1]
    sock.close()
    return port


class ChannelCase(unittest.TestCase):
    """每个用例一张独立端口，避免相互影响。"""

    def setUp(self):
        self.port = free_port()
        self.chan = TcpChannel(host="127.0.0.1", port=self.port,
                               token=DEFAULT_TOKEN, default_timeout=1.0)
        self.assertTrue(self.chan.start(), self.chan.start_error)
        self.games: list[FakeGame] = []

    def tearDown(self):
        for game in self.games:
            game.close()
        self.chan.stop()

    def connect_game(self, **kwargs) -> FakeGame:
        game = FakeGame(host="127.0.0.1", port=self.port, **kwargs)
        ok = game.connect()
        self.assertTrue(ok, "假游戏连接失败")
        self.games.append(game)
        # 等通道登记连接
        deadline = time.time() + 2
        while time.time() < deadline and not self.chan.connected():
            time.sleep(0.02)
        return game


class TestHandshake(ChannelCase):
    def test_connect_and_info(self):
        game = self.connect_game(pid=7777, ver="fake-9")
        self.assertTrue(self.chan.connected())
        info = self.chan.info()
        self.assertEqual(info["channel"], "tcp")
        self.assertTrue(info["connected"])
        self.assertEqual(info["game"]["pid"], 7777)
        self.assertEqual(info["game"]["version"], "fake-9")
        self.assertEqual(game.handshake_reply.get("ver"), 1)

    def test_wrong_token_rejected(self):
        game = FakeGame(host="127.0.0.1", port=self.port, token="wrong-token")
        ok = game.connect()
        self.games.append(game)
        self.assertFalse(ok, "错误 token 不应握手成功")
        self.assertIn("token", str(game.handshake_reply))

    def test_non_hello_first_message_rejected(self):
        sock = socket.create_connection(("127.0.0.1", self.port), timeout=3)
        try:
            sock.sendall(b'{"t":"cmd","cmd":"getPos"}\n')
            sock.settimeout(2)
            try:
                data = sock.recv(4096)
            except socket.timeout:
                data = b""
            self.assertEqual(data, b"", "非 hello 首消息应被断开")
        finally:
            sock.close()
        self.assertFalse(self.chan.connected())

    def test_send_before_game_connected(self):
        reply = self.chan.send({"cmd": "getPos", "args": [["u_1"]]})
        self.assertFalse(reply.ok)
        self.assertIn("尚未连接", reply.error)
        self.assertIn("没有", reply.error)


class TestCommandFlow(ChannelCase):
    def test_send_receives_paired_reply(self):
        game = self.connect_game()
        game.handlers["setPosATL"] = ok_handler({"moved": True})
        reply = self.chan.send({"cmd": "setPosATL",
                                "args": [{"__ent__": "u_17"}, [1, 2, 3]]})
        self.assertTrue(reply.ok, reply.error)
        self.assertEqual(reply.result, {"moved": True})
        self.assertTrue(game.wait_commands(1))
        sent = game.commands[0]
        self.assertEqual(sent["cmd"], "setPosATL")
        self.assertEqual(sent["args"][0], {"__ent__": "u_17"})
        self.assertTrue(sent["cid"].startswith("c"))

    def test_game_reports_failure(self):
        game = self.connect_game()
        game.handlers["boom"] = fail_handler("参数越界")
        reply = self.chan.send({"cmd": "boom", "args": []})
        self.assertFalse(reply.ok)
        self.assertEqual(reply.error, "参数越界")
        self.assertIn("cid", reply.to_dict())

    def test_default_reply_echoes_args(self):
        game = self.connect_game()
        reply = self.chan.send({"cmd": "getPos", "args": [["u_1"]]})
        self.assertTrue(reply.ok)
        self.assertEqual(reply.result["echo"], "getPos")
        self.assertEqual(reply.result["args"], [["u_1"]])

    def test_timeout_when_game_stays_silent(self):
        game = self.connect_game()
        game.handlers["dead"] = silent_handler()
        start = time.time()
        reply = self.chan.send({"cmd": "dead", "args": []}, timeout_s=0.4)
        elapsed = time.time() - start
        self.assertFalse(reply.ok)
        self.assertGreaterEqual(elapsed, 0.35)
        self.assertLess(elapsed, 2.0)
        # 超时文案必须让人知道"结果未知"，而不是"失败"
        self.assertIn("结果未知", reply.error)
        self.assertEqual(self.chan.stats["timeouts"], 1)

    def test_concurrent_commands_pair_correctly(self):
        """并发命令必须各自拿到自己的回执（回执按 cid 配对，不串台）。

        记录用带锁的列表而不是共享字典：多个线程并发写同一个 dict 是测试
        自身的缺陷，会让"结果数不足"这种假失败掩盖真实行为。
        """
        import threading

        game = self.connect_game()
        game.handlers["slow"] = ok_handler({"who": "slow"})
        game.handlers["fast"] = ok_handler({"who": "fast"})

        names = ["slow", "fast", "slow", "fast"]
        results: list = []
        lock = threading.Lock()

        def call(name: str) -> None:
            reply = self.chan.send({"cmd": name, "args": []}, timeout_s=5.0)
            with lock:
                results.append((name, reply))

        threads = [threading.Thread(target=call, args=(n,)) for n in names]
        for t in threads:
            t.start()
        for t in threads:
            t.join(timeout=10)
        self.assertFalse(any(t.is_alive() for t in threads), "有线程未结束")
        self.assertEqual(len(results), len(names))
        for name, reply in results:
            self.assertTrue(reply.ok, f"{name}: {reply.error}")
            # 关键断言：拿到的回执必须是自己那条命令的
            self.assertEqual(reply.result["who"], name)

    def test_unmatched_ack_is_counted_not_fatal(self):
        game = self.connect_game()
        game._send({"t": "ack", "cid": "c-nonexistent", "ok": True})
        time.sleep(0.2)
        self.assertEqual(self.chan.stats["unmatched_acks"], 1)
        reply = self.chan.send({"cmd": "getPos", "args": [["u_1"]]})
        self.assertTrue(reply.ok, "错配回执不应影响后续命令")


class TestDisconnect(ChannelCase):
    def test_kill_fails_pending_immediately(self):
        game = self.connect_game()
        game.handlers["hang"] = silent_handler()
        result: list = []

        import threading
        def call():
            result.append(self.chan.send({"cmd": "hang", "args": []},
                                         timeout_s=10.0))

        t = threading.Thread(target=call)
        t.start()
        time.sleep(0.3)
        self.assertEqual(self.chan.pending_count(), 1)
        game.kill()
        t.join(timeout=5)
        self.assertTrue(result, "断线后应立刻返回，而不是等到超时")
        self.assertFalse(result[0].ok)
        self.assertIn("断开", result[0].error)
        self.assertLess(result[0].elapsed_ms, 5000)

    def test_after_disconnect_send_reports_not_connected(self):
        game = self.connect_game()
        game.kill()
        deadline = time.time() + 3
        while time.time() < deadline and self.chan.connected():
            time.sleep(0.05)
        self.assertFalse(self.chan.connected())
        reply = self.chan.send({"cmd": "getPos", "args": []})
        self.assertFalse(reply.ok)
        self.assertIn("尚未连接", reply.error)

    def test_reconnect_replaces_connection(self):
        first = self.connect_game(pid=1)
        second = self.connect_game(pid=2)
        time.sleep(0.3)
        info = self.chan.info()
        self.assertEqual(info["game"]["pid"], 2, "新连接应替换旧连接")
        reply = self.chan.send({"cmd": "getPos", "args": []})
        self.assertTrue(reply.ok)
        self.assertTrue(len(second.commands) >= 1)
        self.assertEqual(len(first.commands), 0, "命令不应发给已替换的连接")


class TestEventsAndQueue(ChannelCase):
    def test_events_are_buffered_and_drained(self):
        """事件先入缓冲，drain 一次全取走，再 drain 为空。

        不要"先 drain 判断有没有、再 drain 取内容"——第一次 drain 就把事件
        吃掉了，那会让测试永远看到空列表（这是本用例初版的真实错误）。
        """
        game = self.connect_game()
        game.push_event("status:alpha:alive=4/4")
        game.push_event("evt:killed:alpha:u_2")

        collected: list[str] = []
        deadline = time.time() + 3
        while time.time() < deadline and len(collected) < 2:
            collected.extend(self.chan.drain_events())
            time.sleep(0.05)

        self.assertIn("status:alpha:alive=4/4", collected)
        self.assertIn("evt:killed:alpha:u_2", collected)
        self.assertEqual(self.chan.drain_events(), [], "drain 后应清空")

    def test_queue_watermark_reported(self):
        game = self.connect_game()
        game.report_queue(depth=5, dropped=2)
        deadline = time.time() + 3
        while time.time() < deadline:
            info = self.chan.info()
            if info.get("game", {}).get("queue_depth") == 5:
                break
            time.sleep(0.05)
        game_info = self.chan.info()["game"]
        self.assertEqual(game_info["queue_depth"], 5)
        self.assertEqual(game_info["dropped"], 2)

    def test_no_events_when_not_connected(self):
        self.assertEqual(self.chan.drain_events(), [])


class TestPortConflicts(ChannelCase):
    def test_port_in_use_reports_actionable_error(self):
        second = TcpChannel(host="127.0.0.1", port=self.port)
        self.assertFalse(second.start())
        second.stop()  # 关掉未成功的 socket，避免 ResourceWarning
        self.assertIn("监听", second.start_error)
        self.assertIn(str(self.port), second.start_error)


if __name__ == "__main__":
    unittest.main(verbosity=2)
