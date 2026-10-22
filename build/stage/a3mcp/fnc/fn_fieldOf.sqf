/* a3mcp_fnc_fieldOf —— 从 JSON 文本里取一个顶层字符串字段

刻意保守：只用在**错误路径**上取 cid（好把错误回报给正确的请求）。
正常路径一律用 fromJSON 完整解析。

为什么不全部用 fromJSON：错误路径要尽量少依赖东西——若 fromJSON 本身出问题，
"报告错误"这件事也会跟着坏掉。这个函数只用字符串操作，不会抛错。
*/
params [["_json", "", [""]], ["_key", "", [""]]];

private _q = toString [34];
private _needle = _q + _key + _q;         // "key"

private _pos = _json find _needle;
if (_pos < 0) exitWith { "" };

private _rest = _json select [_pos + count _needle, count _json];
private _colon = _rest find ":";
if (_colon < 0) exitWith { "" };

_rest = trim (_rest select [_colon + 1, count _rest]);
if (_rest == "" || { (_rest select [0, 1]) != _q }) exitWith { "" };

_rest = _rest select [1, count _rest];
private _end = _rest find _q;
if (_end < 0) exitWith { "" };

_rest select [0, _end]
