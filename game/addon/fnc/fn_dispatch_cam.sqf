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
    case "camcommand": {
        // camera camCommand command
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camCommand _p1;
        _result = true;
    };
    case "camcommit": {
        // camera camCommit time
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camCommit _p1;
        _result = true;
    };
    case "camcommitprepared": {
        // camera camCommitPrepared time
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camCommitPrepared _p1;
        _result = true;
    };
    case "camcommitted": {
        // camCommitted camera
        private _p0 = _args param [0];
        _result = camCommitted _p0;
    };
    case "camconstuctionsetparams": {
        // camera camConstuctionSetParams [position, radius, maxAboveLand]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 camConstuctionSetParams [_p1, _p2, _p3];
        _result = true;
    };
    case "camcreate": {
        // type camCreate position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 camCreate _p1;
    };
    case "camdestroy": {
        // camDestroy object
        private _p0 = _args param [0];
        camDestroy _p0;
        _result = true;
    };
    case "campreload": {
        // camera camPreload timeout
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camPreload _p1;
        _result = true;
    };
    case "campreloaded": {
        // camPreloaded camera
        private _p0 = _args param [0];
        _result = camPreloaded _p0;
    };
    case "campreparebank": {
        // camera camPrepareBank bank
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camPrepareBank _p1;
        _result = true;
    };
    case "campreparedir": {
        // camera camPrepareDir direction
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camPrepareDir _p1;
        _result = true;
    };
    case "campreparedive": {
        // camera camPrepareDive dive
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camPrepareDive _p1;
        _result = true;
    };
    case "campreparefocus": {
        // camera camPrepareFocus [distance, blur]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 camPrepareFocus [_p1, _p2];
        _result = true;
    };
    case "campreparefov": {
        // camera camPrepareFov fieldOfView
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camPrepareFov _p1;
        _result = true;
    };
    case "campreparefovrange": {
        // camera camPrepareFovRange fovRange
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camPrepareFovRange _p1;
        _result = true;
    };
    case "campreparepos": {
        // camera camPreparePos  position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camPreparePos  _p1;
        _result = true;
    };
    case "campreparerelpos": {
        // camera camPrepareRelPos position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camPrepareRelPos _p1;
        _result = true;
    };
    case "campreparetarget": {
        // camera camPrepareTarget position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camPrepareTarget _p1;
        _result = true;
    };
    case "campreparetarget": {
        // camera camPrepareTarget target
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camPrepareTarget _p1;
        _result = true;
    };
    case "camsetbank": {
        // camera camSetBank  bank
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camSetBank  _p1;
        _result = true;
    };
    case "camsetdir": {
        // camera camSetDir direction
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camSetDir _p1;
        _result = true;
    };
    case "camsetdive": {
        // camera camSetDive  dive
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camSetDive  _p1;
        _result = true;
    };
    case "camsetfocus": {
        // camera camSetFocus focusRange
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camSetFocus _p1;
        _result = true;
    };
    case "camsetfov": {
        // camera camSetFov level
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camSetFov _p1;
        _result = true;
    };
    case "camsetfovrange": {
        // camera camSetFovRange fovRange
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camSetFovRange _p1;
        _result = true;
    };
    case "camsetpos": {
        // camera camSetPos position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camSetPos _p1;
        _result = true;
    };
    case "camsetrelpos": {
        // camera camSetRelPos position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camSetRelPos _p1;
        _result = true;
    };
    case "camsettarget": {
        // camera camSetTarget target
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camSetTarget _p1;
        _result = true;
    };
    case "camsettarget": {
        // camera camSetTarget position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 camSetTarget _p1;
        _result = true;
    };
    case "camtarget": {
        // camTarget camera
        private _p0 = _args param [0];
        _result = camTarget _p0;
    };
    case "camusenvg": {
        // camUseNVG set
        private _p0 = _args param [0];
        camUseNVG _p0;
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
