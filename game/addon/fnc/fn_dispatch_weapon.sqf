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
    case "weaponaccessories": {
        // unit weaponAccessories weapon
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 weaponAccessories _p1;
    };
    case "weaponaccessoriescargo": {
        // container weaponAccessoriesCargo [weaponId, creatorId]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 weaponAccessoriesCargo [_p1, _p2];
    };
    case "weaponcargo": {
        // weaponCargo box
        private _p0 = _args param [0];
        weaponCargo _p0;
        _result = true;
    };
    case "weapondirection": {
        // vehicleName weaponDirection weaponName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 weaponDirection _p1;
    };
    case "weaponinertia": {
        // weaponInertia unit
        private _p0 = _args param [0];
        _result = weaponInertia _p0;
    };
    case "weaponlowered": {
        // weaponLowered unit
        private _p0 = _args param [0];
        _result = weaponLowered _p0;
    };
    case "weaponreloadingtime": {
        // vehicle weaponReloadingTime [gunner, muzzleName]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 weaponReloadingTime [_p1, _p2];
    };
    case "weapons": {
        // weapons unit
        private _p0 = _args param [0];
        weapons _p0;
        _result = true;
    };
    case "weaponsinfo": {
        // unit weaponsInfo [weaponOrMuzzle, onlyLoaded]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 weaponsInfo [_p1, _p2];
        _result = true;
    };
    case "weaponsitems": {
        // weaponsItems vehicle
        private _p0 = _args param [0];
        _result = weaponsItems _p0;
    };
    case "weaponsitemscargo": {
        // weaponsItemsCargo vehicle
        private _p0 = _args param [0];
        _result = weaponsItemsCargo _p0;
    };
    case "weaponstate": {
        // weaponState unit
        private _p0 = _args param [0];
        weaponState _p0;
        _result = true;
    };
    case "weaponstate": {
        // weaponState [vehicle, turretPath, weapon, muzzle, firemode]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        weaponState [_p0, _p1, _p2, _p3, _p4];
        _result = true;
    };
    case "weaponstate": {
        // unit weaponState weaponOrMuzzle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 weaponState _p1;
        _result = true;
    };
    case "weaponsturret": {
        // vehicle weaponsTurret turretPath
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 weaponsTurret _p1;
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
