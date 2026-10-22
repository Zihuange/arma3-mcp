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
params [["_expr", "", [""]], ["_argc", 0, [0]], ["_whitelist", [], [[]]]];

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
private _forbidden = [
    "compile", "compilefinal", "call", "spawn", "exec", "execvm", "execfsm",
    "callextension", "loadfile", "preprocessfile", "preprocessfilelinenumbers",
    "preprocessconfigfile", "remoteexec", "remoteexeccall", "bis_fnc_mp"
];
private _wl = [];
{ _wl pushBack (toLower _x); } forEach _whitelist;

private _used = [];
private _commands = [];
private _bad = "";
private _badReason = "";

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
                if (_low in _forbidden) then {
                    _bad = _tok;
                    _badReason = format [
                        "标识符 %1 属于硬禁命令（不得通过动态表达式触达）", _tok];
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
} forEach (toArray _expr);

// 收尾：表达式以标识符结尾时上面循环不会触发收尾分支
if (count _used > 0) then {
    private _tok = toString _used;
    private _low = toLower _tok;
    if ((!((_low select [0, 2]) == "_p")) && { !(_low in _wl) }) then {
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
