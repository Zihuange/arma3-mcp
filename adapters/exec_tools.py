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
import re
from typing import Any

from mcpcore.registry import Registry, ToolResult
from knowledge.index import CommandIndex, check_call, signature_variants
from knowledge.expr import split_tokens  # noqa: F401  (转出给测试与调用方)
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


def expand_placeholders(expr: str, arg_count: int) -> str:
    """把 `_pN` 占位符展开成 `(_this select N)`。

    ## 为什么必须展开（而不是指望 SQF 侧理解 `_p0`）

    `_p0` **不是** SQF 变量：没有任何东西会把它们绑到实参上。此前直接把原表达式
    `compile` 掉，结果是**一切带参数的表达式都在引擎里报**
    「表达式中未定义的变量：_p0」，而执行器仍回 `ok=true`、结果 `nil` ——
    调用方看到的是"成功地什么都没做"。无参表达式不受影响，所以只用过无参命令的
    测试看不出来（实测：`worldName` 正常，`getPos _p0` 返回 nil）。

    展开成 `(_this select N)` 用引擎原生方式取参数：`_this` 就是实参数组
    （`fn_run` 用 `_resolved call _code` 执行，参数数组由引擎传入 `_this`）。
    这样**参数值不进代码**，拼接注入在这里没有立足之地。

    放在 Python 侧的理由：同样的字符串处理在 SQF 里跑不出预期结果（实测
    `[A3MCP][EXPAND] raw=typeName _p0 -> typeName _p0`，即引擎里那个实现没识别出
    占位符），而这一侧可以用测试逐条覆盖。
    """
    def _sub(match: "re.Match[str]") -> str:
        idx = int(match.group(1))
        if idx >= arg_count:
            return match.group(0)      # 越界的原样保留：校验器本该先拦下
        return "(_this select %d)" % idx

    # 只认"独立成词"的 _pN：后面不能紧跟字母/数字/下划线（`_p0abc` 不是占位符），
    # 前面不能是词字符（避免把 `x_p0` 这类名字切开）。
    out = re.sub(r"(?<![A-Za-z0-9_])_p(\d+)(?![A-Za-z0-9_])", _sub, expr)

    # `call` 的右操作数要单独处理。
    #
    # 引擎要求它**在编译期可确定**：`_p0 call _p1` 直接展开成
    # `(_this select 0) call (_this select 1)` 会被拒绝，实测报
    # `Error position: <call (_this select 1)>`——右边是运行时表达式就不认。
    # 所以先经 getVariable 把函数取回来：`call (missionNamespace getVariable X)`。
    # 这一步在引擎里成立（实测 `missionNamespace getVariable "cba_fnc_vectadd"`
    # 返回 CODE 类型），而函数名仍然只是**数据**，没有被编译成代码。
    #
    # 函数名必须是**全小写**：命名空间里的函数名是小写的（见
    # allVariables 实测：bis_fnc_loop / cba_fnc_vectadd），带大写查不到。
    def _call_target(match: "re.Match[str]") -> str:
        # 取回的参数表达式要**再包一层括号**：`getVariable (_this select 1)`。
        # 少了它就成了 `getVariable _this select 1`（先取变量名再取下标），语义错了。
        return "call (missionNamespace getVariable (%s))" % match.group(1)

    # ⚠ 两处括号要分清：外层字面括号必须转义（`\(` `\)`），而捕获组要包含
    # **完整的 `_this select N`**——第一版只捕获了下标，替换出来是
    # `getVariable 1`（少了个"取哪个"的表达式）。实测踩到过。
    out = re.sub(r"(?<![A-Za-z0-9_])call\s+\((_this select \d+)\)",
                 _call_target, out)
    return out


def register(reg: Registry, idx: CommandIndex, gu, chan: Channel) -> None:  # noqa: ANN001
    """注册执行层工具。chan 由调用方注入（P0 是 NullChannel）。"""

    def _check_expr(expr: str, argc: int, argv: list) -> ToolResult | None:
        """校验表达式（这一步在 MCP 侧先做一遍，游戏侧还会再校验一次）。

        argv 必须传进来：`call` 的目标函数名在**数据**里，不看数据就没法核对
        ——那是本框架里唯一一处"命令名之外还要看值"的判定。
        """
        from knowledge.expr import ExprError, validate, whitelist_from_library
        try:
            validate(expr, argc, whitelist_from_library(), args=argv)
        except ExprError as exc:
            # call 被拦时补一句上下文：它需要单独的闸门，而不是"表达式写错了"，
            # 否则使用者会反复改表达式，而问题其实在开关上。
            extra = ""
            if " call" in " " + expr.lower() and "call" in expr.lower():
                extra = ("\n提示：call 是有条件放行的一级，需要 A3MCP_ENGINE_CALL=1"
                         "（或 A3MCP_PROFILE=debug），且目标函数名不得属于 "
                         "CALL_DENY（bis_fnc_exec* / spawn* / dbg_* 等）。")
            return ToolResult.fail(
                "表达式校验未通过：%s\n"
                "表达式里每个标识符必须是 _p0.._pN 占位符，或白名单内的引擎命令；"
                "禁止分号（多语句）与字符串字面量（参数必须是数据）。%s"
                % (exc, extra))
        if "call" in expr.lower() and not gu.engine_call:
            return ToolResult.fail(
                "表达式用到 call：它是**有条件放行**的一级（参数是函数引用，"
                "必须逐个核对函数名），当前不会执行。\n"
                "用 A3MCP_ENGINE_CALL=1 打开，或改用 A3MCP_PROFILE=debug。\n"
                "与之相对，compile / spawn / execVM 仍是硬禁，任何开关都放不开。")
        return None

    def _do_exec(expr: str, args: list, dry_run: bool,
                 timeout_s: float) -> ToolResult:
        if not isinstance(expr, str) or not expr.strip():
            return ToolResult.fail("缺少 expr（要执行的表达式文本）")
        if not isinstance(args, list):
            return ToolResult.fail("args 必须是数组")

        bad = _check_expr(expr, len(args), args)
        if bad is not None:
            return bad

        # 下发前展开占位符：`_p0` 不是 SQF 变量，不展开的话引擎里必然报
        # "未定义的变量：_p0"，而执行器仍回成功、结果 nil（见 expand_placeholders）。
        code = expand_placeholders(expr, len(args))

        if dry_run:
            audit("exec.dry_run", {"expr": expr, "argc": len(args)})
            return ToolResult.ok(
                "【预演，未执行】\n"
                "表达式：%s\n"
                "参数  ：%s\n"
                "下发形态：%s\n"
                "校验  ：通过（MCP 侧）——游戏侧还会再校验一次\n"
                "确认无误后去掉 dry_run 再调用。"
                % (expr, json.dumps(args, ensure_ascii=False), code),
                {"dry_run": True, "expr": expr, "code": code, "args": args})

        cid = new_cid()
        # 参数数组的形态：[**展开后**的表达式, 实参数组]
        #
        # 展开必须在下发前做：SQF 侧拿到的应当是 `(_this select 0) setPosATL _p1`
        # 这种引擎能直接执行的形式。原表达式（含 _pN）仍留在审计里，便于对账。
        reply = chan.send({"cid": cid, "cmd": "exec", "args": [code, args]},
                          timeout_s=timeout_s)
        audit("exec", {"cid": reply.cid, "expr": expr, "code": code,
                       "argc": len(args),
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
