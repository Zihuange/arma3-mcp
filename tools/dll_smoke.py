"""DLL smoke test: exercise the exported functions the way Arma does, with no Arma 3.

What is checked here -- all of it painful to discover only in-game:
  1. the DLL loads (dependencies / bitness);
  2. the three exports can be called with Arma's signatures without crashing;
  3. the background network thread really works: a fake MCP listener sees it
     connect and complete the handshake;
  4. the native-command whitelist routes correctly: `status` is answered by the
     DLL itself, while a command that needs the game world is queued for SQF;
  5. the executor heartbeat tells the truth: "never polled" before any SQF poll,
     and refreshed right after one.

Why (4) matters: `status` used to be missing from that whitelist, so it went
into the SQF queue -- which meant the diagnostic tool timed out exactly when the
executor was down, i.e. exactly when you need it.

Why (5) matters: "the TCP link is up" and "something in the game will execute
commands" are different facts, and the main menu is the normal case where the
first is true and the second is not. The heartbeat is what separates them.

NOTE: loading the DLL makes it dial 127.0.0.1:32131 by default, and the real MCP
server replaces its active connection when a new one arrives -- so a naive run
would knock the actual game off mid-session. This script therefore loads a copy
whose default port is rewritten to an unused one; see prepare().

ASCII only: Windows Python defaults to the ANSI codepage and raises on CJK text.
"""
import ctypes, json, os, socket, sys, tempfile, threading, time

DLL = sys.argv[1]
PORT = int(sys.argv[2]) if len(sys.argv) > 2 else 32131


def prepare(dll_path, port):
    """Return a copy of the DLL whose default port is `port`.

    Why: the DLL starts dialing from DllMain, and the MCP server keeps a single
    active connection that a newcomer replaces. Running this test against the
    real port would therefore displace the live game. Rewriting the default port
    gives the test its own private target.

    The default port is a 5-digit ASCII literal in .rdata, so an equal-width
    replacement leaves the binary layout intact.
    """
    want = str(port).encode()
    if want == b"32131":
        return dll_path
    data = open(dll_path, "rb").read()
    if data.count(b"32131") != 1:
        raise SystemExit("expected exactly 1 default-port literal, found %d"
                         % data.count(b"32131"))
    out = os.path.join(tempfile.gettempdir(),
                       "a3mcp_smoke_%s.dll" % want.decode())
    with open(out, "wb") as fh:
        fh.write(data.replace(b"32131", want))
    return out

got_hello = []
results = {}                        # label -> (passed, detail)
cmds_sent = threading.Event()

# --- fake MCP: accept one connection, drive it through the interesting cases ---
srv = socket.socket()
srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
srv.bind(("127.0.0.1", PORT))
srv.listen(1)
srv.settimeout(8)


class Conn:
    """Line-framed JSON connection (keeps leftovers across reads)."""

    def __init__(self, sock):
        self.sock = sock
        self.buf = b""

    def send(self, obj):
        self.sock.sendall(json.dumps(obj).encode() + b"\n")

    def line(self, deadline):
        while time.time() < deadline:
            if b"\n" in self.buf:
                line, _, self.buf = self.buf.partition(b"\n")
                return line.decode("utf-8", "replace")
            try:
                chunk = self.sock.recv(65536)
            except socket.timeout:
                continue
            except OSError:
                return None
            if not chunk:
                return None
            self.buf += chunk
        return None

    def wait_ack(self, cid, timeout):
        deadline = time.time() + timeout
        while time.time() < deadline:
            line = self.line(deadline)
            if line is None:
                return None
            try:
                msg = json.loads(line)
            except ValueError:
                continue
            if msg.get("t") == "ack" and msg.get("cid") == cid:
                return msg
        return None


def accept_once():
    try:
        conn, addr = srv.accept()
        conn.settimeout(0.3)
        c = Conn(conn)

        hello = c.line(time.time() + 5)
        got_hello.append((addr, (hello or "").strip()))

        # (4a) native command -- the DLL answers by itself, no SQF involved.
        c.send({"t": "cmd", "cid": "s1", "cmd": "status", "args": []})
        ack = c.wait_ack("s1", 2.0)
        if ack is None:
            results["status answered natively"] = (
                False, "no ack within 2s -- it went to the SQF queue")
        elif "poll_ms_ago" not in json.dumps(ack):
            results["status answered natively"] = (
                False, "acked, but no poll_ms_ago field (stale DLL?)")
        else:
            results["status answered natively"] = (True, "acked with heartbeat")

        # (4b) game-world command -- must be deferred to SQF, so NO ack here.
        c.send({"t": "cmd", "cid": "s2", "cmd": "exec",
                "args": ["1 + 1", []]})
        ack2 = c.wait_ack("s2", 1.5)
        results["exec deferred to SQF"] = (
            ack2 is None,
            "no ack here, as expected" if ack2 is None
            else "unexpected ack before any SQF poll")

        # (4c) A protocol reply is NOT a command. If it were queued, the executor
        # would pick it up, report "unknown command type", and answer with a
        # cid-less ack that pollutes reply matching -- on every single connect.
        c.send({"t": "hello_ack", "ver": 1, "server": "arma3-mcp"})
        time.sleep(0.3)

        cmds_sent.set()
        time.sleep(2.0)
        conn.close()
    except Exception as exc:                      # noqa: BLE001
        got_hello.append(("ERR", str(exc)))
        cmds_sent.set()


threading.Thread(target=accept_once, daemon=True).start()

# --- load and call it the way Arma does ---
lib = ctypes.WinDLL(prepare(DLL, PORT))
print("loaded:", DLL)
print("dialing:", "127.0.0.1:%d" % PORT)

ver = ctypes.create_string_buffer(64)
lib.RVExtensionVersion(ver, 64)
print("RVExtensionVersion ->", ver.value.decode("utf-8", "replace"))


def ask_status():
    """Call the extension the way SQF does and parse the status JSON."""
    buf = ctypes.create_string_buffer(2048)
    lib.RVExtensionArgs(buf, 2048, b"status", None, 0)
    raw = buf.value.decode("utf-8", "replace")
    try:
        return raw, json.loads(raw)
    except ValueError:
        return raw, {}


time.sleep(2.0)                      # give the background thread time to connect
cmds_sent.wait(8)

# (5a) Nothing has polled yet -- this is exactly the main-menu state, where no
# SQF executor exists. The heartbeat must say so (-1) rather than stay silent:
# before this field existed, callers could only guess from the inbox depth, and
# inbox=0 read as "fine" whether the executor had just drained the queue or had
# never existed at all.
raw_before, before = ask_status()
print("status before any poll ->", raw_before[:200])
results["heartbeat says never-polled"] = (
    before.get("poll_ms_ago") == -1,
    "poll_ms_ago=%r" % before.get("poll_ms_ago"))

# (4c) Stand in for the SQF executor and poll the queued command out. This also
# shows the two paths really are separate: `status` came back over the socket,
# while `exec` is only reachable here.
out = ctypes.create_string_buffer(4096)
lib.RVExtensionArgs(out, 4096, b"poll", None, 0)
polled = out.value.decode("utf-8", "replace")[:200]
print("poll ->", polled or "(empty)")
results["queued exec retrievable via poll"] = (
    "exec" in polled,
    polled[:80] if polled else "poll returned nothing")

# A second poll must come back empty: the hello_ack sent above must not
# have been queued. This is the regression guard for that bug.
out2 = ctypes.create_string_buffer(4096)
lib.RVExtensionArgs(out2, 4096, b"poll", None, 0)
leftover = out2.value.decode("utf-8", "replace")[:200]
results["protocol message not queued"] = (
    leftover.strip() == "",
    "queue empty, as expected" if leftover.strip() == ""
    else "hello_ack leaked into the queue: %s" % leftover[:80])

# (5b) Polling must refresh the heartbeat -- otherwise a perfectly healthy
# executor would keep looking dead and every diagnosis would be a false alarm.
raw_after, after = ask_status()
print("status after poll ->", raw_after[:300])
ago = after.get("poll_ms_ago")
results["poll refreshes heartbeat"] = (
    isinstance(ago, int) and 0 <= ago < 3000,
    "poll_ms_ago=%r" % ago)

print()
print("hello received:", bool(got_hello))
for addr, line in got_hello:
    print("   from", addr, "->", line[:160])

print()
print("checks:")
all_ok = bool(got_hello)
for label in ("status answered natively", "exec deferred to SQF",
              "queued exec retrievable via poll",
              "heartbeat says never-polled", "poll refreshes heartbeat",
              "protocol message not queued"):
    passed, detail = results.get(label, (False, "not reached"))
    all_ok = all_ok and passed
    print("   [%s] %-38s %s" % ("PASS" if passed else "FAIL", label, detail))

print()
print("SMOKE RESULT:", "PASS" if all_ok else "FAIL")
sys.exit(0 if all_ok else 1)
