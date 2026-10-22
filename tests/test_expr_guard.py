#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""动态表达式校验器测试（受限于"白名单命令 + 纯数据参数"）。

这是 B 方案（动态表达式 + compile）的安全边界。测试重点不是"正常表达式
能过"，而是**注入尝试是否一律被拒**——因为静态分发方案里由编译器负责的
"命令名是字面量"这件事，在动态方案里没有任何人负责，只能靠这里补上。
"""

from __future__ import annotations

import os
import sys
import unittest

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, REPO)

from knowledge.expr import (  # noqa: E402
    DENY_NAMES, IMPLICIT_VARIABLES, ExprError, build_expr_for, validate,
    whitelist_from_library,
)
from adapters.exec_tools import split_tokens  # noqa: E402


class TestInjectionRejected(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.wl = whitelist_from_library()

    def assertRejected(self, expr: str, argc: int, hint: str = "") :
        with self.assertRaises(ExprError, msg="应当拒绝：%s %s" % (expr, hint)):
            validate(expr, argc, self.wl)

    def test_multi_statement_rejected(self):
        """分号必须拒绝：否则一条请求可塞多语句，绕过按命令计数的审计。"""
        self.assertRejected("_p0 doMove _p1; _p0 setDamage 1", 2)
        self.assertRejected("_p0 setPosATL _p1; execVM \"x.sqf\"", 2)

    def test_string_literals_rejected(self):
        """字符串字面量必须拒绝：参数只能以数据传入，不得写进表达式文本。"""
        self.assertRejected('_p0 setVariable ["x", 1]', 1)
        self.assertRejected('execVM "evil.sqf"', 0)
        self.assertRejected('callExtension ["x", []]', 0)

    def test_deny_list_names_rejected(self):
        """禁区名必须拒绝，且**先于**白名单判定生效。"""
        for name in ("spawn", "execVM", "compile", "callExtension",
                     "remoteExec", "loadFile"):
            self.assertRejected("%s _p0" % name, 1, name)
        self.assertRejected("_p0 setVariable _p1", 2)

    def test_non_whitelisted_name_rejected(self):
        """白名单外的名字必须拒绝——这是防止"命令名注入"的唯一依据。"""
        self.assertRejected("_p0 noSuchCommand _p1", 2)

    def test_placeholder_out_of_range(self):
        self.assertRejected("_p5 setDamage 1", 1)

    def test_unused_arguments_rejected(self):
        """参数未被全部使用 = 静默丢弃参数，必须拒绝而不是放过。"""
        self.assertRejected("_p0 setDamage 1", 2)

    def test_empty_and_oversized(self):
        self.assertRejected("", 0)
        self.assertRejected("_p0 setDamage " + "1" * 500, 1)

    def test_deny_list_covers_forbidden_family(self):
        """禁区清单应覆盖硬禁的关键成员（防止清单被误改小）。"""
        for name in ("compile", "callextension", "execvm", "remoteexec",
                     "loadfile", "spawn"):
            self.assertIn(name, DENY_NAMES)
        self.assertNotIn("call", DENY_NAMES,
                         "call 改由 check_call_target 逐条核对函数名；"
                         "留在禁区清单里会让本方案没有入口")


class TestCallTarget(unittest.TestCase):
    """`call` 的结构化白名单——本轮改动的核心，也是最需要反向验证的地方。

    三层把守，缺一不可：
      1. 目标必须走数据占位符（表达式里不许有字符串字面量）；
      2. 目标必须是合法标识符形状；
      3. 目标不在 CALL_DENY 里。
    """

    @classmethod
    def setUpClass(cls):
        cls.wl = whitelist_from_library()

    def assertRejected(self, expr, argv, hint=""):
        with self.assertRaises(ExprError, msg="应当拒绝：%s %s" % (expr, hint)):
            validate(expr, len(argv), self.wl, args=argv)

    def test_bis_fnc_execvm_still_rejected(self):
        """★ 本方案里最重要的一条：经 call 也碰不到 execVM。

        BIS_fnc_execVM 会把字符串当代码执行，等于把 call 变回 compile。
        所以解禁 call **绝不等于**放开这条路径——它在 CALL_DENY 里，
        而 CALL_DENY 的优先级高于白名单。
        """
        self.assertRejected("_p0 call _p1", ["u_1", "BIS_fnc_execVM"])
        self.assertRejected("missionNamespace call _p0", ["BIS_fnc_execVM"])
        # 大小写不能绕过去
        self.assertRejected("_p0 call _p1", ["u_1", "bis_fnc_execvm"])

    def test_deny_family_rejected_regardless_of_name(self):
        for fn in ("BIS_fnc_execFSM", "BIS_fnc_spawn", "BIS_fnc_dbg_console",
                   "BIS_fnc_codePerformance", "compile", "spawn", "execVM",
                   "callExtension", "remoteExec"):
            self.assertRejected("_p0 call _p1", ["u_1", fn], fn)

    def test_target_must_come_from_data(self):
        """目标写进表达式文本时，逐个核对就失效了——必须拒绝。"""
        # 字面量先被"禁止字符串字面量"拦下
        self.assertRejected('_p0 call "a3mcp_fnc_init"', ["u_1"])
        # 目标是普通标识符（不是占位符）时也要拒绝
        self.assertRejected("_p0 call missionNamespace", ["u_1"])

    def test_target_shape_checked(self):
        """路径、带空格、带点号的目标都不该被当成函数名放过去。"""
        for bad in ("a.sqf", "some file.sqf", "a/b", "1abc"):
            self.assertRejected("_p0 call _p1", ["u_1", bad], bad)

    def test_target_type_checked(self):
        """目标不是字符串、也不是"首元素是字符串的数组"时拒绝。

        （数组形态 `["fn", 参数...]` 是合法的 args call code 写法，
        见 test_args_form_accepted；这里只说"取不出函数名"的那些。）
        """
        self.assertRejected("_p0 call _p1", ["u_1", 42])
        self.assertRejected("_p0 call _p1", ["u_1", [42, 1]])
        self.assertRejected("_p0 call _p1", ["u_1", ["", 1]])

    def test_legitimate_call_accepted(self):
        """正常函数必须能过——把正常调用也拦下的闸门会被整体关掉。"""
        for fn in ("a3mcp_fnc_init", "a3mcp_fnc_validate", "BIS_fnc_help",
                   "CBA_fnc_addBISEventHandler"):
            validate("_p0 call _p1", 2, self.wl, args=["u_1", fn])

    def test_args_form_accepted(self):
        """`[参数, 函数名]` 形态：首元素是函数名，其余是给它的参数。"""
        validate("_p0 call _p1", 2, self.wl,
                 args=["u_1", ["a3mcp_fnc_init", [1, 2]]])

    def test_without_argv_only_text_is_checked(self):
        """不传实参时只做文本层校验。

        这是**必须知道**的边界，不是漏洞：MCP 侧不传 args 就跳过了 CALL_DENY
        那一层（SQF 侧仍会拦，那是第二道防线）。用它固定"传 args 才有值校验"
        这个事实，免得以后有人以为文本层就够了。
        """
        validate("_p0 call _p1", 2, self.wl)      # 不抛异常

    def test_call_is_in_whitelist(self):
        """call 必须在白名单里，否则本方案没有入口。"""
        self.assertIn("call", self.wl)

    def test_multi_statement_still_rejected_with_call(self):
        """call 放行不得让分号规则松动：多语句仍要拒绝。"""
        self.assertRejected("_p0 call _p1; _p0 setDamage 1",
                            ["u_1", "a3mcp_fnc_init"])


class TestValidExpressionsAccepted(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.wl = whitelist_from_library()

    def test_simple_positional(self):
        res = validate("_p0 setPosATL _p1", 2, self.wl)
        self.assertTrue(res["ok"])
        self.assertEqual(res["commands"], ["setposatl"])
        self.assertEqual(res["placeholders"], [0, 1])

    def test_literal_argument_allowed(self):
        """字面量（数字）是数据，允许。"""
        res = validate("_p0 setDamage 1", 1, self.wl)
        self.assertTrue(res["ok"])

    def test_array_form(self):
        res = validate("_p0 add3DENConnection [_p1, _p2]", 3, self.wl)
        self.assertTrue(res["ok"])

    def test_prefix_form(self):
        res = validate("count _p0", 1, self.wl)
        self.assertTrue(res["ok"])

    def test_whitelist_excludes_operators_and_forbidden(self):
        wl = whitelist_from_library()
        # 符号运算符别名不得进白名单（它们不是可调用命令）
        for bad in ("a_greater_b", "a_or_b", "a_hash_b", "+", "-", "=="):
            self.assertNotIn(bad, wl, bad)
        # 禁区名不得进白名单
        for bad in ("execvm", "callextension", "compile", "remoteexec"):
            self.assertNotIn(bad, wl, bad)
        # 实用命令应在白名单内
        for good in ("setposatl", "setdamage", "domove", "getpos"):
            self.assertIn(good, wl, good)


class TestBuildExprForms(unittest.TestCase):
    def test_receiver_positional(self):
        self.assertEqual(build_expr_for("setPosATL", 2, "object setPosATL pos"),
                         "_p0 setPosATL _p1")

    def test_receiver_array(self):
        self.assertEqual(
            build_expr_for("add3DENConnection", 3,
                           "type add3DENConnection [from, to, config]"),
            "_p0 add3DENConnection [_p1, _p2]")

    def test_command_first_array(self):
        self.assertEqual(
            build_expr_for("joinSilent", 3,
                           "[unit1, unit2] joinSilent group"),
            "[_p0, _p1] joinSilent _p2")

    def test_prefix_form(self):
        self.assertEqual(build_expr_for("count", 1, "count array"), "count _p0")

    def test_fallback_without_signature(self):
        self.assertEqual(build_expr_for("doMove", 2), "_p0 doMove _p1")
        self.assertEqual(build_expr_for("isPlayer", 1), "isPlayer _p0")

    def test_generated_expr_passes_validator(self):
        """生成的表达式必须能通过校验器（两条路不能各说各话）。"""
        wl = whitelist_from_library()
        for cmd, sig, argc in [("setPosATL", "object setPosATL pos", 2),
                               ("add3DENConnection",
                                "type add3DENConnection [from, to, config]", 3),
                               ("count", "count array", 1)]:
            expr = build_expr_for(cmd, argc, sig)
            res = validate(expr, argc, wl)
            self.assertTrue(res["ok"], expr)


if __name__ == "__main__":
    unittest.main(verbosity=2)


class TestSqfCallTargetContract(unittest.TestCase):
    """锁定 SQF 侧 `fn_validate::_targetSlotOf` 的行为契约。

    为什么要有这一组：这段逻辑在 SQF 里，改错只有上机才能发现——而每轮上机
    要重打包 PBO、退游戏、重启（实测为一个不一致重启了三次）。这里用 Python
    照它的分支逐行实现一遍，把"哪种形态取到哪个下标"固定下来；SQF 侧改动后
    先跑这一组，对不上就别上机。

    ⚠ 这个模拟与 SQF 的一致性靠**人工对照**维持（见 game/mod/.../fn_validate.sqf
    的 `_targetSlotOf`）。改动任何一侧都必须同时改另一侧与这里的用例。
    """

    @staticmethod
    def _sqf_target_slot(tokens: list, i: int) -> int:
        """照抄 `_targetSlotOf`：认三种形态，其余返回 -1。"""
        if i >= len(tokens):
            return -1
        low = tokens[i].lower()
        if low[:2] == "_p":
            return int(low[2:])
        if low == "_this" and i + 1 < len(tokens) and tokens[i + 1].lower() == "select":
            return int(tokens[i + 2])
        if low == "missionnamespace":
            if i + 1 < len(tokens) and tokens[i + 1].lower() == "getvariable":
                inner = tokens[i + 2].lower()
                if inner == "_this":
                    if i + 3 < len(tokens) and tokens[i + 3].lower() == "select":
                        return int(tokens[i + 4])
                elif inner[:2] == "_p":
                    return int(inner[2:])
        return -1

    def _slot(self, expr: str):
        tokens = split_tokens(expr)
        idx = [i for i, t in enumerate(tokens) if t.lower() == "call"]
        if not idx:
            return None
        return self._sqf_target_slot(tokens, idx[0] + 1)

    def test_raw_form(self):
        self.assertEqual(self._slot("_p0 call _p1"), 1)

    def test_expanded_form(self):
        self.assertEqual(
            self._slot("(_this select 0) call (_this select 1)"), 1)

    def test_dispatch_form_with_expanded_argument(self):
        """这是 MCP 实际下发的形态，也是漏识别过三次的那一个。"""
        self.assertEqual(self._slot(
            "(_this select 0) call "
            "(missionNamespace getVariable (_this select 1))"), 1)

    def test_dispatch_form_with_raw_argument(self):
        self.assertEqual(self._slot(
            "(_this select 0) call (missionNamespace getVariable _p1)"), 1)

    def test_index_is_read_from_the_right_operand(self):
        """下标取错会让 CALL_DENY 核对到**另一个**参数上——静默失效。"""
        self.assertEqual(self._slot(
            "(_this select 1) call "
            "(missionNamespace getVariable (_this select 0))"), 0)

    def test_no_call_returns_none(self):
        self.assertIsNone(self._slot("(_this select 0) setPosATL (_this select 1)"))

    def test_unrecognized_form_returns_minus_one(self):
        """形态不认识要返回 -1（调用方会拒绝），不能"看不懂就放过"。"""
        self.assertEqual(self._sqf_target_slot(["notAForm"], 0), -1)


class TestTokenSplitContract(unittest.TestCase):
    """切分规则只有一处定义（`adapters.exec_tools.split_tokens`）。

    两侧不一致的代价实测过：SQF 把括号留成 token，而 MCP 丢掉括号，于是
    `call (missionNamespace …)` 的目标位置偏移，SQF 报"形态无法识别"——
    看起来像安全策略在正常拒绝，实际是校验器认不出自己人发下来的东西。
    """

    def test_separators_are_dropped(self):
        for expr, want in [
            ("_p0 call _p1", ["_p0", "call", "_p1"]),
            ("_p0 setPosATL [1, 2]", ["_p0", "setPosATL", "1", "2"]),
            ("a,b", ["a", "b"]),
            ("[a, b] joinSilent _p0", ["a", "b", "joinSilent", "_p0"]),
        ]:
            self.assertEqual(split_tokens(expr), want, expr)

    def test_parentheses_do_not_survive_as_tokens(self):
        """括号必须消失：留成 token 会让目标位置偏移（这是踩过的那个坑）。"""
        tokens = split_tokens(
            "(_this select 0) call (missionNamespace getVariable (_this select 1))")
        self.assertNotIn("(", tokens)
        self.assertNotIn(")", tokens)
        # 切分**不改大小写**（大小写不敏感的比较由调用方自己 toLower）
        self.assertEqual(tokens, ["_this", "select", "0", "call", "missionNamespace",
                                 "getVariable", "_this", "select", "1"])

    def test_commas_are_dropped(self):
        self.assertNotIn(",", split_tokens("a, b"))


class TestImplicitVariables(unittest.TestCase):
    """引擎隐式变量放行 —— 依据是一个可验证的技术事实。

    事实：命令库 5181 条里以 `_` 开头的命令名有 **0 条**（SQF 命令名不以 `_` 开头）。
    所以 `_` 开头的标识符必然是**变量读取**，不可能成为命令调用，而"命令名注入"
    正是白名单唯一要防的事 —— 放行它们不扩大任何攻击面。

    边界（同样重要）：只放行**引擎赋值**的那几枚，不放开任意 `_xxx`。
    否则写错变量名会从"早期被拒"退化成"进了游戏才报未定义变量"。
    """

    def test_implicit_variables_are_allowed(self):
        for name in sorted(IMPLICIT_VARIABLES):
            self.assertIn(name, whitelist_from_library(), name)

    def test_implicit_variable_names_are_lowercase(self):
        """表里的名字必须是小写：白名单比较前会 lower，大小写混着会漏放行。"""
        for name in IMPLICIT_VARIABLES:
            self.assertEqual(name, name.lower(), name)

    def test_functional_style_now_works(self):
        """实测动因：`apply`/`count`/`select` 本来就在白名单里，只差 `_x`。"""
        wl = whitelist_from_library()
        for expr in ("str (vehicles apply {[typeOf _x]})",
                     "count (vehicles apply {[typeOf _x]})"):
            validate(expr, 0, wl)

    def test_arbitrary_underscore_name_still_rejected(self):
        """用户自造变量名仍要拒 —— 这是"校验器知道每个名字来源"的边界。"""
        with self.assertRaises(ExprError):
            validate("_foo + 1", 0, whitelist_from_library())

    def test_command_names_never_start_with_underscore(self):
        """把放行依据本身写成断言：一旦命令库出现 `_` 开头的命令名，这条会失败，
        提醒我们重新论证 IMPLICIT_VARIABLES 的安全性。"""
        from knowledge.index import default_index
        idx = default_index()
        offenders = [r["n"] for r in idx.records.values()
                     if r["n"].startswith("_")]
        self.assertEqual(offenders, [],
                         "命令库出现了以 `_` 开头的命令名，白名单的放行依据需要重新论证")


class TestUnrestrictedExpression(unittest.TestCase):
    """无门控模式下的表达式校验：**跳过全部检查**，等于"任意 SQF 代码执行"。

    这里同时钉住默认路径（回归）：加了开关绝不能让正常模式变松。
    """

    def test_default_still_rejects(self):
        wl = whitelist_from_library()
        # 注意：`{ _x setDamage 1 } forEach allUnits` **不在**此列 ——
        # `_x` 已作为引擎隐式变量放行（见 TestImplicitVariables），
        # 而 forEach/setDamage/allUnits 都在白名单，所以它在默认模式下也合法。
        for expr, argc in (("_p0 doMove _p1; _p0 setDamage 1", 2),      # 分号
                           ('compile "systemChat 1"', 0),               # 字符串+硬禁
                           ("zzzNotACommand _p0", 1),                  # 白名单外
                           ('_p0 setDamage "1"', 1)):                  # 字符串字面量
            with self.assertRaises(ExprError, msg=expr):
                validate(expr, argc, wl)
            with self.assertRaises(ExprError, msg=expr):
                validate(expr, argc, wl, unrestricted=False)

    def test_unrestricted_accepts_anything(self):
        """分号、字符串字面量、任意命令名 —— 全放行（这正是"接管"的含义）。"""
        for expr in ("_p0 doMove _p1; _p0 setDamage 1",
                     'compile "systemChat 1"',
                     "{ _x setDamage 1 } forEach allUnits",
                     'systemChat "hello"',
                     "callExtension [\"a\", []]",
                     "zzzNotACommand _p0"):
            res = validate(expr, 2, None, unrestricted=True)
            self.assertTrue(res["ok"], expr)
            self.assertTrue(res.get("unrestricted"), expr)

    def test_unrestricted_keeps_sanity_checks(self):
        """只留两条最低要求：非空 + 长度。防呆，不是门控。"""
        with self.assertRaises(ExprError):
            validate("", 0, None, unrestricted=True)
        with self.assertRaises(ExprError):
            validate("a" * 9000, 0, None, unrestricted=True)

    def test_unrestricted_length_ceiling_is_higher(self):
        """400 是单表达式上限；全开时要能写几十行代码（实测常需要）。"""
        validate("a" * 3000, 0, None, unrestricted=True)   # 通过
        with self.assertRaises(ExprError):
            validate("a" * 3000, 0, None)                  # 默认仍拒
