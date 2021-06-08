MAX_NUM_GLUE_DIALOG_BUTTONS = 3;

local QUEUED_GLUE_DIALOGS = {};

GlueDialogTypes = { };


GlueDialogTypes["OKAY"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
}

GlueDialogTypes["PAID_SERVICE_IN_PROGRESS"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
}

GlueDialogTypes["OKAY_HTML_MUST_ACCEPT"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
	explicitAcknowledge = true,
	html = 1,
}

GlueDialogTypes["OKAY_MUST_ACCEPT"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
	explicitAcknowledge = true,
}

GlueDialogTypes["CANCEL"] = {
	text = "",
	button1 = CANCEL,
	button2 = nil,
	OnAccept = function()
		C_Login.DisconnectFromServer();
	end,
}

GlueDialogTypes["OKAY_HTML"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
	html = 1,
}

GlueDialogTypes["OKAY_WITH_URL"] = {
	text = "",
	button1 = DIALOG_HELP_MORE_INFO,
	button2 = OKAY,
	OnAccept = function()
		LaunchURL(_G[GlueDialog.data]);
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["OKAY_WITH_URL_INDEX"] = {
	text = "",
	button1 = DIALOG_HELP_MORE_INFO,
	button2 = OKAY,
	OnAccept = function()
		local urlIndex = GlueDialog.data;
		LoadURLIndex(urlIndex);
	end,
}

GlueDialogTypes["OKAY_WITH_GENERIC_URL"] = {
	text = "",
	button1 = HELP,
	button2 = OKAY,
	OnAccept = function()
		LaunchURL(BNET_ERROR_GENERIC_URL);
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["ERROR_CINEMATIC"] = {
	text = ERROR_CINEMATIC,
	button1 = OKAY,
	button2 = nil,
}

GlueDialogTypes["CONFIRM_RESET_VIDEO_SETTINGS"] = {
	text = CONFIRM_RESET_SETTINGS,
	button1 = ALL_SETTINGS,
	button2 = CURRENT_SETTINGS,
	button3 = CANCEL,
	showAlert = 1,
	OnAccept = function ()
		VideoOptionsFrame_SetAllToDefaults();
	end,
	OnCancel = function ()
		VideoOptionsFrame_SetCurrentToDefaults();
	end,
	escapeHides = true,
}

GlueDialogTypes["RESET_SERVER_SETTINGS"] = {
	text = RESET_SERVER_SETTINGS,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function ()
		GlueParent.ScreenFrame.OptionsResetFrame:Show();
		-- Switch the reset settings button to cancel mode
		VideoOptionsFrameReset:SetText(CANCEL_RESET);
		VideoOptionsFrameReset:SetScript("OnClick", VideoOptionsFrameReset_OnClick_Cancel);
		SetClearConfigData(true);
	end,
}

GlueDialogTypes["CANCEL_RESET_SETTINGS"] = {
	text = CANCEL_RESET_SETTINGS,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function ()
		GlueParent.ScreenFrame.OptionsResetFrame:Hide();
		-- Switch the reset settings button back to reset mode
		VideoOptionsFrameReset:SetText(RESET_SETTINGS);
		VideoOptionsFrameReset:SetScript("OnClick", VideoOptionsFrameReset_OnClick_Reset);
		SetClearConfigData(false);
	end,
}

GlueDialogTypes["CLIENT_RESTART_ALERT"] = {
	text = CLIENT_RESTART_ALERT,
	button1 = OKAY,
	showAlert = 1,
}

GlueDialogTypes["DECLINE_FAILED"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
	OnAccept = function()
		DeclensionFrame:Show();
	end,
}

GlueDialogTypes["RETRIEVING_CHARACTER_LIST"] = {
	text = CHAR_LIST_RETRIEVING,
	ignoreKeys = true,
	spinner = true,
}

GlueDialogTypes["CHAR_DELETE_IN_PROGRESS"] = {
	text = CHAR_DELETE_IN_PROGRESS,
	ignoreKeys = true,
	spinner = true,
}

GlueDialogTypes["REALM_LIST_IN_PROGRESS"] = {
	text = REALM_LIST_IN_PROGRESS,
	ignoreKeys = true,
	button1 = CANCEL,
	button2 = nil,
	OnAccept = function()
		RealmList_OnCancel();
	end,
}

GlueDialogTypes["OKAY_LEGAL_REDIRECT"] = {
	text = LEGAL_REDIRECT_WARNING,
	button1 = OKAY,
	button2 = nil,
	OnAccept = function ()
		C_Login.DisconnectFromServer();
		LaunchURL(C_Login.GetAgreementLink());
	end,
}

GlueDialogTypes["REALM_IS_FULL"] = {
	text = REALM_IS_FULL_WARNING,
	button1 = YES,
	button2 = NO,
	showAlert = 1,
	OnAccept = function()
		C_RealmList.ConnectToRealm(RealmList.selectedRealm);
	end,
	OnCancel = function()
		C_RealmList.ClearRealmList();
		CharacterSelect_ChangeRealm();
	end,
}

GlueDialogTypes["CONFIRM_PAID_SERVICE"] = {
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

GlueDialogTypes["REALM_LOCALE_WARNING"] = {
	text = REALM_TYPE_LOCALE_WARNING,
	button1 = OKAY,
	button2 = nil,
}

GlueDialogTypes["REALM_TOURNAMENT_WARNING"] = {
	text = REALM_TYPE_TOURNAMENT_WARNING,
	button1 = OKAY,
	button2 = nil,
}

GlueDialogTypes["QUEUED_NORMAL"] = {
	text = "",
	button1 = CHANGE_REALM,
	OnAccept = function()
		C_RealmList.RequestChangeRealmList();
	end,
}

GlueDialogTypes["QUEUED_WITH_FCM"] = {
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

GlueDialogTypes["CHARACTER_BOOST_NO_CHARACTERS_WARNING"] = {
	text = CHARACTER_BOOST_NO_CHARACTERS_WARNING_DIALOG_TEXT,
	button1 = CHARACTER_BOOST_NO_CHARACTERS_WARNING_DIALOG_ACCEPT_WARNING,
	button2 = CHARACTER_BOOST_NO_CHARACTERS_WARNING_DIALOG_IGNORE_WARNING,
	displayVertical = true,
	escapeHides = true,

	OnAccept = function ()
		CharSelectServicesFlowFrame:Hide();
		CharacterSelect_CreateNewCharacter(Enum.CharacterCreateType.Normal);
	end,

	OnCancel = function ()
		CharacterUpgradePopup_BeginCharacterUpgradeFlow(GlueDialog.data);
	end,
}

GlueDialogTypes["CHARACTER_BOOST_FEATURE_RESTRICTED"] = {
	text = "",
	button1 = OKAY,
	escapeHides = true,
};

GlueDialogTypes["BOOST_NOT_RECOMMEND_SPEC_WARNING"] = {
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

GlueDialogTypes["BOOST_ALLIED_RACE_HERITAGE_ARMOR_WARNING"] = {
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

GlueDialogTypes["LEGION_PURCHASE_READY"] = {
	text = BLIZZARD_STORE_LEGION_PURCHASE_READY_DESCRIPTION,
	button1 = BLIZZARD_STORE_LOG_OUT_NOW,
	button2 = CANCEL,
	OnAccept = function()
		C_Login.DisconnectFromServer();
	end,
}

GlueDialogTypes["CONFIGURATION_WARNING"] = {
	button1 = OKAY,
	OnAccept = function()
		C_ConfigurationWarnings.SetConfigurationWarningSeen(GlueDialog.data.configurationWarning);
	end,
	showAlert = 1,
	html = 1,
}

GlueDialogTypes["SUBSCRIPTION_CHANGED_KICK_WARNING"] = {
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
		GlueDialogText:SetText(GlueDialogTypes["SUBSCRIPTION_CHANGED_KICK_WARNING"].text:format(math.ceil(GlueDialog.timeleft)));
	end,
	timeout = 15,
	cover = true,
	anchorPoint = "CENTER",
	anchorOffsetY = 150,
}

function GlueDialog_Queue(which, text, data)
	table.insert(QUEUED_GLUE_DIALOGS, {which = which, text = text, data = data});
end

function GlueDialog_CheckQueuedDialogs()
	if #QUEUED_GLUE_DIALOGS > 0 and not GlueDialog:IsShown() then
		GlueDialog_Show(QUEUED_GLUE_DIALOGS[1].which, QUEUED_GLUE_DIALOGS[1].text, QUEUED_GLUE_DIALOGS[1].data);
		table.remove(QUEUED_GLUE_DIALOGS, 1);
	end
end

function GlueDialog_Show(which, text, data)
	local dialogInfo = GlueDialogTypes[which];
	-- Pick a free dialog to use
	if ( GlueDialog:IsShown() ) then
		if ( GlueDialog.which ~= which ) then -- We don't actually want to hide, we just want to redisplay?
			if ( GlueDialogTypes[GlueDialog.which].OnHide ) then
				GlueDialogTypes[GlueDialog.which].OnHide();
			end

			GlueDialog:Hide();
		end
	end

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
	
	--Show/Hide the disable overlay on the rest of the screen
	GlueDialog.Cover:SetShown(dialogInfo.cover);

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
	GlueDialogText:SetWidth(GlueDialogText.origWidth);

	-- Editbox setup
	if ( dialogInfo.hasEditBox ) then
		GlueDialogEditBox:Show();
		if ( dialogInfo.maxLetters ) then
			GlueDialogEditBox:SetMaxLetters(dialogInfo.maxLetters);
		end
		if ( dialogInfo.maxBytes ) then
			GlueDialogEditBox:SetMaxBytes(dialogInfo.maxBytes);
		end
	else
		GlueDialogEditBox:Hide();
	end

	-- Spinner setup
	if ( dialogInfo.spinner ) then
		GlueDialogSpinner:Show();
	else
		GlueDialogSpinner:Hide();
	end

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
		end

		if ( dialogInfo.spinner)  then
			displayHeight = displayHeight + GlueDialogSpinner:GetHeight();
		end
	end

	GlueDialogBackground:SetHeight(math.floor(displayHeight + 0.5));

	GlueDialog:Show();
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
	local dialogInfo = GlueDialogTypes[GlueDialog.which];
	if ( not which and dialogInfo and dialogInfo.explicitAcknowledge) then
		return false;
	end

	GlueDialog:Hide();
	return true;
end

function GlueDialog_OnLoad(self)
	GlueDialogText.origWidth = GlueDialogText:GetWidth();
	GlueDialogBackground.origWidth = GlueDialogBackground:GetWidth();
	GlueDialogBackground.alertWidth = 600;
end

function GlueDialog_OnShow(self)
	self:Raise();
	local OnShow = GlueDialogTypes[self.which].OnShow;
	if ( OnShow ) then
		OnShow();
	end
end

function GlueDialog_OnUpdate(self, elapsed)
	local which = self.which;
	if ( self.timeleft > 0 ) then
		local timeleft = self.timeleft - elapsed;
		if ( timeleft <= 0 ) then
			self.timeleft = 0;
			local OnCancel = GlueDialogTypes[which].OnCancel;
			if ( OnCancel ) then
				OnCancel();
			end
			self:Hide();
			return;
		end
		self.timeleft = timeleft;
	end
	
	local OnUpdate = GlueDialogTypes[which].OnUpdate;
	if ( OnUpdate ) then
		OnUpdate(elapsed);
	end
end

function GlueDialog_OnHide()
--	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
end

function GlueDialog_OnClick(self, button, down)
	local index = self:GetID();
	GlueDialog:Hide();
	if ( index == 1 ) then
		local OnAccept = GlueDialogTypes[GlueDialog.which].OnAccept;
		if ( OnAccept ) then
			OnAccept();
		end
	elseif ( index == 2 ) then
		local OnCancel = GlueDialogTypes[GlueDialog.which].OnCancel;
		if ( OnCancel ) then
			OnCancel();
		end
	elseif ( index == 3 ) then
		local OnAlt = GlueDialogTypes[GlueDialog.which].OnAlt;
		if ( OnAlt ) then
			OnAlt();
		end
	end
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end

function GlueDialog_OnKeyDown(self, key)
	if ( key == "PRINTSCREEN" ) then
		Screenshot();
		return;
	end

	local info = GlueDialogTypes[GlueDialog.which];
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
