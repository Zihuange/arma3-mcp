#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""执行通道抽象。

MCP 侧只依赖这个接口，因此"通道怎么实现"与"工具怎么用"完全解耦：
  · NullChannel —— 未接通（P0 阶段就是它）。所有执行请求返回**明确未连接**
    错误，而不是假装成功。这是刻意的：一个会静默失败的执行通道比没有更糟。
  · PipeChannel / TcpChannel —— P1 接通游戏内 DLL 后实现（见 docs/deploy.md）。

约定：
  · send(payload) 是**同步**的，返回回执字典 {ok, result?, error?, raw?}；
  · 超时、断开、游戏未响应都必须变成结构化的 error，不抛异常。
"""

from __future__ import annotations

import json
import os
import time
import uuid
from dataclasses import dataclass, field
from typing import Any, Optional


@dataclass
class Reply:
    ok: bool
    cid: str
    result: Any = None
    error: str = ""
    raw: str = ""
    elapsed_ms: int = 0
    channel: str = "none"

    def to_dict(self) -> dict:
        out: dict = {"ok": self.ok, "cid": self.cid, "channel": self.channel,
                     "elapsed_ms": self.elapsed_ms}
        if self.result is not None:
            out["result"] = self.result
        if self.error:
            out["error"] = self.error
        if self.raw:
            out["raw"] = self.raw[:2000]
        return out


class Channel:
    """执行通道接口。"""

    name = "none"

    def connected(self) -> bool:
        return False

    def info(self) -> dict:
        return {"channel": self.name, "connected": self.connected()}

    def send(self, payload: dict, timeout_s: float = 5.0) -> Reply:
        raise NotImplementedError

    def drain(self, limit: int = 200) -> list[str]:
        """取回上行事件（游戏 → MCP）。默认无事件。"""
        return []


class NullChannel(Channel):
    """未接通的通道。诚实报错，不静默失败。"""

    name = "null"

    def __init__(self, reason: str = "") -> None:
        self.reason = reason or (
            "执行通道尚未接通：游戏内的 arma3-mcp 扩展未加载，或管道未建立。")

    def send(self, payload: dict, timeout_s: float = 5.0) -> Reply:  # noqa: ARG002
        cid = new_cid()
        return Reply(
            ok=False, cid=cid, channel=self.name,
            error=(self.reason + "\n"
                   "命令**没有**被发送，也没有被执行——请不要据此认为游戏内已生效。"
                   "\n部署与启动步骤见本仓库 docs/deploy.md。"),
        )

    def info(self) -> dict:
        return {"channel": self.name, "connected": False, "reason": self.reason}


def new_cid() -> str:
    """命令 id。用短随机串：SQF 侧要把它原样回显，越短越不易出错。"""
    return "c" + uuid.uuid4().hex[:10]


def local_preview_command(payload: dict) -> dict:
    """无通道时的本地预演：把要发的负载整理成可核对的形态。

    这不是执行——返回里会明确标注。它的价值是让人/模型在执行前看到
    "最终会发给引擎的到底是什么"，把参数错误挡在通道之前。
    """
    return {
        "would_send": payload,
        "at": time.strftime("%Y-%m-%d %H:%M:%S"),
        "json_bytes": len(json.dumps(payload, ensure_ascii=False).encode("utf-8")),
    }


def channel_from_env(env: Optional[dict] = None) -> Channel:
    """按环境变量选通道。默认 NullChannel（P0 阶段）。"""
    e = env if env is not None else os.environ
    explicit = (e.get("A3MCP_CHANNEL") or "").strip().lower()
    if explicit in ("", "null", "none"):
        return NullChannel()
    # P1 起：pipe / tcp 在此分派
    return NullChannel(reason=f"未知的通道类型 {explicit!r}（P0 只提供 null 通道）")
