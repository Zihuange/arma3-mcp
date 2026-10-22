/* a3mcp_fnc_configQuery —— 游戏内 config 查询的分发器

args = [root, path(斜杠分隔), op, keys?, limit?]
op ∈ {tree, class, search}

MCP 侧契约见 docs/config-query.md；本函数是该契约的游戏侧实现。
回执一律经 fn_ackJson / fn_jsonStringify，不手写 JSON 转义。
*/
params [["_cid", "", [""]], ["_args", [], [[]]]];

private _root = _args param [0, "CfgVehicles", [""]];
private _path = _args param [1, "", [""]];
private _op = toLower (_args param [2, "class", [""]]);
private _keys = _args param [3, [], [[]]];
private _limit = _args param [4, 50, [0]];

// 回执统一走 sendAck（它负责序列化 + 组装 + 上行）；
// 这里保留一个同名闭包是为了调用点读起来一致
private _reply = {
    params [["_cidIn", "", [""]], ["_okIn", true, [true]],
            ["_payloadIn", nil]];
    [_cidIn, _okIn, _payloadIn] call a3mcp_fnc_sendAck;
};

// 解析类路径：configFile >> "CfgVehicles" >> ...
private _cfg = configFile >> _root;
{
    if (_x != "") then { _cfg = _cfg >> _x; };
} forEach (_path splitString "/");

// ── 通配符匹配（`*` 任意串、`?` 单字符）──────────────────────────────
//
// ⚠ 这里曾经是"只取第一个 `*` 之前那一段、看它在类名里是否出现"，
// 于是**模式以 `*` 开头时那一段为空 → 匹配全部类**（实测有人得到 15604 条
// 无关结果）。而且 `?` 从未实现，含 `?` 的模式一律匹配不到（漏报）。
// 旧写法既误报又漏报，两端都错。
//
// 现在是标准 glob：双指针 + 星号回溯。算法与 MCP 侧
// `adapters/config_tools.py::glob_match` 必须一致（那边有测试参考实现），
// 字符码 42='*'、63='?'。
private _globMatch = {
    params [["_pat", "", [""]], ["_name", "", [""]]];
    private _p = toArray _pat;
    private _n = toArray _name;
    private _pl = count _p;
    private _nl = count _n;
    private _pi = 0;
    private _ni = 0;
    private _starP = -1;
    private _starN = -1;
    private _ok = true;

    while { _ni < _nl } do {
        private _pc = if (_pi < _pl) then { _p select _pi } else { -1 };
        if (_pi < _pl && { _pc == 63 || { _pc == (_n select _ni) } }) then {
            _pi = _pi + 1;
            _ni = _ni + 1;
        } else {
            if (_pi < _pl && { _pc == 42 }) then {
                _starP = _pi;
                _starN = _ni;
                _pi = _pi + 1;
            } else {
                if (_starP >= 0) then {
                    _starN = _starN + 1;
                    _ni = _starN;
                    _pi = _starP + 1;
                } else {
                    _ok = false;
                    _ni = _nl;      // 无法匹配：让主循环条件失败以跳出（SQF 没有 break）
                };
            };
        };
    };
    if (_ok) then {
        while { _pi < _pl && { (_p select _pi) == 42 } } do { _pi = _pi + 1; };
        _ok = (_pi == _pl);
    };
    _ok
};

if (!(isClass _cfg)) exitWith {
    [_cid, false, "config 路径不存在" + _root + "/" + _path] call _reply
};

// ⚠ configClasses 是**双参数**命令：`condition configClasses config`。
//
// 本文件曾写成 `configClasses _cfg`（少传 condition），引擎报
// "configclasses: 类型 Config entry，预期为 数组" —— 第一个位置期望的是
// condition 字符串，不是 config。而这个错误只在真机上出现，被 fn_loop 的
// catch 吞掉后，外面看到的是"命令收到了但毫无反应"（没有 ack、没有 [ERR]），
// 只有翻 RPT 的 SQF 错误堆栈才看得到。
//
// 两处统一给 "true"（不过滤，取全部子类），筛的工作留在 SQF 侧做，
// 见 search 分支。命令签名以离线库为准：configClasses 的 condition 是
// String、config 是 Config，返回 Array。
switch (_op) do {
    case "tree": {
        private _children = [];
        private _total = 0;
        {
            _total = _total + 1;
            if (_total <= _limit) then {
                _children pushBack createHashMapFromArray [
                    ["name", configName _x],
                    ["isClass", true]
                ];
            };
        } forEach ("true" configClasses _cfg);
        private _payload = createHashMapFromArray [
            ["children", _children], ["total", _total]
        ];
        [_cid, true, _payload] call a3mcp_fnc_sendAck;
    };
    case "class": {
        private _sum = [_cfg, _keys] call a3mcp_fnc_cfgClass;
        [_cid, true, _sum] call a3mcp_fnc_sendAck;
    };
    case "search": {
        // ⚠ configClasses 是重量级调用（遍历子树）。这里只做一次遍历，
        // 结果整体给 MCP 侧缓存；不要在游戏侧反复遍历匹配。
        private _pattern = toLower (_keys param [0, "", [""]]);
        private _matches = [];
        // `_total` 现在是"**精确命中**总数"，不再是"遍历到的子类数"——
        // 旧实现把遍历数当总数报出去，配合错误的匹配规则，读起来像是
        // "有 15604 个匹配"，实际那是整棵子树的规模。语义必须分开。
        private _total = 0;
        {
            private _nm = configName _x;
            if ([_pattern, toLower _nm] call _globMatch) then {
                _total = _total + 1;
                if (count _matches < _limit) then { _matches pushBack _nm; };
            };
        } forEach ("true" configClasses _cfg);
        private _payload = createHashMapFromArray [
            ["matches", _matches], ["total", _total]
        ];
        [_cid, true, _payload] call a3mcp_fnc_sendAck;
    };
    default {
        [_cid, false, "未知的 op：" + _op] call _reply
    };
};
