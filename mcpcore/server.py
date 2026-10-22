#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""MCP 服务器主循环。

只实现本仓库需要的那部分 MCP 语义，并且**明确不实现**资源（resources）与
提示（prompts）——DSH 的客户端不桥接它们（其源码只处理 ToolListChanged），
实现了也没人用，反而增加出错面。

不变量：
  · 任何异常都不得杀死主循环（工具内部错误 → isError 结果；协议级错误 →
    JSON-RPC error 响应）。长期驻留是 MCP server 的基本要求。
  · 通知（无 id）绝不产生响应——发了会被某些客户端判定为协议违规。
"""

from __future__ import annotations

import json
import sys
import traceback
from typing import Any, BinaryIO, Optional

from .jsonrpc import (
    INTERNAL_ERROR,
    INVALID_PARAMS,
    INVALID_REQUEST,
    METHOD_NOT_FOUND,
    JsonRpcError,
    error_response,
    read_message,
    result_response,
    write_message,
)
from .registry import Registry

PROTOCOL_VERSION = "2024-11-05"
SERVER_NAME = "arma3-mcp"
SERVER_VERSION = "0.1.0"


class Server:
    def __init__(self, registry: Registry, name: str = SERVER_NAME,
                 version: str = SERVER_VERSION,
                 instructions: Optional[str] = None) -> None:
        self.registry = registry
        self.name = name
        self.version = version
        self.instructions = instructions
        self._initialized = False
        # 协议版本：与客户端协商。HTTP 传输可以在 initialize 之前先设置它
        # （见 http_transport 的先读后分发），stdio 则用 initialize 的入参。
        self.protocol_version = PROTOCOL_VERSION
        self.stats = {"received": 0, "calls": 0, "errors": 0}

    # ---------------------------------------------------------------- MCP 方法

    def _initialize(self, params: dict) -> dict:
        client_version = (params.get("protocolVersion")
                          or self.protocol_version or PROTOCOL_VERSION)
        self._initialized = True
        result: dict[str, Any] = {
            # 回显客户端版本：双方协商，回显比硬塞自己的版本更安全
            "protocolVersion": client_version,
            "capabilities": {"tools": {"listChanged": False}},
            "serverInfo": {"name": self.name, "version": self.version},
        }
        if self.instructions:
            result["instructions"] = self.instructions
        return result

    def _tools_list(self) -> dict:
        return {"tools": self.registry.list_mcp()}

    def _tools_call(self, params: dict) -> dict:
        name = params.get("name")
        if not isinstance(name, str) or not name:
            raise JsonRpcError(INVALID_PARAMS, "tools/call 需要字符串参数 name")
        self.stats["calls"] += 1
        result = self.registry.call(name, params.get("arguments"))
        if result.is_error:
            self.stats["errors"] += 1
        return result.to_mcp()

    # ---------------------------------------------------------------- 分发

    def handle(self, msg: dict) -> Optional[dict]:
        """处理一条消息。返回响应字典；通知返回 None。"""
        if msg.get("jsonrpc") not in (None, "2.0"):
            return error_response(msg.get("id"),
                                  JsonRpcError(INVALID_REQUEST,
                                               "jsonrpc 字段必须是 \"2.0\""))
        method = msg.get("method")
        msg_id = msg.get("id")
        is_notification = "id" not in msg or msg_id is None

        if not isinstance(method, str):
            if is_notification:
                return None
            return error_response(msg_id,
                                  JsonRpcError(INVALID_REQUEST, "缺少 method 字段"))

        params = msg.get("params")
        if params is None:
            params = {}
        if not isinstance(params, dict):
            if is_notification:
                return None
            return error_response(msg_id, JsonRpcError(
                INVALID_PARAMS, "params 必须是对象"))

        # ---- 通知：一律不响应 ----
        if is_notification:
            return None

        try:
            if method == "initialize":
                return result_response(msg_id, self._initialize(params))
            if method == "ping":
                return result_response(msg_id, {})
            if method == "tools/list":
                return result_response(msg_id, self._tools_list())
            if method == "tools/call":
                return result_response(msg_id, self._tools_call(params))
            if method in ("resources/list", "resources/templates/list"):
                # 明确不支持：给空表比给错误更友好（部分客户端会无条件探测）
                return result_response(msg_id, {"resources": []})
            if method == "prompts/list":
                return result_response(msg_id, {"prompts": []})
            return error_response(msg_id, JsonRpcError(
                METHOD_NOT_FOUND, f"不支持的方法：{method}"))
        except JsonRpcError as exc:
            self.stats["errors"] += 1
            return error_response(msg_id, exc)
        except Exception as exc:  # noqa: BLE001
            self.stats["errors"] += 1
            return error_response(msg_id, JsonRpcError(
                INTERNAL_ERROR, f"内部错误：{type(exc).__name__}: {exc}",
                data=traceback.format_exc(limit=5)))

    # ---------------------------------------------------------------- 主循环

    def serve(self, stdin: Optional[BinaryIO] = None,
              stdout: Optional[BinaryIO] = None,
              stderr: Optional[BinaryIO] = None) -> int:
        inp = stdin if stdin is not None else sys.stdin.buffer
        out = stdout if stdout is not None else sys.stdout.buffer

        while True:
            try:
                msg = read_message(inp)  # type: ignore[arg-type]
            except JsonRpcError as exc:
                write_message(error_response(None, exc), out)  # type: ignore[arg-type]
                continue
            if msg is None:
                return 0
            self.stats["received"] += 1
            response = self.handle(msg)
            if response is not None:
                write_message(response, out)  # type: ignore[arg-type]


def main(registry: Registry, name: str = SERVER_NAME,
         version: str = SERVER_VERSION,
         instructions: Optional[str] = None) -> int:
    """给 servers/*.py 用的入口包装：任何崩溃都转成可读的 stderr 信息 + 非零码。"""
    server = Server(registry, name=name, version=version,
                    instructions=instructions)
    try:
        return server.serve()
    except KeyboardInterrupt:
        return 0
    except Exception as exc:  # noqa: BLE001
        print(f"[{name}] 致命错误：{type(exc).__name__}: {exc}",
              file=sys.stderr)
        traceback.print_exc(file=sys.stderr)
        return 1
