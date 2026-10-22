#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""MCP Streamable HTTP 传输（仅标准库）。

## 为什么需要它

DSH 的 MCP 客户端支持两种传输：`stdio` 与 `streamable-http`。
`stdio` 要求 DSH 自己启动子进程——而本机 DSH 是 WSL 里的 Node 进程，
**WSL 的 Node 无法执行 Windows 程序**（`spawn` 返回 ENOENT，实测见
docs/decisions.md D14）。所以"在 Windows 侧跑 MCP"只能走 HTTP：
由**用户手动启动**服务端，DSH 作为 HTTP 客户端连过来。

实测的连通性依据（WSL2 NAT）：
  · WSL → Windows（服务端绑 0.0.0.0）  → **可达**（经 WSL 网关地址）
  · WSL → Windows（服务端只绑 127.0.0.1）→ 不可达
故服务端必须绑 0.0.0.0，且 DSH 侧用 WSL 的网关地址访问。

## 实现取舍

MCP 的 Streamable HTTP 允许服务端对 POST 直接回 JSON（不必开 SSE 流）。
本实现采用**无状态 JSON 响应**模式：一个 POST 进来、一个 JSON 出去，
不维持会话流。理由：本服务器的工具本身无跨请求会话状态（执行通道是
进程级的），无状态实现更简单、也更容易排查——出错时看到的就是一个普通 HTTP 请求。

支持：
    POST /mcp   JSON-RPC 请求 → JSON 响应；通知 → 202 无正文
    GET  /mcp   提示用 POST（未实现 SSE 推送：本服务器不主动推送）
    DELETE /mcp 会话终止 → 204
    GET  /health 简单存活探测（运维用，不属于 MCP 协议）
"""

from __future__ import annotations

import json
import sys
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from typing import Any

from .jsonrpc import JsonRpcError
from .server import Server

MCP_PATH = "/mcp"
HEALTH_PATH = "/health"
PROTOCOL_SESSION_HEADER = "Mcp-Session-Id"
MAX_BODY = 8 << 20      # 8MB：正常请求远小于此，防超大 body 打爆内存


class _Handler(BaseHTTPRequestHandler):
    server_version = "arma3-mcp/1.0"
    protocol_version = "HTTP/1.1"

    # 由工厂注入
    mcp_server: Server
    shared_session_id: str = ""
    quiet: bool = True

    def log_message(self, fmt: str, *args: Any) -> None:  # noqa: A003
        if not self.quiet:
            sys.stderr.write("[http] %s\n" % (fmt % args))

    # ---------------------------------------------------------------- 工具

    def _read_body(self) -> bytes | None:
        try:
            length = int(self.headers.get("Content-Length") or 0)
        except ValueError:
            return None
        if length <= 0 or length > MAX_BODY:
            return None
        return self.rfile.read(length)

    def _send_json(self, status: int, payload: dict | None,
                   extra: dict | None = None) -> None:
        body = b"" if payload is None else json.dumps(
            payload, ensure_ascii=False, separators=(",", ":")).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        # 允许带会话头；无状态模式下这个值恒定
        if self.shared_session_id:
            self.send_header(PROTOCOL_SESSION_HEADER, self.shared_session_id)
        for key, value in (extra or {}).items():
            self.send_header(key, value)
        self.end_headers()
        if body:
            self.wfile.write(body)

    # ---------------------------------------------------------------- 路由

    def do_GET(self) -> None:  # noqa: N802
        path = self.path.split("?", 1)[0]
        if path == HEALTH_PATH:
            self._send_json(200, {"ok": True, "server": "arma3-mcp"})
            return
        if path == MCP_PATH:
            # 本服务器不主动推送，因此不提供 SSE 流；明确告知而不是挂住连接
            self.send_response(405)
            self.send_header("Allow", "POST, DELETE")
            self.send_header("Content-Type", "text/plain; charset=utf-8")
            body = ("本服务器不使用 SSE 推送（工具为请求-响应式）。"
                    "请用 POST %s 发送 JSON-RPC 请求。\n" % MCP_PATH).encode("utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        self._send_json(404, {"error": "not found", "path": path})

    def do_DELETE(self) -> None:  # noqa: N802
        path = self.path.split("?", 1)[0]
        if path == MCP_PATH:
            self.send_response(204)
            self.send_header("Content-Length", "0")
            self.end_headers()
            return
        self._send_json(404, {"error": "not found", "path": path})

    def do_POST(self) -> None:  # noqa: N802
        path = self.path.split("?", 1)[0]
        if path != MCP_PATH:
            self._send_json(404, {"error": "not found", "path": path})
            return
        raw = self._read_body()
        if raw is None:
            self._send_json(400, {"jsonrpc": "2.0", "id": None,
                                  "error": {"code": -32700,
                                            "message": "请求体为空或过大"}})
            return
        try:
            msg = json.loads(raw.decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError) as exc:
            self._send_json(400, {"jsonrpc": "2.0", "id": None,
                                  "error": {"code": -32700,
                                            "message": "非法的 JSON：%s" % exc}})
            return
        if not isinstance(msg, dict):
            self._send_json(400, {"jsonrpc": "2.0", "id": None,
                                  "error": {"code": -32600,
                                            "message": "JSON-RPC 消息必须是对象"}})
            return

        # 先记下客户端声明的协议版本，供初始化协商
        if msg.get("method") == "initialize" and isinstance(msg.get("params"), dict):
            requested = msg["params"].get("protocolVersion")
            if isinstance(requested, str) and requested:
                self.mcp_server.protocol_version = requested

        try:
            response = self.mcp_server.handle(msg)
        except JsonRpcError as exc:
            self._send_json(400, {"jsonrpc": "2.0", "id": msg.get("id"),
                                  "error": exc.to_dict()})
            return

        if response is None:
            # 通知：MCP 规定返回 202 且无正文
            self.send_response(202)
            self.send_header("Content-Length", "0")
            self.end_headers()
            return
        self._send_json(200, response)


def build_http_server(server: Server, host: str, port: int,
                      session_id: str = "arma3-mcp",
                      quiet: bool = True) -> ThreadingHTTPServer:
    """构造（但未启动）HTTP 服务器。调用方负责 serve_forever。"""
    handler = type("Arma3McpHandler", (_Handler,), {
        "mcp_server": server,
        "shared_session_id": session_id,
        "quiet": quiet,
    })
    httpd = ThreadingHTTPServer((host, port), handler)
    httpd.daemon_threads = True
    return httpd


def serve_http(server: Server, host: str, port: int,
               session_id: str = "arma3-mcp") -> int:
    """阻塞式运行 HTTP 传输。"""
    try:
        httpd = build_http_server(server, host, port, session_id)
    except OSError as exc:
        print("监听 %s:%d 失败：%s" % (host, port, exc), file=sys.stderr)
        print("（常见原因：端口被占用，或该端口已被其它程序监听。）",
              file=sys.stderr)
        return 2
    actual_host, actual_port = httpd.server_address[:2]
    print("arma3-mcp HTTP 传输已启动：http://%s:%d%s"
          % (actual_host, actual_port, MCP_PATH))
    print("  健康探测：http://%s:%d%s" % (actual_host, actual_port, HEALTH_PATH))
    if host in ("0.0.0.0", "::"):
        print("  监听 0.0.0.0：这是**必需**的——若只绑 127.0.0.1，")
        print("  WSL 里的 DSH 将无法连入（实测：NAT 且只绑回环时不可达）。")
    print("  DSH 侧的 url 应填 WSL 网关地址（见 docs/deploy.md）。")
    sys.stdout.flush()
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n收到中断，退出。")
    finally:
        httpd.shutdown()
    return 0
