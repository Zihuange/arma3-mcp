#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""模拟游戏侧扩展 DLL 的测试客户端。

为什么需要它：真实 DLL 要在 Windows 编译 + 上机才能验证，而通道层的正确性
（握手、回执配对、超时、断线、静默）**完全可以在本机验证**。把这两件事分开，
上机时只需要面对"引擎语义"这一层风险，而不是同时debug网络与协议。

它模拟 DLL 的行为：
  · 主动连到 MCP（方向与真实 DLL 一致）
  · 发 hello 握手（带 token / pid / poll 周期）
  · 收 cmd → 按规则产生回执：正常 / 失败 / 不回应 / 慢回应
  · 定期上报队列水位、推送事件行
  · 可被要求立即断开（验证 MCP 侧对断线的处理）
"""

from __future__ import annotations

import json
import socket
import threading
import time
from typing import Any, Callable, Optional


class FakeGame:
    """一个假游戏连接。默认对任何命令回 ok=true 并回显参数。"""

    def __init__(self, host: str = "127.0.0.1", port: int = 32123,
                 token: str = "arma3-mcp-local", pid: int = 4242,
                 ver: str = "fake-1.0", poll_ms: int = 500) -> None:
        self.host = host
        self.port = port
        self.token = token
        self.pid = pid
        self.ver = ver
        self.poll_ms = poll_ms

        self.sock: Optional[socket.socket] = None
        self.received: list[dict] = []          # 收到的全部消息
        self.commands: list[dict] = []          # 仅 cmd
        self.handshake_reply: Optional[dict] = None
        self.handshake_ok = False
        self._stop = threading.Event()
        self._thread: Optional[threading.Thread] = None
        self._send_lock = threading.Lock()

        # 可注入的行为：cmd 名 -> 处理函数 (cmd_msg) -> dict | None
        #   返回 dict 当作回执；返回 None 表示**故意不回应**（验证超时路径）
        self.handlers: dict[str, Callable[[dict], dict | None]] = {}
        self.default_delay = 0.0                # 每条命令的模拟处理耗时
        self.auto_reply = True

    # ---------------------------------------------------------------- 连接

    def connect(self) -> bool:
        try:
            sock = socket.create_connection((self.host, self.port), timeout=5)
        except OSError:
            return False
        sock.settimeout(0.5)
        self.sock = sock
        self._send({"t": "hello", "token": self.token, "pid": self.pid,
                    "ver": self.ver, "poll_ms": self.poll_ms})
        # 等 hello_ack
        deadline = time.time() + 5
        buf = b""
        while time.time() < deadline:
            try:
                chunk = sock.recv(4096)
            except socket.timeout:
                continue
            except OSError:
                return False
            if not chunk:
                return False
            buf += chunk
            if b"\n" in buf:
                raw, _ = buf.split(b"\n", 1)
                try:
                    msg = json.loads(raw.decode("utf-8"))
                except Exception:  # noqa: BLE001
                    return False
                self.handshake_reply = msg
                self.handshake_ok = bool(msg.get("ok", msg.get("t") == "hello_ack"))
                break
        if not self.handshake_ok:
            return False
        self._thread = threading.Thread(target=self._loop, name="fake-game",
                                        daemon=True)
        self._thread.start()
        return True

    def _send(self, payload: dict) -> None:
        if self.sock is None:
            return
        data = (json.dumps(payload, ensure_ascii=False,
                           separators=(",", ":")) + "\n").encode("utf-8")
        with self._send_lock:
            self.sock.sendall(data)

    def _loop(self) -> None:
        assert self.sock is not None
        buf = b""
        while not self._stop.is_set():
            try:
                chunk = self.sock.recv(65536)
            except socket.timeout:
                continue
            except OSError:
                break
            if not chunk:
                break
            buf += chunk
            while b"\n" in buf:
                raw, buf = buf.split(b"\n", 1)
                if not raw.strip():
                    continue
                try:
                    msg = json.loads(raw.decode("utf-8"))
                except Exception:  # noqa: BLE001
                    continue
                self.received.append(msg)
                if msg.get("t") == "cmd":
                    self.commands.append(msg)
                    self._handle_cmd(msg)

    def _handle_cmd(self, msg: dict) -> None:
        cid = str(msg.get("cid") or "")
        cmd = str(msg.get("cmd") or "")
        handler = self.handlers.get(cmd)
        if handler is not None:
            result = handler(msg)
            if result is None:
                return                       # 故意不回应
            self._send(dict({"t": "ack", "cid": cid}, **result))
            return
        if not self.auto_reply:
            return
        if self.default_delay:
            time.sleep(self.default_delay)
        self._send({"t": "ack", "cid": cid, "ok": True,
                    "result": {"echo": cmd, "args": msg.get("args")}})

    # ---------------------------------------------------------------- 主动行为

    def push_event(self, line: str) -> None:
        self._send({"t": "event", "line": line})

    def report_queue(self, depth: int, dropped: int = 0) -> None:
        self._send({"t": "queue", "depth": depth, "dropped": dropped})

    def wait_commands(self, count: int, timeout: float = 5.0) -> bool:
        deadline = time.time() + timeout
        while time.time() < deadline:
            if len(self.commands) >= count:
                return True
            time.sleep(0.02)
        return len(self.commands) >= count

    def kill(self) -> None:
        """立即断开（不打招呼），验证 MCP 侧的断线处理。"""
        self._stop.set()
        if self.sock is not None:
            try:
                self.sock.close()
            except OSError:
                pass
            self.sock = None

    def close(self) -> None:
        self._stop.set()
        if self.sock is not None:
            try:
                self.sock.close()
            except OSError:
                pass
            self.sock = None


def ok_handler(result: Any = None) -> Callable[[dict], dict]:
    def handler(msg: dict) -> dict:
        return {"ok": True, "result": result if result is not None
                else {"echo": msg.get("cmd")}}
    return handler


def fail_handler(error: str = "模拟失败") -> Callable[[dict], dict]:
    def handler(_msg: dict) -> dict:
        return {"ok": False, "error": error}
    return handler


def silent_handler() -> Callable[[dict], None]:
    """故意不回应：用于验证超时路径。"""
    def handler(_msg: dict) -> None:
        return None
    return handler
