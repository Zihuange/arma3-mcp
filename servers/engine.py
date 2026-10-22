#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""arma3-mcp 引擎能力面服务器（MCP stdio）。

启动：
    python3 -m servers.engine

DSH 侧配置（cordis 插件 mcp-client 的一条 entry）：
    serverName: arma3_engine
    transport: stdio
    command: python3
    args: ['-m', 'servers.engine']
    cwd: <本仓库路径>

环境变量见 docs/deploy.md；闸门默认值 = 最保守但可用（EXOTIC 与输入注入关闭）。
"""

from __future__ import annotations

import os
import sys

# 允许 `python3 servers/engine.py` 与 `python3 -m servers.engine` 两种调用方式
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

import adapters                                          # noqa: E402
from adapters import config_tools, control_tools, exec_tools  # noqa: E402
from guard import Gates                                  # noqa: E402
from knowledge.capabilities import default_matrix        # noqa: E402
from knowledge.index import default_index                # noqa: E402
from knowledge import tools as knowledge_tools           # noqa: E402
from mcpcore import Registry                             # noqa: E402
from mcpcore.http_transport import serve_http            # noqa: E402
from mcpcore.server import Server, main as serve         # noqa: E402

INSTRUCTIONS = """\
本服务器把 Arma 3（Real Virtuality 引擎）的能力面暴露给你：5000+ 条引擎命令与
官方函数，可用结构化调用在游戏内执行。

工作方式（建议顺序）：
  0. capability_matrix —— 先确认"这件事引擎能不能做"，能省掉大量无用功。
  1. cmd_families / cmd_search —— 不知道用哪条命令时先找。
  2. cmd_info —— 看签名、参数类型、返回类型、Arma 3 引入版本。
  3. cmd_check —— 用实际参数试校验，不执行。
  4. exec（建议先 dry_run=true 看预演）—— 真正执行。

两条必须遵守的约定：
  · 参数一律用位置数组：args=[["u_17"], [100,200,0]]。
  · 游戏实体（Object/Group/Control…）用**单元素数组**承载：["u_17"] 是字符串，
    [["u_17"]] 才是实体 u_17。实体名需先在游戏内登记。

不确定就查，不要凭记忆写命令与参数——SQF 的命令名或参数写错通常**不报错**，
只在运行时静默失败，这比报错更难排查。
"""


def choose_channel():
    """按 ALC_CHANNEL 选择执行通道。

    默认 null：不监听任何端口、exec 明确报"未接通"。
    ALC_CHANNEL=tcp 时启动 TCP 服务端等待游戏连入；启动失败（如端口被占）
    会退回 null 并在通道信息里带上原因，而不是抛异常崩掉服务器。
    """
    kind = (os.environ.get("ALC_CHANNEL") or "").strip().lower()
    if kind in ("", "null", "none"):
        return adapters.channel_from_env()
    if kind == "tcp":
        return adapters.tcp_channel_from_env()
    return adapters.NullChannel(reason="未知的通道类型 %r（目前支持 tcp）" % kind)


def build_registry(channel=None) -> Registry:
    """组装工具注册表。

    channel 允许注入：Windows 侧的 HTTP 入口需要**同时**持有游戏连接通道
    （DLL 连进来的那个），注入可避免创建两个实例、开两个端口。
    """
    reg = Registry()
    idx = default_index()
    gates = Gates.from_env()
    chan = channel if channel is not None else choose_channel()
    knowledge_tools.register(reg, idx, gates)
    knowledge_tools.register_capabilities(reg, default_matrix())
    exec_tools.register(reg, idx, gates, chan)
    exec_tools.register_channel_tools(reg, chan)
    control_tools.register(reg, gates, chan)
    # 链路诊断：直接查 DLL 的内部队列状态（排查"命令发了没反应"的关键入口）
    control_tools.register_link_tool(reg, chan)
    # config 查询复用执行通道（运行时读游戏内 config 树）
    config_tools.register(reg, chan, config_tools.ConfigTools(chan))
    return reg


def _arg_value(argv: list[str], flag: str) -> str | None:
    """取 `--flag value` 或 `--flag=value` 的值。"""
    for i, item in enumerate(argv):
        if item == flag and i + 1 < len(argv):
            return argv[i + 1]
        if item.startswith(flag + "="):
            return item.split("=", 1)[1]
    return None


def main() -> int:
    """两种传输：

    · stdio（默认）——DSH 自己启动本进程时用，见 README 的接入配置。
    · http         ——**用户手动启动**本进程时用（例如在 Windows 侧运行，
                      绕开"WSL 的 Node 无法执行 Windows 程序"的限制），
                      DSH 侧以 transport: streamable-http + url 连入。
    """
    argv = sys.argv[1:]
    transport = (_arg_value(argv, "--transport")
                 or os.environ.get("ALC_TRANSPORT") or "stdio").strip().lower()
    reg = build_registry()

    if transport in ("stdio", ""):
        return serve(reg, name="arma3-mcp-engine", version="0.1.0",
                     instructions=INSTRUCTIONS)
    if transport == "http":
        host = _arg_value(argv, "--host") or os.environ.get("ALC_HTTP_HOST") or "0.0.0.0"
        port_text = (_arg_value(argv, "--port")
                     or os.environ.get("ALC_HTTP_PORT") or "32124")
        try:
            port = int(port_text)
        except ValueError:
            print("端口不是整数：%r" % port_text, file=sys.stderr)
            return 2
        server = Server(reg, name="arma3-mcp-engine", version="0.1.0",
                        instructions=INSTRUCTIONS)
        return serve_http(server, host, port)
    print("未知的传输类型：%r（支持 stdio / http）" % transport, file=sys.stderr)
    return 2


if __name__ == "__main__":
    sys.exit(main())
