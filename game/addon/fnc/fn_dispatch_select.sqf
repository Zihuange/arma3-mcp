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
    case "select": {
        // array select index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 select _p1;
    };
    case "select": {
        // array select boolean
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 select _p1;
    };
    case "select": {
        // config select index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 select _p1;
    };
    case "select": {
        // string select [start, length]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 select [_p1, _p2];
    };
    case "select": {
        // array select [start, count]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 select [_p1, _p2];
    };
    case "select": {
        // array select expression
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 select _p1;
    };
    case "selectbestplaces": {
        // selectBestPlaces [position, radius, expression, precision, sourcesCount]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        selectBestPlaces [_p0, _p1, _p2, _p3, _p4];
        _result = true;
    };
    case "selectdiarysubject": {
        // player selectDiarySubject subject
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 selectDiarySubject _p1;
    };
    case "selectededitorobjects": {
        // selectedEditorObjects map
        private _p0 = _args param [0];
        _result = selectedEditorObjects _p0;
    };
    case "selecteditorobject": {
        // map selectEditorObject object
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 selectEditorObject _p1;
    };
    case "selectionnames": {
        // selectionNames object
        private _p0 = _args param [0];
        _result = selectionNames _p0;
    };
    case "selectionnames": {
        // object selectionNames LOD
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 selectionNames _p1;
    };
    case "selectionposition": {
        // object selectionPosition selectionName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 selectionPosition _p1;
    };
    case "selectionposition": {
        // object selectionPosition [selectionName, LOD, returnMode]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = _p0 selectionPosition [_p1, _p2, _p3];
    };
    case "selectionposition": {
        // selectionPosition [object, selectionName, LODIndex, isVisual, returnMode]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _result = selectionPosition [_p0, _p1, _p2, _p3, _p4];
    };
    case "selectionvectordirandup": {
        // object selectionVectorDirAndUp [selectionName, LOD]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 selectionVectorDirAndUp [_p1, _p2];
    };
    case "selectleader": {
        // group selectLeader unitName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 selectLeader _p1;
        _result = true;
    };
    case "selectmax": {
        // selectMax array
        private _p0 = _args param [0];
        _result = selectMax _p0;
    };
    case "selectmin": {
        // selectMin array
        private _p0 = _args param [0];
        _result = selectMin _p0;
    };
    case "selectplayer": {
        // selectPlayer unitName
        private _p0 = _args param [0];
        selectPlayer _p0;
        _result = true;
    };
    case "selectrandom": {
        // selectRandom array
        private _p0 = _args param [0];
        _result = selectRandom _p0;
    };
    case "selectrandomweighted": {
        // selectRandomWeighted valuesAndWeights
        private _p0 = _args param [0];
        _result = selectRandomWeighted _p0;
    };
    case "selectrandomweighted": {
        // values selectRandomWeighted weights
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 selectRandomWeighted _p1;
    };
    case "selectweapon": {
        // unitName selectWeapon muzzleName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 selectWeapon _p1;
        _result = true;
    };
    case "selectweapon": {
        // unit selectWeapon [weapon, muzzle, firemode]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 selectWeapon [_p1, _p2, _p3];
        _result = true;
    };
    case "selectweaponturret": {
        // vehicle selectWeaponTurret [weapon, turretPath, muzzle, firemode]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _p0 selectWeaponTurret [_p1, _p2, _p3, _p4];
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
