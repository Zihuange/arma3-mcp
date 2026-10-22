cmake_minimum_required(VERSION 3.15)
project(arma3_mcp_extension LANGUAGES CXX)

# arma3-mcp 的游戏侧扩展（Arma 3 Extension）。
#
# 目标平台：Windows x64（Arma 3 客户端与专用服务器都是 64 位进程）。
#
# 构建：
#   cmake -S game/extension -B build/ext -A x64
#   cmake --build build/ext --config Release
#
# 产物落 game/mod/（即模组根目录）：Arma 从游戏可执行文件所在目录与模组根
# 探测扩展 DLL，x64 进程优先探测 <name>_x64.dll，故同时输出两个名字。

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(NOT WIN32)
    message(FATAL_ERROR "本扩展只面向 Windows（Arma 3 是 Windows 进程）")
endif()

add_library(arma3_mcp SHARED src/arma3_mcp_extension.cpp)

target_compile_definitions(arma3_mcp PRIVATE
    WIN32_LEAN_AND_MEAN
    NOMINMAX
    _CRT_SECURE_NO_WARNINGS
)
target_link_libraries(arma3_mcp PRIVATE ws2_32)

# 源文件含 UTF-8 中文注释：必须让 MSVC 按 UTF-8 解析。默认按本地代码页解析
# 会让注释吞掉换行，产生大范围级联编译错误（同类工程的实测教训）。
if(MSVC)
    target_compile_options(arma3_mcp PRIVATE /utf-8)
endif()

# 产物必须落**模组根**：Arma 只从"游戏可执行文件目录"与"模组根"探测扩展，
# 不会去 Release/ 这类子目录里找。
#
# ⚠ 只设 RUNTIME_OUTPUT_DIRECTORY 是不够的：Visual Studio 是**多配置生成器**，
# 会在其后追加 <配置> 子目录（实测产物落在 game/mod/Release/）。
# 故同时设置 RUNTIME_OUTPUT_DIRECTORY_<CONFIG> 把配置子目录钉死。
set(A3MCP_MOD_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../mod")
set_target_properties(arma3_mcp PROPERTIES
    OUTPUT_NAME "arma3_mcp"
    RUNTIME_OUTPUT_DIRECTORY "${A3MCP_MOD_DIR}"
    RUNTIME_OUTPUT_DIRECTORY_DEBUG "${A3MCP_MOD_DIR}"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${A3MCP_MOD_DIR}"
    RUNTIME_OUTPUT_DIRECTORY_RELWITHDEBINFO "${A3MCP_MOD_DIR}"
    RUNTIME_OUTPUT_DIRECTORY_MINSIZEREL "${A3MCP_MOD_DIR}"
    # .lib/.exp 是构建中间产物，**不要**放进模组目录（会污染交付物，
    # 也会让"模组目录里该有什么"变得含糊）
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../../build/ext/lib"
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../../build/ext/lib"
)

# x64 优先探测名的副本
add_custom_command(TARGET arma3_mcp POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_FILE:arma3_mcp>"
        "${CMAKE_CURRENT_SOURCE_DIR}/../mod/arma3_mcp_x64.dll"
    COMMENT "复制为 arma3_mcp_x64.dll（x64 进程优先探测该名）"
)
