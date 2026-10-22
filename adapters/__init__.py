#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""适配层：执行通道与工具接线。"""

from .channel import Channel, NullChannel, Reply, channel_from_env, new_cid  # noqa: F401

__all__ = ["Channel", "NullChannel", "Reply", "channel_from_env", "new_cid"]
