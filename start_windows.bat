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
set "PY=H:\Program Files\Anaconda3\python.exe"
set "HERE=<repo>"
set "PORT=%~1"
if "%PORT%"=="" set "PORT=32128"

if not exist "%PY%" (
  echo [x] Python not found: %PY%
  echo     Edit set "PY=..." in this file to point at your python.exe.
  pause
  exit /b 1
)
if not exist "%HERE%\serve_http.py" (
  echo [x] serve_http.py not found under %HERE%
  pause
  exit /b 1
)

cd /d "%HERE%"
echo Starting arma3-mcp HTTP transport on port %PORT% ...
echo The line marked with a star is the url DSH needs.
echo Press Ctrl+C to stop.
echo.
"%PY%" "%HERE%\serve_http.py" --port %PORT%

echo.
echo Server exited. Press any key to close.
pause >nul
