#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Windows 侧环境自检：确认 MCP 能在本机（游戏同侧）跑起来。

为什么单独有这个脚本：MCP 在 Windows 侧运行时，游戏与它在同一个网络栈里，
127.0.0.1 直连、无需跨系统绕行（见 docs/decisions.md D13）。但 Windows 侧的
Python 版本、编码、路径都与 WSL 不同，上机前先跑一遍这个自检能省掉一轮
"到底是环境问题还是代码问题"的排查。

用法（在 Windows 命令行或 WSL 里用 py.exe）：
    python tools/verify_windows.py
"""

import json
import os
import socket
import subprocess
import sys
import threading
import time

HERE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FAILURES = []


def check(label, ok, detail=""):
    print("  %s %s%s" % ("[OK]  " if ok else "[FAIL]", label,
                         ("  " + detail) if detail else ""))
    if not ok:
        FAILURES.append(label)


def main():
    print("== Windows 侧环境自检 ==")
    print("解释器: %s" % sys.executable)
    print("版本  : %s" % sys.version.split()[0])
    print("工作区: %s" % HERE)
    print()

    check("Python >= 3.8", sys.version_info >= (3, 8),
          "当前 %d.%d" % sys.version_info[:2])

    # 命令库（xz 解压是 Windows 侧最容易出问题的一环）
    try:
        sys.path.insert(0, HERE)
        from knowledge.index import default_index
        idx = default_index()
        check("命令库可解压", idx.count() > 5000, "%d 条" % idx.count())
    except Exception as exc:  # noqa: BLE001
        check("命令库可解压", False, repr(exc))

    # 中文输出编码
    try:
        sys.stdout.write("")
        check("标准输出可写", True)
    except Exception as exc:  # noqa: BLE001
        check("标准输出可写", False, repr(exc))

    # 启动 MCP 服务器并列出工具
    env = dict(os.environ)
    env["PYTHONIOENCODING"] = "utf-8"
    proc = subprocess.Popen([sys.executable, "-m", "servers.engine"], cwd=HERE,
                            stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE, env=env)
    try:
        def rpc(msg):
            proc.stdin.write((json.dumps(msg) + "\n").encode("utf-8"))
            proc.stdin.flush()
            line = proc.stdout.readline()
            return json.loads(line.decode("utf-8")) if line else None

        init = rpc({"jsonrpc": "2.0", "id": 1, "method": "initialize",
                    "params": {"protocolVersion": "2024-11-05"}})
        check("MCP 初始化", bool(init and init.get("result")))
        tools = rpc({"jsonrpc": "2.0", "id": 2, "method": "tools/list"})
        names = [t["name"] for t in tools["result"]["tools"]] if tools else []
        check("工具注册", len(names) >= 10, "%d 个：%s" % (len(names), ", ".join(names)))

        info = rpc({"jsonrpc": "2.0", "id": 3, "method": "tools/call",
                    "params": {"name": "cmd_info",
                               "arguments": {"cmd": "setPosATL"}}})
        text = info["result"]["content"][0]["text"] if info else ""
        check("中文与签名渲染", "object setPosATL pos" in text)
    finally:
        proc.stdin.close()
        proc.wait(timeout=10)
        err = proc.stderr.read().decode("utf-8", "replace").strip()
        check("服务器干净退出", proc.returncode == 0, err[:200])

    # TCP 通道在本机回环上可用（这才是 Windows 侧运行的意义）
    port = _free_port()
    env2 = dict(env)
    env2.update({"ALC_CHANNEL": "tcp", "ALC_TCP_HOST": "127.0.0.1",
                 "ALC_TCP_PORT": str(port), "ALC_ENGINE_WRITE": "1"})
    proc2 = subprocess.Popen([sys.executable, "-m", "servers.engine"], cwd=HERE,
                             stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                             stderr=subprocess.PIPE, env=env2)
    try:
        def rpc2(msg):
            proc2.stdin.write((json.dumps(msg) + "\n").encode("utf-8"))
            proc2.stdin.flush()
            line = proc2.stdout.readline()
            return json.loads(line.decode("utf-8")) if line else None

        rpc2({"jsonrpc": "2.0", "id": 1, "method": "initialize",
              "params": {"protocolVersion": "2024-11-05"}})
        ok = False
        sock = None
        for _ in range(30):
            try:
                sock = socket.create_connection(("127.0.0.1", port), timeout=1)
                ok = True
                break
            except OSError:
                time.sleep(0.1)
        check("TCP 通道本机可连（127.0.0.1）", ok,
              "端口 %d；失败说明端口未监听或被防火墙拦截" % port)
        if sock:
            sock.sendall(b'{"t":"hello","token":"arma3-mcp-local","pid":1}\n')
            sock.settimeout(3)
            reply = sock.recv(4096)
            check("握手得到 hello_ack", b"hello_ack" in reply, reply[:80].decode("utf-8", "replace"))
            sock.close()
    finally:
        proc2.stdin.close()
        proc2.wait(timeout=10)

    print()
    if FAILURES:
        print("结果: 有 %d 项未通过 -> %s" % (len(FAILURES), "; ".join(FAILURES)))
        return 1
    print("结果: 全部通过。MCP 可以在 Windows 侧（与游戏同网络栈）运行。")
    return 0


def _free_port():
    s = socket.socket()
    s.bind(("127.0.0.1", 0))
    port = s.getsockname()[1]
    s.close()
    return port


if __name__ == "__main__":
    sys.exit(main())
