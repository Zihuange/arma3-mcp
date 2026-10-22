#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""闸门与分级测试。

重点验证两件事：
  1. **硬禁命令没有任何开关可以放行**——包括显式白名单也不行；
  2. **默认配置下不会误伤常规操作**（例如查位置、设位置、开装具界面）。
第二点同样重要：一个把正常操作也拦下来的闸门，会被使用者整体关掉，
那时它提供的保护就是零。
"""

from __future__ import annotations

import json
import os
import sys
import tempfile
import unittest

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from guard import Gates, classify, forbidden_list  # noqa: E402
from guard.gates import CHEAT_COMMANDS, FORBIDDEN_EXACT, WRITE_PREFIXES  # noqa: E402


class TestClassification(unittest.TestCase):
    def test_forbidden_dynamic_code(self):
        for cmd in ("execVM", "call", "compile", "compileFinal", "spawn",
                    "BIS_fnc_execVM", "BIS_fnc_spawnGroup", "loadFile",
                    "preprocessFile", "callExtension", "remoteExec"):
            self.assertEqual(classify(cmd), "forbidden", cmd)

    def test_case_insensitive(self):
        self.assertEqual(classify("EXECVM"), "forbidden")
        self.assertEqual(classify("CreateVehicle"), "exotic")

    def test_exotic_creates_resources(self):
        for cmd in ("createVehicle", "createGroup", "createUnit", "createMarker",
                    "createLocation", "createSimpleTask"):
            self.assertEqual(classify(cmd), "exotic", cmd)

    def test_exotic_debug_backdoors(self):
        for cmd in ("attrit", "intel_debug", "debug_throw", "air_threat",
                    "group_attach_player"):
            self.assertEqual(classify(cmd), "exotic", cmd)

    def test_upload_channel_is_gated(self):
        """diag_log 是上行通道：不设闸门的话，它可以伪造事件、污染态势。"""
        self.assertEqual(classify("diag_log"), "exotic")

    def test_write_commands(self):
        for cmd in ("setPosATL", "doMove", "addWeapon", "removeAllWeapons",
                    "playMove", "switchMove", "deleteVehicle", "enableAI"):
            self.assertEqual(classify(cmd), "write", cmd)

    def test_read_commands(self):
        for cmd in ("getPos", "markerPos", "allUnits", "nearestObjects",
                    "isPlayer", "canMove", "hasWeapon", "vectorDir"):
            self.assertEqual(classify(cmd), "read", cmd)

    def test_read_exceptions(self):
        for cmd in ("getVariable", "getMarkerPos", "deleteAt", "set"):
            self.assertEqual(classify(cmd), "read", cmd)

    def test_cba_ace_default_to_write(self):
        """社区函数副作用无法静态判断 → 保守按写处理。"""
        self.assertEqual(classify("CBA_fnc_addBISEventHandler"), "write")
        self.assertEqual(classify("ACE_ai_fnc_garrison"), "write")

    def test_empty_name_is_forbidden(self):
        self.assertEqual(classify(""), "forbidden")
        self.assertEqual(classify("   "), "forbidden")

    def test_every_write_prefix_is_used(self):
        """模式表的每一项至少应命中一条真实命令，防止死规则堆积。"""
        from knowledge.index import default_index
        idx = default_index()
        names = [r["n"] for r in idx.records.values()]
        unused = [p for p in WRITE_PREFIXES
                  if not any(n.lower().startswith(p) for n in names)]
        self.assertEqual(unused, [], f"没有命中任何命令的写前缀：{unused}")


class TestGates(unittest.TestCase):
    def test_defaults_are_cautious_but_usable(self):
        g = Gates.from_env({})
        self.assertTrue(g.engine_read)
        self.assertTrue(g.engine_write)
        self.assertFalse(g.engine_exotic, "EXOTIC 默认必须关闭")
        self.assertFalse(g.input_inject, "输入注入默认必须关闭")
        self.assertTrue(g.input_foreground_only)

    def test_env_parsing(self):
        g = Gates.from_env({"ALC_ENGINE_EXOTIC": "1", "ALC_ENGINE_WRITE": "off",
                            "ALC_INPUT_INJECT": "yes"})
        self.assertTrue(g.engine_exotic)
        self.assertFalse(g.engine_write)
        self.assertTrue(g.input_inject)

    def test_env_blank_means_default(self):
        g = Gates.from_env({"ALC_ENGINE_EXOTIC": "", "ALC_ENGINE_WRITE": "  "})
        self.assertFalse(g.engine_exotic)
        self.assertTrue(g.engine_write)

    def test_read_allowed_by_default(self):
        v = Gates.from_env({}).check("getPos")
        self.assertTrue(v.allowed)
        self.assertEqual(v.level, "read")

    def test_write_allowed_by_default(self):
        self.assertTrue(Gates.from_env({}).check("setPosATL").allowed)

    def test_write_blocked_when_disabled(self):
        v = Gates.from_env({"ALC_ENGINE_WRITE": "0"}).check("setPosATL")
        self.assertFalse(v.allowed)
        self.assertEqual(v.needs_flag, "ALC_ENGINE_WRITE")

    def test_read_blocked_when_disabled(self):
        v = Gates.from_env({"ALC_ENGINE_READ": "0"}).check("getPos")
        self.assertFalse(v.allowed)
        self.assertEqual(v.needs_flag, "ALC_ENGINE_READ")

    def test_exotic_blocked_by_default(self):
        v = Gates.from_env({}).check("createVehicle")
        self.assertFalse(v.allowed)
        self.assertEqual(v.needs_flag, "ALC_ENGINE_EXOTIC")

    def test_cheat_needs_own_switch(self):
        v = Gates.from_env({}).check("attrit")
        self.assertFalse(v.allowed)
        self.assertEqual(v.needs_flag, "ALC_ALLOW_CHEAT")

    def test_cheat_allowed_when_both_on(self):
        v = Gates.from_env({"ALC_ENGINE_EXOTIC": "1", "ALC_ALLOW_CHEAT": "1"}) \
            .check("attrit")
        self.assertTrue(v.allowed)

    def test_exotic_allowed_when_enabled(self):
        v = Gates.from_env({"ALC_ENGINE_EXOTIC": "1"}).check("createVehicle")
        self.assertTrue(v.allowed)

    # ------------------------------------------------------------ 硬禁的绝对性

    def test_forbidden_never_allowed_even_with_everything_on(self):
        g = Gates.from_env({
            "ALC_ENGINE_READ": "1", "ALC_ENGINE_WRITE": "1",
            "ALC_ENGINE_EXOTIC": "1", "ALC_ALLOW_CHEAT": "1",
            "ALC_INPUT_INJECT": "1",
        })
        for cmd in sorted(FORBIDDEN_EXACT):
            self.assertFalse(g.check(cmd).allowed, f"{cmd} 不该被放行")
        for cmd in ("BIS_fnc_execVM", "BIS_fnc_spawnGroup", "BIS_fnc_dbg_console"):
            self.assertFalse(g.check(cmd).allowed, f"{cmd} 不该被放行")

    def test_override_cannot_unlock_forbidden(self):
        """显式白名单也不能解锁硬禁——这是刻意的，避免"留个后门"。"""
        g = Gates.from_env({"ALC_ALLOW_COMMANDS": "execVM,compile,callExtension",
                            "ALC_ENGINE_EXOTIC": "1"})
        for cmd in ("execVM", "compile", "callExtension"):
            self.assertFalse(g.check(cmd).allowed, f"{cmd} 被 override 放行了")

    def test_override_works_for_non_forbidden(self):
        g = Gates.from_env({"ALC_ALLOW_COMMANDS": "createVehicle",
                            "ALC_ENGINE_EXOTIC": "0"})
        self.assertTrue(g.check("createVehicle").allowed)

    def test_reasons_are_human_readable(self):
        v = Gates.from_env({}).check("createVehicle")
        self.assertIn("EXOTIC", v.reason)
        v2 = Gates.from_env({}).check("execVM")
        self.assertIn("硬禁", v2.reason)

    def test_snapshot_is_json_serializable(self):
        snap = Gates.from_env({"ALC_ALLOW_COMMANDS": "foo, bar"}).snapshot()
        json.dumps(snap, ensure_ascii=False)
        self.assertEqual(snap["overrides"], ["bar", "foo"])

    def test_forbidden_list_shape(self):
        items = forbidden_list()
        self.assertIn("execvm", items)
        self.assertTrue(any(i.endswith("*") for i in items), "应含前缀规则")


class TestAudit(unittest.TestCase):
    def test_audit_line_is_valid_jsonl(self):
        from guard import audit
        line = audit("exec", {"cmd": "setPosATL", "ok": True})
        rec = json.loads(line)
        self.assertEqual(rec["tool"], "exec")
        self.assertEqual(rec["cmd"], "setPosATL")
        self.assertIn("ts", rec)

    def test_audit_appends_to_file(self):
        from guard import audit
        with tempfile.TemporaryDirectory() as tmp:
            path = os.path.join(tmp, "audit.jsonl")
            audit("exec", {"cmd": "a"}, path=path)
            audit("exec", {"cmd": "b"}, path=path)
            with open(path, encoding="utf-8") as fh:
                lines = [json.loads(x) for x in fh if x.strip()]
            self.assertEqual([x["cmd"] for x in lines], ["a", "b"])

    def test_audit_survives_unwritable_path(self):
        """审计失败不该阻断操作本身（但返回值仍是可记录的原始行）。"""
        from guard import audit
        line = audit("exec", {"cmd": "a"}, path="/proc/nonexistent/x.jsonl")
        self.assertIn("a", line)


if __name__ == "__main__":
    unittest.main(verbosity=2)
