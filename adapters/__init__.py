#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""适配层：执行通道与工具接线。

通道选择是**进程级**决定：MCP 服务器常驻，TCP 通道会一直监听等待游戏连入。
故提供一个统一工厂，把"选哪种通道"的逻辑收在一处，工具层不需要知道细节。
"""

from .channel import (  # noqa: F401
    Channel, NullChannel, Reply, channel_from_env, new_cid,
)
from .tcp_channel import (  # noqa: F401
    DEFAULT_PORT, DEFAULT_TOKEN, PROTOCOL_VERSION, TcpChannel,
    tcp_channel_from_env,
)

__all__ = [
    "Channel", "NullChannel", "Reply", "new_cid", "TcpChannel",
    "channel_from_env", "tcp_channel_from_env", "DEFAULT_PORT",
    "DEFAULT_TOKEN", "PROTOCOL_VERSION",
]
