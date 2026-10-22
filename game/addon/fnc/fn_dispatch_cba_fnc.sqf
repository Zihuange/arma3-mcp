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
    case "cba_fnc_addclasseventhandler": {
        // [_eventName,_eventFunc] call CBA_fnc_addClassEventHandler
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0,_p1] call CBA_fnc_addClassEventHandler;
    };
    case "cba_fnc_additemcontextmenuoption": {
        // [_displayName,_tooltip] call CBA_fnc_addItemContextMenuOption
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0,_p1] call CBA_fnc_addItemContextMenuOption;
    };
    case "cba_fnc_addperframehandler": {
        // [_args,_handle] call CBA_fnc_addPerFrameHandler
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0,_p1] call CBA_fnc_addPerFrameHandler;
    };
    case "cba_fnc_buildingpositions": {
        // [_max] call CBA_fnc_buildingPositions
        private _p0 = _args param [0];
        _result = [_p0] call CBA_fnc_buildingPositions;
    };
    case "cba_fnc_compilefunction": {
        // [_funcName] call CBA_fnc_compileFunction
        private _p0 = _args param [0];
        _result = [_p0] call CBA_fnc_compileFunction;
    };
    case "cba_fnc_debug": {
        // [_useChat,_useLog,_global] call CBA_fnc_debug
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0,_p1,_p2] call CBA_fnc_debug;
    };
    default { _handled = false; };
};

[_handled, _result]
