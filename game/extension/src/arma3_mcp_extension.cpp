// arma3_mcp_extension.cpp
// ---------------------------------------------------------------------------
// arma3-mcp 的游戏侧扩展：把 MCP 服务器的命令送进游戏、把结果送回去。
//
// ## 连接方向
//
// **本扩展作为 TCP 客户端**主动连回 MCP。方向这样定有两个理由：
//   1. MCP 服务器与游戏**都在 Windows 上**（本机形态），所以默认目标是
//      `127.0.0.1` —— 本机回环，不经防火墙、不依赖任何外部 IP；
//   2. 即便将来 MCP 跑在 WSL 里（另一种形态），"游戏连出去"的方向也仍然
//      可用（实测 Windows → WSL 可达，反向不可达）。
// 让游戏侧做客户端，两种形态都不需要改代码，只需改 `configure` 的地址。
//
// ## 为什么网络全在后台线程
//
// `callExtension` 在**游戏逻辑线程**内同步执行。任何阻塞调用都会卡住游戏帧。
// 因此：导出函数只做队列交换（内存操作），socket 收发、重连全部交给后台线程。
// 这条约束在同类工程里被反复验证过，是本文件最重要的结构决定。
//
// ## poll 模型
//
// 引擎不会主动通知 SQF "有命令来了"，只能由 SQF 定时调用 `poll` 取走。
// 所以命令到达后先进本地队列，等 SQF 来取。队列有上限（防止游戏掉线期间
// 无限堆积），**满时丢弃最老的**并把丢弃计数报给 MCP —— 静默丢弃会让上层
// 得出完全错误的结论（"命令成功"），这类失败比报错更贵。
//
// ## 接口
//
//   "arma3_mcp" callExtension ["status", []]            -> 连接状态与统计（JSON）
//   "arma3_mcp" callExtension ["poll", []]              -> 取一条待执行命令（JSON 或 ""）
//   "arma3_mcp" callExtension ["push", [文本]]           -> 上行事件/回执（JSON）
//   "arma3_mcp" callExtension ["configure", [host, port]] -> 设置 MCP 地址（JSON）
//
// 参数与返回都用 JSON，理由：`callExtension` 的参数是字符串数组，返回是字符串，
// 交给引擎的 JSON 解析（SQF 有 fromJSON/toJSON）比自己造分隔符可靠得多 ——
// 自造分隔符会在参数里出现同名分隔符时静默错位。
// ---------------------------------------------------------------------------

#define WIN32_LEAN_AND_MEAN
#define NOMINMAX
#define _WIN32_WINNT 0x0601

#include <winsock2.h>
#include <ws2tcpip.h>
#include <windows.h>

#include <atomic>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <deque>
#include <mutex>
#include <string>
#include <thread>
#include <vector>

#pragma comment(lib, "ws2_32.lib")

namespace a3mcp {

// ------------------------------------------------------------------ 常量

constexpr size_t kMaxLineIn = 1 << 20;   // 单行上限 1MB（防御性）
constexpr size_t kMaxLineOut = 16384;    // 上行单行上限（实测 >=16384 不截断）
constexpr size_t kInqCap = 256;          // 待取命令队列上限
constexpr size_t kOutqCap = 4096;        // 待发队列上限
constexpr int kConnectTimeoutMs = 3000;
constexpr int kRetryDelayMs = 2000;
constexpr int kSelectWaitMs = 100;
constexpr char kVersion[] = "0.1.0";

// ------------------------------------------------------------------ 配置

struct Config {
    // 默认目标：本机回环（MCP 与游戏同机时不需要任何额外配置）
    std::string host = "127.0.0.1";
    std::string port = "32131";
    std::string token = "arma3-mcp-local";

    std::string addr() const { return host + ":" + port; }
};

std::mutex g_cfg_mtx;
Config g_cfg;

// ------------------------------------------------------------------ 队列

struct TextQueue {
    std::mutex mtx;
    std::deque<std::string> q;
    size_t cap;
    std::atomic<size_t> dropped{0};

    explicit TextQueue(size_t c) : cap(c) {}

    // 满时丢最老，并计数（绝不静默）
    void push(const std::string &s) {
        std::lock_guard<std::mutex> lock(mtx);
        q.push_back(s);
        while (q.size() > cap) {
            q.pop_front();
            dropped.fetch_add(1);
        }
    }

    bool pop(std::string &out) {
        std::lock_guard<std::mutex> lock(mtx);
        if (q.empty()) return false;
        out = q.front();
        q.pop_front();
        return true;
    }

    size_t size() {
        std::lock_guard<std::mutex> lock(mtx);
        return q.size();
    }
};

TextQueue g_inq(kInqCap);    // 下行：MCP 命令 -> SQF poll 取走
TextQueue g_outq(kOutqCap);  // 上行：SQF push -> 后台线程发送

std::atomic<bool> g_connected{false};
std::atomic<bool> g_stop{false};
std::atomic<bool> g_force_reconnect{false};
std::atomic<long long> g_rx_lines{0};
std::atomic<long long> g_tx_lines{0};
std::atomic<long long> g_connects{0};

std::mutex g_err_mtx;
std::string g_last_error;

void set_error(const std::string &e) {
    std::lock_guard<std::mutex> lock(g_err_mtx);
    g_last_error = e;
}

std::string get_error() {
    std::lock_guard<std::mutex> lock(g_err_mtx);
    return g_last_error;
}

// ------------------------------------------------------------------ 工具

std::string json_escape(const std::string &in) {
    std::string out;
    out.reserve(in.size() + 8);
    for (unsigned char c : in) {
        switch (c) {
            case '"':  out += "\\\""; break;
            case '\\': out += "\\\\"; break;
            case '\n': out += "\\n"; break;
            case '\r': out += "\\r"; break;
            case '\t': out += "\\t"; break;
            default:
                if (c < 0x20) {
                    char buf[8];
                    std::snprintf(buf, sizeof(buf), "\\u%04x", c);
                    out += buf;
                } else {
                    out += static_cast<char>(c);
                }
        }
    }
    return out;
}

// 极简 JSON 字段提取：只支持 {"key":"value"} 与 {"key":value} 顶层标量。
// 不引第三方 JSON 库（本扩展要保持零依赖、单文件可审）。
bool json_get_string(const std::string &json, const std::string &key,
                     std::string &out) {
    std::string needle = "\"" + key + "\"";
    size_t pos = json.find(needle);
    if (pos == std::string::npos) return false;
    pos = json.find(':', pos + needle.size());
    if (pos == std::string::npos) return false;
    size_t i = pos + 1;
    while (i < json.size() && std::isspace(static_cast<unsigned char>(json[i]))) ++i;
    if (i >= json.size() || json[i] != '"') return false;
    ++i;
    std::string value;
    while (i < json.size()) {
        char c = json[i];
        if (c == '\\' && i + 1 < json.size()) {
            char n = json[i + 1];
            if (n == 'n') value += '\n';
            else if (n == 't') value += '\t';
            else if (n == 'r') value += '\r';
            else value += n;
            i += 2;
            continue;
        }
        if (c == '"') break;
        value += c;
        ++i;
    }
    out = value;
    return true;
}

// ------------------------------------------------------------------ 网络

bool connect_socket(SOCKET &out_sock, const Config &cfg) {
    addrinfo hints{};
    hints.ai_family = AF_INET;
    hints.ai_socktype = SOCK_STREAM;
    hints.ai_protocol = IPPROTO_TCP;
    addrinfo *res = nullptr;
    if (getaddrinfo(cfg.host.c_str(), cfg.port.c_str(), &hints, &res) != 0) {
        set_error("getaddrinfo 失败：" + cfg.addr());
        return false;
    }

    SOCKET s = INVALID_SOCKET;
    for (addrinfo *p = res; p != nullptr; p = p->ai_next) {
        s = socket(p->ai_family, p->ai_socktype, p->ai_protocol);
        if (s == INVALID_SOCKET) continue;

        u_long nonblock = 1;
        ioctlsocket(s, FIONBIO, &nonblock);
        int rc = connect(s, p->ai_addr, static_cast<int>(p->ai_addrlen));
        if (rc == SOCKET_ERROR) {
            fd_set wf;
            FD_ZERO(&wf);
            FD_SET(s, &wf);
            timeval tv{};
            tv.tv_sec = kConnectTimeoutMs / 1000;
            tv.tv_usec = (kConnectTimeoutMs % 1000) * 1000;
            if (select(0, nullptr, &wf, nullptr, &tv) <= 0) {
                closesocket(s);
                s = INVALID_SOCKET;
                continue;
            }
            int soerr = 0, len = sizeof(soerr);
            getsockopt(s, SOL_SOCKET, SO_ERROR, reinterpret_cast<char *>(&soerr), &len);
            if (soerr != 0) {
                closesocket(s);
                s = INVALID_SOCKET;
                continue;
            }
        }
        u_long blocking = 0;
        ioctlsocket(s, FIONBIO, &blocking);
        break;
    }
    freeaddrinfo(res);

    if (s == INVALID_SOCKET) {
        set_error("connect 失败：" + cfg.addr() + "（游戏侧连不到 MCP，"
                  "检查地址与 MCP 是否在监听）");
        return false;
    }
    out_sock = s;
    return true;
}

// 把 outq 全部发出；失败时把未发出的部分放回队列（不丢）
void flush_outbound(SOCKET s) {
    std::vector<std::string> batch;
    std::string line;
    while (g_outq.pop(line)) batch.push_back(line);
    for (size_t i = 0; i < batch.size(); ++i) {
        std::string wire = batch[i] + "\n";
        size_t sent = 0;
        while (sent < wire.size()) {
            int n = send(s, wire.c_str() + sent,
                         static_cast<int>(wire.size() - sent), 0);
            if (n == SOCKET_ERROR) {
                set_error("send 失败，code=" + std::to_string(WSAGetLastError()));
                g_outq.push(wire.substr(sent));
                for (size_t j = i + 1; j < batch.size(); ++j) g_outq.push(batch[j]);
                return;
            }
            sent += static_cast<size_t>(n);
        }
        g_tx_lines.fetch_add(1);
    }
}

// 诊断文件路径：DLL 在自身进程内，SQF 看不见它的队列，出问题时
// "命令到没到 DLL" 无从判断。写一个小文件让外部（MCP/人）能直接读，
// 这在排查"MCP 发了但游戏没反应"时是唯一的直接证据。
std::string diag_path() {
    // 优先环境变量；否则写在 DLL 同目录的固定文件名。
    // 为什么默认要写：DLL 在游戏进程内，SQF 看不见它的队列；而不能依赖
    // 环境变量（游戏由用户手动启动，注入变量不方便）。写一个小文本文件
    // 是"命令到没到 DLL"最直接的取证方式。
    char buf[MAX_PATH] = {0};
    DWORD n = GetEnvironmentVariableA("ALC_DLL_DIAG", buf, MAX_PATH);
    if (n > 0 && n < MAX_PATH) return std::string(buf);

    HMODULE self = nullptr;
    if (GetModuleHandleExA(GET_MODULE_HANDLE_EX_FLAG_FROM_ADDRESS
                           | GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT,
                           reinterpret_cast<LPCSTR>(&diag_path), &self)) {
        char path[MAX_PATH] = {0};
        DWORD len = GetModuleFileNameA(self, path, MAX_PATH);
        if (len > 0 && len < MAX_PATH) {
            std::string full(path);
            size_t slash = full.find_last_of("\\/");
            if (slash != std::string::npos) {
                return full.substr(0, slash + 1) + "arma3_mcp_diag.txt";
            }
        }
    }
    return std::string();
}

void write_diag(const std::string &last) {
    std::string path = diag_path();
    if (path.empty()) return;
    FILE *f = std::fopen(path.c_str(), "wb");
    if (!f) return;
    // tx 是"回执是否真的发出去了"的证据：SQF 记了 ack -> 但 MCP 收不到时，
    // 看 tx 有没有增长即可分开"DLL 没发"与"发了但没到"。
    std::fprintf(f, "rx=%lld\ntx=%lld\ninbox=%zu\noutbox=%zu\nconnects=%lld\nconnected=%d\nlast=%s\n",
                 g_rx_lines.load(), g_tx_lines.load(), g_inq.size(), g_outq.size(),
                 g_connects.load(), g_connected.load() ? 1 : 0,
                 last.substr(0, 300).c_str());
    std::fclose(f);
}

void handle_server_line(const std::string &line) {
    // MCP 下发：{"t":"cmd","cid":"...","cmd":"...","args":[...]}
    // 转成 SQF 侧要的形态原样入队（由 SQF 自己解析 JSON，DLL 不解释内容）
    if (line.empty()) return;
    g_inq.push(line);
    g_rx_lines.fetch_add(1);
    write_diag(line);          // 诊断：命令确实到了 DLL
}

void network_loop() {
    while (!g_stop.load()) {
        Config cfg;
        {
            std::lock_guard<std::mutex> lock(g_cfg_mtx);
            cfg = g_cfg;
        }

        SOCKET s = INVALID_SOCKET;
        if (!connect_socket(s, cfg)) {
            g_connected.store(false);
            Sleep(kRetryDelayMs);
            continue;
        }
        g_connected.store(true);
        g_connects.fetch_add(1);
        set_error("");

        // hello：MCP 侧要先握手再收命令
        {
            std::string hello = "{\"t\":\"hello\",\"token\":\"" +
                json_escape(cfg.token) + "\",\"ver\":\"" + kVersion +
                "\",\"pid\":" + std::to_string(GetCurrentProcessId()) +
                ",\"poll_ms\":100}\n";
            send(s, hello.c_str(), static_cast<int>(hello.size()), 0);
            g_tx_lines.fetch_add(1);
        }

        std::string rbuf;
        while (!g_stop.load() && !g_force_reconnect.exchange(false)) {
            flush_outbound(s);

            fd_set rf;
            FD_ZERO(&rf);
            FD_SET(s, &rf);
            timeval tv{};
            tv.tv_sec = 0;
            tv.tv_usec = kSelectWaitMs * 1000;
            int rc = select(0, &rf, nullptr, nullptr, &tv);
            if (rc == SOCKET_ERROR) {
                set_error("select 失败，code=" + std::to_string(WSAGetLastError()));
                break;
            }
            if (rc == 0) continue;

            char buf[65536];
            int n = recv(s, buf, sizeof(buf), 0);
            if (n <= 0) {
                set_error("连接被对端关闭");
                break;
            }
            rbuf.append(buf, static_cast<size_t>(n));
            size_t pos;
            while ((pos = rbuf.find('\n')) != std::string::npos) {
                std::string line = rbuf.substr(0, pos);
                rbuf.erase(0, pos + 1);
                if (line.size() > kMaxLineIn) continue;
                handle_server_line(line);
            }
            if (rbuf.size() > kMaxLineIn) rbuf.clear();
        }

        closesocket(s);
        g_connected.store(false);
        Sleep(200);
    }
}

// ------------------------------------------------------------------ 导出

// 返回值统一为 JSON 对象字符串。调用方（SQF）用 fromJSON 解析。
std::string make_status() {
    Config cfg;
    {
        std::lock_guard<std::mutex> lock(g_cfg_mtx);
        cfg = g_cfg;
    }
    char buf[1024];
    std::snprintf(buf, sizeof(buf),
        "{\"ok\":true,\"connected\":%s,\"addr\":\"%s\",\"ver\":\"%s\","
        "\"inbox\":%zu,\"outbox\":%zu,\"dropped\":%zu,"
        "\"rx\":%lld,\"tx\":%lld,\"connects\":%lld,\"error\":\"%s\"}",
        g_connected.load() ? "true" : "false",
        json_escape(cfg.addr()).c_str(), kVersion,
        g_inq.size(), g_outq.size(), g_inq.dropped.load(),
        g_rx_lines.load(), g_tx_lines.load(), g_connects.load(),
        json_escape(get_error()).c_str());
    return std::string(buf);
}

std::string handle_call(const std::string &fn,
                        const std::vector<std::string> &args) {
    if (fn == "status") {
        return make_status();
    }
    if (fn == "poll") {
        std::string line;
        if (!g_inq.pop(line)) return "";   // 空串 = 无命令（SQF 侧据此跳过）
        return line;
    }
    if (fn == "push") {
        // SQF 上行：事件或回执，原样入队由后台线程发出
        if (args.empty()) return "{\"ok\":false,\"error\":\"push 需要参数\"}";
        g_outq.push(args[0]);
        return "{\"ok\":true,\"queued\":true}";
    }
    if (fn == "configure") {
        // 运行时改地址：游戏启动脚本可先写入，再 poll
        std::lock_guard<std::mutex> lock(g_cfg_mtx);
        if (args.size() >= 2 && !args[0].empty() && !args[1].empty()) {
            g_cfg.host = args[0];
            g_cfg.port = args[1];
            if (args.size() >= 3 && !args[2].empty()) g_cfg.token = args[2];
            g_force_reconnect.store(true);
            return std::string("{\"ok\":true,\"addr\":\"") +
                   json_escape(g_cfg.addr()) + "\"}";
        }
        return make_status();
    }
    return "{\"ok\":false,\"error\":\"未知的函数名：\" + fn}";
}

}  // namespace a3mcp

// ---------------------------------------------------------------------------
// Arma 3 Extension 导出接口
//   接口签名依据 Bohemia 官方样例：extern "C" + __declspec(dllexport) +
//   __stdcall（x64 下 __stdcall 无实际作用，但保持与 x86 兼容的写法）。
// ---------------------------------------------------------------------------

extern "C" {

__declspec(dllexport) void __stdcall RVExtensionVersion(char *output,
                                                         int outputSize) {
    std::snprintf(output, static_cast<size_t>(outputSize), "arma3_mcp %s",
                  a3mcp::kVersion);
}

__declspec(dllexport) void __stdcall RVExtension(char *output, int outputSize,
                                                  const char *function) {
    std::string fn = function ? function : "";
    std::string result;

    // 支持 "push <text>" 形式。
    //
    // 为什么上行不走数组形式 ["push", [text]]：实测数组形式在引擎侧
    // **参数传递不可靠**（poll 的返回布局同样异常，见 fn_loop 注释）——
    // 表现为 DLL 收到空参数、发送空行，而 MCP 会跳过空行，
    // 于是"SQF 明明记了 ack、MCP 永远收不到"。
    // 单字符串形式把文本直接放进 function 里，没有中间层。
    static const std::string kPushPrefix = "push ";
    if (fn.compare(0, kPushPrefix.size(), kPushPrefix) == 0) {
        std::string payload = fn.substr(kPushPrefix.size());
        // 防御：payload 里若有换行会破坏 NDJSON 协议（一行一消息），
        // 这里统一替换成空格，宁可内容变形也不要污染协议。
        for (char &ch : payload) {
            if (ch == '\n' || ch == '\r') ch = ' ';
        }
        a3mcp::g_outq.push(payload);
        result = "{\"ok\":true,\"queued\":true}";
    } else {
        result = a3mcp::handle_call(fn, {});
    }
    std::snprintf(output, static_cast<size_t>(outputSize), "%s", result.c_str());
}

__declspec(dllexport) int __stdcall RVExtensionArgs(char *output,
                                                     int outputSize,
                                                     const char *function,
                                                     const char **argv,
                                                     int argc) {
    std::string fn = function ? function : "";
    std::vector<std::string> args;
    args.reserve(static_cast<size_t>(argc > 0 ? argc : 0));
    for (int i = 0; i < argc; ++i) {
        args.emplace_back(argv[i] ? argv[i] : "");
    }
    std::string result = a3mcp::handle_call(fn, args);
    std::snprintf(output, static_cast<size_t>(outputSize), "%s", result.c_str());
    return 0;
}

}  // extern "C"

// ---------------------------------------------------------------------------
// DllMain：启动后台网络线程。注意**不在 DllMain 里做任何可能阻塞的事**
// （加载器锁持有期间阻塞会导致死锁），所以线程创建后立即返回。
// ---------------------------------------------------------------------------
BOOL APIENTRY DllMain(HMODULE, DWORD reason, LPVOID) {
    if (reason == DLL_PROCESS_ATTACH) {
        WSADATA wsa{};
        WSAStartup(MAKEWORD(2, 2), &wsa);
        std::thread(a3mcp::network_loop).detach();
    } else if (reason == DLL_PROCESS_DETACH) {
        a3mcp::g_stop.store(true);
    }
    return TRUE;
}
