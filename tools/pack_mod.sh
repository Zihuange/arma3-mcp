#!/usr/bin/env bash
# 把 game/mod/addons/a3mcp 打包成 PBO。
#
# ⚠ 本脚本存在的主要理由：**PBO 里必须是 config.bin（二进制），不能是 config.cpp**。
#   手工敲命令时最容易漏掉"用 CfgConvert 重新 rapify"这一步，而漏掉的后果是
#   **静默的**——PBO 里还是上一版的 config.bin，新函数全部 Undefined variable，
#   上机表现为"新命令毫无反应"。同类工程的部署手册把这列为头号坑。
#   所以：脚本强制先 rapify，打包后逐项复核，不通过就拒绝出包。
#
# 用法：
#   bash tools/pack_mod.sh              # 打包并校验
#   bash tools/pack_mod.sh --stage-only # 只准备 stage（不调 AddonBuilder）
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$REPO/game/mod/addons/a3mcp"
OUT="$REPO/game/mod/addons"
# --out <目录>：把 PBO 打到别处。用途：游戏运行时模组目录被锁，
# 但可以先把包做好，等游戏退出再拷进去（省掉一轮等待）。
if [ "${1:-}" = "--out" ] && [ -n "${2:-}" ]; then
  # AddonBuilder 要求目标路径是**绝对路径**（相对路径会被它拒绝，
  # 报 "Specified path is not absolute"）。所以这里先解析成绝对路径。
  OUT="$(realpath -m "$2")"
  shift 2
fi
STAGE="$REPO/build/stage/a3mcp"

TOOLS_ROOT="${ARMA3_TOOLS:-/mnt/e/SteamLibrary/steamapps/common/Arma 3 Tools}"
CFGCONVERT="$TOOLS_ROOT/CfgConvert/CfgConvert.exe"
ADDBUILDER="$TOOLS_ROOT/AddonBuilder/AddonBuilder.exe"

die() { echo "✗ $*" >&2; exit 1; }
step() { echo; echo "== $* =="; }

[ -d "$SRC" ] || die "找不到模组源码目录：$SRC"

step "0/5 出包前检查：SQF 静态检查"
# 用 SQFLint 检查，但**豁免一类已知误报**：本机 SQFLint 的命令表未收录
# fromJSON/toJSON（引擎确实有这两个命令），把它们写成原生形式时会被报
# "标识符相邻"。实测写成 `call` 形式反而被引擎拒绝（"意外的 )"），
# 所以代码用原生写法，检查器这边豁免 —— 不能让工具误报逼出错误的代码。
SQF_FNC_DIR="$REPO/game/mod/addons/a3mcp/fnc"
SQF_CHECK="${SQF_MCP_CHECK:-<sqf-skill>/scripts/sqfcheck.py}"
if [ -f "$SQF_CHECK" ]; then
  SQF_BAD=0
  for f in "$SQF_FNC_DIR"/*.sqf; do
    out="$(timeout 120 python3 "$SQF_CHECK" "$f" 2>&1 || true)"
    # 统计诊断数，扣除 fromJSON/toJSON 的已知误报
    n=$(echo "$out" | grep -cE "^  [EW] " || true)
    exempt=$(echo "$out" | grep -cE "^  [EW] .*(fromJSON|toJSON)" || true)
    real=$((n - exempt))
    if [ "$real" -gt 0 ]; then
      echo "  X $(basename "$f"): $real 条诊断"
      echo "$out" | grep -E "^  [EW] " | grep -vE "fromJSON|toJSON" | head -3
      SQF_BAD=$((SQF_BAD + real))
    fi
  done
  [ "$SQF_BAD" -eq 0 ] || die "SQF 静态检查未通过（$SQF_BAD 条诊断）"
  echo "  OK：19 文件静态检查通过（已豁免 fromJSON/toJSON 误报）"
else
  echo "  （跳过：找不到 SQFLint，设置 SQF_MCP_CHECK 指定）"
fi

step "0.5/5 出包前检查：函数调用形态"
# 这轮上机的教训：SQFLint **抓不到**"函数调用缺 call"这类错误
# （它把函数名当未定义变量，而未定义变量是默认忽略的诊断类别）。
# 结果静态检查全绿、PBO 正常打包，直到游戏里才报"缺少 ;"。
# 所以出包前必须补这道专门检查。
python3 "$REPO/tools/lint_sqf_calls.py" || die "函数调用形态检查未通过（见上）"
# 文件与声明必须一一对应：漏声明 = 函数不存在（游戏里报 Undefined variable），
# 而且加载期不一定有明确提示
python3 "$REPO/tools/check_cfg_decl.py" || die "CfgFunctions 声明与 .sqf 文件不一致（见上）"

step "1/5 准备 stage"
rm -rf "$STAGE"
mkdir -p "$STAGE/fnc"
cp "$SRC/config.cpp" "$STAGE/config.cpp"
cp "$SRC/\$PBOPREFIX\$" "$STAGE/\$PBOPREFIX\$" 2>/dev/null || echo "a3mcp" > "$STAGE/\$PBOPREFIX\$"
cp "$SRC"/fnc/*.sqf "$STAGE/fnc/"
echo "  已复制 $(ls "$STAGE/fnc" | wc -l) 个 SQF 文件"

step "2/5 保留 config.cpp（由打包器生成 config.bin）"
# 实测得到的两条结论（都会静默出错，故都写进流程）：
#   1. **自动 binarize 会清掉 SQF** —— 不 paconly 时，binarize 面对纯文本
#      模组会把 15 个 .sqf 全部丢弃，产出只剩配置的 PBO，而日志仍报
#      Build Successful。故打包必须加 -packonly。
#   2. **-packonly 不做配置转换** —— 于是 config.bin 得由我们自己生成，
#      否则 PBO 里没有 bin，引擎会认为模组是空的。
# 所以：手工 rapify 出 config.bin，同时**保留** config.cpp（便于调试），
# 再用 -packonly 打包。
[ -f "$CFGCONVERT" ] || die "找不到 CfgConvert：$CFGCONVERT（用 ARMA3_TOOLS 指定 Arma 3 Tools 路径）"
SRC_WIN="$(wslpath -w "$STAGE/config.cpp")"
BIN_WIN="$(wslpath -w "$STAGE/config.bin")"
"$CFGCONVERT" -bin -dst "$BIN_WIN" "$SRC_WIN" >/dev/null 2>&1
[ -s "$STAGE/config.bin" ] || die "CfgConvert 未产出 config.bin（空文件或失败）"
echo "  config.bin 已生成（$(stat -c %s "$STAGE/config.bin") 字节），config.cpp 保留"

FNC_COUNT=$(ls "$STAGE/fnc"/*.sqf | wc -l)
echo "  函数文件数：$FNC_COUNT（校验时会比对）"

if [ "${1:-}" = "--stage-only" ]; then
  step "完成（--stage-only）"
  echo "  stage 已就绪：$STAGE"
  exit 0
fi

step "3/5 AddonBuilder 打包"
[ -f "$ADDBUILDER" ] || die "找不到 AddonBuilder：$ADDBUILDER"

# ⚠ 游戏运行时 PBO 被占用：AddonBuilder 复制会失败，而它的报错只有一句
# 含混的 "Build failed"（真正原因 "Permission denied" 在更早的输出里）。
# 实测踩过：脚本照样报"完成"，交付的却是旧 PBO —— 又一次静默失败。
#
# 判据用"文件能否被独占写入"，而不是查进程名：前者直接对应失败原因，
# 也不依赖 tasklist 的输出格式（那个在脚本内外行为还不一致，不值得纠缠）。
if [ -f "$OUT/a3mcp.pbo" ] && ! ( : >> "$OUT/a3mcp.pbo" ) 2>/dev/null; then
  die "无法写入 $OUT/a3mcp.pbo —— 它正被占用（最常见原因：Arma 3 还开着）。
     两种处理方式：
       a) 完全退出游戏（含启动器）后重跑本脚本；
       b) 先把包打到别处：bash tools/pack_mod.sh --out build/out
          等游戏退出后把 build/out/a3mcp.pbo 拷进模组目录。"
fi
STAGE_WIN="$(wslpath -w "$STAGE" 2>/dev/null || echo "$STAGE")"
OUT_WIN="$(wslpath -w "$OUT" 2>/dev/null || echo "$OUT")"
rm -f "$OUT/a3mcp.pbo"
# -packonly：跳过自动 binarize。实测不做这一步时，binarize 会把纯文本
# 模组里的 SQF 文件清空，产出只有 config.bin 的空壳 PBO（而日志仍报
# Build Successful —— 又一处"静默失败"，所以打包后必须校验）。
AB_LOG="$(mktemp)"
"$ADDBUILDER" "$STAGE_WIN" "$OUT_WIN" -prefix=a3mcp -packonly -clear 2>&1 \
  | tee "$AB_LOG" | tail -8

# 只看"文件存在"是不够的：构建失败时旧文件仍在，于是看起来一切正常。
# 必须检查日志里有没有 Build failed / Permission denied。
if grep -qE "Build failed|Permission denied|\[ERROR\]" "$AB_LOG"; then
  echo
  grep -E "Permission denied|ERROR" "$AB_LOG" | head -3
  rm -f "$AB_LOG"
  die "AddonBuilder 构建失败（见上）。常见原因：游戏正在运行占用 PBO。"
fi
rm -f "$AB_LOG"
[ -f "$OUT/a3mcp.pbo" ] || die "AddonBuilder 未产出 a3mcp.pbo"

step "4/5 校验 PBO"
PBO="$OUT/a3mcp.pbo"
python3 "$REPO/tools/pbo_verify.py" "$PBO" --expect-functions "$FNC_COUNT" \
  || die "PBO 校验失败"

step "5/5 完成"
echo "  产物：$PBO ($(stat -c %s "$PBO") 字节)"

# 模组缺 DLL 就是空壳：SQF 能加载，但所有 callExtension 都不会有反应，
# 而且不会报错。所以在出包时就提醒（不阻断——PBO 本身是好的）。
DLL="$REPO/game/mod/arma3_mcp_x64.dll"
if [ -f "$DLL" ]; then
  echo "  DLL：$(basename "$DLL") ($(stat -c %s "$DLL") 字节)"
else
  echo "  ⚠ 模组目录里没有 DLL —— SQF 能加载但 callExtension 不会有任何反应。"
  echo "    构建：cmake -S game/extension -B build/ext -A x64 && cmake --build build/ext --config Release"
fi
