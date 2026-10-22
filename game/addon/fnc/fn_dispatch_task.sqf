/* 自动生成 —— 请勿手工编辑。
 *
 * 来源：tools/gen_dispatch.py（从命令库签名还原调用形式）
 * 生成的原则：只产出**静态**分发，不使用 compile/execVM —— 见 README 的安全模型。
 *
 * 参数：_fn 目标函数名、_args 参数数组（已由 MCP 侧校验类型）
 * 返回：[是否处理, 结果]
 */
params ["_fn", "_args"];
private _handled = true;
private _result = nil;

switch (toLower _fn) do {
    case "taskalwaysvisible": {
        // taskAlwaysVisible task
        private _p0 = _args param [0];
        _result = taskAlwaysVisible _p0;
    };
    case "taskchildren": {
        // taskChildren task
        private _p0 = _args param [0];
        _result = taskChildren _p0;
    };
    case "taskcompleted": {
        // taskCompleted task
        private _p0 = _args param [0];
        _result = taskCompleted _p0;
    };
    case "taskcustomdata": {
        // taskCustomData task
        private _p0 = _args param [0];
        taskCustomData _p0;
        _result = true;
    };
    case "taskdescription": {
        // taskDescription task
        private _p0 = _args param [0];
        _result = taskDescription _p0;
    };
    case "taskdestination": {
        // taskDestination task
        private _p0 = _args param [0];
        taskDestination _p0;
        _result = true;
    };
    case "taskhint": {
        // taskHint [text, colour, icon]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        taskHint [_p0, _p1, _p2];
        _result = true;
    };
    case "taskmarkeroffset": {
        // taskMarkerOffset unit
        private _p0 = _args param [0];
        _result = taskMarkerOffset _p0;
    };
    case "taskname": {
        // taskName task
        private _p0 = _args param [0];
        _result = taskName _p0;
    };
    case "taskparent": {
        // taskParent task
        private _p0 = _args param [0];
        _result = taskParent _p0;
    };
    case "taskresult": {
        // taskResult task
        private _p0 = _args param [0];
        _result = taskResult _p0;
    };
    case "taskstate": {
        // taskState task
        private _p0 = _args param [0];
        taskState _p0;
        _result = true;
    };
    case "tasktype": {
        // taskType task
        private _p0 = _args param [0];
        _result = taskType _p0;
    };
    default { _handled = false; };
};

[_handled, _result]
