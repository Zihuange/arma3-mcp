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

rem ===================================================================
rem -init= : load the extension AND start the SQF executor at game launch
rem
rem Why -init= at all: preInit/postInit are MISSION-scoped triggers -- they
rem only run once a mission is loaded. Sitting in the main menu, neither
rem fires, so the executor never starts and the DLL never loads (extensions
rem load on the first callExtension). Upstream that looks like "game not
rem connected" with no error anywhere.
rem
rem Two things happen here:
rem   1. load the DLL -- screenshot / input / window_info then work right
rem      away, in the main menu, with no mission loaded;
rem   2. start the SQF executor -- so exec / config_* work too. That needs
rem      the mod's a3mcp_fnc_init, hence the retry loop below.
rem
rem NO QUOTES ANYWHERE. A trailing quote in -init= gets eaten somewhere in
rem the argument chain (reproduced with and without the "start" command),
rem so every string is built from char codes via toString. Three measured
rem failure modes, all from quotes:
rem   1) a bare file path    -> the engine tries to run the path as SQF
rem   2) execVM with quotes  -> RPT: "Error: missing '"
rem   3) the "start" command -> re-parses and eats quotes inside -init=
rem
rem Why the retry loop: -init= runs VERY early (right after CBA PreStart,
rem before the UI exists), so the mod's functions may not be compiled yet.
rem We poll once a second until a3mcp_fnc_init shows up, then call it. The
rem result is logged to the RPT, so one startup answers the open question
rem without guesswork:
rem   A3MCP-BOOT   the spawned starter ran
rem   A3MCP-FN-OK  a3mcp_fnc_init was found -> executor starting
rem   A3MCP-NOFN   it never appeared within the wait window, i.e.
rem                CfgFunctions is not compiled in the main menu
rem
rem Do NOT touch the UI from -init=: a plain "hint" here caused
rem ACCESS_VIOLATION and crashed the game. Only spawn a guarded starter.
rem ===================================================================

rem Char codes for the strings used above (toString builds them without
rem quotes):
rem   arma3_mcp      = 97,114,109,97,51,95,109,99,112
rem   status         = 115,116,97,116,117,115
rem   a3mcp_fnc_init = 97,51,109,99,112,95,102,110,99,95,105,110,105,116
rem   A3MCP-BOOT     = 65,51,77,67,80,45,66,79,79,84
rem   A3MCP-NOFN     = 65,51,77,67,80,45,78,79,70,78
rem   A3MCP-FN-OK    = 65,51,77,67,80,45,70,78,45,79,75
set "CD_EXT=toString [97,114,109,97,51,95,109,99,112]"
set "CD_STATUS=toString [115,116,97,116,117,115]"
set "CD_FN=toString [97,51,109,99,112,95,102,110,99,95,105,110,105,116]"
set "CD_BOOT=toString [65,51,77,67,80,45,66,79,79,84]"
set "CD_NOFN=toString [65,51,77,67,80,45,78,79,70,78]"
set "CD_OK=toString [65,51,77,67,80,45,70,78,45,79,75]"

rem Seconds to wait for the mod functions before giving up (logged as NOFN).
set "WAIT=60"

set "INIT_CODE=%CD_EXT% callExtension %CD_STATUS% ; [] spawn { diag_log %CD_BOOT% ; private _fn = %CD_FN% ; private _n = 0 ; while { _n < %WAIT% } do { _n = _n + 1 ; if (!isNil { missionNamespace getVariable _fn }) exitWith {} ; sleep 1 } ; private _f = missionNamespace getVariable _fn ; if (isNil { _f }) then { diag_log %CD_NOFN% } else { diag_log %CD_OK% ; call _f } }"

echo Launching Arma 3 with arma3-mcp mounted...
echo   executor start: attempted from -init= (see A3MCP-* lines in the RPT)
"%GAME%" -skipIntro -noSplash -malloc=system -hugePages -noPause -noPauseAudio -showScriptErrors "-mod=%MODS%" "-init=%INIT_CODE%"
