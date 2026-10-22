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
    case "diag_captureframe": {
        // diag_captureFrame frame
        private _p0 = _args param [0];
        diag_captureFrame _p0;
        _result = true;
    };
    case "diag_captureframetofile": {
        // diag_captureFrameToFile  frame
        private _p0 = _args param [0];
        diag_captureFrameToFile  _p0;
        _result = true;
    };
    case "diag_captureslowframe": {
        // diag_captureSlowFrame [section, threshold]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        diag_captureSlowFrame [_p0, _p1];
        _result = true;
    };
    case "diag_codeperformance": {
        // diag_codePerformance [code, arguments, cycles]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        diag_codePerformance [_p0, _p1, _p2];
        _result = true;
    };
    case "diag_drawmode": {
        // diag_drawMode type
        private _p0 = _args param [0];
        diag_drawMode _p0;
        _result = true;
    };
    case "diag_dumpscriptassembly": {
        // diag_dumpScriptAssembly  code
        private _p0 = _args param [0];
        diag_dumpScriptAssembly  _p0;
        _result = true;
    };
    case "diag_dynamicsimulationend": {
        // diag_dynamicSimulationEnd file
        private _p0 = _args param [0];
        diag_dynamicSimulationEnd _p0;
        _result = true;
    };
    case "diag_enable": {
        // mode diag_enable  state
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 diag_enable  _p1;
        _result = true;
    };
    case "diag_enabled": {
        // diag_enabled  mode
        private _p0 = _args param [0];
        _result = diag_enabled  _p0;
    };
    case "diag_exportconfig": {
        // diag_exportConfig [path, config]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        diag_exportConfig [_p0, _p1];
        _result = true;
    };
    case "diag_exportterrainsvg": {
        // diag_exportTerrainSVG [filePath, drawLocationNames, drawGrid, drawCountlines, drawTreeObjects, drawMountainHeightpoints, simpleRoads]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        diag_exportTerrainSVG [_p0, _p1, _p2, _p3, _p4, _p5, _p6];
        _result = true;
    };
    case "diag_getterrainheight": {
        // diag_getTerrainHeight positionWorld
        private _p0 = _args param [0];
        _result = diag_getTerrainHeight _p0;
    };
    case "diag_getterrainsegmentoffset": {
        // diag_getTerrainSegmentOffset  PositionWorld
        private _p0 = _args param [0];
        diag_getTerrainSegmentOffset  _p0;
        _result = true;
    };
    case "diag_lightnewload": {
        // diag_lightNewLoad path
        private _p0 = _args param [0];
        diag_lightNewLoad _p0;
        _result = true;
    };
    case "diag_list": {
        // diag_list  mode
        private _p0 = _args param [0];
        _result = diag_list  _p0;
    };
    case "diag_localized": {
        // diag_localized stringtable
        private _p0 = _args param [0];
        _result = diag_localized _p0;
    };
    case "diag_log": {
        // diag_log  output
        private _p0 = _args param [0];
        diag_log  _p0;
        _result = true;
    };
    case "diag_logslowframe": {
        // diag_logSlowFrame [section, threshold]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        diag_logSlowFrame [_p0, _p1];
        _result = true;
    };
    case "diag_mergeconfigfile": {
        // diag_mergeConfigFile  [path, userdir]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        diag_mergeConfigFile  [_p0, _p1];
        _result = true;
    };
    case "diag_recordturretlimits": {
        // diag_recordTurretLimits section
        private _p0 = _args param [0];
        diag_recordTurretLimits _p0;
        _result = true;
    };
    case "diag_setlightnew": {
        // diag_setLightNew config
        private _p0 = _args param [0];
        diag_setLightNew _p0;
        _result = true;
    };
    case "diag_setterrainheight": {
        // position diag_setTerrainHeight height
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 diag_setTerrainHeight _p1;
        _result = true;
    };
    case "diag_toggle": {
        // diag_toggle mode
        private _p0 = _args param [0];
        diag_toggle _p0;
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
