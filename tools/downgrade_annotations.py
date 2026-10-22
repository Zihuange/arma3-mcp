#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""把 PEP 604 联合类型注解（`X | None`）改写为 `Optional[X]` / `Union[...]`。

为什么需要：本仓库原本只在 WSL 侧运行（Python 3.14），注解里用了
`dict | None` 这类 3.10+ 语法。但 Windows 侧只有 Python 3.9（Anaconda），
而**在 Windows 侧运行 MCP 能彻底消除跨系统连接问题**（见 docs/decisions.md D13）。
所以要把源码降到 3.9 可解析。

做法：逐个文件扫描注解位置（def/参数/变量注解），只对注解文本做改写，
其余代码一个字不动。改写后仍由 150 个测试守护行为不变。

用法：
    python3 tools/downgrade_annotations.py --check     # 只报告，不写
    python3 tools/downgrade_annotations.py             # 就地改写
"""

from __future__ import annotations

import argparse
import ast
import io
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SKIP_DIRS = {".git", "__pycache__", "tools"}

# 需要在 typing 里导入的名字
TYPING = "from typing import"


def _find_annotation_spans(src: str) -> list[tuple[int, int, str]]:
    """返回 [(start, end, text)]：注解在源码中的字符区间。

    用 ast 定位而不是正则扫全文：`|` 在布尔表达式、字符串、注释里都会出现，
    全文替换会改坏代码。
    """
    tree = ast.parse(src)
    lines = src.splitlines(keepends=True)
    starts = [0]
    for line in lines:
        starts.append(starts[-1] + len(line))

    def span(node: ast.AST) -> tuple[int, int]:
        start = starts[node.lineno - 1] + node.col_offset
        end = starts[node.end_lineno - 1] + node.end_col_offset
        return start, end

    out: list[tuple[int, int, str]] = []
    for node in ast.walk(tree):
        targets: list[ast.AST] = []
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
            if node.returns is not None:
                targets.append(node.returns)
        if isinstance(node, ast.arg) and node.annotation is not None:
            targets.append(node.annotation)
        if isinstance(node, ast.AnnAssign) and node.annotation is not None:
            targets.append(node.annotation)
        for target in targets:
            start, end = span(target)
            out.append((start, end, src[start:end]))
    out.sort()
    return out


def _split_top_level(text: str, sep: str = "|") -> list[str]:
    """按顶层分隔符切分，忽略括号/方括号内的分隔符。"""
    parts, depth, current = [], 0, []
    for ch in text:
        if ch in "([{":
            depth += 1
        elif ch in ")]}":
            depth -= 1
        if ch == sep and depth == 0:
            parts.append("".join(current).strip())
            current = []
            continue
        current.append(ch)
    parts.append("".join(current).strip())
    return [p for p in parts if p]


def rewrite_annotation(text: str) -> str:
    """`A | B | None` -> `Union[A, B, None]`；只含 None 时用 Optional。"""
    if "|" not in text:
        return text
    parts = _split_top_level(text)
    if len(parts) < 2:
        return text
    non_none = [p for p in parts if p != "None"]
    has_none = len(non_none) != len(parts)
    if has_none and len(non_none) == 1:
        return "Optional[%s]" % non_none[0]
    return "Union[%s]" % ", ".join(parts)


def ensure_typing_import(src: str, names: set[str]) -> str:
    """确保 typing 里导入了需要的名字。"""
    if not names:
        return src
    lines = src.splitlines(keepends=True)
    for idx, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith("from typing import"):
            existing = {n.strip() for n in
                        stripped.split("import", 1)[1].split(",") if n.strip()}
            merged = sorted(existing | names)
            lines[idx] = "from typing import %s\n" % ", ".join(merged)
            return "".join(lines)
    # 没有 typing 导入：插在最后一个 __future__ 导入之后（或第一个 import 之前）
    insert_at = 0
    for idx, line in enumerate(lines):
        if line.startswith("from __future__"):
            insert_at = idx + 1
    lines.insert(insert_at, "from typing import %s\n" % ", ".join(sorted(names)))
    return "".join(lines)


def process_file(path: str, write: bool) -> tuple[int, list[str]]:
    with io.open(path, encoding="utf-8") as fh:
        src = fh.read()
    if "|" not in src:
        return 0, []
    try:
        spans = _find_annotation_spans(src)
    except SyntaxError as exc:
        return 0, ["%s: 无法解析（%s）" % (path, exc.msg)]

    changed = 0
    used: set[str] = set()
    # 从后往前替换，避免位移影响
    for start, end, text in reversed(spans):
        new = rewrite_annotation(text)
        if new == text:
            continue
        if new.startswith("Optional["):
            used.add("Optional")
        elif new.startswith("Union["):
            used.add("Union")
        src = src[:start] + new + src[end:]
        changed += 1

    problems: list[str] = []
    if changed:
        src = ensure_typing_import(src, used)
        try:
            ast.parse(src)
        except SyntaxError as exc:
            return 0, ["%s: 改写后语法错误（第 %s 行：%s）" % (path, exc.lineno, exc.msg)]
        if write:
            with io.open(path, "w", encoding="utf-8") as fh:
                fh.write(src)
    return changed, problems


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="注解降级到 Python 3.9 语法")
    ap.add_argument("--check", action="store_true", help="只报告，不写文件")
    args = ap.parse_args(argv)

    total = 0
    problems: list[str] = []
    for root, dirs, files in os.walk(REPO):
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS]
        for name in sorted(files):
            if not name.endswith(".py"):
                continue
            path = os.path.join(root, name)
            count, errs = process_file(path, write=not args.check)
            problems.extend(errs)
            if count:
                rel = os.path.relpath(path, REPO)
                print("  %-44s %d 处" % (rel, count))
                total += count

    print("\n共改写 %d 处联合类型注解。" % total)
    for problem in problems:
        print("✗ " + problem, file=sys.stderr)
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main())
