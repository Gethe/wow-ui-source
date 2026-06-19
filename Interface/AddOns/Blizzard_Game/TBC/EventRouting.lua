local eventHandlers = {
	["ARENA_TEAM_INVITE_REQUEST"] = GameEvent.HandleArenaTeamInviteRequest,
	["CORPSE_IN_RANGE"] = GameEvent.HandleCorpseInRange,
	["CORPSE_OUT_OF_RANGE"] = GameEvent.HandleCorpseOutOfRange,
	["EQUIP_BIND_CONFIRM"] = GameEvent.HandleEquipBindConfirm,
	["EQUIP_BIND_TRADEABLE_CONFIRM"] = GameEvent.HandleEquipBindTradeableConfirm,
	["GUILDBANKFRAME_CLOSED"] = GameEvent.HandleGuildBankFrameClosed,
	["GUILDBANKFRAME_OPENED"] = GameEvent.HandleGuildBankFrameOpened,
	["PLAYER_ALIVE"] = GameEvent.HandlePlayerAlive,
	["PLAYER_DEAD"] = GameEvent.HandlePlayerDead,
	["PLAYER_UNGHOST"] = GameEvent.HandlePlayerUnghost,
	["RAISED_AS_GHOUL"] = GameEvent.HandlePlayerAlive,
	["RESURRECT_REQUEST"] = GameEvent.HandleResurrectRequest,
	["SELF_RES_SPELL_CHANGED"] = GameEvent.HandleSelfResSpellChanged,
	["SETTINGS_LOADED"] = GameEvent.HandleSettingsLoaded,
	["SOCKET_INFO_UPDATE"] = GameEvent.HandleSocketInfoUpdate,
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
