#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""执行层工具。

链路顺序是刻意的，每一步都能拦下错误，且拦截理由**面向模型可读**：
    查库 → 校验参数 → 过闸门 → （可选 dry-run 到此为止）→ 构造负载 → 送通道

`dry_run` 默认 false 但强烈建议先用它：它把"最终会发给引擎的东西"摊开，
让参数错误在通道之前暴露，而不是进了游戏才炸。
"""

from __future__ import annotations

import json
from typing import Any

from mcpcore.registry import Registry, ToolResult
from knowledge.index import CommandIndex, check_call, signature_variants
from knowledge.serialize import SerializeError, build_command
from adapters.channel import Channel, local_preview_command, new_cid
from guard import audit

# 下行队列在游戏侧是有上限的（P1 实测标定，见 docs/decisions.md）。
# 超过它就会**丢最老的命令且无回报**——所以批量默认取保守值并在超限时拒绝。
DEFAULT_BATCH_MAX = 8
HARD_BATCH_MAX = 32

# ---------------------------------------------------------------------------
# 无头环境（专用服务器）下的"静默无效"警告
#
# 普查发现有一类表达式在服务器上**不报错、却什么都不会发生**（见
# docs/server-capabilities.md）：
#   · hint / systemChat 一类 → 返回 nil，无效果（客户端上会弹消息）
#   · 引用 player 的表达式 → 返回**看似合理的假值**（getPos player → [0,0,0]、
#     side player → "SIDE"），调用方完全可能当成真实数据
#
# 这与本项目一路在打击的失败模式同源：没有错误信息，只有不对的结果。
#
# ⚠ 两个清单**只收实测验证过的条目**。没验证过的不往里加 —— 误报会让调用方
# 开始忽略全部警告，那比没有警告更糟。
_HEADLESS_NO_EFFECT = frozenset({
    "hint", "systemchat",          # 实测：返回 nil、不报错、屏幕上不会有任何东西
    "forcemap", "openmap",         # 实测：同上（地图是给玩家看的，服务器上没有屏幕）
})

# 这些标识符一旦出现在表达式里，无头环境下的结果就不可信（没有玩家可言）。
_HEADLESS_PLAYER_TOKENS = frozenset({
    "player",                      # 实测：getPos player→[0,0,0]；side player→"SIDE"
})


def headless_caveat(expr: str, chan) -> str:  # noqa: ANN001
    """表达式在无头环境下会"静默无效"时，返回一段附注；否则返回空串。

    先做**纯字符串**匹配再探测形态：绝大多数表达式不命中清单，就不必为它们
    多花一次往返（形态探测虽有缓存，仍是一次 DLL 调用）。
    """
    import re as _re

    tokens = {t.lower() for t in _re.findall(r"[A-Za-z_][A-Za-z0-9_]*", expr)}
    no_effect = sorted(tokens & _HEADLESS_NO_EFFECT)
    playerish = sorted(tokens & _HEADLESS_PLAYER_TOKENS)
    if not no_effect and not playerish:
        return ""

    from adapters import health as _health
    has_ui, _why = _health.has_ui(chan)
    if has_ui:
        return ""                  # 客户端上这些都正常，提示就是噪音

    lines = ["", "⚠ 无头环境提示："]
    if no_effect:
        lines.append(
            "  这个表达式用到 %s —— 在专用服务器上它**返回 nil 且不报错**，"
            "屏幕上不会有任何东西（需要进程内有玩家才有意义）。"
            % "、".join(no_effect))
    if playerish:
        lines.append(
            "  它引用了 %s，而当前环境**没有玩家**（isNull player 为真）："
            "相关返回值是**假值而非报错**，例如 getPos player 会给出 [0,0,0]。"
            "不要把这类结果当成真实数据。"
            % "、".join(playerish))
    return "\n".join(lines)


def register(reg: Registry, idx: CommandIndex, gu, chan: Channel) -> None:  # noqa: ANN001
    """注册执行层工具。chan 由调用方注入（P0 是 NullChannel）。"""

    def _check_expr(expr: str, argc: int) -> ToolResult | None:
        """校验表达式（这一步在 MCP 侧先做一遍，游戏侧还会再校验一次）。"""
        from knowledge.expr import ExprError, validate, whitelist_from_library
        try:
            validate(expr, argc, whitelist_from_library())
        except ExprError as exc:
            return ToolResult.fail(
                "表达式校验未通过：%s\n"
                "表达式里每个标识符必须是 _p0.._pN 占位符，或白名单内的引擎命令；"
                "禁止分号（多语句）与字符串字面量（参数必须是数据）。" % exc)
        return None

    def _do_exec(expr: str, args: list, dry_run: bool,
                 timeout_s: float) -> ToolResult:
        if not isinstance(expr, str) or not expr.strip():
            return ToolResult.fail("缺少 expr（要执行的表达式文本）")
        if not isinstance(args, list):
            return ToolResult.fail("args 必须是数组")

        bad = _check_expr(expr, len(args))
        if bad is not None:
            return bad

        if dry_run:
            audit("exec.dry_run", {"expr": expr, "argc": len(args)})
            return ToolResult.ok(
                "【预演，未执行】\n"
                "表达式：%s\n"
                "参数  ：%s\n"
                "校验  ：通过（MCP 侧）——游戏侧还会再校验一次\n"
                "确认无误后去掉 dry_run 再调用。" % (expr, json.dumps(args, ensure_ascii=False)),
                {"dry_run": True, "expr": expr, "args": args})

        cid = new_cid()
        # 参数数组的形态：[表达式, 实参数组]
        reply = chan.send({"cid": cid, "cmd": "exec", "args": [expr, args]},
                          timeout_s=timeout_s)
        audit("exec", {"cid": reply.cid, "expr": expr, "argc": len(args),
                       "ok": reply.ok, "elapsed_ms": reply.elapsed_ms,
                       "channel": reply.channel, "error": reply.error[:200]})

        caveat = headless_caveat(expr, chan)

        if not reply.ok:
            # 超时是这里最常见、也最没有信息量的失败：只说"没等到回执"，
            # 让人分不清是网络问题还是游戏里根本没人执行。补一次**直连**的
            # status 探测（不依赖执行器，所以执行器死着也答得出来），
            # 把结论直接写进错误里——不该让调用方自己去猜去哪查。
            from adapters import health as _health
            h = _health.probe(chan)
            hint = ""
            if h.get("executor") in ("never_started", "stalled"):
                hint = ("\n\n诊断：%s" % h["summary"])
            elif h.get("available"):
                hint = ("\n\n诊断：%s ——命令已送达 DLL 却没能拿到回执，"
                        "多半是这条命令在游戏侧执行出错或耗时过长。"
                        % _health.describe_line(h))
            return ToolResult.fail("执行失败：%s%s" % (reply.error, hint),
                                   reply.to_dict())
        return ToolResult.ok(
            "已执行（cid=%s，%d ms）\n结果：%s%s"
            % (reply.cid, reply.elapsed_ms,
               json.dumps(reply.result, ensure_ascii=False)[:1500], caveat),
            reply.to_dict())

    @reg.tool(
        name="exec",
        description=("在游戏内执行一条**表达式**（动态表达式方案）。"
                     "表达式里用 _p0/_p1… 作参数占位符，标识符必须落在引擎命令"
                     "白名单内；参数以**数据**传入 args，不得写进表达式文本。"
                     "例：expr=\"_p0 setDamage _p1\", args=[[\"u_1\"], [0.5]]。"
                     "实体用单元素数组承载。建议先 dry_run=true 预演。"),
        input_schema={
            "type": "object",
            "properties": {
                "expr": {"type": "string", "minLength": 1,
                         "description": "表达式，如 _p0 doMove _p1"},
                "args": {"type": "array",
                         "description": "实参数组，按 _p0.._pN 对应，如 [[\"u_1\"], [100,200,0]]"},
                "dry_run": {"type": "boolean", "description": "只校验与预演"},
                "timeout_s": {"type": "number", "minimum": 0.2, "maximum": 60,
                              "description": "等待回执秒数，默认 5"},
            },
            "required": ["expr"],
        },
        phase="execute",
    )
    def _exec(args: dict) -> ToolResult:
        return _do_exec(args["expr"], args.get("args") or [],
                        bool(args.get("dry_run")), float(args.get("timeout_s", 5.0)))

    @reg.tool(
        name="exec_batch",
        description=("按顺序执行多条命令，逐条返回结果（前一条失败不影响后续，"
                     "但会在汇总里标出）。批量是为规避引擎侧下行队列上限："
                     "一次下发过多命令会导致**旧命令被静默丢弃**，故默认上限 8 条。"),
        input_schema={
            "type": "object",
            "properties": {
                "calls": {
                    "type": "array",
                    "description": "调用数组，每项 {expr, args}",
                    "items": {
                        "type": "object",
                        "properties": {
                            "expr": {"type": "string", "minLength": 1},
                            "args": {"type": "array"},
                        },
                        "required": ["expr"],
                    },
                },
                "dry_run": {"type": "boolean"},
                "timeout_s": {"type": "number", "minimum": 0.2, "maximum": 60,
                              "description": "每条命令等待回执的秒数，默认 5"},
                "max_calls": {"type": "integer", "minimum": 1,
                              "maximum": HARD_BATCH_MAX,
                              "description": f"允许的最大条数，默认 {DEFAULT_BATCH_MAX}"},
            },
            "required": ["calls"],
        },
        phase="execute",
    )
    def _batch(args: dict) -> ToolResult:
        calls = args["calls"]
        limit = args.get("max_calls", DEFAULT_BATCH_MAX)
        if len(calls) > limit:
            return ToolResult.fail(
                f"一次最多下发 {limit} 条命令（收到 {len(calls)} 条）。\n"
                "原因：引擎侧下行队列有上限，超量会导致**旧命令被丢弃且无回报**。"
                "请拆成多批，或在确认通道能力后用 max_calls 提高上限（上限 "
                f"{HARD_BATCH_MAX}）。")
        dry = bool(args.get("dry_run"))
        results = []
        for i, call in enumerate(calls, 1):
            expr = call.get("expr", "")
            sub = _do_exec(expr, call.get("args") or [], dry,
                           float(args.get("timeout_s", 5.0)))
            results.append({"index": i, "expr": expr, "ok": not sub.is_error,
                            "text": sub.text})
        ok_n = sum(1 for r in results if r["ok"])
        lines = [f"批量执行：{ok_n}/{len(results)} 条成功"
                 + ("（预演模式，未真正执行）" if dry else ""), ""]
        for r in results:
            lines.append(f"[{r['index']}] {'✓' if r['ok'] else '✗'} {r['expr']}")
            for line in r["text"].splitlines():
                lines.append("      " + line)
        return ToolResult.ok("\n".join(lines),
                             {"total": len(results), "ok": ok_n, "results": results})


def register_channel_tools(reg: Registry, chan: Channel) -> None:
    """注册与游戏侧直接相关的查看工具。

    为什么必须单独有它：P1 起游戏侧会**主动上行**事件（命令错误、队列丢弃、
    状态上报）。这些信息不在任何命令的回执里，只能靠拉取事件流才能看到——
    不提供这个入口，使用者就只能看到"命令超时"，而看不到超时的真实原因。
    """

    @reg.tool(
        name="game_events",
        description=("拉取游戏侧主动上行的事件（命令错误、队列水位、状态上报等），"
                     "取走后即清空。命令超时或行为异常时先看这里——"
                     "游戏侧的错误**不在回执里**。"),
        input_schema={
            "type": "object",
            "properties": {
                "limit": {"type": "integer", "minimum": 1, "maximum": 2000,
                          "description": "最多返回多少条（默认 200，取最近的）"},
                "filter": {"type": "string",
                           "description": "只返回包含该子串的事件行，如 evt: 或 err"},
            },
        },
        phase="execute",
    )
    def _events(args: dict) -> ToolResult:
        try:
            events = chan.drain_events(limit=args.get("limit", 200))
        except AttributeError:
            return ToolResult.ok("当前通道不支持事件拉取（未实现 drain_events）。",
                                 {"events": []})
        needle = (args.get("filter") or "").strip()
        if needle:
            events = [e for e in events if needle in e]
        if not events:
            return ToolResult.ok(
                "没有新事件。\n（游戏侧未连接、或确实还没有上行事件。）",
                {"events": [], "count": 0})
        lines = ["游戏侧事件 %d 条（已取走）：" % len(events), ""]
        lines.extend("  " + e for e in events)
        return ToolResult.ok("\n".join(lines),
                             {"events": events, "count": len(events)})
