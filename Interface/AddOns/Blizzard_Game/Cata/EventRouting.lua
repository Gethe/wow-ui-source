local eventHandlers = {
	["ARENA_TEAM_INVITE_CANCEL"] = function(...) GameEvent.HandleArenaTeamInviteCancel(...) end,
	["ARCHAEOLOGY_SURVEY_CAST"] = function(...) GameEvent.HandleArchaeologySurveyCast(...) end,
	["ARCHAEOLOGY_TOGGLE"] = function(...) GameEvent.HandleArchaeologyToggle(...) end,
	["FORGE_MASTER_CLOSED"] = function(...) GameEvent.HandleForgeMasterClosed(...) end,
	["FORGE_MASTER_OPENED"] = function(...) GameEvent.HandleForgeMasterOpened(...) end,
	["PLAYER_ALIVE"] = function(...) GameEvent.HandlePlayerAlive(...) end,
	["PLAYER_UNGHOST"] = function(...) GameEvent.HandlePlayerUnghost(...) end,
	["RAISED_AS_GHOUL"] = function(...) GameEvent.HandlePlayerAlive(...) end,
};

function GameEvent.RegisterCataEvents()
	GameEvent.RegisterInternalEvents(eventHandlers);
end

function GameEvent.InitEvents()
	GameEvent.RegisterSharedEvents();
	GameEvent.RegisterClassicEvents();
	GameEvent.RegisterVanillaEvents();
	GameEvent.RegisterTBCEvents();
	GameEvent.RegisterWrathEvents();
	GameEvent.RegisterCataEvents();
end
