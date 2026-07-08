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
	["TRADE_REQUEST"] = function(...) GameEvent.HandleTradeRequest(...) end,
	["CHANNEL_INVITE_REQUEST"] = function(...) GameEvent.HandleChannelInviteRequest(...) end,
	["CHANNEL_PASSWORD_REQUEST"] = function(...) GameEvent.HandleChannelPasswordRequest(...) end,
	["ACTION_WILL_BIND_ITEM"] = function(...) GameEvent.HandleActionWillBindItem(...) end,
	["ADDON_ACTION_FORBIDDEN"] = function(...) GameEvent.HandleAddonActionForbidden(...) end,
	["AUCTION_HOUSE_SCRIPT_DEPRECATED"] = function(...) GameEvent.HandleAuctionHouseScriptDeprecated(...) end,
	["ALERT_REGIONAL_CHAT_DISABLED"] = function(...) GameEvent.HandleAlertRegionalChatDisabled(...) end,
	["AREA_SPIRIT_HEALER_IN_RANGE"] = function(...) GameEvent.HandleAreaSpiritHealerInRange(...) end,
	["AREA_SPIRIT_HEALER_OUT_OF_RANGE"] = function(...) GameEvent.HandleAreaSpiritHealerOutOfRange(...) end,
	["BARBER_SHOP_OPEN"] = function(...) GameEvent.HandleBarberShopOpen(...) end,
	["BIND_ENCHANT"] = function(...) GameEvent.HandleBindEnchant(...) end,
	["CONFIRM_BEFORE_USE"] = function(...) GameEvent.HandleConfirmBeforeUse(...) end,
	["CORPSE_IN_INSTANCE"] = function(...) GameEvent.HandleCorpseInInstance(...) end,
	["CURSOR_CHANGED"] = function(...) GameEvent.HandleCursorChanged(...) end,
	["DUEL_FINISHED"] = function(...) GameEvent.HandleDuelFinished(...) end,
	["END_BOUND_TRADEABLE"] = function(...) GameEvent.HandleEndBoundTradeable(...) end,
	["EXPERIMENTAL_CVAR_CONFIRMATION_NEEDED"] = function(...) GameEvent.HandleExperimentalCVarConfirmationNeeded(...) end,
	["GROUP_ROSTER_UPDATE"] = function(...) GameEvent.HandleGroupRosterUpdate(...) end,
	["PARTY_INVITE_CANCEL"] = function(...) GameEvent.HandlePartyInviteCancel(...) end,
	["NOTCHED_DISPLAY_MODE_CHANGED"] = function(...) GameEvent.HandleNotchedDisplayModeChanged(...) end,
	["PLAYER_CAMPING"] = function(...) GameEvent.HandlePlayerCamping(...) end,
	["PLAYER_CONTROL_LOST"] = function(...) GameEvent.HandlePlayerControlLost(...) end,
	["PLAYER_LOGIN"] = function(...) GameEvent.HandlePlayerLogin(...) end,
	["PLAYER_ENTERING_WORLD"] = function(...) GameEvent.HandlePlayerEnteringWorld(...) end,
	["PLAYER_SKINNED"] = function(...) GameEvent.HandlePlayerSkinned(...) end,
	["PLAYER_QUITING"] = function(...) GameEvent.HandlePlayerQuiting(...) end,
	["QUEST_LOG_UPDATE"] = function(...) GameEvent.HandleQuestLogUpdate(...) end,
	["UNIT_QUEST_LOG_CHANGED"] = function(...) GameEvent.HandleQuestLogUpdate(...) end,
	["REPLACE_ENCHANT"] = function(...) GameEvent.HandleReplaceEnchant(...) end,
	["SAVED_VARIABLES_TOO_LARGE"] = function(...) GameEvent.HandleSavedVariablesTooLarge(...) end,
	["BAG_OVERFLOW_WITH_FULL_INVENTORY"] = function(...) GameEvent.HandleBagOverflowWithFullInventory(...) end,
	["TRADE_REPLACE_ENCHANT"] = function(...) GameEvent.HandleTradeReplaceEnchant(...) end,
	["USE_BIND_CONFIRM"] = function(...) GameEvent.HandleUseBindConfirm(...) end,
	["USE_NO_REFUND_CONFIRM"] = function(...) GameEvent.HandleUseNoRefundConfirm(...) end,
	["WOW_MOUSE_NOT_FOUND"] = function(...) GameEvent.HandleWowMouseNotFound(...) end,
	["DUEL_REQUESTED"] = function(...) GameEvent.HandleDuelRequested(...) end,
	["DUEL_OUTOFBOUNDS"] = function(...) GameEvent.HandleDuelOutOfBounds(...) end,
	["DUEL_INBOUNDS"] = function(...) GameEvent.HandleDuelInBounds(...) end,
	["TRADE_REQUEST_CANCEL"] = function(...) GameEvent.HandleTradeRequestCancel(...) end,
	["CONFIRM_LOOT_ROLL"] = function(...) GameEvent.HandleConfirmLootRoll(...) end,
	["INSTANCE_BOOT_START"] = function(...) GameEvent.HandleInstanceBootStart(...) end,
	["INSTANCE_BOOT_STOP"] = function(...) GameEvent.HandleInstanceBootStop(...) end,
	["INSTANCE_LOCK_START"] = function(...) GameEvent.HandleInstanceLockStart(...) end,
	["INSTANCE_LOCK_STOP"] = function(...) GameEvent.HandleInstanceLockStop(...) end,
	["INSTANCE_LOCK_WARNING"] = function(...) GameEvent.HandleInstanceLockWarning(...) end,
	["CONFIRM_BINDER"] = function(...) GameEvent.HandleConfirmBinder(...) end,
	["CONFIRM_SUMMON"] = function(...) GameEvent.HandleConfirmSummon(...) end,
	["CANCEL_SUMMON"] = function(...) GameEvent.HandleCancelSummon(...) end,
	["BILLING_NAG_DIALOG"] = function(...) GameEvent.HandleBillingNagDialog(...) end,
	["IGR_BILLING_NAG_DIALOG"] = function(...) GameEvent.HandleIgrBillingNagDialog(...) end,
	["GOSSIP_CONFIRM"] = function(...) GameEvent.HandleGossipConfirm(...) end,
	["GOSSIP_CONFIRM_CANCEL"] = function(...) GameEvent.HandleGossipConfirmCancel(...) end,
	["GOSSIP_CLOSED"] = function(...) GameEvent.HandleGossipConfirmCancel(...) end,
	["GOSSIP_ENTER_CODE"] = function(...) GameEvent.HandleGossipEnterCode(...) end,
	["TAXIMAP_OPENED"] = function(...) GameEvent.HandleTaxiMapOpened(...) end,
	["REPORT_PLAYER_RESULT"] = function(...) GameEvent.HandleReportPlayerResult(...) end,
	["SURVEY_DELIVERED"] = function(...) GameEvent.HandleSurveyDelivered(...) end,
	["CHAT_MSG_WHISPER"] = function(...) HandleGMWhisperIfNeeded(...) end,
	["TRIAL_CAP_REACHED_MONEY"] = function(...) GameEvent.HandleTrialCapReached(...) end,
	["TRIAL_CAP_REACHED_LEVEL"] = function(...) GameEvent.HandleTrialCapReached(...) end,
	["BEHAVIORAL_NOTIFICATION"] = function(...) GameEvent.HandleBehavioralNotification(...) end,
};

function GameEvent.RegisterSharedEvents()
	GameEvent.RegisterInternalEvents(eventHandlers);
end
