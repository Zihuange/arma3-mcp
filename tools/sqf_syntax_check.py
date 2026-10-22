#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""用真实 SQF 解析器检查**表达式**的语法（只关心语法，不关心类型）。

## 为什么需要它

B 方案（动态表达式 + `compile`）的最大风险不是注入——那由
`knowledge/expr.py` 的词法白名单挡着——而是**表达式语法本身写错了**。
这类错误在方案 A（静态分发）里由编译器在构建期挡住；动态表达式没有编译器，
只能等运行时 `compile` 失败，而那时已经在游戏里了。

本工具把这件事提前到本机：把表达式塞进一个最小 SQF 文件，用 SQFLint 解析，
**只筛语法类诊断**，忽略类型/参数/未定义变量类的诊断。

## 为什么要忽略一部分诊断

表达式里的占位符 `_p0`、`_p1` 在检查时必然"未定义"，参数个数与命令也不一定
匹配（`_p0` 被当成数字用）。这些是**检查方式的产物**，不是表达式的缺陷。
所以判据刻意收窄为：
    Encountered …            —— 解析中断（语法错误）
    Expected …               —— 缺少必需的语法成分
    not a valid combination  —— 词法单元组合不成立
其余一律忽略并在报告里计数，避免"把检查器的类型推断当成语法结论"。

用法：
    python3 tools/sqf_syntax_check.py --expr '_p0 setPosATL _p1' --args 2
    python3 tools/sqf_syntax_check.py --batch      # 用命令库批量验证
"""

from __future__ import annotations

import argparse
import os
import re
import subprocess
import sys
import tempfile

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, REPO)

# 检查器路径来源：环境变量优先，其次同机既有的检查脚本候选。
# ⚠ 这是**验证期可选依赖**，不是运行期依赖：服务器本身不需要它；
#   检查器缺失时本工具明确报错，不静默降级（见 docs/decisions.md 的独立性边界）。
SQFCHECK = os.environ.get("SQF_MCP_CHECK", "")
_SQFLINT_CANDIDATES = (
    "<sqf-skill>/scripts/sqfcheck.py",
    os.path.expanduser("~/arma3-sqf-skill/scripts/sqfcheck.py"),
)

# 只认这三类为"语法问题"
SYNTAX_MARKERS = ("Encountered", "Expected", "not a valid combination")

# 占位符替换用的哑值：让解析器能把表达式读完。选 objNull/1 是因为它们在
# SQF 里是任意命令都能接受的最"中性"的值，能最大化走完解析路径。
DUMMY_FIRST = "objNull"
DUMMY_REST = "1"


def _checker_path() -> str | None:
    for candidate in (SQFCHECK,) + _SQFLINT_CANDIDATES:
        if candidate and os.path.isfile(candidate):
            return candidate
    return None


def _dummy_expr(expr: str) -> str:
    """把占位符换成哑值，供解析器消费。"""
    def repl(m: re.Match) -> str:
        return DUMMY_FIRST if m.group(1) == "0" else DUMMY_REST
    return re.sub(r"_p(\d+)", repl, expr)


def check_expr(expr: str) -> dict:
    """返回 {ok, syntax_errors, other_diags, tool}。工具不可用时 ok=False 且说明原因。"""
    checker = _checker_path()
    if checker is None:
        return {"ok": False, "unavailable": True,
                "reason": "找不到 SQF 检查脚本（用 SQF_MCP_CHECK 指定，"
                          "或安装一个静态检查器；这是验证期的可选依赖）"}

    body = _dummy_expr(expr)
    source = "// 自动生成：表达式语法检查（哑值替换占位符）\n%s;\n" % body
    with tempfile.NamedTemporaryFile("w", suffix=".sqf", delete=False,
                                     encoding="utf-8") as fh:
        fh.write(source)
        path = fh.name
    try:
        proc = subprocess.run([sys.executable, checker, path],
                              capture_output=True, text=True, timeout=300)
        out = (proc.stdout or "") + (proc.stderr or "")
    except (OSError, subprocess.SubprocessError) as exc:
        return {"ok": False, "unavailable": True, "reason": "检查器执行失败：%s" % exc}
    finally:
        try:
            os.unlink(path)
        except OSError:
            pass

    syntax, other = [], []
    for line in out.splitlines():
        stripped = line.strip()
        if not stripped.startswith("E ") and not stripped.startswith("W "):
            continue
        if any(marker in stripped for marker in SYNTAX_MARKERS):
            syntax.append(stripped)
        else:
            other.append(stripped)
    return {"ok": not syntax, "syntax_errors": syntax,
            "other_diags": other, "tool": checker}


def batch_check(limit: int | None = None) -> None:
    """对命令库里的"位置参数形态"表达式做批量语法验证。

    只为回答一个问题：**自动生成的表达式，有多少真的语法正确？**
    这决定了动态表达式方案能不能作为"覆盖面持续扩大"的默认路径。
    """
    from knowledge.expr import build_expr_for, whitelist_from_library
    from knowledge.index import default_index, signature_variants

    idx = default_index()
    wl = whitelist_from_library()
    ok = bad = skipped = 0
    failures = []
    for rec in idx.records.values():
        if rec["ty"] != "command":
            continue
        name = rec["n"]
        if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", name):
            skipped += 1
            continue
        if name.lower() not in wl:
            skipped += 1
            continue
        for var in signature_variants(rec):
            argc = len(var["args"])
            if argc == 0 or argc > 3:
                skipped += 1
                continue
            try:
                # 传入签名：形态不同（数组/前缀/中置）需要不同写法
                expr = build_expr_for(name, argc, var.get("code") or "")
            except Exception:  # noqa: BLE001
                skipped += 1
                continue
            res = check_expr(expr)
            if res.get("unavailable"):
                print(res["reason"])
                return
            if res["ok"]:
                ok += 1
            else:
                bad += 1
                if len(failures) < 8:
                    failures.append((expr, res["syntax_errors"][0][:70]))
            if limit and ok + bad >= limit:
                break
        if limit and ok + bad >= limit:
            break

    total = ok + bad
    print("批量语法验证（位置参数形态的引擎命令）")
    print("  通过 : %d" % ok)
    print("  失败 : %d" % bad)
    print("  跳过 : %d（无参数/参数过多/符号命令/不在白名单）" % skipped)
    if total:
        print("  通过率: %.1f%%" % (100.0 * ok / total))
    if failures:
        print("\n失败样本：")
        for expr, why in failures:
            print("  ✗ %-34s %s" % (expr[:34], why))


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description="用真实解析器检查表达式语法")
    ap.add_argument("--expr", help="要检查的表达式")
    ap.add_argument("--batch", action="store_true", help="批量验证命令库")
    ap.add_argument("--limit", type=int, default=None, help="批量模式的样本上限")
    args = ap.parse_args(argv)

    if args.batch:
        batch_check(args.limit)
        return 0
    if not args.expr:
        ap.print_help()
        return 2

    res = check_expr(args.expr)
    if res.get("unavailable"):
        print("无法检查：%s" % res["reason"], file=sys.stderr)
        return 2
    if res["ok"]:
        print("✓ 语法通过：%s" % args.expr)
        print("  （其它诊断 %d 条，属类型/未定义变量类，已忽略）"
              % len(res["other_diags"]))
        return 0
    print("✗ 语法不通过：%s" % args.expr)
    for line in res["syntax_errors"][:5]:
        print("   %s" % line)
    return 1


if __name__ == "__main__":
    sys.exit(main())
