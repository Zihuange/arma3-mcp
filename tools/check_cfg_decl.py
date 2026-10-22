#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""核对 SQF 函数文件与 CfgFunctions 声明是否一一对应。

两个方向都要查，且两种错误都是**静默**的：
  · 写了 .sqf 但没在 config.cpp 声明 → 函数不存在，游戏里报 Undefined variable
  · 声明了但 .sqf 不存在 → 加载期报缺文件，函数不可用

（初版用 `class X {};` 正则统计声明数，会把 `class init { preInit = 1; ... }`
这种多行形式漏掉，得出"少一个声明"的错误结论。这里按函数名集合比对，
不依赖书写形式。）

用法：python3 tools/check_cfg_decl.py
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

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
MOD = os.path.join(REPO, "game", "mod", "addons", "a3mcp")
FNC = os.path.join(MOD, "fnc")

# 声明行形如：class init { ... }  或  class init {};  （含多行体）
DECL_RE = re.compile(r"^\s*class\s+([A-Za-z_][A-Za-z0-9_]*)\s*\{", re.M)


def main() -> int:
    if not os.path.isdir(FNC):
        print("找不到函数目录：%s" % FNC, file=sys.stderr)
        return 2

    files = {f[3:-4] for f in os.listdir(FNC) if f.startswith("fn_") and f.endswith(".sqf")}
    cfg_path = os.path.join(MOD, "config.cpp")
    text = open(cfg_path, encoding="utf-8").read()

    # 只在 CfgFunctions 段内找声明，避免误抓 CfgPatches 里的类
    start = text.find("class CfgFunctions")
    section = text[start:] if start >= 0 else ""
    decls = set()
    for m in DECL_RE.finditer(section):
        name = m.group(1)
        # 只看 `class X {};`（空体声明）与带 preInit/postInit 的初始化函数。
        # 排除命名空间类（class a3mcp { tag=...; class Core { file=...; ... } }）
        # ——它们的体里含嵌套 class，不是函数。
        body = section[m.end():m.end() + 200]
        if re.match(r"\s*(preInit|postInit)\s*=", body) or re.match(r"\s*\}", body):
            decls.add(name)
    decls.discard("CfgFunctions")

    print("SQF 函数文件: %d 个" % len(files))
    print("CfgFunctions 声明: %d 个" % len(decls))

    missing_decl = sorted(files - decls)
    missing_file = sorted(decls - files)

    problems = False
    if missing_decl:
        problems = True
        print("\n以下函数有 .sqf 但**没有声明**（游戏里会 Undefined variable）：")
        for n in missing_decl:
            print("   X fn_%s.sqf" % n)
    if missing_file:
        problems = True
        print("\n以下函数**声明了但没有 .sqf**（加载期会报缺文件）：")
        for n in missing_file:
            print("   X class %s" % n)

    if problems:
        return 1
    print("\nOK: 文件与声明一一对应")
    return 0


if __name__ == "__main__":
    _safe_console()
    sys.exit(main())
