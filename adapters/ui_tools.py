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
    def _list_classes() -> ToolResult:
        """列出界面上所有控件的类名 —— 走模组函数一次遍历做完。

        为什么不在 MCP 侧遍历：
          · 动态表达式里 lambda 参数 `_x` **不在白名单**，`apply { ctrlClassName _x }`
            会被校验器拒掉（那是"命令名注入"的防线，不该为便利放宽）；
          · 逐个 exec 取一个类名 —— 一次往返约 100ms，而界面有 160+ 个控件，且每读
            一个都要重新求值 allControls（扫描成本正比于控件总数）。

        于是"这个界面上有哪些控件类型"在 MCP 侧**无法高效回答**，而它恰恰是探索
        未知界面时最先要问的问题：不知道目标叫什么，就没法用 match_class。
        """
        # args 是**扁平的参数列表**（与 configQuery / configOfEntity 的约定一致），
        # 不是嵌套数组。第一版写成 [["classes"]]，于是 SQF 侧
        # `_args param [0, "classes", [""]]` 拿到的是数组而不是字符串，
        # 引擎报"类型 数组，预期为 字符串"。
        reply = chan.send({"cmd": "uiquery", "args": ["classes"]},
                          timeout_s=25.0)
        if not reply.ok:
            return ToolResult.fail(
                "列控件类名失败：%s\n（这一步依赖模组函数 a3mcp_fnc_uiQuery，"
                "需要游戏侧已加载含它的 PBO）" % reply.error)
        # reply.result **就是** SQF 回的负载，外面没有 {"ok":...} 那层包装 ——
        # 我按自己的想象加了一个 ok 检查，于是每一次成功的回执都被判成"被拒绝"。
        # 对照项目里的同类调用（config_tools 的 data = reply.result 直接用，
        # exec_tools 直接 json.dumps(reply.result)）就能避免。
        data = reply.result
        # fn_uiQuery 回的是 [文本, 扫描数]
        text = ""
        if isinstance(data, list) and data:
            first = data[0]
            text = first if isinstance(first, str) else (
                first.get("v", "") if isinstance(first, dict) else str(first))
        elif isinstance(data, str):
            text = data
        return ToolResult.ok(
            "界面控件类名（按数量降序）：\n\n%s\n\n"
            "下一步：用 match_class 指定其中一个类名，即可拿到可点击的屏幕坐标。"
            % (text or "(没有扫到任何控件)"), data)

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
                "list_classes": {"type": "boolean",
                                 "description": "改而**列出界面上所有控件的类名**"
                                                "（按数量降序），不返回坐标。用于探索"
                                                "未知界面：不知道目标控件叫什么时，"
                                                "先列一遍类名，再按类名精确定位"},
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

        if args.get("list_classes"):
            return _list_classes()

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

    # ------------------------------------------- 整棵树 / 可点元素 / 处理器文本
    #
    # 这三个查询都走模组函数 a3mcp_fnc_uiQuery 的新分页接口：**一次遍历、一次
    # 往返**。此前 MCP 侧逐个 exec 读字段，成本正比于控件数的平方 —— 448 个
    # 控件根本读不完，只能扫前 40 个。分页的理由见 fn_uiQuery.sqf 的头注释
    # （DLL 上行单行 16 KB，超了是**静默截断**）。

    def _uiquery(parts, timeout_s=25.0):
        """发一条 uiQuery，返回 (原始负载, 错误)。"""
        reply = chan.send({"cmd": "uiquery", "args": parts},
                          timeout_s=timeout_s)
        if not reply.ok:
            return None, reply.error
        return reply.result, ""

    def _seg(payload, index):
        """从 SQF 回的结构里取出第 index 段文本。"""
        if isinstance(payload, dict):
            payload = payload.get("v")
        if not isinstance(payload, list) or len(payload) <= index:
            return ""
        seg = payload[index]
        if isinstance(seg, dict):
            seg = seg.get("v")
        return seg if isinstance(seg, str) else ""

    def _rows(text, nfields):
        out = []
        for line in (text or "").split("\n"):
            if not line:
                continue
            parts = line.split("|")
            if len(parts) < nfields:
                continue
            out.append(parts)
        return out

    def _counts(meta):
        out = {}
        for tok in (meta or "").split():
            if "=" in tok:
                k, v = tok.split("=", 1)
                try:
                    out[k] = int(v)
                except ValueError:
                    out[k] = v
        return out

    def _num(parts, i, default=0.0):
        try:
            return float(parts[i])
        except (TypeError, ValueError):
            return default

    def _int(parts, i, default=0):
        """整数容错解析。

        SQF 的 `str` 对较大整数会输出**科学计数法**（实测某个控件的 idc 是
        `6.9e+06`），直接 int() 会抛 ValueError 把整个工具打挂 —— 第一次跑
        全量 tree 就是这么崩的。先按 int 解析，失败再走 float。
        """
        for conv in (int, float):
            try:
                return conv(parts[i])
            except (TypeError, ValueError):
                continue
        return default

    @reg.tool(
        name="ui_snapshot",
        description=(
            "一次拿回**整棵控件树**（分页自动续取），或**所有按钮的执行代码**，"
            "或某个 UI 类在 config 里的**事件处理器文本**。"
            "mode=tree：每个控件一行（display/索引/类名/IDC/类型/启用/显示/"
            "透明度/位置/文本）。mode=actions：只列按钮，并给出它点击后**真正"
            "执行的代码**（运行时 buttonAction；为空时自动去 config 的 "
            "onButtonClick 里找）。mode=handlers：读 config 里某个 display 类"
            "整棵子树的 action/onButtonClick。"
            "tree 的 screen 字段可直接喂给 input_click。"),
        input_schema={
            "type": "object",
            "properties": {
                "mode": {"type": "string",
                         "enum": ["tree", "actions", "handlers"],
                         "description": "默认 tree"},
                "display": {"type": "integer",
                            "description": "只保留某个 display 的控件（tree 用）"},
                "max_records": {"type": "integer", "minimum": 1, "maximum": 2000,
                                "description": "最多取多少条，默认 300。tree 会"
                                               "自动分页直到取够或取完"},
                "class_name": {"type": "string",
                               "description": "handlers 用的 display config 类名，"
                                              "如 Display3DEN / RscDisplayMain"},
            },
        },
        phase="input",
    )
    def _snapshot(args):
        mode = (args.get("mode") or "tree").lower()
        want_display = args.get("display")
        max_records = int(args.get("max_records") or 300)

        if mode == "handlers":
            cls = args.get("class_name") or ""
            payload, err = _uiquery(["handlers", cls], timeout_s=25.0)
            if payload is None:
                return ToolResult.fail(
                    "读 config 处理器失败：%s\n（这一步依赖模组函数 "
                    "a3mcp_fnc_uiQuery 的 handlers 分支，需要装载新版 PBO）" % err)
            meta = _counts(_seg(payload, 1))
            recs = _rows(_seg(payload, 0), 3)
            lines = ["%s 的处理器文本（遍历 %s 个节点，%d 个类带处理器）"
                     % (meta.get("class", "?"), meta.get("nodes", "?"),
                        len(recs)), ""]
            for path, act, onclick in recs:
                lines.append("  " + path)
                if act:
                    lines.append("    action        : %s" % act)
                if onclick:
                    lines.append("    onButtonClick : %s" % onclick)
            if not recs:
                lines.append("  （没有找到带 action / onButtonClick 的类）")
            return ToolResult.ok("\n".join(lines), {"meta": meta, "records": recs})

        if mode == "actions":
            payload, err = _uiquery(["actions", 500, 0], timeout_s=25.0)
            if payload is None:
                return ToolResult.fail(
                    "读按钮 action 失败：%s\n（需要装载含 actions 分支的新版 PBO）"
                    % err)
            meta = _counts(_seg(payload, 1))
            recs = _rows(_seg(payload, 0), 6)
            # config 侧的处理器：只有运行时 action 为空时才需要
            handlers = {}
            for dcls in sorted({r[1] for r in recs if r[1]}):
                hp, herr = _uiquery(["handlers", dcls], timeout_s=25.0)
                if hp is None:
                    continue
                table = {}
                for path, act, onclick in _rows(_seg(hp, 0), 3):
                    cls = path.rsplit("/", 1)[-1]
                    table.setdefault(cls, []).append((path, act, onclick))
                handlers[dcls] = table

            lines = ["可点元素（按钮）共 %s 个；其中运行时 action 为空 %s 个 "
                     "——空不等于不能点，它们的处理器在 config 的 onButtonClick 里。"
                     % (meta.get("buttons", "?"), meta.get("emptyAction", "?")), ""]
            out = []
            for dIdx, dcls, idc, cls, text, act in recs:
                dIdx = _int([dIdx], 0)
                idc = _int([idc], 0, -1)
                entry = {"display": dIdx, "display_class": dcls,
                         "idc": idc, "class": cls, "text": text,
                         "action": act, "handler": "", "handler_path": ""}
                if not act:
                    cands = handlers.get(dcls, {}).get(cls, [])
                    if len(cands) == 1:
                        entry["handler_path"], entry["handler"] = \
                            cands[0][0], (cands[0][2] or cands[0][1])
                    elif len(cands) > 1:
                        entry["handler_path"] = " | ".join(c[0] for c in cands)
                out.append(entry)
                lines.append("  display=%s idc=%s %s" % (dIdx, idc, cls))
                if text:
                    lines.append("    文本   : %s" % text)
                if act:
                    lines.append("    执行   : %s   ← 运行时 buttonAction" % act)
                elif entry["handler"]:
                    lines.append("    执行   : %s   ← config onButtonClick"
                                 % entry["handler"])
                    lines.append("    路径   : %s" % entry["handler_path"])
                elif entry["handler_path"]:
                    lines.append("    执行   : （同名类有多个，需按路径择一）")
                    lines.append("    路径   : %s" % entry["handler_path"])
                else:
                    lines.append("    执行   : （config 里也没有，引擎原生按钮）")
            lines.append("")
            lines.append("提示：action 是**代码字符串**，直接执行等价于点击；"
                         "执行前建议先看清目标（例如 do3DENAction 会真的动作）。")
            return ToolResult.ok("\n".join(lines),
                                 {"meta": meta, "buttons": out,
                                  "handlers": {k: {c: v for c, v in t.items()}
                                               for k, t in handlers.items()}})

        # ---- tree ----
        geom = locator.window_geometry()
        offset = 0
        rows = []
        meta = {}
        display_lines = []
        while True:
            payload, err = _uiquery(["snapshot", 100, offset], timeout_s=25.0)
            if payload is None:
                return ToolResult.fail(
                    "读控件树失败：%s\n（需要装载含 snapshot 分支的新版 PBO）" % err)
            text = _seg(payload, 0)
            meta = _counts(_seg(payload, 1))
            if not display_lines:
                display_lines = _seg(payload, 2).split("\n")
            for parts in _rows(text, 13):
                d = _int(parts, 0)
                if want_display is not None and d != int(want_display):
                    continue
                rel = [_num(parts, i) for i in (8, 9, 10, 11)]
                row = {"display": d, "index": _int(parts, 1),
                       "class": parts[2], "idc": _int(parts, 3, -1),
                       "type": _int(parts, 4),
                       "enabled": parts[5] == "true",
                       "shown": parts[6] == "true",
                       "fade": _num(parts, 7),
                       "rel": rel, "text": parts[12]}
                if geom is not None:
                    row["screen"] = list(to_screen(rel, geom))
                rows.append(row)
                if len(rows) >= max_records:
                    break
            nxt = meta.get("next", -1)
            if len(rows) >= max_records or not isinstance(nxt, int) or nxt < 0:
                break
            offset = nxt

        lines = ["控件树：共 %s 个控件（每 display 配额 100，自动续取）"
                 % meta.get("total", "?"), ""]
        for dl in display_lines:
            if dl:
                lines.append("  " + dl)
        lines.append("")
        for row in rows:
            pos = ", ".join("%.3f" % v for v in row["rel"])
            line = ("  d%d#%-3d %-22s idc=%-5d type=%-2d "
                    % (row["display"], row["index"], row["class"], row["idc"],
                       row["type"]))
            if "screen" in row:
                line += "屏幕(%d,%d) " % tuple(row["screen"])
            line += "rel=[%s]" % pos
            if not row["shown"]:
                line += " [隐藏]"
            if not row["enabled"]:
                line += " [禁用]"
            if row["text"]:
                line += " text=%r" % row["text"][:40]
            lines.append(line)
        lines.append("")
        lines.append("type 1=按钮（buttonAction 可用）；15=控件组（容器，"
                     "子控件在其下）；其余为引擎控件类型。")
        return ToolResult.ok("\n".join(lines),
                             {"total": meta.get("total"), "count": len(rows),
                              "displays": display_lines, "rows": rows})
