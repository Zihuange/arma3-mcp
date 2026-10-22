// a3mcp —— arma3-mcp 游戏侧执行器
//
// 只声明 CfgPatches 与 CfgFunctions，不注册任何自定义类：
// 本模组的职责是"让 MCP 能与游戏对话"，不添加任何游戏内容。
class CfgPatches {
    class a3mcp {
        units[] = {};
        weapons[] = {};
        requiredVersion = 1.0;
        requiredAddons[] = {};
        author = "arma3-mcp";
    };
};

// ── 主菜单即可用：借助 CBA 的 Extended_PreInit（若装了 CBA） ──────────
//
// 背景：preInit / postInit 是**任务级**触发点，停在主菜单时不执行；而命令行
// 的 -init= 参数在传递含引号/路径的代码时不可靠（实测 RPT 报"缺少 '"）。
//
// CBA 的 Extended_PreInit 在**游戏启动阶段**执行、不依赖任务，且完全走
// config 而不过命令行，因此没有引号/转义问题。本仓库不依赖 CBA，
// 但装了就用它把可用时机提前；没装则退回 -init= 与 preInit/postInit。
class Extended_PreInit_EventHandlers {
    class a3mcp {
        // 分两级：先无条件打一行日志（证明 XEH 确实被触发、且时机早于/晚于
        // 函数注册），再尝试调用。若只有第一行、没有第二行，说明此处函数
        // 尚未定义 —— 那就该把调用推迟到 postInit（进任务）或改用其它钩子。
        init = "diag_log '[A3MCP] XEH PreInit fired'; if !(isNil 'a3mcp_fnc_init') then { diag_log '[A3MCP] XEH: fnc ready, starting'; call a3mcp_fnc_init } else { diag_log '[A3MCP] XEH: fnc NOT ready yet' }";
    };
};

class CfgFunctions {
    class a3mcp {
        tag = "a3mcp";
        class Core {
            // file 指向 PBO 前缀下的 fnc 目录
            file = "\a3mcp\fnc";

            // ── 自动启动 ──────────────────────────────────────────────
            // preInit/postInit 是 CfgFunctions 的固定字段：带 preInit = 1 的
            // 函数在**游戏启动时**自动执行，postInit 在**进入任务时**执行。
            // 这样就不需要用户手工敲 `call a3mcp_fnc_init;`。
            //
            // 为什么两个都挂：preInit 早于任务，可让 MCP 尽早拿到连接（进主菜单
            // 就连上，便于确认链路）；postInit 则在任务世界就绪后确保执行器在跑。
            // 重复调用由 fn_init 内部的 A3MCP_STARTED 守卫挡住，不会起两个循环。
            //
            // ⚠ postInit 在**每台机器**上都会执行一次（进任务时）。本仓库的
            // 主形态是本地单机（MCP 与游戏同机），所以这正是想要的；
            // 若将来跑专用服务器，需要在这里按机器角色加判断
            // （UI/config 读取必须在有玩家的客户端上执行）。
            class init {
                preInit = 1;
                postInit = 1;
            };
            class loop {};
            class supervisor {};
            class exec {};
            class run {};
            class jsonParse {};
            class jsonStringify {};
            class ackJson {};
            class pushResult {};
            class sendAck {};
            class input {};
            class validate {};
            class serialize {};
            class resolve {};
            class role {};
            class json {};
            class fieldOf {};
            class cfgValue {};
            class cfgClass {};
            class configQuery {};
            class configOfEntity {};
        };
    };
};
