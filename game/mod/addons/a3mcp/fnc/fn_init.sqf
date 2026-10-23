/* a3mcp_fnc_init —— 扩展执行器的入口（由模组初始化或 -init= 调用）

职责很薄：启动轮询循环。真正的分发在 fn_exec，校验在 fn_validate，
序列化在 fn_serialize。

为什么轮询而不是"等推送"：引擎不提供回调，SQF 只能主动去问扩展
（callExtension）。所以循环周期决定了命令延迟的下限，取 0.1s ——
比状态上报（5s）密得多，又不至于占用过多游戏逻辑线程时间。
*/
// ⚠ 不加类型约束：这个函数被三个入口调用（CfgFunctions 的 preInit/postInit、
// CBA 的 XEH、命令行的 -init=），传进来的 `_this` 不一定是数字 —— 实测 XEH
// 那条路径给的是**字符串**，带 `[0]` 约束的 params 会直接报
// "Params: 类型 字符串，预期为 数字" 并让整个函数中止。所以先取默认值再校验。
params [["_pollDelay", 0.1]];
if (!(_pollDelay isEqualType 0)) then { _pollDelay = 0.1; };

if (missionNamespace getVariable ["A3MCP_STARTED", false]) exitWith {
    diag_log "[A3MCP] init 已在运行，忽略重复调用";
    false
};
missionNamespace setVariable ["A3MCP_STARTED", true, false];
missionNamespace setVariable ["A3MCP_POLL_DELAY", _pollDelay, false];
missionNamespace setVariable ["A3MCP_HEARTBEAT", diag_tickTime, false];
missionNamespace setVariable ["A3MCP_LOOP_GEN", 0, false];
// 编译缓存：表达式文本 -> 已编译的 Code。config 与命令集在运行期基本不变，
// 反复 compile 同一段文本是纯浪费（compile 有实际开销）。
missionNamespace setVariable ["A3MCP_CACHE", createHashMap, false];
missionNamespace setVariable ["A3MCP_DONE", 0, false];
missionNamespace setVariable ["A3MCP_ERR", 0, false];

// 时序守卫：fn_init 现在同时挂在 preInit 与 postInit 上。
// preInit 阶段是"引擎还没跑起来"的时刻（time == 0、调度器未启动），
// 此时发起网络轮询没有意义，也可能拿不到 callExtension 的结果。
// 等 time > 0（世界开始模拟）再起循环，两个入口就都安全。
[_pollDelay] spawn {
    params [["_d", 0.1, [0]]];
    waitUntil { time > 0 };
    [_d, missionNamespace getVariable ["A3MCP_LOOP_GEN", 0]] spawn a3mcp_fnc_loop;
};
diag_log format ["[A3MCP] 执行器已启动（poll 周期 %1s）", _pollDelay];
true
