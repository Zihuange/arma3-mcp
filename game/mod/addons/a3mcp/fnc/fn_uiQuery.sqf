/* a3mcp_fnc_uiQuery —— 界面控件查询

输入：_args 数组
  ["classes"]            列出所有 display 上控件的类名及数量（去重、按数量降序）
  ["find", 类名, 上限]    按类名子串找控件，返回 display/索引/类名/位置/IDC/文本

回执：[_cid, true, 结果] —— 结果含 [_items, _scanned]

── 为什么"列类名"必须在游戏侧做 ──

实测（docs/decisions.md D35）：要找一个没有文本的图标按钮，必须先知道它的类名。
但 MCP 侧的动态表达式走不通：
  · `apply { ctrlClassName _x }` —— lambda 参数 `_x` 不在白名单，被校验器拒掉
    （这是"命令名注入"的防线，不该为便利放宽）；
  · 逐个 exec 取一个类名 —— 一次往返约 100ms，界面有 160+ 个控件，
    而每读一个都要重新求值 allControls（扫描成本正比于控件总数）。

所以"这个界面上有哪些控件类型"在 MCP 侧无法高效回答 —— 而它恰恰是探索未知
界面时最先要问的问题。

── 顺带记下的一个坑 ──

`ctrlClassName` 返回的是**控件**在 config 里的类名。**display 自己的**类名不在这里，
它存在 display 的变量里：
    _cls = _disp getVariable ["BIS_fnc_initDisplay_configClass", ""];
所以拿 `Rsc*` 去猜"控件类名"是错的 —— Eden 的控件用的是自定义类名。
*/

params [["_cid", "", [""]], ["_args", [], [[]]]];

private _op = toLower (_args param [0, "classes", [""]]);
private _arg1 = _args param [1, "", [""]];
private _limit = _args param [2, 0, [0]];

private _reply = {
    params [["_cidIn", "", [""]], ["_okIn", true, [true]],
            ["_payloadIn", nil]];
    [_cidIn, _okIn, _payloadIn] call a3mcp_fnc_sendAck;
};

private _items = [];
private _scanned = 0;

switch (_op) do {
    case "classes": {
        // 类名与计数用两个平行数组：SQF 里 HashMap 要落到命名空间，没必要
        private _names = [];
        private _counts = [];

        {
            private _disp = _x;
            {
                private _cls = ctrlClassName _x;
                _scanned = _scanned + 1;
                if (_cls != "") then {
                    private _hit = _names find _cls;
                    if (_hit < 0) then {
                        _names pushBack _cls;
                        _counts pushBack 1;
                    } else {
                        _counts set [_hit, (_counts select _hit) + 1];
                    };
                };
            } forEach (allControls _disp);
        } forEach allDisplays;

        // 按数量降序：调用方一眼看出哪些是通用控件、哪些是某个界面专有的
        private _pairs = [];
        for "_i" from 0 to ((count _names) - 1) do {
            _pairs pushBack [(_names select _i), (_counts select _i)];
        };
        _pairs sort false;

        // 直接拼成多行文本再上行。
        // 为什么不在游戏侧返回嵌套数组：那样 MCP 侧要处理 {v,t} 的层层解包，
        // 而这个结果的用途就是"给人看"——拼好既省一层转换，也少一处出错点。
        private _lines = [];
        {
            _lines pushBack format ["%1 x%2", _x select 0, _x select 1];
        } forEach _pairs;
        _items = _lines joinString toString [10];
    };

    case "find": {
        private _want = toLower _arg1;
        private _cap = if (_limit > 0) then { _limit } else { 40 };
        private _dispIdx = 0;

        {
            private _disp = _x;
            private _ctrlIdx = 0;
            {
                private _cls = ctrlClassName _x;
                _scanned = _scanned + 1;
                if ((toLower _cls) find _want >= 0) then {
                    if (count _items < _cap) then {
                        _items pushBack [
                            _dispIdx, _ctrlIdx, _cls, ctrlPosition _x,
                            ctrlIDC _x, ctrlText _x
                        ];
                    };
                };
                _ctrlIdx = _ctrlIdx + 1;
            } forEach (allControls _disp);
            _dispIdx = _dispIdx + 1;
        } forEach allDisplays;
    };

    default {
        [_cid, false,
         "uiQuery 不认识的操作：" + _op + "（可用：classes / find）"] call _reply;
        _scanned = -1;
    };
};

if (_scanned >= 0) then {
    [_cid, true, [_items, _scanned]] call _reply;
};
