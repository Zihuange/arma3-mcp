/* a3mcp_fnc_exec —— 执行一条来自 MCP 的命令

输入是 DLL 送来的 JSON 行：{"t":"cmd","cid":"...","cmd":"...","args":[...]}

分四类：
  exec            动态表达式（经 fn_validate 词法校验后用 compile 执行）
  configQuery     读取游戏内 config 树
  configOfEntity  从实体跳到它的 config
  uiQuery         界面控件查询（列类名 / 按类名找 / 整树快照 / 按钮 action）
  fnList          从 CfgFunctions 拼出可调用的函数名（call 的目标核对）

安全要点：表达式**必须**过 fn_validate 才允许编译。这里是第二道校验——
MCP 侧已经校验过一次，但"只做一处校验"的失效方式是静默的
（同类工程的 fn_sideGuard 注释里有同源结论）。

回执一律经 fn_ackJson 构造：不手写 JSON 转义（见该函数说明）。
*/
params [["_payload", "", [""]]];

private _job = [_payload] call a3mcp_fnc_jsonParse;

// fromJSON 对 JSON 对象返回的可能是 HashMap，也可能是 [键,值,...] 数组
// （不同版本表现不同）。两种都兼容——否则一旦猜错，所有命令都会失败，
// 而且失败原因看起来像"载荷格式不对"，会把人带偏。
private _fieldOf = {
    // ⚠ 不要给 _src 加类型约束 `[[]]`：那要求"必须是数组"，而 fromJSON 对
    // JSON 对象返回的是 **HashMap**，于是 params 会把入参拒掉、_src 退回
    // 默认值，cid 永远取不到 —— 表现为"命令执行了但回执 cid 为空"，
    // 上层永远匹配不上、只看到超时。类型约束在这里帮了倒忙。
    params [["_src", nil], ["_key", "", [""]], ["_default", nil]];
    if (_src isEqualType createHashMap) exitWith {
        _src getOrDefault [_key, _default]
    };
    if (_src isEqualType [] && { (_src find _key) >= 0 }) exitWith {
        _src select ((_src find _key) + 1)
    };
    _default
};

if (!(_job isEqualType createHashMap) && !(_job isEqualType [])) exitWith {
    diag_log format ["[A3MCP][ERR] 载荷无法解析为对象：%1", _payload];
    ["", false, "载荷无法解析为对象"] call a3mcp_fnc_sendAck;
    false
};

private _cid = ([_job, "cid", ""] call _fieldOf) + "";
private _type = toLower (([_job, "cmd", ""] call _fieldOf) + "");
private _args = [_job, "args", []] call _fieldOf;

// 输入注入 / 视觉捕捉：实现在 DLL 内，SQF 只做转发（见 fn_input 的说明）。
// 放在 switch 之前是因为它们不是"交给 SQF 执行"的命令。
if (_type in ["window_info", "input_move", "input_click", "input_drag",
              "input_key", "capture"]) exitWith {
    [_cid, _args, _type] call a3mcp_fnc_input;
    true
};

switch (_type) do {
    case "exec": {
        [_cid, _args] call a3mcp_fnc_run;
    };
    case "configquery": {
        [_cid, _args] call a3mcp_fnc_configQuery;
    };
    case "configofentity": {
        [_cid, _args] call a3mcp_fnc_configOfEntity;
    };
    case "uiquery": {
        [_cid, _args] call a3mcp_fnc_uiQuery;
    };
    case "fnlist": {
        [_cid, _args] call a3mcp_fnc_fnList;
    };
    default {
        [_cid, false, "未知的命令类型：" + _type] call a3mcp_fnc_sendAck;
    };
};
true
