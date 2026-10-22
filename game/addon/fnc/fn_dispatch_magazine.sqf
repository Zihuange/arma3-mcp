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
    case "magazinecargo": {
        // magazineCargo object
        private _p0 = _args param [0];
        _result = magazineCargo _p0;
    };
    case "magazines": {
        // magazines vehicle
        private _p0 = _args param [0];
        _result = magazines _p0;
    };
    case "magazines": {
        // magazines [vehicle, includeEmpty]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = magazines [_p0, _p1];
    };
    case "magazinesallturrets": {
        // magazinesAllTurrets vehicle
        private _p0 = _args param [0];
        magazinesAllTurrets _p0;
        _result = true;
    };
    case "magazinesammo": {
        // magazinesAmmo vehicle
        private _p0 = _args param [0];
        magazinesAmmo _p0;
        _result = true;
    };
    case "magazinesammo": {
        // magazinesAmmo [vehicle, includeEmpty]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        magazinesAmmo [_p0, _p1];
        _result = true;
    };
    case "magazinesammocargo": {
        // magazinesAmmoCargo vehicle
        private _p0 = _args param [0];
        _result = magazinesAmmoCargo _p0;
    };
    case "magazinesammofull": {
        // magazinesAmmoFull entity
        private _p0 = _args param [0];
        magazinesAmmoFull _p0;
        _result = true;
    };
    case "magazinesammofull": {
        // magazinesAmmoFull [vehicle, includeEmpty]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        magazinesAmmoFull [_p0, _p1];
        _result = true;
    };
    case "magazinesdetail": {
        // magazinesDetail vehicle
        private _p0 = _args param [0];
        _result = magazinesDetail _p0;
    };
    case "magazinesdetail": {
        // magazinesDetail [vehicle, includeEmpty, includeLoaded]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = magazinesDetail [_p0, _p1, _p2];
    };
    case "magazinesdetailbackpack": {
        // magazinesDetailBackpack unit
        private _p0 = _args param [0];
        _result = magazinesDetailBackpack _p0;
    };
    case "magazinesdetailbackpack": {
        // magazinesDetailBackpack [unit, includeEmpty, includeLoaded]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = magazinesDetailBackpack [_p0, _p1, _p2];
    };
    case "magazinesdetailuniform": {
        // magazinesDetailUniform unit
        private _p0 = _args param [0];
        _result = magazinesDetailUniform _p0;
    };
    case "magazinesdetailuniform": {
        // magazinesDetailUniform [unit, includeEmpty, includeLoaded]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = magazinesDetailUniform [_p0, _p1, _p2];
    };
    case "magazinesdetailvest": {
        // magazinesDetailVest unit
        private _p0 = _args param [0];
        _result = magazinesDetailVest _p0;
    };
    case "magazinesdetailvest": {
        // magazinesDetailVest [unit, includeEmpty, includeLoaded]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = magazinesDetailVest [_p0, _p1, _p2];
    };
    case "magazinesturret": {
        // vehicle magazinesTurret turretPath
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 magazinesTurret _p1;
        _result = true;
    };
    case "magazinesturret": {
        // vehicle magazinesTurret [turretPath, includeEmpty]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 magazinesTurret [_p1, _p2];
        _result = true;
    };
    case "magazineturretammo": {
        // vehicle magazineTurretAmmo [magazineClass, turretPath]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 magazineTurretAmmo [_p1, _p2];
    };
    default { _handled = false; };
};

[_handled, _result]
