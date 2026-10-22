/* a3mcp_fnc_cfgClass —— 把一个 config 类序列化成摘要

刻意只返回**指定**的属性（keys），不倾泻全部：一个 CfgVehicles 类常有 200+
属性，整棵返回会撑爆上层上下文。要哪些由调用方指定（MCP 侧有该用途的关键
字段预置集）。

missing 单独列出：属性不存在时不能返回空值假装成功——那是"看起来正常"的
静默错误，最难排查。
*/
params [["_cfg", configNull, [configNull]], ["_keys", [], [[]]]];

if (isNil "_cfg" || { !(isClass _cfg) }) exitWith {
    createHashMapFromArray [["found", false]]
};

private _props = createHashMap;
private _missing = [];
{
    private _key = _x;
    private _child = _cfg >> _key;
    // 判据：能取到同名子节点才算存在。configName 不等说明 _cfg >> _key
    // 落到别处（引擎对不存在的键返回的不是错误而是上一个有效节点）
    if ((configName _child) != _key) then {
        _missing pushBack _key;
    } else {
        _props set [_key, [_child] call a3mcp_fnc_cfgValue];
    };
} forEach _keys;

private _hier = (configHierarchy _cfg) apply { configName _x };

createHashMapFromArray [
    ["found", true],
    ["parentName", configName (inheritsFrom _cfg)],
    ["hierarchy", _hier],
    ["properties", _props],
    ["missing", _missing]
]
