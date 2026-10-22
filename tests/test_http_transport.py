#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""HTTP 传输测试（MCP Streamable HTTP，无状态 JSON 模式）。

这条传输存在的唯一理由：DSH 是 WSL 里的 Node 进程，无法启动 Windows 程序
（见 docs/decisions.md D14），所以"在 Windows 侧跑 MCP"必须由用户手动启动、
DSH 以 HTTP 连入。因此本文件验证的重点是**协议正确性**与**可被真实客户端连上**。
"""

from __future__ import annotations

import json
import os
import sys
import threading
import unittest
import urllib.error
import urllib.request

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, REPO)

from mcpcore import Registry                           # noqa: E402
from mcpcore.http_transport import (                    # noqa: E402
    HEALTH_PATH, MCP_PATH, build_http_server,
)
from mcpcore.registry import ToolResult                # noqa: E402
from mcpcore.server import Server                      # noqa: E402


def tiny_registry() -> Registry:
    reg = Registry()

    @reg.tool(name="echo", description="回显", input_schema={
        "type": "object", "properties": {"text": {"type": "string"}},
        "required": ["text"]})
    def _echo(args: dict) -> ToolResult:
        return ToolResult.ok("echo: " + args["text"])

    @reg.tool(name="boom", description="总是失败")
    def _boom(_args: dict) -> ToolResult:
        raise RuntimeError("炸了")

    return reg


class HttpCase(unittest.TestCase):
    def setUp(self):
        self.server = Server(tiny_registry())
        self.httpd = build_http_server(self.server, "127.0.0.1", 0, quiet=True)
        self.port = self.httpd.server_address[1]
        self.thread = threading.Thread(target=self.httpd.serve_forever,
                                       daemon=True)
        self.thread.start()

    def tearDown(self):
        self.httpd.shutdown()
        self.httpd.server_close()
        self.thread.join(timeout=5)

    # ---------------------------------------------------------------- helpers

    def url(self, path: str) -> str:
        return "http://127.0.0.1:%d%s" % (self.port, path)

    def post(self, payload, path: str = MCP_PATH):
        data = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(self.url(path), data=data,
                                     headers={"Content-Type": "application/json"},
                                     method="POST")
        try:
            with urllib.request.urlopen(req, timeout=10) as resp:
                return resp.status, resp.headers, resp.read()
        except urllib.error.HTTPError as exc:
            # HTTPError 同时是文件对象：不关会被 GC 报 ResourceWarning
            with exc:
                return exc.code, exc.headers, exc.read()

    def post_json(self, payload, path: str = MCP_PATH):
        status, _, body = self.post(payload, path=path)
        return status, (json.loads(body.decode("utf-8")) if body else None)

    def get(self, path: str):
        try:
            with urllib.request.urlopen(self.url(path), timeout=10) as resp:
                return resp.status, resp.read()
        except urllib.error.HTTPError as exc:
            with exc:
                return exc.code, exc.read()


class TestProtocol(HttpCase):
    def test_initialize_over_http(self):
        status, body = self.post_json({
            "jsonrpc": "2.0", "id": 1, "method": "initialize",
            "params": {"protocolVersion": "2025-03-26",
                       "clientInfo": {"name": "ds h", "version": "1"}}})
        self.assertEqual(status, 200)
        result = body["result"]
        self.assertEqual(result["protocolVersion"], "2025-03-26",
                         "应回显客户端请求的协议版本")
        # 只断言名字与包一致：具体后缀由入口决定（engine.py 传的是
        # arma3-mcp-engine），测试不该锁死入口的配置
        self.assertTrue(result["serverInfo"]["name"].startswith("arma3-mcp"))
        self.assertTrue(result["serverInfo"]["version"])
        self.assertIn("tools", result["capabilities"])

    def test_session_header_present(self):
        status, headers, _ = self.post({
            "jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {}})
        self.assertEqual(status, 200)
        self.assertTrue(headers.get("Mcp-Session-Id"),
                        "应带 Mcp-Session-Id 头（部分客户端要求）")

    def test_tools_list(self):
        self.post_json({"jsonrpc": "2.0", "id": 1, "method": "initialize",
                        "params": {}})
        status, body = self.post_json({"jsonrpc": "2.0", "id": 2,
                                       "method": "tools/list"})
        self.assertEqual(status, 200)
        names = [t["name"] for t in body["result"]["tools"]]
        self.assertIn("echo", names)

    def test_tools_call_success(self):
        status, body = self.post_json({
            "jsonrpc": "2.0", "id": 3, "method": "tools/call",
            "params": {"name": "echo", "arguments": {"text": "你好"}}})
        self.assertEqual(status, 200)
        self.assertFalse(body["result"]["isError"])
        self.assertIn("你好", body["result"]["content"][0]["text"])

    def test_tool_error_is_result_not_http_error(self):
        """工具失败必须是 200 + isError，而不是 HTTP 错误码。

        部分客户端会把非 2xx 当作传输故障并断开，那会把"工具报错"
        升级成"服务器不可用"。
        """
        status, body = self.post_json({
            "jsonrpc": "2.0", "id": 4, "method": "tools/call",
            "params": {"name": "boom", "arguments": {}}})
        self.assertEqual(status, 200)
        self.assertTrue(body["result"]["isError"])
        self.assertIn("炸了", body["result"]["content"][0]["text"])

    def test_unknown_tool_is_error_result(self):
        status, body = self.post_json({
            "jsonrpc": "2.0", "id": 5, "method": "tools/call",
            "params": {"name": "nope", "arguments": {}}})
        self.assertEqual(status, 200)
        self.assertTrue(body["result"]["isError"])

    def test_notification_returns_202_no_content(self):
        status, _, body = self.post({"jsonrpc": "2.0",
                                     "method": "notifications/initialized"})
        self.assertEqual(status, 202)
        self.assertEqual(body, b"", "通知不得返回正文")

    def test_bad_json_returns_400(self):
        req = urllib.request.Request(
            self.url(MCP_PATH), data=b"{not json",
            headers={"Content-Type": "application/json"}, method="POST")
        try:
            with urllib.request.urlopen(req, timeout=10) as resp:
                status, body = resp.status, resp.read()
        except urllib.error.HTTPError as exc:
            with exc:
                status, body = exc.code, exc.read()
        self.assertEqual(status, 400)
        self.assertEqual(json.loads(body)["error"]["code"], -32700)

    def test_non_object_payload_returns_400(self):
        status, body = self.post_json([1, 2, 3])
        self.assertEqual(status, 400)
        self.assertEqual(body["error"]["code"], -32600)

    def test_empty_body_returns_400(self):
        req = urllib.request.Request(self.url(MCP_PATH), data=b"",
                                     headers={"Content-Type": "application/json"},
                                     method="POST")
        try:
            with urllib.request.urlopen(req, timeout=10) as resp:
                status = resp.status
        except urllib.error.HTTPError as exc:
            with exc:
                status = exc.code
        self.assertEqual(status, 400)

    def test_unknown_path_404(self):
        status, body = self.post_json({"jsonrpc": "2.0", "id": 1,
                                       "method": "ping"}, path="/nope")
        self.assertEqual(status, 404)
        self.assertIn("not found", json.dumps(body))

    def test_ping_works(self):
        status, body = self.post_json({"jsonrpc": "2.0", "id": 9,
                                       "method": "ping"})
        self.assertEqual(status, 200)
        self.assertEqual(body["result"], {})


class TestNonPostRoutes(HttpCase):
    def test_health_endpoint(self):
        status, body = self.get(HEALTH_PATH)
        self.assertEqual(status, 200)
        self.assertTrue(json.loads(body.decode("utf-8"))["ok"])

    def test_get_mcp_explains_no_sse(self):
        """GET /mcp 不挂住连接，而是明确说明本服务器不推送。"""
        status, body = self.get(MCP_PATH)
        self.assertEqual(status, 405)
        self.assertIn("POST", body.decode("utf-8"))

    def test_delete_session_returns_204(self):
        req = urllib.request.Request(self.url(MCP_PATH), method="DELETE")
        try:
            with urllib.request.urlopen(req, timeout=10) as resp:
                status = resp.status
        except urllib.error.HTTPError as exc:
            with exc:
                status = exc.code
        self.assertEqual(status, 204)


class TestConcurrency(HttpCase):
    def test_parallel_requests(self):
        """并发请求必须都被正确处理（DSH 可能并行调用工具）。"""
        self.post_json({"jsonrpc": "2.0", "id": 1, "method": "initialize",
                        "params": {}})
        results: list = []
        lock = threading.Lock()

        def call(i: int) -> None:
            status, body = self.post_json({
                "jsonrpc": "2.0", "id": 100 + i, "method": "tools/call",
                "params": {"name": "echo", "arguments": {"text": "t%d" % i}}})
            with lock:
                results.append((i, status, body))

        threads = [threading.Thread(target=call, args=(i,)) for i in range(8)]
        for t in threads:
            t.start()
        for t in threads:
            t.join(timeout=10)
        self.assertEqual(len(results), 8)
        for i, status, body in results:
            self.assertEqual(status, 200)
            self.assertIn("t%d" % i, body["result"]["content"][0]["text"])


if __name__ == "__main__":
    unittest.main(verbosity=2)


class TestSingleInstanceGuard(unittest.TestCase):
    """只允许一个 MCP 实例绑同一端口。

    背景（实测踩到）：`socketserver.TCPServer` 默认 `allow_reuse_address = 1`，
    而这个选项在 **Windows 上允许完全重复绑定**同一地址端口 —— 于是反复启动
    MCP 会留下多个实例同时绑着 `0.0.0.0:32128`，请求被不同实例接走，
    状态报告互相矛盾（一个报 tcp/已接通、另一个报 null/未接通），
    而每个响应单看都自洽，排查代价极高。
    """

    def test_server_disallows_address_reuse(self):
        from mcpcore.http_transport import build_http_server
        srv = build_http_server(None, "127.0.0.1", 0)
        try:
            self.assertFalse(srv.allow_reuse_address,
                             "必须关掉地址重用，否则 Windows 上会多实例共存")
        finally:
            srv.server_close()

    def test_second_bind_on_same_port_fails(self):
        """真正的判据：第二个实例要**绑不上**，而不是悄悄共存。"""
        from mcpcore.http_transport import build_http_server
        first = build_http_server(None, "127.0.0.1", 0)
        port = first.server_address[1]
        try:
            with self.assertRaises(OSError):
                build_http_server(None, "127.0.0.1", port)
        finally:
            first.server_close()
