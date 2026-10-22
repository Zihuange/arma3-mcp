#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""执行闭环端到端测试：MCP 服务器 + TCP 通道 + 假游戏，全部走真实进程与网络。

这是 P1 在本机最重要的验收：
    DSH 侧协议(stdio) → 工具链 → 闸门 → TCP 通道 → 假游戏 → 回执回来
真实 DLL 上机时只需再验证"引擎语义"，网络、协议、配对、超时、断线
这些风险已经在这里排掉了。
"""

from __future__ import annotations
from typing import Optional

import json
import os
import socket
import subprocess
import sys
import time
import unittest

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, REPO)

from tests.fake_game import FakeGame, fail_handler, silent_handler  # noqa: E402


def free_port() -> int:
    sock = socket.socket()
    sock.bind(("127.0.0.1", 0))
    port = sock.getsockname()[1]
    sock.close()
    return port


class McpServer:
    """以子进程驱动 MCP 服务器，并可指定通道环境变量。"""

    def __init__(self, env: dict) -> None:
        merged = dict(os.environ)
        merged.update(env)
        # 用当前解释器启动子进程：这样同一套测试在 WSL(python3) 与
        # Windows(py.exe) 上都能跑——硬编码 /usr/bin/python3 会让
        # Windows 侧整体报错，把平台差异误报成功能缺陷。
        self.proc = subprocess.Popen(
            [sys.executable, "-m", "servers.engine"],
            cwd=REPO, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE, env=merged)
        self._id = 0

    def request(self, method: str, params: Optional[dict] = None) -> dict:
        self._id += 1
        msg = {"jsonrpc": "2.0", "id": self._id, "method": method}
        if params is not None:
            msg["params"] = params
        assert self.proc.stdin is not None
        self.proc.stdin.write((json.dumps(msg) + "\n").encode())
        self.proc.stdin.flush()
        assert self.proc.stdout is not None
        line = self.proc.stdout.readline()
        if not line:
            err = self.proc.stderr.read().decode("utf-8", "replace") if self.proc.stderr else ""
            raise AssertionError("服务器无响应；stderr=" + err[:500])
        return json.loads(line.decode())

    def notify(self, method: str) -> None:
        msg = {"jsonrpc": "2.0", "method": method}
        assert self.proc.stdin is not None
        self.proc.stdin.write((json.dumps(msg) + "\n").encode())
        self.proc.stdin.flush()

    def call(self, tool: str, args: Optional[dict] = None) -> dict:
        resp = self.request("tools/call", {"name": tool,
                                           "arguments": args or {}})
        if "error" in resp:
            raise AssertionError("协议错误：%s" % resp["error"])
        return resp["result"]

    def close(self) -> None:
        # 三个管道都要关：只关 stdin 会留下未回收的 fd（ResourceWarning）
        for stream in (self.proc.stdin, self.proc.stdout, self.proc.stderr):
            if stream is not None:
                try:
                    stream.close()
                except OSError:
                    pass
        try:
            self.proc.wait(timeout=10)
        except subprocess.TimeoutExpired:
            self.proc.kill()


def text_of(result: dict) -> str:
    return "\n".join(c.get("text", "") for c in result.get("content", []))


class ExecE2ECase(unittest.TestCase):
    """每个用例：一个 MCP 子进程（tcp 通道）+ 一个假游戏。"""

    def setUp(self):
        self.port = free_port()
        self.env = {
            "ALC_CHANNEL": "tcp",
            "ALC_TCP_HOST": "127.0.0.1",
            "ALC_TCP_PORT": str(self.port),
            "ALC_ENGINE_WRITE": "1",
            "ALC_ENGINE_EXOTIC": "0",
            "ALC_AUDIT_LOG": os.path.join(REPO, "audit.jsonl"),
        }
        self.srv = McpServer(self.env)
        self.srv.request("initialize", {"protocolVersion": "2024-11-05"})
        self.srv.notify("notifications/initialized")
        self.games: list[FakeGame] = []

    def tearDown(self):
        for game in self.games:
            game.close()
        self.srv.close()

    def connect_game(self, **kwargs) -> FakeGame:
        for _ in range(40):
            game = FakeGame(host="127.0.0.1", port=self.port, **kwargs)
            if game.connect():
                self.games.append(game)
                return game
            time.sleep(0.1)
        raise AssertionError("假游戏无法连上 MCP 的 TCP 通道（端口 %d）" % self.port)

    def wait_tool(self, tool: str, args: dict, timeout: float = 8.0) -> dict:
        """在超时内轮询一个工具，直到它不再报告"未接通"。"""
        deadline = time.time() + timeout
        last = None
        while time.time() < deadline:
            last = self.srv.call(tool, args)
            if "尚未连接" not in text_of(last):
                return last
            time.sleep(0.1)
        return last


class TestConnectedFlow(ExecE2ECase):
    def test_status_shows_game_connected(self):
        self.connect_game(pid=5150)
        result = self.wait_tool("gates_status", {})
        text = text_of(result)
        self.assertIn("tcp", text)
        self.assertNotIn("未接通", text)
        self.assertEqual(result["structuredContent"]["channel"]["game"]["pid"], 5150)

    def test_exec_round_trip(self):
        game = self.connect_game()
        game.handlers["exec"] = lambda m: {"ok": True,
                                               "result": {"moved": [1, 2, 3]}}
        result = self.wait_tool("exec", {"expr": "_p0 setPosATL _p1",
                                         "args": [["u_17"], [1, 2, 3]]})
        text = text_of(result)
        self.assertFalse(result["isError"], text)
        self.assertIn("已执行", text)
        self.assertIn("moved", text)
        self.assertTrue(game.wait_commands(1))
        self.assertEqual(game.commands[-1]["cmd"], "exec")
        self.assertEqual(game.commands[-1]["args"][0], "_p0 setPosATL _p1")

    def test_exec_dry_run_does_not_reach_game(self):
        game = self.connect_game()
        result = self.wait_tool("exec", {"expr": "_p0 setPosATL _p1",
                                         "args": [["u_17"], [1, 2, 3]],
                                         "dry_run": True})
        self.assertIn("预演", text_of(result))
        time.sleep(0.3)
        self.assertEqual(len(game.commands), 0, "预演不应把命令发给游戏")

    def test_game_error_is_reported_to_caller(self):
        """游戏侧报告失败时，失败原因必须原样回到调用方。

        用**真实存在**的命令名（getPos）：不存在的命令会被 MCP 的查库闸门
        先拦下，那测的是闸门而不是游戏侧错误回传。
        """
        game = self.connect_game()
        game.handlers["exec"] = fail_handler("坐标越界")
        result = self.wait_tool("exec", {"expr": "getPos _p0", "args": [["u_1"]]})
        self.assertTrue(result["isError"])
        self.assertIn("坐标越界", text_of(result))

    def test_timeout_says_result_unknown(self):
        game = self.connect_game()
        game.handlers["exec"] = silent_handler()
        result = self.wait_tool("exec", {"expr": "getPos _p0", "args": [["u_1"]],
                                         "timeout_s": 1.0}, timeout=10)
        self.assertTrue(result["isError"])
        text = text_of(result)
        self.assertIn("超时", text)
        self.assertIn("结果未知", text)

    def test_batch_runs_serially_and_reports_each(self):
        game = self.connect_game()
        calls = [{"expr": "getPos _p0", "args": [["u_%d" % i]]}
                 for i in range(1, 5)]
        result = self.wait_tool("exec_batch", {"calls": calls, "timeout_s": 3.0})
        text = text_of(result)
        self.assertFalse(result["isError"], text)
        self.assertIn("4/4", text)
        time.sleep(0.3)
        self.assertEqual(len(game.commands), 4)

    def test_events_from_game_are_readable(self):
        game = self.connect_game()
        game.push_event("evt:cmd_error:参数类型错误")
        game.push_event("queue:depth=3 dropped=1")
        deadline = time.time() + 5
        text = ""
        while time.time() < deadline:
            result = self.srv.call("game_events", {})
            text = text_of(result)
            if "evt:cmd_error" in text:
                break
            time.sleep(0.1)
        self.assertIn("evt:cmd_error", text)
        self.assertIn("参数类型错误", text)

    def test_events_filter(self):
        game = self.connect_game()
        game.push_event("status:alpha:alive=4/4")
        game.push_event("evt:killed:alpha:u_2")
        deadline = time.time() + 5
        text = ""
        while time.time() < deadline:
            result = self.srv.call("game_events", {"filter": "evt:"})
            text = text_of(result)
            if "evt:killed" in text:
                break
            time.sleep(0.1)
        self.assertIn("evt:killed", text)
        self.assertNotIn("status:alpha", text)


class TestDisconnectedFlow(ExecE2ECase):
    def test_exec_without_game_is_honest(self):
        result = self.srv.call("exec", {"expr": "_p0 setPosATL _p1",
                                        "args": [["u_17"], [1, 2, 3]]})
        self.assertTrue(result["isError"])
        text = text_of(result)
        self.assertIn("尚未连接", text)
        self.assertIn("没有", text)

    def test_disconnect_then_reconnect(self):
        game = self.connect_game()
        result = self.wait_tool("exec", {"expr": "getPos _p0", "args": [["u_1"]]})
        self.assertFalse(result["isError"], text_of(result))
        game.kill()
        # 断开后应报告未接通
        deadline = time.time() + 5
        text = ""
        while time.time() < deadline:
            result = self.srv.call("exec", {"expr": "getPos _p0", "args": [["u_1"]]})
            text = text_of(result)
            if "尚未连接" in text:
                break
            time.sleep(0.15)
        self.assertIn("尚未连接", text)
        # 重连后应恢复
        self.connect_game(pid=9999)
        result = self.wait_tool("exec", {"expr": "getPos _p0", "args": [["u_1"]]})
        self.assertFalse(result["isError"], text_of(result))


if __name__ == "__main__":
    unittest.main(verbosity=2)
