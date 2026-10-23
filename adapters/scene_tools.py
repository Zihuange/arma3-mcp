#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""任务世界快照：场景 / 自身 / 任务 / 小队 / 地图。

## 为什么这五个要单独成工具

它们都是"**看一眼**"型的读取，而 MCP 侧的动态表达式做不了这类事：

  · 每条表达式 **400 字符**上限，还没有局部变量 —— 想遍历 `allUnits` 只能
    在表达式里展开成 `(allUnits select 0)`、`(allUnits select 1)`…；
  · `_x` 不在白名单（那是"命令名注入"的防线，不该为便利放宽），所以
    `allUnits apply {...}` 这类写法直接被拒；
  · 每次求值 `allUnits` / `nearestObjects` 都是**全量枚举**，一屏十几个字段
    就要十几次往返，成本随对象数平方增长。

于是把它们放到模组侧一次遍历做完（`a3mcp_fnc_sceneQuery`），MCP 侧只负责
解析与排版。这与 `ui_snapshot` 是同一套理由，见 `fn_sceneQuery.sqf` 头注释。

## 数据形状

游戏侧统一回 "一行一条记录、字段用 `|` 分隔"，回执是 `[文本, 元信息]`。
`player` / `mission` / `squad` 的开头是若干 `key=value` 行，其余行以记录类型
开头（`member|` / `waypoint|` / `task|` / `marker|` / `trigger|`）。

## 为什么不在工具里做缓存

这些是**世界状态**，随时在变；缓存只会给出过期的答案。`ui_locate` 那类
静态结构才值得缓存。
"""

from __future__ import annotations

from typing import Optional

from mcpcore.registry import Registry, ToolResult


def _seg(payload, index: int) -> str:
    """从 `[文本, 元信息]` 里取第 index 段。"""
    if isinstance(payload, dict):
        payload = payload.get("v")
    if not isinstance(payload, list) or len(payload) <= index:
        return ""
    seg = payload[index]
    if isinstance(seg, dict):
        seg = seg.get("v")
    return seg if isinstance(seg, str) else ""


def _rows(text: str, kind: str) -> list[list[str]]:
    """取出以 `kind|` 开头的记录行，按 `|` 切分（首字段就是 kind）。"""
    out = []
    prefix = kind + "|"
    for line in (text or "").split("\n"):
        if line.startswith(prefix):
            out.append(line.split("|"))
    return out


def _kv(text: str, rtypes=("member", "waypoint", "task", "marker", "trigger")):
    """取出 `key=value` 行。

    注意不能只按 `=` 切：记录行里也可能出现 `=`（比如触发器的条件文本），
    所以先排除已知的记录类型前缀。
    """
    out = {}
    for line in (text or "").split("\n"):
        if not line or "=" not in line:
            continue
        head = line.split("|", 1)[0]
        if head in rtypes:
            continue
        k, v = line.split("=", 1)
        out[k.strip()] = v.strip()
    return out


def _meta(text: str) -> dict:
    out = {}
    for tok in (text or "").split():
        if "=" in tok:
            k, v = tok.split("=", 1)
            try:
                out[k] = int(v)
            except ValueError:
                out[k] = v
    return out


def _num(value: str, default: float = 0.0) -> float:
    try:
        return float(value)
    except (TypeError, ValueError):
        return default


def _side_name(raw: str) -> str:
    return {"0": "EAST", "1": "WEST", "2": "GUER", "3": "CIV",
            "4": "LOGIC", "5": "EMPTY"}.get(raw, raw)


class SceneTools:
    def __init__(self, chan) -> None:  # noqa: ANN001
        self.chan = chan

    def query(self, parts: list, timeout_s: float = 20.0):
        """发一条 sceneQuery。返回 (负载, 错误)。"""
        reply = self.chan.send({"cmd": "scenequery", "args": parts},
                               timeout_s=timeout_s)
        if not reply.ok:
            return None, reply.error
        return reply.result, ""

    # ------------------------------------------------------------ 单个快照

    def player(self):
        payload, err = self.query(["player"])
        if payload is None:
            return None, err
        return _kv(_seg(payload, 0)), ""

    def mission(self):
        payload, err = self.query(["mission"], timeout_s=25.0)
        if payload is None:
            return None, err
        text = _seg(payload, 0)
        return {"info": _kv(text, ("diary",)),
                "diary": _rows(text, "diary")}, ""

    def squad(self):
        payload, err = self.query(["squad"])
        if payload is None:
            return None, err
        text = _seg(payload, 0)
        return {"info": _kv(text), "members": _rows(text, "member"),
                "waypoints": _rows(text, "waypoint")}, ""



def register(reg: Registry, chan) -> None:  # noqa: ANN001
    st = SceneTools(chan)

    def _ask(parts, timeout_s=25.0):
        return st.query(parts, timeout_s)

    # ------------------------------------------------------------ 自身

    @reg.tool(
        name="player_state",
        description=("读**本机玩家**自身的状态：位置/朝向/姿态/生命/伤害/"
                     "当前武器与弹匣/装具/所在载具与座位/小队与军衔/视距/时间。"
                     "只读，一次往返。专用服务器上没有 player，会明确拒绝。"),
        input_schema={"type": "object", "properties": {}},
        phase="execute",
    )
    def _player_state(args: dict) -> ToolResult:
        kv, err = st.player()
        if kv is None:
            return ToolResult.fail("读玩家状态失败：%s" % err)
        if not kv:
            return ToolResult.fail("玩家状态为空——执行器可能不在任务里（主菜单/"
                                   "编辑器没有 player 单位）")
        order = ["name", "class", "side", "pos", "dir", "stance", "lifeState",
                 "damage", "alive", "weapon", "primary", "secondary", "handgun",
                 "magCount", "mags", "items", "uniform", "vest", "headgear",
                 "backpack", "vehicle", "seat", "group", "groupSize", "leader",
                 "isLeader", "role", "rank", "viewDistance", "dayTime",
                 "overcast"]
        lines = ["玩家状态：", ""]
        for k in order:
            if k in kv:
                lines.append("  %-12s %s" % (k, kv[k] or "-"))
        rest = [k for k in kv if k not in order]
        for k in rest:
            lines.append("  %-12s %s" % (k, kv[k] or "-"))
        return ToolResult.ok("\n".join(lines), kv)

    # ------------------------------------------------------------ 场景

    @reg.tool(
        name="scene_snapshot",
        description=("列出**玩家周围 radius 米内**的单位、载具与军械：类别、"
                     "类名、显示名、阵营、距离、存活、伤害、对象名、所属载具、"
                     "坐标。按距离由近到远（游戏侧 nearestObjects 的顺序）。"
                     "分页自动续取，`max_records` 控制总量。"),
        input_schema={
            "type": "object",
            "properties": {
                "radius": {"type": "number", "minimum": 1, "maximum": 2000,
                           "description": "搜索半径（米），默认 50"},
                "max_records": {"type": "integer", "minimum": 1, "maximum": 1000,
                                "description": "最多取多少条，默认 80"},
                "kind": {"type": "string", "enum": ["all", "U", "V", "O"],
                         "description": "只看某类：U=人 V=载具 O=其它；默认 all"},
            },
        },
        phase="execute",
    )
    def _scene(args: dict) -> ToolResult:
        radius = int(args.get("radius") or 50)
        want = (args.get("kind") or "all").upper()
        max_records = int(args.get("max_records") or 80)

        rows: list[list[str]] = []
        offset = 0
        meta: dict = {}
        while True:
            payload, err = _ask(["scene", radius, 100, offset])
            if payload is None:
                return ToolResult.fail("读场景失败：%s" % err)
            text = _seg(payload, 0)
            meta = _meta(_seg(payload, 1))
            for line in text.split("\n"):
                if not line or "=" in line:
                    continue
                parts = line.split("|")
                # 场景行**没有类型前缀**，靠字段数识别：12 个字段
                if len(parts) != 12:
                    continue
                if want != "ALL" and parts[0] != want:
                    continue
                rows.append(parts)
                if len(rows) >= max_records:
                    break
            nxt = meta.get("next", -1)
            if len(rows) >= max_records or not isinstance(nxt, int) or nxt < 0:
                break
            offset = nxt

        if not rows:
            return ToolResult.ok(
                "半径 %d 米内没有对象（候选 %s 个）。\n"
                "提示：主菜单/编辑器里 player 可能是空场景，进任务后再试。"
                % (radius, meta.get("candidates", "?")),
                {"rows": [], "meta": meta})

        lines = ["玩家周围 %d 米内对象（候选 %s 个，取回 %d 条）："
                 % (radius, meta.get("candidates", "?"), len(rows)), ""]
        for p in rows:
            kind = {"U": "人", "V": "载具", "O": "其它"}.get(p[0], p[0])
            line = ("  %-3s %-5s %-26s %-6s %6sm  %s"
                    % (p[0], kind, p[1][:26], _side_name(p[3]),
                       "%.1f" % _num(p[4]),
                       p[2] or p[1]))
            flags = []
            if p[5] != "1":
                flags.append("已死")
            if _num(p[6]) > 0:
                flags.append("伤害%.2f" % _num(p[6]))
            if p[8]:
                flags.append("在 %s" % p[8])
            if p[7]:
                flags.append("名=%s" % p[7])
            if flags:
                line += "  [" + " ".join(flags) + "]"
            lines.append(line)
        lines.append("")
        lines.append("坐标为 ATL（x, y, z）：")
        for p in rows[:5]:
            lines.append("  %s(%s) -> (%s, %s, %s)"
                         % (p[0], p[1][:18], p[9], p[10], p[11]))
        if len(rows) > 5:
            lines.append("  … 其余 %d 条见结构化结果" % (len(rows) - 5))
        return ToolResult.ok("\n".join(lines), {"rows": rows, "meta": meta})

    # ------------------------------------------------------------ 小队

    @reg.tool(
        name="squad_state",
        description=("本小队（`group player`）的编队与成员：group/leader/size/"
                     "formation/combatMode/behaviour/speed/currentWaypoint，"
                     "每个人的军衔、角色、生命状态、伤害、与玩家距离、所在载具，"
                     "以及全部航路点的类型/位置/战斗模式。只读。"),
        input_schema={"type": "object", "properties": {}},
        phase="execute",
    )
    def _squad(args: dict) -> ToolResult:
        data, err = st.squad()
        if data is None:
            return ToolResult.fail("读小队状态失败：%s" % err)
        info, members, wps = data["info"], data["members"], data["waypoints"]
        if not info:
            return ToolResult.fail("小队信息为空——执行器可能不在任务里")
        lines = ["小队：", ""]
        for k in ("group", "leader", "size", "formation", "combatMode",
                  "behaviour", "speed", "currentWaypoint"):
            if k in info:
                lines.append("  %-16s %s" % (k, info[k]))
        lines.append("")
        lines.append("成员 %d 人：" % len(members))
        for m in members:
            # member|名字|军衔|角色|生命状态|伤害|距离|载具|存活|是玩家
            lines.append("  %-18s %-10s %-18s %-8s dmg=%-5s 距离=%-7s %s%s"
                         % (m[1][:18], m[2], m[3][:18], m[4], m[5], m[6],
                            ("车:" + m[7]) if m[7] else "",
                            "  ← 本人" if len(m) > 9 and m[9] == "1" else ""))
        if wps:
            lines.append("")
            lines.append("航路点 %d 个：" % len(wps))
            for w in wps:
                lines.append("  #%-2s %-12s (%s, %s)  %s/%s/%s"
                             % (w[1], w[2], w[3], w[4], w[5], w[6], w[7]))
        else:
            lines.append("")
            lines.append("航路点：无")
        return ToolResult.ok("\n".join(lines), data)

    # ------------------------------------------------------------ 任务

    @reg.tool(
        name="mission_snapshot",
        description=("任务环境与目标：任务名/世界/是否联机/时间/日期/阴天/雾/"
                     "雨/风/视距/难度/简报，以及**日记里的任务与记录**"
                     "（主题 + 标题 + 正文）。引擎没有 `simpleTasks` 命令，"
                     "原生任务与 BIS_fnc_taskCreate 建的任务都落在日记里，"
                     "按 Tasks/Diary/Briefing/Intel 四个主题枚举。只读。"),
        input_schema={"type": "object", "properties": {}},
        phase="execute",
    )
    def _mission(args: dict) -> ToolResult:
        data, err = st.mission()
        if data is None:
            return ToolResult.fail("读任务环境失败：%s" % err)
        info, diary = data["info"], data["diary"]
        if not info:
            return ToolResult.fail("任务环境为空——执行器可能不在任务里")
        lines = ["任务环境：", ""]
        for k in ("missionName", "worldName", "isMultiplayer", "dayTime",
                  "date", "overcast", "fog", "rain", "wind", "viewDistance",
                  "difficulty", "taskCount"):
            if k in info:
                lines.append("  %-14s %s" % (k, info[k]))
        brief = info.get("briefing", "")
        if brief:
            lines.append("")
            lines.append("简报：")
            for ln in brief.split("\\n")[:8]:
                lines.append("  " + ln[:100])
        lines.append("")
        if diary:
            lines.append("日记记录 %d 条：" % len(diary))
            for d in diary:
                # diary|主题|标题|正文
                lines.append("  [%-9s] %s" % (d[1], d[2] or "(无标题)"))
                if len(d) > 3 and d[3]:
                    lines.append("      %s" % d[3][:110])
        else:
            lines.append("日记：无记录（该任务没有建任务/日记条目）")
        return ToolResult.ok("\n".join(lines), data)

    # ------------------------------------------------------------ 地图

    @reg.tool(
        name="map_snapshot",
        description=("地图上的全部**标记**与**触发器**：标记的名字/类型/颜色/"
                     "位置/尺寸/透明度/文本，触发器的类型/位置/区域/文本/条件"
                     "文本。分页自动续取。只读。"),
        input_schema={
            "type": "object",
            "properties": {
                "max_records": {"type": "integer", "minimum": 1,
                                "maximum": 1000,
                                "description": "最多取多少条，默认 150"},
                "only": {"type": "string", "enum": ["all", "marker", "trigger"],
                         "description": "只看标记或只看触发器"},
            },
        },
        phase="execute",
    )
    def _map(args: dict) -> ToolResult:
        only = (args.get("only") or "all").lower()
        max_records = int(args.get("max_records") or 150)
        rows: list[list[str]] = []
        meta: dict = {}
        offset = 0
        while True:
            payload, err = _ask(["map", 100, offset])
            if payload is None:
                return ToolResult.fail("读地图对象失败：%s" % err)
            text = _seg(payload, 0)
            meta = _meta(_seg(payload, 1))
            for line in text.split("\n"):
                if not line:
                    continue
                if only != "all" and not line.startswith(only + "|"):
                    continue
                if line.startswith(("marker|", "trigger|")):
                    rows.append(line.split("|"))
                if len(rows) >= max_records:
                    break
            nxt = meta.get("next", -1)
            if len(rows) >= max_records or not isinstance(nxt, int) or nxt < 0:
                break
            offset = nxt

        markers = [r for r in rows if r[0] == "marker"]
        triggers = [r for r in rows if r[0] == "trigger"]
        lines = ["地图对象：标记 %s 个、触发器 %s 个（取回 %d 条）"
                 % (meta.get("markers", "?"), meta.get("triggers", "?"),
                    len(rows)), ""]
        if markers:
            lines.append("标记：")
            for m in markers[:80]:
                # marker|名字|类型|颜色|pos|size|alpha|文本|polyline
                lines.append("  %-22s %-14s %-8s (%s, %s)  size=%s a=%s %s%s"
                             % (m[1][:22], m[2][:14], m[3], m[4], m[5],
                                m[6], m[7],
                                ("「%s」" % m[8]) if m[8] else "",
                                "  [折线]" if m[9] == "1" else ""))
        if triggers:
            lines.append("")
            lines.append("触发器：")
            for i, t in enumerate(triggers[:40]):
                # trigger|名|类型|x|y|宽|高|矩形|角度|文本|条件
                # `str trigger` 是引擎的调试串（形如 `24: <no shape`），当名字用
                # 只会造成噪音，所以这里按序号显示，原始串留在结构化结果里。
                lines.append("  #%-3d %-16s (%s, %s) %sx%s%s %s"
                             % (i, t[2], t[3], t[4], t[5], t[6],
                                " 矩形" if t[7] == "1" else " 圆/椭圆",
                                ("「%s」" % t[9]) if t[9] else ""))
                if len(t) > 10 and t[10]:
                    lines.append("      条件: %s" % t[10][:90])
        if not rows:
            lines.append("（没有标记也没有触发器）")
        return ToolResult.ok("\n".join(lines),
                             {"rows": rows, "meta": meta})
