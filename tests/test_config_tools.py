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


def text_of(result: dict) -> str:
    return "\n".join(c.get("text", "") for c in result.get("content", []))


class ConfigToolCase(unittest.TestCase):
    def setUp(self):
        self.port = free_port()
        self.srv = McpServer({
            "ALC_CHANNEL": "tcp", "ALC_TCP_HOST": "127.0.0.1",
            "ALC_TCP_PORT": str(self.port), "ALC_ENGINE_WRITE": "1",
            "ALC_AUDIT_LOG": os.path.join(REPO, "audit.jsonl"),
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
