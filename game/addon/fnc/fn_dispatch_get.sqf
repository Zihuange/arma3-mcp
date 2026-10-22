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
    case "get": {
        // hashMap get key
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 get _p1;
        _result = true;
    };
    case "get3denactionstate": {
        // get3DENActionState  action
        private _p0 = _args param [0];
        _result = get3DENActionState  _p0;
    };
    case "get3denattribute": {
        // entity get3DENAttribute attribute
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 get3DENAttribute _p1;
        _result = true;
    };
    case "get3denconnections": {
        // get3DENConnections  entity
        private _p0 = _args param [0];
        get3DENConnections  _p0;
        _result = true;
    };
    case "get3denentity": {
        // get3DENEntity  ID
        private _p0 = _args param [0];
        get3DENEntity  _p0;
        _result = true;
    };
    case "get3denentityid": {
        // get3DENEntityID entity
        private _p0 = _args param [0];
        _result = get3DENEntityID _p0;
    };
    case "get3dengrid": {
        // get3DENGrid  type
        private _p0 = _args param [0];
        _result = get3DENGrid  _p0;
    };
    case "get3denlayerentities": {
        // get3DENLayerEntities layerID
        private _p0 = _args param [0];
        get3DENLayerEntities _p0;
        _result = true;
    };
    case "get3denmissionattribute": {
        // section get3DENMissionAttribute class
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 get3DENMissionAttribute _p1;
    };
    case "get3denselected": {
        // get3DENSelected type
        private _p0 = _args param [0];
        _result = get3DENSelected _p0;
    };
    case "getallenv3dsoundcontrollers": {
        // getAllEnv3DSoundControllers object
        private _p0 = _args param [0];
        getAllEnv3DSoundControllers _p0;
        _result = true;
    };
    case "getallenvsoundcontrollers": {
        // getAllEnvSoundControllers position
        private _p0 = _args param [0];
        getAllEnvSoundControllers _p0;
        _result = true;
    };
    case "getallhitpointsdamage": {
        // getAllHitPointsDamage entity
        private _p0 = _args param [0];
        _result = getAllHitPointsDamage _p0;
    };
    case "getallownedmines": {
        // getAllOwnedMines unit
        private _p0 = _args param [0];
        getAllOwnedMines _p0;
        _result = true;
    };
    case "getallpylonsinfo": {
        // getAllPylonsInfo vehicle
        private _p0 = _args param [0];
        getAllPylonsInfo _p0;
        _result = true;
    };
    case "getallsoundcontrollers": {
        // getAllSoundControllers vehicle
        private _p0 = _args param [0];
        getAllSoundControllers _p0;
        _result = true;
    };
    case "getallunittraits": {
        // getAllUnitTraits unit
        private _p0 = _args param [0];
        getAllUnitTraits _p0;
        _result = true;
    };
    case "getammocargo": {
        // getAmmoCargo vehicle
        private _p0 = _args param [0];
        _result = getAmmoCargo _p0;
    };
    case "getanimaimprecision": {
        // getAnimAimPrecision unit
        private _p0 = _args param [0];
        _result = getAnimAimPrecision _p0;
    };
    case "getanimspeedcoef": {
        // getAnimSpeedCoef unit
        private _p0 = _args param [0];
        _result = getAnimSpeedCoef _p0;
    };
    case "getarray": {
        // getArray config
        private _p0 = _args param [0];
        _result = getArray _p0;
    };
    case "getartilleryammo": {
        // getArtilleryAmmo artilleryList
        private _p0 = _args param [0];
        getArtilleryAmmo _p0;
        _result = true;
    };
    case "getartilleryeta": {
        // unit getArtilleryETA  [targetPosition, magazineType]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 getArtilleryETA  [_p1, _p2];
    };
    case "getassetdlcinfo": {
        // getAssetDLCInfo asset
        private _p0 = _args param [0];
        getAssetDLCInfo _p0;
        _result = true;
    };
    case "getassetdlcinfo": {
        // getAssetDLCInfo [class, config]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        getAssetDLCInfo [_p0, _p1];
        _result = true;
    };
    case "getassignedcuratorlogic": {
        // getAssignedCuratorLogic player
        private _p0 = _args param [0];
        _result = getAssignedCuratorLogic _p0;
    };
    case "getassignedcuratorunit": {
        // getAssignedCuratorUnit curatorObj
        private _p0 = _args param [0];
        _result = getAssignedCuratorUnit _p0;
    };
    case "getattacktarget": {
        // getAttackTarget unit
        private _p0 = _args param [0];
        _result = getAttackTarget _p0;
    };
    case "getbackpackcargo": {
        // getBackpackCargo object
        private _p0 = _args param [0];
        getBackpackCargo _p0;
        _result = true;
    };
    case "getbleedingremaining": {
        // getBleedingRemaining unit
        private _p0 = _args param [0];
        _result = getBleedingRemaining _p0;
    };
    case "getburningvalue": {
        // getBurningValue unit
        private _p0 = _args param [0];
        _result = getBurningValue _p0;
    };
    case "getcameraviewdirection": {
        // getCameraViewDirection unit
        private _p0 = _args param [0];
        _result = getCameraViewDirection _p0;
    };
    case "getcargoindex": {
        // vehicle getCargoIndex unit
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 getCargoIndex _p1;
    };
    case "getcenterofmass": {
        // getCenterOfMass object
        private _p0 = _args param [0];
        _result = getCenterOfMass _p0;
    };
    case "getcompatiblepylonmagazines": {
        // vehicle getCompatiblePylonMagazines pylon
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 getCompatiblePylonMagazines _p1;
        _result = true;
    };
    case "getconnecteduav": {
        // getConnectedUAV person
        private _p0 = _args param [0];
        _result = getConnectedUAV _p0;
    };
    case "getconnecteduavunit": {
        // getConnectedUAVUnit person
        private _p0 = _args param [0];
        _result = getConnectedUAVUnit _p0;
    };
    case "getcontainermaxload": {
        // getContainerMaxLoad containerClass
        private _p0 = _args param [0];
        _result = getContainerMaxLoad _p0;
    };
    case "getcorpse": {
        // getCorpse weaponholder
        private _p0 = _args param [0];
        _result = getCorpse _p0;
    };
    case "getcruisecontrol": {
        // getCruiseControl vehicle
        private _p0 = _args param [0];
        getCruiseControl _p0;
        _result = true;
    };
    case "getcustomaimcoef": {
        // getCustomAimCoef unit
        private _p0 = _args param [0];
        _result = getCustomAimCoef _p0;
    };
    case "getcustomsoundcontroller": {
        // getCustomSoundController  [vehicle, controller]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = getCustomSoundController  [_p0, _p1];
    };
    case "getcustomsoundcontrollercount": {
        // getCustomSoundControllerCount vehicle
        private _p0 = _args param [0];
        _result = getCustomSoundControllerCount _p0;
    };
    case "getdammage": {
        // getDammage object
        private _p0 = _args param [0];
        _result = getDammage _p0;
    };
    case "getdebriefingtext": {
        // getDebriefingText end
        private _p0 = _args param [0];
        getDebriefingText _p0;
        _result = true;
    };
    case "getdescription": {
        // getDescription unit
        private _p0 = _args param [0];
        getDescription _p0;
        _result = true;
    };
    case "getdir": {
        // getDir object
        private _p0 = _args param [0];
        _result = getDir _p0;
    };
    case "getdir": {
        // pos1 getDir pos2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 getDir _p1;
    };
    case "getdirvisual": {
        // getDirVisual object
        private _p0 = _args param [0];
        _result = getDirVisual _p0;
    };
    case "getdirvisual": {
        // pos1 getDirVisual pos2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 getDirVisual _p1;
    };
    case "getdiverstate": {
        // getDiverState unit
        private _p0 = _args param [0];
        _result = getDiverState _p0;
    };
    case "getdlcassetsusagebyname": {
        // getDLCAssetsUsageByName assetName
        private _p0 = _args param [0];
        _result = getDLCAssetsUsageByName _p0;
    };
    case "getdlcs": {
        // getDLCs filter
        private _p0 = _args param [0];
        _result = getDLCs _p0;
    };
    case "getdlcusagetime": {
        // getDLCUsageTime appId
        private _p0 = _args param [0];
        _result = getDLCUsageTime _p0;
    };
    case "geteditorcamera": {
        // getEditorCamera map
        private _p0 = _args param [0];
        _result = getEditorCamera _p0;
    };
    case "geteditormode": {
        // getEditorMode map
        private _p0 = _args param [0];
        _result = getEditorMode _p0;
    };
    case "geteditorobjectscope": {
        // map getEditorObjectScope object
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 getEditorObjectScope _p1;
    };
    case "getenginetargetrpmrtd": {
        // getEngineTargetRPMRTD helicopter
        private _p0 = _args param [0];
        _result = getEngineTargetRPMRTD _p0;
    };
    case "getenv3dsoundcontroller": {
        // object getEnv3DSoundController controller
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 getEnv3DSoundController _p1;
    };
    case "getenvsoundcontroller": {
        // position getEnvSoundController controller
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 getEnvSoundController _p1;
    };
    case "geteventhandlerinfo": {
        // oper getEventHandlerInfo [type, id]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 getEventHandlerInfo [_p1, _p2];
        _result = true;
    };
    case "geteventhandlerinfo": {
        // getEventHandlerInfo [type, id]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        getEventHandlerInfo [_p0, _p1];
        _result = true;
    };
    case "getfatigue": {
        // getFatigue unit
        private _p0 = _args param [0];
        _result = getFatigue _p0;
    };
    case "getfieldmanualstartpage": {
        // getFieldManualStartPage display
        private _p0 = _args param [0];
        _result = getFieldManualStartPage _p0;
    };
    case "getforcedflagtexture": {
        // getForcedFlagTexture object
        private _p0 = _args param [0];
        _result = getForcedFlagTexture _p0;
    };
    case "getforcedspeed": {
        // getForcedSpeed entity
        private _p0 = _args param [0];
        _result = getForcedSpeed _p0;
    };
    case "getfriend": {
        // side1 getFriend side2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 getFriend _p1;
    };
    case "getfsmvariable": {
        // FSMhandle getFSMVariable name
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 getFSMVariable _p1;
    };
    case "getfsmvariable": {
        // FSMhandle getFSMVariable [name, defaultValue]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 getFSMVariable [_p1, _p2];
    };
    case "getfuelcargo": {
        // getFuelCargo vehicle
        private _p0 = _args param [0];
        _result = getFuelCargo _p0;
    };
    case "getgroupicon": {
        // group getGroupIcon  id
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 getGroupIcon  _p1;
    };
    case "getgroupiconparams": {
        // getGroupIconParams group
        private _p0 = _args param [0];
        getGroupIconParams _p0;
        _result = true;
    };
    case "getgroupicons": {
        // getGroupIcons group
        private _p0 = _args param [0];
        _result = getGroupIcons _p0;
    };
    case "gethidefrom": {
        // object getHideFrom enemy
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 getHideFrom _p1;
    };
    case "gethit": {
        // vehicle getHit selection
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 getHit _p1;
    };
    case "gethitindex": {
        // vehicle getHitIndex hitPartIndex
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 getHitIndex _p1;
        _result = true;
    };
    case "gethitpointdamage": {
        // vehicle getHitPointDamage hitPointName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 getHitPointDamage _p1;
        _result = true;
    };
    case "getitemcargo": {
        // getItemCargo box
        private _p0 = _args param [0];
        getItemCargo _p0;
        _result = true;
    };
    case "getlightingat": {
        // getLightingAt obj
        private _p0 = _args param [0];
        getLightingAt _p0;
        _result = true;
    };
    case "getmagazinecargo": {
        // getMagazineCargo object
        private _p0 = _args param [0];
        getMagazineCargo _p0;
        _result = true;
    };
    case "getmarkercolor": {
        // getMarkerColor markerName
        private _p0 = _args param [0];
        _result = getMarkerColor _p0;
    };
    case "getmarkerpos": {
        // getMarkerPos markerName
        private _p0 = _args param [0];
        _result = getMarkerPos _p0;
    };
    case "getmarkerpos": {
        // getMarkerPos [markerName, preserveElevation]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = getMarkerPos [_p0, _p1];
    };
    case "getmarkersize": {
        // getMarkerSize markerName
        private _p0 = _args param [0];
        getMarkerSize _p0;
        _result = true;
    };
    case "getmarkertype": {
        // getMarkerType  markerName
        private _p0 = _args param [0];
        _result = getMarkerType  _p0;
    };
    case "getmass": {
        // getMass object
        private _p0 = _args param [0];
        _result = getMass _p0;
    };
    case "getmissionconfig": {
        // getMissionConfig attribute
        private _p0 = _args param [0];
        _result = getMissionConfig _p0;
    };
    case "getmissionconfigvalue": {
        // getMissionConfigValue attribute
        private _p0 = _args param [0];
        getMissionConfigValue _p0;
        _result = true;
    };
    case "getmissionconfigvalue": {
        // getMissionConfigValue  [attribute, defaultValue]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        getMissionConfigValue  [_p0, _p1];
        _result = true;
    };
    case "getmissionlayerentities": {
        // getMissionLayerEntities layerName
        private _p0 = _args param [0];
        getMissionLayerEntities _p0;
        _result = true;
    };
    case "getmissionpath": {
        // getMissionPath filename
        private _p0 = _args param [0];
        _result = getMissionPath _p0;
    };
    case "getmodelinfo": {
        // getModelInfo object
        private _p0 = _args param [0];
        _result = getModelInfo _p0;
    };
    case "getnumber": {
        // getNumber config
        private _p0 = _args param [0];
        _result = getNumber _p0;
    };
    case "getobjectargument": {
        // map getObjectArgument [object, argument]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 getObjectArgument [_p1, _p2];
    };
    case "getobjectchildren": {
        // map getObjectChildren object
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 getObjectChildren _p1;
    };
    case "getobjectdlc": {
        // getObjectDLC obj
        private _p0 = _args param [0];
        getObjectDLC _p0;
        _result = true;
    };
    case "getobjectfov": {
        // getObjectFOV object
        private _p0 = _args param [0];
        _result = getObjectFOV _p0;
    };
    case "getobjectid": {
        // getObjectID object
        private _p0 = _args param [0];
        _result = getObjectID _p0;
    };
    case "getobjectmaterials": {
        // getObjectMaterials obj
        private _p0 = _args param [0];
        getObjectMaterials _p0;
        _result = true;
    };
    case "getobjectproxy": {
        // map getObjectProxy object
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 getObjectProxy _p1;
    };
    case "getobjectscale": {
        // getObjectScale object
        private _p0 = _args param [0];
        _result = getObjectScale _p0;
    };
    case "getobjecttextures": {
        // getObjectTextures obj
        private _p0 = _args param [0];
        getObjectTextures _p0;
        _result = true;
    };
    case "getobjecttype": {
        // getObjectType object
        private _p0 = _args param [0];
        _result = getObjectType _p0;
    };
    case "getopticsmode": {
        // unit getOpticsMode slot
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 getOpticsMode _p1;
    };
    case "getordefault": {
        // hashMap getOrDefault [key, defaultValue, setDefault]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = _p0 getOrDefault [_p1, _p2, _p3];
    };
    case "getordefaultcall": {
        // hashMap getOrDefaultCall [key, code, set]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = _p0 getOrDefaultCall [_p1, _p2, _p3];
    };
    case "getoxygenremaining": {
        // getOxygenRemaining unit
        private _p0 = _args param [0];
        _result = getOxygenRemaining _p0;
    };
    case "getpersonuseddlcs": {
        // getPersonUsedDLCs unit
        private _p0 = _args param [0];
        getPersonUsedDLCs _p0;
        _result = true;
    };
    case "getpilotcameradirection": {
        // getPilotCameraDirection object
        private _p0 = _args param [0];
        _result = getPilotCameraDirection _p0;
    };
    case "getpilotcameraposition": {
        // getPilotCameraPosition object
        private _p0 = _args param [0];
        _result = getPilotCameraPosition _p0;
    };
    case "getpilotcamerarotation": {
        // getPilotCameraRotation object
        private _p0 = _args param [0];
        _result = getPilotCameraRotation _p0;
    };
    case "getpilotcameratarget": {
        // getPilotCameraTarget object
        private _p0 = _args param [0];
        getPilotCameraTarget _p0;
        _result = true;
    };
    case "getplatenumber": {
        // getPlateNumber vehicle
        private _p0 = _args param [0];
        _result = getPlateNumber _p0;
    };
    case "getplayerchannel": {
        // getPlayerChannel player
        private _p0 = _args param [0];
        _result = getPlayerChannel _p0;
    };
    case "getplayerid": {
        // getPlayerID unit
        private _p0 = _args param [0];
        _result = getPlayerID _p0;
    };
    case "getplayeruid": {
        // getPlayerUID unit
        private _p0 = _args param [0];
        getPlayerUID _p0;
        _result = true;
    };
    case "getplayeruidold": {
        // getPlayerUIDOld unit
        private _p0 = _args param [0];
        _result = getPlayerUIDOld _p0;
    };
    case "getplayervonvolume": {
        // getPlayerVoNVolume unit
        private _p0 = _args param [0];
        getPlayerVoNVolume _p0;
        _result = true;
    };
    case "getpos": {
        // getPos object
        private _p0 = _args param [0];
        getPos _p0;
        _result = true;
    };
    case "getpos": {
        // getPos location
        private _p0 = _args param [0];
        getPos _p0;
        _result = true;
    };
    case "getpos": {
        // origin getPos [distance, heading]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 getPos [_p1, _p2];
    };
    case "getposasl": {
        // getPosASL object
        private _p0 = _args param [0];
        _result = getPosASL _p0;
    };
    case "getposaslvisual": {
        // getPosASLVisual object
        private _p0 = _args param [0];
        getPosASLVisual _p0;
        _result = true;
    };
    case "getposaslw": {
        // getPosASLW obj
        private _p0 = _args param [0];
        _result = getPosASLW _p0;
    };
    case "getposatl": {
        // getPosATL object
        private _p0 = _args param [0];
        _result = getPosATL _p0;
    };
    case "getposatlvisual": {
        // getPosATLVisual object
        private _p0 = _args param [0];
        getPosATLVisual _p0;
        _result = true;
    };
    case "getposvisual": {
        // getPosVisual object
        private _p0 = _args param [0];
        _result = getPosVisual _p0;
    };
    case "getposworld": {
        // getPosWorld object
        private _p0 = _args param [0];
        getPosWorld _p0;
        _result = true;
    };
    case "getposworldvisual": {
        // getPosWorldVisual object
        private _p0 = _args param [0];
        _result = getPosWorldVisual _p0;
    };
    case "getpylonmagazines": {
        // getPylonMagazines  vehicle
        private _p0 = _args param [0];
        getPylonMagazines  _p0;
        _result = true;
    };
    case "getreldir": {
        // object getRelDir position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 getRelDir _p1;
    };
    case "getrelpos": {
        // object getRelPos  [distance, direction]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 getRelPos  [_p1, _p2];
        _result = true;
    };
    case "getrepaircargo": {
        // getRepairCargo vehicle
        private _p0 = _args param [0];
        _result = getRepairCargo _p0;
    };
    case "getroadinfo": {
        // getRoadInfo road
        private _p0 = _args param [0];
        getRoadInfo _p0;
        _result = true;
    };
    case "getrotorbrakertd": {
        // getRotorBrakeRTD helicopter
        private _p0 = _args param [0];
        _result = getRotorBrakeRTD _p0;
    };
    case "getsensortargets": {
        // getSensorTargets vehicle
        private _p0 = _args param [0];
        getSensorTargets _p0;
        _result = true;
    };
    case "getsensorthreats": {
        // getSensorThreats vehicle
        private _p0 = _args param [0];
        getSensorThreats _p0;
        _result = true;
    };
    case "getshotparents": {
        // getShotParents projectile
        private _p0 = _args param [0];
        _result = getShotParents _p0;
    };
    case "getslingload": {
        // getSlingLoad vehicle
        private _p0 = _args param [0];
        _result = getSlingLoad _p0;
    };
    case "getsoundcontroller": {
        // vehicle getSoundController controller
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 getSoundController _p1;
    };
    case "getsoundcontrollerresult": {
        // vehicle getSoundControllerResult config
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 getSoundControllerResult _p1;
    };
    case "getspeed": {
        // object getSpeed speedMode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 getSpeed _p1;
        _result = true;
    };
    case "getstamina": {
        // getStamina unit
        private _p0 = _args param [0];
        _result = getStamina _p0;
    };
    case "getstatvalue": {
        // getStatValue name
        private _p0 = _args param [0];
        getStatValue _p0;
        _result = true;
    };
    case "getsuppression": {
        // getSuppression unit
        private _p0 = _args param [0];
        _result = getSuppression _p0;
    };
    case "getterrainheight": {
        // getTerrainHeight positionWorld
        private _p0 = _args param [0];
        _result = getTerrainHeight _p0;
    };
    case "getterrainheightasl": {
        // getTerrainHeightASL position
        private _p0 = _args param [0];
        _result = getTerrainHeightASL _p0;
    };
    case "gettext": {
        // getText config
        private _p0 = _args param [0];
        _result = getText _p0;
    };
    case "gettextraw": {
        // getTextRaw config
        private _p0 = _args param [0];
        _result = getTextRaw _p0;
    };
    case "gettextureinfo": {
        // getTextureInfo texture
        private _p0 = _args param [0];
        getTextureInfo _p0;
        _result = true;
    };
    case "gettextwidth": {
        // text getTextWidth [font, size]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 getTextWidth [_p1, _p2];
    };
    case "gettowparent": {
        // getTowParent towedVehicle
        private _p0 = _args param [0];
        _result = getTowParent _p0;
    };
    case "gettrimoffsetrtd": {
        // getTrimOffsetRTD RTD_helicopter
        private _p0 = _args param [0];
        _result = getTrimOffsetRTD _p0;
    };
    case "getturretlimits": {
        // vehicle getTurretLimits turret
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 getTurretLimits _p1;
        _result = true;
    };
    case "getturretopticsmode": {
        // getTurretOpticsMode obj
        private _p0 = _args param [0];
        _result = getTurretOpticsMode _p0;
    };
    case "getturretopticsmode": {
        // obj getTurretOpticsMode turretPath
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 getTurretOpticsMode _p1;
    };
    case "getunitfreefallinfo": {
        // getUnitFreefallInfo unit
        private _p0 = _args param [0];
        getUnitFreefallInfo _p0;
        _result = true;
    };
    case "getunitloadout": {
        // getUnitLoadout unit
        private _p0 = _args param [0];
        _result = getUnitLoadout _p0;
    };
    case "getunitloadout": {
        // getUnitLoadout [unit, fullMagazines]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = getUnitLoadout [_p0, _p1];
    };
    case "getunitloadout": {
        // getUnitLoadout name
        private _p0 = _args param [0];
        _result = getUnitLoadout _p0;
    };
    case "getunitloadout": {
        // getUnitLoadout config
        private _p0 = _args param [0];
        _result = getUnitLoadout _p0;
    };
    case "getunloadincombat": {
        // getUnloadInCombat vehicle
        private _p0 = _args param [0];
        getUnloadInCombat _p0;
        _result = true;
    };
    case "getuserinfo": {
        // getUserInfo playerID
        private _p0 = _args param [0];
        getUserInfo _p0;
        _result = true;
    };
    case "getusermfdtext": {
        // getUserMFDText vehicle
        private _p0 = _args param [0];
        getUserMFDText _p0;
        _result = true;
    };
    case "getusermfdvalue": {
        // getUserMFDValue vehicle
        private _p0 = _args param [0];
        getUserMFDValue _p0;
        _result = true;
    };
    case "getvariable": {
        // varspace getVariable name
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 getVariable _p1;
        _result = true;
    };
    case "getvariable": {
        // varspace getVariable [name, defaultValue]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 getVariable [_p1, _p2];
    };
    case "getvehiclecargo": {
        // getVehicleCargo storingVehicle
        private _p0 = _args param [0];
        _result = getVehicleCargo _p0;
    };
    case "getvehicletipars": {
        // getVehicleTIPars vehicle
        private _p0 = _args param [0];
        getVehicleTIPars _p0;
        _result = true;
    };
    case "getweaponcargo": {
        // getWeaponCargo object
        private _p0 = _args param [0];
        _result = getWeaponCargo _p0;
    };
    case "getweaponsway": {
        // getWeaponSway unit
        private _p0 = _args param [0];
        getWeaponSway _p0;
        _result = true;
    };
    case "getwingsorientationrtd": {
        // getWingsOrientationRTD RTD_helicopter
        private _p0 = _args param [0];
        _result = getWingsOrientationRTD _p0;
    };
    case "getwingspositionrtd": {
        // getWingsPositionRTD RTD_helicopter
        private _p0 = _args param [0];
        _result = getWingsPositionRTD _p0;
    };
    case "getwppos": {
        // getWPPos [groupOrUnit, index]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = getWPPos [_p0, _p1];
    };
    default { _handled = false; };
};

[_handled, _result]
