#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""能力矩阵读取。

data/capabilities.json 回答的是单条命令签名回答不了的问题：
**「这项操作，引擎到底支不支持？做不到的话该在哪一层做？」**

它不是手写的文档，而是由 tools/build_capabilities.py 逐条核对命令库后生成的
（每条结论都挂着真实存在的依据命令）。所以这里只读取，不做解释性加工。
"""

from __future__ import annotations
from typing import Optional

import json
import os
from functools import lru_cache

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DATA = os.path.join(REPO, "data", "capabilities.json")

_ENGINE_LABEL = {
    "yes": "引擎内可做",
    "partial": "半支持（有坑，见说明）",
    "no": "引擎内做不到",
}
_LAYER_LABEL = {
    "engine": "引擎层（SQF 命令）",
    "windows": "Windows 层（原生输入注入）",
    "forbidden": "禁用（本服务器硬禁）",
}


class CapabilityMatrix:
    def __init__(self, path: str = DATA) -> None:
        self.path = path
        self._data: Optional[dict] = None

    def _ensure(self) -> None:
        if self._data is not None:
            return
        if not os.path.isfile(self.path):
            raise FileNotFoundError(
                f"能力矩阵缺失：{self.path}\n"
                f"请先运行：python3 tools/build_capabilities.py")
        with open(self.path, encoding="utf-8") as fh:
            self._data = json.load(fh)

    @property
    def entries(self) -> list[dict]:
        self._ensure()
        assert self._data is not None
        return self._data["entries"]

    def find(self, query: str) -> list[dict]:
        """按 key 或中文名（含模糊）匹配。也匹配依据命令名。"""
        q = (query or "").strip().lower()
        if not q:
            return []
        hits = []
        for entry in self.entries:
            if q == entry["key"].lower():
                hits.insert(0, entry)
                continue
            if q in entry["key"].lower() or q in entry["name"]:
                hits.append(entry)
                continue
            if any(q in cmd["name"].lower() for cmd in entry["commands"]):
                hits.append(entry)
        return hits

    def render(self, entry: dict) -> str:
        lines = [f"# {entry['name']}　（{entry['key']}）"]
        lines.append(f"引擎支持：{_ENGINE_LABEL.get(entry['engine'], entry['engine'])}")
        lines.append(f"实现层：{_LAYER_LABEL.get(entry['layer'], entry['layer'])}")
        if entry.get("since"):
            lines.append(f"最低 Arma 3 版本：{entry['since']}"
                         + (f"（最早可用命令出现在 {entry['since_earliest']}）"
                            if entry.get("since_earliest") else ""))
        lines.append("")
        lines.append("说明：" + entry["note"])
        if entry["commands"]:
            lines.append("")
            lines.append("依据命令（已核对存在于命令库）：")
            for cmd in entry["commands"]:
                version = cmd.get("arma3_since") or "-"
                lines.append(f"  · {cmd['name']:28s} A3 {version}")
        else:
            lines.append("")
            lines.append("依据：无——引擎内没有任何命令可做这件事。")
        return "\n".join(lines)


@lru_cache(maxsize=1)
def default_matrix() -> CapabilityMatrix:
    return CapabilityMatrix()
