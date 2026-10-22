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
        return ToolResult.ok("\n".join(lines),
                             {"gates": snap, "channel": info,
                              "forbidden_count": len(forbidden_list())})
