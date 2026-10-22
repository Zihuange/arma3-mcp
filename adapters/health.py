#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""执行器健康探测：回答"命令发得出去，可有没有人在接"。

## 为什么需要单独一层

"TCP 已接通"与"游戏里有人能执行命令"是**两件不同的事**。

DLL 一连上 MCP 就是"已接通"，但真正执行命令的 SQF 轮询循环（执行器）只在
游戏加载了任务、或被 -init= 提前拉起来之后才存在。停在主菜单时它根本没在跑：
命令照样收下、静静堆在 DLL 的 inbox 里，调用方一路等到超时——而超时信息里
没有任何线索说明"这不是网络问题，是没人接电话"。

## 靠什么判定

DLL 的 `status` 是**直连命令**（不进 SQF 队列，见 DLL 侧 is_native_command），
所以执行器死掉时它依然答得出来。它带回 `poll_ms_ago`：SQF 每轮 poll 都会刷新
这个时间戳，于是"有没有人在接"从一个猜测变成一个可直接观测的事实。

- `poll_ms_ago == -1`  → 从未 poll 过：执行器从未启动
- `poll_ms_ago > 阈值` → 曾经活过但心跳停了：执行器挂了或游戏卡住
- `poll_ms_ago` 很小    → 正常轮询中

旧版 DLL 不返回该字段，此时如实报"未知"，不猜。
"""

from __future__ import annotations

from typing import Any, Optional

# 判定"心跳停滞"的阈值。SQF 轮询周期是 0.1s，这里给到 3s：
# 30 个周期的余量，足以容忍加载卡顿、GC、切窗口这类短暂停顿，
# 又能在执行器真的没了时几秒内给出结论。
STALE_MS = 3000

# status 是直连命令，正常在毫秒级返回；给 3s 已经非常宽松。
PROBE_TIMEOUT_S = 3.0


def probe(chan, timeout_s: float = PROBE_TIMEOUT_S) -> dict:  # noqa: ANN001
    """查 DLL 状态并判定执行器存活。

    **不抛异常**：探测本身失败也是一种结果（通道没通、DLL 太旧），
    调用方拿到的永远是结构化数据。
    """
    out: dict[str, Any] = {
        "available": False,
        "error": "",
        "connected": None,
        "inbox": None,
        "outbox": None,
        "poll_ms_ago": None,
        "executor": "unknown",
        "summary": "",
        "raw": None,
    }

    try:
        reply = chan.send({"cmd": "status", "args": []}, timeout_s=timeout_s)
    except Exception as exc:  # noqa: BLE001 - 探测失败不该影响调用方
        out["error"] = "查询 DLL 状态时抛错：%s" % exc
        out["summary"] = "无法判定执行器状态（查询本身失败）。"
        return out

    if not getattr(reply, "ok", False):
        out["error"] = getattr(reply, "error", "") or "status 命令未得到回执"
        out["summary"] = (
            "无法判定执行器状态：连 DLL 的状态查询都没有回执，"
            "问题在通道层（DLL 未加载或未连上 MCP），不在执行器。")
        return out

    data: Optional[dict] = reply.result if isinstance(reply.result, dict) else None
    if data is None:
        out["error"] = "status 返回了非对象内容"
        out["summary"] = "无法判定执行器状态（返回格式非预期）。"
        return out

    out["available"] = True
    out["connected"] = data.get("connected")
    out["inbox"] = data.get("inbox")
    out["outbox"] = data.get("outbox")
    out["raw"] = data

    ago = data.get("poll_ms_ago")
    out["poll_ms_ago"] = ago

    if not isinstance(ago, int):
        # 字段缺失 = 旧版 DLL（心跳是后加的）。如实说不知道，不要拿 inbox 猜：
        # inbox=0 既可能是"执行器刚取完"，也可能是"从没有过执行器"。
        out["executor"] = "unknown"
        out["summary"] = (
            "DLL 未提供心跳字段（很可能是旧版扩展），"
            "无法判定执行器是否在运行；请重新编译并重启游戏。")
        return out

    if ago < 0:
        out["executor"] = "never_started"
        out["summary"] = (
            "执行器**从未启动**：DLL 从没被轮询过。常见原因是游戏停在主菜单/"
            "未加载任务，且启动参数没有拉起执行器。"
            "此时 DLL 直连能力（截图、输入、窗口）仍可用，"
            "但 exec、config_* 这类需要游戏世界的命令不会被处理。")
    elif ago > STALE_MS:
        out["executor"] = "stalled"
        out["summary"] = (
            "执行器**心跳停滞**（上次取命令在 %d ms 前）：它启动过但已经不转了。"
            "可能原因：游戏正在加载/卡住、执行器脚本报错被 supervisor 重启中、"
            "或循环已被迫退出。" % ago)
    else:
        out["executor"] = "running"
        out["summary"] = "执行器运行中（%d ms 前刚取过命令）。" % ago

    return out


def describe_line(health: dict) -> str:
    """把探测结果压成一行，供 exec 超时之类的场景直接附加。"""
    label = {
        "running": "运行中",
        "never_started": "从未启动",
        "stalled": "心跳停滞",
        "unknown": "状态未知",
    }.get(health.get("executor", "unknown"), "状态未知")

    if not health.get("available"):
        return "执行器：无法判定（%s）" % (health.get("error") or "状态查询失败")

    parts = ["执行器：%s" % label]
    if health.get("poll_ms_ago") is not None:
        ago = health["poll_ms_ago"]
        parts.append("上次取命令 %s" % ("从未" if ago < 0 else "%d ms 前" % ago))
    if health.get("inbox") is not None:
        parts.append("inbox=%s" % health["inbox"])
    return "，".join(parts)
