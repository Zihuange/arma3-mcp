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
rem The mod path is derived from this script's own location (%~dp0 = the folder
rem holding this file, trailing backslash included), so moving or renaming the
rem repo needs no edit here. GAME and WS above still have to be edited by hand:
rem where Steam put Arma 3 cannot be derived from anything in this repo.
set "MODDIR=%~dp0game\mod"
set "MODS=%WS%\@Enhanced Movement;%WS%\@CBA_A3;%WS%\@Achilles;%MODDIR%"

if not exist "%GAME%" (
  echo [x] Game not found: %GAME%
  pause
  exit /b 1
)
if not exist "%MODDIR%\addons\a3mcp.pbo" (
  echo [x] Mod PBO not found under %MODDIR%
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
rem Why the probes: -init= runs VERY early (right after CBA PreStart, before
rem the UI exists), so the mod's functions may not be compiled yet. We do not
rem guess -- we ask, synchronously, and report the answer over the extension.
rem See the "Probes" block below for what each marker means.
rem
rem Do NOT touch the UI from -init=: a plain "hint" here caused
rem ACCESS_VIOLATION and crashed the game.
rem ===================================================================

rem Char codes for the strings used above (toString builds them without
rem quotes). Probe markers are reported back through the extension as plain
rem text (see the probes below), so they are short on purpose:
rem   arma3_mcp      = 97,114,109,97,51,95,109,99,112
rem   status         = 115,116,97,116,117,115
rem   "push "        = 112,117,115,104,32     (note the trailing space)
rem   a3mcp_fnc_init = 97,51,109,99,112,95,102,110,99,95,105,110,105,116
rem   P1  = 80,49   reached the synchronous part of -init=
rem   P2Y = 80,50,89   a3mcp_fnc_init IS defined here
rem   P2N = 80,50,78   a3mcp_fnc_init is NOT defined here
rem   P3  = 80,51   call returned (fn_init ran)
rem   P4  = 80,52   the spawned block reached the scheduler
set "CD_EXT=toString [97,114,109,97,51,95,109,99,112]"
set "CD_STATUS=toString [115,116,97,116,117,115]"
set "CD_PUSH=toString [112,117,115,104,32]"
set "CD_FN=toString [97,51,109,99,112,95,102,110,99,95,105,110,105,116]"

rem ---------------------------------------------------------------------------
rem Probes. The previous version used spawn + sleep to retry until the mod
rem functions appeared; that produced NO output at all, and the RPT showed why:
rem -init= runs while the engine is still loading moves/anims, i.e. before the
rem scheduler is up, so spawned blocks silently never run. Everything here is
rem therefore SYNCHRONOUS -- no spawn, no sleep, no waitUntil.
rem
rem Each step reports through the extension ("push <text>"), which is a plain
rem callExtension and works at this stage. Read them with the MCP tool
rem game_events. Markers and their meaning are listed above.
rem
rem MEASURED RESULT (2026-09-25): the probes came back P1 + P2N, and no P4.
rem So: the synchronous part runs and the push channel works, the mod's
rem CfgFunctions are NOT compiled in the main menu, and spawned blocks never
rem execute this early. The executor therefore cannot start from -init= --
rem that is engine behaviour, not a coding problem. See decisions.md D20.
rem
rem The probes stay: they are cheap, and if the engine or CBA ever changes
rem this behaviour, one startup will show it instead of another round of
rem guessing. Markers are listed above; read them with the MCP tool
rem game_events (each step reports through the extension's "push" channel,
rem which is a plain callExtension and does work at this stage).
rem ---------------------------------------------------------------------------
rem Note: no SQF local variables are declared here, on purpose. `private` at the
rem top level of -init= has never been verified to work, and a variable used
rem inside the spawned block is exactly what makes SQFLint emit "possibly
rem undefined variable" (it treats a nested block as a new scope). Repeating the
rem char-code expressions costs a few hundred bytes and removes both questions.
rem Everything here is synchronous.
set "INIT_CODE=%CD_EXT% callExtension %CD_STATUS% ; if (isNil { missionNamespace getVariable %CD_FN% }) then { %CD_EXT% callExtension (%CD_PUSH% + toString [80,49]) ; %CD_EXT% callExtension (%CD_PUSH% + toString [80,50,78]) } else { %CD_EXT% callExtension (%CD_PUSH% + toString [80,49]) ; %CD_EXT% callExtension (%CD_PUSH% + toString [80,50,89]) ; call (missionNamespace getVariable %CD_FN%) ; %CD_EXT% callExtension (%CD_PUSH% + toString [80,51]) } ; [] spawn { %CD_EXT% callExtension (%CD_PUSH% + toString [80,52]) }"

echo Launching Arma 3 with arma3-mcp mounted...
echo   executor start: attempted from -init= (see A3MCP-* lines in the RPT)
"%GAME%" -skipIntro -noSplash -malloc=system -hugePages -noPause -noPauseAudio -showScriptErrors "-mod=%MODS%" "-init=%INIT_CODE%"
