local eventHandlers = {
	["ADDON_ACTION_BLOCKED"] = GameEvent.HandleAddonActionBlocked,
	["AUCTION_HOUSE_CLOSED"] = GameEvent.HandleAuctionHouseClosed,
	["AUCTION_HOUSE_DISABLED"] = GameEvent.HandleAuctionHouseDisabled,
	["AUCTION_HOUSE_SHOW"] = GameEvent.HandleAuctionHouseShow,
	["BARBER_SHOP_CLOSE"] = GameEvent.HandleBarberShopClose,
	["CONFIRM_BARBERS_CHOICE"] = GameEvent.HandleConfirmBarbersChoice,
	["CONFIRM_PET_UNLEARN"] = GameEvent.HandleConfirmPetUnlearn,
	["CRAFT_CLOSE"] = GameEvent.HandleCraftClose,
	["CRAFT_SHOW"] = GameEvent.HandleCraftShow,
	["DELETE_ITEM_CONFIRM"] = GameEvent.HandleDeleteItemConfirm,
	["EQUIP_BIND_REFUNDABLE_CONFIRM"] = GameEvent.HandleEquipBindRefundableConfirm,
	["GUILD_INVITE_CANCEL"] = GameEvent.HandleGuildInviteCancel,
	["GUILD_INVITE_REQUEST"] = GameEvent.HandleGuildInviteRequest,
	["LOOT_BIND_CONFIRM"] = GameEvent.HandleLootBindConfirm,
	["MACRO_ACTION_BLOCKED"] = GameEvent.HandleMacroActionBlocked,
	["MACRO_ACTION_FORBIDDEN"] = GameEvent.HandleMacroActionForbidden,
	["MIRROR_TIMER_START"] = GameEvent.HandleMirrorTimerStart,
	["PARTY_INVITE_REQUEST"] = GameEvent.HandlePartyInviteRequest,
	["QUEST_ACCEPT_CONFIRM"] = GameEvent.HandleQuestAcceptConfirm,
	["START_LOOT_ROLL"] = GameEvent.HandleStartLootRoll,
	["TRADE_SKILL_CLOSE"] = GameEvent.HandleTradeSkillClose,
	["TRADE_SKILL_SHOW"] = GameEvent.HandleTradeSkillShow,
	["VARIABLES_LOADED"] = GameEvent.HandleVariablesLoaded,
};

function GameEvent.RegisterClassicEvents()
	GameEvent.RegisterInternalEvents(eventHandlers);
end
