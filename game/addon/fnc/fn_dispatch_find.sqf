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
    case "find": {
        // array find element
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 find _p1;
    };
    case "find": {
        // string find substring
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 find _p1;
    };
    case "find": {
        // string find [substring, indexStart]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 find [_p1, _p2];
    };
    case "findany": {
        // searchIn findAny toFind
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 findAny _p1;
    };
    case "findcover": {
        // object findCover [position, hidePosition, maxDist, minDist, visibilityPosition, ignoreObject]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        _result = _p0 findCover [_p1, _p2, _p3, _p4, _p5, _p6];
    };
    case "finddisplay": {
        // findDisplay idd
        private _p0 = _args param [0];
        _result = findDisplay _p0;
    };
    case "finddisplay": {
        // findDisplay displayName
        private _p0 = _args param [0];
        _result = findDisplay _p0;
    };
    case "findeditorobject": {
        // map findEditorObject value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 findEditorObject _p1;
    };
    case "findemptyposition": {
        // center findEmptyPosition [areaRadius, maxDistance, vehicleType]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = _p0 findEmptyPosition [_p1, _p2, _p3];
    };
    case "findemptypositionready": {
        // center findEmptyPositionReady [radius, maxDistance]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 findEmptyPositionReady [_p1, _p2];
    };
    case "findif": {
        // array findIf code
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 findIf _p1;
    };
    case "findnearestenemy": {
        // object findNearestEnemy position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 findNearestEnemy _p1;
    };
    default { _handled = false; };
};

[_handled, _result]
