/* a3mcp_fnc_loop —— 轮询扩展、取命令、交给 fn_exec 执行

两条硬约束（同类工程踩坑得出的结论）：
  1. **单条命令的错误绝不允许杀死主循环**：每条命令在独立 spawn 内执行并
     try/catch。一个坏参数不该让整个系统失联——失联后上层只看到"超时"，
     极难定位。
  2. **循环必须可被监督者重启**：心跳停滞时 fn_supervisor 拉起新世代，
     旧循环靠世代号自行退出，避免两个循环并行执行命令。

## 取命令的方式（这里踩过一个很贵的坑）

必须用**单字符串形式** `callExtension "poll"`。

用数组形式 `callExtension ["poll", []]` 时，引擎返回的是**三元素数组**——
实测 `["", 0, 0]`，命令内容并不在我以为的 `select 1` 位置（那里是数字 0）。
后果：类型检查静默失败，表现为"命令明明进了 DLL 队列、却永远取不到"，
而两端日志都看不出问题（MCP 只看到超时，游戏只看到循环在跑）。

单字符串形式的返回值**就是扩展的输出本身**，没有布局歧义。下面仍保留
对数组返回的兼容分支（取第一个非空字符串元素，而不是固定下标）。
*/
params [["_delay", 0.1, [0]], ["_gen", 0, [0]]];

while {true} do {
    if ((missionNamespace getVariable ["A3MCP_LOOP_GEN", 0]) != _gen) exitWith {
        diag_log format ["[A3MCP] 循环 gen=%1 退役", _gen];
    };
    missionNamespace setVariable ["A3MCP_HEARTBEAT", diag_tickTime, false];

    // poll 每轮**只能调用一次**：它是"取走并清空"语义，调用两次会让第一次
    // 取到的命令被第二次的空结果覆盖（加诊断时我亲手踩过这个坑）。
    private _raw = "arma3_mcp" callExtension "poll";
    private _pollCount = (missionNamespace getVariable ["A3MCP_POLL_N", 0]) + 1;
    missionNamespace setVariable ["A3MCP_POLL_N", _pollCount, false];

    // 若某版本仍返回数组：取其中第一个非空字符串（不按固定下标取）
    if (_raw isEqualType [] && { count _raw > 0 }) then {
        private _firstStr = "";
        {
            if ((_x isEqualType "") && { _x != "" }) exitWith { _firstStr = _x };
        } forEach _raw;
        _raw = _firstStr;
    };

    // 心跳：每 30s 一次，带 poll 计数与上一次的原始返回（排查取证用）
    private _hbTick = missionNamespace getVariable ["A3MCP_HB_TICK", 0];
    if ((_hbTick + 30) < diag_tickTime) then {
        missionNamespace setVariable ["A3MCP_HB_TICK", diag_tickTime, false];
        missionNamespace setVariable ["A3MCP_LAST_POLL", str _raw, false];
        diag_log format ["[A3MCP] 循环活跃 gen=%1 已执行=%2 错误=%3 poll=%4 last=%5",
            _gen,
            missionNamespace getVariable ["A3MCP_DONE", 0],
            missionNamespace getVariable ["A3MCP_ERR", 0],
            _pollCount,
            (str _raw) select [0, 140]];
    };

    if ((_raw isEqualType "") && { _raw != "" }) then {
        // 命令到达：记一行现场证据（分开"没送到"与"执行出错"）
        diag_log format ["[A3MCP] cmd <- %1", _raw select [0, 200]];
        [_raw] spawn {
            params [["_payload", "", [""]]];
            try {
                [_payload] call a3mcp_fnc_exec;
            } catch {
                private _n = missionNamespace getVariable ["A3MCP_ERR", 0];
                missionNamespace setVariable ["A3MCP_ERR", _n + 1, false];
                diag_log format ["[A3MCP][ERR] 命令抛错：%1 | %2",
                                 _payload, _exception];
                private _cid = [_payload, "cid"] call a3mcp_fnc_fieldOf;
                [_cid, false, "SQF 抛错：" + (str _exception)]
                    call a3mcp_fnc_sendAck;
            };
        };
    };

    uiSleep _delay;
};
