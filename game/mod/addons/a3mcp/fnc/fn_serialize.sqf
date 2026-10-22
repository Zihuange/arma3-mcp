/* a3mcp_fnc_serialize —— 把命令返回值序列化成可回传的 SQF 值

设计取舍：**不追求把游戏对象展开成人可读的长摘要**。
游戏对象（Object/Group/Control/…）用简短标签概括，因为：
  · 展开一个组会带出几十个成员，直接撑爆上层上下文；
  · 上层真需要细节时，应该用专门的命令去查（那是 config 查询与状态查询的职责）。
这样"返回值"始终保持小体量，不会因为一条命令的返回把对话灌满。

nil 被显式表达为 {"t":"nil"} —— 必须与"空数组/0/false"区分开：
SQF 里 nil 表示"不存在"，语义与它们完全不同，混起来会让上层误判。
*/
params [["_v", nil]];

if (isNil "_v") exitWith { createHashMapFromArray [["t", "nil"], ["v", ""]] };

switch (typeName _v) do {
    case "STRING": {
        createHashMapFromArray [["t", "text"], ["v", _v]]
    };
    case "BOOL": {
        createHashMapFromArray [["t", "bool"], ["v", _v]]
    };
    case "SCALAR": {
        createHashMapFromArray [["t", "number"], ["v", _v]]
    };
    case "ARRAY": {
        private _out = [];
        { _out pushBack ([_x] call a3mcp_fnc_serialize); } forEach _v;
        createHashMapFromArray [["t", "array"], ["v", _out]]
    };
    case "HASHMAP": {
        // 显式用 keys/get 遍历，而不是 forEach 的 _x/_y 双参形式：
        // 后者在静态检查里会报"可能未定义的 _y"，而本仓库要求 SQF 交付前
        // 静态检查干净（静态检查发现不了的问题才是上机时最贵的）。
        private _out = createHashMap;
        {
            private _k = _x;
            _out set [_k, [_v get _k] call a3mcp_fnc_serialize];
        } forEach (keys _v);
        createHashMapFromArray [["t", "hashmap"], ["v", _out]]
    };
    default {
        createHashMapFromArray [
            ["t", "other"],
            ["v", typeName _v],
            ["label", [_v] call a3mcp_fnc_role]
        ]
    };
}
