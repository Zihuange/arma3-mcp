# 游戏内 config 查询（运行时）

让 Agent 读**游戏内真实的 config 树**，而不是猜参数。典型价值：`veh_create`
要填 classname 时，它先去 `config_search` 找到真实存在的类名，而不是编一个。

## 为什么是运行时查询

Arma 的 addon 在 PBO 里存的是 **rapified `config.bin`**（二进制），不是文本
`config.cpp`。所以"不启动游戏直接读 PBO 拿配置"需要先实现一个二进制格式
解析器——那是独立且不小的工作量。运行时查询则直接问引擎，拿到的是**当前
实际加载的**配置（含全部 mod），没有格式解析风险。

代价：**必须有游戏在跑**。所以离线能力（`config.cpp` 文本、`mission.sqm`）
是另一条线，不在本文范围。

## 六个工具

| 工具 | 用途 |
|---|---|
| `config_tree(root?, path?, filter?, limit?)` | 浏览子类；不带 root 时列常用顶层类 |
| `config_class(root, path, keys?)` | 类摘要：父类、继承链、来源 mod、关键属性 |
| `config_value(root, path, key\|keys)` | 精确读一个或多个属性 |
| `config_search(pattern, root?, path?)` | 按通配符找**某层直接子类**里的类名（不递归） |
| `config_of(entity, keys?)` | 从**游戏内实体**跳到它的 config |
| `config_cache(clear?)` | 查看/清空缓存 |

设计上刻意分三档（树 → 摘要 → 值），因为一个 config 类常有 **200+ 个属性**，
整棵返回会撑爆上下文。`config_class` 不带 `keys` 时只给该用途的
**关键字段预置集**（见 `adapters/config_tools.py` 的 `KEY_PRESETS`），
并明确告知还有多少字段没显示。

## 游戏侧契约（SQF 必须实现的两个命令）

> 本文定义契约，`tests/test_config_tools.py` 里的假游戏处理器是**可执行的
> 契约实例**。上机时只需验证"引擎查询是否正确"，不必同时猜协议。

### `configQuery`

参数（位置数组）：

```
[root, path(斜杠分隔的字符串), op, keys?(数组), limit?(数字)]
```

`op` 取值与返回：

| op | 返回 |
|---|---|
| `tree` | `{children: [{name, isClass, parent?}], total}` |
| `class` | `{class, parentName, hierarchy[], sourceMod, properties{}, missing[], truncated?}` |
| `search` | `{matches: [类名...], total}` |
| `roots` | `{roots: [顶层类名...]}` |

### `configOfEntity`

```
[[实体名], keys?]
→ {found: bool, type: "类名", properties: {...}}
```

`found=false` 时 MCP 侧会明确报"游戏内找不到实体"，并说明**实体名未定义不会
报错、只表现为找不到**——这是 SQF 的语义陷阱。开发期这个坑真实存在：命令库
里 `missionNamespace getVariable` 对未定义名字返回 `nil` 而不是报错，上游很容易
误读成"实体存在但配置为空"。当前实现改为**显式返回 found 字段**。

## 值的表示：统一带类型

游戏侧每个值用 `{"t": 类型, "v": 值}` 承载，而不是裸值。理由：`""`、`0`、
`false`、`[]` 这些"看起来像没值"的结果，必须能与"属性不存在"区分开。

| 类型 | 渲染 | 说明 |
|---|---|---|
| `number`/`text`/`bool` | 原样 | |
| `array` | `[a, b]`；空数组显式标 `[]（空数组）` | 递归 |
| `config` | `config[CfgVehicles >> B_MRAP_01_F >> model]` | **渲染成可继续查询的路径**，模型要能拿着它往下走 |
| `code` | `<code：只报存在性，不返回内容>` | 见下 |
| `nil` | `(不存在)` | |

**Code 类型刻意不返回内容**：返回了也没用（模型无法执行），且会诱导它去尝试
执行配置里的 `onLoad`/`init`。只报存在性。

## 性能

| 事项 | 处理 |
|---|---|
| `configClasses` 是重量级调用（遍历子树） | 分页（默认 50）+ 总数字段；不无脑全量拉 |
| 同一路径反复查 | MCP 侧进程内缓存（默认 TTL 300s），config 运行期不变 |
| 缓存失效策略 | 刻意简单：按会话存活 + 手动 `refresh`。理由是误报过期数据的代价高于多查一次 |
| 往返开销 | `config_value` 支持一次读多个 key，减少请求数 |

## 安全

- 全部**只读**，不改状态、不生成资源——**不经过写闸门**，默认放行；
- 不需要 EXOTIC 级别；
- 唯一挡掉的是 config 里的 Code 属性（见上）。

## 已知限制与未验证项

1. **未上机验证**：MCP 侧链路（工具 → 通道 → 回执 → 渲染 → 缓存）已用假游戏
   端到端验证；**引擎侧查询的正确性未验证**（需要游戏）。
2. ~~`config_search` 的实现方式待定~~ → **已实现**（2026-09-27）：游戏侧遍历
   `configClasses` 子类时用标准 glob 逐条判掉（`*` 任意串、`?` 单字符），
   MCP 侧另有一份可测试的参考实现与一次二次过滤。

   ⚠ **搜索范围是"该层的直接子类"，不递归** —— 这是引擎 `configClasses` 的语义
   （命令库原文："iterates through all available config **sub classes** of the
   given config class"）。曾经因此被误判成"工具没实现"：有人搜
   `BUS_Inf*`（root=CfgGroups）得到"无匹配"就断定坏了，而那个类其实在
   `CfgGroups >> West >> BLU_F >> Infantry` 下。要找深层类，用 `path` 把层
   指定过去，或先 `config_tree` 逐层下钻。

   **历史 bug（已修）**：旧实现只取第一个 `*` 之前那段做子串包含 ——
   模式以 `*` 开头（`*_F`）时那段为空，于是**匹配全部类**；`?` 则从未实现。
   同时 `_total` 报的是"遍历到的子类数"而非"命中数"，两者被混为一谈，
   于是"匹配 XXX：15604 个"这种读数会把子树的规模当成匹配数。
3. `KEY_PRESETS` 的字段集是**按用途手工挑的**，不是引擎权威列表；上机后应
   按实际常用度调整。
4. 继承属性的行为未定义：`config_class` 目前只读该类自身的属性。需要"沿继承链
   查找"时（如子类未定义 `transportSoldier` 而父类有），应明确用什么语义——
   待上机确认 `configProperties` 的 `inherit` 参数表现。
