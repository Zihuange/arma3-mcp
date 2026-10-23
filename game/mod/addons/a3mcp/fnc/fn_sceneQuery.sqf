/* a3mcp_fnc_sceneQuery —— 任务世界快照（场景 / 自身 / 任务 / 小队 / 地图）

输入：_args 数组，第 0 位是操作名，其后是该操作自己的参数
  ["scene", 半径, 上限, 偏移]   玩家周围的对象（单位/载具/军械），分页
  ["player"]                   玩家自身状态（一行一个 key=value）
  ["mission"]                  任务环境 + 原生任务列表
  ["squad"]                    本小队：编队、成员、航路点
  ["map", 上限, 偏移]           地图标记 + 触发器，分页

回执：一律 [文本, 元信息]，与 uiQuery 的 snapshot/actions/handlers 同形。

── 为什么要放在游戏侧（不是 MCP 侧拼表达式） ──

和 `uiQuery` 同一个理由，而且在任务世界里更严重：
  · MCP 侧动态表达式**每条 400 字符**，还没有局部变量 —— `allUnits apply {...}`
    这种遍历根本写不出来（`_x` 不在白名单，那是"命令名注入"的防线）；
  · 每次求值 `allUnits` / `nearestObjects` 都是**全量枚举**，一个场景几十次
    就退化成 O(n²)，而 MCP 的等待上限只有几秒；
  · 多个字段要拼成一张表时，往返次数还会乘以字段数。
所以"看一圈场上有什么"必须在游戏侧一次做完，再按大小分页回。

── 分页口径 ──

DLL 上行单行上限 16 KB（`kMaxLineOut`），超出的部分会被**静默截断**。
这里沿用 uiQuery 的做法：条数配额 + 12 KB 字符预算双保险，`next` 随回执返回。

── 数据形状 ──

统一"一行一条记录、字段用 `|` 分隔"，与 uiQuery 一致：嵌套数组要过
jsonStringify 的层层包装，体积翻倍且解包容易出错；扁平行最省也最好读。
字段里的 `|`、换行、制表符由 `_flatten` 压成空格。
*/

params [["_cid", "", [""]], ["_args", [], [[]]]];

private _op = toLower (_args param [0, "", [""]]);

private _reply = {
    params [["_cidIn", "", [""]], ["_okIn", true, [true]],
            ["_payloadIn", nil]];
    [_cidIn, _okIn, _payloadIn] call a3mcp_fnc_sendAck;
};

private _flatten = {
    params [["_txt", "", [""]]];
    _txt splitString (toString [10, 13, 9, 124]) joinString " "
};

// 坐标/伤害这类数值统一保留两位：既好读，也避免 `str` 对大数输出科学计数法
private _f2 = {
    params [["_v", 0, [0]]];
    str (round (_v * 100) / 100)
};

private _bt = {
    params [["_b", false, [true]]];
    if (_b) then { "1" } else { "0" }
};

// 类名 → displayName 缓存。同一场景里同类对象成百上千，不缓存就要反复翻 config。
private _dnCache = createHashMap;
private _displayName = {
    params [["_cls", "", [""]]];
    if (_cls == "") exitWith { "" };
    private _hit = _dnCache getOrDefault [_cls, ""];
    if (_hit != "") exitWith { _hit };
    private _txt = getText (configFile >> "CfgVehicles" >> _cls >> "displayName");
    if (_txt == "") then {
        _txt = getText (configFile >> "CfgWeapons" >> _cls >> "displayName");
    };
    if (_txt == "") then {
        _txt = getText (configFile >> "CfgMagazines" >> _cls >> "displayName");
    };
    _dnCache set [_cls, _txt];
    _txt
};

private _lines = [];
private _meta = "";
private _ok = true;
private _err = "";

switch (_op) do {

    /* ── 场景：玩家周围的对象 ─────────────────────────────────────────
       每行：kind|类名|显示名|阵营|距离|存活|伤害|对象名|所属载具|posATL
       kind: U=人 V=载具 O=其它（军械箱/武器架/静态武器） */
    case "scene": {
        private _radius = _args param [1, 50, [0]];
        if (_radius <= 0) then { _radius = 50; };
        private _cap = _args param [2, 0, [0]];
        if (_cap <= 0) then { _cap = 120; };
        private _offset = _args param [3, 0, [0]];
        private _budget = 12000;
        private _used = 0;
        private _total = 0;
        private _next = -1;
        private _stop = false;

        if (isNull player) then {
            [_cid, false, "场景快照需要本机有玩家（专用服务器没有 player）"] call _reply;
            _ok = false;
        } else {
            private _center = getPosATL player;
            private _types = [
                "Man", "Car", "Tank", "Air", "Ship", "StaticWeapon",
                "GroundWeaponHolder", "WeaponHolderSimulated", "ReammoBox_F"
            ];
            private _objs = nearestObjects [_center, _types, _radius];
            _meta = format ["radius=%1 candidates=%2", _radius, (count _objs)];

            {
                private _g = _total;
                _total = _total + 1;
                if (!_stop && {_g >= _offset}) then {
                    if ((count _lines) >= _cap) then {
                        _next = _g;
                        _stop = true;
                    } else {
                        private _o = _x;
                        private _cls = typeOf _o;
                        private _kind = "O";
                        if (_o isKindOf "Man") then { _kind = "U"; } else {
                            if (_o isKindOf "AllVehicles") then { _kind = "V"; };
                        };
                        private _pos = getPosATL _o;
                        private _veh = vehicle _o;
                        private _vehCls = "";
                        if (_veh != _o) then { _vehCls = typeOf _veh; };
                        // 只有人能用 name；对载具/军械调用它会返回字面量
                        // "Error: No unit" —— 那不是名字，是错误占位符。
                        private _uname = "";
                        if (_kind == "U") then { _uname = name _o; };
                        private _fields = [
                            _kind, _cls,
                            ([_cls] call _displayName),
                            str (side _o),
                            ([_center distance _o] call _f2),
                            ([alive _o] call _bt),
                            ([damage _o] call _f2),
                            ([_uname] call _flatten),
                            _vehCls,
                            ([_pos select 0] call _f2),
                            ([_pos select 1] call _f2),
                            ([_pos select 2] call _f2)
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
            } forEach _objs;

            if (!_stop) then { _next = -1; };
            _meta = _meta + format [" total=%1 next=%2 bytes=%3", _total, _next, _used];
        };
    };

    /* ── 自身状态 ────────────────────────────────────────────────────
       每行 key=value。武器/装具只给类名，显示名由调用方按需查（省一半体积）。 */
    case "player": {
        if (isNull player) then {
            [_cid, false, "玩家状态需要本机有玩家（专用服务器没有 player）"] call _reply;
            _ok = false;
        } else {
            private _p = player;
            private _pos = getPosATL _p;
            private _veh = vehicle _p;
            private _grp = group _p;
            private _magList = magazines _p;

            private _kv = {
                params [["_k", "", [""]], ["_v", "", [""]]];
                _lines pushBack (_k + "=" + ([_v] call _flatten));
            };
            ["name", name _p] call _kv;
            ["class", typeOf _p] call _kv;
            ["side", str (side _p)] call _kv;
            private _posTxt = format ["%1,%2,%3",
                ([_pos select 0] call _f2),
                ([_pos select 1] call _f2),
                ([_pos select 2] call _f2)];
            ["pos", _posTxt] call _kv;
            ["dir", ([getDir _p] call _f2)] call _kv;
            ["stance", stance _p] call _kv;
            ["lifeState", lifeState _p] call _kv;
            ["damage", ([damage _p] call _f2)] call _kv;
            ["alive", ([alive _p] call _bt)] call _kv;
            ["weapon", currentWeapon _p] call _kv;
            ["primary", primaryWeapon _p] call _kv;
            ["secondary", secondaryWeapon _p] call _kv;
            ["handgun", handgunWeapon _p] call _kv;
            ["mags", (_magList joinString ",")] call _kv;
            ["magCount", str (count _magList)] call _kv;
            ["items", (items _p joinString ",")] call _kv;
            ["uniform", uniform _p] call _kv;
            ["vest", vest _p] call _kv;
            ["headgear", headgear _p] call _kv;
            ["backpack", backpack _p] call _kv;
            ["vehicle", (if (_veh == _p) then { "" } else { typeOf _veh })] call _kv;
            ["seat", (if (_veh == _p) then { "" } else { str (assignedVehicleRole _p) })] call _kv;
            ["group", groupId _grp] call _kv;
            ["groupSize", str (count units _grp)] call _kv;
            ["leader", name (leader _grp)] call _kv;
            ["isLeader", ([(leader _grp) == _p] call _bt)] call _kv;
            ["role", roleDescription _p] call _kv;
            ["rank", rank _p] call _kv;
            ["viewDistance", str viewDistance] call _kv;
            ["dayTime", str dayTime] call _kv;
            ["overcast", ([overcast] call _f2)] call _kv;
            _meta = format ["fields=%1", (count _lines)];
        };
    };

    /* ── 任务环境 + 原生任务列表 ─────────────────────────────────────
       前若干行 key=value，随后任务行：task|id|state|title|type|dest */
    case "mission": {
        private _kv = {
            params [["_k", "", [""]], ["_v", "", [""]]];
            _lines pushBack (_k + "=" + ([_v] call _flatten));
        };
        ["missionName", missionName] call _kv;
        ["worldName", worldName] call _kv;
        ["isMultiplayer", ([isMultiplayer] call _bt)] call _kv;
        ["dayTime", ([dayTime] call _f2)] call _kv;
        ["date", (str date)] call _kv;
        ["overcast", ([overcast] call _f2)] call _kv;
        ["fog", ([fog] call _f2)] call _kv;
        ["rain", ([rain] call _f2)] call _kv;
        ["wind", (str wind)] call _kv;
        ["viewDistance", str viewDistance] call _kv;
        ["difficulty", str difficulty] call _kv;
        ["briefing", getText (missionConfigFile >> "briefing")] call _kv;

        // 任务/日记：引擎里**没有** `simpleTasks` —— 实测编译期直接报
        // "表达式中的数字无效"（这条命令只存在于命令库/wiki，引擎并不认）。
        // 原生任务挂在日记里，入口是 `player allDiaryRecords <主题>`。
        private _subjects = ["Tasks", "Diary", "Briefing", "Intel"];
        private _recs = 0;
        if (!isNull player) then {
            {
                private _subject = _x;
                private _records = player allDiaryRecords _subject;
                {
                    private _r = _x;
                    private _title = getText (_r >> "title");
                    private _body = getText (_r >> "text");
                    private _fields = [
                        "diary", _subject,
                        ([_title] call _flatten),
                        ([_body] call _flatten)
                    ];
                    _lines pushBack (_fields joinString "|");
                    _recs = _recs + 1;
                } forEach _records;
            } forEach _subjects;
        };
        ["diaryCount", str _recs] call _kv;
        _meta = format ["diary=%1", _recs];
    };

    /* ── 小队 ────────────────────────────────────────────────────────
       先 squad= 一行，随后 member|名字|军衔|角色|状态|伤害|距离|载具，
       再 waypoint|序号|类型|位置|战斗模式|行为 */
    case "squad": {
        if (isNull player) then {
            [_cid, false, "小队状态需要本机有玩家（专用服务器没有 player）"] call _reply;
            _ok = false;
        } else {
            private _grp = group player;
            private _center = getPosATL player;
            private _kv = {
                params [["_k", "", [""]], ["_v", "", [""]]];
                _lines pushBack (_k + "=" + ([_v] call _flatten));
            };
            ["group", groupId _grp] call _kv;
            ["leader", name (leader _grp)] call _kv;
            ["size", str (count units _grp)] call _kv;
            ["formation", formation _grp] call _kv;
            ["combatMode", combatMode _grp] call _kv;
            ["behaviour", behaviour (leader _grp)] call _kv;
            ["speed", speedMode _grp] call _kv;
            ["currentWaypoint", str (currentWaypoint _grp)] call _kv;

            private _members = units _grp;
            {
                private _u = _x;
                private _veh = vehicle _u;
                private _fields = [
                    "member",
                    ([name _u] call _flatten),
                    rank _u,
                    ([roleDescription _u] call _flatten),
                    lifeState _u,
                    ([damage _u] call _f2),
                    ([_center distance _u] call _f2),
                    (if (_veh == _u) then { "" } else { typeOf _veh }),
                    ([alive _u] call _bt),
                    ([_u == player] call _bt)
                ];
                _lines pushBack (_fields joinString "|");
            } forEach _members;

            private _wps = waypoints _grp;
            {
                private _w = _x;
                private _wpos = waypointPosition _w;
                private _fields = [
                    "waypoint",
                    str (_forEachIndex),
                    waypointType _w,
                    ([_wpos select 0] call _f2),
                    ([_wpos select 1] call _f2),
                    waypointCombatMode _w,
                    waypointBehaviour _w,
                    waypointSpeed _w
                ];
                _lines pushBack (_fields joinString "|");
            } forEach _wps;

            _meta = format ["members=%1 waypoints=%2",
                            (count _members), (count _wps)];
        };
    };

    /* ── 地图：标记 + 触发器 ──────────────────────────────────────────
       marker|名字|类型|颜色|x|y|尺寸|透明度|文本|是否折线
       trigger|名|类型|x|y|宽|高|是否矩形|角度|文本|条件（文本，供人看） */
    case "map": {
        private _cap = _args param [1, 0, [0]];
        if (_cap <= 0) then { _cap = 150; };
        private _offset = _args param [2, 0, [0]];
        private _budget = 12000;
        private _used = 0;
        private _total = 0;
        private _next = -1;
        private _stop = false;

        private _marks = allMapMarkers;
        private _trigs = allMissionObjects "EmptyDetector";

        {
            private _g = _total;
            _total = _total + 1;
            if (!_stop && {_g >= _offset}) then {
                if ((count _lines) >= _cap) then {
                    _next = _g;
                    _stop = true;
                } else {
                    private _m = _x;
                    private _pos = markerPos _m;
                    private _size = markerSize _m;
                    private _fields = [
                        "marker", _m, markerType _m, markerColor _m,
                        ([_pos select 0] call _f2),
                        ([_pos select 1] call _f2),
                        ([_size select 0] call _f2),
                        ([markerAlpha _m] call _f2),
                        ([markerText _m] call _flatten),
                        ([(markerShape _m) == "POLYLINE"] call _bt)
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
        } forEach _marks;

        {
            private _g = _total;
            _total = _total + 1;
            if (!_stop && {_g >= _offset}) then {
                if ((count _lines) >= _cap) then {
                    _next = _g;
                    _stop = true;
                } else {
                    private _t = _x;
                    private _pos = getPosATL _t;
                    private _area = triggerArea _t;
                    private _stmts = triggerStatements _t;
                    private _cond = "";
                    if ((count _stmts) > 0) then { _cond = _stmts select 0; };
                    private _fields = [
                        "trigger",
                        ([str _t] call _flatten),
                        triggerType _t,
                        ([_pos select 0] call _f2),
                        ([_pos select 1] call _f2),
                        ([_area select 0] call _f2),
                        ([_area select 1] call _f2),
                        // triggerArea = [宽, 高, 角度, 是否矩形]：第 3 位是角度，
                        // 按布尔取会让每个触发器都显示成"矩形"。
                        ([_area select 3] call _bt),
                        ([_area select 2] call _f2),
                        ([triggerText _t] call _flatten),
                        ([_cond] call _flatten)
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
        } forEach _trigs;

        if (!_stop) then { _next = -1; };
        _meta = format ["markers=%1 triggers=%2 total=%3 next=%4 bytes=%5",
                        (count _marks), (count _trigs), _total, _next, _used];
    };

    default {
        [_cid, false,
         "sceneQuery 不认识的操作：" + _op +
         "（可用：scene / player / mission / squad / map）"] call _reply;
        _ok = false;
    };
};

if (_ok) then {
    private _text = _lines joinString toString [10];
    [_cid, true, [_text, _meta]] call _reply;
};
