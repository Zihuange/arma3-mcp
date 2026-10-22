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
    case "show3dicons": {
        // map show3DIcons bool
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 show3DIcons _p1;
        _result = true;
    };
    case "showchat": {
        // showChat bool
        private _p0 = _args param [0];
        showChat _p0;
        _result = true;
    };
    case "showcinemaborder": {
        // showCinemaBorder show
        private _p0 = _args param [0];
        showCinemaBorder _p0;
        _result = true;
    };
    case "showcommandingmenu": {
        // showCommandingMenu name
        private _p0 = _args param [0];
        showCommandingMenu _p0;
        _result = true;
    };
    case "showcompass": {
        // showCompass show
        private _p0 = _args param [0];
        showCompass _p0;
        _result = true;
    };
    case "showcuratorcompass": {
        // showCuratorCompass bool
        private _p0 = _args param [0];
        showCuratorCompass _p0;
        _result = true;
    };
    case "showgps": {
        // showGPS show
        private _p0 = _args param [0];
        showGPS _p0;
        _result = true;
    };
    case "showhud": {
        // showHUD enable
        private _p0 = _args param [0];
        showHUD _p0;
        _result = true;
    };
    case "showhud": {
        // showHUD [scriptedHUD, info, radar, compass, direction, menu, group, cursors, panels, kills, showIcon3D]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        private _p7 = _args param [7];
        private _p8 = _args param [8];
        private _p9 = _args param [9];
        private _p10 = _args param [10];
        showHUD [_p0, _p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, _p9, _p10];
        _result = true;
    };
    case "showlegend": {
        // map showLegend bool
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 showLegend _p1;
        _result = true;
    };
    case "showmap": {
        // showMap show
        private _p0 = _args param [0];
        showMap _p0;
        _result = true;
    };
    case "showpad": {
        // showPad show
        private _p0 = _args param [0];
        showPad _p0;
        _result = true;
    };
    case "showradio": {
        // showRadio show
        private _p0 = _args param [0];
        showRadio _p0;
        _result = true;
    };
    case "showscoretable": {
        // showScoretable force
        private _p0 = _args param [0];
        showScoretable _p0;
        _result = true;
    };
    case "showsubtitles": {
        // showSubtitles enable
        private _p0 = _args param [0];
        _result = showSubtitles _p0;
    };
    case "showuavfeed": {
        // showUAVFeed show
        private _p0 = _args param [0];
        _result = showUAVFeed _p0;
    };
    case "showwarrant": {
        // showWarrant show
        private _p0 = _args param [0];
        showWarrant _p0;
        _result = true;
    };
    case "showwatch": {
        // showWatch show
        private _p0 = _args param [0];
        showWatch _p0;
        _result = true;
    };
    case "showwaypoint": {
        // waypoint showWaypoint show
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 showWaypoint _p1;
        _result = true;
    };
    case "showwaypoints": {
        // showWaypoints enabled
        private _p0 = _args param [0];
        showWaypoints _p0;
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
