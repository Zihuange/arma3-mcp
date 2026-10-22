# DIK 扫描码速查

来源：**Windows SDK 10.0.22621.0 的 `um/dinput.h`** 里 `#define DIK_*` 的正式定义，
不是凭记忆整理的。这一点重要 —— `keyName` 命令在实机取证时**不可用**
（对 Enter=28 这类确定的码也返回 nil），没有第二条验证途径。

`input_key` 与 `input_macro` 的 `key` / `combo` 用的就是这个码，**不是虚拟键码**。

机器可读的一份在 `data/dik.json`。

## 系统与编辑

| DIK | 码 | 名称 |
|---|---|---|
| `ESCAPE` | 1 |  |
| `BACK` | 14 | backspace |
| `TAB` | 15 |  |

## 主键盘数字行

| DIK | 码 | 名称 |
|---|---|---|
| `1` | 2 |  |
| `2` | 3 |  |
| `3` | 4 |  |
| `4` | 5 |  |
| `5` | 6 |  |
| `6` | 7 |  |
| `7` | 8 |  |
| `8` | 9 |  |
| `9` | 10 |  |
| `0` | 11 |  |
| `MINUS` | 12 | - on main keyboard |
| `EQUALS` | 13 |  |

## 主键盘字母

| DIK | 码 | 名称 |
|---|---|---|
| `Q` | 16 |  |
| `W` | 17 |  |
| `E` | 18 |  |
| `R` | 19 |  |
| `T` | 20 |  |
| `Y` | 21 |  |
| `U` | 22 |  |
| `I` | 23 |  |
| `O` | 24 |  |
| `P` | 25 |  |
| `LBRACKET` | 26 |  |
| `RBRACKET` | 27 |  |
| `RETURN` | 28 | Enter on main keyboard |
| `LCONTROL` | 29 |  |
| `A` | 30 |  |
| `S` | 31 |  |
| `D` | 32 |  |
| `F` | 33 |  |
| `G` | 34 |  |
| `H` | 35 |  |
| `J` | 36 |  |
| `K` | 37 |  |
| `L` | 38 |  |
| `SEMICOLON` | 39 |  |
| `APOSTROPHE` | 40 |  |
| `GRAVE` | 41 | accent grave |

## 修饰键与常用键

| DIK | 码 | 名称 |
|---|---|---|
| `LSHIFT` | 42 |  |
| `BACKSLASH` | 43 |  |
| `Z` | 44 |  |
| `X` | 45 |  |
| `C` | 46 |  |
| `V` | 47 |  |
| `B` | 48 |  |
| `N` | 49 |  |
| `M` | 50 |  |
| `COMMA` | 51 |  |
| `PERIOD` | 52 | . on main keyboard |
| `SLASH` | 53 | / on main keyboard |
| `RSHIFT` | 54 |  |
| `MULTIPLY` | 55 | * on numeric keypad |
| `LMENU` | 56 | left Alt |
| `SPACE` | 57 |  |
| `CAPITAL` | 58 |  |

## 功能键 F1-F10

| DIK | 码 | 名称 |
|---|---|---|
| `F1` | 59 |  |
| `F2` | 60 |  |
| `F3` | 61 |  |
| `F4` | 62 |  |
| `F5` | 63 |  |
| `F6` | 64 |  |
| `F7` | 65 |  |
| `F8` | 66 |  |
| `F9` | 67 |  |
| `F10` | 68 |  |

## 数字键盘与锁定

| DIK | 码 | 名称 |
|---|---|---|
| `NUMLOCK` | 69 |  |
| `SCROLL` | 70 | Scroll Lock |
| `NUMPAD7` | 71 |  |
| `NUMPAD8` | 72 |  |
| `NUMPAD9` | 73 |  |
| `SUBTRACT` | 74 | - on numeric keypad |
| `NUMPAD4` | 75 |  |
| `NUMPAD5` | 76 |  |
| `NUMPAD6` | 77 |  |
| `ADD` | 78 | + on numeric keypad |
| `NUMPAD1` | 79 |  |
| `NUMPAD2` | 80 |  |
| `NUMPAD3` | 81 |  |
| `NUMPAD0` | 82 |  |
| `DECIMAL` | 83 | . on numeric keypad |

## 功能键 F11-F12 等

| DIK | 码 | 名称 |
|---|---|---|
| `OEM_102` | 86 | <> or \| on RT 102-key keyboard (Non-U.S.) |
| `F11` | 87 |  |
| `F12` | 88 |  |

## 符号与 OEM

| DIK | 码 | 名称 |
|---|---|---|
| `F13` | 100 | (NEC PC98) |
| `F14` | 101 | (NEC PC98) |
| `F15` | 102 | (NEC PC98) |
| `KANA` | 112 | (Japanese keyboard) |
| `ABNT_C1` | 115 | /? on Brazilian keyboard |

## 多媒体与 OEM

| DIK | 码 | 名称 |
|---|---|---|
| `CONVERT` | 121 | (Japanese keyboard) |
| `NOCONVERT` | 123 | (Japanese keyboard) |
| `YEN` | 125 | (Japanese keyboard) |
| `ABNT_C2` | 126 | Numpad . on Brazilian keyboard |
| `NUMPADEQUALS` | 141 | = on numeric keypad (NEC PC98) |
| `PREVTRACK` | 144 | Previous Track (DIK_CIRCUMFLEX on Japanese keyboard) |
| `AT` | 145 | (NEC PC98) |
| `COLON` | 146 | (NEC PC98) |
| `UNDERLINE` | 147 | (NEC PC98) |
| `KANJI` | 148 | (Japanese keyboard) |
| `STOP` | 149 | (NEC PC98) |
| `AX` | 150 | (Japan AX) |
| `UNLABELED` | 151 | (J3100) |
| `NEXTTRACK` | 153 | Next Track |
| `NUMPADENTER` | 156 | Enter on numeric keypad |
| `RCONTROL` | 157 |  |
| `MUTE` | 160 | Mute |
| `CALCULATOR` | 161 | Calculator |
| `PLAYPAUSE` | 162 | Play / Pause |
| `MEDIASTOP` | 164 | Media Stop |
| `VOLUMEDOWN` | 174 | Volume - |
| `VOLUMEUP` | 176 | Volume + |
| `WEBHOME` | 178 | Web home |
| `NUMPADCOMMA` | 179 | , on numeric keypad (NEC PC98) |
| `DIVIDE` | 181 | / on numeric keypad |
| `SYSRQ` | 183 |  |

## 其它

| DIK | 码 | 名称 |
|---|---|---|
| `RMENU` | 184 | right Alt |
| `PAUSE` | 197 | Pause |
| `HOME` | 199 | Home on arrow keypad |
| `UP` | 200 | UpArrow on arrow keypad |
| `PRIOR` | 201 | PgUp on arrow keypad |
| `LEFT` | 203 | LeftArrow on arrow keypad |
| `RIGHT` | 205 | RightArrow on arrow keypad |
| `END` | 207 | End on arrow keypad |
| `DOWN` | 208 | DownArrow on arrow keypad |
| `NEXT` | 209 | PgDn on arrow keypad |
| `INSERT` | 210 | Insert on arrow keypad |
| `DELETE` | 211 | Delete on arrow keypad |
| `LWIN` | 219 | Left Windows key |
| `RWIN` | 220 | Right Windows key |
| `APPS` | 221 | AppMenu key |
| `POWER` | 222 | System Power |
| `SLEEP` | 223 | System Sleep |
| `WAKE` | 227 | System Wake |
| `WEBSEARCH` | 229 | Web Search |
| `WEBFAVORITES` | 230 | Web Favorites |
| `WEBREFRESH` | 231 | Web Refresh |
| `WEBSTOP` | 232 | Web Stop |
| `WEBFORWARD` | 233 | Web Forward |
| `WEBBACK` | 234 | Web Back |
| `MYCOMPUTER` | 235 | My Computer |
| `MAIL` | 236 | Mail |
| `MEDIASELECT` | 237 | Media Select |
