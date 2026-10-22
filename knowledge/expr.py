#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""表达式校验器：在**下发前**证明一条动态表达式是"白名单命令 + 纯数据"。

## 为什么需要它

本仓库选择用静态分发（`switch`）而非 `compile` 时，编译器替我们做了一件事：
**命令名在编译期就是字面量**，无法被注入。一旦改用动态表达式，这件事就没有
人做了——所以必须由本模块补上，而且要在**两个位置各做一次**：

  1. MCP 侧（这里）：下发前拒绝，给出可读原因，避免把垃圾送进游戏进程；
  2. SQF 侧（P1 落地）：**独立**再校验一次。理由与 ALC 的 `fn_sideGuard`
     注释同源——"校验只做一处"的失效方式是静默的，而第二道防线便宜。

## 校验判据（词法级，不靠"看起来像"）

表达式被切出所有标识符后，每一枚必须满足其一：
  · 形如 `_p<数字>` 的占位符，且下标小于参数个数；
  · 在命令白名单内。

其余一律拒绝，特别地：
  · **禁止分号** —— 否则一条请求可塞多语句，绕过按命令计数的审计与限流；
  · **禁止字符串字面量** —— 表达式里不该出现代码形态的字符串（参数只走数据）；
  · 禁止 `setVariable` / `publicVariable*` 这类"能改全局状态"的名字混进白名单。

## 与 gen_dispatch 的关系

`gen_dispatch.py` 生成的是**静态**分发（`switch`）。本模块服务于另一条路：
当覆盖面扩大到不值得逐族生成时，用"动态表达式 + 本校验器"扩展。
两条路共用同一份命令白名单与同一份签名知识，避免"两套实现各自漂移"。
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, REPO)

from knowledge.index import default_index  # noqa: E402

# 允许出现在表达式里的标点与运算符（SQF 表达式的最小字符集）
ALLOWED_PUNCT = set("()[]{}.,+-*/%^!=<>&|:;_ \t")

# 永远不允许进入白名单的名字：它们能改变全局状态或引入新的执行面，
# 即使命令库收录了它们，也不能通过动态表达式触达。
DENY_NAMES = {
    "setvariable", "setvariableserverside", "publicvariable",
    "publicvariableserverside", "publicvariableclient", "compile",
    "compilefinal", "call", "spawn", "execvm", "execfsm", "exec",
    "callextension", "loadfile", "preprocessfile",
    "preprocessfilelinenumbers", "preprocessconfigfile",
    "remoteexec", "remoteexeccall", "bis_fnc_mp",
}

PLACEHOLDER_RE = re.compile(r"^_p(\d+)$")
IDENT_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")


class ExprError(ValueError):
    """表达式不合法。消息面向使用者，必须能直接看出哪里不对。"""


def validate(expr: str, arg_count: int, whitelist: set[str] | None = None,
             index=None) -> dict:
    """校验表达式。通过返回 {'ok': True, 'names': [...]}，否则抛 ExprError。"""
    if not isinstance(expr, str) or not expr.strip():
        raise ExprError("表达式为空")
    if len(expr) > 400:
        raise ExprError("表达式过长（%d 字符，上限 400）" % len(expr))
    if ";" in expr:
        raise ExprError("表达式含分号：一条请求只允许一条语句（多语句会绕过"
                        "按命令计数的审计与限流）")
    if '"' in expr or "'" in expr:
        raise ExprError("表达式含字符串字面量：参数必须以**数据**形式传入，"
                        "不得写进表达式文本")

    bad_chars = sorted({ch for ch in expr if ch not in ALLOWED_PUNCT
                        and not ch.isalnum()})
    if bad_chars:
        raise ExprError("表达式含不允许的字符：%s" % ", ".join(repr(c) for c in bad_chars))

    names = IDENT_RE.findall(expr)
    placeholders = []
    commands = []
    for name in names:
        ph = PLACEHOLDER_RE.match(name)
        if ph:
            idx = int(ph.group(1))
            if idx >= arg_count:
                raise ExprError(
                    "占位符 %s 越界：该表达式只有 %d 个参数（下标 0..%d）"
                    % (name, arg_count, arg_count - 1))
            placeholders.append(idx)
            continue
        commands.append(name)

    if arg_count and not placeholders:
        raise ExprError("表达式没有引用任何参数占位符，但传了 %d 个参数——"
                        "参数会被静默丢弃" % arg_count)
    missing = sorted(set(range(arg_count)) - set(placeholders))
    if missing:
        raise ExprError("参数下标 %s 未被表达式使用"
                        % ", ".join(str(i) for i in missing))

    lowered = [c.lower() for c in commands]
    for name in lowered:
        if name in DENY_NAMES:
            raise ExprError("命令 %s 在永久禁区内（不得通过动态表达式触达）" % name)

    if whitelist is not None:
        unknown = sorted({c for c, low in zip(commands, lowered)
                          if low not in whitelist})
        if unknown:
            raise ExprError(
                "表达式引用了白名单外的名字：%s。动态表达式只允许调用白名单内的"
                "命令——这是防止「命令名注入」的唯一依据。"
                % ", ".join(unknown))

    if not commands:
        raise ExprError("表达式里没有命令名（只有占位符或标点）")

    return {"ok": True, "commands": sorted(set(lowered)),
            "placeholders": sorted(set(placeholders)), "names": names}


_OPERATOR_ALIAS_RE = re.compile(
    r"^(a|b)_(greater|less|equal|not_equal|or|and|plus|minus|multiply|divide"
    r"|mod|hash|concat|ternary|greater_equal|less_equal)_(b|a)$")


def _looks_like_operator_alias(low: str) -> bool:
    """识别命令库里以 `a_xxx_b` 形式出现的运算符别名。"""
    return bool(_OPERATOR_ALIAS_RE.match(low))


def _classify_level(name: str) -> str:
    """借用闸门的分级（保持"分级"与"白名单"只有一个真相来源）。"""
    try:
        from guard.gates import classify
        return classify(name)
    except Exception:  # noqa: BLE001
        return "write"          # 取不到分级时按写处理（保守）


def whitelist_from_library(families: list[str] | None = None,
                           kinds: tuple[str, ...] = ("command",)) -> set[str]:
    """从命令库生成白名单（默认只收引擎命令，不含函数库）。

    默认排除函数库：`BIS_fnc_*` 数量大、副作用难以静态判断，且多数不是
    "一条命令改一个状态"的形态。需要时用 families 显式指定。
    """
    idx = default_index()
    out = set()
    for rec in idx.records.values():
        if kinds and rec["ty"] not in kinds:
            continue
        if families and idx.family_of(rec["n"]) not in families:
            continue
        low = rec["n"].lower()
        if low in DENY_NAMES:
            continue
        # 与闸门分级对齐：EXOTIC 级（凭空生成资源 / 网络协调 / 调试后门）
        # 不进白名单。否则"动态表达式"会绕过闸门直接触达它们——
        # 分级就成了摆设（这轮测试正是抓出了这处不一致）。
        if _classify_level(low) not in ("read", "write"):
            continue
        if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", rec["n"]):
            continue          # 符号运算符、含空格的命令名不进白名单
        # 命令库里有形如 `a_greater_b` / `a_or_b` 的**运算符别名**：它们是
        # 中置运算符在库中的键名，不是可调用的命令。放进来会生成
        # `_p0 a_greater_b _p1` 这种不存在的语法（实测静态检查报错）。
        if _looks_like_operator_alias(low):
            continue
        out.add(low)
    return out


def build_expr_for(cmd: str, arg_count: int, signature: str = "") -> str:
    """按签名形态生成表达式。

    实测把"位置参数"模板套在所有命令上，有效命令的语法通过率约 85%——
    失败的都是**形态不同**的命令。故按签名原文选写法：

      数组形态（命令开头，参数在同一对方括号内）
        `[unit1, unit2] joinSilent grp`  → [_p0, _p1] joinSilent _p2
      接收者 + 数组形态
        `object actionKeysNames [action, input]` → _p0 actionKeysNames [_p1, _p2]
      前缀 / 中置 / 位置参数形态（其余）
        `object setPosATL pos` → _p0 setPosATL _p1
        `count array`          → count _p0
        `a distance b`         → _p0 distance _p1

    signature 为空时退化为"接收者 + 位置参数"（最常见的一类）。
    """
    if arg_count < 1:
        raise ExprError("至少要有一个参数")
    sig = (signature or "").strip()
    all_ph = ["_p%d" % i for i in range(arg_count)]

    if sig:
        bracket = re.search(r"\[([^\]]*)\]", sig)
        if bracket:
            inner = bracket.group(1)
            inner_count = len([x for x in re.split(r"[,\s]+", inner) if x.strip()])
            head = sig[:bracket.start()].strip()
            tail = sig[bracket.end():].strip()
            if inner_count >= 2:
                if not head:
                    # 命令开头、参数成组：`[a, b] cmd rest`
                    params = all_ph[:inner_count]
                    rest = all_ph[inner_count:]
                    expr = "[%s] %s" % (", ".join(params), cmd)
                    return (expr + (" " + " ".join(rest) if rest else "")).strip()
                # 接收者 + 成组参数：`object cmd [a, b]`
                params = all_ph[1:1 + inner_count]
                expr = "_p0 %s [%s]" % (cmd, ", ".join(params))
                rest = all_ph[1 + inner_count:]
                return (expr + (" " + " ".join(rest) if rest else "")).strip()
        if sig.lower().startswith(cmd.lower()) and arg_count == 1:
            return "%s _p0" % cmd

    if arg_count == 1:
        return "%s _p0" % cmd
    return "_p0 %s %s" % (cmd, " ".join(all_ph[1:]))


def main(argv=None) -> int:
    ap = argparse.ArgumentParser(description="校验动态表达式（B 方案的闸门）")
    ap.add_argument("--expr", help="要校验的表达式")
    ap.add_argument("--args", type=int, default=0, help="参数个数")
    ap.add_argument("--check-library", action="store_true",
                    help="用命令库生成白名单并报告规模")
    args = ap.parse_args(argv)

    if args.check_library:
        wl = whitelist_from_library()
        print("默认白名单规模（仅引擎命令、排除禁区与符号）：%d 条" % len(wl))
        print("示例：%s" % ", ".join(sorted(wl)[:12]))
        return 0

    wl = whitelist_from_library()
    cases = [
        ("_p0 setPosATL _p1", 2, "正常调用"),
        ("_p0 setposatl _p1", 2, "大小写变体"),
        ("_p0 setVariable [\"x\", 1]", 1, "含字符串与禁区名"),
        ("_p0 doMove _p1; _p0 setDamage 1", 2, "多语句"),
        ("_p0 setDamage", 2, "参数未被全部使用"),
        ("_p0 noSuchCommand _p1", 2, "白名单外命令"),
        ("execVM \"x.sqf\"", 0, "禁区命令"),
        ("_p0 call _p1", 2, "call 注入"),
    ]
    if args.expr:
        cases = [(args.expr, args.args, "命令行输入")]

    for expr, argc, label in cases:
        try:
            res = validate(expr, argc, wl)
            print("  ✓ %-42s %s" % (expr[:42], label))
            print("      → 命令 %s，占位符 %s"
                  % (res["commands"], res["placeholders"]))
        except ExprError as exc:
            print("  ✗ %-42s %s" % (expr[:42], label))
            print("      → %s" % exc)
    return 0


if __name__ == "__main__":
    sys.exit(main())
