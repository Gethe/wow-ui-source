STATICPOPUP_NUMDIALOGS = 4;

StaticPopupDialogs = { };

StaticPopupDialogs["CONFIRM_RESET_SETTINGS"] = { 
	text = CONFIRM_RESET_SETTINGS,
	button1 = ALL_SETTINGS,
	button3 = CURRENT_SETTINGS,
	button2 = CANCEL,
	OnAccept = InterfaceOptionsFrame_SetAllToDefaults,
	OnAlt = InterfaceOptionsFrame_SetCurrentToDefaults,
	OnCancel = function() end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	whileDead = 1,
}

StaticPopupDialogs["CONFIRM_PURCHASE_TOKEN_ITEM"] = {
	text = CONFIRM_PURCHASE_TOKEN_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		BuyMerchantItem(MerchantFrame.itemIndex, MerchantFrame.count);
	end,
	OnCancel = function()
	
	end,
	OnShow = function()
	
	end,
	OnHide = function()
	
	end,
	timeout = 0,
	hideOnEscape = 1,
	hasItemFrame = 1,
}

StaticPopupDialogs["CONFIRM_COMPLETE_EXPENSIVE_QUEST"] = {
	text = CONFIRM_COMPLETE_EXPENSIVE_QUEST,
	button1 = COMPLETE_QUEST,
	button2 = CANCEL,
	OnAccept = function()
		GetQuestReward(QuestFrameRewardPanel.itemChoice);
		PlaySound("igQuestListComplete");
	end,
	OnCancel = function() 
		DeclineQuest();
		PlaySound("igQuestCancel");
	end,
	OnShow = function()
		QuestFrameCompleteQuestButton:Disable();
		QuestFrameCancelButton:Disable();
	end,
	OnHide = function()
		QuestFrameCancelButton:Enable();
	end,
	timeout = 0,
	hideOnEscape = 1,
	hasMoneyFrame = 1,
};
StaticPopupDialogs["USE_GUILDBANK_REPAIR"] = {
	text = USE_GUILDBANK_REPAIR,
	button1 = USE_PERSONAL_FUNDS,
	button2 = OKAY,
	OnAccept = function()
		RepairAllItems();
		PlaySound("ITEM_REPAIR");
	end,
	OnCancel = function ()
		RepairAllItems(1);
		PlaySound("ITEM_REPAIR");
	end,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["GUILDBANK_WITHDRAW"] = {
	text = GUILDBANK_WITHDRAW,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		local moneyInputFrame = getglobal(this:GetParent():GetName().."MoneyInputFrame");
		WithdrawGuildBankMoney(MoneyInputFrame_GetCopper(moneyInputFrame));
	end,
	OnHide = function()
		MoneyInputFrame_ResetMoney(getglobal(this:GetName().."MoneyInputFrame"));
	end,
	EditBoxOnEnterPressed = function()
		WithdrawGuildBankMoney(MoneyInputFrame_GetCopper(this:GetParent()));
		this:GetParent():GetParent():Hide();
	end,
	hasMoneyInputFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["GUILDBANK_DEPOSIT"] = {
	text = GUILDBANK_DEPOSIT,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		local moneyInputFrame = getglobal(this:GetParent():GetName().."MoneyInputFrame");
		DepositGuildBankMoney(MoneyInputFrame_GetCopper(moneyInputFrame));
	end,
	OnHide = function()
		MoneyInputFrame_ResetMoney(getglobal(this:GetName().."MoneyInputFrame"));
	end,
	EditBoxOnEnterPressed = function()
		DepositGuildBankMoney(MoneyInputFrame_GetCopper(this:GetParent()));
		this:GetParent():GetParent():Hide();
	end,
	hasMoneyInputFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_BUY_GUILDBANK_TAB"] = {
	text = CONFIRM_BUY_GUILDBANK_TAB,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		BuyGuildBankTab();
	end,
	OnShow = function()
		MoneyFrame_Update(this:GetName().."MoneyFrame", GetGuildBankTabCost());
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["TOO_MANY_LUA_ERRORS"] = {
	text = TOO_MANY_LUA_ERRORS,
	button1 = DISABLE_ADDONS,
	button2 = IGNORE,
	OnAccept = function()
		DisableAllAddOns();
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
	OnAccept = function()
		AcceptSockets();
		PlaySound("JewelcraftingFinalize");
	end,
	timeout = 0,
	showAlert = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["TAKE_GM_SURVEY"] = {
	text = TAKE_GM_SURVEY,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		GMSurveyFrame_LoadUI();
		ShowUIPanel(GMSurveyFrame);
		TicketStatusFrame:Hide();
	end,
	OnCancel = function()
		TicketStatusFrame.hasGMSurvey = nil;
		TicketStatusFrame:Hide();
	end,
	timeout = 0,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_RESET_INSTANCES"] = {
	text = CONFIRM_RESET_INSTANCES,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		ResetInstances();
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_GUILD_DISBAND"] = {
	text = CONFIRM_GUILD_DISBAND,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		GuildDisband();
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_BUY_BANK_SLOT"] = {
	text = CONFIRM_BUY_BANK_SLOT,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		PurchaseSlot();
	end,
	OnShow = function()
		MoneyFrame_Update(this:GetName().."MoneyFrame", BankFrame.nextSlotCost);
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
	button2 = IGNORE,
	OnAccept = function(data)
		DisableAddOn(data);
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
	OnAccept = function(data)
		GiveMasterLoot(LootFrame.selectedSlot, data);
	end,
	timeout = 0,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"] = {
	text = CONFIRM_BATTLEFIELD_ENTRY,
	button1 = ENTER_BATTLE,
	button2 = HIDE,
	OnAccept = function(data)
		if ( not AcceptBattlefieldPort(data, 1) ) then
			return 1;
		end
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	multiple = 1
};

StaticPopupDialogs["CONFIRM_GUILD_LEAVE"] = {
	text = CONFIRM_GUILD_LEAVE,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		GuildLeave();
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_GUILD_PROMOTE"] = {
	text = CONFIRM_GUILD_PROMOTE,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(name)
		GuildSetLeader(name);
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
	OnAccept = function()
		local text = getglobal(this:GetParent():GetName().."EditBox"):GetText();
		RenamePetition(text);
	end,
	EditBoxOnEnterPressed = function()
		local text = getglobal(this:GetParent():GetName().."EditBox"):GetText();
		RenamePetition(text);
		this:GetParent():Hide();
	end,
	OnShow = function()
		getglobal(this:GetName().."EditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["RENAME_ARENA_TEAM"] = {
	text = RENAME_ARENA_TEAM_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 24,
	OnAccept = function()
		local text = getglobal(this:GetParent():GetName().."EditBox"):GetText();
		RenamePetition(text);
	end,
	EditBoxOnEnterPressed = function()
		local text = getglobal(this:GetParent():GetName().."EditBox"):GetText();
		RenamePetition(text);
		this:GetParent():Hide();
	end,
	OnShow = function()
		getglobal(this:GetName().."EditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_TEAM_LEAVE"] = {
	text = CONFIRM_TEAM_LEAVE,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		ArenaTeamLeave(PVPTeamDetails.team);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_TEAM_PROMOTE"] = {
	text = CONFIRM_TEAM_PROMOTE,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(team, name)
		ArenaTeamSetLeaderByName(team, name);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_TEAM_KICK"] = {
	text = CONFIRM_TEAM_KICK,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(team, name)
		ArenaTeamUninviteByName(team, name);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["HELP_TICKET_QUEUE_DISABLED"] = {
	text = HELP_TICKET_QUEUE_DISABLED,
	button1 = OKAY,
	showAlert = 1,
	timeout = 0,
}

StaticPopupDialogs["CLIENT_RESTART_ALERT"] = {
	text = CLIENT_RESTART_ALERT,
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
	OnAccept = function()
		TakeInboxItem(InboxFrame.openMailID, OpenMailFrame.lastTakeAttachment);
	end,
	OnShow = function()
		MoneyFrame_Update(this:GetName().."MoneyFrame", OpenMailFrame.cod);
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["DELETE_MAIL"] = {
	text = DELETE_MAIL_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
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
	OnAccept = function()
		DeleteInboxItem(InboxFrame.openMailID);
		InboxFrame.openMailID = nil;
		HideUIPanel(OpenMailFrame);
	end,
	OnShow = function()
		MoneyFrame_Update(this:GetName().."MoneyFrame", OpenMailFrame.money);
	end,
	hasMoneyFrame = 1,
	showAlert = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["SEND_MONEY"] = {
	text = SEND_MONEY_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		if ( SetSendMailMoney(MoneyInputFrame_GetCopper(SendMailMoney)) ) then
			SendMailFrame_SendMail();
		end
	end,
	OnCancel = function()
		SendMailMailButton:Enable();
	end,
	OnShow = function()
		MoneyFrame_Update(this:GetName().."MoneyFrame", MoneyInputFrame_GetCopper(SendMailMoney));
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_REPORT_SPAM_CHAT"] = {
	text = REPORT_SPAM_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(lineID)
		ComplainChat(lineID);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_REPORT_SPAM_MAIL"] = {
	text = REPORT_SPAM_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(index)
		ComplainInboxItem(index);
	end,
	OnCancel = function(index)
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
	OnAccept = function()
		local channel = getglobal(this:GetParent():GetName().."EditBox"):GetText();
		JoinPermanentChannel(channel, nil, FCF_GetCurrentChatFrameID(), 1);
		ChatFrame_AddChannel(FCF_GetCurrentChatFrame(), channel);
		getglobal(this:GetParent():GetName().."EditBox"):SetText("");
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function()
		local channel = getglobal(this:GetParent():GetName().."EditBox"):GetText();
		JoinPermanentChannel(channel, nil, FCF_GetCurrentChatFrameID(), 1);
		ChatFrame_AddChannel(FCF_GetCurrentChatFrame(), channel);
		getglobal(this:GetParent():GetName().."EditBox"):SetText("");
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	hideOnEscape = 1
};

StaticPopupDialogs["CHANNEL_INVITE"] = {
	text = CHANNEL_INVITE,
	button1 = ACCEPT_ALT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	whileDead = 1,
	OnHide = function()
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	OnAccept = function(data)
		local name = getglobal(this:GetParent():GetName().."EditBox"):GetText();
		ChannelInvite(data, name);
		getglobal(this:GetParent():GetName().."EditBox"):SetText("");
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(data)
		local name = getglobal(this:GetParent():GetName().."EditBox"):GetText();
		ChannelInvite(data, name);
		getglobal(this:GetParent():GetName().."EditBox"):SetText("");
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	hideOnEscape = 1
};

StaticPopupDialogs["CHANNEL_PASSWORD"] = {
	text = CHANNEL_PASSWORD,
	button1 = ACCEPT_ALT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	whileDead = 1,
	OnHide = function()
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	OnAccept = function(data)
		local password = getglobal(this:GetParent():GetName().."EditBox"):GetText();
		SetChannelPassword(data, password);
		getglobal(this:GetParent():GetName().."EditBox"):SetText("");
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(data)
		local password = getglobal(this:GetParent():GetName().."EditBox"):GetText();
		SetChannelPassword(data, password);
		getglobal(this:GetParent():GetName().."EditBox"):SetText("");
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	hideOnEscape = 1
};

StaticPopupDialogs["NAME_CHAT"] = {
	text = NAME_CHAT_WINDOW,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	whileDead = 1,
	OnAccept = function(renameID)
		local name = getglobal(this:GetParent():GetName().."EditBox"):GetText();
		if ( renameID ) then
			FCF_SetWindowName(getglobal("ChatFrame"..renameID), name);
		else
			FCF_OpenNewWindow(name);
		end
		getglobal(this:GetParent():GetName().."EditBox"):SetText("");
		FCF_DockUpdate();
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(renameID)
		local name = getglobal(this:GetParent():GetName().."EditBox"):GetText();
		if ( renameID ) then
			FCF_SetWindowName(getglobal("ChatFrame"..renameID), name);
		else
			FCF_OpenNewWindow(name);
		end
		getglobal(this:GetParent():GetName().."EditBox"):SetText("");
		FCF_DockUpdate();
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function ()
		this:GetParent():Hide();
	end,
	hideOnEscape = 1
};

StaticPopupDialogs["RESET_CHAT"] = {
	text = RESET_CHAT_WINDOW,
	button1 = ACCEPT,
	button2 = CANCEL,
	whileDead = 1,
	OnAccept = function()
		FCF_ResetChatWindows();
		if ( ChatConfigFrame:IsShown() ) then
			ChatConfig_UpdateChatSettings();
		end
	end,
	timeout = 0,
	EditBoxOnEscapePressed = function ()
		this:GetParent():Hide();
	end,
	hideOnEscape = 1
};

StaticPopupDialogs["HELP_TICKET_ABANDON_CONFIRM"] = {
	text = HELP_TICKET_ABANDON_CONFIRM,
	button1 = YES,
	button2 = NO,
	OnAccept = function(prevFrame)
		DeleteGMTicket();
	end,
	OnCancel = function(prevFrame)
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}
StaticPopupDialogs["HELP_TICKET"] = {
	text = HELP_TICKET_EDIT_ABANDON,
	button1 = HELP_TICKET_EDIT,
	button2 = HELP_TICKET_ABANDON,
	OnAccept = function()
		if ( PETITION_QUEUE_ACTIVE ) then
			ShowUIPanel(HelpFrame);
			HelpFrame_ShowFrame("OpenTicket");
		else
			HideUIPanel(HelpFrame);
			StaticPopup_Show("HELP_TICKET_QUEUE_DISABLED");
		end
	end,
	OnCancel = function()
		local currentFrame = this:GetParent();
		local dialogFrame = StaticPopup_Show("HELP_TICKET_ABANDON_CONFIRM");
		dialogFrame.data = currentFrame;
	end,
	timeout = 0,
	whileDead = 1
}
StaticPopupDialogs["PETRENAMECONFIRM"] = {
	text = PET_RENAME_CONFIRMATION,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		PetRename(this:GetParent().data);
	end,
	OnUpdate = function(elapsed, dialog)
		if ( not UnitExists("pet") ) then
			dialog:Hide();
		end
	end,
	timeout = 0,
	hideOnEscape = 1
}
StaticPopupDialogs["DEATH"] = {
	text = DEATH_RELEASE_TIMER,
	button1 = DEATH_RELEASE,
	button2 = USE_SOULSTONE,
	OnShow = function()
		this.timeleft = GetReleaseTimeRemaining();
		local text = HasSoulstone();
		if ( text ) then
			getglobal(this:GetName().."Button2"):SetText(text);
		end

		if ( IsActiveBattlefieldArena() ) then
			getglobal(this:GetName().."Text"):SetText(DEATH_RELEASE_SPECTATOR);
		elseif ( this.timeleft == -1 ) then
			getglobal(this:GetName().."Text"):SetText(DEATH_RELEASE_NOTIMER);
		end
	end,
	OnAccept = function()
		if ( IsActiveBattlefieldArena() ) then
			local info = ChatTypeInfo["SYSTEM"];
			DEFAULT_CHAT_FRAME:AddMessage(ARENA_SPECTATOR, info.r, info.g, info.b, info.id);
		end
		RepopMe();
	end,
	OnCancel = function(data, reason)
		if ( reason == "override" ) then
			return;
		end
		if ( reason == "timeout" ) then
			return;
		end
		if ( reason == "clicked" ) then
			if ( HasSoulstone() ) then
				UseSoulstone();
			else
				RepopMe();
			end
		end
	end,
	OnUpdate = function(elapsed, dialog)
		local button1 = getglobal(dialog:GetName().."Button1");
		local button2 = getglobal(dialog:GetName().."Button2");
		if ( IsFalling() and (not IsOutOfBounds()) ) then
			button1:Disable();
			button2:Disable();
		else
			button1:Enable();
			button2:Enable();
		end
	end,
	DisplayButton2 = function()
		return HasSoulstone();
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	cancels = "RECOVER_CORPSE"
};
StaticPopupDialogs["RESURRECT"] = {
	StartDelay = GetCorpseRecoveryDelay,
	delayText = RESURRECT_REQUEST_TIMER,
	text = RESURRECT_REQUEST,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnShow = function()
		this.timeleft = GetCorpseRecoveryDelay() + 60;
	end,
	OnAccept = function()
		AcceptResurrect();
	end,
	OnCancel = function()
		DeclineResurrect();
		if ( UnitIsDead("player") ) then
			StaticPopup_Show("DEATH");
		end
	end,
	timeout = 60,
	whileDead = 1,
	cancels = "DEATH",
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["RESURRECT_NO_SICKNESS"] = {
	StartDelay = GetCorpseRecoveryDelay,
	delayText = RESURRECT_REQUEST_NO_SICKNESS_TIMER,
	text = RESURRECT_REQUEST_NO_SICKNESS,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnShow = function()
		this.timeleft = GetCorpseRecoveryDelay() + 60;
	end,
	OnAccept = function()
		AcceptResurrect();
	end,
	OnCancel = function()
		DeclineResurrect();
		if ( UnitIsDead("player") ) then
			StaticPopup_Show("DEATH");
		end
	end,
	timeout = 60,
	whileDead = 1,
	cancels = "DEATH",
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["RESURRECT_NO_TIMER"] = {
	text = RESURRECT_REQUEST_NO_SICKNESS,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnShow = function()
		this.timeleft = GetCorpseRecoveryDelay() + 60;
	end,
	OnAccept = function()
		AcceptResurrect();
	end,
	OnCancel = function()
		DeclineResurrect();
		if ( UnitIsDead("player") ) then
			StaticPopup_Show("DEATH");
		end
	end,
	timeout = 60,
	whileDead = 1,
	cancels = "DEATH",
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1
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
	OnAccept = function()
		StaticPopup_Hide("RESURRECT");
		StaticPopup_Hide("RESURRECT_NO_SICKNESS");
		StaticPopup_Hide("RESURRECT_NO_TIMER");
		RepopMe();
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1	
};
StaticPopupDialogs["TRADE"] = {
	text = TRADE_WITH_QUESTION,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		BeginTrade();
	end,
	OnCancel = function()
		CancelTrade();
	end,
	timeout = 60,
	hideOnEscape = 1
};
StaticPopupDialogs["PARTY_INVITE"] = {
	text = INVITATION,
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = "igPlayerInvite",
	OnShow = function()
		StaticPopupDialogs["PARTY_INVITE"].inviteAccepted = nil;
	end,
	OnAccept = function()
		AcceptGroup();
		StaticPopupDialogs["PARTY_INVITE"].inviteAccepted = 1;
	end,
	OnCancel = function()
		DeclineGroup();
	end,
	OnHide = function()
		if ( not StaticPopupDialogs["PARTY_INVITE"].inviteAccepted ) then
			DeclineGroup();
			this:Hide();
		end
	end,
	timeout = 60,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["GUILD_INVITE"] = {
	text = GUILD_INVITATION,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnAccept = function()
		AcceptGuild();
	end,
	OnCancel = function()
		DeclineGuild();
	end,
	timeout = 60,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["CHAT_CHANNEL_INVITE"] = {
	text = CHAT_INVITE_NOTICE_POPUP,
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = "igPlayerInvite",
	OnShow = function()
		StaticPopupDialogs["CHAT_CHANNEL_INVITE"].inviteAccepted = nil;
	end,
	OnAccept = function(data)
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
	EditBoxOnEnterPressed = function(data)
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
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function(data)
		this:GetParent():Hide();
	end,
	OnHide = function(data)
		local name = data;
		DeclineInvite(name);
	end,
	timeout = 60,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["LEVEL_GRANT_PROPOSED"] = {
	text = LEVEL_GRANT,
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = "igPlayerInvite",
	OnAccept = function()
		AcceptLevelGrant();
	end,
	OnCancel = function()
		DeclineLevelGrant();
	end,
	OnHide = function()
		DeclineLevelGrant();
	end,
	timeout = 60,
	whileDead = 1,
	hideOnEscape = 1
};

function ChatChannelPasswordHandler(data)
	local password = getglobal(this:GetParent():GetName().."EditBox"):GetText();
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
	sound = "igPlayerInvite",
	OnAccept = function(data)
		ChatChannelPasswordHandler(data);
	end,
	EditBoxOnEnterPressed = function(data)
		ChatChannelPasswordHandler(data);
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	timeout = 60,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["LFG_MATCH"] = {
	text = MATCHMAKING_MATCH_S,
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = "igPlayerInvite",
	OnShow = function()
		StaticPopupDialogs["LFG_MATCH"].inviteAccepted = nil;
	end,
	OnAccept = function()
		AcceptLFGMatch();
		StaticPopupDialogs["LFG_MATCH"].inviteAccepted = 1;
	end,
	OnCancel = function()
		DeclineLFGMatch();
	end,
	OnHide = function()
		if ( not StaticPopupDialogs["LFG_MATCH"].inviteAccepted ) then
			DeclineLFGMatch();
		end
	end,
	timeout = 60,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["LFG_PENDING"] = {
	text = MATCHMAKING_PENDING,
	button1 = CANCEL,
	OnAccept = function()
		CancelPendingLFG();
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["ARENA_TEAM_INVITE"] = {
	text = ARENA_TEAM_INVITATION,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnAccept = function()
		AcceptArenaTeam();
	end,
	OnCancel = function()
		DeclineArenaTeam();
	end,
	timeout = 60,
	whileDead = 1,
	hideOnEscape = 1
};


StaticPopupDialogs["CAMP"] = {
	text = CAMP_TIMER,
	button1 = CANCEL,
	--button2 = CAMP_NOW,
	OnAccept = function()
		CancelLogout();
		--ForceLogout();
		-- uncomment the next line once forced logouts are completely implemented (they currently have a failure case)
		-- this.timeleft = 0;
	end,
	OnHide = function()
		if ( this.timeleft > 0 ) then
			CancelLogout();
			this:Hide();
		end
	end,
	timeout = 20,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["QUIT"] = {
	text = QUIT_TIMER,
	button1 = QUIT_NOW,
	button2 = CANCEL,
	OnAccept = function()
		ForceQuit();
		this.timeleft = 0;
	end,
	OnHide = function()
		if ( this.timeleft > 0 ) then
			CancelLogout();
			this:Hide();
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
	OnAccept = function(slot)
		ConfirmLootSlot(slot);
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["EQUIP_BIND"] = {
	text = EQUIP_NO_DROP,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(slot)
		EquipPendingItem(slot);
	end,
	OnCancel = function(slot)
		CancelPendingEquip(slot);
	end,
	OnHide = function(slot)
		CancelPendingEquip(slot);
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["AUTOEQUIP_BIND"] = {
	text = EQUIP_NO_DROP,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(slot)
		EquipPendingItem(slot);
	end,
	OnCancel = function(slot)
		CancelPendingEquip(slot);
	end,
	OnHide = function(slot)
		CancelPendingEquip(slot);
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["USE_BIND"] = {
	text = USE_NO_DROP,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		ConfirmBindOnUse();
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["DELETE_ITEM"] = {
	text = DELETE_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		DeleteCursorItem();
	end,
	OnCancel = function ()
		ClearCursor();
	end,
	OnUpdate = function ()
		if ( not CursorHasItem() ) then
			StaticPopup_Hide("DELETE_ITEM");
		end
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["DELETE_GOOD_ITEM"] = {
	text = DELETE_GOOD_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		DeleteCursorItem();
	end,
	OnCancel = function ()
		ClearCursor();
	end,
	OnUpdate = function ()
		if ( not CursorHasItem() ) then
			StaticPopup_Hide("DELETE_GOOD_ITEM");
		end
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 32,
	OnShow = function()
		getglobal(this:GetName().."Button1"):Disable();
		getglobal(this:GetName().."EditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	EditBoxOnEnterPressed = function()
		if ( getglobal(this:GetParent():GetName().."Button1"):IsEnabled() == 1 ) then
			DeleteCursorItem();
			this:GetParent():Hide();
		end
	end,
	EditBoxOnTextChanged = function ()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		if ( strupper(editBox:GetText()) ==  DELETE_ITEM_CONFIRM_STRING ) then
			getglobal(this:GetParent():GetName().."Button1"):Enable();
		else
			getglobal(this:GetParent():GetName().."Button1"):Disable();
		end
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
		ClearCursor();
	end
};
StaticPopupDialogs["QUEST_ACCEPT"] = {
	text = QUEST_ACCEPT,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
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
	OnShow = function()
		getglobal(this:GetName().."Button1"):Disable();
	end,
	OnAccept = function()
		ConfirmAcceptQuest();
	end,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["ABANDON_PET"] = {
	text = ABANDON_PET,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		PetAbandon();
	end,
	OnUpdate = function(elapsed, dialog)
		if ( not UnitExists("pet") ) then
			dialog:Hide();
		end
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ABANDON_QUEST"] = {
	text = ABANDON_QUEST_CONFIRM,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		AbandonQuest();
		PlaySound("igQuestLogAbandonQuest");
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ABANDON_QUEST_WITH_ITEMS"] = {
	text = ABANDON_QUEST_CONFIRM_WITH_ITEMS,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		AbandonQuest();
		PlaySound("igQuestLogAbandonQuest");
	end,
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
	maxLetters = 12,
	OnAccept = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		AddFriend(editBox:GetText());
	end,
	OnShow = function()
		getglobal(this:GetName().."EditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		AddFriend(editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
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
	hasWideEditBox = 1,
	OnAccept = function()
		local editBox = getglobal(this:GetParent():GetName().."WideEditBox");
		SetFriendNotes(FriendsFrame.NotesID, editBox:GetText());
	end,
	OnShow = function()
		local name, level, class, area, connected, status, note = GetFriendInfo(FriendsFrame.NotesID);
		if ( note ) then
			getglobal(this:GetName().."WideEditBox"):SetText(note);
		end
		getglobal(this:GetName().."WideEditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."WideEditBox"):SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = getglobal(this:GetParent():GetName().."WideEditBox");
		SetFriendNotes(FriendsFrame.NotesID, editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ADD_IGNORE"] = {
	text = ADD_IGNORE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 12,
	OnAccept = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		AddIgnore(editBox:GetText());
	end,
	OnShow = function()
		getglobal(this:GetName().."EditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		AddIgnore(editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ADD_MUTE"] = {
	text = ADD_MUTE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 12,
	OnAccept = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		AddMute(editBox:GetText());
	end,
	OnShow = function()
		getglobal(this:GetName().."EditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		AddMute(editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ADD_TEAMMEMBER"] = {
	text = ADD_TEAMMEMBER_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 12,
	OnAccept = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		ArenaTeamInviteByName(PVPTeamDetails.team, editBox:GetText());
	end,
	OnShow = function()
		getglobal(this:GetName().."EditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		ArenaTeamInviteByName(PVPTeamDetails.team, editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ADD_GUILDMEMBER"] = {
	text = ADD_GUILDMEMBER_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 12,
	OnAccept = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		GuildInvite(editBox:GetText());
	end,
	OnShow = function()
		getglobal(this:GetName().."EditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		GuildInvite(editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ADD_RAIDMEMBER"] = {
	text = ADD_RAIDMEMBER_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 12,
	OnAccept = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		InviteUnit(editBox:GetText());
	end,
	OnShow = function()
		getglobal(this:GetName().."EditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		InviteUnit(editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["REMOVE_GUILDMEMBER"] = {
	text = format(REMOVE_GUILDMEMBER_LABEL, "XXX"),
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		GuildUninvite(GuildFrame.selectedName);
		GuildMemberDetailFrame:Hide();
	end,
	OnShow = function()
		getglobal(this:GetName().."Text"):SetFormattedText(REMOVE_GUILDMEMBER_LABEL, GuildFrame.selectedName);
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["ADD_GUILDRANK"] = {
	text = ADD_GUILDRANK_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 15,
	OnAccept = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		GuildControlAddRank(editBox:GetText());
		GuildControlSetRank(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown));
		UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown));
		GuildControlPopupFrameEditBox:SetText(GuildControlGetRankName(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown)));
		GuildControlCheckboxUpdate(GuildControlGetRankFlags());
		CloseDropDownMenus();
	end,
	OnShow = function()
		getglobal(this:GetName().."EditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		GuildControlAddRank(editBox:GetText());
		GuildControlSetRank(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown));
		UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown));
		GuildControlPopupFrameEditBox:SetText(GuildControlGetRankName(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown)));
		GuildControlCheckboxUpdate(GuildControlGetRankFlags());
		CloseDropDownMenus();
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["SET_GUILDMOTD"] = {
	text = SET_GUILDMOTD_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 128,
	hasWideEditBox = 1,
	OnAccept = function()
		local editBox = getglobal(this:GetParent():GetName().."WideEditBox");
		GuildSetMOTD(editBox:GetText());
	end,
	OnShow = function()
		--getglobal(this:GetName().."WideEditBox"):SetText(GetGuildRosterMOTD());
		getglobal(this:GetName().."WideEditBox"):SetText(CURRENT_GUILD_MOTD);
		getglobal(this:GetName().."WideEditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."WideEditBox"):SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = getglobal(this:GetParent():GetName().."WideEditBox");
		GuildSetMOTD(editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["SET_GUILDPLAYERNOTE"] = {
	text = SET_GUILDPLAYERNOTE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	hasWideEditBox = 1,
	OnAccept = function()
		local editBox = getglobal(this:GetParent():GetName().."WideEditBox");
		GuildRosterSetPublicNote(GetGuildRosterSelection(), editBox:GetText());
	end,
	OnShow = function()
		local name, rank, rankIndex, level, class, zone, note, officernote, online;
		name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(GetGuildRosterSelection());

		getglobal(this:GetName().."WideEditBox"):SetText(note);
		getglobal(this:GetName().."WideEditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."WideEditBox"):SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = getglobal(this:GetParent():GetName().."WideEditBox");
		GuildRosterSetPublicNote(GetGuildRosterSelection(), editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
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
	hasWideEditBox = 1,
	OnAccept = function()
		local editBox = getglobal(this:GetParent():GetName().."WideEditBox");
		GuildRosterSetOfficerNote(GetGuildRosterSelection(), editBox:GetText());
	end,
	OnShow = function()
		local name, rank, rankIndex, level, class, zone, note, officernote, online;
		name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(GetGuildRosterSelection());

		getglobal(this:GetName().."WideEditBox"):SetText(officernote);
		getglobal(this:GetName().."WideEditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."WideEditBox"):SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = getglobal(this:GetParent():GetName().."WideEditBox");
		GuildRosterSetOfficerNote(GetGuildRosterSelection(), editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["RENAME_PET"] = {
	text = PET_RENAME_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 12,
	OnAccept = function()
		local text = getglobal(this:GetParent():GetName().."EditBox"):GetText();
		local dialogFrame = StaticPopup_Show("PETRENAMECONFIRM", text);
		if ( dialogFrame ) then
			dialogFrame.data = text;
		end
	end,
	EditBoxOnEnterPressed = function()
		local text = getglobal(this:GetParent():GetName().."EditBox"):GetText();
		local dialogFrame = StaticPopup_Show("PETRENAMECONFIRM", text);
		if ( dialogFrame ) then
			dialogFrame.data = text;
		end
		this:GetParent():Hide();
	end,
	OnShow = function()
		getglobal(this:GetName().."EditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	OnUpdate = function(elapsed, dialog)
		if ( not UnitExists("pet") ) then
			dialog:Hide();
		end
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["DUEL_REQUESTED"] = {
	text = DUEL_REQUESTED,
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = "igPlayerInvite",
	OnAccept = function()
		AcceptDuel();
	end,
	OnCancel = function()
		CancelDuel();
	end,
	timeout = 60,
	hideOnEscape = 1
};
StaticPopupDialogs["DUEL_OUTOFBOUNDS"] = {
	text = DUEL_OUTOFBOUNDS_TIMER,
	timeout = 10,
};
StaticPopupDialogs["UNLEARN_SKILL"] = {
	text = UNLEARN_SKILL,
	button1 = UNLEARN,
	button2 = CANCEL,
	OnAccept = function(index)
		AbandonSkill(index);
	end,
	timeout = 60,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["XP_LOSS"] = {
	text = CONFIRM_XP_LOSS,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(data)
		if ( data ) then
			getglobal(this:GetParent():GetName().."Text"):SetFormattedText(CONFIRM_XP_LOSS_AGAIN, data);
			this:GetParent().data = nil;
			return 1;
		else
			AcceptXPLoss();
		end
	end,
	OnUpdate = function(elapsed, dialog)
		if ( not CheckSpiritHealerDist() ) then
			dialog:Hide();
		end
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["XP_LOSS_NO_SICKNESS"] = {
	text = CONFIRM_XP_LOSS_NO_SICKNESS,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(data)
		if ( data ) then
			getglobal(this:GetParent():GetName().."Text"):SetText(CONFIRM_XP_LOSS_AGAIN_NO_SICKNESS);
			this:GetParent().data = nil;
			return 1;
		else
			AcceptXPLoss();
		end
	end,
	OnUpdate = function(elapsed, dialog)
		if ( not CheckSpiritHealerDist() ) then
			dialog:Hide();
		end
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["RECOVER_CORPSE"] = {
	StartDelay = GetCorpseRecoveryDelay,
	delayText = RECOVER_CORPSE_TIMER,
	text = RECOVER_CORPSE,
	button1 = ACCEPT,
	OnAccept = function()
		RetrieveCorpse();
		return 1;
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1
};
StaticPopupDialogs["RECOVER_CORPSE_INSTANCE"] = {
	text = RECOVER_CORPSE_INSTANCE,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1
};
--[[ The old version of the dialog... the new one auto-accepts for you.
StaticPopupDialogs["AREA_SPIRIT_HEAL"] = {
	text = AREA_SPIRIT_HEAL,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function()
		this.timeleft = GetAreaSpiritHealerTime();
	end,
	OnAccept = function()
		AcceptAreaSpiritHeal();
		getglobal(this:GetParent():GetName().."Button1"):Hide();
		getglobal(this:GetParent():GetName().."Button2"):Hide();
		return 1;
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1
};
]]
StaticPopupDialogs["AREA_SPIRIT_HEAL"] = {
	text = AREA_SPIRIT_HEAL,
	button1 = CANCEL,
	OnShow = function()
		this.timeleft = GetAreaSpiritHealerTime();
	end,
	OnAccept = function()
		CancelAreaSpiritHeal();
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["BIND_ENCHANT"] = {
	text = BIND_ENCHANT,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		BindEnchant();
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
	OnAccept = function()
		ReplaceEnchant();
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
	OnAccept = function()
		ReplaceTradeEnchant();
	end,
	timeout = 0,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["INSTANCE_BOOT"] = {
	text = INSTANCE_BOOT_TIMER,
	OnShow = function()
		this.timeleft = GetInstanceBootTimeRemaining();
		if ( this.timeleft <= 0 ) then
			StaticPopup_Hide("INSTANCE_BOOT");
		end
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1
};
StaticPopupDialogs["CONFIRM_TALENT_WIPE"] = {
	text = CONFIRM_TALENT_WIPE,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		ConfirmTalentWipe();
	end,
	OnUpdate = function(elapsed, dialog)
		if ( not CheckTalentMasterDist() ) then
			dialog:Hide();
		end
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_PET_UNLEARN"] = {
	text = CONFIRM_PET_UNLEARN,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		ConfirmPetUnlearn();
	end,
	OnUpdate = function(elapsed, dialog)
		if ( not CheckPetUntrainerDist() ) then
			dialog:Hide();
		end
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_BINDER"] = {
	text = CONFIRM_BINDER,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		ConfirmBinder();
	end,
	OnUpdate = function(elapsed, dialog)
		if ( not CheckBinderDist() ) then
			dialog:Hide();
		end
	end,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_SUMMON"] = {
	text = CONFIRM_SUMMON;
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function()
		this.timeleft = GetSummonConfirmTimeLeft();
	end,
	OnAccept = function()
		ConfirmSummon();
	end,
	OnCancel = function()
		CancelSummon();
	end,
	OnUpdate = function(elapsed, dialog)
		local button = getglobal(dialog:GetName().."Button1");
		if ( UnitAffectingCombat("player") ) then
			button:Disable();
		else
			button:Enable();
		end
	end,
	timeout = 0,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1
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
	OnAccept = function(id, rollType)
		ConfirmLootRoll(id, rollType);
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["GOSSIP_CONFIRM"] = {
	text = "%s",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(data)
		SelectGossipOption(data, "", true);
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
	OnAccept = function(data)
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		SelectGossipOption(data, editBox:GetText(), true);
	end,
	OnShow = function()
		getglobal(this:GetName().."EditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	EditBoxOnEnterPressed = function(data)
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		SelectGossipOption(data, editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
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
	OnAccept = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		CombatConfig_CreateCombatFilter(editBox:GetText());
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(data)
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		CombatConfig_CreateCombatFilter(editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function ()
		this:GetParent():Hide();
	end,
	OnHide = function ()
		getglobal(this:GetName().."EditBox"):SetText("");
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
	OnAccept = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		CombatConfig_CreateCombatFilter(editBox:GetText(), this:GetParent().data);
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		CombatConfig_CreateCombatFilter(editBox:GetText(), this:GetParent().data);
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function ()
		this:GetParent():Hide();
	end,
	OnHide = function ()
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_COMBAT_FILTER_DELETE"] = {
	text = CONFIRM_COMBAT_FILTER_DELETE,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
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
	OnAccept = function()
		CombatConfig_SetCombatFiltersToDefault();
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	hideOnEscape = 1
};

function StaticPopup_FindVisible(which, data)
	local info = StaticPopupDialogs[which];
	if ( not info ) then
		return nil;
	end
	for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
		local frame = getglobal("StaticPopup"..index);
		if ( frame:IsShown() and (frame.which == which) and (not info.multiple or (frame.data == data)) ) then
			return frame;
		end
	end
	return nil;
end

function StaticPopup_Resize(dialog, which)
	local text = getglobal(dialog:GetName().."Text");
	local editBox = getglobal(dialog:GetName().."EditBox");
	local button1 = getglobal(dialog:GetName().."Button1");
	
	local width = 320;
	dialog:SetWidth(320);
	if ( StaticPopupDialogs[which].button3 ) then
		width = 440;
	elseif (StaticPopupDialogs[which].hasWideEditBox or StaticPopupDialogs[which].showAlert) then
		-- Widen
		width = 420;
	elseif ( which == "HELP_TICKET" ) then
		width = 350;
	end
	dialog:SetWidth(width);
	
	if ( StaticPopupDialogs[which].hasEditBox ) then
		if ( StaticPopupDialogs[which].hasWideEditBox  ) then
		
		end
		dialog:SetHeight(16 + text:GetHeight() + 8 + editBox:GetHeight() + 8 + button1:GetHeight() + 16);
	elseif ( StaticPopupDialogs[which].hasMoneyFrame ) then
		dialog:SetHeight(16 + text:GetHeight() + 8 + button1:GetHeight() + 32);
	elseif ( StaticPopupDialogs[which].hasMoneyInputFrame ) then
		dialog:SetHeight(16 + text:GetHeight() + 8 + button1:GetHeight() + 38);
	elseif ( StaticPopupDialogs[which].hasItemFrame ) then
		dialog:SetHeight(16 + text:GetHeight() + 8 + button1:GetHeight() + 80);
	else
		dialog:SetHeight(16 + text:GetHeight() + 8 + button1:GetHeight() + 16);
	end
end

function StaticPopup_Show(which, text_arg1, text_arg2, data)
	local info = StaticPopupDialogs[which];
	if ( not info ) then
		return nil;
	end

	if ( UnitIsDeadOrGhost("player") and not info.whileDead ) then
		if ( info.OnCancel ) then
			info.OnCancel();
		end
		return nil;
	end

	if ( InCinematic() and not info.interruptCinematic ) then
		if ( info.OnCancel ) then
			info.OnCancel();
		end
		return nil;
	end

	if ( info.exclusive ) then
		for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
			local frame = getglobal("StaticPopup"..index);
			if ( frame:IsShown() and StaticPopupDialogs[frame.which].exclusive ) then
				frame:Hide();
				local OnCancel = StaticPopupDialogs[frame.which].OnCancel;
				if ( OnCancel ) then
					OnCancel(frame.data, "override");
				end
				break;
			end
		end
	end

	if ( info.cancels ) then
		for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
			local frame = getglobal("StaticPopup"..index);
			if ( frame:IsShown() and (frame.which == info.cancels) ) then
				frame:Hide();
				local OnCancel = StaticPopupDialogs[frame.which].OnCancel;
				if ( OnCancel ) then
					OnCancel(frame.data, "override");
				end
			end
		end
	end

	if ( (which == "CAMP") or (which == "QUIT") ) then
		for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
			local frame = getglobal("StaticPopup"..index);
			if ( frame:IsShown() and not StaticPopupDialogs[frame.which].notClosableByLogout ) then
				frame:Hide();
				local OnCancel = StaticPopupDialogs[frame.which].OnCancel;
				if ( OnCancel ) then
					OnCancel(frame.data, "override");
				end
			end
		end
	end

	if ( which == "DEATH" ) then
		for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
			local frame = getglobal("StaticPopup"..index);
			if ( frame:IsShown() and not StaticPopupDialogs[frame.which].whileDead ) then
				frame:Hide();
				local OnCancel = StaticPopupDialogs[frame.which].OnCancel;
				if ( OnCancel ) then
					OnCancel(frame.data, "override");
				end
			end
		end
	end

	-- Pick a free dialog to use
	local dialog = nil;
	-- Find an open dialog of the requested type
	dialog = StaticPopup_FindVisible(which, data);
	if ( dialog ) then
		local OnCancel = StaticPopupDialogs[which].OnCancel;
		if ( OnCancel ) then
			OnCancel(dialog.data, "override");
		end
		dialog:Hide();
	end
	if ( not dialog ) then
		-- Find a free dialog
		local index = 1;
		if ( StaticPopupDialogs[which].preferredIndex ) then
			index = StaticPopupDialogs[which].preferredIndex;
		end
		for i = index, STATICPOPUP_NUMDIALOGS do
			local frame = getglobal("StaticPopup"..i);
			if ( not frame:IsShown() ) then
				dialog = frame;
				break;
			end
		end
		
		--If dialog not found and there's a preferredIndex then try to find an available frame before the preferredIndex
		if ( not dialog and StaticPopupDialogs[which].preferredIndex ) then
			for i = 1, StaticPopupDialogs[which].preferredIndex do
				local frame = getglobal("StaticPopup"..i);
				if ( not frame:IsShown() ) then
					dialog = frame;
					break;
				end
			end
		end
	end
	if ( not dialog ) then
		if ( info.OnCancel ) then
			info.OnCancel();
		end
		return nil;
	end

	-- Set the text of the dialog
	local text = getglobal(dialog:GetName().."Text");
	if ( (which == "DEATH") or
	     (which == "CAMP") or
		 (which == "QUIT") or
		 (which == "DUEL_OUTOFBOUNDS") or
		 (which == "RECOVER_CORPSE") or
		 (which == "RESURRECT") or
		 (which == "RESURRECT_NO_SICKNESS") or
		 (which == "INSTANCE_BOOT") or
		 (which == "CONFIRM_SUMMON") or
		 (which == "AREA_SPIRIT_HEAL") ) then
		text:SetText(" ");	-- The text will be filled in later.
		text.text_arg1 = text_arg1;
		text.text_arg2 = text_arg2;
	elseif ( which == "BILLING_NAG" ) then
		text:SetFormattedText(StaticPopupDialogs[which].text, text_arg1, MINUTES);
	else
		text:SetFormattedText(StaticPopupDialogs[which].text, text_arg1, text_arg2);
	end
	
	-- If is any of the guild message popups
	local wideEditBox = getglobal(dialog:GetName().."WideEditBox");
	local editBox = getglobal(dialog:GetName().."EditBox");
	local alertIcon = getglobal(dialog:GetName().."AlertIcon");
	if ( info.showAlert ) then
		alertIcon:Show();
	else
		alertIcon:Hide();	
	end

	-- If is the ticket edit dialog then show the close button
	if ( which == "HELP_TICKET" ) then
		getglobal(dialog:GetName().."CloseButton"):Show();
	else
		getglobal(dialog:GetName().."CloseButton"):Hide();
	end

	-- Set the editbox of the dialog
	if ( StaticPopupDialogs[which].hasEditBox ) then
		if ( StaticPopupDialogs[which].hasWideEditBox ) then
			wideEditBox:Show();
			editBox:Hide();

			if ( StaticPopupDialogs[which].maxLetters ) then
				wideEditBox:SetMaxLetters(StaticPopupDialogs[which].maxLetters);
			end
			if ( StaticPopupDialogs[which].maxBytes ) then
				wideEditBox:SetMaxBytes(StaticPopupDialogs[which].maxBytes);
			end
		else
			wideEditBox:Hide();
			editBox:Show();

			if ( StaticPopupDialogs[which].maxLetters ) then
				editBox:SetMaxLetters(StaticPopupDialogs[which].maxLetters);
			end
			if ( StaticPopupDialogs[which].maxBytes ) then
				editBox:SetMaxBytes(StaticPopupDialogs[which].maxBytes);
			end
		end
	else
		wideEditBox:Hide();
		editBox:Hide();
	end
	
	-- Show or hide money frame
	if ( StaticPopupDialogs[which].hasMoneyFrame ) then
		getglobal(dialog:GetName().."MoneyFrame"):Show();
		getglobal(dialog:GetName().."MoneyInputFrame"):Hide();
	elseif ( StaticPopupDialogs[which].hasMoneyInputFrame ) then
		getglobal(dialog:GetName().."MoneyInputFrame"):Show();
		getglobal(dialog:GetName().."MoneyFrame"):Hide();
		-- Set OnEnterPress for money input frames
		if ( StaticPopupDialogs[which].EditBoxOnEnterPressed ) then
			getglobal(dialog:GetName().."MoneyInputFrameGold"):SetScript("OnEnterPressed", StaticPopup_EditBoxOnEnterPressed);
			getglobal(dialog:GetName().."MoneyInputFrameSilver"):SetScript("OnEnterPressed", StaticPopup_EditBoxOnEnterPressed);
			getglobal(dialog:GetName().."MoneyInputFrameCopper"):SetScript("OnEnterPressed", StaticPopup_EditBoxOnEnterPressed);
		else
			getglobal(dialog:GetName().."MoneyInputFrameGold"):SetScript("OnEnterPressed", nil);
			getglobal(dialog:GetName().."MoneyInputFrameSilver"):SetScript("OnEnterPressed", nil);
			getglobal(dialog:GetName().."MoneyInputFrameCopper"):SetScript("OnEnterPressed", nil);
		end
	else
		getglobal(dialog:GetName().."MoneyFrame"):Hide();
		getglobal(dialog:GetName().."MoneyInputFrame"):Hide();
	end

	-- Show or hide item button
	if ( StaticPopupDialogs[which].hasItemFrame ) then
		getglobal(dialog:GetName().."ItemFrame"):Show();
		if ( data and type(data) == "table" ) then
			getglobal(dialog:GetName().."ItemFrame").link = data.link
			getglobal(dialog:GetName().."ItemFrameIconTexture"):SetTexture(data.texture);
			local nameText = getglobal(dialog:GetName().."ItemFrameText");
			nameText:SetTextColor(unpack(data.color or {1, 1, 1, 1}));
			nameText:SetText(data.name);
			if ( data.count and data.count > 1 ) then
				getglobal(dialog:GetName().."ItemFrameCount"):SetText(data.count);
				getglobal(dialog:GetName().."ItemFrameCount"):Show();
			else
				getglobal(dialog:GetName().."ItemFrameCount"):Hide();
			end
		end
	else
		getglobal(dialog:GetName().."ItemFrame"):Hide();
	end
	
	-- Set the buttons of the dialog
	local button1 = getglobal(dialog:GetName().."Button1");
	local button2 = getglobal(dialog:GetName().."Button2");
	local button3 = getglobal(dialog:GetName().."Button3");
	if ( StaticPopupDialogs[which].button3 and ( not StaticPopupDialogs[which].DisplayButton3 or StaticPopupDialogs[which].DisplayButton3() ) ) then
		button1:ClearAllPoints();
		button2:ClearAllPoints();
		button3:ClearAllPoints();
		if ( StaticPopupDialogs[which].hasEditBox ) then
			button1:SetPoint("TOPRIGHT", editBox, "BOTTOM", -72, -8);
			button3:SetPoint("LEFT", button1, "RIGHT", 13, 0);
			button2:SetPoint("LEFT", button3, "RIGHT", 13, 0);
			
		elseif ( StaticPopupDialogs[which].hasMoneyFrame ) then
			button1:SetPoint("TOPRIGHT", text, "BOTTOM", -72, -24);
			button3:SetPoint("LEFT", button1, "RIGHT", 13, 0);
			button2:SetPoint("LEFT", button3, "RIGHT", 13, 0);
			
		elseif ( StaticPopupDialogs[which].hasMoneyInputFrame ) then
			button1:SetPoint("TOPRIGHT", text, "BOTTOM", -72, -30);
			button3:SetPoint("LEFT", button1, "RIGHT", 13, 0);
			button2:SetPoint("LEFT", button3, "RIGHT", 13, 0);
			
		elseif ( StaticPopupDialogs[which].hasItemFrame ) then
			button1:SetPoint("TOPRIGHT", text, "BOTTOM", -72, -70);
			button3:SetPoint("LEFT", button1, "RIGHT", 13, 0);
			button2:SetPoint("LEFT", button3, "RIGHT", 13, 0);
		else
			button1:SetPoint("TOPRIGHT", text, "BOTTOM", -72, -8);
			button3:SetPoint("LEFT", button1, "RIGHT", 13, 0);
			button2:SetPoint("LEFT", button3, "RIGHT", 13, 0);
		end
		button2:SetText(StaticPopupDialogs[which].button2);
		button3:SetText(StaticPopupDialogs[which].button3);
		local width = button2:GetTextWidth();
		if ( width > 110 ) then
			button2:SetWidth(width + 20);
		else
			button2:SetWidth(120);
		end
		button2:Enable();
		button2:Show();
		
		width = button3:GetTextWidth();
		if ( width > 110 ) then
			button3:SetWidth(width + 20);
		else
			button3:SetWidth(120);
		end
		button3:Enable();
		button3:Show();
		
	elseif ( StaticPopupDialogs[which].button2 and
	   ( not StaticPopupDialogs[which].DisplayButton2 or StaticPopupDialogs[which].DisplayButton2() ) ) then
		button1:ClearAllPoints();
		button2:ClearAllPoints();
		if ( StaticPopupDialogs[which].hasEditBox ) then
			button1:SetPoint("TOPRIGHT", editBox, "BOTTOM", -6, -8);
			button2:SetPoint("LEFT", button1, "RIGHT", 13, 0);
		elseif ( StaticPopupDialogs[which].hasMoneyFrame ) then
			button1:SetPoint("TOPRIGHT", text, "BOTTOM", -6, -24);
			button2:SetPoint("LEFT", button1, "RIGHT", 13, 0);
		elseif ( StaticPopupDialogs[which].hasMoneyInputFrame ) then
			button1:SetPoint("TOPRIGHT", text, "BOTTOM", -6, -30);
			button2:SetPoint("LEFT", button1, "RIGHT", 13, 0);
		elseif ( StaticPopupDialogs[which].hasItemFrame ) then
			button1:SetPoint("TOPRIGHT", text, "BOTTOM", -6, -70);
			button2:SetPoint("LEFT", button1, "RIGHT", 13, 0);
		else
			button1:SetPoint("TOPRIGHT", text, "BOTTOM", -6, -8);
			button2:SetPoint("LEFT", button1, "RIGHT", 13, 0);
		end
		button2:SetText(StaticPopupDialogs[which].button2);
		local width = button2:GetTextWidth();
		if ( width > 110 ) then
			button2:SetWidth(width + 20);
		else
			button2:SetWidth(120);
		end
		button2:Enable();
		button2:Show();
		button3:Hide();
	else
		button1:ClearAllPoints();
		button1:SetPoint("TOP", text, "BOTTOM", 0, -8);
		button2:Hide();
		button3:Hide();
	end
	if ( StaticPopupDialogs[which].button1 ) then
		button1:SetText(StaticPopupDialogs[which].button1);
		local width = button1:GetTextWidth();
		if ( width > 120 ) then
			button1:SetWidth(width + 20);
		else
			button1:SetWidth(120);
		end
		button1:Enable();
		button1:Show();
	else
		button1:Hide();
	end

	-- Set the miscellaneous variables for the dialog
	dialog.which = which;
	dialog.timeleft = StaticPopupDialogs[which].timeout;
	dialog.hideOnEscape = StaticPopupDialogs[which].hideOnEscape;
	-- Clear out data
	dialog.data = nil;

	if ( StaticPopupDialogs[which].StartDelay ) then
		dialog.startDelay = StaticPopupDialogs[which].StartDelay();
		button1:Disable();
	else
		dialog.startDelay = nil;
		button1:Enable();
	end

	-- Finally size and show the dialog
	dialog:Show();
	StaticPopup_Resize(dialog, which);

	if ( StaticPopupDialogs[which].sound ) then
		PlaySound(StaticPopupDialogs[which].sound);
	end

	return dialog;
end

function StaticPopup_Hide(which, data)
	for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
		local dialog = getglobal("StaticPopup"..index);
		if ( (dialog.which == which) and (not data or (data == dialog.data)) ) then
			dialog:Hide();
		end
	end
end

function StaticPopup_OnUpdate(dialog, elapsed)
	if ( dialog.timeleft > 0 ) then
		local which = dialog.which;
		local timeleft = dialog.timeleft - elapsed;
		if ( timeleft <= 0 ) then
			dialog.timeleft = 0;
			local OnCancel = StaticPopupDialogs[which].OnCancel;
			if ( OnCancel ) then
				OnCancel(dialog.data, "timeout");
			end
			dialog:Hide();
			return;
		end
		dialog.timeleft = timeleft;

		if ( (which == "DEATH") or
		     (which == "CAMP")  or
			 (which == "QUIT") or
			 (which == "DUEL_OUTOFBOUNDS") or
			 (which == "INSTANCE_BOOT") or
			 (which == "CONFIRM_SUMMON") or
			 (which == "AREA_SPIRIT_HEAL") ) then
			local text = getglobal(dialog:GetName().."Text");
			local hasText = nil;
			if ( text:GetText() ~= " " ) then
				hasText = 1;
			end
			timeleft = ceil(timeleft);
			if ( which == "INSTANCE_BOOT" ) then
				if ( timeleft < 60 ) then
					text:SetFormattedText(StaticPopupDialogs[which].text, GetBindLocation(), timeleft, SECONDS);
				else
					text:SetFormattedText(StaticPopupDialogs[which].text, GetBindLocation(), ceil(timeleft / 60), MINUTES);
				end
			elseif ( which == "CONFIRM_SUMMON" ) then
				if ( timeleft < 60 ) then
					text:SetFormattedText(StaticPopupDialogs[which].text, GetSummonConfirmSummoner(), GetSummonConfirmAreaName(), timeleft, SECONDS);
				else
					text:SetFormattedText(StaticPopupDialogs[which].text, GetSummonConfirmSummoner(), GetSummonConfirmAreaName(), ceil(timeleft / 60), MINUTES);
				end
			else
				if ( timeleft < 60 ) then
					text:SetFormattedText(StaticPopupDialogs[which].text, timeleft, SECONDS);
				else
					text:SetFormattedText(StaticPopupDialogs[which].text, ceil(timeleft / 60), MINUTES);
				end
			end
			if ( not hasText ) then
				StaticPopup_Resize(dialog, which);
			end
		end
	end
	if ( dialog.startDelay ) then
		local which = dialog.which;
		local timeleft = dialog.startDelay - elapsed;
		if ( timeleft <= 0 ) then
			dialog.startDelay = nil;
			local text = getglobal(dialog:GetName().."Text");
			text:SetFormattedText(StaticPopupDialogs[which].text, text.text_arg1, text.text_arg2);
			local button1 = getglobal(dialog:GetName().."Button1");
			button1:Enable();
			StaticPopup_Resize(dialog, which);
			return;
		end
		dialog.startDelay = timeleft;

		if ( which == "RECOVER_CORPSE" or (which == "RESURRECT") or (which == "RESURRECT_NO_SICKNESS") ) then
			local text = getglobal(dialog:GetName().."Text");
			local hasText = nil;
			if ( text:GetText() ~= " " ) then
				hasText = 1;
			end
			timeleft = ceil(timeleft);
			if ( (which == "RESURRECT") or (which == "RESURRECT_NO_SICKNESS") ) then
				if ( timeleft < 60 ) then
					text:SetFormattedText(StaticPopupDialogs[which].delayText, text.text_arg1, timeleft, SECONDS);
				else
					text:SetFormattedText(StaticPopupDialogs[which].delayText, text.text_arg1, ceil(timeleft / 60), MINUTES);
				end
			else
				if ( timeleft < 60 ) then
					text:SetFormattedText(StaticPopupDialogs[which].delayText, timeleft, SECONDS);
				else
					text:SetFormattedText(StaticPopupDialogs[which].delayText, ceil(timeleft / 60), MINUTES);
				end
			end
			if ( not hasText ) then
				StaticPopup_Resize(dialog, which);
			end
		end
	end

	local onUpdate = StaticPopupDialogs[dialog.which].OnUpdate;
	if ( onUpdate ) then
		onUpdate(elapsed, dialog);
	end
end

function StaticPopup_EditBoxOnEnterPressed()
	local EditBoxOnEnterPressed, which, dialog;
	if ( this:GetParent().which ) then
		which = this:GetParent().which;
		dialog = this:GetParent();
	elseif ( this:GetParent():GetParent().which ) then
		-- This is needed if this is a money input frame since it's nested deeper than a normal edit box
		which = this:GetParent():GetParent().which;
		dialog = this:GetParent():GetParent();
	end
	EditBoxOnEnterPressed = StaticPopupDialogs[which].EditBoxOnEnterPressed;
	if ( EditBoxOnEnterPressed ) then
		EditBoxOnEnterPressed(dialog.data);
	end
end

function StaticPopup_EditBoxOnEscapePressed()
	local EditBoxOnEscapePressed = StaticPopupDialogs[this:GetParent().which].EditBoxOnEscapePressed;
	if ( EditBoxOnEscapePressed ) then
		EditBoxOnEscapePressed(this:GetParent().data);
	end
end

function StaticPopup_EditBoxOnTextChanged()
	local EditBoxOnTextChanged = StaticPopupDialogs[this:GetParent().which].EditBoxOnTextChanged;
	if ( EditBoxOnTextChanged ) then
		EditBoxOnTextChanged(this:GetParent().data);
	end
end

function StaticPopup_OnShow()
	PlaySound("igMainMenuOpen");
	local OnShow = StaticPopupDialogs[this.which].OnShow;

	if ( OnShow ) then
		OnShow(this.data);
	end
	if ( StaticPopupDialogs[this.which].hasMoneyInputFrame ) then
		getglobal(this:GetName().."MoneyInputFrameGold"):SetFocus();
	end
end

function StaticPopup_OnHide()
	PlaySound("igMainMenuClose");

	local OnHide = StaticPopupDialogs[this.which].OnHide;
	if ( OnHide ) then
		OnHide(this.data);
	end
end

function StaticPopup_OnClick(dialog, index)
	local which = dialog.which;
	local dontHide = nil;
	if ( index == 1 ) then
		local OnAccept = StaticPopupDialogs[dialog.which].OnAccept;
		if ( OnAccept ) then
			dontHide = OnAccept(dialog.data, dialog.data2);
		end
	elseif ( index == 3 ) then
		local OnAlt = StaticPopupDialogs[dialog.which].OnAlt;
		if ( OnAlt ) then
			OnAlt(dialog.data, "clicked");
		end
	else
		local OnCancel = StaticPopupDialogs[dialog.which].OnCancel;
		if ( OnCancel ) then
			OnCancel(dialog.data, "clicked");
		end
	end

	if ( not dontHide and (which == dialog.which) ) then
		dialog:Hide();
	end
end

function StaticPopup_Visible(which)
	for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
		local frame = getglobal("StaticPopup"..index);
		if( frame:IsShown() and (frame.which == which) ) then 
			return frame:GetName();
		end
	end
	return nil;
end

function StaticPopup_EscapePressed()
	local closed = nil;
	for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
		local frame = getglobal("StaticPopup"..index);
		if( frame:IsShown() and frame.hideOnEscape ) then 
			local OnCancel = StaticPopupDialogs[frame.which].OnCancel;
			if ( OnCancel ) then
				OnCancel(frame.data, "clicked");
			end
			frame:Hide();
			closed = 1;
		end
	end
	return closed;
end
