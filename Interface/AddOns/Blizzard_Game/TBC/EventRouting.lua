local eventHandlers = {
	["ARENA_TEAM_INVITE_REQUEST"] = function(...) GameEvent.HandleArenaTeamInviteRequest(...) end,
	["CORPSE_IN_RANGE"] = function(...) GameEvent.HandleCorpseInRange(...) end,
	["CORPSE_OUT_OF_RANGE"] = function(...) GameEvent.HandleCorpseOutOfRange(...) end,
	["EQUIP_BIND_CONFIRM"] = function(...) GameEvent.HandleEquipBindConfirm(...) end,
	["EQUIP_BIND_TRADEABLE_CONFIRM"] = function(...) GameEvent.HandleEquipBindTradeableConfirm(...) end,
	["GUILDBANKFRAME_CLOSED"] = function(...) GameEvent.HandleGuildBankFrameClosed(...) end,
	["GUILDBANKFRAME_OPENED"] = function(...) GameEvent.HandleGuildBankFrameOpened(...) end,
	["PLAYER_ALIVE"] = function(...) GameEvent.HandlePlayerAlive(...) end,
	["PLAYER_DEAD"] = function(...) GameEvent.HandlePlayerDead(...) end,
	["PLAYER_UNGHOST"] = function(...) GameEvent.HandlePlayerUnghost(...) end,
	["RAISED_AS_GHOUL"] = function(...) GameEvent.HandlePlayerAlive(...) end,
	["RESURRECT_REQUEST"] = function(...) GameEvent.HandleResurrectRequest(...) end,
	["SELF_RES_SPELL_CHANGED"] = function(...) GameEvent.HandleSelfResSpellChanged(...) end,
	["SETTINGS_LOADED"] = function(...) GameEvent.HandleSettingsLoaded(...) end,
	["SOCKET_INFO_UPDATE"] = function(...) GameEvent.HandleSocketInfoUpdate(...) end,
};

function GameEvent.RegisterTBCEvents()
	GameEvent.RegisterInternalEvents(eventHandlers);
end

function GameEvent.InitEvents()
	GameEvent.RegisterSharedEvents();
	GameEvent.RegisterClassicEvents();
	GameEvent.RegisterVanillaEvents();
	GameEvent.RegisterTBCEvents();
end
