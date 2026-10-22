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
    case "drawarrow": {
        // map drawArrow [from, to, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 drawArrow [_p1, _p2, _p3];
        _result = true;
    };
    case "drawellipse": {
        // map drawEllipse [centre, a, b, angle, color, fill]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        _p0 drawEllipse [_p1, _p2, _p3, _p4, _p5, _p6];
        _result = true;
    };
    case "drawicon": {
        // map drawIcon [texture, color, position, width, height, angle, text, shadow, textSize, font, align, drawSideArrows, offsetX, offsetY]
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
        private _p11 = _args param [11];
        _p0 drawIcon [_p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, _p9, _p10, _p11, drawSideArrows, offsetX, offsetY];
        _result = true;
    };
    case "drawicon3d": {
        // drawIcon3D [texture, color, position, width, height, angle, text, shadow, textSize, font, textAlign, drawSideArrows, offsetX, offsetY]
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
        private _p11 = _args param [11];
        private _p12 = _args param [12];
        private _p13 = _args param [13];
        drawIcon3D [_p0, _p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, _p9, _p10, _p11, _p12, _p13];
        _result = true;
    };
    case "drawlaser": {
        // drawLaser [position, direction, beamColor, dotColor, dotSize, beamThickness, beamMaxLength, isIR]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        private _p7 = _args param [7];
        drawLaser [_p0, _p1, _p2, _p3, _p4, _p5, _p6, _p7];
        _result = true;
    };
    case "drawline": {
        // map drawLine [from, to, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 drawLine [_p1, _p2, _p3];
        _result = true;
    };
    case "drawline3d": {
        // drawLine3D [start, end, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        drawLine3D [_p0, _p1, _p2];
        _result = true;
    };
    case "drawlocation": {
        // control drawLocation location
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 drawLocation _p1;
        _result = true;
    };
    case "drawpolygon": {
        // map drawPolygon [polygon, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 drawPolygon [_p1, _p2];
        _result = true;
    };
    case "drawrectangle": {
        // map drawRectangle  [centre, halfWidth, halfHeight, angle, color, fill]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        _p0 drawRectangle  [_p1, _p2, _p3, _p4, _p5, _p6];
        _result = true;
    };
    case "drawtriangle": {
        // map drawTriangle [vertices, color, fill]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 drawTriangle [_p1, _p2, _p3];
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
