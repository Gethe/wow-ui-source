---@diagnostic disable: duplicate-set-field

local eventHandlers = {
	["CORPSE_IN_RANGE"] = function(...) GameEvent.HandleCorpseInRange(...) end,
	["CORPSE_OUT_OF_RANGE"] = function(...) GameEvent.HandleCorpseOutOfRange(...) end,
	["CURSOR_CHANGED"] = function(...) GameEvent.HandleCursorChanged(...) end,
	["DELETE_ITEM_CONFIRM"] = function(...) GameEvent.HandleDeleteItemConfirm(...) end,
	["DUEL_TO_THE_DEATH_REQUESTED"] = function(...) GameEvent.HandleDuelToTheDeathRequested(...) end,
	["LFG_ENABLED_STATE_CHANGED"] = function(...) GameEvent.HandleLFGEnabledStateChanged(...) end,
	["PLAYER_ALIVE"] = function(...) GameEvent.HandlePlayerAlive(...) end,
	["PLAYER_DEAD"] = function(...) GameEvent.HandlePlayerDead(...) end,
	["PLAYER_ENTERING_WORLD"] = function(...) GameEvent.HandlePlayerEnteringWorld(...) end,
	["PLAYER_GUILD_UPDATE"] = function(...) GameEvent.HandlePlayerGuildUpdate(...) end,
	["SELF_RES_SPELL_CHANGED"] = function(...) GameEvent.HandleSelfResSpellChanged(...) end,
	["TRAINER_SHOW"] = function(...) GameEvent.HandleTrainerShow(...) end,
};

function GameEvent.RegisterCamelotEvents()
	GameEvent.RegisterInternalEvents(eventHandlers);
end

function GameEvent.InitEvents()
	GameEvent.RegisterSharedEvents();
	GameEvent.RegisterMainlineEvents();
	GameEvent.RegisterCamelotEvents();
end
