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
    case "add3denconnection": {
        // add3DENConnection  [type, from, to]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = add3DENConnection  [_p0, _p1, _p2];
    };
    case "add3deneventhandler": {
        // add3DENEventHandler  [type, code]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = add3DENEventHandler  [_p0, _p1];
    };
    case "add3denlayer": {
        // parentLayerID add3DENLayer  name
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 add3DENLayer  _p1;
    };
    case "addaction": {
        // object addAction  [title, script, arguments, priority, showWindow, hideOnUse, shortcut, condition, positionInModel, radius, radiusView, showIn3D, available, textDefault, textToolTip]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        private _p7 = _args param [7];
        private _p8 = _args param [8];
        private _p9 = _args param [9];
        private _p10 = _args param [10];
        private _p11 = _args param [11];
        private _p12 = _args param [12];
        private _p13 = _args param [13];
        private _p14 = _args param [14];
        _result = _p0 addAction  [_p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, positionInModel, _p9, _p10, _p11, _p12, _p13, _p14];
    };
    case "addbackpack": {
        // unit addBackpack backpackClassName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addBackpack _p1;
        _result = true;
    };
    case "addbackpackcargo": {
        // vehicle addBackpackCargo [backpackClassName, count]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 addBackpackCargo [_p1, _p2];
        _result = true;
    };
    case "addbackpackcargoglobal": {
        // vehicle addBackpackCargoGlobal [packClassName, count]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 addBackpackCargoGlobal [_p1, _p2];
        _result = true;
    };
    case "addbackpackglobal": {
        // unit addBackpackGlobal backpack
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addBackpackGlobal _p1;
        _result = true;
    };
    case "addbinocularitem": {
        // unit addBinocularItem item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addBinocularItem _p1;
        _result = true;
    };
    case "addcamshake": {
        // addCamShake  [power, duration, frequency]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        addCamShake  [_p0, _p1, _p2];
        _result = true;
    };
    case "addcuratoraddons": {
        // curatorObj addCuratorAddons addons
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addCuratorAddons _p1;
        _result = true;
    };
    case "addcuratorcameraarea": {
        // curatorObj addCuratorCameraArea [cameraAreaID, position, radius]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 addCuratorCameraArea [_p1, _p2, _p3];
        _result = true;
    };
    case "addcuratoreditableobjects": {
        // curatorObj addCuratorEditableObjects [objects, addCrew]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 addCuratorEditableObjects [_p1, _p2];
        _result = true;
    };
    case "addcuratoreditingarea": {
        // curatorObj addCuratorEditingArea [editAreaID, position, radius]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 addCuratorEditingArea [_p1, _p2, _p3];
        _result = true;
    };
    case "addcuratorpoints": {
        // curatorObj addCuratorPoints points
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addCuratorPoints _p1;
        _result = true;
    };
    case "addcuratorselected": {
        // addCuratorSelected items
        private _p0 = _args param [0];
        addCuratorSelected _p0;
        _result = true;
    };
    case "addeventhandler": {
        // target addEventHandler [type, code]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 addEventHandler [_p1, _p2];
    };
    case "addforce": {
        // object addForce  [force, position]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 addForce  [_p1, _p2];
        _result = true;
    };
    case "addforcegeneratorrtd": {
        // addForceGeneratorRTD parameters
        private _p0 = _args param [0];
        _result = addForceGeneratorRTD _p0;
    };
    case "addgoggles": {
        // unit addGoggles type
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addGoggles _p1;
        _result = true;
    };
    case "addgroupicon": {
        // group addGroupIcon [iconClass, offset]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 addGroupIcon [_p1, _p2];
    };
    case "addhandgunitem": {
        // unit addHandgunItem item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addHandgunItem _p1;
        _result = true;
    };
    case "addheadgear": {
        // unit addHeadgear item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addHeadgear _p1;
        _result = true;
    };
    case "additem": {
        // unit addItem item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addItem _p1;
        _result = true;
    };
    case "additemcargo": {
        // box addItemCargo [item, count]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 addItemCargo [_p1, _p2];
        _result = true;
    };
    case "additemcargoglobal": {
        // box addItemCargoGlobal [item, count]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 addItemCargoGlobal [_p1, _p2];
        _result = true;
    };
    case "additempool": {
        // addItemPool [itemName, count]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        addItemPool [_p0, _p1];
        _result = true;
    };
    case "additemtobackpack": {
        // unit addItemToBackpack item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addItemToBackpack _p1;
        _result = true;
    };
    case "additemtouniform": {
        // unit addItemToUniform item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addItemToUniform _p1;
        _result = true;
    };
    case "additemtovest": {
        // unit addItemToVest item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addItemToVest _p1;
        _result = true;
    };
    case "addlivestats": {
        // unit addLiveStats score
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addLiveStats _p1;
        _result = true;
    };
    case "addmagazine": {
        // unitName addMagazine magazineName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addMagazine _p1;
        _result = true;
    };
    case "addmagazine": {
        // unitName addMagazine [magazineName, ammoCount]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 addMagazine [_p1, _p2];
        _result = true;
    };
    case "addmagazineammocargo": {
        // cargospace addMagazineAmmoCargo [magazine, quantity, ammocount]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 addMagazineAmmoCargo [_p1, _p2, _p3];
        _result = true;
    };
    case "addmagazinecargo": {
        // vehicleName addMagazineCargo [magazineName, count]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 addMagazineCargo [_p1, _p2];
        _result = true;
    };
    case "addmagazinecargoglobal": {
        // vehicleName addMagazineCargoGlobal [magazineName, count]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 addMagazineCargoGlobal [_p1, _p2];
        _result = true;
    };
    case "addmagazineglobal": {
        // unit addMagazineGlobal magazineName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addMagazineGlobal _p1;
        _result = true;
    };
    case "addmagazinepool": {
        // addMagazinePool  [magazineName, count]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        addMagazinePool  [_p0, _p1];
        _result = true;
    };
    case "addmagazines": {
        // unit addMagazines [magazineName, count]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 addMagazines [_p1, _p2];
        _result = true;
    };
    case "addmagazineturret": {
        // vehicle addMagazineTurret [magazineName, turretPath, ammoCount]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 addMagazineTurret [_p1, _p2, _p3];
        _result = true;
    };
    case "addmissioneventhandler": {
        // addMissionEventHandler  [event, expression, arguments]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = addMissionEventHandler  [_p0, _p1, _p2];
    };
    case "addmpeventhandler": {
        // object addMPEventHandler [type, expression]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 addMPEventHandler [_p1, _p2];
    };
    case "addmusiceventhandler": {
        // addMusicEventHandler [type, function]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = addMusicEventHandler [_p0, _p1];
    };
    case "addonfiles": {
        // addonFiles [pboPrefix, fileExtension]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        addonFiles [_p0, _p1];
        _result = true;
    };
    case "addownedmine": {
        // unit addOwnedMine mine
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addOwnedMine _p1;
        _result = true;
    };
    case "addplayerscores": {
        // unit addPlayerScores values
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addPlayerScores _p1;
        _result = true;
    };
    case "addprimaryweaponitem": {
        // unit addPrimaryWeaponItem item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addPrimaryWeaponItem _p1;
        _result = true;
    };
    case "addpublicvariableeventhandler": {
        // varName addPublicVariableEventHandler  code
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addPublicVariableEventHandler  _p1;
        _result = true;
    };
    case "addpublicvariableeventhandler": {
        // varName addPublicVariableEventHandler  [target, code]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 addPublicVariableEventHandler  [_p1, _p2];
        _result = true;
    };
    case "addrating": {
        // unitName addRating rating
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addRating _p1;
        _result = true;
    };
    case "addresources": {
        // teamMember addResources [resource1, resource2, ...]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 addResources [_p1, _p2, ...];
        _result = true;
    };
    case "addscore": {
        // unit addScore score
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addScore _p1;
        _result = true;
    };
    case "addscoreside": {
        // side addScoreSide value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addScoreSide _p1;
        _result = true;
    };
    case "addsecondaryweaponitem": {
        // unit addSecondaryWeaponItem item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addSecondaryWeaponItem _p1;
        _result = true;
    };
    case "addswitchableunit": {
        // addSwitchableUnit unit
        private _p0 = _args param [0];
        addSwitchableUnit _p0;
        _result = true;
    };
    case "addteammember": {
        // team addTeamMember member
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addTeamMember _p1;
        _result = true;
    };
    case "addtoremainscollector": {
        // addToRemainsCollector remains
        private _p0 = _args param [0];
        addToRemainsCollector _p0;
        _result = true;
    };
    case "addtorque": {
        // object addTorque torque
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addTorque _p1;
        _result = true;
    };
    case "adduniform": {
        // unit addUniform type
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addUniform _p1;
        _result = true;
    };
    case "adduseractioneventhandler": {
        // addUserActionEventHandler  [keyName, event, expression]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = addUserActionEventHandler  [_p0, _p1, _p2];
    };
    case "addvehicle": {
        // groupName addVehicle vehicleName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addVehicle _p1;
        _result = true;
    };
    case "addvest": {
        // unit addVest type
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addVest _p1;
        _result = true;
    };
    case "addweapon": {
        // object addWeapon weapon
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addWeapon _p1;
        _result = true;
    };
    case "addweaponcargo": {
        // vehicleName addWeaponCargo [weaponName, count]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 addWeaponCargo [_p1, _p2];
        _result = true;
    };
    case "addweaponcargoglobal": {
        // vehicleName addWeaponCargoGlobal [weaponName, count]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 addWeaponCargoGlobal [_p1, _p2];
        _result = true;
    };
    case "addweaponglobal": {
        // object addWeaponGlobal weapon
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 addWeaponGlobal _p1;
        _result = true;
    };
    case "addweaponitem": {
        // unit addWeaponItem [weaponName, itemName, instant]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 addWeaponItem [_p1, _p2, _p3];
        _result = true;
    };
    case "addweaponitem": {
        // unit addWeaponItem [weaponName, [itemName, ammoCount, muzzleName], instant]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _p0 addWeaponItem [_p1, [_p2, _p3, _p4], _p5];
        _result = true;
    };
    case "addweaponpool": {
        // addWeaponPool  [weaponName, count]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        addWeaponPool  [_p0, _p1];
        _result = true;
    };
    case "addweaponturret": {
        // vehicle addWeaponTurret [weaponName, turretPath]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 addWeaponTurret [_p1, _p2];
        _result = true;
    };
    case "addweaponwithattachmentscargo": {
        // container addWeaponWithAttachmentsCargo [weaponConfiguration, weaponsCount]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 addWeaponWithAttachmentsCargo [_p1, _p2];
        _result = true;
    };
    case "addweaponwithattachmentscargoglobal": {
        // container addWeaponWithAttachmentsCargoGlobal [weaponConfiguration, weaponsCount]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 addWeaponWithAttachmentsCargoGlobal [_p1, _p2];
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
