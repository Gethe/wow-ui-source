local eventHandlers = {
	["CORPSE_IN_RANGE"] = GameEvent.HandleCorpseInRange,
	["CORPSE_OUT_OF_RANGE"] = GameEvent.HandleCorpseOutOfRange,
	["PLAYER_DEAD"] = GameEvent.HandlePlayerDead,
	["PLAYER_GUILD_UPDATE"] = GameEvent.HandlePlayerGuildUpdate,
};

function GameEvent.RegisterHardcoreEvents()
	GameEvent.RegisterInternalEvents(eventHandlers);
end