#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""检查本模组的 SQF 函数调用形态是否合法。

## 为什么需要它（这轮上机的教训）

SQFLint **抓不到**这类错误：把函数调用写成 `a3mcp_fnc_xxx [a, b]`
（缺少 `call`）。它把 `a3mcp_fnc_xxx` 当成未定义变量、把后面的数组当成
相邻表达式，而"未定义变量"是它默认忽略的诊断类别——于是静态检查全绿，
PBO 也正常打包，**直到游戏里才报"缺少 ;"**。

正确的形态只有两种：
    [a, b] call a3mcp_fnc_xxx
    expr call a3mcp_fnc_xxx
本脚本把每个 `a3mcp_fnc_*` 的出现位置找出来，检查它前面是否有 `call`；
没有就报错。**在打包前跑**，把这类错误挡在本机。

用法：python3 tools/lint_sqf_calls.py [目录]
"""

from __future__ import annotations

import os
import re
import sys

def _safe_console() -> None:
    """让 CLI 输出在 Windows 中文控制台（GBK）下不崩。

    中文 Windows 的默认 stdout 编码是 **GBK**，而 `✓` / `✗` / `⚠` 不在 GBK 里：
    直接 print 会抛 `UnicodeEncodeError: 'gbk' codec can't encode character`。
    这是分发后最常见的环境（中文用户），CLI 一跑就崩。

    只加 `errors="replace"`、**不改 encoding**：
      · GBK 控制台：符号显示为 `?`，不崩、不乱码；
      · UTF-8 终端：符号正常显示。
    """
    for stream in (sys.stdout, sys.stderr):
        try:
            stream.reconfigure(errors="replace")
        except (AttributeError, ValueError):
            pass          # Python < 3.7 或流不支持：保持原样

FN_RE = re.compile(r"\ba3mcp_fnc_[A-Za-z0-9_]+\b")


def split_code_comment(line: str) -> str:
    """去掉行内 // 注释（跳过字符串内的 //）。"""
    in_str, i = False, 0
    while i < len(line):
        ch = line[i]
        if ch == '"':
            in_str = not in_str
        elif not in_str and ch == "/" and i + 1 < len(line) and line[i + 1] == "/":
            return line[:i]
        i += 1
    return line


def code_only(line: str) -> str:
    """把字符串字面量的内容抹成等长的井号。

    必须这么做：`missionNamespace getVariable ["a3mcp_fnc_xxx", {}]` 里的
    函数名**是字符串**，不是调用点。不抹掉就会把它当"缺少 call"误报
    （初版正是这样一口气报了 11 处，其中 9 处是误报——检查器的误报会让人
    连同真问题一起忽略掉）。
    """
    out, in_str, i = [], False, 0
    while i < len(line):
        ch = line[i]
        if ch == "\\" and in_str and i + 1 < len(line):
            # SQF 字符串里用 \" 表示引号：不处理这个转义，
            # 字符串状态会在中途翻转，后续行内内容就被当成代码 —— 误报的根源
            out.append("##")
            i += 2
            continue
        if ch == '"':
            in_str = not in_str
            out.append(ch)
        else:
            out.append("#" if in_str else ch)
        i += 1
    return "".join(out)


# 合法的调用前缀：call 与 spawn 都是 SQF 里调用函数的写法
LEGAL_PREFIX = ("call", "spawn")


def check_file(path: str) -> list[str]:
    problems = []
    lines = open(path, encoding="utf-8").read().split("\n")
    in_block = False
    for lineno, raw in enumerate(lines, 1):
        # 跳过块注释 /* ... */
        line = raw
        if in_block:
            if "*/" in line:
                line = line.split("*/", 1)[1]
                in_block = False
            else:
                continue
        if line.lstrip().startswith("/*"):
            if "*/" not in line:
                in_block = True
            continue

        code = code_only(split_code_comment(line))
        for m in FN_RE.finditer(code):
            start = m.start()
            before = code[:start].rstrip()
            # 合法：前面是 call 或 spawn
            if any(before.endswith(p) for p in LEGAL_PREFIX):
                continue
            # 合法：函数名出现在 CfgFunctions 声明或字符串里（本目录不会有）
            problems.append(
                "%s:%d 缺少 call：%s"
                % (os.path.basename(path), lineno, line.strip()[:80]))
    return problems


def main(argv=None) -> int:
    target = argv[1] if argv and len(argv) > 1 else \
        os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                     "game", "mod", "addons", "a3mcp", "fnc")
    if not os.path.isdir(target):
        print("目录不存在：%s" % target, file=sys.stderr)
        return 2

    all_problems = []
    files = sorted(f for f in os.listdir(target) if f.endswith(".sqf"))
    for name in files:
        all_problems.extend(check_file(os.path.join(target, name)))

    print("检查 %d 个 SQF 文件的函数调用形态" % len(files))
    if all_problems:
        print()
        for p in all_problems:
            print("  X %s" % p)
        print("\n%d 处调用缺少 call —— 游戏里会报「缺少 ;」，"
              "且 SQFLint 抓不到这类错误。" % len(all_problems))
        return 1
    print("OK: 全部 a3mcp_fnc_* 调用都带 call")
    return 0


if __name__ == "__main__":
    _safe_console()
    sys.exit(main())
