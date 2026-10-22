#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""游戏内 config 查询工具（运行时，走执行通道）。

## 为什么单独成一组工具，而不是让调用方手写 exec

config 查询有三件事手写很痛，而工具层能一次解决：
  1. **类路径**：`configFile >> "CfgVehicles" >> "B_MRAP_01_F"` 这种写法
     在结构化调用里很别扭，工具层统一收成数组 `["CfgVehicles","B_MRAP_01_F"]`；
  2. **体量**：一个 config 类常有 200+ 个属性，整棵返回会撑爆上下文——
     工具层提供「列子类 / 看摘要 / 精确读值」三档，默认只给摘要；
  3. **缓存**：config 在运行期基本不变，同一次会话里反复查同一路径很浪费，
     工具层做进程内缓存。

## 依赖与边界

它**复用执行通道**（`exec` 用的那套），所以没有独立的连接概念：
- 通道未接通 → 明确报错，不假装有数据；
- 全部是**只读**操作，不经过写闸门；
- 唯一刻意挡掉的是 config 里的 **Code 类型**属性（`onLoad`/`init` 之类）：
  只报存在性，不返回代码内容——返回无用，且会诱导去执行它。
"""

from __future__ import annotations

import json
import time
from typing import Any

from mcpcore.registry import Registry, ToolResult
from adapters.channel import Channel
from guard import audit

# 常用根：给模型一个起点，省掉「猜顶层类叫什么」
COMMON_ROOTS = [
    ("CfgVehicles", "载具、单位、建筑、物件"),
    ("CfgWeapons", "武器与装备（含 uniform/vest/headgear）"),
    ("CfgMagazines", "弹匣与消耗品"),
    ("CfgAmmo", "弹药（伤害、初速、引信）"),
    ("CfgGroups", "编辑器里的建制裁剪（阵营/类别/编队）"),
    ("CfgFactionClasses", "阵营"),
    ("CfgMarkerColors", "标记颜色"),
    ("CfgWorlds", "地图（世界）定义"),
    ("CfgSounds", "声音"),
    ("CfgMusic", "音乐"),
]

# 各用途的「关键字段」预置集：不带 keys 时只给这些，避免倾泻 200+ 属性。
KEY_PRESETS = {
    "CfgVehicles": [
        "displayName", "model", "side", "faction", "vehicleClass",
        "transportSoldier", "transportMaxBackpacks", "transportMaxWeapons",
        "maxSpeed", "armor", "armorStructural", "fuelCapacity",
        "typicalCargo", "weapons", "magazines", "linkedItems",
        "scope", "scopeCurator", "crew", "class",
    ],
    "CfgWeapons": [
        "displayName", "model", "picture", "type", "scope",
        "magazines", "magazineWell", "modes", "maxRange", "initSpeed",
        "dispersion", "recoil", "linkedItems", "class",
    ],
    "CfgMagazines": [
        "displayName", "ammo", "count", "initSpeed", "mass", "scope",
        "type", "picture", "class",
    ],
    "CfgAmmo": [
        "displayName", "hit", "indirectHit", "indirectHitRange",
        "typicalSpeed", "initSpeed", "caliber", "explosive", "scope",
        "class",
    ],
}
DEFAULT_PRESET = ["displayName", "scope", "class"]


def _cache_key(root: str, path: list[str], extra: str = "") -> str:
    return "%s|%s|%s" % (root, "/".join(path), extra)


class ConfigTools:
    """config 查询 + 进程内缓存。

    缓存的失效策略刻意简单：按会话存活，不主动失效。理由是 config 在运行期
    基本不变（本场景不使用 `configClass` 动态改写），而**误报过期数据**的代价
    高于多查一次。
    """

    def __init__(self, chan: Channel, ttl_s: float = 300.0,
                 max_entries: int = 2000) -> None:
        self.chan = chan
        self.ttl = ttl_s
        self.max_entries = max_entries
        self._cache: dict[str, tuple[float, Any]] = {}
        self.stats = {"queries": 0, "cache_hits": 0}

    # ---------------------------------------------------------------- 缓存

    def _get(self, key: str) -> Any | None:
        hit = self._cache.get(key)
        if hit is None:
            return None
        stamp, value = hit
        if time.time() - stamp > self.ttl:
            self._cache.pop(key, None)
            return None
        self.stats["cache_hits"] += 1
        return value

    def _put(self, key: str, value: Any) -> None:
        if len(self._cache) >= self.max_entries:
            # 简单淘汰：清掉最旧的一批（config 查询场景不需要精细 LRU）
            for old in sorted(self._cache, key=lambda k: self._cache[k][0])[:200]:
                self._cache.pop(old, None)
        self._cache[key] = (time.time(), value)

    def clear(self) -> int:
        count = len(self._cache)
        self._cache.clear()
        return count

    # ---------------------------------------------------------------- 查询

    def query(self, root: str, path: list[str], op: str = "class",
              keys: list[str] | None = None, limit: int = 50,
              use_cache: bool = True) -> tuple[bool, Any, str]:
        """向游戏发一次 config 查询。

        返回 (ok, data, error)。data 是游戏侧返回的结构化结果。
        """
        extra = "%s|%s|%s" % (op, ",".join(keys or []), limit)
        key = _cache_key(root, path, extra)
        if use_cache:
            cached = self._get(key)
            if cached is not None:
                return True, cached, ""

        payload_args = [root, "/".join(path), op]
        if keys:
            payload_args.append(keys)
        if limit:
            payload_args.append(limit)
        # 走游戏侧的统一分发器；命令名与参数都在白名单/校验之内
        reply = self.chan.send({
            "cmd": "configQuery",
            "args": payload_args,
        })
        self.stats["queries"] += 1
        audit("config_query", {"root": root, "path": "/".join(path), "op": op,
                               "ok": reply.ok, "elapsed_ms": reply.elapsed_ms})
        if not reply.ok:
            return False, None, reply.error
        data = reply.result
        if use_cache:
            self._put(key, data)
        return True, data, ""


def _render_class(data: dict, root: str, path: list[str]) -> str:
    """把一个类摘要渲染成模型可读的文本。"""
    lines = ["# %s >> %s" % (root, " >> ".join(path))]
    if data.get("parentName"):
        lines.append("父类：%s" % data["parentName"])
    if data.get("sourceMod"):
        lines.append("来源 mod：%s" % data["sourceMod"])
    if data.get("hierarchy"):
        lines.append("继承链：%s" % " ← ".join(data["hierarchy"]))
    props = data.get("properties") or {}
    if props:
        lines.append("")
        lines.append("属性（%d 项）：" % len(props))
        for name in sorted(props):
            lines.append("  %s = %s" % (name, _fmt_value(props[name])))
    missing = data.get("missing") or []
    if missing:
        lines.append("")
        lines.append("以下属性不存在：%s" % "、".join(missing))
    if data.get("truncated"):
        lines.append("")
        lines.append("⚠ 属性过多已截断；用 keys 指定要查的属性，或改用 config_tree 展开。")
    return "\n".join(lines)


def _fmt_value(value: Any) -> str:
    """把游戏侧返回的带类型值渲染成人读形态。

    游戏侧统一用 {"t": 类型, "v": 值} 承载——这样"空字符串/0/false"不会与
    "属性不存在"混淆。因此这里必须按类型分支渲染；初版漏了标量分支，
    模型看到的是原始字典（`transportSoldier = {"t": "number", "v": 8}`）。
    """
    if isinstance(value, dict):
        kind = value.get("t")
        if kind == "config":
            # 渲染成可继续查询的路径：模型要能拿着它往下走
            return "config[%s]" % " >> ".join(value.get("v") or [])
        if kind == "code":
            return "<code：只报存在性，不返回内容>"
        if kind == "nil":
            return "(不存在)"
        if kind == "array":
            inner = value.get("v") or []
            if not inner:
                return "[]（空数组）"
            return "[" + ", ".join(_fmt_value(x) for x in inner) + "]"
        if kind in ("number", "text", "bool"):
            return str(value.get("v"))
        return "%s（未知类型）" % json.dumps(value, ensure_ascii=False)[:200]
    if isinstance(value, list):
        return "[" + ", ".join(_fmt_value(x) for x in value) + "]"
    if value is None:
        return "(不存在)"
    return str(value)


def register(reg: Registry, chan: Channel, tools: ConfigTools) -> None:
    @reg.tool(
        name="config_tree",
        description=("浏览游戏内 config 树的子类（如 CfgVehicles 下有哪些载具）。"
                     "不带 path 时列出常用顶层类。用于「先看看有什么」，"
                     "拿到类路径后再用 config_class / config_value 深入。"),
        input_schema={
            "type": "object",
            "properties": {
                "root": {"type": "string",
                         "description": "顶层类名，默认 CfgVehicles。留空则列常用根"},
                "path": {"type": "array", "items": {"type": "string"},
                         "description": "相对于 root 的路径，如 [\"Car\"]"},
                "filter": {"type": "string",
                           "description": "按子串过滤子类名（不区分大小写）"},
                "limit": {"type": "integer", "minimum": 1, "maximum": 200,
                          "description": "最多返回多少个子类，默认 50"},
                "refresh": {"type": "boolean", "description": "忽略缓存重新查询"},
            },
        },
        phase="config",
    )
    def _tree(args: dict) -> ToolResult:
        root = (args.get("root") or "").strip()
        if not root:
            lines = ["游戏内 config 的常用顶层类：", ""]
            for name, desc in COMMON_ROOTS:
                lines.append("  %-20s %s" % (name, desc))
            lines.append("")
            lines.append("用 root 指定一个顶层类继续浏览。")
            return ToolResult.ok("\n".join(lines),
                                 {"roots": [{"name": n, "desc": d}
                                            for n, d in COMMON_ROOTS]})
        path = args.get("path") or []
        ok, data, error = tools.query(
            root, path, op="tree", limit=args.get("limit", 50),
            use_cache=not args.get("refresh"))
        if not ok:
            return ToolResult.fail("config 查询失败：%s" % error)
        children = data.get("children") or []
        total = data.get("total", len(children))
        needle = (args.get("filter") or "").strip().lower()
        if needle:
            children = [c for c in children if needle in (c.get("name") or "").lower()]
        lines = ["%s%s 下的子类（%d/%d）："
                 % (root, (" >> " + " >> ".join(path)) if path else "",
                    len(children), total), ""]
        for child in children:
            tag = "类" if child.get("isClass") else "属性"
            parent = (" ← %s" % child["parent"]) if child.get("parent") else ""
            lines.append("  [%s] %s%s" % (tag, child.get("name", "?"), parent))
        if total > len(children):
            lines.append("")
            lines.append("（只显示前 %d 项，共 %d 项；用 filter 缩小范围或调大 limit）"
                         % (len(children), total))
        lines.append("")
        lines.append("下一步：config_class(root, path=[...子类名]) 看摘要。")
        return ToolResult.ok("\n".join(lines),
                             {"root": root, "path": path, "total": total,
                              "children": children})

    @reg.tool(
        name="config_class",
        description=("读一个 config 类的摘要：父类、继承链、来源 mod、关键属性。"
                     "不带 keys 时只返回该用途的**关键字段预置集**（避免倾泻"
                     "200+ 个属性撑爆上下文）；要精确读某几个字段就传 keys。"),
        input_schema={
            "type": "object",
            "properties": {
                "root": {"type": "string", "description": "顶层类，如 CfgVehicles"},
                "path": {"type": "array", "items": {"type": "string"},
                         "description": "类路径，如 [\"B_MRAP_01_F\"]"},
                "keys": {"type": "array", "items": {"type": "string"},
                         "description": "只读这些属性；省略则用关键字段预置集"},
                "refresh": {"type": "boolean"},
            },
            "required": ["root", "path"],
        },
        phase="config",
    )
    def _class(args: dict) -> ToolResult:
        root = args["root"]
        path = args["path"]
        keys = args.get("keys")
        if not keys:
            keys = KEY_PRESETS.get(root, DEFAULT_PRESET)
        ok, data, error = tools.query(root, path, op="class", keys=keys,
                                      use_cache=not args.get("refresh"))
        if not ok:
            return ToolResult.fail("config 查询失败：%s" % error)
        return ToolResult.ok(_render_class(data, root, path), data)

    @reg.tool(
        name="config_value",
        description=("精确读取 config 里的一个或多个属性值。适合已知字段名时用，"
                     "比 config_class 更省。属性不存在时会明确说明（不返回空值"
                     "假装成功）。"),
        input_schema={
            "type": "object",
            "properties": {
                "root": {"type": "string"},
                "path": {"type": "array", "items": {"type": "string"}},
                "key": {"type": "string", "description": "单个属性名"},
                "keys": {"type": "array", "items": {"type": "string"},
                         "description": "多个属性名（与 key 二选一）"},
                "refresh": {"type": "boolean"},
            },
            "required": ["root", "path"],
        },
        phase="config",
    )
    def _value(args: dict) -> ToolResult:
        keys = args.get("keys") or ([args["key"]] if args.get("key") else [])
        if not keys:
            return ToolResult.fail("需要 key 或 keys 参数")
        ok, data, error = tools.query(args["root"], args["path"], op="class",
                                      keys=keys,
                                      use_cache=not args.get("refresh"))
        if not ok:
            return ToolResult.fail("config 查询失败：%s" % error)
        props = data.get("properties") or {}
        lines = ["%s >> %s" % (args["root"], " >> ".join(args["path"])), ""]
        for name in keys:
            if name in props:
                lines.append("  %s = %s" % (name, _fmt_value(props[name])))
            else:
                lines.append("  %s = (不存在)" % name)
        missing = data.get("missing") or []
        if missing:
            lines.append("")
            lines.append("注：%s 在该类中不存在。可以先用 config_class 不带 keys "
                         "看有哪些可用字段。" % "、".join(missing))
        return ToolResult.ok("\n".join(lines), data)

    @reg.tool(
        name="config_search",
        description=("按通配符搜索 config 类名（不区分大小写），如 \"B_MRAP*\"。"
                     "用于「我想找某类东西，但不知道确切类名」——比在命令行里"
                     "逐层 config_tree 快得多。"),
        input_schema={
            "type": "object",
            "properties": {
                "pattern": {"type": "string", "minLength": 1,
                            "description": "通配符，* 与 ? 可用"},
                "root": {"type": "string", "description": "限定在某顶层类内搜索"},
                "limit": {"type": "integer", "minimum": 1, "maximum": 200},
            },
            "required": ["pattern"],
        },
        phase="config",
    )
    def _search(args: dict) -> ToolResult:
        root = args.get("root") or "CfgVehicles"
        ok, data, error = tools.query(
            root, [], op="search", keys=[args["pattern"]],
            limit=args.get("limit", 50))
        if not ok:
            return ToolResult.fail("config 搜索失败：%s" % error)
        matches = data.get("matches") or []
        lines = ["在 %s 中匹配 %r：%d 个"
                 % (root, args["pattern"], data.get("total", len(matches))), ""]
        for name in matches:
            lines.append("  %s" % name)
        if not matches:
            lines.append("  （无匹配。换个模式，或先用 config_tree 看看有哪些子类。）")
        return ToolResult.ok("\n".join(lines), data)

    @reg.tool(
        name="config_of",
        description=("从一个**游戏内实体**跳到它的 config：返回类路径与摘要"
                     "（如「我看到的这辆车是什么、能坐几个人」）。"
                     "实体名需已在游戏内登记。"),
        input_schema={
            "type": "object",
            "properties": {
                "entity": {"type": "string", "minLength": 1,
                           "description": "游戏内实体名，如 vehicle_1"},
                "keys": {"type": "array", "items": {"type": "string"}},
            },
            "required": ["entity"],
        },
        phase="config",
    )
    def _of(args: dict) -> ToolResult:
        reply = tools.chan.send({"cmd": "configOfEntity",
                                 "args": [[args["entity"]]] + (
                                     [args["keys"]] if args.get("keys") else [])})
        audit("config_of", {"entity": args["entity"], "ok": reply.ok})
        if not reply.ok:
            return ToolResult.fail("查询实体 config 失败：%s" % reply.error)
        data = reply.result or {}
        if not data.get("found"):
            return ToolResult.fail(
                "游戏内找不到实体 %r。实体必须是已登记的变量名；"
                "未定义的实体名不会报错，只会表现为「找不到」。" % args["entity"])
        lines = ["实体 %s 的类：%s" % (args["entity"], data.get("type", "?"))]
        props = data.get("properties") or {}
        if props:
            lines.append("")
            for name in sorted(props):
                lines.append("  %s = %s" % (name, _fmt_value(props[name])))
        return ToolResult.ok("\n".join(lines), data)

    @reg.tool(
        name="config_cache",
        description="查看或清空 config 查询缓存（config 在运行期不变，缓存能省掉重复查询）。",
        input_schema={
            "type": "object",
            "properties": {"clear": {"type": "boolean",
                                     "description": "清空缓存"}},
        },
        phase="config",
    )
    def _cache(args: dict) -> ToolResult:
        if args.get("clear"):
            removed = tools.clear()
            return ToolResult.ok("已清空 %d 条 config 缓存。" % removed,
                                 {"cleared": removed})
        return ToolResult.ok(
            "config 查询统计：查询 %d 次，命中缓存 %d 次，当前缓存 %d 条。"
            % (tools.stats["queries"], tools.stats["cache_hits"],
               len(tools._cache)),
            {"stats": dict(tools.stats), "cached": len(tools._cache)})
