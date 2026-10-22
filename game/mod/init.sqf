/* a3mcp startup entry, referenced by the -init= launch parameter.

Why this file exists:
  preInit / postInit are MISSION-scoped triggers -- they only run once a mission
  is loaded (editor preview counts). Sitting in the main menu, neither fires, so
  the SQF executor never starts and the DLL never loads (extensions load on the
  first callExtension). Upstream that looks like "game not connected".

  But screenshot and input injection do NOT need a game world -- they are plain
  Windows-level operations. So those two capabilities should be available from
  the main menu, and -init= moves the executor's start earlier, to game launch.

Relationship to postInit:
  Both call fn_init; fn_init has an A3MCP_STARTED guard, so the second call is
  ignored and no second polling loop is started. Entering a mission afterwards
  is therefore safe.

NOTE: keep this file pure ASCII. It is loaded directly by the engine (not from
a PBO), where non-ASCII text in comments/log lines is less predictable.
*/
if (isNil "a3mcp_fnc_init") exitWith {
    diag_log "[A3MCP] -init= ran before mod functions were loaded (timing issue)";
};

diag_log "[A3MCP] -init= entry: starting executor at main-menu stage";
call a3mcp_fnc_init;
