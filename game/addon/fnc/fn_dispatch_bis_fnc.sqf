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
    case "bis_fnc_3dcredits": {
        // [text, position, minDist, fadeDist] spawn BIS_fnc_3Dcredits
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2, _p3] spawn BIS_fnc_3Dcredits;
        _result = true;
    };
    case "bis_fnc_3den_onkeydown": {
        // [display, button, shift, ctrl, alt] call BIS_fnc_3den_onKeyDown
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_3den_onKeyDown;
    };
    case "bis_fnc_3den_onkeyup": {
        // [display, button, shift, ctrl, alt] call BIS_fnc_3den_onKeyUp
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_3den_onKeyUp;
    };
    case "bis_fnc_3dencamera": {
        // [mode] call BIS_fnc_3DENCamera
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_3DENCamera;
        _result = true;
    };
    case "bis_fnc_3dencontrolshint": {
        // [mode] call BIS_fnc_3DENControlsHint
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_3DENControlsHint;
        _result = true;
    };
    case "bis_fnc_3dendiagfonts": {
        // fontID call BIS_fnc_3DENDiagFonts
        private _p0 = _args param [0];
        _p0 call BIS_fnc_3DENDiagFonts;
        _result = true;
    };
    case "bis_fnc_3denentitymenu": {
        // [mode] call BIS_fnc_3DENEntityMenu
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_3DENEntityMenu;
        _result = true;
    };
    case "bis_fnc_3denexportsqf": {
        // [showWindow,exportLayers,center,checkBlacklist] call BIS_fnc_3DENExportSQF
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0,_p1,_p2,_p3] call BIS_fnc_3DENExportSQF;
        _result = true;
    };
    case "bis_fnc_3denflashlight": {
        // mode call BIS_fnc_3DENFlashlight
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_3DENFlashlight;
    };
    case "bis_fnc_3dengrid": {
        // [mode, input] call BIS_fnc_3DENGrid
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_3DENGrid;
        _result = true;
    };
    case "bis_fnc_3denintel": {
        // [controlGroup, value] call BIS_fnc_3DENIntel
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_3DENIntel;
        _result = true;
    };
    case "bis_fnc_3denlistlocations": {
        // [mode] call BIS_fnc_3DENListLocations
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_3DENListLocations;
        _result = true;
    };
    case "bis_fnc_3denmoduledescription": {
        // [ctrl,cfg] call BIS_fnc_3DENModuleDescription
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0,_p1] call BIS_fnc_3DENModuleDescription;
        _result = true;
    };
    case "bis_fnc_3denshowmessage": {
        // [text, title, buttonOK, buttonCancel, icon, parentDisplay] call BIS_fnc_3DENShowMessage
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _result = [_p0, _p1, _p2, _p3, _p4, _p5] call BIS_fnc_3DENShowMessage;
    };
    case "bis_fnc_3dentoolbar": {
        // [mode] call BIS_fnc_3DENToolbar
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_3DENToolbar;
    };
    case "bis_fnc_3dentutorial": {
        // [path, index, oneStep, display] call BIS_fnc_3DENTutorial
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2, _p3] call BIS_fnc_3DENTutorial;
        _result = true;
    };
    case "bis_fnc_3denvisionmode": {
        // mode call BIS_fnc_3DENVisionMode
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_3DENVisionMode;
    };
    case "bis_fnc_aan": {
        // [headline, rollingText] spawn BIS_fnc_AAN
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] spawn BIS_fnc_AAN;
        _result = true;
    };
    case "bis_fnc_activateaddons": {
        // [addons] call BIS_fnc_activateAddons
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_activateAddons;
        _result = true;
    };
    case "bis_fnc_addclassoo": {
        // class call BIS_fnc_addClassOO
        private _p0 = _args param [0];
        _p0 call BIS_fnc_addClassOO;
        _result = true;
    };
    case "bis_fnc_addcommmenuitem": {
        // [owner, itemClass, textArguments, expressionArguments, notification] call BIS_fnc_addCommMenuItem
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_addCommMenuItem;
    };
    case "bis_fnc_addcuratorareafromtrigger": {
        // [curatorLogic, triggers, checkedPosition, triggerType, editingArea, cameraArea] call BIS_fnc_addCuratorAreaFromTrigger
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _result = [_p0, _p1, _p2, _p3, _p4, _p5] call BIS_fnc_addCuratorAreaFromTrigger;
    };
    case "bis_fnc_addrespawninventory": {
        // [target, inventoryParams] call BIS_fnc_addRespawnInventory
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_addRespawnInventory;
    };
    case "bis_fnc_addrespawnposition": {
        // [target, position, name] call BIS_fnc_addRespawnPosition
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_addRespawnPosition;
    };
    case "bis_fnc_addscriptedeventhandler": {
        // [namespace, name, code] call BIS_fnc_addScriptedEventHandler
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_addScriptedEventHandler;
    };
    case "bis_fnc_addstackedeventhandler": {
        // [id, event, code, arguments] call BIS_fnc_addStackedEventHandler
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_addStackedEventHandler;
    };
    case "bis_fnc_addsupportlink": {
        // [requesterUnit, requesterMod, providerMod] call BIS_fnc_addSupportLink
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_addSupportLink;
        _result = true;
    };
    case "bis_fnc_addtopairs": {
        // [array, key, value, copyArray] call BIS_fnc_addToPairs
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_addToPairs;
    };
    case "bis_fnc_addvirtualbackpackcargo": {
        // [object,backpackClasses,addItemsGlobal,arsenal] call BIS_fnc_addVirtualBackpackCargo
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0,_p1,_p2,_p3] call BIS_fnc_addVirtualBackpackCargo;
        _result = true;
    };
    case "bis_fnc_addvirtualitemcargo": {
        // [object, itemClasses, addItemsGlobal, arsenal, mode, itemType] call BIS_fnc_addVirtualItemCargo
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        [_p0, _p1, _p2, _p3, _p4, _p5] call BIS_fnc_addVirtualItemCargo;
        _result = true;
    };
    case "bis_fnc_addvirtualmagazinecargo": {
        // [object,magClasses,addItemsGlobal,arsenal] call BIS_fnc_addVirtualMagazineCargo
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0,_p1,_p2,_p3] call BIS_fnc_addVirtualMagazineCargo;
        _result = true;
    };
    case "bis_fnc_addvirtualweaponcargo": {
        // [object,weaponClasses,addItemsGlobal,arsenal] call BIS_fnc_addVirtualWeaponCargo
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0,_p1,_p2,_p3] call BIS_fnc_addVirtualWeaponCargo;
        _result = true;
    };
    case "bis_fnc_addweapon": {
        // [unit, weaponClassName, quantity, type] call BIS_fnc_addWeapon
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_addWeapon;
    };
    case "bis_fnc_advhint": {
        // [classes, duration1, condition1, duration2, condition2, showing, onlyFullHint, onlyOnce, useSound] call BIS_fnc_advHint
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        private _p7 = _args param [7];
        private _p8 = _args param [8];
        [_p0, _p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8] call BIS_fnc_advHint;
        _result = true;
    };
    case "bis_fnc_advhintarg": {
        // [arguments,HTMLColour,hintClass] call BIS_fnc_advHintArg
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0,_p1,_p2] call BIS_fnc_advHintArg;
    };
    case "bis_fnc_advhintformat": {
        // [topic,hint,subHint,colour] call BIS_fnc_advHintFormat
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0,hint,_p2,_p3] call BIS_fnc_advHintFormat;
        _result = true;
    };
    case "bis_fnc_aircraftcatapultlaunch": {
        // [aircraft, direction] call BIS_fnc_aircraftCatapultLaunch
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_aircraftCatapultLaunch;
        _result = true;
    };
    case "bis_fnc_aircraftfoldingwings": {
        // [aircraft, animationState] call BIS_fnc_aircraftFoldingWings
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_aircraftFoldingWings;
        _result = true;
    };
    case "bis_fnc_aircrafttailhook": {
        // [aircraft] call BIS_fnc_aircraftTailhook
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_aircraftTailhook;
        _result = true;
    };
    case "bis_fnc_aircrafttailhookai": {
        // [params, isLanding] call BIS_fnc_aircraftTailhookAi
        private _p0 = _args param [0];
        [_p0, isLanding] call BIS_fnc_aircraftTailhookAi;
        _result = true;
    };
    case "bis_fnc_aligntabs": {
        // array call BIS_fnc_alignTabs
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_alignTabs;
    };
    case "bis_fnc_allsynchronizedobjects": {
        // [object, filter] call BIS_fnc_allSynchronizedObjects
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_allSynchronizedObjects;
    };
    case "bis_fnc_allturrets": {
        // vehicleClass call BIS_fnc_allTurrets
        private _p0 = _args param [0];
        _p0 call BIS_fnc_allTurrets;
        _result = true;
    };
    case "bis_fnc_allturrets": {
        // [vehicleClass, personTurrets] call BIS_fnc_allTurrets
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_allTurrets;
    };
    case "bis_fnc_ambientanim": {
        // [unit, animationSet, equipmentLevel, snapTo, interpolate, attachToLogic] call BIS_fnc_ambientAnim
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        [_p0, _p1, _p2, _p3, _p4, _p5] call BIS_fnc_ambientAnim;
        _result = true;
    };
    case "bis_fnc_ambientanimcombat": {
        // [unit, animationSet, equipmentLevel, condition, behaviour] call BIS_fnc_ambientAnimCombat
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_ambientAnimCombat;
        _result = true;
    };
    case "bis_fnc_ambientanimgetparams": {
        // animType call BIS_fnc_ambientAnimGetParams
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_ambientAnimGetParams;
    };
    case "bis_fnc_ambientblacklist": {
        // [input] call BIS_fnc_ambientBlacklist
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_ambientBlacklist;
    };
    case "bis_fnc_ambientblacklistadd": {
        // [trigger] call BIS_fnc_ambientBlacklistAdd
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_ambientBlacklistAdd;
    };
    case "bis_fnc_ambientflyby": {
        // [startPos, endPos, altitude, speedMode, classname, side] call BIS_fnc_ambientFlyby
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _result = [_p0, _p1, _p2, _p3, _p4, _p5] call BIS_fnc_ambientFlyby;
    };
    case "bis_fnc_ambientplanes": {
        // [quantity, areaRadius, dirStep] call BIS_fnc_ambientPlanes
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_ambientPlanes;
        _result = true;
    };
    case "bis_fnc_animalbehaviour": {
        // [animal] call BIS_fnc_animalBehaviour
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_animalBehaviour;
        _result = true;
    };
    case "bis_fnc_animalsitespawn": {
        // [animalSite, classnamesToSpawn, radius] call BIS_fnc_animalSiteSpawn
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_animalSiteSpawn;
        _result = true;
    };
    case "bis_fnc_animatepicture": {
        // [control, durationOrSpeed, [translationPosition, isRelativeTranslation, useDuration], [scalePosition, isRelativeScale, scalePivot], alpha] call BIS_fnc_animatePicture
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        private _p7 = _args param [7];
        private _p8 = _args param [8];
        _result = [_p0, _p1, [_p2, _p3, _p4], [_p5, _p6, _p7], _p8] call BIS_fnc_animatePicture;
    };
    case "bis_fnc_arefriendly": {
        // [side1, side2] call BIS_fnc_areFriendly
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_areFriendly;
    };
    case "bis_fnc_arithmeticmean": {
        // numbers call BIS_fnc_arithmeticMean
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_arithmeticMean;
    };
    case "bis_fnc_arraycompare": {
        // [array1, array2] call BIS_fnc_arrayCompare
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_arrayCompare;
    };
    case "bis_fnc_arrayinsert": {
        // [array1, array2, index] call BIS_fnc_arrayInsert
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_arrayInsert;
    };
    case "bis_fnc_arraypop": {
        // array call BIS_fnc_arrayPop
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_arrayPop;
    };
    case "bis_fnc_arraypush": {
        // [array, element] call BIS_fnc_arrayPush
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_arrayPush;
    };
    case "bis_fnc_arraypushstack": {
        // [array1, array2] call BIS_fnc_arrayPushStack
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_arrayPushStack;
    };
    case "bis_fnc_arrayshift": {
        // [array] call BIS_fnc_arrayShift
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_arrayShift;
    };
    case "bis_fnc_arrayshuffle": {
        // array call BIS_fnc_arrayShuffle
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_arrayShuffle;
    };
    case "bis_fnc_arrayunshift": {
        // [array, value] call BIS_fnc_arrayUnShift
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_arrayUnShift;
    };
    case "bis_fnc_arsenal": {
        // [mode, params] call BIS_fnc_arsenal
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_arsenal;
        _result = true;
    };
    case "bis_fnc_assignplayerrole": {
        // [vehicle, role, path] call BIS_fnc_assignPlayerRole
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_assignPlayerRole;
    };
    case "bis_fnc_attachtorelative": {
        // [object1, object2, visual] call BIS_fnc_attachToRelative
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_attachToRelative;
        _result = true;
    };
    case "bis_fnc_basevehicle": {
        // class call BIS_fnc_baseVehicle
        private _p0 = _args param [0];
        _p0 call BIS_fnc_baseVehicle;
        _result = true;
    };
    case "bis_fnc_baseweapon": {
        // [weaponName] call BIS_fnc_baseWeapon
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_baseWeapon;
    };
    case "bis_fnc_berp": {
        // [a, b, delta] call BIS_fnc_berp
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_berp;
    };
    case "bis_fnc_berpvector": {
        // [a, b, delta] call BIS_fnc_berpVector
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_berpVector;
    };
    case "bis_fnc_bitflagscheck": {
        // [flagset, flag] call BIS_fnc_bitflagsCheck
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_bitflagsCheck;
        _result = true;
    };
    case "bis_fnc_bitflagsflip": {
        // [flagset, flag] call BIS_fnc_bitflagsFlip
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_bitflagsFlip;
        _result = true;
    };
    case "bis_fnc_bitflagsset": {
        // [flagset, flag] call BIS_fnc_bitflagsSet
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_bitflagsSet;
        _result = true;
    };
    case "bis_fnc_bitflagstoarray": {
        // flagset call BIS_fnc_bitflagsToArray
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_bitflagsToArray;
    };
    case "bis_fnc_bitflagsunset": {
        // [flagset, flag] call BIS_fnc_bitflagsUnset
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_bitflagsUnset;
        _result = true;
    };
    case "bis_fnc_bitwiseand": {
        // [num1, num2] call BIS_fnc_bitwiseAND
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_bitwiseAND;
    };
    case "bis_fnc_bitwisenot": {
        // num call BIS_fnc_bitwiseNOT
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_bitwiseNOT;
    };
    case "bis_fnc_bitwiseor": {
        // [num1, num2] call BIS_fnc_bitwiseOR
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_bitwiseOR;
    };
    case "bis_fnc_bitwisexor": {
        // [num1, num2] call BIS_fnc_bitwiseXOR
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_bitwiseXOR;
    };
    case "bis_fnc_blackin": {
        // [id, smoothing, fadeSpeed] call BIS_fnc_blackIn
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_blackIn;
        _result = true;
    };
    case "bis_fnc_blackout": {
        // [id, smoothing, fadeSpeed] call BIS_fnc_blackOut
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_blackOut;
        _result = true;
    };
    case "bis_fnc_bleedtickets": {
        // [sides, dominanceRatio, bleedingAmount, bleedingDelay] call BIS_fnc_bleedTickets
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_bleedTickets;
    };
    case "bis_fnc_blinkmarker": {
        // [marker, blinkDuration, blinkAmount] spawn BIS_fnc_blinkMarker
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] spawn BIS_fnc_blinkMarker;
        _result = true;
    };
    case "bis_fnc_boundingboxdimensions": {
        // [object] call BIS_fnc_boundingBoxDimensions
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_boundingBoxDimensions;
    };
    case "bis_fnc_boundingboxmarker": {
        // object call BIS_fnc_boundingBoxMarker
        private _p0 = _args param [0];
        _p0 call BIS_fnc_boundingBoxMarker;
        _result = true;
    };
    case "bis_fnc_boundingcircle": {
        // object call BIS_fnc_boundingCircle
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_boundingCircle;
    };
    case "bis_fnc_briefinganimate": {
        // [markerName, stepId, delay] call BIS_fnc_briefingAnimate
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_briefingAnimate;
        _result = true;
    };
    case "bis_fnc_briefinginit": {
        // marker call BIS_fnc_briefingInit
        private _p0 = _args param [0];
        _p0 call BIS_fnc_briefingInit;
        _result = true;
    };
    case "bis_fnc_buildingpositions": {
        // param call BIS_fnc_buildingPositions
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 call BIS_fnc_buildingPositions;
    };
    case "bis_fnc_calculatedatetime": {
        // [startDate, endDateOrOffset, timeUnit] call BIS_fnc_calculateDateTime
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_calculateDateTime;
        _result = true;
    };
    case "bis_fnc_call": {
        // [params, code] call BIS_fnc_call
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_call;
    };
    case "bis_fnc_call": {
        // code call BIS_fnc_call
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_call;
    };
    case "bis_fnc_callscriptedeventhandler": {
        // [namespace, name, arguments, returnResults] call BIS_fnc_callScriptedEventHandler
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_callScriptedEventHandler;
    };
    case "bis_fnc_camera": {
        // [mode, parameter] call BIS_fnc_camera
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_camera;
        _result = true;
    };
    case "bis_fnc_camera_deleted": {
        // [camera] call BIS_fnc_camera_deleted
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_camera_deleted;
        _result = true;
    };
    case "bis_fnc_camera_getcam": {
        // [camera] call BIS_fnc_camera_getCam
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_camera_getCam;
    };
    case "bis_fnc_camera_getcinemabordersenabled": {
        // [camera] call BIS_fnc_camera_getCinemaBordersEnabled
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_camera_getCinemaBordersEnabled;
    };
    case "bis_fnc_camera_getfocus": {
        // [camera] call BIS_fnc_camera_getFocus
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_camera_getFocus;
    };
    case "bis_fnc_camera_getfov": {
        // [camera] call BIS_fnc_camera_getFOV
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_camera_getFOV;
        _result = true;
    };
    case "bis_fnc_camera_gethudenabled": {
        // [camera] call BIS_fnc_camera_getHUDEnabled
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_camera_getHUDEnabled;
    };
    case "bis_fnc_camera_getvisionmode": {
        // [camera] call BIS_fnc_camera_getVisionMode
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_camera_getVisionMode;
    };
    case "bis_fnc_camera_init": {
        // [camera] call BIS_fnc_camera_init
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_camera_init;
        _result = true;
    };
    case "bis_fnc_camera_setcam": {
        // [camera, cameraInstance] call BIS_fnc_camera_setCam
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_camera_setCam;
        _result = true;
    };
    case "bis_fnc_camera_setcinemabordersenabled": {
        // [camera, enabled] call BIS_fnc_camera_setCinemaBordersEnabled
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_camera_setCinemaBordersEnabled;
        _result = true;
    };
    case "bis_fnc_camera_setfocus": {
        // [camera, focusValues] call BIS_fnc_camera_setFocus
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_camera_setFocus;
        _result = true;
    };
    case "bis_fnc_camera_setfov": {
        // [camera, FOV] call BIS_fnc_camera_setFOV
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_camera_setFOV;
        _result = true;
    };
    case "bis_fnc_camera_sethudenabled": {
        // [camera, state] call BIS_fnc_camera_setHUDEnabled
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_camera_setHUDEnabled;
        _result = true;
    };
    case "bis_fnc_camera_setvisionmode": {
        // [camera, mode] call BIS_fnc_camera_setVisionMode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_camera_setVisionMode;
        _result = true;
    };
    case "bis_fnc_camera_tick": {
        // [camera] call BIS_fnc_camera_tick
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_camera_tick;
        _result = true;
    };
    case "bis_fnc_cameraold": {
        // [target] call BIS_fnc_cameraOld
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_cameraOld;
        _result = true;
    };
    case "bis_fnc_camfollow": {
        // [camera, target, refreshTime] call BIS_fnc_camFollow
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_camFollow;
        _result = true;
    };
    case "bis_fnc_cancelmarker": {
        // [marker, duration, fadeTime, sizeMultiplier, angleOffset] spawn BIS_fnc_cancelMarker
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        [_p0, _p1, _p2, _p3, _p4] spawn BIS_fnc_cancelMarker;
        _result = true;
    };
    case "bis_fnc_caralarm": {
        // [mode, car] call BIS_fnc_carAlarm
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_carAlarm;
        _result = true;
    };
    case "bis_fnc_cargoturretindex": {
        // [vehicle, personOrTurretPath] call BIS_fnc_cargoTurretIndex
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_cargoTurretIndex;
        _result = true;
    };
    case "bis_fnc_carrier01animatedeflectors": {
        // [carrierPart, animations, animationState] spawn BIS_fnc_carrier01AnimateDeflectors
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] spawn BIS_fnc_carrier01AnimateDeflectors;
        _result = true;
    };
    case "bis_fnc_carrier01init": {
        // carrier call BIS_fnc_carrier01Init
        private _p0 = _args param [0];
        _p0 call BIS_fnc_carrier01Init;
        _result = true;
    };
    case "bis_fnc_changecolormarker": {
        // [marker, color, duration] spawn BIS_fnc_changeColorMarker
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] spawn BIS_fnc_changeColorMarker;
        _result = true;
    };
    case "bis_fnc_cinemaborder": {
        // [mode, duration, sound, view] call BIS_fnc_cinemaBorder
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2, _p3] call BIS_fnc_cinemaBorder;
        _result = true;
    };
    case "bis_fnc_clamp": {
        // [value, min, max] call BIS_fnc_clamp
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_clamp;
    };
    case "bis_fnc_clampvector": {
        // [vector, min, max] call BIS_fnc_clampVector
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_clampVector;
    };
    case "bis_fnc_classmagazine": {
        // magazineClass call BIS_fnc_classMagazine
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_classMagazine;
    };
    case "bis_fnc_classweapon": {
        // weaponClass call BIS_fnc_classWeapon
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_classWeapon;
    };
    case "bis_fnc_clerp": {
        // [currentValue, targetValue, alpha] call BIS_fnc_clerp
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_clerp;
    };
    case "bis_fnc_codeperformance": {
        // [expression, arguments, cycles, display] call BIS_fnc_codePerformance
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_codePerformance;
    };
    case "bis_fnc_colorconfigtorgba": {
        // configColor call BIS_fnc_colorConfigToRGBA
        private _p0 = _args param [0];
        _p0 call BIS_fnc_colorConfigToRGBA;
        _result = true;
    };
    case "bis_fnc_colormarker": {
        // [marker, color, duration] spawn BIS_fnc_colorMarker
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] spawn BIS_fnc_colorMarker;
        _result = true;
    };
    case "bis_fnc_colorrgbatohtml": {
        // colorArray call BIS_fnc_colorRGBAtoHTML
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_colorRGBAtoHTML;
    };
    case "bis_fnc_colorrgbatotexture": {
        // color call BIS_fnc_colorRGBAtoTexture
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_colorRGBAtoTexture;
    };
    case "bis_fnc_colorrgbtohtml": {
        // colorArray call BIS_fnc_colorRGBtoHTML
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_colorRGBtoHTML;
    };
    case "bis_fnc_comparedatetimes": {
        // [date1, date2] call BIS_fnc_compareDateTimes
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_compareDateTimes;
        _result = true;
    };
    case "bis_fnc_compatibleitems": {
        // weapon call BIS_fnc_compatibleItems
        private _p0 = _args param [0];
        _p0 call BIS_fnc_compatibleItems;
        _result = true;
    };
    case "bis_fnc_compatiblemagazines": {
        // [weapon, returnHidden] call BIS_fnc_compatibleMagazines
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_compatibleMagazines;
    };
    case "bis_fnc_completedcuratorchallengescount": {
        // curator call BIS_fnc_completedCuratorChallengesCount
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_completedCuratorChallengesCount;
    };
    case "bis_fnc_conditionalselect": {
        // [items, condition] call BIS_fnc_conditionalSelect
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_conditionalSelect;
    };
    case "bis_fnc_configextremes": {
        // [paths, properties, propertyTypes, propertyDefaults] call BIS_fnc_configExtremes
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_configExtremes;
    };
    case "bis_fnc_configpath": {
        // [config, format, strict] call BIS_fnc_configPath
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_configPath;
        _result = true;
    };
    case "bis_fnc_configviewer": {
        // [parent, cfg, showOk, onSelect, onAdd, header] call BIS_fnc_configViewer
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        [_p0, _p1, _p2, _p3, _p4, _p5] call BIS_fnc_configViewer;
        _result = true;
    };
    case "bis_fnc_consolidatearray": {
        // array call BIS_fnc_consolidateArray
        private _p0 = _args param [0];
        _p0 call BIS_fnc_consolidateArray;
        _result = true;
    };
    case "bis_fnc_controlconfigs": {
        // [display,path] call BIS_fnc_controlConfigs
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0,_p1] call BIS_fnc_controlConfigs;
    };
    case "bis_fnc_controlpoint_compute": {
        // [controlPoint] call BIS_fnc_controlPoint_compute
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_controlPoint_compute;
        _result = true;
    };
    case "bis_fnc_controlpoint_computeownerkey": {
        // [controlPoint] call BIS_fnc_controlPoint_computeOwnerKey
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_controlPoint_computeOwnerKey;
    };
    case "bis_fnc_controlpoint_getownerkey": {
        // [controlPoint] call BIS_fnc_controlPoint_getOwnerKey
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_controlPoint_getOwnerKey;
    };
    case "bis_fnc_controlpoint_isarrive": {
        // [controlPoint] call BIS_fnc_controlPoint_isArrive
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_controlPoint_isArrive;
    };
    case "bis_fnc_controlpoint_setisarrive": {
        // [controlPoint, isArrive] call BIS_fnc_controlPoint_setIsArrive
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_controlPoint_setIsArrive;
        _result = true;
    };
    case "bis_fnc_convertunits": {
        // [value, from, to, mode, precision] call BIS_fnc_convertUnits
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_convertUnits;
        _result = true;
    };
    case "bis_fnc_cpwaituntil": {
        // [condition, interval] spawn BIS_fnc_CPWaitUntil
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] spawn BIS_fnc_CPWaitUntil;
        _result = true;
    };
    case "bis_fnc_createlogrecord": {
        // [owner, title, text] call BIS_fnc_createLogRecord
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_createLogRecord;
    };
    case "bis_fnc_createobjectoo": {
        // [class,params] call BIS_fnc_createObjectOO
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0,_p1] call BIS_fnc_createObjectOO;
    };
    case "bis_fnc_createruin": {
        // building call BIS_fnc_createRuin
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_createRuin;
    };
    case "bis_fnc_createtooltip": {
        // [input, ctrl, mousePos] call BIS_fnc_createTooltip
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_createTooltip;
    };
    case "bis_fnc_credits_movie": {
        // [display, mode] call BIS_fnc_credits_movie
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_credits_movie;
        _result = true;
    };
    case "bis_fnc_crossproduct": {
        // [vector1, vector2] call BIS_fnc_crossProduct
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_crossProduct;
    };
    case "bis_fnc_ctrlfittotextheight": {
        // [control,offset,time] call BIS_fnc_ctrlFitToTextHeight
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0,_p1,_p2] call BIS_fnc_ctrlFitToTextHeight;
    };
    case "bis_fnc_ctrlsetscale": {
        // [control,scale,time] spawn BIS_fnc_ctrlSetScale
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0,_p1,_p2] spawn BIS_fnc_ctrlSetScale;
    };
    case "bis_fnc_ctrltextheight": {
        // [control] call BIS_fnc_ctrlTextHeight
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_ctrlTextHeight;
    };
    case "bis_fnc_curatorattachobject": {
        // [object] call BIS_fnc_curatorAttachObject
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_curatorAttachObject;
    };
    case "bis_fnc_curatorautomatic": {
        // [curator, sides, cheatCoef, infantryProb, groundProb, airProb, marineProb] call BIS_fnc_curatorAutomatic
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        [_p0, _p1, _p2, _p3, _p4, _p5, _p6] call BIS_fnc_curatorAutomatic;
        _result = true;
    };
    case "bis_fnc_curatorobjectedited": {
        // [module, object] call BIS_fnc_curatorObjectEdited
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_curatorObjectEdited;
    };
    case "bis_fnc_curatorobjectplaced": {
        // [module,object] call BIS_fnc_curatorObjectPlaced
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0,_p1] call BIS_fnc_curatorObjectPlaced;
    };
    case "bis_fnc_curatorobjectregistered": {
        // [curator, code] call BIS_fnc_curatorObjectRegistered
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_curatorObjectRegistered;
        _result = true;
    };
    case "bis_fnc_curatorobjectregisteredtable": {
        // [curatorLogic, [className, cost, className, cost...]] call BIS_fnc_curatorObjectRegisteredTable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, [_p1, _p2, _p1, _p2...]] call BIS_fnc_curatorObjectRegisteredTable;
    };
    case "bis_fnc_curatorpinged": {
        // [module, player] call BIS_fnc_curatorPinged
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_curatorPinged;
    };
    case "bis_fnc_curatorvisionmodes": {
        // [curator] call BIS_fnc_curatorVisionModes
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_curatorVisionModes;
        _result = true;
    };
    case "bis_fnc_curatorwaypointplaced": {
        // [object, waypointGroup, waypointID] call BIS_fnc_curatorWaypointPlaced
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_curatorWaypointPlaced;
    };
    case "bis_fnc_cutdecimals": {
        // [number, precision] call BIS_fnc_cutDecimals
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_cutDecimals;
    };
    case "bis_fnc_dataterminalanimate": {
        // [dataTerminal, step] call BIS_fnc_dataTerminalAnimate
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_dataTerminalAnimate;
        _result = true;
    };
    case "bis_fnc_dataterminalcolor": {
        // [dataTerminal, step1color, step2color, step3color] call BIS_fnc_dataTerminalColor
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_dataTerminalColor;
    };
    case "bis_fnc_dbclassset": {
        // [database, path, (value)] call BIS_fnc_dbClassSet
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, (_p2)] call BIS_fnc_dbClassSet;
        _result = true;
    };
    case "bis_fnc_dbimportxml": {
        // xmlFile call BIS_fnc_dbImportXML
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_dbImportXML;
    };
    case "bis_fnc_dbvalueid": {
        // valueString call BIS_fnc_dbValueId
        private _p0 = _args param [0];
        _p0 call BIS_fnc_dbValueId;
        _result = true;
    };
    case "bis_fnc_debugconsoleexec": {
        // [target, code] call BIS_fnc_debugConsoleExec
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_debugConsoleExec;
        _result = true;
    };
    case "bis_fnc_decodeflags": {
        // scalar call BIS_fnc_decodeFlags
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_decodeFlags;
    };
    case "bis_fnc_decodeflags2": {
        // [value, size] call BIS_fnc_decodeFlags2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_decodeFlags2;
        _result = true;
    };
    case "bis_fnc_deleteinventory": {
        // [unit,input] call BIS_fnc_deleteInventory
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0,_p1] call BIS_fnc_deleteInventory;
    };
    case "bis_fnc_deletetask": {
        // [taskID, owner, removeFromJIP] call BIS_fnc_deleteTask
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_deleteTask;
        _result = true;
    };
    case "bis_fnc_deletevehiclecrew": {
        // [vehicle, crewMember] call BIS_fnc_deleteVehicleCrew
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_deleteVehicleCrew;
        _result = true;
    };
    case "bis_fnc_deltatime": {
        // [id, clear] call BIS_fnc_deltaTime
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_deltaTime;
    };
    case "bis_fnc_destroycity": {
        // [position, areaSize, seed, blacklist] call BIS_fnc_destroyCity
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_destroyCity;
    };
    case "bis_fnc_diagaar": {
        // [mode, arguments] call BIS_fnc_diagAAR
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_diagAAR;
        _result = true;
    };
    case "bis_fnc_diaganim": {
        // [target] call BIS_fnc_diagAnim
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_diagAnim;
        _result = true;
    };
    case "bis_fnc_diagbulletcam": {
        // unit call BIS_fnc_diagBulletCam
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_diagBulletCam;
    };
    case "bis_fnc_diagkeytest": {
        // mode call BIS_fnc_diagKeyTest
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_diagKeyTest;
    };
    case "bis_fnc_diagknowntargets": {
        // [target, radius] call BIS_fnc_diagKnownTargets
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_diagKnownTargets;
        _result = true;
    };
    case "bis_fnc_diagloop": {
        // [code, delay] spawn BIS_fnc_diagLoop
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, delay] spawn BIS_fnc_diagLoop;
        _result = true;
    };
    case "bis_fnc_diagmissionpositions": {
        // [configPath, allUnits, isCampaign] call BIS_fnc_diagMissionPositions
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_diagMissionPositions;
    };
    case "bis_fnc_diagmissionweapons": {
        // [clipboard] call BIS_fnc_diagMissionWeapons
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_diagMissionWeapons;
    };
    case "bis_fnc_diagpreview": {
        // [container, parentClass, distance, startPos] call BIS_fnc_diagPreview
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_diagPreview;
    };
    case "bis_fnc_diagvehicleicons": {
        // [parentClass, position, map] call BIS_fnc_diagVehicleIcons
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_diagVehicleIcons;
        _result = true;
    };
    case "bis_fnc_diagwiki": {
        // [mode] call BIS_fnc_diagWiki
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_diagWiki;
    };
    case "bis_fnc_dirindicator": {
        // [origin, target, color, sizeCoef] call BIS_fnc_dirIndicator
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2, _p3] call BIS_fnc_dirIndicator;
        _result = true;
    };
    case "bis_fnc_dirteffect": {
        // [unit, damage] call BIS_fnc_dirtEffect
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_dirtEffect;
        _result = true;
    };
    case "bis_fnc_dirto": {
        // [param1, param2] call BIS_fnc_dirTo
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_dirTo;
    };
    case "bis_fnc_disablerevive": {
        // [player] call BIS_fnc_disableRevive
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_disableRevive;
        _result = true;
    };
    case "bis_fnc_disablesaving": {
        // id call BIS_fnc_disableSaving
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_disableSaving;
    };
    case "bis_fnc_displaycolorget": {
        // [tag, variable] call BIS_fnc_displayColorGet
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_displayColorGet;
    };
    case "bis_fnc_displaycolorget": {
        // init call BIS_fnc_displayColorGet
        private _p0 = _args param [0];
        _p0 call BIS_fnc_displayColorGet;
        _result = true;
    };
    case "bis_fnc_displaycolorset": {
        // [displayClass, display, commitTime, code] call BIS_fnc_displayColorSet
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_displayColorSet;
    };
    case "bis_fnc_displayloading": {
        // [onLoad, id] call BIS_fnc_displayLoading
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_displayLoading;
        _result = true;
    };
    case "bis_fnc_displayname": {
        // [config] call BIS_fnc_displayName
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_displayName;
    };
    case "bis_fnc_distance2d": {
        // [param1, param2] call BIS_fnc_distance2D
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_distance2D;
    };
    case "bis_fnc_distance2dsqr": {
        // [Point_1,Point_2] call BIS_fnc_distance2Dsqr
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0,_p1] call BIS_fnc_distance2Dsqr;
    };
    case "bis_fnc_door": {
        // [building, doorIndex, animationPhase] call BIS_fnc_door
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_door;
        _result = true;
    };
    case "bis_fnc_doorclose": {
        // [building, doorAnimation, handleDownAnimation, doorHandleUpAnimation, animationPhase] call BIS_fnc_doorClose
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_doorClose;
        _result = true;
    };
    case "bis_fnc_dooropen": {
        // [building, doorAnimation, upDownAnimation, downUpAnimation, animationPhase] call BIS_fnc_doorOpen
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_doorOpen;
        _result = true;
    };
    case "bis_fnc_dotproduct": {
        // [vector1, vector2] call BIS_fnc_dotProduct
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_dotProduct;
    };
    case "bis_fnc_drawao": {
        // [triggers, distance] call BIS_fnc_drawAO
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_drawAO;
        _result = true;
    };
    case "bis_fnc_drawarrow": {
        // [from, to, color, pars, fill, map] call BIS_fnc_drawArrow
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        [_p0, _p1, _p2, _p3, _p4, _p5] call BIS_fnc_drawArrow;
        _result = true;
    };
    case "bis_fnc_drawboundingbox": {
        // [objects, color, draw] call BIS_fnc_drawBoundingBox
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_drawBoundingBox;
    };
    case "bis_fnc_drawcuratordeaths": {
        // [unit] call BIS_fnc_drawCuratorDeaths
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_drawCuratorDeaths;
    };
    case "bis_fnc_drawrespawnpositions": {
        // [state] call BIS_fnc_drawRespawnPositions
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_drawRespawnPositions;
        _result = true;
    };
    case "bis_fnc_dynamicgroups": {
        // [mode, params] call BIS_fnc_dynamicGroups
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_dynamicGroups;
        _result = true;
    };
    case "bis_fnc_dynamictext": {
        // [text, x, y, duration, fadeInTime, deltaY, rscLayer] spawn BIS_fnc_dynamicText
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        [_p0, _p1, _p2, _p3, _p4, _p5, _p6] spawn BIS_fnc_dynamicText;
        _result = true;
    };
    case "bis_fnc_earthquake": {
        // [intensity] spawn BIS_fnc_earthquake
        private _p0 = _args param [0];
        [_p0] spawn BIS_fnc_earthquake;
        _result = true;
    };
    case "bis_fnc_easein": {
        // [a, b, alpha, exp] call BIS_fnc_easeIn
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_easeIn;
    };
    case "bis_fnc_effectfiredrifle": {
        // [unit, nil, nil, nil, ammoType] call BIS_fnc_effectFiredRifle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        [_p0, _p1, _p1, _p1, _p4] call BIS_fnc_effectFiredRifle;
        _result = true;
    };
    case "bis_fnc_egspectator": {
        // [mode, [spectator, whitelistedSides, allowAi, allowFreeCamera, allow3PPCamera, showFocusInfo, showCameraButtons, showControlsHelper, showHeader, showLists]] call BIS_fnc_EGSpectator
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
        _result = [_p0, [_p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, _p9, _p10]] call BIS_fnc_EGSpectator;
    };
    case "bis_fnc_enablesaving": {
        // id call BIS_fnc_enableSaving
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_enableSaving;
    };
    case "bis_fnc_encodeflags": {
        // flags call BIS_fnc_encodeFlags
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_encodeFlags;
    };
    case "bis_fnc_encodeflags2": {
        // arrayOfNumbers call BIS_fnc_encodeFlags2
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_encodeFlags2;
    };
    case "bis_fnc_endloadingscreen": {
        // screenId call BIS_fnc_endLoadingScreen
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_endLoadingScreen;
    };
    case "bis_fnc_endmissionserver": {
        // endType call BIS_fnc_endMissionServer
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_endMissionServer;
    };
    case "bis_fnc_enemysides": {
        // input call BIS_fnc_enemySides
        private _p0 = _args param [0];
        _p0 call BIS_fnc_enemySides;
        _result = true;
    };
    case "bis_fnc_errormsg": {
        // [message, otherParameters] call BIS_fnc_errorMsg
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_errorMsg;
        _result = true;
    };
    case "bis_fnc_establishingshot": {
        // [target, text, altitude, radius, angle, rotation, iconOptions, mode, fadeIn,waitTime] spawn BIS_fnc_establishingShot
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
        _result = [_p0, _p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8,_p9] spawn BIS_fnc_establishingShot;
    };
    case "bis_fnc_estimatedtimeleft": {
        // [time] call BIS_fnc_estimatedTimeLeft
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_estimatedTimeLeft;
    };
    case "bis_fnc_eventtimeline": {
        // [timeline, index, music, codeInterrupt, codeEnd] call BIS_fnc_eventTimeline
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_eventTimeline;
        _result = true;
    };
    case "bis_fnc_execfsm": {
        // filename call BIS_fnc_execFSM
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_execFSM;
    };
    case "bis_fnc_execfsm": {
        // [params, filename] call BIS_fnc_execFSM
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_execFSM;
    };
    case "bis_fnc_executestackedeventhandler": {
        // [EHType] call BIS_fnc_executeStackedEventHandler
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_executeStackedEventHandler;
    };
    case "bis_fnc_execvm": {
        // filename call BIS_fnc_execVM
        private _p0 = _args param [0];
        _p0 call BIS_fnc_execVM;
        _result = true;
    };
    case "bis_fnc_execvm": {
        // [arguments, filename] call BIS_fnc_execVM
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_execVM;
        _result = true;
    };
    case "bis_fnc_exp_camp_dynamicaiskill": {
        // [mode, affectedSides] call BIS_fnc_EXP_camp_dynamicAISkill
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_EXP_camp_dynamicAISkill;
        _result = true;
    };
    case "bis_fnc_exp_camp_iff": {
        // [units] call BIS_fnc_EXP_camp_IFF
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_EXP_camp_IFF;
    };
    case "bis_fnc_exp_camp_initcharacter": {
        // [unit, mode] call BIS_fnc_EXP_camp_initCharacter
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_EXP_camp_initCharacter;
    };
    case "bis_fnc_exp_camp_initclasses": {
        // [mode] call BIS_fnc_EXP_camp_initClasses
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_EXP_camp_initClasses;
    };
    case "bis_fnc_exp_camp_playerchecklist": {
        // [conditionProceed, conditionPlayer, code] call BIS_fnc_EXP_camp_playerChecklist
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_EXP_camp_playerChecklist;
    };
    case "bis_fnc_exp_camp_playtimelinevideo": {
        // [videoPath] call BIS_fnc_EXP_camp_playTimelineVideo
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_EXP_camp_playTimelineVideo;
        _result = true;
    };
    case "bis_fnc_exp_camp_setcinematicmode": {
        // [mode, fadeBlack, fadeSound] call BIS_fnc_EXP_camp_setCinematicMode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_EXP_camp_setCinematicMode;
        _result = true;
    };
    case "bis_fnc_exp_camp_setskill": {
        // [side,skillMin,skillAimMin,skillMax,skillAimMax] call BIS_fnc_EXP_camp_setSkill
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        [_p0,_p1,_p2,_p3,_p4] call BIS_fnc_EXP_camp_setSkill;
        _result = true;
    };
    case "bis_fnc_exportcfghints": {
        // [category, class] call BIS_fnc_exportCfgHints
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_exportCfgHints;
    };
    case "bis_fnc_exportcfgmagazines": {
        // [classes] spawn BIS_fnc_exportCfgMagazines
        private _p0 = _args param [0];
        _result = [_p0] spawn BIS_fnc_exportCfgMagazines;
    };
    case "bis_fnc_exportcfgpatches": {
        // [config, classes] call BIS_fnc_exportCfgPatches
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_exportCfgPatches;
    };
    case "bis_fnc_exportcfgvehicles": {
        // [mode,sides,classes,useAI] call BIS_fnc_exportCfgVehicles
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0,_p1,_p2,_p3] call BIS_fnc_exportCfgVehicles;
    };
    case "bis_fnc_exportcfgvehiclesassetdb": {
        // [side, category] call BIS_fnc_exportCfgVehiclesAssetDB
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_exportCfgVehiclesAssetDB;
        _result = true;
    };
    case "bis_fnc_exportcfgweapons": {
        // [mode, patches, types] spawn BIS_fnc_exportCfgWeapons
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] spawn BIS_fnc_exportCfgWeapons;
    };
    case "bis_fnc_exportconfighierarchy": {
        // [config,class] call BIS_fnc_exportConfigHierarchy
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0,_p1] call BIS_fnc_exportConfigHierarchy;
    };
    case "bis_fnc_exporteditorpreviews": {
        // [duration, type, sides, mods, addons, classes] spawn BIS_fnc_exportEditorPreviews
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        [_p0, _p1, _p2, _p3, _p4, _p5] spawn BIS_fnc_exportEditorPreviews;
        _result = true;
    };
    case "bis_fnc_exportfunctionstowiki": {
        // [filter, timestamp] spawn BIS_fnc_exportFunctionsToWiki
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] spawn BIS_fnc_exportFunctionsToWiki;
    };
    case "bis_fnc_exportguibaseclasses": {
        // mode call BIS_fnc_exportGUIBaseClasses
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_exportGUIBaseClasses;
    };
    case "bis_fnc_exportinventory": {
        // [unit, type, includeIdentity] call BIS_fnc_exportInventory
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_exportInventory;
    };
    case "bis_fnc_exportmaptobitxt": {
        // [resolution, size, zCoeff] call BIS_fnc_exportMapToBiTXT
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_exportMapToBiTXT;
    };
    case "bis_fnc_exportvehicle": {
        // [vehicle,vehicleClass] call BIS_fnc_exportVehicle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0,_p1] call BIS_fnc_exportVehicle;
    };
    case "bis_fnc_ffvupdate": {
        // vehicle call BIS_fnc_ffvUpdate
        private _p0 = _args param [0];
        _p0 call BIS_fnc_ffvUpdate;
        _result = true;
    };
    case "bis_fnc_filterstring": {
        // [text, allowedChars] call BIS_fnc_filterString
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_filterString;
    };
    case "bis_fnc_findallnestedelements": {
        // [array, query] call BIS_fnc_findAllNestedElements
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_findAllNestedElements;
        _result = true;
    };
    case "bis_fnc_findextreme": {
        // [numbers, mode] call BIS_fnc_findExtreme
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_findExtreme;
    };
    case "bis_fnc_findinpairs": {
        // [array, key] call BIS_fnc_findInPairs
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_findInPairs;
    };
    case "bis_fnc_findnestedelement": {
        // [array, query] call BIS_fnc_findNestedElement
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_findNestedElement;
        _result = true;
    };
    case "bis_fnc_findoverwatch": {
        // [target, maxDistance, minDistance, minHeightAbove, searchCentre] call BIS_fnc_findOverwatch
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_findOverwatch;
    };
    case "bis_fnc_findsafepos": {
        // [center, minDist, maxDist, objDist, waterMode, maxGrad, shoreMode, blacklistPos, defaultPos] call BIS_fnc_findSafePos
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        private _p7 = _args param [7];
        private _p8 = _args param [8];
        _result = [_p0, _p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8] call BIS_fnc_findSafePos;
    };
    case "bis_fnc_fire": {
        // [entity, muzzle, turret] call BIS_fnc_fire
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_fire;
        _result = true;
    };
    case "bis_fnc_firesupport": {
        // [arty,target,mag,radius,rounds,delay,conditionEnd,safezone] spawn BIS_fnc_fireSupport
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        private _p7 = _args param [7];
        _result = [_p0,_p1,_p2,_p3,_p4,_p5,_p6,_p7] spawn BIS_fnc_fireSupport;
    };
    case "bis_fnc_firesupportvirtual": {
        // [target, ammo, radius, rounds, delay, conditionEnd, safezone, alt, speed, sounds] spawn BIS_fnc_fireSupportVirtual
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
        _result = [_p0, _p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, _p9] spawn BIS_fnc_fireSupportVirtual;
    };
    case "bis_fnc_fixdate": {
        // date call BIS_fnc_fixDate
        private _p0 = _args param [0];
        _p0 call BIS_fnc_fixDate;
        _result = true;
    };
    case "bis_fnc_forcecuratorinterface": {
        // [mode, waitUntil] call BIS_fnc_forceCuratorInterface
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_forceCuratorInterface;
    };
    case "bis_fnc_formatcuratorchallengeobjects": {
        // classes call BIS_fnc_formatCuratorChallengeObjects
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_formatCuratorChallengeObjects;
    };
    case "bis_fnc_fps": {
        // [duration, sceneId, startDelay] call BIS_fnc_fps
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_fps;
        _result = true;
    };
    case "bis_fnc_ftlmanager": {
        // [functionCalled, type] call BIS_fnc_FTLmanager
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_FTLmanager;
    };
    case "bis_fnc_functionmeta": {
        // functionName call BIS_fnc_functionMeta
        private _p0 = _args param [0];
        _p0 call BIS_fnc_functionMeta;
        _result = true;
    };
    case "bis_fnc_functionpath": {
        // functionName call BIS_fnc_functionPath
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_functionPath;
    };
    case "bis_fnc_functionsdebug": {
        // mode call BIS_fnc_functionsDebug
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_functionsDebug;
    };
    case "bis_fnc_garage": {
        // [mode, params] call BIS_fnc_garage
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_garage;
        _result = true;
    };
    case "bis_fnc_gc": {
        // entity spawn BIS_fnc_GC
        private _p0 = _args param [0];
        _result = _p0 spawn BIS_fnc_GC;
    };
    case "bis_fnc_genericsentence": {
        // [class, speaker, delay, canRepeat] call BIS_fnc_genericSentence
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_genericSentence;
    };
    case "bis_fnc_geometricmean": {
        // array call BIS_fnc_geometricMean
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_geometricMean;
    };
    case "bis_fnc_getangledelta": {
        // [angleA, angleB] call BIS_fnc_getAngleDelta
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_getAngleDelta;
    };
    case "bis_fnc_getarea": {
        // param call BIS_fnc_getArea
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_getArea;
    };
    case "bis_fnc_getcfg": {
        // input call BIS_fnc_getCfg
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_getCfg;
    };
    case "bis_fnc_getcfgdata": {
        // config call BIS_fnc_getCfgData
        private _p0 = _args param [0];
        _p0 call BIS_fnc_getCfgData;
        _result = true;
    };
    case "bis_fnc_getcfgdataarray": {
        // config call BIS_fnc_getCfgDataArray
        private _p0 = _args param [0];
        _p0 call BIS_fnc_getCfgDataArray;
        _result = true;
    };
    case "bis_fnc_getcfgdatabool": {
        // config call BIS_fnc_getCfgDataBool
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_getCfgDataBool;
    };
    case "bis_fnc_getcfgisclass": {
        // configEntry call BIS_fnc_getCfgIsClass
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_getCfgIsClass;
    };
    case "bis_fnc_getcfgisclass": {
        // classNames call BIS_fnc_getCfgIsClass
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_getCfgIsClass;
    };
    case "bis_fnc_getcloudletparams": {
        // [cfgCloudletClass] call BIS_fnc_getCloudletParams
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_getCloudletParams;
        _result = true;
    };
    case "bis_fnc_getfactions": {
        // [parameter] call BIS_fnc_getFactions
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_getFactions;
        _result = true;
    };
    case "bis_fnc_getfrompairs": {
        // [array, key, defaultValue] call BIS_fnc_getFromPairs
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_getFromPairs;
    };
    case "bis_fnc_getidc": {
        // [config, ctrlName] call BIS_fnc_getIDC
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_getIDC;
    };
    case "bis_fnc_getidd": {
        // [config] call BIS_fnc_getIDD
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_getIDD;
    };
    case "bis_fnc_getintersectionsundercursor": {
        // [screenX, screenY, ignoreObj1, ignoreObj2, sortMode, maxResults, LOD1, LOD2] call BIS_fnc_getIntersectionsUnderCursor
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        private _p7 = _args param [7];
        [_p0, _p1, _p2, _p3, _p4, _p5, _p6, _p7] call BIS_fnc_getIntersectionsUnderCursor;
        _result = true;
    };
    case "bis_fnc_getlinedist": {
        // [start1, length1, start2, length2] call BIS_fnc_getLineDist
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_getLineDist;
    };
    case "bis_fnc_getmarkers": {
        // [markerPrefix] call BIS_fnc_getMarkers
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_getMarkers;
    };
    case "bis_fnc_getmarkerstate": {
        // [marker] call BIS_fnc_getMarkerState
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_getMarkerState;
    };
    case "bis_fnc_getname": {
        // [object] call BIS_fnc_getName
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_getName;
    };
    case "bis_fnc_getobjectbbd": {
        // [object] call BIS_fnc_getObjectBBD
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_getObjectBBD;
        _result = true;
    };
    case "bis_fnc_getparamvalue": {
        // paramClass call BIS_fnc_getParamValue
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_getParamValue;
    };
    case "bis_fnc_getpitchbank": {
        // object call BIS_fnc_getPitchBank
        private _p0 = _args param [0];
        _p0 call BIS_fnc_getPitchBank;
        _result = true;
    };
    case "bis_fnc_getrespawninventories": {
        // [target, showDisabled, returnAllInfo] call BIS_fnc_getRespawnInventories
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_getRespawnInventories;
        _result = true;
    };
    case "bis_fnc_getrespawnmarkers": {
        // [side, vehicleMarkers] call BIS_fnc_getRespawnMarkers
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_getRespawnMarkers;
        _result = true;
    };
    case "bis_fnc_getrespawnpositions": {
        // input call BIS_fnc_getRespawnPositions
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_getRespawnPositions;
    };
    case "bis_fnc_getservervariable": {
        // [target, varName, default] call BIS_fnc_getServerVariable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_getServerVariable;
    };
    case "bis_fnc_getturrets": {
        // [input, outputType] call BIS_fnc_getTurrets
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_getTurrets;
        _result = true;
    };
    case "bis_fnc_getunitbyuid": {
        // playerUID call BIS_fnc_getUnitByUID
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_getUnitByUID;
    };
    case "bis_fnc_getunitinsignia": {
        // [target] call BIS_fnc_getUnitInsignia
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_getUnitInsignia;
    };
    case "bis_fnc_getvehiclecustomization": {
        // [object, class] call BIS_fnc_getVehicleCustomization
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_getVehicleCustomization;
        _result = true;
    };
    case "bis_fnc_getvirtualbackpackcargo": {
        // object call BIS_fnc_getVirtualBackpackCargo
        private _p0 = _args param [0];
        _p0 call BIS_fnc_getVirtualBackpackCargo;
        _result = true;
    };
    case "bis_fnc_getvirtualitemcargo": {
        // object call BIS_fnc_getVirtualItemCargo
        private _p0 = _args param [0];
        _p0 call BIS_fnc_getVirtualItemCargo;
        _result = true;
    };
    case "bis_fnc_getvirtualmagazinecargo": {
        // object call BIS_fnc_getVirtualMagazineCargo
        private _p0 = _args param [0];
        _p0 call BIS_fnc_getVirtualMagazineCargo;
        _result = true;
    };
    case "bis_fnc_getvirtualweaponcargo": {
        // object call BIS_fnc_getVirtualWeaponCargo
        private _p0 = _args param [0];
        _p0 call BIS_fnc_getVirtualWeaponCargo;
        _result = true;
    };
    case "bis_fnc_greatestnum": {
        // numbers call BIS_fnc_greatestNum
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_greatestNum;
    };
    case "bis_fnc_gridtopos": {
        // gridPosition call BIS_fnc_gridToPos
        private _p0 = _args param [0];
        _p0 call BIS_fnc_gridToPos;
        _result = true;
    };
    case "bis_fnc_groupfromnetid": {
        // netId call BIS_fnc_groupFromNetId
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_groupFromNetId;
    };
    case "bis_fnc_groupindicator": {
        // argument call BIS_fnc_groupIndicator
        private _p0 = _args param [0];
        _p0 call BIS_fnc_groupIndicator;
        _result = true;
    };
    case "bis_fnc_groupvehicles": {
        // [target, assignedVeh] call BIS_fnc_groupVehicles
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_groupVehicles;
    };
    case "bis_fnc_guibackground": {
        // [position] call BIS_fnc_GUIbackground
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_GUIbackground;
    };
    case "bis_fnc_guieffecttiles": {
        // [display] call BIS_fnc_guiEffectTiles
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_guiEffectTiles;
    };
    case "bis_fnc_guigrid": {
        // [category, grid] call BIS_fnc_GUIgrid
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_GUIgrid;
    };
    case "bis_fnc_guimessage": {
        // [message, header, position, isCancel, parent, pause] spawn BIS_fnc_guiMessage
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        [_p0, _p1, _p2, _p3, _p4, _p5] spawn BIS_fnc_guiMessage;
        _result = true;
    };
    case "bis_fnc_guinewsfeed": {
        // [display] call BIS_fnc_GUInewsfeed
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_GUInewsfeed;
    };
    case "bis_fnc_halo": {
        // [unit, altitude] call BIS_fnc_halo
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_halo;
        _result = true;
    };
    case "bis_fnc_hasitem": {
        // [object, item, searchCrew] call BIS_fnc_hasItem
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_hasItem;
    };
    case "bis_fnc_helicopterdamage": {
        // [helicopter, selection, damage] call BIS_fnc_helicopterDamage
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_helicopterDamage;
    };
    case "bis_fnc_helicoptergethitpoints": {
        // object call BIS_fnc_helicopterGetHitpoints
        private _p0 = _args param [0];
        _p0 call BIS_fnc_helicopterGetHitpoints;
        _result = true;
    };
    case "bis_fnc_helicopterseat": {
        // unit call BIS_fnc_helicopterSeat
        private _p0 = _args param [0];
        _p0 call BIS_fnc_helicopterSeat;
        _result = true;
    };
    case "bis_fnc_helicopterseatmove": {
        // [unit, gesture] call BIS_fnc_helicopterSeatMove
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_helicopterSeatMove;
    };
    case "bis_fnc_help": {
        // parentDisplay call BIS_fnc_help
        private _p0 = _args param [0];
        _p0 call BIS_fnc_help;
        _result = true;
    };
    case "bis_fnc_hextorgb": {
        // [hexString] call BIS_fnc_HEXtoRGB
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_HEXtoRGB;
        _result = true;
    };
    case "bis_fnc_hidemarker": {
        // [marker, duration] spawn BIS_fnc_hideMarker
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] spawn BIS_fnc_hideMarker;
        _result = true;
    };
    case "bis_fnc_hidemarkerarray": {
        // [markerArray, duration] spawn BIS_fnc_hideMarkerArray
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] spawn BIS_fnc_hideMarkerArray;
        _result = true;
    };
    case "bis_fnc_highlightcontrol": {
        // [displayOrControl, thickness] call BIS_fnc_highlightControl
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_highlightControl;
    };
    case "bis_fnc_holdactionadd": {
        // [target, title, idleIcon, progressIcon, conditionShow, conditionProgress, codeStart, codeProgress, codeCompleted, codeInterrupted, arguments, duration, priority, removeCompleted, showUnconscious, showWindow] call BIS_fnc_holdActionAdd
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
        private _p15 = _args param [15];
        _result = [_p0, _p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, _p9, _p10, _p11, _p12, _p13, _p14, _p15] call BIS_fnc_holdActionAdd;
    };
    case "bis_fnc_holdactionremove": {
        // [target,ID] call BIS_fnc_holdActionRemove
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0,_p1] call BIS_fnc_holdActionRemove;
        _result = true;
    };
    case "bis_fnc_holdkey": {
        // [display, key, time, code, control] call BIS_fnc_holdKey
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_holdKey;
        _result = true;
    };
    case "bis_fnc_hudlimits": {
        // [speedLimit, altLimit, dirLimit] call BIS_fnc_HUDLimits
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_HUDLimits;
    };
    case "bis_fnc_inanglesector": {
        // [center, centerAngle, sectorWidth, position] call BIS_fnc_inAngleSector
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_inAngleSector;
    };
    case "bis_fnc_initdisplay": {
        // parameters call BIS_fnc_initDisplay
        private _p0 = _args param [0];
        _p0 call BIS_fnc_initDisplay;
        _result = true;
    };
    case "bis_fnc_initinspectable": {
        // [inspectable, textureInfos, fullScreenText, soundName] call BIS_fnc_initInspectable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2, _p3] call BIS_fnc_initInspectable;
        _result = true;
    };
    case "bis_fnc_initintelobject": {
        // [object] call BIS_fnc_initIntelObject
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_initIntelObject;
    };
    case "bis_fnc_initleaflet": {
        // [mode, parameters] call BIS_fnc_initLeaflet
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_initLeaflet;
        _result = true;
    };
    case "bis_fnc_initlistnboxsorting": {
        // [ctrlFilter, ctrlContent, columnIndexes, idc] call BIS_fnc_initListNBoxSorting
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_initListNBoxSorting;
    };
    case "bis_fnc_initmodules": {
        // [modules] call BIS_fnc_initModules
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_initModules;
    };
    case "bis_fnc_initslidervalue": {
        // [ctrlSlider, ctrlEdit, unit, default] call BIS_fnc_initSliderValue
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2, _p3] call BIS_fnc_initSliderValue;
        _result = true;
    };
    case "bis_fnc_initvehicle": {
        // [vehicle, variant, animations, mass] call BIS_fnc_initVehicle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_initVehicle;
    };
    case "bis_fnc_initvehiclecrew": {
        // [object, params, deleteCrew, anySeat, agents] call BIS_fnc_initVehicleCrew
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_initVehicleCrew;
    };
    case "bis_fnc_initvehiclekart": {
        // [kart,number,livery,raceTeam] call BIS_fnc_initVehicleKart
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0,_p1,_p2,_p3] call BIS_fnc_initVehicleKart;
    };
    case "bis_fnc_initvirtualunit": {
        // [object] call BIS_fnc_initVirtualUnit
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_initVirtualUnit;
    };
    case "bis_fnc_interpolate": {
        // [currentValue, targetValue, delta, interpSpeed] call BIS_fnc_interpolate
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_interpolate;
    };
    case "bis_fnc_interpolateconstant": {
        // [currentValue, targetValue, delta, interpSpeed] call BIS_fnc_interpolateConstant
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_interpolateConstant;
    };
    case "bis_fnc_interpolatevector": {
        // [currentValue, targetValue, delta, interpSpeed] call BIS_fnc_interpolateVector
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_interpolateVector;
    };
    case "bis_fnc_interpolatevectorconstant": {
        // [currentValue, targetValue, delta, interpSpeed] call BIS_fnc_interpolateVectorConstant
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_interpolateVectorConstant;
    };
    case "bis_fnc_intrigger": {
        // [area, position, returnDistance, includeFloorCeiling] call BIS_fnc_inTrigger
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2, _p3] call BIS_fnc_inTrigger;
        _result = true;
    };
    case "bis_fnc_inv": {
        // [unit] call BIS_fnc_inv
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_inv;
        _result = true;
    };
    case "bis_fnc_invadd": {
        // [object,class,force] call BIS_fnc_invAdd
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0,_p1,_p2] call BIS_fnc_invAdd;
        _result = true;
    };
    case "bis_fnc_invcodetoarray": {
        // [configCode] call BIS_fnc_invCodeToArray
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_invCodeToArray;
        _result = true;
    };
    case "bis_fnc_inventoryexists": {
        // [source, name] call BIS_fnc_inventoryExists
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_inventoryExists;
    };
    case "bis_fnc_inverselerp": {
        // [currentValue, targetValue, alpha] call BIS_fnc_inverseLerp
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_inverseLerp;
    };
    case "bis_fnc_invremove": {
        // [object,class,count] call BIS_fnc_invRemove
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0,_p1,_p2] call BIS_fnc_invRemove;
    };
    case "bis_fnc_invslots": {
        // [object] call BIS_fnc_invSlots
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_invSlots;
    };
    case "bis_fnc_invslotsempty": {
        // [object] call BIS_fnc_invSlotsEmpty
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_invSlotsEmpty;
    };
    case "bis_fnc_invslottype": {
        // [class] call BIS_fnc_invSlotType
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_invSlotType;
        _result = true;
    };
    case "bis_fnc_invstring": {
        // [object] call BIS_fnc_invString
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_invString;
    };
    case "bis_fnc_isbuildingenterable": {
        // param call BIS_fnc_isBuildingEnterable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 call BIS_fnc_isBuildingEnterable;
    };
    case "bis_fnc_iscurator": {
        // object call BIS_fnc_isCurator
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_isCurator;
    };
    case "bis_fnc_iscuratoreditable": {
        // [object] call BIS_fnc_isCuratorEditable
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_isCuratorEditable;
    };
    case "bis_fnc_isdatetimenewer": {
        // [date1, date2] call BIS_fnc_isDateTimeNewer
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_isDateTimeNewer;
    };
    case "bis_fnc_isequalvector": {
        // [vector1, vector2, tolerance] call BIS_fnc_isEqualVector
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_isEqualVector;
    };
    case "bis_fnc_isinfrontof": {
        // [reference, checked, offset] call BIS_fnc_isInFrontOf
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_isInFrontOf;
    };
    case "bis_fnc_isinsidearea": {
        // [center, size, position ] call BIS_fnc_isInsideArea
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2 ] call BIS_fnc_isInsideArea;
    };
    case "bis_fnc_isinzoom": {
        // [min, max] call BIS_fnc_isInZoom
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_isInZoom;
    };
    case "bis_fnc_isleapyear": {
        // year call BIS_fnc_isLeapYear
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_isLeapYear;
    };
    case "bis_fnc_islocalized": {
        // [localizationString] call BIS_fnc_isLocalized
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_isLocalized;
    };
    case "bis_fnc_isposblacklisted": {
        // [position, blacklistArea] call BIS_fnc_isPosBlacklisted
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_isPosBlacklisted;
    };
    case "bis_fnc_isthrowable": {
        // magazine call BIS_fnc_isThrowable
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_isThrowable;
    };
    case "bis_fnc_isunitvirtual": {
        // [object] call BIS_fnc_isUnitVirtual
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_isUnitVirtual;
    };
    case "bis_fnc_itemtype": {
        // weaponClass call BIS_fnc_itemType
        private _p0 = _args param [0];
        _p0 call BIS_fnc_itemType;
        _result = true;
    };
    case "bis_fnc_jukebox": {
        // [function, parameters] call BIS_fnc_jukebox
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_jukebox;
        _result = true;
    };
    case "bis_fnc_kbcanspeak": {
        // unit call BIS_fnc_kbCanSpeak
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_kbCanSpeak;
    };
    case "bis_fnc_kbcreatedummy": {
        // dummyVarName call BIS_fnc_kbCreateDummy
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_kbCreateDummy;
    };
    case "bis_fnc_kbisspeaking": {
        // unit call BIS_fnc_kbIsSpeaking
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_kbIsSpeaking;
    };
    case "bis_fnc_kbskip": {
        // [topicName, mission, wait] call BIS_fnc_kbSkip
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_kbSkip;
        _result = true;
    };
    case "bis_fnc_kbtell": {
        // [topic, container, section, radioMode, code, speakers, soundVolume, radioProtocol] spawn BIS_fnc_kbTell
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        private _p7 = _args param [7];
        [_p0, _p1, _p2, _p3, _p4, _p5, _p6, _p7] spawn BIS_fnc_kbTell;
        _result = true;
    };
    case "bis_fnc_kbtelllocal": {
        // [mode, parameters] call BIS_fnc_kbTellLocal
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_kbTellLocal;
        _result = true;
    };
    case "bis_fnc_kbtopicconfig": {
        // [missionName, topic] call BIS_fnc_kbTopicConfig
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_kbTopicConfig;
    };
    case "bis_fnc_keycode": {
        // input call BIS_fnc_keyCode
        private _p0 = _args param [0];
        _p0 call BIS_fnc_keyCode;
        _result = true;
    };
    case "bis_fnc_keyhold": {
        // [description, duration, condition, arguments, loaded] spawn BIS_fnc_keyHold
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        [_p0, _p1, _p2, _p3, _p4] spawn BIS_fnc_keyHold;
        _result = true;
    };
    case "bis_fnc_kmlimport": {
        // filePath call BIS_fnc_KMLimport
        private _p0 = _args param [0];
        _p0 call BIS_fnc_KMLimport;
        _result = true;
    };
    case "bis_fnc_laptopinit": {
        // laptop call BIS_fnc_laptopInit
        private _p0 = _args param [0];
        _p0 call BIS_fnc_laptopInit;
        _result = true;
    };
    case "bis_fnc_laptopplayvideo": {
        // laptop call BIS_fnc_laptopPlayVideo
        private _p0 = _args param [0];
        _p0 call BIS_fnc_laptopPlayVideo;
        _result = true;
    };
    case "bis_fnc_lerp": {
        // [currentValue,targetValue,alpha] call BIS_fnc_lerp
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0,_p1,_p2] call BIS_fnc_lerp;
    };
    case "bis_fnc_lerpvector": {
        // [currentValue, targetValue, alpha] call BIS_fnc_lerpVector
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_lerpVector;
    };
    case "bis_fnc_limititems": {
        // [unit,chanceNVG,chanceBino,chanceGPS,chanceMap,chanceRadio,chanceCompass,chanceWatch] call BIS_fnc_limitItems
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        private _p7 = _args param [7];
        _result = [_p0,_p1,_p2,_p3,_p4,_p5,_p6,_p7] call BIS_fnc_limitItems;
    };
    case "bis_fnc_limitsupport": {
        // [module, supportType, quantity] call BIS_fnc_limitSupport
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_limitSupport;
    };
    case "bis_fnc_limitweaponitems": {
        // [unit,mode,chanceOptics,chanceAttach,chanceMuzzle,chanceUnderbarrel] call BIS_fnc_limitWeaponItems
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _result = [_p0,_p1,_p2,_p3,_p4,_p5] call BIS_fnc_limitWeaponItems;
    };
    case "bis_fnc_livefeed": {
        // [source, target, receiver, effect] call BIS_fnc_liveFeed
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_liveFeed;
    };
    case "bis_fnc_livefeedeffects": {
        // effect call BIS_fnc_liveFeedEffects
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_liveFeedEffects;
    };
    case "bis_fnc_livefeedsetsource": {
        // source call BIS_fnc_liveFeedSetSource
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_liveFeedSetSource;
    };
    case "bis_fnc_livefeedsettarget": {
        // target call BIS_fnc_liveFeedSetTarget
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_liveFeedSetTarget;
    };
    case "bis_fnc_loadclass": {
        // [input, defaultValue] call BIS_fnc_loadClass
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_loadClass;
    };
    case "bis_fnc_loadentry": {
        // [path,defaultConfig] call BIS_fnc_loadEntry
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0,_p1] call BIS_fnc_loadEntry;
        _result = true;
    };
    case "bis_fnc_loadfunctions": {
        // [fileDirectory, prefix, nameVars, global] call BIS_fnc_loadFunctions
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_loadFunctions;
    };
    case "bis_fnc_loadvehicle": {
        // [object,target] call BIS_fnc_loadVehicle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0,_p1] call BIS_fnc_loadVehicle;
    };
    case "bis_fnc_localize": {
        // localizationString call BIS_fnc_localize
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_localize;
    };
    case "bis_fnc_locationdescription": {
        // position call BIS_fnc_locationDescription
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_locationDescription;
    };
    case "bis_fnc_locations": {
        // [types, area, debug] call BIS_fnc_locations
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_locations;
    };
    case "bis_fnc_locations": {
        // [objects] call BIS_fnc_locations
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_locations;
    };
    case "bis_fnc_log": {
        // param call BIS_fnc_log
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_log;
    };
    case "bis_fnc_logformat": {
        // [text, parameters] call BIS_fnc_logFormat
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_logFormat;
    };
    case "bis_fnc_lookatarray": {
        // [initialize, lookAtData] call BIS_fnc_lookAtArray
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_lookAtArray;
        _result = true;
    };
    case "bis_fnc_loop": {
        // [action, parameters] call BIS_fnc_loop
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_loop;
        _result = true;
    };
    case "bis_fnc_lowestnum": {
        // numbers call BIS_fnc_lowestNum
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_lowestNum;
    };
    case "bis_fnc_magazinesentitytype": {
        // class call BIS_fnc_magazinesEntityType
        private _p0 = _args param [0];
        _p0 call BIS_fnc_magazinesEntityType;
        _result = true;
    };
    case "bis_fnc_magnitude": {
        // vector call BIS_fnc_magnitude
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_magnitude;
    };
    case "bis_fnc_magnitudesqr": {
        // vector call BIS_fnc_magnitudeSqr
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_magnitudeSqr;
    };
    case "bis_fnc_mapanimadd": {
        // [duration, toZoom, toPosition, interpModeZoom, interpModePosition, fromZoom, fromPosition] call BIS_fnc_mapAnimAdd
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        [_p0, _p1, _p2, _p3, _p4, _p5, _p6] call BIS_fnc_mapAnimAdd;
        _result = true;
    };
    case "bis_fnc_mapgridsize": {
        // [map] call BIS_fnc_mapGridSize
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_mapGridSize;
    };
    case "bis_fnc_mapsize": {
        // terrainName call BIS_fnc_mapSize
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_mapSize;
    };
    case "bis_fnc_markerparams": {
        // varName call BIS_fnc_markerParams
        private _p0 = _args param [0];
        _p0 call BIS_fnc_markerParams;
        _result = true;
    };
    case "bis_fnc_markerpath": {
        // [start, end, spacing, params] call BIS_fnc_markerPath
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_markerPath;
    };
    case "bis_fnc_markertostring": {
        // [markerName, delimiter] call BIS_fnc_markerToString
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_markerToString;
    };
    case "bis_fnc_markertotrigger": {
        // [markerName, trigger, localChange] call BIS_fnc_markerToTrigger
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_markerToTrigger;
    };
    case "bis_fnc_maxdiffarray": {
        // [arrayOfNumbers] call BIS_fnc_maxDiffArray
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_maxDiffArray;
    };
    case "bis_fnc_mirrorcuratorsettings": {
        // [from, to, modes, shareType] call BIS_fnc_mirrorCuratorSettings
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_mirrorCuratorSettings;
    };
    case "bis_fnc_miscanim": {
        // [anim, person1, vehicle, person2, isOnBoard, altitude, doMove] call BIS_fnc_miscAnim
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        [_p0, _p1, _p2, _p3, _p4, _p5, _p6] call BIS_fnc_miscAnim;
        _result = true;
    };
    case "bis_fnc_missilelaunchpositionfix": {
        // [vehicle, projectile, selection, projectileType] call BIS_fnc_missileLaunchPositionFix
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_missileLaunchPositionFix;
    };
    case "bis_fnc_missionrespawntype": {
        // type call BIS_fnc_missionRespawnType
        private _p0 = _args param [0];
        _p0 call BIS_fnc_missionRespawnType;
        _result = true;
    };
    case "bis_fnc_missionselector": {
        // [area, mapCenter, missionsArray] call BIS_fnc_missionSelector
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_missionSelector;
    };
    case "bis_fnc_modulechat": {
        // [logic, units, isActivated] call BIS_fnc_moduleChat
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_moduleChat;
    };
    case "bis_fnc_modulecovermap": {
        // [centerUnit,units,init] call BIS_fnc_moduleCoverMap
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0,_p1,_p2] call BIS_fnc_moduleCoverMap;
        _result = true;
    };
    case "bis_fnc_moduledamage": {
        // [logic, vehicles, isActivated] call BIS_fnc_moduleDamage
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_moduleDamage;
    };
    case "bis_fnc_moduleeffectsbubbles": {
        // [module] call BIS_fnc_moduleEffectsBubbles
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_moduleEffectsBubbles;
        _result = true;
    };
    case "bis_fnc_moduleeffectsfire": {
        // [module] call BIS_fnc_moduleEffectsFire
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_moduleEffectsFire;
        _result = true;
    };
    case "bis_fnc_moduleeffectsplankton": {
        // [module] call BIS_fnc_moduleEffectsPlankton
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_moduleEffectsPlankton;
        _result = true;
    };
    case "bis_fnc_moduleeffectsshells": {
        // [module] call BIS_fnc_moduleEffectsShells
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_moduleEffectsShells;
        _result = true;
    };
    case "bis_fnc_moduleeffectssmoke": {
        // [module] call BIS_fnc_moduleEffectsSmoke
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_moduleEffectsSmoke;
        _result = true;
    };
    case "bis_fnc_modulefdfademarker": {
        // [markerName, alpha] spawn BIS_fnc_moduleFDFadeMarker
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] spawn BIS_fnc_moduleFDFadeMarker;
    };
    case "bis_fnc_modulefuel": {
        // [logic, units, isActivated] call BIS_fnc_moduleFuel
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_moduleFuel;
    };
    case "bis_fnc_modulelightning": {
        // [target, nil, activate] call BIS_fnc_moduleLightning
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_moduleLightning;
        _result = true;
    };
    case "bis_fnc_modulerank": {
        // [logic, units, activated] call BIS_fnc_moduleRank
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_moduleRank;
    };
    case "bis_fnc_modulerating": {
        // [logic, units, activated] call BIS_fnc_moduleRating
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_moduleRating;
    };
    case "bis_fnc_modulesavegame": {
        // [nil,nil,activated] call BIS_fnc_moduleSaveGame
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0,_p0,_p2] call BIS_fnc_moduleSaveGame;
    };
    case "bis_fnc_moduletracers": {
        // [logic, activated] call BIS_fnc_moduleTracers
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_moduleTracers;
        _result = true;
    };
    case "bis_fnc_monthdays": {
        // [year, month] call BIS_fnc_monthDays
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_monthDays;
    };
    case "bis_fnc_moveaction": {
        // [unit, returnConfig] call BIS_fnc_moveAction
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_moveAction;
        _result = true;
    };
    case "bis_fnc_movein": {
        // [vehicle, unit, role] call BIS_fnc_moveIn
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_moveIn;
    };
    case "bis_fnc_movemarker": {
        // [marker, newPosition, duration, interpolationType] call BIS_fnc_moveMarker
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2, _p3] call BIS_fnc_moveMarker;
        _result = true;
    };
    case "bis_fnc_movetorespawnposition": {
        // [unit, position, canBeDead] call BIS_fnc_moveToRespawnPosition
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_moveToRespawnPosition;
    };
    case "bis_fnc_mp": {
        // [params, functionName, target, isSpawn, isPersistent] call BIS_fnc_MP
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_MP;
    };
    case "bis_fnc_mpexec": {
        // [packetName, packetValue] call BIS_fnc_MPexec
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_MPexec;
    };
    case "bis_fnc_music": {
        // [tracklist, delay] call BIS_fnc_music
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_music;
        _result = true;
    };
    case "bis_fnc_nearesthelipad": {
        // [position, radius, random, types] call BIS_fnc_nearestHelipad
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2, _p3] call BIS_fnc_nearestHelipad;
        _result = true;
    };
    case "bis_fnc_nearestnum": {
        // [values, value] call BIS_fnc_nearestNum
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_nearestNum;
    };
    case "bis_fnc_nearestpoint": {
        // [start, end, point, is2D] call BIS_fnc_nearestPoint
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_nearestPoint;
    };
    case "bis_fnc_nearestposition": {
        // [items, origin] call BIS_fnc_nearestPosition
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_nearestPosition;
        _result = true;
    };
    case "bis_fnc_nearestroad": {
        // [center, radius, blacklist] call BIS_fnc_nearestRoad
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_nearestRoad;
    };
    case "bis_fnc_netid": {
        // objOrGrp call BIS_fnc_netId
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_netId;
    };
    case "bis_fnc_neutralizeunit": {
        // object call BIS_fnc_neutralizeUnit
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_neutralizeUnit;
    };
    case "bis_fnc_numberdigits": {
        // number call BIS_fnc_numberDigits
        private _p0 = _args param [0];
        _p0 call BIS_fnc_numberDigits;
        _result = true;
    };
    case "bis_fnc_numbertext": {
        // [number, modulo] call BIS_fnc_numberText
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_numberText;
    };
    case "bis_fnc_objectfromnetid": {
        // netId call BIS_fnc_objectFromNetId
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_objectFromNetId;
    };
    case "bis_fnc_objectheight": {
        // object call BIS_fnc_objectHeight
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_objectHeight;
    };
    case "bis_fnc_objectinventoryanimatedclose": {
        // [object, animationArray] call BIS_fnc_objectInventoryAnimatedClose
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_objectInventoryAnimatedClose;
        _result = true;
    };
    case "bis_fnc_objectinventoryanimatedopen": {
        // [object, animationArray] call BIS_fnc_objectInventoryAnimatedOpen
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_objectInventoryAnimatedOpen;
        _result = true;
    };
    case "bis_fnc_objectsgrabber": {
        // [position, size, objectOrientation] call BIS_fnc_objectsGrabber
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_objectsGrabber;
        _result = true;
    };
    case "bis_fnc_objectside": {
        // [target, boolean] call BIS_fnc_objectSide
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_objectSide;
    };
    case "bis_fnc_objectside": {
        // target call BIS_fnc_objectSide
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_objectSide;
    };
    case "bis_fnc_objectsmapper": {
        // [position, azimuth, objectsArray, badChance] call BIS_fnc_objectsMapper
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2, _p3] call BIS_fnc_objectsMapper;
        _result = true;
    };
    case "bis_fnc_objecttype": {
        // anObject call BIS_fnc_objectType
        private _p0 = _args param [0];
        _p0 call BIS_fnc_objectType;
        _result = true;
    };
    case "bis_fnc_objectvar": {
        // [object, varNameRoot] call BIS_fnc_objectVar
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_objectVar;
    };
    case "bis_fnc_om_module_initsmallvaluesilder": {
        // [ctrlSlider, ctrlEdit, unit, defaultValue] call BIS_fnc_OM_Module_initSmallValueSilder
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_OM_Module_initSmallValueSilder;
    };
    case "bis_fnc_onend": {
        // argument call BIS_fnc_onEnd
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_onEnd;
    };
    case "bis_fnc_onload": {
        // parameter call BIS_fnc_onLoad
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_onLoad;
    };
    case "bis_fnc_onplayerconnected": {
        // [code, params]] call BIS_fnc_onPlayerConnected
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1]] call BIS_fnc_onPlayerConnected;
    };
    case "bis_fnc_openfieldmanual": {
        // [topic, hint, display, filter] call BIS_fnc_openFieldManual
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2, _p3] call BIS_fnc_openFieldManual;
        _result = true;
    };
    case "bis_fnc_orbataddgroupoverlay": {
        // [target, texture, colour, widthMulti, heightMulti, angle, text, shadow] call BIS_fnc_ORBATAddGroupOverlay
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        private _p7 = _args param [7];
        _result = [_p0, _p1, _p2, _p3, _p4, _p5, _p6, _p7] call BIS_fnc_ORBATAddGroupOverlay;
    };
    case "bis_fnc_orbatanimate": {
        // [target, zoom, duration] spawn BIS_fnc_ORBATAnimate
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] spawn BIS_fnc_ORBATAnimate;
    };
    case "bis_fnc_orbatconfigpreview": {
        // [class] call BIS_fnc_ORBATConfigPreview
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_ORBATConfigPreview;
        _result = true;
    };
    case "bis_fnc_orbatgetgroupparams": {
        // [path] call BIS_fnc_ORBATGetGroupParams
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_ORBATGetGroupParams;
    };
    case "bis_fnc_orbatopen": {
        // [path, display, tags, numTiers, parameters] call BIS_fnc_ORBATOpen
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_ORBATOpen;
    };
    case "bis_fnc_orbatremovegroupoverlay": {
        // [path, number] call BIS_fnc_ORBATRemoveGroupOverlay
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_ORBATRemoveGroupOverlay;
        _result = true;
    };
    case "bis_fnc_orbatsetgroupfade": {
        // [path, alpha, time] call BIS_fnc_ORBATSetGroupFade
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_ORBATSetGroupFade;
    };
    case "bis_fnc_orbatsetgroupparams": {
        // [target, IDType, size, type, side, name, shortName, texture, textSizeCoef, insignia, textColour, commName, commRank, description, assets] call BIS_fnc_ORBATSetGroupParams
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
        _result = [_p0, _p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, _p9, _p10, _p11, _p12, _p13, _p14] call BIS_fnc_ORBATSetGroupParams;
    };
    case "bis_fnc_orbattooltip": {
        // [target, control, position] call BIS_fnc_ORBATTooltip
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_ORBATTooltip;
    };
    case "bis_fnc_ordinalnumber": {
        // [number, language, isFeminine] call BIS_fnc_ordinalNumber
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_ordinalNumber;
    };
    case "bis_fnc_overviewauthor": {
        // [config, control] call BIS_fnc_overviewAuthor
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_overviewAuthor;
    };
    case "bis_fnc_overviewtimetrial": {
        // class call BIS_fnc_overviewTimeTrial
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_overviewTimeTrial;
    };
    case "bis_fnc_packstaticweapon": {
        // [group, weapon, leaderPos] call BIS_fnc_packStaticWeapon
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_packStaticWeapon;
        _result = true;
    };
    case "bis_fnc_param": {
        // [input, index, defaultValue, dataTypes, requiredCount] call BIS_fnc_param
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_param;
    };
    case "bis_fnc_paramcountdown": {
        // number call BIS_fnc_paramCountdown
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_paramCountdown;
    };
    case "bis_fnc_paramdaytime": {
        // datetime call BIS_fnc_paramDaytime
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_paramDaytime;
    };
    case "bis_fnc_paramrespawntickets": {
        // number call BIS_fnc_paramRespawnTickets
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_paramRespawnTickets;
    };
    case "bis_fnc_paramtimeacceleration": {
        // timeMultiplier call BIS_fnc_paramTimeAcceleration
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_paramTimeAcceleration;
    };
    case "bis_fnc_paramviewdistance": {
        // viewDistance call BIS_fnc_paramViewDistance
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_paramViewDistance;
    };
    case "bis_fnc_parsenumber": {
        // value call BIS_fnc_parseNumber
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_parseNumber;
    };
    case "bis_fnc_parsenumbersafe": {
        // [input] call BIS_fnc_parseNumberSafe
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_parseNumberSafe;
        _result = true;
    };
    case "bis_fnc_phoneticalword": {
        // [integer, short] call BIS_fnc_phoneticalWord
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_phoneticalWord;
    };
    case "bis_fnc_pip": {
        // [renderTarget, cameraParams, vehicle, replace] call BIS_fnc_PIP
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_PIP;
    };
    case "bis_fnc_playendmusic": {
        // play call BIS_fnc_playEndMusic
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_playEndMusic;
    };
    case "bis_fnc_playersidefaction": {
        // side call BIS_fnc_playerSideFaction
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_playerSideFaction;
    };
    case "bis_fnc_playmusic": {
        // [class,start,volume] call BIS_fnc_playMusic
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0,_p1,_p2] call BIS_fnc_playMusic;
    };
    case "bis_fnc_playsound": {
        // [sound, forced] call BIS_fnc_playSound
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_playSound;
    };
    case "bis_fnc_playvideo": {
        // [content, size, color, skipVarName, bgColor, keepAspect] spawn BIS_fnc_playVideo
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _result = [_p0, _p1, _p2, _p3, _p4, _p5] spawn BIS_fnc_playVideo;
    };
    case "bis_fnc_posdegtoutm": {
        // [longitude, latitude, zone] call BIS_fnc_posDegToUTM
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_posDegToUTM;
        _result = true;
    };
    case "bis_fnc_posdegtoworld": {
        // [longitude, latitude, world] call BIS_fnc_posDegToWorld
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_posDegToWorld;
        _result = true;
    };
    case "bis_fnc_postogrid": {
        // element call BIS_fnc_posToGrid
        private _p0 = _args param [0];
        _p0 call BIS_fnc_posToGrid;
        _result = true;
    };
    case "bis_fnc_posutmtodeg": {
        // [easting, northing, zone, hemisphere] call BIS_fnc_posUTMToDeg
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2, _p3] call BIS_fnc_posUTMToDeg;
        _result = true;
    };
    case "bis_fnc_pow": {
        // [value1, value2] call BIS_fnc_pow
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_pow;
    };
    case "bis_fnc_prepareao": {
        // density call BIS_fnc_prepareAO
        private _p0 = _args param [0];
        _p0 call BIS_fnc_prepareAO;
        _result = true;
    };
    case "bis_fnc_progressloadingscreen": {
        // [progress] call BIS_fnc_progressLoadingScreen
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_progressLoadingScreen;
    };
    case "bis_fnc_pulsate": {
        // [frequency] call BIS_fnc_pulsate
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_pulsate;
    };
    case "bis_fnc_quotations": {
        // [videoPath, subtitle] call BIS_fnc_quotations
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_quotations;
        _result = true;
    };
    case "bis_fnc_radialred": {
        // [victim, bodyPart, damage, shooter] call BIS_fnc_radialRed
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2, _p3] call BIS_fnc_radialRed;
        _result = true;
    };
    case "bis_fnc_randomindex": {
        // array call BIS_fnc_randomIndex
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_randomIndex;
    };
    case "bis_fnc_randomint": {
        // [min, max] call BIS_fnc_randomInt
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_randomInt;
    };
    case "bis_fnc_randomnum": {
        // [min, max] call BIS_fnc_randomNum
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_randomNum;
    };
    case "bis_fnc_randompos": {
        // [whitelist, blacklist, code] call BIS_fnc_randomPos
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_randomPos;
    };
    case "bis_fnc_randomposintersection": {
        // [firstCircle, secondCircle, positioning1, positioning2] call BIS_fnc_randomPosIntersection
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_randomPosIntersection;
    };
    case "bis_fnc_randompostrigger": {
        // param call BIS_fnc_randomPosTrigger
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_randomPosTrigger;
    };
    case "bis_fnc_rankparams": {
        // [source, infoType] call BIS_fnc_rankParams
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_rankParams;
    };
    case "bis_fnc_reenablerevive": {
        // [player] call BIS_fnc_reenableRevive
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_reenableRevive;
        _result = true;
    };
    case "bis_fnc_registercuratorobject": {
        // [class, status, cost] call BIS_fnc_registerCuratorObject
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, cost] call BIS_fnc_registerCuratorObject;
        _result = true;
    };
    case "bis_fnc_relativedirto": {
        // [from, to] call BIS_fnc_relativeDirTo
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_relativeDirTo;
    };
    case "bis_fnc_relpos": {
        // [origin, distance, direction] call BIS_fnc_relPos
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_relPos;
    };
    case "bis_fnc_relposobject": {
        // [parent, child, relPos, direction] call BIS_fnc_relPosObject
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2, _p3] call BIS_fnc_relPosObject;
        _result = true;
    };
    case "bis_fnc_relscaleddist": {
        // [referenceObject, relativeObject] call BIS_fnc_relScaledDist
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_relScaledDist;
    };
    case "bis_fnc_removeallscriptedeventhandlers": {
        // [namespace, name] call BIS_fnc_removeAllScriptedEventHandlers
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_removeAllScriptedEventHandlers;
    };
    case "bis_fnc_removecommmenuitem": {
        // [owner,itemID] call BIS_fnc_removeCommMenuItem
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0,_p1] call BIS_fnc_removeCommMenuItem;
    };
    case "bis_fnc_removecuratoricon": {
        // [object, id] call BIS_fnc_removeCuratorIcon
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_removeCuratorIcon;
    };
    case "bis_fnc_removedestroyedcuratoreditableobjects": {
        // [object, parentClasses] call BIS_fnc_removeDestroyedCuratorEditableObjects
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_removeDestroyedCuratorEditableObjects;
    };
    case "bis_fnc_removefrompairs": {
        // [array, key, copyArray] call BIS_fnc_removeFromPairs
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_removeFromPairs;
    };
    case "bis_fnc_removeindex": {
        // [array, startIndex, endIndex] call BIS_fnc_removeIndex
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_removeIndex;
    };
    case "bis_fnc_removeindex": {
        // [array, indices] call BIS_fnc_removeIndex
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_removeIndex;
    };
    case "bis_fnc_removenestedelement": {
        // [array, itemToRemove] call BIS_fnc_removeNestedElement
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_removeNestedElement;
    };
    case "bis_fnc_removerespawninventory": {
        // [target, id] call BIS_fnc_removeRespawnInventory
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_removeRespawnInventory;
    };
    case "bis_fnc_removerespawnposition": {
        // [target, id] call BIS_fnc_removeRespawnPosition
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_removeRespawnPosition;
    };
    case "bis_fnc_removescriptedeventhandler": {
        // [namespace, name, id] call BIS_fnc_removeScriptedEventHandler
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_removeScriptedEventHandler;
    };
    case "bis_fnc_removesupportlink": {
        // [requester, provider] call BIS_fnc_removeSupportLink
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_removeSupportLink;
        _result = true;
    };
    case "bis_fnc_removevirtualbackpackcargo": {
        // [object,backpackClasses,removeGlobally] call BIS_fnc_removeVirtualBackpackCargo
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0,_p1,_p2] call BIS_fnc_removeVirtualBackpackCargo;
        _result = true;
    };
    case "bis_fnc_removevirtualitemcargo": {
        // [object,itemClasses,removeGlobally] call BIS_fnc_removeVirtualItemCargo
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0,_p1,_p2] call BIS_fnc_removeVirtualItemCargo;
        _result = true;
    };
    case "bis_fnc_removevirtualmagazinecargo": {
        // [object,magClasses,removeGlobally] call BIS_fnc_removeVirtualMagazineCargo
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0,_p1,_p2] call BIS_fnc_removeVirtualMagazineCargo;
        _result = true;
    };
    case "bis_fnc_removevirtualweaponcargo": {
        // [object,weaponClasses,removeGlobally] call BIS_fnc_removeVirtualWeaponCargo
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0,_p1,_p2] call BIS_fnc_removeVirtualWeaponCargo;
        _result = true;
    };
    case "bis_fnc_replacewithsimpleobject": {
        // [object] call BIS_fnc_replaceWithSimpleObject
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_replaceWithSimpleObject;
    };
    case "bis_fnc_resizemarker": {
        // [marker, size, duration] spawn BIS_fnc_resizeMarker
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] spawn BIS_fnc_resizeMarker;
        _result = true;
    };
    case "bis_fnc_respawnconfirm": {
        // [respawnDelay] spawn BIS_fnc_respawnConfirm
        private _p0 = _args param [0];
        [_p0] spawn BIS_fnc_respawnConfirm;
        _result = true;
    };
    case "bis_fnc_respawncounter": {
        // [text,colour] call BIS_fnc_respawnCounter
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0,_p1] call BIS_fnc_respawnCounter;
    };
    case "bis_fnc_respawngroup": {
        // [oldUnit, newUnit] call BIS_fnc_respawnGroup
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_respawnGroup;
        _result = true;
    };
    case "bis_fnc_respawnmenuinventory": {
        // [player, respawnDelay, revive] call BIS_fnc_respawnMenuInventory
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_respawnMenuInventory;
        _result = true;
    };
    case "bis_fnc_respawnmenuposition": {
        // [player, respawnDelay, revive] call BIS_fnc_respawnMenuPosition
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_respawnMenuPosition;
        _result = true;
    };
    case "bis_fnc_respawnmenuspectator": {
        // [player, respawnDelay] call BIS_fnc_respawnMenuSpectator
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_respawnMenuSpectator;
        _result = true;
    };
    case "bis_fnc_respawnnone": {
        // [killed, killer] spawn BIS_fnc_respawnNone
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] spawn BIS_fnc_respawnNone;
        _result = true;
    };
    case "bis_fnc_respawntickets": {
        // [target, tickets, dynamicTarget] call BIS_fnc_respawnTickets
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_respawnTickets;
    };
    case "bis_fnc_returnchildren": {
        // [config, depth, lastTier, firstTier] call BIS_fnc_returnChildren
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_returnChildren;
    };
    case "bis_fnc_returnconfigentry": {
        // [config,attribute,defaultValue] call BIS_fnc_returnConfigEntry
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0,_p1,_p2] call BIS_fnc_returnConfigEntry;
        _result = true;
    };
    case "bis_fnc_returnnestedelement": {
        // [array, path] call BIS_fnc_returnNestedElement
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_returnNestedElement;
    };
    case "bis_fnc_returnparents": {
        // [config, onlyClassNames] call BIS_fnc_returnParents
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_returnParents;
    };
    case "bis_fnc_returnvehicleturrets": {
        // [configEntry] call BIS_fnc_returnVehicleTurrets
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_returnVehicleTurrets;
    };
    case "bis_fnc_reviveallowed": {
        // [medic, unit] call BIS_fnc_reviveAllowed
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_reviveAllowed;
    };
    case "bis_fnc_revivebleedout": {
        // [player] call BIS_fnc_reviveBleedOut
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_reviveBleedOut;
    };
    case "bis_fnc_revivedamagereset": {
        // [player] call BIS_fnc_reviveDamageReset
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_reviveDamageReset;
        _result = true;
    };
    case "bis_fnc_revivedebug": {
        // [mode] call BIS_fnc_reviveDebug
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_reviveDebug;
        _result = true;
    };
    case "bis_fnc_reviveehhandleheal": {
        // [unit] call BIS_fnc_reviveEhHandleHeal
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_reviveEhHandleHeal;
    };
    case "bis_fnc_reviveehrespawn": {
        // [unit] call BIS_fnc_reviveEhRespawn
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_reviveEhRespawn;
    };
    case "bis_fnc_reviveenabled": {
        // [unit] call BIS_fnc_reviveEhRespawn
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_reviveEhRespawn;
    };
    case "bis_fnc_reviveget3dicons": {
        // [unit] call BIS_fnc_reviveGet3dIcons
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_reviveGet3dIcons;
        _result = true;
    };
    case "bis_fnc_revivegetactionicon": {
        // [unit] call BIS_fnc_reviveGetActionIcon
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_reviveGetActionIcon;
        _result = true;
    };
    case "bis_fnc_reviveiconcontrol": {
        // [mode, unitVar] call BIS_fnc_reviveIconControl
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_reviveIconControl;
    };
    case "bis_fnc_reviveisvalid": {
        // [unit] call BIS_fnc_reviveIsValid
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_reviveIsValid;
    };
    case "bis_fnc_reviveisvalidsecure": {
        // [unit] call BIS_fnc_reviveIsValidSecure
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_reviveIsValidSecure;
    };
    case "bis_fnc_reviveonbeingrevived": {
        // [nil, flagState, unit] call BIS_fnc_reviveOnBeingRevived
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_reviveOnBeingRevived;
    };
    case "bis_fnc_revivesecureunit": {
        // [unit, source] call BIS_fnc_reviveSecureUnit
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_reviveSecureUnit;
        _result = true;
    };
    case "bis_fnc_romannumeral": {
        // integer call BIS_fnc_romanNumeral
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_romanNumeral;
    };
    case "bis_fnc_rotatemarker": {
        // [marker, newAzimuth, absoluteOrRelativ, shortestTurn, duraton] spawn BIS_fnc_rotateMarker
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        [_p0, _p1, _p2, _p3, _p4] spawn BIS_fnc_rotateMarker;
        _result = true;
    };
    case "bis_fnc_rotatevector2d": {
        // [vector2D, angle] call BIS_fnc_rotateVector2D
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_rotateVector2D;
    };
    case "bis_fnc_rotatevector3d": {
        // [vector, angle, axis] call BIS_fnc_rotateVector3D
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_rotateVector3D;
    };
    case "bis_fnc_rounddir": {
        // [rawDirection, rounding] call BIS_fnc_roundDir
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_roundDir;
    };
    case "bis_fnc_rsclayer": {
        // [layerName] call BIS_fnc_rscLayer
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_rscLayer;
    };
    case "bis_fnc_runlater": {
        // [id, code, timer, timerType, condition] call BIS_fnc_runLater
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_runLater;
        _result = true;
    };
    case "bis_fnc_savegame": {
        // [objects] call BIS_fnc_saveGame
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_saveGame;
    };
    case "bis_fnc_saveinventory": {
        // [unit,input,params,delete] call BIS_fnc_saveInventory
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0,_p1,_p2,_p3] call BIS_fnc_saveInventory;
    };
    case "bis_fnc_savevehicle": {
        // [object,target,params,delete] call BIS_fnc_saveVehicle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0,_p1,_p2,_p3] call BIS_fnc_saveVehicle;
    };
    case "bis_fnc_saymessage": {
        // [speaker, message, channel] call BIS_fnc_sayMessage
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_sayMessage;
    };
    case "bis_fnc_sceneareaclearance": {
        // [trigger, objects, destination] spawn BIS_fnc_sceneAreaClearance
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] spawn BIS_fnc_sceneAreaClearance;
        _result = true;
    };
    case "bis_fnc_scenecheckweapons": {
        // [participants] call BIS_fnc_sceneCheckWeapons
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_sceneCheckWeapons;
        _result = true;
    };
    case "bis_fnc_scenegetobjects": {
        // [centre, radius, type] call BIS_fnc_sceneGetObjects
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_sceneGetObjects;
        _result = true;
    };
    case "bis_fnc_scenegetparticipants": {
        // [unit, maxDistance] call BIS_fnc_sceneGetParticipants
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_sceneGetParticipants;
        _result = true;
    };
    case "bis_fnc_sceneintruderdetector": {
        // [sceneCenter, triggerSize] call BIS_fnc_sceneIntruderDetector
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_sceneIntruderDetector;
        _result = true;
    };
    case "bis_fnc_scenerotate": {
        // [center, centerAngle, angle, iniPosition] call BIS_fnc_sceneRotate
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_sceneRotate;
    };
    case "bis_fnc_scenesetobjects": {
        // [centre, objectsArray, applyOffset, stopped] call BIS_fnc_sceneSetObjects
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_sceneSetObjects;
    };
    case "bis_fnc_scriptedwaypointtype": {
        // [waypoint,type] call BIS_fnc_scriptedWaypointType
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0,_p1] call BIS_fnc_scriptedWaypointType;
        _result = true;
    };
    case "bis_fnc_secondstostring": {
        // [totalSeconds, format, returnArray] call BIS_fnc_secondsToString
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_secondsToString;
        _result = true;
    };
    case "bis_fnc_selectcrew": {
        // [side, configEntry] call BIS_fnc_selectCrew
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_selectCrew;
    };
    case "bis_fnc_selectdiarysubject": {
        // [diaryName] call BIS_fnc_selectDiarySubject
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_selectDiarySubject;
    };
    case "bis_fnc_selectrandom": {
        // values call BIS_fnc_selectRandom
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_selectRandom;
    };
    case "bis_fnc_selectrandomweighted": {
        // itemsAndWeights call BIS_fnc_selectRandomWeighted
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_selectRandomWeighted;
    };
    case "bis_fnc_selectrandomweighted": {
        // [items, weights] call BIS_fnc_selectRandomWeighted
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_selectRandomWeighted;
    };
    case "bis_fnc_selectrespawntemplate": {
        // [mode, arguments] call BIS_fnc_selectRespawnTemplate
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_selectRespawnTemplate;
        _result = true;
    };
    case "bis_fnc_setcuratorcamera": {
        // [camPos, targetPos, time] spawn BIS_fnc_setCuratorCamera
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] spawn BIS_fnc_setCuratorCamera;
        _result = true;
    };
    case "bis_fnc_setdate": {
        // [value, global, transition] call BIS_fnc_setDate
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_setDate;
    };
    case "bis_fnc_setfog": {
        // [strength, density, altitude] call BIS_fnc_setFog
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_setFog;
    };
    case "bis_fnc_setheight": {
        // [target, height, position, mode] call BIS_fnc_setHeight
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_setHeight;
    };
    case "bis_fnc_setheight": {
        // [height, mode] call BIS_fnc_setHeight
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_setHeight;
    };
    case "bis_fnc_sethitpointdamage": {
        // [object, hitPoint, damage, useDependency] call BIS_fnc_setHitPointDamage
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2, _p3] call BIS_fnc_setHitPointDamage;
        _result = true;
    };
    case "bis_fnc_setidcstreamfriendly": {
        // [target,IDC] call BIS_fnc_setIDCStreamFriendly
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0,_p1] call BIS_fnc_setIDCStreamFriendly;
    };
    case "bis_fnc_setidentity": {
        // [object, face, speaker, pitch, callsign] call BIS_fnc_setIdentity
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_setIdentity;
    };
    case "bis_fnc_setmissionstatusslot": {
        // [id, text, texture, color, fade, position, barHeight] call BIS_fnc_setMissionStatusSlot
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        _result = [_p0, _p1, _p2, _p3, _p4, _p5, _p6] call BIS_fnc_setMissionStatusSlot;
    };
    case "bis_fnc_setnestedelement": {
        // [array, path, value] call BIS_fnc_setNestedElement
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_setNestedElement;
    };
    case "bis_fnc_setobjectrotation": {
        // [object, rotation] call BIS_fnc_setObjectRotation
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_setObjectRotation;
        _result = true;
    };
    case "bis_fnc_setobjecttexture": {
        // [object, textures] call BIS_fnc_setObjectTexture
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_setObjectTexture;
    };
    case "bis_fnc_setovercast": {
        // [value] call BIS_fnc_setOvercast
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_setOvercast;
    };
    case "bis_fnc_setpitchbank": {
        // [object, pitch, bank] call BIS_fnc_setPitchBank
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_setPitchBank;
        _result = true;
    };
    case "bis_fnc_setppeffecttemplate": {
        // [template, transition, global] call BIS_fnc_setPPeffectTemplate
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_setPPeffectTemplate;
    };
    case "bis_fnc_setrain": {
        // rainParams call BIS_fnc_setRain
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_setRain;
    };
    case "bis_fnc_setrank": {
        // [target, rank] call BIS_fnc_setRank
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_setRank;
    };
    case "bis_fnc_setrespawninventory": {
        // [target, inventory] call BIS_fnc_setRespawnInventory
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_setRespawnInventory;
    };
    case "bis_fnc_setservervariable": {
        // [namespace, varName, value] call BIS_fnc_setServerVariable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_setServerVariable;
    };
    case "bis_fnc_settopairs": {
        // [array, key, newValue] call BIS_fnc_setToPairs
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_setToPairs;
    };
    case "bis_fnc_setvehiclemass": {
        // [vehicle, animationInformation, massDifference] call BIS_fnc_setVehicleMass
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_setVehicleMass;
    };
    case "bis_fnc_shakecuratorcamera": {
        // [strength,duration,area] spawn BIS_fnc_shakeCuratorCamera
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0,_p1,_p2] spawn BIS_fnc_shakeCuratorCamera;
    };
    case "bis_fnc_shakemap": {
        // [duration, magnitude, center] call BIS_fnc_shakeMap
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_shakeMap;
        _result = true;
    };
    case "bis_fnc_showaanarticle": {
        // [arrayOfArrays, display, fade] call BIS_fnc_showAANArticle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_showAANArticle;
    };
    case "bis_fnc_showcuratorattributes": {
        // [target] call BIS_fnc_showCuratorAttributes
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_showCuratorAttributes;
    };
    case "bis_fnc_showcuratorfeedbackmessage": {
        // [curator, messageInfo] call BIS_fnc_showCuratorFeedbackMessage
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_showCuratorFeedbackMessage;
    };
    case "bis_fnc_showmarker": {
        // [marker, duration, finalAlpha] spawn BIS_fnc_showMarker
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] spawn BIS_fnc_showMarker;
        _result = true;
    };
    case "bis_fnc_showmarkerarray": {
        // [marker, duration, hideAfter] spawn BIS_fnc_showMarkerArray
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] spawn BIS_fnc_showMarkerArray;
        _result = true;
    };
    case "bis_fnc_showmarkers": {
        // [action, markers] call BIS_fnc_showMarkers
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_showMarkers;
        _result = true;
    };
    case "bis_fnc_shownotification": {
        // [template, arguments] call BIS_fnc_showNotification
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_showNotification;
    };
    case "bis_fnc_showrespawnmenu": {
        // [mode] call [[BIS_fnc_showRespawnMenu]];
        private _p0 = _args param [0];
        [_p0] call [[BIS_fnc_showRespawnMenu]];;
        _result = true;
    };
    case "bis_fnc_showrespawnmenudisableitem": {
        // [mode, uiControl, listboxItem, message, respawnReference] call BIS_fnc_showRespawnMenuDisableItem
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_showRespawnMenuDisableItem;
        _result = true;
    };
    case "bis_fnc_showsubtitle": {
        // [name, subtitle] spawn BIS_fnc_showSubtitle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] spawn BIS_fnc_showSubtitle;
        _result = true;
    };
    case "bis_fnc_showtime": {
        // [startDate, endDate] call BIS_fnc_showTime
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_showTime;
        _result = true;
    };
    case "bis_fnc_showunitinfo": {
        // [showUnitInfo] call BIS_fnc_showUnitInfo
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_showUnitInfo;
        _result = true;
    };
    case "bis_fnc_showwelcomescreen": {
        // [display, forceLatest] call BIS_fnc_showWelcomeScreen
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_showWelcomeScreen;
    };
    case "bis_fnc_sidecolor": {
        // [side, returnString] call BIS_fnc_sideColor
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_sideColor;
        _result = true;
    };
    case "bis_fnc_sideid": {
        // testedSide call BIS_fnc_sideID
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_sideID;
    };
    case "bis_fnc_sideisenemy": {
        // [sideA, sideB] call BIS_fnc_sideIsEnemy
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_sideIsEnemy;
    };
    case "bis_fnc_sideisfriendly": {
        // [sideA, sideB] call BIS_fnc_sideIsFriendly
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_sideIsFriendly;
    };
    case "bis_fnc_sidename": {
        // [input] call BIS_fnc_sideName
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_sideName;
    };
    case "bis_fnc_sidenameunlocalized": {
        // input call BIS_fnc_sideNameUnlocalized
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_sideNameUnlocalized;
    };
    case "bis_fnc_sidetype": {
        // sideID call BIS_fnc_sideType
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_sideType;
    };
    case "bis_fnc_simplemovemarker": {
        // [marker, newPosition, duration] call BIS_fnc_simpleMoveMarker
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_simpleMoveMarker;
        _result = true;
    };
    case "bis_fnc_simpleobjectdata": {
        // [classname] call BIS_fnc_simpleObjectData
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_simpleObjectData;
        _result = true;
    };
    case "bis_fnc_slerp": {
        // [currentValue, targetValue, alpha] call BIS_fnc_slerp
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_slerp;
    };
    case "bis_fnc_smoothstep": {
        // number call BIS_fnc_smoothStep
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_smoothStep;
    };
    case "bis_fnc_sortalphabetically": {
        // arrayOfStrings call BIS_fnc_sortAlphabetically
        private _p0 = _args param [0];
        _p0 call BIS_fnc_sortAlphabetically;
        _result = true;
    };
    case "bis_fnc_sortby": {
        // [array, parameters, algorithm, direction, filter] call BIS_fnc_sortBy
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_sortBy;
    };
    case "bis_fnc_sortnum": {
        // array call BIS_fnc_sortNum
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_sortNum;
    };
    case "bis_fnc_spawn": {
        // [params, code] spawn BIS_fnc_spawn
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] spawn BIS_fnc_spawn;
        _result = true;
    };
    case "bis_fnc_spawn": {
        // code spawn BIS_fnc_spawn
        private _p0 = _args param [0];
        _p0 spawn BIS_fnc_spawn;
        _result = true;
    };
    case "bis_fnc_spawncrew": {
        // [vehicle,group,dummyMode,dummyType,crewType]] call BIS_fnc_spawnCrew
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        [_p0,_p1,_p2,_p3,_p4]] call BIS_fnc_spawnCrew;
        _result = true;
    };
    case "bis_fnc_spawnenemy": {
        // [aPlayer, target, side, classes, maxEnemies, delay, code] spawn BIS_fnc_spawnEnemy
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        [_p0, _p1, _p2, _p3, _p4, _p5, _p6] spawn BIS_fnc_spawnEnemy;
        _result = true;
    };
    case "bis_fnc_spawnobjects": {
        // [position, className, count, offsetMatrix, offsetDir, dirNoise, enableSimulation] call BIS_fnc_spawnObjects
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        [_p0, _p1, _p2, _p3, _p4, _p5, _p6] call BIS_fnc_spawnObjects;
        _result = true;
    };
    case "bis_fnc_spawnordered": {
        // [params, functionName, mutexName] call BIS_fnc_spawnOrdered
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_spawnOrdered;
    };
    case "bis_fnc_spawnvehicle": {
        // [position, direction, type, sideOrGroup] call BIS_fnc_spawnVehicle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2, _p3] call BIS_fnc_spawnVehicle;
        _result = true;
    };
    case "bis_fnc_splitstring": {
        // [stringToSplit, separators, byWord] call BIS_fnc_splitString
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_splitString;
        _result = true;
    };
    case "bis_fnc_spotter": {
        // [sniper, spotter] call BIS_fnc_spotter
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_spotter;
        _result = true;
    };
    case "bis_fnc_stalk": {
        // [stalker, stalked, refresh, radius, endCondition, endDestination] spawn BIS_fnc_stalk
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _result = [_p0, _p1, _p2, _p3, _p4, _p5] spawn BIS_fnc_stalk;
    };
    case "bis_fnc_startloadingscreen": {
        // [screenId, layout] call BIS_fnc_startLoadingScreen
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_startLoadingScreen;
    };
    case "bis_fnc_strategicmapanimate": {
        // [target,time] spawn BIS_fnc_strategicMapAnimate
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0,_p1] spawn BIS_fnc_strategicMapAnimate;
    };
    case "bis_fnc_strategicmapopen": {
        // [display, pos, missions, ORBATs, markers, images, weather, night, scale, simulation, label, missionName, missionIcon] call BIS_fnc_strategicMapOpen
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
        _result = [_p0, _p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, _p9, _p10, _p11, _p12] call BIS_fnc_strategicMapOpen;
    };
    case "bis_fnc_stringtomarker": {
        // data call BIS_fnc_stringToMarker
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_stringToMarker;
    };
    case "bis_fnc_stringtomarkerlocal": {
        // data call BIS_fnc_stringToMarkerLocal
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_stringToMarkerLocal;
    };
    case "bis_fnc_subselect": {
        // [array, start, endOrLength] call BIS_fnc_subSelect
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_subSelect;
    };
    case "bis_fnc_sunrisesunsettime": {
        // date call BIS_fnc_sunriseSunsetTime
        private _p0 = _args param [0];
        _p0 call BIS_fnc_sunriseSunsetTime;
        _result = true;
    };
    case "bis_fnc_supplydrop": {
        // [airUnit,class] spawn BIS_fnc_supplydrop
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0,_p1] spawn BIS_fnc_supplydrop;
        _result = true;
    };
    case "bis_fnc_swapvars": {
        // [variableName1, variableName2] call BIS_fnc_swapVars
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_swapVars;
        _result = true;
    };
    case "bis_fnc_switchlamp": {
        // [object, state] call BIS_fnc_switchLamp
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_switchLamp;
        _result = true;
    };
    case "bis_fnc_synchronizedobjects": {
        // [object,filter,preciseMatch] call BIS_fnc_synchronizedObjects
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0,_p1,_p2] call BIS_fnc_synchronizedObjects;
    };
    case "bis_fnc_target": {
        // [action, parameters] call BIS_fnc_target
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_target;
        _result = true;
    };
    case "bis_fnc_taskalwaysvisible": {
        // taskID call BIS_fnc_taskAlwaysVisible
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_taskAlwaysVisible;
    };
    case "bis_fnc_taskattack": {
        // [group, position] call BIS_fnc_taskAttack
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_taskAttack;
    };
    case "bis_fnc_taskchildren": {
        // taskID call BIS_fnc_taskChildren
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_taskChildren;
    };
    case "bis_fnc_taskcompleted": {
        // taskID call BIS_fnc_taskCompleted
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_taskCompleted;
    };
    case "bis_fnc_taskcurrent": {
        // unit call BIS_fnc_taskCurrent
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_taskCurrent;
    };
    case "bis_fnc_taskdefend": {
        // [group, position] call BIS_fnc_taskDefend
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_taskDefend;
    };
    case "bis_fnc_taskdescription": {
        // taskName call BIS_fnc_taskDescription
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_taskDescription;
    };
    case "bis_fnc_taskdestination": {
        // taskName call BIS_fnc_taskDestination
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_taskDestination;
    };
    case "bis_fnc_taskexists": {
        // [taskName] call BIS_fnc_taskExists
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_taskExists;
    };
    case "bis_fnc_taskhint": {
        // [taskName, taskState] call BIS_fnc_taskHint
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_taskHint;
    };
    case "bis_fnc_taskparent": {
        // taskName call BIS_fnc_taskParent
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_taskParent;
    };
    case "bis_fnc_taskpatrol": {
        // [group, position, distance, blacklist] call BIS_fnc_taskPatrol
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_taskPatrol;
    };
    case "bis_fnc_taskreal": {
        // [taskName, owner] call BIS_fnc_taskReal
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_taskReal;
    };
    case "bis_fnc_tasksetalwaysvisible": {
        // [taskID,alwaysVisible] call BIS_fnc_taskSetAlwaysVisible
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0,_p1] call BIS_fnc_taskSetAlwaysVisible;
    };
    case "bis_fnc_tasksetdescription": {
        // [taskId, [taskDescription, taskTitle, taskMarker]] call BIS_fnc_taskSetDescription
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, [_p1, _p2, _p3]] call BIS_fnc_taskSetDescription;
    };
    case "bis_fnc_tasksetdestination": {
        // [taskName, destination] call BIS_fnc_taskSetDestination
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_taskSetDestination;
    };
    case "bis_fnc_tasksetstate": {
        // [taskName, taskState, showHint] call BIS_fnc_taskSetState
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_taskSetState;
    };
    case "bis_fnc_taskstate": {
        // taskID call BIS_fnc_taskState
        private _p0 = _args param [0];
        _p0 call BIS_fnc_taskState;
        _result = true;
    };
    case "bis_fnc_tasksunit": {
        // target call BIS_fnc_tasksUnit
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_tasksUnit;
    };
    case "bis_fnc_tasktype": {
        // taskID call BIS_fnc_taskType
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_taskType;
    };
    case "bis_fnc_tasktypeicon": {
        // [type, default] call BIS_fnc_taskTypeIcon
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_taskTypeIcon;
    };
    case "bis_fnc_taskvar": {
        // taskID call BIS_fnc_taskVar
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_taskVar;
    };
    case "bis_fnc_teamcolor": {
        // [teamId, getColour] call BIS_fnc_teamColor
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_teamColor;
        _result = true;
    };
    case "bis_fnc_terraingradangle": {
        // [object, direction, delta] call [[BIS_fnc_terrainGradAngle]];
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call [[BIS_fnc_terrainGradAngle]];;
    };
    case "bis_fnc_texttiles": {
        // [content, position, tileSize, duration, fadeInOutTime, tileTransparency] spawn BIS_fnc_textTiles
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _result = [_p0, _p1, _p2, _p3, _p4, _p5] spawn BIS_fnc_textTiles;
    };
    case "bis_fnc_texturemarker": {
        // [wantedMarker] call BIS_fnc_textureMarker
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_textureMarker;
    };
    case "bis_fnc_texturevehicleicon": {
        // [wantedIcon] call BIS_fnc_textureVehicleIcon
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_textureVehicleIcon;
    };
    case "bis_fnc_threat": {
        // [unit] call BIS_fnc_threat
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_threat;
    };
    case "bis_fnc_timeline_cleanup": {
        // [timeline] call BIS_fnc_timeline_cleanup
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_timeline_cleanup;
        _result = true;
    };
    case "bis_fnc_timeline_deleted": {
        // [timeline] call BIS_fnc_timeline_deleted
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_timeline_deleted;
        _result = true;
    };
    case "bis_fnc_timeline_finish": {
        // [timeline] call BIS_fnc_timeline_finish
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_timeline_finish;
        _result = true;
    };
    case "bis_fnc_timeline_getalpha": {
        // [timeline] call BIS_fnc_timeline_getAlpha
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_timeline_getAlpha;
    };
    case "bis_fnc_timeline_getcurrenttime": {
        // [timeline] call BIS_fnc_timeline_getCurrentTime
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_timeline_getCurrentTime;
    };
    case "bis_fnc_timeline_getinterpmode": {
        // [timeline] call BIS_fnc_timeline_getInterpMode
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_timeline_getInterpMode;
    };
    case "bis_fnc_timeline_getlength": {
        // [timeline] call BIS_fnc_timeline_getLength
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_timeline_getLength;
    };
    case "bis_fnc_timeline_getplayfromstart": {
        // [timeline] call BIS_fnc_timeline_getPlayFromStart
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_timeline_getPlayFromStart;
    };
    case "bis_fnc_timeline_getplayrate": {
        // [timeline] call BIS_fnc_timeline_getPlayRate
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_timeline_getPlayRate;
    };
    case "bis_fnc_timeline_getplaytime": {
        // [timeline] call BIS_fnc_timeline_getPlayTime
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_timeline_getPlayTime;
    };
    case "bis_fnc_timeline_getposition": {
        // [timeline] call BIS_fnc_timeline_getPosition
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_timeline_getPosition;
    };
    case "bis_fnc_timeline_getsimulatedcurves": {
        // [timeline] call BIS_fnc_timeline_getSimulatedCurves
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_timeline_getSimulatedCurves;
    };
    case "bis_fnc_timeline_getstoptime": {
        // [timeline] call BIS_fnc_timeline_getStopTime
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_timeline_getStopTime;
    };
    case "bis_fnc_timeline_gettimeleft": {
        // [timeline] call BIS_fnc_timeline_getTimeLeft
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_timeline_getTimeLeft;
    };
    case "bis_fnc_timeline_isfinished": {
        // [timeline] call BIS_fnc_timeline_isFinished
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_timeline_isFinished;
    };
    case "bis_fnc_timeline_islooping": {
        // [timeline] call BIS_fnc_timeline_isLooping
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_timeline_isLooping;
    };
    case "bis_fnc_timeline_ispaused": {
        // [timeline] call BIS_fnc_timeline_isPaused
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_timeline_isPaused;
    };
    case "bis_fnc_timeline_isplaying": {
        // [timeline] call BIS_fnc_timeline_isPlaying
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_timeline_isPlaying;
    };
    case "bis_fnc_timeline_isreverse": {
        // [timeline] call BIS_fnc_timeline_isReverse
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_timeline_isReverse;
    };
    case "bis_fnc_timeline_play": {
        // [timeline] call BIS_fnc_timeline_play
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_timeline_play;
        _result = true;
    };
    case "bis_fnc_timeline_setinterpmode": {
        // [timeline, mode] call BIS_fnc_timeline_setInterpMode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_timeline_setInterpMode;
        _result = true;
    };
    case "bis_fnc_timeline_setlength": {
        // [timeline, length] call BIS_fnc_timeline_setLength
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_timeline_setLength;
        _result = true;
    };
    case "bis_fnc_timeline_setloop": {
        // [timeline, loop] call BIS_fnc_timeline_setLoop
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_timeline_setLoop;
        _result = true;
    };
    case "bis_fnc_timeline_setpause": {
        // [timeline, pause] call BIS_fnc_timeline_setPause
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_timeline_setPause;
        _result = true;
    };
    case "bis_fnc_timeline_setplayrate": {
        // [timeline, rate] call BIS_fnc_timeline_setPlayRate
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_timeline_setPlayRate;
        _result = true;
    };
    case "bis_fnc_timeline_setposition": {
        // [timeline, position] call BIS_fnc_timeline_setPosition
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_timeline_setPosition;
        _result = true;
    };
    case "bis_fnc_timeline_setreverse": {
        // [timeline, reverse] call BIS_fnc_timeline_setReverse
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_timeline_setReverse;
        _result = true;
    };
    case "bis_fnc_timeline_stop": {
        // [timeline] call BIS_fnc_timeline_stop
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_timeline_stop;
        _result = true;
    };
    case "bis_fnc_timeline_tick": {
        // [timeline] call BIS_fnc_timeline_tick
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_timeline_tick;
        _result = true;
    };
    case "bis_fnc_timetostring": {
        // [time, format] call BIS_fnc_timeToString
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_timeToString;
        _result = true;
    };
    case "bis_fnc_titlecard": {
        // [path, subtitle] call BIS_fnc_titlecard
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_titlecard;
    };
    case "bis_fnc_titletext": {
        // message call BIS_fnc_titleText
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_titleText;
    };
    case "bis_fnc_togglecuratorvisionmode": {
        // [curator, mode] call BIS_fnc_toggleCuratorVisionMode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_toggleCuratorVisionMode;
    };
    case "bis_fnc_toupperdisplaytexts": {
        // [displayClass, controlClasses, blacklist] call BIS_fnc_toUpperDisplayTexts
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_toUpperDisplayTexts;
        _result = true;
    };
    case "bis_fnc_tracebullets": {
        // [unit, number] call BIS_fnc_traceBullets
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_traceBullets;
        _result = true;
    };
    case "bis_fnc_trackmissiontime": {
        // [save, delete] call BIS_fnc_trackMissionTime
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_trackMissionTime;
    };
    case "bis_fnc_transformvectordirandup": {
        // [vectorDirAndUp, yaw, pitch, roll] call BIS_fnc_transformVectorDirAndUp
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2, _p3] call BIS_fnc_transformVectorDirAndUp;
        _result = true;
    };
    case "bis_fnc_tridentexecute": {
        // [side_1, side_2, codeFriendly, codeEnemy] call BIS_fnc_tridentExecute
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_tridentExecute;
    };
    case "bis_fnc_tridentgetrelationship": {
        // [sideA, sideB] call BIS_fnc_tridentGetRelationship
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_tridentGetRelationship;
    };
    case "bis_fnc_tridenthandledamage": {
        // object call BIS_fnc_tridentHandleDamage
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_tridentHandleDamage;
    };
    case "bis_fnc_tridentsetrelationship": {
        // [side1, side2, value, absolute] call BIS_fnc_tridentSetRelationship
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0, _p1, _p2, _p3] call BIS_fnc_tridentSetRelationship;
    };
    case "bis_fnc_triggertomarker": {
        // [trigger, markerName] call BIS_fnc_triggerToMarker
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_triggerToMarker;
    };
    case "bis_fnc_trimstring": {
        // [someText, beginning, length] call BIS_fnc_trimString
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_trimString;
    };
    case "bis_fnc_turretconfig": {
        // [vehicle, turret] call BIS_fnc_turretConfig
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_turretConfig;
    };
    case "bis_fnc_typetext": {
        // [stringLines, posX, posY, rootFormat] spawn BIS_fnc_typeText
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2, _p3] spawn BIS_fnc_typeText;
        _result = true;
    };
    case "bis_fnc_typetext2": {
        // [stringLines, posX, posY, alignBottom, rootFormat, abortParams, abortCond, playSounds] call BIS_fnc_typeText2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        private _p7 = _args param [7];
        [_p0, _p1, _p2, _p3, _p4, _p5, _p6, _p7] call BIS_fnc_typeText2;
        _result = true;
    };
    case "bis_fnc_unitaddon": {
        // [object] call BIS_fnc_unitAddon
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_unitAddon;
    };
    case "bis_fnc_unitcapturefiring": {
        // [unit, duration, startTime] spawn BIS_fnc_unitCaptureFiring
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] spawn BIS_fnc_unitCaptureFiring;
        _result = true;
    };
    case "bis_fnc_unitheadgear": {
        // [unit, headgear, facewear] call BIS_fnc_unitHeadgear
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_unitHeadgear;
    };
    case "bis_fnc_unitplay": {
        // [unit, data, varDone, stateIgnore, obsolete_1, obsolete_2, skipTime] spawn BIS_fnc_unitPlay
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        _result = [_p0, _p1, _p2, _p3, _p4, _p5, _p6] spawn BIS_fnc_unitPlay;
    };
    case "bis_fnc_unitplayfiring": {
        // [unit, data, stateIgnore] spawn BIS_fnc_unitPlayFiring
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] spawn BIS_fnc_unitPlayFiring;
        _result = true;
    };
    case "bis_fnc_unpackstaticweapon": {
        // [group, weaponPos, targetPos, leaderPos] call BIS_fnc_unpackStaticWeapon
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2, _p3] call BIS_fnc_unpackStaticWeapon;
        _result = true;
    };
    case "bis_fnc_updateplayerarray": {
        // [input] call BIS_fnc_updatePlayerArray
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_updatePlayerArray;
    };
    case "bis_fnc_validateparametersoo": {
        // [class,method,params] call BIS_fnc_validateParametersOO
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0,_p1,_p2] call BIS_fnc_validateParametersOO;
    };
    case "bis_fnc_variablespaceadd": {
        // [object, varName, element, global, inArray] call BIS_fnc_variableSpaceAdd
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_variableSpaceAdd;
    };
    case "bis_fnc_variablespaceremove": {
        // [object,varName,element,global,inArray] call BIS_fnc_variableSpaceRemove
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = [_p0,_p1,_p2,_p3,inArray] call BIS_fnc_variableSpaceRemove;
    };
    case "bis_fnc_vectoradd": {
        // [vector1, vector2] call BIS_fnc_vectorAdd
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_vectorAdd;
        _result = true;
    };
    case "bis_fnc_vectordiff": {
        // [vector1, vector2] call BIS_fnc_vectorDiff
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_vectorDiff;
    };
    case "bis_fnc_vectordiranduprelative": {
        // [object1, object2, visual] call BIS_fnc_vectorDirAndUpRelative
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_vectorDirAndUpRelative;
        _result = true;
    };
    case "bis_fnc_vectordivide": {
        // [vector, divider] call BIS_fnc_vectorDivide
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_vectorDivide;
        _result = true;
    };
    case "bis_fnc_vectorfromxtoy": {
        // [vector1, vector2] call BIS_fnc_vectorFromXToY
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_vectorFromXToY;
    };
    case "bis_fnc_vectormultiply": {
        // [vector, factor] call BIS_fnc_vectorMultiply
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_vectorMultiply;
        _result = true;
    };
    case "bis_fnc_vehiclecrewturrets": {
        // vehicle call BIS_fnc_vehicleCrewTurrets
        private _p0 = _args param [0];
        _result = _p0 call BIS_fnc_vehicleCrewTurrets;
    };
    case "bis_fnc_versioninfo": {
        // [gameTypeVersionControl, modControl] call BIS_fnc_versionInfo
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_versionInfo;
        _result = true;
    };
    case "bis_fnc_vrdrawborder": {
        // [center, radius] call BIS_fnc_VRDrawBorder
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_VRDrawBorder;
    };
    case "bis_fnc_vrdrawgrid": {
        // [location, colour] call BIS_fnc_VRDrawGrid
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0, _p1] call BIS_fnc_VRDrawGrid;
        _result = true;
    };
    case "bis_fnc_vreffectkilled": {
        // [object, instant, delay] call BIS_fnc_VREffectKilled
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = [_p0, _p1, _p2] call BIS_fnc_VREffectKilled;
    };
    case "bis_fnc_vrhitpart": {
        // [object,time] call BIS_fnc_VRHitpart
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        [_p0,_p1] call BIS_fnc_VRHitpart;
        _result = true;
    };
    case "bis_fnc_vrspawnselector": {
        // [center, type] call BIS_fnc_VRSpawnSelector
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = [_p0, _p1] call BIS_fnc_VRSpawnSelector;
    };
    case "bis_fnc_vrtimer": {
        // [colour] spawn BIS_fnc_VRTimer
        private _p0 = _args param [0];
        [_p0] spawn BIS_fnc_VRTimer;
        _result = true;
    };
    case "bis_fnc_weaponcomponents": {
        // [classname] call BIS_fnc_weaponComponents
        private _p0 = _args param [0];
        _result = [_p0] call BIS_fnc_weaponComponents;
    };
    case "bis_fnc_weapondirectionrelative": {
        // [vehicle, weapon, visual] call BIS_fnc_weaponDirectionRelative
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        [_p0, _p1, _p2] call BIS_fnc_weaponDirectionRelative;
        _result = true;
    };
    case "bis_fnc_weaponsentitytype": {
        // class call BIS_fnc_weaponsEntityType
        private _p0 = _args param [0];
        _p0 call BIS_fnc_weaponsEntityType;
        _result = true;
    };
    case "bis_fnc_wlsmoothtext": {
        // [text, nbOfLines, duration, color, outline] call BIS_fnc_WLSmoothText
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_WLSmoothText;
        _result = true;
    };
    case "bis_fnc_wpaerobatics": {
        // Custom Waypoint arguments: [visuals, detectionCode, completionCode]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        Custom Waypoint arguments: [_p0, _p1, _p2];
        _result = true;
    };
    case "bis_fnc_wpangle": {
        // Custom Waypoint arguments: [circleLimit, circleBorder, circleDir, customCond, hint]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        Custom Waypoint arguments: [_p0, _p1, _p2, _p3, _p4];
        _result = true;
    };
    case "bis_fnc_wpartillery": {
        // [group, position, target, firedRounds, type] call BIS_fnc_wpArtillery
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_wpArtillery;
    };
    case "bis_fnc_wpcheckpoint": {
        // Custom Waypoint arguments: [posLimit]
        private _p0 = _args param [0];
        Custom Waypoint arguments: [_p0];
        _result = true;
    };
    case "bis_fnc_wpdemine": {
        // [group, position, target, clearUnknownMines] call BIS_fnc_wpDemine
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        [_p0, _p1, _p2, _p3] call BIS_fnc_wpDemine;
        _result = true;
    };
    case "bis_fnc_wpfastrope": {
        // Custom Waypoint arguments: [limitHeight,limitSpeed,fastropeID]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        Custom Waypoint arguments: [_p0,_p1,_p2];
        _result = true;
    };
    case "bis_fnc_wpformation": {
        // Custom Waypoint arguments: [failCode, maxTime, relPos, diffAlt, visualize]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        Custom Waypoint arguments: [_p0, _p1, _p2, _p3, _p4];
        _result = true;
    };
    case "bis_fnc_wphover": {
        // Custom Waypoint arguments: [minTime, reset, altDiff, visualize]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        Custom Waypoint arguments: [_p0, _p1, _p2, _p3];
        _result = true;
    };
    case "bis_fnc_wpland": {
        // arguments: [dirParam, visualize]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        arguments: [_p0, _p1];
        _result = true;
    };
    case "bis_fnc_wprestricted": {
        // Custom Waypoint arguments: [limits, maxTime, failCode, visualize, warnCode]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        Custom Waypoint arguments: [limits, _p1, _p0, _p3, _p4];
        _result = true;
    };
    case "bis_fnc_wpslingloadattach": {
        // Custom Waypoint arguments: [posLimit, failCode, weight]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        Custom Waypoint arguments: [_p0, _p1, _p2];
        _result = true;
    };
    case "bis_fnc_wpslingloaddetach": {
        // Custom Waypoint arguments: [posLimit,limitDir]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        Custom Waypoint arguments: [_p0,_p1];
        _result = true;
    };
    case "bis_fnc_wpsteady": {
        // Custom Waypoint arguments: [limitArray, failLimit, failCode, warningCode, positiveCode]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        Custom Waypoint arguments: [_p0, _p1, _p2, _p3, _p4];
        _result = true;
    };
    case "bis_fnc_wptimed": {
        // Custom Waypoint arguments: [failCode,timeLimit,showHint]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        Custom Waypoint arguments: [_p0,_p1,_p2];
        _result = true;
    };
    case "bis_fnc_wpwinchload": {
        // Custom Waypoint arguments: [limitHeight, winchID, crewman, failCode, loadCode]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        Custom Waypoint arguments: [_p0, _p1, _p2, _p3, _p4];
        _result = true;
    };
    case "bis_fnc_zoomlock": {
        // [cameraCenter] call BIS_fnc_zoomLock
        private _p0 = _args param [0];
        [_p0] call BIS_fnc_zoomLock;
        _result = true;
    };
    case "bis_fnc_zoomlockeh": {
        // position call BIS_fnc_zoomLockEH
        private _p0 = _args param [0];
        _p0 call BIS_fnc_zoomLockEH;
        _result = true;
    };
    case "bis_fnc_zoomonarea": {
        // [area, center, time, handler, forceCam] call BIS_fnc_zoomOnArea
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = [_p0, _p1, _p2, _p3, _p4] call BIS_fnc_zoomOnArea;
    };
    default { _handled = false; };
};

[_handled, _result]
