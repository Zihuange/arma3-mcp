#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""arma3-mcp 启动入口 —— 读配置、设环境变量、启动服务。

## 为什么需要它

服务端本身只认**环境变量**（那是最小、最好测的接口）。但让使用者去记二十来个
环境变量不合理，所以加这一层：把 `a3mcp.json` 翻译成环境变量，再启动。

服务端代码一行不用改 —— 配置文件只是"人友好的入口"，环境变量仍是唯一真相。

## 两种传输

    python start.py                # stdio（默认）：供 MCP 客户端拉起
    python start.py --http         # HTTP：手动启动，客户端用 url 连入
    python start.py --http --http-port 32128

**默认 stdio** 是刻意的：MCP 客户端与服务器同机时（绝大多数情况），客户端
自己 `spawn` 本进程即可，不需要端口、不需要手动启动、不需要知道网关地址。

HTTP 模式用于**客户端无法执行本进程**的场景——本仓库开发机就是如此：
DSH 跑在 WSL 里，而 WSL 的 Node 无法执行 Windows 程序（spawn 返回 ENOENT），
所以只能人工在 Windows 侧启动、客户端经网关地址连入。

## 约定（非常重要）

- **stdio 模式下绝不向 stdout 写任何东西**：stdout 就是 JSON-RPC 流，
  一行日志就会让客户端解析失败。所有提示走 stderr。
- 配置优先级：**命令行 > 环境变量 > a3mcp.json > 内置默认**。
- 配置文件缺失不是错误：没有就用默认值，并在 stderr 提示怎么生成。

## 与游戏侧的连接（另一条独立链路）

`server.channel=tcp` 时，本进程监听 `server.tcp_port`，由**游戏内的扩展 DLL
主动连入**。该端口必须与 DLL 的默认端口一致（`arma3_mcp_extension.cpp` 里
`std::string port = "32132"`）——不一致时游戏侧连不上，而且**没有明显提示**。
"""

from __future__ import annotations

import argparse
import json
import os
import sys

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

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)

DEFAULT_CONFIG_NAME = "a3mcp.json"
EXAMPLE_CONFIG_NAME = "a3mcp.example.json"

# 内置默认值：与 docs 里的说明保持一致，且都是**最保守**的选择。
DEFAULTS = {
    "server": {
        "transport": "stdio",     # stdio | http
        "http_host": "0.0.0.0",
        "http_port": 32128,
        "channel": "tcp",         # tcp | null
        "tcp_host": "127.0.0.1",
        "tcp_port": 32132,        # 必须与 DLL 默认端口一致
        "audit_log": "audit.jsonl",
        "shot_dir": "build/shots",
    },
    "gates": {
        "engine_read": True,
        "engine_write": True,
        "engine_exotic": False,
        "engine_call": False,
        "ui_control": True,
        "input_inject": False,
        "input_foreground_only": True,
        "allow_input_text": True,
        "allow_cheat": False,
        "profile": "",
    },
}

# 配置键 → 环境变量。服务端只认右边这一列。
ENV_MAP = {
    ("server", "transport"): "A3MCP_TRANSPORT",
    ("server", "http_host"): "A3MCP_HTTP_HOST",
    ("server", "http_port"): "A3MCP_HTTP_PORT",
    ("server", "channel"): "A3MCP_CHANNEL",
    ("server", "tcp_host"): "A3MCP_TCP_HOST",
    ("server", "tcp_port"): "A3MCP_TCP_PORT",
    ("server", "audit_log"): "A3MCP_AUDIT_LOG",
    ("server", "shot_dir"): "A3MCP_SHOT_DIR",
    ("gates", "engine_read"): "A3MCP_ENGINE_READ",
    ("gates", "engine_write"): "A3MCP_ENGINE_WRITE",
    ("gates", "engine_exotic"): "A3MCP_ENGINE_EXOTIC",
    ("gates", "engine_call"): "A3MCP_ENGINE_CALL",
    ("gates", "ui_control"): "A3MCP_UI_CONTROL",
    ("gates", "input_inject"): "A3MCP_INPUT_INJECT",
    ("gates", "input_foreground_only"): "A3MCP_INPUT_FOREGROUND_ONLY",
    ("gates", "allow_input_text"): "A3MCP_INPUT_TEXT",
    ("gates", "allow_cheat"): "A3MCP_ALLOW_CHEAT",
    ("gates", "profile"): "A3MCP_PROFILE",
}


def _as_env(value) -> str:
    """配置值 → 环境变量字符串。布尔用 1/0，其余用 str。"""
    if isinstance(value, bool):
        return "1" if value else "0"
    return str(value)


def load_config(path: str) -> tuple[dict, bool]:
    """读配置并与默认值合并。返回 (配置, 是否读到了文件)。"""
    cfg = {section: dict(values) for section, values in DEFAULTS.items()}
    if not os.path.isfile(path):
        return cfg, False
    with open(path, "r", encoding="utf-8") as fh:
        raw = json.load(fh)
    if not isinstance(raw, dict):
        raise SystemExit("配置文件顶层必须是对象：%s" % path)
    for section in cfg:
        part = raw.get(section)
        if isinstance(part, dict):
            for key, value in part.items():
                if key in cfg[section] and value is not None:
                    cfg[section][key] = value
    return cfg, True


def apply_config_to_env(cfg: dict) -> None:
    """把配置写进环境变量，但**不覆盖已显式设置的环境变量**。

    优先级就是这么实现的：环境变量已经有的值不动，所以
    "环境变量 > 配置文件"；命令行参数在调用后另行覆盖。
    """
    for (section, key), env_name in ENV_MAP.items():
        if env_name in os.environ:
            continue
        value = cfg.get(section, {}).get(key)
        if value is None or value == "":
            continue
        os.environ[env_name] = _as_env(value)


def _wsl_gateway() -> str:
    """WSL 看到的 Windows 主机地址（默认路由网关）。

    只在 HTTP 模式下打印提示用。取不到就返回空串——这不该阻断启动。
    """
    try:
        import subprocess
        out = subprocess.run(["ip", "route"], capture_output=True, text=True,
                             timeout=5).stdout
    except (OSError, subprocess.SubprocessError):
        return ""
    for line in out.splitlines():
        if line.startswith("default via "):
            return line.split()[2]
    return ""


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(
        prog="start.py",
        description="启动 arma3-mcp（读 a3mcp.json → 设环境变量 → 起服务）",
        epilog="stdio 模式下 stdout 是 JSON-RPC 流，本脚本只在 stderr 打提示。",
        # ⚠ 必须关掉前缀缩写：否则 `--http` 会被当成 `--http-host`/`--http-port`
        # 的缩写而报"ambiguous option"。实测踩过——而 start_windows.bat 正是
        # 用 `--http` 调进来的，所以它当时直接启动失败。
        allow_abbrev=False)
    ap.add_argument("--http", action="store_true",
                    help="等价于 --transport http（手动启动 HTTP 服务）")
    ap.add_argument("--transport", choices=["stdio", "http"],
                    help="传输方式；默认取配置（未配置则 stdio）")
    ap.add_argument("--config", default=os.path.join(HERE, DEFAULT_CONFIG_NAME),
                    help="配置文件路径（默认 <repo>/%s）" % DEFAULT_CONFIG_NAME)
    ap.add_argument("--http-host", help="HTTP 监听地址（仅 --http）")
    ap.add_argument("--http-port", type=int, help="HTTP 端口（仅 --http）")
    ap.add_argument("--tcp-host", help="游戏连接通道的监听地址")
    ap.add_argument("--tcp-port", type=int, help="游戏连接通道的端口（须与 DLL 一致）")
    ap.add_argument("--unrestricted", action="store_true",
                    help="无门控模式（所有命令放行；风险自担，见 docs/safety.md）")
    args = ap.parse_args(argv)

    cfg, found = load_config(args.config)
    apply_config_to_env(cfg)

    # 命令行最高优先级：直接覆盖环境变量
    if args.http:
        args.transport = "http"
    if args.transport:
        os.environ["A3MCP_TRANSPORT"] = args.transport
    if args.http_host:
        os.environ["A3MCP_HTTP_HOST"] = args.http_host
    if args.http_port:
        os.environ["A3MCP_HTTP_PORT"] = str(args.http_port)
    if args.tcp_host:
        os.environ["A3MCP_TCP_HOST"] = args.tcp_host
    if args.tcp_port:
        os.environ["A3MCP_TCP_PORT"] = str(args.tcp_port)
    if args.unrestricted:
        os.environ["A3MCP_PROFILE"] = "unrestricted"

    transport = (os.environ.get("A3MCP_TRANSPORT") or "stdio").strip().lower()

    # 提示一律走 stderr：stdio 模式下 stdout 必须保持纯净
    if not found:
        print("[start] 未找到 %s，使用内置默认值。\n"
              "        要定制，复制 %s 为 %s 再改。"
              % (args.config, EXAMPLE_CONFIG_NAME, DEFAULT_CONFIG_NAME),
              file=sys.stderr)

    if transport == "http":
        host = os.environ.get("A3MCP_HTTP_HOST") or "0.0.0.0"
        port = os.environ.get("A3MCP_HTTP_PORT") or "32128"
        print("[start] HTTP 模式：http://%s:%s/mcp" % (host, port), file=sys.stderr)
        gateway = _wsl_gateway()
        if gateway:
            print("[start] 若客户端在 WSL 内，用网关地址：http://%s:%s/mcp"
                  % (gateway, port), file=sys.stderr)
        print("[start] （只绑 127.0.0.1 时 WSL 访问不到；默认 0.0.0.0 是对的）",
              file=sys.stderr)
    else:
        print("[start] stdio 模式：由 MCP 客户端拉起本进程（命令行/args 指向本文件）",
              file=sys.stderr)

    if os.environ.get("A3MCP_PROFILE") == "unrestricted":
        print("[start] ⚠ 无门控模式：硬禁命令、CALL_DENY、表达式白名单全部失效",
              file=sys.stderr)

    # 交给服务端：它读 A3MCP_TRANSPORT 决定走 stdio 还是 http
    import servers.engine as engine
    saved = sys.argv
    try:
        sys.argv = ["servers.engine"]
        return engine.main()
    finally:
        sys.argv = saved


if __name__ == "__main__":
    _safe_console()
    sys.exit(main())
