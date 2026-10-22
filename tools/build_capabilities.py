#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""生成能力矩阵 data/capabilities.json。

要回答的问题是：**「这项操作，引擎到底支不支持？」**
这是本项目最该固化的知识——它决定一件事能不能做、该在哪一层做，
而它无法从单条命令的签名里看出来（要看一整族命令的有无）。

做法：把结论写在下面的 CAPABILITIES 里，然后由本脚本**逐条到命令库中核对**
（声明的命令必须真实存在、版本号必须与库里一致）。核对不过就拒绝出包——
这样文档与数据不会漂移，也不会出现「文档说支持、其实没这条命令」的情况。

用法：
    python3 tools/build_capabilities.py            # 核对并生成
    python3 tools/build_capabilities.py --check    # 只核对，不写文件
"""

from __future__ import annotations

import argparse
import json
import os
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, REPO)

from knowledge.index import CommandIndex  # noqa: E402

def _safe_console() -> None:
    """让 CLI 输出在 Windows 中文控制台（GBK）下不崩。

    中文 Windows 的默认 stdout 编码是 **GBK**，而 `✓` / `✗` / `⚠` 不在 GBK 里：
    直接 print 会抛 `UnicodeEncodeError: 'gbk' codec can't encode character`。
    这是分发后最常见的环境（中文用户），CLI 一跑就崩。

    只加 `errors="replace"`、**不改 encoding**：
      · GBK 控制台：符号显示为 `?`，不崩、不乱码；
      · UTF-8 终端：符号正常显示。
    """
    for stream in (sys.stdout, sys.stderr):
        try:
            stream.reconfigure(errors="replace")
        except (AttributeError, ValueError):
            pass          # Python < 3.7 或流不支持：保持原样

OUT = os.path.join(REPO, "data", "capabilities.json")

# 每一项字段：
#   key / name 标识与中文名
#   engine     yes（引擎内可做）/ partial（半支持）/ no（引擎内做不到）
#   commands   依据命令（会被核对存在性与版本）
#   （since 字段由依据命令自动推导，不在这里手写——见 build()）
#   layer      该由哪一层实现：engine / windows / forbidden
#   note       结论与坑
#
# 注意：字符串里一律用中文书名号「」，不要用英文双引号——后者会截断
# Python 字面量（初版正是因此反复编译失败，教训记在 docs/decisions.md）。
CAPABILITIES = [
    {
        "key": "read_input_state",
        "name": "读取输入设备状态",
        "engine": "yes",
        "commands": ["inputMouse", "inputAction", "inputController",
                     "userInputDisabled", "reversedMouseY"],
        "layer": "engine",
        "note": ("只能**读**：inputMouse 返回按键状态、inputAction 返回某个功能"
                 "是否被按下。没有任何命令可以「按下」某个键。"),
    },
    {
        "key": "query_keybinds",
        "name": "查询键位绑定",
        "engine": "yes",
        "commands": ["actionKeys", "actionKeysEx", "keyName", "keyImage",
                     "BIS_fnc_keyCode"],
        "layer": "engine",
        "note": ("用于把「用户动作名」翻译成 DIK 扫描码。将来做输入注入时，"
                 "扫描码应从 actionKeys 反查，而不是手填常数表。"),
    },
    {
        "key": "move_pointer",
        "name": "移动与读取鼠标指针",
        "engine": "yes",
        "commands": ["setMousePosition", "getMousePosition",
                     "ctrlSetMousePosition", "ctrlMousePosition"],
        "layer": "engine",
        "note": "移动指针不等于点击：不产生任何按键事件。",
    },
    {
        "key": "inject_mouse_click",
        "name": "注入鼠标点击（按下与抬起）",
        "engine": "no",
        "commands": [],
        "layer": "windows",
        "note": ("**引擎内无任何命令可做**——已对全部 5000+ 条命令做过穷举检索，"
                 "不存在 inject/emulate/press 类命令。只能由 Windows 层"
                 "（SendInput 或向窗口发消息）实现。"),
    },
    {
        "key": "inject_keyboard",
        "name": "注入键盘按键",
        "engine": "no",
        "commands": [],
        "layer": "windows",
        "note": "同鼠标：引擎无此能力，必须走 Windows 层。",
    },
    {
        "key": "drag_pointer",
        "name": "拖拽（按住、移动、抬起）",
        "engine": "no",
        "commands": [],
        "layer": "windows",
        "note": ("引擎只能移动指针（setMousePosition），按下与抬起都做不到，"
                 "故拖拽必须由 Windows 层组合实现。地图拖拽、装具拖放都属此类。"),
    },
    {
        "key": "activate_control",
        "name": "触发 UI 控件按钮",
        "engine": "partial",
        "commands": ["ctrlActivate"],
        "layer": "engine",
        "note": ("**只触发引擎内建动作**（ok/cancel 之类），**不会**触发按钮自己"
                 "的 UI 事件处理器。要真正「按」一个自定义按钮，只能用坐标点击"
                 "（Windows 层），或者用 ctrlSetText/ctrlChecked 直接改值绕过。"),
    },
    {
        "key": "set_control_values",
        "name": "设置控件值",
        "engine": "yes",
        "commands": ["ctrlSetText", "ctrlSetStructuredText", "ctrlChecked",
                     "ctrlSetPosition", "ctrlCommit", "ctrlEnable", "ctrlShow"],
        "layer": "engine",
        "note": "改值比「点击」可靠：不依赖坐标与焦点，也不受分辨率影响。",
    },
    {
        "key": "open_ui",
        "name": "打开界面",
        "engine": "yes",
        "commands": ["createDisplay", "createDialog", "createGearDialog",
                     "findDisplay", "allDisplays", "closeDisplay", "forceMap"],
        "layer": "engine",
        "note": ("createGearDialog [unit, resource] 是打开装具界面的现成入口。"
                 "UI 命令是 locale effect：必须在**有玩家的进程**内执行，"
                 "专用服务器上无效。"),
    },
    {
        "key": "world_screen_projection",
        "name": "世界坐标与屏幕坐标互转",
        "engine": "yes",
        "commands": ["worldToScreen", "screenToWorld"],
        "layer": "engine",
        "note": ("「点选世界里的东西」的技术基础：先用 worldToScreen 算出目标在"
                 "屏幕上的位置，再让输入层在该坐标点一次。比人手点更准，"
                 "且失败可复现。"),
    },
    {
        "key": "unit_actions",
        "name": "让单位执行玩家级动作",
        "engine": "yes",
        "commands": ["action", "switchAction", "playMove", "playMoveNow",
                     "switchMove", "playGesture", "switchGesture"],
        "layer": "engine",
        "note": ("action [\"RELOAD\"] 这类用法直接走引擎动作表，等价于玩家按键"
                 "触发的动作，不需要模拟键盘。"),
    },
    {
        "key": "engage_target",
        "name": "瞄准与开火",
        "engine": "yes",
        "commands": ["doFire", "commandFire", "fireAtTarget", "doTarget",
                     "commandTarget", "suppressFor", "doSuppressiveFire",
                     "commandSuppressiveFire", "unitAimPosition", "aimPos"],
        "layer": "engine",
        "note": ("无需模拟鼠标按键即可开火；doFire 与 commandFire 的差别在于"
                 "是否让 AI 自主判断。"),
    },
    {
        "key": "interaction_menu",
        "name": "对象交互菜单（滚轮菜单）",
        "engine": "yes",
        "commands": ["actionIDs", "actionParams", "addAction",
                     "BIS_fnc_holdActionAdd", "BIS_fnc_holdActionRemove"],
        "layer": "engine",
        "note": ("枚举可用动作（actionIDs/actionParams）后直接用 action 执行，"
                 "不必去点菜单。"),
    },
    {
        "key": "map_click_hook",
        "name": "地图点击钩子",
        "engine": "yes",
        "commands": ["onMapSingleClick", "onDoubleClick", "onGroupIconClick"],
        "layer": "engine",
        "note": "可挂可清；用于让「在地图上点一下」变成可编程事件。",
    },
    {
        "key": "vehicle_commands",
        "name": "载具乘员指令",
        "engine": "yes",
        "commands": ["sendSimpleCommand", "vehicleMoveInfo", "moveInCargo",
                     "moveInDriver", "moveInGunner", "assignAsCargo"],
        "layer": "engine",
        "note": "sendSimpleCommand 可下达前进/停止/左右转等指令（空中载具会忽略）。",
    },
    {
        "key": "remote_execution",
        "name": "跨机执行",
        "engine": "partial",
        "commands": ["remoteExec", "remoteExecCall", "BIS_fnc_MP"],
        "layer": "forbidden",
        "note": ("本服务器**硬禁** remoteExec 系。理由：它等价于「把任意代码送到"
                 "别的机器执行」，会绕过本仓库全部参数校验与白名单。需要跨机效果"
                 "时，应由执行通道按目标选择执行位置，而不是把命令名交给调用方。"),
    },
    {
        "key": "dynamic_code",
        "name": "动态代码执行",
        "engine": "partial",
        "commands": ["compile", "call", "spawn", "execVM", "callExtension",
                     "loadFile", "preprocessFile"],
        "layer": "forbidden",
        "note": ("引擎支持，但本服务器**永远拒绝**。这是本仓库安全模型的基石："
                 "一旦允许，命令名可以是任意字符串，类型校验与白名单就全部失效。"),
    },
]


def _version_tuple(text):
    parts = []
    for piece in str(text).split("."):
        digits = "".join(ch for ch in piece if ch.isdigit())
        parts.append(int(digits) if digits else 0)
    while len(parts) < 3:
        parts.append(0)
    return tuple(parts[:3])


def build(idx):
    problems = []
    entries = []
    for cap in CAPABILITIES:
        checked = []
        for name in cap["commands"]:
            rec = idx.get(name)
            if rec is None:
                problems.append("%s: 命令 %s 不在命令库中" % (cap["key"], name))
                continue
            checked.append({"name": rec["n"], "arma3_since": idx.arma3_since(rec)})
        # since 由依据命令**自动推导**，不手写：
        #   语义 = 实现该能力所需的最低 Arma 3 版本 = 全部依据命令中引入最晚的那个。
        # 手写声明注定会与数据漂移（初版手写的 8 处声明全被核对抓出），
        # 而这条信息本来就能从数据算出来，没有手写的理由。
        versions = [i["arma3_since"] for i in checked if i["arma3_since"]]
        since = None
        if versions:
            since = max(versions, key=_version_tuple)
        if cap.get("since"):
            problems.append(
                "%s: 不该手写 since（数据可自动推导，写死会漂移）" % cap["key"])
        entries.append({
            "key": cap["key"],
            "name": cap["name"],
            "engine": cap["engine"],
            "layer": cap["layer"],
            "since": since,
            "since_earliest": min(versions, key=_version_tuple) if versions else None,
            "commands": checked,
            "note": cap["note"],
        })
    return {
        "schema": 1,
        "generated": {"builder": "tools/build_capabilities.py",
                      "command_library_records": idx.count()},
        "entries": entries,
        "problems": problems,
    }


def main(argv=None):
    ap = argparse.ArgumentParser(description="生成与核对能力矩阵")
    ap.add_argument("--check", action="store_true", help="只核对，不写文件")
    args = ap.parse_args(argv)

    idx = CommandIndex()
    payload = build(idx)

    if payload["problems"]:
        print("✗ 能力矩阵与命令库不一致：", file=sys.stderr)
        for problem in payload["problems"]:
            print("  · " + problem, file=sys.stderr)
        return 1

    counts = {}
    for entry in payload["entries"]:
        counts[entry["engine"]] = counts.get(entry["engine"], 0) + 1

    if not args.check:
        with open(OUT, "w", encoding="utf-8") as fh:
            json.dump(payload, fh, ensure_ascii=False, indent=1)
            fh.write("\n")
        print("已写入 " + OUT)

    print("能力项 %d 条：%s" % (len(payload["entries"]), counts))
    marks = {"yes": "✓", "partial": "△", "no": "✗"}
    for entry in payload["entries"]:
        print("  %s %-24s 层=%-9s 依据 %2d 条命令  需 A3 %s"
              % (marks[entry["engine"]], entry["name"], entry["layer"],
                 len(entry["commands"]), entry["since"] or "-"))
    print("全部依据命令均已在命令库中核对通过。")
    return 0


if __name__ == "__main__":
    _safe_console()
    sys.exit(main())
