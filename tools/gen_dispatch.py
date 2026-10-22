#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""从命令库生成 SQF 静态分发表（启动调用）。

## 为什么是"生成"而不是"手写"

命令覆盖面会持续扩大，手写 `case` 的成本随命令数线性增长。但本仓库不需要
为此放开 `compile`——业界证据是反的：CBA_A3 因安全原因移除了任意代码执行
能力，官方 debug console 是带权限门槛的管理员工具而非通用 API，而同机另一
个实验项目用静态 `switch` 跑完了生产级对抗、一次 `compile` 都没用。

排除了动态执行，剩下的问题就只是"别手写"：本脚本从命令库的**签名**里还原
出调用形式，生成静态分发的 SQF。生成出来的仍是静态代码——可读、可审、可
静态检查，只是不需要人敲。

## 还原调用形式的依据

签名形如 `object setPosATL pos`、`numberA + numberB`、`[_a,_b] call FNC`，
其参数名（已由 knowledge/index.py 解析出）在代码文本中的**出现位置**就是
参数顺序。实测 5579 条签名里 3402 条可据此还原。

## 产出的是"启动调用"，不是"完整命令"

这一点必须写在最前面，否则会高估本脚本的价值：
  ✓ 生成：把参数喂给引擎命令的那一行（`_a setPosATL _b`）
  ✗ 不生成：参数前的实体解析、结果的序列化、命令专属的前置校验
后者无法从签名推断（签名只描述调用形态，不描述语义）。所以本脚本消除的是
"逐条手写调用"的成本，**不是**"新增命令零成本"——每个新命令仍需人工确认
其返回值如何序列化。

用法：
    python3 tools/gen_dispatch.py                     # 统计与抽样报告
    python3 tools/gen_dispatch.py --write             # 写出 SQF 分发表
    python3 tools/gen_dispatch.py --family set        # 只看某个族
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, REPO)

from knowledge.index import default_index, signature_variants  # noqa: E402

OUT_DIR = os.path.join(REPO, "game", "addon", "fnc")

# 生成 SQF 时的参数占位符前缀。用 _p0.._pN 而不是原参数名：原参数名可能
# 是 `numberA`/`_POSITION0` 这类与 SQF 局部变量规则冲突或不可读的名字。
PARAM_PREFIX = "_p"


def arg_names_ok(spec: dict) -> bool:
    """参数名是否可用于定位。

    ⚠ 实测教训：命令库的类型串里含换行与整张 wiki 表格的参数名（如
    `foo:\n{! classwikitable ...`）**不能**用于匹配代码——它们必然匹配不到，
    而"匹配不到就回退到第一个参数名"会让命令名本身被当成参数，
    生成出 `_p0 setAPURTD` 这种连语法都不成立的调用。
    故这里直接拒绝：宁可标为"无法生成"，也不生成错的东西。
    """
    name = (spec.get("name") or "").strip()
    if not name or name == "(未命名)":
        return False
    if "\n" in name or "{" in name or len(name) > 40:
        return False
    return bool(re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", name))


def arg_mapping(var: dict) -> dict[int, str] | None:
    """参数下标 -> 占位符名（_p0 对应**第 0 个参数**，不是第一个出现的名字）。

    ⚠ 这里曾写错过一次：把"代码中的出现序号"当成了占位符编号，于是
    `object setAPURTD value` 里位于中间的 `setAPURTD` 被编成 _p0、真正的
    参数被编成 _p1，生成出 `_p0 setAPURTD` 这种不存在的语法。
    占位符编号必须锚定**参数下标**，出现位置只用来决定"谁放在哪里"。
    """
    code = var.get("code") or ""
    args = var.get("args") or []
    if not code.strip() or not args:
        return None
    if not all(arg_names_ok(a) for a in args):
        return None
    mapping: dict[int, str] = {}
    for idx, spec in enumerate(args):
        if re.search(r"(?<![A-Za-z0-9_])" + re.escape(spec["name"])
                     + r"(?![A-Za-z0-9_])", code) is None:
            return None
        mapping[idx] = "%s%d" % (PARAM_PREFIX, idx)
    return mapping


def build_expr(var: dict, mapping: dict[int, str]) -> str:
    """把签名代码里的参数名换成占位符。占位符编号 = 参数下标。"""
    code = var["code"].strip()
    args = var["args"]
    # 长名先替换，避免前缀冲突（例如 `arrayA` 与 `array`）
    for idx in sorted(mapping, key=lambda i: -len(args[i]["name"])):
        code = re.sub(
            r"(?<![A-Za-z0-9_])" + re.escape(args[idx]["name"])
            + r"(?![A-Za-z0-9_])", mapping[idx], code)
    return code


def classify_signature(var: dict) -> str:
    """签名的形态：statement（可作语句）/ expression（需求值）。

    SQF 里两者差别很大：`_a setPosATL _b` 是语句，`_a + _b` 是表达式。
    语句可直接执行；表达式必须被消费（赋值或作为返回值）。
    """
    code = (var.get("code") or "").strip()
    if not code:
        return "empty"
    ret = (var.get("returns") or "").strip()
    # 有返回类型且不是 Nothing/Nothing 类 → 表达式
    if ret and ret.lower() not in ("nothing", "void", ""):
        return "expression"
    return "statement"


def analyze(family: str | None = None) -> dict:
    idx = default_index()
    rows = []
    for key, rec in idx.records.items():
        if family and idx.family_of(rec["n"]) != family:
            continue
        variants = signature_variants(rec)
        for vi, var in enumerate(variants):
            mapping = arg_mapping(var)
            row = {
                "cmd": rec["n"],
                "family": idx.family_of(rec["n"]),
                "variant": vi,
                "signature": var["code"],
                "returns": var["returns"],
                "kind": classify_signature(var),
                "argc": len(var["args"]),
                "placeholders": (["%s%d" % (PARAM_PREFIX, i)
                                  for i in sorted(mapping)] if mapping else None),
                "expr": build_expr(var, mapping) if mapping else None,
            }
            rows.append(row)
    return {"rows": rows}


def report(data: dict, limit: int = 12) -> None:
    rows = data["rows"]
    total = len(rows)
    ok = [r for r in rows if r["expr"]]
    stmt = [r for r in ok if r["kind"] == "statement"]
    expr = [r for r in ok if r["kind"] == "expression"]
    noargs = [r for r in rows if r["argc"] == 0]

    print("签名总数            : %d" % total)
    print("可生成启动调用      : %d (%.0f%%)" % (len(ok), 100.0 * len(ok) / max(total, 1)))
    print("  其中语句式        : %d   例：%s"
          % (len(stmt), stmt[0]["expr"] if stmt else "-"))
    print("  其中表达式        : %d   例：%s"
          % (len(expr), expr[0]["expr"] if expr else "-"))
    print("无参数（无需调用生成）: %d" % len(noargs))
    print("无法生成            : %d" % (total - len(ok)))
    if family_filter := None:
        pass

    print("\n生成示例（命令 → SQF 调用）：")
    shown = 0
    seen_fams = set()
    for r in ok:
        if r["family"] in seen_fams and len(seen_fams) > 6:
            continue
        print("  %-24s %-10s %s" % (r["cmd"], r["family"], r["expr"][:60]))
        seen_fams.add(r["family"])
        shown += 1
        if shown >= limit:
            break

    print("\n按族统计可生成比例：")
    by_family: dict[str, list[int]] = {}
    for r in rows:
        slot = by_family.setdefault(r["family"], [0, 0])
        slot[0] += 1
        if r["expr"]:
            slot[1] += 1
    for fam, (tot, good) in sorted(by_family.items(),
                                   key=lambda kv: -kv[1][0])[:14]:
        print("  %-12s %5d/%5d  (%.0f%%)" % (fam, good, tot,
                                             100.0 * good / max(tot, 1)))


def write_sqf(data: dict, family: str) -> str:
    """为一个族生成 SQF 分发表。

    生成的代码是**静态**的：每条命令一个 case，调用是字面量拼出来的，
    没有任何 eval。它可被 SQFLint 静态检查，也可以直接审阅。
    """
    rows = [r for r in data["rows"] if r["family"] == family and r["expr"]]
    if not rows:
        return ""
    lines = [
        "/* 自动生成 —— 请勿手工编辑。",
        " *",
        " * 来源：tools/gen_dispatch.py（从命令库签名还原调用形式）",
        " * 生成的原则：只产出**静态**分发，不使用 compile/execVM —— 见 README 的安全模型。",
        " *",
        " * 参数：_fn 目标函数名、_args 参数数组（已由 MCP 侧校验类型）",
        " * 返回：[是否处理, 结果]",
        " */",
        "params [\"_fn\", \"_args\"];",
        "private _handled = true;",
        "private _result = nil;",
        "",
        "switch (toLower _fn) do {",
    ]
    for r in rows:
        n = r["argc"]
        # 占位符编号 == 参数下标（由 arg_mapping 保证），故直接对应取参
        binds = ["        private _p%d = _args param [%d];" % (i, i)
                 for i in range(n)]
        lines.append('    case "%s": {' % r["cmd"].lower())
        lines.append("        // %s" % r["signature"])
        lines.extend(binds)
        if r["kind"] == "expression":
            lines.append("        _result = %s;" % r["expr"])
        else:
            lines.append("        %s;" % r["expr"])
            lines.append("        _result = true;")
        lines.append("    };")
    lines.extend([
        "    default { _handled = false; };",
        "};",
        "",
        "[_handled, _result]",
    ])
    return "\n".join(lines) + "\n"


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="生成 SQF 静态分发表")
    ap.add_argument("--family", default=None, help="只处理某个命令族")
    ap.add_argument("--write", action="store_true", help="写出 SQF 文件")
    ap.add_argument("--json", action="store_true", help="输出结构化结果")
    args = ap.parse_args(argv)

    data = analyze(args.family)
    if args.json:
        print(json.dumps(data, ensure_ascii=False, indent=1))
        return 0

    report(data)
    if args.write:
        os.makedirs(OUT_DIR, exist_ok=True)
        families = {r["family"] for r in data["rows"] if r["expr"]}
        written = []
        for fam in sorted(families):
            content = write_sqf(data, fam)
            if not content:
                continue
            safe = re.sub(r"[^a-z0-9_]", "_", fam.lower())
            path = os.path.join(OUT_DIR, "fn_dispatch_%s.sqf" % safe)
            with open(path, "w", encoding="utf-8") as fh:
                fh.write(content)
            written.append((fam, len(content.splitlines())))
        print("\n已生成 %d 个分发表文件：" % len(written))
        for fam, lines in written[:12]:
            print("  %-12s %4d 行" % (fam, lines))
        if len(written) > 12:
            print("  …（其余 %d 个）" % (len(written) - 12))
    return 0


if __name__ == "__main__":
    sys.exit(main())
