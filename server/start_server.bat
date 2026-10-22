@echo off
rem Boot the dedicated-server test environment (P3).
rem
rem Modelled on arma_llm_commander (ALC) -- see server.cfg for the three things it
rem taught us. The two that cost real time here:
rem   * a task must be declared via class Missions + -autoInit; passing -mission=
rem     only works for persistent missions, and the server silently skips it
rem     otherwise ("Autolnit is supported only for persistent missions!").
rem   * stdout/stderr must be redirected to a file. A dedicated server has no UI;
rem     without a log there is nothing to look at when it misbehaves.
rem
rem Keep this file pure ASCII and CRLF (cmd.exe reads .bat as OEM codepage).
rem
rem BEFORE RUNNING: the server's DLL dials the same MCP game port as the client
rem (32131), and the MCP server keeps only ONE active connection -- starting this
rem will knock a running client off.

setlocal
set "GAME=H:\SteamLibrary\steamapps\common\Arma 3\arma3server_x64.exe"
set "WS=H:\SteamLibrary\steamapps\common\Arma 3\!Workshop"
rem Self-locating: %~dp0 is this script's folder (server\), so the repo can be
rem moved or renamed without editing anything here. MODDIR walks up one level
rem to the mod that lives at the repo root.
set "HERE=%~dp0"
set "HERE=%HERE:~0,-1%"
set "MODDIR=%~dp0..\game\mod"
set "MODS=%WS%\@CBA_A3;%MODDIR%"
set "PORT=2302"

if not exist "%GAME%" (
  echo [x] Dedicated server not found: %GAME%
  echo     Install "Arma 3 Server" from Steam tools.
  pause
  exit /b 1
)
if not exist "%HERE%\server.cfg" (
  echo [x] server.cfg not found under %HERE%
  pause
  exit /b 1
)
if not exist "%HERE%\mpmissions\mcp_test.Altis\initServer.sqf" (
  echo [x] Test mission not found under %HERE%\mpmissions\mcp_test.Altis
  echo     Without it the executor never starts on the server.
  pause
  exit /b 1
)

rem -init= loads the extension. Same char-code trick as the client: quotes get
rem eaten somewhere in the argument chain.
rem   arma3_mcp = 97,114,109,97,51,95,109,99,112
rem   status    = 115,116,97,116,117,115
set "INIT_CODE=toString [97,114,109,97,51,95,109,99,112] callExtension toString [115,116,97,116,117,115]"

rem -profiles= points at this directory, so the server looks for mpmissions/
rem under it (and keeps its own profile files here, out of the way).
rem -mod= MUST be quoted: the path contains "Arma 3" (a space), and without quotes
rem the engine takes only up to "common\Arma" and silently drops the rest -- the
rem mod list then shows just the built-in "Arma", surfacing later as
rem "CallExtension could not be found".
rem The server only looks for missions in <game>/mpmissions/ -- -profiles= does
rem NOT change that search path (measured: "Can't find mission template: ... in
rem 'mpmissions\\'"). So the test mission is kept in this repo as the source of
rem truth and copied into place on every start; that way editing it here is enough
rem and nobody has to remember a manual copy step.
set "GAMEDIR=H:\SteamLibrary\steamapps\common\Arma 3"
set "MISSIONDIR=%GAMEDIR%\mpmissions\mcp_test.Altis"
if not exist "%MISSIONDIR%" mkdir "%MISSIONDIR%"
copy /y "%HERE%\mpmissions\mcp_test.Altis\mission.sqm" "%MISSIONDIR%\mission.sqm" >nul
copy /y "%HERE%\mpmissions\mcp_test.Altis\initServer.sqf" "%MISSIONDIR%\initServer.sqf" >nul

echo Starting dedicated server on port %PORT% ...
echo   mission deployed to %MISSIONDIR%
echo   mods     : %MODS%
echo   profiles : %HERE%
echo   mission  : mcp_test.Altis  (autoInit)
echo   log      : %HERE%\server_stdout.log
echo   Note: this will replace the client's MCP connection.
echo.

"%GAME%" "-port=%PORT%" "-config=%HERE%\server.cfg" "-profiles=%HERE%" "-name=mcp" "-mod=%MODS%" -nosound -noSplash -skipIntro -noPause -showScriptErrors -filePatching -autoInit "-init=%INIT_CODE%" > "%HERE%\server_stdout.log" 2>&1

echo.
echo Server exited. Log tail:
powershell -NoProfile -Command "Get-Content '%HERE%\server_stdout.log' -Tail 12" 2>nul
pause >nul
