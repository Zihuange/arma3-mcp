/* a3mcp_fnc_jsonParse —— 解析 JSON 文本

`fromJSON` 是引擎命令（MCP 侧用 JSON 传参，游戏侧必须能解析）。
这里用**原生写法** `fromJSON _text`，因为实测 `_text call fromJSON`
会被引擎拒绝（报"意外的 )"）。正确性优先于迁就静态检查。

⚠ 已知静态检查误报：本机 SQFLint 的命令表未收录 fromJSON/toJSON，
写成原生形式它可能报"标识符相邻"。这是检查器的局限，不是代码缺陷——
tools/pack_mod.sh 里对该误报有显式豁免（见其注释）。
*/
params [["_text", "", [""]]];

if (_text == "") exitWith { createHashMap };
fromJSON _text
