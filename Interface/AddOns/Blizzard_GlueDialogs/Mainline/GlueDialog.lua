MAX_NUM_GLUE_DIALOG_BUTTONS = 3;

local QUEUED_GLUE_DIALOGS = {};

StaticPopupDialogs = { };


StaticPopupDialogs["OKAY"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
}

StaticPopupDialogs["PAID_SERVICE_IN_PROGRESS"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
}

StaticPopupDialogs["OKAY_HTML_MUST_ACCEPT"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
	explicitAcknowledge = true,
	html = 1,
}

StaticPopupDialogs["OKAY_MUST_ACCEPT"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
	explicitAcknowledge = true,
}

StaticPopupDialogs["CANCEL"] = {
	text = "",
	button1 = CANCEL,
	button2 = nil,
	OnAccept = function()
		C_Login.DisconnectFromServer();
	end,
}

StaticPopupDialogs["OKAY_HTML"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
	html = 1,
}

StaticPopupDialogs["OKAY_WITH_URL"] = {
	text = "",
	button1 = DIALOG_HELP_MORE_INFO,
	button2 = OKAY,
	OnAccept = function()
		LaunchURL(_G[GlueDialog.data]);
	end,
	OnCancel = function()
	end,
}

StaticPopupDialogs["OKAY_WITH_URL_INDEX"] = {
	text = "",
	button1 = DIALOG_HELP_MORE_INFO,
	button2 = OKAY,
	OnAccept = function()
		local urlIndex = GlueDialog.data;
		LoadURLIndex(urlIndex);
	end,
}

StaticPopupDialogs["OKAY_WITH_GENERIC_URL"] = {
	text = "",
	button1 = HELP,
	button2 = OKAY,
	OnAccept = function()
		LaunchURL(BNET_ERROR_GENERIC_URL);
	end,
	OnCancel = function()
	end,
}

StaticPopupDialogs["ERROR_CINEMATIC"] = {
	text = ERROR_CINEMATIC,
	button1 = OKAY,
	button2 = nil,
}

StaticPopupDialogs["ERROR_CONNECT_TO_PLUNDERSTORM_FAILED"] = {
	text = ERROR_CONNECT_TO_PLUNDERSTORM_FAILED_DIALOG,
	button1 = OKAY,
	button2 = nil,
}

StaticPopupDialogs["CLIENT_RESTART_ALERT"] = {
	text = CLIENT_RESTART_ALERT,
	button1 = OKAY,
	showAlert = 1,
}

StaticPopupDialogs["DECLINE_FAILED"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
	OnAccept = function()
		DeclensionFrame:Show();
	end,
}

StaticPopupDialogs["RETRIEVING_CHARACTER_LIST"] = {
	text = CHAR_LIST_RETRIEVING,
	ignoreKeys = true,
	spinner = true,
}

StaticPopupDialogs["CHAR_DELETE_IN_PROGRESS"] = {
	text = CHAR_DELETE_IN_PROGRESS,
	ignoreKeys = true,
	spinner = true,
}

StaticPopupDialogs["REALM_LIST_IN_PROGRESS"] = {
	text = REALM_LIST_IN_PROGRESS,
	ignoreKeys = true,
	button1 = CANCEL,
	button2 = nil,
	OnAccept = function()
		RealmList_OnCancel();
	end,
}

StaticPopupDialogs["OKAY_LEGAL_REDIRECT"] = {
	text = LEGAL_REDIRECT_WARNING,
	button1 = OKAY,
	button2 = nil,
	OnAccept = function ()
		C_Login.DisconnectFromServer();
		LaunchURL(C_Login.GetAgreementLink());
	end,
}

StaticPopupDialogs["REALM_IS_FULL"] = {
	text = REALM_IS_FULL_WARNING,
	button1 = YES,
	button2 = NO,
	showAlert = 1,
	OnAccept = function()
		C_RealmList.ConnectToRealm(RealmList.selectedRealm);
	end,
	OnCancel = function()
		C_RealmList.ClearRealmList();
		CharacterSelectUtil.ChangeRealm();
	end,
}

StaticPopupDialogs["CONFIRM_PAID_SERVICE"] = {
	text = CONFIRM_PAID_SERVICE,
	button1 = DONE,
	button2 = CANCEL,
	OnAccept = function()
		-- need to get desired faction in case of pandaren doing faction change to another pandaren
		-- this will be nil in any other case
		local noNPE = false;
		C_CharacterCreation.CreateCharacter(CharacterCreateFrame:GetSelectedName(), noNPE, CharacterCreateFrame:GetCreateCharacterFaction());
	end,
	OnCancel = function()
		CharacterCreateFrame:UpdateForwardButton();
	end,
}

StaticPopupDialogs["CONFIRM_VAS_FACTION_CHANGE"] = {
	text = CONFIRM_PAID_SERVICE,
	button1 = DONE,
	button2 = CANCEL,
	OnAccept = function()
		CharacterCreateFrame:BeginVASTransaction();
	end,
	OnCancel = function()
		CharacterCreateFrame:UpdateForwardButton();
	end,
}

StaticPopupDialogs["CHARACTER_CREATE_VAS_ERROR"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
	OnAccept = function ()
		if GlueDialog.data then
			CharacterCreateFrame:Exit();
		end
	end,
}

StaticPopupDialogs["REALM_LOCALE_WARNING"] = {
	text = REALM_TYPE_LOCALE_WARNING,
	button1 = OKAY,
	button2 = nil,
}

StaticPopupDialogs["REALM_TOURNAMENT_WARNING"] = {
	text = REALM_TYPE_TOURNAMENT_WARNING,
	button1 = OKAY,
	button2 = nil,
}

StaticPopupDialogs["QUEUED_NORMAL"] = {
	text = "",
	button1 = CHANGE_REALM,
	OnAccept = function()
		C_RealmList.RequestChangeRealmList();
	end,
}

StaticPopupDialogs["QUEUED_WITH_FCM"] = {
	text = "",
	button1 = QUEUE_FCM_BUTTON,
	button2 = CHANGE_REALM,
	darken = true,
	OnAccept = function()
		ToggleStoreUI();
	end,
	OnCancel = function()
		C_RealmList.RequestChangeRealmList();
	end,
}

StaticPopupDialogs["CHARACTER_BOOST_NO_CHARACTERS_WARNING"] = {
	text = CHARACTER_BOOST_NO_CHARACTERS_WARNING_DIALOG_TEXT,
	button1 = CHARACTER_BOOST_NO_CHARACTERS_WARNING_DIALOG_ACCEPT_WARNING,
	button2 = CHARACTER_BOOST_NO_CHARACTERS_WARNING_DIALOG_IGNORE_WARNING,
	displayVertical = true,
	escapeHides = true,

	OnAccept = function ()
		CharSelectServicesFlowFrame:Hide();
		CharacterSelectUtil.CreateNewCharacter(Enum.CharacterCreateType.Normal);
	end,

	OnCancel = function ()
		CharacterUpgradePopup_BeginCharacterUpgradeFlow(GlueDialog.data);
	end,
}

StaticPopupDialogs["CHARACTER_BOOST_FEATURE_RESTRICTED"] = {
	text = "",
	button1 = OKAY,
	escapeHides = true,
};

StaticPopupDialogs["BOOST_NOT_RECOMMEND_SPEC_WARNING"] = {
	text = BOOST_NOT_RECOMMEND_SPEC_WARNING,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		CharacterServicesMaster_Advance();
	end,
	OnCancel = function()
		local master = CharacterServicesMaster;
		master.flow:Rewind(master);
	end,
}

StaticPopupDialogs["BOOST_ALLIED_RACE_HERITAGE_ARMOR_WARNING"] = {
	button1 = CONTINUE,
	button2 = CANCEL,
	html = 1,
	OnAccept = function()
		-- Character select auto advances to spec select.
		CharacterServicesMaster_Update();
	end,
	OnCancel = function()
		local master = CharacterServicesMaster;
		master.flow:Restart(master);
	end,
}

StaticPopupDialogs["RPE_BOOST_ALLIED_RACE_HERITAGE_ARMOR_WARNING"] = {
	button1 = CONTINUE,
	button2 = CANCEL,
	html = 1,
	OnAccept = function()
		local master = CharacterServicesMaster;
		master.flow:Advance(master);
	end,
	OnCancel = function()
		local master = CharacterServicesMaster;
		master.flow:Restart(master);
	end,
}

StaticPopupDialogs["LEGION_PURCHASE_READY"] = {
	text = BLIZZARD_STORE_LEGION_PURCHASE_READY_DESCRIPTION,
	button1 = BLIZZARD_STORE_LOG_OUT_NOW,
	button2 = CANCEL,
	OnAccept = function()
		C_Login.DisconnectFromServer();
	end,
}

StaticPopupDialogs["CONFIGURATION_WARNING"] = {
	button1 = OKAY,
	OnAccept = function()
		C_ConfigurationWarnings.SetConfigurationWarningSeen(GlueDialog.data.configurationWarning);
	end,
	showAlert = 1,
	html = 1,
}

StaticPopupDialogs["SUBSCRIPTION_CHANGED_KICK_WARNING"] = {
	text = TRIAL_UPGRADE_LOGOUT_WARNING,
	button1 = CAMP_NOW,
	OnShow = function()
		AccountReactivate_CloseDialogs();
	end,
	OnAccept = function()
		C_Login.DisconnectFromServer();
	end,
	OnCancel = function()
		C_Login.DisconnectFromServer();
	end,
	OnHide = function()
		C_Login.DisconnectFromServer();
	end,
	OnUpdate = function()
		GlueDialogText:SetText(StaticPopupDialogs["SUBSCRIPTION_CHANGED_KICK_WARNING"].text:format(math.ceil(GlueDialog.timeleft)));
	end,
	timeout = 15,
	cover = true,
	anchorPoint = "CENTER",
	anchorOffsetY = 150,
}

StaticPopupDialogs["EVOKER_NEW_PLAYER_WARNING"] = {
	text = EVOKER_NEW_PLAYER_WARNING_TEXT,
	button1 = CHOOSE_DIFF_CLASS,
	button2 = CONTINUE_WITH_EVOKER,
	showAlert = 1,
	alertTopCenterAlign = 1;
	displayVertical = 1,
	buttonTextMargin = 40,
	OnAccept = function()
		SelectOtherRaceAvailable();
	end,
	OnCancel = function()
		GlueDialog_Show("EVOKER_NEW_PLAYER_CONFIRMATION");
	end,
}

StaticPopupDialogs["EVOKER_NEW_PLAYER_CONFIRMATION"] = {
	text = EVOKER_NEW_PLAYER_CONFIRMATION_TEXT,
	button1 = CHARACTER_CREATE_ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	editBoxInstructions = EVOKER_NEW_PLAYER_CONFIRM_INSTRUCTION,
	maxLetters = 32,
	editBoxYMargin = 35,
	EditBoxOnTextChanged = function(self)
		GlueDialog_StandardConfirmationTextHandler(self, ADVANCED_CONFIRM_STRING);
	end,
	OnShow = function(self)
		GlueDialogButton1:SetEnabled(false);
	end,
	OnCancel = function()
		GlueDialogButton1:SetEnabled(true);
	end,
	OnAccept = function()
		PlaySound(SOUNDKIT.GS_CHARACTER_SELECTION_CREATE_NEW);
		CharacterCreateFrame:UpdateMode(1);
	end,
}

StaticPopupDialogs["ADD_FRIEND"] = {
	text = ADD_BATTLENET_FRIEND_LABEL,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	autoCompleteSource = GetAutoCompleteResults,
	autoCompleteArgs = { AUTOCOMPLETE_LIST.ADDFRIEND.include, AUTOCOMPLETE_LIST.ADDFRIEND.exclude },
	maxLetters = 12 + 1 + 64,
	OnAccept = function(self)
		GlueAddFriendAccept(GlueDialogEditBox:GetText());
	end,
	OnShow = function(self)
		GlueDialogEditBox:SetFocus();
	end,
	OnHide = function(self)
		ChatEdit_FocusActiveWindow();
		GlueDialogEditBox:SetText("");
	end,
	EditBoxOnEnterPressed = function(self)
		GlueAddFriendAccept(GlueDialogEditBox:GetText());
		self:GetParent():Hide();
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide();
	end,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,
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

StaticPopupDialogs["SWAPPING_ENVIRONMENT"] = {
    text = "SWAPPING_ENVIRONMENT",
    button1 = nil,
    button2 = nil,
    ignoreKeys = true,
    spinner = true,
}

StaticPopupDialogs["ACCOUNT_CONVERSION_DISPLAY"] = {
	text = ACCOUNT_CONVERSION_IN_PROGRESS,
	button1 = nil,
	button2 = nil,
	cover = true,
	ignoreKeys = true,
	spinner = true,
}

StaticPopupDialogs["CREATE_CHARACTER_REALM_CONFIRMATION"] = {
	text = CREATE_CHARACTER_REALM_CONFIRM_DIALOG_TEXT,
	button1 = CONTINUE,
	button2 = CANCEL,
	OnAccept = function()
		if GlueDialog.data then
			GlueDialog.data();
		end
	end
}

local function GlueDialog_SetCustomOnHideScript(self, script)
	self.customOnHideScript = script;
end

local function GlueDialog_GetCustomOnHideScript(self)
	return self.customOnHideScript;
end

local function GlueDialog_RunCustomOnHideScript(self)
	local script = GlueDialog_GetCustomOnHideScript(self);
	GlueDialog_SetCustomOnHideScript(self, nil);
	if script then
		script();
	end
end

function GlueDialog_EditBoxOnEnterPressed(self)
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

function GlueDialog_EditBoxOnEscapePressed(self)
	local EditBoxOnEscapePressed = StaticPopupDialogs[self:GetParent().which].EditBoxOnEscapePressed;
	if ( EditBoxOnEscapePressed ) then
		EditBoxOnEscapePressed(self, self:GetParent().data);
	end
end

function GlueDialog_EditBoxOnTextChanged(self, userInput)
	local EditBoxOnTextChanged = StaticPopupDialogs[self:GetParent().which].EditBoxOnTextChanged;
	if ( EditBoxOnTextChanged ) then
		EditBoxOnTextChanged(self, self:GetParent().data);
	end
end

function GlueDialog_StandardConfirmationTextHandler(self, expectedText)
	GlueDialogButton1:SetEnabled(ConfirmationEditBoxMatches(GlueDialogEditBox, expectedText));
end

function GlueDialog_Queue(which, text, data)
	table.insert(QUEUED_GLUE_DIALOGS, {which = which, text = text, data = data});
end

function GlueDialog_CheckQueuedDialogs()
	if #QUEUED_GLUE_DIALOGS > 0 and not GlueDialog:IsShown() then
		GlueDialog_Show(QUEUED_GLUE_DIALOGS[1].which, QUEUED_GLUE_DIALOGS[1].text, QUEUED_GLUE_DIALOGS[1].data);
		table.remove(QUEUED_GLUE_DIALOGS, 1);
	end
end

function GlueDialog_Show(which, text, data, customOnHideScript)
	local dialogInfo = StaticPopupDialogs[which];
	-- Pick a free dialog to use
	if ( GlueDialog:IsShown() ) then
		if ( GlueDialog.which ~= which ) then -- We don't actually want to hide, we just want to redisplay?
			if ( StaticPopupDialogs[GlueDialog.which].OnHide ) then
				StaticPopupDialogs[GlueDialog.which].OnHide();
			end

			GlueDialog_RunCustomOnHideScript(GlueDialog);
			GlueDialog:Hide();
		end
	end

	GlueDialog_SetCustomOnHideScript(GlueDialog, customOnHideScript);

	GlueDialogBackground:ClearAllPoints();
	if dialogInfo.anchorPoint then
		GlueDialogBackground:SetPoint(dialogInfo.anchorPoint, dialogInfo.anchorOffsetX or 0, dialogInfo.anchorOffsetY or 0);
	else
		GlueDialogBackground:SetPoint("CENTER");
	end

	GlueDialog.data = data;
	local glueText;
	if ( dialogInfo.html ) then
		glueText = GlueDialogHTML;
		GlueDialogHTML:Show();
		GlueDialogText:Hide();
	else
		glueText = GlueDialogText;
		GlueDialogHTML:Hide();
		GlueDialogText:Show();
	end

	-- Set the text of the dialog
	if ( text ) then
		glueText:SetText(text);
	else
		glueText:SetText(dialogInfo.text);
	end

	-- set the optional title
	GlueDialogTitle:Hide();
	glueText:ClearAllPoints();
	glueText:SetPoint("TOP", 0, -16);

	-- Set the buttons of the dialog
	if ( dialogInfo.button3 ) then
		GlueDialogButton1:ClearAllPoints();
		GlueDialogButton2:ClearAllPoints();
		GlueDialogButton3:ClearAllPoints();

		if ( dialogInfo.displayVertical ) then
			GlueDialogButton3:SetPoint("BOTTOM", "GlueDialogBackground", "BOTTOM", 0, 25);
			GlueDialogButton2:SetPoint("BOTTOM", "GlueDialogButton3", "TOP", 0, 10);
			GlueDialogButton1:SetPoint("BOTTOM", "GlueDialogButton2", "TOP", 0, 10);
		else
			GlueDialogButton1:SetPoint("BOTTOMLEFT", "GlueDialogBackground", "BOTTOMLEFT", 75, 25);
			GlueDialogButton2:SetPoint("LEFT", "GlueDialogButton1", "RIGHT", 15, 0);
			GlueDialogButton3:SetPoint("LEFT", "GlueDialogButton2", "RIGHT", 15, 0);
		end

		GlueDialogButton1:SetText(dialogInfo.button1);
		GlueDialogButton1:Show();
		GlueDialogButton2:SetText(dialogInfo.button2);
		GlueDialogButton2:Show();
		GlueDialogButton3:SetText(dialogInfo.button3);
		GlueDialogButton3:Show();
	elseif ( dialogInfo.button2 ) then
		GlueDialogButton1:ClearAllPoints();
		GlueDialogButton2:ClearAllPoints();

		if ( dialogInfo.displayVertical ) then
			GlueDialogButton2:SetPoint("BOTTOM", "GlueDialogBackground", "BOTTOM", 0, 25);
			GlueDialogButton1:SetPoint("BOTTOM", "GlueDialogButton2", "TOP", 0, 10);
		else
			GlueDialogButton1:SetPoint("BOTTOMRIGHT", "GlueDialogBackground", "BOTTOM", -6, 25);
			GlueDialogButton2:SetPoint("LEFT", "GlueDialogButton1", "RIGHT", 15, 0);
		end

		GlueDialogButton1:SetText(dialogInfo.button1);
		GlueDialogButton1:Show();
		GlueDialogButton2:SetText(dialogInfo.button2);
		GlueDialogButton2:Show();
		GlueDialogButton3:Hide();
	elseif ( dialogInfo.button1 ) then
		GlueDialogButton1:ClearAllPoints();
		GlueDialogButton1:SetPoint("BOTTOM", "GlueDialogBackground", "BOTTOM", 0, 25);
		GlueDialogButton1:SetText(dialogInfo.button1);
		GlueDialogButton1:Show();
		GlueDialogButton2:Hide();
		GlueDialogButton3:Hide();
	else
		GlueDialogButton1:Hide();
		GlueDialogButton2:Hide();
		GlueDialogButton3:Hide();
	end
	if (dialogInfo.buttonTextMargin) then
		GlueDialogButton1:SetWidth(GlueDialogButton1:GetTextWidth() + dialogInfo.buttonTextMargin);
		GlueDialogButton2:SetWidth(GlueDialogButton2:GetTextWidth() + dialogInfo.buttonTextMargin);
		GlueDialogButton3:SetWidth(GlueDialogButton3:GetTextWidth() + dialogInfo.buttonTextMargin);
	else
		GlueDialogButton1:SetWidth(200);
		GlueDialogButton2:SetWidth(200);
		GlueDialogButton3:SetWidth(200);
	end

	-- Set the miscellaneous variables for the dialog
	GlueDialog.which = which;
	GlueDialog.timeleft = dialogInfo.timeout or 0;
	GlueDialog.data = data;

	-- Show or hide the alert icon
	if ( dialogInfo.showAlert ) then
		GlueDialogBackground:SetWidth(GlueDialogBackground.alertWidth);
		GlueDialogAlertIcon:Show();
	else
		GlueDialogBackground:SetWidth(GlueDialogBackground.origWidth);
		GlueDialogAlertIcon:Hide();
	end
	GlueDialogAlertIcon:ClearAllPoints();
	if ( dialogInfo.alertTopCenterAlign == 1 ) then
		GlueDialogAlertIcon:SetPoint("TOP", 0, -24);
		glueText:ClearAllPoints();
		glueText:SetPoint("TOP", "GlueDialogAlertIcon", "BOTTOM", 0, -12);
	else
		GlueDialogAlertIcon:SetPoint("LEFT", 24, 0);
	end
	GlueDialogText:SetWidth(GlueDialogText.origWidth);

	-- Editbox setup
	if ( dialogInfo.hasEditBox ) then
		GlueDialogEditBox:Show();
		GlueDialogEditBox.Instructions:SetText(dialogInfo.editBoxInstructions or "");

		if ( dialogInfo.maxLetters ) then
			GlueDialogEditBox:SetMaxLetters(dialogInfo.maxLetters);
		end
		if ( dialogInfo.maxBytes ) then
			GlueDialogEditBox:SetMaxBytes(dialogInfo.maxBytes);
		end
		GlueDialogEditBox:SetText("");
		if ( dialogInfo.editBoxWidth ) then
			GlueDialogEditBox:SetWidth(dialogInfo.editBoxWidth);
		else
			GlueDialogEditBox:SetWidth(130);
		end

		GlueDialogEditBox:ClearAllPoints();
		if (dialogInfo.editBoxYMargin) then
			GlueDialogEditBox:SetPoint("TOP", "GlueDialogText", "BOTTOM", 0, -dialogInfo.editBoxYMargin);
		else
			GlueDialogEditBox:SetPoint("CENTER");
		end
	else
		GlueDialogEditBox:Hide();
	end

	-- Spinner setup
	if ( dialogInfo.spinner ) then
		GlueDialogSpinner:Show();

		GlueDialogSpinner:ClearAllPoints();
		if dialogInfo.button1 or dialogInfo.button2 or dialogInfo.button3 then
			GlueDialogSpinner:SetPoint("BOTTOM", 0, 61);
		else
			GlueDialogSpinner:SetPoint("BOTTOM", 0, 23);
		end
	else
		GlueDialogSpinner:Hide();
	end

	GlueDialog_Resize(GlueDialog, which);

	GlueDialog:Show();
end

function GlueDialog_Resize(self, which)
	local dialogInfo = StaticPopupDialogs[which];

	-- Get the width of the text to aid in determining the width of the dialog
	local textWidth = 0;
	if ( dialogInfo.html ) then
		textWidth = select(3, GlueDialogHTML:GetBoundsRect());
	else
		textWidth = GlueDialogText:GetWidth();
	end

	-- size the width first
	if( dialogInfo.displayVertical ) then
		local borderPadding = 32;
		local backgroundWidth = math.max(GlueDialogButton1:GetWidth(), textWidth);
		GlueDialogBackground:SetWidth(backgroundWidth + borderPadding);
	elseif ( dialogInfo.button3 ) then
		local displayWidth = 75 + GlueDialogButton1:GetWidth() + 15 + GlueDialogButton2:GetWidth() + 15 + GlueDialogButton3:GetWidth() + 75;
		GlueDialogBackground:SetWidth(displayWidth);
		GlueDialogText:SetWidth(displayWidth - 40);
	end

	-- Get the height of the string
	local textHeight, _;
	if ( dialogInfo.html ) then
		_,_,_,textHeight = GlueDialogHTML:GetBoundsRect();
	else
		textHeight = GlueDialogText:GetHeight();
	end

	-- now size the dialog box height
	local displayHeight = 16 + textHeight;
	if( dialogInfo.displayVertical ) then
		if ( dialogInfo.button1 ) then
			displayHeight = displayHeight + 25 + GlueDialogButton1:GetHeight() + 25;
			if ( dialogInfo.button2 ) then
				displayHeight = displayHeight + 10 + GlueDialogButton2:GetHeight();
				if ( dialogInfo.button3 ) then
					displayHeight = displayHeight + 10 + GlueDialogButton3:GetHeight();
				end
			end
		end

		if ( dialogInfo.spinner)  then
			displayHeight = displayHeight + GlueDialogSpinner:GetHeight();
		end
	else
		if ( dialogInfo.button1 ) then
			displayHeight = displayHeight + 13 + GlueDialogButton1:GetHeight() + 25;
		else
			displayHeight = displayHeight + 25;
		end

		if ( dialogInfo.hasEditBox ) then
			displayHeight = displayHeight + 13 + GlueDialogEditBox:GetHeight();
			if (dialogInfo.editBoxYMargin) then
				displayHeight = displayHeight + dialogInfo.editBoxYMargin;
			end
			if (dialogInfo.editBoxInstructions) then
				displayHeight = displayHeight + 3 + GlueDialogEditBox.Instructions:GetHeight();
			end
		end

		if ( dialogInfo.spinner)  then
			displayHeight = displayHeight + GlueDialogSpinner:GetHeight();
		end
	end
	if (dialogInfo.alertTopCenterAlign == 1) then
		displayHeight = displayHeight + GlueDialogAlertIcon:GetHeight() + 36;
	end

	GlueDialogBackground:SetHeight(math.floor(displayHeight + 0.5));
end

function GlueDialog_Hide(which, text)
	if ( which ) then
		if ( GlueDialog.which ~= which ) then
			return false;
		end
	end
	if ( text ) then
		if ( GlueDialogText:GetText() ~= text ) then
			return false;
		end
	end
	local dialogInfo = StaticPopupDialogs[GlueDialog.which];
	if ( not which and dialogInfo and dialogInfo.explicitAcknowledge) then
		return false;
	end

	GlueDialog:Hide();
	return true;
end

function GlueDialog_GetVisible()
	return GlueDialog.which;
end

function GlueDialog_OnLoad(self)
	GlueDialogText.origWidth = GlueDialogText:GetWidth();
	GlueDialogBackground.origWidth = GlueDialogBackground:GetWidth();
	GlueDialogBackground.alertWidth = 600;
end

function GlueDialog_OnShow(self)
	self:Raise();
	local OnShow = StaticPopupDialogs[self.which].OnShow;
	if ( OnShow ) then
		OnShow(self, self.data);
	end
	if StaticPopupDialogs[self.which].cover then
		GlueParent_AddModalFrame(GlueDialog);
	end
end

function GlueDialog_OnUpdate(self, elapsed)
	local which = self.which;
	if ( self.timeleft > 0 ) then
		local timeleft = self.timeleft - elapsed;
		if ( timeleft <= 0 ) then
			self.timeleft = 0;
			local OnCancel = StaticPopupDialogs[which].OnCancel;
			if ( OnCancel ) then
				OnCancel();
			end
			self:Hide();
			return;
		end
		self.timeleft = timeleft;
	end

	local OnUpdate = StaticPopupDialogs[which].OnUpdate;
	if ( OnUpdate ) then
		OnUpdate(self, elapsed);
	end
end

function GlueDialog_OnHide(self)
--	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
	GlueParent_RemoveModalFrame(self);

	GlueDialog_RunCustomOnHideScript(self);
end

function GlueDialog_OnClick(self, button, down)
	GlueDialog:Hide();
	local index = self:GetID();
	local info = StaticPopupDialogs[GlueDialog.which]
	local func;
	if ( index == 1 ) then
		func = info.OnAccept or info.OnButton1;
	elseif ( index == 2 ) then
		func = info.OnCancel or info.OnButton2;
	elseif ( index == 3 ) then
		func = info.OnAlt or info.OnButton3;
	end
	if ( func ) then
		local dialog = self:GetParent():GetParent();
		func(dialog, dialog.data);
	end
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end

function GlueDialog_OnKeyDown(self, key)
	if ( key == "PRINTSCREEN" ) then
		Screenshot();
		return;
	end

	local info = StaticPopupDialogs[GlueDialog.which];
	if ( not info or info.ignoreKeys ) then
		return;
	end

	if ( info and info.escapeHides and key == "ESCAPE" ) then
		if ( info.hideSound ) then
			PlaySound(info.hideSound);
		end
		GlueDialog:Hide();
	elseif ( key == "ESCAPE" ) then
		if ( GlueDialogButton2:IsShown() ) then
			GlueDialogButton2:Click();
		else
			GlueDialogButton1:Click();
		end
		if ( info.hideSound ) then
			PlaySound(info.hideSound);
		end
	elseif (key == "ENTER" ) then
		GlueDialogButton1:Click();
		if ( info.hideSound ) then
			PlaySound(info.hideSound);
		end
	end
end

GlueAnnouncementDialogMixin = {}

function GlueAnnouncementDialogMixin:OnCloseClick()
	BaseNineSliceDialogMixin.OnCloseClick(self);
	CharacterSelect_CheckDialogStates();
end
