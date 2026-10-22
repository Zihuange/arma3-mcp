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
            "unrestricted": "⚠ 无门控模式（所有命令放行，含硬禁与 CALL_DENY）",
            "engine_read": "只读查询", "engine_write": "改变游戏世界",
            "engine_exotic": "凭空生成资源/网络协调/调试后门",
            "engine_call": "call（有条件放行：目标函数名还要过 CALL_DENY）",
            "ui_control": "UI 控件操作", "input_inject": "原生输入注入",
            "input_foreground_only": "仅前台注入", "allow_input_text": "文本输入",
            "allow_cheat": "调试/作弊命令",
        }
        lines = ["闸门状态（true=放行）："]
        # 全开必须**醒目**且出现在最前：这是"现在什么模式"的唯一可见入口，
        # 埋在一堆 ✓ 里等于没有。
        if snap.get("unrestricted"):
            lines.append("  ⚠⚠ 无门控模式已开启 —— 硬禁命令、CALL_DENY、表达式白名单"
                         "全部不再生效。审计里每次调用都会带 mode=unrestricted。")
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

        # "已接通"只说 DLL 连上了 MCP，**不**说游戏里有人在执行命令。
        # 这两件事曾经混为一谈，代价是：exec 一路超时，而状态页看着一切正常——
        # 最坏的一种错，因为没有人会去找问题。
        if info.get("connected"):
            from adapters import health as _health
            h = _health.probe(chan)
            lines.append(f"  {_health.describe_line(h)}")
            if h.get("executor") in ("never_started", "stalled"):
                lines.append("    ↑ 需要游戏世界的命令（exec / config_*）此时不会被"
                             "处理；DLL 直连能力（截图／输入／窗口）仍可用。")
                lines.append("    详见 game_link 的输出。")
        lines.append("")
        lines.append(f"硬禁命令 {len(forbidden_list())} 条（任何开关都放不开）："
                     + "、".join(forbidden_list()[:8]) + " …")
        # call 的目标清单与硬禁清单是**两件事**，必须分开显示：前者管"被调用的
        # 函数名"，后者管"命令名"。合在一起会让人以为 call 仍被硬禁。
        from guard.gates import call_denied_list
        lines.append(f"call 拒绝清单 {len(call_denied_list())} 条"
                     f"（开了 A3MCP_ENGINE_CALL 也调不了）："
                     + "、".join(call_denied_list()[:6]) + " …")
        # 运行环境：同一套代码可能跑在 WSL 或 Windows 侧，出问题时第一个要回答的
        # 就是"我现在连的是哪一个实例"
        import platform
        import sys as _sys
        env = {
            "python": _sys.version.split()[0],
            "platform": platform.platform(),
            "executable": _sys.executable,
            "audit_log": __import__("os").environ.get("A3MCP_AUDIT_LOG") or "(未设置)",
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
        description=("查看游戏侧扩展 DLL 的连接状态与内部队列（收件/发件/丢弃计数），"
                     "并判定执行器是否真的在取命令。"
                     "排查「命令发出去了但游戏没反应」时先用它。"),
        input_schema={"type": "object", "properties": {}},
        phase="control",
    )
    def _link(_args: dict) -> ToolResult:
        # status 是 DLL **直连**命令（不进 SQF 队列，见 DLL 的 is_native_command）。
        # 这一点是刻意的：诊断"为什么命令不通"恰恰发生在执行器没跑的时候，
        # 诊断工具自己绝不能也走那条要依赖执行器的路。
        from adapters import health as _health

        h = _health.probe(chan)
        if not h["available"]:
            return ToolResult.fail("取 DLL 状态失败：%s" % h["error"], h)

        data = h["raw"] or {}
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
        lines.append("→ " + h["summary"])

        if h["executor"] in ("never_started", "stalled") and (data.get("inbox") or 0) > 0:
            lines.append("   注意：inbox=%s 说明已经有命令堆在里面等着，"
                         "这些命令**不会**被执行，只会一路超时。" % data["inbox"])
        if h["executor"] == "running" and (data.get("inbox") or 0) > 3:
            lines.append("   注意：心跳正常但 inbox 有积压，"
                         "可能是某条命令执行时间很长堵住了循环。")
        return ToolResult.ok("\n".join(lines), h)
