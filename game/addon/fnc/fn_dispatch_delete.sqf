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
    case "delete3denentities": {
        // delete3DENEntities  entities
        private _p0 = _args param [0];
        delete3DENEntities  _p0;
        _result = true;
    };
    case "deleteat": {
        // array deleteAt index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 deleteAt _p1;
    };
    case "deleteat": {
        // hashMap deleteAt key
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 deleteAt _p1;
    };
    case "deletecenter": {
        // deleteCenter side
        private _p0 = _args param [0];
        deleteCenter _p0;
        _result = true;
    };
    case "deletecollection": {
        // deleteCollection object
        private _p0 = _args param [0];
        deleteCollection _p0;
        _result = true;
    };
    case "deleteeditorobject": {
        // map deleteEditorObject object
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 deleteEditorObject _p1;
    };
    case "deletegroup": {
        // deleteGroup group
        private _p0 = _args param [0];
        deleteGroup _p0;
        _result = true;
    };
    case "deletegroupwhenempty": {
        // group deleteGroupWhenEmpty delete
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 deleteGroupWhenEmpty _p1;
        _result = true;
    };
    case "deleteidentity": {
        // deleteIdentity  identityName
        private _p0 = _args param [0];
        _result = deleteIdentity  _p0;
    };
    case "deletelocation": {
        // deleteLocation location
        private _p0 = _args param [0];
        deleteLocation _p0;
        _result = true;
    };
    case "deletemarker": {
        // deleteMarker name
        private _p0 = _args param [0];
        deleteMarker _p0;
        _result = true;
    };
    case "deletemarkerlocal": {
        // deleteMarkerLocal markerName
        private _p0 = _args param [0];
        deleteMarkerLocal _p0;
        _result = true;
    };
    case "deleterange": {
        // array deleteRange [from, count]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 deleteRange [_p1, _p2];
        _result = true;
    };
    case "deleteresources": {
        // teamMember deleteResources resources
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 deleteResources _p1;
        _result = true;
    };
    case "deletesite": {
        // deleteSite site
        private _p0 = _args param [0];
        deleteSite _p0;
        _result = true;
    };
    case "deletestatus": {
        // deleteStatus statusName
        private _p0 = _args param [0];
        _result = deleteStatus _p0;
    };
    case "deletetarget": {
        // deleteTarget target
        private _p0 = _args param [0];
        deleteTarget _p0;
        _result = true;
    };
    case "deleteteam": {
        // deleteTeam team
        private _p0 = _args param [0];
        deleteTeam _p0;
        _result = true;
    };
    case "deletevehicle": {
        // deleteVehicle object
        private _p0 = _args param [0];
        deleteVehicle _p0;
        _result = true;
    };
    case "deletevehiclecrew": {
        // vehicle deleteVehicleCrew unit
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 deleteVehicleCrew _p1;
        _result = true;
    };
    case "deletevehiclecrew": {
        // deleteVehicleCrew vehicle
        private _p0 = _args param [0];
        deleteVehicleCrew _p0;
        _result = true;
    };
    case "deletewaypoint": {
        // deleteWaypoint [group, index]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        deleteWaypoint [_p0, _p1];
        _result = true;
    };
    default { _handled = false; };
};

[_handled, _result]
