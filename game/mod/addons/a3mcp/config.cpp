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
