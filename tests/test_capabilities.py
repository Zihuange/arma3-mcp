#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""能力矩阵测试。

能力矩阵的价值全在"结论可信"，所以测试重点是**证据链**：
每条结论的依据命令必须真实存在于命令库，且版本与声明一致。
"""

from __future__ import annotations

import json
import os
import sys
import unittest

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, REPO)

from knowledge.capabilities import CapabilityMatrix  # noqa: E402
from knowledge.index import CommandIndex  # noqa: E402

DATA = os.path.join(REPO, "data", "capabilities.json")


class TestCapabilityMatrix(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        if not os.path.isfile(DATA):
            raise unittest.SkipTest("能力矩阵缺失；先跑 tools/build_capabilities.py")
        cls.matrix = CapabilityMatrix(DATA)
        cls.idx = CommandIndex()

    def test_schema_and_counts(self):
        with open(DATA, encoding="utf-8") as fh:
            payload = json.load(fh)
        self.assertEqual(payload["schema"], 1)
        self.assertEqual(payload["problems"], [], "生成时不应有核对问题")
        self.assertGreater(len(payload["entries"]), 10)

    def test_every_reference_command_exists(self):
        """每条结论的依据命令必须真实存在——这是矩阵可信的根据。"""
        missing = []
        for entry in self.matrix.entries:
            for cmd in entry["commands"]:
                rec = self.idx.get(cmd["name"])
                if rec is None:
                    missing.append((entry["key"], cmd["name"]))
                elif (rec.get("sx") or [{}])[0].get("c") is None:
                    pass
        self.assertEqual(missing, [], f"依据命令不存在：{missing[:5]}")

    def test_version_matches_library(self):
        """声明的版本必须与命令库一致（防止手写漂移）。"""
        bad = []
        for entry in self.matrix.entries:
            for cmd in entry["commands"]:
                rec = self.idx.get(cmd["name"])
                if rec is None:
                    continue
                actual = self.idx.arma3_since(rec)
                if actual != cmd.get("arma3_since"):
                    bad.append((entry["key"], cmd["name"], cmd.get("arma3_since"),
                                actual))
        self.assertEqual(bad, [], f"版本不一致：{bad[:5]}")

    def test_since_is_derived_not_declared(self):
        """since 必须是依据命令中最晚的引入版本（自动推导的结果）。"""
        bad = []
        for entry in self.matrix.entries:
            versions = [c["arma3_since"] for c in entry["commands"]
                        if c.get("arma3_since")]
            if not versions:
                if entry.get("since") is not None:
                    bad.append((entry["key"], "应为 None"))
                continue
            def key(v):
                parts = []
                for p in str(v).split("."):
                    digits = "".join(ch for ch in p if ch.isdigit())
                    parts.append(int(digits) if digits else 0)
                while len(parts) < 3:
                    parts.append(0)
                return tuple(parts[:3])
            expected = max(versions, key=key)
            if entry.get("since") != expected:
                bad.append((entry["key"], entry.get("since"), expected))
        self.assertEqual(bad, [], f"since 推导错误：{bad[:5]}")

    def test_engine_no_entries_have_no_commands(self):
        """声明"引擎做不到"的条目必须**没有**依据命令——空虚也是一种证据。"""
        bad = [e["key"] for e in self.matrix.entries
               if e["engine"] == "no" and e["commands"]]
        self.assertEqual(bad, [], f"引擎做不到却列了依据命令：{bad}")

    def test_engine_yes_entries_have_commands(self):
        bad = [e["key"] for e in self.matrix.entries
               if e["engine"] == "yes" and not e["commands"]]
        self.assertEqual(bad, [], f"声明可做却没有依据命令：{bad}")

    def test_known_conclusions_present(self):
        """关键结论必须在：它们直接决定架构分层（引擎层 vs Windows 层）。"""
        keys = {e["key"] for e in self.matrix.entries}
        for expected in ("inject_mouse_click", "inject_keyboard", "drag_pointer",
                         "activate_control", "world_screen_projection",
                         "dynamic_code", "unit_actions"):
            self.assertIn(expected, keys)

    def test_mouse_click_is_not_engine_supported(self):
        """这条结论是"必须引入 Windows 层"的全部理由，不能被改错。"""
        entry = self.matrix.find("inject_mouse_click")[0]
        self.assertEqual(entry["engine"], "no")
        self.assertEqual(entry["layer"], "windows")
        self.assertEqual(entry["commands"], [])

    def test_ctrlactivate_is_partial(self):
        entry = self.matrix.find("activate_control")[0]
        self.assertEqual(entry["engine"], "partial")
        self.assertIn("UI 事件处理器", entry["note"])

    def test_find_by_key_name_and_command(self):
        self.assertTrue(self.matrix.find("inject_mouse_click"))
        self.assertTrue(self.matrix.find("点击"))
        self.assertTrue(self.matrix.find("ctrlActivate"))
        self.assertEqual(self.matrix.find(""), [])
        self.assertEqual(self.matrix.find("zzz_no_such"), [])

    def test_render_includes_evidence(self):
        entry = self.matrix.find("unit_actions")[0]
        text = self.matrix.render(entry)
        self.assertIn("引擎支持", text)
        self.assertIn("依据命令", text)
        self.assertIn("action", text)

    def test_missing_file_raises_actionable_error(self):
        matrix = CapabilityMatrix("/nonexistent/capabilities.json")
        with self.assertRaises(FileNotFoundError) as ctx:
            _ = matrix.entries
        self.assertIn("build_capabilities", str(ctx.exception))


if __name__ == "__main__":
    unittest.main(verbosity=2)
