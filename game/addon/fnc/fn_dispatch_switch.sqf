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
    case "switch": {
        // switch value
        private _p0 = _args param [0];
        switch _p0;
        _result = true;
    };
    case "switchaction": {
        // soldier switchAction action
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 switchAction _p1;
        _result = true;
    };
    case "switchcamera": {
        // target switchCamera mode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 switchCamera _p1;
        _result = true;
    };
    case "switchcamera": {
        // switchCamera target
        private _p0 = _args param [0];
        switchCamera _p0;
        _result = true;
    };
    case "switchgesture": {
        // soldier switchGesture moveName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 switchGesture _p1;
        _result = true;
    };
    case "switchlight": {
        // lamp switchLight mode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 switchLight _p1;
        _result = true;
    };
    case "switchmove": {
        // person switchMove moveName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 switchMove _p1;
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
