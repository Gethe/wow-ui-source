local eventHandlers = {
	["AUCTION_HOUSE_SHOW_FORMATTED_NOTIFICATION"] = GameEvent.HandleAuctionHouseNotification,
	["AUCTION_HOUSE_SHOW_NOTIFICATION"] = GameEvent.HandleAuctionHouseNotification,
	["CONFIRM_TALENT_WIPE"] = GameEvent.HandleConfirmTalentWipe,
	["CONFIRM_XP_LOSS"] = GameEvent.HandleConfirmXpLoss,
	["CORPSE_IN_RANGE"] = GameEvent.HandleCorpseInRange,
	["CORPSE_OUT_OF_RANGE"] = GameEvent.HandleCorpseOutOfRange,
	["CURRENT_SPELL_CAST_CHANGED"] = GameEvent.HandleCurrentSpellCastChanged,
	["DEBUG_MENU_TOGGLED"] = GameEvent.HandleDebugMenuToggled,
	["DISABLE_TAXI_BENCHMARK"] = GameEvent.HandleDisableTaxiBenchmark,
	["DUEL_TO_THE_DEATH_REQUESTED"] = GameEvent.HandleDuelToTheDeathRequested,
	["ENABLE_TAXI_BENCHMARK"] = GameEvent.HandleEnableTaxiBenchmark,
	["EQUIP_BIND_CONFIRM"] = GameEvent.HandleEquipBindConfirm,
	["EQUIP_BIND_TRADEABLE_CONFIRM"] = GameEvent.HandleEquipBindTradeableConfirm,
	["GET_ITEM_INFO_RECEIVED"] = GameEvent.HandleGetItemInfoReceived,
	["GROUP_INVITE_CONFIRMATION"] = GameEvent.HandleGroupInviteConfirmation,
	["LFG_ENABLED_STATE_CHANGED"] = GameEvent.HandleLFGEnabledStateChanged,
	["LOGOUT_CANCEL"] = GameEvent.HandleLogoutCancel,
	["PLAYER_DEAD"] = GameEvent.HandlePlayerDead,
	["PLAYER_SOFT_INTERACT_CHANGED"] = GameEvent.HandlePlayerSoftInteractChanged,
	["PRODUCT_DISTRIBUTIONS_UPDATED"] = GameEvent.HandleProductDistributionsUpdated,
	["RAID_INSTANCE_WELCOME"] = GameEvent.HandleRaidInstanceWelcome,
	["SPELL_CONFIRMATION_PROMPT"] = GameEvent.HandleSpellConfirmationPrompt,
	["SPELL_CONFIRMATION_TIMEOUT"] = GameEvent.HandleSpellConfirmationTimeout,
	["TALENTS_INVOLUNTARILY_RESET"] = GameEvent.HandleTalentsInvoluntarilyReset,
	["TAXIMAP_OPENED"] = GameEvent.HandleTaxiMapOpened,
	["TOKEN_AUCTION_SOLD"] = GameEvent.HandleTokenAuctionSold,
};

function GameEvent.RegisterVanillaEvents()
	GameEvent.RegisterInternalEvents(eventHandlers);
end

function GameEvent.InitEvents()
	GameEvent.RegisterSharedEvents();
	GameEvent.RegisterClassicEvents();
	GameEvent.RegisterVanillaEvents();
end
