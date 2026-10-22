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
    case "unitaddons": {
        // unitAddons className
        private _p0 = _args param [0];
        _result = unitAddons _p0;
    };
    case "unitaimposition": {
        // unitAimPosition unit
        private _p0 = _args param [0];
        _result = unitAimPosition _p0;
    };
    case "unitaimpositionvisual": {
        // unitAimPositionVisual unit
        private _p0 = _args param [0];
        _result = unitAimPositionVisual _p0;
    };
    case "unitbackpack": {
        // unitBackpack unit
        private _p0 = _args param [0];
        _result = unitBackpack _p0;
    };
    case "unitcombatmode": {
        // unitCombatMode unit
        private _p0 = _args param [0];
        _result = unitCombatMode _p0;
    };
    case "unitisuav": {
        // unitIsUAV object
        private _p0 = _args param [0];
        _result = unitIsUAV _p0;
    };
    case "unitpos": {
        // unitPos unit
        private _p0 = _args param [0];
        _result = unitPos _p0;
    };
    case "unitready": {
        // unitReady unitName
        private _p0 = _args param [0];
        _result = unitReady _p0;
    };
    case "unitrecoilcoefficient": {
        // unitRecoilCoefficient soldier
        private _p0 = _args param [0];
        _result = unitRecoilCoefficient _p0;
    };
    case "units": {
        // units type
        private _p0 = _args param [0];
        units _p0;
        _result = true;
    };
    case "unitsbelowheight": {
        // units unitsBelowHeight height
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 unitsBelowHeight _p1;
        _result = true;
    };
    case "unitsbelowheight": {
        // group unitsBelowHeight height
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 unitsBelowHeight _p1;
        _result = true;
    };
    case "unitturret": {
        // vehicle unitTurret gunner
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 unitTurret _p1;
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
