/* a3mcp_fnc_cfgValue —— 读一个 config 属性并给出带类型的表示

为什么要带类型：`""`、`0`、`false`、`[]` 这些"看起来像没值"的结果，
必须能与"属性不存在"区分开。裸值做不到这一点，所以统一包成
{"t":类型,"v":值}（与 MCP 侧 config-query.md 定义的契约一致）。

Code 类型刻意只报存在性、不返回内容：返回了上层也用不上，反而会诱导它去
尝试执行配置里的 onLoad/init。
*/
params [["_cfg", configNull, [configNull]]];

if (isNil "_cfg") exitWith {
    createHashMapFromArray [["t", "nil"], ["v", ""]]
};

if (isNumber _cfg) exitWith {
    createHashMapFromArray [["t", "number"], ["v", getNumber _cfg]]
};
if (isText _cfg) exitWith {
    createHashMapFromArray [["t", "text"], ["v", getText _cfg]]
};
if (isArray _cfg) exitWith {
    private _raw = getArray _cfg;
    private _out = [];
    { _out pushBack ([_x] call a3mcp_fnc_serialize); } forEach _raw;
    createHashMapFromArray [["t", "array"], ["v", _out]]
};
if (isClass _cfg) exitWith {
    // 类引用：给出从根到该类的路径，让上层能继续往下查
    createHashMapFromArray [
        ["t", "config"],
        ["v", (configHierarchy _cfg) apply { configName _x }]
    ]
};

createHashMapFromArray [["t", "code"], ["v", ""]]
