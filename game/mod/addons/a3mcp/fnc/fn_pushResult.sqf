/* a3mcp_fnc_pushResult —— 把一条回执 JSON 交给扩展发回 MCP

单独成函数：上行只有这一个出口，便于统一加日志与失败处理。

⚠ 用**单字符串形式** `callExtension ("push " + json)`，而不是数组形式
`["push", [json]]`：实测数组形式在引擎侧参数传递不可靠（与 poll 的返回
布局异常同源），表现为 DLL 收到空参数、发送空行，而 MCP 会跳过空行 ——
症状是"SQF 明明记了 ack ->、MCP 却永远收不到"，两端日志都看不出问题。

参数：回执 JSON 文本（由 fn_ackJson 或 fn_run 生成）
*/
params [["_json", "", [""]]];

if (_json == "") exitWith { false };

private _r = "arma3_mcp" callExtension ("push " + _json);

// 回执发送的现场记录：与 fn_sendAck 的 ack -> 日志配对使用——
// 若"ack ->"有、但这里没打出，说明 push 调用本身出了问题。
diag_log format ["[A3MCP] push -> %1 bytes, resp=%2",
                 count _json, str _r];

true
