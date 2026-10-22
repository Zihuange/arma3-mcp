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
    case "do": {
        // construct do code
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 do _p1;
    };
    case "do3denaction": {
        // do3DENAction  action
        private _p0 = _args param [0];
        do3DENAction  _p0;
        _result = true;
    };
    case "doartilleryfire": {
        // unit doArtilleryFire [position, type, rounds]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 doArtilleryFire [_p1, _p2, _p3];
        _result = true;
    };
    case "dofire": {
        // unitName doFire target
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 doFire _p1;
        _result = true;
    };
    case "dofollow": {
        // unit doFollow unitLead
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 doFollow _p1;
        _result = true;
    };
    case "dofsm": {
        // unit doFSM  [fsmName, position, target]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 doFSM  [_p1, _p2, _p3];
        _result = true;
    };
    case "dogetout": {
        // doGetOut units
        private _p0 = _args param [0];
        doGetOut _p0;
        _result = true;
    };
    case "doorphase": {
        // object doorPhase door
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 doorPhase _p1;
    };
    case "dosuppressivefire": {
        // unit doSuppressiveFire  target
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 doSuppressiveFire  _p1;
        _result = true;
    };
    case "dotarget": {
        // unit doTarget target
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 doTarget _p1;
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
