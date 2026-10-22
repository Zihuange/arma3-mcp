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
    case "action": {
        // unit action actionArray
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 action _p1;
        _result = true;
    };
    case "action": {
        // action actionArray
        private _p0 = _args param [0];
        action _p0;
        _result = true;
    };
    case "actionids": {
        // actionIDs entity
        private _p0 = _args param [0];
        _result = actionIDs _p0;
    };
    case "actionkeys": {
        // actionKeys userAction
        private _p0 = _args param [0];
        actionKeys _p0;
        _result = true;
    };
    case "actionkeys": {
        // actionKeys [userAction]
        private _p0 = _args param [0];
        actionKeys [_p0];
        _result = true;
    };
    case "actionkeysex": {
        // actionKeysEx userAction
        private _p0 = _args param [0];
        actionKeysEx _p0;
        _result = true;
    };
    case "actionkeysimages": {
        // actionKeysImages userAction
        private _p0 = _args param [0];
        actionKeysImages _p0;
        _result = true;
    };
    case "actionkeysimages": {
        // actionKeysImages [userAction, maxKeys]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        actionKeysImages [_p0, _p1];
        _result = true;
    };
    case "actionkeysnames": {
        // actionKeysNames  userAction
        private _p0 = _args param [0];
        _result = actionKeysNames  _p0;
    };
    case "actionkeysnames": {
        // actionKeysNames  [userAction, maxKeys, inputDevicePriority]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = actionKeysNames  [_p0, _p1, _p2];
    };
    case "actionkeysnamesarray": {
        // actionKeysNamesArray  userAction
        private _p0 = _args param [0];
        _result = actionKeysNamesArray  _p0;
    };
    case "actionkeysnamesarray": {
        // actionKeysNamesArray  [userAction, maxKeys, inputDevicePriority]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        actionKeysNamesArray  [_p0, _p1, _p2];
        _result = true;
    };
    case "actionname": {
        // actionName action
        private _p0 = _args param [0];
        _result = actionName _p0;
    };
    case "actionparams": {
        // entity actionParams id
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 actionParams _p1;
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
