@echo off
rem Launch Arma 3 with the arma3-mcp mod mounted.
rem
rem Why this file exists: it is easy to start the game without the mod
rem (e.g. from Steam directly), and the symptom is silent -- no error in
rem game, but the MCP side just says "game not connected". This launcher
rem always includes the mod path.
rem
rem Edit MODS below if your other mods change.
rem Keep this file pure ASCII and CRLF (cmd.exe reads .bat as OEM codepage).

setlocal
set "GAME=H:\SteamLibrary\steamapps\common\Arma 3\Arma3_x64.exe"
set "WS=H:\SteamLibrary\steamapps\common\Arma 3\!Workshop"
set "MODS=%WS%\@Enhanced Movement;%WS%\@CBA_A3;%WS%\@Achilles;<repo>\game\mod"

if not exist "%GAME%" (
  echo [x] Game not found: %GAME%
  pause
  exit /b 1
)
if not exist "<repo>\game\mod\addons\a3mcp.pbo" (
  echo [x] Mod PBO not found under <repo>\game\mod
  pause
  exit /b 1
)

echo Launching Arma 3 with arma3-mcp mounted...
start "" "%GAME%" -skipIntro -noSplash -malloc=system -hugePages -noPause -noPauseAudio -showScriptErrors "-mod=%MODS%"
