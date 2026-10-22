#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""命令知识层：族分类、检索、签名查询、参数校验。

数据来自本仓库自带的 data/commands.json.xz（由 tools/build_commands.py 从官方
命令定义生成），**不读取任何外部仓库**。

设计要点（都源于对真实数据的观察，不是理论洁癖）：
  · 类型字符串很脏：2072 个参数类型为空串，大小写混用（Number/NUMBER），
    还有拼写错误（'NUMVER'）。故类型校验**宽容**：识别不出就不校验，
    但必须**如实告知"未校验"**——假装校验过比不校验更危险。
  · 参数名同样脏：569 个空名，还有 _object0 这类内部命名。故参数名只作
    提示，匹配以**位置与类型**为准。
"""

from __future__ import annotations

import json
import lzma
import os
import re
from functools import lru_cache
from typing import Any, Iterable, Optional

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(REPO, "data", "commands.json.xz")

# 命令族：按首词前缀归类。族是给模型看的"目录页"，不是严格语义分类——
# 目的是让它在 5181 条里知道该往哪个方向找，而不是要求分类完备。
FAMILIES: dict[str, dict[str, str]] = {
    "set":    {"zh": "设置/修改状态", "en": "setters"},
    "get":    {"zh": "读取状态", "en": "getters"},
    "add":    {"zh": "添加（武器/动作/事件等）", "en": "adders"},
    "remove": {"zh": "移除", "en": "removers"},
    "create": {"zh": "创建（载具/标记/对象）", "en": "creators"},
    "delete": {"zh": "删除", "en": "deleters"},
    "enable": {"zh": "启用能力", "en": "enablers"},
    "disable": {"zh": "禁用能力", "en": "disablers"},
    "do":     {"zh": "下达动作指令", "en": "orders"},
    "command": {"zh": "下达命令（含 commandFire 等）", "en": "commands"},
    "play":   {"zh": "播放动作/动画/声音", "en": "playback"},
    "switch": {"zh": "切换（动作/相机/姿态）", "en": "switchers"},
    "ctrl":   {"zh": "UI 控件操作", "en": "UI controls"},
    "display": {"zh": "界面（Display）操作", "en": "displays"},
    "dialog": {"zh": "对话框", "en": "dialogs"},
    "task":   {"zh": "任务系统", "en": "task system"},
    "marker": {"zh": "地图标记", "en": "markers"},
    "group":  {"zh": "分队", "en": "groups"},
    "unit":   {"zh": "单位", "en": "units"},
    "vehicle": {"zh": "载具", "en": "vehicles"},
    "weapon": {"zh": "武器与射击", "en": "weapons"},
    "magazine": {"zh": "弹匣与弹药", "en": "magazines"},
    "attach": {"zh": "挂载", "en": "attach"},
    "detach": {"zh": "卸载挂载", "en": "detach"},
    "show":   {"zh": "显示", "en": "show"},
    "hide":   {"zh": "隐藏", "en": "hide"},
    "find":   {"zh": "查找（显示/控件/最近对象）", "en": "find"},
    "nearest": {"zh": "最近对象查询", "en": "nearest"},
    "all":    {"zh": "枚举全部", "en": "enumerate"},
    "is":     {"zh": "布尔判定", "en": "predicates"},
    "can":    {"zh": "能力判定", "en": "capability checks"},
    "has":    {"zh": "存在性判定", "en": "existence checks"},
    "select": {"zh": "选择/筛选", "en": "select"},
    "vector": {"zh": "向量运算", "en": "vectors"},
    "trigger": {"zh": "触发器", "en": "triggers"},
    "draw":   {"zh": "绘制（调试/地图）", "en": "draw"},
    "diag":   {"zh": "诊断", "en": "diagnostics"},
    "ui":     {"zh": "UI 命名空间", "en": "ui namespace"},
    "remote": {"zh": "网络与远程执行", "en": "network"},
    "public": {"zh": "公共变量同步", "en": "public variables"},
    "action": {"zh": "动作与交互菜单", "en": "actions"},
    "input":  {"zh": "输入设备", "en": "input"},
    "mouse":  {"zh": "鼠标", "en": "mouse"},
    "world":  {"zh": "世界与坐标", "en": "world"},
    "terrain": {"zh": "地形与地表", "en": "terrain"},
    "camera": {"zh": "相机", "en": "camera"},
    "cam":    {"zh": "相机", "en": "camera"},
    "move":   {"zh": "移动", "en": "movement"},
    "bis_fnc": {"zh": "BI 官方函数库", "en": "BI functions"},
    "cba_fnc": {"zh": "CBA 社区函数库", "en": "CBA functions"},
    "ace_":   {"zh": "ACE3 函数库", "en": "ACE3 functions"},
}

_FAMILY_ORDER = sorted(FAMILIES, key=len, reverse=True)  # 长前缀优先

# 归一化后的类型名 -> 允许的 JSON 类型集合
_TYPE_MAP: dict[str, set[str]] = {
    "number": {"integer", "number"},
    "integer": {"integer"},
    "string": {"string"},
    "boolean": {"boolean"},
    "array": {"array"},
    "object": {"object"},
    "control": {"object"},       # UI 控件在 JSON 侧就是对象引用
    "display": {"object"},
    "group": {"object"},
    "config": {"object"},
    "location": {"object"},
    "task": {"object"},
    "waypoint": {"object"},
    "namespace": {"object"},
    "hashmap": {"object"},
    "position": {"array"},
    "side": {"string", "object"},
    "code": {"string"},          # 代码在结构化调用里以字符串承载
    "anything": {"string", "number", "integer", "boolean", "object", "array", "null"},
    "null": {"null"},           # NIL 参数的唯一合法取值就是 null
    "nothing": {"null"},
    "void": {"null"},
    "nil": {"null"},
}

# 真实数据里的类型别名与拼写变体（逐个来自全量扫描，不是猜的）。
# 保留独立键而不是都塞进上面的主表：别名是"数据脏"的证据，
# 单列出来便于将来数据源变干净时删除。
_TYPE_ALIASES: dict[str, str] = {
    "scalar": "number",
    "numver": "number",     # 真实拼写错误
    "nubmer": "number",
    "bool": "boolean",
    "any": "anything",
    "nil": "null",
    "position2d": "position",
    "position3d": "position",
    "positionasl": "position",
    "positionatl": "position",
    "positionagl": "position",
    "postion": "position",  # 真实拼写错误
    "vector3d": "array",
    "vector": "array",
    "color": "array",
    "target": "object",
    "logic": "object",
    "fsm": "object",
    "objectrtd": "object",
    "hashmapkey": "string",
}

_OPTIONAL_RE = re.compile(r"optional", re.I)
_LIST_RE = re.compile(r"^\s*array\s+of\s+(.+)$", re.I)
_DEFAULT_RE = re.compile(r"default\s+([^,)]+)", re.I)

# 这些类型字符串无法归一化时视为"未识别"（不校验，但如实报告）
_UNKNOWN = "unknown"


def _lookup_type(word: str) -> Optional[str]:
    """一个候选片段 -> 归一化类型；不认识返回 None。

    真实数据里类型串形态极杂：`Object`、`OBJECT`、`BOOL`、`SCALAR`、
    `Group, Object or (since v2.02) Side`、`Control -`、`Waypoint - format
    [group, index]`、`HashMapKey`……所以这里按"逐级放宽"的顺序试：
    整串 → 别名 → 空格前第一个词 → **文本里出现的类型词（全词匹配）**。
    全词匹配是最后手段：它能把 `Group, Object or Side` 认成 group，
    又不会把 `WaypointLoiterType` 里的 "type" 误认成某种类型。
    """
    key = word.strip().strip(".,;:-–—").lower()
    if not key:
        return None
    if key in _TYPE_MAP:
        return key
    if key in _TYPE_ALIASES:
        return _TYPE_ALIASES[key]
    first = key.split()[0] if key.split() else ""
    if first in _TYPE_MAP:
        return first
    if first in _TYPE_ALIASES:
        return _TYPE_ALIASES[first]
    # 文本中出现的已知类型词：按**出现位置**取最早的那个。
    # 不用"长词优先"：`Object; Array format Position2D` 里 Object 在前，
    # 它才是命令真正要求的形态；长词优先会选出 Position2D，那是错的。
    hits: list[tuple[int, str]] = []
    for known in set(_TYPE_MAP) | set(_TYPE_ALIASES):
        m = re.search(r"\b" + re.escape(known) + r"\b", key)
        if m:
            hits.append((m.start(), known))
    if hits:
        hits.sort(key=lambda x: (x[0], -len(x[1])))
        first_known = hits[0][1]
        if first_known in _TYPE_MAP:
            return first_known
        return _TYPE_ALIASES[first_known]
    return None


def _normalize_type(raw: str) -> tuple[str, bool]:
    """类型字符串 -> (归一化类型, 是否识别)。

    真实数据的形态比文档脏得多，故按下面的顺序逐级尝试：
      1. `Array of X` / 以 `array` 开头（Array format Position2D …）
      2. 括号前的类型词（`Boolean (Optional, default false)`）
      3. 整串是否就是一个类型词（含大小写变体与拼写错误）
      4. 联合类型（逗号/竖线/斜杠分隔），取第一个可识别者

    ⚠ 刻意**不做**"整串里出现类型词就算命中"的兜底扫描：真实数据里有些
    参数名把整张 wiki 表格混了进来（如 `a:\n{! classwikitable …`），
    模糊扫描会从表格文本里"认"出一个类型，把本该"未识别"的参数误标成
    已知类型——那比不识别更糟（会让校验误报，也会掩盖数据缺陷）。
    """
    if not raw or not raw.strip():
        return _UNKNOWN, False
    text = raw.strip()
    head = text.split("(")[0].split("\n")[0].strip()

    lowered = head.lower()
    if lowered.startswith("array"):
        return "array", True
    if _LIST_RE.match(head):
        return "array", True

    for candidate in (head, text):
        hit = _lookup_type(candidate)
        if hit:
            return hit, True

    # 联合类型：真实数据里用逗号、竖线、斜杠或分号分隔（"Object; Array …"）
    parts = [p for p in re.split(r"[,|/;]", head) if p.strip()]
    for part in parts:
        hit = _lookup_type(part)
        if hit:
            return hit, True
    return _UNKNOWN, False


# 与 tools/build_commands.py::SCHEMA 必须一致。
# 分开定义是刻意的：读方不该 import 写方（那是开发工具）；但两边漂移时
# 报错信息会明确指出，不会静默用错格式。
EXPECTED_SCHEMA = 2

WIKI_BASE = "https://community.bistudio.com/wiki/"


def wiki_url(name: str) -> str:
    """命令名 → BI wiki 页面链接。

    映射是**确定性**的（wiki 的页面路径就是命令名），所以数据里不必存 URL，
    运行时拼出来即可。这也是本仓库**不分发 wiki 描述正文**的替代方案：
    需要说明时给链接，而不是复制受版权保护的文本。
    """
    return WIKI_BASE + (name or "").strip()


class CommandIndex:
    """命令库的读取与查询。惰性加载，进程内只解压一次。"""

    def __init__(self, path: str = DATA) -> None:
        self.path = path
        self._records: Optional[dict[str, dict]] = None
        self._meta: Optional[dict] = None

    # ---------------------------------------------------------------- 加载

    @property
    def meta(self) -> dict:
        self._ensure()
        assert self._meta is not None
        return self._meta

    def _ensure(self) -> None:
        if self._records is not None:
            return
        if not os.path.isfile(self.path):
            raise FileNotFoundError(
                f"命令库缺失：{self.path}\n"
                f"请先运行：python3 tools/build_commands.py")
        with lzma.open(self.path, "rb") as fh:
            payload = json.loads(fh.read().decode("utf-8"))
        # 只认**当前**版本：旧版数据（含 d 字段的 schema 1）不兼容，
        # 因为读取方已经不再期望描述文本。报错时直接给出重建命令，
        # 而不是让人猜"为什么读不了库"。
        if payload.get("schema") != EXPECTED_SCHEMA:
            raise ValueError(
                "命令库 schema 版本不匹配：数据是 %r，本代码要 %d。\n"
                "请重跑：python3 tools/build_commands.py"
                % (payload.get("schema"), EXPECTED_SCHEMA))
        self._records = payload["records"]
        self._meta = payload["generated"]

    @property
    def records(self) -> dict[str, dict]:
        self._ensure()
        assert self._records is not None
        return self._records

    def count(self) -> int:
        return len(self.records)

    # ---------------------------------------------------------------- 查询

    def family_of(self, name: str) -> str:
        low = name.lower()
        for fam in _FAMILY_ORDER:
            if low.startswith(fam):
                return fam
        return "其他"

    def families(self) -> list[dict]:
        """命令族清单（目录页）。"""
        buckets: dict[str, list[str]] = {}
        for rec in self.records.values():
            buckets.setdefault(self.family_of(rec["n"]), []).append(rec["n"])
        out = []
        for fam, names in buckets.items():
            info = FAMILIES.get(fam, {})
            out.append({
                "family": fam,
                "count": len(names),
                "zh": info.get("zh", "其他/未分类"),
                "samples": sorted(names)[:6],
            })
        out.sort(key=lambda x: (-x["count"], x["family"]))
        return out

    def search(self, query: str, family: Optional[str] = None,
               kind: Optional[str] = None, limit: int = 25) -> list[dict]:
        """检索命令。按"名字命中 > 描述命中"排序。"""
        q = (query or "").strip().lower()
        if not q:
            return []
        hits: list[tuple[int, dict]] = []
        for rec in self.records.values():
            if family and self.family_of(rec["n"]) != family:
                continue
            if kind and rec["ty"] != kind:
                continue
            name = rec["n"].lower()
            if name == q:
                score = 0
            elif name.startswith(q):
                score = 1
            elif q in name:
                score = 2
            else:
                continue
            hits.append((score, rec))
        hits.sort(key=lambda x: (x[0], len(x[1]["n"]), x[1]["n"].lower()))
        return [{
            "name": r["n"],
            "type": r["ty"],
            "source": r["src"],
            "family": self.family_of(r["n"]),
            # 摘要用**签名**首行，不再是 wiki 描述：数据里已不含描述文本
            # （版权原因，见 NOTICE）。需要说明请按 wiki_url() 取原文。
            "summary": (r["sx"][0]["c"] if r.get("sx") else ""),
        } for _, r in hits[:limit]]

    def get(self, name: str) -> Optional[dict]:
        """按名取记录。先精确（忽略大小写），再尝试唯一前缀匹配。"""
        low = (name or "").strip().lower()
        if not low:
            return None
        rec = self.records.get(low)
        if rec is not None:
            return rec
        # 唯一前缀匹配：模型常写 doMove 之外的简写，这里给一次纠正机会
        candidates = [k for k in self.records if k.startswith(low)]
        if len(candidates) == 1:
            return self.records[candidates[0]]
        return None

    def prefix_candidates(self, name: str, limit: int = 8) -> list[str]:
        """相近命令名建议。

        排序刻意用"像的程度"而不是字典序：问 "setpos" 时最有用的答案是
        setPos/setPosATL 这些**前缀命中**的，而不是碰巧字典序更小的
        setPosASL2 之类。字典序会让建议看起来答非所问。
        """
        low = (name or "").strip().lower()
        if not low:
            return []
        hits = [k for k in self.records if low in k]
        hits.sort(key=lambda k: (not k.startswith(low), len(k), k))
        return hits[:limit]

    def arma3_since(self, rec: dict) -> Optional[str]:
        """该命令在 Arma 3 的引入版本（无则 None）。"""
        for entry in rec.get("compat") or []:
            if entry.get("g") == "arma3":
                return entry.get("v") or None
        return None

    def games(self, rec: dict) -> list[str]:
        return [e.get("g", "") for e in (rec.get("compat") or []) if e.get("g")]


# ------------------------------------------------------------------ 签名与校验

def parse_arg(arg: dict) -> dict:
    """参数条目 -> 归一化描述。

    真实数据里参数名字段常被灌进整张 wiki 表格（换行 + `{! classwikitable`），
    故一律先按换行截断再解析：截断后拿到的才是"名字: 类型"这一行。
    """
    raw_name = (arg.get("n", "") or "").split("\n")[0].strip()
    type_text = (arg.get("t", "") or "").split("\n")[0].strip()
    # 参数名里常带类型与默认值（"x: Number (Optional, default 0)"），剥出名字
    name = raw_name.split(":")[0].strip()
    if not type_text and ":" in raw_name:
        # 类型写在名字里
        type_text = raw_name.split(":", 1)[1].strip()
    if not type_text:
        # 另一种写法："(optional) defaultValue - Anything"：
        # 类型在破折号之后。不剥出来就会把整串参数名当成类型，判为未识别。
        for sep in (" - ", " – ", " — "):
            if sep in raw_name:
                left, right = raw_name.split(sep, 1)
                if _normalize_type(right)[1]:
                    name = left.strip().split(":")[0].strip()
                    type_text = right.strip()
                break
    norm, known = _normalize_type(type_text)
    optional = bool(_OPTIONAL_RE.search(raw_name)) or bool(_OPTIONAL_RE.search(type_text))
    default = None
    m = _DEFAULT_RE.search(raw_name) or _DEFAULT_RE.search(type_text)
    if m:
        default = m.group(1).strip()
        optional = True
    return {
        "name": name or "(未命名)",
        "raw_name": raw_name,
        "raw_type": type_text,
        "type": norm,
        "type_known": known,
        "optional": optional,
        "default": default,
        # 参数描述同样不随数据分发（版权原因）；保留键以便渲染层统一处理
        "desc": "",
    }


def signature_variants(rec: dict) -> list[dict]:
    return [{
        "code": s.get("c", ""),
        "returns": s.get("r", ""),
        "args": [parse_arg(a) for a in s.get("a") or []],
    } for s in rec.get("sx") or []]


def _json_type(value: Any) -> str:
    """判断 JSON 值的类型。

    ⚠ 特例：游戏实体（Object/Group/Control…）在 MCP 参数里**以单元素数组承载**。
    为什么不用对象形式 `{"entity": "u_17"}`：Object 与 Array 参数在所有 SQF
    命令里都是位置参数，让实体写成数组可以和其他参数保持同一种写法
    （`[["u_17"], [100, 200, 0]]`），也避免 LLM 记两种语法。
    代价是数组与对象在类型上无法区分——用数组长度区分：长度 1 的数组既可能
    是实体引用，也可能是"单元素数组"参数。

    因此：**长度 1 的数组同时满足 object 与 array 的期望**；更长或为空的数组
    只算 array。这是有意的宽容——它只放宽"能不能传进去"，不放宽参数个数，
    且序列化层会把长度 1 的数组按签名期望的类型处理。
    """
    if value is None:
        return "null"
    if isinstance(value, bool):
        return "boolean"
    if isinstance(value, int):
        return "integer"
    if isinstance(value, float):
        return "number"
    if isinstance(value, str):
        return "string"
    if isinstance(value, dict):
        return "object"
    if isinstance(value, (list, tuple)):
        if len(value) == 1:
            return "entity_or_array"
        return "array"
    return "unknown"


def check_call(rec: dict, args: Iterable[Any]) -> dict:
    """校验一组位置参数能否匹配某个签名。

    返回 {ok, matched_index, results:[每个签名一条诊断], note}
    诊断必须可读：模型看得懂才知道怎么改。
    """
    if not isinstance(rec, dict):
        raise TypeError("check_call 需要一条命令记录（dict）；"
                        "先确认命令存在（CommandIndex.get 可能返回 None）")
    given = list(args)
    variants = signature_variants(rec)
    if not variants:
        return {"ok": False, "matched_index": None, "results": [],
                "note": "该命令没有可用的签名数据，无法校验参数。"}

    results = []
    matched_index = None
    matched_exact = None   # 全参数都通过校验的签名（最优）
    matched_any = None     # 存在未识别类型但无硬冲突的签名（可接受）
    for idx, var in enumerate(variants):
        declared = var["args"]
        required = [a for a in declared if not a["optional"]]
        reasons = []
        unverified = []

        if len(given) < len(required):
            reasons.append(
                f"参数太少：需要至少 {len(required)} 个（{_describe(required)}），"
                f"给了 {len(given)} 个")
        elif len(declared) and len(given) > len(declared):
            reasons.append(
                f"参数太多：该签名最多 {len(declared)} 个"
                f"（{_describe(declared)}），给了 {len(given)} 个")

        for pos, value in enumerate(given):
            if pos >= len(declared):
                break
            spec = declared[pos]
            if not spec["type_known"]:
                unverified.append(f"#{pos + 1} {spec['name']}"
                                  f"（原类型 {(spec['raw_type'] or '空')[:40]}）")
                continue
            actual = _json_type(value)
            allowed = set(_TYPE_MAP.get(spec["type"], set()))
            if actual == "entity_or_array":
                # 单元素数组：既可能是实体引用，也可能是单元素数组参数，
                # 故 object 与 array 两种期望都应接受
                allowed |= {"object", "array"}
                if spec["type"] in allowed:
                    continue
            if actual not in allowed:
                # 对象/数组互换给出可操作的提示，而不是干巴巴的"类型不符"
                hint = ""
                if spec["type"] in ("object", "group", "control", "display",
                                    "config", "task", "waypoint", "location"):
                    hint = ("；游戏实体请用**单元素数组**承载，例如 [[\"u_17\"]] "
                            "表示实体 u_17")
                elif spec["type"] == "array" and actual == "object":
                    hint = "；数组参数需要 JSON 数组，不是对象"
                reasons.append(
                    f"参数 #{pos + 1} {spec['name']} 类型不符："
                    f"期望 {spec['raw_type'] or spec['type']}（{spec['type']}），"
                    f"实际 {actual}{hint}")

        entry = {
            "index": idx,
            "code": var["code"],
            "returns": var["returns"],
            "ok": not reasons,
            "reasons": reasons,
            "unverified": unverified,
        }
        results.append(entry)
        if entry["ok"]:
            if not unverified and matched_exact is None:
                matched_exact = idx
            if matched_any is None:
                matched_any = idx

    ok = matched_any is not None
    matched_index = matched_exact if matched_exact is not None else matched_any
    note = ""
    if ok:
        chosen = results[matched_index] if matched_index is not None else None
        if chosen and chosen["unverified"]:
            note = ("已匹配签名，但以下参数的类型原数据不可识别，**未做类型校验**："
                    + "、".join(chosen["unverified"])
                    + "。需要精确取值时请查 wiki 原文。")
        if len(results) > 1:
            note += ("" if not note else " ") + \
                    f"（该命令有 {len(results)} 种调用形式，本次匹配第 {matched_index + 1} 种）"
    return {"ok": ok, "matched_index": matched_index, "results": results,
            "note": note}


def _describe(args: list[dict]) -> str:
    parts = []
    for a in args:
        tag = a["name"]
        if a["raw_type"]:
            tag += f": {a['raw_type']}"
        if a["optional"]:
            tag = "[" + tag + "]"
        parts.append(tag)
    return ", ".join(parts)


@lru_cache(maxsize=1)
def default_index() -> CommandIndex:
    return CommandIndex()
