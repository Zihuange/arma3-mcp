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
    case "disableai": {
        // unit disableAI feature
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 disableAI _p1;
        _result = true;
    };
    case "disablebrakes": {
        // transport disableBrakes disable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 disableBrakes _p1;
        _result = true;
    };
    case "disablecollisionwith": {
        // vehicle1 disableCollisionWith vehicle2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 disableCollisionWith _p1;
        _result = true;
    };
    case "disableconversation": {
        // unitName disableConversation  disable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 disableConversation  _p1;
        _result = true;
    };
    case "disablemapindicators": {
        // disableMapIndicators  [disableFriendly, disableEnemy, disableMines, disablePing]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        disableMapIndicators  [_p0, _p1, _p2, _p3];
        _result = true;
    };
    case "disablenvgequipment": {
        // vehicle disableNVGEquipment state
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 disableNVGEquipment _p1;
        _result = true;
    };
    case "disableremotesensors": {
        // disableRemoteSensors state
        private _p0 = _args param [0];
        disableRemoteSensors _p0;
        _result = true;
    };
    case "disabletiequipment": {
        // vehicle disableTIEquipment state
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 disableTIEquipment _p1;
        _result = true;
    };
    case "disableuavconnectability": {
        // object disableUAVConnectability [uav, checkAllItems]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 disableUAVConnectability [_p1, _p2];
        _result = true;
    };
    case "disableuserinput": {
        // disableUserInput state
        private _p0 = _args param [0];
        disableUserInput _p0;
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
