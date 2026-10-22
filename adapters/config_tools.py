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


def glob_match(pattern: str, name: str) -> bool:
    """通配符匹配：`*` 任意串、`?` 单字符。两端都应已小写。

    这是 **SQF 侧 `fn_configQuery::_globMatch` 的参考实现**——两处必须等价。
    为此这个算法写成"双指针 + 星号回溯"的显式形式（不用 `fnmatch`），
    与 SQF 里能写出来的结构一一对应；改一边就要同步改另一边。

    为什么值得单独写：SQF 侧旧实现只取第一个 `*` 之前那段做子串包含，于是
    · 模式以 `*` 开头（如 `*_F`）→ 那段为空 → **匹配全部类**（实测有人因此拿到
      15604 条无关结果）；
    · `?` 从未实现 → 含 `?` 的模式**一条都匹配不到**。
    误报与漏报同时存在。现在两端都用标准 glob。
    """
    p = n = 0
    star_p = star_n = -1
    while n < len(name):
        if p < len(pattern) and (pattern[p] == "?" or pattern[p] == name[n]):
            p += 1
            n += 1
        elif p < len(pattern) and pattern[p] == "*":
            star_p, star_n = p, n
            p += 1
        elif star_p >= 0:
            star_n += 1
            n = star_n
            p = star_p + 1
        else:
            return False
    while p < len(pattern) and pattern[p] == "*":
        p += 1
    return p == len(pattern)


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

        # ⚠ 参数按**位置**对齐：[root, 路径, op, keys, limit] —— 五个位置一个都不能少。
        #
        # 这里曾经写成"有 keys 才 append(keys)，有 limit 才 append(limit)"。
        # 后果：keys 为空而 limit 有值时（`config_tree(root=...)` 正是如此），
        # args 只有四个元素，limit 落进了 keys 的位置。SQF 侧
        # `_args param [3, [], [[]]]` 期望数组却收到数字，param 的类型校验直接
        # 抛异常；而异常被 fn_loop 的 catch 吞掉，于是外面看到的是
        # **"命令收到了、然后什么也没发生"**——既没有 ack 也没有错误日志。
        # 这类"位置错位"不会自己显形，只有从 RPT 的 SQF 错误堆栈才看得出来。
        payload_args = [root, "/".join(path), op, keys or [], limit]
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
                     "`*`=任意串、`?`=单字符（如 `*_F`、`B_?_F`）；想列全部用 `*`。"
                     "⚠ **只搜指定层的直接子类，不递归**（引擎的 configClasses "
                     "就是这个语义）。要找深层的类，用 path 把层指定到那里，"
                     "如 root=CfgGroups path=[\"West\",\"BLU_F\",\"Infantry\"] "
                     "配 pattern=\"*\"; 不清楚层级时先用 config_tree 逐层下钻。"),
        input_schema={
            "type": "object",
            "properties": {
                "pattern": {"type": "string", "minLength": 1,
                            "description": "通配符，* 与 ? 可用"},
                "root": {"type": "string",
                         "description": "顶层类，默认 CfgVehicles"},
                "path": {"type": "array", "items": {"type": "string"},
                         "description": "从 root 往下的层路径，如 [\"West\",\"BLU_F\"]。"
                                        "不填=只搜 root 的直接子类（不递归）"},
                "limit": {"type": "integer", "minimum": 1, "maximum": 200},
            },
            "required": ["pattern"],
        },
        phase="config",
    )
    def _search(args: dict) -> ToolResult:
        root = args.get("root") or "CfgVehicles"
        path = args.get("path") or []
        ok, data, error = tools.query(
            root, path, op="search", keys=[args["pattern"]],
            limit=args.get("limit", 50))
        if not ok:
            return ToolResult.fail("config 搜索失败：%s" % error)
        matches = data.get("matches") or []
        total = data.get("total", len(matches))
        # 二次过滤：匹配规则的权威实现在游戏侧（SQF，遍历子树时顺手判掉），
        # 但若游戏侧跑的是旧版本（把 `*` 开头的模式当"匹配全部"），这里能挡住
        # 那批误报——宁可结果少，也不要把 15000 条无关类名倾泻给调用方。
        pat = args["pattern"].lower()
        filtered = [m for m in matches if glob_match(pat, m.lower())]
        if len(filtered) != len(matches):
            total = len(filtered)
        matches = filtered
        where = "/".join([root] + list(path))
        lines = ["在 %s 中匹配 %r：%d 个"
                 % (where, args["pattern"], total), ""]
        for name in matches:
            lines.append("  %s" % name)
        if not matches:
            # 无匹配时给出**最可能的那个原因**：搜索范围是"该层的直接子类"，
            # 而调用方常常以为它递归。实测有人搜 `BUS_Inf*`（root=CfgGroups）
            # 得到"无匹配"就断定工具坏了——实际那个类在更深一层里。
            lines.append("  （无匹配。搜索只覆盖 **%s 的直接子类**，不递归——"
                         "若目标可能在更深层，用 path 把层指定过去"
                         "（path=[\"West\",\"BLU_F\",\"Infantry\"] 这种），"
                         "或先用 config_tree 逐层下钻看清结构。）" % where)
        return ToolResult.ok("\n".join(lines), data)

    @reg.tool(
        name="function_list",
        description=("列出**可调用的函数名**（从游戏内 CfgFunctions 现算）——"
                     "`call` 的目标核对用的就是这份来源。"
                     "不带 tag：返回各 tag 的名字与函数数（概览）；"
                     "带上 tag（如 `a3mcp` / `BIS`）：列出该 tag 的函数名。"
                     "函数名形如 `<tag>_fnc_<叶子类名>`，可**直接**用作 call 的目标"
                     "（查询大小写不敏感）。"),
        input_schema={
            "type": "object",
            "properties": {
                "tag": {"type": "string",
                        "description": "只要某个 tag 的函数，如 a3mcp / BIS；"
                                       "省略则返回全部 tag 的概览"},
                "limit": {"type": "integer", "minimum": 1, "maximum": 1000,
                          "description": "函数名最多返回多少条（默认 200）"},
            },
        },
        phase="config",
    )
    def _fn_list(args: dict) -> ToolResult:
        reply = tools.chan.send({
            "cmd": "fnList",
            "args": [args.get("tag") or "", args.get("limit", 200)]})
        audit("function_list", {"tag": args.get("tag"), "ok": reply.ok})
        if not reply.ok:
            return ToolResult.fail("列函数失败：%s" % reply.error)
        # 约定：reply.result 就是负载，外面没有 ok 包装
        data = reply.result or {}
        funcs = data.get("functions") or []
        tags = data.get("tags") or []
        total = data.get("total", 0)
        tag = (args.get("tag") or "").strip()

        lines = []
        if tag:
            head = "tag %s 下共 %d 个函数" % (tag, total)
            if data.get("truncated") and len(funcs) < total:
                head += "（只列前 %d 个）" % len(funcs)
            lines.append(head)
            lines.append("")
            lines.extend("  %s" % n for n in funcs)
            if not funcs:
                lines.append("  （没有这个 tag。不带 tag 调用可看全部 tag。）")
        else:
            lines.append("CfgFunctions 里共 %d 个函数，分布在 %d 个 tag："
                         % (total, len(tags)))
            lines.append("")
            for item in tags:
                # 游戏侧给的是 [tagName, count] 二元组
                if isinstance(item, (list, tuple)) and len(item) >= 2:
                    lines.append("  %-24s %s 个" % (item[0], item[1]))
                else:
                    lines.append("  %s" % (item,))
            lines.append("")
            lines.append("要列某个 tag 的函数名，带上 tag 参数（如 tag=\"a3mcp\"）——"
                         "那些名字可直接用作 call 的目标。")
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
