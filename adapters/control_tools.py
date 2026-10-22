#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""闸门与控制面工具：让模型知道"现在能做什么"，而不是撞墙后才知道。"""

from __future__ import annotations

from mcpcore.registry import Registry, ToolResult
from guard import forbidden_list


def register(reg: Registry, gu, chan) -> None:  # noqa: ANN001
    @reg.tool(
        name="gates_status",
        description=("查看当前闸门状态与执行通道是否接通。开始一批操作前先看它，"
                     "可以避免「命令被静默拒绝」这类浪费。"),
        input_schema={"type": "object", "properties": {}},
        phase="control",
    )
    def _status(_args: dict) -> ToolResult:
        snap = gu.snapshot()
        info = chan.info()
        zh = {
            "engine_read": "只读查询", "engine_write": "改变游戏世界",
            "engine_exotic": "凭空生成资源/网络协调/调试后门",
            "ui_control": "UI 控件操作", "input_inject": "原生输入注入",
            "input_foreground_only": "仅前台注入", "allow_input_text": "文本输入",
            "allow_cheat": "调试/作弊命令",
        }
        lines = ["闸门状态（true=放行）："]
        for key, label in zh.items():
            if key in snap:
                lines.append(f"  {'✓' if snap[key] else '✗'} {key:22s} {label}")
        if snap.get("overrides"):
            lines.append(f"  ·  显式放行：{', '.join(snap['overrides'])}")
        lines.append("")
        lines.append(f"执行通道：{info.get('channel')}／"
                     f"{'已接通' if info.get('connected') else '未接通'}")
        if info.get("reason"):
            lines.append(f"  {info['reason']}")
        lines.append("")
        lines.append(f"硬禁命令 {len(forbidden_list())} 条（任何开关都放不开）："
                     + "、".join(forbidden_list()[:8]) + " …")
        # 运行环境：同一套代码可能跑在 WSL 或 Windows 侧，出问题时第一个要回答的
        # 就是"我现在连的是哪一个实例"
        import platform
        import sys as _sys
        env = {
            "python": _sys.version.split()[0],
            "platform": platform.platform(),
            "executable": _sys.executable,
            "audit_log": __import__("os").environ.get("ALC_AUDIT_LOG") or "(未设置)",
        }
        lines.append("")
        lines.append(f"运行环境：Python {env['python']}　{env['platform']}")
        lines.append(f"  解释器：{env['executable']}")
        lines.append(f"  审计落点：{env['audit_log']}")
        return ToolResult.ok("\n".join(lines),
                             {"gates": snap, "channel": info, "runtime": env,
                              "forbidden_count": len(forbidden_list())})


def register_link_tool(reg: Registry, chan) -> None:  # noqa: ANN001
    """注册"链路诊断"工具：直接问 DLL 自己的状态。

    为什么要这个：MCP 侧只看到"命令发出、回执超时"，游戏侧只看到"没收到命令"，
    **两边都看不到 DLL 内部**。而 DLL 自己知道：TCP 连没连上、收件队列里有几条、
    丢了多少条。这个工具用一条特殊命令（status）把这些取回来。

    这是排查"MCP 发了但游戏没反应"的关键一步——能立刻区分：
      · inbox>0  → 命令到了 DLL 但 SQF 没取走（轮询的问题）
      · inbox=0  → 命令根本没到 DLL（TCP 或发送侧的问题）
    """
    import json as _json
    from mcpcore.registry import ToolResult

    @reg.tool(
        name="game_link",
        description=("查看游戏侧扩展 DLL 的连接状态与内部队列（收件/发件/丢弃计数）。"
                     "排查「命令发出去了但游戏没反应」时先用它："
                     "inbox>0 说明命令到了 DLL 但没被取走；inbox=0 说明没送到 DLL。"),
        input_schema={"type": "object", "properties": {}},
        phase="control",
    )
    def _link(_args: dict) -> ToolResult:
        # status 是 DLL 直接处理的函数名（不进 SQF 队列）
        reply = chan.send({"cmd": "status", "args": []}, timeout_s=5.0)
        if not reply.ok:
            return ToolResult.fail("取 DLL 状态失败：%s" % reply.error)
        data = reply.result
        if not isinstance(data, dict):
            return ToolResult.ok("DLL 返回了非预期内容：%s"
                                 % _json.dumps(data, ensure_ascii=False)[:300])
        lines = [
            "游戏侧扩展状态：",
            "  connected : %s" % data.get("connected"),
            " addr      : %s" % data.get("addr"),
            " ver       : %s" % data.get("ver"),
            " inbox     : %s  ← 待 SQF 取走的命令数" % data.get("inbox"),
            " outbox    : %s  ← 待发往 MCP 的回执数" % data.get("outbox"),
            " dropped   : %s  ← 因队列满被丢弃的命令数" % data.get("dropped"),
            " rx/tx     : %s / %s" % (data.get("rx"), data.get("tx")),
            " connects  : %s" % data.get("connects"),
        ]
        if data.get("error"):
            lines.append(" last error: %s" % data["error"])
        lines.append("")
        if data.get("inbox", 0) > 0:
            lines.append("→ inbox>0：命令已到 DLL 但没被 SQF 取走（查轮询）")
        else:
            lines.append("→ inbox=0：命令未在 DLL 队列中（查 TCP 发送侧）")
        return ToolResult.ok("\n".join(lines), data)
