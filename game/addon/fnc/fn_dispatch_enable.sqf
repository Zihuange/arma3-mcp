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
    case "enableai": {
        // unit enableAI skilltype
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 enableAI _p1;
        _result = true;
    };
    case "enableaifeature": {
        // feature enableAIFeature  enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 enableAIFeature  _p1;
        _result = true;
    };
    case "enableaifeature": {
        // unit enableAIFeature  [feature, enable]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 enableAIFeature  [_p1, _p2];
        _result = true;
    };
    case "enableaimprecision": {
        // unit enableAimPrecision enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 enableAimPrecision _p1;
        _result = true;
    };
    case "enableattack": {
        // group enableAttack enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 enableAttack _p1;
        _result = true;
    };
    case "enableautostartuprtd": {
        // helicopterRTD enableAutoStartUpRTD enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 enableAutoStartUpRTD _p1;
        _result = true;
    };
    case "enableautotrimrtd": {
        // helicopterRTD enableAutoTrimRTD enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 enableAutoTrimRTD _p1;
    };
    case "enablecamshake": {
        // enableCamShake  value
        private _p0 = _args param [0];
        enableCamShake  _p0;
        _result = true;
    };
    case "enablecaustics": {
        // enableCaustics bool
        private _p0 = _args param [0];
        enableCaustics _p0;
        _result = true;
    };
    case "enablechannel": {
        // channelID enableChannel enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 enableChannel _p1;
        _result = true;
    };
    case "enablechannel": {
        // channelID enableChannel [chat, VoN]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 enableChannel [_p1, _p2];
        _result = true;
    };
    case "enablecollisionwith": {
        // vehicle1 enableCollisionWith vehicle2
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 enableCollisionWith _p1;
        _result = true;
    };
    case "enablecopilot": {
        // vehicle enableCopilot enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 enableCopilot _p1;
        _result = true;
    };
    case "enabledebriefingstats": {
        // enableDebriefingStats [left, top, width, height]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        enableDebriefingStats [_p0, _p1, _p2, _p3];
        _result = true;
    };
    case "enablediaglegend": {
        // enableDiagLegend enable
        private _p0 = _args param [0];
        enableDiagLegend _p0;
        _result = true;
    };
    case "enabledirectionstabilization": {
        // vehicle enableDirectionStabilization [enabled, turretPath]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 enableDirectionStabilization [_p1, _p2];
        _result = true;
    };
    case "enabledynamicsimulation": {
        // object enableDynamicSimulation enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 enableDynamicSimulation _p1;
        _result = true;
    };
    case "enabledynamicsimulationsystem": {
        // enableDynamicSimulationSystem enable
        private _p0 = _args param [0];
        enableDynamicSimulationSystem _p0;
        _result = true;
    };
    case "enableengineartillery": {
        // enableEngineArtillery enabled
        private _p0 = _args param [0];
        enableEngineArtillery _p0;
        _result = true;
    };
    case "enableenvironment": {
        // enableEnvironment enable
        private _p0 = _args param [0];
        enableEnvironment _p0;
        _result = true;
    };
    case "enablefatigue": {
        // unit enableFatigue enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 enableFatigue _p1;
        _result = true;
    };
    case "enablegunlights": {
        // target enableGunLights state
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 enableGunLights _p1;
        _result = true;
    };
    case "enableinfopanelcomponent": {
        // unit enableInfoPanelComponent [panelID, componentClassOrType, enable]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = _p0 enableInfoPanelComponent [_p1, _p2, _p3];
    };
    case "enableinfopanelcomponent": {
        // [unit, turretPath] enableInfoPanelComponent [panelID, componentClassOrType, enable]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = [_p0, _p1] enableInfoPanelComponent [_p2, _p3, _p4];
    };
    case "enableirlasers": {
        // unitOrGroup enableIRLasers value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 enableIRLasers _p1;
        _result = true;
    };
    case "enablemimics": {
        // unit enableMimics enabled
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 enableMimics _p1;
        _result = true;
    };
    case "enablepersonturret": {
        // vehicle enablePersonTurret [turretPath, enable]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 enablePersonTurret [_p1, _p2];
        _result = true;
    };
    case "enableradio": {
        // enableRadio state
        private _p0 = _args param [0];
        enableRadio _p0;
        _result = true;
    };
    case "enablereload": {
        // object enableReload enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 enableReload _p1;
        _result = true;
    };
    case "enableropeattach": {
        // entity enableRopeAttach enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 enableRopeAttach _p1;
        _result = true;
    };
    case "enablesatnormalondetail": {
        // enableSatNormalOnDetail state
        private _p0 = _args param [0];
        enableSatNormalOnDetail _p0;
        _result = true;
    };
    case "enablesaving": {
        // enableSaving enable
        private _p0 = _args param [0];
        enableSaving _p0;
        _result = true;
    };
    case "enablesaving": {
        // enableSaving [enable, save]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        enableSaving [_p0, _p1];
        _result = true;
    };
    case "enablesentences": {
        // enableSentences enable
        private _p0 = _args param [0];
        enableSentences _p0;
        _result = true;
    };
    case "enablesimulation": {
        // entity enableSimulation state
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 enableSimulation _p1;
        _result = true;
    };
    case "enablesimulationglobal": {
        // entity enableSimulationGlobal enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 enableSimulationGlobal _p1;
        _result = true;
    };
    case "enablestamina": {
        // unit enableStamina enabled
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 enableStamina _p1;
        _result = true;
    };
    case "enablestressdamage": {
        // enableStressDamage state
        private _p0 = _args param [0];
        enableStressDamage _p0;
        _result = true;
    };
    case "enableteamswitch": {
        // enableTeamSwitch enable
        private _p0 = _args param [0];
        enableTeamSwitch _p0;
        _result = true;
    };
    case "enabletraffic": {
        // enableTraffic enable
        private _p0 = _args param [0];
        enableTraffic _p0;
        _result = true;
    };
    case "enableuavconnectability": {
        // object enableUAVConnectability [uav, checkAllItems]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 enableUAVConnectability [_p1, _p2];
        _result = true;
    };
    case "enableuavwaypoints": {
        // uav enableUAVWaypoints enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 enableUAVWaypoints _p1;
        _result = true;
    };
    case "enablevehiclecargo": {
        // vehicle enableVehicleCargo enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 enableVehicleCargo _p1;
        _result = true;
    };
    case "enablevehiclesensor": {
        // vehicle enableVehicleSensor [componentName, enabled]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 enableVehicleSensor [_p1, _p2];
        _result = true;
    };
    case "enableweapondisassembly": {
        // enableWeaponDisassembly enable
        private _p0 = _args param [0];
        enableWeaponDisassembly _p0;
        _result = true;
    };
    case "enableweapondisassembly": {
        // entity enableWeaponDisassembly  enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 enableWeaponDisassembly  _p1;
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
