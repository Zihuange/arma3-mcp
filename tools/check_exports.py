"""校验 DLL 的导出符号名。

Arma 通过固定名字的导出函数调用扩展（RVExtension / RVExtensionArgs /
RVExtensionVersion），名字不对或没导出，引擎就完全不认这个 DLL —— 而且
**不会有明确报错**，只表现为"callExtension 没有反应"。所以编译后必须查。

用 Windows 自带的 dumpbin（VS 工具链）或 Python 的 PE 解析。
"""
import struct, sys, subprocess, os

path = sys.argv[1]
NEEDED = ["RVExtension", "RVExtensionArgs", "RVExtensionVersion"]

# 先试 dumpbin（VS 工具链自带，输出最权威）
candidates = [
    r"H:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\MSVC"
    r"\14.34.31933\bin\Hostx64\x64\dumpbin.exe",
]
for exe in candidates:
    if os.path.isfile(exe):
        try:
            out = subprocess.run([exe, "/EXPORTS", path], capture_output=True,
                                 text=True, timeout=120, errors="replace").stdout
            names = [l.split()[-1] for l in out.splitlines() if "RVExtension" in l]
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

names_rva, = struct.unpack_from("<I", data, exp_rva + 32)
count, = struct.unpack_from("<I", data, exp_rva + 24)
noff = rva_to_off(names_rva)
found = []
for i in range(count):
    nrva, = struct.unpack_from("<I", data, noff + i * 4)
    o = rva_to_off(nrva)
    end = data.index(b"\0", o)
    found.append(data[o:end].decode("ascii", "replace"))
print("parsed exports:")
for n in sorted(found):
    print("   ", n)
missing = [n for n in NEEDED if n not in found]
if missing:
    print("\nMISSING EXPORTS: %s" % ", ".join(missing)); sys.exit(1)
print("\nOK: all three required exports present")
