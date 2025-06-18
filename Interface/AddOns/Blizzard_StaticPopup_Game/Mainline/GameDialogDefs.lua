StaticPopupDialogs["CONFIRM_OVERWRITE_EQUIPMENT_SET"].OnAccept = function(dialog, data)
	 C_EquipmentSet.SaveEquipmentSet(data, dialog.selectedIcon); 
	 GearManagerPopupFrame:Hide();
end;

StaticPopupDialogs["CONFIRM_GLYPH_PLACEMENT"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data) AttachGlyphToSpell(data.id); end,
	OnCancel = function(dialog, data)
	end,
	OnShow = function(dialog, data)
		dialog:SetFormattedText(CONFIRM_GLYPH_PLACEMENT_NO_COST, data.name, data.currentName);
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}
StaticPopupDialogs["CONFIRM_GLYPH_REMOVAL"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data) AttachGlyphToSpell(data.id); end,
	OnCancel = function(dialog, data)
	end,
	OnShow = function(dialog, data)
		dialog:SetFormattedText(CONFIRM_GLYPH_REMOVAL, data.name);
	end,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
}

StaticPopupDialogs["CONFIRM_PURCHASE_ITEM_DELAYED"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		BuyMerchantItem(MerchantFrame.itemIndex, MerchantFrame.count);
	end,
	OnShow = function(dialog, data)
		dialog:SetText(data.confirmationText);
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
	OnAccept = function(dialog, data)
		ItemUpgradeFrame:OnConfirm();
	end,
	OnCancel = function(dialog, data)
		ItemUpgradeFrame:UpdateUpgradeItemInfo();
	end,
	OnShow = function(dialog, data)
		if data.isItemBound then
			dialog:SetText(CONFIRM_UPGRADE_ITEM:format(data.costString));
		else
			dialog:SetText(CONFIRM_UPGRADE_ITEM_BIND:format(data.costString));
		end
	end,
	OnHide = function(dialog, data)
	end,
	timeout = 0,
	hideOnEscape = 1,
	hasItemFrame = 1,
	compactItemFrame = true,
}

StaticPopupDialogs["CONFIRM_LOOT_DISTRIBUTION"].OnAccept = function(dialog, data)
	if ( data == "LootWindow" ) then
		MasterLooterFrame_GiveMasterLoot();
	end
end;

StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"] = {
	text = CONFIRM_BATTLEFIELD_ENTRY,
	button1 = ENTER_LFG,
	button2 = LEAVE_QUEUE,
	OnShow = function(dialog, data)
		local status, mapName, teamSize, registeredMatch = GetBattlefieldStatus(data);
		if ( teamSize == 0 ) then
			dialog:GetButton2():Enable();
		else
			dialog:GetButton2():Disable();
		end
	end,
	OnAccept = function(dialog, data)
		if ( not AcceptBattlefieldPort(data, true) ) then
			return 1;
		end
		if( StaticPopup_Visible( "DEATH" ) ) then
			StaticPopup_Hide( "DEATH" );
		end
	end,
	OnCancel = function(dialog, data)
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
	closeButton = true,
	closeButtonIsHide = true,
};

StaticPopupDialogs["CONFIRM_REPORT_BATTLEPET_NAME"] = {
	text = REPORT_BATTLEPET_NAME_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnShow = function(dialog, data)
		dialog.reportToken = C_ReportSystem.InitiateReportPlayer(PLAYER_REPORT_TYPE_BAD_BATTLEPET_NAME);
	end,
	OnAccept = function(dialog, data)
		C_ReportSystem.SendReportPlayer(dialog.reportToken);
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
	OnShow = function(dialog, data)
		dialog.reportToken = C_ReportSystem.InitiateReportPlayer(PLAYER_REPORT_TYPE_BAD_PET_NAME);
	end,
	OnAccept = function(dialog, data)
		C_ReportSystem.SendReportPlayer(dialog.reportToken);
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["RESET_CHAT"] = {
	text = RESET_CHAT_WINDOW,
	button1 = ACCEPT,
	button2 = CANCEL,
	whileDead = 1,
	OnAccept = function(dialog, data)
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
	OnAccept = function(dialog, data)
		C_PetInfo.PetRename(data.newName, data.petNumber);
	end,
	OnUpdate = function(dialog, elapsed)
		if ( not UnitExists("pet") and not data.petNumber ) then
			dialog:Hide();
		end
	end,
	timeout = 0,
	hideOnEscape = 1,
};

StaticPopupDialogs["DEATH"] = {
	text = DEATH_RELEASE_TIMER,
	GetExpirationText = GameDialogDefsUtil.GetDefaultExpirationText,
	button1 = DEATH_RELEASE,
	button2 = USE_SOULSTONE,	-- rez option 1
	button3 = USE_SOULSTONE,	-- rez option 2
	button4 = DEATH_RECAP,
	selectCallbackByIndex = true,
	cancelIfNotAllowedWhileDead = true,
	OnShow = function(dialog, data)
		dialog.timeleft = GetReleaseTimeRemaining();

		if ( IsActiveBattlefieldArena() and not C_PvP.IsInBrawl() ) then
			dialog:SetText(DEATH_RELEASE_SPECTATOR);
		elseif ( dialog.timeleft == -1 ) then
			dialog:SetText(DEATH_RELEASE_NOTIMER);
		end
		if ( not dialog.UpdateRecapButton ) then
			dialog.UpdateRecapButton = function( dialog )
				local button4 = dialog:GetButton4();
				if ( DeathRecap_HasEvents() ) then
					button4:Enable();
					button4:SetScript("OnEnter", nil );
					button4:SetScript("OnLeave", nil);
				else
					button4:Disable();
					button4:SetMotionScriptsWhileDisabled(true);
					button4:SetScript("OnEnter", function(dialog)
						GameTooltip:SetOwner(dialog, "ANCHOR_BOTTOMRIGHT");
						GameTooltip:SetText(DEATH_RECAP_UNAVAILABLE);
						GameTooltip:Show();
					end );
					button4:SetScript("OnLeave", GameTooltip_Hide);
				end
			end
		end

		dialog:UpdateRecapButton();
	end,
	OnHide = function(dialog, data)
		dialog:GetButton2().option = nil;
		dialog:GetButton3().option = nil;
		local button4 = dialog:GetButton4();
		button4:SetScript("OnEnter", nil );
		button4:SetScript("OnLeave", nil);
		button4:SetMotionScriptsWhileDisabled(false);
	end,
	OnButton1 = function(dialog, data)
		if ( IsActiveBattlefieldArena() and not C_PvP.IsInBrawl() ) then
			local info = ChatTypeInfo["SYSTEM"];
			DEFAULT_CHAT_FRAME:AddMessage(ARENA_SPECTATOR, info.r, info.g, info.b, info.id);
		end
		RepopMe();
		if ( CannotBeResurrected() ) then
			return 1
		end
	end,
	OnButton2 = function(dialog, data, reason)
		return GameDialogDefsUtil.OnResurrectButtonClick(dialog:GetButton2().option, reason);
	end,
	OnButton3 = function(dialog, data, reason)
		return GameDialogDefsUtil.OnResurrectButtonClick(dialog:GetButton3().option, reason);
	end,
	OnButton4 = function(dialog, data, reason)
		OpenDeathRecapUI();
		return true;
	end,
	OnUpdate = function(dialog, elapsed)
		if ( IsFalling() and not IsOutOfBounds()) then
			dialog:GetButton1():Disable();
			dialog:GetButton2():Disable();
			dialog:GetButton3():Disable();
			return;
		end

		local b1_enabled = dialog:GetButton1():IsEnabled();
		local encounterSupressRelease = IsEncounterSuppressingRelease();
		if ( encounterSupressRelease ) then
			dialog:GetButton1():SetEnabled(false);
			dialog:GetButton1():SetText(DEATH_RELEASE);
		else
			local hasNoReleaseAura, noReleaseDuration, hasUntilCancelledDuration = HasNoReleaseAura();
			dialog:GetButton1():SetEnabled(not hasNoReleaseAura);
			if ( hasNoReleaseAura ) then
				if hasUntilCancelledDuration then
					dialog:GetButton1():SetText(DEATH_RELEASE);
				else
					dialog:GetButton1():SetText(math.floor(noReleaseDuration));
				end
			else
				dialog:GetButton1():SetText(DEATH_RELEASE);
			end
		end

		if ( b1_enabled ~= dialog:GetButton1():IsEnabled() ) then
			if ( b1_enabled ) then
				if ( encounterSupressRelease ) then
					dialog:SetText(CAN_NOT_RELEASE_IN_COMBAT);
				else
					dialog:SetText(CAN_NOT_RELEASE_RIGHT_NOW);
				end
			else
				dialog:SetText("");
				StaticPopupDialogs[dialog.which].OnShow(dialog);
			end
			dialog:Resize(dialog.which);
		end

		local option1, option2 = GameDialogDefsUtil.GetSelfResurrectDialogOptions();
		if ( option1 ) then
			if ( option1.name ) then
				dialog:GetButton2():SetText(option1.name);
			end
			dialog:GetButton2().option = option1;
			dialog:GetButton2():SetEnabled(option1.canUse);
		end
		if ( option2 ) then
			if ( option2.name ) then
				dialog:GetButton3():SetText(option2.name);
			end
			dialog:GetButton3().option = option2;
			dialog:GetButton3():SetEnabled(option2.canUse);
		end

		if ( dialog.UpdateRecapButton) then
			dialog:UpdateRecapButton();
		end
	end,
	DisplayButton2 = function(dialog, data)
		local option1, option2 = GameDialogDefsUtil.GetSelfResurrectDialogOptions();
		return option1 ~= nil;
	end,
	DisplayButton3 = function(dialog, data)
		local option1, option2 = GameDialogDefsUtil.GetSelfResurrectDialogOptions();
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

StaticPopupDialogs["GROUP_INVITE_CONFIRMATION"] = {
	text = "%s", --Filled out dynamically
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = SOUNDKIT.IG_PLAYER_INVITE,
	OnAccept = function(dialog, data)
		RespondToInviteConfirmation(data, true);
	end,
	OnCancel = function(dialog, data)
		RespondToInviteConfirmation(data, false);
	end,
	OnHide = function(dialog, data)
		UpdateInviteConfirmationDialogs();
	end,
	OnUpdate = function(dialog, elapsed)
		if ( not dialog.linkRegion or not dialog.nextUpdateTime ) then
			return;
		end

		local timeNow = GetTime();
		if ( dialog.nextUpdateTime > timeNow ) then
			return;
		end

		local _, _, guid, _, _, level, spec, itemLevel = GetInviteConfirmationInfo(data);
		local className, classFilename, _, _, gender, characterName, _ = GetPlayerInfoByGUID(guid);

		GameTooltip:SetOwner(dialog.linkRegion);

		if ( className ) then
			dialog.nextUpdateTime = nil; -- The tooltip will be created with valid data, no more updates necessary.

			local _, _, _, colorCode = GetClassColor(classFilename);
			GameTooltip:SetText(WrapTextInColorCode(characterName, colorCode));

			local _, specName = GetSpecializationInfoByID(spec, gender);
			local characterLine = CHARACTER_LINK_CLASS_LEVEL_SPEC_TOOLTIP:format(level, className, specName);
			local itemLevelLine = CHARACTER_LINK_ITEM_LEVEL_TOOLTIP:format(itemLevel);

			GameTooltip:AddLine(characterLine, HIGHLIGHT_FONT_COLOR:GetRGB());
			GameTooltip:AddLine(itemLevelLine, HIGHLIGHT_FONT_COLOR:GetRGB());
			GameTooltip_SetTooltipWaitingForData(GameTooltip, false);
		else
			dialog.nextUpdateTime = timeNow + .5;
			GameTooltip:SetText(RETRIEVING_DATA, RED_FONT_COLOR:GetRGB());
			GameTooltip_SetTooltipWaitingForData(GameTooltip, true);
		end

		GameTooltip:Show();
	end,
	OnHyperlinkClick = function(dialog, link, text, button)
		-- Only allowing left button for now.
		if ( button == "LeftButton" ) then
			SetItemRef(link, text, button);
		end
	end,
	OnHyperlinkEnter = function(dialog, link, text, region, boundsLeft, boundsBottom, boundsWidth, boundsHeight)
		local linkType = string.match(link, '(.-):');
		if ( linkType ~= "player" ) then
			return;
		end

		dialog.linkRegion = region;
		dialog.linkText = text;
		dialog.nextUpdateTime = GetTime();
		StaticPopupDialogs["GROUP_INVITE_CONFIRMATION"].OnUpdate(dialog);
	end,
	OnHyperlinkLeave = function(dialog)
		dialog.linkRegion = nil;
		dialog.linkText = nil;
		dialog.nextUpdateTime = nil;
		GameTooltip:Hide();
	end,
	timeout = StaticPopupTimeoutSec,
	whileDead = 1,
};

StaticPopupDialogs["CAMP"] = {
	text = CAMP_TIMER,
	GetExpirationText = GameDialogDefsUtil.GetDefaultExpirationText,
	button1 = CANCEL,
	cancelIfNotAllowedWhileLoggingOut = true,
	OnAccept = function(dialog, data)
		CancelLogout();
	end,
	OnCancel = function(dialog, data)
		CancelLogout();
	end,
	timeout = 20,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["PLUNDERSTORM_LEAVE"] = {
	text = PLUNDERSTORM_LOGOUT_TEXT,
	GetExpirationText = GameDialogDefsUtil.GetDefaultExpirationText,
	button1 = CANCEL,
	cancelIfNotAllowedWhileLoggingOut = true,
	OnAccept = function(dialog, data)
		CancelLogout();
	end,
	OnCancel = function(dialog, data)
		CancelLogout();
	end,
	timeout = 20,
	whileDead = 1,
	hideOnEscape = 1
}

local function GetBindWarning(itemLocation)
	local item = Item:CreateFromItemLocation(itemLocation);
	if not item then
		return;
	end

	local _itemID, _itemType, _itemSubType, _itemEquipLoc, _icon, itemClassID, itemSubclassID = C_Item.GetItemInfoInstant(item:GetItemID());
	local isArmor = (itemClassID == Enum.ItemClass.Armor) and (itemSubclassID ~= Enum.ItemArmorSubclass.Shield);
	if isArmor and not IsItemPreferredArmorType(item:GetItemLocation()) then
		return NOT_BEST_ARMOR_TYPE_WARNING;
	end
end

StaticPopupDialogs["EQUIP_BIND"] = {
	text = EQUIP_NO_DROP,
	button1 = OKAY,
	button2 = CANCEL,
	OnShow = function(dialog, data)
		local warning = GetBindWarning(data.itemLocation);
		if warning then
			dialog:SetText(EQUIP_NO_DROP .. "|n|n" .. warning);
		end
	end,
	OnAccept = function(dialog, data)
		EquipPendingItem(data.slot);
	end,
	OnCancel = function(dialog, data)
		CancelPendingEquip(data.slot);
	end,
	OnHide = function(dialog, data)
		CancelPendingEquip(data.slot);
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
	OnShow = function(dialog, data)
		local warning = GetBindWarning(data.itemLocation);
		if warning then
			dialog:SetText(END_REFUND .. "|n|n" .. warning);
		end
	end,
	OnAccept = function(dialog, data)
		EquipPendingItem(data.slot);
	end,
	OnCancel = function(dialog, data)
		CancelPendingEquip(data.slot);
	end,
	OnHide = function(dialog, data)
		CancelPendingEquip(data.slot);
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
	OnShow = function(dialog, data)
		local warning = GetBindWarning(data.itemLocation);
		if warning then
			dialog:SetText(END_BOUND_TRADEABLE .. "|n|n" .. warning);
		end
	end,
	OnAccept = function(dialog, data)
		EquipPendingItem(data.slot);
	end,
	OnCancel = function(dialog, data)
		CancelPendingEquip(data.slot);
	end,
	OnHide = function(dialog, data)
		CancelPendingEquip(data.slot);
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONVERT_TO_BIND_TO_ACCOUNT_CONFIRM"] = {
	text = CONVERT_TO_BIND_TO_ACCOUNT_CONFIRM,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		ConvertItemToBindToAccount();
	end,
	OnCancel = function(dialog, data)
		ClearPendingBindConversionItem();
	end,
	OnHide = function(dialog, data)
		ClearPendingBindConversionItem();
	end,
	OnUpdate = function(dialog, elapsed)
		if not CursorHasItem() then
			dialog:Hide();
		end
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_AZERITE_EMPOWERED_RESPEC_EXPENSIVE"] = {
	text = CONFIRM_AZERITE_EMPOWERED_ITEM_RESPEC_EXPENSIVE,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		PlaySound(SOUNDKIT.UI_80_AZERITEARMOR_REFORGE);
		C_AzeriteEmpoweredItem.ConfirmAzeriteEmpoweredItemRespec(data.empoweredItemLocation);
	end,
	OnShow = function(dialog, data)
		dialog:GetButton1():Disable();
		dialog:GetButton2():Enable();
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		if ( editBox:GetParent():GetButton1():IsEnabled() ) then
			editBox:GetParent():GetButton1():Click();
		end
	end,
	EditBoxOnTextChanged = function(editBox, data)
		StaticPopup_StandardConfirmationTextHandler(editBox, CONFIRM_AZERITE_EMPOWERED_RESPEC_STRING);
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,

	timeout = 0,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 32,
};

StaticPopupDialogs["DELETE_GOOD_ITEM"] = {
	text = DELETE_GOOD_ITEM,
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
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 32,
	OnShow = function(dialog, data)
		local itemLocation = C_Cursor.GetCursorItem();
		if itemLocation and C_Item.DoesItemExist(itemLocation) and C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation) then
			local msg = C_SpellBook.ContainsAnyDisenchantSpell() and DELETE_AZERITE_SCRAPPABLE_OR_DISENCHANTABLE_ITEM or DELETE_AZERITE_SCRAPPABLE_ITEM;
			local itemName = dialog:GetTextFontString().text_arg1;
			local azeriteIconMarkup = CreateTextureMarkup("Interface\\Icons\\INV_AzeriteDebuff",64,64,16,16,0,1,0,1,0,-2);
			dialog:SetText(string.format(msg, itemName, azeriteIconMarkup));
		end

		dialog:GetButton1():Disable();
		dialog:GetButton2():Enable();
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
		MerchantFrame_ResetRefundItem();
		if GameTooltip:GetOwner() == dialog then
			GameTooltip:Hide();
		end
	end,
	OnHyperlinkEnter = function(dialog, link, text, region, boundsLeft, boundsBottom, boundsWidth, boundsHeight)
		GameTooltip:SetOwner(dialog, "ANCHOR_PRESERVE");
		GameTooltip:ClearAllPoints();
		local cursorClearance = 30;
		GameTooltip:SetPoint("TOPLEFT", region, "BOTTOMLEFT", boundsLeft, boundsBottom - cursorClearance);
		GameTooltip:SetHyperlink(link);
	end,
	OnHyperlinkLeave = function(dialog)
		GameTooltip:Hide();
	end,
	OnHyperlinkClick = function(dialog, link, text, button)
		GameTooltip:Hide();
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		if ( editBox:GetParent():GetButton1():IsEnabled() ) then
			DeleteCursorItem();
			editBox:GetParent():Hide();
		end
	end,
	EditBoxOnTextChanged = function(editBox, data)
		StaticPopup_StandardConfirmationTextHandler(editBox, DELETE_ITEM_CONFIRM_STRING);
	end,
	EditBoxOnEscapePressed = function(editBox, data)
		StaticPopup_StandardEditBoxOnEscapePressed(editBox);
		ClearCursor();
	end
};

StaticPopupDialogs["DELETE_GOOD_QUEST_ITEM"] = {
	text = DELETE_GOOD_QUEST_ITEM,
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
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 32,
	OnShow = function(dialog, data)
		dialog:GetButton1():Disable();
		dialog:GetButton2():Enable();
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
		MerchantFrame_ResetRefundItem();
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		if ( editBox:GetParent():GetButton1():IsEnabled() ) then
			DeleteCursorItem();
			editBox:GetParent():Hide();
		end
	end,
	EditBoxOnTextChanged = function(editBox, data)
		StaticPopup_StandardConfirmationTextHandler(editBox, DELETE_ITEM_CONFIRM_STRING);
	end,
	EditBoxOnEscapePressed = function(editBox, data)
		StaticPopup_StandardEditBoxOnEscapePressed(editBox);
		ClearCursor();
	end
};

StaticPopupDialogs["RELEASE_PET"] = {
	text = RELEASE_PET,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		-- If data + petnum, we're abandoning from the stable UI
		-- Otherwise, we're abandoning from the unit frame
		if ( data ) then
			if ( data.summonedPetNumber and data.summonedPetNumber == data.selectedPetNumber ) then
				C_PetInfo.PetAbandon();
			elseif ( data.selectedPetNumber ) then
				C_PetInfo.PetAbandon(data.selectedPetNumber);
			end
		else
			C_PetInfo.PetAbandon();
		end
	end,
	OnUpdate = function(dialog, elapsed)
		if ( dialog.data and not dialog.data.selectedPetNumber ) then
			dialog:Hide();
		elseif ( not dialog.data ) then
			if ( not UnitExists("pet") ) then
				dialog:Hide();
			end
		end
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["ABANDON_QUEST"].OnAccept = function(dialog, data)
	C_QuestLog.AbandonQuest();
	if ( QuestLogPopupDetailFrame:IsShown() ) then
		HideUIPanel(QuestLogPopupDetailFrame);
	end
	PlaySound(SOUNDKIT.IG_QUEST_LOG_ABANDON_QUEST);
end;

StaticPopupDialogs["ABANDON_QUEST_WITH_ITEMS"].OnAccept = function(dialog, data)
	C_QuestLog.AbandonQuest();
	if ( QuestLogPopupDetailFrame:IsShown() ) then
		HideUIPanel(QuestLogPopupDetailFrame);
	end
	PlaySound(SOUNDKIT.IG_QUEST_LOG_ABANDON_QUEST);
end;

StaticPopupDialogs["SET_FRIENDNOTE"].OnShow = function(dialog, data)
	local accountInfo = C_BattleNet.GetAccountInfoByID(FriendsFrame.NotesID);
	if accountInfo and accountInfo.note ~= "" then
		dialog:GetEditBox():SetText(accountInfo.note);
	end
	dialog:GetEditBox():SetFocus();
end;

StaticPopupDialogs["SET_BNFRIENDNOTE"].OnShow = function(dialog, data)
	local accountInfo = C_BattleNet.GetAccountInfoByID(FriendsFrame.NotesID);
	if accountInfo and accountInfo.note ~= "" then
		dialog:GetEditBox():SetText(accountInfo.note);
	end
	dialog:GetEditBox():SetFocus();
end;

StaticPopupDialogs["CONFIRM_REMOVE_COMMUNITY_MEMBER"].OnShow = function(dialog, clubInfo)
	if clubInfo.clubType == Enum.ClubType.Character then
		dialog:SetText(CONFIRM_REMOVE_CHARACTER_COMMUNITY_MEMBER_LABEL:format(clubInfo.name));
	else
		dialog:SetText(CONFIRM_REMOVE_COMMUNITY_MEMBER_LABEL:format(clubInfo.name));
	end
end;

StaticPopupDialogs["CONFIRM_LEAVE_AND_DESTROY_COMMUNITY"].OnShow = function(dialog, clubInfo)
	if clubInfo.clubType == Enum.ClubType.Character then
		dialog:SetText(CONFIRM_LEAVE_AND_DESTROY_CHARACTER_COMMUNITY);
		dialog.SubText:SetText(CONFIRM_LEAVE_AND_DESTROY_CHARACTER_COMMUNITY_SUBTEXT);
	else
		dialog:SetText(CONFIRM_LEAVE_AND_DESTROY_COMMUNITY);
		dialog.SubText:SetText(CONFIRM_LEAVE_AND_DESTROY_COMMUNITY_SUBTEXT);
	end
end;

StaticPopupDialogs["CONFIRM_LEAVE_COMMUNITY"].OnShow = function(dialog, clubInfo)
	if clubInfo.clubType == Enum.ClubType.Character then
		dialog:SetText(CONFIRM_LEAVE_CHARACTER_COMMUNITY);
		dialog.SubText:SetFormattedText(CONFIRM_LEAVE_CHARACTER_COMMUNITY_SUBTEXT, clubInfo.name);
	else
		dialog:SetText(CONFIRM_LEAVE_COMMUNITY);
		dialog.SubText:SetFormattedText(CONFIRM_LEAVE_COMMUNITY_SUBTEXT, clubInfo.name);
	end
end;

StaticPopupDialogs["CONFIRM_DESTROY_COMMUNITY"] = {
	text = "",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, clubInfo)
		C_Club.DestroyClub(clubInfo.clubId);
		CloseCommunitiesSettingsDialog();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 32,
	OnShow = function(dialog, clubInfo)
		if clubInfo.clubType == Enum.ClubType.BattleNet then
			dialog:SetText(CONFIRM_DESTROY_COMMUNITY:format(clubInfo.name));
		else
			dialog:SetText(CONFIRM_DESTROY_CHARACTER_COMMUNITY:format(clubInfo.name));
		end

		dialog:GetButton1():Disable();
		dialog:GetButton2():Enable();
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
		MerchantFrame_ResetRefundItem();
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		if ( editBox:GetParent():GetButton1():IsEnabled() ) then
			editBox:GetParent():GetButton1():Click();
			editBox:GetParent():Hide();
		end
	end,
	EditBoxOnTextChanged = function(editBox, data)
		StaticPopup_StandardConfirmationTextHandler(editBox, COMMUNITIES_DELETE_CONFIRM_STRING);
	end,
	EditBoxOnEscapePressed = function(editBox, data)
		StaticPopup_StandardEditBoxOnEscapePressed(editBox);
		ClearCursor();
	end
};

local function ClubInviteDisabledOnEnter(dialog)
	if(not dialog:IsEnabled()) then
		GameTooltip:SetOwner(dialog, "ANCHOR_BOTTOMRIGHT");
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
	OnAccept = function(dialog, data)
		C_GuildInfo.Invite(dialog:GetEditBox():GetText());
	end,
	OnShow = function(dialog, data)
		dialog:GetEditBox():SetFocus();

		dialog:GetButton1():SetMotionScriptsWhileDisabled(true);
		dialog:GetButton1():SetScript("OnEnter", function(dialog)
			ClubInviteDisabledOnEnter(dialog);
		end );
		dialog:GetButton1():SetScript("OnLeave", GameTooltip_Hide);
		if (dialog.ExtraButton) then
			dialog.ExtraButton:SetMotionScriptsWhileDisabled(true);
			dialog.ExtraButton:SetScript("OnEnter", function(dialog)
				ClubInviteDisabledOnEnter(dialog);
			end );
			dialog.ExtraButton:SetScript("OnLeave", GameTooltip_Hide);
		end
		local clubInfo = C_Club.GetClubInfo(data.clubId);
		if(clubInfo and clubInfo.memberCount and clubInfo.memberCount >= C_Club.GetClubCapacity()) then
			dialog:GetButton1():Disable();
			if (dialog.ExtraButton) then
				dialog.ExtraButton:Disable();
			end
		else
			dialog:GetButton1():Enable();
			if (dialog.ExtraButton) then
				dialog.ExtraButton:Enable();
			end
		end
	end,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
		dialog:GetButton1():SetScript("OnEnter", nil );
		dialog:GetButton1():SetScript("OnLeave", nil);
		if (dialog.ExtraButton) then
			dialog.ExtraButton:SetScript("OnEnter", nil );
			dialog.ExtraButton:SetScript("OnLeave", nil);
		end
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		local invitee = editBox:GetText();
		if invitee == "" then
			ChatFrame_OpenChat("");
		else
			C_GuildInfo.Invite(invitee);
			dialog:Hide();
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
	OnExtraButton = function(dialog, data)
		local clubInfo = ClubFinderGetCurrentClubListingInfo(data.clubId);
		if (clubInfo) then
			local link = GetClubFinderLink(clubInfo.clubFinderGUID, clubInfo.name);
			if not ChatEdit_InsertLink(link) then
				ChatFrame_OpenChat(link);
			end
		end
	end,
}, StaticPopupDialogs["ADD_GUILDMEMBER"]);

StaticPopupDialogs["CONVERT_TO_RAID"].OnAccept = function(dialog, data)
	C_PartyInfo.ConfirmInviteUnit(data);
end;

StaticPopupDialogs["LFG_LIST_AUTO_ACCEPT_CONVERT_TO_RAID"].OnAccept = function(dialog, data)
	C_PartyInfo.ConfirmConvertToRaid();
end;

StaticPopupDialogs["REMOVE_GUILDMEMBER"] = {
	text = format(REMOVE_GUILDMEMBER_LABEL, "XXX"),
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
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
	OnShow = function(dialog, data)
		if data then
			dialog:SetFormattedText(REMOVE_GUILDMEMBER_LABEL, data.name);
		else
			dialog:SetText(GuildFrame.selectedName);
		end
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["SET_GUILDPLAYERNOTE"].editBoxWidth = 260;

StaticPopupDialogs["SET_GUILDOFFICERNOTE"].editBoxWidth = 260;

StaticPopupDialogs["RENAME_PET"] = {
	text = PET_RENAME_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 12,
	OnAccept = function(dialog, data)
		local text = dialog:GetEditBox():GetText();
		local petNum = data and data.petNumber or nil;
		if ( text ) then
			dialog:Hide();
			StaticPopup_Show("PETRENAMECONFIRM", text, nil, {newName = text, petNumber = petNum});
		end
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		local text = editBox:GetText();
		local petNum = data and data.petNumber or nil;
		if ( text ) then
			dialog:Hide();
			StaticPopup_Show("PETRENAMECONFIRM", text, nil, {newName = text, petNumber = petNum});
		end
	end,
	OnShow = function(dialog, data)
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
	end,
	OnUpdate = function(dialog, elapsed)
		if ( dialog.data and not dialog.data.petNumber ) then
			dialog:Hide();
		elseif ( not dialog.data ) then
			if ( not UnitExists("pet") ) then
				dialog:Hide();
			end
		end
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["UNLEARN_SKILL"] = {
	text = UNLEARN_SKILL,
	button1 = UNLEARN,
	button2 = CANCEL,
	OnAccept = function(dialog, index)
		AbandonSkill(index);
		HideUIPanel(ProfessionsFrame);
	end,
	OnShow = function(dialog, data)
		dialog:GetButton1():Disable();
		dialog:GetButton2():Enable();
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		dialog:GetEditBox():SetText("");
	end,
	EditBoxOnEnterPressed = function(editBox, index)
		local dialog = editBox:GetParent();
		if dialog:GetButton1():IsEnabled() then
			AbandonSkill(index);
			HideUIPanel(ProfessionsFrame);
			dialog:Hide();
		end
	end,
	EditBoxOnTextChanged = function(editBox, data)
		StaticPopup_StandardConfirmationTextHandler(editBox, UNLEARN_SKILL_CONFIRMATION);
	end,
	EditBoxOnEscapePressed = function(editBox, data)
		editBox:GetParent():Hide();
		ClearCursor();
	end,
	timeout = StaticPopupTimeoutSec,
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
	OnAccept = function(dialog, data)
		if ( data ) then
			dialog:SetFormattedText(CONFIRM_XP_LOSS_AGAIN, data);
			dialog.data = nil;
			return 1;
		else
			C_PlayerInteractionManager.ConfirmationInteraction(Enum.PlayerInteractionType.SpiritHealer);
			C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.SpiritHealer);
		end
	end,
	OnUpdate = function(dialog, elapsed)
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
	OnAccept = function(dialog, data)
		C_PlayerInteractionManager.ConfirmationInteraction(Enum.PlayerInteractionType.SpiritHealer);
		C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.SpiritHealer);
	end,
	OnUpdate = function(dialog, elapsed)
		if ( not C_PlayerInteractionManager.IsValidNPCInteraction(Enum.PlayerInteractionType.SpiritHealer) ) then
			C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.SpiritHealer);
			dialog:Hide();
		end
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["BIND_SOCKET"] = {
	text = ACTION_WILL_BIND_ITEM,
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

StaticPopupDialogs["REPLACE_TRADESKILL_ENCHANT"] = {
	text = REPLACE_ENCHANT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		C_Item.ReplaceTradeskillEnchant();
	end,
	timeout = 0,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_BLOCK_FRIEND"] = {
	text = "%s",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, accountID)
		BNSetBlocked(accountID, false);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["SPELL_CONFIRMATION_PROMPT_ALERT"] = {
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
	hideOnEscape = 1,
	showAlert = 1
}

StaticPopupDialogs["SPELL_CONFIRMATION_WARNING_ALERT"] = {
	button1 = OKAY,
	OnAccept = function(dialog, data)
		AcceptSpellConfirmationPrompt(data);
	end,
	exclusive = 0,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1
}

StaticPopupDialogs["CONFIRM_LEAVE_BATTLEFIELD"] = {
	text = CONFIRM_LEAVE_BATTLEFIELD,
	button1 = YES,
	button2 = CANCEL,
	OnShow = function(dialog, data)
		local ratedDeserterPenalty = C_PvP.GetPVPActiveRatedMatchDeserterPenalty();
		if ( ratedDeserterPenalty ) then
			local ratingChange = math.abs(ratedDeserterPenalty.personalRatingChange);
			local queuePenaltySpellLink, queuePenaltyDuration = C_Spell.GetSpellLink(ratedDeserterPenalty.queuePenaltySpellID), SecondsToTime(ratedDeserterPenalty.queuePenaltyDuration);
			dialog:SetText(CONFIRM_LEAVE_RATED_MATCH_WITH_PENALTY:format(ratingChange, queuePenaltyDuration, queuePenaltySpellLink));
		elseif ( IsActiveBattlefieldArena() and not C_PvP.IsInBrawl() ) then
			dialog:SetText(CONFIRM_LEAVE_ARENA);
		else
			dialog:SetText(CONFIRM_LEAVE_BATTLEFIELD);
		end
	end,
	OnAccept = function(dialog, data)
		LeaveBattlefield();
	end,
	OnHyperlinkEnter = function(dialog, link, text, region, boundsLeft, boundsBottom, boundsWidth, boundsHeight)
		GameTooltip:SetOwner(dialog, "ANCHOR_CURSOR_RIGHT");
		GameTooltip:SetHyperlink(link);
		GameTooltip:Show();
	end,
	OnHyperlinkLeave = function(dialog)
		GameTooltip_Hide();
	end,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,
	-- acceptDelay - Dynamically set in ConfirmOrLeaveBattlefield()
}

StaticPopupDialogs["PREMADE_SCENARIO_GROUP_SEARCH_DELIST_WARNING"] = {
	text = PREMADE_GROUP_SEARCH_DELIST_WARNING_TEXT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		LFGListFrame_BeginFindScenarioGroup(LFGListFrame, data);
	end,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1,
}

StaticPopupDialogs["PREMADE_GROUP_LEADER_CHANGE_DELIST_WARNING"] = {
	text = GROUP_FINDER_DELIST_WARNING_TITLE,
	GetExpirationSubText = function(dialog, data, timeleft)
		local dialogInfo = dialog.dialogInfo;
		return dialogInfo.subText:format(SecondsToTime(timeleft));
	end,
	subText = GROUP_FINDER_DELIST_WARNING_SUBTEXT,
	button1 = LIST_MY_GROUP,
	button2 = GROUP_FINDER_DESLIST_WARNING_EDIT_LISTING,
	button3 = UNLIST_MY_GROUP,

	OnAccept = function(dialog, data)
		dialog.delistOnHide = false;
	end,

	OnCancel = function(dialog, data, reason)
		if(reason ~= "timeout") then
			LFGListUtil_OpenBestWindow(true);
			dialog.delistOnHide = false;
		end
	end,

	OnHide = function(dialog, data)
		if  (C_LFGList.HasActiveEntryInfo() and dialog.delistOnHide) then
			C_LFGList.RemoveListing();
		end
	end,

	OnShow = function(dialog, data)
		dialog:SetText(GROUP_FINDER_DELIST_WARNING_TITLE:format(data.listingTitle));
		dialog.timeleft = data.delistTime;
		dialog.delistOnHide = true;
	end,

	whileDead = 1,
	showAlert = 1,
}

StaticPopupDialogs["PREMADE_SCENARIO_GROUP_INSECURE_SEARCH"] = {
	text = PREMADE_GROUP_INSECURE_SEARCH,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		LFGListFrame_BeginFindScenarioGroup(LFGListFrame, data);
	end,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1,
}

StaticPopupDialogs["LEAVING_TUTORIAL_AREA"] = {
	text = "",
	button1 = "",
	button2 = NPE_ABANDON_LEAVE_TUTORIAL,
	OnButton1 = function(dialog, data)
		C_Tutorial.ReturnToTutorialArea();
	end,
	OnButton2 = function(dialog, data)
		C_Tutorial.AbandonTutorialArea();
	end,
	OnShow = function(dialog, data)
		if UnitFactionGroup("player") == "Horde" then
			dialog:GetButton1():SetText(NPE_ABANDON_H_RETURN);
			dialog:SetText(NPE_ABANDON_H_WARNING);
		else
			dialog:GetButton1():SetText(NPE_ABANDON_A_RETURN);
			dialog:SetText(NPE_ABANDON_A_WARNING);
		end
	end,
	selectCallbackByIndex = true,
};

StaticPopupDialogs["CLUB_FINDER_ENABLED_DISABLED"] = {
	text = CLUB_FINDER_ENABLE_DISABLE_MESSAGE,
	button1 = OKAY,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1,
}

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

StaticPopupDialogs["INVITE_COMMUNITY_MEMBER"] = {
	text = INVITE_COMMUNITY_MEMBER_POPUP_INVITE_TEXT,
	subText = INVITE_COMMUNITY_MEMBER_POPUP_INVITE_SUB_TEXT_BTAG,
	button1 = INVITE_COMMUNITY_MEMBER_POPUP_SEND_INVITE,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		InviteToClub(data.clubId, dialog:GetEditBox():GetText());
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
	OnShow = function(dialog, data)
		dialog:GetEditBox():SetFocus();

		local clubInfo = C_Club.GetClubInfo(data.clubId);
		if clubInfo.clubType == Enum.ClubType.BattleNet then
			AutoCompleteEditBox_SetAutoCompleteSource(dialog:GetEditBox(), C_Club.GetInvitationCandidates, data.clubId);
			dialog.SubText:SetText(INVITE_COMMUNITY_MEMBER_POPUP_INVITE_SUB_TEXT_BNET_FRIEND);
			dialog:GetEditBox().Instructions:SetText(INVITE_COMMUNITY_MEMBER_POPUP_INVITE_EDITBOX_INSTRUCTIONS);
		else
			AutoCompleteEditBox_SetAutoCompleteSource(dialog:GetEditBox(), GetAutoCompleteResults, AUTOCOMPLETE_LIST.COMMUNITY.include, AUTOCOMPLETE_LIST.COMMUNITY.exclude);
			dialog.SubText:SetText(INVITE_COMMUNITY_MEMBER_POPUP_INVITE_SUB_TEXT_CHARACTER);
			dialog:GetEditBox().Instructions:SetText("");
		end
		dialog:GetButton1():SetMotionScriptsWhileDisabled(true);
		dialog:GetButton1():SetScript("OnEnter", function(dialog)
			ClubInviteDisabledOnEnter(dialog);
		end );
		dialog:GetButton1():SetScript("OnLeave", GameTooltip_Hide);
		if (dialog.ExtraButton) then
			dialog.ExtraButton:SetMotionScriptsWhileDisabled(true);
			dialog.ExtraButton:SetScript("OnEnter", function(dialog)
				ClubInviteDisabledOnEnter(dialog);
			end );
			dialog.ExtraButton:SetScript("OnLeave", GameTooltip_Hide);
		end

		if(clubInfo and clubInfo.memberCount and clubInfo.memberCount >= C_Club.GetClubCapacity()) then
			dialog:GetButton1():Disable();
			if (dialog.ExtraButton) then
				dialog.ExtraButton:Disable();
			end
		else
			dialog:GetButton1():Enable();
			if (dialog.ExtraButton) then
				dialog.ExtraButton:Enable();
			end
		end
	end,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
		dialog:GetButton1():SetScript("OnEnter", nil );
		dialog:GetButton1():SetScript("OnLeave", nil);
		if (dialog.ExtraButton) then
			dialog.ExtraButton:SetScript("OnEnter", nil );
			dialog.ExtraButton:SetScript("OnLeave", nil);
		end
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		editBox:GetParent():GetButton1():Click();
	end,
	EditBoxOnEscapePressed = function(editBox, data)
		StaticPopup_StandardEditBoxOnEscapePressed(editBox);
		ClearCursor();
	end
};

StaticPopupDialogs["INVITE_COMMUNITY_MEMBER_WITH_INVITE_LINK"] = Mixin({
	extraButton = INVITE_COMMUNITY_MEMBER_POPUP_OPEN_INVITE_MANAGER,
	OnExtraButton = function(dialog, data)
		CommunitiesTicketManagerDialog_Open(data.clubId, data.streamId);
	end,
}, StaticPopupDialogs["INVITE_COMMUNITY_MEMBER"]);

StaticPopupDialogs["CONFIRM_RAF_REMOVE_RECRUIT"] = {
	text = RAF_REMOVE_RECRUIT_CONFIRM,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		C_RecruitAFriend.RemoveRAFRecruit(data);
	end,
	timeout = 0,
	whileDead = 1,
	exclusive = 1,
	showAlert = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 32,
	OnShow = function(dialog, data)
		dialog:GetButton1():Disable();
		dialog:GetButton2():Enable();
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		if ( editBox:GetParent():GetButton1():IsEnabled() ) then
			C_RecruitAFriend.RemoveRAFRecruit(data);
			editBox:GetParent():Hide();
		end
	end,
	EditBoxOnTextChanged = function(editBox, data)
		StaticPopup_StandardConfirmationTextHandler(editBox, REMOVE_RECRUIT_CONFIRM_STRING);
	end,
	EditBoxOnEscapePressed = StaticPopup_StandardEditBoxOnEscapePressed,
};

local factionMajorCities = {
	["Alliance"] = STORMWIND,
	["Horde"] = ORGRIMMAR,
}

StaticPopupDialogs["RETURNING_PLAYER_PROMPT"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnShow = function(dialog, data)
		local playerFactionGroup = UnitFactionGroup("player");
		local factionCity = playerFactionGroup and factionMajorCities[playerFactionGroup] or nil;
		if(factionCity) then
			dialog:SetText(RETURNING_PLAYER_PROMPT:format(factionCity));
		end
	end,
	OnAccept = function(dialog, data)
		C_ReturningPlayerUI.AcceptPrompt();
		dialog:Hide();
	end,
	OnCancel = function(dialog, data)
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

StaticPopupDialogs["REMIX_END_OF_EVENT_NOTICE"] = {
    text = REMIX_END_OF_EVENT_NOTICE,
    button1 = OKAY,
}

StaticPopupDialogs["CONFIRM_PROFESSION_RESPEC"] = {
	text = PROFESSION_RESPEC_CONFIRMATION,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data) C_TradeSkillUI.ConfirmProfessionRespec(); HideUIPanel(ProfessionsFrame); end,
	OnCancel = function(dialog, data) C_TradeSkillUI.CancelProfessionRespec(); end,
	OnUpdate = function(dialog, elapsed)
		if ( not C_TradeSkillUI.CheckRespecNPC() ) then
			StaticPopup_Hide("CONFIRM_PROFESSION_RESPEC");
		end
	end,
	hideOnEscape = true,
	timeout = 0,
	exclusive = true,
}
