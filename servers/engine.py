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

from adapters import channel_from_env                    # noqa: E402
from adapters import control_tools, exec_tools           # noqa: E402
from guard import Gates                                  # noqa: E402
from knowledge.capabilities import default_matrix        # noqa: E402
from knowledge.index import default_index                # noqa: E402
from knowledge import tools as knowledge_tools           # noqa: E402
from mcpcore import Registry                             # noqa: E402
from mcpcore.server import main as serve                 # noqa: E402

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


def build_registry() -> Registry:
    reg = Registry()
    idx = default_index()
    gates = Gates.from_env()
    chan = channel_from_env()
    knowledge_tools.register(reg, idx, gates)
    knowledge_tools.register_capabilities(reg, default_matrix())
    exec_tools.register(reg, idx, gates, chan)
    control_tools.register(reg, gates, chan)
    return reg


def main() -> int:
    reg = build_registry()
    return serve(reg, name="arma3-mcp-engine", version="0.1.0",
                 instructions=INSTRUCTIONS)


if __name__ == "__main__":
    sys.exit(main())
