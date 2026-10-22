/* mcp_test —— arma3-mcp 的专用服务器测试任务（服务器侧入口）
 *
 * 为什么入口在任务的 initServer.sqf，而不是模组的 preInit/postInit：
 * 实测（见 docs/decisions.md D27）专用服务器上只有 DLL 能加载，模组的
 * CfgFunctions 要等**任务加载**才编译 —— 与客户端停在主菜单时完全一样。
 * initServer.sqf 是 dedicated server 执行任务的入口，函数在这里已经可用。
 *
 * 这一步之后，执行器（SQF 轮询循环）就会跑起来，MCP 侧的 game_link
 * 心跳应当显示"运行中"，exec / config_* 随之可用。
 */

diag_log "[MCPTEST] initServer 开始，准备启动执行器";

if (isNil "a3mcp_fnc_init") exitWith {
    // 到了这里说明模组没挂上，或者 CfgFunctions 没编译 —— 要说清楚是哪一种，
    // 而不是让上层只看到"执行器没起来"。
    diag_log "[MCPTEST][ERR] a3mcp_fnc_init 不存在：检查 -mod 是否挂上了本仓库的 game/mod";
};

call a3mcp_fnc_init;

diag_log "[MCPTEST] 执行器启动调用已发出";
