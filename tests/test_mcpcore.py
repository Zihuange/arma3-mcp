#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""MCP 协议层测试：帧读写、分发、错误码、异常隔离。"""

from __future__ import annotations

import io
import json
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from mcpcore import (  # noqa: E402
    INVALID_PARAMS, METHOD_NOT_FOUND, PARSE_ERROR, JsonRpcError, Registry,
    Server, read_message, write_message,
)
from mcpcore.registry import ToolResult  # noqa: E402


def reg_with_tools() -> Registry:
    reg = Registry()

    @reg.tool(name="echo", description="回显", input_schema={
        "type": "object",
        "properties": {"text": {"type": "string"}},
        "required": ["text"],
    })
    def _echo(args: dict) -> ToolResult:
        return ToolResult.ok("echo: " + args["text"])

    @reg.tool(name="boom", description="总是抛异常")
    def _boom(_args: dict) -> ToolResult:
        raise RuntimeError("炸弹")

    return reg


class TestFraming(unittest.TestCase):
    def test_newline_framed(self):
        stream = io.BytesIO(b'{"a":1}\n{"b":2}\n')
        self.assertEqual(read_message(stream), {"a": 1})
        self.assertEqual(read_message(stream), {"b": 2})
        self.assertIsNone(read_message(stream))

    def test_content_length_framed(self):
        body = json.dumps({"jsonrpc": "2.0", "id": 1}).encode()
        stream = io.BytesIO(b"Content-Length: %d\r\n\r\n" % len(body) + body)
        self.assertEqual(read_message(stream), {"jsonrpc": "2.0", "id": 1})

    def test_blank_lines_skipped(self):
        stream = io.BytesIO(b"\n\n\r\n" + b'{"x":1}\n')
        self.assertEqual(read_message(stream), {"x": 1})

    def test_bad_json_raises_parse_error(self):
        stream = io.BytesIO(b"not json\n")
        with self.assertRaises(JsonRpcError) as ctx:
            read_message(stream)
        self.assertEqual(ctx.exception.code, PARSE_ERROR)

    def test_non_object_is_invalid(self):
        with self.assertRaises(JsonRpcError):
            read_message(io.BytesIO(b"[1,2,3]\n"))

    def test_write_message_is_newline_terminated(self):
        buf = io.BytesIO()
        write_message({"jsonrpc": "2.0", "id": 1}, buf)
        self.assertTrue(buf.getvalue().endswith(b"\n"))
        self.assertEqual(json.loads(buf.getvalue()), {"jsonrpc": "2.0", "id": 1})


class TestDispatch(unittest.TestCase):
    def setUp(self):
        self.server = Server(reg_with_tools())

    def test_initialize_echoes_protocol_version(self):
        resp = self.server.handle({
            "jsonrpc": "2.0", "id": 1, "method": "initialize",
            "params": {"protocolVersion": "2025-03-26"},
        })
        self.assertEqual(resp["result"]["protocolVersion"], "2025-03-26")
        self.assertIn("tools", resp["result"]["capabilities"])

    def test_initialize_defaults_when_absent(self):
        resp = self.server.handle({"jsonrpc": "2.0", "id": 1,
                                   "method": "initialize", "params": {}})
        self.assertTrue(resp["result"]["protocolVersion"])

    def test_tools_list(self):
        resp = self.server.handle({"jsonrpc": "2.0", "id": 2, "method": "tools/list"})
        names = [t["name"] for t in resp["result"]["tools"]]
        self.assertIn("echo", names)
        for tool in resp["result"]["tools"]:
            self.assertIn("inputSchema", tool)
            self.assertTrue(tool["description"])

    def test_notification_gets_no_response(self):
        self.assertIsNone(self.server.handle({
            "jsonrpc": "2.0", "method": "notifications/initialized"}))

    def test_unknown_method(self):
        resp = self.server.handle({"jsonrpc": "2.0", "id": 3, "method": "nope"})
        self.assertEqual(resp["error"]["code"], METHOD_NOT_FOUND)

    def test_resources_and_prompts_are_empty_not_error(self):
        for method in ("resources/list", "prompts/list"):
            resp = self.server.handle({"jsonrpc": "2.0", "id": 4, "method": method})
            self.assertIn("result", resp)

    def test_bad_params_type(self):
        resp = self.server.handle({"jsonrpc": "2.0", "id": 5,
                                   "method": "tools/call", "params": [1]})
        self.assertEqual(resp["error"]["code"], INVALID_PARAMS)

    def test_call_missing_name(self):
        resp = self.server.handle({"jsonrpc": "2.0", "id": 6,
                                   "method": "tools/call", "params": {}})
        self.assertEqual(resp["error"]["code"], INVALID_PARAMS)

    def test_unknown_tool_is_error_result_not_crash(self):
        resp = self.server.handle({
            "jsonrpc": "2.0", "id": 7, "method": "tools/call",
            "params": {"name": "nope", "arguments": {}}})
        self.assertTrue(resp["result"]["isError"])
        self.assertIn("未知工具", resp["result"]["content"][0]["text"])

    def test_tool_exception_becomes_error_result(self):
        resp = self.server.handle({
            "jsonrpc": "2.0", "id": 8, "method": "tools/call",
            "params": {"name": "boom", "arguments": {}}})
        self.assertTrue(resp["result"]["isError"])
        self.assertIn("炸弹", resp["result"]["content"][0]["text"])

    def test_schema_violation_is_reported_readably(self):
        resp = self.server.handle({
            "jsonrpc": "2.0", "id": 9, "method": "tools/call",
            "params": {"name": "echo", "arguments": {"text": 5}}})
        self.assertTrue(resp["result"]["isError"])
        self.assertIn("参数校验失败", resp["result"]["content"][0]["text"])

    def test_missing_required_field(self):
        resp = self.server.handle({
            "jsonrpc": "2.0", "id": 10, "method": "tools/call",
            "params": {"name": "echo", "arguments": {}}})
        self.assertTrue(resp["result"]["isError"])
        self.assertIn("text", resp["result"]["content"][0]["text"])

    def test_serve_loop_survives_garbage(self):
        """喂入垃圾 + 正常请求，服务器必须继续工作（长期驻留要求）。"""
        inbox = io.BytesIO(
            b'this is not json\n'
            b'{"jsonrpc":"2.0","id":1,"method":"tools/list"}\n'
            b'{"jsonrpc":"2.0","id":2,"method":"tools/call","params":{"name":"boom","arguments":{}}}\n'
            b'{"jsonrpc":"2.0","id":3,"method":"tools/list"}\n')
        outbox = io.BytesIO()
        rc = self.server.serve(inbox, outbox)  # type: ignore[arg-type]
        self.assertEqual(rc, 0)
        lines = [json.loads(l) for l in outbox.getvalue().splitlines() if l.strip()]
        ids = [l.get("id") for l in lines]
        self.assertIn(3, ids, "垃圾消息后的请求必须仍被处理")
        self.assertEqual(lines[0]["error"]["code"], PARSE_ERROR)


class TestSchemaHelpers(unittest.TestCase):
    def test_type_union_and_null(self):
        from mcpcore.schema import SchemaError, validate
        schema = {"type": "object",
                  "properties": {"x": {"type": ["number", "null"]}}}
        validate({"x": None}, schema)
        validate({"x": 1.5}, schema)
        validate({"x": 3}, schema)
        with self.assertRaises(SchemaError):
            validate({"x": "3"}, schema)

    def test_bool_is_not_integer(self):
        from mcpcore.schema import SchemaError, validate
        with self.assertRaises(SchemaError):
            validate(True, {"type": "integer"})
        validate(True, {"type": "boolean"})

    def test_enum_and_bounds(self):
        from mcpcore.schema import SchemaError, validate
        validate("a", {"enum": ["a", "b"]})
        with self.assertRaises(SchemaError):
            validate("c", {"enum": ["a", "b"]})
        validate(5, {"type": "integer", "minimum": 1, "maximum": 10})
        with self.assertRaises(SchemaError):
            validate(11, {"type": "integer", "maximum": 10})

    def test_anyof_and_additional_properties(self):
        from mcpcore.schema import SchemaError, validate
        validate([1], {"anyOf": [{"type": "array"}, {"type": "null"}]})
        with self.assertRaises(SchemaError):
            validate({"a": 1}, {"type": "object", "additionalProperties": False,
                                "properties": {}})

    def test_nested_items(self):
        from mcpcore.schema import SchemaError, validate
        schema = {"type": "array", "items": {"type": "number"}}
        validate([1, 2.5], schema)
        with self.assertRaises(SchemaError):
            validate([1, "x"], schema)


if __name__ == "__main__":
    unittest.main(verbosity=2)
