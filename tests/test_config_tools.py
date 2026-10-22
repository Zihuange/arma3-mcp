#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""游戏内 config 查询工具的端到端测试（用假游戏，不需要 Arma 3）。

本文件同时充当**游戏侧契约**：它规定了 `configQuery` / `configOfEntity`
该返回什么结构。SQF 侧实现（P1 上机部分）必须满足这里定义的形状——
这样上机时只需验证"引擎查询是否正确"，而不是同时猜协议。
"""

from __future__ import annotations

import json
import os
import socket
import subprocess
import sys
import time
import unittest

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, REPO)

from adapters.config_tools import glob_match  # noqa: E402

from tests.fake_game import FakeGame  # noqa: E402


def free_port() -> int:
    sock = socket.socket()
    sock.bind(("127.0.0.1", 0))
    port = sock.getsockname()[1]
    sock.close()
    return port


# ---- 假游戏侧：模拟 SQF 的实现（这就是给 SQF 的契约）-----------------------

def _cfg(t, v):            # noqa: ANN001
    return {"t": t, "v": v}


def config_query_handler(msg: dict) -> dict:
    """模拟 SQF 的 configQuery 分发器。

    参数约定（与 adapters/config_tools.py 一致）：
        [root, path(斜杠分隔), op, keys?, limit?]
    返回：见下面各 op 的结构。
    """
    args = msg.get("args") or []
    root = args[0] if len(args) > 0 else ""
    path = (args[1] if len(args) > 1 else "")
    op = args[2] if len(args) > 2 else "class"
    keys = args[3] if len(args) > 3 and isinstance(args[3], list) else []
    limit = args[4] if len(args) > 4 and isinstance(args[4], int) else 50

    if op == "tree":
        children = [
            {"name": "Car", "isClass": True, "parent": ""},
            {"name": "Tank", "isClass": True, "parent": ""},
            {"name": "B_MRAP_01_F", "isClass": True, "parent": "Car_F"},
            {"name": "B_Truck_01_transport_F", "isClass": True},
            {"name": "Boat_Transport_01_F", "isClass": True},
        ][:limit]
        return {"ok": True, "result": {"children": children, "total": 1247}}

    if op == "search":
        pattern = keys[0] if keys else ""
        all_names = ["B_MRAP_01_F", "B_MRAP_01_hmg_F", "O_MRAP_02_F",
                     "I_MRAP_03_F"]
        needle = pattern.replace("*", "").lower()
        matches = [n for n in all_names if needle in n.lower()][:limit]
        return {"ok": True, "result": {"matches": matches, "total": len(matches)}}

    if op == "class":
        props = {}
        known = {
            "displayName": _cfg("text", "M-ATV"),
            "transportSoldier": _cfg("number", 8),
            "armor": _cfg("number", 80),
            "maxSpeed": _cfg("number", 110),
            "weapons": _cfg("array", [_cfg("text", "HMG_127")]),
            "model": _cfg("config", ["CfgVehicles", "B_MRAP_01_F", "model"]),
            "onLoad": _cfg("code", ""),
        }
        missing = []
        for k in keys:
            if k in known:
                props[k] = known[k]
            else:
                missing.append(k)
        result = {
            "class": root + (("/" + path) if path else ""),
            "parentName": "Car_F",
            "hierarchy": ["All", "AllVehicles", "Land", "Car", "Car_F"],
            "sourceMod": "A3_Soft_F",
            "properties": props,
            "missing": missing,
        }
        if len(keys) > 20:
            result["truncated"] = True
        return {"ok": True, "result": result}

    if op == "roots":
        return {"ok": True, "result": {"roots": ["CfgVehicles", "CfgWeapons"]}}

    return {"ok": False, "error": "未知的 op：%s" % op}


def config_of_handler(msg: dict) -> dict:
    args = msg.get("args") or []
    name = (args[0][0] if args and isinstance(args[0], list) and args[0]
            else "")
    if name != "veh_1":
        return {"ok": True, "result": {"found": False}}
    return {"ok": True, "result": {
        "found": True, "type": "B_MRAP_01_F",
        "properties": {"displayName": _cfg("text", "M-ATV"),
                       "transportSoldier": _cfg("number", 8)},
    }}


class McpServer:
    def __init__(self, env: dict) -> None:
        merged = dict(os.environ)
        merged.update(env)
        self.proc = subprocess.Popen(
            ["/usr/bin/python3", "-m", "servers.engine"], cwd=REPO,
            stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE, env=merged)
        self._id = 0

    def request(self, method: str, params: dict | None = None) -> dict:
        self._id += 1
        msg = {"jsonrpc": "2.0", "id": self._id, "method": method}
        if params is not None:
            msg["params"] = params
        self.proc.stdin.write((json.dumps(msg) + "\n").encode())
        self.proc.stdin.flush()
        line = self.proc.stdout.readline()
        if not line:
            err = self.proc.stderr.read().decode("utf-8", "replace") if self.proc.stderr else ""
            raise AssertionError("服务器无响应；stderr=" + err[:400])
        return json.loads(line.decode())

    def call(self, tool: str, args: dict | None = None) -> dict:
        resp = self.request("tools/call", {"name": tool, "arguments": args or {}})
        if "error" in resp:
            raise AssertionError("协议错误：%s" % resp["error"])
        return resp["result"]

    def close(self) -> None:
        for stream in (self.proc.stdin, self.proc.stdout, self.proc.stderr):
            if stream is not None:
                try:
                    stream.close()
                except OSError:
                    pass
        try:
            self.proc.wait(timeout=10)
        except subprocess.TimeoutExpired:
            self.proc.kill()


def fn_list_handler(msg: dict) -> dict:
    """模拟 SQF 的 fnList：按 [tag, limit] 返回函数名或 tag 概览。

    结构与游戏侧一致（fn_fnList.sqf）：
        {"functions": [...], "total": n, "tags": [[tagName, count], ...],
         "truncated": bool, "tagFilter": "..."}
    """
    args = msg.get("args") or []
    tag = (args[0] if len(args) > 0 and isinstance(args[0], str) else "")
    limit = args[1] if len(args) > 1 and isinstance(args[1], int) else 200
    all_tags = [["a3mcp", 3], ["BIS", 2], ["bis", 1]]
    if not tag:
        return {"ok": True, "result": {
            "functions": [], "total": 5, "tags": all_tags,
            "truncated": False, "tagFilter": ""}}
    if tag.lower() == "a3mcp":
        names = ["a3mcp_fnc_init", "a3mcp_fnc_validate", "a3mcp_fnc_fnList"]
        return {"ok": True, "result": {
            "functions": names[:limit], "total": 3, "tags": [["a3mcp", 3]],
            "truncated": len(names) > limit, "tagFilter": "a3mcp"}}
    if tag.lower() == "bis":
        names = ["BIS_fnc_sortBy", "BIS_fnc_arrayShuffle"]
        return {"ok": True, "result": {
            "functions": names[:limit], "total": 2, "tags": [["BIS", 2]],
            "truncated": len(names) > limit, "tagFilter": "bis"}}
    return {"ok": True, "result": {
        "functions": [], "total": 0, "tags": [], "truncated": False,
        "tagFilter": tag}}


def text_of(result: dict) -> str:
    return "\n".join(c.get("text", "") for c in result.get("content", []))


class ConfigToolCase(unittest.TestCase):
    def setUp(self):
        self.port = free_port()
        self.srv = McpServer({
            "A3MCP_CHANNEL": "tcp", "A3MCP_TCP_HOST": "127.0.0.1",
            "A3MCP_TCP_PORT": str(self.port), "A3MCP_ENGINE_WRITE": "1",
            "A3MCP_AUDIT_LOG": os.path.join(REPO, "audit.jsonl"),
        })
        self.srv.request("initialize", {"protocolVersion": "2024-11-05"})
        self.game: FakeGame | None = None

    def tearDown(self):
        if self.game:
            self.game.close()
        self.srv.close()

    def connect_game(self) -> FakeGame:
        for _ in range(40):
            game = FakeGame(host="127.0.0.1", port=self.port)
            if game.connect():
                self.game = game
                game.handlers["configQuery"] = config_query_handler
                game.handlers["configOfEntity"] = config_of_handler
                game.handlers["fnList"] = fn_list_handler
                return game
            time.sleep(0.1)
        raise AssertionError("假游戏无法连接")

    def wait_tool(self, tool: str, args: dict, timeout: float = 8.0) -> dict:
        deadline = time.time() + timeout
        last = None
        while time.time() < deadline:
            last = self.srv.call(tool, args)
            if "尚未连接" not in text_of(last):
                return last
            time.sleep(0.1)
        return last


class TestConfigTree(ConfigToolCase):
    def test_roots_listing(self):
        result = self.srv.call("config_tree", {})
        text = text_of(result)
        self.assertIn("CfgVehicles", text)
        self.assertIn("CfgWeapons", text)

    def test_list_children(self):
        self.connect_game()
        result = self.wait_tool("config_tree", {"root": "CfgVehicles"})
        text = text_of(result)
        self.assertIn("B_MRAP_01_F", text)
        self.assertIn("1247", text, "应显示总数，让模型知道被截断了")
        data = result["structuredContent"]
        self.assertEqual(data["total"], 1247)

    def test_filter_children(self):
        self.connect_game()
        result = self.wait_tool("config_tree", {"root": "CfgVehicles",
                                                "filter": "mrap"})
        text = text_of(result)
        self.assertIn("B_MRAP_01_F", text)
        self.assertNotIn("B_Truck_01", text)


class TestConfigClass(ConfigToolCase):
    def test_preset_keys_used_when_keys_omitted(self):
        game = self.connect_game()
        self.wait_tool("config_class", {"root": "CfgVehicles",
                                        "path": ["B_MRAP_01_F"]})
        sent = [c for c in game.commands if c["cmd"] == "configQuery"][-1]
        keys = sent["args"][3]
        self.assertIn("transportSoldier", keys, "应使用 CfgVehicles 的预置字段集")

    def test_render_includes_inheritance_and_values(self):
        self.connect_game()
        result = self.wait_tool("config_class", {"root": "CfgVehicles",
                                                 "path": ["B_MRAP_01_F"],
                                                 "keys": ["displayName",
                                                          "transportSoldier"]})
        text = text_of(result)
        self.assertIn("M-ATV", text)
        self.assertIn("transportSoldier = 8", text)
        self.assertIn("父类", text)
        self.assertIn("继承链", text)

    def test_config_reference_rendered_as_path(self):
        """config 引用必须渲染成可继续查询的路径，而不是一串无意义的东西。"""
        self.connect_game()
        result = self.wait_tool("config_class", {"root": "CfgVehicles",
                                                 "path": ["B_MRAP_01_F"],
                                                 "keys": ["model"]})
        self.assertIn("CfgVehicles >> B_MRAP_01_F >> model", text_of(result))

    def test_code_property_not_returned(self):
        """Code 类型只报存在性——不返回代码内容（返回无用且诱导执行）。"""
        self.connect_game()
        result = self.wait_tool("config_class", {"root": "CfgVehicles",
                                                 "path": ["B_MRAP_01_F"],
                                                 "keys": ["onLoad"]})
        text = text_of(result)
        self.assertIn("code", text)
        self.assertNotIn("hint", text)

    def test_missing_key_reported_not_faked(self):
        self.connect_game()
        result = self.wait_tool("config_value", {"root": "CfgVehicles",
                                                 "path": ["B_MRAP_01_F"],
                                                 "key": "noSuchField"})
        self.assertIn("不存在", text_of(result))


class TestConfigSearch(ConfigToolCase):
    def test_search_by_wildcard(self):
        self.connect_game()
        result = self.wait_tool("config_search", {"pattern": "B_MRAP*",
                                                  "root": "CfgVehicles"})
        text = text_of(result)
        self.assertIn("B_MRAP_01_F", text)
        self.assertNotIn("O_MRAP_02_F", text)

    def test_no_match_explains(self):
        self.connect_game()
        result = self.wait_tool("config_search", {"pattern": "zzz_nothing*"})
        self.assertIn("无匹配", text_of(result))

    def test_no_match_points_at_the_real_cause(self):
        """无匹配时要提示"只搜直接子类，不递归"。

        实测踩到：有人搜 `BUS_Inf*`（root=CfgGroups）得到无匹配，就断定这个工具
        坏了——其实那个类在 `CfgGroups >> West >> BLU_F >> Infantry` 下，而引擎的
        `configClasses` 只遍历**直接子类**。无匹配最常见的原因就是搜错了层，
        所以这句话必须出现在提示里。
        """
        self.connect_game()
        result = self.wait_tool("config_search", {"pattern": "BUS_Inf*",
                                                  "root": "CfgGroups"})
        text = text_of(result)
        self.assertIn("无匹配", text)
        self.assertIn("直接子类", text)
        self.assertIn("path", text)

    def test_path_is_passed_through(self):
        """深层搜索靠 path —— 它必须原样传到游戏侧（斜杠拼接）。"""
        game = self.connect_game()
        self.wait_tool("config_search", {"pattern": "*", "root": "CfgGroups",
                                         "path": ["West", "BLU_F", "Infantry"]})
        self.assertTrue(game.wait_commands(1))
        sent = game.commands[-1]["args"]
        self.assertEqual(sent[0], "CfgGroups")                  # root
        self.assertEqual(sent[1], "West/BLU_F/Infantry")        # path（斜杠分隔）
        self.assertEqual(sent[2], "search")                     # op

    def test_reported_location_includes_path(self):
        """回执要写清"搜的是哪一层"，否则深层搜索的结果无从对账。"""
        self.connect_game()
        result = self.wait_tool("config_search", {"pattern": "*", "root": "CfgGroups",
                                                  "path": ["West"]})
        self.assertIn("CfgGroups/West", text_of(result))


class TestConfigOfEntity(ConfigToolCase):
    def test_found_entity(self):
        self.connect_game()
        result = self.wait_tool("config_of", {"entity": "veh_1"})
        text = text_of(result)
        self.assertIn("B_MRAP_01_F", text)
        self.assertIn("transportSoldier = 8", text)

    def test_missing_entity_is_clear_not_empty(self):
        """实体不存在时要说清"找不到"及其原因，不能静默返回空。"""
        self.connect_game()
        result = self.wait_tool("config_of", {"entity": "no_such_entity"})
        self.assertTrue(result["isError"])
        text = text_of(result)
        self.assertIn("找不到", text)
        self.assertIn("实体", text)


class TestCache(ConfigToolCase):
    def test_second_query_hits_cache(self):
        game = self.connect_game()
        args = {"root": "CfgVehicles", "path": ["B_MRAP_01_F"],
                "keys": ["armor"]}
        self.wait_tool("config_class", args)
        before = len([c for c in game.commands if c["cmd"] == "configQuery"])
        self.srv.call("config_class", args)          # 第二次
        time.sleep(0.3)
        after = len([c for c in game.commands if c["cmd"] == "configQuery"])
        self.assertEqual(before, after, "第二次应命中缓存，不再发往游戏")
        cache = self.srv.call("config_cache", {})
        self.assertIn("命中缓存", text_of(cache))

    def test_refresh_bypasses_cache(self):
        game = self.connect_game()
        args = {"root": "CfgVehicles", "path": ["B_MRAP_01_F"], "keys": ["armor"]}
        self.wait_tool("config_class", args)
        before = len([c for c in game.commands if c["cmd"] == "configQuery"])
        self.srv.call("config_class", dict(args, refresh=True))
        time.sleep(0.3)
        after = len([c for c in game.commands if c["cmd"] == "configQuery"])
        self.assertEqual(after, before + 1, "refresh 应绕过缓存重新查询")

    def test_clear_cache(self):
        self.connect_game()
        self.wait_tool("config_class", {"root": "CfgVehicles",
                                        "path": ["B_MRAP_01_F"], "keys": ["armor"]})
        result = self.srv.call("config_cache", {"clear": True})
        self.assertIn("已清空", text_of(result))


class TestNoChannel(ConfigToolCase):
    def test_config_query_without_game_is_honest(self):
        """没有游戏时必须明确报错，不能返回空数据假装成功。"""
        result = self.srv.call("config_class", {"root": "CfgVehicles",
                                                "path": ["B_MRAP_01_F"],
                                                "keys": ["armor"]})
        self.assertTrue(result["isError"])
        self.assertIn("尚未连接", text_of(result))


if __name__ == "__main__":
    unittest.main(verbosity=2)


class TestPayloadShape(ConfigToolCase):
    """断言**发出去的负载形状**，不依赖假游戏端的宽容度。

    为什么单列一个类：假游戏端的 handler 对 keys 做了 `isinstance(..., list)`
    容错，于是"limit 落进 keys 位置"这种错误在契约测试里完全看不见 ——
    而真游戏侧会因此抛 param 类型异常、被 fn_loop 的 catch 吞掉，表现为
    "命令收到了但毫无反应"。所以这里直接盯住线上负载本身。
    """

    def _last_config_query(self, game) -> dict:  # noqa: ANN001
        cmds = [c for c in game.commands if c.get("cmd") == "configQuery"]
        self.assertTrue(cmds, "没有发出 configQuery 命令")
        return cmds[-1]

    def test_args_keep_positional_alignment_without_keys(self):
        """不给 keys 时（config_tree(root=…) 的典型调用），位置仍须对齐。"""
        game = self.connect_game()
        self.wait_tool("config_tree", {"root": "CfgVehicles"})
        args = self._last_config_query(game)["args"]

        self.assertEqual(len(args), 5, "args 必须占满 [root, path, op, keys, limit]")
        self.assertIsInstance(args[3], list, "keys 位置必须收到数组，不能是 limit")
        self.assertIsInstance(args[4], int, "limit 位置必须收到数字")

    def test_args_keep_positional_alignment_with_keys(self):
        game = self.connect_game()
        self.wait_tool("config_value", {"root": "CfgVehicles",
                                        "path": ["B_MRAP_01_F"],
                                        "keys": ["displayName"]})
        args = self._last_config_query(game)["args"]

        self.assertEqual(len(args), 5)
        self.assertEqual(args[3], ["displayName"])
        self.assertIsInstance(args[4], int)


class TestGlobMatchContract(unittest.TestCase):
    """通配符匹配契约：`adapters.config_tools.glob_match` 是 SQF 侧
    `fn_configQuery::_globMatch` 的参考实现，两者必须等价。

    背景（实测踩到）：SQF 侧旧实现只取第一个 `*` 之前那段做子串包含 ——
    · `*_F` 这类模式（那段为空）→ **匹配全部类**，有人因此拿到 15604 条无关结果；
    · `?` 从未实现 → 含 `?` 的模式一条都匹配不到。
    误报与漏报同时存在，而工具描述却写着"`*` 与 `?` 可用"。

    下面这组用例同时是 SQF 实现的验收清单：上机时抽查同样这几条即可。
    """

    def test_star_matches_everything(self):
        self.assertTrue(glob_match("*", "b_mrap_01_f"))
        self.assertTrue(glob_match("**", "abc"))
        self.assertTrue(glob_match("*abc*", "abc"))

    def test_prefix_and_suffix(self):
        self.assertTrue(glob_match("b_mrap*", "b_mrap_01_f"))
        self.assertFalse(glob_match("b_mrap*", "b_truck_01_f"))
        self.assertTrue(glob_match("*_f", "b_mrap_01_f"))
        # ★ 旧实现这里误报（`*` 开头 → 匹配全部）
        self.assertFalse(glob_match("*_f", "b_truck_01"))

    def test_middle_star(self):
        self.assertTrue(glob_match("b_*_f", "b_mrap_01_f"))
        self.assertFalse(glob_match("b_*_f", "b_mrap_01"))

    def test_question_mark_single_char(self):
        """★ 旧实现完全没实现 `?`，含 `?` 的模式一条都匹配不到。"""
        self.assertTrue(glob_match("b_?_f", "b_1_f"))
        self.assertFalse(glob_match("b_?_f", "b_12_f"))
        self.assertTrue(glob_match("b_mrap_0?_f", "b_mrap_01_f"))
        # ★ 旧实现这里漏报
        self.assertTrue(glob_match("b_?rap*", "b_mrap_01_f"))

    def test_edges(self):
        self.assertTrue(glob_match("", ""))
        self.assertFalse(glob_match("", "x"))
        self.assertFalse(glob_match("?", ""))
        self.assertTrue(glob_match("?*", "a"))
        self.assertTrue(glob_match("a*c", "abc"))
        self.assertFalse(glob_match("a*c", "ab"))

    def test_matches_are_case_insensitive_when_lowered(self):
        """调用方负责小写；这里固定"先 lower 再匹配"的用法。"""
        self.assertTrue(glob_match("b_mrap*".lower(), "B_MRAP_01_F".lower()))


class TestFunctionList(ConfigToolCase):
    """`function_list`：从 CfgFunctions 现算可调用的函数名（call 的目标来源）。

    规则（实测见 decisions.md D39）：函数名 = <tag> + "_fnc_" + <叶子类名>；
    tag 取直接子类的 tag 字段，没有该字段时用类名
    （实测 A3 / A2PMC 的 tag 也都是 "BIS"，Ares 没有该字段）。
    """

    def test_overview_lists_tags_with_counts(self):
        """不带 tag：给概览，而不是倾泻几千个函数名。"""
        self.connect_game()
        text = text_of(self.wait_tool("function_list", {}))
        self.assertIn("CfgFunctions", text)
        self.assertIn("a3mcp", text)
        # tag 名统一按小写显示（与大小写不敏感的查询行为一致，见合并逻辑）
        self.assertIn("bis", text.lower())

    def test_tag_lists_function_names(self):
        self.connect_game()
        text = text_of(self.wait_tool("function_list", {"tag": "a3mcp"}))
        self.assertIn("a3mcp_fnc_init", text)
        self.assertIn("a3mcp_fnc_validate", text)

    def test_limit_is_reported_not_silent(self):
        """截断必须说出来 —— 否则调用方会以为"就这么多"。"""
        self.connect_game()
        text = text_of(self.wait_tool("function_list", {"tag": "a3mcp",
                                                        "limit": 1}))
        self.assertIn("只列前 1 个", text)

    def test_unknown_tag_says_so(self):
        self.connect_game()
        text = text_of(self.wait_tool("function_list", {"tag": "no_such_tag"}))
        self.assertIn("没有这个 tag", text)

    def test_overview_is_sorted_by_count(self):
        """概览按函数数降序——目的是"哪个 tag 值得看"，不是字母表顺序。"""
        self.connect_game()
        text = text_of(self.wait_tool("function_list", {}))
        # 假游戏数据：a3mcp=3、BIS(2)+bis(1) 合并为 3
        # → 同数时按名字升序，a3mcp 在前
        self.assertLess(text.index("a3mcp"), text.index("bis"),
                        "概览应按函数数降序排列")

    def test_same_tag_different_case_is_merged(self):
        """大小写不同的同名 tag 要合并显示。

        实测：config 里 `BIS`(1733) 与 `bis`(24) 并存，而查询是大小写不敏感的
        （`tag=bis` 得 1757）。概览若分开显示，就会与"查这个 tag 能得多少"对不上。
        假游戏数据里 BIS=2、bis=1 → 合并后应为 3，且只出现一行。
        """
        self.connect_game()
        text = text_of(self.wait_tool("function_list", {}))
        self.assertEqual(text.lower().count("bis"), 1,
                         "同名不同大小写的 tag 应合并成一行：\n" + text)
        self.assertIn("3 个", text)

    def test_declared_tag_count_matches_listed_lines(self):
        """标题里的个数必须等于实际列出的行数。

        曾经标题用游戏侧给的条目数、列表用合并后的结果 → "分布在 10 个 tag："
        下面只有 9 行。这类"数字与内容对不上"细看才发现，所以固化成断言。
        """
        self.connect_game()
        text = text_of(self.wait_tool("function_list", {}))
        head = [ln for ln in text.splitlines() if "分布在" in ln][0]
        declared = int(head.split("分布在")[1].split("个")[0].strip())
        listed = len([ln for ln in text.splitlines()
                      if ln.startswith("  ") and "个" in ln])
        self.assertEqual(declared, listed,
                         "标题说 %d 个 tag，实际列了 %d 行：\n%s"
                         % (declared, listed, text))

    def test_cmd_name_matches_sqf_dispatch(self):
        """下行 cmd 名必须与 fn_exec.sqf 的 case 对上（那边 toLower 后比较）。"""
        game = self.connect_game()
        self.wait_tool("function_list", {"tag": "a3mcp"})
        self.assertTrue(game.wait_commands(1))
        self.assertEqual(game.commands[-1]["cmd"], "fnList")
