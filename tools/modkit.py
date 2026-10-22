#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""arma3-mcp 模组工具：打包 / 部署 / 校验（跨平台，零第三方依赖）。

## 为什么是一个入口

打包与部署是同一件事的两半：产物必须**带着签名**落到游戏目录，否则签名描述的
是另一份内容。分开两套脚本时，最容易犯的错就是"只拷了 PBO"。

## 三个子命令

    python tools/modkit.py pack   [--out DIR] [--no-sign]
    python tools/modkit.py deploy [--check-only]
    python tools/modkit.py check

- `pack`   ：SQF 静态检查 → stage → rapify(config.bin) → AddonBuilder → PBO 校验
             → 签名 → 官方工具复核
- `deploy` ：游戏在运行就拒绝 → PBO 与 .bisign 一起拷 → 逐文件哈希比对 → 签名复核
- `check`  ：只校验当前部署状态（不拷贝）

## 跨平台

Windows 原生直接调用工具；WSL/Linux 下用 `wslpath -w` 把路径转成 Windows 形式
（Arma 3 Tools 是 Windows 程序）。两者都不是时明确失败——**不假装成功**。

## 配置

`a3mcp.json` 的 `toolkit` 段（可选）：

    { "toolkit": { "arma3_tools": "E:/.../Arma 3 Tools",
                   "sign_key": "~/.arma3-mcp/arma3-mcp.biprivatekey",
                   "key_name": "arma3-mcp" } }

也可用环境变量覆盖：`ARMA3_TOOLS`、`ARMA3_SIGN_KEY`、`ARMA3_KEY_NAME`。

## 为什么签名失败要直接中止

出未签名包比不出包更糟：它看起来是成功的。在单机编辑器里未签名也能跑，
但在 `-verifySignatures` 的环境里会加载失败/被踢——典型的"本机没事、服务器炸"。
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import subprocess
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
MOD_SRC = os.path.join(REPO, "game", "mod", "addons", "a3mcp")
MOD_OUT = os.path.join(REPO, "game", "mod", "addons")
KEYS_DIR = os.path.join(REPO, "game", "mod", "keys")
STAGE = os.path.join(REPO, "build", "stage", "a3mcp")
DEFAULT_OUT = os.path.join(REPO, "build", "pbo_out")
DLL_NAME = "arma3_mcp_x64.dll"

# Arma 3 Tools 的常见安装位置（同时给 Windows 与 WSL 形式）
TOOLS_CANDIDATES = [
    "E:/SteamLibrary/steamapps/common/Arma 3 Tools",
    "C:/Program Files (x86)/Steam/steamapps/common/Arma 3 Tools",
    "D:/SteamLibrary/steamapps/common/Arma 3 Tools",
    "/mnt/e/SteamLibrary/steamapps/common/Arma 3 Tools",
    "/mnt/c/Program Files (x86)/Steam/steamapps/common/Arma 3 Tools",
    "/mnt/d/SteamLibrary/steamapps/common/Arma 3 Tools",
]


# --------------------------------------------------------------------- 基础工具

def die(msg: str) -> "None":
    print("✗ %s" % msg, file=sys.stderr)
    raise SystemExit(1)


def warn(msg: str) -> None:
    print("⚠ %s" % msg, file=sys.stderr)


def step(msg: str) -> None:
    print()
    print("== %s ==" % msg)


def load_toolkit_config() -> dict:
    """读 a3mcp.json 的 toolkit 段（缺失就返回空 dict）。"""
    path = os.path.join(REPO, "a3mcp.json")
    if not os.path.isfile(path):
        return {}
    try:
        with open(path, "r", encoding="utf-8") as fh:
            raw = json.load(fh)
    except (OSError, ValueError):
        return {}
    part = raw.get("toolkit") if isinstance(raw, dict) else None
    return part if isinstance(part, dict) else {}


def to_native(path: str) -> str:
    """给 Windows 程序用的路径。

    - Windows 原生：绝对路径直接可用
    - WSL/Linux：用 `wslpath -w` 转成 `X:\\...`
    - 都没有（纯 Linux 且无 WSL）：明确失败，因为 Arma 3 Tools 是 Windows 程序
    """
    p = os.path.abspath(path)
    if os.name == "nt":
        return p
    wslpath = shutil.which("wslpath")
    if not wslpath:
        die("当前环境既不是 Windows 也没有 wslpath，无法调用 Arma 3 Tools。\n"
            "    本工具需要在 Windows，或在能调用 Windows 程序的 WSL 里运行。")
    out = subprocess.run([wslpath, "-w", p], capture_output=True, text=True)
    if out.returncode != 0 or not out.stdout.strip():
        die("路径转换失败：%s（wslpath: %s）" % (p, out.stderr.strip()))
    return out.stdout.strip()


def find_tools(cfg: dict) -> dict:
    """定位 Arma 3 Tools 及各可执行文件。缺失时明确报错。"""
    root = (os.environ.get("ARMA3_TOOLS") or cfg.get("arma3_tools") or "").strip()
    if not root:
        for cand in TOOLS_CANDIDATES:
            # 候选同时含 Windows 与 WSL 形式，按当前平台选能用的那个
            if os.path.isdir(cand):
                root = cand
                break
    if not root or not os.path.isdir(root):
        die("找不到 Arma 3 Tools。\n"
            "    在 a3mcp.json 的 toolkit.arma3_tools 指定，或设 ARMA3_TOOLS 环境变量。\n"
            "    常见位置：<Steam库>/steamapps/common/Arma 3 Tools")

    def tool(*parts: str) -> str:
        p = os.path.join(root, *parts)
        if not os.path.isfile(p):
            die("Arma 3 Tools 里缺少 %s（在 %s 下找不到）"
                % (os.path.join(*parts), root))
        return p

    return {
        "root": root,
        "cfgconvert": tool("CfgConvert", "CfgConvert.exe"),
        "addonbuilder": tool("AddonBuilder", "AddonBuilder.exe"),
        "signtool": tool("DSSignFile", "DSSignFile.exe"),
        "checktool": tool("DSSignFile", "DSCheckSignatures.exe"),
    }


def find_sign_key(cfg: dict, tools: dict, key_name: str) -> str:
    """定位签名私钥。**私钥不进仓库**，所以这里必须能明确报错。"""
    explicit = (os.environ.get("ARMA3_SIGN_KEY") or cfg.get("sign_key") or "").strip()
    candidates = []
    if explicit:
        p = os.path.expanduser(explicit)
        if not os.path.isabs(p):
            p = os.path.join(REPO, p)      # 配置里用相对仓库根的路径更自然
        candidates.append(p)
    candidates.append(os.path.expanduser(
        os.path.join("~", ".arma3-mcp", "%s.biprivatekey" % key_name)))
    candidates.append(os.path.join(tools["root"], "DSSignFile",
                                   "%s.biprivatekey" % key_name))
    for cand in candidates:
        if os.path.isfile(cand):
            return cand
    die("找不到签名私钥（密钥名 %s）。\n"
        "    查找过：\n%s\n"
        "    首次使用请生成一对新密钥（Arma 3 Tools 的 DSCreateKey.exe）：\n"
        "        DSCreateKey %s\n"
        "    然后把私钥放到 ~/.arma3-mcp/%s.biprivatekey，\n"
        "    公钥放进 game/mod/keys/%s.bikey（公钥要随版本分发）。"
        % (key_name, "\n".join("      · " + c for c in candidates),
           key_name, key_name, key_name))


def md5(path: str) -> str:
    h = hashlib.md5()
    with open(path, "rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def game_running() -> bool:
    """游戏是否在运行（运行中 PBO 被锁，拷贝必失败）。"""
    try:
        if os.name != "nt":
            # WSL：问 Windows 侧
            ps = shutil.which("powershell.exe") or \
                 "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe"
            out = subprocess.run(
                [ps, "-NoProfile", "-Command",
                 "(Get-Process -Name arma3_x64 -ErrorAction SilentlyContinue "
                 "| Measure-Object).Count"],
                capture_output=True, text=True, timeout=30)
            return out.stdout.strip() not in ("", "0")
        out = subprocess.run(["tasklist", "/FI", "IMAGENAME eq arma3_x64.exe"],
                             capture_output=True, text=True)
        return "arma3_x64.exe" in out.stdout
    except (OSError, subprocess.SubprocessError):
        return False      # 判定不了就不阻断（部署本身还有哈希校验兜底）


# --------------------------------------------------------------------- 各子命令

def sqf_gate_checks() -> None:
    """出包前的 SQF 检查：调用形态 + CfgFunctions 声明一致性。"""
    step("0/5 出包前检查：SQF 调用形态与声明")
    for script, label in (("lint_sqf_calls.py", "函数调用形态"),
                          ("check_cfg_decl.py", "CfgFunctions 声明")):
        path = os.path.join(REPO, "tools", script)
        if not os.path.isfile(path):
            die("缺少检查脚本：%s" % path)
        proc = subprocess.run([sys.executable, path], capture_output=True, text=True)
        tail = (proc.stdout + proc.stderr).strip().splitlines()[-3:]
        if proc.returncode != 0:
            print("\n".join(tail), file=sys.stderr)
            die("%s 检查未通过" % label)
        print("  ✓ %s" % label)


def cmd_pack(args) -> int:
    cfg = load_toolkit_config()
    key_name = (os.environ.get("ARMA3_KEY_NAME") or cfg.get("key_name")
                or "arma3-mcp").strip()
    out_dir = os.path.abspath(args.out or DEFAULT_OUT)
    tools = find_tools(cfg)

    [dirname] = [MOD_SRC]
    if not os.path.isdir(dirname):
        die("找不到模组源码目录：%s" % dirname)

    sqf_gate_checks()

    step("1/5 准备 stage")
    if os.path.isdir(STAGE):
        shutil.rmtree(STAGE)
    os.makedirs(os.path.join(STAGE, "fnc"))
    shutil.copy2(os.path.join(MOD_SRC, "config.cpp"),
                 os.path.join(STAGE, "config.cpp"))
    prefix_src = os.path.join(MOD_SRC, "$PBOPREFIX$")
    if os.path.isfile(prefix_src):
        shutil.copy2(prefix_src, os.path.join(STAGE, "$PBOPREFIX$"))
    else:
        with open(os.path.join(STAGE, "$PBOPREFIX$"), "w", encoding="ascii") as fh:
            fh.write("a3mcp")
    fnc_dir = os.path.join(MOD_SRC, "fnc")
    sqf_files = [f for f in os.listdir(fnc_dir) if f.endswith(".sqf")]
    for name in sqf_files:
        shutil.copy2(os.path.join(fnc_dir, name),
                     os.path.join(STAGE, "fnc", name))
    print("  已复制 %d 个 SQF 文件" % len(sqf_files))

    step("2/5 生成 config.bin（rapify）")
    # 不 rapify 的话 PBO 里还是旧 config.bin，新函数全部 Undefined variable，
    # 而且是**静默**的（日志仍报构建成功）。
    cfg_cpp = to_native(os.path.join(STAGE, "config.cpp"))
    cfg_bin = to_native(os.path.join(STAGE, "config.bin"))
    proc = subprocess.run([tools["cfgconvert"], "-bin", "-dst", cfg_bin, cfg_cpp],
                          capture_output=True, text=True)
    if proc.returncode != 0 or not os.path.isfile(os.path.join(STAGE, "config.bin")):
        die("CfgConvert 未产出 config.bin：%s" % (proc.stderr or proc.stdout).strip())
    print("  config.bin 已生成（%d 字节）"
          % os.path.getsize(os.path.join(STAGE, "config.bin")))

    step("3/5 AddonBuilder 打包")
    os.makedirs(out_dir, exist_ok=True)
    pbo = os.path.join(out_dir, "a3mcp.pbo")
    if os.path.isfile(pbo):
        # 游戏运行时 PBO 被占用：AddonBuilder 只会报一句含混的 "Build failed"。
        try:
            with open(pbo, "ab"):
                pass
        except OSError:
            die("无法写入 %s —— 它正被占用（最常见原因：Arma 3 还开着）。\n"
                "    完全退出游戏后重跑，或用 --out 打到别处。" % pbo)
        os.unlink(pbo)
    proc = subprocess.run(
        [tools["addonbuilder"], to_native(STAGE), to_native(out_dir),
         "-prefix=a3mcp", "-packonly", "-clear"],
        capture_output=True, text=True)
    combined = (proc.stdout or "") + (proc.stderr or "")
    if proc.returncode != 0 or "Build failed" in combined or \
            "Permission denied" in combined or not os.path.isfile(pbo):
        print("\n".join(combined.strip().splitlines()[-6:]), file=sys.stderr)
        die("AddonBuilder 构建失败（见上）。常见原因：游戏正在运行占用 PBO。")
    print("  产物：a3mcp.pbo（%d 字节）" % os.path.getsize(pbo))

    step("4/5 校验 PBO")
    verify = os.path.join(REPO, "tools", "pbo_verify.py")
    proc = subprocess.run([sys.executable, verify, pbo,
                           "--expect-functions", str(len(sqf_files))],
                          capture_output=True, text=True)
    print("  " + (proc.stdout or "").strip().splitlines()[-1] if proc.stdout else "")
    if proc.returncode != 0:
        print("\n".join(((proc.stdout or "") + (proc.stderr or "")).strip()
                        .splitlines()[-5:]), file=sys.stderr)
        die("PBO 校验失败")

    step("4.5/5 签名 PBO")
    bisign = "%s.%s.bisign" % (pbo, key_name)
    if args.no_sign:
        warn("已跳过签名（--no-sign）。只在确定环境不校验签名时这么做。")
    else:
        key = find_sign_key(cfg, tools, key_name)
        # 先删旧签名：留着会让"签名成功"的判据退化成"文件存在"
        for name in os.listdir(out_dir):
            if name.startswith("a3mcp.pbo.") and name.endswith(".bisign"):
                os.unlink(os.path.join(out_dir, name))
        proc = subprocess.run([tools["signtool"], to_native(key), to_native(pbo)],
                              capture_output=True, text=True)
        if proc.returncode != 0 or not os.path.isfile(bisign):
            die("签名失败：%s" % (proc.stderr or proc.stdout).strip())
        if os.path.getmtime(bisign) < os.path.getmtime(pbo):
            die("bisign 不比 PBO 新，签名可能对应旧内容")
        # 官方工具复核：它判的是**内容是否匹配**，不只看文件在不在
        check(tools, os.path.dirname(pbo), KEYS_DIR)
        print("  已签名：%s（%d 字节）"
              % (os.path.basename(bisign), os.path.getsize(bisign)))
        print("  ⚠ 部署时**必须连同 .bisign 一起拷**，只拷 PBO 等于没签。")

    step("5/5 完成")
    print("  产物：%s" % pbo)
    dll = os.path.join(REPO, "game", "mod", DLL_NAME)
    if os.path.isfile(dll):
        print("  DLL ：%s（%d 字节）" % (DLL_NAME, os.path.getsize(dll)))
    else:
        warn("模组目录里没有 %s —— SQF 能加载，但 callExtension 不会有任何反应。"
             % DLL_NAME)
        print("        构建：cmake -S game/extension -B build/ext -A x64 "
              "&& cmake --build build/ext --config Release")
    return 0


def check(tools: dict, pbo_dir: str, keys_dir: str) -> None:
    """用官方工具复核签名。

    ⚠ 判据是"**有没有输出**"：通过时无输出；失败时输出
    `No signature found` 或 `Signature ... is wrong`。
    不要猜错误措辞——曾经只匹配 "invalid"，把 "is wrong" 报成了成功。
    """
    if not (os.path.isdir(pbo_dir) and os.path.isdir(keys_dir)):
        raise SystemExit("签名复核跳过：目录不存在（%s / %s）" % (pbo_dir, keys_dir))
    proc = subprocess.run(
        [tools["checktool"], to_native(pbo_dir), to_native(keys_dir)],
        capture_output=True, text=True)
    out = ((proc.stdout or "") + (proc.stderr or "")).strip()
    if out:
        print(out, file=sys.stderr)
        die("签名复核未通过（见上）：PBO 与 .bisign 的内容对不上。\n"
            "    常见原因：只更新了其中一个（PBO 换了没重签，或签了新包但部署的还是旧的）。")


def cmd_deploy(args) -> int:
    cfg = load_toolkit_config()
    tools = find_tools(cfg)
    src_dir = os.path.abspath(args.source or DEFAULT_OUT)
    dst_dir = MOD_OUT

    print("== 部署模组 ==")
    print("  源  ：%s" % src_dir)
    print("  目标：%s" % dst_dir)

    if not os.path.isdir(dst_dir):
        die("目标目录不存在：%s" % dst_dir)
    if not os.path.isfile(os.path.join(REPO, "game", "mod", DLL_NAME)):
        warn("模组目录里没有 %s —— SQF 能加载，但 callExtension 不会有任何反应"
             % DLL_NAME)

    running = game_running()
    if running and not args.check_only:
        die("游戏正在运行（arma3_x64.exe）。PBO 被占用时拷贝会失败。\n"
            "    请先完全退出游戏（或加 --check-only 只校验当前状态）。")
    if running:
        warn("游戏在运行 —— 只做校验，不拷贝")

    src_pbo = os.path.join(src_dir, "a3mcp.pbo")
    bisigns = []
    if os.path.isdir(src_dir):
        bisigns = sorted(f for f in os.listdir(src_dir)
                         if f.startswith("a3mcp.pbo.") and f.endswith(".bisign"))

    if not args.check_only:
        if not os.path.isfile(src_pbo):
            die("找不到 %s（先跑：python tools/modkit.py pack）" % src_pbo)
        if not bisigns:
            die("找不到签名文件（%s/a3mcp.pbo.*.bisign）。\n"
                "    pack 现在会自动签名；若确实要部署未签名包，请显式手工拷贝。" % src_dir)

        print()
        print("[1/3] 拷贝 PBO")
        dst_pbo = os.path.join(dst_dir, "a3mcp.pbo")
        try:
            shutil.copy2(src_pbo, dst_pbo)
        except OSError as exc:
            die("PBO 拷贝失败（最常见原因：游戏还开着）：%s" % exc)
        if md5(src_pbo) != md5(dst_pbo):
            die("PBO 拷贝后内容不一致（拷贝没真正生效）")
        print("  ✓ a3mcp.pbo")

        print("[2/3] 拷贝签名")
        for name in bisigns:
            dst = os.path.join(dst_dir, name)
            try:
                shutil.copy2(os.path.join(src_dir, name), dst)
            except OSError as exc:
                die("签名拷贝失败：%s" % exc)
            if md5(os.path.join(src_dir, name)) != md5(dst):
                die("签名拷贝后内容不一致")
            print("  ✓ %s" % name)

    else:
        print()
        print("[1/3] 跳过拷贝（--check-only）")
        print("[2/3] 跳过拷贝（--check-only）")

    print("[3/3] 校验签名")
    check(tools, dst_dir, KEYS_DIR)
    print("  ✓ 签名有效（官方工具无输出）")

    pbo = os.path.join(dst_dir, "a3mcp.pbo")
    keys = sorted(f for f in os.listdir(KEYS_DIR) if f.endswith(".bikey")) \
        if os.path.isdir(KEYS_DIR) else []
    print()
    print("== 完成 ==")
    if os.path.isfile(pbo):
        print("  PBO  ：%d 字节" % os.path.getsize(pbo))
    print("  公钥 ：%s" % (" ".join(keys) or "（无）"))
    print()
    print("  挂载模组（文档里也有）：")
    print('    Arma3_x64.exe -mod="<repo>\\game\\mod" -skipIntro -noSplash')
    print("  若环境校验签名，客户端 keys/ 里需要有同一个 .bikey。")
    return 0


def cmd_check(args) -> int:
    """只校验当前部署状态。"""
    cfg = load_toolkit_config()
    tools = find_tools(cfg)
    check(tools, MOD_OUT, KEYS_DIR)
    print("✓ 当前部署的签名有效（官方工具无输出）")
    return 0


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(
        prog="modkit.py",
        description="arma3-mcp 模组工具：打包 / 部署 / 校验（跨平台）")
    sub = ap.add_subparsers(dest="command", required=True)

    p_pack = sub.add_parser("pack", help="打包模组（含 SQF 检查、rapify、PBO 校验、签名）")
    p_pack.add_argument("--out", help="PBO 输出目录（默认 build/pbo_out）")
    p_pack.add_argument("--no-sign", action="store_true",
                        help="跳过签名（确认环境不校验签名时）")
    p_pack.set_defaults(func=cmd_pack)

    p_dep = sub.add_parser("deploy", help="部署到游戏模组目录（PBO + 签名一起拷）")
    p_dep.add_argument("--check-only", action="store_true",
                       help="只校验当前状态，不拷贝")
    p_dep.add_argument("--source", help="PBO 所在目录（默认 build/pbo_out）")
    p_dep.set_defaults(func=cmd_deploy)

    p_chk = sub.add_parser("check", help="校验当前部署的签名")
    p_chk.set_defaults(func=cmd_check)

    args = ap.parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    _safe_console()
    sys.exit(main())
