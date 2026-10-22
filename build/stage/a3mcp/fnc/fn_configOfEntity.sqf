/* a3mcp_fnc_configOfEntity —— 从一个游戏内实体跳到它的 config

args = [[实体名], keys?]

用途：把"我看到的这个东西"变成"它是什么、有哪些属性"。
实体名是**游戏内变量名**（任务编辑器里给对象起的名字）。

⚠ 关键语义：`missionNamespace getVariable` 对未定义的名字返回 **nil 而不报错**。
上游极容易把它误读成"实体存在但配置为空"。所以这里显式返回 found 字段，
并区分三种失败：名字未定义 / 名字有值但不是对象 / 对象已不存在。
混成一句"找不到"会让人在上机时白查很久。

回执一律经 fn_ackJson，不手写 JSON 转义。
*/
params [["_cid", "", [""]], ["_args", [], [[]]]];

private _name = "";
if ((count _args) > 0) then {
    private _first = _args select 0;
    if (_first isEqualType []) then {
        _name = _first param [0, "", [""]];
    } else {
        _name = _first;
    };
};
private _keys = _args param [1, [], [[]]];

private _reply = {
    params [["_cidIn", "", [""]], ["_data", createHashMap, [createHashMap]]];
    [_cidIn, true, _data] call a3mcp_fnc_sendAck;
};

if (_name == "") exitWith {
    [_cid, createHashMapFromArray [
        ["found", false], ["reason", "未提供实体名"]]] call _reply
};

private _obj = missionNamespace getVariable [_name, nil];

if (isNil "_obj") exitWith {
    [_cid, createHashMapFromArray [
        ["found", false],
        ["reason", format ["任务命名空间里没有名为 %1 的变量", _name]]
    ]] call _reply
};

if (!(_obj isEqualType objNull)) exitWith {
    [_cid, createHashMapFromArray [
        ["found", false],
        ["reason", format ["%1 存在，但它不是对象（typeName=%2）",
                           _name, typeName _obj]]
    ]] call _reply
};

if (isNull _obj) exitWith {
    [_cid, createHashMapFromArray [
        ["found", false],
        ["reason", format ["%1 指向的对象已不存在（可能已被删除）", _name]]
    ]] call _reply
};

private _cfg = configOf _obj;

// 未指定 keys 时给一组最常用的，避免倾泻数百属性
if (count _keys == 0) then {
    _keys = ["displayName", "transportSoldier", "armor", "maxSpeed",
             "side", "faction", "vehicleClass"];
};

private _props = createHashMap;
private _missing = [];
{
    private _k = _x;
    private _child = _cfg >> _k;
    if ((configName _child) != _k) then {
        _missing pushBack _k;
    } else {
        _props set [_k, [_child] call a3mcp_fnc_cfgValue];
    };
} forEach _keys;

[_cid, createHashMapFromArray [
    ["found", true],
    ["name", _name],
    ["type", typeOf _obj],
    ["properties", _props],
    ["missing", _missing]
]] call _reply
