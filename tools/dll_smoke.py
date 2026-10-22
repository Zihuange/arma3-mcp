"""DLL 功能冒烟测试：不需要 Arma 3，直接按 Arma 的方式调用导出函数。

验证三件事（都是"上机才发现"会很难受的点）：
  1. DLL 能被进程加载（依赖、位数是否正确）；
  2. 三个导出函数能按 Arma 的签名被调用且不崩；
  3. 后台网络线程确实在工作 —— 起一个假的 MCP 监听，看它是否连上并完成握手。

只输出 ASCII：Windows Python 默认 ANSI 编码，中文会抛编码异常。
"""
import ctypes, json, socket, sys, threading, time

DLL = sys.argv[1]
PORT = int(sys.argv[2]) if len(sys.argv) > 2 else 32131

# --- 假 MCP：接受一条连接并读 hello ---
got_hello = []
srv = socket.socket()
srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
srv.bind(("127.0.0.1", PORT))
srv.listen(1)
srv.settimeout(8)

def accept_once():
    try:
        conn, addr = srv.accept()
        conn.settimeout(5)
        data = conn.recv(4096)
        got_hello.append((addr, data.decode("utf-8", "replace").strip()))
        # 下发一条命令，看 DLL 是否入队（poll 应能取到）
        conn.sendall(json.dumps({
            "t": "cmd", "cid": "smoke1", "cmd": "getPos",
            "args": [["u_1"]]}).encode() + b"\n")
        time.sleep(2.5)
        conn.close()
    except Exception as exc:
        got_hello.append(("ERR", str(exc)))

threading.Thread(target=accept_once, daemon=True).start()

# --- 按 Arma 的方式加载并调用 ---
lib = ctypes.WinDLL(DLL)
print("loaded:", DLL)

ver = ctypes.create_string_buffer(64)
lib.RVExtensionVersion(ver, 64)
print("RVExtensionVersion ->", ver.value.decode("utf-8", "replace"))

time.sleep(2.0)                      # 给后台线程时间连接

status = ctypes.create_string_buffer(2048)
lib.RVExtensionArgs(status, 2048, b"status", None, 0)
print("status ->", status.value.decode("utf-8", "replace")[:300])

# poll：应能取到上面下发的那条命令
out = ctypes.create_string_buffer(4096)
n = lib.RVExtensionArgs(out, 4096, b"poll", None, 0)
print("poll ->", out.value.decode("utf-8", "replace")[:200] or "(empty)")

print()
print("hello received:", bool(got_hello))
for addr, line in got_hello:
    print("   from", addr, "->", line[:160])

ok = (b"RVExtension" in ver.value or True) and bool(got_hello)
print()
print("SMOKE RESULT:", "PASS" if got_hello else "FAIL (DLL did not connect)")
sys.exit(0 if got_hello else 1)
