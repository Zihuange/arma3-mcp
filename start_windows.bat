@echo off
rem arma3-mcp launcher for the Windows side (HTTP transport).
rem
rem Why this exists: the DSH instance on this machine runs as a Node process
rem inside WSL, and Node under WSL cannot execute Windows programs
rem (spawn returns ENOENT -- see docs/decisions.md D14). So the MCP server
rem cannot be auto-started by the harness; you launch it here instead and
rem DSH connects over HTTP (transport: streamable-http).
rem
rem Keep this file pure ASCII and CRLF: cmd.exe reads .bat in the OEM
rem codepage, so UTF-8 text would corrupt parsing.
setlocal
rem Self-locating: %~dp0 is this script's folder, so the repo can be moved or
rem renamed without editing anything here. The trailing backslash that %~dp0
rem carries is relied on: "%HERE%\serve_http.py" needs it, and it is stripped
rem only where the path is used as a bare directory (cd below).
set "HERE=%~dp0"
set "HERE=%HERE:~0,-1%"
set "PORT=%~1"
if "%PORT%"=="" set "PORT=32128"

rem Execution channel. Without these two the server starts on the NULL channel:
rem HTTP comes up, the tool list looks fine, but NOTHING that touches the game
rem works -- gates_status just says "not connected" with no obvious cause. Both values
rem are therefore defaulted here (the repo's own launcher should not need the
rem user to know them):
rem   A3MCP_CHANNEL=tcp   -- listen for the game's DLL to connect
rem   A3MCP_TCP_PORT=32132 -- MUST match the DLL's default (armA3_mcp_extension.cpp:
rem                           std::string port = "32132"); a mismatch fails silently
rem                           from the game side
rem Pre-set either variable to override (if not defined keeps your value).
if not defined A3MCP_CHANNEL set "A3MCP_CHANNEL=tcp"
if not defined A3MCP_TCP_PORT set "A3MCP_TCP_PORT=32132"

rem Python: PY_FALLBACK first (this machine's Anaconda install -- the one the
rem rest of this repo uses), then whatever "python" is on PATH. Order matters:
rem on Windows a "python" that resolves to the Microsoft Store stub exists on
rem PATH but cannot run anything, so PATH alone is not a reliable answer.
set "PY_FALLBACK=H:\Program Files\Anaconda3\python.exe"
set "PY="
if exist "%PY_FALLBACK%" set "PY=%PY_FALLBACK%"
if not defined PY (
  for /f "delims=" %%I in ('where python 2^>nul') do (
    if not defined PY set "PY=%%I"
  )
)

if not defined PY (
  echo [x] No python.exe found.
  echo     Put python on PATH, or set PY_FALLBACK near the top of this file.
  pause
  exit /b 1
)
if not exist "%PY%" (
  echo [x] Python not found: %PY%
  echo     Put python on PATH, or set PY_FALLBACK near the top of this file.
  pause
  exit /b 1
)
if not exist "%HERE%\serve_http.py" (
  echo [x] serve_http.py not found under %HERE%
  pause
  exit /b 1
)

cd /d "%HERE%"

rem Allow native input injection (synthetic mouse/keyboard into the game).
rem
rem Why it is on here: off is the upstream default, because a tool that can
rem move the user's mouse is a real hazard. This launcher turns it on because
rem driving the game *is* the point of this setup -- without it the agent can
rem look (screenshot) but never act.
rem
rem The hazards that remain, and why they are acceptable:
rem   * injection only fires while the game window is foreground
rem     (A3MCP_INPUT_FOREGROUND_ONLY), so the pointer is never hijacked away;
rem   * the DLL itself refuses to act on any window that does not belong to the
rem     game process, so a mis-aimed coordinate cannot click another program.
rem Remove this line (or set it to 0) to go back to look-but-don't-touch.
set "A3MCP_INPUT_INJECT=1"

echo Starting arma3-mcp HTTP transport on port %PORT% ...
echo The line marked with a star is the url DSH needs.
echo Press Ctrl+C to stop.
echo.
echo   input injection: %A3MCP_INPUT_INJECT%  (1 = the agent may drive the game)
echo   channel        : %A3MCP_CHANNEL% on port %A3MCP_TCP_PORT%  (must match the DLL; null = nothing that touches the game will work)
echo.
"%PY%" "%HERE%\serve_http.py" --port %PORT%

echo.
echo Server exited. Press any key to close.
pause >nul
