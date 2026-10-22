/* a3mcp_fnc_resolve —— 把 MCP 传来的参数值解析成游戏内的实际值

两种实体写法都要认（这是链路首次跑通后暴露的细节）：
  1. {"__ent__": "u_17"}    —— MCP 侧显式编码
  2. ["u_17"]               —— **单元素字符串数组**，MCP 侧文档约定的写法
     （被调命令的对象参数都是位置参数，用数组承载最省事）
第 2 种漏掉时，参数会原样以数组传给引擎命令 → 类型错 → 返回 nil，
而回执是 ok=true，于是表现为"命令成功但结果为空"。

⚠ 语义陷阱：实体名未定义时 getVariable 返回 nil 而**不报错**。上游容易把
"没这个实体"误读成"实体存在但值为空"。故这里保持返回 nil，由调用方显式
判断并汇报 —— 不在这里静默替换成 objNull。
*/
params [["_value", nil]];

// 写法 1：显式实体对象
if (_value isEqualType createHashMap) exitWith {
    private _name = _value getOrDefault ["__ent__", ""];
    if (_name != "") then {
        missionNamespace getVariable [_name, nil]
    } else {
        _value
    };
};

// 写法 2：单元素字符串数组 = 实体引用
if ((_value isEqualType []) && { count _value == 1 }) then {
    private _first = _value select 0;
    if (_first isEqualType "") then {
        missionNamespace getVariable [_first, nil]
    } else {
        _value
    };
} else {
    _value
}
