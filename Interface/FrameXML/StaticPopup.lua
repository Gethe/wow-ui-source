StaticPopup_DisplayedFrames = { };

STATICPOPUP_NUMDIALOGS = 4;
STATICPOPUP_TIMEOUT = 60;
STATICPOPUP_TEXTURE_ALERT = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew";
STATICPOPUP_TEXTURE_ALERTGEAR = "Interface\\DialogFrame\\UI-Dialog-Icon-AlertOther";
StaticPopupDialogs = { };

local FullscreenFrame = UIParent;

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

function StaticPopup_StandardConfirmationTextHandler(self, expectedText)
	local parent = self:GetParent();
	parent.button1:SetEnabled(ConfirmationEditBoxMatches(parent.editBox, expectedText));
end

function StaticPopup_StandardNonEmptyTextHandler(self)
	local parent = self:GetParent();
	parent.button1:SetEnabled(UserEditBoxNonEmpty(parent.editBox));
end

function StaticPopup_StandardEditBoxOnEscapePressed(self)
	self:GetParent():Hide();
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
	OnAccept = function (self) C_EquipmentSet.SaveEquipmentSet(self.data, self.selectedIcon); GearManagerPopupFrame:Hide(); end,
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

StaticPopupDialogs["CONFIRM_GLYPH_PLACEMENT"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function (self) AttachGlyphToSpell(self.data.id); end,
	OnCancel = function (self)
	end,
	OnShow = function(self)
		self.text:SetFormattedText(CONFIRM_GLYPH_PLACEMENT_NO_COST, self.data.name, self.data.currentName);
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}

StaticPopupDialogs["CONFIRM_GLYPH_REMOVAL"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function (self) AttachGlyphToSpell(self.data.id); end,
	OnCancel = function (self)
	end,
	OnShow = function(self)
		self.text:SetFormattedText(CONFIRM_GLYPH_REMOVAL, self.data.name);
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
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

StaticPopupDialogs["CONFIRM_PURCHASE_ITEM_DELAYED"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		BuyMerchantItem(MerchantFrame.itemIndex, MerchantFrame.count);
	end,
	OnShow = function(self, data)
		self.text:SetText(data.confirmationText);
	end,
	timeout = 0,
	hideOnEscape = 1,
	showAlert = 1,
	hasItemFrame = 1,
	acceptDelay = 5,
}

StaticPopupDialogs["CONFIRM_UPGRADE_ITEM"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		ItemUpgradeFrame:OnConfirm();
	end,
	OnCancel = function()
		ItemUpgradeFrame:Update();
	end,
	OnShow = function(self, data)
		if data.isItemBound then
			self.text:SetText(CONFIRM_UPGRADE_ITEM:format(data.costString));
		else
			self.text:SetText(CONFIRM_UPGRADE_ITEM_BIND:format(data.costString));
		end
	end,
	OnHide = function()

	end,
	timeout = 0,
	hideOnEscape = 1,
	hasItemFrame = 1,
	compactItemFrame = true,
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
		end
	end,
	timeout = 0,
	hideOnEscape = 1,
};

StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"] = {
	text = CONFIRM_BATTLEFIELD_ENTRY,
	button1 = ENTER_LFG,
	button2 = LEAVE_QUEUE,
	OnShow = function(self, data)
		local status, mapName, teamSize, registeredMatch = GetBattlefieldStatus(data);
		if ( teamSize == 0 ) then
			self.button2:Enable();
		else
			self.button2:Disable();
		end
	end,
	OnAccept = function(self, data)
		if ( not AcceptBattlefieldPort(data, true) ) then
			return 1;
		end
		if( StaticPopup_Visible( "DEATH" ) ) then
			StaticPopup_Hide( "DEATH" );
		end
	end,
	OnCancel = function(self, data)
		if ( not AcceptBattlefieldPort(data, false) ) then	--Actually declines the battlefield port.
			return 1;
		end
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1,
	noCancelOnEscape = 1,
	noCancelOnReuse = 1,
	multiple = 1,
	closeButton = 1,
	closeButtonIsHide = 1,
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
	OnShow = function(self)
		self.reportToken = C_ReportSystem.InitiateReportPlayer(PLAYER_REPORT_TYPE_BAD_BATTLEPET_NAME);
	end,
	OnAccept = function(self)
		C_ReportSystem.SendReportPlayer(self.reportToken);
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
	OnShow = function(self)
		self.reportToken = C_ReportSystem.InitiateReportPlayer(PLAYER_REPORT_TYPE_BAD_PET_NAME);
	end,
	OnAccept = function(self)
		C_ReportSystem.SendReportPlayer(self.reportToken);
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
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
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
			ChatConfig_ResetChatSettings();
		end
	end,
	timeout = 0,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
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
	button4 = DEATH_RECAP,
	selectCallbackByIndex = true,
	OnShow = function(self)
		self.timeleft = GetReleaseTimeRemaining();

		if ( IsActiveBattlefieldArena() and not C_PvP.IsInBrawl() ) then
			self.text:SetText(DEATH_RELEASE_SPECTATOR);
		elseif ( self.timeleft == -1 ) then
			self.text:SetText(DEATH_RELEASE_NOTIMER);
		end
		if ( not self.UpdateRecapButton ) then
			self.UpdateRecapButton = function( self )
				if ( DeathRecap_HasEvents() ) then
					self.button4:Enable();
					self.button4:SetScript("OnEnter", nil );
					self.button4:SetScript("OnLeave", nil);
				else
					self.button4:Disable();
					self.button4:SetMotionScriptsWhileDisabled(true);
					self.button4:SetScript("OnEnter", function(self)
						GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
						GameTooltip:SetText(DEATH_RECAP_UNAVAILABLE);
						GameTooltip:Show();
					end );
					self.button4:SetScript("OnLeave", GameTooltip_Hide);
				end
			end
		end

		self:UpdateRecapButton();
	end,
	OnHide = function(self)
		self.button2.option = nil;
		self.button3.option = nil;
		self.button4:SetScript("OnEnter", nil );
		self.button4:SetScript("OnLeave", nil);
		self.button4:SetMotionScriptsWhileDisabled(false);
	end,
	OnButton1 = function(self)
		if ( IsActiveBattlefieldArena() and not C_PvP.IsInBrawl() ) then
			local info = ChatTypeInfo["SYSTEM"];
			DEFAULT_CHAT_FRAME:AddMessage(ARENA_SPECTATOR, info.r, info.g, info.b, info.id);
		end
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
	OnButton4 = function()
		OpenDeathRecapUI();
		return true;
	end,
	OnUpdate = function(self, elapsed)
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
			local hasNoReleaseAura, noReleaseDuration, hasUntilCancelledDuration = HasNoReleaseAura();
			self.button1:SetEnabled(not hasNoReleaseAura);
			if ( hasNoReleaseAura ) then
				if hasUntilCancelledDuration then
					self.button1:SetText(DEATH_RELEASE);
				else
					self.button1:SetText(math.floor(noReleaseDuration));
				end
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

		if ( self.UpdateRecapButton) then
			self:UpdateRecapButton();
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

		local _, _, guid, _, _, level, spec, itemLevel = GetInviteConfirmationInfo(self.data);
		local className, classFilename, _, _, gender, characterName, _ = GetPlayerInfoByGUID(guid);

		GameTooltip:SetOwner(self.linkRegion);

		if ( className ) then
			self.nextUpdateTime = nil; -- The tooltip will be created with valid data, no more updates necessary.

			local _, _, _, colorCode = GetClassColor(classFilename);
			GameTooltip:SetText(WrapTextInColorCode(characterName, colorCode));

			local _, specName = GetSpecializationInfoByID(spec, gender);
			local characterLine = CHARACTER_LINK_CLASS_LEVEL_SPEC_TOOLTIP:format(level, className, specName);
			local itemLevelLine = CHARACTER_LINK_ITEM_LEVEL_TOOLTIP:format(itemLevel);

			GameTooltip:AddLine(characterLine, HIGHLIGHT_FONT_COLOR:GetRGB());
			GameTooltip:AddLine(itemLevelLine, HIGHLIGHT_FONT_COLOR:GetRGB());
			GameTooltip_SetTooltipWaitingForData(GameTooltip, false);
		else
			self.nextUpdateTime = timeNow + .5;
			GameTooltip:SetText(RETRIEVING_DATA, RED_FONT_COLOR:GetRGB());
			GameTooltip_SetTooltipWaitingForData(GameTooltip, true);
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
		local linkType = string.match(link, '(.-):');
		if ( linkType ~= "player" ) then
			return;
		end

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
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	OnCancel = function(self, data)
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
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
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
	OnCancel = function(self)
		CancelLogout();
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

StaticPopupDialogs["CONFIRM_AZERITE_EMPOWERED_RESPEC_EXPENSIVE"] = {
	text = CONFIRM_AZERITE_EMPOWERED_ITEM_RESPEC_EXPENSIVE,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		PlaySound(SOUNDKIT.UI_80_AZERITEARMOR_REFORGE);
		C_AzeriteEmpoweredItem.ConfirmAzeriteEmpoweredItemRespec(data.empoweredItemLocation);
	end,
	OnShow = function(self, data)
		self.button1:Disable();
		self.button2:Enable();
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		if ( self:GetParent().button1:IsEnabled() ) then
			self:GetParent().button1:Click();
		end
	end,
	EditBoxOnTextChanged = function (self)
		StaticPopup_StandardConfirmationTextHandler(self, CONFIRM_AZERITE_EMPOWERED_RESPEC_STRING);
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,

	timeout = 0,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 32,
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
		local itemLocation = C_Cursor.GetCursorItem();
		if itemLocation and C_Item.DoesItemExist(itemLocation) and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation) then
			local msg = C_SpellBook.ContainsAnyDisenchantSpell() and DELETE_AZERITE_SCRAPPABLE_OR_DISENCHANTABLE_ITEM or DELETE_AZERITE_SCRAPPABLE_ITEM;
			local itemName = self.text.text_arg1;
			local azeriteIconMarkup = CreateTextureMarkup("Interface\\Icons\\INV_AzeriteDebuff",64,64,16,16,0,1,0,1,0,-2);
			self.text:SetText(string.format(msg, itemName, azeriteIconMarkup));
		end

		self.button1:Disable();
		self.button2:Enable();
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
		MerchantFrame_ResetRefundItem();
		if GameTooltip:GetOwner() == self then
			GameTooltip:Hide();
		end
	end,
	OnHyperlinkEnter = function(self, link, text, region, boundsLeft, boundsBottom, boundsWidth, boundsHeight)
		GameTooltip:SetOwner(self, "ANCHOR_PRESERVE");
		GameTooltip:ClearAllPoints();
		local cursorClearance = 30;
		GameTooltip:SetPoint("TOPLEFT", region, "BOTTOMLEFT", boundsLeft, boundsBottom - cursorClearance);
		GameTooltip:SetHyperlink(link);
	end,
	OnHyperlinkLeave = function(self)
		GameTooltip:Hide();
	end,
	OnHyperlinkClick = function(self, link, text, button)
		GameTooltip:Hide();
	end,
	EditBoxOnEnterPressed = function(self)
		if ( self:GetParent().button1:IsEnabled() ) then
			DeleteCursorItem();
			self:GetParent():Hide();
		end
	end,
	EditBoxOnTextChanged = function (self)
		StaticPopup_StandardConfirmationTextHandler(self, DELETE_ITEM_CONFIRM_STRING);
	end,
	EditBoxOnEscapePressed = function(self)
		StaticPopup_StandardEditBoxOnEscapePressed(self);
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
		StaticPopup_StandardConfirmationTextHandler(self, DELETE_ITEM_CONFIRM_STRING);
	end,
	EditBoxOnEscapePressed = function(self)
		StaticPopup_StandardEditBoxOnEscapePressed(self);
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
		C_QuestLog.AbandonQuest();
		if ( QuestLogPopupDetailFrame:IsShown() ) then
			HideUIPanel(QuestLogPopupDetailFrame);
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
		C_QuestLog.AbandonQuest();
		if ( QuestLogPopupDetailFrame:IsShown() ) then
			HideUIPanel(QuestLogPopupDetailFrame);
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
	OnAccept = function(self)
		BNSetFriendNote(FriendsFrame.NotesID, self.editBox:GetText());
	end,
	OnShow = function(self)
		local accountInfo = C_BattleNet.GetAccountInfoByID(FriendsFrame.NotesID);
		if accountInfo and accountInfo.note ~= "" then
			self.editBox:SetText(accountInfo.note);
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
	OnAccept = function(self, data)
		C_Club.KickMember(data.clubId, data.memberId);
	end,
	OnShow = function(self, data)
		if data.clubType == Enum.ClubType.Character then
			self.text:SetText(CONFIRM_REMOVE_CHARACTER_COMMUNITY_MEMBER_LABEL:format(data.name));
		else
			self.text:SetText(CONFIRM_REMOVE_COMMUNITY_MEMBER_LABEL:format(data.name));
		end
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
		if clubInfo.clubType == Enum.ClubType.Character then
			self.text:SetText(CONFIRM_LEAVE_AND_DESTROY_CHARACTER_COMMUNITY);
			self.SubText:SetText(CONFIRM_LEAVE_AND_DESTROY_CHARACTER_COMMUNITY_SUBTEXT);
		else
			self.text:SetText(CONFIRM_LEAVE_AND_DESTROY_COMMUNITY);
			self.SubText:SetText(CONFIRM_LEAVE_AND_DESTROY_COMMUNITY_SUBTEXT);
		end
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
		if clubInfo.clubType == Enum.ClubType.Character then
			self.text:SetText(CONFIRM_LEAVE_CHARACTER_COMMUNITY);
			self.SubText:SetFormattedText(CONFIRM_LEAVE_CHARACTER_COMMUNITY_SUBTEXT, clubInfo.name);
		else
			self.text:SetText(CONFIRM_LEAVE_COMMUNITY);
			self.SubText:SetFormattedText(CONFIRM_LEAVE_COMMUNITY_SUBTEXT, clubInfo.name);
		end
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
		if clubInfo.clubType == Enum.ClubType.BattleNet then
			self.text:SetText(CONFIRM_DESTROY_COMMUNITY:format(clubInfo.name));
		else
			self.text:SetText(CONFIRM_DESTROY_CHARACTER_COMMUNITY:format(clubInfo.name));
		end

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
		StaticPopup_StandardConfirmationTextHandler(self, COMMUNITIES_DELETE_CONFIRM_STRING);
	end,
	EditBoxOnEscapePressed = function(self)
		StaticPopup_StandardEditBoxOnEscapePressed();
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
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

local function ClubInviteDisabledOnEnter(self)
	if(not self:IsEnabled()) then
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
		GameTooltip_AddColoredLine(GameTooltip, CLUB_FINDER_MAX_MEMBER_COUNT_HIT, RED_FONT_COLOR, true);
		GameTooltip:Show();
	end
end

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
	OnShow = function(self, data)
		self.editBox:SetFocus();

		self.button1:SetMotionScriptsWhileDisabled(true);
		self.button1:SetScript("OnEnter", function(self)
			ClubInviteDisabledOnEnter(self);
		end );
		self.button1:SetScript("OnLeave", GameTooltip_Hide);
		if (self.extraButton) then
			self.extraButton:SetMotionScriptsWhileDisabled(true);
			self.extraButton:SetScript("OnEnter", function(self)
				ClubInviteDisabledOnEnter(self);
			end );
			self.extraButton:SetScript("OnLeave", GameTooltip_Hide);
		end
		local clubInfo = C_Club.GetClubInfo(data.clubId);
		if(clubInfo and clubInfo.memberCount and clubInfo.memberCount >= C_Club.GetClubCapacity()) then
			self.button1:Disable();
			if (self.extraButton) then
				self.extraButton:Disable();
			end
		else
			self.button1:Enable();
			if (self.extraButton) then
				self.extraButton:Enable();
			end
		end
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
		self.button1:SetScript("OnEnter", nil );
		self.button1:SetScript("OnLeave", nil);
		if (self.extraButton) then
			self.extraButton:SetScript("OnEnter", nil );
			self.extraButton:SetScript("OnLeave", nil);
		end
	end,
	EditBoxOnEnterPressed = function(self)
		local parent = self:GetParent();
		local invitee = parent.editBox:GetText();
		if invitee == "" then
			ChatFrame_OpenChat("");
		else
			C_GuildInfo.Invite(invitee);
			parent:Hide();
		end
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["ADD_GUILDMEMBER_WITH_FINDER_LINK"] = Mixin({
	extraButton = CLUB_FINDER_LINK_POST_IN_CHAT,
	OnExtraButton = function(self, data)
		local clubInfo = ClubFinderGetCurrentClubListingInfo(data.clubId);
		if (clubInfo) then
			local link = GetClubFinderLink(clubInfo.clubFinderGUID, clubInfo.name);
			if not ChatEdit_InsertLink(link) then
				ChatFrame_OpenChat(link);
			end
		end
	end,
}, StaticPopupDialogs["ADD_GUILDMEMBER"]);

StaticPopupDialogs["CONVERT_TO_RAID"] = {
	text = CONVERT_TO_RAID_LABEL,
	button1 = CONVERT,
	button2 = CANCEL,
	OnAccept = function(self, data)
		C_PartyInfo.ConfirmInviteUnit(data);
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
		C_PartyInfo.ConfirmConvertToRaid();
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
		if data then
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
		if data then
			self.text:SetFormattedText(REMOVE_GUILDMEMBER_LABEL, data.name);
		else
			self.text:SetText(GuildFrame.selectedName);
		end
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
	editBoxWidth = 260,
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
	editBoxWidth = 260,
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
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
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
		HideUIPanel(ProfessionsFrame);
	end,
	OnShow = function(self)
		self.button1:Disable();
		self.button2:Enable();
		self.editBox:SetFocus();
	end,
	OnHide = function(self)
		self.editBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self, index)
		local parent = self:GetParent();
		if parent.button1:IsEnabled() then
			AbandonSkill(index);
			HideUIPanel(ProfessionsFrame);
			parent:Hide();
		end
	end,
	EditBoxOnTextChanged = function(self)
		local parent = self:GetParent();
		StaticPopup_StandardConfirmationTextHandler(self, UNLEARN_SKILL_CONFIRMATION);
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
		ClearCursor();
	end,
	timeout = STATICPOPUP_TIMEOUT,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 32,
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
		end
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
		C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.SpiritHealer);
	end,
	OnUpdate = function(self, dialog)
		if ( not C_PlayerInteractionManager.IsValidNPCInteraction(Enum.PlayerInteractionType.SpiritHealer) ) then
			C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.SpiritHealer);
			self:Hide();
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
StaticPopupDialogs["BIND_SOCKET"] = {
	text = ACTION_WILL_BIND_ITEM,
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
StaticPopupDialogs["REPLACE_TRADESKILL_ENCHANT"] = {
	text = REPLACE_ENCHANT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self)
		C_Item.ReplaceTradeskillEnchant();
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
	notClosableByLogout = 1
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
	OnAccept = function(self)
		CombatConfig_CreateCombatFilter(self.editBox:GetText());
	end,
	timeout = 0,
	EditBoxOnEnterPressed = function(self, data)
		local parent = self:GetParent();
		CombatConfig_CreateCombatFilter(parent.editBox:GetText());
		parent:Hide();
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
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
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
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
		StaticPopup_StandardNonEmptyTextHandler(self);
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

StaticPopupDialogs["CONFIRM_BLOCK_FRIEND"] = {
	text = "%s",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self, accountID)
		BNSetBlocked(accountID, false);
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
		local ratedDeserterPenalty = C_PvP.GetPVPActiveRatedMatchDeserterPenalty();
		if ( ratedDeserterPenalty ) then
			local ratingChange = math.abs(ratedDeserterPenalty.personalRatingChange);
			local queuePenaltySpellLink, queuePenaltyDuration = C_SpellBook.GetSpellLinkFromSpellID(ratedDeserterPenalty.queuePenaltySpellID), SecondsToTime(ratedDeserterPenalty.queuePenaltyDuration);
			self.text:SetText(CONFIRM_LEAVE_RATED_MATCH_WITH_PENALTY:format(ratingChange, queuePenaltyDuration, queuePenaltySpellLink));
		elseif ( IsActiveBattlefieldArena() and not C_PvP.IsInBrawl() ) then
			self.text:SetText(CONFIRM_LEAVE_ARENA);
		else
			self.text:SetText(CONFIRM_LEAVE_BATTLEFIELD);
		end
	end,
	OnAccept = function(self, data)
		LeaveBattlefield();
	end,
	OnHyperlinkEnter = function(self, link, text, region, boundsLeft, boundsBottom, boundsWidth, boundsHeight)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT");
		GameTooltip:SetHyperlink(link);
		GameTooltip:Show();
	end,
	OnHyperlinkLeave = function(self)
		GameTooltip_Hide();
	end,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,
	-- acceptDelay - Dynamically set in ConfirmOrLeaveBattlefield()
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
		WardrobeOutfitFrame:NameOutfit(self.editBox:GetText(), self.data);
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
		StaticPopup_StandardNonEmptyTextHandler(self);
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
};

StaticPopupDialogs["CONFIRM_OVERWRITE_TRANSMOG_OUTFIT"] = {
	text = TRANSMOG_OUTFIT_CONFIRM_OVERWRITE,
	button1 = YES,
	button2 = NO,
	OnAccept = function (self) WardrobeOutfitFrame:OverwriteOutfit(self.data.outfitID) end,
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
	OnAccept = function (self) WardrobeOutfitFrame:DeleteOutfit(self.data); end,
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
	button1 = OKAY,
	button2 = CANCEL,
	OnShow = function(self)
		if ( WardrobeOutfitFrame.name ) then
			self.button1:SetText(SAVE);
		else
			self.button1:SetText(CONTINUE);
		end
	end,
	OnAccept = function(self)
		WardrobeOutfitFrame:ContinueWithSave();
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
		WardrobeCollectionFrameModelDropDown_SetFavorite(self.data, setFavorite, confirmed);
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

StaticPopupDialogs["PREMADE_GROUP_LEADER_CHANGE_DELIST_WARNING"] = {
	text = GROUP_FINDER_DELIST_WARNING_TITLE,
	subText = GROUP_FINDER_DELIST_WARNING_SUBTEXT,
	button1 = LIST_MY_GROUP,
	button2 = GROUP_FINDER_DESLIST_WARNING_EDIT_LISTING,
	button3 = UNLIST_MY_GROUP,

	OnAccept = function(self)
		self.delistOnHide = false;
	end,

	OnCancel = function(self, data, reason)
		if(reason ~= "timeout") then
			LFGListUtil_OpenBestWindow(true);
			self.delistOnHide = false;
		end
	end,

	OnHide = function(self)
		if  (C_LFGList.HasActiveEntryInfo() and self.delistOnHide) then
			C_LFGList.RemoveListing();
		end
	end,

	OnShow = function(self, data)
		self.text:SetText(GROUP_FINDER_DELIST_WARNING_TITLE:format(data.listingTitle));
		self.timeleft = data.delistTime;
		self.delistOnHide = true;
	end,

	whileDead = 1,
	showAlert = 1,
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

StaticPopupDialogs["LEAVING_TUTORIAL_AREA"] = {
	text = "",
	button1 = "",
	button2 = NPE_ABANDON_LEAVE_TUTORIAL,
	OnButton1 = function(self)
		C_Tutorial.ReturnToTutorialArea();
	end,
	OnButton2 = function(self)
		C_Tutorial.AbandonTutorialArea();
	end,
	OnShow = function(self)
		if UnitFactionGroup("player") == "Horde" then
			self.button1:SetText(NPE_ABANDON_H_RETURN);
			self.text:SetText(NPE_ABANDON_H_WARNING);
		else
			self.button1:SetText(NPE_ABANDON_A_RETURN);
			self.text:SetText(NPE_ABANDON_A_WARNING);
		end
	end,
	selectCallbackByIndex = true,
};

local function InviteToClub(clubId, text)
	local clubInfo = C_Club.GetClubInfo(clubId);
	local isBattleNetClub = clubInfo.clubType == Enum.ClubType.BattleNet;
	if isBattleNetClub then
		local invitationCandidates = C_Club.GetInvitationCandidates(nil, nil, nil, nil, clubId);
		for i, candidate in ipairs(invitationCandidates) do
			if candidate.name == text then
				C_Club.SendInvitation(clubId, candidate.memberId);
				return;
			end
		end
		local errorStr = ERROR_CLUB_ACTION_INVITE_MEMBER:format(ERROR_CLUB_MUST_BE_BNET_FRIEND);
		UIErrorsFrame:AddMessage(errorStr, RED_FONT_COLOR:GetRGB());
	else
		C_Club.SendCharacterInvitation(clubId, text);
	end
end

StaticPopupDialogs["CLUB_FINDER_ENABLED_DISABLED"] = {
	text = CLUB_FINDER_ENABLE_DISABLE_MESSAGE,
	button1 = OKAY,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1,
}

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

		local clubInfo = C_Club.GetClubInfo(data.clubId);
		if clubInfo.clubType == Enum.ClubType.BattleNet then
			AutoCompleteEditBox_SetAutoCompleteSource(self.editBox, C_Club.GetInvitationCandidates, data.clubId);
			self.SubText:SetText(INVITE_COMMUNITY_MEMBER_POPUP_INVITE_SUB_TEXT_BNET_FRIEND);
			self.editBox.Instructions:SetText(INVITE_COMMUNITY_MEMBER_POPUP_INVITE_EDITBOX_INSTRUCTIONS);
		else
			AutoCompleteEditBox_SetAutoCompleteSource(self.editBox, GetAutoCompleteResults, AUTOCOMPLETE_LIST.COMMUNITY.include, AUTOCOMPLETE_LIST.COMMUNITY.exclude);
			self.SubText:SetText(INVITE_COMMUNITY_MEMBER_POPUP_INVITE_SUB_TEXT_CHARACTER);
			self.editBox.Instructions:SetText("");
		end
		self.button1:SetMotionScriptsWhileDisabled(true);
		self.button1:SetScript("OnEnter", function(self)
			ClubInviteDisabledOnEnter(self);
		end );
		self.button1:SetScript("OnLeave", GameTooltip_Hide);
		if (self.extraButton) then
			self.extraButton:SetMotionScriptsWhileDisabled(true);
			self.extraButton:SetScript("OnEnter", function(self)
				ClubInviteDisabledOnEnter(self);
			end );
			self.extraButton:SetScript("OnLeave", GameTooltip_Hide);
		end

		if(clubInfo and clubInfo.memberCount and clubInfo.memberCount >= C_Club.GetClubCapacity()) then
			self.button1:Disable();
			if (self.extraButton) then
				self.extraButton:Disable();
			end
		else
			self.button1:Enable();
			if (self.extraButton) then
				self.extraButton:Enable();
			end
		end
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		self.editBox:SetText("");
		self.button1:SetScript("OnEnter", nil );
		self.button1:SetScript("OnLeave", nil);
		if (self.extraButton) then
			self.extraButton:SetScript("OnEnter", nil );
			self.extraButton:SetScript("OnLeave", nil);
		end
	end,
	EditBoxOnEnterPressed = function(self)
		self:GetParent().button1:Click();
	end,
	EditBoxOnEscapePressed = function(self)
		StaticPopup_StandardEditBoxOnEscapePressed(self);
		ClearCursor();
	end
};

StaticPopupDialogs["INVITE_COMMUNITY_MEMBER_WITH_INVITE_LINK"] = Mixin({
	extraButton = INVITE_COMMUNITY_MEMBER_POPUP_OPEN_INVITE_MANAGER,

	OnExtraButton = function(self, data)
		CommunitiesTicketManagerDialog_Open(data.clubId, data.streamId);
	end,
}, StaticPopupDialogs["INVITE_COMMUNITY_MEMBER"]);

StaticPopupDialogs["CONFIRM_RAF_REMOVE_RECRUIT"] = {
	text = RAF_REMOVE_RECRUIT_CONFIRM,
	button1 = YES,
	button2 = NO,
	OnAccept = function(self, data)
		C_RecruitAFriend.RemoveRAFRecruit(data);
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
	end,
	EditBoxOnEnterPressed = function(self, data)
		if ( self:GetParent().button1:IsEnabled() ) then
			C_RecruitAFriend.RemoveRAFRecruit(data);
			self:GetParent():Hide();
		end
	end,
	EditBoxOnTextChanged = function (self)
		StaticPopup_StandardConfirmationTextHandler(self, REMOVE_RECRUIT_CONFIRM_STRING);
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
};

StaticPopupDialogs["REGIONAL_CHAT_DISABLED"] = {
	text = REGIONAL_RESTRICT_CHAT_DIALOG_TITLE,
	subText = REGIONAL_RESTRICT_CHAT_DIALOG_MESSAGE,
	button1 = REGIONAL_RESTRICT_CHAT_DIALOG_ENABLE,
	button2 = REGIONAL_RESTRICT_CHAT_DIALOG_DISABLE,
	OnAccept = function()
		local disabled = false;
		C_SocialRestrictions.SetChatDisabled(disabled);
		ChatConfigFrame_OnChatDisabledChanged(disabled);
	end,
	OnShow = function(self)
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
	OnAccept = function()
		local disabled = true;
		C_SocialRestrictions.SetChatDisabled(disabled);
		ChatConfigFrame_OnChatDisabledChanged(disabled);
	end,
	timeout = 0,
	exclusive = 1,
};

local factionMajorCities = {
	["Alliance"] = STORMWIND,
	["Horde"] = ORGRIMMAR,
}

StaticPopupDialogs["RETURNING_PLAYER_PROMPT"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnShow = function(self)
		local playerFactionGroup = UnitFactionGroup("player");
		local factionCity = playerFactionGroup and factionMajorCities[playerFactionGroup] or nil;
		if(factionCity) then
			self.text:SetText(RETURNING_PLAYER_PROMPT:format(factionCity));
		end
	end,
	OnAccept = function(self)
		C_ReturningPlayerUI.AcceptPrompt();
		self:Hide();
	end,
	OnCancel = function()
		C_ReturningPlayerUI.DeclinePrompt();
	end,
	timeout = 0,
	exclusive = 1,
}

StaticPopupDialogs["CRAFTING_HOUSE_DISABLED"] = {
	text = ERR_CRAFTING_HOUSE_DISABLED,
	button1 = OKAY,
	timeout = 0,
	showAlertGear = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["PERKS_PROGRAM_DISABLED"] = {
	text = ERR_PERKS_PROGRAM_DISABLED,
	button1 = OKAY,
	timeout = 0,
	showAlertGear = 1,
	hideOnEscape = 1
};

function StaticPopup_FindVisible(which, data)
	local info = StaticPopupDialogs[which];
	if ( not info ) then
		return nil;
	end
	for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
		local frame = _G["StaticPopup"..index];
		if ( frame:IsShown() and (frame.which == which) and (not info.multiple or (frame.data == data)) ) then
			return frame;
		end
	end
	return nil;
end

function StaticPopup_Visible(which)
	for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
		local frame = _G["StaticPopup"..index];
		if( frame:IsShown() and (frame.which == which) ) then
			return frame:GetName(), frame;
		end
	end
	return nil;
end

function StaticPopup_Resize(dialog, which)
	local info = StaticPopupDialogs[which];
	if ( not info ) then
		return nil;
	end

	local text = _G[dialog:GetName().."Text"];
	local editBox = _G[dialog:GetName().."EditBox"];
	local button1 = _G[dialog:GetName().."Button1"];
	local extraButton = dialog.extraButton;

	local maxHeightSoFar, maxWidthSoFar = (dialog.maxHeightSoFar or 0), (dialog.maxWidthSoFar or 0);
	local width = 320;

	if ( info.verticalButtonLayout ) then
		width = width + 30;
	else
		if (info.showAlert or info.showAlertGear or info.customAlertIcon or info.closeButton or info.wide) then
			width = 420;
		elseif ( info.editBoxWidth and info.editBoxWidth > 260 ) then
			width = width + (info.editBoxWidth - 260);
		elseif ( which == "GUILD_IMPEACH" ) then
			width = 375;
		end
	end

	-- Ensure that the dialog can contain the buttons, regardless of the configuration.
	local button2 = _G[dialog:GetName().."Button2"];
	local button3 = _G[dialog:GetName().."Button3"];
	local button4 = _G[dialog:GetName().."Button4"];
	local buttons = {button1, button2, button3, button4};
	local outerMargin = 60;
	local buttonMinWidth = outerMargin;
	for index, button in ipairs(buttons) do
		if button:IsShown() then
			buttonMinWidth = buttonMinWidth + button:GetWidth();
		end
	end
	width = max(width, buttonMinWidth);

	if ( dialog.insertedFrame ) then
		width = max(width, dialog.insertedFrame:GetWidth());
	end
	if ( width > maxWidthSoFar ) then
		dialog:SetWidth(width);
		dialog.maxWidthSoFar = width;
	end

	if ( info.wideText ) then
		dialog.text:SetWidth(360);
		dialog.SubText:SetWidth(360);
	else
		dialog.text:SetWidth(290);
		dialog.SubText:SetWidth(290);
	end

	-- Slightly reducing width to prevent the text from feeling cramped
	if ( info.normalSizedSubText and not info.wideText ) then
		local currentWidth = dialog.SubText:GetWidth();
		dialog.SubText:SetWidth(currentWidth - 20);
	end

	local height = 32 + text:GetHeight() + 2;
	if ( info.extraButton ) then
		height = height + 40 + extraButton:GetHeight();
	end
	if ( not info.nobuttons ) then
		height = height + 6 + button1:GetHeight();
	end
	if ( info.hasEditBox ) then
		height = height + 8 + editBox:GetHeight();
	elseif ( info.hasMoneyFrame ) then
		height = height + 16;
	elseif ( info.hasMoneyInputFrame ) then
		height = height + 22;
	end
	if ( info.hasDropDown ) then
		height = height + 8 + dialog.DropDownControl:GetHeight();
	end
	if ( dialog.insertedFrame ) then
		height = height + dialog.insertedFrame:GetHeight();
	end
	if ( info.hasItemFrame ) then
		if ( info.compactItemFrame ) then
			height = height + 44;
		else
			height = height + 64;
		end
	end
	if ( dialog.SubText:IsShown() ) then
		height = height + dialog.SubText:GetHeight() + 8;
		-- Adding a bit more vertical space to prevent the text from feeling cramped
		if ( info.normalSizedSubText and info.compactItemFrame) then
			height = height + 18;
		end
	end

	if ( info.verticalButtonLayout ) then
		height = height + 16 + (26 * (dialog.numButtons - 1));
	end

	if ( height > maxHeightSoFar ) then
		dialog:SetHeight(height);
		dialog.maxHeightSoFar = height;
	end
end

function StaticPopup_ShowNotification(systemPrefix, notificationType, message)
	local staticPopupToken = (systemPrefix or "NOTIFICATION_")..(notificationType or "GENERIC");

	if StaticPopupDialogs[staticPopupToken] == nil then
		StaticPopupDialogs[staticPopupToken] = {
			text = "",

			OnShow = function(self, popupMessage)
				self.text:SetText(popupMessage);
			end,

			button1 = OKAY,
			timeout = 0,
			whileDead = 1,
		};
	end

	local text_arg1 = nil;
	local text_arg2 = nil;
	StaticPopup_Show(staticPopupToken, text_arg1, text_arg2, message);
end

function StaticPopup_ShowGenericConfirmation(text, callback, insertedFrame)
	local data = { text = text, callback = callback, };
	StaticPopup_ShowCustomGenericConfirmation(data, insertedFrame);
end

-- customData keys:
-- .text: the text for the confirmation.
-- .text_arg1 : formatted into text if provided
-- .text_arg2 : formatted into text if provided
-- .callback: the callback when the player accepts.
-- .cancelCallback: the callback when the player cancels (will not be called on accept).
-- .acceptText: custom text for the accept button.
-- .cancelText: custom text for the cancel button.
-- .showAlert: whether or not the alert texture should show.
-- .referenceKey: used with StaticPopup_IsCustomGenericConfirmationShown.
function StaticPopup_ShowCustomGenericConfirmation(customData, insertedFrame)
	StaticPopup_Show("GENERIC_CONFIRMATION", nil, nil, customData, insertedFrame);
end

function StaticPopup_IsCustomGenericConfirmationShown(referenceKey)
	for index = 1, STATICPOPUP_NUMDIALOGS do
		local frame = _G["StaticPopup"..index];
		if ( frame:IsShown() and (frame.which == "GENERIC_CONFIRMATION") and (frame.data.referenceKey == referenceKey) ) then
			return true;
		end
	end

	return false;
end

-- customData keys:
-- .text: the text for the confirmation.
-- .text_arg1 : formatted into text if provided
-- .text_arg2 : formatted into text if provided
-- .callback: the callback when the player accepts.
-- .cancelCallback: the callback when the player cancels (will not be called on accept).
-- .acceptText: custom text for the accept button.
-- .cancelText: custom text for the cancel button.
-- .maxLetters: the maximum text length that can be entered.
-- .countInvisibleLetters: used in tandem with maxLetters.
function StaticPopup_ShowCustomGenericInputBox(customData, insertedFrame)
	StaticPopup_Show("GENERIC_INPUT_BOX", nil, nil, customData, insertedFrame);
end

function StaticPopup_ShowGenericDropDown(text, callback, options, hasButtons, defaultOption, insertedFrame)
	local data = { text = text, callback = callback, options = options, hasButtons = hasButtons, defaultOption = defaultOption };
	StaticPopup_Show("GENERIC_DROP_DOWN", nil, nil, data, insertedFrame);
end

local tempButtonLocs = {};	--So we don't make a new table each time.
function StaticPopup_Show(which, text_arg1, text_arg2, data, insertedFrame)
	local info = StaticPopupDialogs[which];
	if ( not info ) then
		return nil;
	end

	if ( info.OnAccept and info.OnButton1 ) then
		error("Dialog "..which.. " cannot have both OnAccept and OnButton1");
	end
	if ( info.OnCancel and info.OnButton2 ) then
		error("Dialog "..which.. " cannot have both OnCancel and OnButton2");
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
		StaticPopup_HideExclusive();
	end

	if ( info.cancels ) then
		for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
			local frame = _G["StaticPopup"..index];
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
			local frame = _G["StaticPopup"..index];
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
			local frame = _G["StaticPopup"..index];
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
		if ( not info.noCancelOnReuse ) then
			local OnCancel = info.OnCancel;
			if ( OnCancel ) then
				OnCancel(dialog, dialog.data, "override");
			end
		end
		dialog:Hide();
	end
	if ( not dialog ) then
		-- Find a free dialog
		local index = 1;
		if ( info.preferredIndex ) then
			index = info.preferredIndex;
		end
		for i = index, STATICPOPUP_NUMDIALOGS do
			local frame = _G["StaticPopup"..i];
			if ( not frame:IsShown() ) then
				dialog = frame;
				break;
			end
		end

		--If dialog not found and there's a preferredIndex then try to find an available frame before the preferredIndex
		if ( not dialog and info.preferredIndex ) then
			for i = 1, info.preferredIndex do
				local frame = _G["StaticPopup"..i];
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

	dialog.CoverFrame:SetShown(info.fullScreenCover);

	dialog.maxHeightSoFar, dialog.maxWidthSoFar = 0, 0;
	local bottomSpace = info.extraButton ~= nil and (dialog.extraButton:GetHeight() + 60) or 16;

	-- Set the text of the dialog
	local text = _G[dialog:GetName().."Text"];
	text:Show();
	if ( (which == "DEATH") or
	     (which == "CAMP") or
		 (which == "QUIT") or
		 (which == "DUEL_OUTOFBOUNDS") or
		 (which == "RECOVER_CORPSE") or
		 (which == "RESURRECT") or
		 (which == "RESURRECT_NO_SICKNESS") or
		 (which == "INSTANCE_BOOT") or
		 (which == "GARRISON_BOOT") or
		 (which == "INSTANCE_LOCK") or
		 (which == "CONFIRM_SUMMON") or
		 (which == "CONFIRM_SUMMON_SCENARIO") or
		 (which == "CONFIRM_SUMMON_STARTING_AREA") or
		 (which == "BFMGR_INVITED_TO_ENTER") or
		 (which == "AREA_SPIRIT_HEAL") or
		 (which == "CONFIRM_REMOVE_COMMUNITY_MEMBER") or
		 (which == "CONFIRM_DESTROY_COMMUNITY_STREAM") or
		 (which == "CONFIRM_RUNEFORGE_LEGENDARY_CRAFT") or
		 (which == "ANIMA_DIVERSION_CONFIRM_CHANNEL")) then
		text:SetText(" ");	-- The text will be filled in later.
		text.text_arg1 = text_arg1;
		text.text_arg2 = text_arg2;
	elseif (which == "PREMADE_GROUP_LEADER_CHANGE_DELIST_WARNING") then
		dialog.SubText:SetText(" ");	-- The text will be filled in later.
		dialog.SubText.text_arg1 = text_arg1;
		dialog.SubText.text_arg2 = text_arg2;
	elseif ( which == "BILLING_NAG" ) then
		text:SetFormattedText(info.text, text_arg1, MINUTES);
	elseif ( which == "SPELL_CONFIRMATION_PROMPT" or which == "SPELL_CONFIRMATION_WARNING" ) then
		text:SetText(text_arg1);
		info.text = text_arg1;
		info.timeout = text_arg2;
	elseif ( which == "CONFIRM_AZERITE_EMPOWERED_RESPEC_EXPENSIVE" ) then
		local separateThousands = true;
		local goldDisplay = GetMoneyString(data.respecCost, separateThousands);
		text:SetFormattedText(info.text, goldDisplay, text_arg1, CONFIRM_AZERITE_EMPOWERED_RESPEC_STRING);
	elseif  ( which == "BUYOUT_AUCTION_EXPENSIVE" ) then
		local separateThousands = true;
		local goldDisplay = GetMoneyString(text_arg1, separateThousands);
		text:SetFormattedText(info.text, goldDisplay, BUYOUT_AUCTION_CONFIRMATION_STRING);
	else
		text:SetFormattedText(info.text, text_arg1, text_arg2);
		text.text_arg1 = text_arg1;
		text.text_arg2 = text_arg2;
	end

	-- Show or hide the close button
	if ( info.closeButton ) then
		local closeButton = dialog.CloseButton;
		if ( info.closeButtonIsHide ) then
			closeButton:SetNormalAtlas("RedButton-Exit");
			closeButton:SetPushedAtlas("RedButton-exit-pressed");
		else
			closeButton:SetNormalAtlas("RedButton-MiniCondense");
			closeButton:SetPushedAtlas("RedButton-MiniCondense-pressed");
		end
		closeButton:Show();
	else
		dialog.CloseButton:Hide();
	end

	-- Set the editbox of the dialog
	local editBox = _G[dialog:GetName().."EditBox"];
	if ( info.hasEditBox ) then
		editBox:Show();

		editBox.Instructions:SetText(info.editBoxInstructions or "");

		if ( info.maxLetters ) then
			editBox:SetMaxLetters(info.maxLetters);
			editBox:SetCountInvisibleLetters(info.countInvisibleLetters);
		end
		if ( info.maxBytes ) then
			editBox:SetMaxBytes(info.maxBytes);
		end
		editBox:SetText("");
		if ( info.editBoxWidth ) then
			editBox:SetWidth(info.editBoxWidth);
		else
			editBox:SetWidth(130);
		end

		editBox:ClearAllPoints();
		editBox:SetPoint("BOTTOM", 0, 29 + bottomSpace);
	else
		editBox:Hide();
	end

	if ( info.hasDropDown ) then
		dialog.DropDownControl:Show();
		dialog.DropDownControl:SetOptions(info.dropDownOptions, info.dropDownDefaultOption);

		local function StaticPopup_OnDropDownOptionSelected(value, isUserInput)
			info.OnDropDownOptionSelected(dialog, data, value, isUserInput);
		end

		dialog.DropDownControl:SetOptionSelectedCallback(nil);
		dialog.DropDownControl:SetSelectedValue(nil);

		if info.OnDropDownOptionSelected then
			dialog.DropDownControl:SetOptionSelectedCallback(StaticPopup_OnDropDownOptionSelected);
		end
	else
		dialog.DropDownControl:Hide();
	end

	-- Show or hide money frame
	if ( info.hasMoneyFrame ) then
		_G[dialog:GetName().."MoneyFrame"]:Show();
		_G[dialog:GetName().."MoneyInputFrame"]:Hide();
	elseif ( info.hasMoneyInputFrame ) then
		local moneyInputFrame = _G[dialog:GetName().."MoneyInputFrame"];
		moneyInputFrame:Show();
		_G[dialog:GetName().."MoneyFrame"]:Hide();
		-- Set OnEnterPress for money input frames
		if ( info.EditBoxOnEnterPressed ) then
			moneyInputFrame.gold:SetScript("OnEnterPressed", StaticPopup_EditBoxOnEnterPressed);
			moneyInputFrame.silver:SetScript("OnEnterPressed", StaticPopup_EditBoxOnEnterPressed);
			moneyInputFrame.copper:SetScript("OnEnterPressed", StaticPopup_EditBoxOnEnterPressed);
		else
			moneyInputFrame.gold:SetScript("OnEnterPressed", nil);
			moneyInputFrame.silver:SetScript("OnEnterPressed", nil);
			moneyInputFrame.copper:SetScript("OnEnterPressed", nil);
		end
	else
		_G[dialog:GetName().."MoneyFrame"]:Hide();
		_G[dialog:GetName().."MoneyInputFrame"]:Hide();
	end

	dialog.ItemFrame:ClearAllPoints();
	dialog.SubText:ClearAllPoints();
	local itemFrameXOffset = -60;
	local itemFrameYOffset = -6;
	local subTextSpacingYOffset = info.normalSizedSubText and -18 or -6;
	if ( info.itemFrameAboveSubtext and info.hasItemFrame and info.subText ) then
		dialog.ItemFrame:SetPoint("TOP", dialog.text, "BOTTOM", itemFrameXOffset, itemFrameYOffset);
		-- Other components (like the moneyFrame) can be anchored under subtext so we anchor to the item frame instead of the bottom of the window.
		dialog.SubText:SetPoint("TOP", dialog.ItemFrame, "BOTTOM", -itemFrameXOffset, subTextSpacingYOffset);
	else
		dialog.ItemFrame:SetPoint("BOTTOM", itemFrameXOffset, bottomSpace + (info.compactItemFrame and 29 or 39));
		dialog.SubText:SetPoint("TOP", dialog.text, "BOTTOM", 0, subTextSpacingYOffset);
	end

	dialog.ItemFrame.itemID = nil;
	-- Show or hide item button
	if ( info.hasItemFrame ) then
		dialog.ItemFrame:Show();
		if ( data and type(data) == "table" ) then
			dialog.ItemFrame:SetCustomOnEnter(data.itemFrameOnEnter);

			local itemFrameCallback = data.itemFrameCallback;
			if ( itemFrameCallback ) then
				itemFrameCallback(dialog.ItemFrame);
			else
				if ( data.useLinkForItemInfo ) then
					dialog.ItemFrame:RetrieveInfo(data);
				end
				dialog.ItemFrame:DisplayInfo(data.link, data.name, data.color, data.texture, data.count, data.tooltip);
			end
		end
	else
		dialog.ItemFrame:Hide();
	end

	-- Set the miscellaneous variables for the dialog
	dialog.which = which;
	dialog.timeleft = info.timeout or 0;
	dialog.hideOnEscape = info.hideOnEscape;
	dialog.exclusive = info.exclusive;
	dialog.enterClicksFirstButton = info.enterClicksFirstButton;
	dialog.insertedFrame = insertedFrame;
	if ( info.subText ) then
		dialog.SubText:SetFontObject(info.normalSizedSubText and "GameFontNormal" or "GameFontNormalSmall");
		dialog.SubText:SetText(info.subText);
		dialog.SubText:Show();
	else
		dialog.SubText:Hide();
	end

	if ( insertedFrame ) then
		insertedFrame:SetParent(dialog);
		insertedFrame:ClearAllPoints();
		if ( dialog.SubText:IsShown() ) then
			insertedFrame:SetPoint("TOP", dialog.SubText, "BOTTOM");
		else
			insertedFrame:SetPoint("TOP", text, "BOTTOM");
		end
		insertedFrame:Show();
		_G[dialog:GetName().."MoneyFrame"]:SetPoint("TOP", insertedFrame, "BOTTOM");
		_G[dialog:GetName().."MoneyInputFrame"]:SetPoint("TOP", insertedFrame, "BOTTOM");
	elseif ( dialog.SubText:IsShown() ) then
		_G[dialog:GetName().."MoneyFrame"]:SetPoint("TOP", dialog.SubText, "BOTTOM", 0, -5);
		_G[dialog:GetName().."MoneyInputFrame"]:SetPoint("TOP", dialog.SubText, "BOTTOM", 0, -5);
	else
		_G[dialog:GetName().."MoneyFrame"]:SetPoint("TOP", dialog.text, "BOTTOM", 0, -5);
		_G[dialog:GetName().."MoneyInputFrame"]:SetPoint("TOP", dialog.text, "BOTTOM", 0, -5);
	end
	-- Clear out data
	dialog.data = data;

	-- Set the buttons of the dialog
	local button1 = _G[dialog:GetName().."Button1"];
	local button2 = _G[dialog:GetName().."Button2"];
	local button3 = _G[dialog:GetName().."Button3"];
	local button4 = _G[dialog:GetName().."Button4"];

	local buttons = {button1, button2, button3, button4};
	for index, button in ipairs_reverse(buttons) do
		button:SetText(info["button"..index]);
		button:Hide();
		button:SetWidth(1);
		button:ClearAllPoints();
		button.PulseAnim:Stop();

		if not (info["button"..index] and ( not info["DisplayButton"..index] or info["DisplayButton"..index](dialog))) then
			table.remove(buttons, index);
		end
	end

	dialog.numButtons = #buttons;

	local buttonTextMargin = 20;
	local minButtonWidth = 120;
	local maxButtonWidth = minButtonWidth;
	for index, button in ipairs(buttons) do
		local buttonWidth = button:GetTextWidth() + buttonTextMargin;
		maxButtonWidth = math.max(maxButtonWidth, buttonWidth);
	end

	local function InitButton(button, index)
		if info[string.format("button%dPulse", index)] then
			button.PulseAnim:Play();
		end
		button:Enable();
		button:Show();
	end

	-- Button layout logic depends on the width of the dialog, so this needs to be resized to account
	-- for any configuration options first. It will be resized again after the buttons have been arranged.
	StaticPopup_Resize(dialog, which);

	local buttonPadding = 10;
	local minButtonWidth = 120;
	local totalButtonPadding = (#buttons - 1) * buttonPadding;
	local totalButtonWidth = #buttons * maxButtonWidth;
	local totalWidth;
	local uncondensedTotalWidth = totalButtonWidth + totalButtonPadding;
	if uncondensedTotalWidth < dialog:GetWidth() then
		for index, button in ipairs(buttons) do
			button:SetWidth(maxButtonWidth);
			InitButton(button, index);
		end
		totalWidth = uncondensedTotalWidth;
	else
		totalWidth = totalButtonPadding;
		for index, button in ipairs(buttons) do
			local buttonWidth = math.max(minButtonWidth, button:GetTextWidth()) + buttonTextMargin;
			button:SetWidth(buttonWidth);
			totalWidth = totalWidth + buttonWidth;
			InitButton(button, index);
		end
	end

	if #buttons > 0 then
		if info.verticalButtonLayout then
			buttons[1]:SetPoint("TOP", dialog.text, "BOTTOM", 0, -16);
			for index = 2, #buttons do
				buttons[index]:SetPoint("TOP", buttons[index-1], "BOTTOM", 0, -6);
			end
		else
			local offset = totalWidth / 2;
			buttons[1]:SetPoint("BOTTOMLEFT", dialog, "BOTTOM", -offset, bottomSpace);
			for index = 2, #buttons do
				buttons[index]:SetPoint("BOTTOMLEFT", buttons[index-1], "BOTTOMRIGHT", buttonPadding, 0);
			end
		end
	end

	if info.extraButton then
		local extraButton = dialog.extraButton;
		extraButton:Show();
		extraButton:SetPoint("BOTTOM", dialog, "BOTTOM", 0, 22);
		extraButton:SetText(info.extraButton);
		--widen if too small, but reset to 128 otherwise
		local width = 128
		local padding = 40;
		local textWidth = extraButton:GetTextWidth() + padding;
		width = math.max(width, textWidth);
		extraButton:SetWidth(width);

		dialog.Separator:Show();
	else
		dialog.extraButton:Hide();
		dialog.Separator:Hide();
	end

	-- Show or hide the alert icon
	local alertIcon = _G[dialog:GetName().."AlertIcon"];
	local dataShowsAlert = (which == "GENERIC_CONFIRMATION") and data.showAlert;
	if ( dataShowsAlert or info.showAlert ) then
		alertIcon:SetTexture(STATICPOPUP_TEXTURE_ALERT);
		if ( button3:IsShown() )then
			alertIcon:SetPoint("LEFT", 24, 10);
		else
			alertIcon:SetPoint("LEFT", 24, 0);
		end
		alertIcon:Show();
	elseif ( info.showAlertGear ) then
		alertIcon:SetTexture(STATICPOPUP_TEXTURE_ALERTGEAR);
		if ( button3:IsShown() )then
			alertIcon:SetPoint("LEFT", 24, 0);
		else
			alertIcon:SetPoint("LEFT", 24, 0);
		end
		alertIcon:Show();
	elseif ( info.customAlertIcon ) then
		alertIcon:SetTexture(info.customAlertIcon);
		if ( button3:IsShown() ) then
			alertIcon:SetPoint("LEFT", 24, 0);
		else
			alertIcon:SetPoint("LEFT", 24, 0);
		end
		alertIcon:Show();
	else
		alertIcon:SetTexture();
		alertIcon:Hide();
	end

	dialog.Spinner:Hide();

	if ( info.StartDelay ) then
		dialog.startDelay = info.StartDelay(dialog);
		if (not dialog.startDelay or dialog.startDelay <= 0) then
			button1:Enable();
		else
			button1:Disable();
		end
	elseif info.acceptDelay then
		dialog.acceptDelay = info.acceptDelay;
		button1:Disable();
	else
		dialog.startDelay = nil;
		dialog.acceptDelay = nil;
		button1:Enable();
	end

	editBox:SetSecureText(info.editBoxSecureText);
	editBox.hasAutoComplete = info.autoCompleteSource ~= nil;
	if ( editBox.hasAutoComplete ) then
		AutoCompleteEditBox_SetAutoCompleteSource(editBox, info.autoCompleteSource, unpack(info.autoCompleteArgs));
	else
		AutoCompleteEditBox_SetAutoCompleteSource(editBox, nil);
	end

	dialog.DarkOverlay:Hide();

	dialog:SetWindow(nil);

	-- Finally size and show the dialog
	StaticPopup_SetUpPosition(dialog);
	dialog:Show();

	StaticPopup_Resize(dialog, which);

	if ( info.sound ) then
		PlaySound(info.sound);
	end

	return dialog;
end

function StaticPopup_Hide(which, data)
	for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
		local dialog = _G["StaticPopup"..index];
		if ( dialog:IsShown() and (dialog.which == which) and (not data or (data == dialog.data)) ) then
			dialog:Hide();
		end
	end
end

local SpellConfirmationFormatter = CreateFromMixins(SecondsFormatterMixin);
SpellConfirmationFormatter:Init(0, SecondsFormatter.Abbreviation.None, true, true);

function StaticPopup_OnUpdate(dialog, elapsed)
	if ( dialog.timeleft > 0 ) then
		local which = dialog.which;
		local timeleft = dialog.timeleft - elapsed;
		if ( timeleft <= 0 ) then
			if ( not StaticPopupDialogs[which].timeoutInformationalOnly ) then
				dialog.timeleft = 0;
				local OnCancel = StaticPopupDialogs[which].OnCancel;
				if ( OnCancel ) then
					OnCancel(dialog, dialog.data, "timeout");
				end
				dialog:Hide();
			end
			return;
		end
		dialog.timeleft = timeleft;

		if ( (which == "DEATH") or
		     (which == "CAMP")  or
			 (which == "QUIT") or
			 (which == "DUEL_OUTOFBOUNDS") or
			 (which == "INSTANCE_BOOT") or
			 (which == "GARRISON_BOOT") or
			 (which == "CONFIRM_SUMMON") or
			 (which == "CONFIRM_SUMMON_SCENARIO") or
			 (which == "CONFIRM_SUMMON_STARTING_AREA") or
			 (which == "BFMGR_INVITED_TO_ENTER") or
			 (which == "AREA_SPIRIT_HEAL") or
			 (which == "SPELL_CONFIRMATION_PROMPT") or
			 (which == "PREMADE_GROUP_LEADER_CHANGE_DELIST_WARNING") or
			 (which == "ANIMA_DIVERSION_CONFIRM_CHANNEL")) then
			local text = _G[dialog:GetName().."Text"];
			timeleft = ceil(timeleft);
			if ( (which == "INSTANCE_BOOT") or (which == "GARRISON_BOOT") ) then
				if ( timeleft < 60 ) then
					text:SetFormattedText(StaticPopupDialogs[which].text, timeleft, SECONDS);
				else
					text:SetFormattedText(StaticPopupDialogs[which].text, ceil(timeleft / 60), MINUTES);
				end
			elseif ( which == "CONFIRM_SUMMON" or which == "CONFIRM_SUMMON_SCENARIO" or which == "CONFIRM_SUMMON_STARTING_AREA" ) then
				if ( timeleft < 60 ) then
					text:SetFormattedText(StaticPopupDialogs[which].text, C_SummonInfo.GetSummonConfirmSummoner() or "", C_SummonInfo.GetSummonConfirmAreaName(), timeleft, SECONDS);
				else
					text:SetFormattedText(StaticPopupDialogs[which].text, C_SummonInfo.GetSummonConfirmSummoner() or "", C_SummonInfo.GetSummonConfirmAreaName(), ceil(timeleft / 60), MINUTES);
				end
			elseif ( which == "BFMGR_INVITED_TO_ENTER") then
				if ( timeleft < 60 ) then
					text:SetFormattedText(StaticPopupDialogs[which].text, text.text_arg1, timeleft, SECONDS);
				else
					text:SetFormattedText(StaticPopupDialogs[which].text, text.text_arg1, ceil(timeleft / 60), MINUTES);
				end
			elseif ( which == "SPELL_CONFIRMATION_PROMPT") then
				local time = SpellConfirmationFormatter:Format(timeleft);
				text:SetText(StaticPopupDialogs[which].text .. " " ..TIME_REMAINING .. " " .. time);
			elseif (which == "PREMADE_GROUP_LEADER_CHANGE_DELIST_WARNING") then
				dialog.SubText:SetText(StaticPopupDialogs[which].subText:format(SecondsToTime(timeleft)));
			elseif (which == "ANIMA_DIVERSION_CONFIRM_CHANNEL") then
				local formatterOutput = WorldQuestsSecondsFormatter:Format(timeleft);
				local formattedTime = BONUS_OBJECTIVE_TIME_LEFT:format(formatterOutput);
				text:SetFormattedText(StaticPopupDialogs[which].text, text.text_arg1, formattedTime);
			else
				if ( timeleft < 60 ) then
					text:SetFormattedText(StaticPopupDialogs[which].text, timeleft, SECONDS);
				else
					text:SetFormattedText(StaticPopupDialogs[which].text, ceil(timeleft / 60), MINUTES);
				end
			end
			StaticPopup_Resize(dialog, which);
		end
	end
	if ( dialog.startDelay ) then
		local which = dialog.which;
		local timeleft = dialog.startDelay - elapsed;
		if ( timeleft <= 0 ) then
			dialog.startDelay = nil;
			local text = _G[dialog:GetName().."Text"];
			text:SetFormattedText(StaticPopupDialogs[which].text, text.text_arg1, text.text_arg2);
			local button1 = _G[dialog:GetName().."Button1"];
			button1:Enable();
			StaticPopup_Resize(dialog, which);
			return;
		end
		dialog.startDelay = timeleft;

		if ( which == "RECOVER_CORPSE" or (which == "RESURRECT") or (which == "RESURRECT_NO_SICKNESS") ) then
			local text = _G[dialog:GetName().."Text"];
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
			StaticPopup_Resize(dialog, which);
		end
	end

	if dialog.acceptDelay then
		dialog.acceptDelay = dialog.acceptDelay - elapsed;
		if dialog.acceptDelay <= 0 then
			dialog.button1:Enable();
			local info = StaticPopupDialogs[dialog.which];
			dialog.button1:SetText(info.button1);
			dialog.acceptDelay = nil;

			if info.OnAcceptDelayExpired ~= nil then
				info.OnAcceptDelayExpired(dialog, dialog.data);
			end
		else
			dialog.button1:Disable();
			dialog.button1:SetText(math.ceil(dialog.acceptDelay));
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
	if ( not self.hasAutoComplete or not AutoCompleteEditBox_OnEnterPressed(self) ) then
		EditBoxOnEnterPressed = StaticPopupDialogs[which].EditBoxOnEnterPressed;
		if ( EditBoxOnEnterPressed ) then
			EditBoxOnEnterPressed(self, dialog.data);
		end
	end
end

function StaticPopup_EditBoxOnEscapePressed(self)
	local EditBoxOnEscapePressed = StaticPopupDialogs[self:GetParent().which].EditBoxOnEscapePressed;
	if ( EditBoxOnEscapePressed ) then
		EditBoxOnEscapePressed(self, self:GetParent().data);
	end
end

function StaticPopup_EditBoxOnTextChanged(self, userInput)
	if ( not self.hasAutoComplete or not AutoCompleteEditBox_OnTextChanged(self, userInput) ) then
		local EditBoxOnTextChanged = StaticPopupDialogs[self:GetParent().which].EditBoxOnTextChanged;
		if ( EditBoxOnTextChanged ) then
			EditBoxOnTextChanged(self, self:GetParent().data);
		end
	end
	self.Instructions:SetShown(self:GetText() == "");
end

function StaticPopup_OnLoad(self)
	local name = self:GetName();
	self.button1 = _G[name .. "Button1"];
	self.button2 = _G[name .. "Button2"];
	self.button3 = _G[name .. "Button3"];
	self.text = _G[name .. "Text"];
	self.icon = _G[name .. "AlertIcon"];
	self.moneyInputFrame = _G[name .. "MoneyInputFrame"];
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end

function StaticPopup_OnShow(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);

	local dialog = StaticPopupDialogs[self.which];
	local OnShow = dialog.OnShow;

	if ( OnShow ) then
		OnShow(self, self.data);
	end
	if ( dialog.hasMoneyInputFrame ) then
		_G[self:GetName().."MoneyInputFrameGold"]:SetFocus();
	end
	if ( dialog.enterClicksFirstButton ) then
		self:SetScript("OnKeyDown", StaticPopup_OnKeyDown);
	end
end

function StaticPopup_OnHide(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);

	StaticPopup_CollapseTable();

	local dialog = StaticPopupDialogs[self.which];
	local OnHide = dialog.OnHide;
	if ( OnHide ) then
		OnHide(self, self.data);
	end
	self.extraFrame:Hide();
	if ( dialog.enterClicksFirstButton ) then
		self:SetScript("OnKeyDown", nil);
	end
	if ( self.insertedFrame ) then
		self.insertedFrame:Hide();
		self.insertedFrame:SetParent(nil);
		local text = _G[self:GetName().."Text"];
		_G[self:GetName().."MoneyFrame"]:SetPoint("TOP", text, "BOTTOM", 0, -5);
		_G[self:GetName().."MoneyInputFrame"]:SetPoint("TOP", text, "BOTTOM", 0, -5);
	end
end

function StaticPopup_OnCloseButtonClicked(closeButton, button)
	closeButton:GetParent():Hide();
end

local function StaticPopup_CallInfoHandler(dialog, handlerName, ...)
	if ( dialog:IsShown() ) then
		local which = dialog.which;
		local info = StaticPopupDialogs[which];
		if ( info ) then
			local handler = info[handlerName];
			if ( handler ) then
				handler(dialog, ...);
			end
		end
	end
end

function StaticPopup_OnHyperlinkClick(self, ...)
	StaticPopup_CallInfoHandler(self, "OnHyperlinkClick", ...);
end

function StaticPopup_OnHyperlinkEnter(self, ...)
	StaticPopup_CallInfoHandler(self, "OnHyperlinkEnter", ...);
end

function StaticPopup_OnHyperlinkLeave(self, ...)
	StaticPopup_CallInfoHandler(self, "OnHyperlinkLeave", ...);
end

function StaticPopup_OnClick(dialog, index)
	if ( not dialog:IsShown() ) then
		return;
	end
	local which = dialog.which;
	local info = StaticPopupDialogs[which];
	if ( not info ) then
		return nil;
	end

	if info.selectCallbackByIndex then
		local func;
		if ( index == 1 ) then
			func = info.OnAccept or info.OnButton1;
		elseif ( index == 2 ) then
			func = info.OnCancel or info.OnButton2;
		elseif ( index == 3 ) then
			func = info.OnButton3;
		elseif ( index == 4 ) then
			func = info.OnButton4;
		elseif ( index == 5 ) then
			func = info.OnExtraButton;
		end

		if ( func ) then
			local keepOpen = func(dialog, dialog.data, "clicked");
			if ( not keepOpen and which == dialog.which ) then
				dialog:Hide();
			end
		end
	else
		-- Keeping this temporarily for backward compatibility
		local hide = true;
		if ( index == 1 ) then
			local OnAccept = info.OnAccept or info.OnButton1;
			if ( OnAccept ) then
				hide = not OnAccept(dialog, dialog.data, dialog.data2);
			end
		elseif ( index == 3 ) then
			local OnAlt = info.OnAlt;
			if ( OnAlt ) then
				OnAlt(dialog, dialog.data, "clicked");
			end
		elseif ( index == 5 ) then
			local OnExtraButton = info.OnExtraButton;
			if ( OnExtraButton ) then
				OnExtraButton(dialog, dialog.data, dialog.data2);
			end
		else
			local OnCancel = info.OnCancel;
			if ( OnCancel ) then
				hide = not OnCancel(dialog, dialog.data, "clicked");
			end
		end

		if ( hide and (which == dialog.which) and ( index ~= 3 or not info.noCloseOnAlt) ) then
			-- can dialog.which change inside one of the On* functions???
			dialog:Hide();
		end
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
				button = _G[frameName.."Button"..i];
				if ( button ) then
					if ( button:IsShown() ) then
						if ( button:IsEnabled() ) then
							StaticPopup_OnClick(self, i);
						end
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

function StaticPopup_EscapePressed()
	local closed = nil;
	for _, frame in pairs(StaticPopup_DisplayedFrames) do
		if( frame:IsShown() and frame.hideOnEscape ) then
			local standardDialog = StaticPopupDialogs[frame.which];
			if ( standardDialog ) then
				local OnCancel = standardDialog.OnCancel;
				local noCancelOnEscape = standardDialog.noCancelOnEscape;
				if ( OnCancel and not noCancelOnEscape) then
					OnCancel(frame, frame.data, "clicked");
				end
				frame:Hide();
			else
				StaticPopupSpecial_Hide(frame);
			end
			closed = 1;
		end
	end
	return closed;
end

function StaticPopup_SetUpPosition(dialog)
	if ( not tContains(StaticPopup_DisplayedFrames, dialog) ) then
		StaticPopup_SetUpAnchor(dialog, #StaticPopup_DisplayedFrames + 1);
		tinsert(StaticPopup_DisplayedFrames, dialog);
	end
end

function StaticPopup_SetUpAnchor(dialog, idx)
	dialog:SetParent(FullscreenFrame);
	dialog:SetFrameStrata("DIALOG");
	local lastFrame = StaticPopup_DisplayedFrames[idx - 1];
	if ( lastFrame ) then
		dialog:SetPoint("TOP", lastFrame, "BOTTOM", 0, 0);
	else
		dialog:SetPoint("TOP", FullscreenFrame, "TOP", 0, dialog.topOffset or -135);
	end
end

function StaticPopup_CollapseTable()
	local displayedFrames = StaticPopup_DisplayedFrames;
	local index = #displayedFrames;
	while ( ( index >= 1 ) and ( not displayedFrames[index]:IsShown() ) ) do
		tremove(displayedFrames, index);
		index = index - 1;
	end
end

function StaticPopupSpecial_Show(frame)
	if ( frame.exclusive ) then
		StaticPopup_HideExclusive();
	end
	StaticPopup_SetUpPosition(frame);
	frame:Show();
end

function StaticPopupSpecial_Hide(frame)
	frame:Hide();
	StaticPopup_CollapseTable();
end

function StaticPopupSpecial_Toggle(frame)
	if frame:IsShown() then
		StaticPopupSpecial_Hide(frame);
	else
		StaticPopupSpecial_Show(frame);
	end
end

function StaticPopup_ReparentDialogs()
	for _, frame in pairs(StaticPopup_DisplayedFrames) do
		frame:SetParent(FullscreenFrame);
		frame:SetFrameStrata("DIALOG");
	end
end

function StaticPopup_SetFullScreenFrame(frame)
	if frame then
		FullscreenFrame = frame;
		StaticPopup_ReparentDialogs();
	end
end

function StaticPopup_ClearFullScreenFrame()
	FullscreenFrame = UIParent;
	StaticPopup_ReparentDialogs();
end

--Note that things will look sub-fantastic if toActivate is bigger than toReplace
function StaticPopupSpecial_Replace(toActivate, toReplace)
	local idx = nil;
	for i=1, #StaticPopup_DisplayedFrames do
		if ( StaticPopup_DisplayedFrames[i] == toReplace ) then
			idx = i;
			break;
		end
	end

	if ( idx ) then
		StaticPopup_DisplayedFrames[idx] = toActivate;
		StaticPopup_SetUpAnchor(toActivate, idx);

		toReplace:Hide();
		toActivate:Show();
		return true;
	end

	return false;
end

--Used to figure out if we can resize a frame
function StaticPopup_IsLastDisplayedFrame(frame)
	for i=#StaticPopup_DisplayedFrames, 1, -1 do
		local popup = StaticPopup_DisplayedFrames[i];
		if ( popup:IsShown() ) then
			return frame == popup
		end
	end
	return false;
end

function StaticPopup_OnEvent(self)
	self.maxHeightSoFar = 0;
	StaticPopup_Resize(self, self.which);
end

function StaticPopup_HideExclusive()
	for _, frame in pairs(StaticPopup_DisplayedFrames) do
		if ( frame:IsShown() and frame.exclusive ) then
			local standardDialog = StaticPopupDialogs[frame.which];
			if ( standardDialog ) then
				frame:Hide();
				local OnCancel = standardDialog.OnCancel;
				if ( OnCancel ) then
					OnCancel(frame, frame.data, "override");
				end
			else
				StaticPopupSpecial_Hide(frame);
			end
			break;
		end
	end
end

-- beforeSpinnerWaitTime is the time we wait before showing the spinner after hitting accept
function StaticPopup_OnAcceptWithSpinner(onAcceptCallback, onEventCallback, events, beforeSpinnerWaitTime, self)
	onAcceptCallback(self);

	self.button1:Disable();
	self.button2:Disable();

	local spinnerTimer = C_Timer.NewTimer(beforeSpinnerWaitTime, function()
		self.DarkOverlay:Show();
		self.Spinner:Show();
	end);

	FrameUtil.RegisterFrameForEvents(self, events);

	local oldOnEvent = self:GetScript("OnEvent");
	local oldOnHide = self:GetScript("OnHide");

	local function OnComplete()
		spinnerTimer:Cancel();
		self.Spinner:Hide();
		self:SetScript("OnEvent", oldOnEvent);
		self:SetScript("OnHide", oldOnHide);
		FrameUtil.UnregisterFrameForEvents(self, events);
		self:Hide();
	end

	self:SetScript("OnEvent", function(self, event, ...)
		if oldOnEvent then
			oldOnEvent(self, event, ...);
		end

		for i, registeredEvent in ipairs(events) do
			if event == registeredEvent then
				if onEventCallback(self, event, ...) then
					OnComplete();
				end
			end
		end
	end);
	self:SetScript("OnHide", function()
		if oldOnHide then
			oldOnHide(self);
		end
		OnComplete();
	end);

	return true;
end



StaticPopupItemFrameMixin = {};

function StaticPopupItemFrameMixin:OnLoad()
	self:GetParent().itemFrame = self;
	self:RegisterEvent("GET_ITEM_INFO_RECEIVED");
end

function StaticPopupItemFrameMixin:OnEvent(event, ...)
	if ( event == "GET_ITEM_INFO_RECEIVED" ) then
		local itemID = ...;
		if ( itemID == self.itemID ) then
			local data = self:GetParent().data;
			self:RetrieveInfo(data);
			self:DisplayInfo(data.link, data.name, data.color, data.texture, data.count);
		end
	end
end

function StaticPopupItemFrameMixin:OnEnter()
	if ( self.customOnEnter ) then
		self.customOnEnter(self);
	elseif ( self.link ) then
		local tooltip = self.tooltip or GameTooltip;
		tooltip:SetOwner(self, "ANCHOR_RIGHT");
		tooltip:SetHyperlink(self.link);
	end
end

function StaticPopupItemFrameMixin:OnLeave()
	local tooltip = self.tooltip or GameTooltip;
	tooltip:Hide();
end

function StaticPopupItemFrameMixin:SetCustomOnEnter(customOnEnter)
	self.customOnEnter = customOnEnter;
end

function StaticPopupItemFrameMixin:RetrieveInfo(data)
	local itemName, _, itemQuality, _, _, _, _, _, _, texture = C_Item.GetItemInfo(data.link);
	if ( itemName ) then
		data.name = itemName;
		local r, g, b = C_Item.GetItemQualityColor(itemQuality);
		data.color = {r, g, b, 1};
		data.texture = texture;
		self.itemID = nil;
	else
		local itemID, _, _, _, texture = C_Item.GetItemInfoInstant(data.link);
		data.name = RETRIEVING_ITEM_INFO;
		data.color = {RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, 1};
		data.texture = texture;
		self.itemID = itemID;
	end
end

function StaticPopupItemFrameMixin:DisplayInfo(link, name, color, texture, count, tooltip)
	self.link = link;
	self.tooltip = tooltip;
	_G[self:GetName().."IconTexture"]:SetTexture(texture);
	local nameText = _G[self:GetName().."Text"];
	nameText:SetTextColor(unpack(color or {1, 1, 1, 1}));
	nameText:SetText(name);

	if link then
		local quality = select(3, C_Item.GetItemInfo(link));
		SetItemButtonQuality(self, quality, link);
	end

	if ( count and count > 1 ) then
		_G[self:GetName().."Count"]:SetText(count);
		_G[self:GetName().."Count"]:Show();
	else
		_G[self:GetName().."Count"]:Hide();
	end
end
