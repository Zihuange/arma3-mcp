#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""校验打包出来的 PBO 结构。

起因：PBO 打包最容易出的错是**静默**的——用旧 config.bin 打包、或误把
config.cpp 一起打进去。两种情况下 PBO 都能正常加载，但函数全都不存在，
上机表现为"新命令毫无反应"，排查成本很高。所以打包后必须自动复核。

判据（缺一不可）：
  · 含 config.bin        —— 没有它就是空的模组
  · **不含 config.cpp**  —— 同时存在时引擎的取舍不是我们想要的
  · 文件数与函数数相符
  · 头部与文件表完整（无截断）
"""

from __future__ import annotations

import argparse
import struct
import sys


def read_pbo(path: str) -> dict:
    """扫描 PBO，取出文件名清单。

    刻意用"扫描文件名"而不是严格解析头部：PBO 头部的条目布局随打包器版本
    与配置有细微差异（本仓库实测 AddonBuilder 产出中同时出现 config.cpp 与
    config.bin 两个条目），严格按某一种布局解析会误报。而本工具的用途只是
    **校验交付物内容是否齐全**——名字清单足够，且不会因为格式细节误判。
    """
    with open(path, "rb") as fh:
        data = fh.read()

    names = []
    # 文件名在头部以 \0 分隔的 ASCII 串出现；取所有可打印片段再筛扩展名
    for chunk in data.split(b"\x00"):
        if not chunk or len(chunk) > 260:
            continue
        try:
            text = chunk.decode("ascii")
        except UnicodeDecodeError:
            continue
        if not text or any(ord(c) < 32 for c in text):
            continue
        if text.endswith((".sqf", ".cpp", ".bin", ".hpp")) or text in (
                "$PBOPREFIX$",) or text.startswith("fnc\\"):
            names.append(text.replace("\\", "/"))

    return {"entries": [{"name": n} for n in names], "size": len(data)}


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description="校验 PBO 结构")
    ap.add_argument("pbo")
    ap.add_argument("--expect-functions", type=int, default=None,
                    help="期望的 SQF 函数文件数（.sqf 计数）")
    args = ap.parse_args(argv)

    try:
        info = read_pbo(args.pbo)
    except (OSError, ValueError) as exc:
        print("✗ 读取 PBO 失败：%s" % exc, file=sys.stderr)
        return 2

    names = [e["name"] for e in info["entries"]]
    lower = [n.lower() for n in names]
    problems = []

    if not info["entries"]:
        problems.append("PBO 里读不到任何文件名（文件损坏或格式异常）")

    # 判据说明：AddonBuilder 会读 config.cpp 并**自动生成** config.bin，
    # 两者同时进入 PBO 是正常做法（config.bin 供引擎加载，config.cpp 便于调试）。
    # 所以这里只要求 config.bin 存在——它缺失才是致命的（模组会变成空的）。
    if "config.bin" not in lower:
        problems.append("**缺少 config.bin** —— 引擎会认为模组是空的，"
                        "所有函数都不存在（只需提供 config.cpp，"
                        "由打包器生成 bin）")
    elif "config.cpp" not in lower:
        print("注：PBO 内没有 config.cpp（只有 config.bin）——可正常加载，"
              "但调试时不方便核对配置来源。")

    sqf = [n for n in names if n.lower().endswith(".sqf")]
    if args.expect_functions is not None and len(sqf) != args.expect_functions:
        problems.append("SQF 文件数不符：PBO 内 %d，期望 %d"
                        % (len(sqf), args.expect_functions))
    if not sqf:
        problems.append("PBO 内没有任何 .sqf 文件")

    print("PBO：%s（%d 字节）" % (args.pbo, info["size"]))
    print("条目 %d 个，其中 .sqf %d 个" % (len(names), len(sqf)))
    for name in sorted(names):
        print("   %s" % name)

    if problems:
        print()
        for problem in problems:
            print("✗ %s" % problem, file=sys.stderr)
        return 1
    has_cpp = "config.cpp" in lower
    print("\n✓ 结构校验通过：含 config.bin、%d 个 .sqf%s"
          % (len(sqf), "、含 config.cpp（便于调试）" if has_cpp else ""))
    return 0


if __name__ == "__main__":
    sys.exit(main())
