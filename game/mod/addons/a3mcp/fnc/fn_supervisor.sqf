/* a3mcp_fnc_supervisor —— 心跳监督者

为什么需要：轮询循环一旦因任何原因停止，整个 MCP 就与游戏失联，而上层只会
看到"命令超时"，很难定位。监督者让这种失联**可自愈**，并把重启事件上报。

世代机制：每次拉起新循环都递增 A3MCP_LOOP_GEN。旧循环每轮核对自己的世代号，
发现已被更新就自行退出 —— 这样即使出现"看似死了其实还在跑"的误判，
也不会留下两个循环并行执行命令（同一个命令执行两遍的后果比失联更难查）。
*/
params [["_stallLimit", 15, [0]], ["_checkInterval", 5, [0]],
        ["_delay", 0.1, [0]]];

private _myGen = missionNamespace getVariable ["A3MCP_LOOP_GEN", 0];
while {true} do {
    sleep _checkInterval;
    private _curGen = missionNamespace getVariable ["A3MCP_LOOP_GEN", 0];
    if (_curGen != _myGen) exitWith {
        diag_log format ["[A3MCP] 监督者 gen=%1 退役（已有更新世代）", _myGen];
    };
    private _hb = missionNamespace getVariable ["A3MCP_HEARTBEAT", 0];
    if ((diag_tickTime - _hb) > _stallLimit) then {
        private _ng = _curGen + 1;
        missionNamespace setVariable ["A3MCP_LOOP_GEN", _ng, false];
        missionNamespace setVariable ["A3MCP_HEARTBEAT", diag_tickTime, false];
        diag_log format ["[A3MCP][ERR] 轮询停滞 %1s，重启为 gen=%2",
                         diag_tickTime - _hb, _ng];
        "arma3_mcp" callExtension ["push", [format [
            "{""t"":""event"",""line"":""evt:loop_restart:gen=%1""}", _ng]]];
        [_delay, _ng] spawn a3mcp_fnc_loop;
        _myGen = _ng;
    };
};
