#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""从官方命令定义生成仓库自带的命令库。

数据来源**不是**本机任何一个 Arma 代码库，而是编辑器扩展自带的官方命令定义
（SQFLint definitions/documentation.json，内容源自 BI wiki）。这条选择是
"独立性"的地基：只要这个来源在，命令库就能在本仓库内独立重建，
无需任何外部仓库在场。

产物：data/commands.json.xz
  {
    "schema": 1,
    "generated": {...来源指纹...},
    "records": { "<小写命令名>": {n,ty,d,sx:[{c,a,r}],compat:[{g,v}],src}, ... }
  }

用法：
    python3 tools/build_commands.py                    # 自动探测来源并重建
    python3 tools/build_commands.py --source <path>    # 指定来源
    python3 tools/build_commands.py --check            # 只校验现有产物与来源一致
    python3 tools/build_commands.py --report           # 打印覆盖率统计

退出码：0 成功 / 2 来源缺失 / 3 校验不一致
"""

from __future__ import annotations

import argparse
import glob
import hashlib
import json
import lzma
import os
import sys
from datetime import datetime, timezone

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DEFAULT_OUT = os.path.join(REPO, "data", "commands.json.xz")
SCHEMA = 1

# 自动探测顺序：先环境变量，再编辑器扩展（多个版本时取版本号最大者）。
# 之所以支持环境变量：来源可能被更新或换位置，但不该逼迫脚本改动。
ENV_SOURCE = "ARMA3_MCP_CMD_SOURCE"
GLOBS = [
    "/mnt/c/Users/*/.vscode/extensions/skacekachna.sqflint-*/definitions/documentation.json",
    "/mnt/c/Users/*/.vscode-insiders/extensions/skacekachna.sqflint-*/definitions/documentation.json",
    os.path.expanduser("~/.vscode/extensions/skacekachna.sqflint-*/definitions/documentation.json"),
]


def find_source() -> str | None:
    """定位命令定义来源。找不到返回 None（调用方负责报错，不静默降级）。"""
    env = os.environ.get(ENV_SOURCE)
    if env:
        return env if os.path.isfile(env) else None
    hits: list[str] = []
    for pattern in GLOBS:
        hits.extend(glob.glob(pattern))
    if not hits:
        return None
    # 版本号最大的优先（路径里带 -0.12.4 这类片段）
    def version_key(p: str) -> tuple:
        for part in p.split(os.sep):
            if part.startswith("skacekachna.sqflint-"):
                tail = part.rsplit("-", 1)[-1]
                return tuple(int(x) if x.isdigit() else 0 for x in tail.split("."))
        return (0,)

    return sorted(hits, key=version_key)[-1]


def sha256_of(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def parse_syntaxes(raw: dict) -> list[dict]:
    """把 documentation.json 的 syntaxes 转成精简签名列表。

    保留结构：c=签名原文, a=[{n,t,d}]=参数, r=返回类型。
    这几个字段是"可自动校验参数"的全部依据，缺一不可，故不做有损裁剪
    （本地那份精简索引把 compatibility 裁掉了，结果就是版本查询永远答不了）。
    """
    out = []
    for syn in raw.get("syntaxes") or []:
        args = []
        for arg in syn.get("args") or []:
            args.append({
                "n": arg.get("name", ""),
                "t": arg.get("type", ""),
                "d": (arg.get("description") or "")[:200],
            })
        ret = syn.get("returns")
        out.append({
            "c": syn.get("code", ""),
            "a": args,
            "r": (ret or {}).get("type", "") if isinstance(ret, dict) else "",
        })
    return out


def parse_compat(raw: dict) -> list[dict]:
    out = []
    for entry in raw.get("compatibility") or []:
        if isinstance(entry, dict):
            out.append({"g": entry.get("game", ""), "v": entry.get("version", "")})
    return out


def build(source: str) -> dict:
    with open(source, "r", encoding="utf-8") as fh:
        raw = json.load(fh)
    if not isinstance(raw, dict) or not raw:
        raise ValueError("来源不是预期的对象结构（应为 命令名 -> 定义）")

    records: dict[str, dict] = {}
    for key, entry in raw.items():
        if not isinstance(entry, dict):
            continue
        name = entry.get("title") or key
        records[key.lower()] = {
            "n": name,
            "ty": entry.get("type", ""),
            "d": (entry.get("description") or "")[:400],
            "sx": parse_syntaxes(entry),
            "compat": parse_compat(entry),
            "src": entry.get("source", ""),
        }

    return {
        "schema": SCHEMA,
        "generated": {
            "at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
            "source_path": source,
            "source_sha256": sha256_of(source),
            "records": len(records),
            "builder": "tools/build_commands.py",
        },
        "records": records,
    }


def dump(path: str, payload: dict) -> None:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    blob = json.dumps(payload, ensure_ascii=False, separators=(",", ":"),
                      sort_keys=True).encode("utf-8")
    tmp = path + ".tmp"
    with lzma.open(tmp, "wb", preset=6) as fh:
        fh.write(blob)
    os.replace(tmp, path)


def load(path: str) -> dict:
    with lzma.open(path, "rb") as fh:
        return json.loads(fh.read().decode("utf-8"))


def report(payload: dict) -> int:
    recs = payload["records"]
    by_type: dict[str, int] = {}
    by_src: dict[str, int] = {}
    with_compat = with_arma3 = with_sig = with_args = 0
    for rec in recs.values():
        by_type[rec["ty"]] = by_type.get(rec["ty"], 0) + 1
        by_src[rec["src"]] = by_src.get(rec["src"], 0) + 1
        compat = rec.get("compat") or []
        if compat:
            with_compat += 1
        if any(c.get("g") == "arma3" for c in compat):
            with_arma3 += 1
        if rec.get("sx"):
            with_sig += 1
        if any(s.get("a") for s in rec.get("sx") or []):
            with_args += 1
    total = len(recs)
    print(f"条目总数      : {total}")
    print(f"类型          : {by_type}")
    print(f"来源          : {by_src}")
    print(f"有签名        : {with_sig} ({with_sig * 100 // max(total,1)}%)")
    print(f"带参数的签名  : {with_args}")
    print(f"有兼容信息    : {with_compat}")
    print(f"其中支持 arma3: {with_arma3}")
    return 0


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description="生成仓库自带的 Arma3 命令库")
    ap.add_argument("--source", default=None, help="命令定义来源（默认自动探测）")
    ap.add_argument("--out", default=DEFAULT_OUT, help="产物路径")
    ap.add_argument("--check", action="store_true",
                    help="只校验现有产物与来源是否一致（不写入）")
    ap.add_argument("--report", action="store_true", help="打印覆盖率统计后退出")
    args = ap.parse_args(argv)

    source = args.source or find_source()
    if not source or not os.path.isfile(source):
        print("错误：找不到命令定义来源。", file=sys.stderr)
        print(f"  自动探测的模式：{ENV_SOURCE} 环境变量，或", file=sys.stderr)
        for pattern in GLOBS:
            print(f"    {pattern}", file=sys.stderr)
        print("  可用 --source 显式指定。", file=sys.stderr)
        return 2

    payload = build(source)

    if args.report:
        if os.path.isfile(args.out):
            return report(load(args.out))
        return report(payload)

    if args.check:
        if not os.path.isfile(args.out):
            print(f"错误：产物不存在 {args.out}", file=sys.stderr)
            return 3
        current = load(args.out)
        same_sha = (current["generated"]["source_sha256"]
                    == payload["generated"]["source_sha256"])
        same_count = current["generated"]["records"] == payload["generated"]["records"]
        if same_sha and same_count:
            print(f"一致：{payload['generated']['records']} 条，"
                  f"来源 sha256 {payload['generated']['source_sha256'][:16]}…")
            return 0
        print("不一致：产物与来源不匹配", file=sys.stderr)
        print(f"  产物 sha256={current['generated']['source_sha256'][:16]}… "
              f"records={current['generated']['records']}", file=sys.stderr)
        print(f"  来源 sha256={payload['generated']['source_sha256'][:16]}… "
              f"records={payload['generated']['records']}", file=sys.stderr)
        return 3

    dump(args.out, payload)
    size = os.path.getsize(args.out)
    print(f"已生成 {args.out}")
    print(f"  条目 {payload['generated']['records']}，"
          f"{size / 1024:.0f} KB，来源 sha256 "
          f"{payload['generated']['source_sha256'][:16]}…")
    print(f"  来源路径 {source}")
    return report(payload)


if __name__ == "__main__":
    sys.exit(main())
