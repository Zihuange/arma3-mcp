/* 自动生成 —— 请勿手工编辑。
 *
 * 来源：tools/gen_dispatch.py（从命令库签名还原调用形式）
 * 生成的原则：只产出**静态**分发，不使用 compile/execVM —— 见 README 的安全模型。
 *
 * 参数：_fn 目标函数名、_args 参数数组（已由 MCP 侧校验类型）
 * 返回：[是否处理, 结果]
 */
params ["_fn", "_args"];
private _handled = true;
private _result = nil;

switch (toLower _fn) do {
    case "group": {
        // group object
        private _p0 = _args param [0];
        _result = group _p0;
    };
    case "groupchat": {
        // unitName groupChat chatText
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 groupChat _p1;
        _result = true;
    };
    case "groupfromnetid": {
        // groupFromNetId id
        private _p0 = _args param [0];
        _result = groupFromNetId _p0;
    };
    case "groupid": {
        // groupId group
        private _p0 = _args param [0];
        _result = groupId _p0;
    };
    case "groupid": {
        // groupId unit
        private _p0 = _args param [0];
        _result = groupId _p0;
    };
    case "groupowner": {
        // groupOwner group
        private _p0 = _args param [0];
        _result = groupOwner _p0;
    };
    case "groupradio": {
        // unit groupRadio  radioName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 groupRadio  _p1;
        _result = true;
    };
    case "groups": {
        // groups side
        private _p0 = _args param [0];
        groups _p0;
        _result = true;
    };
    case "groupselectedunits": {
        // groupSelectedUnits unit
        private _p0 = _args param [0];
        _result = groupSelectedUnits _p0;
    };
    case "groupselectunit": {
        // player groupSelectUnit [unit, select]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 groupSelectUnit [_p1, _p2];
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
