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
    case "nearestbuilding": {
        // nearestBuilding position
        private _p0 = _args param [0];
        _result = nearestBuilding _p0;
    };
    case "nearestlocation": {
        // nearestLocation [position, locationClass]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = nearestLocation [_p0, _p1];
    };
    case "nearestlocationwithdubbing": {
        // nearestLocationWithDubbing position
        private _p0 = _args param [0];
        _result = nearestLocationWithDubbing _p0;
    };
    case "nearestobject": {
        // nearestObject [position, type]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = nearestObject [_p0, _p1];
    };
    case "nearestobject": {
        // nearestObject position
        private _p0 = _args param [0];
        _result = nearestObject _p0;
    };
    case "nearestobject": {
        // position nearestObject typeOrId
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 nearestObject _p1;
    };
    case "nearestobject": {
        // position nearestObject id
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 nearestObject _p1;
    };
    default { _handled = false; };
};

[_handled, _result]
