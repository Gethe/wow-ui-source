STATICPOPUP_NUMDIALOGS = 4;

StaticPopupDialogs = { };

StaticPopupDialogs["CONFIRM_OVERWRITE_EQUIPMENT_SET"] = {
	text = CONFIRM_OVERWRITE_EQUIPMENT_SET,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self) SaveEquipmentSet(self.data, self.selectedIcon); GearManagerDialogPopup:Hide(); end,
	OnCancel = function (self) end,
	OnHide = function (self) self.data = nil; self.selectedIcon = nil; end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}

StaticPopupDialogs["CONFIRM_DELETE_EQUIPMENT_SET"] = {
	text = CONFIRM_DELETE_EQUIPMENT_SET,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self) DeleteEquipmentSet(self.data); end,
	OnCancel = function (self) end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}

StaticPopupDialogs["CONFIRM_REMOVE_GLYPH"] = {
	text = CONFIRM_REMOVE_GLYPH,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self)
		local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup or 1;
		if ( talentGroup == GetActiveTalentGroup() ) then
			RemoveGlyphFromSocket(self.data);
		end
	end,
	OnCancel = function (self)
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}

StaticPopupDialogs["CONFIRM_GLYPH_PLACEMENT"] = {
	text = CONFIRM_GLYPH_PLACEMENT,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self) PlaceGlyphInSocket(self.data); end,
	OnCancel = function (self) end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}

StaticPopupDialogs["CONFIRM_RESET_VIDEO_SETTINGS"] = { 
	text = CONFIRM_RESET_SETTINGS,
	button1 = ALL_SETTINGS,
	button3 = CURRENT_SETTINGS,
	button2 = CANCEL,
	OnAccept = function ()
		VideoOptionsFrame_SetAllToDefaults();
	end,
	OnAlt = function ()
		VideoOptionsFrame_SetCurrentToDefaults();
	end,
	OnCancel = function() end,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	whileDead = 1,
}

StaticPopupDialogs["CONFIRM_RESET_AUDIO_SETTINGS"] = { 
	text = CONFIRM_RESET_SETTINGS,
	button1 = ALL_SETTINGS,
	button3 = CURRENT_SETTINGS,
	button2 = CANCEL,
	OnAccept = function ()
		AudioOptionsFrame_SetAllToDefaults();
	end,
	OnAlt = function ()
		AudioOptionsFrame_SetCurrentToDefaults();
	end,
	OnCancel = function() end,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	whileDead = 1,
}

StaticPopupDialogs["CONFIRM_RESET_INTERFACE_SETTINGS"] = { 
	text = CONFIRM_RESET_INTERFACE_SETTINGS,
	button1 = ALL_SETTINGS,
	button3 = CURRENT_SETTINGS,
	button2 = CANCEL,
	OnAccept = function ()
		InterfaceOptionsFrame_SetAllToDefaults();
	end,
	OnAlt = function ()
		InterfaceOptionsFrame_SetCurrentToDefaults();
	end,
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

StaticPopupDialogs["CONFIRM_REFUND_TOKEN_ITEM"] = {
	text = CONFIRM_REFUND_TOKEN_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		local currentHonor, maxHonor = GetHonorCurrency();
		if ( MerchantFrame.honorPoints and (MerchantFrame.honorPoints + currentHonor > maxHonor) ) then
			StaticPopup_Show("CONFIRM_REFUND_MAX_HONOR", (MerchantFrame.honorPoints + currentHonor - maxHonor) )
		else
			local currentArenaPoints, maxArenaPoints = GetArenaCurrency();
			if ( MerchantFrame.arenaPoints and (MerchantFrame.arenaPoints + currentArenaPoints > maxArenaPoints) ) then
				StaticPopup_Show("CONFIRM_REFUND_MAX_ARENA_POINTS", (MerchantFrame.arenaPoints + currentArenaPoints - maxArenaPoints))
			else
				ContainerRefundItemPurchase(MerchantFrame.refundBag, MerchantFrame.refundSlot);
			end
		end
		StackSplitFrame:Hide();
	end,
	OnCancel = function()
		ClearCursor();
	end,
	OnShow = function()
	
	end,
	OnHide = function()
		MerchantFrame.refundItem = nil;	
	end,
	timeout = 0,
	hideOnEscape = 1,
	hasItemFrame = 1,
}

StaticPopupDialogs["CONFIRM_REFUND_MAX_HONOR"] = {
	text = CONFIRM_REFUND_MAX_HONOR,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		ContainerRefundItemPurchase(MerchantFrame.refundBag, MerchantFrame.refundSlot);
		StackSplitFrame:Hide();
	end,
	OnCancel = function()
		ClearCursor();
	end,
	OnShow = function()
	
	end,
	OnHide = function()
		MerchantFrame.refundItem = nil;
	end,
	timeout = 0,
	hideOnEscape = 1,
}

StaticPopupDialogs["CONFIRM_REFUND_MAX_ARENA_POINTS"] = {
	text = CONFIRM_REFUND_MAX_ARENA_POINTS,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		ContainerRefundItemPurchase(MerchantFrame.refundBag, MerchantFrame.refundSlot);
		StackSplitFrame:Hide();
	end,
	OnCancel = function()
		ClearCursor();
	end,
	OnShow = function()
	
	end,
	OnHide = function()
		MerchantFrame.refundItem = nil;
	end,
	timeout = 0,
	hideOnEscape = 1,
}


StaticPopupDialogs["CONFIRM_HIGH_COST_ITEM"] = {
	text = CONFIRM_HIGH_COST_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		BuyMerchantItem(MerchantFrame.itemIndex, MerchantFrame.count);
	end,
	OnCancel = function()
	
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, MerchantFrame.price*MerchantFrame.count);
	end,
	OnHide = function()
	
	end,
	timeout = 0,
	hideOnEscape = 1,
	hasMoneyFrame = 1,
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
StaticPopupDialogs["CONFIRM_ACCEPT_PVP_QUEST"] = {
	text = CONFIRM_ACCEPT_PVP_QUEST,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		AcceptQuest();
	end,
	OnCancel = function() 
		DeclineQuest();
		PlaySound("igQuestCancel");
	end,
	OnShow = function()
		QuestFrameAcceptButton:Disable();
		QuestFrameDeclineButton:Disable();
	end,
	OnHide = function()
		QuestFrameDeclineButton:Enable();
	end,
	timeout = 0,
	hideOnEscape = 1,
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
	OnAccept = function(self)
		WithdrawGuildBankMoney(MoneyInputFrame_GetCopper(self.moneyInputFrame));
	end,
	OnHide = function(self)
		MoneyInputFrame_ResetMoney(self.moneyInputFrame);
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent():GetParent();
		WithdrawGuildBankMoney(MoneyInputFrame_GetCopper(parent.moneyInputFrame));
		parent:Hide();
	end,
	hasMoneyInputFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["GUILDBANK_DEPOSIT"] = {
	text = GUILDBANK_DEPOSIT,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		DepositGuildBankMoney(MoneyInputFrame_GetCopper(self.moneyInputFrame));
	end,
	OnHide = function(self)
		MoneyInputFrame_ResetMoney(self.moneyInputFrame);
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent():GetParent();
		DepositGuildBankMoney(MoneyInputFrame_GetCopper(parent.moneyInputFrame));
		parent:Hide();
	end,
	hasMoneyInputFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_BUY_GUILDBANK_TAB"] = {
	text = CONFIRM_BUY_GUILDBANK_TAB,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		BuyGuildBankTab();
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, GetGuildBankTabCost());
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["TOO_MANY_LUA_ERRORS"] = {
	text = TOO_MANY_LUA_ERRORS,
	button1 = DISABLE_ADDONS,
	button2 = IGNORE_ERRORS,
	OnAccept = function(self)
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
	OnAccept = function(self)
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
	OnAccept = function(self)
		GMSurveyFrame_LoadUI();
		ShowUIPanel(GMSurveyFrame);
		TicketStatusFrame:Hide();
	end,
	OnCancel = function(self)
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
	OnAccept = function(self)
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
	OnAccept = function(self)
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
	OnAccept = function(self)
		PurchaseSlot();
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, BankFrame.nextSlotCost);
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
	OnAccept = function(self, data)
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
	OnAccept = function(self, data)
		GiveMasterLoot(LootFrame.selectedSlot, data);
	end,
	timeout = 0,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"] = {
	text = CONFIRM_BATTLEFIELD_ENTRY,
	button1 = ENTER_BATTLE,
	button2 = HIDE,
	OnAccept = function(self, data)
		if ( not AcceptBattlefieldPort(data, 1) ) then
			return 1;
		end
		if( StaticPopup_Visible( "DEATH" ) ) then
			StaticPopup_Hide( "DEATH" );
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
	OnAccept = function(self)
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
	OnAccept = function(self, name)
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
	OnAccept = function(self)
		local text = self.editBox:GetText();
		RenamePetition(text);
	end,
	EditBoxOnEnterPressed = function(self)
		local text = self:GetParent().editBox:GetText();
		RenamePetition(text);
		self:GetParent():Hide();
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		self.editBox:SetText("");
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
	OnAccept = function(self)
		local text = self.editBox:GetText();
		RenamePetition(text);
	end,
	EditBoxOnEnterPressed = function(self)
		local text = self:GetText();
		RenamePetition(text);
		self:GetParent():Hide();
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		self.editBox:SetText("");
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
	OnAccept = function(self, team)
		ArenaTeamLeave(team);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_TEAM_PROMOTE"] = {
	text = CONFIRM_TEAM_PROMOTE,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, team, name)
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
	OnAccept = function(self, team, name)
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
	OnAccept = function(self)
		TakeInboxItem(InboxFrame.openMailID, OpenMailFrame.lastTakeAttachment);
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, OpenMailFrame.cod);
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["COD_CONFIRMATION_AUTO_LOOT"] = {
	text = COD_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, index)
		AutoLootMailItem(index);
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, OpenMailFrame.cod);
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["DELETE_MAIL"] = {
	text = DELETE_MAIL_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
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
	OnAccept = function(self)
		DeleteInboxItem(InboxFrame.openMailID);
		InboxFrame.openMailID = nil;
		HideUIPanel(OpenMailFrame);
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, OpenMailFrame.money);
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
	OnAccept = function(self)
		if ( SetSendMailMoney(MoneyInputFrame_GetCopper(SendMailMoney)) ) then
			SendMailFrame_SendMail();
		end
	end,
	OnCancel = function(self)
		SendMailMailButton:Enable();
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, MoneyInputFrame_GetCopper(SendMailMoney));
	end,
	hasMoneyFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_REPORT_SPAM_CHAT"] = {
	text = REPORT_SPAM_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, lineID)
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
	OnAccept = function(self, index)
		ComplainInboxItem(index);
	end,
	OnCancel = function(self, index)
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
	OnAccept = function(self)
		local channel = self.editBox:GetText();
		JoinPermanentChannel(channel, nil, FCF_GetCurrentChatFrameID(), 1);
		ChatFrame_AddChannel(FCF_GetCurrentChatFrame(), channel);
		self.editBox:SetText("");
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		local editBox = parent.editBox;
		local channel = editBox:GetText();
		JoinPermanentChannel(channel, nil, FCF_GetCurrentChatFrameID(), 1);
		ChatFrame_AddChannel(FCF_GetCurrentChatFrame(), channel);
		editBox:SetText("");
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
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
	OnHide = function(self)
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		self.editBox:SetText("");
	end,
	OnAccept = function(self, data)
		local name = self.editBox:GetText();
		ChannelInvite(data, name);
		self.editBox:SetText("");
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(self, data)
		local parent = self:GetParent();
		local editBox = parent.editBox;
		ChannelInvite(data, editBox:GetText());
		editBox:SetText("");
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
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
	OnHide = function(self)
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		self.editBox:SetText("");
	end,
	OnAccept = function(self, data)
		local password = self.editBox:GetText();
		SetChannelPassword(data, password);
		self.editBox:SetText("");
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(self, data)
		local parent = self:GetParent();
		local editBox = parent.editBox
		local password = editBox:GetText();
		SetChannelPassword(data, password);
		editBox:SetText("");
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
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
	OnAccept = function(self, renameID)
		local name = self.editBox:GetText();
		if ( renameID ) then
			FCF_SetWindowName(getglobal("ChatFrame"..renameID), name);
		else
			FCF_OpenNewWindow(name);
		end
		self.editBox:SetText("");
		FCF_DockUpdate();
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(self, renameID)
		local parent = self:GetParent();
		local editBox = parent.editBox
		local name = editBox:GetText();
		if ( renameID ) then
			FCF_SetWindowName(getglobal("ChatFrame"..renameID), name);
		else
			FCF_OpenNewWindow(name);
		end
		editBox:SetText("");
		FCF_DockUpdate();
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function (self)
		self:GetParent():Hide();
	end,
	hideOnEscape = 1
};

StaticPopupDialogs["RESET_CHAT"] = {
	text = RESET_CHAT_WINDOW,
	button1 = ACCEPT,
	button2 = CANCEL,
	whileDead = 1,
	OnAccept = function(self)
		FCF_ResetChatWindows();
		if ( ChatConfigFrame:IsShown() ) then
			ChatConfig_UpdateChatSettings();
		end
	end,
	timeout = 0,
	EditBoxOnEscapePressed = function (self)
		self:GetParent():Hide();
	end,
	hideOnEscape = 1
};

StaticPopupDialogs["HELP_TICKET_ABANDON_CONFIRM"] = {
	text = HELP_TICKET_ABANDON_CONFIRM,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, prevFrame)
		DeleteGMTicket();
	end,
	OnCancel = function(self, prevFrame)
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}
StaticPopupDialogs["HELP_TICKET"] = {
	text = HELP_TICKET_EDIT_ABANDON,
	button1 = HELP_TICKET_EDIT,
	button2 = HELP_TICKET_ABANDON,
	OnAccept = function(self)
		if ( PETITION_QUEUE_ACTIVE ) then
			ShowUIPanel(HelpFrame);
			HelpFrame_ShowFrame("OpenTicket");
		else
			HideUIPanel(HelpFrame);
			StaticPopup_Show("HELP_TICKET_QUEUE_DISABLED");
		end
	end,
	OnCancel = function(self)
		local currentFrame = self:GetParent();
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
	OnAccept = function(self, data)
		PetRename(data);
	end,
	OnUpdate = function(self, elapsed)
		if ( not UnitExists("pet") ) then
			self:Hide();
		end
	end,
	timeout = 0,
	hideOnEscape = 1
}
StaticPopupDialogs["DEATH"] = {
	text = DEATH_RELEASE_TIMER,
	button1 = DEATH_RELEASE,
	button2 = USE_SOULSTONE,
	OnShow = function(self)
		self.timeleft = GetReleaseTimeRemaining();
		local text = HasSoulstone();
		if ( text ) then
			self.button2:SetText(text);
		end

		if ( IsActiveBattlefieldArena() ) then
			self.text:SetText(DEATH_RELEASE_SPECTATOR);
		elseif ( self.timeleft == -1 ) then
			self.text:SetText(DEATH_RELEASE_NOTIMER);
		end
	end,
	OnAccept = function(self)
		if ( IsActiveBattlefieldArena() ) then
			local info = ChatTypeInfo["SYSTEM"];
			DEFAULT_CHAT_FRAME:AddMessage(ARENA_SPECTATOR, info.r, info.g, info.b, info.id);
		end
		RepopMe();
	end,
	OnCancel = function(self, data, reason)
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
	OnUpdate = function(self, elapsed)
		if ( IsFalling() and (not IsOutOfBounds()) ) then
			self.button1:Disable();
			self.button2:Disable();
		elseif ( HasSoulstone() ) then	--Bug ID 153643
			self.button1:Enable();
			self.button2:Enable();
		else
			self.button1:Enable();
			self.button2:Disable();
		end
	end,
	DisplayButton2 = function(self)
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
	OnShow = function(self)
		self.timeleft = GetCorpseRecoveryDelay() + 60;
	end,
	OnAccept = function(self)
		AcceptResurrect();
	end,
	OnCancel = function(self)
		DeclineResurrect();
		if ( UnitIsDead("player") and not UnitIsControlling("player") ) then
			StaticPopup_Show("DEATH");
		end
	end,
	timeout = 60,
	whileDead = 1,
	cancels = "DEATH",
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1,
	noCancelOnReuse = 1
};
StaticPopupDialogs["RESURRECT_NO_SICKNESS"] = {
	StartDelay = GetCorpseRecoveryDelay,
	delayText = RESURRECT_REQUEST_NO_SICKNESS_TIMER,
	text = RESURRECT_REQUEST_NO_SICKNESS,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnShow = function(self)
		self.timeleft = GetCorpseRecoveryDelay() + 60;
	end,
	OnAccept = function(self)
		AcceptResurrect();
	end,
	OnCancel = function(self)
		DeclineResurrect();
		if ( UnitIsDead("player") and not UnitIsControlling("player") ) then
			StaticPopup_Show("DEATH");
		end
	end,
	timeout = 60,
	whileDead = 1,
	cancels = "DEATH",
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1,
	noCancelOnReuse = 1
};
StaticPopupDialogs["RESURRECT_NO_TIMER"] = {
	text = RESURRECT_REQUEST_NO_SICKNESS,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnShow = function(self)
		self.timeleft = GetCorpseRecoveryDelay() + 60;
	end,
	OnAccept = function(self)
		AcceptResurrect();
	end,
	OnCancel = function(self)
		DeclineResurrect();
		if ( UnitIsDead("player") and not UnitIsControlling("player") ) then
			StaticPopup_Show("DEATH");
		end
	end,
	timeout = 60,
	whileDead = 1,
	cancels = "DEATH",
	interruptCinematic = 1,
	notClosableByLogout = 1,
	hideOnEscape = 1,
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
	OnAccept = function(self)
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
	OnAccept = function(self)
		BeginTrade();
	end,
	OnCancel = function(self)
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
	OnShow = function(self)
		self.inviteAccepted = nil;
	end,
	OnAccept = function(self)
		AcceptGroup();
		self.inviteAccepted = 1;
	end,
	OnCancel = function(self)
		DeclineGroup();
	end,
	OnHide = function(self)
		if ( not self.inviteAccepted ) then
			DeclineGroup();
			self:Hide();
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
	OnAccept = function(self)
		AcceptGuild();
	end,
	OnCancel = function(self)
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
	OnShow = function(self)
		StaticPopupDialogs["CHAT_CHANNEL_INVITE"].inviteAccepted = nil;
	end,
	OnAccept = function(self, data)
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
	EditBoxOnEnterPressed = function(self, data)
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
		self:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function(self, data)
		self:GetParent():Hide();
	end,
	OnHide = function(self, data)
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
	OnAccept = function(self)
		AcceptLevelGrant();
	end,
	OnCancel = function(self)
		DeclineLevelGrant();
	end,
	OnHide = function()
		DeclineLevelGrant();
	end,
	timeout = 60,
	whileDead = 1,
	hideOnEscape = 1
};

function ChatChannelPasswordHandler(self, data)
	local password = getglobal(self:GetName().."EditBox"):GetText();
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
	OnAccept = function(self, data)
		ChatChannelPasswordHandler(self, data);
	end,
	EditBoxOnEnterPressed = function(self, data)
		ChatChannelPasswordHandler(self:GetParent(), data);
		self:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
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
	OnShow = function(self)
		StaticPopupDialogs["LFG_MATCH"].inviteAccepted = nil;
	end,
	OnAccept = function(self)
		AcceptLFGMatch();
		StaticPopupDialogs["LFG_MATCH"].inviteAccepted = 1;
	end,
	OnCancel = function(self)
		DeclineLFGMatch();
	end,
	OnHide = function(self)
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
	OnAccept = function(self)
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
	OnAccept = function(self)
		AcceptArenaTeam();
	end,
	OnCancel = function(self)
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
	OnAccept = function(self)
		CancelLogout();
		--ForceLogout();
		-- uncomment the next line once forced logouts are completely implemented (they currently have a failure case)
		-- this.timeleft = 0;
	end,
	OnHide = function(self)
		if ( self.timeleft > 0 ) then
			CancelLogout();
			self:Hide();
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
	OnAccept = function(self)
		ForceQuit();
		self.timeleft = 0;
	end,
	OnHide = function(self)
		if ( self.timeleft > 0 ) then
			CancelLogout();
			self:Hide();
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
	OnAccept = function(self, slot)
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
	OnAccept = function(self, slot)
		EquipPendingItem(slot);
	end,
	OnCancel = function(self, slot)
		CancelPendingEquip(slot);
	end,
	OnHide = function(self, slot)
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
	OnAccept = function(self, slot)
		EquipPendingItem(slot);
	end,
	OnCancel = function(self, slot)
		CancelPendingEquip(slot);
	end,
	OnHide = function(self, slot)
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
	OnAccept = function(self)
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
	OnAccept = function(self)
		DeleteCursorItem();
	end,
	OnCancel = function (self)
		ClearCursor();
	end,
	OnUpdate = function (self)
		if ( not CursorHasItem() ) then
			self:Hide();
		end
	end,
	OnHide = function()
		MerchantFrame.refundItem = nil;
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
	OnAccept = function(self)
		DeleteCursorItem();
	end,
	OnCancel = function (self)
		ClearCursor();
	end,
	OnUpdate = function (self)
		if ( not CursorHasItem() ) then
			self:Hide();
		end
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 32,
	OnShow = function(self)
		self.button1:Disable();
		self.button2:Enable();
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		self.editBox:SetText("");
		MerchantFrame.refundItem = nil;
	end,
	EditBoxOnEnterPressed = function(self)
		if ( self:GetParent().button1:IsEnabled() == 1 ) then
			DeleteCursorItem();
			self:GetParent():Hide();
		end
	end,
	EditBoxOnTextChanged = function (self)
		local parent = self:GetParent();
		if ( strupper(parent.editBox:GetText()) ==  DELETE_ITEM_CONFIRM_STRING ) then
			parent.button1:Enable();
		else
			parent.button1:Disable();
		end
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
		ClearCursor();
	end
};
StaticPopupDialogs["QUEST_ACCEPT"] = {
	text = QUEST_ACCEPT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
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
	OnShow = function(self)
		self.button1:Disable();
	end,
	OnAccept = function(self)
		ConfirmAcceptQuest();
	end,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["ABANDON_PET"] = {
	text = ABANDON_PET,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		PetAbandon();
	end,
	OnUpdate = function(self, elapsed)
		if ( not UnitExists("pet") ) then
			self:Hide();
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
	OnAccept = function(self)
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
	OnAccept = function(self)
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
	maxLetters = 12 + 1 + 64,
	OnAccept = function(self)
		AddFriend(self.editBox:GetText());
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		AddFriend(parent.editBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
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
	OnAccept = function(self)
		SetFriendNotes(FriendsFrame.NotesID, self.wideEditBox:GetText());
	end,
	OnShow = function(self)
		local name, level, class, area, connected, status, note = GetFriendInfo(FriendsFrame.NotesID);
		if ( note ) then
			self.wideEditBox:SetText(note);
		end
		self.wideEditBox:SetFocus();
	end,
	OnHide = function(self)
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		self.wideEditBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		SetFriendNotes(FriendsFrame.NotesID, parent.wideEditBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
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
	OnAccept = function(self)
		AddIgnore(self.editBox:GetText());
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		AddIgnore(parent.editBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
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
	OnAccept = function(self)
		AddMute(self.editBox:GetText());
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		AddMute(parent.editBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
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
	OnAccept = function(self)
		ArenaTeamInviteByName(PVPTeamDetails.team, self.editBox:GetText());
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		ArenaTeamInviteByName(PVPTeamDetails.team, parent.editBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
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
	OnAccept = function(self)
		GuildInvite(self.editBox:GetText());
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		GuildInvite(parent.editBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
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
	OnAccept = function(self)
		InviteUnit(self.editBox:GetText());
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		InviteUnit(parent.editBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["REMOVE_GUILDMEMBER"] = {
	text = format(REMOVE_GUILDMEMBER_LABEL, "XXX"),
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		GuildUninvite(GuildFrame.selectedName);
		GuildMemberDetailFrame:Hide();
	end,
	OnShow = function(self)
		self.text:SetFormattedText(REMOVE_GUILDMEMBER_LABEL, GuildFrame.selectedName);
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
	OnAccept = function(self)
		GuildControlAddRank(self.editBox:GetText());
		UIDropDownMenu_Initialize(GuildControlPopupFrameDropDown, GuildControlPopupFrameDropDown_Initialize);
		GuildControlSetRank(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown));
		UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown));
		GuildControlPopupFrameEditBox:SetText(GuildControlGetRankName(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown)));
		GuildControlCheckboxUpdate(GuildControlGetRankFlags());
		CloseDropDownMenus();
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		GuildControlAddRank(parent.editBox:GetText());
		UIDropDownMenu_Initialize(GuildControlPopupFrameDropDown, GuildControlPopupFrameDropDown_Initialize);
		GuildControlSetRank(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown));
		UIDropDownMenu_SetSelectedID(GuildControlPopupFrameDropDown, UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown));
		GuildControlPopupFrameEditBox:SetText(GuildControlGetRankName(UIDropDownMenu_GetSelectedID(GuildControlPopupFrameDropDown)));
		GuildControlCheckboxUpdate(GuildControlGetRankFlags());
		CloseDropDownMenus();
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
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
	OnAccept = function(self)
		GuildSetMOTD(self.wideEditBox:GetText());
	end,
	OnShow = function(self)
		self.wideEditBox:SetText(CURRENT_GUILD_MOTD);
		self.wideEditBox:SetFocus();
	end,
	OnHide = function(self)
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		self.wideEditBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		GuildSetMOTD(parent.wideEditBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
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
	OnAccept = function(self)
		GuildRosterSetPublicNote(GetGuildRosterSelection(), self.wideEditBox:GetText());
	end,
	OnShow = function(self)
		--Sets the text to the 7th return from GetGuildRosterInfo(GetGuildRosterSelection());
		self.wideEditBox:SetText(select(7, GetGuildRosterInfo(GetGuildRosterSelection())));
		self.wideEditBox:SetFocus();
	end,
	OnHide = function(self)
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		self.wideEditBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		GuildRosterSetPublicNote(GetGuildRosterSelection(), parent.wideEditBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
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
	OnAccept = function(self)
		GuildRosterSetOfficerNote(GetGuildRosterSelection(), self.wideEditBox:GetText());
	end,
	OnShow = function(self)
		local name, rank, rankIndex, level, class, zone, note, officernote, online;
		name, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(GetGuildRosterSelection());

		self.wideEditBox:SetText(select(8, GetGuildRosterInfo(GetGuildRosterSelection())));
		self.wideEditBox:SetFocus();
	end,
	OnHide = function(self)
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		self.wideEditBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		GuildRosterSetOfficerNote(GetGuildRosterSelection(), parent.wideEditBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
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
	OnAccept = function(self)
		local text = self.editBox:GetText();
		local dialogFrame = StaticPopup_Show("PETRENAMECONFIRM", text);
		if ( dialogFrame ) then
			dialogFrame.data = text;
		end
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		local text = parent.editBox:GetText();
		local dialogFrame = StaticPopup_Show("PETRENAMECONFIRM", text);
		if ( dialogFrame ) then
			dialogFrame.data = text;
		end
		parent:Hide();
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		self.editBox:SetText("");
	end,
	OnUpdate = function(self, elapsed)
		if ( not UnitExists("pet") ) then
			self:Hide();
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
	OnAccept = function(self)
		AcceptDuel();
	end,
	OnCancel = function(self)
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
	OnAccept = function(self, index)
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
	OnAccept = function(self, data)
		if ( data ) then
			self.text:SetFormattedText(CONFIRM_XP_LOSS_AGAIN, data);
			self.data = nil;
			return 1;
		else
			AcceptXPLoss();
		end
	end,
	OnUpdate = function(self, elapsed)
		if ( not CheckSpiritHealerDist() ) then
			self:Hide();
			CloseGossip();
		end
	end,
	OnCancel = function(self)
		CloseGossip();
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
	OnAccept = function(self, data)
		if ( data ) then
			self.text:SetText(CONFIRM_XP_LOSS_AGAIN_NO_SICKNESS);
			self.data = nil;
			return 1;
		else
			AcceptXPLoss();
		end
	end,
	OnUpdate = function(self, dialog)
		if ( not CheckSpiritHealerDist() ) then
			self:Hide();
			CloseGossip();
		end
	end,
	OnCancel = function(self)
		CloseGossip();
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
	OnAccept = function(self)
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

StaticPopupDialogs["AREA_SPIRIT_HEAL"] = {
	text = AREA_SPIRIT_HEAL,
	button1 = CANCEL,
	OnShow = function(self)
		self.timeleft = GetAreaSpiritHealerTime();
	end,
	OnAccept = function(self)
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
	OnAccept = function(self)
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
	OnAccept = function(self)
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
	OnAccept = function(self)
		ReplaceTradeEnchant();
	end,
	timeout = 0,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["INSTANCE_BOOT"] = {
	text = INSTANCE_BOOT_TIMER,
	OnShow = function(self)
		self.timeleft = GetInstanceBootTimeRemaining();
		if ( self.timeleft <= 0 ) then
			self:Hide();
		end
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1
};

StaticPopupDialogs["INSTANCE_LOCK"] = {
	-- we use a custom timer called lockTimeleft in here to avoid special casing the static popup code
	-- if you use timeout or timeleft then you will go through the StaticPopup system's standard OnUpdate
	-- code which we don't want for this dialog
	text = INSTANCE_LOCK_TIMER,
	button1 = ACCEPT,
	button2 = INSTANCE_LEAVE,
	OnShow = function(self)
		local lockTimeleft = GetInstanceLockTimeRemaining();
		if ( lockTimeleft <= 0 ) then
			self:Hide();
			return;
		end
		self.lockTimeleft = lockTimeleft;

		local name, type, difficulty = GetInstanceInfo();
		self.name, self.difficulty = name, difficulty;
	end,
	OnUpdate = function(self, elapsed)
		local lockTimeleft = self.lockTimeleft - elapsed;
		if ( lockTimeleft <= 0 ) then
			local OnCancel = StaticPopupDialogs["INSTANCE_LOCK"].OnCancel;
			if ( OnCancel ) then
				OnCancel(self, nil, "timeout");
			end
			self:Hide();
			return;
		end
		self.lockTimeleft = lockTimeleft;

		local text = _G[self:GetName().."Text"];
		local name = NORMAL_FONT_COLOR_CODE..(self.name or "")..FONT_COLOR_CODE_CLOSE;
		local difficulty = NORMAL_FONT_COLOR_CODE..((self.difficulty > 0 and _G["DUNGEON_DIFFICULTY"..self.difficulty]) or "")..FONT_COLOR_CODE_CLOSE;
		text:SetFormattedText(INSTANCE_LOCK_TIMER, name, difficulty, SecondsToTime(ceil(lockTimeleft), nil, 1));
		StaticPopup_Resize(self, "INSTANCE_LOCK");
	end,
	OnAccept = function(self)
		RespondInstanceLock(true);
		self.name, self.difficulty = nil, nil;
		self.lockTimeleft = nil;
	end,
	OnCancel = function(self, data, reason)
		if ( reason == "timeout" ) then
			self:Hide();
			return;
		end
		RespondInstanceLock(false);
		self.name, self.difficulty = nil, nil;
		self.lockTimeleft = nil;
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
	OnAccept = function(self)
		ConfirmTalentWipe();
	end,
	OnUpdate = function(self, elapsed)
		if ( not CheckTalentMasterDist() ) then
			self:Hide();
		end
	end,
	OnCancel = function(self)
		if ( PlayerTalentFrame ) then
			HideUIPanel(PlayerTalentFrame);
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
	OnAccept = function(self)
		ConfirmBinder();
	end,
	OnUpdate = function(self, elapsed)
		if ( not CheckBinderDist() ) then
			self:Hide();
		end
	end,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_SUMMON"] = {
	text = CONFIRM_SUMMON;
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function(self)
		self.timeleft = GetSummonConfirmTimeLeft();
	end,
	OnAccept = function(self)
		ConfirmSummon();
	end,
	OnCancel = function()
		CancelSummon();
	end,
	OnUpdate = function(self, elapsed)
		if ( UnitAffectingCombat("player") or (not PlayerCanTeleport()) ) then
			self.button1:Disable();
		else
			self.button1:Enable();
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
	OnAccept = function(self, id, rollType)
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
	OnAccept = function(self, data)
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
	OnAccept = function(self, data)
		SelectGossipOption(data, self.editBox:GetText(), true);
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self, data)
		local parent = self:GetParent();
		SelectGossipOption(data, parent.editBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
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
	OnAccept = function(self)
		CombatConfig_CreateCombatFilter(self.editBox:GetText());
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(self, data)
		local parent = self:GetParent();
		CombatConfig_CreateCombatFilter(parent.editBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function (self)
		self:GetParent():Hide();
	end,
	OnHide = function (self)
		self.editBox:SetText("");
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
	OnAccept = function(self)
		CombatConfig_CreateCombatFilter(self.editBox:GetText(), self.data);
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		CombatConfig_CreateCombatFilter(parent.editBox:GetText(), parent.data);
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function (self)
		self:GetParent():Hide();
	end,
	OnHide = function (self)
		self.editBox:SetText("");
	end,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_COMBAT_FILTER_DELETE"] = {
	text = CONFIRM_COMBAT_FILTER_DELETE,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
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
	OnAccept = function(self)
		CombatConfig_SetCombatFiltersToDefault();
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_LFG_REMOVE_LAST_ROLE"] = {
	text = CONFIRM_LFG_REMOVE_LAST_ROLE,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		LFGFrameClearAllButton_OnClick();
		LFGFrame_UpdateRolesChosen();
	end,
	OnCancel = function(self)
		LFGFrame_UpdateRoleBoxes();
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["SET_LFGNOTE"] = {
	text = SET_COMMENT_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 63,
	hasWideEditBox = 1,
	OnAccept = function(self)
		SetLFGComment(self.wideEditBox:GetText());
	end,
	OnShow = function(self)
		--Sets the text to the 7th return from GetGuildRosterInfo(GetGuildRosterSelection());
		self.wideEditBox:SetText(select(9, GetLookingForGroup()));
		self.wideEditBox:SetFocus();
	end,
	OnHide = function(self)
		if ( ChatFrameEditBox:IsShown() ) then
			ChatFrameEditBox:SetFocus();
		end
		self.wideEditBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		SetLFGComment(self:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["SIMPLE_CHAT_OPTION_ENABLE_INTERRUPT"] = {
	text = SIMPLE_CHAT_OPTION_ENABLE_INTERRUPT,
	button1 = YES,
	button2 = CANCEL,
	OnAccept = function(self)
		InterfaceOptionsSocialPanelSimpleChat_ConfirmCheck();
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["ADVANCED_WATCHFRAME_OPTION_ENABLE_INTERRUPT"] = {
	text = ADVANCED_WATCHFRAME_OPTION_ENABLE_INTERRUPT,
	button1 = YES,
	button2 = CANCEL,
	OnAccept = function(self)
		InterfaceOptionsObjectivesPanelAdvancedWatchFrame_ConfirmUncheck();
	end,
	timeout = 0,
	whileDead = 1,
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
					OnCancel(frame, frame.data, "override");
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
					OnCancel(frame, frame.data, "override");
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
					OnCancel(frame, frame.data, "override");
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
					OnCancel(frame, frame.data, "override");
				end
			end
		end
	end

	-- Pick a free dialog to use
	local dialog = nil;
	-- Find an open dialog of the requested type
	dialog = StaticPopup_FindVisible(which, data);
	if ( dialog ) then
		if ( not StaticPopupDialogs[which].noCancelOnReuse ) then
			local OnCancel = StaticPopupDialogs[which].OnCancel;
			if ( OnCancel ) then
				OnCancel(dialog, dialog.data, "override");
			end
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
		 (which == "INSTANCE_LOCK") or
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
	dialog.enterClicksFirstButton = StaticPopupDialogs[which].enterClicksFirstButton;
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
				OnCancel(dialog, dialog.data, "timeout");
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
			 (which == "AREA_SPIRIT_HEAL")) then
			local text = getglobal(dialog:GetName().."Text");
			local hasText = nil;
			if ( text:GetText() ~= " " ) then
				hasText = 1;
			end
			timeleft = ceil(timeleft);
			if ( which == "INSTANCE_BOOT" ) then
				if ( timeleft < 60 ) then
					text:SetFormattedText(StaticPopupDialogs[which].text, timeleft, SECONDS);
				else
					text:SetFormattedText(StaticPopupDialogs[which].text, ceil(timeleft / 60), MINUTES);
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
		onUpdate(dialog, elapsed);
	end
end

function StaticPopup_EditBoxOnEnterPressed(self)
	local EditBoxOnEnterPressed, which, dialog;
	local parent = self:GetParent();
	if ( parent.which ) then
		which = parent.which;
		dialog = parent;
	elseif ( parent:GetParent().which ) then
		-- This is needed if this is a money input frame since it's nested deeper than a normal edit box
		which = parent:GetParent().which;
		dialog = parent:GetParent();
	end
	EditBoxOnEnterPressed = StaticPopupDialogs[which].EditBoxOnEnterPressed;
	if ( EditBoxOnEnterPressed ) then
		EditBoxOnEnterPressed(self, dialog.data);
	end
end

function StaticPopup_EditBoxOnEscapePressed(self)
	local EditBoxOnEscapePressed = StaticPopupDialogs[self:GetParent().which].EditBoxOnEscapePressed;
	if ( EditBoxOnEscapePressed ) then
		EditBoxOnEscapePressed(self, self:GetParent().data);
	end
end

function StaticPopup_EditBoxOnTextChanged(self)
	local EditBoxOnTextChanged = StaticPopupDialogs[self:GetParent().which].EditBoxOnTextChanged;
	if ( EditBoxOnTextChanged ) then
		EditBoxOnTextChanged(self, self:GetParent().data);
	end
end

function StaticPopup_OnShow(self)
	PlaySound("igMainMenuOpen");

	local dialog = StaticPopupDialogs[self.which];
	local OnShow = dialog.OnShow;

	if ( OnShow ) then
		OnShow(self, self.data);
	end
	if ( dialog.hasMoneyInputFrame ) then
		getglobal(self:GetName().."MoneyInputFrameGold"):SetFocus();
	end
	if ( dialog.enterClicksFirstButton ) then
		self:SetScript("OnKeyDown", StaticPopup_OnKeyDown);
	end
end

function StaticPopup_OnHide(self)
	PlaySound("igMainMenuClose");

	local dialog = StaticPopupDialogs[self.which];
	local OnHide = dialog.OnHide;
	if ( OnHide ) then
		OnHide(self, self.data);
	end
	if ( dialog.enterClicksFirstButton ) then
		self:SetScript("OnKeyDown", nil);
	end
end

function StaticPopup_OnClick(dialog, index)
	if ( not dialog:IsShown() ) then
		return;
	end
	local which = dialog.which;
	local dontHide = nil;
	if ( index == 1 ) then
		local OnAccept = StaticPopupDialogs[dialog.which].OnAccept;
		if ( OnAccept ) then
			dontHide = OnAccept(dialog, dialog.data, dialog.data2);
		end
	elseif ( index == 3 ) then
		local OnAlt = StaticPopupDialogs[dialog.which].OnAlt;
		if ( OnAlt ) then
			OnAlt(dialog, dialog.data, "clicked");
		end
	else
		local OnCancel = StaticPopupDialogs[dialog.which].OnCancel;
		if ( OnCancel ) then
			OnCancel(dialog, dialog.data, "clicked");
		end
	end

	if ( not dontHide and (which == dialog.which) ) then
		dialog:Hide();
	end
end

function StaticPopup_OnKeyDown(self, key)
	-- previously, StaticPopup_EscapePressed() captured the escape key for dialogs, but now we need
	-- to catch it here
	if ( GetBindingFromClick(key) == "TOGGLEGAMEMENU" ) then
		return StaticPopup_EscapePressed();
	elseif ( GetBindingFromClick(key) == "SCREENSHOT" ) then
		RunBinding("SCREENSHOT");
		return;
	end

	local dialog = StaticPopupDialogs[self.which];
	if ( dialog ) then
		if ( key == "ENTER" and dialog.enterClicksFirstButton ) then
			local frameName = self:GetName();
			local button;
			local i = 1;
			while ( true ) do
				button = getglobal(frameName.."Button"..i);
				if ( button ) then
					if ( button:IsShown() ) then
						StaticPopup_OnClick(self, i);
						return;
					end
					i = i + 1;
				else
					break;
				end
			end
		end
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
				OnCancel(frame, frame.data, "clicked");
			end
			frame:Hide();
			closed = 1;
		end
	end
	return closed;
end
