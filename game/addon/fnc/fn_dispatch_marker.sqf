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
    case "markeralpha": {
        // markerAlpha markerName
        private _p0 = _args param [0];
        _result = markerAlpha _p0;
    };
    case "markerbrush": {
        // markerBrush name
        private _p0 = _args param [0];
        _result = markerBrush _p0;
    };
    case "markerchannel": {
        // markerChannel marker
        private _p0 = _args param [0];
        _result = markerChannel _p0;
    };
    case "markercolor": {
        // markerColor markerName
        private _p0 = _args param [0];
        _result = markerColor _p0;
    };
    case "markerdir": {
        // markerDir markerName
        private _p0 = _args param [0];
        _result = markerDir _p0;
    };
    case "markerpolyline": {
        // markerPolyline marker
        private _p0 = _args param [0];
        markerPolyline _p0;
        _result = true;
    };
    case "markerpos": {
        // markerPos markerName
        private _p0 = _args param [0];
        _result = markerPos _p0;
    };
    case "markerpos": {
        // markerPos [markerName, preserveElevation]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = markerPos [_p0, _p1];
    };
    case "markershadow": {
        // markerShadow marker
        private _p0 = _args param [0];
        markerShadow _p0;
        _result = true;
    };
    case "markershape": {
        // markerShape  name
        private _p0 = _args param [0];
        markerShape  _p0;
        _result = true;
    };
    case "markersize": {
        // markerSize markerName
        private _p0 = _args param [0];
        markerSize _p0;
        _result = true;
    };
    case "markertext": {
        // markerText markerName
        private _p0 = _args param [0];
        _result = markerText _p0;
    };
    case "markertype": {
        // markerType  markerName
        private _p0 = _args param [0];
        _result = markerType  _p0;
    };
    default { _handled = false; };
};

[_handled, _result]
