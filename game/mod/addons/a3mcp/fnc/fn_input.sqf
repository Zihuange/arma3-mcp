/* a3mcp_fnc_input —— 把输入注入 / 视觉捕捉类命令转发给扩展执行

## 为什么需要这一层

这些能力的实现在 DLL 内（游戏进程内才能判定前台窗口归属、才能抓本进程的
DirectX 画面），但 MCP 下发的命令**统一进入 SQF 的执行队列**。所以由 SQF
转一手：

    MCP --TCP--> DLL(入队) --> SQF(取命令) --callExtension--> DLL(真正执行)
                                          <--返回 JSON-----
    SQF --回执--> DLL --> MCP

## 转发形式必须是单字符串

DLL 侧按 `"cmd arg1 arg2 …"` 解析。不用数组形式 `[cmd, [args]]`：实测该形式
在引擎侧参数传递不可靠（poll 的返回布局、push 的参数都因此出过问题），
单字符串形式把参数直接编进命令名，没有中间层。

参数拼接收规则：
  · 字符串（如截图输出路径）**原样拼接**，不加引号
  · 数字用 str 转换（DLL 侧按整数解析，坐标/按钮/毫秒都是整数）

## 关于 callExtension 的两条硬约束（已查证 BI wiki）

  · 它是**阻塞**的：游戏会等扩展返回。所以 DLL 侧这些函数都不做长耗时操作，
    网络 I/O 也全在后台线程。
  · 扩展单次返回上限 **10240 字节**。所以截图**不走返回值**，而是 DLL 写文件、
    MCP 侧读文件 —— 图片体积远超这个限制。
*/
params [["_cid", "", [""]], ["_args", [], [[]]], ["_verb", "", [""]]];

if (_verb == "") exitWith {
    [_cid, false, "input 转发缺少命令名"] call a3mcp_fnc_sendAck
};

// 拼成 "verb p1 p2 …"
private _cmd = _verb;
{
    if (_x isEqualType "") then {
        _cmd = _cmd + " " + _x;
    } else {
        _cmd = _cmd + " " + (str _x);
    };
} forEach _args;

private _r = "arma3_mcp" callExtension _cmd;

// 扩返回非字符串时（例如引擎报错码）统一转成可读文本，
// 否则后面拼 JSON 会得到 nil 相关的一堆难懂报错。
if !(_r isEqualType "") then {
    _r = str _r;
};

// 空返回 = 扩展没给出结果。这必须显式表达，不能让上层把"空"当成"成功"。
if (_r == "") then {
    [_cid, false, "扩展无响应（命令已发出但未返回结果）：" + _cmd]
        call a3mcp_fnc_sendAck;
} else {
    // _r 本身就是 JSON（如 {"ok":true,...}），直接嵌进回执的 result 字段，
    // 不要再经过一次序列化 —— 那会把它变成"JSON 字符串"而不是 JSON 对象。
    private _ack = [_cid, true, _r] call a3mcp_fnc_ackJson;
    [_ack] call a3mcp_fnc_pushResult;
}
