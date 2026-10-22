/* a3mcp_fnc_run —— 执行一条动态表达式（args = [表达式, 参数数组, 白名单?]）

流程：校验 -> 取编译缓存或编译 -> 解析参数 -> 执行 -> 序列化 -> 回执。

## 占位符 `_pN` 在 MCP 侧就已展开成 `(_this select N)`

`_p0` 等占位符**不是** SQF 变量，没有任何东西会把它们绑到实参上。此前直接
`compile` 原表达式，结果是**一切带参数的表达式都在引擎里报**
「表达式中未定义的变量：_p0」，而执行器仍回 `ok=true`、结果 `nil` ——
调用方看到的是"成功地什么都没做"。无参表达式（`worldName`）不受影响，
所以只用过无参命令的测试看不出这个缺口。

展开放在 MCP 侧（`adapters/exec_tools.py::expand_placeholders`），本文件收到的
`_expr` 已经是 `(_this select 0) setPosATL (_this select 1)` 这种可直接编译的形态。
两侧都试过一次 SQF 实现，引擎里都不认——不在这一侧重复它，只保留一处实现。
`fn_validate` 仍认原始形态，所以直接下发 `_p0 call _p1` 也不会被误拒。

## 回执不手写 JSON

上机首测的报错全出自手写 JSON 转义：SQF 的转义是两个连续引号（""），
不是 C/JSON 习惯的 \"；而且静态检查抓不到这类错误。现在一律经
fn_jsonStringify（内部 toJSON）生成，调用方不碰转义。

## 为什么用编译缓存

`compile` 有实际开销，而命令集在运行期不变，同一段表达式会被反复执行
（例如把一队人移动到不同坐标）。缓存按**原始表达式文本**作键——展开后的代码
统一是 `_this select N` 形态，所以同一表达式配不同参数可以复用同一份 code。

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
//
// 第 4 个参数（实参表）必须传：`call` 的目标函数名在**数据**里，不看数据就
// 无法核对它。这是本框架里唯一一处"命令名之外还要看值"的判定。
private _v = [_expr, _argc, _whitelist, _argValues] call a3mcp_fnc_validate;
if !(_v select 0) exitWith {
    [_cid, _expr, format ["表达式校验未通过：%1", _v select 2]] call _fail
};

// ---- 参数解析：实体引用换回实际对象（参数始终是数据，不是代码）----
private _resolved = [];
{ _resolved pushBack ([_x] call a3mcp_fnc_resolve); } forEach _argValues;

// 这里收到的 `_expr` **已经**是展开形态（`(_this select 0) setPosATL _p1`）——
// 占位符展开在 MCP 侧完成，见 adapters/exec_tools.py::expand_placeholders。
//
// 为什么不在这一侧做：同样的字符串处理在引擎里跑不出预期结果（实测诊断
// `raw=typeName _p0 -> typeName _p0`，即那个实现没识别出占位符），而 MCP 侧
// 可以用测试逐条覆盖（含 `_p0abc`、`x_p0` 这类误替换边界）。一处实现、一处测试。

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
