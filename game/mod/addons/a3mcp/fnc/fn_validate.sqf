/* a3mcp_fnc_validate —— 表达式的词法校验（下发后的第二道防线）

判据与 MCP 侧 knowledge/expr.py 保持一致，但**独立实现、独立执行**：
MCP 侧校验可能在版本错配或实现漂移时失效，而这里是游戏进程内的最后一道。

被编译的表达式里每个标识符必须是：
  · `_p<数字>` 占位符，且下标 < 参数个数；
  · 或在白名单内。
另外：**禁止分号**（一条请求只能一条语句——否则可以塞多语句绕过按命令计数的
审计与限流），**禁止双引号**（参数必须是数据，不得以字符串形式写进表达式）。

返回 [是否通过, 白名单中出现的命令名数组, 错误原因]。
*/
params [["_expr", "", [""]], ["_argc", 0, [0]], ["_whitelist", [], [[]]],
        ["_args", [], [[]]]];

if (_expr == "") exitWith { [false, [], "表达式为空"] };
if (count _expr > 400) exitWith { [false, [], "表达式过长（上限 400 字符）"] };
if ((_expr find ";") >= 0) exitWith {
    [false, [], "表达式含分号：一条请求只允许一条语句"]
};
if ((_expr find (toString [34])) >= 0) exitWith {
    [false, [], "表达式含双引号：参数必须以数据形式传入"]
};

// SQF 侧的判据是**硬禁清单**，而不是完整白名单。
//
// 为什么不是白名单：MCP 是唯一入口（DLL 只接受 MCP 的连接），完整白名单
// （2500+ 条）由 MCP 侧校验；把它整份传给 SQF 既浪费（每次命令几十 KB），
// 也修不了真正的威胁。SQF 侧保留的职责是纵深防御——拒绝最危险的关键字，
// 这样即使 MCP 侧校验被绕过，也无法在这里执行 compile/execVM 之类。
//
// `call` **不在**下面这个清单里：它是"有条件放行"的一级，函数名逐个核对。
// 它的纵深防御在紧随其后的 _callDeny 清单里独立实现（不依赖 MCP 侧是否守规矩）。
private _forbidden = [
    "compile", "compilefinal", "spawn", "exec", "execvm", "execfsm",
    "callextension", "loadfile", "preprocessfile", "preprocessfilelinenumbers",
    "preprocessconfigfile", "remoteexec", "remoteexeccall", "bis_fnc_mp"
];

// call 的目标函数名：这一类永远不能调。
//
// 与 MCP 侧 guard/gates.py 的 CALL_DENY 是**独立实现**——这正是纵深防御的意义：
// 两边都漏同一处才算漏。清单收的是"能把字符串变成代码"的执行类函数，
// 它们会让 call 退化成 compile。
private _callDeny = [
    "bis_fnc_execvm", "bis_fnc_execfsm", "bis_fnc_spawn",
    "bis_fnc_codeperformance", "bis_fnc_dbg_remotelyexec",
    "bis_fnc_mp", "bis_fnc_callsqf",
    "call", "compile", "compilefinal", "spawn", "execvm", "execfsm",
    "callextension", "remoteexec", "remoteexeccall"
];
private _callDenyPrefixes = [
    "bis_fnc_exec", "bis_fnc_spawn", "bis_fnc_dbg_",
    "bis_fnc_codeperformance", "bis_fnc_callsqf", "spawn_", "exec_"
];

private _wl = [];
{ _wl pushBack (toLower _x); } forEach _whitelist;

// ⚠ 展开形态里的 `_this` / `(select N)` 要**豁免**，但**绝不能**往 `_wl` 里 push。
//
// 踩过这个坑：这里曾经写 `_wl pushBackUnique "_this"`，而 SQF 侧的策略是
// "白名单为空 = 只挡禁区，完整白名单由 MCP 负责"（见下面的注释）。push 一个
// 元素就把它从"空"变成"非空"，于是**全量白名单校验被意外启用**——列表里只有
// `_this` 一条，其它所有命令（连 `select`、`typeName`）统统被判"不在白名单内"，
// 表现为"带参表达式全部被拒"。
//
// 所以豁免写在检查处，不写进名单：名单的"空/非空"语义是有意的开关。
//
// 清单与 MCP 侧 `knowledge/expr.py::IMPLICIT_VARIABLES` 同步（那边有论证：
// 命令库 5181 条里以 `_` 开头的命令名有 **0 条**，所以 `_` 开头者必是变量读取，
// 不可能成为命令调用）。`select` 不是变量，它是展开形态里的命令，一并豁免。
private _implicitTokens = ["_this", "_x", "_foreachindex", "_exception", "select"];
private _isExpansionToken = {
    params [["_low", "", [""]]];
    _low in _implicitTokens
};

// 把表达式切成 token，用于定位 `call` 的目标。
//
// 为什么不复用上面的字符循环：那条循环是"边走边校验"的，没有留下 token 序列；
// 而 call 的校验需要**看后一个 token**。为此再切一遍比改造那条循环更清楚——
// 后者是这个文件里最容易写错的地方（注释里记着两处因此踩过的坑）。
//
// ⚠ 括号必须切开：展开形态的目标是 `(_this select 1)`，不切的话它整个是一枚
// token（`"(_this"` / `"select"` / `"1)"`），识别不了。分隔符集合要与解析侧
// （tools 与 MCP 的展开逻辑）一致，否则又是一次"自己人的输出自己看不懂"。
// ⚠ 切分规则必须与 MCP 侧**严格一致**（那边是 `adapters/exec_tools.split_tokens`，
// 用 `re.split(r"[ \t()\[\]{},]+")`）。两侧不一致的代价实测过三次：
// 症状是"call 的目标形态无法识别"，即 SQF 校验器认不出 MCP 自己发下去的表达式，
// 而报错看起来像安全策略在正常拒绝——最容易被当成"安全生效了"的那种假象。
//
// 规则（全部分隔符都**丢弃**，不作为 token 保留）：
//   空白 ` \t`、圆括号 `()`、方括号 `[]`、花括号 `{}`、逗号 `,`
private _splitExpr = {
    params [["_s", "", [""]]];
    private _tokens = [];
    private _acc = [];
    {
        private _c = _x;
        if (_c in [32, 9, 40, 41, 91, 93, 123, 125, 44]) then {
            if (count _acc > 0) then {
                _tokens pushBack (toString _acc);
                _acc = [];
            };
        } else {
            _acc pushBack _c;
        };
    } forEach (toArray _s);
    if (count _acc > 0) then { _tokens pushBack (toString _acc) };
    _tokens
};

// 从 token 流里取 `call` 目标的**参数下标**；认不出来返回 -1。
//
// 两种合法形态都要认：
//   `_p0 call _p1`               → 原始形态（调用方直接下发）
//   `_p0 call (_this select 1)`  → MCP 侧展开占位符后的形态
//
// 第二种曾被我漏掉，症状是：MCP 侧刚把带参表达式修好，call 反而全线报
// "目标必须写成占位符" —— 一条**假拒绝**：看起来像安全策略在起作用，
// 实际是校验器不认识自己人发下来的东西。展开顺序与校验顺序必须对齐。
private _targetSlotOf = {
    params [["_tokens", [], [[]]], ["_i", 0, [0]]];
    if (_i >= (count _tokens)) exitWith { -1 };

    private _next = _tokens select _i;
    private _nextLow = toLower _next;
    if ((_nextLow select [0, 2]) == "_p") exitWith {
        parseNumber (_nextLow select [2, count _nextLow - 2]);
    };
    // 展开形态 `call (_this select N)`
    //
    // ⚠ 形态判断要写成**顺序的 if/exitWith**，不要写成
    // `if (cond) then { exitWith {…} }` 嵌套——`exitWith` 退出的是**整个代码块**，
    // 嵌在 `then` 里会连带退出外层，后面的分支再也走不到（实测这么写过）。
    if ((toLower _next) == "_this"
            && { (toLower (_tokens select (_i + 1))) == "select" }) exitWith {
        parseNumber (_tokens select (_i + 2));
    };
    // 下发形态 `call (missionNamespace getVariable N)`
    //
    // 引擎要求 call 的右操作数在编译期可确定（`call (_this select 1)` 会被拒，
    // 实测 Error position: <call (_this select 1)>），所以函数名先经 getVariable
    // 取回来。括号在切分时已被去掉，参数就紧跟 getVariable：
    //   `_this select N`（展开形态的内层）或 `_pN`（原始形态）
    if ((toLower _next) == "missionnamespace") exitWith {
        private _deny = -1;
        // 索引按"括号已被丢弃"来算：`_i`=missionNamespace，`_i+1`=getVariable，
        // `_i+2` 起才是参数。差一位的写法（把 getVariable 记在 _i+2）会一路
        // 落到 -1，症状是"形态无法识别"——看起来像策略在正常拒绝。
        if ((toLower (_tokens select (_i + 1))) == "getvariable") then {
            private _inner = toLower (_tokens select (_i + 2));
            if (_inner == "_this") then {
                if ((toLower (_tokens select (_i + 3))) == "select") then {
                    _deny = parseNumber (_tokens select (_i + 4));
                };
            } else {
                if ((_inner select [0, 2]) == "_p") then {
                    _deny = parseNumber (_inner select [2, count _inner - 2]);
                };
            };
        };
        _deny
    };
    -1
};

// call 的目标函数名：必须来自**数据**，且不在 _callDeny / 拒绝前缀里。
//
// "来自数据"是这一层能成立的前提：写进表达式文本的话，调用什么就固定在文本里，
// 逐个核对也就无从谈起。
private _checkCallTarget = {
    params [["_exprText", "", [""]]];
    private _tokens = [_exprText] call _splitExpr;

    private _slot = -1;
    private _seenCall = false;
    {
        if ((toLower _x) == "call") then {
            _seenCall = true;
            _slot = [_tokens, _forEachIndex + 1] call _targetSlotOf;
        };
    } forEach _tokens;

    // 没有 call：这一层没意见。
    if (!_seenCall) exitWith { [true, ""] };
    // 有 call、但目标**两种合法形态都不是** → 拒绝。
    // 这里不能"不认识就放过"：那等于给"换个伪装写法"留了一条路，
    // 而 MCP 侧一旦漏掉（它只认原始形态），这里就是唯一还站着的一道。
    if (_slot < 0) exitWith {
        [false, "call 的目标形态无法识别：只接受 `_p0 call _p1` 或展开后的"
            + " `call (_this select N)`"]
    };

    if ((count _args) <= _slot) exitWith {
        [false, format ["call 的目标下标 %1 没有对应实参", _slot]]
    };

    private _fn = (_args select _slot) + "";
    private _low = toLower _fn;
    if (_low in _callDeny) exitWith {
        [false, format ["call 的目标 %1 被永久拒绝（执行类/远程类官方函数）", _fn]]
    };

    private _deniedByPrefix = "";
    {
        if ((_low select [0, count _x]) == _x) then {
            _deniedByPrefix = _x;
        };
    } forEach _callDenyPrefixes;
    if (_deniedByPrefix != "") exitWith {
        [false, format ["call 的目标 %1 被永久拒绝（命中拒绝前缀 %2*）",
            _fn, _deniedByPrefix]]
    };

    [true, ""]
};

private _used = [];
private _commands = [];
private _bad = "";
private _badReason = "";

// 纯数字 token：**不是标识符**，白名单校验要跳过它。
//
// 为什么需要：切分把数字也算作词的一部分（为了让 `_p0` 不被切成 `_p`），
// 于是**展开形态**里的下标 `0`/`1` 会以独立 token 的身份走到白名单校验，
// 被判成"标识符 0 不在白名单内"——合法表达式被自己的校验器拒掉。
// 实测踩到：`typeName (_this select 0)` 报"标识符 0 不在白名单内"。
private _isAllDigits = {
    params [["_tok", "", [""]]];
    private _digits = toArray "0123456789";
    private _ok = (count _tok > 0);
    { if (!(_x in _digits)) then { _ok = false }; } forEach (toArray _tok);
    _ok
};

// 词法切分：字母/下划线开头、后接字母数字下划线的连续串即一个标识符
{
    private _ch = _x;
    // ⚠ 数字必须算"词的一部分"：否则 _p0 会被切成 "_p"（'0' 被当分隔符），
    // 于是占位符校验报"名字格式不对"——而它看起来完全合法。
    // 这类切分错误极难从报错反推，因为报错指向的是校验规则而不是切分逻辑。
    private _isWord = (_ch in (toArray "abcdefghijklmnopqrstuvwxyz"))
        || (_ch in (toArray "ABCDEFGHIJKLMNOPQRSTUVWXYZ"))
        || (_ch in (toArray "0123456789"))
        || (_ch == 95);
    if (_isWord) then {
        _used pushBack _ch;
    } else {
        if (count _used > 0) then {
            private _tok = toString _used;
            _used = [];
            private _low = toLower _tok;
            if ((_low select [0, 2]) == "_p") then {
                // 占位符：下标必须落在参数范围内
                private _idxStr = _low select [2, count _low - 2];
                private _ok = (count _idxStr > 0);
                {
                    if (_x < 48 || { _x > 57 }) then { _ok = false };
                } forEach (toArray _idxStr);
                if (!_ok) then {
                    _bad = _tok;
                    _badReason = "占位符名格式不对（应为 _p0、_p1 …）";
                } else {
                    if ((parseNumber _idxStr) >= _argc) then {
                        _bad = _tok;
                        _badReason = format [
                            "占位符 %1 越界：本次只有 %2 个参数", _tok, _argc];
                    };
                };
            } else {
                // 纯数字不是标识符：它是展开形态的下标（`_this select 0`）。
                // 不跳过的话，合法表达式会被判"标识符 0 不在白名单内"。
                if (([_tok] call _isAllDigits) || { [_low] call _isExpansionToken }) then {
                    _commands pushBackUnique _low;
                } else {
                if (_low in _forbidden) then {
                    _bad = _tok;
                    _badReason = format [
                        "标识符 %1 属于硬禁命令（不得通过动态表达式触达）", _tok];
                } else {
                    // call 是有条件放行的一级：函数名逐个核对，核对不过就整条拒绝。
                    // 这里放在白名单校验**之前**：目标是数据，可能根本不在表达式里，
                    // 靠白名单看不出来。
                    private _callVerdict = [true, ""];
                    if (_low == "call") then {
                        _callVerdict = [_expr] call _checkCallTarget;
                    };
                    if (!(_callVerdict select 0)) then {
                        _bad = _tok;
                        _badReason = _callVerdict select 1;
                    } else {
                        // 传了白名单就按白名单校验（MCP 侧可选传精简白名单）；
                        // 没传则只挡禁区——完整校验由 MCP 负责
                        if ((count _wl) > 0 && { !(_low in _wl) }) then {
                            _bad = _tok;
                            _badReason = format [
                                "标识符 %1 不在白名单内且不是参数占位符", _tok];
                        } else {
                            _commands pushBackUnique _low;
                        };
                    };
                };
                };
            };
        };
    };
} forEach (toArray _expr);

// 收尾：表达式以标识符结尾时上面循环不会触发收尾分支
if (count _used > 0) then {
    private _tok = toString _used;
    private _low = toLower _tok;
    // ⚠ 这里必须和上面循环内一样带 `(count _wl) > 0` 守卫。
    //
    // 漏掉它时（本行曾经就是漏的），MCP 不传白名单（_wl 为空）的场景下
    // `_low in []` 恒为 false、`!false` 恒为 true，于是**任何以词字符结尾的
    // 表达式都会被误判为"标识符不在白名单内"**。
    //
    // 破坏面比看上去大得多：词法切分把数字也算作词的一部分（为了 _p0 不被
    // 切成 _p），所以 `(allUnits) select 0` 末尾那个 0 会被当成标识符 0 而
    // 报"标识符 0 不在白名单内"。实测中 worldName 与 (allUnits) select 0
    // 两条都倒在这里，等于动态表达式功能整体不可用。
    if ((!((_low select [0, 2]) == "_p")) && { (count _wl) > 0 }
            && { !(_low in _wl) }) then {
        _bad = _tok;
        _badReason = format ["标识符 %1 不在白名单内", _tok];
    } else {
        if ((_low select [0, 2]) == "_p") then {
            private _idxStr = _low select [2, count _low - 2];
            if ((parseNumber _idxStr) >= _argc) then {
                _bad = _tok;
                _badReason = format ["占位符 %1 越界", _tok];
            };
        } else {
            _commands pushBackUnique _low;
        };
    };
};

if (_bad != "") exitWith { [false, [], _badReason] };
if (count _commands == 0) exitWith {
    [false, [], "表达式里没有白名单命令（只有占位符或运算符）"]
};
[true, _commands, ""]
