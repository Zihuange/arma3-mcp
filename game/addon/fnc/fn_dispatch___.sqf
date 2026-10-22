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
    case "!_a": {
        // ! a
        private _p0 = _args param [0];
        _result = ! _p0;
    };
    case "+": {
        // numberA + numberB
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 + _p1;
    };
    case "+": {
        // + number
        private _p0 = _args param [0];
        _result = + _p0;
    };
    case "+": {
        // arrayA + arrayB
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 + _p1;
    };
    case "+": {
        // stringA + stringB
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 + _p1;
    };
    case "+": {
        // + array
        private _p0 = _args param [0];
        _result = + _p0;
    };
    case "+": {
        // + hashMap
        private _p0 = _args param [0];
        _result = + _p0;
    };
    case "-": {
        // numberA - numberB
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 - _p1;
    };
    case "-": {
        // - numberA
        private _p0 = _args param [0];
        _result = - _p0;
    };
    case "-": {
        // arrayA - arrayB
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 - _p1;
    };
    case "a_!=_b": {
        // a != b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 != _p1;
    };
    case "a_%_b": {
        // a % b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 % _p1;
    };
    case "a_&&_b": {
        // booleanA && booleanB
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 && _p1;
    };
    case "a_&&_b": {
        // boolean && code
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 && _p1;
    };
    case "a_*_b": {
        // a * b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 * _p1;
    };
    case "a_/_b": {
        // a / b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 / _p1;
    };
    case "a_/_b": {
        // config / name
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 / _p1;
        _result = true;
    };
    case "a_:_b": {
        // a : b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 : _p1;
        _result = true;
    };
    case "a_==_b": {
        // a == b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 == _p1;
    };
    case "a_=_b": {
        // variable = value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 = _p1;
        _result = true;
    };
    case "a_^_b": {
        // a ^ b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 ^ _p1;
    };
    case "a_greater=_b": {
        // a &gt;= b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 &gt;= _p1;
    };
    case "a_greater_b": {
        // a > b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 > _p1;
    };
    case "a_hash_b": {
        // array  # index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0  # _p1;
    };
    case "a_less=_b": {
        // a <= b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 <= _p1;
    };
    case "a_less_b": {
        // a &lt; b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 &lt; _p1;
    };
    case "a_or_b": {
        // a !! b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 !! _p1;
    };
    case "a_or_b": {
        // a !! b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 !! _p1;
    };
    case "abs": {
        // abs x
        private _p0 = _args param [0];
        _result = abs _p0;
    };
    case "acos": {
        // acos x
        private _p0 = _args param [0];
        _result = acos _p0;
    };
    case "activateaddons": {
        // activateAddons addonsList
        private _p0 = _args param [0];
        activateAddons _p0;
        _result = true;
    };
    case "activatekey": {
        // activateKey keyname
        private _p0 = _args param [0];
        activateKey _p0;
        _result = true;
    };
    case "activetitleeffectparams": {
        // activeTitleEffectParams layer
        private _p0 = _args param [0];
        activeTitleEffectParams _p0;
        _result = true;
    };
    case "admin": {
        // admin ownerID
        private _p0 = _args param [0];
        admin _p0;
        _result = true;
    };
    case "agent": {
        // agent teamMember
        private _p0 = _args param [0];
        _result = agent _p0;
    };
    case "agltoasl": {
        // AGLToASL posAGL
        private _p0 = _args param [0];
        _result = AGLToASL _p0;
    };
    case "aimedattarget": {
        // vehicle aimedAtTarget [target, weapon]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 aimedAtTarget [_p1, _p2];
        _result = true;
    };
    case "aimpos": {
        // aimPos  unit
        private _p0 = _args param [0];
        _result = aimPos  _p0;
    };
    case "airdensityrtd": {
        // airDensityRTD altitude
        private _p0 = _args param [0];
        _result = airDensityRTD _p0;
    };
    case "airplanethrottle": {
        // airplaneThrottle airplane
        private _p0 = _args param [0];
        _result = airplaneThrottle _p0;
    };
    case "airportside": {
        // airportSide id
        private _p0 = _args param [0];
        _result = airportSide _p0;
    };
    case "airportside": {
        // airportSide target
        private _p0 = _args param [0];
        _result = airportSide _p0;
    };
    case "aisfinishheal": {
        // AISFinishHeal [unit, healer, healerCanHeal]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        AISFinishHeal [_p0, _p1, _p2];
        _result = true;
    };
    case "alive": {
        // alive object
        private _p0 = _args param [0];
        _result = alive _p0;
    };
    case "ammo": {
        // unit ammo muzzle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 ammo _p1;
    };
    case "ammoonpylon": {
        // vehicle ammoOnPylon pylon
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ammoOnPylon _p1;
        _result = true;
    };
    case "and": {
        // a and b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 and _p1;
    };
    case "and": {
        // a and b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 and _p1;
    };
    case "animate": {
        // object animate [animationName, phase, speed]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 animate [_p1, _p2, _p3];
        _result = true;
    };
    case "animatebay": {
        // vehicle animateBay  [bay, animphase, instant]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 animateBay  [_p1, _p2, _p3];
        _result = true;
    };
    case "animatedoor": {
        // object animateDoor [doorname, phase, instant]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 animateDoor [_p1, _p2, _p3];
        _result = true;
    };
    case "animatepylon": {
        // vehicle animatePylon [pylon, animphase, instant]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 animatePylon [_p1, _p2, _p3];
        _result = true;
    };
    case "animatesource": {
        // object animateSource [source, phase, speed]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 animateSource [_p1, _p2, _p3];
        _result = true;
    };
    case "animationnames": {
        // animationNames object
        private _p0 = _args param [0];
        animationNames _p0;
        _result = true;
    };
    case "animationphase": {
        // object animationPhase  animationName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 animationPhase  _p1;
    };
    case "animationsourcephase": {
        // object animationSourcePhase source
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 animationSourcePhase _p1;
    };
    case "animationstate": {
        // animationState unitName
        private _p0 = _args param [0];
        _result = animationState _p0;
    };
    case "append": {
        // array1 append array2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 append _p1;
        _result = true;
    };
    case "apply": {
        // array apply code
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 apply _p1;
    };
    case "apply": {
        // hashmap apply code
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 apply _p1;
    };
    case "arrayintersect": {
        // array1 arrayIntersect array2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 arrayIntersect _p1;
    };
    case "asin": {
        // asin x
        private _p0 = _args param [0];
        _result = asin _p0;
    };
    case "asltoagl": {
        // ASLToAGL posASL
        private _p0 = _args param [0];
        _result = ASLToAGL _p0;
    };
    case "asltoatl": {
        // ASLToATL pos
        private _p0 = _args param [0];
        ASLToATL _p0;
        _result = true;
    };
    case "assert": {
        // assert condition
        private _p0 = _args param [0];
        _result = assert _p0;
    };
    case "assignascargo": {
        // unitName assignAsCargo vehicleName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 assignAsCargo _p1;
        _result = true;
    };
    case "assignascargoindex": {
        // character assignAsCargoIndex [vehicle, index]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 assignAsCargoIndex [_p1, _p2];
    };
    case "assignascommander": {
        // unitName assignAsCommander vehicleName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 assignAsCommander _p1;
        _result = true;
    };
    case "assignasdriver": {
        // unitName assignAsDriver vehicleName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 assignAsDriver _p1;
        _result = true;
    };
    case "assignasgunner": {
        // unitName assignAsGunner vehicleName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 assignAsGunner _p1;
        _result = true;
    };
    case "assignasturret": {
        // unit assignAsTurret [vehicle, turretPath]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 assignAsTurret [_p1, _p2];
        _result = true;
    };
    case "assigncurator": {
        // player assignCurator curatorObj
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 assignCurator _p1;
        _result = true;
    };
    case "assignedcargo": {
        // assignedCargo vehicle
        private _p0 = _args param [0];
        assignedCargo _p0;
        _result = true;
    };
    case "assignedcommander": {
        // assignedCommander  vehicle
        private _p0 = _args param [0];
        _result = assignedCommander  _p0;
    };
    case "assigneddriver": {
        // assignedDriver vehicle
        private _p0 = _args param [0];
        _result = assignedDriver _p0;
    };
    case "assignedgroup": {
        // assignedGroup vehicle
        private _p0 = _args param [0];
        _result = assignedGroup _p0;
    };
    case "assignedgunner": {
        // assignedGunner vehicle
        private _p0 = _args param [0];
        _result = assignedGunner _p0;
    };
    case "assigneditems": {
        // assignedItems  unit
        private _p0 = _args param [0];
        _result = assignedItems  _p0;
    };
    case "assignedtarget": {
        // assignedTarget vehicleName
        private _p0 = _args param [0];
        _result = assignedTarget _p0;
    };
    case "assignedteam": {
        // assignedTeam unitName
        private _p0 = _args param [0];
        assignedTeam _p0;
        _result = true;
    };
    case "assignedvehicle": {
        // assignedVehicle unit
        private _p0 = _args param [0];
        _result = assignedVehicle _p0;
    };
    case "assignedvehiclerole": {
        // assignedVehicleRole unitName
        private _p0 = _args param [0];
        assignedVehicleRole _p0;
        _result = true;
    };
    case "assignedvehicles": {
        // assignedVehicles group
        private _p0 = _args param [0];
        assignedVehicles _p0;
        _result = true;
    };
    case "assignitem": {
        // unit assignItem item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 assignItem _p1;
        _result = true;
    };
    case "assignteam": {
        // unit assignTeam team
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 assignTeam _p1;
        _result = true;
    };
    case "assigntoairport": {
        // plane assignToAirport id
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 assignToAirport _p1;
        _result = true;
    };
    case "assigntoairport": {
        // plane assignToAirport target
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 assignToAirport _p1;
        _result = true;
    };
    case "atan": {
        // atan  x
        private _p0 = _args param [0];
        _result = atan  _p0;
    };
    case "atan2": {
        // y atan2 x
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 atan2 _p1;
    };
    case "atg": {
        // atg x
        private _p0 = _args param [0];
        _result = atg _p0;
    };
    case "atltoasl": {
        // ATLToASL pos
        private _p0 = _args param [0];
        ATLToASL _p0;
        _result = true;
    };
    case "attackenabled": {
        // attackEnabled name
        private _p0 = _args param [0];
        _result = attackEnabled _p0;
    };
    case "awake": {
        // object awake awake
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 _p1 _p1;
        _result = true;
    };
    case "backpack": {
        // backpack unit
        private _p0 = _args param [0];
        _result = backpack _p0;
    };
    case "backpackcargo": {
        // backpackCargo box
        private _p0 = _args param [0];
        _result = backpackCargo _p0;
    };
    case "backpackcontainer": {
        // backpackContainer unit
        private _p0 = _args param [0];
        _result = backpackContainer _p0;
    };
    case "backpackitems": {
        // backpackItems unit
        private _p0 = _args param [0];
        _result = backpackItems _p0;
    };
    case "backpackmagazines": {
        // backpackMagazines unit
        private _p0 = _args param [0];
        backpackMagazines _p0;
        _result = true;
    };
    case "backpacks": {
        // backpacks unit
        private _p0 = _args param [0];
        _result = backpacks _p0;
    };
    case "backpackspacefor": {
        // backpack backpackSpaceFor weaponName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 backpackSpaceFor _p1;
    };
    case "batterychargertd": {
        // batteryChargeRTD helicopterRTD
        private _p0 = _args param [0];
        _result = batteryChargeRTD _p0;
    };
    case "behaviour": {
        // behaviour unit
        private _p0 = _args param [0];
        behaviour _p0;
        _result = true;
    };
    case "bezierinterpolation": {
        // progress bezierInterpolation positions
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 bezierInterpolation _p1;
    };
    case "bin_fnc_cargoplatform_01_adjust": {
        // [object] call BIN_fnc_cargoPlatform_01_adjust
        private _p0 = _args param [0];
        [_p0] call BIN_fnc_cargoPlatform_01_adjust;
        _result = true;
    };
    case "bin_fnc_cbrnhoseinit": {
        // [unit] call BIN_fnc_CBRNHoseInit
        private _p0 = _args param [0];
        [_p0] call BIN_fnc_CBRNHoseInit;
        _result = true;
    };
    case "bin_fnc_colorhsltorgb": {
        // [hue, saturation, lightness] call BIN_fnc_colorHSLtoRGB
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIN_fnc_colorHSLtoRGB;
        _result = true;
    };
    case "bin_fnc_enablesaving": {
        // [enableSaving, saveGame] call BIN_fnc_enableSaving
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIN_fnc_enableSaving;
        _result = true;
    };
    case "binocular": {
        // binocular unit
        private _p0 = _args param [0];
        _result = binocular _p0;
    };
    case "binocularitems": {
        // binocularItems unit
        private _p0 = _args param [0];
        _result = binocularItems _p0;
    };
    case "binocularmagazine": {
        // binocularMagazine  unit
        private _p0 = _args param [0];
        _result = binocularMagazine  _p0;
    };
    case "bis_som_addsupportrequestfunc": {
        // [secops, unit] call BIS_SOM_addSupportRequestFunc
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_SOM_addSupportRequestFunc;
        _result = true;
    };
    case "boundingbox": {
        // boundingBox object
        private _p0 = _args param [0];
        _result = boundingBox _p0;
    };
    case "boundingbox": {
        // clippingType boundingBox object
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 boundingBox _p1;
    };
    case "boundingboxreal": {
        // boundingBoxReal object
        private _p0 = _args param [0];
        _result = boundingBoxReal _p0;
    };
    case "boundingboxreal": {
        // clippingType boundingBoxReal object
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 boundingBoxReal _p1;
    };
    case "boundingcenter": {
        // boundingCenter object
        private _p0 = _args param [0];
        _result = boundingCenter _p0;
    };
    case "brakesdisabled": {
        // brakesDisabled transport
        private _p0 = _args param [0];
        _result = brakesDisabled _p0;
    };
    case "breakout": {
        // breakOut  name
        private _p0 = _args param [0];
        breakOut  _p0;
        _result = true;
    };
    case "breakout": {
        // value breakOut  name
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 breakOut  _p1;
    };
    case "breakto": {
        // breakTo name
        private _p0 = _args param [0];
        breakTo _p0;
        _result = true;
    };
    case "breakwith": {
        // breakWith return
        private _p0 = _args param [0];
        _result = breakWith _p0;
    };
    case "buildingexit": {
        // building buildingExit index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 buildingExit _p1;
    };
    case "buildingpos": {
        // building buildingPos  index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 buildingPos  _p1;
    };
    case "buldozer_enableroaddiag": {
        // buldozer_enableRoadDiag enable
        private _p0 = _args param [0];
        buldozer_enableRoadDiag _p0;
        _result = true;
    };
    case "buldozer_loadnewroads": {
        // buldozer_loadNewRoads path
        private _p0 = _args param [0];
        _result = buldozer_loadNewRoads _p0;
    };
    case "buttonaction": {
        // buttonAction  idc
        private _p0 = _args param [0];
        _result = buttonAction  _p0;
    };
    case "buttonaction": {
        // buttonAction  control
        private _p0 = _args param [0];
        _result = buttonAction  _p0;
    };
    case "buttonsetaction": {
        // buttonSetAction  [idc, action]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        buttonSetAction  [_p0, _p1];
        _result = true;
    };
    case "buttonsetaction": {
        // control buttonSetAction  action
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 buttonSetAction  _p1;
        _result = true;
    };
    case "calculatepath": {
        // calculatePath [type, behaviour, from, to]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = calculatePath [_p0, _p1, _p2, _p3];
    };
    case "calculateplayervisibilitybyfriendly": {
        // calculatePlayerVisibilityByFriendly calculate
        private _p0 = _args param [0];
        calculatePlayerVisibilityByFriendly _p0;
        _result = true;
    };
    case "call": {
        // call code
        private _p0 = _args param [0];
        _result = call _p0;
    };
    case "call": {
        // args call code
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 call _p1;
    };
    case "callextension": {
        // extension callExtension function
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 callExtension _p1;
    };
    case "callextension": {
        // extension callExtension  [function, arguments]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 callExtension  [_p1, _p2];
        _result = true;
    };
    case "captive": {
        // captive object
        private _p0 = _args param [0];
        _result = captive _p0;
    };
    case "captivenum": {
        // captiveNum unit
        private _p0 = _args param [0];
        _result = captiveNum _p0;
    };
    case "case": {
        // case b
        private _p0 = _args param [0];
        case _p0;
        _result = true;
    };
    case "catch": {
        // tryBlock catch code
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 catch _p1;
    };
    case "cba_accessory_fnc_switchattachment": {
        // [_switchTo] call CBA_accessory_fnc_switchAttachment
        private _p0 = _args param [0];
        _result = [_p0] call CBA_accessory_fnc_switchAttachment;
    };
    case "cbchecked": {
        // cbChecked control
        private _p0 = _args param [0];
        _result = cbChecked _p0;
    };
    case "cbsetchecked": {
        // control cbSetChecked state
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 cbSetChecked _p1;
        _result = true;
    };
    case "ceil": {
        // ceil  x
        private _p0 = _args param [0];
        _result = ceil  _p0;
    };
    case "channelenabled": {
        // channelEnabled channelID
        private _p0 = _args param [0];
        _result = channelEnabled _p0;
    };
    case "checkaifeature": {
        // checkAIFeature feature
        private _p0 = _args param [0];
        _result = checkAIFeature _p0;
    };
    case "checkaifeature": {
        // unit checkAIFeature feature
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 checkAIFeature _p1;
    };
    case "checkvisibility": {
        // [ignore, LOD, ignore2] checkVisibility [beg, end]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = [_p0, _p1, _p2] checkVisibility [_p3, _p4];
    };
    case "classname": {
        // className location
        private _p0 = _args param [0];
        _result = className _p0;
    };
    case "clear3denattribute": {
        // entity clear3DENAttribute  attribute
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 clear3DENAttribute  _p1;
    };
    case "clear3deninventory": {
        // clear3DENInventory  entities
        private _p0 = _args param [0];
        clear3DENInventory  _p0;
        _result = true;
    };
    case "clearallitemsfrombackpack": {
        // clearAllItemsFromBackpack unit
        private _p0 = _args param [0];
        clearAllItemsFromBackpack _p0;
        _result = true;
    };
    case "clearbackpackcargo": {
        // clearBackpackCargo box
        private _p0 = _args param [0];
        clearBackpackCargo _p0;
        _result = true;
    };
    case "clearbackpackcargoglobal": {
        // clearBackpackCargoGlobal unit
        private _p0 = _args param [0];
        clearBackpackCargoGlobal _p0;
        _result = true;
    };
    case "cleargroupicons": {
        // clearGroupIcons  group
        private _p0 = _args param [0];
        clearGroupIcons  _p0;
        _result = true;
    };
    case "clearitemcargo": {
        // clearItemCargo box
        private _p0 = _args param [0];
        clearItemCargo _p0;
        _result = true;
    };
    case "clearitemcargoglobal": {
        // clearItemCargoGlobal box
        private _p0 = _args param [0];
        clearItemCargoGlobal _p0;
        _result = true;
    };
    case "clearitempool": {
        // clearItemPool box
        private _p0 = _args param [0];
        clearItemPool _p0;
        _result = true;
    };
    case "clearmagazinecargo": {
        // clearMagazineCargo vehicleName
        private _p0 = _args param [0];
        clearMagazineCargo _p0;
        _result = true;
    };
    case "clearmagazinecargoglobal": {
        // clearMagazineCargoGlobal  object
        private _p0 = _args param [0];
        clearMagazineCargoGlobal  _p0;
        _result = true;
    };
    case "clearoverlay": {
        // clearOverlay map
        private _p0 = _args param [0];
        clearOverlay _p0;
        _result = true;
    };
    case "clearvehicleinit": {
        // clearVehicleInit objectName
        private _p0 = _args param [0];
        clearVehicleInit _p0;
        _result = true;
    };
    case "clearweaponcargo": {
        // clearWeaponCargo vehicleName
        private _p0 = _args param [0];
        clearWeaponCargo _p0;
        _result = true;
    };
    case "clearweaponcargoglobal": {
        // clearWeaponCargoGlobal unit
        private _p0 = _args param [0];
        clearWeaponCargoGlobal _p0;
        _result = true;
    };
    case "closedialog": {
        // closeDialog  exitcode
        private _p0 = _args param [0];
        closeDialog  _p0;
        _result = true;
    };
    case "closedisplay": {
        // display closeDisplay exitCode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 closeDisplay _p1;
        _result = true;
    };
    case "closeoverlay": {
        // closeOverlay map
        private _p0 = _args param [0];
        closeOverlay _p0;
        _result = true;
    };
    case "collapseobjecttree": {
        // collapseObjectTree map
        private _p0 = _args param [0];
        collapseObjectTree _p0;
        _result = true;
    };
    case "collect3denhistory": {
        // collect3DENHistory code
        private _p0 = _args param [0];
        collect3DENHistory _p0;
        _result = true;
    };
    case "collect3denhistory": {
        // [text, tooltip, icon] collect3DENHistory code
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2] collect3DENHistory _p3;
        _result = true;
    };
    case "collectivertd": {
        // collectiveRTD helicopterRTD
        private _p0 = _args param [0];
        _result = collectiveRTD _p0;
    };
    case "collisiondisabledwith": {
        // collisionDisabledWith obj
        private _p0 = _args param [0];
        collisionDisabledWith _p0;
        _result = true;
    };
    case "combatbehaviour": {
        // combatBehaviour unit
        private _p0 = _args param [0];
        _result = combatBehaviour _p0;
    };
    case "combatbehaviour": {
        // combatBehaviour group
        private _p0 = _args param [0];
        _result = combatBehaviour _p0;
    };
    case "combatmode": {
        // combatMode group
        private _p0 = _args param [0];
        combatMode _p0;
        _result = true;
    };
    case "comment": {
        // comment text
        private _p0 = _args param [0];
        comment _p0;
        _result = true;
    };
    case "commitoverlay": {
        // commitOverlay map
        private _p0 = _args param [0];
        commitOverlay _p0;
        _result = true;
    };
    case "compatibleitems": {
        // compatibleItems weapon
        private _p0 = _args param [0];
        compatibleItems _p0;
        _result = true;
    };
    case "compatibleitems": {
        // compatibleItems [weapon, slot]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        compatibleItems [_p0, _p1];
        _result = true;
    };
    case "compatiblemagazines": {
        // compatibleMagazines weapon
        private _p0 = _args param [0];
        compatibleMagazines _p0;
        _result = true;
    };
    case "compatiblemagazines": {
        // compatibleMagazines [weapon, muzzle]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        compatibleMagazines [_p0, _p1];
        _result = true;
    };
    case "compile": {
        // compile expression
        private _p0 = _args param [0];
        _result = compile _p0;
    };
    case "compilefinal": {
        // compileFinal  expression
        private _p0 = _args param [0];
        _result = compileFinal  _p0;
    };
    case "compilescript": {
        // compileScript [path, final, prefixHeader]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = compileScript [_p0, _p1, _p2];
    };
    case "completedfsm": {
        // completedFSM fsmHandle
        private _p0 = _args param [0];
        _result = completedFSM _p0;
    };
    case "composetext": {
        // composeText arguments
        private _p0 = _args param [0];
        composeText _p0;
        _result = true;
    };
    case "config_greater_greater_name": {
        // config >> name
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 >> _p1;
    };
    case "configclasses": {
        // condition configClasses config
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 configClasses _p1;
    };
    case "confighierarchy": {
        // configHierarchy configClass
        private _p0 = _args param [0];
        _result = configHierarchy _p0;
    };
    case "configname": {
        // configName config
        private _p0 = _args param [0];
        _result = configName _p0;
    };
    case "configof": {
        // configOf object
        private _p0 = _args param [0];
        _result = configOf _p0;
    };
    case "configproperties": {
        // configProperties [config, condition, inherit]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = configProperties [_p0, _p1, _p2];
    };
    case "configsourceaddonlist": {
        // configSourceAddonList config
        private _p0 = _args param [0];
        configSourceAddonList _p0;
        _result = true;
    };
    case "configsourcemod": {
        // configSourceMod config
        private _p0 = _args param [0];
        _result = configSourceMod _p0;
    };
    case "configsourcemodlist": {
        // configSourceModList config
        private _p0 = _args param [0];
        configSourceModList _p0;
        _result = true;
    };
    case "confirmsensortarget": {
        // vehicle confirmSensorTarget [side, isConfirmed]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 confirmSensorTarget [_p1, _p2];
        _result = true;
    };
    case "connectterminaltouav": {
        // person connectTerminalToUAV uav
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 connectTerminalToUAV _p1;
    };
    case "connecttoserver": {
        // connectToServer [ip, port, password]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        connectToServer [_p0, _p1, _p2];
        _result = true;
    };
    case "continuewith": {
        // continueWith return
        private _p0 = _args param [0];
        _result = continueWith _p0;
    };
    case "controlsgroupctrl": {
        // ctrlgrp controlsGroupCtrl idc
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 controlsGroupCtrl _p1;
    };
    case "conversationdisabled": {
        // conversationDisabled unit
        private _p0 = _args param [0];
        _result = conversationDisabled _p0;
    };
    case "copytoclipboard": {
        // copyToClipboard text
        private _p0 = _args param [0];
        copyToClipboard _p0;
        _result = true;
    };
    case "copywaypoints": {
        // groupTo copyWaypoints groupFrom
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 copyWaypoints _p1;
        _result = true;
    };
    case "cos": {
        // cos x
        private _p0 = _args param [0];
        _result = cos _p0;
    };
    case "count": {
        // count value
        private _p0 = _args param [0];
        _result = count _p0;
    };
    case "count": {
        // condition count array
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 count _p1;
    };
    case "countenemy": {
        // unitName countEnemy arrayName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 countEnemy _p1;
    };
    case "countfriendly": {
        // unitName countFriendly arrayName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 countFriendly _p1;
    };
    case "countside": {
        // side countSide  array
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 countSide  _p1;
    };
    case "counttype": {
        // type countType objects
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 countType _p1;
    };
    case "countunknown": {
        // unitName countUnknown arrayName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 countUnknown _p1;
    };
    case "crew": {
        // crew vehicleName
        private _p0 = _args param [0];
        _result = crew _p0;
    };
    case "ctaddheader": {
        // ctAddHeader control
        private _p0 = _args param [0];
        _result = ctAddHeader _p0;
    };
    case "ctaddrow": {
        // ctAddRow control
        private _p0 = _args param [0];
        _result = ctAddRow _p0;
    };
    case "ctclear": {
        // ctClear ctrl
        private _p0 = _args param [0];
        ctClear _p0;
        _result = true;
    };
    case "ctcursel": {
        // ctCurSel ctrl
        private _p0 = _args param [0];
        _result = ctCurSel _p0;
    };
    case "ctdata": {
        // ctrl ctData row
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 ctData _p1;
    };
    case "ctfindheaderrows": {
        // ctrl ctFindHeaderRows index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 ctFindHeaderRows _p1;
    };
    case "ctfindrowheader": {
        // ctrl ctFindRowHeader rowIndex
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 ctFindRowHeader _p1;
    };
    case "ctheadercontrols": {
        // ctrl ctHeaderControls index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 ctHeaderControls _p1;
    };
    case "ctheadercount": {
        // ctHeaderCount ctrl
        private _p0 = _args param [0];
        _result = ctHeaderCount _p0;
    };
    case "ctremoveheaders": {
        // ctrl ctRemoveHeaders indices
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctRemoveHeaders _p1;
        _result = true;
    };
    case "ctrowcontrols": {
        // control ctRowControls index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 ctRowControls _p1;
    };
    case "ctrowcount": {
        // ctRowCount control
        private _p0 = _args param [0];
        _result = ctRowCount _p0;
    };
    case "ctsetcursel": {
        // control ctSetCurSel index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctSetCurSel _p1;
        _result = true;
    };
    case "ctsetdata": {
        // ctrl ctSetData [index, data]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 ctSetData [_p1, _p2];
        _result = true;
    };
    case "ctsetheadertemplate": {
        // control ctSetHeaderTemplate config
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctSetHeaderTemplate _p1;
        _result = true;
    };
    case "ctsetrowtemplate": {
        // control ctSetRowTemplate config
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctSetRowTemplate _p1;
        _result = true;
    };
    case "ctsetvalue": {
        // control ctSetValue [index, value]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 ctSetValue [_p1, _p2];
        _result = true;
    };
    case "ctvalue": {
        // control ctValue index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 ctValue _p1;
    };
    case "curatoraddons": {
        // curatorAddons curatorObj
        private _p0 = _args param [0];
        _result = curatorAddons _p0;
    };
    case "curatorcameraarea": {
        // curatorCameraArea curatorObj
        private _p0 = _args param [0];
        _result = curatorCameraArea _p0;
    };
    case "curatorcameraareaceiling": {
        // curatorCameraAreaCeiling curatorObj
        private _p0 = _args param [0];
        _result = curatorCameraAreaCeiling _p0;
    };
    case "curatorcoef": {
        // curatorObj curatorCoef action
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 curatorCoef _p1;
    };
    case "curatoreditableobjects": {
        // curatorEditableObjects curatorObj
        private _p0 = _args param [0];
        _result = curatorEditableObjects _p0;
    };
    case "curatoreditingarea": {
        // curatorEditingArea curator
        private _p0 = _args param [0];
        curatorEditingArea _p0;
        _result = true;
    };
    case "curatoreditingareatype": {
        // curatorEditingAreaType curator
        private _p0 = _args param [0];
        _result = curatorEditingAreaType _p0;
    };
    case "curatorpoints": {
        // curatorPoints curatorObj
        private _p0 = _args param [0];
        _result = curatorPoints _p0;
    };
    case "curatorregisteredobjects": {
        // curatorRegisteredObjects curator
        private _p0 = _args param [0];
        _result = curatorRegisteredObjects _p0;
    };
    case "curatorselectionpreset": {
        // curatorSelectionPreset numkey
        private _p0 = _args param [0];
        curatorSelectionPreset _p0;
        _result = true;
    };
    case "curatorwaypointcost": {
        // curatorWaypointCost curatorObj
        private _p0 = _args param [0];
        _result = curatorWaypointCost _p0;
    };
    case "currentcommand": {
        // currentCommand vehicleName
        private _p0 = _args param [0];
        _result = currentCommand _p0;
    };
    case "currentmagazine": {
        // currentMagazine vehicle
        private _p0 = _args param [0];
        _result = currentMagazine _p0;
    };
    case "currentmagazinedetail": {
        // currentMagazineDetail object
        private _p0 = _args param [0];
        _result = currentMagazineDetail _p0;
    };
    case "currentmagazinedetailturret": {
        // vehicle currentMagazineDetailTurret turretPath
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 currentMagazineDetailTurret _p1;
    };
    case "currentmagazineturret": {
        // vehicle currentMagazineTurret turretPath
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 currentMagazineTurret _p1;
    };
    case "currentmuzzle": {
        // currentMuzzle unit
        private _p0 = _args param [0];
        _result = currentMuzzle _p0;
    };
    case "currentpilot": {
        // currentPilot vehicle
        private _p0 = _args param [0];
        _result = currentPilot _p0;
    };
    case "currenttask": {
        // currentTask person
        private _p0 = _args param [0];
        _result = currentTask _p0;
    };
    case "currenttasks": {
        // currentTasks teamMember
        private _p0 = _args param [0];
        _result = currentTasks _p0;
    };
    case "currentthrowable": {
        // currentThrowable player
        private _p0 = _args param [0];
        currentThrowable _p0;
        _result = true;
    };
    case "currentvisionmode": {
        // currentVisionMode entity
        private _p0 = _args param [0];
        _result = currentVisionMode _p0;
    };
    case "currentvisionmode": {
        // currentVisionMode [entity]
        private _p0 = _args param [0];
        currentVisionMode [_p0];
        _result = true;
    };
    case "currentvisionmode": {
        // vehicle currentVisionMode turretPath
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 currentVisionMode _p1;
        _result = true;
    };
    case "currentvisionmode": {
        // unit currentVisionMode weapon
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 currentVisionMode _p1;
        _result = true;
    };
    case "currentwaypoint": {
        // currentWaypoint  groupName
        private _p0 = _args param [0];
        _result = currentWaypoint  _p0;
    };
    case "currentweapon": {
        // currentWeapon vehicle
        private _p0 = _args param [0];
        _result = currentWeapon _p0;
    };
    case "currentweaponmode": {
        // currentWeaponMode gunner
        private _p0 = _args param [0];
        _result = currentWeaponMode _p0;
    };
    case "currentweaponturret": {
        // vehicle currentWeaponTurret turretPath
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 currentWeaponTurret _p1;
    };
    case "currentzeroing": {
        // currentZeroing object
        private _p0 = _args param [0];
        _result = currentZeroing _p0;
    };
    case "currentzeroing": {
        // object currentZeroing [weaponClass, muzzleClass]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 currentZeroing [_p1, _p2];
        _result = true;
    };
    case "customchat": {
        // unit customChat [customChannelID, message]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 customChat [_p1, _p2];
        _result = true;
    };
    case "customradio": {
        // unit customRadio [customChannelID, message]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 customRadio [_p1, _p2];
        _result = true;
    };
    case "cutfadeout": {
        // layer cutFadeOut  duration
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 cutFadeOut  _p1;
        _result = true;
    };
    case "cutfadeout": {
        // layerName cutFadeOut  duration
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 cutFadeOut  _p1;
    };
    case "cutobj": {
        // cutObj [class, type, speed, showInMap]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        cutObj [_p0, _p1, _p2, _p3];
        _result = true;
    };
    case "cutobj": {
        // layer cutObj [class, type, speed, showInMap]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _p0 cutObj [_p1, _p2, _p3, _p4];
        _result = true;
    };
    case "cutobj": {
        // layerName cutObj [class, type, speed, showInMap]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = _p0 cutObj [_p1, _p2, _p3, _p4];
    };
    case "cutrsc": {
        // cutRsc [class, effect, speed, showInMap]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        cutRsc [_p0, _p1, _p2, _p3];
        _result = true;
    };
    case "cutrsc": {
        // layer cutRsc [class, effect, speed, showInMap]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _p0 cutRsc [_p1, _p2, _p3, _p4];
        _result = true;
    };
    case "cuttext": {
        // cutText [text, type, speed, showInMap, isStructuredText]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        cutText [_p0, _p1, _p2, _p3, _p4];
        _result = true;
    };
    case "cuttext": {
        // layer cutText [text, type, speed, showInMap, isStructuredText]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _p0 cutText [_p1, _p2, _p3, _p4, _p5];
        _result = true;
    };
    case "damage": {
        // damage object
        private _p0 = _args param [0];
        _result = damage _p0;
    };
    case "datetonumber": {
        // dateToNumber date
        private _p0 = _args param [0];
        _result = dateToNumber _p0;
    };
    case "deactivatekey": {
        // deActivateKey keyname
        private _p0 = _args param [0];
        deActivateKey _p0;
        _result = true;
    };
    case "debriefingtext": {
        // debriefingText end
        private _p0 = _args param [0];
        _result = debriefingText _p0;
    };
    case "debugfsm": {
        // FSMhandle debugFSM true
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 debugFSM _p1;
        _result = true;
    };
    case "debuglog": {
        // debugLog anything
        private _p0 = _args param [0];
        debugLog _p0;
        _result = true;
    };
    case "decaygraphvalues": {
        // decayGraphValues [lowerBoundValues, graphValues, coef]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        decayGraphValues [_p0, _p1, _p2];
        _result = true;
    };
    case "default": {
        // default a
        private _p0 = _args param [0];
        default _p0;
        _result = true;
    };
    case "deg": {
        // deg value
        private _p0 = _args param [0];
        _result = deg _p0;
    };
    case "detectedmines": {
        // detectedMines side
        private _p0 = _args param [0];
        _result = detectedMines _p0;
    };
    case "diarysubjectexists": {
        // player diarySubjectExists  name
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 diarySubjectExists  _p1;
    };
    case "didjipowner": {
        // didJIPOwner  object
        private _p0 = _args param [0];
        _result = didJIPOwner  _p0;
    };
    case "difficultyenabled": {
        // difficultyEnabled  flagName
        private _p0 = _args param [0];
        _result = difficultyEnabled  _p0;
    };
    case "difficultyoption": {
        // difficultyOption optionName
        private _p0 = _args param [0];
        _result = difficultyOption _p0;
    };
    case "direction": {
        // direction object
        private _p0 = _args param [0];
        direction _p0;
        _result = true;
    };
    case "directionstabilizationenabled": {
        // vehicle directionStabilizationEnabled turretPath
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 directionStabilizationEnabled _p1;
    };
    case "directsay": {
        // unit directSay radioName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 directSay _p1;
        _result = true;
    };
    case "dissolveteam": {
        // dissolveTeam teamColor
        private _p0 = _args param [0];
        dissolveTeam _p0;
        _result = true;
    };
    case "distance": {
        // param1 distance param2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 distance _p1;
    };
    case "distance": {
        // location1 distance location2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 distance _p1;
    };
    case "distance2d": {
        // from distance2D to
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 distance2D _p1;
    };
    case "distancesqr": {
        // var1 distanceSqr var2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 distanceSqr _p1;
        _result = true;
    };
    case "driver": {
        // driver vehicle
        private _p0 = _args param [0];
        driver _p0;
        _result = true;
    };
    case "drop": {
        // drop parameters
        private _p0 = _args param [0];
        drop _p0;
        _result = true;
    };
    case "dynamicsimulationdistance": {
        // dynamicSimulationDistance  category
        private _p0 = _args param [0];
        _result = dynamicSimulationDistance  _p0;
    };
    case "dynamicsimulationdistancecoef": {
        // dynamicSimulationDistanceCoef class
        private _p0 = _args param [0];
        _result = dynamicSimulationDistanceCoef _p0;
    };
    case "dynamicsimulationenabled": {
        // dynamicSimulationEnabled object
        private _p0 = _args param [0];
        _result = dynamicSimulationEnabled _p0;
    };
    case "echo": {
        // echo  text
        private _p0 = _args param [0];
        echo  _p0;
        _result = true;
    };
    case "edit3denmissionattributes": {
        // edit3DENMissionAttributes  section
        private _p0 = _args param [0];
        edit3DENMissionAttributes  _p0;
        _result = true;
    };
    case "editobject": {
        // map editObject object
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 editObject _p1;
    };
    case "effectivecommander": {
        // effectiveCommander vehicle
        private _p0 = _args param [0];
        _result = effectiveCommander _p0;
    };
    case "elevateperiscope": {
        // vehicle elevatePeriscope [turret, elevation, speed, blockUserInput]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _p0 elevatePeriscope [_p1, _p2, _p3, _p4];
        _result = true;
    };
    case "else": {
        // ifCode else  elseCode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 else  _p1;
    };
    case "emptypositions": {
        // vehicle emptyPositions position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 emptyPositions _p1;
    };
    case "endmission": {
        // endMission endType
        private _p0 = _args param [0];
        endMission _p0;
        _result = true;
    };
    case "engineon": {
        // vehicle engineOn state
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 engineOn _p1;
        _result = true;
    };
    case "enginesisonrtd": {
        // enginesIsOnRTD RTD_helicopter
        private _p0 = _args param [0];
        enginesIsOnRTD _p0;
        _result = true;
    };
    case "enginespowerrtd": {
        // enginesPowerRTD RTD_helicopter
        private _p0 = _args param [0];
        _result = enginesPowerRTD _p0;
    };
    case "enginesrpmrtd": {
        // enginesRpmRTD RTD_helicopter
        private _p0 = _args param [0];
        _result = enginesRpmRTD _p0;
    };
    case "enginestorquertd": {
        // enginesTorqueRTD RTD_helicopter
        private _p0 = _args param [0];
        _result = enginesTorqueRTD _p0;
    };
    case "entities": {
        // entities type
        private _p0 = _args param [0];
        _result = entities _p0;
    };
    case "entities": {
        // entities [typesInclude, typesExclude, includeCrews, excludeDead]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = entities [_p0, _p1, _p2, _p3];
    };
    case "equipmentdisabled": {
        // equipmentDisabled vehicle
        private _p0 = _args param [0];
        equipmentDisabled _p0;
        _result = true;
    };
    case "estimatedtimeleft": {
        // estimatedTimeLeft seconds
        private _p0 = _args param [0];
        estimatedTimeLeft _p0;
        _result = true;
    };
    case "everybackpack": {
        // everyBackpack box
        private _p0 = _args param [0];
        _result = everyBackpack _p0;
    };
    case "everycontainer": {
        // everyContainer object
        private _p0 = _args param [0];
        _result = everyContainer _p0;
    };
    case "exec": {
        // argument exec script
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 exec _p1;
        _result = true;
    };
    case "execfsm": {
        // arguments execFSM fsmFilePath
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 execFSM _p1;
    };
    case "execfsm": {
        // execFSM fsmFilePath
        private _p0 = _args param [0];
        _result = execFSM _p0;
    };
    case "execvm": {
        // arguments execVM filename
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 execVM _p1;
        _result = true;
    };
    case "execvm": {
        // execVM filename
        private _p0 = _args param [0];
        execVM _p0;
        _result = true;
    };
    case "exitwith": {
        // ifType exitWith code
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 exitWith _p1;
    };
    case "exp": {
        // exp x
        private _p0 = _args param [0];
        _result = exp _p0;
    };
    case "expecteddestination": {
        // expectedDestination person
        private _p0 = _args param [0];
        expectedDestination _p0;
        _result = true;
    };
    case "exportjipmessages": {
        // exportJIPMessages fileName
        private _p0 = _args param [0];
        exportJIPMessages _p0;
        _result = true;
    };
    case "exportlandscapexyz": {
        // exportLandscapeXYZ filename
        private _p0 = _args param [0];
        exportLandscapeXYZ _p0;
        _result = true;
    };
    case "eyedirection": {
        // eyeDirection unit
        private _p0 = _args param [0];
        _result = eyeDirection _p0;
    };
    case "eyepos": {
        // eyePos object
        private _p0 = _args param [0];
        _result = eyePos _p0;
    };
    case "face": {
        // face person
        private _p0 = _args param [0];
        _result = face _p0;
    };
    case "faction": {
        // faction unitName
        private _p0 = _args param [0];
        _result = faction _p0;
    };
    case "fadeenvironment": {
        // time fadeEnvironment volume
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 fadeEnvironment _p1;
        _result = true;
    };
    case "fademusic": {
        // time fadeMusic  volume
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 fadeMusic  _p1;
        _result = true;
    };
    case "faderadio": {
        // time fadeRadio  volume
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 fadeRadio  _p1;
        _result = true;
    };
    case "fadesound": {
        // time fadeSound  volume
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 fadeSound  _p1;
        _result = true;
    };
    case "fadespeech": {
        // time fadeSpeech  volume
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 fadeSpeech  _p1;
        _result = true;
    };
    case "failmission": {
        // failMission endtype
        private _p0 = _args param [0];
        failMission _p0;
        _result = true;
    };
    case "fileexists": {
        // fileExists path
        private _p0 = _args param [0];
        _result = fileExists _p0;
    };
    case "fillweaponsfrompool": {
        // fillWeaponsFromPool  unit
        private _p0 = _args param [0];
        fillWeaponsFromPool  _p0;
        _result = true;
    };
    case "finite": {
        // finite number
        private _p0 = _args param [0];
        _result = finite _p0;
    };
    case "fire": {
        // unit fire muzzle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 fire _p1;
        _result = true;
    };
    case "fire": {
        // unit fire [muzzle, mode, magazine]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 fire [_p1, _p2, _p3];
        _result = true;
    };
    case "fireattarget": {
        // sourceVehicle fireAtTarget [targetVehicle, weaponMuzzleName]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 fireAtTarget [_p1, _p2];
    };
    case "firstbackpack": {
        // firstBackpack box
        private _p0 = _args param [0];
        _result = firstBackpack _p0;
    };
    case "flag": {
        // flag unit
        private _p0 = _args param [0];
        _result = flag _p0;
    };
    case "flaganimationphase": {
        // flagAnimationPhase  flag
        private _p0 = _args param [0];
        _result = flagAnimationPhase  _p0;
    };
    case "flagowner": {
        // flagOwner  flag
        private _p0 = _args param [0];
        _result = flagOwner  _p0;
    };
    case "flagside": {
        // flagSide flag
        private _p0 = _args param [0];
        _result = flagSide _p0;
    };
    case "flagtexture": {
        // flagTexture flagCarrier
        private _p0 = _args param [0];
        _result = flagTexture _p0;
    };
    case "flatten": {
        // flatten array
        private _p0 = _args param [0];
        _result = flatten _p0;
    };
    case "fleeing": {
        // fleeing  unit
        private _p0 = _args param [0];
        _result = fleeing  _p0;
    };
    case "floor": {
        // floor num
        private _p0 = _args param [0];
        _result = floor _p0;
    };
    case "flyinheight": {
        // aircraft flyInHeight altitude
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 flyInHeight _p1;
        _result = true;
    };
    case "flyinheightasl": {
        // aircraft flyInHeightASL [standardAltitude, combatAltitude, stealthAltitude]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 flyInHeightASL [_p1, _p2, _p3];
        _result = true;
    };
    case "focusedctrl": {
        // focusedCtrl display
        private _p0 = _args param [0];
        _result = focusedCtrl _p0;
    };
    case "for": {
        // for arguments
        private _p0 = _args param [0];
        for _p0;
        _result = true;
    };
    case "for": {
        // for [init, condition, codeToExecute]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        for [_p0, _p1, _p2];
        _result = true;
    };
    case "forceadduniform": {
        // unit forceAddUniform type
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 forceAddUniform _p1;
        _result = true;
    };
    case "forceatpositionrtd": {
        // forceAtPositionRTD position
        private _p0 = _args param [0];
        _result = forceAtPositionRTD _p0;
    };
    case "forcecadetdifficulty": {
        // forceCadetDifficulty [showCadetHints, showCadetWP]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        forceCadetDifficulty [_p0, _p1];
        _result = true;
    };
    case "forceflagtexture": {
        // object forceFlagTexture texture
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 forceFlagTexture _p1;
        _result = true;
    };
    case "forcefollowroad": {
        // vehicle forceFollowRoad state
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 forceFollowRoad _p1;
        _result = true;
    };
    case "forcegeneratorrtd": {
        // forceGeneratorRTD index
        private _p0 = _args param [0];
        _result = forceGeneratorRTD _p0;
    };
    case "forcemap": {
        // forceMap show
        private _p0 = _args param [0];
        forceMap _p0;
        _result = true;
    };
    case "forcerespawn": {
        // forceRespawn unit
        private _p0 = _args param [0];
        forceRespawn _p0;
        _result = true;
    };
    case "forcespeed": {
        // object forceSpeed speed
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 forceSpeed _p1;
        _result = true;
    };
    case "forceunicode": {
        // forceUnicode mode
        private _p0 = _args param [0];
        _result = forceUnicode _p0;
    };
    case "forcewalk": {
        // unit forceWalk value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 forceWalk _p1;
        _result = true;
    };
    case "forceweaponfire": {
        // unit forceWeaponFire [muzzle, firemode]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 forceWeaponFire [_p1, _p2];
        _result = true;
    };
    case "foreach": {
        // code forEach array
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 forEach _p1;
    };
    case "foreach": {
        // code forEach hashMap
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 forEach _p1;
    };
    case "foreachmember": {
        // command forEachMember team
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 forEachMember _p1;
        _result = true;
    };
    case "foreachmemberagent": {
        // command forEachMemberAgent team
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 forEachMemberAgent _p1;
        _result = true;
    };
    case "foreachmemberteam": {
        // command forEachMemberTeam team
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 forEachMemberTeam _p1;
        _result = true;
    };
    case "forgettarget": {
        // group forgetTarget target
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 forgetTarget _p1;
        _result = true;
    };
    case "format": {
        // format [formatString, var1, var2, ...]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = format [_p0, _p1, _p2, ...];
    };
    case "formation": {
        // formation  target
        private _p0 = _args param [0];
        _result = formation  _p0;
    };
    case "formationdirection": {
        // formationDirection unitName
        private _p0 = _args param [0];
        _result = formationDirection _p0;
    };
    case "formationleader": {
        // formationLeader unitName
        private _p0 = _args param [0];
        _result = formationLeader _p0;
    };
    case "formationmembers": {
        // formationMembers person
        private _p0 = _args param [0];
        _result = formationMembers _p0;
    };
    case "formationposition": {
        // formationPosition unit
        private _p0 = _args param [0];
        _result = formationPosition _p0;
    };
    case "formationtask": {
        // formationTask unit
        private _p0 = _args param [0];
        formationTask _p0;
        _result = true;
    };
    case "formleader": {
        // formLeader unitName
        private _p0 = _args param [0];
        _result = formLeader _p0;
    };
    case "freeextension": {
        // freeExtension extension
        private _p0 = _args param [0];
        freeExtension _p0;
        _result = true;
    };
    case "from": {
        // for from b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 from _p1;
        _result = true;
    };
    case "fromeditor": {
        // fromEditor teamMember
        private _p0 = _args param [0];
        _result = fromEditor _p0;
    };
    case "fuel": {
        // fuel vehicle
        private _p0 = _args param [0];
        _result = fuel _p0;
    };
    case "fullcrew": {
        // fullCrew vehicle
        private _p0 = _args param [0];
        fullCrew _p0;
        _result = true;
    };
    case "fullcrew": {
        // fullCrew [vehicle, type, includeEmpty]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        fullCrew [_p0, _p1, _p2];
        _result = true;
    };
    case "gearidcammocount": {
        // gearIDCAmmoCount idc
        private _p0 = _args param [0];
        _result = gearIDCAmmoCount _p0;
    };
    case "gearslotammocount": {
        // gearSlotAmmoCount control
        private _p0 = _args param [0];
        _result = gearSlotAmmoCount _p0;
    };
    case "gearslotdata": {
        // gearSlotData control
        private _p0 = _args param [0];
        _result = gearSlotData _p0;
    };
    case "gesturestate": {
        // gestureState unitName
        private _p0 = _args param [0];
        _result = gestureState _p0;
    };
    case "globalchat": {
        // unitName globalChat chatText
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 globalChat _p1;
        _result = true;
    };
    case "globalradio": {
        // unit globalRadio radioName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 globalRadio _p1;
        _result = true;
    };
    case "goggles": {
        // goggles unit
        private _p0 = _args param [0];
        _result = goggles _p0;
    };
    case "goto": {
        // goto label
        private _p0 = _args param [0];
        goto _p0;
        _result = true;
    };
    case "gunner": {
        // gunner  vehicle
        private _p0 = _args param [0];
        _result = gunner  _p0;
    };
    case "handgunitems": {
        // handgunItems unit
        private _p0 = _args param [0];
        _result = handgunItems _p0;
    };
    case "handgunmagazine": {
        // handgunMagazine unit
        private _p0 = _args param [0];
        _result = handgunMagazine _p0;
    };
    case "handgunweapon": {
        // handgunWeapon unit
        private _p0 = _args param [0];
        _result = handgunWeapon _p0;
    };
    case "handshit": {
        // handsHit unitName
        private _p0 = _args param [0];
        _result = handsHit _p0;
    };
    case "hcallgroups": {
        // hcAllGroups unit
        private _p0 = _args param [0];
        _result = hcAllGroups _p0;
    };
    case "hcgroupparams": {
        // unit hcGroupParams group
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 hcGroupParams _p1;
    };
    case "hcleader": {
        // hcLeader group
        private _p0 = _args param [0];
        _result = hcLeader _p0;
    };
    case "hcremoveallgroups": {
        // hcRemoveAllGroups unit
        private _p0 = _args param [0];
        hcRemoveAllGroups _p0;
        _result = true;
    };
    case "hcremovegroup": {
        // unit hcRemoveGroup group
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 hcRemoveGroup _p1;
        _result = true;
    };
    case "hcselected": {
        // hcSelected unit
        private _p0 = _args param [0];
        _result = hcSelected _p0;
    };
    case "hcselectgroup": {
        // unit hcSelectGroup array
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 hcSelectGroup _p1;
        _result = true;
    };
    case "hcsetgroup": {
        // unit hcSetGroup [group, groupName, team]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 hcSetGroup [_p1, _p2, _p3];
        _result = true;
    };
    case "hcshowbar": {
        // hcShowBar bool
        private _p0 = _args param [0];
        hcShowBar _p0;
        _result = true;
    };
    case "headgear": {
        // headgear unit
        private _p0 = _args param [0];
        _result = headgear _p0;
    };
    case "hint": {
        // hint message
        private _p0 = _args param [0];
        hint _p0;
        _result = true;
    };
    case "hintc": {
        // hintC message
        private _p0 = _args param [0];
        hintC _p0;
        _result = true;
    };
    case "hintc": {
        // title hintC message
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 hintC _p1;
        _result = true;
    };
    case "hintcadet": {
        // hintCadet text
        private _p0 = _args param [0];
        hintCadet _p0;
        _result = true;
    };
    case "hintsilent": {
        // hintSilent text
        private _p0 = _args param [0];
        hintSilent _p0;
        _result = true;
    };
    case "hmd": {
        // hmd unit
        private _p0 = _args param [0];
        _result = hmd _p0;
    };
    case "hostmission": {
        // hostMission [configEntry, activeDisplay]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        hostMission [_p0, _p1];
        _result = true;
    };
    case "htmlload": {
        // control htmlLoad filename
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 htmlLoad _p1;
        _result = true;
    };
    case "if": {
        // if  condition
        private _p0 = _args param [0];
        if  _p0;
        _result = true;
    };
    case "image": {
        // image filename
        private _p0 = _args param [0];
        image _p0;
        _result = true;
    };
    case "importallgroups": {
        // importAllGroups map
        private _p0 = _args param [0];
        importAllGroups _p0;
        _result = true;
    };
    case "importance": {
        // importance location
        private _p0 = _args param [0];
        _result = importance _p0;
    };
    case "in": {
        // value in array
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 in _p1;
    };
    case "in": {
        // unit in vehicle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 in _p1;
    };
    case "in": {
        // position in location
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 in _p1;
    };
    case "in": {
        // needle in haystack
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 in _p1;
    };
    case "in": {
        // key in hashMap
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 in _p1;
    };
    case "inarea": {
        // position inArea area
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 inArea _p1;
    };
    case "inarea": {
        // position inArea [center, a, b, angle, isRectangle, c]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        _result = _p0 inArea [_p1, _p2, _p3, _p4, _p5, _p6];
    };
    case "inareaarray": {
        // positions inAreaArray area
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 inAreaArray _p1;
        _result = true;
    };
    case "inareaarray": {
        // positions inAreaArray  [center, a, b, angle, isRectangle, c]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        _p0 inAreaArray  [_p1, _p2, _p3, _p4, _p5, _p6];
        _result = true;
    };
    case "inareaarrayindexes": {
        // positions inAreaArrayIndexes area
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 inAreaArrayIndexes _p1;
        _result = true;
    };
    case "incapacitatedstate": {
        // incapacitatedState person
        private _p0 = _args param [0];
        _result = incapacitatedState _p0;
    };
    case "inflame": {
        // fireplace inflame  burn
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 inflame  _p1;
        _result = true;
    };
    case "inflamed": {
        // inflamed fireplace
        private _p0 = _args param [0];
        _result = inflamed _p0;
    };
    case "infopanel": {
        // infoPanel infoPanelId
        private _p0 = _args param [0];
        _result = infoPanel _p0;
    };
    case "infopanelcomponentenabled": {
        // unit infoPanelComponentEnabled [panelID, componentClassOrType]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 infoPanelComponentEnabled [_p1, _p2];
    };
    case "infopanelcomponentenabled": {
        // [unit, turretPath] infoPanelComponentEnabled [panelID, componentClassOrType]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1] infoPanelComponentEnabled [_p2, _p3];
    };
    case "infopanelcomponents": {
        // unit infoPanelComponents panelID
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 infoPanelComponents _p1;
        _result = true;
    };
    case "infopanelcomponents": {
        // [unit, turretPath] infoPanelComponents panelID
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1] infoPanelComponents _p2;
        _result = true;
    };
    case "infopanels": {
        // infoPanels unit
        private _p0 = _args param [0];
        infoPanels _p0;
        _result = true;
    };
    case "infopanels": {
        // infoPanels [unit, turretPath]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        infoPanels [_p0, _p1];
        _result = true;
    };
    case "ingameuiseteventhandler": {
        // inGameUISetEventHandler [handlerName, code]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        inGameUISetEventHandler [_p0, _p1];
        _result = true;
    };
    case "inheritsfrom": {
        // inheritsFrom config
        private _p0 = _args param [0];
        _result = inheritsFrom _p0;
    };
    case "inpolygon": {
        // position inPolygon polygon
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 inPolygon _p1;
    };
    case "inrangeofartillery": {
        // pos inRangeOfArtillery [units, magazineType]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 inRangeOfArtillery [_p1, _p2];
    };
    case "insert": {
        // array insert [index, valuesToInsert, onlyIfUnique]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 insert [_p1, _p2, _p3];
        _result = true;
    };
    case "insert": {
        // string insert [index, substring]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 insert [_p1, _p2];
    };
    case "insert": {
        // hashMap insert  [splitArray, [keysAndValues]]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 insert  [_p1, [_p2]];
        _result = true;
    };
    case "insidebuilding": {
        // insideBuilding man
        private _p0 = _args param [0];
        _result = insideBuilding _p0;
    };
    case "intersect": {
        // [object, lodName] intersect [begPos, endPos]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1] intersect [_p2, _p3];
        _result = true;
    };
    case "itemcargo": {
        // itemCargo object
        private _p0 = _args param [0];
        _result = itemCargo _p0;
    };
    case "items": {
        // items unit
        private _p0 = _args param [0];
        _result = items _p0;
    };
    case "itemswithmagazines": {
        // itemsWithMagazines unit
        private _p0 = _args param [0];
        _result = itemsWithMagazines _p0;
    };
    case "join": {
        // unitArray join group
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 join _p1;
        _result = true;
    };
    case "joinas": {
        // unit joinAs [group, id]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 joinAs [_p1, _p2];
        _result = true;
    };
    case "joinassilent": {
        // unit joinAsSilent [group, id]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 joinAsSilent [_p1, _p2];
        _result = true;
    };
    case "joinsilent": {
        // unitArray joinSilent group
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 joinSilent _p1;
        _result = true;
    };
    case "joinstring": {
        // array joinString separator
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 joinString _p1;
    };
    case "kbadddatabase": {
        // person kbAddDatabase fileName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 kbAddDatabase _p1;
    };
    case "kbadddatabasetargets": {
        // person kbAddDatabaseTargets fileName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 kbAddDatabaseTargets _p1;
    };
    case "kbaddtopic": {
        // person kbAddTopic [topicName, conversationFile, fsmFile, eventHandler]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _p0 kbAddTopic [_p1, _p2, _p3, _p4];
        _result = true;
    };
    case "kbhastopic": {
        // person kbHasTopic topicName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 kbHasTopic _p1;
    };
    case "kbremovetopic": {
        // person kbRemoveTopic topicName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 kbRemoveTopic _p1;
        _result = true;
    };
    case "kbwassaid": {
        // person kbWasSaid [receiver, topic, sentenceID, maxAge]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = _p0 kbWasSaid [_p1, _p2, _p3, _p4];
    };
    case "keyimage": {
        // keyImage  dikCode
        private _p0 = _args param [0];
        keyImage  _p0;
        _result = true;
    };
    case "keyname": {
        // keyName  dikCode
        private _p0 = _args param [0];
        _result = keyName  _p0;
    };
    case "keys": {
        // keys hashMap
        private _p0 = _args param [0];
        _result = keys _p0;
    };
    case "knowsabout": {
        // who knowsAbout target
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 knowsAbout _p1;
        _result = true;
    };
    case "land": {
        // helicopter land mode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 land _p1;
        _result = true;
    };
    case "landat": {
        // plane landAt ID
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 landAt _p1;
        _result = true;
    };
    case "landat": {
        // plane landAt airportObject
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 landAt _p1;
        _result = true;
    };
    case "landresult": {
        // landResult helicopter
        private _p0 = _args param [0];
        landResult _p0;
        _result = true;
    };
    case "lasertarget": {
        // laserTarget entity
        private _p0 = _args param [0];
        _result = laserTarget _p0;
    };
    case "lasertarget": {
        // vehicle laserTarget turret
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 laserTarget _p1;
    };
    case "lbadd": {
        // lbAdd [idc, text]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = lbAdd [_p0, _p1];
    };
    case "lbadd": {
        // control lbAdd text
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 lbAdd _p1;
    };
    case "lbclear": {
        // lbClear idc
        private _p0 = _args param [0];
        lbClear _p0;
        _result = true;
    };
    case "lbclear": {
        // lbClear control
        private _p0 = _args param [0];
        lbClear _p0;
        _result = true;
    };
    case "lbcolor": {
        // lbColor  [idc, index]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = lbColor  [_p0, _p1];
    };
    case "lbcolor": {
        // control lbColor  index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 lbColor  _p1;
    };
    case "lbcolorright": {
        // lbColorRight [idc, index]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = lbColorRight [_p0, _p1];
    };
    case "lbcolorright": {
        // control lbColorRight  index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 lbColorRight  _p1;
        _result = true;
    };
    case "lbcursel": {
        // lbCurSel  idc
        private _p0 = _args param [0];
        _result = lbCurSel  _p0;
    };
    case "lbcursel": {
        // lbCurSel  control
        private _p0 = _args param [0];
        _result = lbCurSel  _p0;
    };
    case "lbdata": {
        // lbData  [idc, index]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = lbData  [_p0, _p1];
    };
    case "lbdata": {
        // control lbData  index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 lbData  _p1;
    };
    case "lbdelete": {
        // lbDelete  [idc, index]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        lbDelete  [_p0, _p1];
        _result = true;
    };
    case "lbdelete": {
        // control lbDelete  index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 lbDelete  _p1;
        _result = true;
    };
    case "lbisselected": {
        // control lbIsSelected index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 lbIsSelected _p1;
    };
    case "lbpicture": {
        // lbPicture [idc, index]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = lbPicture [_p0, _p1];
    };
    case "lbpicture": {
        // control lbPicture index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 lbPicture _p1;
    };
    case "lbpictureright": {
        // lbPictureRight [idc, index]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = lbPictureRight [_p0, _p1];
    };
    case "lbpictureright": {
        // control lbPictureRight index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 lbPictureRight _p1;
    };
    case "lbselection": {
        // lbSelection control
        private _p0 = _args param [0];
        _result = lbSelection _p0;
    };
    case "lbsetcolor": {
        // lbSetColor [idc, index, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        lbSetColor [_p0, _p1, _p2];
        _result = true;
    };
    case "lbsetcolor": {
        // control lbSetColor [index, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lbSetColor [_p1, _p2];
        _result = true;
    };
    case "lbsetcolorright": {
        // lbSetColorRight  [idc, index, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        lbSetColorRight  [_p0, _p1, _p2];
        _result = true;
    };
    case "lbsetcolorright": {
        // control lbSetColorRight  [index, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lbSetColorRight  [_p1, _p2];
        _result = true;
    };
    case "lbsetcursel": {
        // lbSetCurSel [idc, index]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        lbSetCurSel [_p0, _p1];
        _result = true;
    };
    case "lbsetcursel": {
        // control lbSetCurSel  index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 lbSetCurSel  _p1;
        _result = true;
    };
    case "lbsetdata": {
        // lbSetData [idc, index, data]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        lbSetData [_p0, _p1, _p2];
        _result = true;
    };
    case "lbsetdata": {
        // control lbSetData [index, data]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lbSetData [_p1, _p2];
        _result = true;
    };
    case "lbsetpicture": {
        // lbSetPicture [idc, index, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        lbSetPicture [_p0, _p1, _p2];
        _result = true;
    };
    case "lbsetpicture": {
        // control lbSetPicture  [index, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lbSetPicture  [_p1, _p2];
        _result = true;
    };
    case "lbsetpicturecolor": {
        // lbSetPictureColor [idc, index, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        lbSetPictureColor [_p0, _p1, _p2];
        _result = true;
    };
    case "lbsetpicturecolor": {
        // control lbSetPictureColor  [index, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lbSetPictureColor  [_p1, _p2];
        _result = true;
    };
    case "lbsetpicturecolordisabled": {
        // lbSetPictureColorDisabled [idc, index, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        lbSetPictureColorDisabled [_p0, _p1, _p2];
        _result = true;
    };
    case "lbsetpicturecolordisabled": {
        // control lbSetPictureColorDisabled  [index, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lbSetPictureColorDisabled  [_p1, _p2];
        _result = true;
    };
    case "lbsetpicturecolorselected": {
        // lbSetPictureColorSelected [idc, index, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        lbSetPictureColorSelected [_p0, _p1, _p2];
        _result = true;
    };
    case "lbsetpicturecolorselected": {
        // control lbSetPictureColorSelected [index, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lbSetPictureColorSelected [_p1, _p2];
        _result = true;
    };
    case "lbsetpictureright": {
        // lbSetPictureRight [idc, index, name]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        lbSetPictureRight [_p0, _p1, _p2];
        _result = true;
    };
    case "lbsetpictureright": {
        // control lbSetPictureRight [index, name]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lbSetPictureRight [_p1, _p2];
        _result = true;
    };
    case "lbsetpicturerightcolor": {
        // lbSetPictureRightColor [idc, index, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        lbSetPictureRightColor [_p0, _p1, _p2];
        _result = true;
    };
    case "lbsetpicturerightcolor": {
        // control lbSetPictureRightColor [index, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lbSetPictureRightColor [_p1, _p2];
        _result = true;
    };
    case "lbsetpicturerightcolordisabled": {
        // lbSetPictureRightColorDisabled [idc, index, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        lbSetPictureRightColorDisabled [_p0, _p1, _p2];
        _result = true;
    };
    case "lbsetpicturerightcolordisabled": {
        // control lbSetPictureRightColorDisabled  [index, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lbSetPictureRightColorDisabled  [_p1, _p2];
        _result = true;
    };
    case "lbsetpicturerightcolorselected": {
        // lbSetPictureRightColorSelected [idc, index, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        lbSetPictureRightColorSelected [_p0, _p1, _p2];
        _result = true;
    };
    case "lbsetpicturerightcolorselected": {
        // control lbSetPictureRightColorSelected [index, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lbSetPictureRightColorSelected [_p1, _p2];
        _result = true;
    };
    case "lbsetselectcolor": {
        // lbSetSelectColor  [idc, index, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        lbSetSelectColor  [_p0, _p1, _p2];
        _result = true;
    };
    case "lbsetselectcolor": {
        // control lbSetSelectColor [index, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lbSetSelectColor [_p1, _p2];
        _result = true;
    };
    case "lbsetselectcolorright": {
        // lbSetSelectColorRight [idc, index, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        lbSetSelectColorRight [_p0, _p1, _p2];
        _result = true;
    };
    case "lbsetselectcolorright": {
        // control lbSetSelectColorRight [index, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lbSetSelectColorRight [_p1, _p2];
        _result = true;
    };
    case "lbsettext": {
        // lbSetText [idc, index, name]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        lbSetText [_p0, _p1, _p2];
        _result = true;
    };
    case "lbsettext": {
        // control lbSetText [index, name]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lbSetText [_p1, _p2];
        _result = true;
    };
    case "lbsettextright": {
        // control lbSetTextRight [row, name]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lbSetTextRight [_p1, _p2];
        _result = true;
    };
    case "lbsettooltip": {
        // lbSetTooltip [idc, index, tooltip]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        lbSetTooltip [_p0, _p1, _p2];
        _result = true;
    };
    case "lbsettooltip": {
        // control lbSetTooltip [index, tooltip]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lbSetTooltip [_p1, _p2];
        _result = true;
    };
    case "lbsetvalue": {
        // lbSetValue  [idc, index, value]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        lbSetValue  [_p0, _p1, _p2];
        _result = true;
    };
    case "lbsetvalue": {
        // control lbSetValue  [index, value]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lbSetValue  [_p1, _p2];
        _result = true;
    };
    case "lbsize": {
        // lbSize  idc
        private _p0 = _args param [0];
        _result = lbSize  _p0;
    };
    case "lbsize": {
        // lbSize  control
        private _p0 = _args param [0];
        _result = lbSize  _p0;
    };
    case "lbsort": {
        // lbSort control
        private _p0 = _args param [0];
        lbSort _p0;
        _result = true;
    };
    case "lbsort": {
        // lbSort [control, sortOrder]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        lbSort [_p0, _p1];
        _result = true;
    };
    case "lbsort": {
        // lbSort idc
        private _p0 = _args param [0];
        lbSort _p0;
        _result = true;
    };
    case "lbsort": {
        // lbSort [idc, sortOrder]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        lbSort [_p0, _p1];
        _result = true;
    };
    case "lbsortby": {
        // controlOrIDC lbSortBy [sortByType, reversedOrder, caseSensitive, useTextRight, unicodeOff]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _p0 lbSortBy [_p1, _p2, _p3, _p4, _p5];
        _result = true;
    };
    case "lbsortbyvalue": {
        // lbSortByValue  control
        private _p0 = _args param [0];
        lbSortByValue  _p0;
        _result = true;
    };
    case "lbsortbyvalue": {
        // lbSortByValue  idc
        private _p0 = _args param [0];
        lbSortByValue  _p0;
        _result = true;
    };
    case "lbtext": {
        // lbText [idc, index]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = lbText [_p0, _p1];
    };
    case "lbtext": {
        // control lbText index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 lbText _p1;
    };
    case "lbtextright": {
        // lbTextRight [idc, index]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = lbTextRight [_p0, _p1];
    };
    case "lbtextright": {
        // control lbTextRight index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 lbTextRight _p1;
    };
    case "lbtooltip": {
        // lbTooltip [idc, index]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = lbTooltip [_p0, _p1];
    };
    case "lbtooltip": {
        // control lbTooltip index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 lbTooltip _p1;
    };
    case "lbvalue": {
        // lbValue  [idc, index]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = lbValue  [_p0, _p1];
    };
    case "lbvalue": {
        // control lbValue  index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 lbValue  _p1;
    };
    case "leader": {
        // leader  unitOrGroup
        private _p0 = _args param [0];
        _result = leader  _p0;
    };
    case "leaderboarddeinit": {
        // leaderboardDeInit boardName
        private _p0 = _args param [0];
        _result = leaderboardDeInit _p0;
    };
    case "leaderboardgetrows": {
        // leaderboardGetRows boardName
        private _p0 = _args param [0];
        leaderboardGetRows _p0;
        _result = true;
    };
    case "leaderboardinit": {
        // leaderboardInit boardName
        private _p0 = _args param [0];
        _result = leaderboardInit _p0;
    };
    case "leaderboardrequestrowsfriends": {
        // leaderboardRequestRowsFriends  boardName
        private _p0 = _args param [0];
        _result = leaderboardRequestRowsFriends  _p0;
    };
    case "leaderboardrequestrowsglobal": {
        // leaderboardRequestRowsGlobal [leaderboard, offset, rows]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = leaderboardRequestRowsGlobal [_p0, _p1, _p2];
    };
    case "leaderboardrequestrowsglobalarounduser": {
        // leaderboardRequestRowsGlobalAroundUser [leaderboard, offset, rows]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = leaderboardRequestRowsGlobalAroundUser [_p0, _p1, _p2];
    };
    case "leaderboardstate": {
        // leaderboardState boardname
        private _p0 = _args param [0];
        leaderboardState _p0;
        _result = true;
    };
    case "leavevehicle": {
        // group leaveVehicle vehicle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 leaveVehicle _p1;
        _result = true;
    };
    case "lifestate": {
        // lifeState unit
        private _p0 = _args param [0];
        _result = lifeState _p0;
    };
    case "lightattachobject": {
        // light lightAttachObject [object, position]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lightAttachObject [_p1, _p2];
        _result = true;
    };
    case "lightdetachobject": {
        // lightDetachObject light
        private _p0 = _args param [0];
        lightDetachObject _p0;
        _result = true;
    };
    case "lightison": {
        // lightIsOn lamppost
        private _p0 = _args param [0];
        lightIsOn _p0;
        _result = true;
    };
    case "limitspeed": {
        // objectName limitSpeed speed
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 limitSpeed _p1;
        _result = true;
    };
    case "linearconversion": {
        // linearConversion  [minFrom, maxFrom, value, minTo, maxTo, clip]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _result = linearConversion  [_p0, _p1, _p2, _p3, _p4, _p5];
    };
    case "lineintersects": {
        // lineIntersects [begPos, endPos, objIgnore1, objIgnore2]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = lineIntersects [_p0, _p1, _p2, _p3];
    };
    case "lineintersectsobjs": {
        // lineIntersectsObjs [begPos, endPos, ignoreObj1, ignoreObj2, sortByDistance, flags]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        lineIntersectsObjs [_p0, _p1, _p2, _p3, _p4, _p5];
        _result = true;
    };
    case "lineintersectssurfaces": {
        // lineIntersectsSurfaces [begPosASL, endPosASL, ignoreObj1, ignoreObj2, sortMode, maxResults, LOD1, LOD2, returnUnique]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        private _p7 = _args param [7];
        private _p8 = _args param [8];
        lineIntersectsSurfaces [_p0, _p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8];
        _result = true;
    };
    case "lineintersectswith": {
        // lineIntersectsWith [begPos, endPos, objIgnore1, objIgnore2, sortByDistance]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = lineIntersectsWith [_p0, _p1, _p2, _p3, _p4];
    };
    case "linkitem": {
        // unit linkItem item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 linkItem _p1;
        _result = true;
    };
    case "list": {
        // list trigger
        private _p0 = _args param [0];
        list _p0;
        _result = true;
    };
    case "listobjects": {
        // map listObjects type
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 listObjects _p1;
    };
    case "listremotetargets": {
        // listRemoteTargets side
        private _p0 = _args param [0];
        listRemoteTargets _p0;
        _result = true;
    };
    case "listvehiclesensors": {
        // listVehicleSensors vehicle
        private _p0 = _args param [0];
        listVehicleSensors _p0;
        _result = true;
    };
    case "ln": {
        // ln  x
        private _p0 = _args param [0];
        _result = ln  _p0;
    };
    case "lnbaddarray": {
        // lnbAddArray [idc, arrayOfTextAndValues]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = lnbAddArray [_p0, _p1];
    };
    case "lnbaddcolumn": {
        // control lnbAddColumn position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 lnbAddColumn _p1;
        _result = true;
    };
    case "lnbaddcolumn": {
        // lnbAddColumn [controlOrIdc, position]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        lnbAddColumn [_p0, _p1];
        _result = true;
    };
    case "lnbaddrow": {
        // lnbAddRow [idc, data]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = lnbAddRow [_p0, _p1];
    };
    case "lnbaddrow": {
        // ctrl lnbAddRow data
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 lnbAddRow _p1;
    };
    case "lnbclear": {
        // lnbClear idc
        private _p0 = _args param [0];
        lnbClear _p0;
        _result = true;
    };
    case "lnbclear": {
        // lnbClear ctrl
        private _p0 = _args param [0];
        lnbClear _p0;
        _result = true;
    };
    case "lnbcolor": {
        // lnbColor [idc, [row, column]]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = lnbColor [_p0, [_p1, _p2]];
    };
    case "lnbcolor": {
        // control lnbColor [row, column]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 lnbColor [_p1, _p2];
    };
    case "lnbcolorright": {
        // lnbColorRight [idc, [row, column]]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = lnbColorRight [_p0, [_p1, _p2]];
    };
    case "lnbcolorright": {
        // ctrl lnbColorRight [row, column]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 lnbColorRight [_p1, _p2];
    };
    case "lnbcurselrow": {
        // lnbCurSelRow idc
        private _p0 = _args param [0];
        _result = lnbCurSelRow _p0;
    };
    case "lnbcurselrow": {
        // lnbCurSelRow ctrl
        private _p0 = _args param [0];
        _result = lnbCurSelRow _p0;
    };
    case "lnbdata": {
        // lnbData [idc, [row, column]]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = lnbData [_p0, [_p1, _p2]];
    };
    case "lnbdata": {
        // ctrl lnbData [row, column]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 lnbData [_p1, _p2];
    };
    case "lnbdeletecolumn": {
        // lnbDeleteColumn [idc, index]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        lnbDeleteColumn [_p0, _p1];
        _result = true;
    };
    case "lnbdeletecolumn": {
        // ctrl lnbDeleteColumn index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 lnbDeleteColumn _p1;
        _result = true;
    };
    case "lnbdeleterow": {
        // _ctrl lnbDeleteRow row
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 lnbDeleteRow _p1;
        _result = true;
    };
    case "lnbgetcolumnsposition": {
        // lnbGetColumnsPosition _ctrl
        private _p0 = _args param [0];
        _result = lnbGetColumnsPosition _p0;
    };
    case "lnbpicture": {
        // lnbPicture [idc, [row, column]]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = lnbPicture [_p0, [_p1, _p2]];
    };
    case "lnbpictureright": {
        // lnbPictureRight [idc, [row, column]]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = lnbPictureRight [_p0, [_p1, _p2]];
    };
    case "lnbpictureright": {
        // ctrl lnbPictureRight [row, column]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 lnbPictureRight [_p1, _p2];
    };
    case "lnbsetcolor": {
        // lnbSetColor [idc, [row, column], color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        lnbSetColor [_p0, [_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsetcolor": {
        // ctrl lnbSetColor [[row, column], color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 lnbSetColor [[_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsetcolorright": {
        // lnbSetColorRight [idc, [row, column], color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        lnbSetColorRight [_p0, [_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsetcolorright": {
        // ctrl lnbSetColorRight [[row, column], color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 lnbSetColorRight [[_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsetcolumnspos": {
        // lnbSetColumnsPos [idc, positions]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        lnbSetColumnsPos [_p0, _p1];
        _result = true;
    };
    case "lnbsetcolumnspos": {
        // ctrl lnbSetColumnsPos positions
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 lnbSetColumnsPos _p1;
        _result = true;
    };
    case "lnbsetcurselrow": {
        // lnbSetCurSelRow [idc, index]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        lnbSetCurSelRow [_p0, _p1];
        _result = true;
    };
    case "lnbsetcurselrow": {
        // ctrl lnbSetCurSelRow index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 lnbSetCurSelRow _p1;
        _result = true;
    };
    case "lnbsetdata": {
        // lnbSetData [idc, [row, column], data]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        lnbSetData [_p0, [_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsetdata": {
        // ctrl lnbSetData [[row, column], data]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 lnbSetData [[_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsetpicture": {
        // lnbSetPicture [idc, [row, column], picturePathOrName]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        lnbSetPicture [_p0, [_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsetpicture": {
        // ctrl lnbSetPicture [[row, column], picturePathOrName]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 lnbSetPicture [[_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsetpicturecolor": {
        // lnbSetPictureColor [idc, [row, column], colour]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        lnbSetPictureColor [_p0, [_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsetpicturecolor": {
        // ctrl lnbSetPictureColor [[row, column], colour]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 lnbSetPictureColor [[_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsetpicturecolorright": {
        // lnbSetPictureColorRight [idc, [row, column], color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        lnbSetPictureColorRight [_p0, [_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsetpicturecolorright": {
        // ctrl lnbSetPictureColorRight [[row, column], color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 lnbSetPictureColorRight [[_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsetpicturecolorselected": {
        // lnbSetPictureColorSelected [idc, [row, column], colour]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        lnbSetPictureColorSelected [_p0, [_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsetpicturecolorselected": {
        // ctrl lnbSetPictureColorSelected [[row, column], colour]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 lnbSetPictureColorSelected [[_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsetpicturecolorselectedright": {
        // lnbSetPictureColorSelectedRight [idc, [row, column], color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        lnbSetPictureColorSelectedRight [_p0, [_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsetpicturecolorselectedright": {
        // ctrl lnbSetPictureColorSelectedRight [[row, column], color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 lnbSetPictureColorSelectedRight [[_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsetpictureright": {
        // lnbSetPictureRight [idc, [row, column], path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        lnbSetPictureRight [_p0, [_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsetpictureright": {
        // ctrl lnbSetPicture [[row, column], path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 lnbSetPicture [[_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsettext": {
        // lnbSetText [idc, [row, column], data]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        lnbSetText [_p0, [_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsettext": {
        // ctrl lnbSetText [[row, column], data]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 lnbSetText [[_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsettextright": {
        // lnbSetTextRight [idc, [row, column], text]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        lnbSetTextRight [_p0, [_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsettextright": {
        // ctrl lnbSetTextRight [[row, column], text]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 lnbSetTextRight [[_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsettooltip": {
        // lnbSetTooltip [idc, [row, column], text]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        lnbSetTooltip [_p0, [_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsettooltip": {
        // ctrl lnbSetTooltip [[row, column], text]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 lnbSetTooltip [[_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsetvalue": {
        // lnbSetValue [idc, [row, column], value]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        lnbSetValue [_p0, [_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsetvalue": {
        // control lnbSetValue [[row, column], value]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 lnbSetValue [[_p1, _p2], _p3];
        _result = true;
    };
    case "lnbsize": {
        // lnbSize controlOrIDC
        private _p0 = _args param [0];
        _result = lnbSize _p0;
    };
    case "lnbsort": {
        // lnbSort [idc, column, reversed]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        lnbSort [_p0, _p1, _p2];
        _result = true;
    };
    case "lnbsort": {
        // control lnbSort  [column, reversed]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lnbSort  [_p1, _p2];
        _result = true;
    };
    case "lnbsortby": {
        // [controlOrIDC, column] lnbSortBy [sortByType, reversedOrder, caseSensitive, useTextRight,  unicodeOff]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        [_p0, _p1] lnbSortBy [_p2, _p3, _p4, _p5,  _p6];
        _result = true;
    };
    case "lnbsortbyvalue": {
        // lnbSortByValue [idc, column, reversed]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        lnbSortByValue [_p0, _p1, _p2];
        _result = true;
    };
    case "lnbsortbyvalue": {
        // control lnbSortByValue [column, reversed]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lnbSortByValue [_p1, _p2];
        _result = true;
    };
    case "lnbtext": {
        // control lnbText [row, column]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 lnbText [_p1, _p2];
    };
    case "lnbtextright": {
        // lnbTextRight [idc, [row, column]]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = lnbTextRight [_p0, [_p1, _p2]];
    };
    case "lnbtextright": {
        // ctrl lnbTextRight [row, column]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 lnbTextRight [_p1, _p2];
    };
    case "lnbvalue": {
        // lnbValue [idc, [row, column]]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = lnbValue [_p0, [_p1, _p2]];
    };
    case "lnbvalue": {
        // ctrl lnbValue [row, column]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 lnbValue [_p1, _p2];
    };
    case "load": {
        // load unit
        private _p0 = _args param [0];
        _result = load _p0;
    };
    case "loadabs": {
        // loadAbs unit
        private _p0 = _args param [0];
        _result = loadAbs _p0;
    };
    case "loadbackpack": {
        // loadBackpack unit
        private _p0 = _args param [0];
        _result = loadBackpack _p0;
    };
    case "loadconfig": {
        // loadConfig path
        private _p0 = _args param [0];
        _result = loadConfig _p0;
    };
    case "loadcuratorselectionpreset": {
        // loadCuratorSelectionPreset numkey
        private _p0 = _args param [0];
        loadCuratorSelectionPreset _p0;
        _result = true;
    };
    case "loadfile": {
        // loadFile fileName
        private _p0 = _args param [0];
        _result = loadFile _p0;
    };
    case "loadidentity": {
        // unit loadIdentity  name
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 loadIdentity  _p1;
    };
    case "loadmagazine": {
        // transport loadMagazine [turretPath, weaponName, magazineName]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 loadMagazine [_p1, _p2, _p3];
        _result = true;
    };
    case "loadoverlay": {
        // map loadOverlay config
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 loadOverlay _p1;
        _result = true;
    };
    case "loadstatus": {
        // object loadStatus  entryName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 loadStatus  _p1;
    };
    case "loaduniform": {
        // loadUniform unit
        private _p0 = _args param [0];
        _result = loadUniform _p0;
    };
    case "loadvest": {
        // loadVest unit
        private _p0 = _args param [0];
        _result = loadVest _p0;
    };
    case "local": {
        // local object
        private _p0 = _args param [0];
        _result = local _p0;
    };
    case "localize": {
        // localize stringName
        private _p0 = _args param [0];
        _result = localize _p0;
    };
    case "locationposition": {
        // locationPosition location
        private _p0 = _args param [0];
        _result = locationPosition _p0;
    };
    case "lock": {
        // vehicleName lock locked
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 lock _p1;
        _result = true;
    };
    case "lock": {
        // vehicleName lock lockstate
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 lock _p1;
        _result = true;
    };
    case "lockcamerato": {
        // vehicle lockCameraTo [target, turretPath]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lockCameraTo [_p1, _p2];
        _result = true;
    };
    case "lockcamerato": {
        // vehicle lockCameraTo [target, turretPath, temporary]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 lockCameraTo [_p1, _p2, _p3];
        _result = true;
    };
    case "lockcargo": {
        // vehicle lockCargo lock
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 lockCargo _p1;
        _result = true;
    };
    case "lockcargo": {
        // vehicle lockCargo [index, lock]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lockCargo [_p1, _p2];
        _result = true;
    };
    case "lockdriver": {
        // vehicle lockDriver lock
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 lockDriver _p1;
        _result = true;
    };
    case "locked": {
        // locked vehicle
        private _p0 = _args param [0];
        locked _p0;
        _result = true;
    };
    case "lockedcamerato": {
        // vehicle lockedCameraTo turretPath
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 lockedCameraTo _p1;
        _result = true;
    };
    case "lockedcargo": {
        // vehicle lockedCargo cargoIndex
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 lockedCargo _p1;
    };
    case "lockeddriver": {
        // lockedDriver vehicle
        private _p0 = _args param [0];
        _result = lockedDriver _p0;
    };
    case "lockedinventory": {
        // lockedInventory vehicle
        private _p0 = _args param [0];
        _result = lockedInventory _p0;
    };
    case "lockedturret": {
        // vehicle lockedTurret turretPath
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 lockedTurret _p1;
    };
    case "lockidentity": {
        // lockIdentity unit
        private _p0 = _args param [0];
        _result = lockIdentity _p0;
    };
    case "lockinventory": {
        // vehicle lockInventory lock
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 lockInventory _p1;
        _result = true;
    };
    case "lockturret": {
        // vehicle lockTurret [turretPath, lock]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 lockTurret [_p1, _p2];
        _result = true;
    };
    case "lockwp": {
        // groupName lockWP lock
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 lockWP _p1;
        _result = true;
    };
    case "log": {
        // log  x
        private _p0 = _args param [0];
        _result = log  _p0;
    };
    case "lookatpos": {
        // map lookAtPos position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 lookAtPos _p1;
        _result = true;
    };
    case "mapanimadd": {
        // mapAnimAdd [time, zoom, position]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        mapAnimAdd [_p0, _p1, _p2];
        _result = true;
    };
    case "mapcenteroncamera": {
        // mainmap mapCenterOnCamera enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 mapCenterOnCamera _p1;
        _result = true;
    };
    case "mapcenteroncamera": {
        // mapCenterOnCamera  minimap
        private _p0 = _args param [0];
        mapCenterOnCamera  _p0;
        _result = true;
    };
    case "mapgridposition": {
        // mapGridPosition param
        private _p0 = _args param [0];
        _result = mapGridPosition _p0;
    };
    case "matrixmultiply": {
        // matrix1 matrixMultiply matrix2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 matrixMultiply _p1;
    };
    case "matrixtranspose": {
        // matrixTranspose matrix
        private _p0 = _args param [0];
        _result = matrixTranspose _p0;
    };
    case "max": {
        // a max  b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 max  _p1;
    };
    case "maxload": {
        // maxLoad container
        private _p0 = _args param [0];
        _result = maxLoad _p0;
    };
    case "members": {
        // members team
        private _p0 = _args param [0];
        _result = members _p0;
    };
    case "menuaction": {
        // menuAction [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = menuAction [_p0, _p1];
    };
    case "menuaction": {
        // control menuAction path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 menuAction _p1;
    };
    case "menuadd": {
        // menuAdd [idc, path, text]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = menuAdd [_p0, _p1, _p2];
    };
    case "menuadd": {
        // control menuAdd [path, text]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 menuAdd [_p1, _p2];
    };
    case "menuchecked": {
        // control menuChecked path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 menuChecked _p1;
    };
    case "menuclear": {
        // menuClear idc
        private _p0 = _args param [0];
        menuClear _p0;
        _result = true;
    };
    case "menuclear": {
        // menuClear control
        private _p0 = _args param [0];
        menuClear _p0;
        _result = true;
    };
    case "menucollapse": {
        // menuCollapse [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        menuCollapse [_p0, _p1];
        _result = true;
    };
    case "menucollapse": {
        // control menuCollapse path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 menuCollapse _p1;
        _result = true;
    };
    case "menudata": {
        // menuData [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = menuData [_p0, _p1];
    };
    case "menudata": {
        // control menuData path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 menuData _p1;
    };
    case "menudelete": {
        // menuDelete [idc,path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        menuDelete [_p0,_p1];
        _result = true;
    };
    case "menudelete": {
        // control menuDelete path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 menuDelete _p1;
        _result = true;
    };
    case "menuenable": {
        // menuEnable [idc, path, enable]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        menuEnable [_p0, _p1, _p2];
        _result = true;
    };
    case "menuenable": {
        // control menuEnable [path, enable]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 menuEnable [_p1, _p2];
        _result = true;
    };
    case "menuenabled": {
        // menuEnabled [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = menuEnabled [_p0, _p1];
    };
    case "menuenabled": {
        // control menuEnabled path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 menuEnabled _p1;
    };
    case "menuexpand": {
        // menuExpand [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        menuExpand [_p0, _p1];
        _result = true;
    };
    case "menuexpand": {
        // control menuExpand path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 menuExpand _p1;
        _result = true;
    };
    case "menuhover": {
        // menuHover idc
        private _p0 = _args param [0];
        _result = menuHover _p0;
    };
    case "menuhover": {
        // menuHover control
        private _p0 = _args param [0];
        _result = menuHover _p0;
    };
    case "menupicture": {
        // menuPicture [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = menuPicture [_p0, _p1];
    };
    case "menupicture": {
        // control menuPicture path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 menuPicture _p1;
    };
    case "menusetaction": {
        // menuSetAction [idc, path, action]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        menuSetAction [_p0, _p1, _p2];
        _result = true;
    };
    case "menusetaction": {
        // control menuSetAction [path, action]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 menuSetAction [_p1, _p2];
        _result = true;
    };
    case "menusetcheck": {
        // menuSetCheck [idc, path, checked]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        menuSetCheck [_p0, _p1, _p2];
        _result = true;
    };
    case "menusetcheck": {
        // control menuSetCheck [path, checked]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 menuSetCheck [_p1, _p2];
        _result = true;
    };
    case "menusetdata": {
        // menuSetData [idc, path, data]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        menuSetData [_p0, _p1, _p2];
        _result = true;
    };
    case "menusetdata": {
        // control menuSetData [path, data]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 menuSetData [_p1, _p2];
        _result = true;
    };
    case "menusetpicture": {
        // menuSetPicture [idc, path, picture]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        menuSetPicture [_p0, _p1, _p2];
        _result = true;
    };
    case "menusetpicture": {
        // control menuSetPicture [path, picture]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 menuSetPicture [_p1, _p2];
        _result = true;
    };
    case "menusetshortcut": {
        // menuSetShortcut [idc, path, shortcut]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        menuSetShortcut [_p0, _p1, _p2];
        _result = true;
    };
    case "menusetshortcut": {
        // control menuSetShortcut [path, shortcut]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 menuSetShortcut [_p1, _p2];
        _result = true;
    };
    case "menusettext": {
        // menuSetText [idc, path, text]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        menuSetText [_p0, _p1, _p2];
        _result = true;
    };
    case "menusettext": {
        // control menuSetText [path, text]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 menuSetText [_p1, _p2];
        _result = true;
    };
    case "menuseturl": {
        // menuSetURL [idc, path, link]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        menuSetURL [_p0, _p1, _p2];
        _result = true;
    };
    case "menuseturl": {
        // control menuSetURL [path, link]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 menuSetURL [_p1, _p2];
        _result = true;
    };
    case "menusetvalue": {
        // menuSetValue [idc, path, value]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        menuSetValue [_p0, _p1, _p2];
        _result = true;
    };
    case "menusetvalue": {
        // control menuSetValue [path, value]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 menuSetValue [_p1, _p2];
        _result = true;
    };
    case "menushortcut": {
        // menuShortcut [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = menuShortcut [_p0, _p1];
    };
    case "menushortcut": {
        // control menuShortcut path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 menuShortcut _p1;
    };
    case "menushortcuttext": {
        // menuShortcutText [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = menuShortcutText [_p0, _p1];
    };
    case "menushortcuttext": {
        // control menuShortcutText path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 menuShortcutText _p1;
    };
    case "menusize": {
        // menuSize [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = menuSize [_p0, _p1];
    };
    case "menusize": {
        // control menuSize path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 menuSize _p1;
    };
    case "menusort": {
        // menuSort [idc, path, AtoZ]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        menuSort [_p0, _p1, _p2];
        _result = true;
    };
    case "menusort": {
        // control menuSort [path, AtoZ]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 menuSort [_p1, _p2];
        _result = true;
    };
    case "menutext": {
        // menuText [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = menuText [_p0, _p1];
    };
    case "menutext": {
        // control menuText path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 menuText _p1;
    };
    case "menuurl": {
        // menuURL [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = menuURL [_p0, _p1];
    };
    case "menuurl": {
        // control menuURL path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 menuURL _p1;
    };
    case "menuvalue": {
        // menuValue [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = menuValue [_p0, _p1];
    };
    case "merge": {
        // hashMap1 merge hashMap2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 merge _p1;
        _result = true;
    };
    case "min": {
        // a min  b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 min  _p1;
    };
    case "mineactive": {
        // mineActive obj
        private _p0 = _args param [0];
        _result = mineActive _p0;
    };
    case "minedetectedby": {
        // mine mineDetectedBy faction
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 mineDetectedBy _p1;
    };
    case "missiletarget": {
        // missileTarget munition
        private _p0 = _args param [0];
        _result = missileTarget _p0;
    };
    case "missiletargetpos": {
        // missileTargetPos munition
        private _p0 = _args param [0];
        missileTargetPos _p0;
        _result = true;
    };
    case "mod": {
        // a mod b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 mod _p1;
    };
    case "modeltoworld": {
        // model modelToWorld position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 modelToWorld _p1;
        _result = true;
    };
    case "modeltoworldvisual": {
        // object modelToWorldVisual  modelPos
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 modelToWorldVisual  _p1;
    };
    case "modeltoworldvisualworld": {
        // obj modelToWorldVisualWorld modelPos
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 modelToWorldVisualWorld _p1;
        _result = true;
    };
    case "modeltoworldworld": {
        // obj modelToWorldWorld modelPos
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 modelToWorldWorld _p1;
        _result = true;
    };
    case "modparams": {
        // modParams [modClass, options]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = modParams [_p0, _p1];
    };
    case "moonphase": {
        // moonPhase date
        private _p0 = _args param [0];
        _result = moonPhase _p0;
    };
    case "morale": {
        // morale unit
        private _p0 = _args param [0];
        _result = morale _p0;
    };
    case "name": {
        // name object
        private _p0 = _args param [0];
        _result = name _p0;
    };
    case "name": {
        // name location
        private _p0 = _args param [0];
        _result = name _p0;
    };
    case "namedproperties": {
        // namedProperties  object
        private _p0 = _args param [0];
        namedProperties  _p0;
        _result = true;
    };
    case "namesound": {
        // nameSound person
        private _p0 = _args param [0];
        _result = nameSound _p0;
    };
    case "nearentities": {
        // position nearEntities radius
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 nearEntities _p1;
        _result = true;
    };
    case "nearentities": {
        // position nearEntities [type, radius]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 nearEntities [_p1, _p2];
        _result = true;
    };
    case "nearobjects": {
        // position nearObjects radius
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 nearObjects _p1;
    };
    case "nearobjects": {
        // position nearObjects [typeName, radius]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 nearObjects [_p1, _p2];
    };
    case "nearobjectsready": {
        // position nearObjectsReady radius
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 nearObjectsReady _p1;
    };
    case "nearroads": {
        // pos nearRoads radius
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 nearRoads _p1;
        _result = true;
    };
    case "nearsupplies": {
        // origin nearSupplies radius
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 nearSupplies _p1;
        _result = true;
    };
    case "nearsupplies": {
        // origin nearSupplies [typeName, radius]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 nearSupplies [_p1, _p2];
        _result = true;
    };
    case "neartargets": {
        // unit nearTargets  range
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 nearTargets  _p1;
        _result = true;
    };
    case "needreload": {
        // needReload vehicle
        private _p0 = _args param [0];
        needReload _p0;
        _result = true;
    };
    case "needservice": {
        // needService vehicle
        private _p0 = _args param [0];
        needService _p0;
        _result = true;
    };
    case "netid": {
        // netId  var
        private _p0 = _args param [0];
        _result = netId  _p0;
    };
    case "newoverlay": {
        // map newOverlay config
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 newOverlay _p1;
        _result = true;
    };
    case "nextmenuitemindex": {
        // nextMenuItemIndex map
        private _p0 = _args param [0];
        _result = nextMenuItemIndex _p0;
    };
    case "nmenuitems": {
        // map nMenuItems menuName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 nMenuItems _p1;
    };
    case "nmenuitems": {
        // map nMenuItems  index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 nMenuItems  _p1;
    };
    case "not": {
        // not a
        private _p0 = _args param [0];
        _result = not _p0;
    };
    case "numberofenginesrtd": {
        // numberOfEnginesRTD helicopterRTD
        private _p0 = _args param [0];
        _result = numberOfEnginesRTD _p0;
    };
    case "numbertodate": {
        // numberToDate [year, time]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        numberToDate [_p0, _p1];
        _result = true;
    };
    case "object": {
        // object id
        private _p0 = _args param [0];
        _result = object _p0;
    };
    case "objectcurators": {
        // objectCurators obj
        private _p0 = _args param [0];
        _result = objectCurators _p0;
    };
    case "objectfromnetid": {
        // objectFromNetId id
        private _p0 = _args param [0];
        _result = objectFromNetId _p0;
    };
    case "objectparent": {
        // objectParent object
        private _p0 = _args param [0];
        _result = objectParent _p0;
    };
    case "objstatus": {
        // objectivenumber objStatus status
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 objStatus _p1;
        _result = true;
    };
    case "onbriefinggear": {
        // onBriefingGear  soundName
        private _p0 = _args param [0];
        onBriefingGear  _p0;
        _result = true;
    };
    case "onbriefinggroup": {
        // onBriefingGroup  soundName
        private _p0 = _args param [0];
        onBriefingGroup  _p0;
        _result = true;
    };
    case "onbriefingnotes": {
        // onBriefingNotes  soundName
        private _p0 = _args param [0];
        onBriefingNotes  _p0;
        _result = true;
    };
    case "onbriefingplan": {
        // onBriefingPlan  soundName
        private _p0 = _args param [0];
        onBriefingPlan  _p0;
        _result = true;
    };
    case "onbriefingteamswitch": {
        // onBriefingTeamSwitch soundName
        private _p0 = _args param [0];
        onBriefingTeamSwitch _p0;
        _result = true;
    };
    case "oncommandmodechanged": {
        // onCommandModeChanged code
        private _p0 = _args param [0];
        onCommandModeChanged _p0;
        _result = true;
    };
    case "ondoubleclick": {
        // map onDoubleClick command
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 onDoubleClick _p1;
        _result = true;
    };
    case "oneachframe": {
        // onEachFrame statement
        private _p0 = _args param [0];
        onEachFrame _p0;
        _result = true;
    };
    case "ongroupiconclick": {
        // onGroupIconClick command
        private _p0 = _args param [0];
        onGroupIconClick _p0;
        _result = true;
    };
    case "ongroupiconoverenter": {
        // onGroupIconOverEnter command
        private _p0 = _args param [0];
        onGroupIconOverEnter _p0;
        _result = true;
    };
    case "ongroupiconoverleave": {
        // onGroupIconOverLeave command
        private _p0 = _args param [0];
        onGroupIconOverLeave _p0;
        _result = true;
    };
    case "onhcgroupselectionchanged": {
        // onHCGroupSelectionChanged code
        private _p0 = _args param [0];
        onHCGroupSelectionChanged _p0;
        _result = true;
    };
    case "onmapsingleclick": {
        // onMapSingleClick command
        private _p0 = _args param [0];
        onMapSingleClick _p0;
        _result = true;
    };
    case "onmapsingleclick": {
        // params onMapSingleClick command
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 onMapSingleClick _p1;
        _result = true;
    };
    case "onplayerconnected": {
        // onPlayerConnected code
        private _p0 = _args param [0];
        onPlayerConnected _p0;
        _result = true;
    };
    case "onplayerdisconnected": {
        // onPlayerDisconnected  code
        private _p0 = _args param [0];
        onPlayerDisconnected  _p0;
        _result = true;
    };
    case "onpreloadfinished": {
        // onPreloadFinished command
        private _p0 = _args param [0];
        onPreloadFinished _p0;
        _result = true;
    };
    case "onpreloadstarted": {
        // onPreloadStarted command
        private _p0 = _args param [0];
        onPreloadStarted _p0;
        _result = true;
    };
    case "onshownewobject": {
        // map onShowNewObject command
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 onShowNewObject _p1;
    };
    case "onteamswitch": {
        // onTeamSwitch commandset
        private _p0 = _args param [0];
        onTeamSwitch _p0;
        _result = true;
    };
    case "opendlcpage": {
        // openDLCPage dlcID
        private _p0 = _args param [0];
        _result = openDLCPage _p0;
    };
    case "opengps": {
        // openGPS open
        private _p0 = _args param [0];
        _result = openGPS _p0;
    };
    case "openmap": {
        // openMap show
        private _p0 = _args param [0];
        _result = openMap _p0;
    };
    case "openmap": {
        // openMap [show, forced]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = openMap [_p0, _p1];
    };
    case "opensteamapp": {
        // openSteamApp appID
        private _p0 = _args param [0];
        _result = openSteamApp _p0;
    };
    case "openyoutubevideo": {
        // openYoutubeVideo youTubeUrl
        private _p0 = _args param [0];
        _result = openYoutubeVideo _p0;
    };
    case "or": {
        // a or b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 or _p1;
    };
    case "or": {
        // a or b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 or _p1;
    };
    case "ordergetin": {
        // unitArray orderGetIn order
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 orderGetIn _p1;
        _result = true;
    };
    case "owner": {
        // owner object
        private _p0 = _args param [0];
        _result = owner _p0;
    };
    case "param": {
        // param [index, defaultValue, expectedDataTypes, expectedArrayCount]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = param [_p0, _p1, _p2, _p3];
    };
    case "param": {
        // argument param [index, defaultValue, expectedDataTypes, expectedArrayCount]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = _p0 param [_p1, _p2, _p3, _p4];
    };
    case "params": {
        // params [element1, element2,...elementN]
        private _p0 = _args param [0];
        _result = params [element1, element2,..._p0];
    };
    case "params": {
        // argument params [element1, element2,...elementN]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 params [element1, element2,..._p1];
    };
    case "parsenumber": {
        // parseNumber value
        private _p0 = _args param [0];
        _result = parseNumber _p0;
    };
    case "parsesimplearray": {
        // parseSimpleArray stringArray
        private _p0 = _args param [0];
        _result = parseSimpleArray _p0;
    };
    case "parsetext": {
        // parseText text
        private _p0 = _args param [0];
        parseText _p0;
        _result = true;
    };
    case "periscopeelevation": {
        // vehicle periscopeElevation turretPath
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 periscopeElevation _p1;
        _result = true;
    };
    case "pickweaponpool": {
        // pickWeaponPool object
        private _p0 = _args param [0];
        pickWeaponPool _p0;
        _result = true;
    };
    case "pitch": {
        // pitch person
        private _p0 = _args param [0];
        _result = pitch _p0;
    };
    case "pose": {
        // pose unit
        private _p0 = _args param [0];
        pose _p0;
        _result = true;
    };
    case "position": {
        // position object
        private _p0 = _args param [0];
        _result = position _p0;
    };
    case "position": {
        // position location
        private _p0 = _args param [0];
        _result = position _p0;
    };
    case "positioncameratoworld": {
        // positionCameraToWorld cameraPos
        private _p0 = _args param [0];
        _result = positionCameraToWorld _p0;
    };
    case "posscreentoworld": {
        // map posScreenToWorld [x, y]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 posScreenToWorld [_p1, _p2];
    };
    case "posworldtoscreen": {
        // map posWorldToScreen position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 posWorldToScreen _p1;
    };
    case "ppeffectadjust": {
        // effect ppEffectAdjust settings
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ppEffectAdjust _p1;
        _result = true;
    };
    case "ppeffectcommit": {
        // effect ppEffectCommit commit
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ppEffectCommit _p1;
        _result = true;
    };
    case "ppeffectcommit": {
        // handle ppEffectCommit commit
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ppEffectCommit _p1;
        _result = true;
    };
    case "ppeffectcommit": {
        // handles ppEffectCommit commit
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ppEffectCommit _p1;
        _result = true;
    };
    case "ppeffectcommitted": {
        // ppEffectCommitted effect
        private _p0 = _args param [0];
        _result = ppEffectCommitted _p0;
    };
    case "ppeffectcommitted": {
        // ppEffectCommitted handle
        private _p0 = _args param [0];
        _result = ppEffectCommitted _p0;
    };
    case "ppeffectcreate": {
        // ppEffectCreate [name, priority]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = ppEffectCreate [_p0, _p1];
    };
    case "ppeffectdestroy": {
        // ppEffectDestroy effect
        private _p0 = _args param [0];
        ppEffectDestroy _p0;
        _result = true;
    };
    case "ppeffectdestroy": {
        // ppEffectDestroy effects
        private _p0 = _args param [0];
        ppEffectDestroy _p0;
        _result = true;
    };
    case "ppeffectenable": {
        // effect ppEffectEnable enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ppEffectEnable _p1;
        _result = true;
    };
    case "ppeffectenable": {
        // effect ppEffectEnable enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ppEffectEnable _p1;
        _result = true;
    };
    case "ppeffectenable": {
        // effectArray ppEffectEnable enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ppEffectEnable _p1;
        _result = true;
    };
    case "ppeffectenabled": {
        // ppEffectEnabled effect
        private _p0 = _args param [0];
        _result = ppEffectEnabled _p0;
    };
    case "ppeffectenabled": {
        // ppEffectEnabled effect
        private _p0 = _args param [0];
        _result = ppEffectEnabled _p0;
    };
    case "ppeffectforceinnvg": {
        // ppHandle ppEffectForceInNVG force
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ppEffectForceInNVG _p1;
        _result = true;
    };
    case "precision": {
        // precision entity
        private _p0 = _args param [0];
        _result = precision _p0;
    };
    case "preloadcamera": {
        // preloadCamera position
        private _p0 = _args param [0];
        _result = preloadCamera _p0;
    };
    case "preloadsound": {
        // preloadSound soundName
        private _p0 = _args param [0];
        _result = preloadSound _p0;
    };
    case "preloadtitleobj": {
        // preloadTitleObj [name, type, speed, showInMap]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = preloadTitleObj [_p0, _p1, _p2, _p3];
    };
    case "preloadtitlersc": {
        // preloadTitleRsc [name, type, speed, showInMap]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = preloadTitleRsc [_p0, _p1, _p2, _p3];
    };
    case "preprocessfile": {
        // preprocessFile fileName
        private _p0 = _args param [0];
        _result = preprocessFile _p0;
    };
    case "preprocessfilelinenumbers": {
        // preprocessFileLineNumbers fileName
        private _p0 = _args param [0];
        _result = preprocessFileLineNumbers _p0;
    };
    case "primaryweapon": {
        // primaryWeapon unit
        private _p0 = _args param [0];
        _result = primaryWeapon _p0;
    };
    case "primaryweaponitems": {
        // primaryWeaponItems unit
        private _p0 = _args param [0];
        _result = primaryWeaponItems _p0;
    };
    case "primaryweaponmagazine": {
        // primaryWeaponMagazine unit
        private _p0 = _args param [0];
        _result = primaryWeaponMagazine _p0;
    };
    case "priority": {
        // priority task
        private _p0 = _args param [0];
        _result = priority _p0;
    };
    case "private": {
        // private variableName
        private _p0 = _args param [0];
        private _p0;
        _result = true;
    };
    case "private": {
        // private variableNameList
        private _p0 = _args param [0];
        private _p0;
        _result = true;
    };
    case "private": {
        // private _identifier = value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p0 = _p1;
        _result = true;
    };
    case "processdiarylink": {
        // processDiaryLink link
        private _p0 = _args param [0];
        processDiaryLink _p0;
        _result = true;
    };
    case "progressloadingscreen": {
        // progressLoadingScreen progress
        private _p0 = _args param [0];
        progressLoadingScreen _p0;
        _result = true;
    };
    case "progressposition": {
        // progressPosition control
        private _p0 = _args param [0];
        _result = progressPosition _p0;
    };
    case "progresssetposition": {
        // control progressSetPosition progress
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 progressSetPosition _p1;
        _result = true;
    };
    case "pushback": {
        // array pushBack element
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 pushBack _p1;
    };
    case "pushbackunique": {
        // array pushBackUnique element
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 pushBackUnique _p1;
    };
    case "putweaponpool": {
        // putWeaponPool object
        private _p0 = _args param [0];
        putWeaponPool _p0;
        _result = true;
    };
    case "queryitemspool": {
        // queryItemsPool name
        private _p0 = _args param [0];
        _result = queryItemsPool _p0;
    };
    case "querymagazinepool": {
        // queryMagazinePool name
        private _p0 = _args param [0];
        _result = queryMagazinePool _p0;
    };
    case "queryweaponpool": {
        // queryWeaponPool name
        private _p0 = _args param [0];
        _result = queryWeaponPool _p0;
    };
    case "rad": {
        // rad value
        private _p0 = _args param [0];
        _result = rad _p0;
    };
    case "radiochanneladd": {
        // customChannelID radioChannelAdd units
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 radioChannelAdd _p1;
        _result = true;
    };
    case "radiochannelcreate": {
        // radioChannelCreate [color, label, callSign, units, sentenceType]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = radioChannelCreate [_p0, _p1, _p2, _p3, _p4];
    };
    case "radiochannelinfo": {
        // radioChannelInfo customChannelID
        private _p0 = _args param [0];
        radioChannelInfo _p0;
        _result = true;
    };
    case "radiochannelremove": {
        // customChannelID radioChannelRemove units
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 radioChannelRemove _p1;
        _result = true;
    };
    case "radiochannelsetcallsign": {
        // customChannelID radioChannelSetCallSign callSign
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 radioChannelSetCallSign _p1;
        _result = true;
    };
    case "radiochannelsetlabel": {
        // customChannelID radioChannelSetLabel label
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 radioChannelSetLabel _p1;
        _result = true;
    };
    case "random": {
        // random x
        private _p0 = _args param [0];
        random _p0;
        _result = true;
    };
    case "random": {
        // random [min, mid, max]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        random [_p0, _p1, _p2];
        _result = true;
    };
    case "random": {
        // seed random x
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 random _p1;
        _result = true;
    };
    case "random": {
        // seed random [x, y]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 random [_p1, _p2];
        _result = true;
    };
    case "rank": {
        // rank unit
        private _p0 = _args param [0];
        _result = rank _p0;
    };
    case "rankid": {
        // rankId unit
        private _p0 = _args param [0];
        _result = rankId _p0;
    };
    case "rating": {
        // rating unitName
        private _p0 = _args param [0];
        _result = rating _p0;
    };
    case "rectangular": {
        // rectangular location
        private _p0 = _args param [0];
        _result = rectangular _p0;
    };
    case "regexmatch": {
        // haystack regexMatch pattern
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 regexMatch _p1;
    };
    case "registeredtasks": {
        // registeredTasks teamMember
        private _p0 = _args param [0];
        registeredTasks _p0;
        _result = true;
    };
    case "registertask": {
        // teamMember registerTask entryName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 registerTask _p1;
    };
    case "reload": {
        // reload unitName
        private _p0 = _args param [0];
        reload _p0;
        _result = true;
    };
    case "reloadenabled": {
        // reloadEnabled unitName
        private _p0 = _args param [0];
        _result = reloadEnabled _p0;
    };
    case "reportremotetarget": {
        // side reportRemoteTarget [target, time]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 reportRemoteTarget [_p1, _p2];
        _result = true;
    };
    case "requiredversion": {
        // requiredVersion version
        private _p0 = _args param [0];
        _result = requiredVersion _p0;
    };
    case "resetsubgroupdirection": {
        // resetSubgroupDirection unit
        private _p0 = _args param [0];
        resetSubgroupDirection _p0;
        _result = true;
    };
    case "resize": {
        // array resize count
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 resize _p1;
        _result = true;
    };
    case "resize": {
        // array resize [count, fill]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 resize [_p1, _p2];
        _result = true;
    };
    case "resources": {
        // resources member
        private _p0 = _args param [0];
        _result = resources _p0;
    };
    case "respawnvehicle": {
        // vehicle respawnVehicle [delay, count]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 respawnVehicle [_p1, _p2];
        _result = true;
    };
    case "restarteditorcamera": {
        // restartEditorCamera map
        private _p0 = _args param [0];
        restartEditorCamera _p0;
        _result = true;
    };
    case "reveal": {
        // toWhom reveal target
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 reveal _p1;
        _result = true;
    };
    case "reveal": {
        // toWhom reveal [target, accuracy]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 reveal [_p1, _p2];
        _result = true;
    };
    case "revealmine": {
        // side revealMine mine
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 revealMine _p1;
        _result = true;
    };
    case "reverse": {
        // reverse array
        private _p0 = _args param [0];
        reverse _p0;
        _result = true;
    };
    case "reverse": {
        // reverse string
        private _p0 = _args param [0];
        _result = reverse _p0;
    };
    case "roadat": {
        // roadAt position
        private _p0 = _args param [0];
        _result = roadAt _p0;
    };
    case "roadsconnectedto": {
        // roadsConnectedTo roadSegment
        private _p0 = _args param [0];
        roadsConnectedTo _p0;
        _result = true;
    };
    case "roadsconnectedto": {
        // roadsConnectedTo [roadSegment, extended]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        roadsConnectedTo [_p0, _p1];
        _result = true;
    };
    case "roledescription": {
        // roleDescription unit
        private _p0 = _args param [0];
        _result = roleDescription _p0;
    };
    case "ropeattachedobjects": {
        // ropeAttachedObjects ropesOwner
        private _p0 = _args param [0];
        _result = ropeAttachedObjects _p0;
    };
    case "ropeattachedto": {
        // ropeAttachedTo cargo
        private _p0 = _args param [0];
        _result = ropeAttachedTo _p0;
    };
    case "ropeattachenabled": {
        // ropeAttachEnabled entity
        private _p0 = _args param [0];
        _result = ropeAttachEnabled _p0;
    };
    case "ropeattachto": {
        // [entity, toPoint, ropeEndDownVector] ropeAttachTo rope
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2] ropeAttachTo _p3;
        _result = true;
    };
    case "ropeattachto": {
        // entity ropeAttachTo rope
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ropeAttachTo _p1;
        _result = true;
    };
    case "ropecreate": {
        // ropeCreate [fromObject, fromPoint, toObject, toPoint, segments, length]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _result = ropeCreate [_p0, _p1, _p2, _p3, _p4, _p5];
    };
    case "ropecreate": {
        // ropeCreate [fromObject, fromPoint, length, segments, unroll, ropeType]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = ropeCreate [_p0, _p1, _p2, _p3, _p4, ropeType];
    };
    case "ropecut": {
        // ropeCut [rope, length]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        ropeCut [_p0, _p1];
        _result = true;
    };
    case "ropedestroy": {
        // ropeDestroy rope
        private _p0 = _args param [0];
        ropeDestroy _p0;
        _result = true;
    };
    case "ropedetach": {
        // attachedObject ropeDetach rope
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ropeDetach _p1;
        _result = true;
    };
    case "ropeendposition": {
        // ropeEndPosition rope
        private _p0 = _args param [0];
        ropeEndPosition _p0;
        _result = true;
    };
    case "ropelength": {
        // ropeLength rope
        private _p0 = _args param [0];
        _result = ropeLength _p0;
    };
    case "ropes": {
        // ropes ropesOwner
        private _p0 = _args param [0];
        _result = ropes _p0;
    };
    case "ropesattachedto": {
        // ropesAttachedTo cargo
        private _p0 = _args param [0];
        _result = ropesAttachedTo _p0;
    };
    case "ropesegments": {
        // ropeSegments rope
        private _p0 = _args param [0];
        ropeSegments _p0;
        _result = true;
    };
    case "ropesetcargomass": {
        // ropeSetCargoMass [rope, cargo, mass]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = ropeSetCargoMass [_p0, _p1, _p2];
    };
    case "ropeunwind": {
        // ropeUnwind [rope, speed, length, relative]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        ropeUnwind [_p0, _p1, _p2, _p3];
        _result = true;
    };
    case "ropeunwound": {
        // ropeUnwound rope
        private _p0 = _args param [0];
        _result = ropeUnwound _p0;
    };
    case "rotorsforcesrtd": {
        // rotorsForcesRTD helicopter
        private _p0 = _args param [0];
        _result = rotorsForcesRTD _p0;
    };
    case "rotorsrpmrtd": {
        // rotorsRpmRTD RTD_helicopter
        private _p0 = _args param [0];
        _result = rotorsRpmRTD _p0;
    };
    case "round": {
        // round value
        private _p0 = _args param [0];
        _result = round _p0;
    };
    case "save3deninventory": {
        // save3DENInventory entities
        private _p0 = _args param [0];
        save3DENInventory _p0;
        _result = true;
    };
    case "saveidentity": {
        // unit saveIdentity name
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 saveIdentity _p1;
    };
    case "saveoverlay": {
        // saveOverlay map
        private _p0 = _args param [0];
        saveOverlay _p0;
        _result = true;
    };
    case "savestatus": {
        // object saveStatus name
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 saveStatus _p1;
    };
    case "savevar": {
        // saveVar varname
        private _p0 = _args param [0];
        saveVar _p0;
        _result = true;
    };
    case "say": {
        // from say sound
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 say _p1;
        _result = true;
    };
    case "say2d": {
        // from say2D sound
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 say2D _p1;
        _result = true;
    };
    case "say3d": {
        // from say3D sound
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 say3D _p1;
    };
    case "say3d": {
        // from say3D [sound, maxDistance, pitch, isSpeech, offset]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _result = _p0 say3D [_p1, _p2, _p3, _p4, _p5];
    };
    case "say3d": {
        // [from, to] say3D sound
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1] say3D _p2;
    };
    case "say3d": {
        // [from, to] say3D [sound, maxDistance, pitch, isSpeech, offset]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        _result = [_p0, _p1] say3D [_p2, _p3, _p4, _p5, _p6];
    };
    case "scopename": {
        // scopeName name
        private _p0 = _args param [0];
        scopeName _p0;
        _result = true;
    };
    case "score": {
        // score unit
        private _p0 = _args param [0];
        _result = score _p0;
    };
    case "scoreside": {
        // scoreSide side
        private _p0 = _args param [0];
        _result = scoreSide _p0;
    };
    case "screenshot": {
        // screenshot filename
        private _p0 = _args param [0];
        _result = screenshot _p0;
    };
    case "screentoworld": {
        // screenToWorld screen
        private _p0 = _args param [0];
        _result = screenToWorld _p0;
    };
    case "scriptdone": {
        // scriptDone handle
        private _p0 = _args param [0];
        _result = scriptDone _p0;
    };
    case "scriptname": {
        // scriptName name
        private _p0 = _args param [0];
        scriptName _p0;
        _result = true;
    };
    case "scudstate": {
        // scudState scudName
        private _p0 = _args param [0];
        scudState _p0;
        _result = true;
    };
    case "secondaryweapon": {
        // secondaryWeapon unit
        private _p0 = _args param [0];
        _result = secondaryWeapon _p0;
    };
    case "secondaryweaponitems": {
        // secondaryWeaponItems unit
        private _p0 = _args param [0];
        _result = secondaryWeaponItems _p0;
    };
    case "secondaryweaponmagazine": {
        // secondaryWeaponMagazine unit
        private _p0 = _args param [0];
        _result = secondaryWeaponMagazine _p0;
    };
    case "sendaumessage": {
        // sendAUMessage [clientList, command]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        sendAUMessage [_p0, _p1];
        _result = true;
    };
    case "sendsimplecommand": {
        // vehicleName sendSimpleCommand command
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 sendSimpleCommand _p1;
        _result = true;
    };
    case "sendudpmessage": {
        // sendUDPMessage [ip, port, message]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = sendUDPMessage [_p0, _p1, _p2];
    };
    case "servercommand": {
        // serverCommand command
        private _p0 = _args param [0];
        _result = serverCommand _p0;
    };
    case "servercommand": {
        // password serverCommand command
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 serverCommand _p1;
    };
    case "servercommandavailable": {
        // serverCommandAvailable command
        private _p0 = _args param [0];
        _result = serverCommandAvailable _p0;
    };
    case "servercommandexecutable": {
        // serverCommandExecutable command
        private _p0 = _args param [0];
        _result = serverCommandExecutable _p0;
    };
    case "side": {
        // side target
        private _p0 = _args param [0];
        _result = side _p0;
    };
    case "sidechat": {
        // unit sideChat chatText
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 sideChat _p1;
        _result = true;
    };
    case "sidechat": {
        // [side, identity] sideChat chatText
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1] sideChat _p2;
        _result = true;
    };
    case "sideradio": {
        // unit sideRadio radioName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 sideRadio _p1;
        _result = true;
    };
    case "sideradio": {
        // [side, identity] sideRadio radioName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1] sideRadio _p2;
        _result = true;
    };
    case "simpletasks": {
        // simpleTasks unit
        private _p0 = _args param [0];
        _result = simpleTasks _p0;
    };
    case "simulationenabled": {
        // simulationEnabled entity
        private _p0 = _args param [0];
        _result = simulationEnabled _p0;
    };
    case "simulclouddensity": {
        // simulCloudDensity pos
        private _p0 = _args param [0];
        simulCloudDensity _p0;
        _result = true;
    };
    case "simulcloudocclusion": {
        // simulCloudOcclusion [pos1, pos2]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        simulCloudOcclusion [_p0, _p1];
        _result = true;
    };
    case "simulinclouds": {
        // simulInClouds pos
        private _p0 = _args param [0];
        simulInClouds _p0;
        _result = true;
    };
    case "simulsethumidity": {
        // simulSetHumidity humidity
        private _p0 = _args param [0];
        simulSetHumidity _p0;
        _result = true;
    };
    case "sin": {
        // sin x
        private _p0 = _args param [0];
        _result = sin _p0;
    };
    case "size": {
        // size location
        private _p0 = _args param [0];
        size _p0;
        _result = true;
    };
    case "sizeof": {
        // sizeOf classname
        private _p0 = _args param [0];
        _result = sizeOf _p0;
    };
    case "skill": {
        // skill unit
        private _p0 = _args param [0];
        _result = skill _p0;
    };
    case "skillfinal": {
        // unit skillFinal skillName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 skillFinal _p1;
    };
    case "skiptime": {
        // skipTime duration
        private _p0 = _args param [0];
        skipTime _p0;
        _result = true;
    };
    case "sleep": {
        // sleep delay
        private _p0 = _args param [0];
        sleep _p0;
        _result = true;
    };
    case "sliderposition": {
        // sliderPosition idc
        private _p0 = _args param [0];
        _result = sliderPosition _p0;
    };
    case "sliderposition": {
        // sliderPosition control
        private _p0 = _args param [0];
        _result = sliderPosition _p0;
    };
    case "sliderrange": {
        // sliderRange idc
        private _p0 = _args param [0];
        sliderRange _p0;
        _result = true;
    };
    case "sliderrange": {
        // sliderRange control
        private _p0 = _args param [0];
        sliderRange _p0;
        _result = true;
    };
    case "slidersetposition": {
        // sliderSetPosition [idc, pos]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        sliderSetPosition [_p0, _p1];
        _result = true;
    };
    case "slidersetposition": {
        // control sliderSetPosition pos
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 sliderSetPosition _p1;
        _result = true;
    };
    case "slidersetrange": {
        // sliderSetRange [idc, min, max]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        sliderSetRange [_p0, _p1, _p2];
        _result = true;
    };
    case "slidersetrange": {
        // control sliderSetRange [min, max]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 sliderSetRange [_p1, _p2];
        _result = true;
    };
    case "slidersetspeed": {
        // sliderSetSpeed [idc, line, page, step]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        sliderSetSpeed [_p0, _p1, _p2, _p3];
        _result = true;
    };
    case "slidersetspeed": {
        // control sliderSetSpeed [line, page, step]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 sliderSetSpeed [_p1, _p2, _p3];
        _result = true;
    };
    case "sliderspeed": {
        // sliderSpeed idc
        private _p0 = _args param [0];
        sliderSpeed _p0;
        _result = true;
    };
    case "sliderspeed": {
        // sliderSpeed control
        private _p0 = _args param [0];
        sliderSpeed _p0;
        _result = true;
    };
    case "soldiermagazines": {
        // soldierMagazines unit
        private _p0 = _args param [0];
        soldierMagazines _p0;
        _result = true;
    };
    case "someammo": {
        // someAmmo unitName
        private _p0 = _args param [0];
        _result = someAmmo _p0;
    };
    case "sort": {
        // array sort order
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 sort _p1;
        _result = true;
    };
    case "soundparams": {
        // soundParams id
        private _p0 = _args param [0];
        soundParams _p0;
        _result = true;
    };
    case "spawn": {
        // arguments spawn code
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 spawn _p1;
        _result = true;
    };
    case "speaker": {
        // speaker unit
        private _p0 = _args param [0];
        _result = speaker _p0;
    };
    case "speed": {
        // speed object
        private _p0 = _args param [0];
        _result = speed _p0;
    };
    case "speedmode": {
        // speedMode groupName
        private _p0 = _args param [0];
        _result = speedMode _p0;
    };
    case "splitstring": {
        // str splitString delimiters
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 splitString _p1;
    };
    case "sqrt": {
        // sqrt x
        private _p0 = _args param [0];
        _result = sqrt _p0;
    };
    case "squadparams": {
        // squadParams unit
        private _p0 = _args param [0];
        squadParams _p0;
        _result = true;
    };
    case "stance": {
        // stance unit
        private _p0 = _args param [0];
        stance _p0;
        _result = true;
    };
    case "startloadingscreen": {
        // startLoadingScreen [text, resource]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        startLoadingScreen [_p0, _p1];
        _result = true;
    };
    case "step": {
        // for step stepSize
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 step _p1;
        _result = true;
    };
    case "stop": {
        // unitName stop toggle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 stop _p1;
        _result = true;
    };
    case "stopenginertd": {
        // stopEngineRTD heli
        private _p0 = _args param [0];
        stopEngineRTD _p0;
        _result = true;
    };
    case "stopped": {
        // stopped unitName
        private _p0 = _args param [0];
        _result = stopped _p0;
    };
    case "stopsound": {
        // stopSound id
        private _p0 = _args param [0];
        stopSound _p0;
        _result = true;
    };
    case "str": {
        // str value
        private _p0 = _args param [0];
        _result = str _p0;
    };
    case "supportinfo": {
        // supportInfo mask
        private _p0 = _args param [0];
        _result = supportInfo _p0;
    };
    case "suppressfor": {
        // unit suppressFor duration
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 suppressFor _p1;
        _result = true;
    };
    case "surfaceiswater": {
        // surfaceIsWater position
        private _p0 = _args param [0];
        _result = surfaceIsWater _p0;
    };
    case "surfacenormal": {
        // surfaceNormal position
        private _p0 = _args param [0];
        surfaceNormal _p0;
        _result = true;
    };
    case "surfacetexture": {
        // surfaceTexture position
        private _p0 = _args param [0];
        _result = surfaceTexture _p0;
    };
    case "surfacetype": {
        // surfaceType position
        private _p0 = _args param [0];
        _result = surfaceType _p0;
    };
    case "swimindepth": {
        // unit swimInDepth value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 swimInDepth _p1;
        _result = true;
    };
    case "synchronizedobjects": {
        // synchronizedObjects unit
        private _p0 = _args param [0];
        _result = synchronizedObjects _p0;
    };
    case "synchronizedtriggers": {
        // synchronizedTriggers waypoint
        private _p0 = _args param [0];
        _result = synchronizedTriggers _p0;
    };
    case "synchronizedwaypoints": {
        // synchronizedWaypoints obj
        private _p0 = _args param [0];
        _result = synchronizedWaypoints _p0;
    };
    case "synchronizeobjectsadd": {
        // unit synchronizeObjectsAdd objects
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 synchronizeObjectsAdd _p1;
        _result = true;
    };
    case "synchronizeobjectsremove": {
        // unit synchronizeObjectsRemove objects
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 synchronizeObjectsRemove _p1;
        _result = true;
    };
    case "synchronizetrigger": {
        // trigger synchronizeTrigger waypoints
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 synchronizeTrigger _p1;
        _result = true;
    };
    case "synchronizewaypoint": {
        // triggerOrWaypoint synchronizeWaypoint waypoints
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 synchronizeWaypoint _p1;
        _result = true;
    };
    case "systemchat": {
        // systemChat text
        private _p0 = _args param [0];
        systemChat _p0;
        _result = true;
    };
    case "tan": {
        // tan x
        private _p0 = _args param [0];
        _result = tan _p0;
    };
    case "targetknowledge": {
        // unit targetKnowledge target
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 targetKnowledge _p1;
        _result = true;
    };
    case "targets": {
        // unitOrGroup targets [enemyOnly, maxDistance, sides, maxAge, alternateCenter]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _result = _p0 targets [_p1, _p2, _p3, _p4, _p5];
    };
    case "targetsaggregate": {
        // [speaker, side, classname, position, timeMax] targetsAggregate candidates
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        [_p0, _p1, _p2, _p3, _p4] targetsAggregate _p5;
        _result = true;
    };
    case "targetsquery": {
        // enquirer targetsQuery [targetIgnore, targetSide, targetType, targetPosition, targetMaxAge]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _p0 targetsQuery [_p1, _p2, _p3, _p4, _p5];
        _result = true;
    };
    case "teammember": {
        // teamMember person
        private _p0 = _args param [0];
        teamMember _p0;
        _result = true;
    };
    case "teamname": {
        // teamName team
        private _p0 = _args param [0];
        _result = teamName _p0;
    };
    case "teamtype": {
        // teamType team
        private _p0 = _args param [0];
        _result = teamType _p0;
    };
    case "terminate": {
        // terminate scriptHandle
        private _p0 = _args param [0];
        terminate _p0;
        _result = true;
    };
    case "text": {
        // text string
        private _p0 = _args param [0];
        text _p0;
        _result = true;
    };
    case "text": {
        // text location
        private _p0 = _args param [0];
        _result = text _p0;
    };
    case "textlog": {
        // textLog anything
        private _p0 = _args param [0];
        textLog _p0;
        _result = true;
    };
    case "textlogformat": {
        // textLogFormat [format, arg1, arg2, ...]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        textLogFormat [_p0, _p1, _p2, ...];
        _result = true;
    };
    case "tg": {
        // tg x
        private _p0 = _args param [0];
        _result = tg _p0;
    };
    case "then": {
        // ifType then thenCode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 then _p1;
    };
    case "throttlertd": {
        // throttleRTD helicopterRTD
        private _p0 = _args param [0];
        _result = throttleRTD _p0;
    };
    case "throw": {
        // throw expression
        private _p0 = _args param [0];
        throw _p0;
        _result = true;
    };
    case "titlecut": {
        // titleCut [text, type, speed]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        titleCut [_p0, _p1, _p2];
        _result = true;
    };
    case "titlefadeout": {
        // titleFadeOut duration
        private _p0 = _args param [0];
        titleFadeOut _p0;
        _result = true;
    };
    case "titleobj": {
        // titleObj [class, type, speed, showInMap]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        titleObj [_p0, _p1, _p2, _p3];
        _result = true;
    };
    case "titlersc": {
        // titleRsc [text, type, speed, showInMap]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        titleRsc [_p0, _p1, _p2, _p3];
        _result = true;
    };
    case "titletext": {
        // titleText [text, type, speed,  showInMap, isStructuredText]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        titleText [_p0, _p1, _p2,  _p3, _p4];
        _result = true;
    };
    case "to": {
        // forType to b
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 to _p1;
        _result = true;
    };
    case "toarray": {
        // toArray string
        private _p0 = _args param [0];
        _result = toArray _p0;
    };
    case "toarray": {
        // toArray hashMap
        private _p0 = _args param [0];
        _result = toArray _p0;
    };
    case "toarray": {
        // hashMap toArray splitArrays
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 toArray _p1;
        _result = true;
    };
    case "tofixed": {
        // number toFixed decimals
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 toFixed _p1;
    };
    case "tofixed": {
        // toFixed decimals
        private _p0 = _args param [0];
        toFixed _p0;
        _result = true;
    };
    case "tolower": {
        // toLower string
        private _p0 = _args param [0];
        _result = toLower _p0;
    };
    case "toloweransi": {
        // toLowerANSI string
        private _p0 = _args param [0];
        _result = toLowerANSI _p0;
    };
    case "tostring": {
        // toString array
        private _p0 = _args param [0];
        _result = toString _p0;
    };
    case "tostring": {
        // toString code
        private _p0 = _args param [0];
        _result = toString _p0;
    };
    case "toupper": {
        // toUpper string
        private _p0 = _args param [0];
        _result = toUpper _p0;
    };
    case "toupperansi": {
        // toUpperANSI string
        private _p0 = _args param [0];
        _result = toUpperANSI _p0;
    };
    case "trim": {
        // trim stringValue
        private _p0 = _args param [0];
        _result = trim _p0;
    };
    case "trim": {
        // string trim [chars, where]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 trim [_p1, _p2];
    };
    case "try": {
        // try code
        private _p0 = _args param [0];
        try _p0;
        _result = true;
    };
    case "try": {
        // args try code
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 try _p1;
        _result = true;
    };
    case "turretlocal": {
        // vehicle turretLocal turretPath
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 turretLocal _p1;
        _result = true;
    };
    case "turretowner": {
        // vehicle turretOwner turretPath
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 turretOwner _p1;
    };
    case "tvadd": {
        // tvAdd [idc, pathParent, text]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = tvAdd [_p0, _p1, _p2];
    };
    case "tvadd": {
        // control tvAdd [pathParent, text]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 tvAdd [_p1, _p2];
    };
    case "tvclear": {
        // tvClear idc
        private _p0 = _args param [0];
        tvClear _p0;
        _result = true;
    };
    case "tvclear": {
        // tvClear control
        private _p0 = _args param [0];
        tvClear _p0;
        _result = true;
    };
    case "tvcollapse": {
        // tvCollapse [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        tvCollapse [_p0, _p1];
        _result = true;
    };
    case "tvcollapse": {
        // control tvCollapse path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 tvCollapse _p1;
        _result = true;
    };
    case "tvcollapseall": {
        // tvCollapseAll idc
        private _p0 = _args param [0];
        tvCollapseAll _p0;
        _result = true;
    };
    case "tvcollapseall": {
        // tvCollapseAll control
        private _p0 = _args param [0];
        tvCollapseAll _p0;
        _result = true;
    };
    case "tvcount": {
        // tvCount [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = tvCount [_p0, _p1];
    };
    case "tvcount": {
        // ctrl tvCount path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 tvCount _p1;
    };
    case "tvcursel": {
        // tvCurSel idc
        private _p0 = _args param [0];
        _result = tvCurSel _p0;
    };
    case "tvcursel": {
        // tvCurSel control
        private _p0 = _args param [0];
        _result = tvCurSel _p0;
    };
    case "tvdata": {
        // tvData [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = tvData [_p0, _p1];
    };
    case "tvdata": {
        // control tvData path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 tvData _p1;
    };
    case "tvdelete": {
        // tvDelete [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        tvDelete [_p0, _p1];
        _result = true;
    };
    case "tvdelete": {
        // control tvDelete path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 tvDelete _p1;
        _result = true;
    };
    case "tvexpand": {
        // tvExpand [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        tvExpand [_p0, _p1];
        _result = true;
    };
    case "tvexpand": {
        // control tvExpand path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 tvExpand _p1;
        _result = true;
    };
    case "tvexpandall": {
        // tvExpandAll idc
        private _p0 = _args param [0];
        tvExpandAll _p0;
        _result = true;
    };
    case "tvexpandall": {
        // tvExpandAll control
        private _p0 = _args param [0];
        tvExpandAll _p0;
        _result = true;
    };
    case "tvisselected": {
        // control tvIsSelected path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 tvIsSelected _p1;
    };
    case "tvpicture": {
        // tvPicture [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = tvPicture [_p0, _p1];
    };
    case "tvpicture": {
        // ctrl tvPicture path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 tvPicture _p1;
    };
    case "tvpictureright": {
        // tvPictureRight [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = tvPictureRight [_p0, _p1];
    };
    case "tvpictureright": {
        // ctrl tvPictureRight path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 tvPictureRight _p1;
    };
    case "tvselection": {
        // tvSelection control
        private _p0 = _args param [0];
        _result = tvSelection _p0;
    };
    case "tvsetcolor": {
        // tvSetColor [idc, path, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        tvSetColor [_p0, _p1, _p2];
        _result = true;
    };
    case "tvsetcolor": {
        // control tvSetColor [path, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 tvSetColor [_p1, _p2];
        _result = true;
    };
    case "tvsetcursel": {
        // tvSetCurSel [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        tvSetCurSel [_p0, _p1];
        _result = true;
    };
    case "tvsetcursel": {
        // control tvSetCurSel path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 tvSetCurSel _p1;
        _result = true;
    };
    case "tvsetdata": {
        // tvSetData [idc, path, data]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        tvSetData [_p0, _p1, _p2];
        _result = true;
    };
    case "tvsetdata": {
        // ctrl tvSetData [path, data]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 tvSetData [_p1, _p2];
        _result = true;
    };
    case "tvsetpicture": {
        // tvSetPicture [idc, path, name]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        tvSetPicture [_p0, _p1, _p2];
        _result = true;
    };
    case "tvsetpicture": {
        // control tvSetPicture [path, name]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 tvSetPicture [_p1, _p2];
        _result = true;
    };
    case "tvsetpicturecolor": {
        // tvSetPictureColor [idc, path, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        tvSetPictureColor [_p0, _p1, _p2];
        _result = true;
    };
    case "tvsetpicturecolor": {
        // ctrl tvSetPictureColor [path, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 tvSetPictureColor [_p1, _p2];
        _result = true;
    };
    case "tvsetpicturecolordisabled": {
        // control tvSetPictureColorDisabled [path, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 tvSetPictureColorDisabled [_p1, _p2];
        _result = true;
    };
    case "tvsetpicturecolorselected": {
        // control tvSetPictureColorSelected [path, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 tvSetPictureColorSelected [_p1, _p2];
        _result = true;
    };
    case "tvsetpictureright": {
        // tvSetPictureRight [idc, path, name]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        tvSetPictureRight [_p0, _p1, _p2];
        _result = true;
    };
    case "tvsetpictureright": {
        // control tvSetPictureRight [path, name]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 tvSetPictureRight [_p1, _p2];
        _result = true;
    };
    case "tvsetpicturerightcolor": {
        // tvSetPictureRightColor [idc, path, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        tvSetPictureRightColor [_p0, _p1, _p2];
        _result = true;
    };
    case "tvsetpicturerightcolor": {
        // control tvSetPictureRightColor [path, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 tvSetPictureRightColor [_p1, _p2];
        _result = true;
    };
    case "tvsetpicturerightcolordisabled": {
        // control tvSetPictureRightColorDisabled [path, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 tvSetPictureRightColorDisabled [_p1, _p2];
        _result = true;
    };
    case "tvsetpicturerightcolorselected": {
        // control tvSetPictureRightColorSelected [path, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 tvSetPictureRightColorSelected [_p1, _p2];
        _result = true;
    };
    case "tvsetselectcolor": {
        // ctrl tvSetSelectColor [path, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 tvSetSelectColor [_p1, _p2];
        _result = true;
    };
    case "tvsetselected": {
        // control tvSetSelected [path, selected]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 tvSetSelected [_p1, _p2];
        _result = true;
    };
    case "tvsettext": {
        // tvSetText [idc, path, text]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        tvSetText [_p0, _p1, _p2];
        _result = true;
    };
    case "tvsettext": {
        // control tvSetText [path, text]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 tvSetText [_p1, _p2];
        _result = true;
    };
    case "tvsettooltip": {
        // tvSetTooltip [idc, path, text]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        tvSetTooltip [_p0, _p1, _p2];
        _result = true;
    };
    case "tvsettooltip": {
        // ctrl tvSetTooltip [path, text]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 tvSetTooltip [_p1, _p2];
        _result = true;
    };
    case "tvsetvalue": {
        // tvSetValue [idc, path, val]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        tvSetValue [_p0, _p1, _p2];
        _result = true;
    };
    case "tvsetvalue": {
        // ctrl tvSetValue [path, val]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 tvSetValue [_p1, _p2];
        _result = true;
    };
    case "tvsort": {
        // control tvSort [path, reversed]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 tvSort [_p1, _p2];
        _result = true;
    };
    case "tvsort": {
        // tvSort [idc, path, reversed]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        tvSort [_p0, _p1, _p2];
        _result = true;
    };
    case "tvsortall": {
        // control tvSortAll [path, reversed]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 tvSortAll [_p1, _p2];
        _result = true;
    };
    case "tvsortbyvalue": {
        // control tvSortByValue [path, ascending]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 tvSortByValue [_p1, _p2];
        _result = true;
    };
    case "tvsortbyvalueall": {
        // control tvSortByValueAll [path, reversed]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 tvSortByValueAll [_p1, _p2];
        _result = true;
    };
    case "tvtext": {
        // tvText [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = tvText [_p0, _p1];
    };
    case "tvtext": {
        // control tvText path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 tvText _p1;
    };
    case "tvtooltip": {
        // tvTooltip [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = tvTooltip [_p0, _p1];
    };
    case "tvtooltip": {
        // ctrl tvTooltip path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 tvTooltip _p1;
    };
    case "tvvalue": {
        // tvValue [idc, path]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = tvValue [_p0, _p1];
    };
    case "tvvalue": {
        // ctrl tvValue path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 tvValue _p1;
    };
    case "type": {
        // type location
        private _p0 = _args param [0];
        _result = type _p0;
    };
    case "type": {
        // type task
        private _p0 = _args param [0];
        _result = type _p0;
    };
    case "typename": {
        // typeName anything
        private _p0 = _args param [0];
        _result = typeName _p0;
    };
    case "typeof": {
        // typeOf obj
        private _p0 = _args param [0];
        _result = typeOf _p0;
    };
    case "uavcontrol": {
        // UAVControl uav
        private _p0 = _args param [0];
        UAVControl _p0;
        _result = true;
    };
    case "unassigncurator": {
        // unassignCurator curatorObj
        private _p0 = _args param [0];
        unassignCurator _p0;
        _result = true;
    };
    case "unassignitem": {
        // unit unassignItem item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 unassignItem _p1;
        _result = true;
    };
    case "unassignteam": {
        // unassignTeam vehicleName
        private _p0 = _args param [0];
        unassignTeam _p0;
        _result = true;
    };
    case "unassignvehicle": {
        // unassignVehicle unitName
        private _p0 = _args param [0];
        unassignVehicle _p0;
        _result = true;
    };
    case "underwater": {
        // underwater object
        private _p0 = _args param [0];
        _result = underwater _p0;
    };
    case "uniform": {
        // uniform unit
        private _p0 = _args param [0];
        _result = uniform _p0;
    };
    case "uniformcontainer": {
        // uniformContainer unit
        private _p0 = _args param [0];
        _result = uniformContainer _p0;
    };
    case "uniformitems": {
        // uniformItems unit
        private _p0 = _args param [0];
        _result = uniformItems _p0;
    };
    case "uniformmagazines": {
        // uniformMagazines unit
        private _p0 = _args param [0];
        uniformMagazines _p0;
        _result = true;
    };
    case "uniqueunititems": {
        // uniqueUnitItems unit
        private _p0 = _args param [0];
        uniqueUnitItems _p0;
        _result = true;
    };
    case "uniqueunititems": {
        // uniqueUnitItems [unit, weaponsItems, uniformItems, vestItems, backpackItems, assignedItems]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        uniqueUnitItems [_p0, _p1, _p2, _p3, _p4, _p5];
        _result = true;
    };
    case "unlinkitem": {
        // unit unlinkItem item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 unlinkItem _p1;
        _result = true;
    };
    case "unlockachievement": {
        // unlockAchievement name
        private _p0 = _args param [0];
        _result = unlockAchievement _p0;
    };
    case "unregistertask": {
        // teamMember unregisterTask name
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 unregisterTask _p1;
    };
    case "updateobjecttree": {
        // updateObjectTree map
        private _p0 = _args param [0];
        updateObjectTree _p0;
        _result = true;
    };
    case "useaiopermapobstructiontest": {
        // useAIOperMapObstructionTest state
        private _p0 = _args param [0];
        useAIOperMapObstructionTest _p0;
        _result = true;
    };
    case "useaisteeringcomponent": {
        // useAISteeringComponent state
        private _p0 = _args param [0];
        useAISteeringComponent _p0;
        _result = true;
    };
    case "useaudiotimeformoves": {
        // soldier useAudioTimeForMoves toggle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 useAudioTimeForMoves _p1;
        _result = true;
    };
    case "values": {
        // values hashmap
        private _p0 = _args param [0];
        _result = values _p0;
    };
    case "velocity": {
        // velocity object
        private _p0 = _args param [0];
        _result = velocity _p0;
    };
    case "velocitymodelspace": {
        // velocityModelSpace vehicle
        private _p0 = _args param [0];
        _result = velocityModelSpace _p0;
    };
    case "verifysignature": {
        // verifySignature filename
        private _p0 = _args param [0];
        _result = verifySignature _p0;
    };
    case "vest": {
        // vest unit
        private _p0 = _args param [0];
        _result = vest _p0;
    };
    case "vestcontainer": {
        // vestContainer unit
        private _p0 = _args param [0];
        _result = vestContainer _p0;
    };
    case "vestitems": {
        // vestItems unit
        private _p0 = _args param [0];
        _result = vestItems _p0;
    };
    case "vestmagazines": {
        // vestMagazines unit
        private _p0 = _args param [0];
        vestMagazines _p0;
        _result = true;
    };
    case "visibleposition": {
        // visiblePosition object
        private _p0 = _args param [0];
        _result = visiblePosition _p0;
    };
    case "visiblepositionasl": {
        // visiblePositionASL object
        private _p0 = _args param [0];
        visiblePositionASL _p0;
        _result = true;
    };
    case "waituntil": {
        // waitUntil condition
        private _p0 = _args param [0];
        _result = waitUntil _p0;
    };
    case "waterdamaged": {
        // waterDamaged object
        private _p0 = _args param [0];
        _result = waterDamaged _p0;
    };
    case "waypointattachedobject": {
        // waypointAttachedObject waypoint
        private _p0 = _args param [0];
        _result = waypointAttachedObject _p0;
    };
    case "waypointattachedvehicle": {
        // waypointAttachedVehicle waypoint
        private _p0 = _args param [0];
        _result = waypointAttachedVehicle _p0;
    };
    case "waypointattachobject": {
        // waypoint waypointAttachObject objectID
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 waypointAttachObject _p1;
        _result = true;
    };
    case "waypointattachobject": {
        // waypoint waypointAttachObject object
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 waypointAttachObject _p1;
        _result = true;
    };
    case "waypointattachvehicle": {
        // waypoint waypointAttachVehicle vehicleName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 waypointAttachVehicle _p1;
        _result = true;
    };
    case "waypointbehaviour": {
        // waypointBehaviour waypoint
        private _p0 = _args param [0];
        _result = waypointBehaviour _p0;
    };
    case "waypointcombatmode": {
        // waypointCombatMode waypoint
        private _p0 = _args param [0];
        _result = waypointCombatMode _p0;
    };
    case "waypointcompletionradius": {
        // waypointCompletionRadius waypoint
        private _p0 = _args param [0];
        _result = waypointCompletionRadius _p0;
    };
    case "waypointdescription": {
        // waypointDescription waypoint
        private _p0 = _args param [0];
        _result = waypointDescription _p0;
    };
    case "waypointforcebehaviour": {
        // waypointForceBehaviour waypoint
        private _p0 = _args param [0];
        _result = waypointForceBehaviour _p0;
    };
    case "waypointformation": {
        // waypointFormation waypoint
        private _p0 = _args param [0];
        _result = waypointFormation _p0;
    };
    case "waypointhouseposition": {
        // waypointHousePosition waypoint
        private _p0 = _args param [0];
        _result = waypointHousePosition _p0;
    };
    case "waypointloiteraltitude": {
        // waypointLoiterAltitude waypoint
        private _p0 = _args param [0];
        _result = waypointLoiterAltitude _p0;
    };
    case "waypointloiterradius": {
        // waypointLoiterRadius Waypoint
        private _p0 = _args param [0];
        _result = waypointLoiterRadius _p0;
    };
    case "waypointloitertype": {
        // waypointLoiterType waypoint
        private _p0 = _args param [0];
        _result = waypointLoiterType _p0;
    };
    case "waypointname": {
        // waypointName waypoint
        private _p0 = _args param [0];
        _result = waypointName _p0;
    };
    case "waypointposition": {
        // waypointPosition [groupOrUnit, index]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = waypointPosition [_p0, _p1];
    };
    case "waypoints": {
        // waypoints groupName
        private _p0 = _args param [0];
        waypoints _p0;
        _result = true;
    };
    case "waypointscript": {
        // waypointScript waypoint
        private _p0 = _args param [0];
        _result = waypointScript _p0;
    };
    case "waypointsenableduav": {
        // waypointsEnabledUAV uav
        private _p0 = _args param [0];
        _result = waypointsEnabledUAV _p0;
    };
    case "waypointshow": {
        // waypointShow waypoint
        private _p0 = _args param [0];
        waypointShow _p0;
        _result = true;
    };
    case "waypointspeed": {
        // waypointSpeed waypoint
        private _p0 = _args param [0];
        _result = waypointSpeed _p0;
    };
    case "waypointstatements": {
        // waypointStatements waypoint
        private _p0 = _args param [0];
        _result = waypointStatements _p0;
    };
    case "waypointtimeout": {
        // waypointTimeout waypoint
        private _p0 = _args param [0];
        _result = waypointTimeout _p0;
    };
    case "waypointtimeoutcurrent": {
        // waypointTimeoutCurrent group
        private _p0 = _args param [0];
        _result = waypointTimeoutCurrent _p0;
    };
    case "waypointtype": {
        // waypointType waypoint
        private _p0 = _args param [0];
        _result = waypointType _p0;
    };
    case "waypointvisible": {
        // waypointVisible waypoint
        private _p0 = _args param [0];
        _result = waypointVisible _p0;
    };
    case "weightrtd": {
        // weightRTD helicopter
        private _p0 = _args param [0];
        _result = weightRTD _p0;
    };
    case "wfsidetext": {
        // WFSideText value
        private _p0 = _args param [0];
        _result = WFSideText _p0;
    };
    case "while": {
        // while condition
        private _p0 = _args param [0];
        while _p0;
        _result = true;
    };
    case "wingsforcesrtd": {
        // wingsForcesRTD RTD_helicopter
        private _p0 = _args param [0];
        _result = wingsForcesRTD _p0;
    };
    case "with": {
        // with namespace
        private _p0 = _args param [0];
        with _p0;
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
