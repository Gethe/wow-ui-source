local eventHandlers = {
	["ADDON_ACTION_BLOCKED"] = function(...) GameEvent.HandleAddonActionBlocked(...) end,
	["AUCTION_HOUSE_CLOSED"] = function(...) GameEvent.HandleAuctionHouseClosed(...) end,
	["AUCTION_HOUSE_DISABLED"] = function(...) GameEvent.HandleAuctionHouseDisabled(...) end,
	["AUCTION_HOUSE_SHOW"] = function(...) GameEvent.HandleAuctionHouseShow(...) end,
	["BARBER_SHOP_CLOSE"] = function(...) GameEvent.HandleBarberShopClose(...) end,
	["CONFIRM_BARBERS_CHOICE"] = function(...) GameEvent.HandleConfirmBarbersChoice(...) end,
	["CONFIRM_PET_UNLEARN"] = function(...) GameEvent.HandleConfirmPetUnlearn(...) end,
	["CRAFT_CLOSE"] = function(...) GameEvent.HandleCraftClose(...) end,
	["CRAFT_SHOW"] = function(...) GameEvent.HandleCraftShow(...) end,
	["DELETE_ITEM_CONFIRM"] = function(...) GameEvent.HandleDeleteItemConfirm(...) end,
	["EQUIP_BIND_REFUNDABLE_CONFIRM"] = function(...) GameEvent.HandleEquipBindRefundableConfirm(...) end,
	["GUILD_INVITE_CANCEL"] = function(...) GameEvent.HandleGuildInviteCancel(...) end,
	["GUILD_INVITE_REQUEST"] = function(...) GameEvent.HandleGuildInviteRequest(...) end,
	["LOOT_BIND_CONFIRM"] = function(...) GameEvent.HandleLootBindConfirm(...) end,
	["MACRO_ACTION_BLOCKED"] = function(...) GameEvent.HandleMacroActionBlocked(...) end,
	["MACRO_ACTION_FORBIDDEN"] = function(...) GameEvent.HandleMacroActionForbidden(...) end,
	["MIRROR_TIMER_START"] = function(...) GameEvent.HandleMirrorTimerStart(...) end,
	["PARTY_INVITE_REQUEST"] = function(...) GameEvent.HandlePartyInviteRequest(...) end,
	["QUEST_ACCEPT_CONFIRM"] = function(...) GameEvent.HandleQuestAcceptConfirm(...) end,
	["START_LOOT_ROLL"] = function(...) GameEvent.HandleStartLootRoll(...) end,
	["TRADE_SKILL_CLOSE"] = function(...) GameEvent.HandleTradeSkillClose(...) end,
	["TRADE_SKILL_SHOW"] = function(...) GameEvent.HandleTradeSkillShow(...) end,
	["VARIABLES_LOADED"] = function(...) GameEvent.HandleVariablesLoaded(...) end,
};

function GameEvent.RegisterClassicEvents()
	GameEvent.RegisterInternalEvents(eventHandlers);
end
