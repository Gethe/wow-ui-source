local handlers = {};
local eventFrame = CreateFrame("Frame");

eventFrame:SetScript("OnEvent", function(self, event, ...)
	local handler = handlers[event];
	if handler then
		handler(self, event, ...);
	end
end);

function GameEvent.RegisterInternalEvent(event, handler)
	if handlers[event] == nil then
		eventFrame:RegisterEvent(event);
	end

	handlers[event] = handler;
end

function GameEvent.RegisterInternalEvents(eventHandlers)
	for event, handler in pairs(eventHandlers) do
		GameEvent.RegisterInternalEvent(event, handler);
	end
end

function GameEvent.UnregisterInternalEvent(event)
	if handlers[event] ~= nil then
		eventFrame:UnregisterEvent(event);
		handlers[event] = nil;
	end
end

local function HandleGMWhisperIfNeeded(dispatcher, event, ...)
	if select(6, ...) == "GM" then
		GameEvent.HandleGMChatWhisper(dispatcher, event, ...);
	end
end

local eventHandlers = {
	["TRADE_REQUEST"] = GameEvent.HandleTradeRequest,
	["CHANNEL_INVITE_REQUEST"] = GameEvent.HandleChannelInviteRequest,
	["CHANNEL_PASSWORD_REQUEST"] = GameEvent.HandleChannelPasswordRequest,
	["ACTION_WILL_BIND_ITEM"] = GameEvent.HandleActionWillBindItem,
	["ADDON_ACTION_FORBIDDEN"] = GameEvent.HandleAddonActionForbidden,
	["AUCTION_HOUSE_SCRIPT_DEPRECATED"] = GameEvent.HandleAuctionHouseScriptDeprecated,
	["ALERT_REGIONAL_CHAT_DISABLED"] = GameEvent.HandleAlertRegionalChatDisabled,
	["AREA_SPIRIT_HEALER_IN_RANGE"] = GameEvent.HandleAreaSpiritHealerInRange,
	["AREA_SPIRIT_HEALER_OUT_OF_RANGE"] = GameEvent.HandleAreaSpiritHealerOutOfRange,
	["BARBER_SHOP_OPEN"] = GameEvent.HandleBarberShopOpen,
	["BIND_ENCHANT"] = GameEvent.HandleBindEnchant,
	["CONFIRM_BEFORE_USE"] = GameEvent.HandleConfirmBeforeUse,
	["CORPSE_IN_INSTANCE"] = GameEvent.HandleCorpseInInstance,
	["CURSOR_CHANGED"] = GameEvent.HandleCursorChanged,
	["DUEL_FINISHED"] = GameEvent.HandleDuelFinished,
	["END_BOUND_TRADEABLE"] = GameEvent.HandleEndBoundTradeable,
	["EXPERIMENTAL_CVAR_CONFIRMATION_NEEDED"] = GameEvent.HandleExperimentalCVarConfirmationNeeded,
	["GROUP_ROSTER_UPDATE"] = GameEvent.HandleGroupRosterUpdate,
	["PARTY_INVITE_CANCEL"] = GameEvent.HandlePartyInviteCancel,
	["NOTCHED_DISPLAY_MODE_CHANGED"] = GameEvent.HandleNotchedDisplayModeChanged,
	["PLAYER_CAMPING"] = GameEvent.HandlePlayerCamping,
	["PLAYER_CONTROL_LOST"] = GameEvent.HandlePlayerControlLost,
	["PLAYER_LOGIN"] = GameEvent.HandlePlayerLogin,
	["PLAYER_ENTERING_WORLD"] = GameEvent.HandlePlayerEnteringWorld,
	["PLAYER_SKINNED"] = GameEvent.HandlePlayerSkinned,
	["PLAYER_QUITING"] = GameEvent.HandlePlayerQuiting,
	["QUEST_LOG_UPDATE"] = GameEvent.HandleQuestLogUpdate,
	["UNIT_QUEST_LOG_CHANGED"] = GameEvent.HandleQuestLogUpdate,
	["REPLACE_ENCHANT"] = GameEvent.HandleReplaceEnchant,
	["SAVED_VARIABLES_TOO_LARGE"] = GameEvent.HandleSavedVariablesTooLarge,
	["BAG_OVERFLOW_WITH_FULL_INVENTORY"] = GameEvent.HandleBagOverflowWithFullInventory,
	["TRADE_REPLACE_ENCHANT"] = GameEvent.HandleTradeReplaceEnchant,
	["USE_BIND_CONFIRM"] = GameEvent.HandleUseBindConfirm,
	["USE_NO_REFUND_CONFIRM"] = GameEvent.HandleUseNoRefundConfirm,
	["WOW_MOUSE_NOT_FOUND"] = GameEvent.HandleWowMouseNotFound,
	["DUEL_REQUESTED"] = GameEvent.HandleDuelRequested,
	["DUEL_OUTOFBOUNDS"] = GameEvent.HandleDuelOutOfBounds,
	["DUEL_INBOUNDS"] = GameEvent.HandleDuelInBounds,
	["TRADE_REQUEST_CANCEL"] = GameEvent.HandleTradeRequestCancel,
	["CONFIRM_LOOT_ROLL"] = GameEvent.HandleConfirmLootRoll,
	["INSTANCE_BOOT_START"] = GameEvent.HandleInstanceBootStart,
	["INSTANCE_BOOT_STOP"] = GameEvent.HandleInstanceBootStop,
	["INSTANCE_LOCK_START"] = GameEvent.HandleInstanceLockStart,
	["INSTANCE_LOCK_STOP"] = GameEvent.HandleInstanceLockStop,
	["INSTANCE_LOCK_WARNING"] = GameEvent.HandleInstanceLockWarning,
	["CONFIRM_BINDER"] = GameEvent.HandleConfirmBinder,
	["CONFIRM_SUMMON"] = GameEvent.HandleConfirmSummon,
	["CANCEL_SUMMON"] = GameEvent.HandleCancelSummon,
	["BILLING_NAG_DIALOG"] = GameEvent.HandleBillingNagDialog,
	["IGR_BILLING_NAG_DIALOG"] = GameEvent.HandleIgrBillingNagDialog,
	["GOSSIP_CONFIRM"] = GameEvent.HandleGossipConfirm,
	["GOSSIP_CONFIRM_CANCEL"] = GameEvent.HandleGossipConfirmCancel,
	["GOSSIP_CLOSED"] = GameEvent.HandleGossipConfirmCancel,
	["GOSSIP_ENTER_CODE"] = GameEvent.HandleGossipEnterCode,
	["TAXIMAP_OPENED"] = GameEvent.HandleTaxiMapOpened,
	["REPORT_PLAYER_RESULT"] = GameEvent.HandleReportPlayerResult,
	["SURVEY_DELIVERED"] = GameEvent.HandleSurveyDelivered,
	["CHAT_MSG_WHISPER"] = HandleGMWhisperIfNeeded,
	["TRIAL_CAP_REACHED_MONEY"] = GameEvent.HandleTrialCapReached,
	["TRIAL_CAP_REACHED_LEVEL"] = GameEvent.HandleTrialCapReached,
	["BEHAVIORAL_NOTIFICATION"] = GameEvent.HandleBehavioralNotification,
};

function GameEvent.RegisterSharedEvents()
	GameEvent.RegisterInternalEvents(eventHandlers);
end
