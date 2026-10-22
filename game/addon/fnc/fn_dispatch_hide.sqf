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
    case "hidebehindscripted": {
        // object hideBehindScripted scriptedHideBehind
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 hideBehindScripted _p1;
        _result = true;
    };
    case "hidebody": {
        // hideBody unit
        private _p0 = _args param [0];
        hideBody _p0;
        _result = true;
    };
    case "hideobject": {
        // hideObject object
        private _p0 = _args param [0];
        hideObject _p0;
        _result = true;
    };
    case "hideobject": {
        // object hideObject hidden
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 hideObject _p1;
        _result = true;
    };
    case "hideobjectglobal": {
        // hideObjectGlobal object
        private _p0 = _args param [0];
        hideObjectGlobal _p0;
        _result = true;
    };
    case "hideobjectglobal": {
        // object hideObjectGlobal  hidden
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 hideObjectGlobal  _p1;
        _result = true;
    };
    case "hideselection": {
        // object hideSelection [selection, hidden]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 hideSelection [_p1, _p2];
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
