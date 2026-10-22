/* a3mcp_fnc_fnList —— 列出**可调用的函数名**（给 call 的目标核对用）

args = [tag 过滤?, limit?]

## 为什么需要它

`call` 放开后（见 guard/gates.py 的 call_gated 级），函数名是作为**数据**传进来核对的。
核对需要一份"哪些函数名算数"的来源——这份来源不能靠人肉维护（装了模组就变），
只能从 `CfgFunctions` 现算。所以有了本函数。

## 拼接规则（实测得出，见 decisions.md D39）

    函数名 = <tag> + "_fnc_" + <叶子类名>

    CfgFunctions
      └── <T>            ← 直接子类，**tag 字段在这里读**
            └── <C>      ← 二级分类（Core / Arrays …），**不进名字**
                  └── <F> ← 函数类名，进名字

实测确认的细节（都不是推断）：
  · `a3mcp` 的 tag 是 `a3mcp`，其下只有 1 个分类 `Core`，含 22 个函数类；
  · `BIS` 的 tag 是 `BIS`；**`A3` / `A2PMC` 的 tag 也是 `BIS`**（不是"缺失"）；
  · `Ares` **没有 tag 字段** → 此时用**类名**当 tag；
  · 类名**保留原样大小写**；函数名查询**大小写不敏感**
    （`a3mcp_fnc_configQuery` 与全小写都能 cast 到 CODE）。

端到端验证过：按此规则拼出的 `BIS_fnc_sortBy` / `BIS_fnc_arrayShuffle` /
`a3mcp_fnc_uiQuery` 都能在 missionNamespace 里取到 **CODE**，而故意拼错的
`BIS_fnc_noSuchFunction` 取到 nil（对照成立，不是"随便拼都能中"）。

## 为什么不给 tag 过滤时就只报数

BIS 的函数有几千个，全量倾泻既没用（调用方看不完）也会撑爆回执。
所以不指定 tag 时返回**每个 tag 的名字与函数数**（概览），
指定 tag 时才列出函数名（受 limit 约束）。

回执一律经 fn_sendAck，不手写 JSON 转义。
*/
params [["_cid", "", [""]], ["_args", [], [[]]]];

private _tagFilter = toLower (_args param [0, "", [""]]);
private _limit = _args param [1, 200, [0]];

private _funcs = [];
private _total = 0;
private _tags = [];
private _truncated = false;

// 一次遍历同时完成"计数"与"收集"：这个函数会被反复调用，别扫两遍。
{
    private _tagCfg = _x;
    // tag 字段优先；没有该字段（实测 Ares 就是）则退回类名
    private _tagEntry = _tagCfg >> "tag";
    private _tagName = "";
    if (isText _tagEntry) then { _tagName = getText _tagEntry; };
    if (_tagName == "") then { _tagName = configName _tagCfg };

    if (_tagFilter == "" || { toLower _tagName == _tagFilter }) then {
        private _count = 0;
        {
            private _catCfg = _x;
            {
                _count = _count + 1;
                // 只有明确要某个 tag 时才收集函数名：否则几万条会把回执撑爆
                if (_tagFilter != "") then {
                    if (count _funcs < _limit) then {
                        _funcs pushBack (_tagName + "_fnc_" + configName _x);
                    } else {
                        _truncated = true;
                    };
                };
            } forEach ("true" configClasses _catCfg);
        } forEach ("true" configClasses _tagCfg);
        _total = _total + _count;
        _tags pushBack [_tagName, _count];
    };
} forEach ("true" configClasses (configFile >> "CfgFunctions"));

private _payload = createHashMapFromArray [
    ["functions", _funcs],
    ["total", _total],
    ["tags", _tags],
    ["truncated", _truncated],
    ["tagFilter", _tagFilter]
];
[_cid, true, _payload] call a3mcp_fnc_sendAck;
