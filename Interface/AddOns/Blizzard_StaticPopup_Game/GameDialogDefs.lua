local function SetupLockOnDeclineButtonAndEscape(dialog, declineTimeLeft)
	dialog.declineTimeLeft = declineTimeLeft or .5;
	dialog:GetButton2():SetButtonState("NORMAL", true);
	dialog.ticker = C_Timer.NewTicker(.5, function()
		dialog.declineTimeLeft = dialog.declineTimeLeft - .5;
		if (dialog.declineTimeLeft == 0) then
			dialog.ticker:Cancel();
			dialog:GetButton2():SetButtonState("NORMAL", false);
			return;
		else
			dialog:GetButton2():SetButtonState("NORMAL", true);
		end
	end);
	dialog.hideOnEscape = false;
end

StaticPopupDialogs["GENERIC_CONFIRMATION"] = {
	text = "",		-- supplied dynamically.
	button1 = "",	-- supplied dynamically.
	button2 = "",	-- supplied dynamically.
	OnShow = function(dialog, data)
		dialog:SetFormattedText(data.text, data.text_arg1, data.text_arg2);
		dialog:GetButton1():SetText(data.acceptText or YES);
		dialog:GetButton2():SetText(data.cancelText or NO);

		if data.showAlert then
			dialog.AlertIcon:Show();
		end
	end,
	OnAccept = function(dialog, data)
		data.callback();
	end,
	OnCancel = function(dialog, data)
		local cancelCallback = data and data.cancelCallback or nil;
		if cancelCallback ~= nil then
			cancelCallback();
		end
	end,
	hideOnEscape = 1,
	timeout = 0,
	multiple = 1,
	whileDead = 1,
	wide = 1, -- Always wide to accomodate the alert icon if it is present.
};

StaticPopupDialogs["GENERIC_INPUT_BOX"] = {
	text = "",		-- supplied dynamically.
	button1 = "",	-- supplied dynamically.
	button2 = "",	-- supplied dynamically.
	hasEditBox = 1,
	OnShow = function(dialog, data)
		dialog:SetFormattedText(data.text, data.text_arg1, data.text_arg2);
		dialog:GetButton1():SetText(data.acceptText or DONE);
		dialog:GetButton2():SetText(data.cancelText or CANCEL);

		dialog:GetEditBox():SetMaxLetters(data.maxLetters or 24);
		dialog:GetEditBox():SetCountInvisibleLetters(not not data.countInvisibleLetters);
	end,
	OnAccept = function(dialog, data)
		local text = dialog:GetEditBox():GetText();
		data.callback(text);
	end,
	OnCancel = function(dialog, data)
		local cancelCallback = data.cancelCallback;
		if cancelCallback ~= nil then
			cancelCallback();
		end
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		if dialog:GetButton1():IsEnabled() then
			local text = dialog:GetEditBox():GetText();
			data.callback(text);
			dialog:Hide();
		end
	end,
	EditBoxOnTextChanged = StaticPopup_StandardNonEmptyTextHandler,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
};

StaticPopupDialogs["GENERIC_DROP_DOWN"] = {
	text = "", -- supplied dynamically.
	button1 = ACCEPT,
	button2 = CANCEL,
	hasDropdown = 1,
	OnShow = function(dialog, data)
		dialog:SetText(data.text);

		local requiresConfirmation = not not data.requiresConfirmation;
		dialog:GetButton1():SetShown(requiresConfirmation);
		dialog:GetButton2():SetShown(requiresConfirmation);

		dialog.selection = data.defaultOption;
		local function SetSelected(option)
			if requiresConfirmation then
				dialog.selection = option;
			else
				data.callback(option);
				dialog:Hide();
			end
		end

		dialog.Dropdown:SetupMenu(function(dropdown, rootDescription)
			local function IsSelected(option)
				return option == dialog.selection;
			end

			for index, option in ipairs(data.options) do
				rootDescription:CreateRadio(option.text, IsSelected, SetSelected, option.value);
			end
		end);
	end,
	OnAccept = function(dialog, data)
		if dialog.selection then
			data.callback(dialog.selection);
		end
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
};

StaticPopupDialogs["CONFIRM_OVERWRITE_EQUIPMENT_SET"] = {
	text = CONFIRM_OVERWRITE_EQUIPMENT_SET,
	button1 = YES,
	button2 = NO,
	--OnAccept OVERRIDEN
	OnCancel = function(dialog, data) end,
	OnHide = function(dialog, data) dialog.data = nil; dialog.selectedIcon = nil; end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
};

StaticPopupDialogs["CONFIRM_SAVE_EQUIPMENT_SET"] = {
	text = CONFIRM_SAVE_EQUIPMENT_SET,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data) C_EquipmentSet.SaveEquipmentSet(data); end,
	OnCancel = function(dialog, data) end,
	OnHide = function(dialog, data) dialog.data = nil; end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
};

StaticPopupDialogs["CONFIRM_DELETE_EQUIPMENT_SET"] = {
	text = CONFIRM_DELETE_EQUIPMENT_SET,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data) C_EquipmentSet.DeleteEquipmentSet(data); end,
	OnCancel = function(dialog, data) end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
};

StaticPopupDialogs["ERROR_CINEMATIC"] = {
	text = ERROR_CINEMATIC,
	button1 = OKAY,
	button2 = nil,
	timeout = 0,
	OnAccept = function(dialog, data)
	end,
	OnCancel = function(dialog, data)
	end,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_RESET_TEXTTOSPEECH_SETTINGS"] = {
	text = CONFIRM_TEXT_TO_SPEECH_RESET,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		TextToSpeechFrame_SetToDefaults();
	end,
	OnCancel = function(dialog, data) end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	whileDead = 1,
};

StaticPopupDialogs["CONFIRM_REDOCK_CHAT"] = {
	text = CONFIRM_REDOCK_CHAT,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		RedockChatWindows();
	end,
	OnCancel = function(dialog, data) end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	whileDead = 1,
};

StaticPopupDialogs["CONFIRM_PURCHASE_TOKEN_ITEM"] = {
	text = CONFIRM_PURCHASE_TOKEN_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		BuyMerchantItem(MerchantFrame.itemIndex, MerchantFrame.count);
	end,
	OnCancel = function(dialog, data)
	end,
	OnShow = function(dialog, data)
	end,
	OnHide = function(dialog, data)
	end,
	timeout = 0,
	hideOnEscape = 1,
	hasItemFrame = 1,
};

StaticPopupDialogs["CONFIRM_PURCHASE_NONREFUNDABLE_ITEM"] = {
	text = CONFIRM_PURCHASE_NONREFUNDABLE_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		BuyMerchantItem(MerchantFrame.itemIndex, MerchantFrame.count);
	end,
	OnCancel = function(dialog, data)
	end,
	OnShow = function(dialog, data)
	end,
	OnHide = function(dialog, data)
	end,
	timeout = 0,
	hideOnEscape = 1,
	hasItemFrame = 1,
};

StaticPopupDialogs["CONFIRM_REFUND_TOKEN_ITEM"] = {
	text = CONFIRM_REFUND_TOKEN_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		C_Container.ContainerRefundItemPurchase(MerchantFrame.refundBag, MerchantFrame.refundSlot, MerchantFrame.refundItemEquipped);
		StackSplitFrame:Hide();
	end,
	OnCancel = function(dialog, data)
		ClearCursor();
	end,
	OnShow = function(dialog, data)
		if(MerchantFrame.price ~= 0) then
			MoneyFrame_Update(dialog.MoneyFrame, MerchantFrame.price);
		end
	end,
	OnHide = function(dialog, data)
		MerchantFrame_ResetRefundItem();
	end,
	timeout = 0,
	hideOnEscape = 1,
	hasItemFrame = 1,
};

StaticPopupDialogs["CONFIRM_REFUND_MAX_HONOR"] = {
	text = CONFIRM_REFUND_MAX_HONOR,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		C_Container.ContainerRefundItemPurchase(MerchantFrame.refundBag, MerchantFrame.refundSlot);
		StackSplitFrame:Hide();
	end,
	OnCancel = function(dialog, data)
		ClearCursor();
	end,
	OnShow = function(dialog, data)
	end,
	OnHide = function(dialog, data)
		MerchantFrame_ResetRefundItem();
	end,
	timeout = 0,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_REFUND_MAX_ARENA_POINTS"] = {
	text = CONFIRM_REFUND_MAX_ARENA_POINTS,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		C_Container.ContainerRefundItemPurchase(MerchantFrame.refundBag, MerchantFrame.refundSlot);
		StackSplitFrame:Hide();
	end,
	OnCancel = function(dialog, data)
		ClearCursor();
	end,
	OnShow = function(dialog, data)
	end,
	OnHide = function(dialog, data)
		MerchantFrame_ResetRefundItem();
	end,
	timeout = 0,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_REFUND_MAX_HONOR_AND_ARENA"] = {
	text = CONFIRM_REFUND_MAX_HONOR_AND_ARENA,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		C_Container.ContainerRefundItemPurchase(MerchantFrame.refundBag, MerchantFrame.refundSlot);
		StackSplitFrame:Hide();
	end,
	OnCancel = function(dialog, data)
		ClearCursor();
	end,
	OnShow = function(dialog, data)
	end,
	OnHide = function(dialog, data)
		MerchantFrame_ResetRefundItem();
	end,
	timeout = 0,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_HIGH_COST_ITEM"] = {
	text = CONFIRM_HIGH_COST_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		BuyMerchantItem(MerchantFrame.itemIndex, MerchantFrame.count);
	end,
	OnCancel = function(dialog, data)
	end,
	OnShow = function(dialog, data)
		MoneyFrame_Update(dialog.MoneyFrame, MerchantFrame.price*MerchantFrame.count);
	end,
	OnHide = function(dialog, data)
	end,
	timeout = 0,
	hideOnEscape = 1,
	hasMoneyFrame = 1,
};

StaticPopupDialogs["CONFIRM_COMPLETE_EXPENSIVE_QUEST"] = {
	text = CONFIRM_COMPLETE_EXPENSIVE_QUEST,
	button1 = COMPLETE_QUEST,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		GetQuestReward(QuestInfoFrame.itemChoice);
		PlaySound(SOUNDKIT.IG_QUEST_LIST_COMPLETE);
	end,
	OnCancel = function(dialog, data)
		DeclineQuest();
		PlaySound(SOUNDKIT.IG_QUEST_CANCEL);
	end,
	OnShow = function(dialog, data)
		QuestInfoFrame.acceptButton:Disable();
	end,
	timeout = 0,
	hideOnEscape = 1,
	hasMoneyFrame = 1,
};
StaticPopupDialogs["CONFIRM_ACCEPT_PVP_QUEST"] = {
	text = CONFIRM_ACCEPT_PVP_QUEST,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		AcceptQuest();
	end,
	OnCancel = function(dialog, data)
		DeclineQuest();
		PlaySound(SOUNDKIT.IG_QUEST_CANCEL);
	end,
	OnShow = function(dialog, data)
		QuestFrameAcceptButton:Disable();
		QuestFrameDeclineButton:Disable();
	end,
	OnHide = function(dialog, data)
		QuestFrameAcceptButton:Enable();
		QuestFrameDeclineButton:Enable();
	end,
	timeout = 0,
	hideOnEscape = 1,
};
StaticPopupDialogs["USE_GUILDBANK_REPAIR"] = {
	text = USE_GUILDBANK_REPAIR,
	button1 = USE_PERSONAL_FUNDS,
	button2 = OKAY,
	OnAccept = function(dialog, data)
		RepairAllItems();
		PlaySound(SOUNDKIT.ITEM_REPAIR);
	end,
	OnCancel = function(dialog, data)
		RepairAllItems(true);
		PlaySound(SOUNDKIT.ITEM_REPAIR);
	end,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["GUILDBANK_WITHDRAW"] = {
	text = GUILDBANK_WITHDRAW,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		WithdrawGuildBankMoney(MoneyInputFrame_GetCopper(dialog.MoneyInputFrame));
	end,
	OnHide = function(dialog, data)
		MoneyInputFrame_ResetMoney(dialog.MoneyInputFrame);
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent():GetParent();
		WithdrawGuildBankMoney(MoneyInputFrame_GetCopper(dialog.MoneyInputFrame));
		dialog:Hide();
	end,
	hasMoneyInputFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["GUILDBANK_DEPOSIT"] = {
	text = GUILDBANK_DEPOSIT,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		DepositGuildBankMoney(MoneyInputFrame_GetCopper(dialog.MoneyInputFrame));
	end,
	OnHide = function(dialog, data)
		MoneyInputFrame_ResetMoney(dialog.MoneyInputFrame);
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent():GetParent();
		DepositGuildBankMoney(MoneyInputFrame_GetCopper(dialog.MoneyInputFrame));
		dialog:Hide();
	end,
	hasMoneyInputFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_BUY_GUILDBANK_TAB"] = {
	text = CONFIRM_BUY_GUILDBANK_TAB,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		BuyGuildBankTab();
	end,
	OnShow = function(dialog, data)
		MoneyFrame_Update(dialog.MoneyFrame, GetGuildBankTabCost());
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_BUY_REAGENTBANK_TAB"] = {
	text = CONFIRM_BUY_REAGNETBANK_TAB,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		BuyReagentBank();
	end,
	OnShow = function(dialog, data)
		MoneyFrame_Update(dialog.MoneyFrame, GetReagentBankCost());
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["TOO_MANY_LUA_ERRORS"] = {
	text = TOO_MANY_LUA_ERRORS,
	button1 = DISABLE_ADDONS,
	button2 = IGNORE_ERRORS,
	OnAccept = function(dialog, data)
		C_AddOns.DisableAllAddOns();
		ReloadUI();
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_ACCEPT_SOCKETS"] = {
	text = CONFIRM_ACCEPT_SOCKETS,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		AcceptSockets();
		PlaySound(SOUNDKIT.JEWEL_CRAFTING_FINALIZE);
	end,
	timeout = 0,
	showAlert = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_RESET_INSTANCES"] = {
	text = CONFIRM_RESET_INSTANCES,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		ResetInstances();
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_RESET_CHALLENGE_MODE"] = {
	text = CONFIRM_RESET_CHALLENGE_MODE,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		C_ChallengeMode.Reset();
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_GUILD_DISBAND"] = {
	text = CONFIRM_GUILD_DISBAND,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		C_GuildInfo.Disband();
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_BUY_BANK_SLOT"] = {
	text = CONFIRM_BUY_BANK_SLOT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		PurchaseSlot();
	end,
	OnShow = function(dialog, data)
		MoneyFrame_Update(dialog.MoneyFrame, BankFrame.nextSlotCost);
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1,
};

StaticPopupDialogs["MACRO_ACTION_FORBIDDEN"] = {
	text = MACRO_ACTION_FORBIDDEN,
	button1 = OKAY,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"] = {
	text = ADDON_ACTION_FORBIDDEN,
	button1 = DISABLE,
	button2 = IGNORE_DIALOG,
	OnAccept = function(dialog, data)
		C_AddOns.DisableAddOn(data);
		ReloadUI();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_LOOT_DISTRIBUTION"] = {
	text = CONFIRM_LOOT_DISTRIBUTION,
	button1 = YES,
	button2 = NO,
	--OnAccept OVERRIDEN
	timeout = 0,
	hideOnEscape = 1,
};

StaticPopupDialogs["BFMGR_CONFIRM_WORLD_PVP_QUEUED"] = {
	text = WORLD_PVP_QUEUED,
	button1 = OKAY,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["BFMGR_CONFIRM_WORLD_PVP_QUEUED_WARMUP"] = {
	text = WORLD_PVP_QUEUED_WARMUP,
	button1 = OKAY,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["BFMGR_DENY_WORLD_PVP_QUEUED"] = {
	text = WORLD_PVP_FAIL,
	button1 = OKAY,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["BFMGR_INVITED_TO_QUEUE"] = {
	text = WORLD_PVP_INVITED,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function(dialog, battleID)
		SetupLockOnDeclineButtonAndEscape(dialog);
	end,
	OnAccept = function(dialog, battleID)
		BattlefieldMgrQueueInviteResponse(battleID, 1);
	end,
	OnCancel = function(dialog, battleID)
		BattlefieldMgrQueueInviteResponse(battleID, 0);
	end,
	timeout = 0,
	whileDead = 1,
	multiple = 1
};

StaticPopupDialogs["BFMGR_INVITED_TO_QUEUE_WARMUP"] = {
	text = WORLD_PVP_INVITED_WARMUP;
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function(dialog, battleID)
		SetupLockOnDeclineButtonAndEscape(dialog);
	end,
	OnAccept = function(dialog, battleID)
		BattlefieldMgrQueueInviteResponse(battleID, 1);
	end,
	OnCancel = function(dialog, battleID)
		BattlefieldMgrQueueInviteResponse(battleID, 0);
	end,
	timeout = 0,
	whileDead = 1,
	multiple = 1
};

StaticPopupDialogs["BFMGR_INVITED_TO_ENTER"] = {
	text = WORLD_PVP_ENTER,
	GetExpirationText = function(dialog, data, timeleft)
		local dialogInfo = dialog.dialogInfo;
		if timeleft < 60 then
			return string.format(dialogInfo.text, dialog:GetTextFontString().text_arg1, timeleft, SECONDS);
		else
			return string.format(dialogInfo.text, dialog:GetTextFontString().text_arg1, ceil(timeleft / 60), MINUTES);
		end
	end,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function(dialog, battleID)
		for i = 1, MAX_WORLD_PVP_QUEUES do
			local status, mapName, queueID, timeleft = GetWorldPVPQueueStatus(i);
			if ( queueID == battleID ) then
				dialog.timeleft = timeleft;
			end
		end
		SetupLockOnDeclineButtonAndEscape(dialog);
	end,
	OnAccept = function(dialog, battleID)
		BattlefieldMgrEntryInviteResponse(battleID, true);
	end,
	OnCancel = function(dialog, battleID)
		BattlefieldMgrEntryInviteResponse(battleID, false);
	end,
	timeout = 0,
	timeoutInformationalOnly = 1;
	whileDead = 1,
	multiple = 1,
	sound = SOUNDKIT.PVP_THROUGH_QUEUE,
};

StaticPopupDialogs["BFMGR_EJECT_PENDING"] = {
	text = WORLD_PVP_PENDING,
	button1 = OKAY,
	showAlert = 1,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["BFMGR_EJECT_PENDING_REMOTE"] = {
	text = WORLD_PVP_PENDING_REMOTE,
	button1 = OKAY,
	showAlert = 1,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["BFMGR_PLAYER_EXITED_BATTLE"] = {
	text = WORLD_PVP_EXITED_BATTLE,
	button1 = OKAY,
	showAlert = 1,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["BFMGR_PLAYER_LOW_LEVEL"] = {
	text = WORLD_PVP_LOW_LEVEL,
	button1 = OKAY,
	showAlert = 1,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["BFMGR_PLAYER_NOT_WHILE_IN_RAID"] = {
	text = WORLD_PVP_NOT_WHILE_IN_RAID,
	button1 = OKAY,
	showAlert = 1,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["BFMGR_PLAYER_DESERTER"] = {
	text = WORLD_PVP_DESERTER,
	button1 = OKAY,
	showAlert = 1,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["CONFIRM_GUILD_LEAVE"] = {
	text = CONFIRM_GUILD_LEAVE,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		C_GuildInfo.Leave();
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_GUILD_PROMOTE"] = {
	text = CONFIRM_GUILD_PROMOTE,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, name)
		C_GuildInfo.SetLeader(name);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["RENAME_GUILD"] = {
	text = RENAME_GUILD_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 24,
	OnAccept = function(dialog, data)
		local text = dialog:GetEditBox():GetText();
		RenamePetition(text);
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local text = editBox:GetText();
		RenamePetition(text);
		editBox:GetParent():Hide();
	end,
	OnShow = function(dialog, data)
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["HELP_TICKET_QUEUE_DISABLED"] = {
	text = HELP_TICKET_QUEUE_DISABLED,
	button1 = OKAY,
	showAlert = 1,
	timeout = 0,
};

StaticPopupDialogs["CLIENT_RESTART_ALERT"] = {
	text = CLIENT_RESTART_ALERT,
	button1 = OKAY,
	showAlert = 1,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["CLIENT_LOGOUT_ALERT"] = {
	text = CLIENT_LOGOUT_ALERT,
	button1 = OKAY,
	showAlert = 1,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["COD_ALERT"] = {
	text = COD_INSUFFICIENT_MONEY,
	button1 = CLOSE,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["COD_CONFIRMATION"] = {
	text = COD_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		TakeInboxItem(InboxFrame.openMailID, OpenMailFrame.lastTakeAttachment);
	end,
	OnShow = function(dialog, data)
		MoneyFrame_Update(dialog.MoneyFrame, OpenMailFrame.cod);
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["COD_CONFIRMATION_AUTO_LOOT"] = {
	text = COD_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, index)
		AutoLootMailItem(index);
	end,
	OnShow = function(dialog, index)
		MoneyFrame_Update(dialog.MoneyFrame, OpenMailFrame.cod);
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["DELETE_MAIL"] = {
	text = DELETE_MAIL_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		DeleteInboxItem(InboxFrame.openMailID);
		InboxFrame.openMailID = nil;
		HideUIPanel(OpenMailFrame);
	end,
	showAlert = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["DELETE_MONEY"] = {
	text = DELETE_MONEY_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		DeleteInboxItem(InboxFrame.openMailID);
		InboxFrame.openMailID = nil;
		HideUIPanel(OpenMailFrame);
	end,
	OnShow = function(dialog, data)
		MoneyFrame_Update(dialog.MoneyFrame, OpenMailFrame.money);
	end,
	hasMoneyFrame = 1,
	showAlert = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_REPORT_SPAM_MAIL"] = {
	text = REPORT_SPAM_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, index)
		ComplainInboxItem(index);
	end,
	OnCancel = function(dialog, index)
		OpenMailReportSpamButton:Enable();
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["JOIN_CHANNEL"] = {
	text = ADD_CHANNEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	whileDead = 1,
	OnAccept = function(dialog, data)
		local channel = dialog:GetEditBox():GetText();
		JoinPermanentChannel(channel, nil, FCF_GetCurrentChatFrameID(), 1);
		ChatFrame_AddChannel(FCF_GetCurrentChatFrame(), channel);
		dialog:GetEditBox():SetText("");
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		local channel = editBox:GetText();
		JoinPermanentChannel(channel, nil, FCF_GetCurrentChatFrameID(), 1);
		ChatFrame_AddChannel(FCF_GetCurrentChatFrame(), channel);
		editBox:SetText("");
		dialog:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	hideOnEscape = 1
};

StaticPopupDialogs["CHANNEL_INVITE"] = {
	text = CHANNEL_INVITE,
	button1 = ACCEPT_ALT,
	button2 = CANCEL,
	hasEditBox = 1,
	autoCompleteSource = GetAutoCompleteResults,
	autoCompleteArgs = { AUTOCOMPLETE_LIST.CHANINVITE.include, AUTOCOMPLETE_LIST.CHANINVITE.exclude },
	maxLetters = 31,
	whileDead = 1,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
	end,
	OnAccept = function(dialog, data)
		local name = dialog:GetEditBox():GetText();
		ChannelInvite(data, name);
		dialog:GetEditBox():SetText("");
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		ChannelInvite(data, editBox:GetText());
		editBox:SetText("");
		dialog:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	hideOnEscape = 1
};

StaticPopupDialogs["CHANNEL_PASSWORD"] = {
	text = CHANNEL_PASSWORD,
	button1 = ACCEPT_ALT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	whileDead = 1,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
	end,
	OnAccept = function(dialog, data)
		local password = dialog:GetEditBox():GetText();
		SetChannelPassword(data, password);
		dialog:GetEditBox():SetText("");
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		local password = editBox:GetText();
		SetChannelPassword(data, password);
		editBox:SetText("");
		dialog:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	hideOnEscape = 1
};

StaticPopupDialogs["NAME_CHAT"] = {
	text = NAME_CHAT_WINDOW,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	whileDead = 1,
	OnAccept = function(dialog, renameID)
		local name = dialog:GetEditBox():GetText();
		if ( renameID ) then
			FCF_SetWindowName(_G["ChatFrame"..renameID], name);
		else
			local frame = FCF_OpenNewWindow(name);
			FCF_CopyChatSettings(frame, DEFAULT_CHAT_FRAME);
		end
		dialog:GetEditBox():SetText("");
		FCF_DockUpdate();
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(editBox, renameID)
		local dialog = editBox:GetParent();
		local name = editBox:GetText();
		if ( renameID ) then
			FCF_SetWindowName(_G["ChatFrame"..renameID], name);
		else
			local frame = FCF_OpenNewWindow(name);
			FCF_CopyChatSettings(frame, DEFAULT_CHAT_FRAME);
		end
		editBox:SetText("");
		FCF_DockUpdate();
		dialog:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	hideOnEscape = 1
};

StaticPopupDialogs["RESURRECT"] = {
	StartDelay = GetCorpseRecoveryDelay,
	GetExpirationText = function(dialog, data, timeleft)
		if timeleft < 60 then
			return string.format(RESURRECT_REQUEST_TIMER, dialog:GetTextFontString().text_arg1, timeleft, SECONDS);
		else
			return string.format(RESURRECT_REQUEST_TIMER, dialog:GetTextFontString().text_arg1, ceil(timeleft / 60), MINUTES);
		end
	end,
	text = RESURRECT_REQUEST,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnShow = function(dialog, data)
		dialog.timeleft = GetCorpseRecoveryDelay() + 60;
		SetupLockOnDeclineButtonAndEscape(dialog);
	end,
	OnAccept = function(dialog, data)
		AcceptResurrect();
	end,
	OnCancel = function(dialog, data, reason)
		if ( reason == "timeout" ) then
			TimeoutResurrect();
		else
			DeclineResurrect();
		end
		if ( UnitIsDead("player") and not UnitIsControlling("player") ) then
			StaticPopup_Show("DEATH");
		end
	end,
	timeout = StaticPopupTimeoutSec,
	whileDead = 1,
	cancels = "DEATH",
	interruptCinematic = 1,
	notClosableByLogout = 1,
	noCancelOnReuse = 1,
};
StaticPopupDialogs["RESURRECT_NO_SICKNESS"] = {
	StartDelay = GetCorpseRecoveryDelay,
	GetExpirationText = function(dialog, data, timeleft)
		if timeleft < 60 then
			return string.format(RESURRECT_REQUEST_NO_SICKNESS_TIMER, dialog:GetTextFontString().text_arg1, timeleft, SECONDS);
		else
			return string.format(RESURRECT_REQUEST_NO_SICKNESS_TIMER, dialog:GetTextFontString().text_arg1, ceil(timeleft / 60), MINUTES);
		end
	end,
	text = RESURRECT_REQUEST_NO_SICKNESS,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnShow = function(dialog, data)
		dialog.timeleft = GetCorpseRecoveryDelay() + 60;
		SetupLockOnDeclineButtonAndEscape(dialog);
	end,
	OnAccept = function(dialog, data)
		AcceptResurrect();
	end,
	OnCancel = function(dialog, data, reason)
		if ( reason == "timeout" ) then
			TimeoutResurrect();
		else
			DeclineResurrect();
		end
		if ( UnitIsDead("player") and not UnitIsControlling("player") ) then
			StaticPopup_Show("DEATH");
		end
	end,
	timeout = StaticPopupTimeoutSec,
	whileDead = 1,
	cancels = "DEATH",
	interruptCinematic = 1,
	notClosableByLogout = 1,
	noCancelOnReuse = 1,
};
StaticPopupDialogs["RESURRECT_NO_TIMER"] = {
	text = RESURRECT_REQUEST_NO_SICKNESS,
	button1 = ACCEPT,
	button1Pulse = true,
	button2 = DECLINE,
	OnShow = function(dialog, data)
		dialog.timeleft = GetCorpseRecoveryDelay() + 60;
		local declineTimeLeft;
		local resOptions = C_DeathInfo.GetSelfResurrectOptions();
		if ( resOptions and #resOptions > 0 ) then
			declineTimeLeft = 1;
		else
			declineTimeLeft = 5;
		end
		SetupLockOnDeclineButtonAndEscape(dialog, declineTimeLeft);
	end,
	OnAccept = function(dialog, data)
		AcceptResurrect();
	end,
	OnCancel = function(dialog, data, reason)
		if ( reason == "timeout" ) then
			TimeoutResurrect();
		else
			DeclineResurrect();
		end
		if ( UnitIsDead("player") and not UnitIsControlling("player") ) then
			StaticPopup_Show("DEATH");
		end
	end,
	timeout = StaticPopupTimeoutSec,
	whileDead = 1,
	cancels = "DEATH",
	interruptCinematic = 1,
	notClosableByLogout = 1,
	noCancelOnReuse = 1
};
StaticPopupDialogs["SKINNED"] = {
	text = DEATH_CORPSE_SKINNED,
	button1 = ACCEPT,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
};
StaticPopupDialogs["SKINNED_REPOP"] = {
	text = DEATH_CORPSE_SKINNED,
	button1 = DEATH_RELEASE,
	button2 = DECLINE,
	OnShow = function(dialog, data)
		dialog.timeleft = GetCorpseRecoveryDelay() + 60;
		SetupLockOnDeclineButtonAndEscape(dialog);
	end,
	OnAccept = function(dialog, data)
		StaticPopup_Hide("RESURRECT");
		StaticPopup_Hide("RESURRECT_NO_SICKNESS");
		StaticPopup_Hide("RESURRECT_NO_TIMER");
		RepopMe();
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
};
StaticPopupDialogs["TRADE"] = {
	text = TRADE_WITH_QUESTION,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		BeginTrade();
	end,
	OnCancel = function(dialog, data)
		CancelTrade();
	end,
	timeout = StaticPopupTimeoutSec,
	hideOnEscape = 1
};
StaticPopupDialogs["PARTY_INVITE"] = {
	text = "%s",
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = SOUNDKIT.IG_PLAYER_INVITE,
	OnShow = function(dialog, data)
		dialog.inviteAccepted = nil;
		SetupLockOnDeclineButtonAndEscape(dialog);
	end,
	OnAccept = function(dialog, data)
		AcceptGroup();
		dialog.inviteAccepted = 1;
	end,
	OnCancel = function(dialog, data)
		DeclineGroup();
	end,
	OnHide = function(dialog, data)
		if ( not dialog.inviteAccepted ) then
			DeclineGroup();
			dialog:Hide();
		end
	end,
	timeout = StaticPopupTimeoutSec,
	whileDead = 1,
};

StaticPopupDialogs["CHAT_CHANNEL_INVITE"] = {
	text = CHAT_INVITE_NOTICE_POPUP,
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = SOUNDKIT.IG_PLAYER_INVITE,
	OnShow = function(dialog, data)
		StaticPopupDialogs["CHAT_CHANNEL_INVITE"].inviteAccepted = nil;
	end,
	OnAccept = function(dialog, data)
		local name = data;
		local zoneChannel, channelName = JoinPermanentChannel(name, nil, DEFAULT_CHAT_FRAME:GetID(), 1);
		if ( channelName ) then
			name = channelName;
		end
		if ( not zoneChannel ) then
			return;
		end

		local i = 1;
		while ( DEFAULT_CHAT_FRAME.channelList[i] ) do
			i = i + 1;
		end
		DEFAULT_CHAT_FRAME.channelList[i] = name;
		DEFAULT_CHAT_FRAME.zoneChannelList[i] = zoneChannel;
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local name = data;
		local zoneChannel, channelName = JoinPermanentChannel(name, nil, DEFAULT_CHAT_FRAME:GetID(), 1);
		if ( channelName ) then
			name = channelName;
		end
		if ( not zoneChannel ) then
			return;
		end

		local i = 1;
		while ( DEFAULT_CHAT_FRAME.channelList[i] ) do
			i = i + 1;
		end
		DEFAULT_CHAT_FRAME.channelList[i] = name;
		DEFAULT_CHAT_FRAME.zoneChannelList[i] = zoneChannel;
		StaticPopupDialogs["CHAT_CHANNEL_INVITE"].inviteAccepted = 1;
		editBox:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	OnCancel = function(dialog, data)
		local chanName = data;
		DeclineChannelInvite(chanName);
	end,
	timeout = CHANNEL_INVITE_TIMEOUT,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["BN_BLOCK_FAILED_TOO_MANY_RID"] = {
	text = BN_BLOCK_FAILED_TOO_MANY_RID,
	button1 = OKAY,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["BN_BLOCK_FAILED_TOO_MANY_CID"] = {
	text = BN_BLOCK_FAILED_TOO_MANY_CID,
	button1 = OKAY,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};

local function ChatChannelPasswordHandler(dialog, data)
	local password = dialog:GetEditBox():GetText();
	local name = data;
	local zoneChannel, channelName = JoinPermanentChannel(name, password, DEFAULT_CHAT_FRAME:GetID(), 1);
	if ( channelName ) then
		name = channelName;
	end
	if ( not zoneChannel ) then
		return;
	end

	local i = 1;
	while ( DEFAULT_CHAT_FRAME.channelList[i] ) do
		i = i + 1;
	end
	DEFAULT_CHAT_FRAME.channelList[i] = name;
	DEFAULT_CHAT_FRAME.zoneChannelList[i] = zoneChannel;
	StaticPopupDialogs["CHAT_CHANNEL_INVITE"].inviteAccepted = 1;
end

StaticPopupDialogs["CHAT_CHANNEL_PASSWORD"] = {
	text = CHAT_PASSWORD_NOTICE_POPUP,
	hasEditBox = 1,
	maxLetters = 31,
	button1 = OKAY,
	button2 = CANCEL,
	sound = SOUNDKIT.IG_PLAYER_INVITE,
	OnAccept = function(dialog, data)
		ChatChannelPasswordHandler(dialog, data);
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		ChatChannelPasswordHandler(editBox:GetParent(), data);
		editBox:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = StaticPopupTimeoutSec,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["QUIT"] = {
	text = QUIT_TIMER,
	GetExpirationText = GameDialogDefsUtil.GetDefaultExpirationText,
	button1 = QUIT_NOW,
	button2 = CANCEL,
	cancelIfNotAllowedWhileLoggingOut = true,
	OnAccept = function(dialog, data)
		ForceQuit();
		dialog.timeleft = 0;
	end,
	OnHide = function(dialog, data)
		if ( dialog.timeleft > 0 ) then
			CancelLogout();
			dialog:Hide();
		end
	end,
	timeout = 20,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["LOOT_BIND"] = {
	text = LOOT_NO_DROP,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, slot)
		ConfirmLootSlot(slot);
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["USE_BIND"] = {
	text = USE_NO_DROP,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		C_Item.ConfirmBindOnUse();
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIM_BEFORE_USE"] = {
	text = CONFIRM_ITEM_USE,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		C_Item.ConfirmOnUse();
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["USE_NO_REFUND_CONFIRM"] = {
	text = END_REFUND,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		C_Item.ConfirmNoRefundOnUse();
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_AZERITE_EMPOWERED_BIND"] = {
	text = AZERITE_EMPOWERED_BIND_NO_DROP,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		data.SelectPower();
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	showAlert = 1,
};

StaticPopupDialogs["CONFIRM_AZERITE_EMPOWERED_SELECT_POWER"] = {
	text = AZERITE_EMPOWERED_SELECT_POWER,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		data.SelectPower();
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_AZERITE_EMPOWERED_RESPEC"] = {
	text = CONFIRM_AZERITE_EMPOWERED_ITEM_RESPEC,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		PlaySound(SOUNDKIT.UI_80_AZERITEARMOR_REFORGE);
		C_AzeriteEmpoweredItem.ConfirmAzeriteEmpoweredItemRespec(data.empoweredItemLocation);
	end,
	OnShow = function(dialog, data)
		MoneyFrame_Update(dialog.MoneyFrame, data.respecCost);
	end,
	timeout = 0,
	hideOnEscape = 1,
	exclusive = 1,
	showAlert = 1,
	hasMoneyFrame = 1,
};

StaticPopupDialogs["DELETE_ITEM"] = {
	text = DELETE_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		DeleteCursorItem();
	end,
	OnCancel = function(dialog, data)
		ClearCursor();
	end,
	OnUpdate = function(dialog, elapsed)
		if ( not CursorHasItem() ) then
			dialog:Hide();
		end
	end,
	OnHide = function(dialog, data)
		MerchantFrame_ResetRefundItem();
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["DELETE_QUEST_ITEM"] = {
	text = DELETE_QUEST_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		DeleteCursorItem();
	end,
	OnCancel = function(dialog, data)
		ClearCursor();
	end,
	OnUpdate = function(dialog, elapsed)
		if ( not CursorHasItem() ) then
			dialog:Hide();
		end
	end,
	OnHide = function(dialog, data)
		MerchantFrame_ResetRefundItem();
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["QUEST_ACCEPT"] = {
	text = QUEST_ACCEPT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		ConfirmAcceptQuest();
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["QUEST_ACCEPT_LOG_FULL"] = {
	text = QUEST_ACCEPT_LOG_FULL,
	button1 = YES,
	button2 = NO,
	OnShow = function(dialog, data)
		dialog:GetButton1():Disable();
	end,
	OnAccept = function(dialog, data)
		ConfirmAcceptQuest();
	end,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["ABANDON_QUEST"] = {
	text = ABANDON_QUEST_CONFIRM,
	button1 = YES,
	button2 = NO,
	--OnAccept OVERRIDEN
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["ABANDON_QUEST_WITH_ITEMS"] = {
	text = ABANDON_QUEST_CONFIRM_WITH_ITEMS,
	button1 = YES,
	button2 = NO,
	--OnAccept OVERRIDEN
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["ADD_FRIEND"] = {
	text = ADD_FRIEND_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	autoCompleteSource = GetAutoCompleteResults,
	autoCompleteArgs = { AUTOCOMPLETE_LIST.ADDFRIEND.include, AUTOCOMPLETE_LIST.ADDFRIEND.exclude },
	maxLetters = 12 + 1 + 64,
	OnAccept = function(dialog, data)
		C_FriendList.AddFriend(dialog:GetEditBox():GetText());
	end,
	OnShow = function(dialog, data)
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		C_FriendList.AddFriend(editBox:GetText());
		dialog:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["SET_FRIENDNOTE"] = {
	text = SET_FRIENDNOTE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 48,
	countInvisibleLetters = true,
	editBoxWidth = 350,
	OnAccept = function(dialog, data)
		if(not C_FriendList.SetFriendNotes(FriendsFrame.NotesID, dialog:GetEditBox():GetText())) then
			UIErrorsFrame:AddExternalErrorMessage(ERR_FRIEND_NOT_FOUND);
		end
	end,
	--OnShow OVERRIDEN
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		if(not C_FriendList.SetFriendNotes(FriendsFrame.NotesID, editBox:GetText())) then
			UIErrorsFrame:AddExternalErrorMessage(ERR_FRIEND_NOT_FOUND);
		end
		dialog:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["SET_BNFRIENDNOTE"] = {
	text = SET_FRIENDNOTE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 127,
	countInvisibleLetters = true,
	editBoxWidth = 350,
	OnAccept = function(dialog, data)
		BNSetFriendNote(FriendsFrame.NotesID, dialog:GetEditBox():GetText());
	end,
	--OnShow OVERRIDEN
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		BNSetFriendNote(FriendsFrame.NotesID, editBox:GetText());
		dialog:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["SET_COMMUNITY_MEMBER_NOTE"] = {
	text = SET_FRIENDNOTE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 200,
	countInvisibleLetters = true,
	editBoxWidth = 350,
	OnAccept = function(dialog, data)
		C_Club.SetClubMemberNote(data.clubId, data.memberId, dialog:GetEditBox():GetText());
	end,
	OnShow = function(dialog, data)
		local memberInfo = C_Club.GetMemberInfo(data.clubId, data.memberId);
		if ( memberInfo and memberInfo.memberNote ) then
			dialog:GetEditBox():SetText(memberInfo.memberNote);
		end
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		C_Club.SetClubMemberNote(data.clubId, data.memberId, editBox:GetText());
		dialog:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_REMOVE_COMMUNITY_MEMBER"] = {
	text = CONFIRM_REMOVE_COMMUNITY_MEMBER_LABEL,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		C_Club.KickMember(data.clubId, data.memberId);
	end,
	--OnShow OVERRIDEN
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};


StaticPopupDialogs["CONFIRM_DESTROY_COMMUNITY_STREAM"] = {
	text = CONFIRM_DESTROY_COMMUNITY_STREAM_LABEL,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		C_Club.DestroyStream(data.clubId, data.streamId);
	end,
	OnShow = function(dialog, data)
		local streamInfo = C_Club.GetStreamInfo(data.clubId, data.streamId);
		if streamInfo then
			dialog:SetText(CONFIRM_DESTROY_COMMUNITY_STREAM_LABEL:format(streamInfo.name));
		end
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_LEAVE_AND_DESTROY_COMMUNITY"] = {
	text = CONFIRM_LEAVE_AND_DESTROY_COMMUNITY,
	subText = CONFIRM_LEAVE_AND_DESTROY_COMMUNITY_SUBTEXT,
	button1 = ACCEPT,
	button2 = CANCEL,
	--OnShow OVERRIDEN
	OnAccept = function(dialog, clubInfo)
		C_Club.DestroyClub(clubInfo.clubId);
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_LEAVE_COMMUNITY"] = {
	text = CONFIRM_LEAVE_COMMUNITY,
	subText = CONFIRM_LEAVE_COMMUNITY_SUBTEXT,
	button1 = ACCEPT,
	button2 = CANCEL,
	--OnShow OVERRIDEN
	OnAccept = function(dialog, clubInfo)
		C_Club.LeaveClub(clubInfo.clubId);
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["ADD_IGNORE"] = {
	text = ADD_IGNORE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	autoCompleteSource = GetAutoCompleteResults,
	autoCompleteArgs = { AUTOCOMPLETE_LIST.IGNORE.include, AUTOCOMPLETE_LIST.IGNORE.exclude },
	maxLetters = 12 + 1 + 64, --name space realm (77 max)
	OnAccept = function(dialog, data)
		C_FriendList.AddIgnore(dialog:GetEditBox():GetText());
	end,
	OnShow = function(dialog, data)
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		C_FriendList.AddIgnore(editBox:GetText());
		dialog:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONVERT_TO_RAID"] = {
	text = CONVERT_TO_RAID_LABEL,
	button1 = CONVERT,
	button2 = CANCEL,
	--OnAccept OVERRIDEN
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	showAlert = 1
};

StaticPopupDialogs["LFG_LIST_AUTO_ACCEPT_CONVERT_TO_RAID"] = {
	text = CONVERT_TO_RAID_LABEL,
	button1 = CONVERT,
	button2 = CANCEL,
	--OnAccept OVERRIDEN
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	showAlert = 1
};

StaticPopupDialogs["SET_GUILDPLAYERNOTE"] = {
	text = SET_GUILDPLAYERNOTE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	OnAccept = function(dialog, data)
		GuildRosterSetPublicNote(GetGuildRosterSelection(), dialog:GetEditBox():GetText());
	end,
	OnShow = function(dialog, data)
		--Sets the text to the 7th return from GetGuildRosterInfo(GetGuildRosterSelection());
		dialog:GetEditBox():SetText(select(7, GetGuildRosterInfo(GetGuildRosterSelection())));
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		GuildRosterSetPublicNote(GetGuildRosterSelection(), editBox:GetText());
		dialog:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["SET_GUILDOFFICERNOTE"] = {
	text = SET_GUILDOFFICERNOTE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	OnAccept = function(dialog, data)
		GuildRosterSetOfficerNote(GetGuildRosterSelection(), dialog:GetEditBox():GetText());
	end,
	OnShow = function(dialog, data)
		local fullName, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(GetGuildRosterSelection());

		dialog:GetEditBox():SetText(select(8, GetGuildRosterInfo(GetGuildRosterSelection())));
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		GuildRosterSetOfficerNote(GetGuildRosterSelection(), editBox:GetText());
		dialog:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["SET_GUILD_COMMUNITIY_NOTE"] = {
	text = SET_GUILDPLAYERNOTE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	editBoxWidth = 260,
	OnAccept = function(dialog, data)
		C_GuildInfo.SetNote(data.guid, dialog:GetEditBox():GetText(), data.isPublic);
	end,
	OnShow = function(dialog, data)
		dialog:SetText(data.isPublic and SET_GUILDPLAYERNOTE_LABEL or SET_GUILDOFFICERNOTE_LABEL);
		dialog:GetEditBox():SetText(data.currentNote);
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		C_GuildInfo.SetNote(data.guid, editBox:GetText(), data.isPublic);
		dialog:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["DUEL_REQUESTED"] = {
	text = DUEL_REQUESTED,
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = SOUNDKIT.IG_PLAYER_INVITE,
	OnAccept = function(dialog, data)
		AcceptDuel();
	end,
	OnCancel = function(dialog, data)
		CancelDuel();
	end,
	timeout = StaticPopupTimeoutSec,
	hideOnEscape = 1
};

StaticPopupDialogs["DUEL_OUTOFBOUNDS"] = {
	text = DUEL_OUTOFBOUNDS_TIMER,
	GetExpirationText = GameDialogDefsUtil.GetDefaultExpirationText,
	timeout = 10,
};
StaticPopupDialogs["PET_BATTLE_PVP_DUEL_REQUESTED"] = {
	text = PET_BATTLE_PVP_DUEL_REQUESTED,
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = SOUNDKIT.IG_PLAYER_INVITE,
	OnAccept = function(dialog, data)
		C_PetBattles.AcceptPVPDuel();
	end,
	OnCancel = function(dialog, data)
		C_PetBattles.CancelPVPDuel();
	end,
	timeout = StaticPopupTimeoutSec,
	hideOnEscape = 1
};

StaticPopupDialogs["RECOVER_CORPSE"] = {
	StartDelay = GetCorpseRecoveryDelay,
	GetExpirationText = function(dialog, data, timeleft)
		if timeleft < 60 then
			return string.format(RECOVER_CORPSE_TIMER, timeleft, SECONDS);
		else
			return string.format(RECOVER_CORPSE_TIMER, ceil(timeleft / 60), MINUTES);
		end
	end,
	text = RECOVER_CORPSE,
	button1 = ACCEPT,
	OnAccept = function(dialog, data)
		RetrieveCorpse();
		return 1;
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
};
StaticPopupDialogs["RECOVER_CORPSE_INSTANCE"] = {
	text = RECOVER_CORPSE_INSTANCE,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1
};

StaticPopupDialogs["AREA_SPIRIT_HEAL"] = {
	text = AREA_SPIRIT_HEAL,
	GetExpirationText = GameDialogDefsUtil.GetDefaultExpirationText,
	button1 = CHOOSE_LOCATION,
	button2 = CANCEL,
	OnShow = function(dialog, data)
		dialog.timeleft = GetAreaSpiritHealerTime();
	end,
	OnAccept = function(dialog, data)
		OpenWorldMap();
		return true;	--Don't close this popup.
	end,
	OnCancel = function(dialog, data)
		CancelAreaSpiritHeal();
	end,
	DisplayButton1 = function(dialog, data)
		return IsCemeterySelectionAvailable();
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1,
	timeoutInformationalOnly = 1,
	noCancelOnReuse = 1
};

StaticPopupDialogs["BIND_ENCHANT"] = {
	text = BIND_ENCHANT,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		C_Item.BindEnchant();
	end,
	timeout = 0,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["REFUNDABLE_SOCKET"] = {
	text = END_REFUND,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		C_ItemSocketInfo.CompleteSocketing();
	end,
	timeout = 0,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ACTION_WILL_BIND_ITEM"] = {
	text = ACTION_WILL_BIND_ITEM,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		C_Item.ActionBindsItem();
	end,
	timeout = 0,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["REPLACE_ENCHANT"] = {
	text = REPLACE_ENCHANT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		C_Item.ReplaceEnchant();
	end,
	timeout = 0,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["TRADE_REPLACE_ENCHANT"] = {
	text = REPLACE_ENCHANT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		C_Item.ReplaceTradeEnchant();
	end,
	timeout = 0,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["TRADE_POTENTIAL_BIND_ENCHANT"] = {
	text = TRADE_POTENTIAL_BIND_ENCHANT,
	button1 = OKAY,
	button2 = CANCEL,
	OnShow = function(dialog, data)
		TradeFrameTradeButton:Disable();
	end,
	OnHide = function(dialog, data)
		TradeFrameTradeButton_SetToEnabledState();
	end,
	OnCancel = function(dialog, data)
		ClickTradeButton(TRADE_ENCHANT_SLOT, true);
	end,
	timeout = 0,
	showAlert = 1,
	hideOnEscape = 1,
	noCancelOnReuse = 1
};
StaticPopupDialogs["TRADE_POTENTIAL_REMOVE_TRANSMOG"] = {
	text = TRADE_POTENTIAL_REMOVE_TRANSMOG,
	button1 = OKAY,
	timeout = 0,
	showAlert = 1,
	hideOnEscape = 1,
};
StaticPopupDialogs["CONFIRM_MERCHANT_TRADE_TIMER_REMOVAL"] = {
	text = CONFIRM_MERCHANT_TRADE_TIMER_REMOVAL,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		SellCursorItem();
	end,
	OnCancel = function(dialog, data)
		ClearCursor();
	end,
	OnUpdate = function(dialog, elapsed)
		if ( not CursorHasItem() ) then
			dialog:Hide();
		end
	end,
	timeout = 0,
	showAlert = 1,
	hideOnEscape = 1,
};
StaticPopupDialogs["END_BOUND_TRADEABLE"] = {
	text = END_BOUND_TRADEABLE,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		C_Item.EndBoundTradeable(data);
	end,
	timeout = 0,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1,
};

local function GetInstanceOrGarrisonBootExpiryText(dialog, data, timeleft)
	local dialogInfo = dialog.dialogInfo;
	if GetClassicExpansionLevel() < LE_EXPANSION_WRATH_OF_THE_LICH_KING then
		if timeleft < 60 then
			return string.format(dialogInfo.text, GetBindLocation(), timeleft, SECONDS);
		else
			return string.format(dialogInfo.text, GetBindLocation(), ceil(timeleft / 60), MINUTES);
		end
	else
		return GameDialogDefsUtil.GetDefaultExpirationText(dialog, data, timeleft);
	end
end

StaticPopupDialogs["INSTANCE_BOOT"] = {
	text = INSTANCE_BOOT_TIMER,
	GetExpirationText = GetInstanceOrGarrisonBootExpiryText,
	OnShow = function(dialog, data)
		dialog.timeleft = GetInstanceBootTimeRemaining();
		if ( dialog.timeleft <= 0 ) then
			dialog:Hide();
		end
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1
};

StaticPopupDialogs["GARRISON_BOOT"] = {
	text = GARRISON_BOOT_TIMER,
	GetExpirationText = GetInstanceOrGarrisonBootExpiryText,
	OnShow = function(dialog, data)
		dialog.timeleft = GetInstanceBootTimeRemaining();
		if ( dialog.timeleft <= 0 ) then
			dialog:Hide();
		end
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1
};

function InstanceLock_OnEnter(dialogTextLabel)
	local data = dialogTextLabel:GetOwningDialogData();
	GameTooltip:SetOwner(dialogTextLabel:GetOwningDialog(), "ANCHOR_BOTTOM");

	if data.encountersComplete > 0 then
		GameTooltip:SetText(BOSSES);
		for i = 1, data.encountersTotal do
			local bossName, _, isKilled = GetInstanceLockTimeRemainingEncounter(i);
			if isKilled then
				GameTooltip:AddDoubleLine(bossName, BOSS_DEAD, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			else
				GameTooltip:AddDoubleLine(bossName, BOSS_ALIVE, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b);
			end
		end
	else
		GameTooltip:SetText(ALL_BOSSES_ALIVE);
	end

	GameTooltip:Show();
end

StaticPopupDialogs["INSTANCE_LOCK"] = {
	-- we use a custom timer called lockTimeleft in here to avoid special casing the static popup code
	-- if you use timeout or timeleft then you will go through the StaticPopup system's standard OnUpdate
	-- code which we don't want for this dialog
	text = INSTANCE_LOCK_TIMER,
	textOnEnterScript = InstanceLock_OnEnter,
	textOnLeaveScript = GameTooltip_Hide,
	button1 = ACCEPT,
	button2 = INSTANCE_LEAVE,
	OnShow = function(dialog, data)
		local lockTimeleft, isPreviousInstance = GetInstanceLockTimeRemaining();
		if ( data.enforceTime and lockTimeleft <= 0 ) then
			dialog:Hide();
			return;
		end
		dialog.lockTimeleft = lockTimeleft;
		dialog.isPreviousInstance = isPreviousInstance;

		local type, difficulty;
		dialog.name, type, difficulty, dialog.difficultyName = GetInstanceInfo();

		if ( not data.enforceTime ) then
			local name = GetDungeonNameWithDifficulty(dialog.name, dialog.difficultyName);
			local lockstring = string.format((dialog.isPreviousInstance and INSTANCE_LOCK_WARNING_PREVIOUSLY_SAVED or INSTANCE_LOCK_WARNING), name, SecondsToTime(ceil(lockTimeleft), nil, 1));
			local time, extending;
			time, extending, data.encountersTotal, data.encountersComplete = GetInstanceLockTimeRemaining();
			local bosses = string.format(BOSSES_KILLED, data.encountersComplete, data.encountersTotal);
			dialog:SetFormattedText(INSTANCE_LOCK_SEPARATOR, lockstring, bosses);
			dialog:Resize("INSTANCE_LOCK");
		end

	end,
	OnUpdate = function(dialog, elapsed)
		local enforceTime = data;
		if ( enforceTime ) then
			local lockTimeleft = dialog.lockTimeleft - elapsed;
			if ( lockTimeleft <= 0 ) then
				local OnCancel = StaticPopupDialogs["INSTANCE_LOCK"].OnCancel;
				if ( OnCancel ) then
					OnCancel(dialog, nil, "timeout");
				end
				dialog:Hide();
				return;
			end
			dialog.lockTimeleft = lockTimeleft;

			local name = GetDungeonNameWithDifficulty(dialog.name, dialog.difficultyName);

			-- Set dialog message using information that describes which bosses are still around
			local lockstring = string.format((dialog.isPreviousInstance and INSTANCE_LOCK_TIMER_PREVIOUSLY_SAVED or INSTANCE_LOCK_TIMER), name, SecondsToTime(ceil(lockTimeleft), nil, 1));
			local time, extending;
			time, extending, dialog.data.encountersTotal, dialog.data.encountersComplete = GetInstanceLockTimeRemaining();
			local bosses = string.format(BOSSES_KILLED, dialog.data.encountersComplete, dialog.data.encountersTotal);
			dialog:SetFormattedText(INSTANCE_LOCK_SEPARATOR, lockstring, bosses);

			-- make sure the dialog fits the text
			dialog:Resize("INSTANCE_LOCK");
		end
	end,
	OnAccept = function(dialog, data)
		RespondInstanceLock(true);
		dialog.name, dialog.difficultyName = nil, nil;
		dialog.lockTimeleft = nil;
	end,
	OnCancel = function(dialog, data, reason)
		if ( reason == "timeout" ) then
			dialog:Hide();
			return;
		end
		RespondInstanceLock(false);
		dialog.name, dialog.difficultyName = nil, nil;
		dialog.lockTimeleft = nil;
	end,
	DisplayButton2 = function(dialog, data)
		local enforceTime = data;
		return enforceTime ~= nil;
	end,
	timeout = 0,
	showAlert = 1,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	noCancelOnReuse = 1,
};

StaticPopupDialogs["CONFIRM_TALENT_WIPE"] = {
	text = CONFIRM_TALENT_WIPE,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		ConfirmTalentWipe();
	end,
	OnUpdate = function(dialog, elapsed)
		if ( not CheckTalentMasterDist() ) then
			dialog:Hide();
		end
	end,
	OnCancel = function(dialog, data)
		if ( PlayerTalentFrame ) then
			HideUIPanel(PlayerTalentFrame);
		end
	end,
	hasMoneyFrame = 1,
	exclusive = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_BINDER"] = {
	text = CONFIRM_BINDER,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		C_PlayerInteractionManager.ConfirmationInteraction(Enum.PlayerInteractionType.Binder);
		C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.Binder);
	end,
	OnUpdate = function(dialog, elapsed)
		if ( not C_PlayerInteractionManager.IsValidNPCInteraction(Enum.PlayerInteractionType.Binder) ) then
			C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.Binder);
			dialog:Hide();
		end
	end,
	OnCancel = function(dialog, data)
		C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.Binder);
		dialog:Hide();
	end,
	timeout = 0,
	hideOnEscape = 1
};

local function GetConfirmSummonExpiryText(dialog, data, timeleft)
	local dialogInfo = dialog.dialogInfo;
	local arg1 = C_SummonInfo.GetSummonConfirmSummoner() or "";
	local arg2 = C_SummonInfo.GetSummonConfirmAreaName();
	if timeleft < 60 then
		return string.format(dialogInfo.text, arg1, arg2, timeleft, SECONDS);
	else
		return string.format(dialogInfo.text, arg1, arg2, ceil(timeleft / 60), MINUTES);
	end
end

StaticPopupDialogs["CONFIRM_SUMMON"] = {
	text = CONFIRM_SUMMON;
	GetExpirationText = GetConfirmSummonExpiryText,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function(dialog, data)
		dialog.timeleft = C_SummonInfo.GetSummonConfirmTimeLeft();
		SetupLockOnDeclineButtonAndEscape(dialog);
	end,
	OnAccept = function(dialog, data)
		C_SummonInfo.ConfirmSummon();
	end,
	OnCancel = function(dialog, data)
		C_SummonInfo.CancelSummon();
	end,
	OnUpdate = function(dialog, elapsed)
		if ( UnitAffectingCombat("player") or (not PlayerCanTeleport()) ) then
			dialog:GetButton1():Disable();
		else
			dialog:GetButton1():Enable();
		end
	end,
	timeout = 0,
	interruptCinematic = 1,
	notClosableByLogout = 1,
};

StaticPopupDialogs["CONFIRM_SUMMON_SCENARIO"] = {
	text = CONFIRM_SUMMON_SCENARIO;
	GetExpirationText = GetConfirmSummonExpiryText,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function(dialog, data)
		dialog.timeleft = C_SummonInfo.GetSummonConfirmTimeLeft();
	end,
	OnAccept = function(dialog, data)
		C_SummonInfo.ConfirmSummon();
	end,
	OnCancel = function(dialog, data)
		C_SummonInfo.CancelSummon();
	end,
	OnUpdate = function(dialog, elapsed)
		if ( UnitAffectingCombat("player") or (not PlayerCanTeleport()) ) then
			dialog:GetButton1():Disable();
		else
			dialog:GetButton1():Enable();
		end
	end,
	timeout = 0,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1,
};

-- Summon dialog when being summoned when in a starting area
StaticPopupDialogs["CONFIRM_SUMMON_STARTING_AREA"] = {
	text = CONFIRM_SUMMON_STARTING_AREA,
	GetExpirationText = GetConfirmSummonExpiryText,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function(dialog, data)
		dialog.timeleft = C_SummonInfo.GetSummonConfirmTimeLeft();
	end,
	OnAccept = function(dialog, data)
		C_SummonInfo.ConfirmSummon();
	end,
	OnCancel = function(dialog, data)
		C_SummonInfo.CancelSummon();
	end,
	OnUpdate = function(dialog, elapsed)
		if ( UnitAffectingCombat("player") or (not PlayerCanTeleport()) ) then
			dialog:GetButton1():Disable();
		else
			dialog:GetButton1():Enable();
		end
	end,
	timeout = 0,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1,
	showAlert = 1,
};

StaticPopupDialogs["BILLING_NAG"] = {
	text = BILLING_NAG_DIALOG;
	button1 = OKAY,
	timeout = 0,
	showAlert = 1
};
StaticPopupDialogs["IGR_BILLING_NAG"] = {
	text = IGR_BILLING_NAG_DIALOG;
	button1 = OKAY,
	timeout = 0,
	showAlert = 1
};
StaticPopupDialogs["CONFIRM_LOOT_ROLL"] = {
	text = LOOT_NO_DROP,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, id, rollType)
		ConfirmLootRoll(id, rollType);
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	hideOnEscape = 1,
	showAlert = 1
};
StaticPopupDialogs["GOSSIP_CONFIRM"] = {
	text = "%s",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		C_GossipInfo.SelectOption(data, "", true);
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["GOSSIP_ENTER_CODE"] = {
	text = ENTER_CODE,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	OnAccept = function(dialog, data)
		C_GossipInfo.SelectOption(data, dialog:GetEditBox():GetText(), true);
	end,
	OnShow = function(dialog, data)
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		C_GossipInfo.SelectOption(data, editBox:GetText());
		dialog:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CREATE_COMBAT_FILTER"] = {
	text = ENTER_FILTER_NAME,
	button1 = ACCEPT,
	button2 = CANCEL,
	whileDead = 1,
	hasEditBox = 1,
	maxLetters = 32,
	OnAccept = function(dialog, data)
		CombatConfig_CreateCombatFilter(dialog:GetEditBox():GetText());
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		CombatConfig_CreateCombatFilter(editBox:GetText());
		dialog:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	OnHide = function(dialog, data)
		dialog:GetEditBox():SetText("");
	end,
	hideOnEscape = 1
};
StaticPopupDialogs["COPY_COMBAT_FILTER"] = {
	text = ENTER_FILTER_NAME,
	button1 = ACCEPT,
	button2 = CANCEL,
	whileDead = 1,
	hasEditBox = 1,
	maxLetters = 32,
	OnAccept = function(dialog, data)
		CombatConfig_CreateCombatFilter(dialog:GetEditBox():GetText(), data);
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		CombatConfig_CreateCombatFilter(editBox:GetText(), data);
		dialog:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	OnHide = function(dialog, data)
		dialog:GetEditBox():SetText("");
	end,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_COMBAT_FILTER_DELETE"] = {
	text = CONFIRM_COMBAT_FILTER_DELETE,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		CombatConfig_DeleteCurrentCombatFilter();
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_COMBAT_FILTER_DEFAULTS"] = {
	text = CONFIRM_COMBAT_FILTER_DEFAULTS,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		CombatConfig_SetCombatFiltersToDefault();
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["WOW_MOUSE_NOT_FOUND"] = {
	text = WOW_MOUSE_NOT_FOUND,
	button1 = OKAY,
	OnHide = function(dialog, data)
		SetCVar("enableWoWMouse", "0");
	end,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_BUY_STABLE_SLOT"] = {
	text = CONFIRM_BUY_STABLE_SLOT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		BuyStableSlot();
	end,
	OnShow = function(dialog, data)
		MoneyFrame_Update(dialog.MoneyFrame, GetNextStableSlotCost());
	end,
	timeout = 0,
	hideOnEscape = 1,
	hasMoneyFrame = 1,
};

StaticPopupDialogs["TALENTS_INVOLUNTARILY_RESET"] = {
	text = TALENTS_INVOLUNTARILY_RESET,
	button1 = OKAY,
	timeout = 0,
};

StaticPopupDialogs["TALENTS_INVOLUNTARILY_RESET_PET"] = {
	text = TALENTS_INVOLUNTARILY_RESET_PET,
	button1 = OKAY,
	timeout = 0,
};

StaticPopupDialogs["SPEC_INVOLUNTARILY_CHANGED"] = {
	text = SPEC_INVOLUNTARILY_CHANGED,
	button1 = OKAY,
	timeout = 0,
};

StaticPopupDialogs["VOTE_BOOT_PLAYER"] = {
	text = VOTE_BOOT_PLAYER,
	button1 = YES,
	button2 = NO,
	StartDelay = function(dialog, data)
		if (data) then
			return 0;
		else
			return 3;
		end
	end,
	OnAccept = function(dialog, data)
		SetLFGBootVote(true);
	end,
	OnCancel = function(dialog, data)
		SetLFGBootVote(false);
	end,
	showAlert = true,
	noCancelOnReuse = 1,
	whileDead = 1,
	interruptCinematic = 1,
	timeout = 0,
};

StaticPopupDialogs["VOTE_BOOT_REASON_REQUIRED"] = {
	text = VOTE_BOOT_REASON_REQUIRED,
	button1 = OKAY,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 64,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		UninviteUnit(data, editBox:GetText());
		dialog:Hide();
	end,
	EditBoxOnTextChanged = StaticPopup_StandardNonEmptyTextHandler,
	OnShow = function(dialog, data)
		dialog:GetButton1():Disable();
	end,
	OnAccept = function(dialog, data)
		UninviteUnit(data, dialog:GetEditBox():GetText());
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
};

StaticPopupDialogs["LAG_SUCCESS"] = {
	text = HELPFRAME_REPORTLAG_TEXT1,
	button1 = OKAY,
	timeout = 0,
};

StaticPopupDialogs["LFG_OFFER_CONTINUE"] = {
	text = LFG_OFFER_CONTINUE,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		PartyLFGStartBackfill();
	end,
	noCancelOnReuse = 1,
	timeout = 0,
};

StaticPopupDialogs["CONFIRM_MAIL_ITEM_UNREFUNDABLE"] = {
	text = END_REFUND,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		RespondMailLockSendItem(data.slot, true);
	end,
	OnCancel = function(dialog, data)
		RespondMailLockSendItem(data.slot, false);
	end,
	timeout = 0,
	hasItemFrame = 1,
};

StaticPopupDialogs["AUCTION_HOUSE_DISABLED"] = {
	text = ERR_AUCTION_HOUSE_DISABLED,
	button1 = OKAY,
	timeout = 0,
	showAlertGear = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_BLOCK_INVITES"] = {
	text = BLOCK_INVITES_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, inviteID)
		BNSetBlocked(inviteID, true);
		BNDeclineFriendInvite(inviteID);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["BATTLENET_UNAVAILABLE"] = {
	text = BATTLENET_UNAVAILABLE_ALERT,
	button1 = OKAY,
	timeout = 0,
	showAlertGear = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["WEB_PROXY_FAILED"] = {
	text = WEB_PROXY_FAILED,
	button1 = OKAY,
	timeout = 0,
	showAlertGear = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["WEB_ERROR"] = {
	text = WEB_ERROR,
	button1 = OKAY,
	timeout = 0,
	showAlertGear = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_REMOVE_WOW_FRIEND"] = {
	text = CONFIRM_REMOVE_WOW_FRIEND,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, contextData)
		local fullName = UnitPopupSharedUtil.GetFullPlayerName(contextData);
		if not C_FriendList.RemoveFriend(fullName) then
			UIErrorsFrame:AddExternalErrorMessage(ERR_FRIEND_NOT_FOUND);
		end
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_REMOVE_BN_FRIEND"] = {
	text = "%s",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, bnetIDAccount)
		BNRemoveFriend(bnetIDAccount);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["PICKUP_MONEY"] = {
	text = AMOUNT_TO_PICKUP,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		MoneyInputFrame_PickupPlayerMoney(dialog.MoneyInputFrame);
	end,
	OnHide = function(dialog, data)
		MoneyInputFrame_ResetMoney(dialog.MoneyInputFrame);
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent():GetParent();
		MoneyInputFrame_PickupPlayerMoney(dialog.MoneyInputFrame);
		dialog:Hide();
	end,
	hasMoneyInputFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_GUILD_CHARTER_SIGNATURE"] = {
	text = GUILD_REPUTATION_WARNING_GENERIC.."\n"..CONFIRM_CONTINUE,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		SignPetition();
	end,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_GUILD_CHARTER_PURCHASE"] = {
	text = GUILD_REPUTATION_WARNING_GENERIC.."\n"..CONFIRM_CONTINUE,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		GuildRegistrar_PurchaseCharter(true);
	end,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["GUILD_DEMOTE_CONFIRM"] = {
	text = "%s",
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		C_GuildInfo.Demote(data);
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["GUILD_PROMOTE_CONFIRM"] = {
	text = "%s",
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		C_GuildInfo.Promote(data);
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_RANK_AUTHENTICATOR_REMOVE"] = {
	text = "%s",
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		local checkbox = data;
		checkbox:SetChecked(false);
		GuildControlUI_CheckClicked(checkbox);
	end,
	timeout = 0,
	showAlert = 1,
	hideOnEscape = 1,
	whileDead = 1,
};
StaticPopupDialogs["VOID_DEPOSIT_CONFIRM"] = {
	text = VOID_STORAGE_DEPOSIT_CONFIRMATION.."\n"..CONFIRM_CONTINUE,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		VoidStorage_UpdateTransferButton();
	end,
	OnCancel = function(dialog, data)
		VoidStorage_CloseConfirmationDialog(data.slot);
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
	hasItemFrame = 1
};

StaticPopupDialogs["GUILD_IMPEACH"] = {
	text = GUILD_IMPEACH_POPUP_TEXT ,
	button1 = GUILD_IMPEACH_POPUP_CONFIRM,
	button2 = CANCEL,
	OnAccept = function(dialog, data) ReplaceGuildMaster(); end,
	OnCancel = function(dialog, data) end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
};

local SpellConfirmationFormatter = CreateFromMixins(SecondsFormatterMixin);
SpellConfirmationFormatter:Init(0, SecondsFormatter.Abbreviation.None, true, true);

StaticPopupDialogs["SPELL_CONFIRMATION_PROMPT"] = {
	GetExpirationText = function(dialog, data, timeleft)
		local dialogInfo = dialog.dialogInfo;
		local time = SpellConfirmationFormatter:Format(timeleft);
		return dialogInfo.text .. " " ..TIME_REMAINING .. " " .. time;
	end,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		AcceptSpellConfirmationPrompt(data);
	end,
	OnCancel = function(dialog, data)
		DeclineSpellConfirmationPrompt(data);
	end,
	exclusive = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["SPELL_CONFIRMATION_WARNING"] = {
	button1 = OKAY,
	OnAccept = function(dialog, data)
		AcceptSpellConfirmationPrompt(data);
	end,
	exclusive = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_LAUNCH_URL"] = {
	text = CONFIRM_LAUNCH_URL,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data) LoadURLIndex(data.index, data.mapID); end,
	hideOnEscape = 1,
	timeout = 0,
};

StaticPopupDialogs["CONFIRM_LEAVE_INSTANCE_PARTY"] = {
	text = "%s",
	button1 = YES,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		if ( IsInGroup(LE_PARTY_CATEGORY_INSTANCE) ) then
			LeaveInstanceParty();
		end
	end,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,
};

StaticPopupDialogs["CONFIRM_SURRENDER_ARENA"] = {
	text = CONFIRM_SURRENDER_ARENA,
	button1 = YES,
	button2 = CANCEL,
	OnShow = function(dialog, data)
		dialog:SetText(CONFIRM_SURRENDER_ARENA);
	end,
	OnAccept = function(dialog, data)
		SurrenderArena();
	end,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,
};

StaticPopupDialogs["SAVED_VARIABLES_TOO_LARGE"] = {
	text = SAVED_VARIABLES_TOO_LARGE,
	button1 = OKAY,
	timeout = 0,
	showAlertGear = 1,
	hideOnEscape = 1,
	whileDead = 1,
};

StaticPopupDialogs["PRODUCT_ASSIGN_TO_TARGET_FAILED"] = {
	text = PRODUCT_CLAIMING_FAILED,
	button1 = OKAY,
	timeout = 0,
	showAlertGear = 1,
	whileDead = 1,
};

StaticPopupDialogs["BATTLEFIELD_BORDER_WARNING"] = {
	text = "",
	OnShow = function(dialog, data)
		dialog.timeleft = data.timer;
	end,
	OnUpdate = function(dialog, elapsed, data)
		dialog:SetFormattedText(BATTLEFIELD_BORDER_WARNING, data.name, SecondsToTime(dialog.timeleft, false, true));
		dialog:Resize("BATTLEFIELD_BORDER_WARNING");
	end,
	nobuttons = 1,
	timeout = 0,
	whileDead = 1,
	closeButton = true,
};

StaticPopupDialogs["LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS"] = {
	text = LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS,
	button1 = OKAY,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["LFG_LIST_ENTRY_EXPIRED_TIMEOUT"] = {
	text = LFG_LIST_ENTRY_EXPIRED_TIMEOUT,
	button1 = OKAY,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["NAME_TRANSMOG_OUTFIT"] = {
	text = TRANSMOG_OUTFIT_NAME,
	button1 = SAVE,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		WardrobeOutfitManager:NameOutfit(dialog:GetEditBox():GetText(), data);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 31,
	OnShow = function(dialog, data)
		dialog:GetButton1():Disable();
		dialog:GetButton2():Enable();
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		dialog:GetEditBox():SetText("");
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		if ( editBox:GetParent():GetButton1():IsEnabled() ) then
			StaticPopup_OnClick(editBox:GetParent(), 1);
		end
	end,
	EditBoxOnTextChanged = StaticPopup_StandardNonEmptyTextHandler,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
};

StaticPopupDialogs["CONFIRM_OVERWRITE_TRANSMOG_OUTFIT"] = {
	text = TRANSMOG_OUTFIT_CONFIRM_OVERWRITE,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data) WardrobeOutfitManager:OverwriteOutfit(data.outfitID) end,
	OnCancel = function(dialog, data)
		local name = data.name;
		dialog:Hide();
		local outfitDialog = StaticPopup_Show("NAME_TRANSMOG_OUTFIT");
		if ( outfitDialog ) then
			dialog:GetEditBox():SetText(name);
		end
	end,
	hideOnEscape = 1,
	timeout = 0,
	whileDead = 1,
	noCancelOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_DELETE_TRANSMOG_OUTFIT"] = {
	text = TRANSMOG_OUTFIT_CONFIRM_DELETE,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		C_TransmogCollection.DeleteOutfit(data);
	end,
	OnCancel = function(dialog, data) end,
	hideOnEscape = 1,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["TRANSMOG_OUTFIT_CHECKING_APPEARANCES"] = {
	text = TRANSMOG_OUTFIT_CHECKING_APPEARANCES,
	button1 = CANCEL,
	hideOnEscape = 1,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["TRANSMOG_OUTFIT_ALL_INVALID_APPEARANCES"] = {
	text = TRANSMOG_OUTFIT_ALL_INVALID_APPEARANCES,
	button1 = OKAY,
	hideOnEscape = 1,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["TRANSMOG_OUTFIT_SOME_INVALID_APPEARANCES"] = {
	text = TRANSMOG_OUTFIT_SOME_INVALID_APPEARANCES,
	button1 = SAVE,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		WardrobeOutfitManager:ContinueWithSave();
	end,
	hideOnEscape = 1,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["TRANSMOG_APPLY_WARNING"] = {
	text = "%s",
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		return WardrobeTransmogFrame:ApplyPending(data.warningIndex);
	end,
	OnHide = function(dialog, data)
		WardrobeTransmogFrame:UpdateApplyButton();
	end,
	timeout = 0,
	hideOnEscape = 1,
	hasItemFrame = 1,
};

StaticPopupDialogs["TRANSMOG_FAVORITE_WARNING"] = {
	text = TRANSMOG_FAVORITE_LOSE_REFUND_AND_TRADE,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		local setFavorite = true;
		local confirmed = true;
		WardrobeCollectionFrameModelDropdown_SetFavorite(data, setFavorite, confirmed);
	end,
	timeout = 0,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_UNLOCK_TRIAL_CHARACTER"] = {
	text = CHARACTER_UPGRADE_FINISH_BUTTON_POPUP_TEXT,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		ClassTrialThanksForPlayingDialog:ConfirmCharacterBoost(data.guid, data.boostType);
	end,
	OnCancel = function(dialog, data)
		ClassTrialThanksForPlayingDialog:ShowThanks();
	end,
	timeout = 0,
	whileDead = 1,
	fullScreenCover = true,
};

StaticPopupDialogs["DANGEROUS_SCRIPTS_WARNING"] = {
	text = DANGEROUS_SCRIPTS_WARNING,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		SetAllowDangerousScripts(true);
	end,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
};

StaticPopupDialogs["EXPERIMENTAL_CVAR_WARNING"] = {
	text = EXPERIMENTAL_FEATURE_TURNED_ON_WARNING,
	button1 = ACCEPT,
	button2 = DISABLE,
	OnCancel = function(dialog, data)
		ResetTestCvars();
	end,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
};

StaticPopupDialogs["PREMADE_GROUP_SEARCH_DELIST_WARNING"] = {
	text = PREMADE_GROUP_SEARCH_DELIST_WARNING_TEXT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		LFGListFrame_BeginFindQuestGroup(LFGListFrame, data);
	end,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["PREMADE_GROUP_INSECURE_SEARCH"] = {
	text = PREMADE_GROUP_INSECURE_SEARCH,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		LFGListFrame_BeginFindQuestGroup(LFGListFrame, data);
	end,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["BACKPACK_INCREASE_SIZE"] = {
	text = BACKPACK_AUTHENTICATOR_DIALOG_DESCRIPTION,
	button1 = ACTIVATE,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		LoadURLIndex(41);
	end,
	--OnHide OVERRIDEN
	wide = true,
	timeout = 0,
	whileDead = 0,
};

StaticPopupDialogs["GROUP_FINDER_AUTHENTICATOR_POPUP"] = {
	text = GROUP_FINDER_AUTHENTICATOR_POPUP_DESC,
	button1 = ACTIVATE,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		LoadURLIndex(41);
	end,
	wide = true,
	timeout = 0,
	whileDead = 0,
};
StaticPopupDialogs["CLIENT_INVENTORY_FULL_OVERFLOW"] = {
	text = BACKPACK_AUTHENTICATOR_FULL_INVENTORY,
	button1 = OKAY,
	hideOnEscape = 1,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
};

StaticPopupDialogs["AUCTION_HOUSE_DEPRECATED"] = {
	text = AUCTION_HOUSE_DEPRECATED,
	button1 = OKAY,
	hideOnEscape = 1,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
};

StaticPopupDialogs["REGIONAL_CHAT_DISABLED"] = {
	text = REGIONAL_RESTRICT_CHAT_DIALOG_TITLE,
	subText = REGIONAL_RESTRICT_CHAT_DIALOG_MESSAGE,
	button1 = REGIONAL_RESTRICT_CHAT_DIALOG_ENABLE,
	button2 = REGIONAL_RESTRICT_CHAT_DIALOG_DISABLE,
	OnAccept = function(dialog, data)
		Settings.OpenToCategory(Settings.SOCIAL_CATEGORY_ID);
	end,
	OnShow = function(dialog, data)
		C_SocialRestrictions.AcknowledgeRegionalChatDisabled();
	end,
	timeout = 0,
	hideOnEscape = false,
	exclusive = 1,
};

StaticPopupDialogs["CHAT_CONFIG_DISABLE_CHAT"] = {
	text = RESTRICT_CHAT_CONFIG_DIALOG_MESSAGE,
	button1 = RESTRICT_CHAT_CONFIG_DIALOG_DISABLE,
	button2 = RESTRICT_CHAT_CONFIG_DIALOG_CANCEL,
	OnAccept = function(dialog, data)
		local disabled = true;
		C_SocialRestrictions.SetChatDisabled(disabled);
		ChatConfigFrame_OnChatDisabledChanged(disabled);
	end,
	timeout = 0,
	exclusive = 1,
};
