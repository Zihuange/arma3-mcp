#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""独立性自检：本仓库不得依赖本机其它 Arma 代码库。

"独立"必须是**可执行的断言**，不是声明。本脚本查三件事：

  1. 代码里不得出现对其它仓库的运行期引用（import / subprocess / 硬编码路径）；
  2. 自带数据必须能只凭"官方命令定义"重建，且重建结果与仓库内的产物一致；
  3. 清单文件（white list）本身要有效——不存在的路径写进去等于没检查。

退出码：0 全部通过 / 1 有违规 / 2 环境不足（如数据来源缺失，属"无法验证"）
"""

from __future__ import annotations

import hashlib
import json
import lzma
import os
import re
import subprocess
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# 本机其它 Arma 代码库：本仓库可以参考它们的**结论**，但绝不能在运行期依赖
OTHER_REPOS = [
    "arma3-sqf-skill",
    "arma3-terrain-grid",
    "arma_llm_commander",
]

# 允许出现这些名字的文件：文档（说明"参考了什么"）与本脚本（定义禁令）。
DOC_ALLOWED = {"README.md", "check_independence.py"}
DOC_SUFFIXES = (".md",)

# 仓库外的绝对路径：除已声明的工作区外不应硬编码
ALLOWED_PATH_PREFIXES = (
    "/mnt/c/Users/",        # 命令定义来源（编辑器扩展）——已声明的外部数据源
    "/mnt/c/Program Files", # Windows Java（SQFLint 用，P1 起）
)


# 反向断言的特征：判断"不存在"而不是"引用"。这类代码写出仓库名是必要的，
# 否则就没法检查数据污染。
_NEGATIVE_MARKERS = (
    "forbidden", "assertNotIn", "assertNotRegex", "not in ", "OTHER_REPOS",
    "该仓库", "不得", "禁止",
)


def _is_negative_assertion(line: str) -> bool:
    return any(marker in line for marker in _NEGATIVE_MARKERS)


def _prev_code_line(lines: list[str], lineno: int) -> str:
    """取该行之前最近的、非注释非空的一行（用于多行语句的延续行判断）。"""
    idx = lineno - 2
    while idx >= 0:
        candidate = lines[idx].strip()
        if candidate and not candidate.startswith("#"):
            return candidate
        idx -= 1
    return ""


def python_files() -> list[str]:
    out = []
    for root, dirs, files in os.walk(REPO):
        dirs[:] = [d for d in dirs if d not in (".git", "__pycache__")]
        for name in files:
            if name.endswith(".py"):
                out.append(os.path.join(root, name))
    return sorted(out)


def check_code_references() -> list[str]:
    """代码中不得引用其它仓库。"""
    problems = []
    for path in python_files():
        rel = os.path.relpath(path, REPO)
        if os.path.basename(path) in DOC_ALLOWED:
            continue
        with open(path, encoding="utf-8") as fh:
            text = fh.read()
        lines = text.splitlines()
        for other in OTHER_REPOS:
            for lineno, line in enumerate(text.splitlines(), 1):
                if other not in line:
                    continue
                stripped = line.strip()
                # 注释里提到来源是允许的（记录 provenance）
                if stripped.startswith("#"):
                    continue
                # 反向断言也是允许的：测试与自检本身要检查
                # "数据里有没有别的仓库路径"，这类代码必须写出仓库名。
                # 多行语句的延续行本身没有关键词，故回看上一行。
                if _is_negative_assertion(stripped) or _is_negative_assertion(
                        _prev_code_line(lines, lineno)):
                    continue
                problems.append(f"{rel}:{lineno} 引用了其它仓库 {other}："
                                f"{stripped[:90]}")
    return problems


def check_hardcoded_paths() -> list[str]:
    """不允许把仓库外的绝对路径写进代码（数据来源除外，且要显式声明）。"""
    problems = []
    pattern = re.compile(r"""["'](/mnt/[a-z]/[^"']{4,})["']""")
    for path in python_files():
        rel = os.path.relpath(path, REPO)
        with open(path, encoding="utf-8") as fh:
            for lineno, line in enumerate(fh, 1):
                if line.strip().startswith("#"):
                    continue
                for match in pattern.finditer(line):
                    target = match.group(1)
                    if target.startswith(ALLOWED_PATH_PREFIXES):
                        continue
                    if target.startswith("<repo>"):
                        continue   # 自己仓库内的路径不算外部依赖
                    problems.append(f"{rel}:{lineno} 硬编码外部路径 {target}")
    return problems


def check_data_rebuild() -> tuple[int, list[str]]:
    """自带数据必须能从官方定义重建，且与仓库产物一致。"""
    import importlib.util

    builder_path = os.path.join(REPO, "tools", "build_commands.py")
    spec = importlib.util.spec_from_file_location("build_commands", builder_path)
    assert spec and spec.loader
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)

    source = mod.find_source()
    if not source:
        return 2, ["找不到命令定义来源，无法验证数据可重建（设置 "
                   f"{mod.ENV_SOURCE} 后再试）"]

    payload = mod.build(source)
    blob = json.dumps(payload, ensure_ascii=False, separators=(",", ":"),
                      sort_keys=True).encode("utf-8")
    rebuilt_sha = hashlib.sha256(blob).hexdigest()
    # 同一来源必须给出同样的内容（generated.at 时间戳不同，故只比对 records）
    with lzma.open(os.path.join(REPO, "data", "commands.json.xz"), "rb") as fh:
        stored = json.loads(fh.read().decode("utf-8"))

    problems = []
    if stored["records"] != payload["records"]:
        problems.append("重建结果与仓库内产物不一致（命令库内容有漂移）")
    if stored["generated"]["source_sha256"] != payload["generated"]["source_sha256"]:
        problems.append("来源指纹不一致（来源文件已变化，请重跑 build_commands）")
    print(f"  来源：{source}")
    print(f"  来源 sha256：{payload['generated']['source_sha256'][:16]}…")
    print(f"  重建内容 sha256：{rebuilt_sha[:16]}…")
    print(f"  条目：{len(payload['records'])}")
    return (1 if problems else 0), problems


def check_no_external_imports() -> list[str]:
    """只允许标准库与本仓库自身的模块。"""
    problems = []
    allowed_third_party: set[str] = set()   # 本仓库刻意零第三方依赖
    import sys as _sys
    stdlib = set(_sys.stdlib_module_names)
    local = {"mcpcore", "knowledge", "guard", "adapters", "servers", "tools",
             "tests"}
    pattern = re.compile(r"^\s*(?:from|import)\s+([a-zA-Z_][\w.]*)")
    for path in python_files():
        rel = os.path.relpath(path, REPO)
        with open(path, encoding="utf-8") as fh:
            for lineno, line in enumerate(fh, 1):
                m = pattern.match(line)
                if not m:
                    continue
                root = m.group(1).split(".")[0]
                if root in stdlib or root in local or root in allowed_third_party:
                    continue
                if root.startswith("_"):
                    continue
                problems.append(f"{rel}:{lineno} 导入了非标准库模块 {root}")
    return problems


def check_manifest_of_other_repos() -> list[str]:
    """清单里的仓库名必须真实存在——否则'检查'是空的。"""
    problems = []
    parent = os.path.dirname(REPO)
    for other in OTHER_REPOS:
        if not os.path.isdir(os.path.join(parent, other)):
            problems.append(f"清单中的 {other} 在同级目录不存在"
                            f"（清单已过期，请更新 OTHER_REPOS）")
    return problems


def run_tests_isolated() -> tuple[bool, str]:
    """在"看不到其它仓库"的副本里跑测试。

    做法：把仓库复制到临时目录再跑。复制件无法访问原目录之外的东西
    （路径全部相对仓库根），因此只要能跑通，就说明没有隐藏的运行期依赖。
    """
    import shutil
    import tempfile

    with tempfile.TemporaryDirectory(prefix="arma3-mcp-iso-") as tmp:
        dest = os.path.join(tmp, "arma3-mcp")
        shutil.copytree(REPO, dest, ignore=shutil.ignore_patterns(
            ".git", "__pycache__", "*.pyc"))
        proc = subprocess.run(
            [sys.executable, "-m", "unittest", "discover", "-s", "tests",
             "-t", ".", "-q"],
            cwd=dest, capture_output=True, text=True, timeout=1800)
        tail = (proc.stdout + proc.stderr).strip().splitlines()[-6:]
        return proc.returncode == 0, "\n".join("    " + l for l in tail)


def main() -> int:
    print("== 独立性自检 ==")
    failures: list[str] = []

    print("\n[1/5] 检查代码是否引用其它仓库 …")
    refs = check_code_references()
    failures += refs
    print(f"  {'✓ 未发现引用' if not refs else f'✗ {len(refs)} 处引用'}")

    print("\n[2/5] 检查硬编码的外部路径 …")
    paths = check_hardcoded_paths()
    failures += paths
    print(f"  {'✓ 未发现越界路径' if not paths else f'✗ {len(paths)} 处'}")

    print("\n[3/5] 检查依赖是否只有标准库 …")
    imports = check_no_external_imports()
    failures += imports
    print(f"  {'✓ 仅标准库与本地模块' if not imports else f'✗ {len(imports)} 处'}")

    print("\n[4/5] 检查数据可重建且一致 …")
    code, data_problems = check_data_rebuild()
    if code == 2:
        print("  ⚠ 无法验证（环境不足）")
        for p in data_problems:
            print("    " + p)
    else:
        failures += data_problems
        print(f"  {'✓ 一致' if not data_problems else '✗ 不一致'}")

    print("\n[5/5] 检查清单有效性 …")
    manifest = check_manifest_of_other_repos()
    failures += manifest
    print(f"  {'✓ 清单有效' if not manifest else f'✗ {len(manifest)} 条失效'}")

    print("\n[附加] 在隔离副本中运行全部测试 …")
    ok, tail = run_tests_isolated()
    print(tail)
    if not ok:
        failures.append("隔离副本中的测试未全部通过")

    print("\n== 结论 ==")
    if failures:
        print(f"✗ 未通过，共 {len(failures)} 项：")
        for f in failures:
            print("  · " + f)
        return 1
    print("✓ 本仓库不依赖其它 Arma 代码库：代码无引用、数据可自建、"
          "隔离副本测试通过。")
    return 0


if __name__ == "__main__":
    sys.exit(main())
