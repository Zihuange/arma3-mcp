#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""结构化调用 → SQF 表达式。

这是模型与游戏内执行之间**唯一**的翻译点，所以它必须：
  · 只输出 JSON 化的参数（SQF 侧用 `fromJSON` 解析），绝不拼接裸文本；
  · 明确区分"实体引用"与"数组"——`[["u_17"]]` 是实体，`["u_17"]` 是数组；
  · 对无法表达的值（对象、函数）直接拒绝，而不是编一个看起来对的写法。

为什么实体用单元素数组而不用对象：所有 SQF 命令的对象参数都是**位置参数**，
统一成数组写法后，模型只需记住一种语法；而校验层用"长度为 1 的数组"
区分实体与普通数组（见 knowledge/index.py 的 _json_type）。
"""

from __future__ import annotations

import json
import math
from typing import Any


class SerializeError(ValueError):
    """参数无法序列化。消息面向使用者，要能读懂。"""


# 已知的"实体类"类型名（与 knowledge/index.py 的 _TYPE_MAP 保持同一口径）
ENTITY_TYPES = {
    "object", "group", "control", "display", "config", "task", "waypoint",
    "location",
}

# 只接受引擎标识符形态的实参名：字母/数字/下划线/点，且不能以数字开头。
# 这既是格式约束，也是注入防线——名字里不可能夹带 SQF 代码。
_ENTITY_NAME_OK = set(
    "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_.")


def _clean_entity_name(raw: Any) -> str:
    if not isinstance(raw, str):
        raise SerializeError(f"实体引用必须是字符串，实际 {type(raw).__name__}")
    name = raw.strip()
    if not name:
        raise SerializeError("实体引用不能是空字符串")
    if not name[0].isalpha() and name[0] != "_":
        raise SerializeError(f"实体引用 {name!r} 必须以字母或下划线开头")
    bad = [ch for ch in name if ch not in _ENTITY_NAME_OK]
    if bad:
        raise SerializeError(
            f"实体引用 {name!r} 含非法字符 {bad!r}（只允许字母、数字、下划线、点）")
    return name


def _encode_value(value: Any, expected_type: str | None) -> Any:
    """把 JSON 值转成"可直接交给 SQF fromJSON"的形态。

    实体用 {"__ent__": "名字"} 承载——对象形式的标记不会被业务数据误用，
    且 SQF 侧一眼可辨（`isEqualType {}` + 键存在性）。
    """
    if value is None or isinstance(value, (bool, str)):
        return value
    if isinstance(value, (int, float)):
        if isinstance(value, float) and (math.isnan(value) or math.isinf(value)):
            raise SerializeError("不接受 NaN / Infinity 作为参数")
        return value
    if isinstance(value, dict):
        # 显式实体写法 {entity: "u_17"} / {__ent__: "u_17"} 也接受
        for key in ("__ent__", "entity"):
            if key in value and len(value) == 1:
                return {"__ent__": _clean_entity_name(value[key])}
        return {k: _encode_value(v, None) for k, v in value.items()}
    if isinstance(value, (list, tuple)):
        items = list(value)
        # 长度为 1 且期望是实体类 → 实体引用
        if len(items) == 1 and expected_type in ENTITY_TYPES:
            return {"__ent__": _clean_entity_name(items[0])}
        # 长度为 1 但期望是数组：可能仍是实体（类型未知时），
        # 也可能是真数组。以"元素是不是合法实体名"为判据，两条路都通。
        if len(items) == 1 and isinstance(items[0], str):
            try:
                return {"__ent__": _clean_entity_name(items[0])}
            except SerializeError:
                return [_encode_value(items[0], None)]
        return [_encode_value(item, None) for item in items]
    raise SerializeError(
        f"参数含无法序列化的值（{type(value).__name__}）；"
        f"只接受 null/bool/number/string/array/object")


def build_command(name: str, args: list, variants: list[dict] | None = None,
                  matched_index: int | None = None) -> dict:
    """构造交给游戏内执行器的调用负载。

    返回 {"expr": SQF 表达式文本, "payload": 结构化负载, "json": JSON 文本}
    · expr 是给日志/人工核对看的**预览**，不是执行依据（执行依据是 json）；
    · 选中的签名变体用于判断每个位置参数的期望类型。
    """
    if not isinstance(name, str) or not name.strip():
        raise SerializeError("命令名必须是非空字符串")
    if args is None:
        args = []
    if not isinstance(args, (list, tuple)):
        raise SerializeError(
            f"args 必须是数组（位置参数列表），实际 {type(args).__name__}")

    expected: list[str | None] = []
    if variants and matched_index is not None and 0 <= matched_index < len(variants):
        for spec in variants[matched_index].get("args") or []:
            expected.append(spec.get("type"))

    encoded = []
    for idx, value in enumerate(args):
        exp = expected[idx] if idx < len(expected) else None
        encoded.append(_encode_value(value, exp))

    payload = {"cmd": name.strip(), "args": encoded}
    json_text = json.dumps(payload, ensure_ascii=False, separators=(",", ":"))

    # 人类可读预览：实体显示为 <名字>，其余按 JSON 显示（仅用于日志与回显）
    preview_args = []
    for value in encoded:
        if isinstance(value, dict) and "__ent__" in value:
            preview_args.append("<" + str(value["__ent__"]) + ">")
        else:
            preview_args.append(json.dumps(value, ensure_ascii=False))
    expr = name.strip() + " " + " ".join(preview_args)
    return {"expr": expr.strip(), "payload": payload, "json": json_text}
