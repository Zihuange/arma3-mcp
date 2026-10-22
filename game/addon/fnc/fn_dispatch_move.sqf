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
    case "move": {
        // group move position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 move _p1;
        _result = true;
    };
    case "move3dencamera": {
        // move3DENCamera  [position, useOffset]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        move3DENCamera  [_p0, _p1];
        _result = true;
    };
    case "moveinany": {
        // unit moveInAny vehicle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 moveInAny _p1;
    };
    case "moveincargo": {
        // unit moveInCargo vehicle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 moveInCargo _p1;
        _result = true;
    };
    case "moveincargo": {
        // unit moveInCargo [vehicle, cargoIndex, canReassign]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 moveInCargo [_p1, _p2, _p3];
        _result = true;
    };
    case "moveincommander": {
        // unitName moveInCommander vehicle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 moveInCommander _p1;
        _result = true;
    };
    case "moveindriver": {
        // unit moveInDriver vehicle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 moveInDriver _p1;
        _result = true;
    };
    case "moveingunner": {
        // unitName moveInGunner vehicle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 moveInGunner _p1;
        _result = true;
    };
    case "moveinturret": {
        // unitName moveInTurret  [vehicle, turretPath]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 moveInTurret  [_p1, _p2];
        _result = true;
    };
    case "moveobjecttoend": {
        // map moveObjectToEnd object
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 moveObjectToEnd _p1;
        _result = true;
    };
    case "moveout": {
        // moveOut soldier
        private _p0 = _args param [0];
        moveOut _p0;
        _result = true;
    };
    case "moveout": {
        // soldier moveOut vehicle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 moveOut _p1;
        _result = true;
    };
    case "movetarget": {
        // target moveTarget [position, typeAccuracy, posAccuracy]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = _p0 moveTarget [_p1, _p2, _p3];
    };
    case "movetime": {
        // moveTime soldier
        private _p0 = _args param [0];
        _result = moveTime _p0;
    };
    case "moveto": {
        // unit moveTo position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 moveTo _p1;
        _result = true;
    };
    case "movetocompleted": {
        // moveToCompleted  person
        private _p0 = _args param [0];
        _result = moveToCompleted  _p0;
    };
    case "movetofailed": {
        // moveToFailed unit
        private _p0 = _args param [0];
        _result = moveToFailed _p0;
    };
    default { _handled = false; };
};

[_handled, _result]
