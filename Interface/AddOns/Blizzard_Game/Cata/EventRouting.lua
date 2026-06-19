local eventHandlers = {
	["ARENA_TEAM_INVITE_CANCEL"] = GameEvent.HandleArenaTeamInviteCancel,
	["ARCHAEOLOGY_SURVEY_CAST"] = GameEvent.HandleArchaeologySurveyCast,
	["ARCHAEOLOGY_TOGGLE"] = GameEvent.HandleArchaeologyToggle,
	["FORGE_MASTER_CLOSED"] = GameEvent.HandleForgeMasterClosed,
	["FORGE_MASTER_OPENED"] = GameEvent.HandleForgeMasterOpened,
	["PLAYER_ALIVE"] = GameEvent.HandlePlayerAlive,
	["PLAYER_UNGHOST"] = GameEvent.HandlePlayerUnghost,
	["RAISED_AS_GHOUL"] = GameEvent.HandlePlayerAlive,
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
