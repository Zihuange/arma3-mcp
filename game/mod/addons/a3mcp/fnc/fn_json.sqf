/* a3mcp_fnc_jsonEscape —— 把字符串转义成可安全嵌入 JSON 的形态

为什么自己写：`toJSON` 会把**整个值**序列化（自带引号），而这里需要把若干
片段拼进一个 JSON 对象。不转义就拼，内容一旦含引号或反斜杠就产出非法 JSON，
上层解析失败——而且失败得很安静（表现为"没有回执"）。

实现说明：引号与反斜杠一律用**字符码**构造（toString [34] / [92]），
不写字面量转义。SQF 里写 `""""` 这类转义极易出错且难以审阅。
*/
params [["_s", "", [""]]];

private _quote = toString [34];
private _backslash = toString [92];
private _out = "";

{
    _out = _out + (switch (_x) do {
        case 34: { _backslash + _quote };   // "
        case 92: { _backslash + _backslash }; // backslash
        case 10: { _backslash + "n" };
        case 13: { _backslash + "r" };
        case 9:  { _backslash + "t" };
        default {
            if (_x < 32) then {
                private _hex = "0123456789abcdef";
                _backslash + "u00"
                    + (_hex select (floor (_x / 16)))
                    + (_hex select (_x mod 16))
            } else {
                toString [_x]
            };
        };
    });
} forEach (toArray _s);

_out
