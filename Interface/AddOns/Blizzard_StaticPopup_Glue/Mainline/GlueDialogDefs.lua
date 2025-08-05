StaticPopupDialogs["ERROR_CONNECT_TO_EVENT_REALM_FAILED"] = {
	text = ERROR_CONNECT_TO_PLUNDERSTORM_FAILED_DIALOG,
	button1 = OKAY,
	button2 = nil,
};

StaticPopupDialogs["REALM_IS_FULL"].OnCancel = function(dialog, data)
	C_RealmList.ClearRealmList();
	CharacterSelectUtil.ChangeRealm();
end;

StaticPopupDialogs["CONFIRM_PAID_SERVICE"].OnAccept = function(dialog, data)
	-- need to get desired faction in case of pandaren doing faction change to another pandaren
	-- this will be nil in any other case
	local noNPE = false;
	C_CharacterCreation.CreateCharacter(CharacterCreateFrame:GetSelectedName(), 
		noNPE, CharacterCreateFrame:GetCreateCharacterFaction());
end;

StaticPopupDialogs["CONFIRM_PAID_SERVICE"].OnCancel = function(dialog, data)
	CharacterCreateFrame:UpdateForwardButton();
end;

StaticPopupDialogs["CONFIRM_VAS_FACTION_CHANGE"].OnCancel = function(dialog, data)
	CharacterCreateFrame:UpdateForwardButton();
end;

StaticPopupDialogs["QUEUED_WITH_FCM"].OnAccept = function(dialog, data)
	ToggleStoreUI();
end;

StaticPopupDialogs["CHARACTER_BOOST_NO_CHARACTERS_WARNING"].OnAccept = function(dialog, data)
	CharSelectServicesFlowFrame:Hide();
	CharacterSelectUtil.CreateNewCharacter(Enum.CharacterCreateType.Normal);
end;

StaticPopupDialogs["RPE_BOOST_ALLIED_RACE_HERITAGE_ARMOR_WARNING"] = {
	button1 = CONTINUE,
	button2 = CANCEL,
	html = 1,
	OnAccept = function(dialog, data)
		local master = CharacterServicesMaster;
		master.flow:Advance(master);
	end,
	OnCancel = function(dialog, data)
		local master = CharacterServicesMaster;
		master.flow:Restart(master);
	end,
};

StaticPopupDialogs["EVOKER_NEW_PLAYER_WARNING"] = {
	text = EVOKER_NEW_PLAYER_WARNING_TEXT,
	button1 = CHOOSE_DIFF_CLASS,
	button2 = CONTINUE_WITH_EVOKER,
	showAlert = 1,
	alertTopCenterAlign = 1;
	displayVertical = 1,
	buttonTextMargin = 40,
	OnAccept = function(dialog, data)
		SelectOtherRaceAvailable();
	end,
	OnCancel = function(dialog, data)
		StaticPopup_Show("EVOKER_NEW_PLAYER_CONFIRMATION");
	end,
};

StaticPopupDialogs["EVOKER_NEW_PLAYER_CONFIRMATION"] = {
	text = EVOKER_NEW_PLAYER_CONFIRMATION_TEXT,
	button1 = CHARACTER_CREATE_ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	editBoxInstructions = EVOKER_NEW_PLAYER_CONFIRM_INSTRUCTION,
	maxLetters = 32,
	editBoxYMargin = 35,
	EditBoxOnTextChanged = function(editBox, data)
		StaticPopup_StandardConfirmationTextHandler(editBox, ADVANCED_CONFIRM_STRING);
	end,
	OnShow = function(dialog, data)
		dialog:GetButton1():SetEnabled(false);
	end,
	OnCancel = function(dialog, data)
		dialog:GetButton1():SetEnabled(true);
	end,
	OnAccept = function(dialog, data)
		PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_CREATE_NEW);
		CharacterCreateFrame:UpdateMode(1);
	end,
};

StaticPopupDialogs["ADD_FRIEND"] = {
	text = ADD_BATTLENET_FRIEND_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	autoCompleteSource = GetAutoCompleteResults,
	autoCompleteArgs = { AUTOCOMPLETE_LIST.ADDFRIEND.include, AUTOCOMPLETE_LIST.ADDFRIEND.exclude },
	maxLetters = 12 + 1 + 64,
	OnAccept = function(dialog, data)
		local text = dialog:GetText();
		GlueAddFriendAccept(text);
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
		GlueAddFriendAccept(editBox:GetText());
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

StaticPopupDialogs["SWAPPING_ENVIRONMENT"] = {
    text = "SWAPPING_ENVIRONMENT",
    button1 = nil,
    button2 = nil,
    ignoreKeys = true,
    spinner = true,
};

StaticPopupDialogs["ACCOUNT_CONVERSION_DISPLAY"] = {
	text = ACCOUNT_CONVERSION_IN_PROGRESS,
	button1 = nil,
	button2 = nil,
	cover = true,
	ignoreKeys = true,
	spinner = true,
};

StaticPopupDialogs["CREATE_CHARACTER_REALM_CONFIRMATION"] = {
	text = CREATE_CHARACTER_REALM_CONFIRM_DIALOG_TEXT,
	button1 = CONTINUE,
	button2 = CANCEL,
	OnAccept = function(dialog, data)
		if data then
			data();
		end
	end
};

StaticPopupDialogs["ACCOUNT_STORE_BEGIN_PURCHASE_OR_REFUND"] = {
	text = "",
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		local itemInfo = data;
		if itemInfo.status == Enum.AccountStoreItemStatus.Refundable then
			PlaySound(SOUNDKIT.ACCOUNT_STORE_ITEM_REFUND);
			C_AccountStore.RefundItem(itemInfo.id);
		else
			PlaySound(SOUNDKIT.ACCOUNT_STORE_ITEM_PURCHASE);
			C_AccountStore.BeginPurchase(itemInfo.id);
		end
	end
};

StaticPopupDialogs["CONFIRM_DELETE_CHARACTER_GROUP"] = {
	text = CONFIRM_DELETE_CHARACTER_GROUP_TEXT,
	button1 = YES,
	button2 = NO,
	OnAccept = function(dialog, data)
		if data then
			data();
		end
	end,
	cover = true
};