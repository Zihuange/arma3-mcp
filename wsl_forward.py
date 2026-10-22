#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""本地转发器：把 WSL 回环上的请求转给 Windows 侧的 arma3-mcp。

## 为什么需要它（这是实测出来的链路事实）

本机 WSL2 是 NAT 模式，实测结论：

| 从 WSL 访问 Windows 的 32128 | 结果 |
|---|---|
| 直连 `192.168.160.1:32128`（curl --noproxy / Python / Node） | **超时** |
| **经代理** `192.168.160.1:7897` | **成功** |

也就是说：WSL 只能**经代理**到达 Windows 的那个端口。

而 DSH 用的是 Node 的 `fetch`（undici），**默认不读 `HTTP_PROXY` 环境变量**
（需要显式 ProxyAgent 或 Node 24+ 的 NODE_USE_ENV_PROXY），所以给 DSH 填
`http://192.168.160.1:32128/mcp` 会一直超时。

本转发器把这个问题收在一处：DSH 只连本机回环（永远可达），
由本进程经代理把请求转给 Windows 侧。DSH 侧无需任何代理配置。

## 用法

    python3 wsl_forward.py                       # 默认 :32130 -> 上游 :32128（经代理）
    python3 wsl_forward.py --listen 32130 --upstream-port 32128
    python3 wsl_forward.py --no-proxy            # 不走代理（若将来直连可用）

DSH 配置里把 url 指向 http://127.0.0.1:32130/mcp
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


class _ForwardHandler(BaseHTTPRequestHandler):
    server_version = "arma3-mcp-forward/1.0"
    protocol_version = "HTTP/1.1"

    upstream: str = ""
    proxy: str = ""
    quiet: bool = True

    def log_message(self, fmt: str, *args) -> None:  # noqa: A003
        if not self.quiet:
            sys.stderr.write("[fwd] %s\n" % (fmt % args))

    # -------------------------------------------------------------- 转发

    def _opener(self):
        if self.proxy:
            return urllib.request.build_opener(
                urllib.request.ProxyHandler({"http": self.proxy,
                                             "https": self.proxy}))
        return urllib.request.build_opener(urllib.request.ProxyHandler({}))

    def _forward(self, method: str, body: bytes | None) -> None:
        url = self.upstream + self.path
        headers = {"Content-Type": self.headers.get("Content-Type",
                                                    "application/json")}
        # 透传会话头（MCP 用得到）
        for name in ("Mcp-Session-Id", "Accept"):
            value = self.headers.get(name)
            if value:
                headers[name] = value
        request = urllib.request.Request(url, data=body, headers=headers,
                                         method=method)
        try:
            with self._opener().open(request, timeout=60) as resp:
                payload = resp.read()
                self._reply(resp.status, payload,
                            resp.headers.get("Content-Type",
                                             "application/json"))
        except urllib.error.HTTPError as exc:
            # 上游的 4xx/5xx 原样透传（不要吞成 502，那会掩盖真实原因）
            with exc:
                payload = exc.read()
                self._reply(exc.code, payload,
                            exc.headers.get("Content-Type", "application/json"))
        except Exception as exc:  # noqa: BLE001
            message = json.dumps({
                "error": "forward failed",
                "detail": "%s: %s" % (type(exc).__name__, exc),
                "upstream": url,
                "hint": ("转发器连不上上游。请确认 Windows 侧已运行 "
                         "start_windows.bat；若代理地址变了，检查 --proxy。"),
            }, ensure_ascii=False).encode("utf-8")
            self._reply(502, message, "application/json")

    def _reply(self, status: int, payload: bytes, content_type: str) -> None:
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(payload)))
        self.end_headers()
        if payload:
            self.wfile.write(payload)

    # -------------------------------------------------------------- 路由

    def do_GET(self) -> None:  # noqa: N802
        self._forward("GET", None)

    def do_POST(self) -> None:  # noqa: N802
        try:
            length = int(self.headers.get("Content-Length") or 0)
        except ValueError:
            length = 0
        body = self.rfile.read(length) if length > 0 else None
        self._forward("POST", body)

    def do_DELETE(self) -> None:  # noqa: N802
        self._forward("DELETE", None)


def build_forwarder(listen_host: str, listen_port: int, upstream_host: str,
                    upstream_port: int, proxy: str,
                    quiet: bool = True) -> ThreadingHTTPServer:
    upstream = "http://%s:%d" % (upstream_host, upstream_port)
    handler = type("ForwardHandler", (_ForwardHandler,), {
        "upstream": upstream, "proxy": proxy, "quiet": quiet,
    })
    httpd = ThreadingHTTPServer((listen_host, listen_port), handler)
    httpd.daemon_threads = True
    return httpd


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="WSL→Windows 的 arma3-mcp 转发器")
    ap.add_argument("--listen-host", default="127.0.0.1")
    ap.add_argument("--listen", type=int, default=32130,
                    help="WSL 侧监听端口（DSH 连这个）")
    ap.add_argument("--upstream-host", default=None,
                    help="Windows 侧地址；默认取 WSL 默认网关")
    ap.add_argument("--upstream-port", type=int, default=32128,
                    help="Windows 侧 arma3-mcp 的端口")
    ap.add_argument("--proxy", default=None,
                    help="代理地址；默认读 HTTP_PROXY 环境变量")
    ap.add_argument("--no-proxy", action="store_true", help="不走代理直连")
    ap.add_argument("--verbose", action="store_true")
    args = ap.parse_args(argv)

    upstream_host = args.upstream_host
    if not upstream_host:
        # WSL 的默认网关就是 Windows 上 vEthernet (WSL) 的地址
        try:
            with open("/proc/net/route") as fh:
                for line in fh.readlines()[1:]:
                    fields = line.split()
                    if len(fields) > 2 and fields[1] == "00000000":
                        raw = int(fields[2], 16)
                        upstream_host = ".".join(str((raw >> shift) & 0xFF)
                                                 for shift in (0, 8, 16, 24))
                        break
        except OSError:
            pass
    if not upstream_host:
        print("无法确定上游地址，请用 --upstream-host 指定。", file=sys.stderr)
        return 2

    if args.no_proxy:
        proxy = ""
    elif args.proxy is not None:
        proxy = args.proxy
    else:
        proxy = (os.environ.get("HTTP_PROXY")
                 or os.environ.get("http_proxy") or "")

    try:
        httpd = build_forwarder(args.listen_host, args.listen, upstream_host,
                                args.upstream_port, proxy,
                                quiet=not args.verbose)
    except OSError as exc:
        print("监听 %s:%d 失败：%s" % (args.listen_host, args.listen, exc),
              file=sys.stderr)
        return 2

    print("转发器已启动")
    print("  DSH 请填 : http://%s:%d/mcp" % (args.listen_host, args.listen))
    print("  上游     : http://%s:%d%s"
          % (upstream_host, args.upstream_port, "（经代理 %s）" % proxy
             if proxy else "（直连）"))
    print("  停止     : Ctrl+C")
    sys.stdout.flush()
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\n已停止。")
    finally:
        httpd.server_close()
    return 0


if __name__ == "__main__":
    sys.exit(main())
