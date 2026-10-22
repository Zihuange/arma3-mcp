#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""mcpcore —— 零依赖的 MCP stdio 骨架。

为什么手写而不是用官方 SDK：
  · 本仓库的硬约束是"仅标准库"（要能在任何只装了 Python 的机器上跑，
    包括 Windows 侧的 Anaconda）；装 SDK 就多一条 pip 依赖链。
  · MCP 的 stdio 面很小：initialize / tools/list / tools/call /
    notifications 收尾。实测不到 200 行，维护成本低于依赖成本。

分包：
  jsonrpc.py  —— 帧读写与 JSON-RPC 2.0 错误码
  schema.py   —— 工具输入 schema 的轻量校验（type/enum/required/anyOf/items）
  registry.py —— 工具注册表（本仓库是唯一工具源，无动态发现）
  server.py   —— 主循环与 MCP 方法分发
"""

from .jsonrpc import (  # noqa: F401
    PARSE_ERROR, INVALID_REQUEST, METHOD_NOT_FOUND, INVALID_PARAMS, INTERNAL_ERROR,
    JsonRpcError, read_message, write_message,
)
from .registry import Tool, ToolResult, Registry  # noqa: F401
from .server import Server  # noqa: F401

__all__ = [
    "PARSE_ERROR", "INVALID_REQUEST", "METHOD_NOT_FOUND", "INVALID_PARAMS",
    "INTERNAL_ERROR", "JsonRpcError", "read_message", "write_message",
    "Tool", "ToolResult", "Registry", "Server",
]
