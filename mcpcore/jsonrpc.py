#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""JSON-RPC 2.0 over stdio（MCP 的传输基础）。

MCP 的 stdio 传输有两种帧格式：
  1. 换行分隔的 JSON（本实现支持，也是 DSH 客户端走的那条）
  2. LSP 风格的 Content-Length 头（本实现也支持，为了兼容别的客户端）

读入时**自动判定**两种格式，写出时用换行分隔——这是最宽容的组合。
"""

from __future__ import annotations

import io
import json
import sys
from typing import Any, Optional

# JSON-RPC 2.0 标准错误码
PARSE_ERROR = -32700
INVALID_REQUEST = -32600
METHOD_NOT_FOUND = -32601
INVALID_PARAMS = -32602
INTERNAL_ERROR = -32603


class JsonRpcError(Exception):
    """带 JSON-RPC 错误码的异常；服务器据此构造 error 响应。"""

    def __init__(self, code: int, message: str, data: Any = None) -> None:
        super().__init__(message)
        self.code = code
        self.message = message
        self.data = data

    def to_dict(self) -> dict:
        out: dict[str, Any] = {"code": self.code, "message": self.message}
        if self.data is not None:
            out["data"] = self.data
        return out


def read_message(stream: io.BufferedReader) -> Optional[dict]:
    """读一条消息。EOF 返回 None。

    Content-Length 头与换行分隔两种帧自动识别：
    以 "Content-Length" 开头（大小写不敏感）即按 LSP 风格解析，
    否则按"读一整行当作一个 JSON 文档"解析。
    """
    first = stream.readline()
    while first in (b"\r\n", b"\n"):   # 跳过空行
        first = stream.readline()
    if not first:
        return None

    stripped = first.lstrip()
    if stripped[:14].lower() == b"content-length":
        try:
            length = int(stripped.split(b":", 1)[1].strip())
        except (IndexError, ValueError) as exc:
            raise JsonRpcError(PARSE_ERROR, "非法的 Content-Length 头") from exc
        # 吃掉其余头部直到空行
        while True:
            line = stream.readline()
            if not line or line in (b"\r\n", b"\n"):
                break
        body = stream.read(length)
        if len(body) < length:
            return None
        return _loads(body)

    return _loads(first)


def _loads(raw: bytes) -> dict:
    try:
        obj = json.loads(raw.decode("utf-8"))
    except UnicodeDecodeError as exc:
        raise JsonRpcError(PARSE_ERROR, "消息不是合法 UTF-8") from exc
    except json.JSONDecodeError as exc:
        raise JsonRpcError(PARSE_ERROR, f"非法的 JSON：{exc}") from exc
    if not isinstance(obj, dict):
        raise JsonRpcError(INVALID_REQUEST, "JSON-RPC 消息必须是对象")
    return obj


def write_message(payload: dict, stream: Optional[io.BufferedWriter] = None) -> None:
    """写一条消息（换行分隔）。"""
    out = stream if stream is not None else sys.stdout.buffer
    data = json.dumps(payload, ensure_ascii=False, separators=(",", ":"))
    out.write(data.encode("utf-8") + b"\n")
    out.flush()


def error_response(msg_id: Any, err: JsonRpcError) -> dict:
    return {"jsonrpc": "2.0", "id": msg_id, "error": err.to_dict()}


def result_response(msg_id: Any, result: Any) -> dict:
    return {"jsonrpc": "2.0", "id": msg_id, "result": result}
