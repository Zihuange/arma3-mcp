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
    case "cameraeffect": {
        // camera cameraEffect [effectName, effectPosition, r2tName]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 cameraEffect [_p1, _p2, _p3];
        _result = true;
    };
    case "cameraeffectenablehud": {
        // cameraEffectEnableHUD enable
        private _p0 = _args param [0];
        cameraEffectEnableHUD _p0;
        _result = true;
    };
    case "camerainterest": {
        // cameraInterest entity
        private _p0 = _args param [0];
        _result = cameraInterest _p0;
    };
    default { _handled = false; };
};

[_handled, _result]
