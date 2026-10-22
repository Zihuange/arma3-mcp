#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""工具注册表。

每个工具声明：名字、一句话描述（给 LLM 看的，写清楚了它才知道什么时候用）、
输入 schema、以及处理函数。schema 在调用前校验，handler 只面对干净入参。
"""

from __future__ import annotations

import json
from dataclasses import dataclass, field
from typing import Any, Callable

from .schema import SchemaError, validate


@dataclass
class ToolResult:
    """工具返回值。text 是给模型看的正文；is_error 让客户端正确渲染失败。"""

    text: str
    is_error: bool = False
    structured: Any = None

    @classmethod
    def ok(cls, text: str, structured: Any = None) -> "ToolResult":
        return cls(text=text, is_error=False, structured=structured)

    @classmethod
    def fail(cls, text: str, structured: Any = None) -> "ToolResult":
        return cls(text=text, is_error=True, structured=structured)

    def to_mcp(self) -> dict:
        payload: dict[str, Any] = {
            "content": [{"type": "text", "text": self.text}],
            "isError": self.is_error,
        }
        if self.structured is not None:
            payload["structuredContent"] = self.structured
        return payload


@dataclass
class Tool:
    name: str
    description: str
    input_schema: dict
    handler: Callable[[dict], ToolResult]
    # 供本仓库内部使用的元数据（不发给客户端，避免污染 LLM 上下文）
    meta: dict = field(default_factory=dict)

    def to_mcp(self) -> dict:
        return {
            "name": self.name,
            "description": self.description,
            "inputSchema": self.input_schema,
        }


class Registry:
    def __init__(self) -> None:
        self._tools: dict[str, Tool] = {}

    def add(self, tool: Tool) -> None:
        if tool.name in self._tools:
            raise ValueError(f"工具名重复：{tool.name}")
        self._tools[tool.name] = tool

    def tool(self, name: str, description: str, input_schema: dict | None = None,
             **meta: Any) -> Callable:
        """装饰器形式的注册。"""
        def deco(fn: Callable[[dict], ToolResult]) -> Callable:
            self.add(Tool(
                name=name,
                description=description,
                input_schema=input_schema or {"type": "object", "properties": {}},
                handler=fn,
                meta=meta,
            ))
            return fn
        return deco

    def get(self, name: str) -> Tool | None:
        return self._tools.get(name)

    def names(self) -> list[str]:
        return sorted(self._tools)

    def list_mcp(self) -> list[dict]:
        return [self._tools[n].to_mcp() for n in self.names()]

    def call(self, name: str, arguments: Any) -> ToolResult:
        """执行工具。参数校验失败返回 is_error 结果（不抛异常）。"""
        tool = self.get(name)
        if tool is None:
            return ToolResult.fail(
                f"未知工具 {name!r}。可用工具：{', '.join(self.names())}")
        args = arguments if isinstance(arguments, dict) else {}
        if arguments is not None and not isinstance(arguments, dict):
            return ToolResult.fail(
                f"参数必须是对象（JSON object），实际收到 "
                f"{type(arguments).__name__}")
        try:
            validate(args, tool.input_schema)
        except SchemaError as exc:
            return ToolResult.fail(
                f"参数校验失败：{exc}\n参数 schema："
                f"{json.dumps(tool.input_schema, ensure_ascii=False)}")
        try:
            return tool.handler(args)
        except Exception as exc:  # noqa: BLE001 —— 工具故障不该杀死服务器
            import traceback
            return ToolResult.fail(
                f"工具 {name} 内部错误：{type(exc).__name__}: {exc}\n"
                f"{traceback.format_exc(limit=5)}")
