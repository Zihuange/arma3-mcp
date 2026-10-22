#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""知识层工具（MCP 工具定义 + 渲染）。

这一层的定位：让模型**在不猜的前提下**写出正确的引擎调用。
三个工具对应三种需求——找命令（family/search）、看签名（info/params）、
验参数（check/validate）。渲染文本的目标是"模型读一遍就知道下一步"。
"""

from __future__ import annotations

import json
from typing import Any, Optional

from guard import classify
from mcpcore.registry import Registry, ToolResult
from .capabilities import CapabilityMatrix
from .index import CommandIndex, check_call, signature_variants, wiki_url

ENTITY_NOTE = (
    "游戏实体（Object/Group/Control…）用**单元素数组**承载，例如 "
    "[[\"u_17\"]] 表示实体 u_17。实体名就是游戏内该对象的变量名"
    "（任务编辑器里给对象起的名称）；P0 阶段还没有名字登记表，"
    "名字未定义时执行会失败并如实回报。"
)


def _fmt_signature(var: dict) -> str:
    args = []
    for a in var["args"]:
        t = a["raw_type"] or ("未标注" if not a["type_known"] else a["type"])
        body = f"{a['name']}: {t}"
        args.append(f"[{body}]" if a["optional"] else body)
    ret = f" → {var['returns']}" if var["returns"] else ""
    return f"{var['code']}  ({', '.join(args)}){ret}" if args else \
           f"{var['code']}{ret}"


def render_info(rec: dict, idx: CommandIndex, name: str) -> str:
    lines = [f"# {rec['n']}"]
    lines.append(f"类型：{rec['ty']}　来源：{rec['src']}"
                 + (f"　Arma 3 起：{idx.arma3_since(rec)}" if idx.arma3_since(rec) else ""))
    games = idx.games(rec)
    if games:
        lines.append(f"出现于：{', '.join(games)}")
    lines.append("")
    # 说明给**链接**而不是正文：本仓库不分发 BI wiki 的描述文本（见 NOTICE）。
    # 链接由命令名直接拼出，确定性映射，不需要在数据里存 URL。
    lines.append("说明：见 wiki 原文 → " + wiki_url(rec["n"]))
    lines.append("")
    variants = signature_variants(rec)
    if not variants:
        lines.append("⚠ 该命令没有签名数据。不要凭记忆拼参数——请查 wiki 原文。")
    else:
        lines.append(f"调用形式（{len(variants)} 种）：")
        for i, var in enumerate(variants, 1):
            lines.append(f"  {i}. {_fmt_signature(var)}")
            for a in var["args"]:
                if a["desc"]:
                    lines.append(f"       · {a['name']}：{a['desc']}")
                if a["default"] is not None:
                    lines.append(f"       · {a['name']} 默认值：{a['default']}")
    lines.append("")
    lines.append("实体参数：" + ENTITY_NOTE)
    lines.append("下一步：用 cmd_check 验证你的参数，再用 exec 执行。")
    return "\n".join(lines)


def register(reg: Registry, idx: CommandIndex, gu,
             matrix: Optional[CapabilityMatrix] = None) -> None:  # noqa: ANN001
    """把知识层工具注册进注册表。gu 为闸门对象，matrix 为能力矩阵。"""

    @reg.tool(
        name="cmd_families",
        description=("列出 Arma 3 引擎命令的族（目录页）。当你不确定某类能力"
                     "对应哪个命令时，先看这里再检索。"),
        input_schema={"type": "object", "properties": {}},
        phase="knowledge",
    )
    def _families(_args: dict) -> ToolResult:
        fams = idx.families()
        total = idx.count()
        lines = [f"命令库共 {total} 条（含 BI 官方函数、CBA、ACE3）。族清单：", ""]
        for f in fams:
            lines.append(f"  {f['family']:10s} {f['count']:5d}  {f['zh']}　例："
                         + "、".join(f["samples"][:4]))
        lines.append("")
        lines.append("用 cmd_search 在族内检索，或直接 cmd_info 查具体命令。")
        return ToolResult.ok("\n".join(lines), {"total": total, "families": fams})

    @reg.tool(
        name="cmd_search",
        description=("按关键词检索引擎命令与官方函数（5000+ 条）。支持用 family "
                     "限定族、用 kind 区分 command/function。"),
        input_schema={
            "type": "object",
            "properties": {
                "query": {"type": "string", "minLength": 1,
                          "description": "关键词（英文命令名或描述片段）"},
                "family": {"type": "string",
                           "description": "限定命令族，如 set / create / ctrl"},
                "kind": {"type": "string", "enum": ["command", "function"],
                         "description": "只找引擎命令或只找函数"},
                "limit": {"type": "integer", "minimum": 1, "maximum": 100,
                          "description": "返回条数上限，默认 25"},
            },
            "required": ["query"],
        },
        phase="knowledge",
    )
    def _search(args: dict) -> ToolResult:
        hits = idx.search(args["query"], family=args.get("family"),
                          kind=args.get("kind"), limit=args.get("limit", 25))
        if not hits:
            hint = idx.prefix_candidates(args["query"])
            text = f"没有匹配 {args['query']!r} 的命令。"
            if hint:
                text += "\n相近的名字：" + "、".join(hint)
            text += ("\n提示：命令库源自 BI wiki，未必收录全部引擎命令。"
                     "若确认存在，请让人类查 wiki 原文。")
            return ToolResult.ok(text, {"hits": []})
        lines = [f"匹配 {len(hits)} 条（query={args['query']!r}）："]
        for h in hits:
            lines.append(f"  {h['name']:34s} [{h['type'][:4]}/{h['source']:5s}] "
                         f"{h['summary'][:70]}")
        lines.append("")
        lines.append("用 cmd_info 看签名。")
        return ToolResult.ok("\n".join(lines), {"hits": hits})

    @reg.tool(
        name="cmd_info",
        description=("查看一条命令的完整签名：所有调用形式、每个参数的类型与说明、"
                     "返回类型、引入版本、所属来源（core/CBA/ACE）。"
                     "写任何 SQF 调用之前都应先看它。"),
        input_schema={
            "type": "object",
            "properties": {"cmd": {"type": "string", "minLength": 1,
                                   "description": "命令名，如 setPosATL"}},
            "required": ["cmd"],
        },
        phase="knowledge",
    )
    def _info(args: dict) -> ToolResult:
        rec = idx.get(args["cmd"])
        if rec is None:
            cands = idx.prefix_candidates(args["cmd"])
            text = f"命令库中没有 {args['cmd']!r}。"
            if cands:
                text += "\n相近的名字：" + "、".join(cands)
            else:
                text += ("\n命令库源自 BI wiki，可能未收录该命令——"
                         "**这不等于命令不存在**。需要确认时请查 wiki 原文。")
            return ToolResult.fail(text)
        gate = classify(rec["n"])
        body = render_info(rec, idx, args["cmd"])
        body += f"\n\n闸门分级：{gate}"
        return ToolResult.ok(body, {"record": rec, "level": gate})

    @reg.tool(
        name="cmd_check",
        description=("在**不执行**的前提下验证一组参数能否匹配某条命令的签名。"
                     "返回匹配到的调用形式、逐条拒绝原因（若失败）。"
                     "参数用位置数组，实体用单元素数组。"),
        input_schema={
            "type": "object",
            "properties": {
                "cmd": {"type": "string", "minLength": 1},
                "args": {"type": "array",
                         "description": "位置参数数组，如 [[\"u_17\"], [100,200,0]]"},
            },
            "required": ["cmd", "args"],
        },
        phase="knowledge",
    )
    def _check(args: dict) -> ToolResult:
        rec = idx.get(args["cmd"])
        if rec is None:
            return ToolResult.fail(f"命令库中没有 {args['cmd']!r}。")
        result = check_call(rec, args["args"])
        result["cmd"] = rec["n"]
        lines = [f"{rec['n']} 参数校验：{'通过' if result['ok'] else '不通过'}"]
        if result["matched_index"] is not None:
            var = signature_variants(rec)[result["matched_index"]]
            lines.append(f"匹配形式：{_fmt_signature(var)}")
        if result["note"]:
            lines.append(result["note"])
        if not result["ok"]:
            lines.append("")
            lines.append("各调用形式的拒绝原因：")
            for r in result["results"]:
                lines.append(f"  · {r['code']}")
                for why in r["reasons"]:
                    lines.append(f"      ✗ {why}")
        else:
            lines.append("")
            lines.append("可以执行：exec(cmd=…, args=…)")
        return ToolResult.ok("\n".join(lines), result)

    @reg.tool(
        name="cmd_gate",
        description=("查询某条命令当前是否被放行、属于哪一级（只读/写/EXOTIC/硬禁），"
                     "以及需要哪个开关。执行前若不确定，先问它。"),
        input_schema={
            "type": "object",
            "properties": {"cmd": {"type": "string", "minLength": 1}},
            "required": ["cmd"],
        },
        phase="knowledge",
    )
    def _gate(args: dict) -> ToolResult:
        name = args["cmd"]
        rec = idx.get(name)
        resolved = rec["n"] if rec else name
        verdict = gu.check(resolved)
        level = verdict.level
        lines = [f"{resolved}：{'放行' if verdict.allowed else '拒绝'}"
                 f"（分级 {level}）"]
        if rec is None:
            lines.append("注意：该命令不在自带命令库中，分级由命名规则推断得出。")
        if verdict.reason:
            lines.append(verdict.reason)
        if verdict.needs_flag:
            lines.append(f"所需开关：{verdict.needs_flag}=1")
        if level == "forbidden":
            lines.append("硬禁命令没有例外——任何开关都放不开，请改用结构化调用。")
        return ToolResult.ok("\n".join(lines),
                             {"cmd": resolved, "verdict": verdict.to_dict(),
                              "in_library": rec is not None})


def register_capabilities(reg: Registry, matrix: CapabilityMatrix) -> None:
    """注册能力矩阵工具。

    与 cmd_info 的分工：cmd_info 回答「这条命令怎么调」，
    本工具回答「这件事能不能做、该在哪一层做」——后者查不到是常态，
    因为限制往往来自"整族命令都不存在"而不是某条命令的参数。
    """

    @reg.tool(
        name="capability_matrix",
        description=("查询某项操作在引擎层面是否可行，以及该在哪一层实现。"
                     "带 query 时按名称/关键词模糊查找，不带则列出全部条目。"
                     "做自动化之前先问它，可以避免把时间花在引擎根本做不到的事上。"),
        input_schema={
            "type": "object",
            "properties": {
                "query": {"type": "string",
                          "description": "能力名或关键词，如 点击 / 开火 / UI / 输入"},
            },
        },
        phase="knowledge",
    )
    def _matrix(args: dict) -> ToolResult:
        query = (args.get("query") or "").strip()
        if not query:
            lines = ["能力矩阵（结论均已核对命令库）：", ""]
            for entry in matrix.entries:
                mark = {"yes": "✓", "partial": "△", "no": "✗"}[entry["engine"]]
                lines.append(
                    f"  {mark} {entry['name']:24s} "
                    f"{_short_layer(entry['layer']):12s} "
                    f"需 A3 {entry.get('since') or '-'}")
            lines.append("")
            lines.append("用 query 参数看某一条的详情。")
            return ToolResult.ok("\n".join(lines),
                                 {"entries": [{k: e[k] for k in
                                               ("key", "name", "engine", "layer",
                                                "since")}
                                              for e in matrix.entries]})
        hits = matrix.find(query)
        if not hits:
            keys = "、".join(e["key"] for e in matrix.entries)
            return ToolResult.ok(
                f"能力矩阵中没有匹配 {query!r} 的条目。\n可用条目：{keys}\n"
                f"（若你问的是某条具体命令怎么用，请用 cmd_info。）",
                {"hits": []})
        text = "\n\n".join(matrix.render(entry) for entry in hits)
        return ToolResult.ok(text, {"hits": [e["key"] for e in hits]})


def _short_layer(layer: str) -> str:
    return {"engine": "引擎层", "windows": "Windows 层",
            "forbidden": "禁用"}.get(layer, layer)
