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
    case "set": {
        // array set [index, value]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 set [_p1, _p2];
        _result = true;
    };
    case "set": {
        // hashMap set [key, value, insertOnly]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = _p0 set [_p1, _p2, _p3];
    };
    case "set3denattribute": {
        // entity set3DENAttribute [class, value]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 set3DENAttribute [_p1, _p2];
    };
    case "set3dengrid": {
        // set3DENGrid [type, value]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        set3DENGrid [_p0, _p1];
        _result = true;
    };
    case "set3deniconsvisible": {
        // set3DENIconsVisible [showMap, showScene]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        set3DENIconsVisible [_p1, _p0];
        _result = true;
    };
    case "set3denlayer": {
        // entity set3DENLayer layerID
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 set3DENLayer _p1;
    };
    case "set3denlinesvisible": {
        // set3DENLinesVisible [showMap, showScene]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        set3DENLinesVisible [_p1, _p0];
        _result = true;
    };
    case "set3denlogictype": {
        // objects set3DENLogicType classname
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 set3DENLogicType _p1;
        _result = true;
    };
    case "set3denmissionattribute": {
        // section set3DENMissionAttribute [class, value]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 set3DENMissionAttribute [_p1, _p2];
    };
    case "set3denmodelsvisible": {
        // set3DENModelsVisible [map, scene]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        set3DENModelsVisible [_p0, _p1];
        _result = true;
    };
    case "set3denobjecttype": {
        // objects set3DENObjectType classname
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 set3DENObjectType _p1;
        _result = true;
    };
    case "set3denselected": {
        // set3DENSelected entities
        private _p0 = _args param [0];
        set3DENSelected _p0;
        _result = true;
    };
    case "setacctime": {
        // setAccTime accFactor
        private _p0 = _args param [0];
        setAccTime _p0;
        _result = true;
    };
    case "setactualcollectivertd": {
        // helicopterRTD setActualCollectiveRTD value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setActualCollectiveRTD _p1;
        _result = true;
    };
    case "setairplanethrottle": {
        // airplane setAirplaneThrottle value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setAirplaneThrottle _p1;
        _result = true;
    };
    case "setairportside": {
        // id setAirportSide side
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setAirportSide _p1;
        _result = true;
    };
    case "setairportside": {
        // target setAirportSide side
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setAirportSide _p1;
        _result = true;
    };
    case "setammo": {
        // unit setAmmo [weaponOrMuzzle, count]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setAmmo [_p1, _p2];
        _result = true;
    };
    case "setammocargo": {
        // vehicleName setAmmoCargo ammoCargo
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setAmmoCargo _p1;
        _result = true;
    };
    case "setammoonpylon": {
        // vehicle setAmmoOnPylon [pylon, ammocount]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setAmmoOnPylon [_p1, _p2];
        _result = true;
    };
    case "setanimspeedcoef": {
        // unit setAnimSpeedCoef coef
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setAnimSpeedCoef _p1;
        _result = true;
    };
    case "setaperture": {
        // setAperture aperture
        private _p0 = _args param [0];
        setAperture _p0;
        _result = true;
    };
    case "setaperturenew": {
        // setApertureNew [minimum, standard, maximum, luminance]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        setApertureNew [_p0, _p1, _p2, _p3];
        _result = true;
    };
    case "setapurtd": {
        // helicopterRTD setAPURTD [value, time]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setAPURTD [_p1, _p2];
        _result = true;
    };
    case "setarmorypoints": {
        // setArmoryPoints points
        private _p0 = _args param [0];
        setArmoryPoints _p0;
        _result = true;
    };
    case "setautonomous": {
        // uav setAutonomous bool
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 setAutonomous _p1;
    };
    case "setbatterychargertd": {
        // helicopterRTD setBatteryChargeRTD charge
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setBatteryChargeRTD _p1;
        _result = true;
    };
    case "setbatteryrtd": {
        // helicopterRTD setBatteryRTD enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setBatteryRTD _p1;
        _result = true;
    };
    case "setbehaviour": {
        // groupOrUnit setBehaviour behaviour
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setBehaviour _p1;
        _result = true;
    };
    case "setbehaviourstrong": {
        // groupName setBehaviourStrong behaviour
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setBehaviourStrong _p1;
        _result = true;
    };
    case "setbleedingremaining": {
        // unit setBleedingRemaining time
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setBleedingRemaining _p1;
        _result = true;
    };
    case "setbrakesrtd": {
        // helicopterRTD setBrakesRTD [value, wheelIndex]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setBrakesRTD [_p1, _p2];
        _result = true;
    };
    case "setcameraeffect": {
        // triggerOrWaypoint setCameraEffect [type, position]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setCameraEffect [_p1, _p2];
        _result = true;
    };
    case "setcamerainterest": {
        // entity setCameraInterest interest
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setCameraInterest _p1;
        _result = true;
    };
    case "setcamshakedefparams": {
        // setCamShakeDefParams [power, duration, frequency, minSpeed, minMass, caliberCoefHit, vehicleCoef]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        setCamShakeDefParams [_p0, _p1, _p2, _p3, _p4, _p5, _p6];
        _result = true;
    };
    case "setcamshakeparams": {
        // setCamShakeParams  [posCoef, vertCoef, horzCoef, bankCoef, interpolation]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        setCamShakeParams  [_p0, _p1, _p2, _p3, _p4];
        _result = true;
    };
    case "setcamuseti": {
        // state setCamUseTI modeIndex
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setCamUseTI _p1;
        _result = true;
    };
    case "setcaptive": {
        // unitName setCaptive status
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setCaptive _p1;
        _result = true;
    };
    case "setcaptive": {
        // unitName setCaptive statusNumber
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setCaptive _p1;
        _result = true;
    };
    case "setcenterofmass": {
        // myObject setCenterOfMass [centerOfMass, time]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setCenterOfMass [_p1, _p2];
        _result = true;
    };
    case "setcenterofmass": {
        // myObject setCenterOfMass centerOfMass
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setCenterOfMass _p1;
        _result = true;
    };
    case "setcollisionlight": {
        // vehicle setCollisionLight set
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setCollisionLight _p1;
        _result = true;
    };
    case "setcombatbehaviour": {
        // unit setCombatBehaviour behaviour
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setCombatBehaviour _p1;
        _result = true;
    };
    case "setcombatbehaviour": {
        // group setCombatBehaviour behaviour
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setCombatBehaviour _p1;
        _result = true;
    };
    case "setcombatmode": {
        // group setCombatMode mode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setCombatMode _p1;
        _result = true;
    };
    case "setcompassoscillation": {
        // setCompassOscillation [angle, frequencyMin, frequencyMax]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        setCompassOscillation [_p0, _p1, _p2];
        _result = true;
    };
    case "setconvoyseparation": {
        // vehicle setConvoySeparation distance
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setConvoySeparation _p1;
        _result = true;
    };
    case "setcruisecontrol": {
        // vehicle setCruiseControl [speed, autoThrust]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setCruiseControl [_p1, _p2];
        _result = true;
    };
    case "setcuratorcameraareaceiling": {
        // curatorObj setCuratorCameraAreaCeiling height
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setCuratorCameraAreaCeiling _p1;
        _result = true;
    };
    case "setcuratorcoef": {
        // curatorObj setCuratorCoef [action, coef]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setCuratorCoef [_p1, _p2];
        _result = true;
    };
    case "setcuratoreditingareatype": {
        // curatorObj setCuratorEditingAreaType bool
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setCuratorEditingAreaType _p1;
        _result = true;
    };
    case "setcuratorselected": {
        // setCuratorSelected items
        private _p0 = _args param [0];
        setCuratorSelected _p0;
        _result = true;
    };
    case "setcuratorselectionpreset": {
        // numkey setCuratorSelectionPreset objects
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setCuratorSelectionPreset _p1;
        _result = true;
    };
    case "setcuratorwaypointcost": {
        // curatorObj setCuratorWaypointCost cost
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setCuratorWaypointCost _p1;
        _result = true;
    };
    case "setcurrentchannel": {
        // setCurrentChannel channelID
        private _p0 = _args param [0];
        _result = setCurrentChannel _p0;
    };
    case "setcurrenttask": {
        // object setCurrentTask task
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setCurrentTask _p1;
        _result = true;
    };
    case "setcurrentwaypoint": {
        // groupName setCurrentWaypoint waypoint
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setCurrentWaypoint _p1;
        _result = true;
    };
    case "setcustomaimcoef": {
        // unit setCustomAimCoef coef
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setCustomAimCoef _p1;
        _result = true;
    };
    case "setcustommissiondata": {
        // setCustomMissionData data
        private _p0 = _args param [0];
        setCustomMissionData _p0;
        _result = true;
    };
    case "setcustomsoundcontroller": {
        // setCustomSoundController [vehicle, controller, value]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = setCustomSoundController [_p0, _p1, _p2];
    };
    case "setcustomweightrtd": {
        // helicopterRTD setCustomWeightRTD weight
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setCustomWeightRTD _p1;
        _result = true;
    };
    case "setdamage": {
        // object setDamage damage
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setDamage _p1;
        _result = true;
    };
    case "setdamage": {
        // object setDamage [damage, useEffects, killer, instigator]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _p0 setDamage [_p1, _p2, _p3, _p4];
        _result = true;
    };
    case "setdammage": {
        // object setDammage damage
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setDammage _p1;
        _result = true;
    };
    case "setdate": {
        // setDate date
        private _p0 = _args param [0];
        setDate _p0;
        _result = true;
    };
    case "setdebriefingtext": {
        // endType setDebriefingText [title, description]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setDebriefingText [_p1, _p2];
        _result = true;
    };
    case "setdefaultcamera": {
        // setDefaultCamera [position, direction]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        setDefaultCamera [_p0, _p1];
        _result = true;
    };
    case "setdestination": {
        // object setDestination [position, planningMode, forceReplan]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 setDestination [_p1, _p2, _p3];
        _result = true;
    };
    case "setdetailmapblendpars": {
        // setDetailMapBlendPars [fullDetail, noDetail]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        setDetailMapBlendPars [_p0, _p1];
        _result = true;
    };
    case "setdiaryrecordtext": {
        // unit setDiaryRecordText [[subject, diaryRecord], [title, text, icon]]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _p0 setDiaryRecordText [[_p1, _p2], [_p3, _p4, _p5]];
        _result = true;
    };
    case "setdiarysubjectpicture": {
        // unit setDiarySubjectPicture [subject, picture]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setDiarySubjectPicture [_p1, _p2];
        _result = true;
    };
    case "setdir": {
        // object setDir heading
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setDir _p1;
        _result = true;
    };
    case "setdirection": {
        // location setDirection direction
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setDirection _p1;
        _result = true;
    };
    case "setdriveonpath": {
        // vehicleName setDriveOnPath points
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setDriveOnPath _p1;
        _result = true;
    };
    case "setdropinterval": {
        // particleSource setDropInterval interval
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setDropInterval _p1;
        _result = true;
    };
    case "setdynamicsimulationdistance": {
        // category setDynamicSimulationDistance distance
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setDynamicSimulationDistance _p1;
        _result = true;
    };
    case "setdynamicsimulationdistancecoef": {
        // class setDynamicSimulationDistanceCoef multiplier
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setDynamicSimulationDistanceCoef _p1;
        _result = true;
    };
    case "seteditormode": {
        // map setEditorMode mode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setEditorMode _p1;
        _result = true;
    };
    case "seteffectcondition": {
        // trigger setEffectCondition statement
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setEffectCondition _p1;
        _result = true;
    };
    case "seteffectcondition": {
        // waypoint setEffectCondition statement
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setEffectCondition _p1;
        _result = true;
    };
    case "seteffectivecommander": {
        // vehicle setEffectiveCommander person
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setEffectiveCommander _p1;
        _result = true;
    };
    case "setenginerpmrtd": {
        // helicopter setEngineRpmRTD [rpm, engineIndex]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setEngineRpmRTD [_p1, _p2];
        _result = true;
    };
    case "setface": {
        // person setFace face
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setFace _p1;
        _result = true;
    };
    case "setfaceanimation": {
        // unit setFaceAnimation blink
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setFaceAnimation _p1;
        _result = true;
    };
    case "setfatigue": {
        // unit setFatigue value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setFatigue _p1;
        _result = true;
    };
    case "setfeaturetype": {
        // object setFeatureType type
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 setFeatureType _p1;
    };
    case "setflaganimationphase": {
        // flag setFlagAnimationPhase phase
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setFlagAnimationPhase _p1;
        _result = true;
    };
    case "setflagowner": {
        // flag setFlagOwner owner
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setFlagOwner _p1;
        _result = true;
    };
    case "setflagside": {
        // flag setFlagSide side
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setFlagSide _p1;
        _result = true;
    };
    case "setflagtexture": {
        // flag setFlagTexture texture
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setFlagTexture _p1;
        _result = true;
    };
    case "setfog": {
        // time setFog fog
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setFog _p1;
        _result = true;
    };
    case "setfog": {
        // time setFog [fogValue, fogDecay, fogBase]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 setFog [_p1, _p2, _p3];
        _result = true;
    };
    case "setforcegeneratorrtd": {
        // value setForceGeneratorRTD arr
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setForceGeneratorRTD _p1;
        _result = true;
    };
    case "setformation": {
        // group setFormation formation
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setFormation _p1;
        _result = true;
    };
    case "setformationtask": {
        // unit setFormationTask task
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setFormationTask _p1;
        _result = true;
    };
    case "setformdir": {
        // group setFormDir heading
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setFormDir _p1;
        _result = true;
    };
    case "setfriend": {
        // side1 setFriend [side2, value]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setFriend [_p1, _p2];
        _result = true;
    };
    case "setfromeditor": {
        // teamMember setFromEditor fromEditor
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setFromEditor _p1;
        _result = true;
    };
    case "setfsmvariable": {
        // handle setFSMVariable [name, value]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setFSMVariable [_p1, _p2];
        _result = true;
    };
    case "setfuel": {
        // vehicle setFuel amount
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setFuel _p1;
        _result = true;
    };
    case "setfuelcargo": {
        // vehicle setFuelCargo amount
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setFuelCargo _p1;
        _result = true;
    };
    case "setgroupicon": {
        // group setGroupIcon [id, icon, offset]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 setGroupIcon [_p1, _p2, _p3];
        _result = true;
    };
    case "setgroupiconparams": {
        // group setGroupIconParams properties
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setGroupIconParams _p1;
        _result = true;
    };
    case "setgroupiconsselectable": {
        // setGroupIconsSelectable selectable
        private _p0 = _args param [0];
        setGroupIconsSelectable _p0;
        _result = true;
    };
    case "setgroupiconsvisible": {
        // setGroupIconsVisible [showOnMap, showOnHUD]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        setGroupIconsVisible [_p0, _p1];
        _result = true;
    };
    case "setgroupid": {
        // group setGroupId [nameFormat, nameParam1, ..., nameParamN]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setGroupId [_p1, _p2, ..., nameParamN];
        _result = true;
    };
    case "setgroupowner": {
        // group setGroupOwner clientID
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 setGroupOwner _p1;
    };
    case "setgusts": {
        // time setGusts value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setGusts _p1;
        _result = true;
    };
    case "sethidebehind": {
        // object setHideBehind [objectWhereHide, hidePosition]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setHideBehind [_p1, _p2];
        _result = true;
    };
    case "sethit": {
        // object setHit [part, damage, useEffects, killer, instigator]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _p0 setHit [_p1, _p2, _p3, _p4, _p5];
        _result = true;
    };
    case "sethitindex": {
        // vehicle setHitIndex [hitPartIndex, damage, useEffects, killer, instigator]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _p0 setHitIndex [_p1, _p2, _p3, _p4, _p5];
        _result = true;
    };
    case "sethitpointdamage": {
        // vehicle setHitPointDamage [hitPointName, damage, useEffects, killer, instigator]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _p0 setHitPointDamage [_p1, _p2, _p3, _p4, _p5];
        _result = true;
    };
    case "sethorizonparallaxcoef": {
        // setHorizonParallaxCoef coef
        private _p0 = _args param [0];
        setHorizonParallaxCoef _p0;
        _result = true;
    };
    case "sethudmovementlevels": {
        // setHUDMovementLevels [minSpeed, maxSpeed, minAlt, maxAlt, minDir, maxDir, targetOrPosition]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        setHUDMovementLevels [_p0, _p1, _p2, _p3, _p4, _p5, _p6];
        _result = true;
    };
    case "sethumidity": {
        // setHumidity humidity
        private _p0 = _args param [0];
        setHumidity _p0;
        _result = true;
    };
    case "setidentity": {
        // person setIdentity identity
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setIdentity _p1;
        _result = true;
    };
    case "setimportance": {
        // location setImportance value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setImportance _p1;
        _result = true;
    };
    case "setleader": {
        // team setLeader leader
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setLeader _p1;
        _result = true;
    };
    case "setlightambient": {
        // light setLightAmbient color
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setLightAmbient _p1;
        _result = true;
    };
    case "setlightattenuation": {
        // light setLightAttenuation [start, constant, linear, quadratic, hardlimitstart, hardlimitend]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        _p0 setLightAttenuation [_p1, _p2, _p3, _p4, _p5, _p6];
        _result = true;
    };
    case "setlightbrightness": {
        // light setLightBrightness brightness
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setLightBrightness _p1;
        _result = true;
    };
    case "setlightcolor": {
        // light setLightColor [r, g, b]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 setLightColor [_p1, _p2, _p3];
        _result = true;
    };
    case "setlightconepars": {
        // lightReflector setLightConePars [outerAngle, innerAngle, fadeCoef]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 setLightConePars [_p1, _p2, _p3];
        _result = true;
    };
    case "setlightdaylight": {
        // light setLightDayLight bool
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setLightDayLight _p1;
        _result = true;
    };
    case "setlightflaremaxdistance": {
        // light setLightFlareMaxDistance distance
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setLightFlareMaxDistance _p1;
        _result = true;
    };
    case "setlightflaresize": {
        // light setLightFlareSize size
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setLightFlareSize _p1;
        _result = true;
    };
    case "setlightintensity": {
        // light setLightIntensity value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setLightIntensity _p1;
        _result = true;
    };
    case "setlightir": {
        // light setLightIR value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setLightIR _p1;
        _result = true;
    };
    case "setlightnings": {
        // time setLightnings value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setLightnings _p1;
        _result = true;
    };
    case "setlightuseflare": {
        // light setLightUseFlare bool
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setLightUseFlare _p1;
        _result = true;
    };
    case "setlightvolumeshape": {
        // lightReflector setLightVolumeShape [shapePath, scale]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setLightVolumeShape [_p1, _p2];
        _result = true;
    };
    case "setlocalwindparams": {
        // setLocalWindParams [strength, diameter]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        setLocalWindParams [_p0, _p1];
        _result = true;
    };
    case "setmarkeralpha": {
        // marker setMarkerAlpha alpha
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMarkerAlpha _p1;
        _result = true;
    };
    case "setmarkeralphalocal": {
        // marker setMarkerAlphaLocal alpha
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMarkerAlphaLocal _p1;
        _result = true;
    };
    case "setmarkerbrush": {
        // markerName setMarkerBrush brush
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMarkerBrush _p1;
        _result = true;
    };
    case "setmarkerbrushlocal": {
        // markerName setMarkerBrushLocal brush
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMarkerBrushLocal _p1;
        _result = true;
    };
    case "setmarkercolor": {
        // markerName setMarkerColor color
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMarkerColor _p1;
        _result = true;
    };
    case "setmarkercolorlocal": {
        // markerName setMarkerColorLocal color
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMarkerColorLocal _p1;
        _result = true;
    };
    case "setmarkerdir": {
        // markerName setMarkerDir angle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMarkerDir _p1;
        _result = true;
    };
    case "setmarkerdirlocal": {
        // markerName setMarkerDirLocal angle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMarkerDirLocal _p1;
        _result = true;
    };
    case "setmarkerpolyline": {
        // marker setMarkerPolyline path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMarkerPolyline _p1;
        _result = true;
    };
    case "setmarkerpolylinelocal": {
        // marker setMarkerPolylineLocal path
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMarkerPolylineLocal _p1;
        _result = true;
    };
    case "setmarkerpos": {
        // markerName setMarkerPos pos
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMarkerPos _p1;
        _result = true;
    };
    case "setmarkerposlocal": {
        // markerName setMarkerPosLocal pos
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMarkerPosLocal _p1;
        _result = true;
    };
    case "setmarkershadow": {
        // marker setMarkerShadow shadowState
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMarkerShadow _p1;
        _result = true;
    };
    case "setmarkershadowlocal": {
        // marker setMarkerShadowLocal shadowState
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMarkerShadowLocal _p1;
        _result = true;
    };
    case "setmarkershape": {
        // markerName setMarkerShape shape
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMarkerShape _p1;
        _result = true;
    };
    case "setmarkershapelocal": {
        // markerName setMarkerShapeLocal shape
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMarkerShapeLocal _p1;
        _result = true;
    };
    case "setmarkersizelocal": {
        // markerName setMarkerSizeLocal [axisA, axisB]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setMarkerSizeLocal [_p1, _p2];
        _result = true;
    };
    case "setmarkertext": {
        // markerName setMarkerText text
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMarkerText _p1;
        _result = true;
    };
    case "setmarkertextlocal": {
        // markerName setMarkerTextLocal text
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMarkerTextLocal _p1;
        _result = true;
    };
    case "setmarkertype": {
        // markerName setMarkerType type
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMarkerType _p1;
        _result = true;
    };
    case "setmarkertypelocal": {
        // markerName setMarkerTypeLocal type
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMarkerTypeLocal _p1;
        _result = true;
    };
    case "setmass": {
        // myObject setMass mass
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMass _p1;
        _result = true;
    };
    case "setmass": {
        // myObject setMass [mass, time]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setMass [_p1, _p2];
        _result = true;
    };
    case "setmaxload": {
        // container setMaxLoad maxLoadValue
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMaxLoad _p1;
        _result = true;
    };
    case "setmimic": {
        // person setMimic mimic
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMimic _p1;
        _result = true;
    };
    case "setmissiletarget": {
        // munition setMissileTarget target
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 setMissileTarget _p1;
    };
    case "setmissiletargetpos": {
        // munition setMissileTargetPos position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMissileTargetPos _p1;
        _result = true;
    };
    case "setmouseposition": {
        // setMousePosition [x, y]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        setMousePosition [_p0, _p1];
        _result = true;
    };
    case "setmusiceffect": {
        // trigger setMusicEffect track
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMusicEffect _p1;
        _result = true;
    };
    case "setmusiceffect": {
        // waypoint setMusicEffect track
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setMusicEffect _p1;
        _result = true;
    };
    case "setmusiceventhandler": {
        // setMusicEventHandler [type, function]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = setMusicEventHandler [_p0, _p1];
    };
    case "setname": {
        // unit setName name
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setName _p1;
        _result = true;
    };
    case "setname": {
        // unit setName [name, firstName, lastName]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 setName [_p1, _p2, _p3];
        _result = true;
    };
    case "setname": {
        // location setName name
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setName _p1;
        _result = true;
    };
    case "setnamesound": {
        // person setNameSound name
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setNameSound _p1;
        _result = true;
    };
    case "setobjectmaterial": {
        // obj setObjectMaterial [selectionNumber, material]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setObjectMaterial [_p1, _p2];
        _result = true;
    };
    case "setobjectmaterialglobal": {
        // obj setObjectMaterialGlobal [selection, material]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setObjectMaterialGlobal [_p1, _p2];
        _result = true;
    };
    case "setobjectproxy": {
        // map setObjectProxy [object, proxy]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setObjectProxy [_p1, _p2];
        _result = true;
    };
    case "setobjectscale": {
        // object setObjectScale scale
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setObjectScale _p1;
        _result = true;
    };
    case "setobjecttexture": {
        // object setObjectTexture [selection, texture]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setObjectTexture [_p1, _p2];
        _result = true;
    };
    case "setobjecttextureglobal": {
        // object setObjectTextureGlobal [selection, texture]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setObjectTextureGlobal [_p1, _p2];
        _result = true;
    };
    case "setobjectviewdistance": {
        // setObjectViewDistance objectDistance
        private _p0 = _args param [0];
        setObjectViewDistance _p0;
        _result = true;
    };
    case "setobjectviewdistance": {
        // setObjectViewDistance [objectDistance, shadowDistance]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        setObjectViewDistance [_p0, _p1];
        _result = true;
    };
    case "setopticsmode": {
        // unit setOpticsMode mode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setOpticsMode _p1;
        _result = true;
    };
    case "setovercast": {
        // time setOvercast overcast
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setOvercast _p1;
        _result = true;
    };
    case "setowner": {
        // object setOwner clientID
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 setOwner _p1;
    };
    case "setoxygenremaining": {
        // unit setOxygenRemaining value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setOxygenRemaining _p1;
        _result = true;
    };
    case "setparticleclass": {
        // source setParticleClass className
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setParticleClass _p1;
        _result = true;
    };
    case "setparticlefire": {
        // source setParticleFire [coreIntensity, coreDistance, damageTime]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 setParticleFire [_p1, _p2, _p3];
        _result = true;
    };
    case "setparticleparams": {
        // particleSource setParticleParams array
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setParticleParams _p1;
        _result = true;
    };
    case "setparticlerandom": {
        // particleSource setParticleRandom [lifeTime, position, moveVelocity, rotationVelocity, size, color, directionPeriod, directionIntensity, angle, bounceOnSurface]
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
        _p0 setParticleRandom [_p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8, _p9, _p10];
        _result = true;
    };
    case "setpilotcameradirection": {
        // object setPilotCameraDirection Vector3D
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setPilotCameraDirection _p1;
        _result = true;
    };
    case "setpilotcamerarotation": {
        // object setPilotCameraRotation rotation
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setPilotCameraRotation _p1;
        _result = true;
    };
    case "setpilotcameratarget": {
        // object setPilotCameraTarget target
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 setPilotCameraTarget _p1;
    };
    case "setpilotlight": {
        // vehicle setPilotLight set
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setPilotLight _p1;
        _result = true;
    };
    case "setpipeffect": {
        // name setPiPEffect [effect, optionalParam1, ..., optionalParamN]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setPiPEffect [_p1, _p2, ..., optionalParamN];
        _result = true;
    };
    case "setpipviewdistance": {
        // setPiPViewDistance distance
        private _p0 = _args param [0];
        setPiPViewDistance _p0;
        _result = true;
    };
    case "setpitch": {
        // person setPitch pitch
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setPitch _p1;
        _result = true;
    };
    case "setplatenumber": {
        // vehicle setPlateNumber string
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setPlateNumber _p1;
        _result = true;
    };
    case "setplayable": {
        // setPlayable unitName
        private _p0 = _args param [0];
        setPlayable _p0;
        _result = true;
    };
    case "setplayerrespawntime": {
        // setPlayerRespawnTime interval
        private _p0 = _args param [0];
        setPlayerRespawnTime _p0;
        _result = true;
    };
    case "setplayervonvolume": {
        // unit setPlayerVoNVolume volume
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setPlayerVoNVolume _p1;
        _result = true;
    };
    case "setpos": {
        // object setPos pos
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setPos _p1;
        _result = true;
    };
    case "setposasl": {
        // object setPosASL pos
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setPosASL _p1;
        _result = true;
    };
    case "setposasl2": {
        // obj setPosASL2 pos
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setPosASL2 _p1;
        _result = true;
    };
    case "setposaslw": {
        // obj setPosASLW pos
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setPosASLW _p1;
        _result = true;
    };
    case "setposatl": {
        // object setPosATL pos
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setPosATL _p1;
        _result = true;
    };
    case "setposition": {
        // location setPosition pos
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setPosition _p1;
        _result = true;
    };
    case "setposworld": {
        // object setPosWorld position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setPosWorld _p1;
        _result = true;
    };
    case "setpylonloadout": {
        // vehicle setPylonLoadout [pylon, magazine, forced, turret]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = _p0 setPylonLoadout [_p1, _p2, _p3, _p4];
    };
    case "setpylonspriority": {
        // vehicle setPylonsPriority priorities
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setPylonsPriority _p1;
        _result = true;
    };
    case "setradiomsg": {
        // index setRadioMsg text
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setRadioMsg _p1;
        _result = true;
    };
    case "setrain": {
        // time setRain rain
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setRain _p1;
        _result = true;
    };
    case "setrain": {
        // setRain rainParams
        private _p0 = _args param [0];
        setRain _p0;
        _result = true;
    };
    case "setrain": {
        // setRain config
        private _p0 = _args param [0];
        setRain _p0;
        _result = true;
    };
    case "setrainbow": {
        // time setRainbow value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setRainbow _p1;
        _result = true;
    };
    case "setrandomlip": {
        // unit setRandomLip bool
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setRandomLip _p1;
        _result = true;
    };
    case "setrank": {
        // unitName setRank rank
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setRank _p1;
        _result = true;
    };
    case "setrectangular": {
        // location setRectangular set
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setRectangular _p1;
        _result = true;
    };
    case "setrepaircargo": {
        // vehicleName setRepairCargo amount
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setRepairCargo _p1;
        _result = true;
    };
    case "setrotorbrakertd": {
        // helicopterRTD setRotorBrakeRTD enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setRotorBrakeRTD _p1;
        _result = true;
    };
    case "setshadowdistance": {
        // setShadowDistance value
        private _p0 = _args param [0];
        setShadowDistance _p0;
        _result = true;
    };
    case "setshotparents": {
        // projectile setShotParents [vehicle, instigator]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setShotParents [_p1, _p2];
        _result = true;
    };
    case "setside": {
        // location setSide side
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setSide _p1;
        _result = true;
    };
    case "setsimpletaskalwaysvisible": {
        // taskID setSimpleTaskAlwaysVisible state
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setSimpleTaskAlwaysVisible _p1;
        _result = true;
    };
    case "setsimpletaskdescription": {
        // task setSimpleTaskDescription [description, descriptionShort, descriptionHUD]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 setSimpleTaskDescription [_p1, _p2, _p3];
        _result = true;
    };
    case "setsimpletaskdestination": {
        // task setSimpleTaskDestination pos
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setSimpleTaskDestination _p1;
        _result = true;
    };
    case "setsimpletasktarget": {
        // task setSimpleTaskTarget [target, precisePosition]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setSimpleTaskTarget [_p1, _p2];
        _result = true;
    };
    case "setsimpletasktype": {
        // task setSimpleTaskType taskType
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setSimpleTaskType _p1;
        _result = true;
    };
    case "setsimulweatherlayers": {
        // setSimulWeatherLayers layers
        private _p0 = _args param [0];
        setSimulWeatherLayers _p0;
        _result = true;
    };
    case "setsize": {
        // location setSize size
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setSize _p1;
        _result = true;
    };
    case "setskill": {
        // unit setSkill skill
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setSkill _p1;
        _result = true;
    };
    case "setskill": {
        // unit setSkill [skillName, value]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setSkill [_p1, _p2];
        _result = true;
    };
    case "setslingload": {
        // heli setSlingLoad cargo
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 setSlingLoad _p1;
    };
    case "setsoundeffect": {
        // trigger setSoundEffect [sound, voice, soundEnv, soundDet]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _p0 setSoundEffect [_p1, _p2, _p3, _p4];
        _result = true;
    };
    case "setsoundeffect": {
        // waypoint setSoundEffect [sound, voice]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setSoundEffect [_p1, _p2];
        _result = true;
    };
    case "setspeaker": {
        // person setSpeaker speaker
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setSpeaker _p1;
        _result = true;
    };
    case "setspeech": {
        // location setSpeech speech
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setSpeech _p1;
        _result = true;
    };
    case "setspeedmode": {
        // groupName setSpeedMode mode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setSpeedMode _p1;
        _result = true;
    };
    case "setstamina": {
        // unit setStamina stamina
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setStamina _p1;
        _result = true;
    };
    case "setstaminascheme": {
        // setStaminaScheme scheme
        private _p0 = _args param [0];
        setStaminaScheme _p0;
        _result = true;
    };
    case "setstarterrtd": {
        // helicopterRTD setStarterRTD [enable, engineIndex]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setStarterRTD [_p1, _p2];
        _result = true;
    };
    case "setstatvalue": {
        // setStatValue [name, value]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = setStatValue [_p0, _p1];
    };
    case "setsuppression": {
        // unit setSuppression value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setSuppression _p1;
        _result = true;
    };
    case "setsystemofunits": {
        // setSystemOfUnits value
        private _p0 = _args param [0];
        setSystemOfUnits _p0;
        _result = true;
    };
    case "settargetage": {
        // object setTargetAge age
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setTargetAge _p1;
        _result = true;
    };
    case "settaskmarkeroffset": {
        // obj setTaskState position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setTaskState _p1;
        _result = true;
    };
    case "settaskstate": {
        // task setTaskState state
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setTaskState _p1;
        _result = true;
    };
    case "setterraingrid": {
        // setTerrainGrid grid
        private _p0 = _args param [0];
        setTerrainGrid _p0;
        _result = true;
    };
    case "setterrainheight": {
        // setTerrainHeight [positionAndAltitudeArray, adjustObjects]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        setTerrainHeight [_p0, _p1];
        _result = true;
    };
    case "settext": {
        // location setText text
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setText _p1;
        _result = true;
    };
    case "setthrottlertd": {
        // helicopterRTD setThrottleRTD [value, engineIndex]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setThrottleRTD [_p1, _p2];
        _result = true;
    };
    case "settimemultiplier": {
        // setTimeMultiplier value
        private _p0 = _args param [0];
        setTimeMultiplier _p0;
        _result = true;
    };
    case "settiparameter": {
        // setTIParameter [paramName, newValue]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        setTIParameter [_p0, _p1];
        _result = true;
    };
    case "settitleeffect": {
        // triggerOrWaypoint setTitleEffect [type, effect, text]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 setTitleEffect [_p1, _p2, _p3];
        _result = true;
    };
    case "settonemapping": {
        // setToneMapping toneName
        private _p0 = _args param [0];
        setToneMapping _p0;
        _result = true;
    };
    case "settonemappingparams": {
        // toneName setToneMappingParams params
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setToneMappingParams _p1;
        _result = true;
    };
    case "settowparent": {
        // towedVehicle setTowParent towingVehicle
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setTowParent _p1;
        _result = true;
    };
    case "settrafficdensity": {
        // setTrafficDensity [density, xMin, xMax, zMin, zMax]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        setTrafficDensity [_p0, _p1, _p2, _p3, _p4];
        _result = true;
    };
    case "settrafficdistance": {
        // setTrafficDistance distance
        private _p0 = _args param [0];
        setTrafficDistance _p0;
        _result = true;
    };
    case "settrafficgap": {
        // setTrafficGap [gap, xMin, xMax, zMin, zMax]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        setTrafficGap [_p0, _p1, _p2, _p3, _p4];
        _result = true;
    };
    case "settrafficspeed": {
        // setTrafficSpeed [speed, xMin, xMax, zMin, zMax]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        setTrafficSpeed [_p0, _p1, _p2, _p3, _p4];
        _result = true;
    };
    case "settriggeractivation": {
        // trigger setTriggerActivation [by, type, repeating]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 setTriggerActivation [_p1, _p2, _p3];
        _result = true;
    };
    case "settriggerarea": {
        // trigger setTriggerArea [a, b, angle, isRectangle, c]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _p0 setTriggerArea [_p1, _p2, _p3, _p4, _p5];
        _result = true;
    };
    case "settriggerinterval": {
        // trigger setTriggerInterval interval
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setTriggerInterval _p1;
        _result = true;
    };
    case "settriggerstatements": {
        // trigger setTriggerStatements [condition, activation, deactivation]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 setTriggerStatements [_p1, _p2, _p3];
        _result = true;
    };
    case "settriggertext": {
        // trigger setTriggerText text
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setTriggerText _p1;
        _result = true;
    };
    case "settriggertimeout": {
        // trigger setTriggerTimeout [min, mid, max, interruptable]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _p0 setTriggerTimeout [_p1, _p2, _p3, _p4];
        _result = true;
    };
    case "settriggertype": {
        // trigger setTriggerType action
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setTriggerType _p1;
        _result = true;
    };
    case "setturretlimits": {
        // vehicle setTurretLimits [turret, minTurn, maxTurn, minElev, maxElev]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        _p0 setTurretLimits [_p1, _p2, _p3, _p4, _p5];
        _result = true;
    };
    case "setturretopticsmode": {
        // obj setTurretOpticsMode mode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setTurretOpticsMode _p1;
        _result = true;
    };
    case "setturretopticsmode": {
        // obj setTurretOpticsMode [turretPath, opticModeIndex]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setTurretOpticsMode [_p1, _p2];
        _result = true;
    };
    case "settype": {
        // location setType name
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setType _p1;
        _result = true;
    };
    case "setunconscious": {
        // unit setUnconscious set
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setUnconscious _p1;
        _result = true;
    };
    case "setunitability": {
        // unit setUnitAbility value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setUnitAbility _p1;
        _result = true;
    };
    case "setunitcombatmode": {
        // unit setUnitCombatMode mode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setUnitCombatMode _p1;
        _result = true;
    };
    case "setunitfreefallheight": {
        // unit setUnitFreefallHeight minHeight
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setUnitFreefallHeight _p1;
        _result = true;
    };
    case "setunitloadout": {
        // unit setUnitLoadout loadout
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setUnitLoadout _p1;
        _result = true;
    };
    case "setunitloadout": {
        // unit setUnitLoadout [loadout, fullMagazines]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setUnitLoadout [_p1, _p2];
        _result = true;
    };
    case "setunitloadout": {
        // unit setUnitLoadout name
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setUnitLoadout _p1;
        _result = true;
    };
    case "setunitloadout": {
        // unit setUnitLoadout config
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setUnitLoadout _p1;
        _result = true;
    };
    case "setunitpos": {
        // unit setUnitPos mode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setUnitPos _p1;
        _result = true;
    };
    case "setunitposweak": {
        // unit setUnitPosWeak mode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setUnitPosWeak _p1;
        _result = true;
    };
    case "setunitrank": {
        // unitName setUnitRank rank
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setUnitRank _p1;
        _result = true;
    };
    case "setunitrecoilcoefficient": {
        // unitName setUnitRecoilCoefficient coefficient
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setUnitRecoilCoefficient _p1;
        _result = true;
    };
    case "setunloadincombat": {
        // vehicle setUnloadInCombat [allowCargo, allowTurrets]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setUnloadInCombat [_p1, _p2];
        _result = true;
    };
    case "setuseractiontext": {
        // object setUserActionText [actionIndex, textMenu, textWindowBackground, textWindowForeground]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _p0 setUserActionText [_p1, _p2, _p3, _p4];
        _result = true;
    };
    case "setusermfdtext": {
        // vehicle setUserMFDText [index, value]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setUserMFDText [_p1, _p2];
        _result = true;
    };
    case "setusermfdvalue": {
        // vehicle setUserMFDValue [index, value]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setUserMFDValue [_p1, _p2];
        _result = true;
    };
    case "setvectordir": {
        // object setVectorDir vectorDir
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setVectorDir _p1;
        _result = true;
    };
    case "setvectordirandup": {
        // vehicle setVectorDirAndUp [vectorDir, vectorUp]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setVectorDirAndUp [_p1, _p2];
        _result = true;
    };
    case "setvectorup": {
        // object setVectorUp vectorUp
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setVectorUp _p1;
        _result = true;
    };
    case "setvehicleammo": {
        // vehicleName setVehicleAmmo value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setVehicleAmmo _p1;
        _result = true;
    };
    case "setvehicleammodef": {
        // unit setVehicleAmmoDef value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setVehicleAmmoDef _p1;
        _result = true;
    };
    case "setvehiclearmor": {
        // vehicleName setVehicleArmor value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setVehicleArmor _p1;
        _result = true;
    };
    case "setvehiclecargo": {
        // vehicle setVehicleCargo cargo
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 setVehicleCargo _p1;
    };
    case "setvehicleid": {
        // vehicleName setVehicleId id
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setVehicleId _p1;
        _result = true;
    };
    case "setvehicleinit": {
        // unitName setVehicleInit statement
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setVehicleInit _p1;
        _result = true;
    };
    case "setvehiclelock": {
        // vehicleName setVehicleLock lockState
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setVehicleLock _p1;
        _result = true;
    };
    case "setvehicleposition": {
        // object setVehiclePosition [position, markers, placement, special]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = _p0 setVehiclePosition [_p1, _p2, _p3, _p4];
    };
    case "setvehicleradar": {
        // vehicle setVehicleRadar rule
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setVehicleRadar _p1;
        _result = true;
    };
    case "setvehiclereceiveremotetargets": {
        // vehicle setVehicleReceiveRemoteTargets bool
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setVehicleReceiveRemoteTargets _p1;
        _result = true;
    };
    case "setvehiclereportownposition": {
        // vehicle setVehicleReportOwnPosition report
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setVehicleReportOwnPosition _p1;
        _result = true;
    };
    case "setvehiclereportremotetargets": {
        // vehicle setVehicleReportRemoteTargets bool
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setVehicleReportRemoteTargets _p1;
        _result = true;
    };
    case "setvehicletipars": {
        // vehicle setVehicleTIPars [engine, wheels, weapon]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 setVehicleTIPars [_p1, _p2, _p3];
        _result = true;
    };
    case "setvehiclevarname": {
        // object setVehicleVarName name
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setVehicleVarName _p1;
        _result = true;
    };
    case "setvelocitymodelspace": {
        // vehicle setVelocityModelSpace velocity
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setVelocityModelSpace _p1;
        _result = true;
    };
    case "setviewdistance": {
        // setViewDistance distance
        private _p0 = _args param [0];
        setViewDistance _p0;
        _result = true;
    };
    case "setwantedrpmrtd": {
        // helicopterRTD setWantedRPMRTD [value, time, engineIndex]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 setWantedRPMRTD [_p1, _p2, _p3];
        _result = true;
    };
    case "setwaves": {
        // time setWaves value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setWaves _p1;
        _result = true;
    };
    case "setwaypointbehaviour": {
        // waypoint setWaypointBehaviour mode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setWaypointBehaviour _p1;
        _result = true;
    };
    case "setwaypointcombatmode": {
        // waypoint setWaypointCombatMode mode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setWaypointCombatMode _p1;
        _result = true;
    };
    case "setwaypointcompletionradius": {
        // waypoint setWaypointCompletionRadius radius
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setWaypointCompletionRadius _p1;
        _result = true;
    };
    case "setwaypointdescription": {
        // waypoint setWaypointDescription text
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setWaypointDescription _p1;
        _result = true;
    };
    case "setwaypointforcebehaviour": {
        // waypoint setWaypointForceBehaviour state
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setWaypointForceBehaviour _p1;
        _result = true;
    };
    case "setwaypointformation": {
        // waypoint setWaypointFormation formation
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setWaypointFormation _p1;
        _result = true;
    };
    case "setwaypointhouseposition": {
        // waypoint setWaypointHousePosition pos
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setWaypointHousePosition _p1;
        _result = true;
    };
    case "setwaypointloiteraltitude": {
        // waypoint setWaypointLoiterAltitude loiterAltitude
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setWaypointLoiterAltitude _p1;
        _result = true;
    };
    case "setwaypointloiterradius": {
        // waypoint setWaypointLoiterRadius radius
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setWaypointLoiterRadius _p1;
        _result = true;
    };
    case "setwaypointloitertype": {
        // waypoint setWaypointLoiterType type
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setWaypointLoiterType _p1;
        _result = true;
    };
    case "setwaypointname": {
        // waypoint setWaypointName name
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setWaypointName _p1;
        _result = true;
    };
    case "setwaypointposition": {
        // waypoint setWaypointPosition [center, radius]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setWaypointPosition [_p1, _p2];
        _result = true;
    };
    case "setwaypointscript": {
        // waypoint setWaypointScript command
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setWaypointScript _p1;
        _result = true;
    };
    case "setwaypointspeed": {
        // waypoint setWaypointSpeed mode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setWaypointSpeed _p1;
        _result = true;
    };
    case "setwaypointstatements": {
        // waypoint setWaypointStatements [condition, statement]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 setWaypointStatements [_p1, _p2];
        _result = true;
    };
    case "setwaypointtimeout": {
        // waypoint setWaypointTimeout [min, mid, max]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 setWaypointTimeout [_p1, _p2, _p3];
        _result = true;
    };
    case "setwaypointtype": {
        // waypoint setWaypointType type
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setWaypointType _p1;
        _result = true;
    };
    case "setwaypointvisible": {
        // waypoint setWaypointVisible visible
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setWaypointVisible _p1;
        _result = true;
    };
    case "setweaponreloadingtime": {
        // vehicle setWeaponReloadingTime [gunner, muzzleName, reloadTime]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = _p0 setWeaponReloadingTime [_p1, _p2, _p3];
    };
    case "setweaponzeroing": {
        // object setWeaponZeroing [weaponClass, muzzleClass, zeroingIndex]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = _p0 setWeaponZeroing [_p1, _p2, _p3];
    };
    case "setwind": {
        // setWind [x, y, forced]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        setWind [_p0, _p1, _p2];
        _result = true;
    };
    case "setwinddir": {
        // time setWindDir value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setWindDir _p1;
        _result = true;
    };
    case "setwinddir": {
        // setWindDir direction
        private _p0 = _args param [0];
        setWindDir _p0;
        _result = true;
    };
    case "setwindforce": {
        // time setWindForce wind
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setWindForce _p1;
        _result = true;
    };
    case "setwindstr": {
        // time setWindStr value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setWindStr _p1;
        _result = true;
    };
    case "setwingforcescalertd": {
        // helicopterRTD setWingForceScaleRTD [leftHorizontal, rightHorizontal, vertical]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 setWingForceScaleRTD [_p1, _p2, _p3];
        _result = true;
    };
    case "setwppos": {
        // waypoint setWPPos pos
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 setWPPos _p1;
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
