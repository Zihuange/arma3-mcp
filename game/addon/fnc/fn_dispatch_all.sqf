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
    case "allcontrols": {
        // allControls display
        private _p0 = _args param [0];
        allControls _p0;
        _result = true;
    };
    case "allcontrols": {
        // allControls controlsGroup
        private _p0 = _args param [0];
        allControls _p0;
        _result = true;
    };
    case "alldiaryrecords": {
        // person allDiaryRecords subject
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 allDiaryRecords _p1;
        _result = true;
    };
    case "alldiarysubjects": {
        // allDiarySubjects person
        private _p0 = _args param [0];
        allDiarySubjects _p0;
        _result = true;
    };
    case "alllods": {
        // allLODs objectOrModel
        private _p0 = _args param [0];
        allLODs _p0;
        _result = true;
    };
    case "allmissionobjects": {
        // allMissionObjects type
        private _p0 = _args param [0];
        allMissionObjects _p0;
        _result = true;
    };
    case "allobjects": {
        // objectType allObjects objectCollection
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 allObjects _p1;
    };
    case "allobjects": {
        // objectType allObjects objectCollection
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 allObjects _p1;
        _result = true;
    };
    case "allow3dmode": {
        // map allow3DMode bool
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 allow3DMode _p1;
        _result = true;
    };
    case "allowcrewinimmobile": {
        // vehicle allowCrewInImmobile allow
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 allowCrewInImmobile _p1;
        _result = true;
    };
    case "allowcrewinimmobile": {
        // vehicle allowCrewInImmobile [brokenWheels, upsideDown]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 allowCrewInImmobile [_p1, _p2];
        _result = true;
    };
    case "allowcuratorlogicignoreareas": {
        // curatorObj allowCuratorLogicIgnoreAreas allow
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 allowCuratorLogicIgnoreAreas _p1;
        _result = true;
    };
    case "allowdamage": {
        // entity allowDamage allow
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 allowDamage _p1;
        _result = true;
    };
    case "allowdammage": {
        // object allowDammage allow
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 allowDammage _p1;
        _result = true;
    };
    case "allowedservice": {
        // allowedService vehicle
        private _p0 = _args param [0];
        _result = allowedService _p0;
    };
    case "allowfileoperations": {
        // map allowFileOperations bool
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 allowFileOperations _p1;
        _result = true;
    };
    case "allowfleeing": {
        // unitOrGroup allowFleeing  cowardice
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 allowFleeing  _p1;
        _result = true;
    };
    case "allowgetin": {
        // unitArray allowGetIn allow
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 allowGetIn _p1;
        _result = true;
    };
    case "allowservice": {
        // vehicle allowService type
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 allowService _p1;
        _result = true;
    };
    case "allowsprint": {
        // unit allowSprint  state
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 allowSprint  _p1;
        _result = true;
    };
    case "allsimpleobjects": {
        // allSimpleObjects classes
        private _p0 = _args param [0];
        _result = allSimpleObjects _p0;
    };
    case "allturrets": {
        // allTurrets vehicle
        private _p0 = _args param [0];
        allTurrets _p0;
        _result = true;
    };
    case "allturrets": {
        // allTurrets [vehicle, includeFFV]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        allTurrets [_p0, _p1];
        _result = true;
    };
    case "allvariables": {
        // allVariables namespace
        private _p0 = _args param [0];
        allVariables _p0;
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
