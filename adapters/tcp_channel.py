#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""TCP 执行通道：MCP 侧做**服务端**，游戏进程内的扩展 DLL 主动连回来。

## 为什么方向是这样（这条是实测决定的，不是设计偏好）

本机实测（WSL2 NAT 模式）：

| 方向 | 结果 |
|---|---|
| WSL → Windows 的 `127.0.0.1` | **连不上**（Connection refused） |
| WSL → Windows 的局域网 IP | 连不上（NAT 网关只转发到 WSL，不反向） |
| Windows → WSL 的 IP | **能连**（实测成功，源地址是网关 192.168.160.1） |

而 DSH 侧（MCP 服务器）跑在 WSL 里，游戏跑在 Windows 里。所以只有
"游戏连回 MCP"这一条路走得通。

原本计划用 Windows 命名管道，同样被两条事实否掉：
  1. 方向问题依旧（管道也必须由游戏侧发起）；
  2. WSL 侧的 Python 根本访问不到 Windows 命名管道
     （`multiprocessing.connection` 的管道地址只在 Windows 上有效，
     而 MCP 服务器不在 Windows 上）。
TCP 则是两边都原生支持、且已被上面的实测证明可行。

## 协议（换行分隔 JSON，UTF-8）

游戏 → MCP：
    {"t":"hello","token":"...","pid":1234,"ver":"1.0","poll_ms":500}
    {"t":"ack","cid":"c123","ok":true,"result":<任意>}
    {"t":"ack","cid":"c123","ok":false,"error":"..."}
    {"t":"event","line":"status:alpha:..."}          # SQF 上行事件原样转发
    {"t":"queue","depth":3,"dropped":0}              # 下行队列水位（可选）

MCP → 游戏：
    {"t":"hello_ack","ver":1,"server":"arma3-mcp"}
    {"t":"cmd","cid":"c123","cmd":"setPosATL","args":[...]}

## 不变量

  · 单个活跃连接：新连接到来即替换旧连接（本地单机只有一个游戏实例；
    多实例在 P3 用显式 instance id 区分）。
  · 发送是**同步**的：调用方拿到回执或超时。超时不是异常，而是结构化结果。
  · 回执按 cid 配对；配对不上的回执被记录但不影响其它请求。
"""

from __future__ import annotations

import json
import os
import socket
import sys
import threading
import time
from dataclasses import dataclass, field
from typing import Any, Optional

from .channel import Channel, Reply, new_cid

DEFAULT_PORT = 32123
PROTOCOL_VERSION = 1
MAX_LINE = 1 << 20              # 单行上限 1MB，防御性
DEFAULT_TOKEN = "arma3-mcp-local"


@dataclass
class Pending:
    cid: str
    event: threading.Event = field(default_factory=threading.Event)
    reply: Optional[Reply] = None
    sent_at: float = 0.0


class GameConnection:
    """一个已握手的游戏连接。"""

    def __init__(self, sock: socket.socket, addr: tuple) -> None:
        self.sock = sock
        self.addr = addr
        self.pid: Optional[int] = None
        self.version = ""
        self.poll_ms = 0
        self.connected_at = time.time()
        self.last_recv_at = time.time()
        self.queue_depth = 0
        self.dropped = 0
        self.events: list[str] = []
        self._events_lock = threading.Lock()
        self._send_lock = threading.Lock()
        self.closed = False

    def send(self, payload: dict) -> None:
        line = json.dumps(payload, ensure_ascii=False,
                          separators=(",", ":")) + "\n"
        data = line.encode("utf-8")
        with self._send_lock:
            if self.closed:
                raise OSError("连接已关闭")
            self.sock.sendall(data)

    def push_event(self, line: str) -> None:
        with self._events_lock:
            self.events.append(line)
            if len(self.events) > 2000:      # 环形上限，防内存无界增长
                del self.events[:len(self.events) - 2000]

    def drain_events(self) -> list[str]:
        with self._events_lock:
            out = list(self.events)
            self.events.clear()
        return out

    def info(self) -> dict:
        return {
            "addr": "%s:%s" % self.addr,
            "pid": self.pid,
            "version": self.version,
            "poll_ms": self.poll_ms,
            "connected_s": round(time.time() - self.connected_at, 1),
            "last_recv_s": round(time.time() - self.last_recv_at, 1),
            "queue_depth": self.queue_depth,
            "dropped": self.dropped,
        }


class TcpChannel(Channel):
    """MCP 侧的 TCP 服务端通道。"""

    name = "tcp"

    def __init__(self, host: str = "0.0.0.0", port: int = DEFAULT_PORT,
                 token: str = DEFAULT_TOKEN,
                 default_timeout: float = 5.0) -> None:
        self.host = host
        self.port = port
        self.token = token
        self.default_timeout = default_timeout
        self.conn: Optional[GameConnection] = None
        self._conn_lock = threading.RLock()
        self._pending: dict[str, Pending] = {}
        self._pending_lock = threading.Lock()
        self._server: Optional[socket.socket] = None
        self._threads: list[threading.Thread] = []
        self._stop = threading.Event()
        self.started = False
        self.start_error = ""
        # 统计：用于 gates_status 暴露真实状况
        self.stats = {"connections": 0, "commands_sent": 0, "timeouts": 0,
                      "errors": 0, "unmatched_acks": 0}

    # ---------------------------------------------------------------- 生命周期

    def start(self) -> bool:
        if self.started:
            return True
        srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            # ⚠ 跨平台差异：Windows 上 SO_REUSEADDR 的语义与 Unix 相反——
            # 它允许**另一个进程绑同一端口**并静默抢走连接（实测：测试里
            # "端口被占用应报错"在 Windows 上失败）。故 Windows 用
            # SO_EXCLUSIVEADDRUSE（独占绑定），Unix 侧才用 SO_REUSEADDR
            # （避免 TIME_WAIT 期间无法重启）。
            if hasattr(socket, "SO_EXCLUSIVEADDRUSE"):
                srv.setsockopt(socket.SOL_SOCKET, socket.SO_EXCLUSIVEADDRUSE, 1)
            else:
                srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            srv.bind((self.host, self.port))
            srv.listen(4)
            srv.settimeout(0.5)
        except OSError as exc:
            # 失败时必须关掉这个 socket：否则每次重试都漏一个 fd
            # （测试里出现的 ResourceWarning 就是这个泄漏的症状）
            try:
                srv.close()
            except OSError:
                pass
            self.start_error = ("监听 %s:%d 失败：%s"
                               % (self.host, self.port, exc))
            return False
        self._server = srv
        self.started = True
        t = threading.Thread(target=self._accept_loop, name="arma3-accept",
                             daemon=True)
        t.start()
        self._threads.append(t)
        return True

    def stop(self) -> None:
        self._stop.set()
        with self._conn_lock:
            if self.conn is not None:
                try:
                    self.conn.sock.close()
                except OSError:
                    pass
                self.conn.closed = True
                self.conn = None
        if self._server is not None:
            try:
                self._server.close()
            except OSError:
                pass
        self.started = False

    def connected(self) -> bool:
        with self._conn_lock:
            return self.conn is not None and not self.conn.closed

    def info(self) -> dict:
        with self._conn_lock:
            conn = self.conn
        out: dict[str, Any] = {
            "channel": self.name,
            "connected": self.connected(),
            "listen": "%s:%d" % (self.host, self.port),
            "started": self.started,
            "stats": dict(self.stats),
        }
        if self.start_error:
            out["reason"] = self.start_error
        elif conn is None:
            out["reason"] = ("还没有游戏连接。请在游戏侧加载 arma3-mcp 扩展"
                             "（它会主动连到本服务器的 %s:%d）。"
                             % (self.host, self.port))
        else:
            out["game"] = conn.info()
        return out

    # ---------------------------------------------------------------- 收连接

    def _accept_loop(self) -> None:
        assert self._server is not None
        while not self._stop.is_set():
            try:
                sock, addr = self._server.accept()
            except socket.timeout:
                continue
            except OSError:
                break
            t = threading.Thread(target=self._serve_conn, args=(sock, addr),
                                 name="arma3-conn", daemon=True)
            t.start()
            self._threads.append(t)

    def _serve_conn(self, sock: socket.socket, addr: tuple) -> None:
        sock.settimeout(1.0)
        buf = b""
        conn = GameConnection(sock, addr)
        self._trace("accept", "来自 %s:%s 的连接" % addr)

        # ---- 握手：第一条消息必须是 hello 且 token 正确 ----
        if not self._handshake(conn, sock):
            try:
                sock.close()
            except OSError:
                pass
            return

        self.stats["connections"] += 1
        with self._conn_lock:
            old = self.conn
            self.conn = conn
        if old is not None and not old.closed:
            # 新连接替换旧连接（本地单机只有一个游戏实例）
            try:
                old.sock.close()
            except OSError:
                pass
            old.closed = True

        while not self._stop.is_set() and not conn.closed:
            try:
                chunk = sock.recv(65536)
            except socket.timeout:
                continue
            except OSError:
                break
            if not chunk:
                break
            # 收到原始字节的现场记录：用于区分"对端没发"与"发了但解析失败"
            self._trace("recv", "%d bytes: %s"
                        % (len(chunk), chunk[:150].decode("utf-8", "replace")))
            buf += chunk
            while b"\n" in buf:
                raw, buf = buf.split(b"\n", 1)
                if not raw.strip():
                    continue
                if len(raw) > MAX_LINE:
                    continue
                try:
                    msg = json.loads(raw.decode("utf-8"))
                except (UnicodeDecodeError, json.JSONDecodeError):
                    self.stats["errors"] += 1
                    continue
                conn.last_recv_at = time.time()
                self._handle(conn, msg)

        conn.closed = True
        with self._conn_lock:
            if self.conn is conn:
                self.conn = None
        try:
            sock.close()
        except OSError:
            pass
        # 断线时让所有等待中的请求立即失败，而不是各自超时
        self._fail_all_pending("游戏连接已断开")

    def _handshake(self, conn: GameConnection, sock: socket.socket) -> bool:
        # 握手失败是最隐蔽的一类故障：DLL 连上了、但没有完成 hello，
        # 于是 MCP 侧表现为"从未连接"，而游戏侧毫无察觉。故把失败原因记下来。
        self._trace("handshake", "开始（等待 hello，5s 超时）")
        deadline = time.time() + 5.0
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
            if b"\n" not in buf:
                continue
            raw, _ = buf.split(b"\n", 1)
            try:
                msg = json.loads(raw.decode("utf-8"))
            except Exception:  # noqa: BLE001
                return False
            if msg.get("t") != "hello":
                self._trace("handshake", "首条消息不是 hello：%s" % str(msg)[:120])
                return False
            if self.token and msg.get("token") != self.token:
                self._trace("handshake", "token 不匹配（DLL 的 %r）"
                            % str(msg.get("token"))[:40])
                try:
                    conn.send({"t": "hello_ack", "ok": False,
                               "error": "token 不匹配"})
                except OSError:
                    pass
                return False
            self._trace("handshake", "成功 pid=%s ver=%s" % (msg.get("pid"), msg.get("ver")))
            conn.pid = msg.get("pid")
            conn.version = str(msg.get("ver") or "")
            conn.poll_ms = int(msg.get("poll_ms") or 0)
            try:
                conn.send({"t": "hello_ack", "ver": PROTOCOL_VERSION,
                           "server": "arma3-mcp",
                           "note": "命令以 {\"t\":\"cmd\"} 下发；回执用 "
                                   "{\"t\":\"ack\"}，须带同一 cid"})
            except OSError:
                return False
            return True
        return False

    # ---------------------------------------------------------------- 收消息

    def _trace(self, direction: str, payload) -> None:
        """可选诊断：ALC_TRACE=1 时把消息流记到 stderr。

        为什么需要：排查"命令发出去了但游戏没反应"时，必须能分开
        "MCP 没送到" / "DLL 没回" / "SQF 没执行"三种情况。默认关闭，
        因为它会刷屏；只在定位链路问题时打开。
        """
        if not os.environ.get("ALC_TRACE"):
            return
        text = payload if isinstance(payload, str) else json.dumps(
            payload, ensure_ascii=False)[:300]
        sys.stderr.write("[trace %s] %s\n" % (direction, text[:300]))
        sys.stderr.flush()

    def _handle(self, conn: GameConnection, msg: dict) -> None:
        self._trace("game->mcp", msg)
        kind = msg.get("t")
        if kind == "ack":
            cid = str(msg.get("cid") or "")
            with self._pending_lock:
                pending = self._pending.pop(cid, None)
            if pending is None:
                self.stats["unmatched_acks"] += 1
                return
            ok = bool(msg.get("ok"))
            pending.reply = Reply(
                ok=ok, cid=cid,
                result=msg.get("result"),
                error="" if ok else str(msg.get("error") or "游戏侧报告失败"),
                raw=json.dumps(msg, ensure_ascii=False)[:2000],
                elapsed_ms=int((time.time() - pending.sent_at) * 1000),
                channel=self.name)
            pending.event.set()
            return
        if kind == "event":
            conn.push_event(str(msg.get("line") or ""))
            return
        if kind == "queue":
            conn.queue_depth = int(msg.get("depth") or 0)
            conn.dropped = int(msg.get("dropped") or 0)
            return
        if kind == "pong":
            return
        self.stats["errors"] += 1

    # ---------------------------------------------------------------- 发命令

    def send(self, payload: dict, timeout_s: Optional[float] = None,
             cid: Optional[str] = None) -> Reply:
        timeout = self.default_timeout if timeout_s is None else timeout_s
        cid = cid or payload.get("cid") or new_cid()

        with self._conn_lock:
            conn = self.conn
        if conn is None or conn.closed:
            return Reply(
                ok=False, cid=cid, channel=self.name,
                error=("游戏侧尚未连接。命令**没有**被发送，也没有被执行。\n"
                       "请确认游戏已加载 arma3-mcp 扩展（它需要主动连到 "
                       "%s:%d）。" % (self.host, self.port)))

        pending = Pending(cid=cid, sent_at=time.time())
        with self._pending_lock:
            self._pending[cid] = pending

        body = {"t": "cmd", "cid": cid, "cmd": payload.get("cmd", ""),
                "args": payload.get("args", [])}
        try:
            self._trace("mcp->game", body)
            conn.send(body)
            self.stats["commands_sent"] += 1
        except OSError as exc:
            with self._pending_lock:
                self._pending.pop(cid, None)
            self.stats["errors"] += 1
            return Reply(ok=False, cid=cid, channel=self.name,
                         error="发送失败：%s" % exc)

        if not pending.event.wait(timeout):
            with self._pending_lock:
                self._pending.pop(cid, None)
            self.stats["timeouts"] += 1
            return Reply(
                ok=False, cid=cid, channel=self.name,
                elapsed_ms=int(timeout * 1000),
                error=("等待回执超时（%.1fs）。命令**已发送**但结果未知——"
                       "不要据此认为它失败了；请用事件流或游戏内状态核对。"
                       % timeout))
        assert pending.reply is not None
        return pending.reply

    def _fail_all_pending(self, reason: str) -> None:
        with self._pending_lock:
            pendings = list(self._pending.values())
            self._pending.clear()
        for pending in pendings:
            pending.reply = Reply(ok=False, cid=pending.cid, channel=self.name,
                                  error=reason)
            pending.event.set()

    # ---------------------------------------------------------------- 事件

    def drain_events(self, limit: int = 200) -> list[str]:
        with self._conn_lock:
            conn = self.conn
        if conn is None:
            return []
        events = conn.drain_events()
        if limit and len(events) > limit:
            return events[-limit:]
        return events

    def pending_count(self) -> int:
        with self._pending_lock:
            return len(self._pending)


def tcp_channel_from_env(env: Optional[dict] = None) -> Channel:
    """按环境变量构造通道。

    ALC_CHANNEL=tcp 时启用本通道；其余情况退回 NullChannel（诚实报错）。
    """
    from .channel import NullChannel

    e = env if env is not None else os.environ
    kind = (e.get("ALC_CHANNEL") or "").strip().lower()
    if kind in ("", "null", "none"):
        return NullChannel()
    if kind != "tcp":
        return NullChannel(reason="未知的通道类型 %r（目前支持 tcp）" % kind)
    host = (e.get("ALC_TCP_HOST") or "0.0.0.0").strip()
    try:
        port = int(e.get("ALC_TCP_PORT") or DEFAULT_PORT)
    except ValueError:
        port = DEFAULT_PORT
    token = e.get("ALC_TCP_TOKEN") or DEFAULT_TOKEN
    chan = TcpChannel(host=host, port=port, token=token)
    if not chan.start():
        # 启动失败不抛异常：让工具的报错里带上原因（比崩溃更有用）
        return NullChannel(reason="TCP 通道启动失败：" + chan.start_error)
    return chan
