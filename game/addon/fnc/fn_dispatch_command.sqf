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
    case "commandartilleryfire": {
        // unit commandArtilleryFire [position, type, rounds]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 commandArtilleryFire [_p1, _p2, _p3];
        _result = true;
    };
    case "commandchat": {
        // unitName commandChat chatText
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 commandChat _p1;
        _result = true;
    };
    case "commandchat": {
        // [side, identity] commandChat chatText
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1] commandChat _p2;
        _result = true;
    };
    case "commander": {
        // commander  vehicle
        private _p0 = _args param [0];
        _result = commander  _p0;
    };
    case "commandfire": {
        // unitName commandFire target
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 commandFire _p1;
        _result = true;
    };
    case "commandfollow": {
        // unit commandFollow unitLead
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 commandFollow _p1;
        _result = true;
    };
    case "commandfsm": {
        // unitName commandFSM [fsmFile, position, target]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 commandFSM [_p1, _p2, _p3];
        _result = true;
    };
    case "commandmove": {
        // unitName commandMove  position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 commandMove  _p1;
        _result = true;
    };
    case "commandradio": {
        // unit commandRadio radioName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 commandRadio _p1;
        _result = true;
    };
    case "commandradio": {
        // [side, identity] commandRadio radioName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1] commandRadio _p2;
        _result = true;
    };
    case "commandstop": {
        // commandStop  target
        private _p0 = _args param [0];
        commandStop  _p0;
        _result = true;
    };
    case "commandsuppressivefire": {
        // unit commandSuppressiveFire target
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 commandSuppressiveFire _p1;
        _result = true;
    };
    case "commandtarget": {
        // unit commandTarget target
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 commandTarget _p1;
        _result = true;
    };
    case "commandwatch": {
        // units commandWatch position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 commandWatch _p1;
        _result = true;
    };
    case "commandwatch": {
        // units commandWatch target
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 commandWatch _p1;
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
