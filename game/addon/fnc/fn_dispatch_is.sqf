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
    case "isabletobreathe": {
        // isAbleToBreathe  unit
        private _p0 = _args param [0];
        _result = isAbleToBreathe  _p0;
    };
    case "isagent": {
        // isAgent teamMember
        private _p0 = _args param [0];
        _result = isAgent _p0;
    };
    case "isaimprecisionenabled": {
        // isAimPrecisionEnabled unit
        private _p0 = _args param [0];
        _result = isAimPrecisionEnabled _p0;
    };
    case "isallowedcrewinimmobile": {
        // isAllowedCrewInImmobile vehicle
        private _p0 = _args param [0];
        _result = isAllowedCrewInImmobile _p0;
    };
    case "isarray": {
        // isArray config
        private _p0 = _args param [0];
        _result = isArray _p0;
    };
    case "isautohoveron": {
        // isAutoHoverOn vehicle
        private _p0 = _args param [0];
        _result = isAutoHoverOn _p0;
    };
    case "isautonomous": {
        // isAutonomous uav
        private _p0 = _args param [0];
        _result = isAutonomous _p0;
    };
    case "isautostartupenabledrtd": {
        // isAutoStartUpEnabledRTD helicopter
        private _p0 = _args param [0];
        _result = isAutoStartUpEnabledRTD _p0;
    };
    case "isautotrimonrtd": {
        // isAutoTrimOnRTD helicopter
        private _p0 = _args param [0];
        _result = isAutoTrimOnRTD _p0;
    };
    case "isawake": {
        // isAwake object
        private _p0 = _args param [0];
        _result = isAwake _p0;
    };
    case "isbleeding": {
        // isBleeding  unit
        private _p0 = _args param [0];
        _result = isBleeding  _p0;
    };
    case "isburning": {
        // isBurning unit
        private _p0 = _args param [0];
        _result = isBurning _p0;
    };
    case "isclass": {
        // isClass config
        private _p0 = _args param [0];
        _result = isClass _p0;
    };
    case "iscollisionlighton": {
        // isCollisionLightOn vehicle
        private _p0 = _args param [0];
        _result = isCollisionLightOn _p0;
    };
    case "iscopilotenabled": {
        // isCopilotEnabled vehicle
        private _p0 = _args param [0];
        _result = isCopilotEnabled _p0;
    };
    case "isdamageallowed": {
        // isDamageAllowed object
        private _p0 = _args param [0];
        _result = isDamageAllowed _p0;
    };
    case "isengineon": {
        // isEngineOn vehicle
        private _p0 = _args param [0];
        _result = isEngineOn _p0;
    };
    case "isequalref": {
        // val1 isEqualRef val2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 isEqualRef _p1;
    };
    case "isequalto": {
        // val1 isEqualTo val2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 isEqualTo _p1;
    };
    case "isequaltype": {
        // val1 isEqualType val2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 isEqualType _p1;
    };
    case "isequaltypeall": {
        // arr isEqualTypeAll val
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 isEqualTypeAll _p1;
    };
    case "isequaltypeany": {
        // val isEqualTypeAny types
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 isEqualTypeAny _p1;
    };
    case "isequaltypearray": {
        // arr1 isEqualTypeArray arr2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 isEqualTypeArray _p1;
    };
    case "isequaltypeparams": {
        // input isEqualTypeParams  template
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 isEqualTypeParams  _p1;
    };
    case "isfinal": {
        // isFinal code
        private _p0 = _args param [0];
        _result = isFinal _p0;
    };
    case "isflashlighton": {
        // unit isFlashlightOn  weapon
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 isFlashlightOn  _p1;
    };
    case "isflatempty": {
        // position isFlatEmpty [minDistance, mode, maxGradient, maxGradientRadius, overLandOrWater, shoreLine, ignoreObject]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        private _p7 = _args param [7];
        _result = _p0 isFlatEmpty [_p1, _p2, _p3, _p4, _p5, _p6, _p7];
    };
    case "isforcedwalk": {
        // isForcedWalk unitName
        private _p0 = _args param [0];
        _result = isForcedWalk _p0;
    };
    case "isformationleader": {
        // isFormationLeader unit
        private _p0 = _args param [0];
        _result = isFormationLeader _p0;
    };
    case "isgroupdeletedwhenempty": {
        // isGroupDeletedWhenEmpty group
        private _p0 = _args param [0];
        _result = isGroupDeletedWhenEmpty _p0;
    };
    case "ishidden": {
        // isHidden person
        private _p0 = _args param [0];
        _result = isHidden _p0;
    };
    case "ishidebehindscripted": {
        // isHideBehindScripted vehicle
        private _p0 = _args param [0];
        _result = isHideBehindScripted _p0;
    };
    case "isinremainscollector": {
        // isInRemainsCollector remain
        private _p0 = _args param [0];
        _result = isInRemainsCollector _p0;
    };
    case "isirlaseron": {
        // unit isIRLaserOn weapon
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 isIRLaserOn _p1;
    };
    case "iskeyactive": {
        // isKeyActive keyName
        private _p0 = _args param [0];
        _result = isKeyActive _p0;
    };
    case "iskindof": {
        // object isKindOf typeName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 isKindOf _p1;
    };
    case "iskindof": {
        // typeName1 isKindOf typeName2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 isKindOf _p1;
    };
    case "iskindof": {
        // typeName1 isKindOf [typeName2, targetConfig]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 isKindOf [_p1, _p2];
    };
    case "islaseron": {
        // isLaserOn entity
        private _p0 = _args param [0];
        _result = isLaserOn _p0;
    };
    case "islaseron": {
        // vehicle isLaserOn turret
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 isLaserOn _p1;
    };
    case "islighton": {
        // isLightOn vehicle
        private _p0 = _args param [0];
        _result = isLightOn _p0;
    };
    case "islighton": {
        // isLightOn [vehicle, turret]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = isLightOn [_p0, _p1];
    };
    case "islocalized": {
        // isLocalized  stringName
        private _p0 = _args param [0];
        _result = isLocalized  _p0;
    };
    case "ismanualfire": {
        // isManualFire vehicleName
        private _p0 = _args param [0];
        _result = isManualFire _p0;
    };
    case "ismarkedforcollection": {
        // isMarkedForCollection  object
        private _p0 = _args param [0];
        _result = isMarkedForCollection  _p0;
    };
    case "isnil": {
        // isNil variableName
        private _p0 = _args param [0];
        _result = isNil _p0;
    };
    case "isnil": {
        // isNil code
        private _p0 = _args param [0];
        _result = isNil _p0;
    };
    case "isnotequalref": {
        // val1 isNotEqualRef val2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 isNotEqualRef _p1;
    };
    case "isnotequalto": {
        // val1 isNotEqualTo val2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 isNotEqualTo _p1;
    };
    case "isnull": {
        // isNull entity
        private _p0 = _args param [0];
        _result = isNull _p0;
    };
    case "isnumber": {
        // isNumber config
        private _p0 = _args param [0];
        _result = isNumber _p0;
    };
    case "isobjecthidden": {
        // isObjectHidden object
        private _p0 = _args param [0];
        _result = isObjectHidden _p0;
    };
    case "isobjectrtd": {
        // isObjectRTD helicopter
        private _p0 = _args param [0];
        _result = isObjectRTD _p0;
    };
    case "isonroad": {
        // isOnRoad position
        private _p0 = _args param [0];
        _result = isOnRoad _p0;
    };
    case "isplayer": {
        // isPlayer unit
        private _p0 = _args param [0];
        _result = isPlayer _p0;
    };
    case "isplayer": {
        // isPlayer [person]
        private _p0 = _args param [0];
        _result = isPlayer [_p0];
    };
    case "isrealtime": {
        // isRealTime map
        private _p0 = _args param [0];
        _result = isRealTime _p0;
    };
    case "issensortargetconfirmed": {
        // unit isSensorTargetConfirmed side
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 isSensorTargetConfirmed _p1;
    };
    case "isshowing3dicons": {
        // isShowing3DIcons map
        private _p0 = _args param [0];
        _result = isShowing3DIcons _p0;
    };
    case "issimpleobject": {
        // isSimpleObject object
        private _p0 = _args param [0];
        _result = isSimpleObject _p0;
    };
    case "issprintallowed": {
        // isSprintAllowed unit
        private _p0 = _args param [0];
        _result = isSprintAllowed _p0;
    };
    case "isstaminaenabled": {
        // isStaminaEnabled  unit
        private _p0 = _args param [0];
        _result = isStaminaEnabled  _p0;
    };
    case "istext": {
        // isText  config
        private _p0 = _args param [0];
        _result = isText  _p0;
    };
    case "istouchingground": {
        // isTouchingGround object
        private _p0 = _args param [0];
        _result = isTouchingGround _p0;
    };
    case "isturnedout": {
        // isTurnedOut unit
        private _p0 = _args param [0];
        _result = isTurnedOut _p0;
    };
    case "isuavconnectable": {
        // object isUAVConnectable [uav, checkAllItems]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 isUAVConnectable [_p1, _p2];
    };
    case "isuavconnected": {
        // isUAVConnected uav
        private _p0 = _args param [0];
        _result = isUAVConnected _p0;
    };
    case "isuniformallowed": {
        // unit isUniformAllowed type
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 isUniformAllowed _p1;
    };
    case "isvehiclecargo": {
        // isVehicleCargo cargo
        private _p0 = _args param [0];
        _result = isVehicleCargo _p0;
    };
    case "isvehicleradaron": {
        // isVehicleRadarOn vehicle
        private _p0 = _args param [0];
        _result = isVehicleRadarOn _p0;
    };
    case "isvehiclesensorenabled": {
        // vehicle isVehicleSensorEnabled componentName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 isVehicleSensorEnabled _p1;
    };
    case "iswalking": {
        // isWalking unitName
        private _p0 = _args param [0];
        _result = isWalking _p0;
    };
    case "isweapondeployed": {
        // isWeaponDeployed unit
        private _p0 = _args param [0];
        _result = isWeaponDeployed _p0;
    };
    case "isweapondeployed": {
        // isWeaponDeployed [unit, onGround]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = isWeaponDeployed [_p0, _p1];
    };
    case "isweaponrested": {
        // isWeaponRested unit
        private _p0 = _args param [0];
        _result = isWeaponRested _p0;
    };
    default { _handled = false; };
};

[_handled, _result]
