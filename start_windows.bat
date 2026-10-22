@echo off
rem arma3-mcp launcher for the Windows side (HTTP transport).
rem
rem For **stdio** -- the default and the recommended mode when the MCP client
rem runs on the same machine -- you do NOT need this script. Point the client at
rem     python "<repo>\start.py"
rem and it spawns the server itself.
rem
rem Use this launcher only when the client cannot spawn a Windows process,
rem e.g. DSH running inside WSL: Node under WSL cannot execute Windows programs
rem (spawn returns ENOENT), so the server must be started by hand and the
rem client connects over HTTP. See docs/deploy.md.
rem
rem All settings come from a3mcp.json (copy a3mcp.example.json first).
rem Extra arguments are passed through to start.py, e.g.
rem     start_windows.bat --http-port 32130
rem
rem Keep this file pure ASCII and CRLF: cmd.exe reads .bat in the OEM codepage,
rem so UTF-8 text would corrupt parsing.
setlocal

rem Self-locating: %~dp0 is this script's folder, trailing backslash included.
set "HERE=%~dp0"

rem Optional: pin an interpreter via the PY_FALLBACK environment variable.
rem The default below is the author's machine; it is used ONLY when that file
rem actually exists, so it is harmless on other machines (falls back to PATH).
if not defined PY_FALLBACK set "PY_FALLBACK=H:\Program Files\Anaconda3\python.exe"
set "PY="
if exist "%PY_FALLBACK%" set "PY=%PY_FALLBACK%"
if not defined PY (
  for /f "delims=" %%I in ('where python 2^>nul') do (
    if not defined PY set "PY=%%I"
  )
)
if not defined PY (
  echo [x] No python.exe found.
  echo     Put python on PATH, or set PY_FALLBACK before running this script.
  pause
  exit /b 1
)

if not exist "%HERE%start.py" (
  echo [x] start.py not found under %HERE%
  pause
  exit /b 1
)

echo Starting arma3-mcp (HTTP transport). Press Ctrl+C to stop.
echo Settings come from a3mcp.json in this folder; see a3mcp.example.json.
echo.
"%PY%" "%HERE%start.py" --http %*

echo.
echo Server exited. Press any key to close.
pause >nul
