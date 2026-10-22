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
    case "create3dencomposition": {
        // create3DENComposition [configPath,  position]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        create3DENComposition [_p0,  _p1];
        _result = true;
    };
    case "create3denentity": {
        // create3DENEntity [mode, class, position, isEmpty]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        create3DENEntity [_p0, _p1, _p2, _p3];
        _result = true;
    };
    case "create3denentity": {
        // group create3DENEntity [mode, class, position, isEmpty]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _p0 create3DENEntity [_p1, _p2, _p3, _p4];
        _result = true;
    };
    case "createagent": {
        // createAgent [type, position, markers, placement, special]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = createAgent [_p0, _p1, _p2, _p3, _p4];
    };
    case "createcenter": {
        // createCenter side
        private _p0 = _args param [0];
        _result = createCenter _p0;
    };
    case "createdialog": {
        // createDialog  dialogName
        private _p0 = _args param [0];
        _result = createDialog  _p0;
    };
    case "createdialog": {
        // createDialog [dialogName, forceOnTop]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = createDialog [_p0, _p1];
    };
    case "creatediarylink": {
        // createDiaryLink [subject, record, text]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = createDiaryLink [_p0, _p1, _p2];
    };
    case "creatediaryrecord": {
        // player createDiaryRecord [subject, text, task, taskState, showTitle]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _p0 createDiaryRecord [_p1, _p2, _p3, _p4, _p5];
        _result = true;
    };
    case "creatediaryrecord": {
        // player createDiaryRecord [subject, [title, text, icon], task, taskState, showTitle]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        private _p7 = _args param [7];
        _p0 createDiaryRecord [_p1, [_p2, _p3, _p4], _p5, _p6, _p7];
        _result = true;
    };
    case "creatediarysubject": {
        // player createDiarySubject  [subject, displayName, picture]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = _p0 createDiarySubject  [_p1, _p2, _p3];
    };
    case "createdisplay": {
        // parent createDisplay  resourceName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 createDisplay  _p1;
        _result = true;
    };
    case "creategeardialog": {
        // createGearDialog [unit, resource]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        createGearDialog [_p0, _p1];
        _result = true;
    };
    case "creategroup": {
        // createGroup side
        private _p0 = _args param [0];
        _result = createGroup _p0;
    };
    case "creategroup": {
        // createGroup [side, deleteWhenEmpty]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = createGroup [_p0, _p1];
    };
    case "createguardedpoint": {
        // createGuardedPoint [side, position, objectMapID, vehicle]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        createGuardedPoint [_p0, _p1, _p2, _p3];
        _result = true;
    };
    case "createhashmapfromarray": {
        // keys createHashMapFromArray values
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 createHashMapFromArray _p1;
    };
    case "createlocation": {
        // createLocation [className, position, sizeX, sizeY]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = createLocation [_p0, _p1, _p2, _p3];
    };
    case "createlocation": {
        // createLocation [location]
        private _p0 = _args param [0];
        _result = createLocation [_p0];
    };
    case "createmarker": {
        // createMarker [name, position, channel, creator]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = createMarker [_p0, _p1, _p2, _p3];
    };
    case "createmarkerlocal": {
        // createMarkerLocal [name, position, channel, creator]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = createMarkerLocal [_p0, _p1, _p2, _p3];
    };
    case "createmenu": {
        // map createMenu index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 createMenu _p1;
        _result = true;
    };
    case "createmine": {
        // createMine [type, position, markers, placement]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = createMine [_p0, _p1, _p2, _p3];
    };
    case "createmissiondisplay": {
        // display createMissionDisplay missionRootDirectoryString
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 createMissionDisplay _p1;
    };
    case "createmissiondisplay": {
        // display createMissionDisplay  [missionRootDirectoryString, cfgMissionsClass]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 createMissionDisplay  [_p1, _p2];
    };
    case "creatempcampaigndisplay": {
        // display createMPCampaignDisplay class
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 createMPCampaignDisplay _p1;
        _result = true;
    };
    case "createsimpleobject": {
        // createSimpleObject [shapeName, positionWorld, local]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = createSimpleObject [_p0, _p1, _p2];
    };
    case "createsimpleobject": {
        // createSimpleObject [className, positionASL, local]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = createSimpleObject [_p0, _p1, _p2];
    };
    case "createsimpletask": {
        // unit createSimpleTask  [name, parentTask]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 createSimpleTask  [_p1, _p2];
    };
    case "createsite": {
        // type createSite pos
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 createSite _p1;
    };
    case "createsoundsource": {
        // createSoundSource [type, position, markers, placement]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = createSoundSource [_p0, _p1, _p2, _p3];
    };
    case "createtarget": {
        // obj createTarget [type, position, typeAccuracy, posAccuracy]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = _p0 createTarget [_p1, _p2, _p3, _p4];
    };
    case "createtask": {
        // teamMember createTask [[type, parentTask], priority, name1, value1, (...), nameN, valueN]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _result = _p0 createTask [[_p1, _p2], _p3, _p4, _p5, (...), nameN, valueN];
    };
    case "createteam": {
        // createTeam  [type, name]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        createTeam  [_p0, _p1];
        _result = true;
    };
    case "createtrigger": {
        // createTrigger [type, position, makeGlobal]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = createTrigger [_p0, _p1, _p2];
    };
    case "createunit": {
        // group createUnit [type, position, markers, placement, special]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _result = _p0 createUnit [_p1, _p2, _p3, _p4, _p5];
    };
    case "createunit": {
        // type createUnit [position, group, init, skill, rank]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _p0 createUnit [_p1, _p2, _p3, _p4, _p5];
        _result = true;
    };
    case "createvehicle": {
        // type createVehicle position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 createVehicle _p1;
    };
    case "createvehicle": {
        // createVehicle [type, position, markers, placement, special]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = createVehicle [_p0, _p1, _p2, _p3, _p4];
    };
    case "createvehiclecrew": {
        // createVehicleCrew vehicle
        private _p0 = _args param [0];
        _result = createVehicleCrew _p0;
    };
    case "createvehiclelocal": {
        // type createVehicleLocal position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 createVehicleLocal _p1;
    };
    default { _handled = false; };
};

[_handled, _result]
