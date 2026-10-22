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
    case "attachedobject": {
        // attachedObject location
        private _p0 = _args param [0];
        _result = attachedObject _p0;
    };
    case "attachedobjects": {
        // attachedObjects obj
        private _p0 = _args param [0];
        attachedObjects _p0;
        _result = true;
    };
    case "attachedto": {
        // attachedTo obj
        private _p0 = _args param [0];
        _result = attachedTo _p0;
    };
    case "attachobject": {
        // location attachObject object
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 attachObject _p1;
        _result = true;
    };
    case "attachto": {
        // object1 attachTo [object2, offset, memPoint, followBoneRotation]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _p0 attachTo [_p1, _p2, _p3, _p4];
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
