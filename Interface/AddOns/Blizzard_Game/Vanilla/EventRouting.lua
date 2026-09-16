local eventHandlers = {
	["AUCTION_HOUSE_SHOW_FORMATTED_NOTIFICATION"] = function(...) GameEvent.HandleAuctionHouseNotification(...) end,
	["AUCTION_HOUSE_SHOW_NOTIFICATION"] = function(...) GameEvent.HandleAuctionHouseNotification(...) end,
	["CONFIRM_TALENT_WIPE"] = function(...) GameEvent.HandleConfirmTalentWipe(...) end,
	["CONFIRM_XP_LOSS"] = function(...) GameEvent.HandleConfirmXpLoss(...) end,
	["CORPSE_IN_RANGE"] = function(...) GameEvent.HandleCorpseInRange(...) end,
	["CORPSE_OUT_OF_RANGE"] = function(...) GameEvent.HandleCorpseOutOfRange(...) end,
	["CURRENT_SPELL_CAST_CHANGED"] = function(...) GameEvent.HandleCurrentSpellCastChanged(...) end,
	["DEBUG_MENU_TOGGLED"] = function(...) GameEvent.HandleDebugMenuToggled(...) end,
	["DISABLE_TAXI_BENCHMARK"] = function(...) GameEvent.HandleDisableTaxiBenchmark(...) end,
	["DUEL_TO_THE_DEATH_REQUESTED"] = function(...) GameEvent.HandleDuelToTheDeathRequested(...) end,
	["ENABLE_TAXI_BENCHMARK"] = function(...) GameEvent.HandleEnableTaxiBenchmark(...) end,
	["EQUIP_BIND_CONFIRM"] = function(...) GameEvent.HandleEquipBindConfirm(...) end,
	["EQUIP_BIND_TRADEABLE_CONFIRM"] = function(...) GameEvent.HandleEquipBindTradeableConfirm(...) end,
	["GROUP_INVITE_CONFIRMATION"] = function(...) GameEvent.HandleGroupInviteConfirmation(...) end,
	["LFG_ENABLED_STATE_CHANGED"] = function(...) GameEvent.HandleLFGEnabledStateChanged(...) end,
	["LOGOUT_CANCEL"] = function(...) GameEvent.HandleLogoutCancel(...) end,
	["PLAYER_DEAD"] = function(...) GameEvent.HandlePlayerDead(...) end,
	["PLAYER_SOFT_INTERACT_CHANGED"] = function(...) GameEvent.HandlePlayerSoftInteractChanged(...) end,
	["PRODUCT_DISTRIBUTIONS_UPDATED"] = function(...) GameEvent.HandleProductDistributionsUpdated(...) end,
	["RAID_INSTANCE_WELCOME"] = function(...) GameEvent.HandleRaidInstanceWelcome(...) end,
	["SPELL_CONFIRMATION_PROMPT"] = function(...) GameEvent.HandleSpellConfirmationPrompt(...) end,
	["SPELL_CONFIRMATION_TIMEOUT"] = function(...) GameEvent.HandleSpellConfirmationTimeout(...) end,
	["TALENTS_INVOLUNTARILY_RESET"] = function(...) GameEvent.HandleTalentsInvoluntarilyReset(...) end,
	["TAXIMAP_OPENED"] = function(...) GameEvent.HandleTaxiMapOpened(...) end,
	["TOKEN_AUCTION_SOLD"] = function(...) GameEvent.HandleTokenAuctionSold(...) end,
};

function GameEvent.RegisterVanillaEvents()
	GameEvent.RegisterInternalEvents(eventHandlers);
end

function GameEvent.InitEvents()
	GameEvent.RegisterSharedEvents();
	GameEvent.RegisterClassicEvents();
	GameEvent.RegisterVanillaEvents();
end
