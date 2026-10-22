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
    DENY_NAMES, ExprError, build_expr_for, validate, whitelist_from_library,
)


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
        for name in ("call", "spawn", "execVM", "compile", "callExtension",
                     "remoteExec", "loadFile"):
            self.assertRejected("%s _p0" % name, 1, name)
        self.assertRejected("_p0 call _p1", 2)
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
                     "loadfile", "spawn", "call"):
            self.assertIn(name, DENY_NAMES)


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
