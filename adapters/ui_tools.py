#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""UI 定位工具：把游戏内控件的位置换算成**可直接点击的屏幕坐标**。

## 为什么需要它（P2 缺的那一环）

P2 的两半此前是断开的：

  · `input_click` 要的是**屏幕坐标**（客户区坐标 + 客户区原点）；
  · 而游戏里能问到的只有 `ctrlPosition`，它返回的是**归一化坐标**
    `[x, y, w, h]`（相对屏幕的比例，可以为负、可以大于 1 —— 控件超出屏幕时
    就是这样）。

中间那步换算没人做，于是"用控件定位、用坐标点击"这条本该最可靠的路走不通，
只剩下"照着截图目测坐标"——而目测在分辨率或窗口位置变化后立刻失效。

## 换算公式

    screen_x = origin_x + (rel_x + rel_w / 2) * client_w
    screen_y = origin_y + (rel_y + rel_h / 2) * client_h

即取控件**中心**。`origin` / `client_w` / `client_h` 来自 DLL 的 `window_info`，
坐标原点是**客户区**左上角在屏幕上的位置（不是窗口矩形）。

实测校准：编辑器地图控件返回 `[-0.281, -0.088, 1.563, 1.176]`，代入得中心
`(0.5, 0.5)` → 屏幕 `(680, 407)`，正是 1360x768 客户区的中心，与"地图铺满
编辑区"相符。

## 已知限制（实测，别当成 bug）

**写入对引擎内建 UI 无效**：对编辑器地图的滚动块调 `ctrlSetText` 返回正常
（nil、不报错），读回却仍是空 —— 引擎静默忽略。编辑器 UI 是引擎原生的，
不是 SQF 建的控件。所以本工具只负责**定位**："改值"只对自己 `createDisplay`
出来的控件可靠，"按按钮"应当走点击（`ctrlActivate` 不会触发自定义按钮的
事件处理器，见能力矩阵 activate_control）。详见 decisions.md D24。

**性能（实测，比最初估计的差得多）**：枚举控件要靠 `exec` 一次次问游戏，而
表达式里不能定义局部变量，所以每读一个控件的类名都得重写一遍
`(allControls (allDisplays select N))` —— 而**每次求值都会全量枚举该 display
的控件**。于是总耗时正比于**控件总数**，分批读根本摊薄不了（我最初以为能）。

实测：编辑器那个 321 控件的 display，光按类名扫一遍就要一分钟以上，HTTP 请求
直接挂死。所以本工具**默认只扫前 `MAX_SCAN` 个控件**并把这件事说清楚；要覆盖
更多就显式调大，自己承担时间。真正干净的做法是在模组里加一个"一次遍历返回
全部类名"的函数（见 decisions.md），那需要改 PBO。

"""

from __future__ import annotations

from typing import Any, Optional

from mcpcore.registry import Registry, ToolResult

# 引擎侧对动态表达式的硬上限（实测报错原文："表达式过长（上限 400 字符）"）。
# 超了不是慢，是**直接被拒**。
EXPR_MAX = 400

# 每次 exec 里读多少个控件的类名。每读一个都要重写一遍
# `ctrlClassName ((allControls (allDisplays select N)) select I)`，约 60 字符，
# 所以 8 个就已经越过 400 的天花板 —— 最初写 8 时整批被引擎拒掉，而症状是
# "每条都要等满超时"，看起来像性能问题。5 个约 300 字符，留出余量。
BATCH = 5

# 单次 exec 的超时。读类名本身不慢，慢的是它背后的全量枚举。
READ_TIMEOUT_S = 8.0

# 默认最多扫多少个控件。见文件头的性能说明：读一个控件的类名就要一次全量
# 枚举，成本正比于控件总数，所以必须有默认上限 —— 没有它，一个 321 控件的
# display 会让这个工具跑上一分钟以上（实测过，HTTP 请求直接挂死）。
MAX_SCAN = 40


def _unv(node: Any) -> Any:
    """剥掉游戏侧序列化的 {v, t} 外壳，取出裸值。"""
    if isinstance(node, dict) and "v" in node and "t" in node:
        return node["v"]
    return node


def _as_list(node: Any) -> list:
    val = _unv(node)
    return val if isinstance(val, list) else []


def _as_int(node: Any) -> Optional[int]:
    val = _unv(node)
    return val if isinstance(val, int) else None


def _as_str(node: Any) -> str:
    val = _unv(node)
    return val if isinstance(val, str) else ""


class UiLocator:
    def __init__(self, chan) -> None:  # noqa: ANN001
        self.chan = chan

    # ------------------------------------------------------------ 底层

    def _eval(self, expr: str, args: Optional[list] = None,
              timeout_s: float = READ_TIMEOUT_S) -> tuple[bool, Any, str]:
        """跑一条只读表达式。返回 (ok, 裸值, 错误)。"""
        reply = self.chan.send({"cmd": "exec", "args": [expr, args or []]},
                               timeout_s=timeout_s)
        if not reply.ok:
            return False, None, reply.error
        return True, _unv(reply.result), ""

    def display_count(self) -> tuple[bool, int, str]:
        ok, val, err = self._eval("count allDisplays")
        if not ok:
            return False, 0, err
        n = _as_int(val)
        if n is None:
            return False, 0, "allDisplays 返回了非预期内容"
        return True, n, ""

    def control_count(self, display_idx: int) -> tuple[bool, int, str]:
        ok, val, err = self._eval(
            "count allControls (allDisplays select %d)" % display_idx)
        if not ok:
            return False, 0, err
        n = _as_int(val)
        if n is None:
            return False, 0, "allControls 返回了非预期内容"
        return True, n, ""

    def class_names(self, display_idx: int, start: int,
                    count: int) -> tuple[bool, list[str], str]:
        """一次读 count 个控件的类名。

        表达式里不能定义局部变量（校验器只认 _p0.._pN 占位符与白名单命令），
        所以只能把 `(allControls (allDisplays select N))` 重复写出来 —— 分批
        是为了摊薄这部分重复。
        """
        inner = "(allControls (allDisplays select %d))" % display_idx
        parts: list[str] = []
        for i in range(count):
            piece = "ctrlClassName (%s select %d)" % (inner, start + i)
            candidate = "[" + ", ".join(parts + [piece]) + "]"
            if parts and len(candidate) > EXPR_MAX:
                break            # 少读几个，好过整批被引擎拒掉
            parts.append(piece)
        ok, val, err = self._eval("[" + ", ".join(parts) + "]")
        if not ok:
            return False, [], err
        names = [_as_str(x) for x in _as_list(val)]
        if not names:
            return False, [], "类名批量读取返回空的非预期结果"
        return True, names, ""

    def control_text(self, display_idx: int, index: int) -> str:
        ok, val, _ = self._eval(
            "ctrlText ((allControls (allDisplays select %d)) select %d)"
            % (display_idx, index))
        return _as_str(val) if ok else ""

    def control_idc(self, display_idx: int, index: int) -> Optional[int]:
        ok, val, _ = self._eval(
            "ctrlIDC ((allControls (allDisplays select %d)) select %d)"
            % (display_idx, index))
        return _as_int(val) if ok else None

    def control_pos(self, display_idx: int,
                    index: int) -> Optional[list[float]]:
        """读控件的归一化位置 [x, y, w, h]。"""
        ok, val, _ = self._eval(
            "ctrlPosition ((allControls (allDisplays select %d)) select %d)"
            % (display_idx, index))
        arr = _as_list(val)
        if len(arr) != 4:
            return None
        out: list[float] = []
        for item in arr:
            num = _unv(item)
            if not isinstance(num, (int, float)):
                return None
            out.append(float(num))
        return out

    def window_geometry(self) -> Optional[dict]:
        """客户区尺寸与它在屏幕上的原点 —— 换算的基准。"""
        reply = self.chan.send({"cmd": "window_info", "args": []}, timeout_s=5.0)
        if not reply.ok or not isinstance(reply.result, dict):
            return None
        data = reply.result
        origin = data.get("client_origin")
        size = data.get("client")          # 字段名是 client，不是 client_size
        if not (isinstance(origin, list) and isinstance(size, list)):
            return None
        if len(origin) != 2 or len(size) != 2:
            return None
        return {"origin": (int(origin[0]), int(origin[1])),
                "size": (int(size[0]), int(size[1]))}


def to_screen(rel: list[float], geom: dict) -> tuple[int, int]:
    """归一化控件位置 → 屏幕坐标（取控件中心）。

    单独拎出来是为了可测：换算错了不会报错，只会点到别处。
    """
    ox, oy = geom["origin"]
    cw, ch = geom["size"]
    cx = rel[0] + rel[2] / 2.0
    cy = rel[1] + rel[3] / 2.0
    return int(round(ox + cx * cw)), int(round(oy + cy * ch))


def register(reg: Registry, chan) -> None:  # noqa: ANN001
    locator = UiLocator(chan)

    @reg.tool(
        name="ui_locate",
        description=("在游戏 UI 里查找控件，返回**可直接交给 input_click 的屏幕坐标**。"
                     "先用它定位、再点击，比照着截图目测坐标可靠（不受分辨率与"
                     "窗口位置影响）。可按类名／文本／IDC 过滤。"
                     "注意：只负责定位；对引擎内建 UI 的写入是无效的（见 docs）。"),
        input_schema={
            "type": "object",
            "properties": {
                "display": {"type": "integer",
                            "description": "限定 display 索引；省略则搜全部"},
                "match_class": {"type": "string",
                                "description": "类名精确匹配，如 Map／RscButton"},
                "match_text": {"type": "string",
                               "description": "控件文本包含该子串（区分大小写）"},
                "match_idc": {"type": "integer", "description": "控件 IDC"},
                "limit": {"type": "integer", "minimum": 1, "maximum": 50,
                          "description": "最多返回几个匹配，默认 10"},
                "max_scan": {"type": "integer", "minimum": 1, "maximum": 500,
                             "description": "最多扫描多少个控件（默认 %d）。扫描成本正比于此值，调大可能很慢。" % MAX_SCAN},
            },
        },
        phase="input",
    )
    def _locate(args: dict) -> ToolResult:
        # 无头形态（专用服务器）没有 UI 控件树，直接说明比让它在几百个空控件里
        # 空转要好。
        from adapters import health as _health
        ui_why = _health.require_ui(chan)
        if ui_why is not None:
            return ToolResult.fail(ui_why, {"headless": True})

        want_class = args.get("match_class")
        want_text = args.get("match_text")
        want_idc = args.get("match_idc")
        limit = int(args.get("limit") or 10)
        max_scan = int(args.get("max_scan") or MAX_SCAN)

        if want_class is None and want_text is None and want_idc is None:
            return ToolResult.fail(
                "至少要给一个匹配条件（match_class / match_text / match_idc），"
                "否则会在几百个控件里全量回读位置，很慢且没有意义。")

        geom = locator.window_geometry()
        if geom is None:
            return ToolResult.fail(
                "拿不到窗口几何信息（window_info 无回执）——DLL 未加载或未接通，"
                "换算屏幕坐标的前提不成立。")

        ok, total_displays, err = locator.display_count()
        if not ok:
            return ToolResult.fail(
                "读 display 数量失败：%s\n"
                "（执行器可能需要先在任务里启动；用 gates_status 确认执行器状态。）"
                % err)

        displays = ([int(args["display"])] if args.get("display") is not None
                    else list(range(total_displays)))

        matches: list[dict] = []
        scanned = 0
        truncated = False
        for d in displays:
            ok, n, err = locator.control_count(d)
            if not ok:
                continue
            idx = 0
            # ⚠ 配额是**每个 display** 的，不是全局的。
            #
            # 实测踩过：写成全局配额时，第一个 display（编辑器有 321 个控件）
            # 会把 40 的额度一次吃光，于是后面的 display 一个控件都没扫到 ——
            # 而目标控件恰好在第二个 display 里，表现为"明明存在却报没有匹配"。
            scanned_in_display = 0
            while idx < n:
                if scanned_in_display >= max_scan:
                    truncated = True
                    break
                take = min(BATCH, n - idx, max_scan - scanned_in_display)
                ok, names, err = locator.class_names(d, idx, take)
                if not ok or not names:
                    idx += take
                    continue
                # 按**实际读到的个数**推进：表达式长度预检可能让它少于 take，
                # 按 take 推进会跳过若干控件。
                take = len(names)
                for offset, name in enumerate(names):
                    scanned += 1
                    scanned_in_display += 1
                    if want_class is not None and name != want_class:
                        continue
                    matches.append({"display": d, "index": idx + offset,
                                    "class": name})
                idx += take
            # ⚠ 这里**不能** break：max_scan 是每个 display 的配额，扫满一个
            # display 就该继续下一个。原先留了 `if truncated: break`，于是第一个
            # display 吃满配额后整个循环结束，后面的 display 一个控件都扫不到
            # （目标 Map 恰好在第二个 display 里，表现为"明明存在却报没有匹配"）。

        # 粗筛之后才逐个补细节 —— 未匹配的控件不必付这个代价
        needs_text = want_text is not None
        needs_idc = want_idc is not None
        refined: list[dict] = []
        for m in matches:
            if needs_text:
                m["text"] = locator.control_text(m["display"], m["index"])
                if want_text not in m["text"]:
                    continue
            if needs_idc:
                m["idc"] = locator.control_idc(m["display"], m["index"])
                if m["idc"] != want_idc:
                    continue
            rel = locator.control_pos(m["display"], m["index"])
            if rel is None:
                continue
            m["rel"] = rel
            m["screen"] = to_screen(rel, geom)
            refined.append(m)
            if len(refined) >= limit:
                break

        if not refined:
            return ToolResult.ok(
                "没有匹配的控件（扫描了 %d 个%s，display=%s）。\n"
                "提示：类名可用 ctrlClassName 读到的值，例如 Map／MouseArea／"
                "RscButton；编辑器菜单栏是**引擎原生 UI**，不在这套控件树里。"
                % (scanned, "(已达 max_scan 上限)" if truncated else "", displays),
                {"scanned": scanned, "truncated": truncated, "matches": []})

        scope = ("扫描 %d 个" % scanned if not truncated
                 else "只扫描了前 %d 个（已达 max_scan 上限，未覆盖全部控件）" % scanned)
        lines = ["匹配到 %d 个控件（%s）：" % (len(refined), scope), ""]
        for m in refined:
            lines.append("  display=%d index=%d class=%s"
                         % (m["display"], m["index"], m["class"]))
            if "text" in m:
                lines.append("    text   : %r" % m["text"])
            if "idc" in m:
                lines.append("    idc    : %s" % m["idc"])
            lines.append("    rel    : [%s]" % ", ".join("%.4f" % v for v in m["rel"]))
            lines.append("    屏幕中心: (%d, %d)  ← 可直接 input_click"
                         % m["screen"])
        lines.append("")
        lines.append("提示：控件中心未必是可点击点（有的控件只在特定子区域响应），"
                     "点不中时用 rel 自行微调。")
        return ToolResult.ok("\n".join(lines),
                             {"scanned": scanned, "truncated": truncated,
                              "geometry": geom, "matches": refined})
