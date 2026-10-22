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
    case "vectoradd": {
        // vector1 vectorAdd vector2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 vectorAdd _p1;
    };
    case "vectorcos": {
        // vector1 vectorCos vector2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 vectorCos _p1;
    };
    case "vectorcrossproduct": {
        // vector1 vectorCrossProduct vector2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 vectorCrossProduct _p1;
        _result = true;
    };
    case "vectordiff": {
        // vector1 vectorDiff vector2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 vectorDiff _p1;
    };
    case "vectordir": {
        // vectorDir object
        private _p0 = _args param [0];
        _result = vectorDir _p0;
    };
    case "vectordirvisual": {
        // vectorDirVisual objectName
        private _p0 = _args param [0];
        _result = vectorDirVisual _p0;
    };
    case "vectordistance": {
        // point1 vectorDistance point2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 vectorDistance _p1;
    };
    case "vectordistancesqr": {
        // vector1 vectorDistanceSqr vector2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 vectorDistanceSqr _p1;
    };
    case "vectordotproduct": {
        // vector1 vectorDotProduct vector2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 vectorDotProduct _p1;
    };
    case "vectorfromto": {
        // vector1 vectorFromTo vector2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 vectorFromTo _p1;
    };
    case "vectorlinearconversion": {
        // vectorLinearConversion [rangeFrom, rangeTo, rangeValue, vectorFrom, vectorTo, clip]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _result = vectorLinearConversion [_p0, _p1, _p2, _p3, _p4, _p5];
    };
    case "vectormagnitude": {
        // vectorMagnitude vector
        private _p0 = _args param [0];
        _result = vectorMagnitude _p0;
    };
    case "vectormagnitudesqr": {
        // vectorMagnitudeSqr vector
        private _p0 = _args param [0];
        _result = vectorMagnitudeSqr _p0;
    };
    case "vectormodeltoworld": {
        // object vectorModelToWorld modelDir
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 vectorModelToWorld _p1;
    };
    case "vectormodeltoworldvisual": {
        // object vectorModelToWorldVisual modelDir
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 vectorModelToWorldVisual _p1;
    };
    case "vectormultiply": {
        // vector vectorMultiply scalar
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 vectorMultiply _p1;
    };
    case "vectornormalized": {
        // vectorNormalized vector
        private _p0 = _args param [0];
        _result = vectorNormalized _p0;
    };
    case "vectorup": {
        // vectorUp object
        private _p0 = _args param [0];
        _result = vectorUp _p0;
    };
    case "vectorupvisual": {
        // vectorUpVisual objectName
        private _p0 = _args param [0];
        _result = vectorUpVisual _p0;
    };
    case "vectorworldtomodel": {
        // object vectorWorldToModel worldDir
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 vectorWorldToModel _p1;
    };
    case "vectorworldtomodelvisual": {
        // object vectorWorldToModelVisual worldDir
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 vectorWorldToModelVisual _p1;
    };
    default { _handled = false; };
};

[_handled, _result]
