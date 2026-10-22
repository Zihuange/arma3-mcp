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
    case "playableslotsnumber": {
        // playableSlotsNumber side
        private _p0 = _args param [0];
        _result = playableSlotsNumber _p0;
    };
    case "playaction": {
        // soldier playAction action
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 playAction _p1;
        _result = true;
    };
    case "playactionnow": {
        // soldier playActionNow action
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 playActionNow _p1;
        _result = true;
    };
    case "playersnumber": {
        // playersNumber side
        private _p0 = _args param [0];
        _result = playersNumber _p0;
    };
    case "playgesture": {
        // soldier playGesture moveName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 playGesture _p1;
        _result = true;
    };
    case "playmove": {
        // unitName playMove moveName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 playMove _p1;
        _result = true;
    };
    case "playmovenow": {
        // soldier playMoveNow moveName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 playMoveNow _p1;
        _result = true;
    };
    case "playmusic": {
        // playMusic musicName
        private _p0 = _args param [0];
        playMusic _p0;
        _result = true;
    };
    case "playmusic": {
        // playMusic [musicName, start]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        playMusic [_p0, _p1];
        _result = true;
    };
    case "playscriptedmission": {
        // playScriptedMission [world, expression, config, ignoreChildWindow]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        playScriptedMission [_p0, _p1, _p2, _p3];
        _result = true;
    };
    case "playsound": {
        // playSound soundName
        private _p0 = _args param [0];
        _result = playSound _p0;
    };
    case "playsound": {
        // playSound [soundName, isSpeech, offset]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = playSound [_p0, _p1, _p2];
    };
    case "playsound3d": {
        // playSound3D [filename, soundSource, isInside, soundPosition, volume, soundPitch, distance, offset, local]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        private _p5 = _args param [5];
        private _p6 = _args param [6];
        private _p7 = _args param [7];
        private _p8 = _args param [8];
        playSound3D [_p0, _p1, _p2, _p3, _p4, _p5, _p6, _p7, _p8];
        _result = true;
    };
    case "playsoundui": {
        // playSoundUI [sound, volume, soundPitch, isEffect, offset]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        playSoundUI [_p0, _p1, _p2, _p3, _p4];
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
