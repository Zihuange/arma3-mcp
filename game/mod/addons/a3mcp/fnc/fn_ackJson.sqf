/* a3mcp_fnc_ackJson —— 构造一条合法的 JSON 回执

存在的理由：回执要嵌进 JSON，而**手写字符串转义是上机首测的主要故障源**——
SQF 的转义是两个连续引号（""），不是 C/JSON 习惯的 \"；写错只会在游戏里
报"缺少 ]"/"缺少 ;"，而 SQFLint 抓不到这类错误。

这里的做法：用一个引号变量 _q 代替每次都数引号，让结构一眼可读。
转义值由调用方传入时已经过 a3mcp_fnc_jsonEscape。
*/
params [["_cid", "", [""]], ["_ok", true, [true]], ["_payload", "", [""]]];

private _q = """";        // 一个双引号字符（SQF 里写成四个引号）

private _status = if (_ok) then { "true" } else { "false" };
private _key = if (_ok) then { "result" } else { "error" };

private _body = _q + "t" + _q + ":" + _q + "ack" + _q
    + "," + _q + "cid" + _q + ":" + _q + _cid + _q
    + "," + _q + "ok" + _q + ":" + _status
    + "," + _q + _key + _q + ":" + _payload;

"{" + _body + "}"
