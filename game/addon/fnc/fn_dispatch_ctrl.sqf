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
    case "ctrlactivate": {
        // ctrlActivate controlName
        private _p0 = _args param [0];
        ctrlActivate _p0;
        _result = true;
    };
    case "ctrladdeventhandler": {
        // control ctrlAddEventHandler  [handler, function]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 ctrlAddEventHandler  [_p1, _p2];
    };
    case "ctrlangle": {
        // ctrlAngle control
        private _p0 = _args param [0];
        _result = ctrlAngle _p0;
    };
    case "ctrlanimatemodel": {
        // control ctrlAnimateModel [source, phase, speed]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 ctrlAnimateModel [_p1, _p2, _p3];
        _result = true;
    };
    case "ctrlanimationphasemodel": {
        // control ctrlAnimationPhaseModel source
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 ctrlAnimationPhaseModel _p1;
    };
    case "ctrlat": {
        // display ctrlAt [x, y]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 ctrlAt [_p1, _p2];
    };
    case "ctrlautoscrolldelay": {
        // ctrlAutoScrollDelay control
        private _p0 = _args param [0];
        _result = ctrlAutoScrollDelay _p0;
    };
    case "ctrlautoscrollrewind": {
        // ctrlAutoScrollRewind control
        private _p0 = _args param [0];
        _result = ctrlAutoScrollRewind _p0;
    };
    case "ctrlautoscrollspeed": {
        // ctrlAutoScrollSpeed control
        private _p0 = _args param [0];
        _result = ctrlAutoScrollSpeed _p0;
    };
    case "ctrlbackgroundcolor": {
        // ctrlBackgroundColor control
        private _p0 = _args param [0];
        ctrlBackgroundColor _p0;
        _result = true;
    };
    case "ctrlchecked": {
        // ctrlChecked control
        private _p0 = _args param [0];
        _result = ctrlChecked _p0;
    };
    case "ctrlchecked": {
        // control ctrlChecked  index
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 ctrlChecked  _p1;
    };
    case "ctrlclassname": {
        // ctrlClassName control
        private _p0 = _args param [0];
        _result = ctrlClassName _p0;
    };
    case "ctrlcommit": {
        // control ctrlCommit time
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlCommit _p1;
        _result = true;
    };
    case "ctrlcommitted": {
        // ctrlCommitted controlName
        private _p0 = _args param [0];
        _result = ctrlCommitted _p0;
    };
    case "ctrlcreate": {
        // display ctrlCreate [class, idc, controlsGroup]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _result = _p0 ctrlCreate [_p1, _p2, _p3];
    };
    case "ctrldelete": {
        // ctrlDelete control
        private _p0 = _args param [0];
        _result = ctrlDelete _p0;
    };
    case "ctrlenable": {
        // ctrlEnable  [idc, enable]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        ctrlEnable  [_p0, _p1];
        _result = true;
    };
    case "ctrlenable": {
        // controlName ctrlEnable enable
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlEnable _p1;
        _result = true;
    };
    case "ctrlenabled": {
        // ctrlEnabled  idc
        private _p0 = _args param [0];
        _result = ctrlEnabled  _p0;
    };
    case "ctrlenabled": {
        // ctrlEnabled  controlName
        private _p0 = _args param [0];
        _result = ctrlEnabled  _p0;
    };
    case "ctrlfade": {
        // ctrlFade controlName
        private _p0 = _args param [0];
        _result = ctrlFade _p0;
    };
    case "ctrlfontheight": {
        // ctrlFontHeight control
        private _p0 = _args param [0];
        _result = ctrlFontHeight _p0;
    };
    case "ctrlforegroundcolor": {
        // ctrlForegroundColor control
        private _p0 = _args param [0];
        ctrlForegroundColor _p0;
        _result = true;
    };
    case "ctrlhtmlloaded": {
        // ctrlHTMLLoaded control
        private _p0 = _args param [0];
        _result = ctrlHTMLLoaded _p0;
    };
    case "ctrlidc": {
        // ctrlIDC  control
        private _p0 = _args param [0];
        _result = ctrlIDC  _p0;
    };
    case "ctrlidd": {
        // ctrlIDD  display
        private _p0 = _args param [0];
        _result = ctrlIDD  _p0;
    };
    case "ctrlmapanimadd": {
        // map ctrlMapAnimAdd  [time, zoom, position]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 ctrlMapAnimAdd  [_p1, _p2, _p3];
        _result = true;
    };
    case "ctrlmapanimclear": {
        // ctrlMapAnimClear controlName
        private _p0 = _args param [0];
        ctrlMapAnimClear _p0;
        _result = true;
    };
    case "ctrlmapanimcommit": {
        // ctrlMapAnimCommit  mapControl
        private _p0 = _args param [0];
        ctrlMapAnimCommit  _p0;
        _result = true;
    };
    case "ctrlmapanimdone": {
        // ctrlMapAnimDone controlName
        private _p0 = _args param [0];
        _result = ctrlMapAnimDone _p0;
    };
    case "ctrlmapcursor": {
        // control ctrlMapCursor [defaultCursor, newCursor]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 ctrlMapCursor [_p1, _p2];
        _result = true;
    };
    case "ctrlmapdir": {
        // ctrlMapDir ctrl
        private _p0 = _args param [0];
        _result = ctrlMapDir _p0;
    };
    case "ctrlmapmouseover": {
        // ctrlMapMouseOver control
        private _p0 = _args param [0];
        ctrlMapMouseOver _p0;
        _result = true;
    };
    case "ctrlmapposition": {
        // ctrlMapPosition map
        private _p0 = _args param [0];
        _result = ctrlMapPosition _p0;
    };
    case "ctrlmapscale": {
        // ctrlMapScale ctrl
        private _p0 = _args param [0];
        _result = ctrlMapScale _p0;
    };
    case "ctrlmapscreentoworld": {
        // control ctrlMapScreenToWorld [x, y]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _result = _p0 ctrlMapScreenToWorld [_p1, _p2];
    };
    case "ctrlmapsetposition": {
        // map ctrlMapSetPosition [x, y, w, h]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _p0 ctrlMapSetPosition [_p1, _p2, _p3, _p4];
        _result = true;
    };
    case "ctrlmapworldtoscreen": {
        // control ctrlMapWorldToScreen position
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 ctrlMapWorldToScreen _p1;
    };
    case "ctrlmodel": {
        // ctrlModel control
        private _p0 = _args param [0];
        _result = ctrlModel _p0;
    };
    case "ctrlmodeldirandup": {
        // ctrlModelDirAndUp control
        private _p0 = _args param [0];
        _result = ctrlModelDirAndUp _p0;
    };
    case "ctrlmodelscale": {
        // ctrlModelScale  control
        private _p0 = _args param [0];
        _result = ctrlModelScale  _p0;
    };
    case "ctrlmouseposition": {
        // ctrlMousePosition control
        private _p0 = _args param [0];
        _result = ctrlMousePosition _p0;
    };
    case "ctrlparent": {
        // ctrlParent control
        private _p0 = _args param [0];
        _result = ctrlParent _p0;
    };
    case "ctrlparentcontrolsgroup": {
        // ctrlParentControlsGroup ctrl
        private _p0 = _args param [0];
        _result = ctrlParentControlsGroup _p0;
    };
    case "ctrlposition": {
        // ctrlPosition  controlName
        private _p0 = _args param [0];
        ctrlPosition  _p0;
        _result = true;
    };
    case "ctrlremovealleventhandlers": {
        // control ctrlRemoveAllEventHandlers handlerName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlRemoveAllEventHandlers _p1;
        _result = true;
    };
    case "ctrlremoveeventhandler": {
        // control ctrlRemoveEventHandler [type, id]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 ctrlRemoveEventHandler [_p1, _p2];
        _result = true;
    };
    case "ctrlscale": {
        // ctrlScale control
        private _p0 = _args param [0];
        _result = ctrlScale _p0;
    };
    case "ctrlscrollvalues": {
        // ctrlScrollValues control
        private _p0 = _args param [0];
        ctrlScrollValues _p0;
        _result = true;
    };
    case "ctrlsetactivecolor": {
        // control ctrlSetActiveColor color
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetActiveColor _p1;
        _result = true;
    };
    case "ctrlsetangle": {
        // control ctrlSetAngle [angle, centerX, centerY, now]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _p0 ctrlSetAngle [_p1, _p2, _p3, _p4];
        _result = true;
    };
    case "ctrlsetautoscrolldelay": {
        // control ctrlSetAutoScrollDelay delay
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetAutoScrollDelay _p1;
        _result = true;
    };
    case "ctrlsetautoscrollrewind": {
        // control ctrlSetAutoScrollRewind set
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetAutoScrollRewind _p1;
        _result = true;
    };
    case "ctrlsetautoscrollspeed": {
        // control ctrlSetAutoScrollSpeed speed
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetAutoScrollSpeed _p1;
        _result = true;
    };
    case "ctrlsetbackgroundcolor": {
        // control ctrlSetBackgroundColor color
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetBackgroundColor _p1;
        _result = true;
    };
    case "ctrlsetchecked": {
        // control ctrlSetChecked checked
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetChecked _p1;
        _result = true;
    };
    case "ctrlsetchecked": {
        // control ctrlSetChecked [index, checked]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 ctrlSetChecked [_p1, _p2];
        _result = true;
    };
    case "ctrlsetdisabledcolor": {
        // ctrlSetDisabledColor [idc, color]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        ctrlSetDisabledColor [_p0, _p1];
        _result = true;
    };
    case "ctrlsetdisabledcolor": {
        // ctrl ctrlSetDisabledColor color
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetDisabledColor _p1;
        _result = true;
    };
    case "ctrlseteventhandler": {
        // controlName ctrlSetEventHandler [handlerName, function]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 ctrlSetEventHandler [_p1, _p2];
        _result = true;
    };
    case "ctrlsetfade": {
        // controlName ctrlSetFade fade
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFade _p1;
        _result = true;
    };
    case "ctrlsetfocus": {
        // ctrlSetFocus  control
        private _p0 = _args param [0];
        ctrlSetFocus  _p0;
        _result = true;
    };
    case "ctrlsetfont": {
        // control ctrlSetFont fontName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFont _p1;
        _result = true;
    };
    case "ctrlsetfonth1": {
        // controlName ctrlSetFontH1 fontName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontH1 _p1;
        _result = true;
    };
    case "ctrlsetfonth1b": {
        // controlName ctrlSetFontH1B fontName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontH1B _p1;
        _result = true;
    };
    case "ctrlsetfonth2": {
        // controlName ctrlSetFontH2 fontName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontH2 _p1;
        _result = true;
    };
    case "ctrlsetfonth2b": {
        // controlName ctrlSetFontH2B fontName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontH2B _p1;
        _result = true;
    };
    case "ctrlsetfonth3": {
        // controlName ctrlSetFontH3 fontName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontH3 _p1;
        _result = true;
    };
    case "ctrlsetfonth3b": {
        // controlName ctrlSetFontH3B fontName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontH3B _p1;
        _result = true;
    };
    case "ctrlsetfonth4": {
        // controlName ctrlSetFontH4 fontName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontH4 _p1;
        _result = true;
    };
    case "ctrlsetfonth4b": {
        // controlName ctrlSetFontH4B fontName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontH4B _p1;
        _result = true;
    };
    case "ctrlsetfonth5": {
        // controlName ctrlSetFontH5 fontName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontH5 _p1;
        _result = true;
    };
    case "ctrlsetfonth5b": {
        // controlName ctrlSetFontH5B fontName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontH5B _p1;
        _result = true;
    };
    case "ctrlsetfonth6": {
        // controlName ctrlSetFontH6 fontName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontH6 _p1;
        _result = true;
    };
    case "ctrlsetfonth6b": {
        // controlName ctrlSetFontH6B fontName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontH6B _p1;
        _result = true;
    };
    case "ctrlsetfontheight": {
        // control ctrlSetFontHeight  size
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontHeight  _p1;
        _result = true;
    };
    case "ctrlsetfontheighth1": {
        // controlName ctrlSetFontHeightH1 height
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontHeightH1 _p1;
        _result = true;
    };
    case "ctrlsetfontheighth2": {
        // controlName ctrlSetFontHeightH2 height
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontHeightH2 _p1;
        _result = true;
    };
    case "ctrlsetfontheighth3": {
        // controlName ctrlSetFontHeightH3 height
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontHeightH3 _p1;
        _result = true;
    };
    case "ctrlsetfontheighth4": {
        // controlName ctrlSetFontHeightH4 height
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontHeightH4 _p1;
        _result = true;
    };
    case "ctrlsetfontheighth5": {
        // controlName ctrlSetFontHeightH5 height
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontHeightH5 _p1;
        _result = true;
    };
    case "ctrlsetfontheighth6": {
        // controlName ctrlSetFontHeightH6 height
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontHeightH6 _p1;
        _result = true;
    };
    case "ctrlsetfontheightsecondary": {
        // ctrl ctrlSetFontHeightSecondary value
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontHeightSecondary _p1;
        _result = true;
    };
    case "ctrlsetfontp": {
        // control ctrlSetFontP fontOrSize
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontP _p1;
        _result = true;
    };
    case "ctrlsetfontpb": {
        // controlName ctrlSetFontPB fontName
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontPB _p1;
        _result = true;
    };
    case "ctrlsetfontsecondary": {
        // ctrl ctrlSetFontSecondary fontClass
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetFontSecondary _p1;
        _result = true;
    };
    case "ctrlsetforegroundcolor": {
        // control ctrlSetForegroundColor color
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetForegroundColor _p1;
        _result = true;
    };
    case "ctrlsetmodel": {
        // control ctrlSetModel model
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetModel _p1;
        _result = true;
    };
    case "ctrlsetmodeldirandup": {
        // control ctrlSetModelDirAndUp dirAndUp
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetModelDirAndUp _p1;
        _result = true;
    };
    case "ctrlsetmodelscale": {
        // control ctrlSetModelScale  scale
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetModelScale  _p1;
        _result = true;
    };
    case "ctrlsetmouseposition": {
        // control ctrlSetMousePosition [x, y]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 ctrlSetMousePosition [_p1, _p2];
        _result = true;
    };
    case "ctrlsetpixelprecision": {
        // control ctrlSetPixelPrecision mode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetPixelPrecision _p1;
        _result = true;
    };
    case "ctrlsetposition": {
        // controlName ctrlSetPosition  [x, y]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 ctrlSetPosition  [_p1, _p2];
        _result = true;
    };
    case "ctrlsetposition": {
        // controlName ctrlSetPosition  [x, y, w, h]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        private _p4 = _args param [4];
        _p0 ctrlSetPosition  [_p1, _p2, _p3, _p4];
        _result = true;
    };
    case "ctrlsetposition": {
        // controlName ctrlSetPosition  [x, z, y]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        private _p3 = _args param [3];
        _p0 ctrlSetPosition  [_p1, _p2, _p3];
        _result = true;
    };
    case "ctrlsetpositionh": {
        // control ctrlSetPositionH h
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetPositionH _p1;
        _result = true;
    };
    case "ctrlsetpositionw": {
        // control ctrlSetPositionW w
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetPositionW _p1;
        _result = true;
    };
    case "ctrlsetpositionx": {
        // control ctrlSetPositionX x
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetPositionX _p1;
        _result = true;
    };
    case "ctrlsetpositiony": {
        // control ctrlSetPositionY y
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetPositionY _p1;
        _result = true;
    };
    case "ctrlsetscale": {
        // control ctrlSetScale  scale
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetScale  _p1;
        _result = true;
    };
    case "ctrlsetscrollvalues": {
        // control ctrlSetScrollValues [vScrollValue, hScrollValue]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 ctrlSetScrollValues [_p1, _p2];
        _result = true;
    };
    case "ctrlsetshadow": {
        // control ctrlSetShadow shadow
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetShadow _p1;
        _result = true;
    };
    case "ctrlsetstructuredtext": {
        // control ctrlSetStructuredText structuredText
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetStructuredText _p1;
        _result = true;
    };
    case "ctrlsettext": {
        // ctrlSetText [idc, text]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        ctrlSetText [_p0, _p1];
        _result = true;
    };
    case "ctrlsettext": {
        // control ctrlSetText text
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetText _p1;
        _result = true;
    };
    case "ctrlsettextcolor": {
        // control ctrlSetTextColor color
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetTextColor _p1;
        _result = true;
    };
    case "ctrlsettextcolorsecondary": {
        // control ctrlSetTextColorSecondary color
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetTextColorSecondary _p1;
        _result = true;
    };
    case "ctrlsettextsecondary": {
        // control ctrlSetTextSecondary text
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetTextSecondary _p1;
        _result = true;
    };
    case "ctrlsettextselection": {
        // control ctrlSetTextSelection [start, length]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        private _p2 = _args param [2];
        _p0 ctrlSetTextSelection [_p1, _p2];
        _result = true;
    };
    case "ctrlsettooltip": {
        // control ctrlSetTooltip text
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetTooltip _p1;
        _result = true;
    };
    case "ctrlsettooltipcolorbox": {
        // control ctrlSetTooltipColorBox  color
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetTooltipColorBox  _p1;
        _result = true;
    };
    case "ctrlsettooltipcolorshade": {
        // control ctrlSetTooltipColorShade color
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetTooltipColorShade _p1;
        _result = true;
    };
    case "ctrlsettooltipcolortext": {
        // display ctrlSetTooltipColorText color
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetTooltipColorText _p1;
        _result = true;
    };
    case "ctrlsettooltipmaxwidth": {
        // ctrl ctrlSetTooltipMaxWidth width
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _result = _p0 ctrlSetTooltipMaxWidth _p1;
    };
    case "ctrlseturl": {
        // control ctrlSetURL URL
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetURL _p1;
        _result = true;
    };
    case "ctrlseturloverlaymode": {
        // control ctrlSetURLOverlayMode mode
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlSetURLOverlayMode _p1;
        _result = true;
    };
    case "ctrlshadow": {
        // ctrlShadow control
        private _p0 = _args param [0];
        _result = ctrlShadow _p0;
    };
    case "ctrlshow": {
        // ctrlShow [idc, show]
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        ctrlShow [_p0, _p1];
        _result = true;
    };
    case "ctrlshow": {
        // controlName ctrlShow show
        private _p0 = _args param [0];
        private _p1 = _args param [1];
        _p0 ctrlShow _p1;
        _result = true;
    };
    case "ctrlshown": {
        // ctrlShown controlName
        private _p0 = _args param [0];
        _result = ctrlShown _p0;
    };
    case "ctrlstyle": {
        // ctrlStyle control
        private _p0 = _args param [0];
        _result = ctrlStyle _p0;
    };
    case "ctrltext": {
        // ctrlText  idc
        private _p0 = _args param [0];
        _result = ctrlText  _p0;
    };
    case "ctrltext": {
        // ctrlText  controlName
        private _p0 = _args param [0];
        _result = ctrlText  _p0;
    };
    case "ctrltextcolor": {
        // ctrlTextColor control
        private _p0 = _args param [0];
        _result = ctrlTextColor _p0;
    };
    case "ctrltextheight": {
        // ctrlTextHeight  control
        private _p0 = _args param [0];
        _result = ctrlTextHeight  _p0;
    };
    case "ctrltextsecondary": {
        // ctrlTextSecondary control
        private _p0 = _args param [0];
        _result = ctrlTextSecondary _p0;
    };
    case "ctrltextselection": {
        // ctrlTextSelection control
        private _p0 = _args param [0];
        ctrlTextSelection _p0;
        _result = true;
    };
    case "ctrltextwidth": {
        // ctrlTextWidth control
        private _p0 = _args param [0];
        _result = ctrlTextWidth _p0;
    };
    case "ctrltooltip": {
        // ctrlTooltip control
        private _p0 = _args param [0];
        _result = ctrlTooltip _p0;
    };
    case "ctrltype": {
        // ctrlType control
        private _p0 = _args param [0];
        _result = ctrlType _p0;
    };
    case "ctrlurl": {
        // ctrlURL control
        private _p0 = _args param [0];
        _result = ctrlURL _p0;
    };
    case "ctrlurloverlaymode": {
        // ctrlURLOverlayMode control
        private _p0 = _args param [0];
        _result = ctrlURLOverlayMode _p0;
    };
    case "ctrlvisible": {
        // ctrlVisible  idc
        private _p0 = _args param [0];
        _result = ctrlVisible  _p0;
    };
    default { _handled = false; };
};

[_handled, _result]
