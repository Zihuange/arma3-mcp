/* a3mcp_fnc_jsonStringify —— 把值序列化成 JSON 文本

与 fn_jsonParse 对称的封装，用原生写法 `toJSON _value`（理由同该函数：
call 形式会被引擎拒绝）。

关键收益：**调用方不再手写 JSON 转义**。SQF 的转义是两个连续引号（""）
而不是 C/JSON 习惯的 \" —— 上机首测的报错全出自这里，而且静态检查抓不到。
把序列化交给引擎，这类缺陷从根上消失。

⚠ 同 fn_jsonParse：SQFLint 未收录 toJSON，可能产生误报，已在打包检查中豁免。
*/
params [["_value", []]];
toJSON _value
