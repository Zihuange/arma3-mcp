/* a3mcp_fnc_sendAck —— 发送一条回执（序列化 + 组装 + 上行，一步到位）

为什么单独成函数（这轮上机的教训）：
之前在每个调用点写
    [_cid, true, [_data] call a3mcp_fnc_jsonStringify] call a3mcp_fnc_ackJson
这种"嵌套 call 出现在数组元素里"的写法，**引擎解析不了**，报的是
"Error in expression"——而且它在**加载期**就报，整个函数都不可用。
分步赋值（先算出负载，再组装回执）既没有歧义，也好读。

参数：cid、ok、负载（成功时是已序列化的 JSON 文本，失败时是错误说明）
*/
// ⚠ _payload 不加类型约束：调用方传进来的可能是 HashMap（未序列化的结构），
// 也可能是字符串（错误说明）。约束成 [""] 会让 HashMap 被 params 拒掉、
// 静默退回空串 —— 那是"回执里结果为空"的成因。
params [["_cid", "", [""]], ["_ok", true, [true]], ["_payload", nil]];

private _json = "";
if (_ok) then {
    _json = [_payload] call a3mcp_fnc_jsonStringify;
} else {
    _json = _payload;      // 失败时负载就是可读的错误说明，直接进 error 字段
};

private _ack = [_cid, _ok, _json] call a3mcp_fnc_ackJson;
diag_log format ["[A3MCP] ack -> cid=%1 ok=%2", _cid, _ok];
[_ack] call a3mcp_fnc_pushResult
