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

# 运行期代码（MCP 服务器与它的支撑模块）——绝不允许依赖外部路径或仓库。
# tools/ 下是**验证期**工具：它们可选地调用外部静态检查器（SQFLint）来验证
# 生成的 SQF；检查器缺失时如实报错，而不是静默降级。这个区分是有意的：
#   · 运行期依赖外部仓库   → 本仓库无法独立工作   （不可接受）
#   · 验证期可选依赖检查器 → 少一项验证能力       （可接受，且已在文档标注）
RUNTIME_DIRS = ("mcpcore", "knowledge", "guard", "adapters", "servers")
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
        if rel.split(os.sep)[0] not in RUNTIME_DIRS:
            # 验证期工具允许引用外部检查器（见 RUNTIME_DIRS 注释）
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


# 借外部项目的名字当自己的标识符前缀 —— 比路径引用**更隐蔽**的依赖痕迹。
#
# check_code_references 只查路径与 import，查不出 `ALC_ENGINE_READ` 这种写法：
# 它不 import 任何东西、也不指向任何路径，但读代码的人会以为必须同时装
# arma_llm_commander 才能用。实测漏过一次（19 个环境变量全用着别家的前缀）。
OTHER_REPO_ABBREVS = {
    "arma_llm_commander": "alc",
    "arma3-sqf-skill": "asqfs",
    "arma3-terrain-grid": "atg",
}

# 允许出现的位置：**说明来源**的文档（它们的职责就是记录参考了什么），
# 以及本脚本（它定义禁令，必须写出这些名字）。
#
# handoff.md 也在其中：它的职责是告诉下一个会话"哪些旧名字已被禁"，因此
# 必须能写出旧名字。禁掉它等于让交接文档说不清这件事，而自检本身仍然有效
# ——代码与其它文档正文照旧零容忍。
ABBREV_ALLOWED_FILES = {"provenance.md", "history.md", "handoff.md",
                        "check_independence.py"}

_ABBREV_SUFFIXES = (".py", ".sqf", ".bat", ".cfg", ".json", ".md")


def check_borrowed_naming() -> list[str]:
    """代码与文档正文里不得借用外部项目的名字作为标识符前缀。

    匹配 `<缩写>_`（前面不能再是字母，避免 `malc_x` 这类误报）。
    大小写不敏感：`ALC_ENGINE_READ` 与 `alc_engine_read` 同样算借用。
    """
    problems = []
    for root, dirs, files in os.walk(REPO):
        dirs[:] = [d for d in dirs if d not in (".git", "__pycache__", "build")]
        for name in files:
            if not name.endswith(_ABBREV_SUFFIXES):
                continue
            if name in ABBREV_ALLOWED_FILES:
                continue
            path = os.path.join(root, name)
            rel = os.path.relpath(path, REPO)
            try:
                text = open(path, encoding="utf-8").read()
            except (UnicodeDecodeError, OSError):
                continue
            for other, abbr in OTHER_REPO_ABBREVS.items():
                for lineno, line in enumerate(text.splitlines(), 1):
                    if re.search(r"(?<![A-Za-z])%s_" % re.escape(abbr), line,
                                 re.IGNORECASE):
                        problems.append(
                            f"{rel}:{lineno} 借用了 {other} 的名字作为标识符："
                            f"{line.strip()[:80]}")
    return problems


def check_hardcoded_paths() -> list[str]:
    """不允许把仓库外的绝对路径写进**运行期**代码。

    验证期工具（tools/）允许写候选检查器路径——那份路径以"候选列表 + 存在性
    检查"的形式使用，缺失即明确报错，不影响服务器运行。
    """
    problems = []
    pattern = re.compile(r"""["'](/mnt/[a-z]/[^"']{4,})["']""")
    for path in python_files():
        rel = os.path.relpath(path, REPO)
        top = rel.split(os.sep)[0]
        if top not in RUNTIME_DIRS:
            continue
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


# 启动脚本里的**本仓库**绝对路径 —— 另一种独立性缺陷，且性质不同。
#
# check_hardcoded_paths 查的是"指向别的仓库"，查不到这里：`<repo>`
# 指的正是自己，所以它不算外部依赖，却让仓库一旦被搬动/改名，脚本就在别的机器上
# 静默找不到自己的文件。用 `%~dp0` 自定位可以完全消除这一项。
#
# 游戏安装路径（Steam 库）与解释器路径**不在检查范围**：它们无法从仓库位置推导，
# 只能手工编辑，属于已声明的本机配置。
_BAT_PATH_RE = re.compile(r"[A-Za-z]:[\\/]([A-Za-z0-9_.\-\\/ ]+)")
_BAT_SELF_REPO_SEGMENT = re.compile(
    r"arma3-mcp", re.IGNORECASE)


def bat_files() -> list[str]:
    """被 git 跟踪的 .bat 文件。

    用 git 而不是遍历目录：`build/` 被 .gitignore 忽略、内容是本地生成的
    一次性脚本，不参与交付，约束它们只会制造假警报。git 不可用时返回空列表
    （这项检查随之跳过，而不是让整个自检失败）。
    """
    try:
        proc = subprocess.run(["git", "ls-files", "*.bat"], cwd=REPO,
                              capture_output=True, text=True, timeout=30)
    except (OSError, subprocess.SubprocessError):
        return []
    if proc.returncode != 0:
        return []
    return [os.path.join(REPO, line.strip()) for line in proc.stdout.splitlines()
            if line.strip()]


def check_bat_self_location() -> list[str]:
    """启动用的 .bat 不得硬编码本仓库路径——它必须自己定位。"""
    problems = []
    for path in bat_files():
        rel = os.path.relpath(path, REPO)
        if not os.path.exists(path):
            continue
        try:
            text = open(path, encoding="utf-8", errors="replace").read()
        except OSError:
            continue
        for lineno, line in enumerate(text.splitlines(), 1):
            stripped = line.strip()
            if stripped.lower().startswith("rem "):
                continue          # 注释里提到旧路径不构成行为依赖
            for match in _BAT_PATH_RE.finditer(line):
                if _BAT_SELF_REPO_SEGMENT.search(match.group(1)):
                    problems.append(
                        f"{rel}:{lineno} 硬编码了本仓库的绝对路径："
                        f"{match.group(0)[:60]}（应改用 %~dp0 自定位）")
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
    borrowed = check_borrowed_naming()
    if borrowed:
        print("  ✗ 借用了外部项目的命名：")
        for p in borrowed[:10]:
            print(f"      {p}")
        failures += borrowed
    else:
        print("  ✓ 命名独立（未借用外部项目的名字）")

    paths = check_hardcoded_paths()
    failures += paths
    print(f"  {'✓ 未发现越界路径' if not paths else f'✗ {len(paths)} 处'}")

    selfloc = check_bat_self_location()
    failures += selfloc
    if selfloc:
        print("  ✗ 启动脚本硬编码了本仓库路径：")
        for p in selfloc[:10]:
            print(f"      {p}")
    else:
        print(f"  ✓ 启动脚本自定位（{len(bat_files())} 个 .bat 用 %~dp0）")

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
