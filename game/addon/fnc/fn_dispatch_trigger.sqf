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
    case "triggeractivated": {
        // triggerActivated trigger
        private _p0 = _args param [0];
        _result = triggerActivated _p0;
    };
    case "triggeractivation": {
        // triggerActivation trigger
        private _p0 = _args param [0];
        _result = triggerActivation _p0;
    };
    case "triggerammo": {
        // triggerAmmo munition
        private _p0 = _args param [0];
        triggerAmmo _p0;
        _result = true;
    };
    case "triggerarea": {
        // triggerArea trigger
        private _p0 = _args param [0];
        triggerArea _p0;
        _result = true;
    };
    case "triggerattachedvehicle": {
        // triggerAttachedVehicle trigger
        private _p0 = _args param [0];
        _result = triggerAttachedVehicle _p0;
    };
    case "triggerattachobject": {
        // triggerName triggerAttachObject objectId
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 triggerAttachObject _p1;
        _result = true;
    };
    case "triggerattachvehicle": {
        // triggerName triggerAttachVehicle objects
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 triggerAttachVehicle _p1;
        _result = true;
    };
    case "triggerdynamicsimulation": {
        // unit triggerDynamicSimulation trigger
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 triggerDynamicSimulation _p1;
        _result = true;
    };
    case "triggerinterval": {
        // triggerInterval trigger
        private _p0 = _args param [0];
        _result = triggerInterval _p0;
    };
    case "triggerstatements": {
        // triggerStatements trigger
        private _p0 = _args param [0];
        triggerStatements _p0;
        _result = true;
    };
    case "triggertext": {
        // triggerText trigger
        private _p0 = _args param [0];
        _result = triggerText _p0;
    };
    case "triggertimeout": {
        // triggerTimeout trigger
        private _p0 = _args param [0];
        _result = triggerTimeout _p0;
    };
    case "triggertimeoutcurrent": {
        // triggerTimeoutCurrent trigger
        private _p0 = _args param [0];
        _result = triggerTimeoutCurrent _p0;
    };
    case "triggertype": {
        // triggerType trigger
        private _p0 = _args param [0];
        _result = triggerType _p0;
    };
    default { _handled = false; };
};

[_handled, _result]
