/* a3mcp_fnc_run —— 执行一条动态表达式（args = [表达式, 参数数组, 白名单?]）

流程：校验 -> 取编译缓存或编译 -> 解析参数 -> 执行 -> 序列化 -> 回执。

## 回执不手写 JSON

上机首测的报错全出自手写 JSON 转义：SQF 的转义是两个连续引号（""），
不是 C/JSON 习惯的 \"；而且静态检查抓不到这类错误。现在一律经
fn_jsonStringify（内部 toJSON）生成，调用方不碰转义。

## 为什么用编译缓存

`compile` 有实际开销，而命令集在运行期不变，同一段表达式会被反复执行
（例如把一队人移动到不同坐标）。缓存按表达式文本作键。
*/
params [["_cid", "", [""]], ["_args", [], [[]]]];

private _expr = _args param [0, ""];
private _argValues = _args param [1, []];
private _whitelist = _args param [2, []];

// 失败回执：显式接收参数，不靠闭包捕获（SQF 虽共享作用域，显式传参更清晰）
private _fail = {
    params [["_cidIn", "", [""]], ["_exprIn", "", [""]],
            ["_reasonIn", "", [""]]];
    diag_log format ["[A3MCP][ERR] %1 | expr=%2", _reasonIn, _exprIn];
    [_cidIn, false, "cmd_failed: " + _reasonIn] call a3mcp_fnc_sendAck;
};

if (!(_expr isEqualType "") || { _expr == "" }) exitWith {
    [_cid, _expr, "缺少表达式"] call _fail
};
if !(_argValues isEqualType []) exitWith {
    [_cid, _expr, "参数必须是数组"] call _fail
};

private _argc = count _argValues;

// ---- 第一道：词法校验（游戏进程内的最后一道防线）----
private _v = [_expr, _argc, _whitelist] call a3mcp_fnc_validate;
if !(_v select 0) exitWith {
    [_cid, _expr, format ["表达式校验未通过：%1", _v select 2]] call _fail
};

// ---- 参数解析：实体引用换回实际对象（参数始终是数据，不是代码）----
private _resolved = [];
{ _resolved pushBack ([_x] call a3mcp_fnc_resolve); } forEach _argValues;

// ---- 编译（带缓存）----
private _cache = missionNamespace getVariable ["A3MCP_CACHE", createHashMap];
private _code = _cache getOrDefault [_expr, nil];
if (isNil "_code") then {
    _code = compile _expr;
    _cache set [_expr, _code];
};

// ---- 执行 ----
private _value = nil;
private _ok = true;
private _err = "";
try {
    _value = _resolved call _code;
} catch {
    _ok = false;
    _err = str _exception;
};

if (!_ok) exitWith {
    [_cid, _expr, format ["执行出错：%1", _err]] call _fail
};

private _n = missionNamespace getVariable ["A3MCP_DONE", 0];
missionNamespace setVariable ["A3MCP_DONE", _n + 1, false];

// 成功：结果序列化后经 jsonStringify 嵌入回执
private _ser = [_value] call a3mcp_fnc_serialize;
[_cid, true, _ser] call a3mcp_fnc_sendAck;
