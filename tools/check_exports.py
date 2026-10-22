"""校验 DLL 的导出符号名。

Arma 通过固定名字的导出函数调用扩展（RVExtension / RVExtensionArgs /
RVExtensionVersion），名字不对或没导出，引擎就完全不认这个 DLL —— 而且
**不会有明确报错**，只表现为"callExtension 没有反应"。所以编译后必须查。

用 Windows 自带的 dumpbin（VS 工具链）或 Python 的 PE 解析。
"""
import struct, sys, subprocess, os, glob

path = sys.argv[1]
NEEDED = ["RVExtension", "RVExtensionArgs", "RVExtensionVersion"]

# 先试 dumpbin（VS 工具链自带，输出最权威）。
# 路径用 glob 搜：MSVC 工具集版本号会随 VS 更新变化，写死版本号会在
# 升级后静默失效——而这个工具的职责正是"编译后必须查"，不能靠运气。
candidates = []
for root in (r"H:\Program Files\Microsoft Visual Studio\2022",
             r"C:\Program Files\Microsoft Visual Studio\2022",
             r"H:\Program Files (x86)\Microsoft Visual Studio\2022",
             r"C:\Program Files (x86)\Microsoft Visual Studio\2022"):
    candidates += glob.glob(root + r"\*\VC\Tools\MSVC\*\bin\Hostx64\x64\dumpbin.exe")

for exe in candidates:
    if os.path.isfile(exe):
        try:
            out = subprocess.run([exe, "/EXPORTS", path], capture_output=True,
                                 text=True, timeout=120, errors="replace").stdout
            names = [l.split()[-1] for l in out.splitlines() if "RVExtension" in l]
            # 解析不出任何名字时**不能**判缺失：那说明按输出格式取值失败了，
            # 而不是 DLL 没导出。这种情况退到下面的 PE 解析，避免假阳性。
            if not names:
                print("dumpbin 有输出但未解析出导出名，改用 PE 解析")
                break
            print("dumpbin exports:")
            for n in sorted(set(names)):
                print("   ", n)
            missing = [n for n in NEEDED if n not in names]
            if missing:
                print("\nMISSING EXPORTS: %s" % ", ".join(missing))
                sys.exit(1)
            print("\nOK: all three required exports present")
            sys.exit(0)
        except Exception as exc:
            print("dumpbin failed: %s" % exc)

# 退路：自己解析 PE 导出表
with open(path, "rb") as fh:
    data = fh.read()
pe = struct.unpack_from("<I", data, 0x3C)[0]
assert data[pe:pe + 4] == b"PE\0\0", "不是 PE 文件"
coff = pe + 4
nsec, = struct.unpack_from("<H", data, coff + 2)
opt_size, = struct.unpack_from("<H", data, coff + 16)
opt = coff + 20
magic, = struct.unpack_from("<H", data, opt)
dd_off = opt + (112 if magic == 0x20b else 96)
exp_rva, exp_size = struct.unpack_from("<II", data, dd_off)
if exp_rva == 0:
    print("no export table"); sys.exit(1)
sec_off = opt + opt_size
sections = []
for i in range(nsec):
    base = sec_off + i * 40
    name = data[base:base + 8].rstrip(b"\0").decode("ascii", "replace")
    vsize, vaddr, rsize, raddr = struct.unpack_from("<IIII", data, base + 8)
    sections.append((vaddr, vsize, raddr, rsize, name))

def rva_to_off(rva):
    for vaddr, vsize, raddr, rsize, _ in sections:
        if vaddr <= rva < vaddr + max(vsize, rsize):
            return raddr + (rva - vaddr)
    return None

# ⚠ 导出目录的位置是 **RVA**，读它之前必须先映射成文件偏移。
#
# 这里曾经直接拿 exp_rva 当文件偏移用（data[exp_rva + 24] 读 NumberOfNames），
# 而 exp_rva 落在 .rdata（vaddr 0x11000 / raddr 0x10000），照 RVA 读会读到
# 别处、恒得 0 —— found 永远为空，工具于是**永远**报 MISSING EXPORTS。
# 失败方向还指向 DLL，会让人去查一个根本没问题的产物。
exp_off = rva_to_off(exp_rva)
if exp_off is None:
    print("导出目录 RVA %#x 无法映射到文件偏移" % exp_rva)
    sys.exit(1)
names_rva, = struct.unpack_from("<I", data, exp_off + 32)
count, = struct.unpack_from("<I", data, exp_off + 24)
noff = rva_to_off(names_rva)
if noff is None:
    print("导出名表 RVA %#x 无法映射到文件偏移" % names_rva)
    sys.exit(1)
found = []
for i in range(count):
    nrva, = struct.unpack_from("<I", data, noff + i * 4)
    o = rva_to_off(nrva)
    if o is None:
        continue
    end = data.index(b"\0", o)
    found.append(data[o:end].decode("ascii", "replace"))
print("parsed exports:")
for n in sorted(found):
    print("   ", n)
missing = [n for n in NEEDED if n not in found]
if missing:
    print("\nMISSING EXPORTS: %s" % ", ".join(missing)); sys.exit(1)
print("\nOK: all three required exports present")
