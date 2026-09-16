local eventHandlers = {
	["CORPSE_IN_RANGE"] = function(...) GameEvent.HandleCorpseInRange(...) end,
	["CORPSE_OUT_OF_RANGE"] = function(...) GameEvent.HandleCorpseOutOfRange(...) end,
	["PLAYER_DEAD"] = function(...) GameEvent.HandlePlayerDead(...) end,
	["PLAYER_GUILD_UPDATE"] = function(...) GameEvent.HandlePlayerGuildUpdate(...) end,
};

function GameEvent.RegisterHardcoreEvents()
	GameEvent.RegisterInternalEvents(eventHandlers);
end