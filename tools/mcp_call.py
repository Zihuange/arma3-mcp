#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""从命令行直接调用 Windows 侧 MCP 服务器的一条工具（WSL 侧使用）。

## 为什么需要它

MCP 服务器跑在 Windows 侧（见 D14/D15），DSH 侧通过 HTTP 连过去。但在
**排查与实测**时，经 DSH 客户端调用多一层不透明：客户端连不上时不报错，
只是"工具不存在"，人就不知道自己面对的是没启动、端口不对、还是工具名写错了。
这个脚本把那一层拿掉——一个 POST 进去、结果直接印出来。

它同时也是实测脚本的底座：把结论写进测试之前，先用它确认引擎的真实行为。

用法：
    python3 tools/mcp_call.py --list
    python3 tools/mcp_call.py exec --args '{"expr": "worldName"}'
    python3 tools/mcp_call.py health --gw 192.168.160.1 --port 32128

退出码：0 成功 / 1 工具返回错误 / 2 连不上或协议错。
"""

from __future__ import annotations

import argparse
import json
import socket
import subprocess
import sys
import urllib.error
import urllib.request

def _safe_console() -> None:
    """让 CLI 输出在 Windows 中文控制台（GBK）下不崩。

    中文 Windows 的默认 stdout 编码是 **GBK**，而 `✓` / `✗` / `⚠` 不在 GBK 里：
    直接 print 会抛 `UnicodeEncodeError: 'gbk' codec can't encode character`。
    这是分发后最常见的环境（中文用户），CLI 一跑就崩。

    只加 `errors="replace"`、**不改 encoding**：
      · GBK 控制台：符号显示为 `?`，不崩、不乱码；
      · UTF-8 终端：符号正常显示。
    """
    for stream in (sys.stdout, sys.stderr):
        try:
            stream.reconfigure(errors="replace")
        except (AttributeError, ValueError):
            pass          # Python < 3.7 或流不支持：保持原样

DEFAULT_PORT = 32128


def wsl_gateway() -> str:
    """WSL 看到的 Windows 主机地址（默认路由网关）。

    服务端绑 0.0.0.0 时可经此地址访问；写死 IP 会在每次重启后失效。
    """
    try:
        out = subprocess.run(["ip", "route"], capture_output=True, text=True,
                             timeout=10).stdout
    except (OSError, subprocess.SubprocessError):
        return ""
    for line in out.splitlines():
        if line.startswith("default via "):
            return line.split()[2]
    return ""


def rpc(url: str, method: str, params: dict | None = None,
        timeout: float = 60.0) -> dict:
    body = json.dumps({"jsonrpc": "2.0", "id": 1, "method": method,
                       "params": params or {}}).encode("utf-8")
    req = urllib.request.Request(
        url, data=body,
        headers={"Content-Type": "application/json",
                 "Accept": "application/json, text/event-stream"})
    with urllib.request.urlopen(req, timeout=timeout) as resp:
        raw = resp.read().decode("utf-8", "replace")
    return json.loads(raw)


def call_tool(url: str, name: str, args: dict, timeout: float = 60.0) -> dict:
    return rpc(url, "tools/call", {"name": name, "arguments": args}, timeout)


def render(reply: dict) -> tuple[int, str]:
    """把 JSON-RPC 回执整理成可读文本；返回 (退出码, 文本)。"""
    if "error" in reply:
        return 2, "协议错误：%s" % json.dumps(reply["error"], ensure_ascii=False)
    result = reply.get("result") or {}
    parts = []
    for item in result.get("content") or []:
        if item.get("type") == "text":
            parts.append(item.get("text", ""))
    text = "\n".join(parts) or json.dumps(result, ensure_ascii=False)
    return (1 if result.get("isError") else 0), text


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description="直接调用 arma3-mcp 的一条工具")
    ap.add_argument("tool", nargs="?", help="工具名；用 --list 看全部")
    ap.add_argument("--args", default="{}", help="工具参数（JSON 对象）")
    ap.add_argument("--gw", default="", help="Windows 主机地址，默认取 WSL 网关")
    ap.add_argument("--port", type=int, default=DEFAULT_PORT)
    ap.add_argument("--timeout", type=float, default=60.0)
    ap.add_argument("--list", action="store_true", help="列出全部工具")
    ap.add_argument("--raw", action="store_true", help="打印原始 JSON 回执")
    ns = ap.parse_args(argv)

    host = ns.gw or wsl_gateway()
    if not host:
        print("取不到 WSL 网关地址，请用 --gw 指定", file=sys.stderr)
        return 2
    url = "http://%s:%d/mcp" % (host, ns.port)

    try:
        if ns.list:
            reply = rpc(url, "tools/list", timeout=ns.timeout)
            if ns.raw:
                print(json.dumps(reply, ensure_ascii=False, indent=2))
                return 0
            tools = (reply.get("result") or {}).get("tools") or []
            print("工具 %d 个：" % len(tools))
            for t in tools:
                print("  %-22s %s" % (t.get("name"),
                                      (t.get("description") or "").splitlines()[0][:70]))
            return 0

        if not ns.tool:
            ap.error("需要工具名，或用 --list")
        try:
            tool_args = json.loads(ns.args)
        except json.JSONDecodeError as exc:
            print("--args 不是合法 JSON：%s" % exc, file=sys.stderr)
            return 2
        reply = call_tool(url, ns.tool, tool_args, ns.timeout)
        if ns.raw:
            print(json.dumps(reply, ensure_ascii=False, indent=2))
        code, text = render(reply)
        print(text)
        return code
    except urllib.error.HTTPError as exc:
        print("HTTP %s（%s）" % (exc.code, exc.reason), file=sys.stderr)
        return 2
    except (urllib.error.URLError, socket.timeout, OSError) as exc:
        print("连不上 %s：%s" % (url, exc), file=sys.stderr)
        return 2


if __name__ == "__main__":
    _safe_console()
    sys.exit(main())
