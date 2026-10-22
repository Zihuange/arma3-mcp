#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""UI 定位的换算测试（不需要游戏）。

## 为什么这些用例重要

坐标换算错了**不会报错**——只会点到别的地方，而且换个分辨率或窗口位置之后
症状还会变。所以这里把公式钉死在**实测数据**上，而不是自己编一组数：

    编辑器地图控件 ctrlPosition = [-0.281379, -0.0882083, 1.56276, 1.17642]
    客户区 1360x768，原点 (0, 23)  →  屏幕中心应为 (680, 407)

680/407 正是客户区中心，与"地图铺满编辑区"相符。这条基准一旦被改坏，
测试立刻失败。
"""

from __future__ import annotations

import os
import sys
import unittest

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, REPO)

from adapters.ui_tools import BATCH, _as_list, _as_int, _as_str, _unv, to_screen  # noqa: E402

# 实测：编辑器地图控件
GEOM = {"origin": (0, 23), "size": (1360, 768)}
MAP_REL = [-0.281379, -0.0882083, 1.56276, 1.17642]


class TestUnwrap(unittest.TestCase):
    """游戏侧把每个值包成 {v, t}，取值前必须先剥壳。"""

    def test_unwrap_scalar(self):
        self.assertEqual(_unv({"v": 42, "t": "number"}), 42)

    def test_unwrap_passthrough(self):
        self.assertEqual(_unv("plain"), "plain")

    def test_helpers_reject_wrong_type(self):
        self.assertEqual(_as_str({"v": 5, "t": "number"}), "")
        self.assertIsNone(_as_int({"v": "x", "t": "text"}))
        self.assertEqual(_as_list({"v": "x", "t": "text"}), [])

    def test_helpers_unwrap(self):
        self.assertEqual(_as_str({"v": "Map", "t": "text"}), "Map")
        self.assertEqual(_as_int({"v": 7, "t": "number"}), 7)
        self.assertEqual(_as_list([{"v": 1, "t": "number"}]), [{"v": 1, "t": "number"}])


class TestToScreen(unittest.TestCase):
    def test_measured_map_control_lands_at_client_centre(self):
        """实测基准：地图控件中心 = 客户区中心。"""
        self.assertEqual(to_screen(MAP_REL, GEOM), (680, 407))

    def test_origin_is_added_not_ignored(self):
        """客户区原点必须加进去 —— 漏了它，所有点击都会上移 23px。"""
        geom = {"origin": (100, 200), "size": (1000, 500)}
        # 相对 (0,0,0,0) 的控件中心 = 客户区左上角
        self.assertEqual(to_screen([0.0, 0.0, 0.0, 0.0], geom), (100, 200))

    def test_size_is_used_not_just_position(self):
        """取的是**中心**：只用 rel[0]/rel[1] 会点到控件左上角。"""
        geom = {"origin": (0, 0), "size": (100, 100)}
        # 控件占满右半屏：[0.5, 0, 0.5, 1] → 中心 (0.75, 0.5) → (75, 50)
        self.assertEqual(to_screen([0.5, 0.0, 0.5, 1.0], geom), (75, 50))

    def test_negative_position_is_allowed(self):
        """控件可以超出屏幕（实测地图控件就是负坐标），不该崩或被夹断。"""
        geom = {"origin": (0, 0), "size": (1000, 1000)}
        self.assertEqual(to_screen([-1.0, -1.0, 1.0, 1.0], geom), (-500, -500))

    def test_rounding(self):
        geom = {"origin": (0, 0), "size": (1000, 1000)}
        # 中心 0.3335 * 1000 = 333.5 → banker's rounding 下 round(333.5) = 334
        x, y = to_screen([0.0, 0.0, 0.667, 0.667], geom)
        self.assertEqual((x, y), (334, 334))

    def test_batch_size_is_sane(self):
        """批量读类名的步长不该被改成 1（那会让枚举慢一个数量级）。"""
        self.assertGreaterEqual(BATCH, 4)


class TestLocatorGuards(unittest.TestCase):
    """定位器的失败路径：不该抛异常，要给得出人话的原因。"""

    def test_window_geometry_rejects_wrong_field_name(self):
        """字段名是 client 而不是 client_size —— 这里守住这个契约。

        实测踩过：写成 client_size 会静默拿到 None，然后工具报"拿不到窗口
        几何"，看起来像 DLL 的问题，其实只是字段名错。
        """
        from adapters.ui_tools import UiLocator

        class FakeChan:
            def send(self, payload, timeout_s=5.0):  # noqa: ANN001
                class R:
                    ok = True
                    result = {"ok": True, "client_origin": [0, 23],
                              "client_size": [1360, 768]}   # 故意用错字段名
                return R()

        self.assertIsNone(UiLocator(FakeChan()).window_geometry())

    def test_window_geometry_accepts_real_shape(self):
        from adapters.ui_tools import UiLocator

        class FakeChan:
            def send(self, payload, timeout_s=5.0):  # noqa: ANN001
                class R:
                    ok = True
                    result = {"ok": True, "client_origin": [0, 23],
                              "client": [1360, 768]}
                return R()

        self.assertEqual(UiLocator(FakeChan()).window_geometry(),
                         {"origin": (0, 23), "size": (1360, 768)})


if __name__ == "__main__":
    unittest.main()


class FakeExecChan:
    """按表达式内容作答的假通道，用来验证 ui_locate 的扫描范围。

    只实现 ui_locate 真正会发的那几种表达式，按正则识别意图。
    """

    def __init__(self, displays):  # noqa: ANN001
        # displays: [[类名, ...], ...]，每个元素是一个 display 的控件类名表
        self.displays = displays
        self.expressions = []

    def send(self, payload, timeout_s=5.0):  # noqa: ANN001
        import re
        from adapters.channel import Reply

        cmd = payload.get("cmd")
        if cmd == "status":
            # ui_locate 入口会做形态检查（见 health.has_ui）：需要 status + 窗口
            # 两条都成功才判为"有界面"。
            return Reply(ok=True, cid="s", channel="tcp",
                         result={"ok": True, "connected": True, "inbox": 0})
        if cmd == "window_info":
            return Reply(ok=True, cid="w", channel="tcp",
                         result={"ok": True, "client": [1000, 1000],
                                 "client_origin": [0, 0]})
        if cmd != "exec":
            return Reply(ok=False, cid="x", channel="tcp", error="未预期的命令")

        expr = payload["args"][0]
        self.expressions.append(expr)

        if expr == "count allDisplays":
            return Reply(ok=True, cid="a", channel="tcp", result=len(self.displays))

        m = re.match(r"count allControls \(allDisplays select (\d+)\)$", expr)
        if m:
            return Reply(ok=True, cid="b", channel="tcp",
                         result=len(self.displays[int(m.group(1))]))

        # ⚠ 先判 ctrlPosition：它的表达式同样含 `)) select N`，若放在类名分支
        # 之后会被那条正则先命中，于是"读位置"被当成"读类名"应答。
        m = re.search(r"ctrlPosition \(\(allControls \(allDisplays select (\d+)\)\) "
                      r"select (\d+)\)", expr)
        if m:
            return Reply(ok=True, cid="d", channel="tcp",
                         result=[0.0, 0.0, 1.0, 1.0])

        # 批量读类名：[ctrlClassName ((allControls (allDisplays select D)) select I), ...]
        d = re.search(r"allDisplays select (\d+)", expr)
        idxs = re.findall(r"\)\) select (\d+)", expr)
        if d and idxs:
            names = self.displays[int(d.group(1))]
            return Reply(ok=True, cid="c", channel="tcp",
                         result=[names[int(i)] for i in idxs])

        return Reply(ok=False, cid="e", channel="tcp", error="未预期的表达式: " + expr[:80])


def _locate(chan, **kwargs):  # noqa: ANN001
    from mcpcore.registry import Registry
    from adapters import ui_tools, health

    health.forget_ui_cache()
    reg = Registry()
    ui_tools.register(reg, chan)
    return reg.call("ui_locate", kwargs)


class TestScanScope(unittest.TestCase):
    """max_scan 是**每个 display** 的配额 —— 这条曾经写错过两次。"""

    def test_later_display_is_still_scanned(self):
        """第一个 display 吃满配额后，后面的 display 仍要被扫到。

        目标控件在第二个 display 里是常见情形（编辑器的 Map 就是），所以
        "扫满一个就收工"会让工具报"没有匹配"——而控件明明存在。
        """
        chan = FakeExecChan([["A"] * 100, ["Map"] * 4])
        res = _locate(chan, match_class="Map", max_scan=5, limit=5)
        self.assertIn("Map", res.text)
        self.assertNotIn("没有匹配", res.text)

    def test_scanned_counts_all_displays(self):
        """scanned 应当是各 display 的扫描数之和，而不是只有第一个。"""
        chan = FakeExecChan([["A"] * 100, ["B"] * 4])
        res = _locate(chan, match_class="Zzz", max_scan=5)
        self.assertEqual(res.structured["scanned"], 9)    # 5 + 4（第二个只有 4 个）

    def test_single_display_arg_limits_scope(self):
        chan = FakeExecChan([["A"] * 100, ["Map"] * 4])
        res = _locate(chan, match_class="Map", display=1, max_scan=5)
        self.assertIn("Map", res.text)
        self.assertEqual(res.structured["scanned"], 4)

    def test_truncated_flag_when_quota_hit(self):
        chan = FakeExecChan([["A"] * 100])
        res = _locate(chan, match_class="Zzz", max_scan=5)
        self.assertTrue(res.structured["truncated"])

    def test_requires_a_match_condition(self):
        """不给条件就等于在几百个控件里全量回读位置，必须拦住。"""
        chan = FakeExecChan([["A"] * 10])
        res = _locate(chan)
        self.assertTrue(res.is_error)
        self.assertIn("至少要给一个匹配条件", res.text)
