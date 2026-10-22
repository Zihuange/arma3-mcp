#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""数据层测试：自带命令库的完整性，以及对**全部 5181 条**命令的自检。

自检的价值：命令库是外部数据源生成的，字段缺失、类型字符串畸形、
签名解析崩溃这类问题不会在抽样里暴露，只有全量跑一遍才能确认
"任意一条命令都能查到签名并构造出通过校验的调用"。
"""

from __future__ import annotations

import json
import lzma
import os
import sys
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from knowledge.index import (  # noqa: E402
    CommandIndex, _TYPE_MAP, _normalize_type, check_call, parse_arg,
    signature_variants,
)

DATA = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
                    "data", "commands.json.xz")


def candidates_for(normalized_type: str) -> list:
    """某个归一化类型下的候选值（按"最可能合法"排序）。

    从类型的**允许 JSON 类型集合**反推候选值，而不是手写一张映射表——
    手写表必漏（第一版就漏掉了 control/waypoint/task/hashmap 这些同样是
    "对象引用"的类型，于是测试自己造出 integer，再要求它们通过）。

    未知类型给**全部**候选：有些参数的类型信息在数据源里就是残的，
    用一个固定值要求它通过，测出来的是测试自己的偏见，不是校验器的缺陷。
    """
    by_json_type = {
        "number": [1.5, 3],
        "integer": [3, 1.5],
        "string": ["x"],
        "boolean": [True, False],
        "array": [[1, 2], []],
        "object": [["ent_1"], {"__ent__": "ent_1"}],
        "null": [None],
    }
    allowed = _TYPE_MAP.get(normalized_type)
    if not allowed:
        return [1.5, "x", True, ["ent_1"], [1, 2], None]
    # object 优先：游戏实体类参数（Object/Group/Control/Task/Waypoint…）
    # 在 JSON 侧统一是单元素数组，排前面能最快命中
    order = ["object", "array", "string", "number", "integer", "boolean", "null"]
    out: list = []
    for key in order:
        if key in allowed:
            out.extend(by_json_type[key])
    return out or [1.5, "x", True, ["ent_1"], [1, 2], None]


def first_passing(rec: dict, declared: list[dict]) -> tuple[bool, list, str]:
    """对一条签名做候选值搜索：存在一组能通过校验的参数吗？

    这比"按类型造一个值"更能反映真实能力——模型也是这么试的。
    返回 (是否通过, 通过的参数, 失败说明)。
    """
    from itertools import product

    pools = [candidates_for(spec["type"]) for spec in declared]
    if not pools:
        return True, [], ""
    # 组合数上限保护：签名超过 4 个参数时只取前 2 个候选
    total = 1
    for p in pools:
        total *= len(p)
    if total > 256:
        pools = [p[:2] for p in pools]
    last = ""
    for combo in product(*pools):
        result = check_call(rec, list(combo))
        if result["ok"]:
            return True, list(combo), ""
        for r in result["results"]:
            for why in r["reasons"]:
                if "类型不符" in why:
                    last = why
    return False, [], last


class TestAllCommandsSelfCheck(unittest.TestCase):
    """对全部命令做"是否存在合法调用"的自检。

    这是本仓库存数据层最关键的一条断言：它同时证明
      · 签名解析不崩溃；
      · 类型归一化没有把合法调用误判为类型错误。
    **零容忍**：当前实现下 4337 个有参数的签名全部能找到合法调用。
    一旦出现新的失败条目，说明类型归一化或参数解析出现了真回归
    （开发过程中正是这条断言抓出了 `NIL`/`HashMap` 未映射、
    "类型词写在参数名里"未剥离等一批缺陷）。
    """

    @classmethod
    def setUpClass(cls):
        cls.idx = CommandIndex(DATA)
        cls.checked = 0
        cls.crashes = []
        cls.failed = []
        for key, rec in cls.idx.records.items():
            for var in signature_variants(rec):
                if not var["args"]:
                    continue
                try:
                    ok, combo, why = first_passing(rec, var["args"])
                except Exception as exc:  # noqa: BLE001
                    cls.crashes.append((key, var["code"][:40], repr(exc)))
                    continue
                cls.checked += 1
                if not ok:
                    cls.failed.append((key, var["code"][:40], why[:120]))

    def test_coverage_is_broad(self):
        self.assertGreater(self.checked, 4000, f"自检覆盖太少：{self.checked}")

    def test_no_crashes(self):
        self.assertEqual(self.crashes[:5], [], f"校验器崩溃：{self.crashes[:5]}")

    def test_every_command_has_a_reachable_call(self):
        self.assertEqual(
            self.failed[:5], [],
            f"有 {len(self.failed)} 个签名找不到任何合法调用：{self.failed[:5]}")


class TestLibraryIntegrity(unittest.TestCase):
    """自带命令库的完整性与规模。"""

    @classmethod
    def setUpClass(cls):
        cls.idx = CommandIndex(DATA)

    def test_data_file_exists(self):
        self.assertTrue(os.path.isfile(DATA),
                        "命令库缺失；先运行 tools/build_commands.py")

    def test_schema_version_and_meta(self):
        with lzma.open(DATA, "rb") as fh:
            payload = json.loads(fh.read().decode("utf-8"))
        # 引用代码里的常量，避免"改了格式忘了改测试"再来一次
        from knowledge.index import EXPECTED_SCHEMA
        self.assertEqual(payload["schema"], EXPECTED_SCHEMA)
        gen = payload["generated"]
        for key in ("source_sha256", "records", "builder", "at"):
            self.assertIn(key, gen)
        self.assertEqual(gen["records"], len(payload["records"]))
        self.assertEqual(len(gen["source_sha256"]), 64)

    def test_expected_size(self):
        """条目数是"来源未被误改"的最直接信号。"""
        self.assertEqual(self.idx.count(), 5181)

    def test_every_record_has_required_fields(self):
        """必需字段：命令名 / 类型 / 签名 / 来源。

        `d`（wiki 描述正文）**刻意不在其中** —— 它受版权保护（BI wiki），
        与 MIT 分发不兼容，已在 schema 2 移除。见 NOTICE。
        """
        missing = []
        for key, rec in self.idx.records.items():
            for field in ("n", "ty", "sx", "src"):
                if field not in rec:
                    missing.append((key, field))
        self.assertEqual(missing, [], f"字段缺失：{missing[:5]}")

    def test_no_copyrighted_description_in_data(self):
        """反向断言：数据里**不得**再出现描述正文。

        这一条是防回归的——有人"顺手"把 wiki 描述加回来，就等于把
        版权问题一起加回来。需要说明时由 cmd_info 给 wiki 链接。
        """
        offenders = [k for k, r in self.idx.records.items() if r.get("d")]
        self.assertEqual(offenders, [], f"仍有描述字段：{offenders[:5]}")
        for key, rec in self.idx.records.items():
            for sig in rec.get("sx") or []:
                for arg in sig.get("a") or []:
                    self.assertNotIn("d", arg,
                                     f"{key} 的参数仍带描述字段")

    def test_every_record_has_at_least_one_signature(self):
        empty = [k for k, r in self.idx.records.items() if not r.get("sx")]
        self.assertEqual(empty, [], f"无签名的记录：{empty[:5]}")

    def test_signatures_have_content(self):
        """每条签名至少要能说明"怎么调"或"返回什么"。

        数据里有 18 条函数式签名 code 为空（如 BIS_fnc_3DEN_init），
        但它们都带返回类型；完全没有信息的签名才是问题。
        """
        bad = []
        for k, r in self.idx.records.items():
            for s in r["sx"]:
                if not s.get("c") and not s.get("r"):
                    bad.append(k)
        # 数据源里只有 2 条如此（BIS_fnc_basicTask / BIS_fnc_execRemote）。
        # 数量上升意味着来源结构变了，需要重新核对生成脚本。
        self.assertLessEqual(len(bad), 2, f"无内容签名增多：{bad[:5]}")

    def test_empty_code_is_rare_and_known(self):
        """空 code 的规模要盯住：突然变多意味着数据源结构变了。"""
        empty = sum(1 for r in self.idx.records.values()
                    for s in r["sx"] if not s.get("c"))
        self.assertLessEqual(empty, 20, f"空 code 签名增多：{empty}")

    def test_compat_coverage(self):
        """版本兼容信息必须被保留（本地那份精简索引就是裁掉了它才失去价值）。"""
        with_compat = sum(1 for r in self.idx.records.values() if r.get("compat"))
        with_arma3 = sum(
            1 for r in self.idx.records.values()
            if any(c.get("g") == "arma3" for c in r.get("compat") or []))
        self.assertEqual(with_compat, 4655)
        self.assertEqual(with_arma3, 4608)

    def test_no_external_path_dependency(self):
        """数据文件里不得残留外部仓库路径（独立性检查的数据侧一半）。"""
        with lzma.open(DATA, "rb") as fh:
            blob = fh.read().decode("utf-8")
        for forbidden in ("arma3-sqf-skill", "arma_llm_commander",
                          "arma3-terrain-grid"):
            self.assertNotIn(forbidden, blob)




class TestQueries(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.idx = CommandIndex(DATA)

    def test_families_partition_everything(self):
        total = sum(f["count"] for f in self.idx.families())
        self.assertEqual(total, self.idx.count())

    def test_known_families_present(self):
        names = {f["family"] for f in self.idx.families()}
        for expected in ("set", "get", "create", "ctrl", "bis_fnc"):
            self.assertIn(expected, names)

    def test_family_lookup(self):
        self.assertEqual(self.idx.family_of("setPosATL"), "set")
        self.assertEqual(self.idx.family_of("BIS_fnc_spawnGroup"), "bis_fnc")
        self.assertEqual(self.idx.family_of("CBA_fnc_addBISEventHandler"), "cba_fnc")
        self.assertEqual(self.idx.family_of("zzzUnknownThing"), "其他")

    def test_get_is_case_insensitive(self):
        self.assertIsNotNone(self.idx.get("setposatl"))
        self.assertIsNotNone(self.idx.get("SetPosATL"))

    def test_get_unique_prefix(self):
        rec = self.idx.get("setposat")
        self.assertIsNotNone(rec)
        self.assertEqual(rec["n"].lower(), "setposatl")

    def test_get_missing_returns_none(self):
        self.assertIsNone(self.idx.get("this_cmd_does_not_exist_zz"))

    def test_prefix_candidates_suggest(self):
        cands = self.idx.prefix_candidates("setpos")
        # 前缀命中的候选必须排在前面（候选名是字典键，小写）
        self.assertTrue(cands, "应给出相近命令建议")
        self.assertTrue(any("setpos" in c for c in cands[:4]),
                        f"前缀命中的候选未被优先给出：{cands}")

    def test_search_ranks_exact_first(self):
        hits = self.idx.search("setposatl", limit=10)
        self.assertTrue(hits)
        self.assertEqual(hits[0]["name"].lower(), "setposatl")

    def test_search_filters(self):
        only_cmd = self.idx.search("pos", kind="command", limit=50)
        self.assertTrue(all(h["type"] == "command" for h in only_cmd))
        only_fn = self.idx.search("spawn", kind="function", limit=50)
        self.assertTrue(all(h["type"] == "function" for h in only_fn))

    def test_search_empty_query(self):
        self.assertEqual(self.idx.search(""), [])
        self.assertEqual(self.idx.search("   "), [])

    def test_arma3_since(self):
        rec = self.idx.get("inputMouse")
        self.assertEqual(self.idx.arma3_since(rec), "2.08")


class TestTypeNormalization(unittest.TestCase):
    def test_empty_unknown(self):
        self.assertEqual(_normalize_type(""), ("unknown", False))
        self.assertEqual(_normalize_type("   "), ("unknown", False))

    def test_case_insensitive(self):
        self.assertEqual(_normalize_type("NUMBER")[0], "number")
        self.assertEqual(_normalize_type("String")[0], "string")
        self.assertEqual(_normalize_type("BOOL")[0], "boolean")
        self.assertEqual(_normalize_type("OBJECT")[0], "object")

    def test_array_of(self):
        self.assertEqual(_normalize_type("Array of Numbers")[0], "array")
        self.assertEqual(_normalize_type("Array of Strings")[0], "array")

    def test_type_word_with_description(self):
        """真实数据里类型词后面常跟一长串说明。"""
        self.assertEqual(_normalize_type("Boolean (Optional, default false)")[0],
                         "boolean")
        self.assertEqual(
            _normalize_type("Array format Position2D or PositionATL")[0], "array")
        self.assertEqual(
            _normalize_type("Object; Array format Position2D")[0], "object")

    def test_typo_tolerated(self):
        self.assertEqual(_normalize_type("NUMVER")[0], "number")

    def test_every_mapped_type_is_reachable(self):
        """_TYPE_MAP 里每个键都应能被某个输入串命中（防止死条目）。"""
        for key in _TYPE_MAP:
            got, known = _normalize_type(key)
            self.assertTrue(known, f"{key} 无法被归一化")
            self.assertEqual(got, key)


class TestArgParsing(unittest.TestCase):
    def test_optional_detected(self):
        spec = parse_arg({"n": "preserveElevation: Boolean (Optional, default false)",
                          "t": "", "d": ""})
        self.assertTrue(spec["optional"])
        self.assertEqual(spec["type"], "boolean")
        self.assertEqual(spec["default"], "false")

    def test_name_without_type(self):
        spec = parse_arg({"n": "unit", "t": "Object", "d": ""})
        self.assertEqual(spec["name"], "unit")
        self.assertEqual(spec["type"], "object")
        self.assertFalse(spec["optional"])

    def test_unnamed_arg(self):
        spec = parse_arg({"n": "", "t": "", "d": ""})
        self.assertEqual(spec["name"], "(未命名)")
        self.assertFalse(spec["type_known"])


if __name__ == "__main__":
    unittest.main(verbosity=2)
