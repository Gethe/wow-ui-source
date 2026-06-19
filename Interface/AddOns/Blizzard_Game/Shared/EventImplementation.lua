local sendReportResultToErrorString = {
	[Enum.SendReportResult.Success] = ERR_REPORT_SUBMITTED_SUCCESSFULLY,
	[Enum.SendReportResult.GeneralError] = ERR_REPORT_SUBMISSION_FAILED,
	[Enum.SendReportResult.TooManyReports] = REPORT_RESULT_TOO_MANY_REPORTS,
	[Enum.SendReportResult.RequiresChatLine] = REPORT_RESULT_REQUIRES_CHAT,
	[Enum.SendReportResult.RequiresChatLineOrVoice] = REPORT_RESULT_REQUIRES_CHAT_OR_VOICE,
};

local function GetErrorMessageFromSendReportResult(result)
	return sendReportResultToErrorString[result] or ERR_REPORT_SUBMISSION_FAILED;
end

local sendReportResultToChatString = {
	[Enum.SendReportResult.Success] = COMPLAINT_ADDED,
	[Enum.SendReportResult.GeneralError] = ERR_REPORT_SUBMISSION_FAILED,
	[Enum.SendReportResult.TooManyReports] = REPORT_RESULT_TOO_MANY_REPORTS,
	[Enum.SendReportResult.RequiresChatLine] = REPORT_RESULT_REQUIRES_CHAT,
	[Enum.SendReportResult.RequiresChatLineOrVoice] = REPORT_RESULT_REQUIRES_CHAT_OR_VOICE,
};

local function GetChatMessageFromSendReportResult(result)
	return sendReportResultToChatString[result] or ERR_REPORT_SUBMISSION_FAILED;
end

function GameEvent.HandleTokenAuctionSold(dispatcher, _event)
	local itemName = C_Item.GetItemInfo(WOW_TOKEN_ITEM_ID);
	if itemName then
		ChatFrameUtil.AddSystemMessage(ERR_AUCTION_SOLD_S:format(itemName));
	else
		dispatcher:RegisterEvent("GET_ITEM_INFO_RECEIVED");
	end
end

function GameEvent.HandleGetItemInfoReceived(dispatcher, _event, itemID)
	if itemID == WOW_TOKEN_ITEM_ID then
		local itemName = C_Item.GetItemInfo(WOW_TOKEN_ITEM_ID);
		ChatFrameUtil.AddSystemMessage(ERR_AUCTION_SOLD_S:format(itemName));
		dispatcher:UnregisterEvent("GET_ITEM_INFO_RECEIVED");
	end
end

function GameEvent.HandleGroupInviteConfirmation(_dispatcher, _event)
	UpdateInviteConfirmationDialogs();
end

function GameEvent.HandleReportPlayerResult(_dispatcher, _event, result)
	UIErrorsFrame:AddExternalErrorMessage(GetErrorMessageFromSendReportResult(result));
	ChatFrameUtil.AddSystemMessage(GetChatMessageFromSendReportResult(result));
end

function GameEvent.HandleSurveyDelivered(dispatcher, event)
	WowSurveyStatusFrame_OnSurveyDelivered(event);
	dispatcher:UnregisterEvent("SURVEY_DELIVERED");
end

function GameEvent.HandleNotchedDisplayModeChanged(_dispatcher, _event)
	UpdateUIParentPosition();
end

function GameEvent.HandleTrialCapReached(dispatcher, event)
	if not GameLimitedMode_IsActive() then
		return;
	end

	if event == "TRIAL_CAP_REACHED_LEVEL" then
		ChatFrameUtil.AddSystemMessage(CAPPED_LEVEL_TRIAL);
	elseif event == "TRIAL_CAP_REACHED_MONEY" then
		ChatFrameUtil.AddSystemMessage(CAPPED_MONEY_TRIAL);
	end

	dispatcher:UnregisterEvent("TRIAL_CAP_REACHED_MONEY");
	dispatcher:UnregisterEvent("TRIAL_CAP_REACHED_LEVEL");
end

function GameEvent.HandleExperimentalCVarConfirmationNeeded(_dispatcher, _event)
	StaticPopup_Show("EXPERIMENTAL_CVAR_WARNING");
end

function GameEvent.HandleTradeRequest(_dispatcher, _event, arg1)
	StaticPopup_Show("TRADE", arg1);
end

function GameEvent.HandleChannelInviteRequest(_dispatcher, _event, arg1, arg2)
	if GetCVarBool("blockChannelInvites") then
		DeclineChannelInvite(arg1);
	else
		StaticPopup_Show("CHAT_CHANNEL_INVITE", arg1, arg2, arg1);
	end
end

function GameEvent.HandleChannelPasswordRequest(_dispatcher, _event, arg1)
	StaticPopup_Show("CHAT_CHANNEL_PASSWORD", arg1, nil, arg1);
end

function GameEvent.HandleActionWillBindItem(_dispatcher, _event)
	StaticPopup_Show("ACTION_WILL_BIND_ITEM");
end

function GameEvent.HandleAddonActionForbidden(_dispatcher, _event, arg1)
	StaticPopup_Show("ADDON_ACTION_FORBIDDEN", arg1, nil, arg1);
end

function GameEvent.HandleAuctionHouseScriptDeprecated(_dispatcher, _event)
	StaticPopup_Show("AUCTION_HOUSE_DEPRECATED");
end

function GameEvent.HandleAlertRegionalChatDisabled(_dispatcher, _event)
	StaticPopup_Show("REGIONAL_CHAT_DISABLED");
end

function GameEvent.HandleAreaSpiritHealerInRange(_dispatcher, _event)
	AcceptAreaSpiritHeal();
	StaticPopup_Show("AREA_SPIRIT_HEAL");
end

function GameEvent.HandleAreaSpiritHealerOutOfRange(_dispatcher, _event)
	StaticPopup_Hide("AREA_SPIRIT_HEAL");
end

function GameEvent.HandleBarberShopOpen(_dispatcher, _event)
	ShowBarberShopFrame();
end

function GameEvent.HandleBindEnchant(_dispatcher, _event)
	StaticPopup_Show("BIND_ENCHANT");
end

function GameEvent.HandleConfirmBeforeUse(_dispatcher, _event)
	StaticPopup_Show("CONFIM_BEFORE_USE");
end

function GameEvent.HandleCorpseInInstance(_dispatcher, _event)
	StaticPopup_Show("RECOVER_CORPSE_INSTANCE");
end

function GameEvent.HandleCursorChanged(_dispatcher, _event)
	if not CursorHasItem() then
		StaticPopup_Hide("EQUIP_BIND");
		StaticPopup_Hide("EQUIP_BIND_TRADEABLE");
	end
end

function GameEvent.HandleDuelFinished(_dispatcher, _event)
	StaticPopup_Hide("DUEL_REQUESTED");
	StaticPopup_Hide("DUEL_OUTOFBOUNDS");
end

function GameEvent.HandleEndBoundTradeable(_dispatcher, _event, arg1)
	StaticPopup_Show("END_BOUND_TRADEABLE", nil, nil, arg1);
end

function GameEvent.HandleGroupRosterUpdate(_dispatcher, _event)
	UpdateRaidAndPartyFrames();
	if not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		StaticPopup_Hide("CONFIRM_LEAVE_INSTANCE_PARTY");
	end
end

function GameEvent.HandlePartyInviteCancel(_dispatcher, _event)
	StaticPopup_Hide("PARTY_INVITE");
	StaticPopupSpecial_Hide(LFGInvitePopup);
end

function GameEvent.HandlePlayerCamping(_dispatcher, _event)
	StaticPopup_Show("CAMP");
end

function GameEvent.HandlePlayerControlLost(_dispatcher, _event)
	if UnitOnTaxi("player") then
		return true;
	end
	CloseAllWindows_WithExceptions();
	return false;
end

function GameEvent.HandlePlayerLogin(_dispatcher, _event)
	TimeManager_LoadUI();
	CombatLog_LoadUI();
end

function GameEvent.HandlePlayerSkinned(_dispatcher, _event)
	StaticPopup_Hide("RESURRECT");
	StaticPopup_Hide("RESURRECT_NO_SICKNESS");
	StaticPopup_Hide("RESURRECT_NO_TIMER");
	UIErrorsFrame:AddMessage(DEATH_CORPSE_SKINNED, 1.0, 0.1, 0.1, 1.0);
end

function GameEvent.HandlePlayerQuiting(_dispatcher, _event)
	StaticPopup_Show("QUIT");
end

function GameEvent.HandleQuestLogUpdate(_dispatcher, _event)
	UpdateQuestAcceptLogFullDialog();
end

function GameEvent.HandleReplaceEnchant(_dispatcher, _event, arg1, arg2)
	StaticPopup_Show("REPLACE_ENCHANT", arg1, arg2);
end

function GameEvent.HandleSavedVariablesTooLarge(_dispatcher, _event, arg1)
	StaticPopup_Show("SAVED_VARIABLES_TOO_LARGE", arg1);
end

function GameEvent.HandleBagOverflowWithFullInventory(_dispatcher, _event)
	StaticPopup_Show("CLIENT_INVENTORY_FULL_OVERFLOW");
end

function GameEvent.HandleTradeReplaceEnchant(_dispatcher, _event, arg1, arg2)
	StaticPopup_Show("TRADE_REPLACE_ENCHANT", arg1, arg2);
end

function GameEvent.HandleUseBindConfirm(_dispatcher, _event)
	StaticPopup_Show("USE_BIND");
end

function GameEvent.HandleUseNoRefundConfirm(_dispatcher, _event)
	StaticPopup_Show("USE_NO_REFUND_CONFIRM");
end

function GameEvent.HandleWowMouseNotFound(_dispatcher, _event)
	StaticPopup_Show("WOW_MOUSE_NOT_FOUND");
end

function GameEvent.HandleDuelRequested(_dispatcher, _event, arg1)
	StaticPopup_Show("DUEL_REQUESTED", arg1);
end

function GameEvent.HandleDuelOutOfBounds(_dispatcher, _event)
	StaticPopup_Show("DUEL_OUTOFBOUNDS");
end

function GameEvent.HandleDuelInBounds(_dispatcher, _event)
	StaticPopup_Hide("DUEL_OUTOFBOUNDS");
end

function GameEvent.HandleTradeRequestCancel(_dispatcher, _event)
	StaticPopup_Hide("TRADE");
end

function GameEvent.HandleConfirmLootRoll(_dispatcher, _event, arg1, arg2)
	ConfirmLootRollDialog_Show(arg1, arg2);
end

function GameEvent.HandleInstanceBootStart(_dispatcher, _event)
	ShowInstanceBootDialog();
end

function GameEvent.HandleInstanceBootStop(_dispatcher, _event)
	HideInstanceBootDialog();
end

function GameEvent.HandleInstanceLockStart(_dispatcher, _event)
	ShowInstanceLockDialog(true);
end

function GameEvent.HandleInstanceLockStop(_dispatcher, _event)
	HideInstanceLockDialog();
end

function GameEvent.HandleInstanceLockWarning(_dispatcher, _event)
	ShowInstanceLockDialog(false);
end

function GameEvent.HandleConfirmBinder(_dispatcher, _event, arg1)
	StaticPopup_Show("CONFIRM_BINDER", arg1);
end

function GameEvent.HandleConfirmSummon(_dispatcher, _event, arg1, arg2)
	ShowSummonConfirmationDialog(arg1, arg2);
end

function GameEvent.HandleCancelSummon(_dispatcher, _event)
	HideSummonConfirmationDialogs();
end

function GameEvent.HandleBillingNagDialog(_dispatcher, _event, arg1)
	StaticPopup_Show("BILLING_NAG", arg1);
end

function GameEvent.HandleIgrBillingNagDialog(_dispatcher, _event)
	StaticPopup_Show("IGR_BILLING_NAG");
end

function GameEvent.HandleGossipConfirm(_dispatcher, _event, arg1, arg2, arg3)
	GossipConfirmDialog_Show(arg1, arg2, arg3);
end

function GameEvent.HandleGossipConfirmCancel(_dispatcher, _event)
	StaticPopup_Hide("GOSSIP_CONFIRM");
	StaticPopup_Hide("GOSSIP_ENTER_CODE");
end

function GameEvent.HandleGossipEnterCode(_dispatcher, _event, arg1)
	StaticPopup_Show("GOSSIP_ENTER_CODE", nil, nil, arg1);
end

function GameEvent.HandleGMChatWhisper(_dispatcher, event, ...)
	GMChatFrame_OnWhisperFromGM(event, ...);
end

function GameEvent.HandleBehavioralNotification(dispatcher, event, ...)
	dispatcher:UnregisterEvent("BEHAVIORAL_NOTIFICATION");
	BehavioralMessagingTray_OnNotification(event, ...);
end

function GameEvent.HandlePlayerEnteringWorld(_dispatcher, _event, isInitialLogin, isUIReload)
	CloseAllWindows(1);

	StaticPopup_Hide("CONFIRM_LEAVE_BATTLEFIELD");

	UpdateMicroButtons();

	UpdateUIParentPosition();
	
	if C_Commentator.IsSpectating() then
		Commentator_LoadUI();
	end

	if Kiosk.IsEnabled() then
		KioskFrame_HandlePlayerEnteringWorld(isInitialLogin, isUIReload);
	end
end

