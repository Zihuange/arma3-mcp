# 引擎行为陷阱清单

这里的每一条都是"**不报错、只给错结果**"那类失败——本仓库一路在打击的失败模式。
清单只收两类来源，且**逐条标明**：

- **【库】** —— 用离线命令库（5181 条，`sqfapi.py lookup`）核实的签名/描述差异。
  这类不需要上机就能确认，证据可复现。
- **【报告】** —— 来自外部会话的实战报告，**本项目尚未实测**。
  可能成立，但上机前不要当定论用。

> 收录标准：**只收有来源的条目**。凭印象写的"这个命令可能有问题"会让整份清单
> 失去可信度——一处误报就足以让人开始忽略全部条目。

---

## 一、命令形态类（离线可核实）

| 命令 | 陷阱 | 来源 |
|---|---|---|
| `weaponZeroing` | **不存在**。只有 `currentZeroing` / `setWeaponZeroing` | 【库】查证无此命令 |
| `getMissionTime` | **不存在**。用 `time` 或 `diag_tickTime` | 【库】查证无此命令 |
| `positionCameraToWorld` | 参数顺序是 **[x, z, y]** = 右、上、前，**不是** [x,y,z] | 【库】原文 "format [x, z, y]" |
| `sizeOf` | 返回**包围球直径**，不是物体尺寸；要精确尺寸用 `boundingBoxReal` | 【库】原文 "diameter of bounding sphere" |
| `boundingBoxReal` | 参数是 **Object**（不是类名字符串）。注意 `sizeOf` 要的**恰恰是**类名字符串——两者相反 | 【库】签名 `boundingBoxReal object` |
| `nearestObjects` | `types` 是**类名字符串数组**（如 `["B_MRAP_01_F"]`），**不是对象数组** | 【库】原文 "List of class name"，例 `["Tank"]` |

⚠ 最后一条曾被人报告成"类型参数必须是**对象数组**"——那是**表述错误**，
照它写会把对象塞进数组里，同样返回 0。数组里放**类名字符串**才对。

## 二、返回值易被误解（部分离线可核实）

| 命令 | 陷阱 | 来源 |
|---|---|---|
| `worldToScreen` | 返回**归一化 UI 坐标（0–1）**，乘分辨率才是像素。另外：**位置不在屏幕内时返回空数组**（不是报错）——把空数组当坐标用就静默出错 | 【库】描述确认 UI space + 空数组；归一化部分为【报告】 |
| `screenToWorld` | 返回**屏幕射线与地形的交点**（landscape / PositionAGL），**取不到天空中或屏幕上方的点** | 【库】原文 "position on landscape" |
| `getPos` | 对**非对象**（如字符串、数组）静默返回 `nil` | 【报告】 |
| `sizeOf` | 部分类返回 `0` | 【报告】 |
| `exec` 回执的嵌套包装 | 只解**最外层**：标量给 `{"v":12,"t":"number"}`，但**数组元素仍带包装**（`{"v":[{"v":9,"t":"number"},…]}`）——`int(val[0])` 会炸 `TypeError`，要取 `val[0]["v"]` | 【报告】 |
| config 类元素的名字不在 `v` 里 | 形如 `{"v":"CONFIG","label":"Config(BUS_InfSquad)","t":"other"}`，类名要从 `label` 用 `^Config\((.+)\)$` 提取 | 【报告】 |

## 三、config 读取（外部会话实测，本项目未复验）

数一个 config 条目下有**几个子项**时，两个写法数的**不是同一种东西**：

| 表达式 | `BUS_InfSquad` 的结果 | 数的是 |
|---|---|---|
| `count (<filter> configClasses <cfg>)` | **8** | ✅ 只数 class 子类（要的就是这个） |
| `count <cfg>` | **12** | ❌ 把非 class 的子条目（属性）也算进去 |

**这个错误是静默的**——两组数字都"看起来合理"，没有任何报错。凡是数人数/条目数，
一律用 `configClasses`。

| 项 | 说明 | 来源 |
|---|---|---|
| `configClasses` 只遍历**直接子类** | 命令库原文："iterates through all available config **sub classes**"。不递归——搜/数深层前必须先把层指定过去 | 【库】 |
| `config_search` 因此只覆盖一层 | 搜 `BUS_Inf*`（root=CfgGroups）必然"无匹配"，那个类在 `West >> BLU_F >> Infantry` 下。要用 `path` 指定层，或 `config_tree` 逐层下钻 | 【库】+【报告】 |
| 判定"是不是人"用 `isMan` | `getNumber (cfg >> "isMan")`：载具=0、士兵=1。**不要用类名前缀猜** | 【报告】 |
| config Unit 条目数 ≠ 运行时人数 | `BUS_MechInfSquad` 有 9 个条目（1 辆 APC + 8 步兵），运行时是 8 步兵 + 3 车组 = **11 人** | 【报告】 |
| `CfgGroups` 的分类名两侧**不对称** | 蓝方 `{Infantry, SpecOps, Support, Motorized, Mechanized, Armored}`；红方 `{Infantry, UInfantry, SpecOps, Support, Motorized_MTP, Mechanized, Armored}` —— **红方没有 `Motorized`**，且 `BUS_Support_Mort` vs `OI_support_Mort` 大小写也不同 | 【报告】 |
| `CfgGroups` 顶层只有 4 类 | `Empty` / `West` / `East` / `Indep` —— **没有 Civilian** | 【报告】 |

**过滤条件只能经 `args` 传**：`configClasses` 的 condition 是**字符串**
（`"true" configClasses cfg`），而表达式禁止字符串字面量 —— 所以它必须作为数据
传进来（`_p1 configClasses (configFile >> _p0)`）。这一段字符串**在游戏侧执行**，
那里的 `_x` 是合法的：白名单只校验表达式文本，不校验作为数据传入的条件串。

```python
# 表达式里只用 _pN；过滤条件整个走 args
expr = "count (_p1 configClasses (configFile >> _p0))"
args = ["CfgGroups", "true"]

# 条件串里可以用 _x（它在游戏侧执行）
expr = "count (_p2 configClasses (configFile >> _p0 >> _p1))"
args = ["CfgGroups", "West",
        'getNumber (configFile >> "CfgVehicles" >> getText (_x >> "vehicle") >> "isMan") == 0']
```

> 类名与分类名**一律从 `config_tree` / 导出数据取，不要猜**。猜错的后果不是报错，
> 而是 `configClass` 返回 null、生成物静默不生效（静态检查也查不出）。代码里应加
> `isClass` 守卫，把静默失败变成显式报错。

## 四、事件与调度（需上机核实）

| 项 | 陷阱 | 来源 |
|---|---|---|
| `addMissionEventHandler` | 事件名必须在任务事件枚举内：`"Fired"` **不是**任务事件（报 `Unknown enum value`）；单位开火要用 `addEventHandler` | 【报告】 |

## 五、SQF 语言层（本项目有独立证据的会标注）

| 项 | 说明 | 来源 |
|---|---|---|
| 一元命令不能写成二元 | `removeAllWeapons player;` ✓／`player removeAllWeapons player;` ✗。写前查签名看是 `cmd unit` 还是 `unit cmd arg` | 【报告】+ 本项目 `tools/lint_sqf_calls.py` 专查此类形态 |
| 事件处理器是 unscheduled | 里面不能 `waitUntil`/`sleep`。只做登记，等待交给 scheduled 主循环 | 【报告】 |
| `waitUntil` 死锁 | 退出条件要写成"对象消失 **OR** 超时 **OR** 采满"，只等一个条件会在对象提前消失时永远等下去 | 【报告】 |
| 局部变量与代码块 | **同步** `call` 的代码块**可以**读到外层 `private` 变量（本仓库 `fn_validate` 广泛依赖，实测成立）；**异步**回调（`onEachFrame`、事件处理器）在函数返回后执行，那时外层局部变量可能已失效 | 本项目实测（同步）+【报告】（异步） |

> ⚠ 关于"局部变量不跨代码块边界"的两种说法：**不要一概而论**。
> 同步 `call` 成立，异步回调不成立。混为一谈会导致把正常代码改坏。

---

## 附：两条曾被误传的"引擎规则"

这两条在外部报告里出现过，但**本项目有反例**，记在这里以免后续会话照做无用的改动。

### 1. "中文注释会导致 `.sqf` 伪语法错误（引擎报缺少 ;，而 SQFLint 干净）"

**本项目反例**：`game/mod/addons/a3mcp/fnc/` 下 22 个 `.sqf` 共 **24464 字节**
非 ASCII 字符（大量中文注释），全部正常加载。`fn_validate.sqf` 自己就有
6823 字节中文注释，它在引擎里加载**零错误**。

真正会同时满足"引擎报缺少 ;、SQFLint 却干净"的，是本项目踩过的这两类：
- **语句形态不对**：`if (cond) then { exitWith {…}; };` 引擎报"缺少 ;"，
  要写成 `if (cond) exitWith {…};`。定位指向块内的 `{`，看起来像块内容有错。
- **一元/二元形态写反**（见上表）。

**结论**：遇到"SQFLint 干净但引擎报错"，先查**语句形态**，不要去改注释语言。
把中文注释全改成英文，会白丢可读性而问题依旧。

（**边界**见下一条：`.bat` 是另一回事——那里确实必须纯 ASCII。）

### 2. 编码要求要分文件类型：`.bat` 必须纯 ASCII，`.sqf` 没这个限制

"非 ASCII 会导致伪语法错误"这句话**只对 `.bat` 成立**：

| 文件 | 要求 | 依据 |
|---|---|---|
| `.bat` | **纯 ASCII + CRLF** | `cmd.exe` 按 OEM 码页读取，UTF-8 文本会破坏解析。本仓库三个启动脚本的注释里都写着这条 |
| `.sqf` | 无此限制 | 本项目 22 个 `.sqf` 共 24464 字节中文注释，**全部正常加载** |

所以"把注释全改成英文"对 `.sqf` 是白费功夫；但对 `.bat` **必须遵守**——
本文件作者就犯过一次：在 `start_windows.bat` 的注释里写了一个中文词，
`file` 立刻从 `ASCII text` 变成 `UTF-8 text`（自检可查：
`python3 -c "print(sum(1 for b in open('x.bat','rb').read() if b>127))"` 应为 0）。

### 3. "SQFLint 的 `Possibly undefined variable` 一定是真 bug"

**本项目反例**：SQFLint 把嵌套代码块当成新作用域，于是"外层 `private` 变量在
内层块里被读取"会被它报成 possibly undefined —— 而那在 SQF 里是**合法且常用**的
（`fn_validate.sqf` 的 `_checkCallTarget` 读外层 `_args` 就是这种）。
`fn_run.sqf` 的注释里记着这个误报。

**结论**：这条诊断要**分情况**：读外层局部变量 → 多半是误报；读**异步回调**里的
外层变量 → 可能是真 bug。

---

## 施工约定

- 想往清单里加条目：**先给出可复现的来源**。能用离线命令库核实的，用【库】标注；
  只能靠上机的，用【报告】并说明"本项目未实测"。
- 报告与本项目实测冲突时，**以实测为准**，并把冲突记进本文档（像上面那两条）。
