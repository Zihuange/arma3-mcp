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


def register(reg: Registry, idx: CommandIndex, gu, chan: Channel) -> None:  # noqa: ANN001
    """注册执行层工具。chan 由调用方注入（P0 是 NullChannel）。"""

    def _prepare(cmd: str, args: list) -> tuple[dict | None, ToolResult | None]:
        """查库 + 校验 + 过闸门 + 构造负载。失败返回 (None, 错误结果)。"""
        rec = idx.get(cmd)
        if rec is None:
            cands = idx.prefix_candidates(cmd)
            text = f"命令库中没有 {cmd!r}，拒绝执行（不猜命令名）。"
            if cands:
                text += "\n相近的名字：" + "、".join(cands)
            return None, ToolResult.fail(text)

        verdict = gu.check(rec["n"])
        if not verdict.allowed:
            return None, ToolResult.fail(
                f"闸门拒绝执行 {rec['n']}：{verdict.reason}"
                + (f"\n所需开关：{verdict.needs_flag}=1" if verdict.needs_flag else ""))

        check = check_call(rec, args)
        if not check["ok"]:
            lines = [f"{rec['n']} 参数校验不通过，未执行。各调用形式的拒绝原因："]
            for r in check["results"]:
                lines.append(f"  · {r['code']}")
                for why in r["reasons"]:
                    lines.append(f"      ✗ {why}")
            lines.append("\n先用 cmd_info 看签名，再用 cmd_check 试参数。")
            return None, ToolResult.fail("\n".join(lines))

        variants = signature_variants(rec)
        try:
            built = build_command(rec["n"], args, variants, check["matched_index"])
        except SerializeError as exc:
            return None, ToolResult.fail(f"参数无法序列化：{exc}")

        return {"record": rec, "check": check, "built": built,
                "verdict": verdict}, None

    def _do_exec(cmd: str, args: list, dry_run: bool,
                 timeout_s: float) -> ToolResult:
        prepared, err = _prepare(cmd, args)
        if err is not None:
            return err
        assert prepared is not None
        built = prepared["built"]
        verdict = prepared["verdict"]

        if dry_run:
            info = local_preview_command(built["payload"])
            audit("exec.dry_run", {"cmd": built["payload"]["cmd"],
                                   "level": verdict.level})
            return ToolResult.ok(
                ("【预演，未执行】\n"
                 f"表达式：{built['expr']}\n"
                 f"负载：{built['json']}\n"
                 f"分级：{verdict.level}（{ '放行' if verdict.allowed else '拒绝'}）\n"
                 f"负载大小：{info['json_bytes']} 字节\n"
                 "确认无误后去掉 dry_run 再调用。"),
                {"dry_run": True, "payload": built["payload"],
                 "level": verdict.level})

        cid = new_cid()
        reply = chan.send({"cid": cid, "cmd": built["payload"]["cmd"],
                           "args": built["payload"]["args"]}, timeout_s=timeout_s)
        audit("exec", {"cid": reply.cid, "cmd": built["payload"]["cmd"],
                       "level": verdict.level, "ok": reply.ok,
                       "elapsed_ms": reply.elapsed_ms,
                       "channel": reply.channel,
                       "error": reply.error[:200]})

        if not reply.ok:
            return ToolResult.fail(
                f"执行失败（{built['payload']['cmd']}）：{reply.error}",
                reply.to_dict())
        return ToolResult.ok(
            f"已执行 {built['payload']['cmd']}（cid={reply.cid}，"
            f"{reply.elapsed_ms} ms）\n结果："
            f"{json.dumps(reply.result, ensure_ascii=False)[:1500]}",
            reply.to_dict())

    @reg.tool(
        name="exec",
        description=("在游戏内执行一条引擎命令（结构化调用：命令名 + 位置参数）。"
                     "执行前会查库校验参数并过闸门。强烈建议先用 dry_run=true "
                     "看清将要发送的内容。游戏实体参数用单元素数组，"
                     "如 [[\"u_17\"]]。"),
        input_schema={
            "type": "object",
            "properties": {
                "cmd": {"type": "string", "minLength": 1,
                        "description": "命令名或官方函数名，如 setPosATL"},
                "args": {"type": "array",
                         "description": "位置参数数组"},
                "dry_run": {"type": "boolean",
                            "description": "只校验与预演，不真正执行"},
                "timeout_s": {"type": "number", "minimum": 0.2, "maximum": 60,
                              "description": "等待回执的秒数，默认 5"},
            },
            "required": ["cmd"],
        },
        phase="execute",
    )
    def _exec(args: dict) -> ToolResult:
        return _do_exec(args["cmd"], args.get("args") or [],
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
                    "description": "调用数组，每项 {cmd, args}",
                    "items": {
                        "type": "object",
                        "properties": {
                            "cmd": {"type": "string", "minLength": 1},
                            "args": {"type": "array"},
                        },
                        "required": ["cmd"],
                    },
                },
                "dry_run": {"type": "boolean"},
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
            cmd = call.get("cmd", "")
            sub = _do_exec(cmd, call.get("args") or [], dry,
                           float(args.get("timeout_s", 5.0)))
            results.append({"index": i, "cmd": cmd, "ok": not sub.is_error,
                            "text": sub.text})
        ok_n = sum(1 for r in results if r["ok"])
        lines = [f"批量执行：{ok_n}/{len(results)} 条成功"
                 + ("（预演模式，未真正执行）" if dry else ""), ""]
        for r in results:
            lines.append(f"[{r['index']}] {'✓' if r['ok'] else '✗'} {r['cmd']}")
            for line in r["text"].splitlines():
                lines.append("      " + line)
        return ToolResult.ok("\n".join(lines),
                             {"total": len(results), "ok": ok_n, "results": results})
