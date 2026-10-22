/* a3mcp_fnc_role —— 把任意值概括成一个短标签，用于序列化

规则：简单类型用 typeName；游戏实体用能用少量命令说清的形态（名字 + 类名）。
刻意**不展开**实体细节：一个组有几十个成员，全列会把上下文撑爆；需要细节时
让上层用专门的命令去查（这也是 config 查询独立成一组工具的原因）。
*/
params [["_v", nil]];
private _t = typeName _v;

if (_t == "OBJECT") exitWith { "Object(" + (typeOf _v) + ")" };
if (_t == "GROUP") exitWith { "Group" };
if (_t == "CONTROL") exitWith { "Control" };
if (_t == "DISPLAY") exitWith { "Display" };
if (_t == "CONFIG") exitWith { "Config(" + (configName _v) + ")" };
if (_t == "TASK") exitWith { "Task" };
if (_t == "LOCATION") exitWith { "Location" };
_t
