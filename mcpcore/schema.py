#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""工具输入 schema 的轻量校验。

为什么需要它：MCP 工具的参数直接来自 LLM，参数类型错（把数组写成字符串、
把数字写成字符串）会让下游的原生层收到垃圾。**在边界处校验并给出可读的
拒绝原因**，比让错误穿透到游戏进程内再崩掉要便宜得多。

支持的 JSON Schema 子集（够用且可无障碍扩展）：
  type（含 type 数组与 "null"）
  enum
  anyOf
  properties / required / additionalProperties
  items
  minimum / maximum

不追求完整实现——完整实现要引第三方库，与本仓库"仅标准库"的约束冲突。
未识别的关键字一律忽略（宽松），但**类型与必填是严格执行的**。
"""

from __future__ import annotations

from typing import Any

JsonSchema = dict


class SchemaError(ValueError):
    """校验失败。message 面向使用者（要能读懂哪里错了）。"""


_TYPE_ALIASES = {
    "integer": "integer",
    "number": "number",
    "string": "string",
    "boolean": "boolean",
    "object": "object",
    "array": "array",
    "null": "null",
}


def _type_of(value: Any) -> str:
    # 注意顺序：bool 是 int 的子类，必须先判 bool
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
        return "array"
    return "unknown"


def _type_matches(actual: str, expected: str) -> bool:
    if expected == "number":
        return actual in ("number", "integer")   # 整数是合法的 number
    if expected == "integer":
        return actual == "integer"               # 但 1.5 不是 integer
    return actual == expected


def validate(value: Any, schema: JsonSchema, path: str = "$") -> None:
    """校验 value 是否符合 schema。不符合抛 SchemaError。"""
    if not isinstance(schema, dict):
        return

    if "anyOf" in schema:
        errors = []
        for branch in schema["anyOf"]:
            try:
                validate(value, branch, path)
                return
            except SchemaError as exc:
                errors.append(str(exc))
        raise SchemaError(
            f"{path}: 不匹配任何一种允许的形式（{' | '.join(errors)}）")

    if "enum" in schema:
        allowed = schema["enum"]
        if value not in allowed:
            raise SchemaError(
                f"{path}: 取值 {value!r} 不在允许集合 {allowed!r} 内")

    expected = schema.get("type")
    if expected is not None:
        expected_list = expected if isinstance(expected, list) else [expected]
        actual = _type_of(value)
        if not any(_type_matches(actual, str(e)) for e in expected_list):
            raise SchemaError(
                f"{path}: 期望类型 {'/'.join(str(e) for e in expected_list)}，"
                f"实际 {actual}")

    if isinstance(value, (int, float)) and not isinstance(value, bool):
        if "minimum" in schema and value < schema["minimum"]:
            raise SchemaError(f"{path}: {value} 小于最小值 {schema['minimum']}")
        if "maximum" in schema and value > schema["maximum"]:
            raise SchemaError(f"{path}: {value} 大于最大值 {schema['maximum']}")

    if isinstance(value, str):
        if "maxLength" in schema and len(value) > schema["maxLength"]:
            raise SchemaError(
                f"{path}: 字符串长度 {len(value)} 超过上限 {schema['maxLength']}")

    if isinstance(value, dict):
        props = schema.get("properties") or {}
        for key in schema.get("required") or []:
            if key not in value:
                raise SchemaError(f"{path}: 缺少必填字段 {key!r}")
        extra = schema.get("additionalProperties", True)
        for key, sub in value.items():
            if key in props:
                validate(sub, props[key], f"{path}.{key}")
            elif extra is False:
                raise SchemaError(
                    f"{path}: 不认识的字段 {key!r}（允许的字段："
                    f"{', '.join(sorted(props)) or '无'}）")
            elif isinstance(extra, dict):
                validate(sub, extra, f"{path}.{key}")

    if isinstance(value, (list, tuple)) and "items" in schema:
        for idx, item in enumerate(value):
            validate(item, schema["items"], f"{path}[{idx}]")
