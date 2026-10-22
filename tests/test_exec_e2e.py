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
from adapters.exec_tools import expand_placeholders  # noqa: E402


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
            "A3MCP_CHANNEL": "tcp",
            "A3MCP_TCP_HOST": "127.0.0.1",
            "A3MCP_TCP_PORT": str(self.port),
            "A3MCP_ENGINE_WRITE": "1",
            "A3MCP_ENGINE_EXOTIC": "0",
            "A3MCP_AUDIT_LOG": os.path.join(REPO, "audit.jsonl"),
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
        # 下发的必须是**展开后**的形态：`_p0` 不是 SQF 变量，原样下发的话引擎会
        # 报"未定义的变量：_p0"，而回执仍是成功、结果 nil（实测踩过）。
        self.assertEqual(game.commands[-1]["args"][0],
                         "(_this select 0) setPosATL (_this select 1)")
        # 参数以数据原样下发，不被展开逻辑碰到
        self.assertEqual(game.commands[-1]["args"][1], [["u_17"], [1, 2, 3]])

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


class TestCallGateE2E(ExecE2ECase):
    """`call` 的闭环：闸门 + 目标核对 + 真的不到游戏里去。

    只测 Python 侧不够——**判定发生在服务器进程里**，而这一族最容易出的问题是
    "校验写对了，但调用链没把数据传下去"，那样闸门就是装饰。所以这里让请求
    真的走过 MCP 进程、走到假游戏，再看它有没有到。
    """

    def setUp(self):
        super().setUp()
        self.env = dict(self.env, A3MCP_ENGINE_CALL="1")
        # 默认的 setUp 起的服务器没开 call 闸门，这里换一个开着的
        self.srv.close()
        self.srv = McpServer(self.env)
        self.srv.request("initialize", {"protocolVersion": "2024-11-05"})
        self.srv.notify("notifications/initialized")

    def test_execvm_via_call_is_rejected_and_never_sent(self):
        """★ 最重要的一条：BIS_fnc_execVM 经 call 也必须拒，且不能发到游戏。"""
        game = self.connect_game()
        result = self.srv.call("exec", {"expr": "_p0 call _p1",
                                        "args": [["u_1"], "BIS_fnc_execVM"]})
        text = text_of(result)
        self.assertTrue(result["isError"], text)
        self.assertIn("BIS_fnc_execVM", text)
        time.sleep(0.3)
        self.assertEqual(len(game.commands), 0,
                         "被 CALL_DENY 拒绝的调用不该出现在游戏侧")

    def test_deny_family_never_reaches_game(self):
        """执行类/远程类整族都到不了游戏侧。"""
        game = self.connect_game()
        for fn in ("BIS_fnc_execFSM", "BIS_fnc_spawn", "BIS_fnc_dbg_console",
                   "compile", "spawn", "execVM", "callExtension"):
            result = self.srv.call("exec", {"expr": "_p0 call _p1",
                                            "args": [["u_1"], fn]})
            self.assertTrue(result["isError"], "%s 应被拒绝：%s"
                            % (fn, text_of(result)))
        time.sleep(0.3)
        self.assertEqual(len(game.commands), 0)

    def test_legitimate_call_reaches_game(self):
        """正常函数要能真的发出去——否则这闸门只是把能力关掉了。"""
        game = self.connect_game()
        game.handlers["exec"] = lambda m: {"ok": True, "result": {"ran": True}}
        result = self.wait_tool("exec", {"expr": "_p0 call _p1",
                                         "args": [["u_1"], "a3mcp_fnc_validate"]})
        text = text_of(result)
        self.assertFalse(result["isError"], text)
        self.assertTrue(game.wait_commands(1))
        # 目标函数名走数据、位置保持不变：展开只动占位符，不碰参数数组。
        # 这条一起守住"展开没把参数挪位"——挪位的话 CALL_DENY 核对的就是别的值了。
        self.assertEqual(game.commands[-1]["args"][0],
                         "(_this select 0) call (missionNamespace"
                         " getVariable (_this select 1))")
        self.assertEqual(game.commands[-1]["args"][1][1], "a3mcp_fnc_validate")


class TestPlaceholderExpansion(unittest.TestCase):
    """占位符展开的单元测试。

    这是**曾经整条链路失效**的地方：`_p0` 不是 SQF 变量，原样下发必然在引擎里
    报"未定义的变量：_p0"，而回执仍报成功、结果 nil —— 调用方看到的是"成功地
    什么都没做"。无参表达式不受影响，所以只用无参命令的测试发现不了。

    展开只认"独立成词"的 `_pN`，边界用例与正向用例同等重要：误替换会把正常
    标识符切坏，那比不展开更难查。
    """

    def test_basic_expansion(self):
        self.assertEqual(expand_placeholders("_p0 setPosATL _p1", 2),
                         "(_this select 0) setPosATL (_this select 1)")

    def test_single_and_no_arg(self):
        self.assertEqual(expand_placeholders("getPos _p0", 1),
                         "getPos (_this select 0)")
        self.assertEqual(expand_placeholders("worldName", 0), "worldName")

    def test_call_form(self):
        """call 的目标要包一层 getVariable。

        引擎要求 call 的右操作数**编译期可确定**：直接给 `(_this select 1)`
        会被拒（实测 `Error position: <call (_this select 1)>`）。所以展开时
        先经 getVariable 把函数取回来——函数名仍只是数据，没被编译成代码。
        """
        self.assertEqual(
            expand_placeholders("_p0 call _p1", 2),
            "(_this select 0) call (missionNamespace getVariable (_this select 1))")

    def test_multi_digit_index(self):
        self.assertEqual(expand_placeholders("_p0 + _p10", 11),
                         "(_this select 0) + (_this select 10)")

    def test_word_boundaries_not_touched(self):
        """形近但非占位符的标识符不能被切开。"""
        for src in ("_p0abc", "_plimit", "_p_0", "x_p0", "a_p0b"):
            self.assertEqual(expand_placeholders(src, 4), src, src)

    def test_out_of_range_left_alone(self):
        """越界下标原样保留：那是校验器该拦的，展开不该悄悄改语义。"""
        self.assertEqual(expand_placeholders("_p0", 0), "_p0")
        self.assertEqual(expand_placeholders("_p3", 2), "_p3")

    def test_repeated_placeholder(self):
        self.assertEqual(expand_placeholders("_p0 + _p0", 1),
                         "(_this select 0) + (_this select 0)")


class TestCallGateClosedE2E(ExecE2ECase):
    """闸门关着时（默认）call 必须被拒——这是本档默认值的一部分。"""

    def test_call_rejected_when_gate_closed(self):
        game = self.connect_game()
        result = self.srv.call("exec", {"expr": "_p0 call _p1",
                                        "args": [["u_1"], "a3mcp_fnc_init"]})
        text = text_of(result)
        self.assertTrue(result["isError"], text)
        # 报错要指向开关，而不是让人反复改表达式
        self.assertIn("A3MCP_ENGINE_CALL", text)
        time.sleep(0.3)
        self.assertEqual(len(game.commands), 0)


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
