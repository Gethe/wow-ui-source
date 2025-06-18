local function SetupLockOnDeclineButtonAndEscape(self, declineTimeLeft)
	self.declineTimeLeft = declineTimeLeft or .5;
	self.button2:SetButtonState("NORMAL", true);
	self.ticker = C_Timer.NewTicker(.5, function()
		self.declineTimeLeft = self.declineTimeLeft - .5;
		if (self.declineTimeLeft == 0) then
			self.ticker:Cancel();
			self.button2:SetButtonState("NORMAL", false);
			return;
		else
			self.button2:SetButtonState("NORMAL", true);
		end
	end);
	self.hideOnEscape = false;
end

local function GetSelfResurrectDialogOptions()
	local resOptions = GetSortedSelfResurrectOptions();
	if ( resOptions ) then
		if ( IsEncounterLimitingResurrections() ) then
			return resOptions[1], resOptions[2];
		else
			return resOptions[1];
		end
	end
end

local function OnResurrectButtonClick(selectedOption, reason)
	if ( reason == "override" ) then
		return;
	end
	if ( reason == "timeout" ) then
		return;
	end
	if ( reason == "clicked" ) then
		local found = false;
		local resOptions = C_DeathInfo.GetSelfResurrectOptions();
		if ( resOptions ) then
			for i, option in pairs(resOptions) do
				if ( option.optionType == selectedOption.optionType and option.id == selectedOption.id and option.canUse ) then
					C_DeathInfo.UseSelfResurrectOption(option.optionType, option.id);
					found = true;
					break;
				end
			end
		end
		if ( not found ) then
			RepopMe();
		end
		if ( CannotBeResurrected() ) then
			return true;
		end
	end
end

StaticPopupDialogs["GENERIC_CONFIRMATION"] = {
	text = "",		-- supplied dynamically.
	button1 = "",	-- supplied dynamically.
	button2 = "",	-- supplied dynamically.
	OnShow = function(self, data)
		self.text:SetFormattedText(data.text, data.text_arg1, data.text_arg2);
		self.button1:SetText(data.acceptText or YES);
		self.button2:SetText(data.cancelText or NO);

		if data.showAlert then
			self.AlertIcon:Show();
		end
	end,
	OnAccept = function(self, data)
		data.callback();
	end,
	OnCancel = function(self, data)
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
	OnShow = function(self, data)
		self.text:SetFormattedText(data.text, data.text_arg1, data.text_arg2);
		self.button1:SetText(data.acceptText or DONE);
		self.button2:SetText(data.cancelText or CANCEL);

		self.editBox:SetMaxLetters(data.maxLetters or 24);
		self.editBox:SetCountInvisibleLetters(not not data.countInvisibleLetters);
	end,
	OnAccept = function(self, data)
		local text = self.editBox:GetText();
		data.callback(text);
	end,
	OnCancel = function(self, data)
		local cancelCallback = data.cancelCallback;
		if cancelCallback ~= nil then
			cancelCallback();
		end
	end,
	EditBoxOnEnterPressed = function(self, data)
		local parent = self:GetParent();
		if parent.button1:IsEnabled() then
			local text = parent.editBox:GetText();
			data.callback(text);
			parent:Hide();
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
	hasDropDown = 1,
	dropDownOptions = {};
	OnShow = function(self, data)
		self.text:SetText(data.text);
		self.DropDownControl:SetOptions(data.options, data.defaultOption);

		local hasButtons = not not data.hasButtons;
		self.button1:SetShown(hasButtons);
		self.button2:SetShown(hasButtons);

		if hasButtons then
			self.DropDownControl:SetOptionSelectedCallback(nil);
		else
			local function StaticPopupGenericDropDownOptionSelectedCallback(option)
				data.callback(option);
				self:Hide();
			end

			self.DropDownControl:SetOptionSelectedCallback(StaticPopupGenericDropDownOptionSelectedCallback);
		end
	end,
	OnAccept = function(self, data)
		data.callback(self.DropDownControl:GetSelectedValue());
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
	OnAccept = function (self) C_EquipmentSet.SaveEquipmentSet(self.data, self.selectedIcon); GearManagerDialogPopup:Hide(); end,
	OnCancel = function (self) end,
	OnHide = function (self) self.data = nil; self.selectedIcon = nil; end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
}

StaticPopupDialogs["CONFIRM_SAVE_EQUIPMENT_SET"] = {
	text = CONFIRM_SAVE_EQUIPMENT_SET,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self) C_EquipmentSet.SaveEquipmentSet(self.data); end,
	OnCancel = function (self) end,
	OnHide = function (self) self.data = nil; end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
}


StaticPopupDialogs["ERROR_CINEMATIC"] = {
	text = ERROR_CINEMATIC,
	button1 = OKAY,
	button2 = nil,
	timeout = 0,
	OnAccept = function()
	end,
	OnCancel = function()
	end,
	whileDead = 1,
	hideOnEscape = 1,
}

StaticPopupDialogs["ERR_SOR_STARTING_EXPERIENCE_INCOMPLETE"] = {
	text = ERR_SOR_STARTING_EXPERIENCE_INCOMPLETE,
	button1 = OKAY,
	button2 = nil,
	timeout = 0,
	OnAccept = function()
	end,
	OnCancel = function()
	end,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,
}

StaticPopupDialogs["CONFIRM_DELETE_EQUIPMENT_SET"] = {
	text = CONFIRM_DELETE_EQUIPMENT_SET,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self) C_EquipmentSet.DeleteEquipmentSet(self.data); end,
	OnCancel = function (self) end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
}

StaticPopupDialogs["CONFIRM_RESET_TEXTTOSPEECH_SETTINGS"] = {
	text = CONFIRM_TEXT_TO_SPEECH_RESET,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function ()
		TextToSpeechFrame_SetToDefaults();
	end,
	OnCancel = function() end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	whileDead = 1,
}

StaticPopupDialogs["CONFIRM_REDOCK_CHAT"] = {
	text = CONFIRM_REDOCK_CHAT,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function ()
		RedockChatWindows();
	end,
	OnCancel = function() end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	whileDead = 1,
}

StaticPopupDialogs["MAC_OPEN_UNIVERSAL_ACCESS"] = {
	text = MAC_OPEN_UNIVERSAL_ACCESS,
	button1 = YES,
	button2 = NO,
	OnAccept = function ()
		C_MacOptions.OpenUniversalAccess();
		ShowUIPanel(MacOptionsFrame);
	end,
	OnCancel = function()
		ShowUIPanel(MacOptionsFrame);
	end,
	OnShow = function(self)
		if (MAC_OPEN_UNIVERSAL_ACCESS1090 ~= nil) then
			self.text:SetFormattedText(MAC_OPEN_UNIVERSAL_ACCESS1090, C_MacOptions.GetGameBundleName());
		else
			self.text:SetText(MAC_OPEN_UNIVERSAL_ACCESS);
		end
	end,
	showAlert = 1,
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

StaticPopupDialogs["CONFIRM_PURCHASE_NONREFUNDABLE_ITEM"] = {
	text = CONFIRM_PURCHASE_NONREFUNDABLE_ITEM,
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

StaticPopupDialogs["CONFIRM_UPGRADE_ITEM"] = {
	text = CONFIRM_UPGRADE_ITEM,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		C_ItemUpgrade.UpgradeItem(1);
		PlaySound(SOUNDKIT.UI_REFORGING_REFORGE);
	end,
	OnCancel = function()
		ItemUpgradeFrame:Update();
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
		C_Container.ContainerRefundItemPurchase(MerchantFrame.refundBag, MerchantFrame.refundSlot, MerchantFrame.refundItemEquipped);
		StackSplitFrame:Hide();
	end,
	OnCancel = function()
		ClearCursor();
	end,
	OnShow = function(self)
		if(MerchantFrame.price ~= 0) then
			MoneyFrame_Update(self.moneyFrame, MerchantFrame.price);
		end
	end,
	OnHide = function()
		MerchantFrame_ResetRefundItem();
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
		C_Container.ContainerRefundItemPurchase(MerchantFrame.refundBag, MerchantFrame.refundSlot);
		StackSplitFrame:Hide();
	end,
	OnCancel = function()
		ClearCursor();
	end,
	OnShow = function()

	end,
	OnHide = function()
		MerchantFrame_ResetRefundItem();
	end,
	timeout = 0,
	hideOnEscape = 1,
}

StaticPopupDialogs["CONFIRM_REFUND_MAX_ARENA_POINTS"] = {
	text = CONFIRM_REFUND_MAX_ARENA_POINTS,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		C_Container.ContainerRefundItemPurchase(MerchantFrame.refundBag, MerchantFrame.refundSlot);
		StackSplitFrame:Hide();
	end,
	OnCancel = function()
		ClearCursor();
	end,
	OnShow = function()

	end,
	OnHide = function()
		MerchantFrame_ResetRefundItem();
	end,
	timeout = 0,
	hideOnEscape = 1,
}

StaticPopupDialogs["CONFIRM_REFUND_MAX_HONOR_AND_ARENA"] = {
	text = CONFIRM_REFUND_MAX_HONOR_AND_ARENA,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		C_Container.ContainerRefundItemPurchase(MerchantFrame.refundBag, MerchantFrame.refundSlot);
		StackSplitFrame:Hide();
	end,
	OnCancel = function()
		ClearCursor();
	end,
	OnShow = function()

	end,
	OnHide = function()
		MerchantFrame_ResetRefundItem();
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
		GetQuestReward(QuestInfoFrame.itemChoice);
		PlaySound(SOUNDKIT.IG_QUEST_LIST_COMPLETE);
	end,
	OnCancel = function()
		DeclineQuest();
		PlaySound(SOUNDKIT.IG_QUEST_CANCEL);
	end,
	OnShow = function()
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
	OnAccept = function()
		AcceptQuest();
	end,
	OnCancel = function()
		DeclineQuest();
		PlaySound(SOUNDKIT.IG_QUEST_CANCEL);
	end,
	OnShow = function()
		QuestFrameAcceptButton:Disable();
		QuestFrameDeclineButton:Disable();
	end,
	OnHide = function()
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
	OnAccept = function()
		RepairAllItems();
		PlaySound(SOUNDKIT.ITEM_REPAIR);
	end,
	OnCancel = function ()
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
StaticPopupDialogs["CONFIRM_BUY_REAGENTBANK_TAB"] = {
	text = CONFIRM_BUY_REAGNETBANK_TAB,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		BuyReagentBank();
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, GetReagentBankCost());
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
	OnAccept = function(self)
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
	OnAccept = function(self)
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
	OnAccept = function(self)
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
	OnAccept = function(self)
		C_GuildInfo.Disband();
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["ADD_TEAMMEMBER"] = {
	text = ADD_TEAMMEMBER_LABEL,
	button1 = INVITE,
	button2 = CANCEL,
	hasEditBox = 1,
	autoCompleteParams = AUTOCOMPLETE_LIST.TEAM_INVITE,
	maxLetters = 77,
	OnAccept = function(self)
		if( GetCurrentArenaSeasonUsesTeams() ) then
			ArenaTeamInviteByName(PVPTeamDetails.team, self.editBox:GetText());
		end
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		if( GetCurrentArenaSeasonUsesTeams() ) then
			local parent = self:GetParent();
			ArenaTeamInviteByName(PVPTeamDetails.team, parent.editBox:GetText());
			parent:Hide();
		end
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_TEAM_DISBAND"] = {
	text = CONFIRM_TEAM_DISBAND,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function (self)
		ArenaTeamDisband(self.data);
	end,
	OnCancel = function (self)
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_TEAM_LEAVE"] = {
	text = CONFIRM_TEAM_LEAVE,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		ArenaTeamLeave(self.data);
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
		ArenaTeamSetLeaderByName(self.data, name);
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
		ArenaTeamUninviteByName(self.data, name);
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
	timeout = STATICPOPUP_TIMEOUT,
	whileDead = 1,
	hideOnEscape = 1
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
	OnAccept = function(self, data)
		if ( data == "LootWindow" ) then
			MasterLooterFrame_GiveMasterLoot();
		elseif ( data == "LootHistory" ) then
			LootHistoryDropdown_GiveMasterLoot();
		end
	end,
	timeout = 0,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"] = {
	text = CONFIRM_BATTLEFIELD_ENTRY,
	button1 = ENTER_BATTLE,
	button2 = HIDE,
	OnAccept = function(self, data)
		if ( not AcceptBattlefieldPort(data, true) ) then
			return 1;
		end
		if( StaticPopup_Visible( "DEATH" ) ) then
			StaticPopup_Hide( "DEATH" );
		end
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	noCancelOnEscape = 1,
	noCancelOnReuse = 1,
	multiple = 1
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
	OnShow = function(self)
		SetupLockOnDeclineButtonAndEscape(self);
	end,
	OnAccept = function(self, battleID)
		BattlefieldMgrQueueInviteResponse(battleID,1);
	end,
	OnCancel = function(self, battleID)
		BattlefieldMgrQueueInviteResponse(battleID,0);
	end,
	timeout = 0,
	whileDead = 1,
	multiple = 1
};

StaticPopupDialogs["BFMGR_INVITED_TO_QUEUE_WARMUP"] = {
	text = WORLD_PVP_INVITED_WARMUP;
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function(self)
		SetupLockOnDeclineButtonAndEscape(self);
	end,
	OnAccept = function(self, battleID)
		BattlefieldMgrQueueInviteResponse(battleID,1);
	end,
	OnCancel = function(self, battleID)
		BattlefieldMgrQueueInviteResponse(battleID,0);
	end,
	timeout = 0,
	whileDead = 1,
	multiple = 1
};

StaticPopupDialogs["BFMGR_INVITED_TO_ENTER"] = {
	text = WORLD_PVP_ENTER,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function(self)
		for i = 1, MAX_WORLD_PVP_QUEUES do
			local status, mapName, queueID, timeleft = GetWorldPVPQueueStatus(i);
			if ( queueID == self.data ) then
				self.timeleft = timeleft;
			end
		end
		SetupLockOnDeclineButtonAndEscape(self);
	end,
	OnAccept = function(self, battleID)
		BattlefieldMgrEntryInviteResponse(battleID, true);
	end,
	OnCancel = function(self, battleID)
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
	OnAccept = function(self)
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
	OnAccept = function(self, name)
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
		ChatEdit_FocusActiveWindow();
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
		local text = self:GetParent().editBox:GetText();
		RenamePetition(text);
		self:GetParent():Hide();
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
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

StaticPopupDialogs["CONFIRM_REPORT_BATTLEPET_NAME"] = {
	text = REPORT_BATTLEPET_NAME_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		C_ChatInfo.ReportPlayer(PLAYER_REPORT_TYPE_BAD_BATTLEPET_NAME);
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_REPORT_PET_NAME"] = {
	text = REPORT_PET_NAME_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		C_ChatInfo.ReportPlayer(PLAYER_REPORT_TYPE_BAD_PET_NAME);
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
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
	autoCompleteSource = GetAutoCompleteResults,
	autoCompleteArgs = { AUTOCOMPLETE_LIST.CHANINVITE.include, AUTOCOMPLETE_LIST.CHANINVITE.exclude },
	maxLetters = 31,
	whileDead = 1,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
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
		ChatEdit_FocusActiveWindow();
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
			FCF_SetWindowName(_G["ChatFrame"..renameID], name);
		else
			local frame = FCF_OpenNewWindow(name);
			FCF_CopyChatSettings(frame, DEFAULT_CHAT_FRAME);
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
			FCF_SetWindowName(_G["ChatFrame"..renameID], name);
		else
			local frame = FCF_OpenNewWindow(name);
			FCF_CopyChatSettings(frame, DEFAULT_CHAT_FRAME);
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
	hideOnEscape = 1,
	exclusive = 1,
};
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
	hideOnEscape = 1,
};
StaticPopupDialogs["DEATH"] = {
	text = DEATH_RELEASE_TIMER,
	button1 = DEATH_RELEASE,
	button2 = USE_SOULSTONE,	-- rez option 1
	button3 = USE_SOULSTONE,	-- rez option 2
	selectCallbackByIndex = true,
	OnShow = function(self)
		self.timeleft = GetReleaseTimeRemaining();
		self.resyncTime = 0; -- Timer so that we don't call GetReleaseTimeRemaining too frequently.

		if ( self.timeleft == -1 ) then
			self.text:SetText(DEATH_RELEASE_NOTIMER);
		end
	end,
	OnHide = function(self)
		self.button2.option = nil;
		self.button3.option = nil;
	end,
	OnButton1 = function(self)
		RepopMe();
		if ( CannotBeResurrected() ) then
			return 1
		end
	end,
	OnButton2 = function(self, data, reason)
		return OnResurrectButtonClick(self.button2.option, reason);
	end,
	OnButton3 = function(self, data, reason)
		return OnResurrectButtonClick(self.button3.option, reason);
	end,
	OnUpdate = function(self, elapsed)
		self.resyncTime = self.resyncTime - elapsed;
		if (self.resyncTime <= 0) then
			self.timeleft = GetReleaseTimeRemaining();
			self.resyncTime = 5;
		end

		if ( IsFalling() and not IsOutOfBounds()) then
			self.button1:Disable();
			self.button2:Disable();
			self.button3:Disable();
			return;
		end

		local b1_enabled = self.button1:IsEnabled();
		local encounterSupressRelease = IsEncounterSuppressingRelease();
		if ( encounterSupressRelease ) then
			self.button1:SetEnabled(false);
			self.button1:SetText(DEATH_RELEASE);
		else
			local hasNoReleaseAura, noReleaseDuration = HasNoReleaseAura();
			self.button1:SetEnabled(not hasNoReleaseAura);
			if ( hasNoReleaseAura ) then
				self.button1:SetText(math.floor(noReleaseDuration));
			else
				self.button1:SetText(DEATH_RELEASE);
			end
		end

		if ( b1_enabled ~= self.button1:IsEnabled() ) then
			if ( b1_enabled ) then
				if ( encounterSupressRelease ) then
					self.text:SetText(CAN_NOT_RELEASE_IN_COMBAT);
				else
					self.text:SetText(CAN_NOT_RELEASE_RIGHT_NOW);
				end
			else
				self.text:SetText("");
				StaticPopupDialogs[self.which].OnShow(self);
			end
			StaticPopup_Resize(self, self.which);
		end

		local option1, option2 = GetSelfResurrectDialogOptions();
		if ( option1 ) then
			if ( option1.name ) then
				self.button2:SetText(option1.name);
			end
			self.button2.option = option1;
			self.button2:SetEnabled(option1.canUse);
		end
		if ( option2 ) then
			if ( option2.name ) then
				self.button3:SetText(option2.name);
			end
			self.button3.option = option2;
			self.button3:SetEnabled(option2.canUse);
		end
	end,
	DisplayButton2 = function(self)
		local option1, option2 = GetSelfResurrectDialogOptions();
		return option1 ~= nil;
	end,
	DisplayButton3 = function(self)
		local option1, option2 = GetSelfResurrectDialogOptions();
		return option2 ~= nil;
	end,

	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
	notClosableByLogout = 1,
	noCancelOnReuse = 1,
	hideOnEscape = false,
	noCloseOnAlt = true,
	cancels = "RECOVER_CORPSE",
	timeoutInformationalOnly = 1,
};
StaticPopupDialogs["RESURRECT"] = {
	StartDelay = GetCorpseRecoveryDelay,
	delayText = RESURRECT_REQUEST_TIMER,
	text = RESURRECT_REQUEST,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnShow = function(self)
		self.timeleft = GetCorpseRecoveryDelay() + 60;
		SetupLockOnDeclineButtonAndEscape(self);
	end,
	OnAccept = function(self)
		AcceptResurrect();
	end,
	OnCancel = function(self, data, reason)
		if ( reason == "timeout" ) then
			TimeoutResurrect();
		else
			DeclineResurrect();
		end
		if ( UnitIsDead("player") and not UnitIsControlling("player") ) then
			StaticPopup_Show("DEATH");
		end
	end,
	timeout = STATICPOPUP_TIMEOUT,
	whileDead = 1,
	cancels = "DEATH",
	interruptCinematic = 1,
	notClosableByLogout = 1,
	noCancelOnReuse = 1,
};
StaticPopupDialogs["RESURRECT_NO_SICKNESS"] = {
	StartDelay = GetCorpseRecoveryDelay,
	delayText = RESURRECT_REQUEST_NO_SICKNESS_TIMER,
	text = RESURRECT_REQUEST_NO_SICKNESS,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnShow = function(self)
		self.timeleft = GetCorpseRecoveryDelay() + 60;
		SetupLockOnDeclineButtonAndEscape(self);
	end,
	OnAccept = function(self)
		AcceptResurrect();
	end,
	OnCancel = function(self, data, reason)
		if ( reason == "timeout" ) then
			TimeoutResurrect();
		else
			DeclineResurrect();
		end
		if ( UnitIsDead("player") and not UnitIsControlling("player") ) then
			StaticPopup_Show("DEATH");
		end
	end,
	timeout = STATICPOPUP_TIMEOUT,
	whileDead = 1,
	cancels = "DEATH",
	interruptCinematic = 1,
	notClosableByLogout = 1,
	noCancelOnReuse = 1
};
StaticPopupDialogs["RESURRECT_NO_TIMER"] = {
	text = RESURRECT_REQUEST_NO_SICKNESS,
	button1 = ACCEPT,
	button1Pulse = true,
	button2 = DECLINE,
	OnShow = function(self)
		self.timeleft = GetCorpseRecoveryDelay() + 60;
		local declineTimeLeft;
		local resOptions = C_DeathInfo.GetSelfResurrectOptions();
		if ( resOptions and #resOptions > 0 ) then
			declineTimeLeft = 1;
		else
			declineTimeLeft = 5;
		end
		SetupLockOnDeclineButtonAndEscape(self, declineTimeLeft);
	end,
	OnAccept = function(self)
		AcceptResurrect();
	end,
	OnCancel = function(self, data, reason)
		if ( reason == "timeout" ) then
			TimeoutResurrect();
		else
			DeclineResurrect();
		end
		if ( UnitIsDead("player") and not UnitIsControlling("player") ) then
			StaticPopup_Show("DEATH");
		end
	end,
	timeout = STATICPOPUP_TIMEOUT,
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
	OnShow = function(self)
		self.timeleft = GetCorpseRecoveryDelay() + 60;
		SetupLockOnDeclineButtonAndEscape(self);
	end,
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
	timeout = STATICPOPUP_TIMEOUT,
	hideOnEscape = 1
};
StaticPopupDialogs["PARTY_INVITE"] = {
	text = "%s",
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = SOUNDKIT.IG_PLAYER_INVITE,
	OnShow = function(self)
		self.inviteAccepted = nil;
		SetupLockOnDeclineButtonAndEscape(self);
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
	timeout = STATICPOPUP_TIMEOUT,
	whileDead = 1,
};
StaticPopupDialogs["GROUP_INVITE_CONFIRMATION"] = {
	text = "%s", --Filled out dynamically
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = SOUNDKIT.IG_PLAYER_INVITE,
	OnAccept = function(self)
		RespondToInviteConfirmation(self.data, true);
	end,
	OnCancel = function(self)
		RespondToInviteConfirmation(self.data, false);
	end,
	OnHide = function(self)
		UpdateInviteConfirmationDialogs();
	end,
	OnUpdate = function(self)
		if ( not self.linkRegion or not self.nextUpdateTime ) then
			return;
		end

		local timeNow = GetTime();
		if ( self.nextUpdateTime > timeNow ) then
			return;
		end

		local _, _, guid, roles, _, level = GetInviteConfirmationInfo(self.data);
		local className, classFilename, _, _, gender, characterName, _ = GetPlayerInfoByGUID(guid);

		GameTooltip:SetOwner(self.linkRegion, "ANCHOR_CURSOR_RIGHT");

		if ( className ) then
			self.nextUpdateTime = nil; -- The tooltip will be created with valid data, no more updates necessary.

			local _, _, _, colorCode = GetClassColor(classFilename);
			GameTooltip:SetText(WrapTextInColorCode(characterName, colorCode));

			local characterLine = CHARACTER_LINK_CLASS_LEVEL_TOOLTIP:format(level, className);
			if (roles["TANK"] or roles["HEALER"] or roles["DAMAGER"]) then
				characterLine = characterLine .. " ";
				if (roles["TANK"]) then
					characterLine = characterLine .. " " .. INLINE_TANK_ICON_SMALL;
				end
				if (roles["HEALER"]) then
					characterLine = characterLine .. " " .. INLINE_HEALER_ICON_SMALL;
				end
				if (roles["DAMAGER"]) then
					characterLine = characterLine .. " " .. INLINE_DAMAGER_ICON_SMALL;
				end
			end

			GameTooltip:AddLine(characterLine, HIGHLIGHT_FONT_COLOR:GetRGB());
		else
			self.nextUpdateTime = timeNow + .5;
			GameTooltip:SetText(RETRIEVING_DATA, RED_FONT_COLOR:GetRGB());
		end

		GameTooltip:Show();
	end,
	OnHyperlinkClick = function(self, link, text, button)
		-- Only allowing left button for now.
		if ( button == "LeftButton" ) then
			SetItemRef(link, text, button);
		end
	end,
	OnHyperlinkEnter = function(self, link, text, region, boundsLeft, boundsBottom, boundsWidth, boundsHeight)
		self.linkRegion = region;
		self.linkText = text;
		self.nextUpdateTime = GetTime();
		StaticPopupDialogs["GROUP_INVITE_CONFIRMATION"].OnUpdate(self);
	end,
	OnHyperlinkLeave = function(self)
		self.linkRegion = nil;
		self.linkText = nil;
		self.nextUpdateTime = nil;
		GameTooltip:Hide();
	end,
	timeout = STATICPOPUP_TIMEOUT,
	whileDead = 1,
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
	sound = SOUNDKIT.IG_PLAYER_INVITE,
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
	OnCancel = function(self, data)
		local chanName = data;
		DeclineChannelInvite(chanName);
	end,
	timeout = CHANNEL_INVITE_TIMEOUT,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["LEVEL_GRANT_PROPOSED"] = {
	text = LEVEL_GRANT,
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = SOUNDKIT.IG_PLAYER_INVITE,
	OnAccept = function(self)
		AcceptLevelGrant();
	end,
	OnCancel = function(self)
		DeclineLevelGrant();
	end,
	OnHide = function()
		DeclineLevelGrant();
	end,
	timeout = STATICPOPUP_TIMEOUT,
	whileDead = 1,
	hideOnEscape = 1
};

do
	local warningSeenBefore = false;
	StaticPopupDialogs["LEVEL_GRANT_PROPOSED_ALLIED_RACE"] = {
		text = LEVEL_GRANT_ALLIED_RACE,
		button1 = ACCEPT,
		button2 = DECLINE,
		sound = SOUNDKIT.IG_PLAYER_INVITE,
		OnAccept = function(self)
			AcceptLevelGrant();
		end,
		OnCancel = function(self)
			if (self.ticker) then
				self.ticker:Cancel();
				self.ticker = nil;
			end
			DeclineLevelGrant();
		end,
		OnShow = function(self)
			if (not warningSeenBefore) then
				self.button1:Disable();
				self.timeLeft = 3;
				self.button1:SetText(self.timeLeft);
				self.ticker = C_Timer.NewTicker(1, function()
					self.timeLeft = self.timeLeft - 1;
					self.button1:SetText(self.timeLeft);
					if (self.timeLeft <= 0) then
						self.ticker:Cancel();
						self.ticker = nil;
						self.button1:SetText(OKAY);
						self.button1:Enable();
						warningSeenBefore = true;
					end
				end);
			end
		end,
		OnHide = function(self)
			if (self.ticker) then
				self.ticker:Cancel();
				self.ticker = nil;
			end
			DeclineLevelGrant();
		end,
		showAlert = 1,
		timeout = STATICPOPUP_TIMEOUT,
		whileDead = 1,
		hideOnEscape = 1
	};
end

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

function ChatChannelPasswordHandler(self, data)
	local password = _G[self:GetName().."EditBox"]:GetText();
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
	timeout = STATICPOPUP_TIMEOUT,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CAMP"] = {
	text = CAMP_TIMER,
	button1 = CANCEL,
	OnAccept = function(self)
		CancelLogout();
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
StaticPopupDialogs["EQUIP_BIND_REFUNDABLE"] = {
	text = END_REFUND,
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
StaticPopupDialogs["EQUIP_BIND_TRADEABLE"] = {
	text = END_BOUND_TRADEABLE,
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
	OnAccept = function(self)
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
	OnAccept = function(self)
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
	OnAccept = function(self, data)
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
	OnAccept = function(self, data)
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
	OnAccept = function(self, data)
		PlaySound(SOUNDKIT.UI_80_AZERITEARMOR_REFORGE);
		C_AzeriteEmpoweredItem.ConfirmAzeriteEmpoweredItemRespec(data.empoweredItemLocation);
	end,
	OnShow = function(self, data)
		MoneyFrame_Update(self.moneyFrame, data.respecCost);
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
		MerchantFrame_ResetRefundItem();
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
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
		MerchantFrame_ResetRefundItem();
	end,
	EditBoxOnEnterPressed = function(self)
		if ( self:GetParent().button1:IsEnabled() ) then
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
StaticPopupDialogs["DELETE_GOOD_QUEST_ITEM"] = {
	text = DELETE_GOOD_QUEST_ITEM,
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
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
		MerchantFrame_ResetRefundItem();
	end,
	EditBoxOnEnterPressed = function(self)
		if ( self:GetParent().button1:IsEnabled() ) then
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
		if ClassicExpansionAtLeast(LE_EXPANSION_WRATH_OF_THE_LICH_KING) then
			if ( QuestLogDetailFrame:IsShown() ) then
				HideUIPanel(QuestLogDetailFrame);
			end
		end
		PlaySound(SOUNDKIT.IG_QUEST_LOG_ABANDON_QUEST);
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
		if ClassicExpansionAtLeast(LE_EXPANSION_WRATH_OF_THE_LICH_KING) then
			if ( QuestLogDetailFrame:IsShown() ) then
				HideUIPanel(QuestLogDetailFrame);
			end
		end
		PlaySound(SOUNDKIT.IG_QUEST_LOG_ABANDON_QUEST);
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
	autoCompleteSource = GetAutoCompleteResults,
	autoCompleteArgs = { AUTOCOMPLETE_LIST.ADDFRIEND.include, AUTOCOMPLETE_LIST.ADDFRIEND.exclude },
	maxLetters = 12 + 1 + 64,
	OnAccept = function(self)
		C_FriendList.AddFriend(self.editBox:GetText());
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		C_FriendList.AddFriend(parent.editBox:GetText());
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
	countInvisibleLetters = true,
	editBoxWidth = 350,
	OnAccept = function(self)
		if(not C_FriendList.SetFriendNotes(FriendsFrame.NotesID, self.editBox:GetText())) then
			UIErrorsFrame:AddExternalErrorMessage(ERR_FRIEND_NOT_FOUND);
		end
	end,
	OnShow = function(self)
		local info = C_FriendList.GetFriendInfo(FriendsFrame.NotesID);
		if ( info.notes ) then
			self.editBox:SetText(info.notes);
		end
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		if(not C_FriendList.SetFriendNotes(FriendsFrame.NotesID, parent.editBox:GetText())) then
			UIErrorsFrame:AddExternalErrorMessage(ERR_FRIEND_NOT_FOUND);
		end
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
StaticPopupDialogs["SET_BNFRIENDNOTE"] = {
	text = SET_FRIENDNOTE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 127,
	countInvisibleLetters = true,
	editBoxWidth = 350,
	OnAccept = function(self)
		BNSetFriendNote(FriendsFrame.NotesID, self.editBox:GetText());
	end,
	OnShow = function(self)
		local bnetIDAccount, accountName, battleTag, isBattleTag, characterName, bnetIDGameAccount, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText = BNGetFriendInfoByID(FriendsFrame.NotesID);
		if ( noteText ) then
			self.editBox:SetText(noteText);
		end
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		BNSetFriendNote(FriendsFrame.NotesID, parent.editBox:GetText());
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

StaticPopupDialogs["SET_COMMUNITY_MEMBER_NOTE"] = {
	text = SET_FRIENDNOTE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 200,
	countInvisibleLetters = true,
	editBoxWidth = 350,
	OnAccept = function(self, data)
		C_Club.SetClubMemberNote(data.clubId, data.memberId, self.editBox:GetText());
	end,
	OnShow = function(self, data)
		local memberInfo = C_Club.GetMemberInfo(data.clubId, data.memberId);
		if ( memberInfo and memberInfo.memberNote ) then
			self.editBox:SetText(memberInfo.memberNote);
		end
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self, data)
		local parent = self:GetParent();
		C_Club.SetClubMemberNote(data.clubId, data.memberId, parent.editBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_REMOVE_COMMUNITY_MEMBER"] = {
	text = CONFIRM_REMOVE_COMMUNITY_MEMBER_LABEL,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		C_Club.KickMember(data.clubId, data.memberId);
	end,
	OnShow = function(self, data)
		self.text:SetText(CONFIRM_REMOVE_COMMUNITY_MEMBER_LABEL:format(data.name));
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_DESTROY_COMMUNITY_STREAM"] = {
	text = CONFIRM_DESTROY_COMMUNITY_STREAM_LABEL,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		C_Club.DestroyStream(data.clubId, data.streamId);
	end,
	OnShow = function(self, data)
		local streamInfo = C_Club.GetStreamInfo(data.clubId, data.streamId);
		if streamInfo then
			self.text:SetText(CONFIRM_DESTROY_COMMUNITY_STREAM_LABEL:format(streamInfo.name));
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
	OnShow = function(self, clubInfo)
		self.text:SetText(CONFIRM_LEAVE_AND_DESTROY_COMMUNITY);
		self.SubText:SetText(CONFIRM_LEAVE_AND_DESTROY_COMMUNITY_SUBTEXT);
	end,
	OnAccept = function(self, clubInfo)
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
	OnShow = function(self, clubInfo)
		self.text:SetText(CONFIRM_LEAVE_COMMUNITY);
		self.SubText:SetFormattedText(CONFIRM_LEAVE_COMMUNITY_SUBTEXT, clubInfo.name);
	end,
	OnAccept = function(self, clubInfo)
		C_Club.LeaveClub(clubInfo.clubId);
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_DESTROY_COMMUNITY"] = {
	text = "",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, clubInfo)
		C_Club.DestroyClub(clubInfo.clubId);
		CloseCommunitiesSettingsDialog();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 32,
	OnShow = function(self, clubInfo)
		self.text:SetText(CONFIRM_DESTROY_COMMUNITY:format(clubInfo.name));

		self.button1:Disable();
		self.button2:Enable();
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
		MerchantFrame_ResetRefundItem();
	end,
	EditBoxOnEnterPressed = function(self)
		if ( self:GetParent().button1:IsEnabled() ) then
			self:GetParent().button1:Click();
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


StaticPopupDialogs["ADD_IGNORE"] = {
	text = ADD_IGNORE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	autoCompleteSource = GetAutoCompleteResults,
	autoCompleteArgs = { AUTOCOMPLETE_LIST.IGNORE.include, AUTOCOMPLETE_LIST.IGNORE.exclude },
	maxLetters = 12 + 1 + 64, --name space realm (77 max)
	OnAccept = function(self)
		C_FriendList.AddIgnore(self.editBox:GetText());
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		C_FriendList.AddIgnore(parent.editBox:GetText());
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
	autoCompleteSource = GetAutoCompleteResults,
	autoCompleteArgs = { AUTOCOMPLETE_LIST.GUILD_INVITE.include, AUTOCOMPLETE_LIST.GUILD_INVITE.exclude },
	maxLetters = 48,
	OnAccept = function(self)
		C_GuildInfo.Invite(self.editBox:GetText());
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		C_GuildInfo.Invite(parent.editBox:GetText());
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
	autoCompleteSource = GetAutoCompleteResults,
	autoCompleteArgs = { AUTOCOMPLETE_LIST.INVITE.include, AUTOCOMPLETE_LIST.INVITE.exclude },
	maxLetters = 77,
	OnAccept = function(self)
		InviteToGroup(self.editBox:GetText());
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		InviteToGroup(parent.editBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["CONVERT_TO_RAID"] = {
	text = CONVERT_TO_RAID_LABEL,
	button1 = CONVERT,
	button2 = CANCEL,
	OnAccept = function(self, data)
		ConvertToRaid();
		C_PartyInfo.InviteUnit(data);
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	showAlert = 1
};
StaticPopupDialogs["LFG_LIST_AUTO_ACCEPT_CONVERT_TO_RAID"] = {
	text = CONVERT_TO_RAID_LABEL,
	button1 = CONVERT,
	button2 = CANCEL,
	OnAccept = function(self, data)
		ConvertToRaid();
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	showAlert = 1
};
StaticPopupDialogs["REMOVE_GUILDMEMBER"] = {
	text = format(REMOVE_GUILDMEMBER_LABEL, "XXX"),
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		--The Classic Guild UI (FriendFrame) does not provide a guid while the modern version does.
		if data and data.guid then
			C_GuildInfo.RemoveFromGuild(data.guid);
			if CommunitiesFrame then
				CommunitiesFrame:CloseGuildMemberDetailFrame();
			end
		else
			C_GuildInfo.Uninvite(GuildFrame.selectedName);
			if GuildMemberDetailFrame then
				GuildMemberDetailFrame:Hide();
			end
		end
	end,
	OnShow = function(self, data)
		if data and data.name then
			self.text:SetFormattedText(REMOVE_GUILDMEMBER_LABEL, data.name);
		else
			self.text:SetFormattedText(REMOVE_GUILDMEMBER_LABEL, GuildFrame.selectedName);
		end
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

local function AddGuildRank(text)
	GuildControlAddRank(text);
	local rank = GuildControlGetRank();
	GuildControlSetRank(rank);
	GuildControlPopupFrameDropdown:GenerateMenu();
	GuildControlPopupFrameEditBox:SetText(GuildControlGetRankName(rank));
	GuildControlCheckboxUpdate(C_GuildInfo.GuildControlGetRankFlags(rank));
end

StaticPopupDialogs["ADD_GUILDRANK"] = {
	text = ADD_GUILDRANK_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 15,
	OnAccept = function(self)
		AddGuildRank(self.editBox:GetText());
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		AddGuildRank(parent.editBox:GetText());
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
	wide = true,
	editBoxWidth = 350,
	OnAccept = function(self)
		C_GuildInfo.SetMOTD(self.editBox:GetText());
	end,
	OnShow = function(self)
		self.editBox:SetText(GetGuildRosterMOTD());
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		C_GuildInfo.SetMOTD(parent.editBox:GetText());
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
	wide = true,
	editBoxWidth = 350,
	OnAccept = function(self)
		GuildRosterSetPublicNote(GetGuildRosterSelection(), self.editBox:GetText());
	end,
	OnShow = function(self)
		--Sets the text to the 7th return from GetGuildRosterInfo(GetGuildRosterSelection());
		self.editBox:SetText(select(7, GetGuildRosterInfo(GetGuildRosterSelection())));
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		GuildRosterSetPublicNote(GetGuildRosterSelection(), parent.editBox:GetText());
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
	wide = true,
	editBoxWidth = 350,
	OnAccept = function(self)
		GuildRosterSetOfficerNote(GetGuildRosterSelection(), self.editBox:GetText());
	end,
	OnShow = function(self)
		local fullName, rank, rankIndex, level, class, zone, note, officernote, online = GetGuildRosterInfo(GetGuildRosterSelection());

		self.editBox:SetText(select(8, GetGuildRosterInfo(GetGuildRosterSelection())));
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		GuildRosterSetOfficerNote(GetGuildRosterSelection(), parent.editBox:GetText());
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

StaticPopupDialogs["SET_GUILD_COMMUNITIY_NOTE"] = {
	text = SET_GUILDPLAYERNOTE_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 31,
	editBoxWidth = 260,
	OnAccept = function(self, data)
		C_GuildInfo.SetNote(data.guid, self.editBox:GetText(), data.isPublic);
	end,
	OnShow = function(self, data)
		self.text:SetText(data.isPublic and SET_GUILDPLAYERNOTE_LABEL or SET_GUILDOFFICERNOTE_LABEL);
		self.editBox:SetText(data.currentNote);
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self, data)
		local parent = self:GetParent();
		C_GuildInfo.SetNote(data.guid, self:GetText(), data.isPublic);
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
		ChatEdit_FocusActiveWindow();
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
	sound = SOUNDKIT.IG_PLAYER_INVITE,
	OnAccept = function(self)
		AcceptDuel();
	end,
	OnCancel = function(self)
		CancelDuel();
	end,
	timeout = STATICPOPUP_TIMEOUT,
	hideOnEscape = 1
};
-- Hardcore popups
if (C_GameRules.IsHardcoreActive()) then
	StaticPopupDialogs["HARDCORE_DEATH"] = {
		text = HARDCORE_DEATH,
		button1 = HARDCORE_GO_AGAIN,
		button2 = DEATH_RELEASE,
		--button3 = DEATH_REINCARNATE_CHARACTER,
		selectCallbackByIndex = true,
		OnShow = function(self)
			self.button1:Enable();
			self.button2:Enable();
			return;
		end,
		OnButton1 = function(self)
			Logout();
			return;
		end,
		OnButton2 = function(self)
			RepopMe();
		end,
		OnButton3 = function(self)
			-- Set some state, then start logout process as normal
			local guid = UnitGUID("player");
			local className, _, _, _, _, characterName, _ = GetPlayerInfoByGUID(guid);
			local level = UnitLevel("player");
			C_Reincarnation.StartReincarnation(guid, characterName, className, level);
			Logout();
		end,
		OnUpdate = function(self, elapsed)
			-- If button text is too long, widen out the dialogue
			if (string.len(self.button1:GetText()) > 20 or string.len(self.button2:GetText()) > 20) then
				local textWidth = math.max(self.button1:GetWidth(), self.button2:GetWidth())
				if (textWidth > 120) then
					self.button1:SetWidth(textWidth);
					self.button2:SetWidth(textWidth);
				end
				self:SetWidth(420)
			end
			if ( IsFalling() and not IsOutOfBounds()) then
				self.button1:Disable();
				self.button2:Disable();
				return;
			else
				self.button1:Enable();
				self.button2:Enable();
				return;
			end
		end,
		timeout = 0,
		whileDead = 1,
		interruptCinematic = 1,
		notClosableByLogout = 1,
		noCancelOnReuse = 1,
		hideOnEscape = false,
		noCloseOnAlt = true,
		cancels = "HARDCORE_RECOVER_CORPSE",
		timeoutInformationalOnly = 1,
	};
	StaticPopupDialogs["HARDCORE_RECOVER_CORPSE"] = {
		text = HARDCORE_RECOVER_CORPSE,
		button1 = HARDCORE_GO_AGAIN,
		OnAccept = function(self)
			Logout();
			return 1;
		end,
		whileDead = 1,
		interruptCinematic = 1,
		notClosableByLogout = 1
	};
	StaticPopupDialogs["HARDCORE_RECOVER_CORPSE_INSTANCE"] = {
		text = HARDCORE_RECOVER_CORPSE_INSTANCE,
		timeout = 0,
		whileDead = 1,
		interruptCinematic = 1,
		notClosableByLogout = 1
	};
	StaticPopupDialogs["HARDCORE_DEATH_GUILD_HANDOFF"] = {
		button1 = ACCEPT,
		text = HARDCORE_GUILDLEADER_DEATH,
		OnAccept = function(self)
			if ( self.button1:IsEnabled() ) then
				-- Pass guild lead
				local text = self.editBox:GetText();
				C_GuildInfo.SetLeader(text);
				self:Hide();
				if (UnitIsDead("player")) then
					StaticPopup_Show("HARDCORE_DEATH");
				end
			end
		end,
		OnUpdate = function (self)
			--
		end,
		timeout = 0,
		whileDead = 1,
		exclusive = 1,
		showAlert = 1,
		hasEditBox = 1,
		maxLetters = 12,
		notClosableByLogout = 1,
		cancels = "HARDCORE_RECOVER_CORPSE",
		OnShow = function(self)
			self.button1:Disable();
			self.editBox:SetFocus();
		end,
		EditBoxOnEnterPressed = function(self)
			local parent = self:GetParent();
			if ( parent.button1:IsEnabled() ) then
				-- Pass guild lead
				local text = parent.editBox:GetText();
				C_GuildInfo.SetLeader(text);
				parent:Hide();
				if (UnitIsDead("player")) then
					StaticPopup_Show("HARDCORE_DEATH");
				end
			end
		end,
		EditBoxOnTextChanged = function (self)
			local parent = self:GetParent();
			local text = parent.editBox:GetText();
			if (text == "") then
				return
			end
			local playerInSameGuild = C_GuildInfo.MemberExistsByName(text);
			-- Check if this is a player, and if that player is in our guild
			if (playerInSameGuild) then
				parent.button1:Enable();
			else
				parent.button1:Disable();
			end
		end,
	};
	StaticPopupDialogs["DUEL_TO_THE_DEATH_REQUESTED"] = {
		text = DUEL_TO_THE_DEATH_REQUESTED,
		button1 = ACCEPT,
		button2 = DECLINE,
		sound = SOUNDKIT.HARDCORE_DUEL,
		OnAccept = function(self)
			self:Hide();
			StaticPopup_Show("DUEL_TO_THE_DEATH_REQUESTED_CONFIRM");
		end,
		OnCancel = function(self)
			CancelDuel();
		end,
		OnUpdate = function(self)
			if ( not self.linkRegion or not self.nextUpdateTime ) then
				return;
			end

			local timeNow = GetTime();
			if ( self.nextUpdateTime > timeNow ) then
				return;
			end

			local guid, level = GetDuelerInfo();
			local className, classFilename, _, _, gender, characterName, _ = GetPlayerInfoByGUID(guid);
			self.target = characterName;
			GameTooltip:SetOwner(self.linkRegion, "ANCHOR_CURSOR_RIGHT");

			if ( className ) then
				self.nextUpdateTime = nil; -- The tooltip will be created with valid data, no more updates necessary.

				local _, _, _, colorCode = GetClassColor(classFilename);
				GameTooltip:SetText(WrapTextInColorCode(characterName, colorCode));
				local characterLine
				if (level < 0) then
					characterLine = UNIT_TYPE_LETHAL_LEVEL_TEMPLATE:format(className);
				else
					characterLine = CHARACTER_LINK_CLASS_LEVEL_TOOLTIP:format(level, className);
				end
				GameTooltip:AddLine(characterLine, HIGHLIGHT_FONT_COLOR:GetRGB());
			else
				self.nextUpdateTime = timeNow + .5;
				GameTooltip:SetText(RETRIEVING_DATA, RED_FONT_COLOR:GetRGB());
			end

			GameTooltip:Show();
		end,
		OnHyperlinkClick = function(self, link, text, button)
			-- Target whoever is challenging us.
			if ( button == "LeftButton" and self.target ) then
				TargetUnit(self.target)
			end
		end,
		OnHyperlinkEnter = function(self, link, text, region, boundsLeft, boundsBottom, boundsWidth, boundsHeight)
			self.linkRegion = region;
			self.linkText = text;
			self.nextUpdateTime = GetTime();
			StaticPopupDialogs["DUEL_TO_THE_DEATH_REQUESTED"].OnUpdate(self);
		end,
		OnHyperlinkLeave = function(self)
			self.linkRegion = nil;
			self.linkText = nil;
			self.nextUpdateTime = nil;
			GameTooltip:Hide();
		end,
		timeout = STATICPOPUP_TIMEOUT,
		hideOnEscape = 1
	};
	StaticPopupDialogs["DUEL_TO_THE_DEATH_REQUESTED_CONFIRM"] = {
		text = DUEL_TO_THE_DEATH_REQUEST_CONFIRM,
		button1 = ACCEPT,
		button2 = DECLINE,
		hasEditBox = 1,
		maxLetters = math.max(12, string.len(HARDCORE_DUEL_CONFIRMATION)),
		wide = true,
		OnAccept = function(self)
			AcceptDuel();
		end,
		OnCancel = function(self)
			CancelDuel();
		end,
		EditBoxOnTextChanged = function (self)
			local parent = self:GetParent();
			if (strupper(parent.editBox:GetText()) == HARDCORE_DUEL_CONFIRMATION) then
				parent.button1:Enable();
			else
				parent.button1:Disable();
			end
		end,
		EditBoxOnEscapePressed = function(self)
			CancelDuel();
			self:GetParent():Hide();
		end,
		OnShow = function(self)
			self.button1:Disable();
		end,
		timeout = STATICPOPUP_TIMEOUT,
		hideOnEscape = 1
	};
	StaticPopupDialogs["DUEL_TO_THE_DEATH_CHALLENGE_CONFIRM"] = {
		text = DUEL_TO_THE_DEATH_CHALLENGE_CONFIRM,
		button1 = ACCEPT,
		button2 = DECLINE,
		hasEditBox = 1,
		maxLetters = math.max(12, string.len(HARDCORE_DUEL_CONFIRMATION)),
		wide = true,
		OnAccept = function(self)
			StartDuel(self.data.unit, true, true);
		end,
		OnCancel = function(self)
			-- Duel hasn't started yet
		end,
		EditBoxOnTextChanged = function (self)
			local parent = self:GetParent();
			if (strupper(parent.editBox:GetText()) == HARDCORE_DUEL_CONFIRMATION) then
				parent.button1:Enable();
			else
				parent.button1:Disable();
			end
		end,
		EditBoxOnEscapePressed = function(self)
			self:GetParent():Hide();
		end,
		OnShow = function(self)
			self.button1:Disable();
		end,
		timeout = STATICPOPUP_TIMEOUT,
		hideOnEscape = 1
	};
end
StaticPopupDialogs["DUEL_OUTOFBOUNDS"] = {
	text = DUEL_OUTOFBOUNDS_TIMER,
	timeout = 10,
};
StaticPopupDialogs["PET_BATTLE_PVP_DUEL_REQUESTED"] = {
	text = PET_BATTLE_PVP_DUEL_REQUESTED,
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = SOUNDKIT.IG_PLAYER_INVITE,
	OnAccept = function(self)
		C_PetBattles.AcceptPVPDuel();
	end,
	OnCancel = function(self)
		C_PetBattles.CancelPVPDuel();
	end,
	timeout = STATICPOPUP_TIMEOUT,
	hideOnEscape = 1
};
StaticPopupDialogs["UNLEARN_SKILL"] = {
	text = UNLEARN_SKILL,
	button1 = UNLEARN,
	button2 = CANCEL,
	OnAccept = function(self, index)
		AbandonSkill(index);
		if TradeSkillFrame then
			HideUIPanel(TradeSkillFrame);
		end
	end,
	timeout = STATICPOPUP_TIMEOUT,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["UNLEARN_SPECIALIZATION"] = {
	text = UNLEARN_SKILL,
	button1 = UNLEARN,
	button2 = CANCEL,
	OnAccept = function(self, index)
		UnlearnSpecialization(index);
	end,
	timeout = STATICPOPUP_TIMEOUT,
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
			C_PlayerInteractionManager.ConfirmationInteraction(Enum.PlayerInteractionType.SpiritHealer);
			C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.SpiritHealer);
		end
	end,
	OnUpdate = function(self, elapsed)
		if ( not C_PlayerInteractionManager.IsValidNPCInteraction(Enum.PlayerInteractionType.SpiritHealer) ) then
			C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.SpiritHealer);
			self:Hide();
		end
	end,
	OnCancel = function(self)
		C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.SpiritHealer);
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["XP_LOSS_NO_DURABILITY"] = {
	text = CONFIRM_XP_LOSS_NO_DURABILITY,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, data)
		if ( data ) then
			self.text:SetFormattedText(CONFIRM_XP_LOSS_AGAIN_NO_DURABILITY, data);
			self.data = nil;
			return 1;
		else
			C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.SpiritHealer);
		end
	end,
	OnUpdate = function(self, elapsed)
		if ( not C_PlayerInteractionManager.IsValidNPCInteraction(Enum.PlayerInteractionType.SpiritHealer) ) then
			self:Hide();
			C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.SpiritHealer);
		end
	end,
	OnCancel = function(self)
		C_PlayerInteractionManager.ClearInteraction();
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
			 C_PlayerInteractionManager.ConfirmationInteraction(Enum.PlayerInteractionType.SpiritHealer)
		end
	end,
	OnUpdate = function(self, dialog)
		if ( not C_PlayerInteractionManager.IsValidNPCInteraction(Enum.PlayerInteractionType.SpiritHealer) ) then
			C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.SpiritHealer);
			self:Hide();
		end
	end,
	OnCancel = function(self)
		C_GossipInfo.CloseGossip();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["XP_LOSS_NO_SICKNESS_NO_DURABILITY"] = {
	text = CONFIRM_XP_LOSS_NO_SICKNESS_NO_DURABILITY,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, data)
		C_PlayerInteractionManager.ConfirmationInteraction(Enum.PlayerInteractionType.SpiritHealer);
	end,
	OnUpdate = function(self, dialog)
		if ( not C_PlayerInteractionManager.IsValidNPCInteraction(Enum.PlayerInteractionType.SpiritHealer) ) then
			C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.SpiritHealer);
			self:Hide();
		end
	end,
	OnCancel = function(self)
		C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.SpiritHealer);
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
	button1 = CHOOSE_LOCATION,
	button2 = CANCEL,
	OnShow = function(self)
		self.timeleft = GetAreaSpiritHealerTime();
	end,
	OnAccept = function(self)
		OpenWorldMap();
		return true;	--Don't close this popup.
	end,
	OnCancel = function(self)
		CancelAreaSpiritHeal();
	end,
	DisplayButton1 = function(self)
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
	OnAccept = function(self)
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
	OnAccept = function(self)
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
	OnAccept = function(self)
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
	OnAccept = function(self)
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
	OnAccept = function(self)
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
	OnShow = function(self)
		TradeFrameTradeButton:Disable();
	end,
	OnHide = function(self)
		TradeFrameTradeButton_SetToEnabledState();
	end,
	OnCancel = function(self)
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
	OnAccept = function(self)
		SellCursorItem();
	end,
	OnCancel = function(self)
		ClearCursor();
	end,
	OnUpdate = function (self)
		if ( not CursorHasItem() ) then
			self:Hide();
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
	OnAccept = function(self)
		C_Item.EndBoundTradeable(self.data);
	end,
	timeout = 0,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1,
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
	notClosableByLogout = 1,
	height = 85
};
StaticPopupDialogs["GARRISON_BOOT"] = {
	text = GARRISON_BOOT_TIMER,
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
		local enforceTime = self.data;
		local lockTimeleft, isPreviousInstance = GetInstanceLockTimeRemaining();
		if ( enforceTime and lockTimeleft <= 0 ) then
			self:Hide();
			return;
		end
		self.lockTimeleft = lockTimeleft;
		self.isPreviousInstance = isPreviousInstance;

		local type, difficulty;
		self.name, type, difficulty, self.difficultyName = GetInstanceInfo();

		self.extraFrame:SetAllPoints(self.text)
		self.extraFrame:Show()
		self.extraFrame:SetScript("OnEnter", InstanceLock_OnEnter)
		self.extraFrame:SetScript("OnLeave", GameTooltip_Hide)

		if ( not enforceTime ) then
			local name = GetDungeonNameWithDifficulty(self.name, self.difficultyName);
			local text = _G[self:GetName().."Text"];
			local lockstring = string.format((self.isPreviousInstance and INSTANCE_LOCK_WARNING_PREVIOUSLY_SAVED or INSTANCE_LOCK_WARNING), name, SecondsToTime(ceil(lockTimeleft), nil, 1));
			local time, extending;
			time, extending, self.extraFrame.encountersTotal, self.extraFrame.encountersComplete = GetInstanceLockTimeRemaining();
			local bosses = string.format(BOSSES_KILLED, self.extraFrame.encountersComplete, self.extraFrame.encountersTotal);
			text:SetFormattedText(INSTANCE_LOCK_SEPARATOR, lockstring, bosses);
			StaticPopup_Resize(self, "INSTANCE_LOCK");
		end

	end,
	OnHide = function(self)
		self.extraFrame:SetScript("OnEnter", nil)
		self.extraFrame:SetScript("OnLeave", nil)
	end,
	OnUpdate = function(self, elapsed)
		local enforceTime = self.data;
		if ( enforceTime ) then
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

			local name = GetDungeonNameWithDifficulty(self.name, self.difficultyName);

			-- Set dialog message using information that describes which bosses are still around
			local text = _G[self:GetName().."Text"];
			local lockstring = string.format((self.isPreviousInstance and INSTANCE_LOCK_TIMER_PREVIOUSLY_SAVED or INSTANCE_LOCK_TIMER), name, SecondsToTime(ceil(lockTimeleft), nil, 1));
			local time, extending;
			time, extending, self.extraFrame.encountersTotal, self.extraFrame.encountersComplete = GetInstanceLockTimeRemaining();
			local bosses = string.format(BOSSES_KILLED, self.extraFrame.encountersComplete, self.extraFrame.encountersTotal);
			text:SetFormattedText(INSTANCE_LOCK_SEPARATOR, lockstring, bosses);

			-- make sure the dialog fits the text
			StaticPopup_Resize(self, "INSTANCE_LOCK");
		end
	end,
	OnAccept = function(self)
		RespondInstanceLock(true);
		self.name, self.difficultyName = nil, nil;
		self.lockTimeleft = nil;
	end,
	OnCancel = function(self, data, reason)
		if ( reason == "timeout" ) then
			self:Hide();
			return;
		end
		RespondInstanceLock(false);
		self.name, self.difficultyName = nil, nil;
		self.lockTimeleft = nil;
	end,
	DisplayButton2 = function(self)
		return self.data;
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
	exclusive = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_BARBERS_CHOICE"] = {
	text = BARBERS_CHOICE_CONFIRM,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		ConfirmBarbersChoice();
	end,
	hasMoneyFrame = 1,
	exclusive = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_PET_UNLEARN"] = {
	text = CONFIRM_PET_UNLEARN,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		ConfirmPetUnlearn();
	end,
	OnUpdate = function(self, elapsed)
		if ( not CheckTalentMasterDist() ) then
			self:Hide();
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
	OnAccept = function(self)
		C_PlayerInteractionManager.ConfirmationInteraction(Enum.PlayerInteractionType.Binder);
		C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.Binder);
	end,
	OnUpdate = function(self, elapsed)
		if ( not C_PlayerInteractionManager.IsValidNPCInteraction(Enum.PlayerInteractionType.Binder) ) then
			C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.Binder);
			self:Hide();
		end
	end,
	OnCancel = function(self)
		C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.Binder);
		self:Hide();
	end,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_SUMMON"] = {
	text = CONFIRM_SUMMON;
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function(self)
		self.timeleft = C_SummonInfo.GetSummonConfirmTimeLeft();
		SetupLockOnDeclineButtonAndEscape(self);
	end,
	OnAccept = function(self)
		C_SummonInfo.ConfirmSummon();
	end,
	OnCancel = function()
		C_SummonInfo.CancelSummon();
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
};

StaticPopupDialogs["CONFIRM_SUMMON_SCENARIO"] = {
	text = CONFIRM_SUMMON_SCENARIO;
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function(self)
		self.timeleft = C_SummonInfo.GetSummonConfirmTimeLeft();
	end,
	OnAccept = function(self)
		C_SummonInfo.ConfirmSummon();
	end,
	OnCancel = function()
		C_SummonInfo.CancelSummon();
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
	hideOnEscape = 1,
};

-- Summon dialog when being summoned when in a starting area
StaticPopupDialogs["CONFIRM_SUMMON_STARTING_AREA"] = {
	text = CONFIRM_SUMMON_STARTING_AREA,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function(self)
		self.timeleft = C_SummonInfo.GetSummonConfirmTimeLeft();
	end,
	OnAccept = function(self)
		C_SummonInfo.ConfirmSummon();
	end,
	OnCancel = function()
		C_SummonInfo.CancelSummon();
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
	OnAccept = function(self, id, rollType)
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
	OnAccept = function(self, data)
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
	OnAccept = function(self, data)
		C_GossipInfo.SelectOption(data, self.editBox:GetText(), true);
	end,
	OnShow = function(self)
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self, data)
		local parent = self:GetParent();
		C_GossipInfo.SelectOption(data, parent.editBox:GetText());
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

StaticPopupDialogs["WOW_MOUSE_NOT_FOUND"] = {
	text = WOW_MOUSE_NOT_FOUND,
	button1 = OKAY,
	OnHide = function(self)
		SetCVar("enableWoWMouse", "0");
		-- FIXME - Open Settings
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
	OnAccept = function(self)
		BuyStableSlot();
	end,
	OnShow = function(self)
		MoneyFrame_Update(self.moneyFrame, GetNextStableSlotCost());
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
	StartDelay = function(self) if (self.data) then return 0 else return 3 end end,
	OnAccept = function(self)
		SetLFGBootVote(true);
	end,
	OnCancel = function(self)
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
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		UninviteUnit(parent.data, self:GetText());
		parent:Hide();
	end,
	EditBoxOnTextChanged = function(self)
		if ( strtrim(self:GetText()) == "" ) then
			self:GetParent().button1:Disable();
		else
			self:GetParent().button1:Enable();
		end
	end,
	OnShow = function(self)
		self.button1:Disable();
	end,
	OnAccept = function(self)
		UninviteUnit(self.data, self.editBox:GetText());
	end,
	timeout = 0,
	whileDead = 1,
	interruptCinematic = 1,
};

StaticPopupDialogs["LAG_SUCCESS"] = {
	text = HELPFRAME_REPORTLAG_TEXT1,
	button1 = OKAY,
	timeout = 0,
}

StaticPopupDialogs["LFG_OFFER_CONTINUE"] = {
	text = LFG_OFFER_CONTINUE,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		PartyLFGStartBackfill();
	end,
	noCancelOnReuse = 1,
	timeout = 0,
}

StaticPopupDialogs["CONFIRM_MAIL_ITEM_UNREFUNDABLE"] = {
	text = END_REFUND,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		RespondMailLockSendItem(self.data.slot, true);
	end,
	OnCancel = function(self)
		RespondMailLockSendItem(self.data.slot, false);
	end,
	timeout = 0,
	hasItemFrame = 1,
}

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
	OnAccept = function(self, inviteID)
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

StaticPopupDialogs["CONFIRM_REMOVE_FRIEND"] = {
	text = "%s",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, bnetIDAccount)
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
	OnAccept = function(self)
		MoneyInputFrame_PickupPlayerMoney(self.moneyInputFrame);
	end,
	OnHide = function(self)
		MoneyInputFrame_ResetMoney(self.moneyInputFrame);
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent():GetParent();
		MoneyInputFrame_PickupPlayerMoney(parent.moneyInputFrame);
		parent:Hide();
	end,
	hasMoneyInputFrame = 1,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_GUILD_CHARTER_SIGNATURE"] = {
	text = GUILD_REPUTATION_WARNING_GENERIC.."\n"..CONFIRM_CONTINUE,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		SignPetition();
	end,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["CONFIRM_GUILD_CHARTER_PURCHASE"] = {
	text = GUILD_REPUTATION_WARNING_GENERIC.."\n"..CONFIRM_CONTINUE,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		GuildRegistrar_PurchaseCharter(true);
	end,
	timeout = 0,
	hideOnEscape = 1
};
StaticPopupDialogs["GUILD_DEMOTE_CONFIRM"] = {
	text = "%s",
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		C_GuildInfo.Demote(self.data);
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};
StaticPopupDialogs["GUILD_PROMOTE_CONFIRM"] = {
	text = "%s",
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		C_GuildInfo.Promote(self.data);
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_RANK_AUTHENTICATOR_REMOVE"] = {
	text = "%s",
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		local checkbox = self.data;
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
	OnAccept = function(self)
		VoidStorage_UpdateTransferButton();
	end,
	OnCancel = function(self)
		VoidStorage_CloseConfirmationDialog(self.data.slot);
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
	OnAccept = function (self) ReplaceGuildMaster(); end,
	OnCancel = function (self) end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}

StaticPopupDialogs["SPELL_CONFIRMATION_PROMPT" ] = {
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		AcceptSpellConfirmationPrompt(self.data);
	end,
	OnCancel = function(self)
		DeclineSpellConfirmationPrompt(self.data);
	end,
	exclusive = 0,
	whileDead = 1,
	hideOnEscape = 1
}

StaticPopupDialogs["SPELL_CONFIRMATION_WARNING" ] = {
	button1 = OKAY,
	OnAccept = function(self)
		AcceptSpellConfirmationPrompt(self.data);
	end,
	exclusive = 0,
	whileDead = 1,
	hideOnEscape = 1
}

StaticPopupDialogs["CONFIRM_LAUNCH_URL"] = {
	text = CONFIRM_LAUNCH_URL,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self, data) LoadURLIndex(data.index, data.mapID); end,
	hideOnEscape = 1,
	timeout = 0,
}

StaticPopupDialogs["CONFIRM_LEAVE_INSTANCE_PARTY"] = {
	text = "%s",
	button1 = YES,
	button2 = CANCEL,
	OnAccept = function(self, data)
		if ( IsInGroup(LE_PARTY_CATEGORY_INSTANCE) ) then
			LeaveInstanceParty();
		end
	end,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,
}

StaticPopupDialogs["CONFIRM_LEAVE_BATTLEFIELD"] = {
	text = CONFIRM_LEAVE_BATTLEFIELD,
	button1 = YES,
	button2 = CANCEL,
	OnShow = function(self)
		if ( IsActiveBattlefieldArena() and not C_PvP.IsInBrawl() ) then
			self.text:SetText(CONFIRM_LEAVE_ARENA);
		else
			self.text:SetText(CONFIRM_LEAVE_BATTLEFIELD);
		end
	end,
	OnAccept = function(self, data)
		LeaveBattlefield();
	end,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,
}

StaticPopupDialogs["CONFIRM_SURRENDER_ARENA"] = {
	text = CONFIRM_SURRENDER_ARENA,
	button1 = YES,
	button2 = CANCEL,
	OnShow = function(self)
		self.text:SetText(CONFIRM_SURRENDER_ARENA);
	end,
	OnAccept = function(self, data)
		SurrenderArena();
	end,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,
}

StaticPopupDialogs["SAVED_VARIABLES_TOO_LARGE"] = {
	text = SAVED_VARIABLES_TOO_LARGE,
	button1 = OKAY,
	timeout = 0,
	showAlertGear = 1,
	hideOnEscape = 1,
	whileDead = 1,
}

StaticPopupDialogs["PRODUCT_ASSIGN_TO_TARGET_FAILED"] = {
	text = PRODUCT_CLAIMING_FAILED,
	button1 = OKAY,
	timeout = 0,
	showAlertGear = 1,
	whileDead = 1,
}

StaticPopupDialogs["BATTLEFIELD_BORDER_WARNING"] = {
	text = "",
	OnShow = function(self)
		self.timeleft = self.data.timer;
	end,
	OnUpdate = function(self)
		self.text:SetFormattedText(BATTLEFIELD_BORDER_WARNING, self.data.name, SecondsToTime(self.timeleft, false, true));
		StaticPopup_Resize(self, "BATTLEFIELD_BORDER_WARNING");
	end,
	nobuttons = 1,
	timeout = 0,
	whileDead = 1,
	closeButton = 1,
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
	OnAccept = function(self)
		WardrobeOutfitManager:NameOutfit(self.editBox:GetText(), self.data);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 31,
	OnShow = function(self)
		self.button1:Disable();
		self.button2:Enable();
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		if ( self:GetParent().button1:IsEnabled() ) then
			StaticPopup_OnClick(self:GetParent(), 1);
		end
	end,
	EditBoxOnTextChanged = function (self)
		local parent = self:GetParent();
		if ( parent.editBox:GetText() ~= "" ) then
			parent.button1:Enable();
		else
			parent.button1:Disable();
		end
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end
};

StaticPopupDialogs["CONFIRM_OVERWRITE_TRANSMOG_OUTFIT"] = {
	text = TRANSMOG_OUTFIT_CONFIRM_OVERWRITE,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self) WardrobeOutfitManager:OverwriteOutfit(self.data.outfitID) end,
	OnCancel = function (self)
		local name = self.data.name;
		self:Hide();
		local dialog = StaticPopup_Show("NAME_TRANSMOG_OUTFIT");
		if ( dialog ) then
			self.editBox:SetText(name);
		end
	end,
	hideOnEscape = 1,
	timeout = 0,
	whileDead = 1,
	noCancelOnEscape = 1,
}

StaticPopupDialogs["CONFIRM_DELETE_TRANSMOG_OUTFIT"] = {
	text = TRANSMOG_OUTFIT_CONFIRM_DELETE,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self) 
		C_TransmogCollection.DeleteOutfit(self.data); 
	end,
	OnCancel = function (self) end,
	hideOnEscape = 1,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["TRANSMOG_OUTFIT_CHECKING_APPEARANCES"] = {
	text = TRANSMOG_OUTFIT_CHECKING_APPEARANCES,
	button1 = CANCEL,
	hideOnEscape = 1,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["TRANSMOG_OUTFIT_ALL_INVALID_APPEARANCES"] = {
	text = TRANSMOG_OUTFIT_ALL_INVALID_APPEARANCES,
	button1 = OKAY,
	hideOnEscape = 1,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["TRANSMOG_OUTFIT_SOME_INVALID_APPEARANCES"] = {
	text = TRANSMOG_OUTFIT_SOME_INVALID_APPEARANCES,
	button1 = SAVE,
	button2 = CANCEL,
	OnAccept = function(self)
		WardrobeOutfitManager:ContinueWithSave();
	end,
	hideOnEscape = 1,
	timeout = 0,
	whileDead = 1,
}

StaticPopupDialogs["TRANSMOG_APPLY_WARNING"] = {
	text = "%s",
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		return WardrobeTransmogFrame:ApplyPending(self.data.warningIndex);
	end,
	OnHide = function()
		WardrobeTransmogFrame:UpdateApplyButton();
	end,
	timeout = 0,
	hideOnEscape = 1,
	hasItemFrame = 1,
}

StaticPopupDialogs["TRANSMOG_FAVORITE_WARNING"] = {
	text = TRANSMOG_FAVORITE_LOSE_REFUND_AND_TRADE,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		local setFavorite = 1;
		local confirmed = true;
		WardrobeCollectionFrameModelDropdown_SetFavorite(self.data, setFavorite, confirmed);
	end,
	timeout = 0,
	hideOnEscape = 1,
}

StaticPopupDialogs["CONFIRM_UNLOCK_TRIAL_CHARACTER"] = {
	text = CHARACTER_UPGRADE_FINISH_BUTTON_POPUP_TEXT,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self, data)
		ClassTrialThanksForPlayingDialog:ConfirmCharacterBoost(data.guid, data.boostType);
	end,
	OnCancel = function()
		ClassTrialThanksForPlayingDialog:ShowThanks();
	end,
	timeout = 0,
	whileDead = 1,
	fullScreenCover = true,
}

StaticPopupDialogs["DANGEROUS_SCRIPTS_WARNING"] = {
	text = DANGEROUS_SCRIPTS_WARNING,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		SetAllowDangerousScripts(true);
	end,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
}

StaticPopupDialogs["EXPERIMENTAL_CVAR_WARNING"] = {
	text = EXPERIMENTAL_FEATURE_TURNED_ON_WARNING,
	button1 = ACCEPT,
	button2 = DISABLE,
	OnCancel = function()
		ResetTestCvars();
	end,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
}

StaticPopupDialogs["PREMADE_GROUP_SEARCH_DELIST_WARNING"] = {
	text = PREMADE_GROUP_SEARCH_DELIST_WARNING_TEXT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		LFGListFrame_BeginFindQuestGroup(LFGListFrame, self.data);
	end,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1,
}

StaticPopupDialogs["PREMADE_GROUP_INSECURE_SEARCH"] = {
	text = PREMADE_GROUP_INSECURE_SEARCH,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		LFGListFrame_BeginFindQuestGroup(LFGListFrame, self.data);
	end,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1,
}

StaticPopupDialogs["BACKPACK_INCREASE_SIZE"] = {
	text = BACKPACK_AUTHENTICATOR_DIALOG_DESCRIPTION,
	button1 = ACTIVATE,
	button2 = CANCEL,
	OnAccept = function(self)
		LoadURLIndex(41);
	end,
	OnHide = function(self)
		ContainerFrame_SetBackpackForceExtended(false);
	end,
	wide = true,
	timeout = 0,
	whileDead = 0,
}

StaticPopupDialogs["GROUP_FINDER_AUTHENTICATOR_POPUP"] = {
	text = GROUP_FINDER_AUTHENTICATOR_POPUP_DESC,
	button1 = ACTIVATE,
	button2 = CANCEL,
	OnAccept = function(self)
		LoadURLIndex(41);
	end,
	wide = true,
	timeout = 0,
	whileDead = 0,
}

StaticPopupDialogs["CLIENT_INVENTORY_FULL_OVERFLOW"] = {
	text = BACKPACK_AUTHENTICATOR_FULL_INVENTORY,
	button1 = OKAY,
	hideOnEscape = 1,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
}

StaticPopupDialogs["AUCTION_HOUSE_DEPRECATED"] = {
	text = AUCTION_HOUSE_DEPRECATED,
	button1 = OKAY,
	hideOnEscape = 1,
	timeout = 0,
	whileDead = 1,
	showAlert = 1,
}

local function InviteToClub(clubId, text)
	local invitationCandidates = C_Club.GetInvitationCandidates(nil, nil, nil, nil, clubId);
	for i, candidate in ipairs(invitationCandidates) do
		if candidate.name == text then
			C_Club.SendInvitation(clubId, candidate.memberId);
			return;
		end
	end
	local errorStr = ERROR_CLUB_ACTION_INVITE_MEMBER:format(ERROR_CLUB_MUST_BE_BNET_FRIEND);
	UIErrorsFrame:AddMessage(errorStr, RED_FONT_COLOR:GetRGB());
end

StaticPopupDialogs["INVITE_COMMUNITY_MEMBER"] = {
	text = INVITE_COMMUNITY_MEMBER_POPUP_INVITE_TEXT,
	subText = INVITE_COMMUNITY_MEMBER_POPUP_INVITE_SUB_TEXT_BTAG,
	button1 = INVITE_COMMUNITY_MEMBER_POPUP_SEND_INVITE,
	button2 = CANCEL,
	OnAccept = function(self, data)
		InviteToClub(data.clubId, self.editBox:GetText());
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 32,
	editBoxSecureText = true,
	editBoxWidth = 250,
	autoCompleteSource = C_Club.GetInvitationCandidates,
	autoCompleteArgs = {}, -- set dynamically below.
	OnShow = function(self, data)
		self.editBox:SetFocus();
		AutoCompleteEditBox_SetAutoCompleteSource(self.editBox, C_Club.GetInvitationCandidates, data.clubId);
		self.SubText:SetText(INVITE_COMMUNITY_MEMBER_POPUP_INVITE_SUB_TEXT_BNET_FRIEND);
		self.editBox.Instructions:SetText(INVITE_COMMUNITY_MEMBER_POPUP_INVITE_EDITBOX_INSTRUCTIONS);
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent().button1:Click();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
		ClearCursor();
	end
};

StaticPopupDialogs["INVITE_COMMUNITY_MEMBER_WITH_INVITE_LINK"] = Mixin({
	extraButton = INVITE_COMMUNITY_MEMBER_POPUP_OPEN_INVITE_MANAGER,
	OnExtraButton = function(self, data)
		CommunitiesTicketManagerDialog_Open(data.clubId, data.streamId);
	end,
}, StaticPopupDialogs["INVITE_COMMUNITY_MEMBER"]);

do
	local warningSeenBefore = false;
	StaticPopupDialogs["RAF_GRANT_LEVEL_ALLIED_RACE"] = {
		text = LEVEL_GRANT_ALLIED_RACE_WARNING,
		button1 = OKAY,
		button2 = CANCEL,
		OnAccept = function(self)
			GrantLevel(self.data);
		end,
		OnShow = function(self)
			if (not warningSeenBefore) then
				self.button1:Disable();
				self.timeLeft = 3;
				self.button1:SetText(self.timeLeft);
				self.ticker = C_Timer.NewTicker(1, function()
					self.timeLeft = self.timeLeft - 1;
					self.button1:SetText(self.timeLeft);
					if (self.timeLeft <= 0) then
						self.ticker:Cancel();
						self.ticker = nil;
						self.button1:SetText(OKAY);
						self.button1:Enable();
						warningSeenBefore = true;
					end
				end);
			end
		end,
		OnHide = function(self)
			if (self.ticker) then
				self.ticker:Cancel();
				self.ticker = nil;
			end
		end,
		showAlert = 1,
		whileDead = 0,
		hideOnEscape = 1,
	}
end

StaticPopupDialogs["REGIONAL_CHAT_DISABLED"] = {
	text = REGIONAL_RESTRICT_CHAT_DIALOG_TITLE,
	subText = REGIONAL_RESTRICT_CHAT_DIALOG_MESSAGE,
	button1 = REGIONAL_RESTRICT_CHAT_DIALOG_ENABLE,
	button2 = REGIONAL_RESTRICT_CHAT_DIALOG_DISABLE,
	OnAccept = function()
		Settings.OpenToCategory(Settings.SOCIAL_CATEGORY_ID);
	end,
	OnShow = function(self)
		C_SocialRestrictions.AcknowledgeRegionalChatDisabled();
	end,
	timeout = 0,
	hideOnEscape = 0,
	exclusive = 1,
	wide = true,
};

StaticPopupDialogs["CHAT_CONFIG_DISABLE_CHAT"] = {
	text = RESTRICT_CHAT_CONFIG_DIALOG_MESSAGE,
	button1 = RESTRICT_CHAT_CONFIG_DIALOG_DISABLE,
	button2 = RESTRICT_CHAT_CONFIG_DIALOG_CANCEL,
	OnAccept = function()
		local disabled = true;
		C_SocialRestrictions.SetChatDisabled(disabled);
		ChatConfigFrame_OnChatDisabledChanged(disabled);
	end,
	timeout = 0,
	hideOnEscape = 0,
	exclusive = 1,
};

StaticPopupDialogs["ON_BATTLEFIELD_AUTO_QUEUE"] = {
	button1 = JOIN,
	button2 = BATTLEFIELD_GROUP_JOIN,
	button3 = CANCEL,
	selectCallbackByIndex = true,
	OnShow = function(self)
		self.text:SetText(WORLD_PVP_INVITED_WARMUP:format(GetWorldPVPQueueMapName(true)));
		if ( not IsInGroup() or not UnitIsGroupLeader("player") ) then
			self.button2:Disable();
		end
	end,
	OnButton1 = function(self)
		JoinWorldPVPQueue(true, false);
	end,
	OnButton2 = function(self, data, reason)
		JoinWorldPVPQueue(true, true);
	end,
	OnButton3 = function()

	end,
	timeout = 15,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = false,
	exclusive = 1,
};

StaticPopupDialogs["ON_BATTLEFIELD_AUTO_QUEUE_EJECT"] = {
	button1 = OKAY,
	OnShow = function(self)
		self.text:SetText(WORLD_PVP_AUTO_QUEUE_EJECT:format(GetWorldPVPQueueMapName(true)));
	end,
	OnButton1 = function()
	end,
	timeout = 15,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = false,
};

StaticPopupDialogs["ON_WORLD_PVP_QUEUE"] = {
	button1 = JOIN,
	button2 = BATTLEFIELD_GROUP_JOIN,
	button3 = CANCEL,
	selectCallbackByIndex = true,
	OnShow = function(self)
		self.text:SetText(WORLD_PVP_INVITED_WARMUP:format(GetWorldPVPQueueMapName(false)));
		if ( not IsInGroup() or not UnitIsGroupLeader("player") ) then
			self.button2:Disable();
		end
	end,
	OnButton1 = function(self)
		JoinWorldPVPQueue(false, false);
	end,
	OnButton2 = function(self, data, reason)
		JoinWorldPVPQueue(false, true);
	end,
	OnButton3 = function()

	end,
	showAlert = 1,
	hideOnEscape = false,
};

StaticPopupDialogs["RAID_PROFILE_DELETION"] = {
	text = CONFIRM_COMPACT_UNIT_FRAME_PROFILE_DELETION,
	button1 = DELETE,
	button2 = CANCEL,
	OnAccept = function(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		local newProfile = GetRaidProfileName(1);
		if ( newProfile == self.data.profile ) then
			newProfile = GetRaidProfileName(2);
		end
		CompactUnitFrameProfiles_ActivateRaidProfile(newProfile);
		DeleteRaidProfile(self.data.profile);
		self.data.cbObject:OnDeleted();
	end,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["DOWNLOAD_HIGH_RES_TEXTURES"] = {
    text = IsMacClient() and HD_TEXTURES_DLG_TEXT_MAC or HD_TEXTURES_DLG_TEXT,
    button1 = IsMacClient() and HD_TEXTURES_DLG_ACCEPT_MAC or HD_TEXTURES_DLG_ACCEPT,
    button2 = CANCEL,
    escapeHides = true,
	OnAccept = function()
		C_BattleNet.InstallHighResTextures();
	end,
};

StaticPopupDialogs["RAID_PROFILE_NEW"] = {
	text = CREATE_NEW_COMPACT_UNIT_FRAME_PROFILE,
	button1 = CREATE,
	button2 = CANCEL,
	OnAccept = function(self)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		local newProfileName = strtrim(self.editBox:GetText());
		CompactUnitFrameProfiles_CreateProfile(newProfileName);
		self.data.cbObject:OnAdded(newProfileName);
	end,
	EditBoxOnTextChanged = function(self)
		if ( strtrim(self:GetText()) == "" ) then
			self:GetParent().button1:Disable();
		else
			self:GetParent().button1:Enable();
		end
	end,
	EditBoxOnEnterPressed = function(self)
		local newProfileName = strtrim(self:GetParent().editBox:GetText());
		CompactUnitFrameProfiles_CreateProfile(newProfileName);
		self:GetParent().data.cbObject:OnAdded(newProfileName);
		self:GetParent():Hide();
	end,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 31
};
