#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""端到端测试：以子进程方式启动真实服务器，走 stdio 协议对话。

为什么必须用子进程而不是直接调 handler：stdio 帧格式、启动失败、
静默退出、非 UTF-8 输出这类问题只在真实进程边界上才会暴露。
"""

from __future__ import annotations

import json
import os
import subprocess
import sys
import unittest

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


class ServerProcess:
    """把服务器当子进程驱动：发一条消息，读一条响应。"""

    def __init__(self, env: dict | None = None) -> None:
        merged = dict(os.environ)
        merged.setdefault("PYTHONIOENCODING", "utf-8")
        if env:
            merged.update(env)
        self.proc = subprocess.Popen(
            [sys.executable, "-m", "servers.engine"],
            cwd=REPO, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE, env=merged)
        self._id = 0

    def send(self, method: str, params: dict | None = None,
             notify: bool = False) -> dict | None:
        msg: dict = {"jsonrpc": "2.0", "method": method}
        if not notify:
            self._id += 1
            msg["id"] = self._id
        if params is not None:
            msg["params"] = params
        assert self.proc.stdin is not None
        self.proc.stdin.write(
            (json.dumps(msg, ensure_ascii=False) + "\n").encode("utf-8"))
        self.proc.stdin.flush()
        if notify:
            return None
        return self._read()

    def call(self, tool: str, args: dict | None = None) -> dict:
        resp = self.send("tools/call", {"name": tool, "arguments": args or {}})
        assert resp is not None
        if "error" in resp:
            raise AssertionError(f"tools/call 返回协议错误：{resp['error']}")
        return resp["result"]

    def _read(self) -> dict:
        assert self.proc.stdout is not None
        line = self.proc.stdout.readline()
        if not line:
            err = b""
            if self.proc.stderr is not None:
                err = self.proc.stderr.read()
            raise AssertionError(
                f"服务器无响应或已退出；stderr={err.decode('utf-8', 'replace')[:800]}")
        return json.loads(line.decode("utf-8"))

    def close(self) -> tuple[int, str]:
        assert self.proc.stdin is not None
        self.proc.stdin.close()
        rc = self.proc.wait(timeout=10)
        err = b""
        if self.proc.stderr is not None:
            err = self.proc.stderr.read()
        return rc, err.decode("utf-8", "replace")


def text_of(result: dict) -> str:
    return "\n".join(c.get("text", "") for c in result.get("content", []))


class TestEngineServerE2E(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.srv = ServerProcess()
        init = cls.srv.send("initialize", {
            "protocolVersion": "2024-11-05",
            "clientInfo": {"name": "test", "version": "1.0"}})
        assert init is not None
        cls.init_result = init["result"]
        cls.srv.send("notifications/initialized", notify=True)

    @classmethod
    def tearDownClass(cls):
        rc, err = cls.srv.close()
        # 服务器必须干净退出（没有 traceback）
        assert rc == 0, f"服务器退出码 {rc}，stderr={err[:500]}"

    # ------------------------------------------------------------ 协议与能力

    def test_initialize_contract(self):
        self.assertEqual(self.init_result["serverInfo"]["name"], "arma3-mcp-engine")
        self.assertIn("tools", self.init_result["capabilities"])
        self.assertIn("instructions", self.init_result)

    def test_tool_catalog(self):
        resp = self.srv.send("tools/list")
        assert resp is not None
        names = [t["name"] for t in resp["result"]["tools"]]
        for expected in ("cmd_families", "cmd_search", "cmd_info", "cmd_check",
                         "cmd_gate", "exec", "exec_batch", "gates_status"):
            self.assertIn(expected, names)
        # 每个工具都必须有可读描述（模型靠它决定要不要用）
        for tool in resp["result"]["tools"]:
            self.assertGreater(len(tool["description"]), 10, tool["name"])
            self.assertEqual(tool["inputSchema"]["type"], "object")

    # ------------------------------------------------------------ 知识链路

    def test_families_lists_catalog(self):
        text = text_of(self.srv.call("cmd_families"))
        self.assertIn("5181", text)
        self.assertIn("set", text)

    def test_search_finds_command(self):
        text = text_of(self.srv.call("cmd_search", {"query": "setposatl"}))
        self.assertIn("setPosATL", text)

    def test_search_no_hit_explains_itself(self):
        result = self.srv.call("cmd_search", {"query": "zzz_no_such_thing"})
        text = text_of(result)
        self.assertIn("没有匹配", text)
        self.assertIn("wiki", text, "未收录时必须提示这并不等于命令不存在")

    def test_info_shows_signature_and_gate(self):
        text = text_of(self.srv.call("cmd_info", {"cmd": "setPosATL"}))
        self.assertIn("object setPosATL pos", text)
        self.assertIn("闸门分级", text)
        self.assertIn("单元素数组", text, "必须告知实体参数的承载方式")

    def test_info_unknown_command_is_error(self):
        result = self.srv.call("cmd_info", {"cmd": "noSuchCommandZzz"})
        self.assertTrue(result["isError"])

    def test_check_valid_params(self):
        result = self.srv.call("cmd_check", {
            "cmd": "setPosATL", "args": [["u_17"], [100, 200, 0]]})
        self.assertFalse(result["isError"])
        self.assertIn("通过", text_of(result))

    def test_check_rejects_wrong_type(self):
        result = self.srv.call("cmd_check", {
            "cmd": "setPosATL", "args": [["u_17"], "not-a-position"]})
        self.assertIn("不通过", text_of(result))
        self.assertIn("类型不符", text_of(result))

    # ------------------------------------------------------------ 执行链路

    def test_exec_dry_run_shows_payload_without_sending(self):
        result = self.srv.call("exec", {
            "cmd": "setPosATL", "args": [["u_17"], [1, 2, 3]], "dry_run": True})
        text = text_of(result)
        self.assertFalse(result["isError"])
        self.assertIn("预演，未执行", text)
        self.assertIn("<u_17>", text)
        payload = result["structuredContent"]["payload"]
        self.assertEqual(payload["cmd"], "setPosATL")
        self.assertEqual(payload["args"][0], {"__ent__": "u_17"})

    def test_exec_without_channel_fails_loudly(self):
        """P0 阶段没有执行通道：必须明确说"没发送、没执行"，绝不假装成功。"""
        result = self.srv.call("exec", {
            "cmd": "setPosATL", "args": [["u_17"], [1, 2, 3]]})
        self.assertTrue(result["isError"])
        text = text_of(result)
        self.assertIn("未接通", text)
        self.assertIn("没有", text)

    def test_exec_blocks_forbidden_command(self):
        result = self.srv.call("exec", {"cmd": "execVM", "args": ["x.sqf"]})
        self.assertTrue(result["isError"])
        self.assertIn("硬禁", text_of(result))

    def test_exec_blocks_exotic_by_default(self):
        result = self.srv.call("exec", {
            "cmd": "createVehicle", "args": ["B_MRAP_01_F", [0, 0, 0]]})
        self.assertTrue(result["isError"])
        self.assertIn("EXOTIC", text_of(result))

    def test_exec_rejects_bad_args_before_channel(self):
        result = self.srv.call("exec", {"cmd": "setPosATL", "args": []})
        self.assertTrue(result["isError"])
        self.assertIn("参数校验不通过", text_of(result))

    def test_exec_unknown_command_suggests(self):
        result = self.srv.call("exec", {"cmd": "setposat", "args": []})
        text = text_of(result)
        self.assertTrue(result["isError"])
        self.assertIn("setposatl", text.lower())

    def test_exec_batch_respects_limit(self):
        calls = [{"cmd": "getPos", "args": [["u_1"]]} for _ in range(12)]
        result = self.srv.call("exec_batch", {"calls": calls})
        self.assertTrue(result["isError"])
        self.assertIn("最多", text_of(result))

    def test_exec_batch_dry_run_summary(self):
        calls = [{"cmd": "getPos", "args": [["u_1"]]},
                 {"cmd": "markerPos", "args": ["m_1"]}]
        result = self.srv.call("exec_batch", {"calls": calls, "dry_run": True})
        text = text_of(result)
        self.assertIn("2/2", text)
        self.assertIn("预演", text)

    # ------------------------------------------------------------ 控制面

    def test_gates_status_reports_channel_and_flags(self):
        result = self.srv.call("gates_status")
        text = text_of(result)
        self.assertIn("engine_exotic", text)
        self.assertIn("input_inject", text)
        self.assertIn("执行通道", text)
        structured = result["structuredContent"]
        self.assertFalse(structured["gates"]["engine_exotic"])
        self.assertFalse(structured["channel"]["connected"])

    def test_cmd_gate_explains(self):
        text = text_of(self.srv.call("cmd_gate", {"cmd": "attrit"}))
        self.assertIn("拒绝", text)
        self.assertIn("ALC_ALLOW_CHEAT", text)

    # ------------------------------------------------------------ 健壮性

    def test_garbage_then_normal_request(self):
        assert self.srv.proc.stdin is not None
        self.srv.proc.stdin.write(b"{{{ not json\n")
        self.srv.proc.stdin.flush()
        line = self.srv.proc.stdout.readline()  # type: ignore[union-attr]
        err = json.loads(line.decode("utf-8"))
        self.assertEqual(err["error"]["code"], -32700)
        # 服务器仍能正常工作
        self.assertIn("5181", text_of(self.srv.call("cmd_families")))

    def test_notification_produces_no_response(self):
        """通知不得产生响应——发了会被客户端判为协议违规。"""
        self.srv.send("notifications/cancelled", {"requestId": 999}, notify=True)
        # 紧跟一个正常请求：如果通知产生了响应，这里读到的就会是它
        resp = self.srv.send("ping")
        assert resp is not None
        self.assertEqual(resp.get("result"), {})


class TestChannelSelection(unittest.TestCase):
    def test_default_is_null_channel(self):
        from adapters import channel_from_env
        chan = channel_from_env({})
        self.assertEqual(chan.name, "null")
        self.assertFalse(chan.connected())

    def test_unknown_channel_type_reports_reason(self):
        from adapters import channel_from_env
        chan = channel_from_env({"ALC_CHANNEL": "carrier-pigeon"})
        self.assertFalse(chan.connected())
        self.assertIn("carrier-pigeon", chan.info()["reason"])

    def test_null_channel_send_explains_no_execution(self):
        from adapters import channel_from_env
        reply = channel_from_env({}).send({"cmd": "getPos", "args": []})
        self.assertFalse(reply.ok)
        self.assertIn("没有", reply.error)
        self.assertTrue(reply.cid)


if __name__ == "__main__":
    unittest.main(verbosity=2)
