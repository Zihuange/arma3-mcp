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

// ⚠ GDI+ 的头文件（GdiplusBitmap.h 等）内部使用 min/max，而本文件定义了
// NOMINMAX（防止 windows.h 的 min/max 宏污染 std）。两者直接相遇会编译失败
// （C2146/C2447）。解法：用 std::min/std::max 补上 GDI+ 需要的名字。
#include <algorithm>
using std::min;
using std::max;
// GDI+ 还依赖 COM 接口（IStream 等），而 WIN32_LEAN_AND_MEAN 把 ole 系列
// 头文件排除了 —— 显式补上，否则 GdiplusImaging.h 会报一堆语法错误。
#include <objidl.h>
#include <gdiplus.h>

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
#pragma comment(lib, "gdiplus.lib")

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

// 执行器心跳：SQF 每轮 poll 都刷新这个时间戳。
//
// 为什么需要它：TCP 接通只说明 DLL 连上了 MCP，**不说明游戏里有东西在取命令**。
// 主菜单、未加载任务、执行器脚本报错，都会让命令静静堆在 g_inq 里，调用方一路
// 等到超时，而且分不清"游戏慢"和"执行器根本没跑"。有了心跳，status 就能直接
// 回答这个问题。0 表示从未 poll 过（执行器从未启动）。
std::atomic<long long> g_last_poll_ms{0};

long long now_ms() {
    return static_cast<long long>(GetTickCount64());
}

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

// 这些命令由 DLL 自己处理，**不进 SQF 队列**。
//
// 为什么：它们是纯 Windows 层操作（输入注入、截图、窗口几何），不需要游戏
// 世界。走 SQF 会白白多一次 poll + callExtension 往返，而且**依赖执行器在跑**
// —— 主菜单、未加载任务时就用不了，恰恰是这些能力最该可用的场景。
struct JVal {
    enum Kind { NUL, BOOL, NUM, STR, ARR, OBJ } kind = NUL;
    bool b = false;
    double num = 0;
    std::string str;
    std::vector<JVal> arr;
    std::vector<std::pair<std::string, JVal> > obj;

    const JVal *find(const std::string &key) const {
        for (size_t i = 0; i < obj.size(); ++i) {
            if (obj[i].first == key) return &obj[i].second;
        }
        return nullptr;
    }
    std::string as_str() const { return kind == STR ? str : std::string(); }
    // 数组元素取值：既是数字也是字符串时都尽量给出可读形态
    std::string item_str(size_t i) const {
        if (kind != ARR || i >= arr.size()) return std::string();
        const JVal &v = arr[i];
        if (v.kind == STR) return v.str;
        if (v.kind == NUM) {
            char buf[64];
            if (v.num == static_cast<double>(static_cast<long long>(v.num))) {
                std::snprintf(buf, sizeof(buf), "%lld",
                              static_cast<long long>(v.num));
            } else {
                std::snprintf(buf, sizeof(buf), "%g", v.num);
            }
            return std::string(buf);
        }
        if (v.kind == BOOL) return v.b ? "1" : "0";
        return std::string();
    }
    const JVal *item(size_t i) const {
        return (kind == ARR && i < arr.size()) ? &arr[i] : nullptr;
    }
};

class JsonParser {
public:
    explicit JsonParser(const std::string &s) : s_(s), i_(0) {}

    bool parse(JVal &out) {
        skip();
        if (!value(out)) return false;
        skip();
        return true;   // 尾部有剩余内容不算错（容忍）
    }

private:
    const std::string &s_;
    size_t i_;

    void skip() {
        while (i_ < s_.size()) {
            char c = s_[i_];
            if (c == ' ' || c == '\t' || c == '\n' || c == '\r') { ++i_; continue; }
            break;
        }
    }
    bool lit(const char *word) {
        size_t n = std::strlen(word);
        if (s_.compare(i_, n, word) == 0) { i_ += n; return true; }
        return false;
    }
    bool value(JVal &out) {
        skip();
        if (i_ >= s_.size()) return false;
        char c = s_[i_];
        if (c == '{') return object(out);
        if (c == '[') return array(out);
        if (c == '"') { out.kind = JVal::STR; return string(out.str); }
        if (lit("true"))  { out.kind = JVal::BOOL; out.b = true;  return true; }
        if (lit("false")) { out.kind = JVal::BOOL; out.b = false; return true; }
        if (lit("null"))  { out.kind = JVal::NUL; return true; }
        return number(out);
    }
    bool string(std::string &out) {
        if (i_ >= s_.size() || s_[i_] != '"') return false;
        ++i_;
        out.clear();
        while (i_ < s_.size()) {
            char c = s_[i_++];
            if (c == '"') return true;
            if (c == '\\' && i_ < s_.size()) {
                char e = s_[i_++];
                switch (e) {
                    case 'n': out += '\n'; break;
                    case 't': out += '\t'; break;
                    case 'r': out += '\r'; break;
                    case 'b': out += '\b'; break;
                    case 'f': out += '\f'; break;
                    case 'u': {
                        // \uXXXX：只处理 BMP 内的 ASCII 情况，其余原样丢弃
                        if (i_ + 4 <= s_.size()) {
                            std::string hex = s_.substr(i_, 4);
                            i_ += 4;
                            unsigned code = static_cast<unsigned>(
                                std::strtoul(hex.c_str(), nullptr, 16));
                            if (code < 0x80) {
                                out += static_cast<char>(code);
                            } else {
                                out += '?';   // 非 ASCII 不在此处还原
                            }
                        }
                        break;
                    }
                    default: out += e; break;
                }
                continue;
            }
            out += c;
        }
        return false;   // 字符串未闭合
    }
    bool number(JVal &out) {
        const char *start = s_.c_str() + i_;
        char *end = nullptr;
        double v = std::strtod(start, &end);
        if (end == start) return false;
        i_ += static_cast<size_t>(end - start);
        out.kind = JVal::NUM;
        out.num = v;
        return true;
    }
    bool array(JVal &out) {
        if (s_[i_] != '[') return false;
        ++i_;
        out.kind = JVal::ARR;
        skip();
        if (i_ < s_.size() && s_[i_] == ']') { ++i_; return true; }
        while (i_ < s_.size()) {
            JVal v;
            if (!value(v)) return false;
            out.arr.push_back(v);
            skip();
            if (i_ < s_.size() && s_[i_] == ',') { ++i_; skip(); continue; }
            if (i_ < s_.size() && s_[i_] == ']') { ++i_; return true; }
            return false;
        }
        return false;
    }
    bool object(JVal &out) {
        if (s_[i_] != '{') return false;
        ++i_;
        out.kind = JVal::OBJ;
        skip();
        if (i_ < s_.size() && s_[i_] == '}') { ++i_; return true; }
        while (i_ < s_.size()) {
            skip();
            std::string key;
            if (!string(key)) return false;
            skip();
            if (i_ >= s_.size() || s_[i_] != ':') return false;
            ++i_;
            JVal v;
            if (!value(v)) return false;
            out.obj.push_back(std::make_pair(key, v));
            skip();
            if (i_ < s_.size() && s_[i_] == ',') { ++i_; continue; }
            if (i_ < s_.size() && s_[i_] == '}') { ++i_; return true; }
            return false;
        }
        return false;
    }
};

// 构造一条 ack 回执 JSON。result_raw 应是**已序列化的 JSON 值**
// （形如 {"ok":true,...}），直接嵌入而不加引号。
std::string make_ack(const std::string &cid, bool ok,
                     const std::string &result_raw) {
    std::string out = "{\"t\":\"ack\",\"cid\":\"" + json_escape(cid) + "\","
                      "\"ok\":" + (ok ? "true" : "false");
    if (ok) {
        out += ",\"result\":" + (result_raw.empty() ? "null" : result_raw);
    } else {
        out += ",\"error\":\"" + json_escape(result_raw) + "\"";
    }
    out += "}";
    return out;
}
// 前向声明：下面的直连分发要调用这些实现，而它们的定义在文件靠后处。
// （C++ 需要先见到声明；这里集中列出，避免为了顺序而把实现搬来搬去。）
std::string window_info();
std::string focus_game();
std::string capture_window(const std::string &out_path, int max_width);
std::string input_move(int x, int y);
std::string input_click(int x, int y, int button, int hold_ms);
std::string input_key(int scan, bool down, int hold_ms);
std::string input_drag(int x1, int y1, int x2, int y2, int steps);
std::string make_status();
std::string json_ok(const std::string &extra);
std::string json_err(const std::string &message);

bool is_native_command(const std::string &name) {
    // status 必须在这里：它是**诊断链路本身**用的命令。
    //
    // 曾经把它漏在直连白名单外，结果它进 g_inq 等 SQF 取走 —— 而"诊断为什么
    // 命令不通"恰恰发生在执行器没跑的时候，于是诊断工具自己先超时，陷入
    // "要查不通的原因，得先用一个不通的工具"的死结。诊断路径必须比被诊断的
    // 对象更可靠：DLL 自己的状态，DLL 自己就能答，不该依赖游戏世界里有没有
    // 人接电话。
    return name == "window_info" || name == "focus_game" ||
           name == "input_move"  || name == "input_click" ||
           name == "input_key"   || name == "input_drag" ||
           name == "capture"     || name == "status";
}

// 从 args 数组里取一个字符串参数
std::string arg_str(const JVal *args, size_t i) {
    const JVal *v = args ? args->item(i) : nullptr;
    if (!v) return std::string();
    if (v->kind == JVal::STR) return v->str;
    if (v->kind == JVal::NUM) return v->item_str(0) == "" ? std::string() : v->item_str(0);
    return std::string();
}

int arg_int(const JVal *args, size_t i, int def) {
    const JVal *v = args ? args->item(i) : nullptr;
    if (!v) return def;
    if (v->kind == JVal::NUM) return static_cast<int>(v->num);
    if (v->kind == JVal::BOOL) return v->b ? 1 : 0;
    if (v->kind == JVal::STR) return std::atoi(v->str.c_str());
    return def;
}

// 执行一条 DLL 直连命令，返回**已序列化的 JSON 结果**
std::string run_native(const std::string &name, const JVal *args) {
    if (name == "status")      return make_status();
    if (name == "window_info") return window_info();
    if (name == "focus_game")  return focus_game();
    if (name == "capture") {
        std::string path = arg_str(args, 0);
        if (path.empty()) return json_err("capture 需要输出路径");
        return capture_window(path, arg_int(args, 1, 0));
    }
    if (name == "input_move") {
        return input_move(arg_int(args, 0, 0), arg_int(args, 1, 0));
    }
    if (name == "input_click") {
        int autofocus = arg_int(args, 4, 0);
        if (autofocus) {
            std::string f = focus_game();
            if (f.find("\"foreground\":true") == std::string::npos) {
                return json_err("自动聚焦失败，前台仍不是游戏窗口");
            }
        }
        return input_click(arg_int(args, 0, 0), arg_int(args, 1, 0),
                           arg_int(args, 2, 0), arg_int(args, 3, 30));
    }
    if (name == "input_key") {
        return input_key(arg_int(args, 0, 0), arg_int(args, 1, 0) != 0,
                         arg_int(args, 2, 0));
    }
    if (name == "input_drag") {
        return input_drag(arg_int(args, 0, 0), arg_int(args, 1, 0),
                          arg_int(args, 2, 0), arg_int(args, 3, 0),
                          arg_int(args, 4, 20));
    }
    return json_err("未实现的直连命令：" + name);
}

void handle_server_line(const std::string &line) {
    // MCP 下发：{"t":"cmd","cid":"...","cmd":"...","args":[...]}
    if (line.empty()) return;

    // 先看是否 DLL 能自己处理（输入/截图/窗口/状态），避免绕 SQF
    JVal msg;
    if (msg.kind == JVal::NUL && JsonParser(line).parse(msg) &&
        msg.kind == JVal::OBJ) {
        const JVal *t = msg.find("t");
        const JVal *c = msg.find("cmd");

        // ⚠ 协议层消息（hello_ack 等）**不是发给 SQF 的命令**，必须在这里
        // 拦住。曾经漏了这一步：t != "cmd" 的消息会掉进下面的入队，于是
        // 执行器每次连接都会取到一条 hello_ack，报"未知的命令类型"，再回一条
        // cid 为空的失败回执——空 cid 的 ack 还会污染 MCP 侧的回执配对。
        // 这是每次连接都必然发生的纯噪声，且症状（莫名其妙的一条错误回执）
        // 离原因很远，所以在此显式记录理由，避免以后又被"简化"掉。
        if (t && t->as_str() != "cmd") {
            return;
        }

        if (t && t->as_str() == "cmd" && c && is_native_command(c->as_str())) {
            const JVal *cid_v = msg.find("cid");
            std::string cid = cid_v ? cid_v->as_str() : "";
            const JVal *args = msg.find("args");
            std::string result = run_native(c->as_str(), args);
            // 结果自身带 ok 字段；这里统一包成 ack
            bool ok = result.find("\"ok\":false") == std::string::npos;
            g_outq.push(make_ack(cid, true, result));
            g_rx_lines.fetch_add(1);
            write_diag(line);
            (void)ok;
            return;
        }
    }

    // 其余命令仍交给 SQF 执行（表达式、config 查询等需要游戏世界）。
    // 解析失败的行也走这里：宁可让 SQF 报"未知的命令类型"，也不要静默吞掉
    // ——诊断信息比干净更重要。
    g_inq.push(line);
    g_rx_lines.fetch_add(1);
    write_diag(line);
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
    // poll_ms_ago: 距今多少毫秒前执行器取过命令；-1 表示从未取过（执行器未启动）。
    // 调用方用 "> 2000ms 或 -1" 判定执行器没在跑，而不是靠 inbox 猜。
    long long last_poll = g_last_poll_ms.load();
    long long poll_ago = (last_poll == 0) ? -1 : (now_ms() - last_poll);
    std::snprintf(buf, sizeof(buf),
        "{\"ok\":true,\"connected\":%s,\"addr\":\"%s\",\"ver\":\"%s\","
        "\"inbox\":%zu,\"outbox\":%zu,\"dropped\":%zu,"
        "\"rx\":%lld,\"tx\":%lld,\"connects\":%lld,\"poll_ms_ago\":%lld,"
        "\"error\":\"%s\"}",
        g_connected.load() ? "true" : "false",
        json_escape(cfg.addr()).c_str(), kVersion,
        g_inq.size(), g_outq.size(), g_inq.dropped.load(),
        g_rx_lines.load(), g_tx_lines.load(), g_connects.load(),
        poll_ago,
        json_escape(get_error()).c_str());
    return std::string(buf);
}

// ===========================================================================
// 用户操作模拟与视觉捕捉
//
// 这两块放在 DLL（游戏进程内）而不是外部工具，理由：
//   · 进程内才能直接判定"目标窗口是否属于本进程"，避免误操作别的程序；
//   · 进程内才能用 PrintWindow 抓取本进程的 DirectX 画面；
//   · 不需要跨进程坐标换算带来的误差。
// ===========================================================================

// ------------------------------------------------------------------ 输入注入

// 找本进程的"游戏主窗口"：枚举顶层窗口，取可见且客户区面积最大的那个。
//
// 为什么不用 GetForegroundWindow 直接当目标：游戏**经常不是前台**（用户在看
// 文档、看 Agent 输出），而截图在后台完全可以进行。之前把截图也绑在前台上，
// 结果是"用户一旦切走就截不到图"——这不是安全需要，是设计缺陷。
// 只有**输入注入**才必须要求前台（SendInput 作用于系统输入队列，前台不是
// 游戏时会点到别的程序上）。
HWND find_game_window() {
    struct Ctx { HWND best; long long area; };
    Ctx ctx = {nullptr, 0};
    EnumWindows([](HWND hwnd, LPARAM lp) -> BOOL {
        Ctx *c = reinterpret_cast<Ctx *>(lp);
        DWORD pid = 0;
        GetWindowThreadProcessId(hwnd, &pid);
        if (pid != GetCurrentProcessId()) return TRUE;
        if (!IsWindowVisible(hwnd)) return TRUE;
        RECT rc = {0, 0, 0, 0};
        if (!GetClientRect(hwnd, &rc)) return TRUE;
        long long area = static_cast<long long>(rc.right - rc.left)
                       * static_cast<long long>(rc.bottom - rc.top);
        if (area > c->area) { c->area = area; c->best = hwnd; }
        return TRUE;
    }, reinterpret_cast<LPARAM>(&ctx));
    return ctx.best;
}

// 前台校验：只允许对本进程的窗口注入。
//
// 为什么必须校验：SendInput 作用于**系统输入队列**，注入时如果前台是别的
// 窗口，那次点击就会打到那个窗口上（可能是浏览器、可能是聊天框）。
// 这不是"可能出错"，而是"必然会打错"，所以默认拒绝而不是尽力而为。
bool foreground_is_self(std::string &why) {
    HWND fg = GetForegroundWindow();
    if (!fg) {
        why = "当前没有前台窗口";
        return false;
    }
    DWORD pid = 0;
    GetWindowThreadProcessId(fg, &pid);
    if (pid != GetCurrentProcessId()) {
        why = "前台窗口不属于游戏进程（拒绝注入，避免误操作其它程序）";
        return false;
    }
    return true;
}

std::string json_ok(const std::string &extra = "") {
    return extra.empty() ? std::string("{\"ok\":true}")
                         : std::string("{\"ok\":true,") + extra + "}";
}

std::string json_err(const std::string &message) {
    return "{\"ok\":false,\"error\":\"" + json_escape(message) + "\"}";
}

// 从 " 100 200 0 30" 这类尾部提取整数序列。
// 转发命令的参数是空格分隔的整数，没有嵌套结构，不需要 JSON 解析。
std::vector<int> tail_ints(const std::string &s) {
    std::vector<int> out;
    const char *p = s.c_str();
    while (*p) {
        while (*p == ' ' || *p == '\t') ++p;
        if (!*p) break;
        char *end = nullptr;
        long v = std::strtol(p, &end, 10);
        if (end == p) break;          // 不是数字就停
        out.push_back(static_cast<int>(v));
        p = end;
    }
    return out;
}

// 鼠标坐标一律用**屏幕坐标**（SendInput 与 SetCursorPos 都按屏幕坐标工作）。
// 调用方应先 window_info 拿到客户区原点，再做换算。
std::string input_move(int x, int y) {
    if (!SetCursorPos(x, y)) {
        return json_err("SetCursorPos 失败（坐标越界？）");
    }
    return json_ok();
}

std::string input_click(int x, int y, int button, int hold_ms) {
    std::string why;
    if (!foreground_is_self(why)) return json_err(why);

    if (!SetCursorPos(x, y)) return json_err("SetCursorPos 失败");
    Sleep(10);   // 给系统一点时间更新指针位置，再发按键

    DWORD down_flag = MOUSEEVENTF_LEFTDOWN, up_flag = MOUSEEVENTF_LEFTUP;
    if (button == 1) { down_flag = MOUSEEVENTF_RIGHTDOWN; up_flag = MOUSEEVENTF_RIGHTUP; }
    else if (button == 2) { down_flag = MOUSEEVENTF_MIDDLEDOWN; up_flag = MOUSEEVENTF_MIDDLEUP; }

    INPUT in = {};
    in.type = INPUT_MOUSE;
    in.mi.dwFlags = down_flag;
    if (SendInput(1, &in, sizeof(INPUT)) != 1) {
        return json_err("SendInput 按下失败（输入被系统拒绝？）");
    }
    if (hold_ms > 0) Sleep(hold_ms > 5000 ? 5000 : hold_ms);
    in.mi.dwFlags = up_flag;
    SendInput(1, &in, sizeof(INPUT));
    return json_ok("\"x\":" + std::to_string(x) + ",\"y\":" + std::to_string(y));
}

// 键盘：用扫描码（KEYEVENTF_SCANCODE）而不是虚拟键码。
// 游戏普遍按扫描码读键盘（与键盘布局无关），用虚拟键码在非美式布局下会错位。
std::string input_key(int scan, bool down, int hold_ms) {
    std::string why;
    if (!foreground_is_self(why)) return json_err(why);
    if (scan <= 0 || scan > 255) return json_err("扫描码应在 1..255");

    INPUT in = {};
    in.type = INPUT_KEYBOARD;
    in.ki.wScan = static_cast<WORD>(scan);
    in.ki.dwFlags = KEYEVENTF_SCANCODE | (down ? 0 : KEYEVENTF_KEYUP);
    if (SendInput(1, &in, sizeof(INPUT)) != 1) {
        return json_err("SendInput 键盘事件失败");
    }
    if (down && hold_ms > 0) {
        Sleep(hold_ms > 5000 ? 5000 : hold_ms);
        in.ki.dwFlags = KEYEVENTF_SCANCODE | KEYEVENTF_KEYUP;
        SendInput(1, &in, sizeof(INPUT));
    }
    return json_ok();
}

// 拖拽：按下 -> 分步移动 -> 抬起。
// 分步而不是瞬移：很多 UI 只在指针**移动过程**中更新拖拽状态，
// 一次跳到终点会被当作"没有拖拽"。
std::string input_drag(int x1, int y1, int x2, int y2, int steps) {
    std::string why;
    if (!foreground_is_self(why)) return json_err(why);
    if (steps < 1) steps = 1;
    if (steps > 100) steps = 100;

    INPUT in = {};
    in.type = INPUT_MOUSE;

    SetCursorPos(x1, y1);
    Sleep(10);
    in.mi.dwFlags = MOUSEEVENTF_LEFTDOWN;
    if (SendInput(1, &in, sizeof(INPUT)) != 1) return json_err("拖拽按下失败");

    for (int i = 1; i <= steps; ++i) {
        int x = x1 + (x2 - x1) * i / steps;
        int y = y1 + (y2 - y1) * i / steps;
        SetCursorPos(x, y);
        Sleep(15);
    }

    in.mi.dwFlags = MOUSEEVENTF_LEFTUP;
    SendInput(1, &in, sizeof(INPUT));
    return json_ok("\"from\":[" + std::to_string(x1) + "," + std::to_string(y1)
                   + "],\"to\":[" + std::to_string(x2) + "," + std::to_string(y2)
                   + "],\"steps\":" + std::to_string(steps));
}

// ------------------------------------------------------------------ 窗口信息

// 坐标换算的前提：调用方必须知道客户区在屏幕上的原点与 DPI。
// 直接把这三个数给出去，胜过在文档里描述。
std::string window_info() {
    // 报告"游戏窗口"而不是"前台窗口"：调用方关心的是该往哪儿点、截哪儿，
    // 而游戏多半不在前台。同时如实告知它当前是否前台 —— 输入注入需要。
    HWND hwnd = find_game_window();
    if (!hwnd) return json_err("找不到游戏窗口（扩展尚未在游戏进程内加载？）");

    HWND fg = GetForegroundWindow();
    bool is_self = (fg == hwnd);

    RECT wr = {0, 0, 0, 0}, cr = {0, 0, 0, 0};
    GetWindowRect(hwnd, &wr);
    GetClientRect(hwnd, &cr);
    POINT origin = {0, 0};
    ClientToScreen(hwnd, &origin);

    UINT dpi = 96;
    using GetDpiForWindowFn = UINT(WINAPI *)(HWND);
    HMODULE user32 = GetModuleHandleA("user32.dll");
    if (user32) {
        auto fn = reinterpret_cast<GetDpiForWindowFn>(
            GetProcAddress(user32, "GetDpiForWindow"));
        if (fn) dpi = fn(hwnd);
    }

    char buf[512];
    std::snprintf(buf, sizeof(buf),
        "{\"ok\":true,\"is_self\":%s,\"foreground\":true,"
        "\"window\":[%ld,%ld,%ld,%ld],"
        "\"client\":[%ld,%ld],"
        "\"client_origin\":[%ld,%ld],"
        "\"dpi\":%u,\"scale\":%.2f}",
        is_self ? "true" : "false",
        wr.left, wr.top, wr.right, wr.bottom,
        cr.right, cr.bottom,
        origin.x, origin.y, dpi, dpi / 96.0);
    return std::string(buf);
}

// ------------------------------------------------------------------ 窗口聚焦

// 把游戏窗口切到前台。
//
// 为什么需要绕：Windows 只允许**当前前台进程**调用 SetForegroundWindow 成功，
// 否则它只会闪一下任务栏图标。绕过办法是把自己附加到前台窗口的输入队列
// （AttachThreadInput），使本线程"看起来"属于前台线程，再调用即可生效。
// 这是长期存在的系统行为，不是权宜 hack。
std::string focus_game() {
    HWND hwnd = find_game_window();
    if (!hwnd) return json_err("找不到游戏窗口");

    if (IsIconic(hwnd)) {
        ShowWindow(hwnd, SW_RESTORE);
    }

    HWND fg = GetForegroundWindow();
    if (fg == hwnd) {
        return json_ok("\"foreground\":true,\"already\":true");
    }

    DWORD fg_thread = fg ? GetWindowThreadProcessId(fg, nullptr) : 0;
    DWORD my_thread = GetCurrentThreadId();
    bool attached = false;
    if (fg_thread != 0 && fg_thread != my_thread) {
        attached = AttachThreadInput(my_thread, fg_thread, TRUE) != 0;
    }

    BOOL ok = SetForegroundWindow(hwnd);
    BringWindowToTop(hwnd);
    SetActiveWindow(hwnd);

    if (attached) {
        AttachThreadInput(my_thread, fg_thread, FALSE);
    }

    // 等窗口管理器把切换做完，否则紧接着的注入可能仍打到旧前台窗口上
    Sleep(120);

    bool now_fg = (GetForegroundWindow() == hwnd);
    char buf[256];
    std::snprintf(buf, sizeof(buf),
        "{\"ok\":true,\"foreground\":%s,\"set_ok\":%s,\"attached\":%s}",
        now_fg ? "true" : "false", ok ? "true" : "false",
        attached ? "true" : "false");
    return std::string(buf);
}

// ------------------------------------------------------------------ 视觉捕捉

ULONG_PTR g_gdiplus_token = 0;
bool g_gdiplus_ready = false;

bool ensure_gdiplus() {
    if (g_gdiplus_ready) return true;
    Gdiplus::GdiplusStartupInput input;
    if (Gdiplus::GdiplusStartup(&g_gdiplus_token, &input, nullptr) != Gdiplus::Ok) {
        return false;
    }
    g_gdiplus_ready = true;
    return true;
}

int encoder_clsid(const WCHAR *mime, CLSID *clsid) {
    UINT num = 0, size = 0;
    Gdiplus::GetImageEncodersSize(&num, &size);
    if (size == 0) return -1;
    auto *info = static_cast<Gdiplus::ImageCodecInfo *>(malloc(size));
    if (!info) return -1;
    Gdiplus::GetImageEncoders(num, size, info);
    int found = -1;
    for (UINT i = 0; i < num; ++i) {
        if (wcscmp(info[i].MimeType, mime) == 0) {
            *clsid = info[i].Clsid;
            found = static_cast<int>(i);
            break;
        }
    }
    free(info);
    return found;
}

// 把窗口画面存成 PNG。
//
// 优先级：PrintWindow + PW_RENDERFULLCONTENT（能抓到 DirectX 内容）
//        → 失败则退回 BitBlt（窗口化模式下通常可用；独占全屏会得到黑屏）。
//
// 缩放：给上层一个 max_width 是因为截图可能很大（1080p 的 PNG 上 MB），
// 而 MCP 返回图片要走 JSON 传输，体积直接决定往返耗时。
std::string capture_window(const std::string &out_path, int max_width) {
    if (!ensure_gdiplus()) return json_err("GDI+ 初始化失败");

    // 截图在**后台也能做**：目标是游戏窗口，不要求它是前台。
    // （只有输入注入才必须前台。）
    HWND hwnd = find_game_window();
    if (!hwnd) return json_err("找不到游戏窗口");

    RECT cr = {0, 0, 0, 0};
    GetClientRect(hwnd, &cr);
    int w = cr.right - cr.left;
    int h = cr.bottom - cr.top;
    if (w <= 0 || h <= 0) return json_err("窗口客户区尺寸无效");

    HDC hdc = GetDC(hwnd);
    HDC mem = CreateCompatibleDC(hdc);
    HBITMAP bmp = CreateCompatibleBitmap(hdc, w, h);
    if (!bmp || !mem) {
        if (bmp) DeleteObject(bmp);
        if (mem) DeleteDC(mem);
        ReleaseDC(hwnd, hdc);
        return json_err("创建位图失败");
    }
    HGDIOBJ old = SelectObject(mem, bmp);

    // 先试能抓 DirectX 的方式
    BOOL printed = PrintWindow(hwnd, mem, 0x00000002 /* PW_RENDERFULLCONTENT */);
    const char *method = "PrintWindow";
    if (!printed) {
        BitBlt(mem, 0, 0, w, h, hdc, 0, 0, SRCCOPY);
        method = "BitBlt";
    }

    Gdiplus::Bitmap image(bmp, nullptr);

    // 需要缩放时先生成缩放副本
    Gdiplus::Bitmap *to_save = &image;
    Gdiplus::Bitmap *scaled = nullptr;
    int out_w = w, out_h = h;
    if (max_width > 0 && w > max_width) {
        out_w = max_width;
        out_h = static_cast<int>(static_cast<double>(h) * max_width / w);
        if (out_h < 1) out_h = 1;
        scaled = new Gdiplus::Bitmap(out_w, out_h, PixelFormat32bppARGB);
        Gdiplus::Graphics g(scaled);
        g.SetInterpolationMode(Gdiplus::InterpolationModeHighQualityBicubic);
        g.DrawImage(&image, 0, 0, out_w, out_h);
        to_save = scaled;
    }

    CLSID clsid;
    std::string error;
    if (encoder_clsid(L"image/png", &clsid) < 0) {
        error = "找不到 PNG 编码器";
    } else {
        std::wstring wide(out_path.begin(), out_path.end());
        if (to_save->Save(wide.c_str(), &clsid, nullptr) != Gdiplus::Ok) {
            error = "保存 PNG 失败（路径不可写？）";
        }
    }

    if (scaled) delete scaled;
    SelectObject(mem, old);
    DeleteObject(bmp);
    DeleteDC(mem);
    ReleaseDC(hwnd, hdc);

    if (!error.empty()) return json_err(error);

    char buf[640];
    std::snprintf(buf, sizeof(buf),
        "{\"ok\":true,\"path\":\"%s\",\"width\":%d,\"height\":%d,"
        "\"source_width\":%d,\"source_height\":%d,\"method\":\"%s\"}",
        json_escape(out_path).c_str(), out_w, out_h, w, h, method);
    return std::string(buf);
}

// ===========================================================================
// 极简 JSON 解析（仅覆盖 MCP 下发的固定结构）
//
// ## 为什么需要它
//
// 输入注入与截图是 DLL 自己的能力，但 MCP 下发的命令原先统一入队交给 SQF，
// 再让 SQF 用 callExtension 转回来 —— 白白绕一圈，而且**依赖 SQF 执行器在跑**
// （主菜单、未加载任务时就用不了，正是那两项能力最该可用的场景）。
//
// 要让 DLL 直接处理，就得从消息里取出 cid 与 args，于是需要解析 JSON。
// 这里只实现必要的子集：对象/数组/字符串/数字/布尔/null，足以覆盖
// {"t":"cmd","cid":"...","cmd":"...","args":[...]} 这一种结构。
// 不做通用 JSON 库，也不处理任何畸形输入之外的情况。
// ===========================================================================


std::string handle_call(const std::string &fn,
                        const std::vector<std::string> &args) {
    if (fn == "status") {
        return make_status();
    }
    if (fn == "poll") {
        // 执行器心跳：能被 poll 到，就说明游戏里有脚本在跑。注意即使队列为空
        // 也要刷新——"活着但没活干"和"死了"必须能区分开。
        g_last_poll_ms.store(now_ms());
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
    // ---- 用户操作模拟与视觉捕捉 ----
    //
    // 这些命令由 SQF 转发过来（MCP 下发的命令统一进 SQF 队列，SQF 再用
    // callExtension 转一手）。转发形式是**单字符串**："cmd arg1 arg2 …"。
    // 不用数组形式的原因见文件末尾关于 push/poll 的说明：数组形式在引擎侧
    // 不可靠，而单字符串形式没有中间层。
    if (fn == "window_info") {
        return window_info();
    }
    if (fn == "focus_game") {
        return focus_game();
    }
    if (fn.rfind("input_move", 0) == 0) {
        std::vector<int> v = tail_ints(fn.substr(10));
        if (v.size() < 2) return json_err("input_move 需要 x y");
        return input_move(v[0], v[1]);
    }
    if (fn.rfind("input_click", 0) == 0) {
        std::vector<int> v = tail_ints(fn.substr(11));
        if (v.size() < 2) return json_err("input_click 需要 x y [button] [hold_ms] [autofocus]");
        // 第 5 个参数是 auto_focus：注入前先抢焦点。
        // 否则前台不是游戏时会被保护性拒绝（这是对的，但用户不在游戏前时
        // 就完全用不了，所以给调用方一个显式选择）。
        if (v.size() > 4 && v[4] != 0) {
            std::string f = focus_game();
            if (f.find("\"foreground\":true") == std::string::npos) {
                return json_err("自动聚焦失败，前台仍不是游戏窗口");
            }
        }
        return input_click(v[0], v[1],
                           v.size() > 2 ? v[2] : 0,
                           v.size() > 3 ? v[3] : 30);
    }
    if (fn.rfind("input_key", 0) == 0) {
        std::vector<int> v = tail_ints(fn.substr(9));
        if (v.size() < 2) return json_err("input_key 需要 scan down [hold_ms]");
        return input_key(v[0], v[1] != 0, v.size() > 2 ? v[2] : 0);
    }
    if (fn.rfind("input_drag", 0) == 0) {
        std::vector<int> v = tail_ints(fn.substr(10));
        if (v.size() < 4) return json_err("input_drag 需要 x1 y1 x2 y2 [steps]");
        return input_drag(v[0], v[1], v[2], v[3], v.size() > 4 ? v[4] : 20);
    }
    if (fn.rfind("capture ", 0) == 0) {
        // 路径可能含空格，但 max_width 一定是末尾的纯数字，据此从右往左切
        std::string rest = fn.substr(8);
        std::string path = rest;
        int mw = 0;
        size_t sp = rest.rfind(' ');
        if (sp != std::string::npos) {
            std::string last = rest.substr(sp + 1);
            bool digits = !last.empty();
            for (size_t i = 0; i < last.size(); ++i) {
                if (!isdigit(static_cast<unsigned char>(last[i]))) { digits = false; break; }
            }
            if (digits) { path = rest.substr(0, sp); mw = std::atoi(last.c_str()); }
        }
        if (path.empty()) return json_err("capture 需要输出路径");
        return capture_window(path, mw);
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
