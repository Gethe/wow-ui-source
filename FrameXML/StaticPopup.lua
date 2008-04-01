
STATICPOPUP_NUMDIALOGS = 4;

StaticPopupDialogs = { };

StaticPopupDialogs["CLIENT_RESTART_ALERT"] = {
	text = TEXT(CLIENT_RESTART_ALERT),
	button1 = TEXT(OKAY),
	showAlert = 1,
	timeout = 0,
};

StaticPopupDialogs["CONFIRM_PROFESSION"] = {
	text = TEXT(format(PROFESSION_CONFIRMATION1, "XXX")),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	OnAccept = function()
		BuyTrainerService(ClassTrainerFrame.selectedService);
		ClassTrainerFrame.showSkillDetails = nil;
		ClassTrainer_SetSelection(ClassTrainerFrame.selectedService);
		ClassTrainerFrame_Update();
	end,
	OnShow = function()
		local cp1, cp2 = UnitCharacterPoints("player");
		if ( cp2 < MAX_LEARNABLE_PROFESSIONS ) then
			getglobal(this:GetName().."Text"):SetText(format(PROFESSION_CONFIRMATION2, GetTrainerServiceSkillLine(ClassTrainerFrame.selectedService)));
		else
			getglobal(this:GetName().."Text"):SetText(format(PROFESSION_CONFIRMATION1, GetTrainerServiceSkillLine(ClassTrainerFrame.selectedService)));
		end
	end,
	showAlert = 1,
	timeout = 0,
};

StaticPopupDialogs["CANCEL_AUCTION"] = {
	text = TEXT(CANCEL_AUCTION_CONFIRMATION),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	OnAccept = function()
		CancelAuction(GetSelectedAuctionItem("owner"));
	end,
	OnShow = function()
		MoneyFrame_Update(this:GetName().."MoneyFrame", AuctionFrameAuctions.cancelPrice);
		if ( AuctionFrameAuctions.cancelPrice > 0 ) then
			getglobal(this:GetName().."Text"):SetText(CANCEL_AUCTION_CONFIRMATION_MONEY);
		else
			getglobal(this:GetName().."Text"):SetText(CANCEL_AUCTION_CONFIRMATION);
		end
		
	end,
	hasMoneyFrame = 1,
	showAlert = 1,
	timeout = 0,
};

StaticPopupDialogs["MEMORY_EXHAUSTED"] = {
	text = TEXT(MEMORY_EXHAUSTED),
	button1 = TEXT(QUIT_NOW),
	OnAccept = function()
		ForceQuit();
	end,
	timeout = 0,
	whileDead = 1,
};

StaticPopupDialogs["COD_ALERT"] = {
	text = TEXT(COD_INSUFFICIENT_MONEY),
	button1 = TEXT(CLOSE),
	timeout = 0,
};

StaticPopupDialogs["COD_CONFIRMATION"] = {
	text = TEXT(COD_CONFIRMATION),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	OnAccept = function()
		TakeInboxItem(InboxFrame.openMailID);
	end,
	OnShow = function()
		MoneyFrame_Update(this:GetName().."MoneyFrame", OpenMailFrame.cod);
	end,
	hasMoneyFrame = 1,
	timeout = 0,
};

StaticPopupDialogs["BUYOUT_AUCTION"] = {
	text = TEXT(BUYOUT_AUCTION_CONFIRMATION),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	OnAccept = function()
		PlaceAuctionBid(AuctionFrame.type, GetSelectedAuctionItem(AuctionFrame.type), AuctionFrame.buyoutPrice);
	end,
	OnShow = function()
		MoneyFrame_Update(this:GetName().."MoneyFrame", AuctionFrame.buyoutPrice);
	end,
	hasMoneyFrame = 1,
	showAlert = 1,
	timeout = 0,
};

StaticPopupDialogs["DELETE_MAIL"] = {
	text = TEXT(DELETE_MAIL_CONFIRMATION),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	OnAccept = function()
		DeleteInboxItem(InboxFrame.openMailID);
		InboxFrame.openMailID = nil;
		HideUIPanel(OpenMailFrame);
	end,
	showAlert = 1,
	timeout = 0,
};

StaticPopupDialogs["DELETE_MONEY"] = {
	text = TEXT(DELETE_MONEY_CONFIRMATION),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
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
};

StaticPopupDialogs["SEND_MONEY"] = {
	text = TEXT(SEND_MONEY_CONFIRMATION),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
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
};

StaticPopupDialogs["JOIN_CHANNEL"] = {
	text = TEXT(ADD_CHANNEL),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	hasEditBox = 1,
	maxLetters = 31,
	whileDead = 1,
	OnAccept = function()
		local channel = getglobal(this:GetParent():GetName().."EditBox"):GetText();
		JoinChannelByName(channel, nil, FCF_GetCurrentChatFrameID());
		ChatFrame_AddChannel(FCF_GetCurrentChatFrame(), channel);
		getglobal(this:GetParent():GetName().."EditBox"):SetText("");
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function()
		local channel = getglobal(this:GetParent():GetName().."EditBox"):GetText();
		JoinChannelByName(channel, nil, FCF_GetCurrentChatFrameID());
		ChatFrame_AddChannel(FCF_GetCurrentChatFrame(), channel);
		getglobal(this:GetParent():GetName().."EditBox"):SetText("");
		this:GetParent():Hide();
	end
};

StaticPopupDialogs["NAME_CHAT"] = {
	text = TEXT(NAME_CHAT_WINDOW),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
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
	end
};

StaticPopupDialogs["HELP_TICKET_ABANDON_CONFIRM"] = {
	text = TEXT(HELP_TICKET_ABANDON_CONFIRM),
	button1 = TEXT(YES),
	button2 = TEXT(NO),
	OnAccept = function(prevFrame)
		DeleteGMTicket();
	end,
	OnCancel = function(prevFrame)
	end,
	timeout = 0,
	whileDead = 1
}
StaticPopupDialogs["HELP_TICKET"] = {
	text = TEXT(HELP_TICKET_EDIT_ABANDON),
	button1 = TEXT(HELP_TICKET_EDIT),
	button2 = TEXT(HELP_TICKET_ABANDON),
	OnAccept = function()
		ShowUIPanel(HelpFrame);
		HelpFrame_ShowFrame("OpenTicket")
	end,
	OnCancel = function()
		local currentFrame = this:GetParent();
		local dialogFrame = StaticPopup_Show("HELP_TICKET_ABANDON_CONFIRM");
		dialogFrame.data = currentFrame;
	end,
	timeout = 0,
	whileDead = 1;
}
StaticPopupDialogs["PETRENAMECONFIRM"] = {
	text = TEXT(PET_RENAME_CONFIRMATION),
	button1 = TEXT(YES),
	button2 = TEXT(NO),
	OnAccept = function()
		PetRename(this:GetParent().data);
	end,
	timeout = 0
}
StaticPopupDialogs["DEATH"] = {
	text = TEXT(DEATH_RELEASE_TIMER),
	button1 = TEXT(DEATH_RELEASE),
	button2 = TEXT(USE_SOULSTONE),
	OnShow = function()
		this.timeleft = GetReleaseTimeRemaining();
	end,
	OnAccept = function()
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
	delayText = TEXT(RESURRECT_REQUEST_TIMER),
	text = TEXT(RESURRECT_REQUEST),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(DECLINE),
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
	notClosableByLogout = 1
};
StaticPopupDialogs["RESURRECT_NO_SICKNESS"] = {
	StartDelay = GetCorpseRecoveryDelay,
	delayText = TEXT(RESURRECT_REQUEST_NO_SICKNESS_TIMER),
	text = TEXT(RESURRECT_REQUEST_NO_SICKNESS),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(DECLINE),
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
	notClosableByLogout = 1
};
StaticPopupDialogs["TRADE"] = {
	text = TEXT(TRADE_WITH_QUESTION),
	button1 = TEXT(YES),
	button2 = TEXT(NO),
	OnAccept = function()
		BeginTrade();
	end,
	OnCancel = function()
		CancelTrade();
	end,
	timeout = 60
};
StaticPopupDialogs["PARTY_INVITE"] = {
	text = TEXT(INVITATION),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(DECLINE),
	sound = "igPlayerInvite",
	OnAccept = function()
		AcceptGroup();
	end,
	OnCancel = function()
		DeclineGroup();
	end,
	timeout = 60,
	whileDead = 1
};
StaticPopupDialogs["GUILD_INVITE"] = {
	text = TEXT(GUILD_INVITATION),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(DECLINE),
	OnAccept = function()
		AcceptGuild();
	end,
	OnCancel = function()
		DeclineGuild();
	end,
	timeout = 60,
	whileDead = 1
};
StaticPopupDialogs["CAMP"] = {
	text = TEXT(CAMP_TIMER),
	button1 = TEXT(CANCEL),
	--button2 = TEXT(CAMP_NOW),
	OnAccept = function()
		CancelLogout();
		--ForceLogout();
		-- uncomment the next line once forced logouts are completely implemented (they currently have a failure case)
		-- this.timeleft = 0;
	end,
	OnHide = function()
		if ( this.timeleft > 0 ) then
			CancelLogout();
		end
	end,
	timeout = 20,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["QUIT"] = {
	text = TEXT(QUIT_TIMER),
	button1 = TEXT(QUIT_NOW),
	button2 = TEXT(CANCEL),
	OnAccept = function()
		ForceQuit();
		this.timeleft = 0;
	end,
	OnHide = function()
		if ( this.timeleft > 0 ) then
			CancelLogout();
		end
	end,
	timeout = 20,
	whileDead = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["LOOT_BIND"] = {
	text = TEXT(LOOT_NO_DROP),
	button1 = TEXT(OKAY),
	button2 = TEXT(CANCEL),
	OnAccept = function(slot)
		LootSlot(slot);
	end,
	timeout = 0,
	exclusive = 1
};
StaticPopupDialogs["EQUIP_BIND"] = {
	text = TEXT(EQUIP_NO_DROP),
	button1 = TEXT(OKAY),
	button2 = TEXT(CANCEL),
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
	whileDead = 1
};
StaticPopupDialogs["AUTOEQUIP_BIND"] = {
	text = TEXT(EQUIP_NO_DROP),
	button1 = TEXT(OKAY),
	button2 = TEXT(CANCEL),
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
	whileDead = 1
};
StaticPopupDialogs["USE_BIND"] = {
	text = TEXT(USE_NO_DROP),
	button1 = TEXT(OKAY),
	button2 = TEXT(CANCEL),
	OnAccept = function()
		ConfirmBindOnUse();
	end,
	timeout = 0,
	exclusive = 1
};
StaticPopupDialogs["DELETE_ITEM"] = {
	text = TEXT(DELETE_ITEM),
	button1 = TEXT(YES),
	button2 = TEXT(NO),
	OnAccept = function()
		DeleteCursorItem();
	end,
	timeout = 0,
	exclusive = 1,
	showAlert = 1
};
StaticPopupDialogs["QUEST_ACCEPT"] = {
	text = TEXT(QUEST_ACCEPT),
	button1 = TEXT(YES),
	button2 = TEXT(NO),
	OnAccept = function()
		ConfirmAcceptQuest();
	end,
	timeout = 0,
	exclusive = 1
};
StaticPopupDialogs["ABANDON_PET"] = {
	text = TEXT(ABANDON_PET),
	button1 = TEXT(OKAY),
	button2 = TEXT(CANCEL),
	OnAccept = function()
		PetAbandon();
	end,
	timeout = 0,
	exclusive = 1
};
StaticPopupDialogs["ABANDON_QUEST"] = {
	text = TEXT(ABANDON_QUEST_CONFIRM),
	button1 = TEXT(YES),
	button2 = TEXT(NO),
	OnAccept = function()
		AbandonQuest();
		PlaySound("igQuestLogAbandonQuest");
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1
};
StaticPopupDialogs["ADD_FRIEND"] = {
	text = TEXT(ADD_FRIEND_LABEL),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
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
		if ( ChatFrameEditBox:IsVisible() ) then
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
	whileDead = 1
};
StaticPopupDialogs["ADD_IGNORE"] = {
	text = TEXT(ADD_IGNORE_LABEL),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
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
		if ( ChatFrameEditBox:IsVisible() ) then
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
	whileDead = 1
};
StaticPopupDialogs["ADD_GUILDMEMBER"] = {
	text = TEXT(ADD_GUILDMEMBER_LABEL),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	hasEditBox = 1,
	maxLetters = 12,
	OnAccept = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		GuildInviteByName(editBox:GetText());
	end,
	OnShow = function()
		getglobal(this:GetName().."EditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		GuildInviteByName(editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1
};
StaticPopupDialogs["ADD_RAIDMEMBER"] = {
	text = TEXT(ADD_RAIDMEMBER_LABEL),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	hasEditBox = 1,
	maxLetters = 12,
	OnAccept = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		InviteByName(editBox:GetText());
	end,
	OnShow = function()
		getglobal(this:GetName().."EditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		InviteByName(editBox:GetText());
		this:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function()
		this:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1
};
StaticPopupDialogs["REMOVE_GUILDMEMBER"] = {
	text = format(TEXT(REMOVE_GUILDMEMBER_LABEL), "XXX"),
	button1 = TEXT(YES),
	button2 = TEXT(NO),
	OnAccept = function()
		GuildUninviteByName(GuildFrame.selectedName);
	end,
	OnShow = function()
		getglobal(this:GetName().."Text"):SetText(format(TEXT(REMOVE_GUILDMEMBER_LABEL), GuildFrame.selectedName));
	end,
	timeout = 0,
	exclusive = 1
};
StaticPopupDialogs["ADD_GUILDRANK"] = {
	text = TEXT(ADD_GUILDRANK_LABEL),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	hasEditBox = 1,
	maxLetters = 15,
	OnAccept = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		GuildControlAddRank(editBox:GetText());
		--GuildRoster();
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
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	EditBoxOnEnterPressed = function()
		local editBox = getglobal(this:GetParent():GetName().."EditBox");
		GuildControlAddRank(editBox:GetText());
		--GuildRoster();
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
	exclusive = 1
};
StaticPopupDialogs["SET_GUILDMOTD"] = {
	text = TEXT(SET_GUILDMOTD_LABEL),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	hasEditBox = 1,
	maxLetters = 60,
	hasWideEditBox = 1,
	OnAccept = function()
		local editBox = getglobal(this:GetParent():GetName().."WideEditBox");
		GuildSetMOTD(editBox:GetText());
	end,
	OnShow = function()
		getglobal(this:GetName().."WideEditBox"):SetText(GetGuildRosterMOTD());
		getglobal(this:GetName().."WideEditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsVisible() ) then
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
	exclusive = 1
};
StaticPopupDialogs["SET_GUILDPLAYERNOTE"] = {
	text = TEXT(SET_GUILDPLAYERNOTE_LABEL),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	hasEditBox = 1,
	maxLetters = 31,
	hasWideEditBox = 1,
	OnAccept = function()
		local editBox = getglobal(this:GetParent():GetName().."WideEditBox");
		GuildRosterSetPublicNote(GetGuildRosterSelection(), editBox:GetText());
	end,
	OnShow = function()
		local name, rank, rankIndex, level, class, zone, group, note, officernote, online;
		name, rank, rankIndex, level, class, zone, group, note, officernote, online = GetGuildRosterInfo(GetGuildRosterSelection());

		getglobal(this:GetName().."WideEditBox"):SetText(note);
		getglobal(this:GetName().."WideEditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsVisible() ) then
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
	exclusive = 1
};
StaticPopupDialogs["SET_GUILDOFFICERNOTE"] = {
	text = TEXT(SET_GUILDOFFICERNOTE_LABEL),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	hasEditBox = 1,
	maxLetters = 31,
	hasWideEditBox = 1,
	OnAccept = function()
		local editBox = getglobal(this:GetParent():GetName().."WideEditBox");
		GuildRosterSetOfficerNote(GetGuildRosterSelection(), editBox:GetText());
	end,
	OnShow = function()
		local name, rank, rankIndex, level, class, zone, group, note, officernote, online;
		name, rank, rankIndex, level, class, zone, group, note, officernote, online = GetGuildRosterInfo(GetGuildRosterSelection());

		getglobal(this:GetName().."WideEditBox"):SetText(officernote);
		getglobal(this:GetName().."WideEditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsVisible() ) then
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
	exclusive = 1
};
StaticPopupDialogs["RENAME_PET"] = {
	text = TEXT(PET_RENAME_LABEL),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	hasEditBox = 1,
	maxLetters = 16,
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
	end,
	OnShow = function()
		getglobal(this:GetName().."EditBox"):SetFocus();
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	timeout = 0,
	exclusive = 1
};
StaticPopupDialogs["DUEL_REQUESTED"] = {
	text = TEXT(DUEL_REQUESTED),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(DECLINE),
	sound = "igPlayerInvite",
	OnAccept = function()
		AcceptDuel();
	end,
	OnCancel = function()
		CancelDuel();
	end,
	timeout = 60,
};
StaticPopupDialogs["DUEL_OUTOFBOUNDS"] = {
	text = TEXT(DUEL_OUTOFBOUNDS_TIMER),
	timeout = 10,
};
StaticPopupDialogs["UNLEARN_SKILL"] = {
	text = TEXT(UNLEARN_SKILL),
	button1 = TEXT(UNLEARN),
	button2 = TEXT(CANCEL),
	OnAccept = function(index)
		AbandonSkill(index);
	end,
	timeout = 60,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1
};
StaticPopupDialogs["XP_LOSS"] = {
	text = TEXT(CONFIRM_XP_LOSS),
	button1 = TEXT(YES),
	button2 = TEXT(NO),
	OnAccept = function(data)
		if ( data ) then
			getglobal(this:GetParent():GetName().."Text"):SetText(format(TEXT(CONFIRM_XP_LOSS_AGAIN), data));
			this:GetParent().data = nil;
			return 1;
		else
			AcceptXPLoss();
		end
	end,
	OnUpdate = function(elapsed)
		if ( not CheckSpiritHealerDist() ) then
			this:Hide();
		end
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1
};
StaticPopupDialogs["XP_LOSS_NO_SICKNESS"] = {
	text = TEXT(CONFIRM_XP_LOSS_NO_SICKNESS),
	button1 = TEXT(YES),
	button2 = TEXT(NO),
	OnAccept = function(data)
		if ( data ) then
			getglobal(this:GetParent():GetName().."Text"):SetText(TEXT(CONFIRM_XP_LOSS_AGAIN_NO_SICKNESS));
			this:GetParent().data = nil;
			return 1;
		else
			AcceptXPLoss();
		end
	end,
	OnUpdate = function(elapsed)
		if ( not CheckSpiritHealerDist() ) then
			this:Hide();
		end
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1
};
StaticPopupDialogs["RECOVER_CORPSE"] = {
	StartDelay = GetCorpseRecoveryDelay,
	delayText = TEXT(RECOVER_CORPSE_TIMER),
	text = TEXT(RECOVER_CORPSE),
	button1 = TEXT(ACCEPT),
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
	text = TEXT(RECOVER_CORPSE_INSTANCE),
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1
};
StaticPopupDialogs["REPLACE_ENCHANT"] = {
	text = TEXT(REPLACE_ENCHANT),
	button1 = TEXT(YES),
	button2 = TEXT(NO),
	OnAccept = function()
		ReplaceEnchant();
	end,
	timeout = 0,
	exclusive = 1,
	showAlert = 1
};
StaticPopupDialogs["TRADE_REPLACE_ENCHANT"] = {
	text = TEXT(REPLACE_ENCHANT),
	button1 = TEXT(YES),
	button2 = TEXT(NO),
	OnAccept = function()
		ReplaceTradeEnchant();
	end,
	timeout = 0,
	exclusive = 1,
	showAlert = 1
};
StaticPopupDialogs["INSTANCE_BOOT"] = {
	text = TEXT(INSTANCE_BOOT_TIMER),
	OnShow = function()
		this.timeleft = GetInstanceBootTimeRemaining();
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1
};
StaticPopupDialogs["CONFIRM_TALENT_WIPE"] = {
	text = TEXT(CONFIRM_TALENT_WIPE),
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	OnAccept = function()
		ConfirmTalentWipe();
	end,
	OnUpdate = function(elapsed)
		if ( not CheckTalentMasterDist() ) then
			this:Hide();
		end
	end,
	hasMoneyFrame = 1,
	timeout = 0,
};
StaticPopupDialogs["CONFIRM_SUMMON"] = {
	text = TEXT(CONFIRM_SUMMON);
	button1 = TEXT(ACCEPT),
	button2 = TEXT(CANCEL),
	OnShow = function()
		this.timeleft = GetSummonConfirmTimeLeft();
	end,
	OnAccept = function()
		ConfirmSummon();
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1
};
StaticPopupDialogs["BILLING_NAG"] = {
	text = TEXT(BILLING_NAG_DIALOG);
	button1 = TEXT(MANAGE_ACCOUNT),
	button2 = TEXT(CANCEL),
	OnAccept = function()
		LaunchURL(TEXT(AUTH_NO_TIME_URL));
	end,
	timeout = 0,
	showAlert = 1
};

function StaticPopup_FindVisible(which)
	for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
		local frame = getglobal("StaticPopup"..index);
		if ( frame:IsVisible() and (frame.which == which) ) then
			return frame;
		end
	end
	return nil;
end

function StaticPopup_Resize(dialog, which)
	local text = getglobal(dialog:GetName().."Text");
	local editBox = getglobal(dialog:GetName().."EditBox");
	local button1 = getglobal(dialog:GetName().."Button1");
	if ( StaticPopupDialogs[which].hasEditBox ) then
		dialog:SetHeight(16 + text:GetHeight() + 8 + editBox:GetHeight() + 8 + button1:GetHeight() + 16);
	elseif ( StaticPopupDialogs[which].hasMoneyFrame ) then
		dialog:SetHeight(16 + text:GetHeight() + 8 + button1:GetHeight() + 32);
	else
		dialog:SetHeight(16 + text:GetHeight() + 8 + button1:GetHeight() + 16);
	end
end

function StaticPopup_Show(which, text_arg1, text_arg2)
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
			if ( frame:IsVisible() and StaticPopupDialogs[frame.which].exclusive ) then
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
			if ( frame:IsVisible() and (frame.which == info.cancels) ) then
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
			if ( frame:IsVisible() and not StaticPopupDialogs[frame.which].notClosableByLogout ) then
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
			if ( frame:IsVisible() and not StaticPopupDialogs[frame.which].whileDead ) then
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
	if ( not dialog ) then
		-- Find an open dialog of the requested type
		dialog = StaticPopup_FindVisible(which);
		if ( dialog ) then
			local OnCancel = StaticPopupDialogs[which].OnCancel;
			if ( OnCancel ) then
				OnCancel(dialog.data, "override");
			end
			dialog:Hide();
		end
	end
	if ( not dialog ) then
		-- Find a free dialog
		for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
			local frame = getglobal("StaticPopup"..index);
			if ( not frame:IsVisible() ) then
				dialog = frame;
				break;
			end
		end
	end
	if ( not dialog ) then
		info.OnCancel();
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
		 (which == "CONFIRM_SUMMON") ) then
		text:SetText(" ");	-- The text will be filled in later.
		text.text_arg1 = text_arg1;
		text.text_arg2 = text_arg2;
	elseif ( which == "BILLING_NAG" ) then
		if ( text_arg1 < 60 ) then
			text:SetText(format(StaticPopupDialogs[which].text, text_arg1, GetText("MINUTES", nil, text_arg1)));
		elseif ( text_arg1 < (60 * 24) ) then
			text:SetText(format(StaticPopupDialogs[which].text, ceil(text_arg1 / 60), GetText("HOURS", nil, ceil(text_arg1 / 60))));
		else
			text:SetText(format(StaticPopupDialogs[which].text, ceil(text_arg1 / (60 * 24)), GetText("DAYS", nil, ceil(text_arg1 / (60 * 24)))));
		end
	else
		text:SetText(format(StaticPopupDialogs[which].text, text_arg1, text_arg2));
	end
	
	-- If is any of the guild message popups
	local wideEditBox = getglobal(dialog:GetName().."WideEditBox");
	local editBox = getglobal(dialog:GetName().."EditBox");
	local alertIcon = getglobal(dialog:GetName().."AlertIcon");
	alertIcon:Hide();
	dialog:SetWidth(320);
	if ( (which == "SET_GUILDMOTD") or (which == "SET_GUILDPLAYERNOTE") or (which == "SET_GUILDPLAYERNOTE") or (which == "SET_GUILDOFFICERNOTE" )) then
		-- Widen
		dialog:SetWidth(420);
	elseif ( info.showAlert ) then
		-- If is the delete item dialog display the error image
		dialog:SetWidth(420);
		alertIcon:Show();
	end

	-- If is the ticket edit dialog then show the close button
	if ( which == "HELP_TICKET" ) then
		getglobal(dialog:GetName().."CloseButton"):Show();
		dialog:SetWidth(350);
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
	else
		getglobal(dialog:GetName().."MoneyFrame"):Hide();
	end

	-- Set the buttons of the dialog
	local button1 = getglobal(dialog:GetName().."Button1");
	local button2 = getglobal(dialog:GetName().."Button2");
	if ( StaticPopupDialogs[which].button2 and
	   ( not StaticPopupDialogs[which].DisplayButton2 or StaticPopupDialogs[which].DisplayButton2() ) ) then
		button1:ClearAllPoints();
		button2:ClearAllPoints();
		if ( StaticPopupDialogs[which].hasEditBox ) then
			button1:SetPoint("TOPRIGHT", editBox:GetName(), "BOTTOM", -6, -8);
			button2:SetPoint("LEFT", button1:GetName(), "RIGHT", 13, 0);
		elseif ( StaticPopupDialogs[which].hasMoneyFrame ) then
			button1:SetPoint("TOPRIGHT", text:GetName(), "BOTTOM", -6, -24);
			button2:SetPoint("LEFT", button1:GetName(), "RIGHT", 13, 0);
		else
			button1:SetPoint("TOPRIGHT", text:GetName(), "BOTTOM", -6, -8);
			button2:SetPoint("LEFT", button1:GetName(), "RIGHT", 13, 0);
		end
		button2:SetText(StaticPopupDialogs[which].button2);
		local width = button2:GetTextWidth();
		if ( width > 110 ) then
			button2:SetWidth(width + 20);
		else
			button2:SetWidth(120);
		end
		button2:Show();
	else
		button1:ClearAllPoints();
		button1:SetPoint("TOP", text:GetName(), "BOTTOM", 0, -8);
		button2:Hide();
	end
	if ( StaticPopupDialogs[which].button1 ) then
		button1:SetText(StaticPopupDialogs[which].button1);
		local width = button1:GetTextWidth();
		if ( width > 120 ) then
			button1:SetWidth(width + 20);
		else
			button1:SetWidth(120);
		end
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
	StaticPopup_Resize(dialog, which);
	dialog:Show();

	if ( StaticPopupDialogs[which].sound ) then
		PlaySound(StaticPopupDialogs[which].sound);
	end

	return dialog;
end

function StaticPopup_Hide(which)
	for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
		local dialog = getglobal("StaticPopup"..index);
		if ( dialog.which == which ) then
			dialog:Hide();
		end
	end
end

function StaticPopup_OnUpdate(elapsed)
	if ( this.timeleft > 0 ) then
		local which = this.which;
		local timeleft = this.timeleft - elapsed;
		if ( timeleft <= 0 ) then
			this.timeleft = 0;
			local OnCancel = StaticPopupDialogs[which].OnCancel;
			if ( OnCancel ) then
				OnCancel(this.data, "timeout");
			end
			this:Hide();
			return;
		end
		this.timeleft = timeleft;

		if ( (which == "DEATH") or
		     (which == "CAMP")  or
			 (which == "QUIT") or
			 (which == "DUEL_OUTOFBOUNDS") or
			 (which == "INSTANCE_BOOT") or
			 (which == "CONFIRM_SUMMON") ) then
			local text = getglobal(this:GetName().."Text");
			local hasText = nil;
			if ( text:GetText() ~= " " ) then
				hasText = 1;
			end
			timeleft = ceil(timeleft);
			if ( which == "INSTANCE_BOOT" ) then
				if ( timeleft < 60 ) then
					text:SetText(format(StaticPopupDialogs[which].text, GetBindLocation(), timeleft, GetText("SECONDS", nil, timeleft)));
				else
					text:SetText(format(StaticPopupDialogs[which].text, GetBindLocation(), ceil(timeleft / 60), GetText("MINUTES", nil, ceil(timeleft / 60))));
				end
			elseif ( which == "CONFIRM_SUMMON" ) then
				if ( timeleft < 60 ) then
					text:SetText(format(StaticPopupDialogs[which].text, GetSummonConfirmSummoner(), GetSummonConfirmAreaName(), timeleft, GetText("SECONDS", nil, timeleft)));
				else
					text:SetText(format(StaticPopupDialogs[which].text, GetSummonConfirmSummoner(), GetSummonConfirmAreaName(), ceil(timeleft / 60), GetText("MINUTES", nil, ceil(timeleft / 60))));
				end
			else
				if ( timeleft < 60 ) then
					text:SetText(format(StaticPopupDialogs[which].text, timeleft, GetText("SECONDS", nil, timeleft)));
				else
					text:SetText(format(StaticPopupDialogs[which].text, ceil(timeleft / 60), GetText("MINUTES", nil, ceil(timeleft / 60))));
				end
			end
			if ( not hasText ) then
				StaticPopup_Resize(this, which);
			end
		end
	end
	if ( this.startDelay ) then
		local which = this.which;
		local timeleft = this.startDelay - elapsed;
		if ( timeleft <= 0 ) then
			this.startDelay = nil;
			local text = getglobal(this:GetName().."Text");
			text:SetText(format(StaticPopupDialogs[which].text, text.text_arg1, text.text_arg2));
			local button1 = getglobal(this:GetName().."Button1");
			button1:Enable();
			StaticPopup_Resize(this, which);
			return;
		end
		this.startDelay = timeleft;

		if ( which == "RECOVER_CORPSE" or (which == "RESURRECT") or (which == "RESURRECT_NO_SICKNESS") ) then
			local text = getglobal(this:GetName().."Text");
			local hasText = nil;
			if ( text:GetText() ~= " " ) then
				hasText = 1;
			end
			timeleft = ceil(timeleft);
			if ( (which == "RESURRECT") or (which == "RESURRECT_NO_SICKNESS") ) then
				if ( timeleft < 60 ) then
					text:SetText(format(StaticPopupDialogs[which].delayText, text.text_arg1, timeleft, GetText("SECONDS", nil, timeleft)));
				else
					text:SetText(format(StaticPopupDialogs[which].delayText, text.text_arg1, ceil(timeleft / 60), GetText("MINUTES", nil, ceil(timeleft / 60))));
				end
			else
				if ( timeleft < 60 ) then
					text:SetText(format(StaticPopupDialogs[which].delayText, timeleft, GetText("SECONDS", nil, timeleft)));
				else
					text:SetText(format(StaticPopupDialogs[which].delayText, ceil(timeleft / 60), GetText("MINUTES", nil, ceil(timeleft / 60))));
				end
			end
			if ( not hasText ) then
				StaticPopup_Resize(this, which);
			end
		end
	end

	local onUpdate = StaticPopupDialogs[this.which].OnUpdate;
	if ( onUpdate ) then
		onUpdate(elapsed);
	end
end

function StaticPopup_EditBoxOnEnterPressed()
	local EditBoxOnEnterPressed = StaticPopupDialogs[this:GetParent().which].EditBoxOnEnterPressed;
	if ( EditBoxOnEnterPressed ) then
		EditBoxOnEnterPressed(this:GetParent().data);
		this:GetParent():Hide();
	end
end

function StaticPopup_EditBoxOnEscapePressed()
	local EditBoxOnEscapePressed = StaticPopupDialogs[this:GetParent().which].EditBoxOnEscapePressed;
	if ( EditBoxOnEscapePressed ) then
		EditBoxOnEscapePressed(this:GetParent().data);
	end
end

function StaticPopup_OnShow()
	PlaySound("igMainMenuOpen");

	local OnShow = StaticPopupDialogs[this.which].OnShow;
	if ( OnShow ) then
		OnShow(this.data);
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
	local dontHide = nil;
	if ( index == 1 ) then
		local OnAccept = StaticPopupDialogs[dialog.which].OnAccept;
		if ( OnAccept ) then
			dontHide = OnAccept(dialog.data);
		end
	else
		local OnCancel = StaticPopupDialogs[dialog.which].OnCancel;
		if ( OnCancel ) then
			OnCancel(dialog.data, "clicked");
		end
	end
	-- this if is a temporary hack; it will be going away once ForcedLogout is completely implemented!
--	if ( (index ~= 2) and (dialog.which == "CAMP") ) then
--		return;
--	end

	if ( not dontHide ) then
		dialog:Hide();
	end
end

function StaticPopup_Visible(which)
	for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
		local frame = getglobal("StaticPopup"..index);
		if( frame:IsVisible() and (frame.which == which) ) then 
			return 1;
		end
	end
	return nil;
end

function StaticPopup_EscapePressed()
	local closed = nil;
	for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
		local frame = getglobal("StaticPopup"..index);
		if( frame:IsVisible() and frame.hideOnEscape ) then 
			frame:Hide();
			closed = 1;
		end
	end
	return closed;
end