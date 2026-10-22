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
    case "remove3denconnection": {
        // remove3DENConnection [type, from, to]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = remove3DENConnection [_p0, _p1, _p2];
    };
    case "remove3deneventhandler": {
        // remove3DENEventHandler [type,id]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        remove3DENEventHandler [_p0,_p1];
        _result = true;
    };
    case "remove3denlayer": {
        // remove3DENLayer layerID
        private _p0 = _args param [0];
        _result = remove3DENLayer _p0;
    };
    case "removeaction": {
        // unit removeAction actionID
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeAction _p1;
        _result = true;
    };
    case "removeall3deneventhandlers": {
        // removeAll3DENEventHandlers type
        private _p0 = _args param [0];
        removeAll3DENEventHandlers _p0;
        _result = true;
    };
    case "removeallactions": {
        // removeAllActions obj
        private _p0 = _args param [0];
        removeAllActions _p0;
        _result = true;
    };
    case "removeallassigneditems": {
        // removeAllAssignedItems unit
        private _p0 = _args param [0];
        removeAllAssignedItems _p0;
        _result = true;
    };
    case "removeallbinocularitems": {
        // removeAllBinocularItems unit
        private _p0 = _args param [0];
        removeAllBinocularItems _p0;
        _result = true;
    };
    case "removeallcontainers": {
        // removeAllContainers unit
        private _p0 = _args param [0];
        removeAllContainers _p0;
        _result = true;
    };
    case "removeallcuratoraddons": {
        // removeAllCuratorAddons curatorObj
        private _p0 = _args param [0];
        removeAllCuratorAddons _p0;
        _result = true;
    };
    case "removeallcuratorcameraareas": {
        // removeAllCuratorCameraAreas curatorObj
        private _p0 = _args param [0];
        removeAllCuratorCameraAreas _p0;
        _result = true;
    };
    case "removeallcuratoreditingareas": {
        // removeAllCuratorEditingAreas curatorObj
        private _p0 = _args param [0];
        removeAllCuratorEditingAreas _p0;
        _result = true;
    };
    case "removealleventhandlers": {
        // target removeAllEventHandlers handlerType
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeAllEventHandlers _p1;
        _result = true;
    };
    case "removeallhandgunitems": {
        // removeAllHandgunItems unit
        private _p0 = _args param [0];
        removeAllHandgunItems _p0;
        _result = true;
    };
    case "removeallitems": {
        // removeAllItems unit
        private _p0 = _args param [0];
        removeAllItems _p0;
        _result = true;
    };
    case "removeallitemswithmagazines": {
        // removeAllItemsWithMagazines unit
        private _p0 = _args param [0];
        removeAllItemsWithMagazines _p0;
        _result = true;
    };
    case "removeallmissioneventhandlers": {
        // removeAllMissionEventHandlers type
        private _p0 = _args param [0];
        removeAllMissionEventHandlers _p0;
        _result = true;
    };
    case "removeallmpeventhandlers": {
        // objectName removeAllMPEventHandlers event
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeAllMPEventHandlers _p1;
        _result = true;
    };
    case "removeallmusiceventhandlers": {
        // removeAllMusicEventHandlers type
        private _p0 = _args param [0];
        removeAllMusicEventHandlers _p0;
        _result = true;
    };
    case "removeallownedmines": {
        // removeAllOwnedMines unit
        private _p0 = _args param [0];
        removeAllOwnedMines _p0;
        _result = true;
    };
    case "removeallprimaryweaponitems": {
        // removeAllPrimaryWeaponItems unit
        private _p0 = _args param [0];
        removeAllPrimaryWeaponItems _p0;
        _result = true;
    };
    case "removeallsecondaryweaponitems": {
        // removeAllSecondaryWeaponItems unit
        private _p0 = _args param [0];
        removeAllSecondaryWeaponItems _p0;
        _result = true;
    };
    case "removealluseractioneventhandlers": {
        // removeAllUserActionEventHandlers [keyName, eventType]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        removeAllUserActionEventHandlers [_p0, _p1];
        _result = true;
    };
    case "removeallweapons": {
        // removeAllWeapons unitName
        private _p0 = _args param [0];
        removeAllWeapons _p0;
        _result = true;
    };
    case "removebackpack": {
        // removeBackpack unit
        private _p0 = _args param [0];
        removeBackpack _p0;
        _result = true;
    };
    case "removebackpackglobal": {
        // removeBackpackGlobal unit
        private _p0 = _args param [0];
        removeBackpackGlobal _p0;
        _result = true;
    };
    case "removebinocularitem": {
        // unit removeBinocularItem item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeBinocularItem _p1;
        _result = true;
    };
    case "removeclothing": {
        // unit removeClothing item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeClothing _p1;
        _result = true;
    };
    case "removecuratoraddons": {
        // curatorObj removeCuratorAddons addons
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeCuratorAddons _p1;
        _result = true;
    };
    case "removecuratorcameraarea": {
        // curatorObj removeCuratorCameraArea cameraAreaID
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeCuratorCameraArea _p1;
        _result = true;
    };
    case "removecuratoreditableobjects": {
        // curatorObj removeCuratorEditableObjects [[objects], removeCrew]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 removeCuratorEditableObjects [[_p1], _p2];
        _result = true;
    };
    case "removecuratoreditingarea": {
        // curatorObj removeCuratorEditingArea editAreaID
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeCuratorEditingArea _p1;
        _result = true;
    };
    case "removediaryrecord": {
        // unit removeDiaryRecord [subject, diaryRecord]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 removeDiaryRecord [_p1, _p2];
        _result = true;
    };
    case "removediarysubject": {
        // player removeDiarySubject diaryPage
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeDiarySubject _p1;
        _result = true;
    };
    case "removeeventhandler": {
        // target removeEventHandler [type, index]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 removeEventHandler [_p1, _p2];
        _result = true;
    };
    case "removefromremainscollector": {
        // removeFromRemainsCollector remains
        private _p0 = _args param [0];
        removeFromRemainsCollector _p0;
        _result = true;
    };
    case "removegoggles": {
        // removeGoggles unit
        private _p0 = _args param [0];
        removeGoggles _p0;
        _result = true;
    };
    case "removegroupicon": {
        // group removeGroupIcon iconID
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeGroupIcon _p1;
        _result = true;
    };
    case "removehandgunitem": {
        // unit removeHandgunItem item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeHandgunItem _p1;
        _result = true;
    };
    case "removeheadgear": {
        // removeHeadgear unit
        private _p0 = _args param [0];
        removeHeadgear _p0;
        _result = true;
    };
    case "removeitem": {
        // unit removeItem item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeItem _p1;
        _result = true;
    };
    case "removeitemfrombackpack": {
        // unit removeItemFromBackpack item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeItemFromBackpack _p1;
        _result = true;
    };
    case "removeitemfromuniform": {
        // unit removeItemFromUniform item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeItemFromUniform _p1;
        _result = true;
    };
    case "removeitemfromvest": {
        // unit removeItemFromVest item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeItemFromVest _p1;
        _result = true;
    };
    case "removeitems": {
        // unit removeItems item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeItems _p1;
        _result = true;
    };
    case "removemagazine": {
        // unitName removeMagazine magazineName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeMagazine _p1;
        _result = true;
    };
    case "removemagazineglobal": {
        // unit removeMagazineGlobal magazineName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeMagazineGlobal _p1;
        _result = true;
    };
    case "removemagazines": {
        // unitName removeMagazines magazineName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeMagazines _p1;
        _result = true;
    };
    case "removemagazinesturret": {
        // vehicle removeMagazinesTurret [magazineName, turretPath]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 removeMagazinesTurret [_p1, _p2];
        _result = true;
    };
    case "removemagazineturret": {
        // vehicle removeMagazineTurret [magazineName, turretPath]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 removeMagazineTurret [_p1, _p2];
        _result = true;
    };
    case "removemenuitem": {
        // map removeMenuItem index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeMenuItem _p1;
        _result = true;
    };
    case "removemissioneventhandler": {
        // removeMissionEventHandler [type, index]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        removeMissionEventHandler [_p0, _p1];
        _result = true;
    };
    case "removempeventhandler": {
        // unitName removeMPEventHandler [event, index]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 removeMPEventHandler [_p1, _p2];
        _result = true;
    };
    case "removemusiceventhandler": {
        // removeMusicEventHandler [type, id]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        removeMusicEventHandler [_p0, _p1];
        _result = true;
    };
    case "removeprimaryweaponitem": {
        // unit removePrimaryWeaponItem item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removePrimaryWeaponItem _p1;
        _result = true;
    };
    case "removesecondaryweaponitem": {
        // unit removeSecondaryWeaponItem item
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeSecondaryWeaponItem _p1;
        _result = true;
    };
    case "removesimpletask": {
        // person removeSimpleTask task
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeSimpleTask _p1;
        _result = true;
    };
    case "removeswitchableunit": {
        // removeSwitchableUnit  unitName
        private _p0 = _args param [0];
        removeSwitchableUnit  _p0;
        _result = true;
    };
    case "removeteammember": {
        // team removeTeamMember member
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeTeamMember _p1;
        _result = true;
    };
    case "removeuniform": {
        // removeUniform unit
        private _p0 = _args param [0];
        removeUniform _p0;
        _result = true;
    };
    case "removeuseractioneventhandler": {
        // removeUserActionEventHandler  [keyName, event, index]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        removeUserActionEventHandler  [_p0, _p1, _p2];
        _result = true;
    };
    case "removevest": {
        // removeVest unit
        private _p0 = _args param [0];
        removeVest _p0;
        _result = true;
    };
    case "removeweapon": {
        // unit removeWeapon weapon
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeWeapon _p1;
        _result = true;
    };
    case "removeweaponglobal": {
        // unit removeWeaponGlobal weapon
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 removeWeaponGlobal _p1;
        _result = true;
    };
    case "removeweaponturret": {
        // vehicle removeWeaponTurret [weaponName, turretPath]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 removeWeaponTurret [_p1, _p2];
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
