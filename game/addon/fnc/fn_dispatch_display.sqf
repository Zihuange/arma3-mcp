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
    case "displayaddeventhandler": {
        // display displayAddEventHandler [eventName, code]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 displayAddEventHandler [_p1, _p2];
    };
    case "displaychild": {
        // displayChild display
        private _p0 = _args param [0];
        _result = displayChild _p0;
    };
    case "displayctrl": {
        // display displayCtrl idc
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 displayCtrl _p1;
    };
    case "displayctrl": {
        // displayCtrl idc
        private _p0 = _args param [0];
        _result = displayCtrl _p0;
    };
    case "displayparent": {
        // displayParent display
        private _p0 = _args param [0];
        _result = displayParent _p0;
    };
    case "displayremovealleventhandlers": {
        // display displayRemoveAllEventHandlers eventName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 displayRemoveAllEventHandlers _p1;
        _result = true;
    };
    case "displayremoveeventhandler": {
        // display displayRemoveEventHandler  [handlerType, id]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 displayRemoveEventHandler  [_p1, _p2];
        _result = true;
    };
    case "displayseteventhandler": {
        // display displaySetEventHandler [handlerName, function]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 displaySetEventHandler [_p1, _p2];
        _result = true;
    };
    case "displayuniquename": {
        // displayUniqueName display
        private _p0 = _args param [0];
        _result = displayUniqueName _p0;
    };
    case "displayupdate": {
        // displayUpdate display
        private _p0 = _args param [0];
        displayUpdate _p0;
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
