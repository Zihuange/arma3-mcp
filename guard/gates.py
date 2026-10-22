#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""闸门与风险分级。

三类闸门（按能力危险度分，不按命令族分）：
  ENGINE_READ   只读查询与纯计算                 默认 开
  ENGINE_WRITE  改变游戏世界（含 UI 改动）        默认 开
  ENGINE_EXOTIC 凭空生成资源 / 网络协调 / 调试后门 默认 关

一条不许动摇的规则：**硬禁命令永远拒绝，任何开关都放不开**。
它们是"任意代码执行"面（execVM / compile / callExtension / loadFile …）。
理由不是洁癖：MCP 工具的参数来自 LLM，一旦命令名可以来自任意字符串，
本仓库全部的类型校验与白名单就都成了装饰。

分级来源见 docs/provenance.md；显式清单优先于模式规则——名字像不代表语义同。
"""

from __future__ import annotations
from typing import Optional

import json
import os
import sys
import time
from dataclasses import dataclass, field

# --------------------------------------------------------------- 硬禁（无条件）

FORBIDDEN_EXACT = {
    # 动态代码执行：放行即等于放弃参数校验
    "compile", "compilefinal", "spawn", "exec", "execvm", "execfsm",
    "preprocessfile", "preprocessfilelinenumbers", "preprocessconfigfile",
    "loadfile", "callExtension".lower(),
    # 远程执行：跨机注入面
    "remoteexec", "remoteexeccall", "bis_fnc_mp",
    # 官方封装的执行函数
    "bis_fnc_execvm", "bis_fnc_execfsm", "bis_fnc_spawn",
    "bis_fnc_codeperformance", "bis_fnc_dbg_remotelyexec",
}

# `call` 不在硬禁里，但也不是普通命令——它是**有条件放行**的一级。
#
# 为什么它和 compile/spawn 不同（这是本轮唯一的判据变化）：
#   compile / spawn / execVM 的参数是**任意字符串**，放行即等于放弃校验；
#   而 `call` 的参数是**函数引用**——它只能取到有限的那些已编译符号，
#   且这些符号的名字可以逐个核对（见下表的 CALL_DENY 与 function_list 白名单）。
#   引擎定义支持这一点：`call code` 的 code 参数"also accepts datatype String"，
#   传字符串时按**函数名**解析，不建新代码对象（BI 命令库原文）。
#
# 因此 `call` 走 A3MCP_ENGINE_CALL 闸门，且函数名要额外过 CALL_DENY。
# 仍留在 FORBIDDEN_PREFIXES 里的 `bis_fnc_exec*` 说明：这条路不等于"能执行任意代码"。

# 即使开了 call 闸门也**一律拒绝**的函数名。
#
# 两类：
#   · 执行类——它们把字符串编译成代码，等于把 `call` 变回 `compile`；
#   · 远程类——跨机注入面。
# 优先级**高于**白名单：显式放行也解不开（见 Gates.check）。
CALL_DENY_EXACT = {
    "bis_fnc_execvm", "bis_fnc_execfsm", "bis_fnc_spawn",
    "bis_fnc_codeperformance", "bis_fnc_dbg_remotelyexec",
    "bis_fnc_mp", "bis_fnc_callsqf",
    "call", "compile", "compilefinal", "spawn", "execvm", "execfsm",
    "callextension", "remoteexec", "remoteexeccall",
}
CALL_DENY_PREFIXES = (
    "bis_fnc_exec",        # execVM / execFSM / execRemote / execCode …
    "bis_fnc_spawn",       # spawn / spawnGroup … 都是另起代码
    "bis_fnc_dbg_",        # 调试后门
    "bis_fnc_codeperformance",
    "bis_fnc_callsqf",
    "spawn_",              # 引擎内部的 spawn 变体
    "exec_",
)

FORBIDDEN_PREFIXES = (
    "bis_fnc_exec",        # BIS_fnc_execVM / execFSM / execRemote …
    "bis_fnc_spawn",       # BIS_fnc_spawnGroup 等会绕过受控注册
    "bis_fnc_dbg_",        # 调试后门
    "bis_fnc_codeperformance",
)

# 需 EXOTIC 闸门

# 凭空生成资源：这类命令让"战力"与"地图原状"解耦，属于沙盒能力
EXOTIC_EXACT = {
    "createvehicle", "createvehiclet", "createvehiclecrew", "createvehiclelocal",
    "creategroup", "createunit", "createagent", "createmarker",
    "createlocation", "createsimpletask", "createtask",
    # 上行通道本身与调试后门
    "diag_log", "diag_export", "attrit", "intel_debug", "debug_throw",
    "air_threat", "group_attach_player",
}
EXOTIC_PREFIXES = (
    "create",
    "sendudp",
    "sendau",
    "publicvariable",
)

# --------------------------------------------------------------- 写操作模式

WRITE_PREFIXES = (
    "set", "add", "remove", "delete", "enable", "disable", "do", "command",
    "play", "switch", "attach", "detach", "show", "hide", "force",
    "move", "assign", "join", "leave", "selectweapon", "fire", "action",
    "trigger", "allow", "lock", "unlock", "reveal", "weapon",
)

# 名字像写操作、实际只是查询/本地计算的例外
READ_EXCEPTIONS = {
    "getvariable", "getmarkerpos", "getpos", "getdir", "deleteat",
    "isnil", "set",          # `set` 是数组赋值（局部），不改游戏世界
    "showhud",               # 只改本地 HUD 显示，不改变世界状态
}

# 关键字里带这些词的，即使前缀是 get/set，也按只读处理（纯计算/查询返回）
READ_HINTS = ("time", "date", "version", "fps", "diag_", "worldsize")


def _norm(name: str) -> str:
    return (name or "").strip().lower()


def call_denied(fn_name: str) -> Optional[str]:
    """函数名是否属于"即使开了 call 闸门也一律拒绝"的一类。

    返回命中的原因（供报错文本用），没命中返回 None。
    """
    f = _norm(fn_name).lstrip("_")
    if not f:
        return None
    if f in CALL_DENY_EXACT:
        return "执行类/远程类官方函数（会把 call 变回 compile）"
    for prefix in CALL_DENY_PREFIXES:
        if f.startswith(prefix):
            return "执行类/远程类官方函数（前缀 %s*）" % prefix
    return None


def call_denied_list() -> list[str]:
    """CALL_DENY 清单（供文档生成与自检）。"""
    return sorted(CALL_DENY_EXACT) + [p + "*" for p in CALL_DENY_PREFIXES]


@dataclass
class Verdict:
    allowed: bool
    level: str                       # read / write / exotic / forbidden
    reason: str = ""
    needs_flag: Optional[str] = None

    def to_dict(self) -> dict:
        out: dict = {"allowed": self.allowed, "level": self.level}
        if self.reason:
            out["reason"] = self.reason
        if self.needs_flag:
            out["needs_flag"] = self.needs_flag
        return out


def classify(name: str) -> str:
    """给命令分级：read / write / exotic / call_gated / forbidden。

    `call` 单独一级是刻意的：它的风险不来自"命令本身危险"，而来自**它的参数**。
    分级函数看不到参数，所以它只能回答"这类命令需要额外核对"，核对在
    `Gates.check`（开关）与 `knowledge.expr.validate`（函数名）里各做一次。
    """
    n = _norm(name)
    if not n:
        return "forbidden"
    if n in FORBIDDEN_EXACT or any(n.startswith(p) for p in FORBIDDEN_PREFIXES):
        return "forbidden"
    if n == "call":
        return "call_gated"
    if n in EXOTIC_EXACT or any(n.startswith(p) for p in EXOTIC_PREFIXES):
        return "exotic"
    if n in READ_EXCEPTIONS:
        return "read"
    if n in ("diag_ticktime", "diag_frameno"):
        return "read"
    if n.startswith(WRITE_PREFIXES):
        return "write"
    # CBA/ACE 函数的副作用无法静态判断 → 保守按写处理
    if n.startswith(("cba_fnc_", "ace_")):
        return "write"
    return "read"


@dataclass
class Gates:
    """闸门状态。默认值 = 最保守但仍可用。"""

    engine_read: bool = True
    engine_write: bool = True
    engine_exotic: bool = False
    engine_call: bool = False
    ui_control: bool = True
    input_inject: bool = False
    input_foreground_only: bool = True
    allow_input_text: bool = True
    allow_cheat: bool = False
    overrides: set[str] = field(default_factory=set)

    @classmethod
    def from_env(cls, env: Optional[dict] = None) -> "Gates":
        e = env if env is not None else os.environ

        def flag(key: str, default: bool) -> bool:
            raw = e.get(key)
            if raw is None or raw.strip() == "":
                return default
            return raw.strip().lower() in ("1", "true", "yes", "on")

        extra = (e.get("A3MCP_ALLOW_COMMANDS") or "").strip()
        profile = (e.get("A3MCP_PROFILE") or "").strip().lower()
        # debug 档：只把偏"能力探索"的两项默认打开（EXOTIC 与 call）。
        # 刻意不含 engine_write / input_inject —— 那两个改变了"会不会动到世界"
        # 的性质，而 debug 的本意是"能查能调"，不是"放手改"。
        debug = profile == "debug"
        return cls(
            engine_read=flag("A3MCP_ENGINE_READ", True),
            engine_write=flag("A3MCP_ENGINE_WRITE", True),
            engine_exotic=flag("A3MCP_ENGINE_EXOTIC", debug),
            engine_call=flag("A3MCP_ENGINE_CALL", debug),
            ui_control=flag("A3MCP_UI_CONTROL", True),
            input_inject=flag("A3MCP_INPUT_INJECT", False),
            input_foreground_only=flag("A3MCP_INPUT_FOREGROUND_ONLY", True),
            allow_input_text=flag("A3MCP_INPUT_TEXT", True),
            allow_cheat=flag("A3MCP_ALLOW_CHEAT", False),
            overrides={x.strip().lower() for x in extra.split(",") if x.strip()},
        )

    def check(self, name: str) -> Verdict:
        n = _norm(name)
        level = classify(n)
        if n in self.overrides and level not in ("forbidden", "call_gated"):
            # 显式放行只对"非硬禁"有效——硬禁没有例外，这是刻意的。
            #
            # call_gated 同样**不接受**显式放行，理由不同：它要核对的是"调用哪个
            # 函数"，那份清单在 knowledge.expr 里逐条比对函数名。用一个命令名级别
            # 的开关放行 call，等于绕开那次核对——那就是留后门。
            return Verdict(True, level, reason=f"{n} 由 A3MCP_ALLOW_COMMANDS 显式放行")
        if level == "forbidden":
            return Verdict(
                False, level,
                reason=(f"{n} 属于**硬禁命令**（动态代码执行 / 注入面），"
                        f"没有任何开关能放行。请改用结构化调用表达同一意图。"))
        if level == "call_gated" and not self.engine_call:
            return Verdict(
                False, level,
                reason=("call 是有条件放行的一级：它的参数是函数引用，必须逐个核对"
                        "函数名。当前未开 A3MCP_ENGINE_CALL。"),
                needs_flag="A3MCP_ENGINE_CALL")
        if level == "exotic" and not self.engine_exotic:
            need = "A3MCP_ALLOW_CHEAT" if n in CHEAT_COMMANDS else "A3MCP_ENGINE_EXOTIC"
            if need == "A3MCP_ALLOW_CHEAT" and self.allow_cheat:
                return Verdict(True, level, reason=f"{n} 已由调试开关放行")
            return Verdict(
                False, level,
                reason=(f"{n} 需要 EXOTIC 闸门（凭空生成资源 / 网络协调 / "
                        f"调试后门）。"),
                needs_flag=need)
        if level == "write" and not self.engine_write:
            return Verdict(
                False, level,
                reason=f"{n} 会改变游戏世界，需要 ENGINE_WRITE 闸门。",
                needs_flag="A3MCP_ENGINE_WRITE")
        if level == "read" and not self.engine_read:
            return Verdict(False, level, reason="只读闸门已关闭。",
                           needs_flag="A3MCP_ENGINE_READ")
        return Verdict(True, level)

    def snapshot(self) -> dict:
        return {
            "engine_read": self.engine_read,
            "engine_write": self.engine_write,
            "engine_exotic": self.engine_exotic,
            "engine_call": self.engine_call,
            "ui_control": self.ui_control,
            "input_inject": self.input_inject,
            "input_foreground_only": self.input_foreground_only,
            "allow_input_text": self.allow_input_text,
            "allow_cheat": self.allow_cheat,
            "overrides": sorted(self.overrides),
        }


# 调试/作弊性质的命令：即使开了 EXOTIC 也建议单独开关（来源：命令审计分类）
CHEAT_COMMANDS = {
    "attrit", "intel_debug", "debug_throw", "air_threat",
    "group_attach_player", "diag_log", "diag_export",
}


def audit(tool: str, detail: dict, path: Optional[str] = None) -> str:
    """生成一条审计记录（JSONL），可选追加落盘。返回该行文本。

    带上实例标识（pid + 解释器）：同一份仓库可能同时被 WSL 侧与 Windows 侧的
    实例使用，而审计落到同一个文件——不区分来源的话，审计记录回答不了
    "这是谁做的"（多实例共存是常态，不是例外）。
    """
    rec = {"ts": round(time.time(), 3), "tool": tool,
           "pid": os.getpid(), "exe": sys.executable}
    rec.update(detail)
    line = json.dumps(rec, ensure_ascii=False, separators=(",", ":"))
    target = path or os.environ.get("A3MCP_AUDIT_LOG")
    if target:
        try:
            os.makedirs(os.path.dirname(os.path.abspath(target)), exist_ok=True)
            with open(target, "a", encoding="utf-8") as fh:
                fh.write(line + "\n")
        except OSError:
            pass   # 审计失败不该阻断操作本身，但也不静默——见返回值的 raw 行
    return line


def forbidden_list() -> list[str]:
    """硬禁清单（供文档生成与自检，避免文档与实现漂移）。"""
    return sorted(FORBIDDEN_EXACT) + [p + "*" for p in FORBIDDEN_PREFIXES]
