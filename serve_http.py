#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""在**本机（Windows）**启动 MCP 服务器的 HTTP 传输，并打印 DSH 该填的地址。

## 为什么需要这个启动器

本机 DSH 跑在 WSL 里的 Node 进程，而 **WSL 的 Node 无法执行 Windows 程序**
（`spawn` 返回 ENOENT，实测见 docs/decisions.md D14）。所以 MCP 若想在
Windows 侧运行（与游戏同网络栈），只能由**用户手动启动**，DSH 以
`transport: streamable-http` 连过来。

## 地址怎么定（这是本脚本存在的主要理由）

实测（WSL2 NAT 模式）：
  · Windows 服务绑 `0.0.0.0` → WSL 经**网关地址**可达；
  · Windows 服务只绑 `127.0.0.1` → WSL **不可达**。
该网关地址就是 Windows 上 `vEthernet (WSL)` 网卡的 IPv4。
本脚本启动监听后自动探测并打印它，省掉手工查 IP 的来回。

用法（在 Windows 命令行 / PowerShell 里，于仓库根目录下）：
    python serve_http.py                     # 默认端口 32124
    python serve_http.py --port 32124 --verbose

或直接双击 `start_windows.bat`：它自己定位仓库根目录，并已设好输入注入开关。
本脚本不使用任何仓库外路径——`HERE` 由 `__file__` 推出，仓库可以任意搬动。
"""

import argparse
import os
import socket
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)


def wsl_host_address() -> str:
    """探测 Windows 上 vEthernet (WSL) 网卡的 IPv4——即 WSL 看到的网关地址。

    用 `ipconfig` 而不是 PowerShell cmdlet：不依赖执行策略（PowerShell 脚本
    可能被策略拦住），且 Windows 原生自带。
    """
    try:
        out = subprocess.run(["ipconfig"], capture_output=True, text=True,
                             timeout=15, errors="replace").stdout
    except (OSError, subprocess.SubprocessError):
        return ""
    lines = out.splitlines()
    for idx, line in enumerate(lines):
        low = line.lower()
        # 适配器标题行含 "WSL"（中英文系统都保留该英文词）
        if "wsl" in low and "适配器" in line or ("adapter" in low and "wsl" in low):
            for probe in lines[idx + 1: idx + 12]:
                text = probe.strip()
                if ("IPv4" in text or "ipv4" in text.lower()) and ":" in text:
                    candidate = text.split(":", 1)[1].strip()
                    candidate = candidate.split("(")[0].strip()
                    if _looks_like_ipv4(candidate):
                        return candidate
    return ""


def _looks_like_ipv4(text: str) -> bool:
    parts = text.split(".")
    if len(parts) != 4:
        return False
    return all(p.isdigit() and 0 <= int(p) <= 255 for p in parts)


def lan_addresses() -> list[str]:
    """本机所有非回环 IPv4（找不到 WSL 网卡时的兜底提示）。"""
    found: list[str] = []
    try:
        for info in socket.getaddrinfo(socket.gethostname(), None,
                                       socket.AF_INET):
            addr = info[4][0]
            if addr not in found and not addr.startswith("127."):
                found.append(addr)
    except OSError:
        pass
    return found


def main() -> int:
    ap = argparse.ArgumentParser(
        description="在 Windows 侧启动 arma3-mcp 的 HTTP 传输")
    ap.add_argument("--host", default="0.0.0.0",
                    help="监听地址。必须是 0.0.0.0，否则 WSL 里的 DSH 连不进来")
    ap.add_argument("--port", type=int, default=32124)
    ap.add_argument("--game-port", type=int, default=32131,
                    help="游戏侧扩展 DLL 连入的端口（与 HTTP 同一进程）")
    ap.add_argument("--no-game-channel", action="store_true",
                    help="不开游戏连接端口（只做只读的离线工具时用）")
    ap.add_argument("--verbose", action="store_true", help="打印每个 HTTP 请求")
    args = ap.parse_args()

    # 审计默认落盘：不设的话 guard.audit() 拿不到路径，审计会**静默失效**
    # （P1 起这是安全要求：谁在什么时候动了什么，必须可追溯）
    os.environ.setdefault("A3MCP_AUDIT_LOG", os.path.join(HERE, "audit.jsonl"))

    from adapters.tcp_channel import TcpChannel
    from mcpcore.http_transport import build_http_server, MCP_PATH, HEALTH_PATH
    from mcpcore.server import Server
    from servers.engine import INSTRUCTIONS, build_registry

    # 游戏连接通道：DLL 作为 TCP 客户端连到本端口。
    # 与 HTTP 跑在同一个进程里 —— 这样工具（config 查询、exec）与游戏连接
    # 共用一份状态，不需要额外进程或额外配置。
    game_channel = None
    if not args.no_game_channel:
        game_channel = TcpChannel(host="127.0.0.1", port=args.game_port)
        if not game_channel.start():
            print("⚠ 游戏连接端口启动失败：%s" % game_channel.start_error)
            print("  （HTTP 仍可用；游戏侧 DLL 将无法连入。）")
            game_channel = None

    server = Server(build_registry(game_channel), name="arma3-mcp-engine",
                    version="0.1.0", instructions=INSTRUCTIONS)
    try:
        httpd = build_http_server(server, args.host, args.port, quiet=not args.verbose)
    except OSError as exc:
        print("监听 %s:%d 失败：%s" % (args.host, args.port, exc), file=sys.stderr)
        print("（端口可能被占用：先用 netstat -ano | findstr %d 确认）"
              % args.port, file=sys.stderr)
        return 2

    wsl_ip = wsl_host_address()
    print("=" * 66)
    print("arma3-mcp HTTP 传输已启动（Windows 侧）")
    print("  本机地址   : http://127.0.0.1:%d%s" % (args.port, MCP_PATH))
    if wsl_ip:
        print("  ★ DSH 填这个: http://%s:%d%s" % (wsl_ip, args.port, MCP_PATH))
        print("    （%s 是 Windows 上 vEthernet (WSL) 的地址，WSL 经它访问本机）"
              % wsl_ip)
    else:
        print("  ⚠ 没找到 vEthernet (WSL) 网卡。请在 Windows 运行 ipconfig，")
        print("    把 WSL 网卡的 IPv4 填进 DSH 配置（形如 http://172.x.x.x:%d%s）"
              % (args.port, MCP_PATH))
        others = lan_addresses()
        if others:
            print("    本机其它地址：%s" % ", ".join(others))
    print("  健康探测   : http://127.0.0.1:%d%s" % (args.port, HEALTH_PATH))
    if game_channel is not None:
        print("  ★ 游戏侧扩展连这个 : 127.0.0.1:%d" % args.game_port)
        print("    （DLL 默认就连这里；等它连上后 exec/config_* 才可用）")
    else:
        print("  游戏连接   : 未开启（config 查询与 exec 将报「未接通」）")
    print("  审计日志   : %s" % os.environ.get("A3MCP_AUDIT_LOG", "(未设置)"))
    print("  运行环境   : %s" % sys.version.split()[0])
    print("  闸门配置   : 环境变量 A3MCP_ENGINE_WRITE 等（见 docs/deploy.md）")
    print("  停止       : Ctrl+C")
    print("=" * 66)
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
