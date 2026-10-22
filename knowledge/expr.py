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
#
# `call` **不在**这个集合里，但它也不是普通白名单成员：它是唯一一条
# "风险由参数决定"的命令。放行它要三条同时成立（见 _check_call_target）：
#   1. 函数名必须走**数据占位符**——表达式里不许出现字符串字面量，所以
#      函数名不可能被写进文本，只能是调用方传进来的数据；
#   2. 该数据必须是合法标识符形状（不是路径、不是含空格的东西）；
#   3. 不在 CALL_DENY 里（bis_fnc_exec* / spawn* / dbg_* 一律拒绝）。
#
# 这三条把 call 从"参数无法校验"变成"参数可以逐个校验"，而不是"放开了 call"。
# 引擎定义支持字符串形态：BI 命令库对 `call code` 的 code 参数注明
# "also accepts datatype String"——传字符串时按函数名解析，不建新代码对象。
DENY_NAMES = {
    "setvariable", "setvariableserverside", "publicvariable",
    "publicvariableserverside", "publicvariableclient", "compile",
    "compilefinal", "spawn", "execvm", "execfsm", "exec",
    "callextension", "loadfile", "preprocessfile",
    "preprocessfilelinenumbers", "preprocessconfigfile",
    "remoteexec", "remoteexeccall", "bis_fnc_mp",
}

# 表达式切分规则 —— **唯一定义处**。
#
# SQF 侧 `fn_validate::_splitExpr` 必须与这里逐字符等价。为什么强调：
# 两侧曾经不一致（一边丢括号、一边把括号留成 token），症状是 SQF 报
# "call 的目标形态无法识别"——它认不出 MCP 自己发下去的表达式，而报错文本
# 看起来像安全策略在正常拒绝。为一个不一致重启了三次游戏，代价全是上机时间。
# 规则：空白 ` \t`、圆括号、方括号、花括号、逗号 —— **全部丢弃**，不留 token。
TOKEN_SEPARATORS = " \t()[]{},"
TOKEN_SPLIT_RE = re.compile(r"[%s]+" % re.escape(TOKEN_SEPARATORS))


def split_tokens(expr: str) -> list[str]:
    """按 token 切分表达式（丢弃全部分隔符，不改大小写）。"""
    return [t for t in TOKEN_SPLIT_RE.split(expr) if t]


PLACEHOLDER_RE = re.compile(r"^_p(\d+)$")
IDENT_RE = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")

# 引擎在特定上下文里**自动赋值**的隐式变量 —— 放行它们。
#
# 依据是一个可验证的技术事实，不是"看起来无害"：命令库 5181 条里，以 `_` 开头的
# 命令名有 **0 条** —— SQF 的命令名不以 `_` 开头。所以任何 `_` 开头的标识符
# 必然是**变量读取**，不可能成为命令调用；而"命令名注入"正是白名单要防的
# 唯一一件事。放行它们不扩大任何攻击面。
#
# 为什么只放行这几枚、而不是所有 `_xxx`：校验器还要能回答"这个标识符是哪来的"。
# 这四枚由引擎在 forEach/apply/filter/count（`_x`、`_forEachIndex`）、
# call/spawn（`_this`）、catch（`_exception`）里赋值；别的 `_foo` 是调用方自造
# 的变量，放行会把"写错名字被早期拒绝"退化成"进了游戏才报未定义变量"。
#
# 实测动因：`vehicles apply {[typeOf _x]}` 曾被拒（`_x` 不在白名单），而
# `apply`/`count`/`select`/`findif` 这些命令本来就在白名单里 —— 差的就是这一枚，
# 函数式写法整条用不了。
IMPLICIT_VARIABLES = frozenset({
    "_this",           # call / spawn / 代码块收到的参数
    "_x",              # forEach / apply / filter / count 的当前元素
    "_foreachindex",   # 同上的下标
    "_exception",      # catch 捕获到的异常
})

# call 的目标必须是"像函数名/变量名"的一段：不能含空格、点、斜杠、引号。
# 形状校验**不代替**值校验（值校验在 _check_call_target 里做），它只是先挡掉
# 一眼就不该出现在这里的形态（例如 "a.sqf"、"x y"）。
_CALL_TARGET_RE = re.compile(r"^[A-Za-z_][A-Za-z0-9_]{0,127}$")


class ExprError(ValueError):
    """表达式不合法。消息面向使用者，必须能直接看出哪里不对。"""


def _call_target_slot(expr: str, names: list[str]) -> int | None:
    """表达式里 `call` 目标的**参数下标**；没写 call 或认不出来时返回 None。

    为什么只认占位符：函数名一旦以字面量形式出现，就等于把"调用什么"写死在
    表达式文本里，白名单也就无从逐条核对。传成数据（_pN）是本方案成立的前提。

    三种形态（都会出现，少认一种就是"自己人的输出自己看不懂"）：
      `_p0 call _p1`                                  → 1
      `_p0 call (_this select 1)`                     → 1（展开形态）
      `_p0 call (missionNamespace getVariable _p1)`   → 1（下发形态）
    """
    toks = split_tokens(expr)
    for i, tok in enumerate(toks):
        if tok.lower() != "call" or i + 1 >= len(toks):
            continue
        nxt = toks[i + 1]
        ph = PLACEHOLDER_RE.match(nxt)
        if ph:
            return int(ph.group(1))
        # 展开形态 `(_this select N)` 与下发形态 `(missionNamespace getVariable …)`
        #
        # ⚠ 切分把括号整个去掉了（分隔符集合含 `()`），这里**看不到**括号，
        # 只能按名字判断：紧跟 call 的是 `_this`/`missionNamespace`，
        # 参数就是其后那组 `select N`。按边界位置去数括号会永远扑空——
        # 那样 CALL_DENY 等于没被核对，而报错还显示成"目标必须写成占位符"，
        # 看起来像安全策略在起作用（实测踩过）。
        if nxt.lower() == "_this" and i + 3 < len(toks):
            if toks[i + 2].lower() == "select" and toks[i + 3].isdigit():
                return int(toks[i + 3])
        if nxt.lower() == "missionnamespace" and i + 5 < len(toks):
            if toks[i + 2].lower() != "getvariable":
                return None
            # 括号已被切掉，参数就是紧跟 getVariable 的那组：`_this select N`
            d, e, f = toks[i + 3].lower(), toks[i + 4].lower(), toks[i + 5]
            if d == "_this" and e == "select" and f.isdigit():
                return int(f)
            ph2 = PLACEHOLDER_RE.match(f)
            if ph2:
                return int(ph2.group(1))
        return None            # 有 call，但目标形态不认识 → 交给调用方报错
    return None


def _fn_name_from_arg(arg) -> str | None:
    """从实参里取出函数名；取不到返回 None。

    实参有两种携带方式：
      "a3mcp_fnc_init"                 → 直接就是函数名
      ["a3mcp_fnc_init", [参数...]]     → 第一个元素是函数名（call 的目标）

    ⚠ 返回 None 表示"这个值当不了函数名"，**不是**"没传"。
    """
    if isinstance(arg, str):
        return arg
    if isinstance(arg, list) and arg and isinstance(arg[0], str):
        return arg[0]
    return None


def check_call_target(fn_name) -> None:
    """校验 call 的目标函数名；不合法时抛 ExprError。

    这是"结构化白名单"里**唯一**能逐条核对的部分，所以错在哪必须说清楚：
    使用者看到的应当是"这个名字不允许 / 形状不对"，而不是笼统的"表达式不合法"。

    ⚠ 类型必须**显式**判断，不能只靠正则：`_CALL_TARGET_RE.match(42)` 抛的是
    TypeError，而调用方只捕获 ExprError ——那个 TypeError 会一路冒到 MCP 工具层，
    变成一条与安全无关的内部错误。实测踩到过（测试传数字时触发）。
    """
    from guard.gates import call_denied                # 延迟导入，避免环依赖
    if not isinstance(fn_name, str):
        raise ExprError(
            "call 的目标必须是**函数名字符串**，实际拿到 %s。"
            "形式是 `_p0 call _p1`，args 里第 1 项给函数名。"
            % type(fn_name).__name__)
    if not fn_name:
        raise ExprError(
            "call 的目标是空字符串：它必须是要调用的函数名"
            "（例：a3mcp_fnc_validate）。")
    if not _CALL_TARGET_RE.match(fn_name):
        raise ExprError(
            "call 的目标 %r 不是合法函数名：只允许字母/数字/下划线，且以字母或"
            "下划线开头。call 只用于按名字调用已编译的函数。" % fn_name)
    why = call_denied(fn_name)
    if why:
        raise ExprError(
            "call 的目标 %s 被永久拒绝（%s）。这一类把字符串编译成代码，"
            "等于把 call 变回 compile——所以它不受 A3MCP_ENGINE_CALL 与白名单影响。"
            % (fn_name, why))


# 无门控模式下的长度上限。默认路径是 400（单表达式够用）；全开时必须放宽，
# 否则"让 LLM 接管"会被一条字符数限制卡住。8000 足够写几十行 SQF，
# 又留了一道防呆（避免把几 MB 的东西塞进 downlink）。
UNRESTRICTED_MAX_LEN = 8000


def validate(expr: str, arg_count: int, whitelist: set[str] | None = None,
             index=None, args: list | None = None,
             unrestricted: bool = False) -> dict:
    """校验表达式。通过返回 {'ok': True, 'names': [...]}，否则抛 ExprError。

    args 是可选的**实参**。给了它就额外校验 `call` 的目标函数名——那是本框架里
    唯一"命令名之外还需要看值"的判定，光看表达式文本看不出来（目标在数据里）。

    unrestricted=True 时**跳过全部校验**（白名单、永久禁区、字符串字面量、
    分号、占位符越界），只留"非空 + 长度上限"。这条分支等于把 `exec` 变成
    "任意 SQF 代码执行"——它由 `A3MCP_PROFILE=unrestricted` 显式开启，
    默认永远走不到。之所以保留这个参数而不是删掉检查，见 guard/gates.py 里
    `unrestricted` 字段的注释：**模式必须可观测**（审计要能标记它）。
    """
    if unrestricted:
        if not isinstance(expr, str) or not expr.strip():
            raise ExprError("表达式为空")
        if len(expr) > UNRESTRICTED_MAX_LEN:
            raise ExprError("表达式过长（无门控模式上限 %d 字符）"
                            % UNRESTRICTED_MAX_LEN)
        return {"ok": True, "commands": [], "placeholders": [], "names": [],
                "unrestricted": True}

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
    # 表达式可能已经处于**展开形态**（`(_this select 0)`）——MCP 侧展开后就长这样，
    # 而校验在展开前后各跑一次（便于逐条测试与复用）。此时参数由 `_this` 承载，
    # 不该再按"必须出现 _pN"来要求，否则每次调用都会被自己的展开形态判死。
    expanded = "_this" in names

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

    if not expanded:
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

    # `call` 的额外一道：目标是数据，必须拿出来逐个核对。
    if "call" in lowered:
        slot = _call_target_slot(expr, names)
        if slot is None:
            raise ExprError(
                "call 的目标必须写成占位符（形如 `_p0 call _p1`）：函数名要作为"
                "数据传入才能逐条核对，写进表达式文本会让这条校验失效。")
        if args is not None and slot < len(args):
            check_call_target(_fn_name_from_arg(args[slot]))

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

    `call` 是唯一的例外：它属于"分级为 called_gated、但仍进白名单"的一条。
    它不进白名单的话本方案就没有入口——而它真正的把关在 validate 里做
    （目标函数名逐个核对），不靠"是否出现在白名单"这一层。
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
        #
        # call 是例外，且是唯一的例外：它的分级叫 call_gated，是"要看参数"而不是
        # "不能进来"。把它挡在白名单外，本方案就没有入口了；真正的把关在
        # validate 的 check_call_target（逐个核对函数名）。
        if low != "call" and _classify_level(low) not in ("read", "write"):
            continue
        if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", rec["n"]):
            continue          # 符号运算符、含空格的命令名不进白名单
        # 命令库里有形如 `a_greater_b` / `a_or_b` 的**运算符别名**：它们是
        # 中置运算符在库中的键名，不是可调用的命令。放进来会生成
        # `_p0 a_greater_b _p1` 这种不存在的语法（实测静态检查报错）。
        if _looks_like_operator_alias(low):
            continue
        out.add(low)

    # 隐式变量必须放行，否则两件事同时坏掉：
    #   · 修复占位符等于没修 —— 展开把 `_p0` 变成 `(_this select 0)`，
    #     而 `_this` 不在命令库里，于是每条带参表达式都被判"白名单外的名字"；
    #   · 函数式写法整条用不了 —— `apply`/`count`/`select` 本来就在白名单里，
    #     却因为 `_x` 被拒而无法使用。
    # 依据与边界见 IMPLICIT_VARIABLES 上方注释。
    out |= IMPLICIT_VARIABLES
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
