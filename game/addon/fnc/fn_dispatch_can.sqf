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
    case "canadd": {
        // object canAdd item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 canAdd _p1;
    };
    case "canadd": {
        // object canAdd [item, count]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 canAdd [_p1, _p2];
    };
    case "canadd": {
        // weapon canAdd item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 canAdd _p1;
    };
    case "canadd": {
        // weapon canAdd [attachment, slot]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 canAdd [_p1, _p2];
    };
    case "canadd": {
        // weapon canAdd [magazine, muzzle]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 canAdd [_p1, _p2];
    };
    case "canadditemtobackpack": {
        // unit canAddItemToBackpack item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 canAddItemToBackpack _p1;
    };
    case "canadditemtobackpack": {
        // unit canAddItemToBackpack [item, count]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 canAddItemToBackpack [_p1, _p2];
    };
    case "canadditemtouniform": {
        // unit canAddItemToUniform item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 canAddItemToUniform _p1;
    };
    case "canadditemtouniform": {
        // unit canAddItemToUniform [item, count]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 canAddItemToUniform [_p1, _p2];
    };
    case "canadditemtovest": {
        // unit canAddItemToVest item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 canAddItemToVest _p1;
    };
    case "canadditemtovest": {
        // unit canAddItemToVest [item, count]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 canAddItemToVest [_p1, _p2];
    };
    case "cancelsimpletaskdestination": {
        // cancelSimpleTaskDestination task
        private _p0 = _args param [0];
        cancelSimpleTaskDestination _p0;
        _result = true;
    };
    case "candeployweapon": {
        // canDeployWeapon unit
        private _p0 = _args param [0];
        _result = canDeployWeapon _p0;
    };
    case "canfire": {
        // canFire unitName
        private _p0 = _args param [0];
        _result = canFire _p0;
    };
    case "canmove": {
        // canMove vehicle
        private _p0 = _args param [0];
        _result = canMove _p0;
    };
    case "canslingload": {
        // heli canSlingLoad cargo
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 canSlingLoad _p1;
    };
    case "canslingload": {
        // typeOfHeli canSlingLoad typeOfCargo
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 canSlingLoad _p1;
    };
    case "canstand": {
        // canStand unit
        private _p0 = _args param [0];
        _result = canStand _p0;
    };
    case "cantriggerdynamicsimulation": {
        // canTriggerDynamicSimulation unit
        private _p0 = _args param [0];
        _result = canTriggerDynamicSimulation _p0;
    };
    case "canunloadincombat": {
        // canUnloadInCombat vehicle
        private _p0 = _args param [0];
        _result = canUnloadInCombat _p0;
    };
    case "canvehiclecargo": {
        // vehicle canVehicleCargo cargo
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 canVehicleCargo _p1;
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
