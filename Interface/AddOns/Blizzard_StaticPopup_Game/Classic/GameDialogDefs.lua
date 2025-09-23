StaticPopupDialogs["CONFIRM_OVERWRITE_EQUIPMENT_SET"].OnAccept = function(dialog, data)
	C_EquipmentSet.SaveEquipmentSet(data, dialog.selectedIcon); 
	GearManagerDialogPopup:Hide();
end;

StaticPopupDialogs["ERR_SOR_STARTING_EXPERIENCE_INCOMPLETE"] = {
	text = ERR_SOR_STARTING_EXPERIENCE_INCOMPLETE,
	button1 = OKAY,
	button2 = nil,
	timeout = 0,
	OnAccept = function(dialog, data)
	end,
	OnCancel = function(dialog, data)
	end,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,
}

StaticPopupDialogs["ERR_SOR_STARTING_EXPERIENCE_INCOMPLETE"] = {
	text = ERR_SOR_STARTING_EXPERIENCE_INCOMPLETE,
	button1 = OKAY,
	button2 = nil,
	timeout = 0,
	OnAccept = function(dialog, data)
	end,
	OnCancel = function(dialog, data)
	end,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,
}

StaticPopupDialogs["MAC_OPEN_UNIVERSAL_ACCESS"] = {
	text = MAC_OPEN_UNIVERSAL_ACCESS,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		C_MacOptions.OpenUniversalAccess();
		ShowUIPanel(MacOptionsFrame);
	end,
	OnCancel = function(dialog, data)
		ShowUIPanel(MacOptionsFrame);
	end,
	OnShow = function(dialog, data)
		if (MAC_OPEN_UNIVERSAL_ACCESS1090 ~= nil) then
			dialog:SetFormattedText(MAC_OPEN_UNIVERSAL_ACCESS1090, C_MacOptions.GetGameBundleName());
		else
			dialog:SetText(MAC_OPEN_UNIVERSAL_ACCESS);
		end
	end,
	showAlert = 1,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	whileDead = 1,
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
	timeout = 0,
	hideOnEscape = 1,
	hasItemFrame = 1,
}

StaticPopupDialogs["ADD_TEAMMEMBER"] = {
	text = ADD_TEAMMEMBER_LABEL,
	button1 = INVITE,
	button2 = CANCEL,
	hasEditBox = 1,
	autoCompleteParams = AUTOCOMPLETE_LIST.TEAM_INVITE,
	maxLetters = 77,
	OnAccept = function(dialog, data)
		if( GetCurrentArenaSeasonUsesTeams() ) then
			ArenaTeamInviteByName(PVPTeamDetails.team, dialog:GetEditBox():GetText());
		end
	end,
	OnShow = function(dialog, data)
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		if( GetCurrentArenaSeasonUsesTeams() ) then
			local dialog = editBox:GetParent();
			ArenaTeamInviteByName(PVPTeamDetails.team, editBox:GetText());
			dialog:Hide();
		end
	end,
	EditBoxOnEscapePressed = function(editBox, data)
		editBox:GetParent():Hide();
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
	OnAccept = function(dialog, data)
		ArenaTeamDisband(data);
	end,
	OnCancel = function(dialog, data)
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_TEAM_LEAVE"] = {
	text = CONFIRM_TEAM_LEAVE,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		ArenaTeamLeave(data);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_TEAM_PROMOTE"] = {
	text = CONFIRM_TEAM_PROMOTE,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, team, name)
		ArenaTeamSetLeaderByName(data, name);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_TEAM_KICK"] = {
	text = CONFIRM_TEAM_KICK,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, team, name)
		ArenaTeamUninviteByName(data, name);
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["ARENA_TEAM_INVITE"] = {
	text = ARENA_TEAM_INVITATION,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnAccept = function(dialog, data)
		AcceptArenaTeam();
	end,
	OnCancel = function(dialog, data)
		DeclineArenaTeam();
	end,
	timeout = StaticPopupTimeoutSec,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_LOOT_DISTRIBUTION"].OnAccept = function(dialog, data)
	if ( data == "LootWindow" ) then
		MasterLooterFrame_GiveMasterLoot();
	elseif ( data == "LootHistory" ) then
		LootHistoryDropdown_GiveMasterLoot();
	end
end;

StaticPopupDialogs["CONFIRM_BATTLEFIELD_ENTRY"] = {
	text = CONFIRM_BATTLEFIELD_ENTRY,
	button1 = ENTER_BATTLE,
	button2 = HIDE,
	OnAccept = function(dialog, data)
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

StaticPopupDialogs["RENAME_ARENA_TEAM"] = {
	text = RENAME_ARENA_TEAM_LABEL,
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

StaticPopupDialogs["CONFIRM_REPORT_BATTLEPET_NAME"] = {
	text = REPORT_BATTLEPET_NAME_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
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
	OnAccept = function(dialog, data)
		C_ChatInfo.ReportPlayer(PLAYER_REPORT_TYPE_BAD_PET_NAME);
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
			ChatConfig_UpdateChatSettings();
		end
	end,
	timeout = 0,
	EditBoxOnEscapePressed = function(editBox, data)
		editBox:GetParent():Hide();
	end,
	hideOnEscape = 1,
	exclusive = 1,
};

StaticPopupDialogs["PETRENAMECONFIRM"] = {
	text = PET_RENAME_CONFIRMATION,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		PetRename(data);
	end,
	OnUpdate = function(dialog, elapsed)
		if ( not UnitExists("pet") ) then
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
	selectCallbackByIndex = true,
	cancelIfNotAllowedWhileDead = true,
	OnShow = function(dialog, data)
		dialog.timeleft = GetReleaseTimeRemaining();
		dialog.resyncTime = 0; -- Timer so that we don't call GetReleaseTimeRemaining too frequently.

		if ( dialog.timeleft == -1 ) then
			dialog:SetText(DEATH_RELEASE_NOTIMER);
		end
	end,
	OnHide = function(dialog, data)
		dialog:GetButton2().option = nil;
		dialog:GetButton3().option = nil;
	end,
	OnButton1 = function(dialog, data)
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
	OnUpdate = function(dialog, elapsed)
		dialog.resyncTime = dialog.resyncTime - elapsed;
		if (dialog.resyncTime <= 0) then
			dialog.timeleft = GetReleaseTimeRemaining();
			dialog.resyncTime = 5;
		end

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
			local hasNoReleaseAura, noReleaseDuration = HasNoReleaseAura();
			dialog:GetButton1():SetEnabled(not hasNoReleaseAura);
			if ( hasNoReleaseAura ) then
				dialog.Bbutton1:SetText(math.floor(noReleaseDuration));
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
	cancels = "RECOVER_CORPSE",
	timeoutInformationalOnly = 1,
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

		local _, _, guid, roles, _, level = GetInviteConfirmationInfo(data);
		local className, classFilename, _, _, gender, characterName, _ = GetPlayerInfoByGUID(guid);

		GameTooltip:SetOwner(dialog.linkRegion, "ANCHOR_CURSOR_RIGHT");

		if ( className ) then
			dialog.nextUpdateTime = nil; -- The tooltip will be created with valid data, no more updates necessary.

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
			dialog.nextUpdateTime = timeNow + .5;
			GameTooltip:SetText(RETRIEVING_DATA, RED_FONT_COLOR:GetRGB());
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

StaticPopupDialogs["GUILD_INVITE"] = {
	text = GUILD_INVITATION,
	button1 = ACCEPT,
	button2 = DECLINE,
	OnAccept = function(dialog, data)
		AcceptGuild();
	end,
	OnCancel = function(dialog, data)
		DeclineGuild();
	end,
	timeout = 60,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["LEVEL_GRANT_PROPOSED"] = {
	text = LEVEL_GRANT,
	button1 = ACCEPT,
	button2 = DECLINE,
	sound = SOUNDKIT.IG_PLAYER_INVITE,
	OnAccept = function(dialog, data)
		AcceptLevelGrant();
	end,
	OnCancel = function(dialog, data)
		DeclineLevelGrant();
	end,
	OnHide = function(dialog, data)
		DeclineLevelGrant();
	end,
	timeout = StaticPopupTimeoutSec,
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
		OnAccept = function(dialog, data)
			AcceptLevelGrant();
		end,
		OnCancel = function(dialog, data)
			if (dialog.ticker) then
				dialog.ticker:Cancel();
				dialog.ticker = nil;
			end
			DeclineLevelGrant();
		end,
		OnShow = function(dialog, data)
			if (not warningSeenBefore) then
				dialog:GetButton1():Disable();
				dialog.timeLeft = 3;
				dialog:GetButton1():SetText(dialog.timeLeft);
				dialog.ticker = C_Timer.NewTicker(1, function()
					dialog.timeLeft = dialog.timeLeft - 1;
					dialog:GetButton1():SetText(dialog.timeLeft);
					if (dialog.timeLeft <= 0) then
						dialog.ticker:Cancel();
						dialog.ticker = nil;
						dialog:GetButton1():SetText(OKAY);
						dialog:GetButton1():Enable();
						warningSeenBefore = true;
					end
				end);
			end
		end,
		OnHide = function(dialog, data)
			if (dialog.ticker) then
				dialog.ticker:Cancel();
				dialog.ticker = nil;
			end
			DeclineLevelGrant();
		end,
		showAlert = 1,
		timeout = StaticPopupTimeoutSec,
		whileDead = 1,
		hideOnEscape = 1
	};
end

StaticPopupDialogs["CAMP"] = {
	text = CAMP_TIMER,
	GetExpirationText = GameDialogDefsUtil.GetDefaultExpirationText,
	button1 = CANCEL,
	cancelIfNotAllowedWhileLoggingOut = true,
	OnAccept = function(dialog, data)
		CancelLogout();
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

StaticPopupDialogs["EQUIP_BIND"] = {
	text = EQUIP_NO_DROP,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, slot)
		EquipPendingItem(slot);
	end,
	OnCancel = function(dialog, slot)
		CancelPendingEquip(slot);
	end,
	OnHide = function(dialog, slot)
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
	OnAccept = function(dialog, slot)
		EquipPendingItem(slot);
	end,
	OnCancel = function(dialog, slot)
		CancelPendingEquip(slot);
	end,
	OnHide = function(dialog, slot)
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
	OnAccept = function(dialog, slot)
		EquipPendingItem(slot);
	end,
	OnCancel = function(dialog, slot)
		CancelPendingEquip(slot);
	end,
	OnHide = function(dialog, slot)
		CancelPendingEquip(slot);
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
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
		local dialog = editBox:GetParent();
		if ( strupper(editBox:GetText()) ==  DELETE_ITEM_CONFIRM_STRING ) then
			dialog:GetButton1():Enable();
		else
			dialog:GetButton1():Disable();
		end
	end,
	EditBoxOnEscapePressed = function(editBox, data)
		editBox:GetParent():Hide();
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
		local parent = editBox:GetParent();
		if ( strupper(editBox:GetText()) ==  DELETE_ITEM_CONFIRM_STRING ) then
			parent:GetButton1():Enable();
		else
			parent:GetButton1():Disable();
		end
	end,
	EditBoxOnEscapePressed = function(editBox, data)
		editBox:GetParent():Hide();
		ClearCursor();
	end
};

StaticPopupDialogs["ABANDON_PET"] = {
	text = ABANDON_PET,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		PetAbandon();
	end,
	OnUpdate = function(dialog, elapsed)
		if ( not UnitExists("pet") ) then
			dialog:Hide();
		end
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["ABANDON_QUEST"].OnAccept = function(dialog, data)
	AbandonQuest();
	if ClassicExpansionAtLeast(LE_EXPANSION_WRATH_OF_THE_LICH_KING) then
		if ( QuestLogDetailFrame:IsShown() ) then
			HideUIPanel(QuestLogDetailFrame);
		end
	end
	PlaySound(SOUNDKIT.IG_QUEST_LOG_ABANDON_QUEST);
end;

StaticPopupDialogs["ABANDON_QUEST_WITH_ITEMS"].OnAccept = function(dialog, data)
	AbandonQuest();
	if ClassicExpansionAtLeast(LE_EXPANSION_WRATH_OF_THE_LICH_KING) then
		if ( QuestLogDetailFrame:IsShown() ) then
			HideUIPanel(QuestLogDetailFrame);
		end
	end
	PlaySound(SOUNDKIT.IG_QUEST_LOG_ABANDON_QUEST);
end;

StaticPopupDialogs["SET_FRIENDNOTE"].OnShow = function(dialog, data)
	local bnetIDAccount, accountName, battleTag, isBattleTag, characterName, bnetIDGameAccount, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText = BNGetFriendInfoByID(FriendsFrame.NotesID);
	if ( noteText ) then
		dialog:GetEditBox():SetText(noteText);
	end
	dialog:GetEditBox():SetFocus();
end;

StaticPopupDialogs["SET_BNFRIENDNOTE"].OnShow = function(dialog, data)
	local bnetIDAccount, accountName, battleTag, isBattleTag, characterName, bnetIDGameAccount, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText = BNGetFriendInfoByID(FriendsFrame.NotesID);
	if ( noteText ) then
		dialog:GetEditBox():SetText(noteText);
	end
	dialog:GetEditBox():SetFocus();
end;

StaticPopupDialogs["CONFIRM_REMOVE_COMMUNITY_MEMBER"].OnShow = function(dialog, data)
	dialog:SetText(CONFIRM_REMOVE_COMMUNITY_MEMBER_LABEL:format(data.name));
end;

StaticPopupDialogs["CONFIRM_LEAVE_AND_DESTROY_COMMUNITY"].OnShow = function(dialog, data)
	dialog:SetText(CONFIRM_LEAVE_AND_DESTROY_COMMUNITY);
	dialog.SubText:SetText(CONFIRM_LEAVE_AND_DESTROY_COMMUNITY_SUBTEXT);
end;

StaticPopupDialogs["CONFIRM_LEAVE_COMMUNITY"].OnShow = function(dialog, clubInfo)
	dialog:SetText(CONFIRM_LEAVE_COMMUNITY);
	dialog.SubText:SetFormattedText(CONFIRM_LEAVE_COMMUNITY_SUBTEXT, clubInfo.name);
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
		dialog:SetText(CONFIRM_DESTROY_COMMUNITY:format(clubInfo.name));

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
		local dialog = editBox:GetParent();
		if ( strupper(editBox:GetText()) ==  DELETE_ITEM_CONFIRM_STRING ) then
			dialog:GetButton1():Enable();
		else
			dialog:GetButton1():Disable();
		end
	end,
	EditBoxOnEscapePressed = function(editBox, data)
		editBox:GetParent():Hide();
		ClearCursor();
	end
};

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
	end,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		C_GuildInfo.Invite(editBox:GetText());
		dialog:Hide();
	end,
	EditBoxOnEscapePressed = function(editBox, data)
		editBox:GetParent():Hide();
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
	OnAccept = function(dialog, data)
		InviteToGroup(dialog:GetEditBox():GetText());
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
		InviteToGroup(editBox:GetText());
		dialog:Hide();
	end,
	EditBoxOnEscapePressed = function(editBox, data)
		editBox:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["CONVERT_TO_RAID"].OnAccept = function(dialog, data)
	ConvertToRaid();
	C_PartyInfo.InviteUnit(data);
end;

StaticPopupDialogs["LFG_LIST_AUTO_ACCEPT_CONVERT_TO_RAID"].OnAccept = function(dialog, data)
	ConvertToRaid();
end;


StaticPopupDialogs["REMOVE_GUILDMEMBER"] = {
	text = format(REMOVE_GUILDMEMBER_LABEL, "XXX"),
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
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
	OnShow = function(dialog, data)
		if data and data.name then
			dialog:SetFormattedText(REMOVE_GUILDMEMBER_LABEL, data.name);
		else
			dialog:SetFormattedText(REMOVE_GUILDMEMBER_LABEL, GuildFrame.selectedName);
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
	OnAccept = function(dialog, data)
		AddGuildRank(dialog:GetEditBox():GetText());
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
		AddGuildRank(editBox:GetText());
		dialog:Hide();
	end,
	EditBoxOnEscapePressed = function(editBox, data)
		editBox:GetParent():Hide();
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
	OnAccept = function(dialog, data)
		C_GuildInfo.SetMOTD(dialog:GetEditBox():GetText());
	end,
	OnShow = function(dialog, data)
		dialog:GetEditBox():SetText(GetGuildRosterMOTD());
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		C_GuildInfo.SetMOTD(editBox:GetText());
		dialog:Hide();
	end,
	EditBoxOnEscapePressed = function(editBox, data)
		editBox:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["SET_GUILDPLAYERNOTE"].wide = true;
StaticPopupDialogs["SET_GUILDPLAYERNOTE"].editBoxWidth = 350;

StaticPopupDialogs["SET_GUILDOFFICERNOTE"].editBoxWidth = 350;

StaticPopupDialogs["RENAME_PET"] = {
	text = PET_RENAME_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	maxLetters = 12,
	OnAccept = function(dialog, data)
		local text = dialog:GetEditBox():GetText();
		local dialogFrame = StaticPopup_Show("PETRENAMECONFIRM", text);
		if ( dialogFrame ) then
			dialogFrame.data = text;
		end
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		local dialog = editBox:GetParent();
		local text = editBox:GetText();
		StaticPopup_Show("PETRENAMECONFIRM", text, nil, text);
		dialog:Hide();
	end,
	OnShow = function(dialog, data)
		dialog:GetEditBox():SetFocus();
	end,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
	end,
	OnUpdate = function(dialog, elapsed)
		if ( not UnitExists("pet") ) then
			dialog:Hide();
		end
	end,
	timeout = 0,
	exclusive = 1,
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
		OnShow = function(dialog, data)
			dialog:GetButton1():Enable();
			dialog:GetButton2():Enable();
			return;
		end,
		OnButton1 = function(dialog, data)
			Logout();
			return;
		end,
		OnButton2 = function(dialog, data)
			RepopMe();
		end,
		OnButton3 = function(dialog, data)
			-- Set some state, then start logout process as normal
			local guid = UnitGUID("player");
			local className, _, _, _, _, characterName, _ = GetPlayerInfoByGUID(guid);
			local level = UnitLevel("player");
			C_Reincarnation.StartReincarnation(guid, characterName, className, level);
			Logout();
		end,
		OnUpdate = function(dialog, elapsed)
			-- If button text is too long, widen out the dialogue
			if (string.len(dialog:GetButton1():GetText()) > 20 or string.len(dialog:GetButton2():GetText()) > 20) then
				local textWidth = math.max(dialog:GetButton1():GetWidth(), dialog:GetButton2():GetWidth())
				if (textWidth > 120) then
					dialog:GetButton1():SetWidth(textWidth);
					dialog:GetButton2():SetWidth(textWidth);
				end
				dialog:SetWidth(420)
			end
			if ( IsFalling() and not IsOutOfBounds()) then
				dialog:GetButton1():Disable();
				dialog:GetButton2():Disable();
				return;
			else
				dialog:GetButton1():Enable();
				dialog:GetButton2():Enable();
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
		OnAccept = function(dialog, data)
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
		OnAccept = function(dialog, data)
			if ( dialog:GetButton1():IsEnabled() ) then
				-- Pass guild lead
				local text = dialog:GetEditBox():GetText();
				C_GuildInfo.SetLeader(text);
				dialog:Hide();
				if (UnitIsDead("player")) then
					StaticPopup_Show("HARDCORE_DEATH");
				end
			end
		end,
		OnUpdate = function(dialog, elapsed)
		end,
		timeout = 0,
		whileDead = 1,
		exclusive = 1,
		showAlert = 1,
		hasEditBox = 1,
		maxLetters = 12,
		notClosableByLogout = 1,
		cancels = "HARDCORE_RECOVER_CORPSE",
		OnShow = function(dialog, data)
			dialog:GetButton1():Disable();
			dialog:GetEditBox():SetFocus();
		end,
		EditBoxOnEnterPressed = function(editBox, data)
			local dialog = editBox:GetParent();
			if ( dialog:GetButton1():IsEnabled() ) then
				-- Pass guild lead
				local text = editBox:GetText();
				C_GuildInfo.SetLeader(text);
				dialog:Hide();
				if (UnitIsDead("player")) then
					StaticPopup_Show("HARDCORE_DEATH");
				end
			end
		end,
		EditBoxOnTextChanged = function(editBox, data)
			local dialog = editBox:GetParent();
			local text = editBox:GetText();
			if (text == "") then
				return
			end
			local playerInSameGuild = C_GuildInfo.MemberExistsByName(text);
			-- Check if this is a player, and if that player is in our guild
			if (playerInSameGuild) then
				dialog:GetButton1():Enable();
			else
				dialog:GetButton1():Disable();
			end
		end,
	};
	StaticPopupDialogs["DUEL_TO_THE_DEATH_REQUESTED"] = {
		text = DUEL_TO_THE_DEATH_REQUESTED,
		button1 = ACCEPT,
		button2 = DECLINE,
		sound = SOUNDKIT.HARDCORE_DUEL,
		OnAccept = function(dialog, data)
			dialog:Hide();
			StaticPopup_Show("DUEL_TO_THE_DEATH_REQUESTED_CONFIRM");
		end,
		OnCancel = function(dialog, data)
			CancelDuel();
		end,
		OnUpdate = function(dialog, elapsed)
			if ( not dialog.linkRegion or not dialog.nextUpdateTime ) then
				return;
			end

			local timeNow = GetTime();
			if ( dialog.nextUpdateTime > timeNow ) then
				return;
			end

			local guid, level = GetDuelerInfo();
			local className, classFilename, _, _, gender, characterName, _ = GetPlayerInfoByGUID(guid);
			dialog.target = characterName;
			GameTooltip:SetOwner(dialog.linkRegion, "ANCHOR_CURSOR_RIGHT");

			if ( className ) then
				dialog.nextUpdateTime = nil; -- The tooltip will be created with valid data, no more updates necessary.

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
				dialog.nextUpdateTime = timeNow + .5;
				GameTooltip:SetText(RETRIEVING_DATA, RED_FONT_COLOR:GetRGB());
			end

			GameTooltip:Show();
		end,
		OnHyperlinkClick = function(dialog, link, text, button)
			-- Target whoever is challenging us.
			if ( button == "LeftButton" and dialog.target ) then
				TargetUnit(dialog.target)
			end
		end,
		OnHyperlinkEnter = function(dialog, link, text, region, boundsLeft, boundsBottom, boundsWidth, boundsHeight)
			dialog.linkRegion = region;
			dialog.linkText = text;
			dialog.nextUpdateTime = GetTime();
			StaticPopupDialogs["DUEL_TO_THE_DEATH_REQUESTED"].OnUpdate(dialog);
		end,
		OnHyperlinkLeave = function(dialog)
			dialog.linkRegion = nil;
			dialog.linkText = nil;
			dialog.nextUpdateTime = nil;
			GameTooltip:Hide();
		end,
		timeout = StaticPopupTimeoutSec,
		hideOnEscape = 1
	};
	StaticPopupDialogs["DUEL_TO_THE_DEATH_REQUESTED_CONFIRM"] = {
		text = DUEL_TO_THE_DEATH_REQUEST_CONFIRM,
		button1 = ACCEPT,
		button2 = DECLINE,
		hasEditBox = 1,
		maxLetters = math.max(12, string.len(HARDCORE_DUEL_CONFIRMATION)),
		wide = true,
		OnAccept = function(dialog, data)
			AcceptDuel();
		end,
		OnCancel = function(dialog, data)
			CancelDuel();
		end,
		EditBoxOnTextChanged = function(editBox, data)
			local dialog = editBox:GetParent();
			if (strupper(editBox:GetText()) == HARDCORE_DUEL_CONFIRMATION) then
				dialog:GetButton1():Enable();
			else
				dialog:GetButton1():Disable();
			end
		end,
		EditBoxOnEscapePressed = function(editBox, data)
			CancelDuel();
			editBox:GetParent():Hide();
		end,
		OnShow = function(dialog, data)
			dialog:GetButton1():Disable();
		end,
		timeout = StaticPopupTimeoutSec,
		hideOnEscape = 1
	};
	StaticPopupDialogs["DUEL_TO_THE_DEATH_CHALLENGE_CONFIRM"] = {
		text = DUEL_TO_THE_DEATH_CHALLENGE_CONFIRM,
		button1 = ACCEPT,
		button2 = DECLINE,
		hasEditBox = 1,
		maxLetters = math.max(12, string.len(HARDCORE_DUEL_CONFIRMATION)),
		wide = true,
		OnAccept = function(dialog, data)
			StartDuel(data.unit, true, true);
		end,
		OnCancel = function(dialog, data)
			-- Duel hasn't started yet
		end,
		EditBoxOnTextChanged = function(editBox, data)
			local dialog = editBox:GetParent();
			if (strupper(editBox:GetText()) == HARDCORE_DUEL_CONFIRMATION) then
				dialog:GetButton1():Enable();
			else
				dialog:GetButton1():Disable();
			end
		end,
		EditBoxOnEscapePressed = function(editBox, data)
			editBox:GetParent():Hide();
		end,
		OnShow = function(dialog, data)
			dialog:GetButton1():Disable();
		end,
		timeout = StaticPopupTimeoutSec,
		hideOnEscape = 1
	};
end

StaticPopupDialogs["UNLEARN_SKILL"] = {
	text = UNLEARN_SKILL,
	button1 = UNLEARN,
	button2 = CANCEL,
	OnAccept = function(dialog, index)
		AbandonSkill(index);
		if TradeSkillFrame then
			HideUIPanel(TradeSkillFrame);
		end
	end,
	timeout = StaticPopupTimeoutSec,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["UNLEARN_SPECIALIZATION"] = {
	text = UNLEARN_SKILL,
	button1 = UNLEARN,
	button2 = CANCEL,
	OnAccept = function(dialog, index)
		UnlearnSpecialization(index);
	end,
	timeout = StaticPopupTimeoutSec,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
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
			dialog:Hide();
		end
	end,
	OnCancel = function(dialog, data)
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
	OnAccept = function(dialog, data)
		if ( data ) then
			dialog:SetFormattedText(CONFIRM_XP_LOSS_AGAIN_NO_DURABILITY, data);
			dialog.data = nil;
			return 1;
		else
			C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.SpiritHealer);
		end
	end,
	OnUpdate = function(dialog, elapsed)
		if ( not C_PlayerInteractionManager.IsValidNPCInteraction(Enum.PlayerInteractionType.SpiritHealer) ) then
			dialog:Hide();
			C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.SpiritHealer);
		end
	end,
	OnCancel = function(dialog, data)
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
	OnAccept = function(dialog, data)
		if ( data ) then
			dialog:SetText(CONFIRM_XP_LOSS_AGAIN_NO_SICKNESS);
			dialog.data = nil;
			return 1;
		else
			 C_PlayerInteractionManager.ConfirmationInteraction(Enum.PlayerInteractionType.SpiritHealer)
		end
	end,
	OnUpdate = function(dialog, elapsed)
		if ( not C_PlayerInteractionManager.IsValidNPCInteraction(Enum.PlayerInteractionType.SpiritHealer) ) then
			C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.SpiritHealer);
			dialog:Hide();
		end
	end,
	OnCancel = function(dialog, data)
		C_GossipInfo.CloseGossip();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
	showAlert = 1,
	hideOnEscape = 1
};

StaticPopupDialogs["INSTANCE_BOOT"].height = 85;

StaticPopupDialogs["CONFIRM_BARBERS_CHOICE"] = {
	text = BARBERS_CHOICE_CONFIRM,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
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
	OnAccept = function(dialog, data)
		ConfirmPetUnlearn();
	end,
	OnUpdate = function(dialog, elapsed)
		if ( not CheckTalentMasterDist() ) then
			dialog:Hide();
		end
	end,
	hasMoneyFrame = 1,
	exclusive = 1,
	timeout = 0,
	hideOnEscape = 1
};

StaticPopupDialogs["CONFIRM_LEAVE_BATTLEFIELD"] = {
	text = CONFIRM_LEAVE_BATTLEFIELD,
	button1 = YES,
	button2 = CANCEL,
	OnShow = function(dialog, data)
		if ( IsActiveBattlefieldArena() and not C_PvP.IsInBrawl() ) then
			dialog:SetText(CONFIRM_LEAVE_ARENA);
		else
			dialog:SetText(CONFIRM_LEAVE_BATTLEFIELD);
		end
	end,
	OnAccept = function(dialog, data)
		LeaveBattlefield();
	end,
	whileDead = 1,
	hideOnEscape = 1,
	showAlert = 1,
}

StaticPopupDialogs["BACKPACK_INCREASE_SIZE"].OnHide = function(dialog, data)
	ContainerFrame_SetBackpackForceExtended(false);
end;

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
		AutoCompleteEditBox_SetAutoCompleteSource(dialog:GetEditBox(), C_Club.GetInvitationCandidates, data.clubId);
		dialog.SubText:SetText(INVITE_COMMUNITY_MEMBER_POPUP_INVITE_SUB_TEXT_BNET_FRIEND);
		dialog:GetEditBox().Instructions:SetText(INVITE_COMMUNITY_MEMBER_POPUP_INVITE_EDITBOX_INSTRUCTIONS);
	end,
	OnHide = function(dialog, data)
		ChatEdit_FocusActiveWindow();
		dialog:GetEditBox():SetText("");
	end,
	EditBoxOnEnterPressed = function(editBox, data)
		editBox:GetParent():GetButton1():Click();
	end,
	EditBoxOnEscapePressed = function(editBox, data)
		editBox:GetParent():Hide();
		ClearCursor();
	end
};

StaticPopupDialogs["INVITE_COMMUNITY_MEMBER_WITH_INVITE_LINK"] = Mixin({
	extraButton = INVITE_COMMUNITY_MEMBER_POPUP_OPEN_INVITE_MANAGER,
	OnExtraButton = function(dialog, data)
		CommunitiesTicketManagerDialog_Open(data.clubId, data.streamId);
	end,
}, StaticPopupDialogs["INVITE_COMMUNITY_MEMBER"]);

do
	local warningSeenBefore = false;
	StaticPopupDialogs["RAF_GRANT_LEVEL_ALLIED_RACE"] = {
		text = LEVEL_GRANT_ALLIED_RACE_WARNING,
		button1 = OKAY,
		button2 = CANCEL,
		OnAccept = function(dialog, data)
			GrantLevel(data);
		end,
		OnShow = function(dialog, data)
			if (not warningSeenBefore) then
				dialog:GetButton1():Disable();
				dialog.timeLeft = 3;
				dialog:GetButton1():SetText(dialog.timeLeft);
				dialog.ticker = C_Timer.NewTicker(1, function()
					dialog.timeLeft = dialog.timeLeft - 1;
					dialog:GetButton1():SetText(dialog.timeLeft);
					if (dialog.timeLeft <= 0) then
						dialog.ticker:Cancel();
						dialog.ticker = nil;
						dialog:GetButton1():SetText(OKAY);
						dialog:GetButton1():Enable();
						warningSeenBefore = true;
					end
				end);
			end
		end,
		OnHide = function(dialog, data)
			if (dialog.ticker) then
				dialog.ticker:Cancel();
				dialog.ticker = nil;
			end
		end,
		showAlert = 1,
		whileDead = 0,
		hideOnEscape = 1,
	}
end

StaticPopupDialogs["REGIONAL_CHAT_DISABLED"].wide = true;

StaticPopupDialogs["REGIONAL_CHAT_DISABLED"].hideOnEscape = 0;

StaticPopupDialogs["ON_BATTLEFIELD_AUTO_QUEUE"] = {
	button1 = JOIN,
	button2 = BATTLEFIELD_GROUP_JOIN,
	button3 = CANCEL,
	selectCallbackByIndex = true,
	OnShow = function(dialog, data)
		dialog:SetText(WORLD_PVP_INVITED_WARMUP:format(GetWorldPVPQueueMapName(true)));
		if ( not IsInGroup() or not UnitIsGroupLeader("player") ) then
			dialog:GetButton2():Disable();
		end
	end,
	OnButton1 = function(dialog, data)
		JoinWorldPVPQueue(true, false);
	end,
	OnButton2 = function(dialog, data, reason)
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
	OnShow = function(dialog, data)
		dialog:SetText(WORLD_PVP_AUTO_QUEUE_EJECT:format(GetWorldPVPQueueMapName(true)));
	end,
	OnButton1 = function(dialog, data)
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
	OnShow = function(dialog, data)
		dialog:SetText(WORLD_PVP_INVITED_WARMUP:format(GetWorldPVPQueueMapName(false)));
		if ( not IsInGroup() or not UnitIsGroupLeader("player") ) then
			dialog:GetButton2():Disable();
		end
	end,
	OnButton1 = function(dialog, data)
		JoinWorldPVPQueue(false, false);
	end,
	OnButton2 = function(dialog, data, reason)
		JoinWorldPVPQueue(false, true);
	end,
	OnButton3 = function(dialog, data)
	end,
	showAlert = 1,
	hideOnEscape = false,
};

StaticPopupDialogs["RAID_PROFILE_DELETION"] = {
	text = CONFIRM_COMPACT_UNIT_FRAME_PROFILE_DELETION,
	button1 = DELETE,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		local newProfile = GetRaidProfileName(1);
		if ( newProfile == data.profile ) then
			newProfile = GetRaidProfileName(2);
		end
		CompactUnitFrameProfiles_ActivateRaidProfile(newProfile);
		DeleteRaidProfile(data.profile);
		data.cbObject:OnDeleted();
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
	OnAccept = function(dialog, data)
		C_BattleNet.InstallHighResTextures();
	end,
};

StaticPopupDialogs["RAID_PROFILE_NEW"] = {
	text = CREATE_NEW_COMPACT_UNIT_FRAME_PROFILE,
	button1 = CREATE,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		local newProfileName = strtrim(dialog:GetEditBox():GetText());
		CompactUnitFrameProfiles_CreateProfile(newProfileName);
		data.cbObject:OnAdded(newProfileName);
	end,
	EditBoxOnTextChanged = StaticPopup_StandardNonEmptyTextHandler,
	EditBoxOnEnterPressed = function(editBox, data)
		local newProfileName = strtrim(editBox:GetText());
		CompactUnitFrameProfiles_CreateProfile(newProfileName);
		data.cbObject:OnAdded(newProfileName);
		editBox:GetParent():Hide();
	end,
	exclusive = 1,
	whileDead = 1,
	hideOnEscape = 1,
	hasEditBox = 1,
	maxLetters = 31
};
