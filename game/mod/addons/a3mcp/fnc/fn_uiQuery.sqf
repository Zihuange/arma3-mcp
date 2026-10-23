/* a3mcp_fnc_uiQuery —— 界面控件查询

输入：_args 数组，第 0 位是操作名，其后是各操作自己的参数
  ["classes"]                 列出所有 display 上控件的类名及数量（去重、按数量降序）
  ["find", 类名, 上限]         按类名子串找控件，返回 display/索引/类名/位置/IDC/文本
  ["snapshot", 上限, 偏移]     整棵控件树（分页）；每行一个控件
  ["actions", 上限, 偏移]      所有按钮（type 1）及其**运行时 action 代码**
  ["handlers", display类名]    config 里某个 UI 类整棵子树的 action/onButtonClick 文本

回执：见各分支。classes/find 回 [_items, _scanned]，其余回自定义结构。

── 为什么"列类名"必须在游戏侧做 ──

实测（docs/decisions.md D35）：要找一个没有文本的图标按钮，必须先知道它的类名。
但 MCP 侧的动态表达式走不通：
  · `apply { ctrlClassName _x }` —— lambda 参数 `_x` 不在白名单，被校验器拒掉
    （这是"命令名注入"的防线，不该为便利放宽）；
  · 逐个 exec 取一个类名 —— 一次往返约 100ms，界面有 160+ 个控件，
    而每读一个都要重新求值 allControls（扫描成本正比于控件总数）。

所以"这个界面上有哪些控件类型"在 MCP 侧无法高效回答 —— 而它恰恰是探索未知
界面时最先要问的问题。

── 为什么 snapshot 必须分页（上机实测的硬限制） ──

DLL 的**上行**单行上限是 16 KB（game/extension 的 kMaxLineOut）。Eden 编辑器
一个 display 就有 304 个控件，整棵树序列化约 50 KB —— 超出的部分会被**静默
截断**，回执看起来"成功"但只有前半段。这类失败最难查，所以这里用"条数配额
+ 字节预算"双保险：任何一页都不会超过 12 KB，下一页的位置随回执一起返回。

── "UI 元素指向哪个功能"的三种落点（真机验证，见 D41） ──

  1. config 的 `action`        → 运行时 `buttonAction` 读得到，读到即可 `call compile`；
  2. config 的 `onButtonClick` → **没有**运行时 getter，只有 config 里有；
  3. 两者都空（引擎原生按钮） → 只能坐标点击。

Eden 实测：Display3DEN 的 32 个按钮里 8 个走 action、19 个走 onButtonClick、
6 个都没有；菜单条 MenuStrip 的 128 个菜单项 config 里连 action 都没有。

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

// 文本里的分隔符与换行必须压平，否则一"行"会被解析成两行。
//
// ⚠ 调用形态是 `[参数] call _flatten`，**不能**写成 `[_flatten, [参数]] call _flatten`
// —— 后者把函数自己当成了第一个参数，params 的类型校验把整个入参拒掉，函数
// 静默返回 ""：结果是"所有 onButtonClick 都读成空"，而没有任何报错。
private _flatten = {
    params [["_txt", "", [""]]];
    _txt splitString (toString [10, 13, 9, 124]) joinString " "
};

private _items = [];
private _scanned = 0;
private _custom = [];       // 非 classes/find 的操作自带的回执结构
private _hasCustom = false;

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

    /* ── 整棵控件树（分页） ───────────────────────────────────────────
       每行：display|全局索引|类名|idc|类型|启用|显示|透明度|x|y|w|h|文本
       位置是**归一化**的 [x,y,w,h]（相对屏幕比例），屏幕坐标仍由 MCP 侧
       用 window_info 的客户区换算 —— 换算公式只有一处，避免两边各写一遍。 */
    case "snapshot": {
        private _cap = _args param [1, 0, [0]];
        if (_cap <= 0) then { _cap = 100; };
        private _offset = _args param [2, 0, [0]];
        private _budget = 12000;      // 字符预算，给 16 KB 上行上限留 4 KB 余量
        private _used = 0;
        private _total = 0;
        private _next = -1;
        private _stop = false;
        private _lines = [];
        private _meta = [];

        {
            private _disp = _x;
            private _dIdx = count _meta;
            _meta pushBack format ["display %1 = %2, controls=%3",
                _dIdx,
                (_disp getVariable ["BIS_fnc_initDisplay_configClass", "?"]),
                (count (allControls _disp))];

            {
                private _g = _total;
                _total = _total + 1;
                if (!_stop && {_g >= _offset}) then {
                    if ((count _lines) >= _cap) then {
                        _next = _g;
                        _stop = true;
                    } else {
                        private _pos = ctrlPosition _x;
                        // ⚠ 嵌套 call 不能直接写在数组元素里 —— 引擎解析不了，
                        // 报的是 "Error in expression"（见 fn_sendAck 的注释）。
                        private _txt = [ctrlText _x] call _flatten;
                        private _fields = [
                            str _dIdx, str _g, ctrlClassName _x,
                            str (ctrlIDC _x), str (ctrlType _x),
                            str (ctrlEnabled _x), str (ctrlShown _x),
                            str (ctrlFade _x),
                            str (_pos select 0), str (_pos select 1),
                            str (_pos select 2), str (_pos select 3),
                            _txt
                        ];
                        private _line = _fields joinString "|";
                        if ((_used + (count _line)) > _budget) then {
                            _next = _g;
                            _stop = true;
                        } else {
                            _lines pushBack _line;
                            _used = _used + (count _line) + 1;
                        };
                    };
                };
            } forEach (allControls _disp);
        } forEach allDisplays;

        if (!_stop) then { _next = -1; };
        _hasCustom = true;
        private _text = _lines joinString toString [10];
        private _info = format ["total=%1 next=%2 bytes=%3",
                                _total, _next, _used];
        private _head = _meta joinString toString [10];
        _custom = [_text, _info, _head];
    };

    /* ── 可点元素及其运行时 action ────────────────────────────────────
       只收 type 1（按钮）。type 16 是 Eden 主菜单的"磁贴"，`buttonAction`
       对它没有定义，硬调只会得到空串 —— 如实跳过，免得给出假结果。 */
    case "actions": {
        private _cap = _args param [1, 0, [0]];
        if (_cap <= 0) then { _cap = 200; };
        private _offset = _args param [2, 0, [0]];
        private _budget = 12000;
        private _used = 0;
        private _seen = 0;            // 按钮序号（不是控件序号）
        private _next = -1;
        private _empty = 0;
        private _stop = false;
        private _lines = [];
        private _dIdx = 0;

        {
            private _disp = _x;
            private _cur = _dIdx;
            private _dcls = _disp getVariable ["BIS_fnc_initDisplay_configClass", ""];
            _dIdx = _dIdx + 1;
            {
                if (!_stop) then {
                    if ((ctrlType _x) isEqualTo 1) then {
                        if (_seen >= _offset) then {
                            if ((count _lines) >= _cap) then {
                                _next = _seen;
                                _stop = true;
                            } else {
                                private _act = buttonAction _x;
                                if (_act == "") then { _empty = _empty + 1; };
                                private _txt = [ctrlText _x] call _flatten;
                                _act = [_act] call _flatten;
                                private _fields = [
                                    str _cur, _dcls, str (ctrlIDC _x),
                                    ctrlClassName _x, _txt, _act
                                ];
                                private _line = _fields joinString "|";
                                if ((_used + (count _line)) > _budget) then {
                                    _next = _seen;
                                    _stop = true;
                                } else {
                                    _lines pushBack _line;
                                    _used = _used + (count _line) + 1;
                                };
                            };
                        };
                        _seen = _seen + 1;
                    };
                };
            } forEach (allControls _disp);
        } forEach allDisplays;

        if (!_stop) then { _next = -1; };
        // emptyAction 只统计本页里 action 为空的按钮：空 ≠ 不能点，它的处理器
        // 多半在 config 的 onButtonClick 里（用 handlers 分支查）。
        _hasCustom = true;
        private _text = _lines joinString toString [10];
        private _info = format ["buttons=%1 next=%2 emptyAction=%3",
                                _seen, _next, _empty];
        _custom = [_text, _info];
    };

    /* ── config 侧的处理器文本 ────────────────────────────────────────
       这是"UI 元素 → 功能"的另一半：运行时没有 getter 的那部分
       （onButtonClick）只有从 config 读。按类名与 snapshot 对齐即可合表。
       路径用遍历时拼出来的祖先链，因为 SQF 拿不到 config 的父节点。 */
    case "handlers": {
        private _cls = _arg1;
        if (_cls == "") then { _cls = "RscDisplayMain"; };
        private _budget = 12000;
        private _used = 0;
        private _nodes = 0;
        private _lines = [];
        private _root = configFile >> _cls;
        private _stack = [[_root, _cls]];

        while { (count _stack) > 0 && _nodes < 4000 && _used < _budget } do {
            private _node = _stack deleteAt 0;
            private _cfg = _node select 0;
            private _base = _node select 1;
            {
                private _c = _x;
                private _path = _base + "/" + (configName _c);
                _nodes = _nodes + 1;
                private _a = getText (_c >> "action");
                private _o = getText (_c >> "onButtonClick");
                if (_a != "" || _o != "") then {
                    _a = [_a] call _flatten;
                    _o = [_o] call _flatten;
                    private _line = [_path, _a, _o] joinString "|";
                    _lines pushBack _line;
                    _used = _used + (count _line) + 1;
                };
                _stack pushBack [_c, _path];
            // ⚠ configClasses 是**双参数**命令：`condition configClasses config`。
            // 写成单参数（`configClasses _cfg`）引擎报 "类型 Config entry，
            // 预期为 数组" —— 同一个坑 fn_configQuery.sqf 里已经记过一次。
            } forEach ("true" configClasses _cfg);
        };

        _hasCustom = true;
        private _text = _lines joinString toString [10];
        private _info = format ["class=%1 nodes=%2 handlers=%3",
                                _cls, _nodes, (count _lines)];
        _custom = [_text, _info];
    };

    default {
        [_cid, false,
         "uiQuery 不认识的操作：" + _op +
         "（可用：classes / find / snapshot / actions / handlers）"] call _reply;
        _scanned = -1;
    };
};

if (_hasCustom) then {
    [_cid, true, _custom] call _reply;
} else {
    if (_scanned >= 0) then {
        [_cid, true, [_items, _scanned]] call _reply;
    };
};
