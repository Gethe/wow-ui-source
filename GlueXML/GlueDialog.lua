MAX_NUM_GLUE_DIALOG_BUTTONS = 3;

GlueDialogTypes = { };

GlueDialogTypes["SYSTEM_INCOMPATIBLE_SSE"] = {
	text = SYSTEM_INCOMPATIBLE_SSE,
	button1 = OKAY,
	html = 1,
	showAlert = 1,
	escapeHides = true,
	OnAccept = function ()
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["ERROR_CINEMATIC"] = {
	text = ERROR_CINEMATIC,
	button1 = OKAY,
	button2 = nil,
	OnAccept = function()
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["CANCEL_RESET_SETTINGS"] = {
	text = CANCEL_RESET_SETTINGS,
	button1 = OKAY,
	button2 = CANCEL,
	escapeHides = true,
	OnAccept = function ()
		AccountLoginUIResetFrame:Hide();
		-- Switch the reset settings button back to reset mode
		VideoOptionsFrameReset:SetText(RESET_SETTINGS);
		VideoOptionsFrameReset:SetScript("OnClick", VideoOptionsFrameReset_OnClick_Reset);
		SetClearConfigData(false);
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["RESET_SERVER_SETTINGS"] = {
	text = RESET_SERVER_SETTINGS,
	button1 = OKAY,
	button2 = CANCEL,
	escapeHides = true,
	OnAccept = function ()
		AccountLoginUIResetFrame:Show();
		-- Switch the reset settings button to cancel mode
		VideoOptionsFrameReset:SetText(CANCEL_RESET);
		VideoOptionsFrameReset:SetScript("OnClick", VideoOptionsFrameReset_OnClick_Cancel);
		SetClearConfigData(true);
	end,
	OnCancel = function ()
	end,
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
	OnAlt = function() end,
	escapeHides = true,
}

GlueDialogTypes["CONFIRM_RESET_AUDIO_SETTINGS"] = { 
	text = CONFIRM_RESET_SETTINGS,
	button1 = ALL_SETTINGS,
	button2 = CURRENT_SETTINGS,
	button3 = CANCEL,
	showAlert = 1,
	OnAccept = function ()
		AudioOptionsFrame_SetAllToDefaults();
	end,
	OnCancel = function ()
		AudioOptionsFrame_SetCurrentToDefaults();
	end,
	OnAlt = function() end,
	escapeHides = true,
}

GlueDialogTypes["CLIENT_RESTART_ALERT"] = {
	text = CLIENT_RESTART_ALERT,
	button1 = OKAY,
	showAlert = 1,
}

GlueDialogTypes["REALM_IS_FULL"] = {
	text = REALM_IS_FULL_WARNING,
	button1 = YES,
	button2 = NO,
	showAlert = 1,
	OnAccept = function()
		SetGlueScreen("charselect");
		ChangeRealm(RealmList.selectedCategory , RealmList.currentRealm);
	end,
	OnCancel = function()
		CharacterSelect_ChangeRealm();
	end,
}

GlueDialogTypes["SUGGEST_REALM"] = {
	text = format(SUGGESTED_REALM_TEXT,"UNKNOWN REALM"),
	button1 = ACCEPT,
	button2 = VIEW_ALL_REALMS,
	OnShow = function()
		GlueDialogText:SetFormattedText(SUGGESTED_REALM_TEXT, RealmWizard.suggestedRealmName);
	end,
	OnAccept = function()
		SetGlueScreen("charselect");
		ChangeRealm(RealmWizard.suggestedCategory, RealmWizard.suggestedID);
	end,
	OnCancel = function()
		SetGlueScreen("charselect");
		CharacterSelect_ChangeRealm();
	end,
}

GlueDialogTypes["DISCONNECTED"] = {
	text = DISCONNECTED,
	button1 = OKAY,
	button2 = nil,
	OnShow = function()
		VirtualKeypadFrame:Hide();
		SecurityMatrixLoginFrame:Hide();
		StatusDialogClick();
	end,
	OnAccept = function()
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["PARENTAL_CONTROL"] = {
	text = AUTH_PARENTAL_CONTROL,
	button1 = MANAGE_ACCOUNT,
	button2 = OKAY,
	OnShow = function()
		VirtualKeypadFrame:Hide();
		SecurityMatrixLoginFrame:Hide();
		StatusDialogClick();
	end,
	OnAccept = function()
		LaunchURL(AUTH_NO_TIME_URL);
	end,
	OnCancel = function()
		StatusDialogClick();
	end,
}

GlueDialogTypes["STREAMING_ERROR"] = {
	text = DISCONNECTED,
	button1 = DIALOG_HELP_MORE_INFO,
	button2 = OKAY,
	OnShow = function()
		VirtualKeypadFrame:Hide();
		SecurityMatrixLoginFrame:Hide();
		StatusDialogClick();
	end,
	OnAccept = function()
		LaunchURL(DISCONNECT_STREAMING_ERROR_URL);
	end,
	OnCancel = function()
		StatusDialogClick();
	end,
}

GlueDialogTypes["INVALID_NAME"] = {
	text = CHAR_CREATE_INVALID_NAME,
	button1 = OKAY,
	button2 = nil,
	OnAccept = function()
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["CANCEL"] = {
	text = "",
	button1 = CANCEL,
	button2 = nil,
	OnAccept = function()
		StatusDialogClick();
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["QUEUED_WITH_FCM"] = {
	text = "",
	button1 = CANCEL,
	button2 = QUEUE_FCM_BUTTON,
	OnAccept = function()
		StatusDialogClick();
	end,
	OnCancel = function()
		LaunchURL(QUEUE_FCM_URL)
	end,
}

GlueDialogTypes["OKAY"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
	OnShow = function()
		if ( VirtualKeypadFrame:IsShown() ) then
			VirtualKeypadFrame:Hide();
			CancelLogin();
		end
	end,
	OnAccept = function()
		StatusDialogClick();
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["OKAY_HTML"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
	html = 1,
	OnShow = function()
		if ( VirtualKeypadFrame:IsShown() ) then
			VirtualKeypadFrame:Hide();
			CancelLogin();
		end
	end,
	OnAccept = function()
		StatusDialogClick();
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["OKAY_HTML_EXIT"] = {
	text = "",
	button1 = OKAY,
	button2 = EXIT_GAME,
	html = 1,
	OnShow = function()
		if ( VirtualKeypadFrame:IsShown() ) then
			VirtualKeypadFrame:Hide();
			CancelLogin();
		end
	end,
	OnAccept = function()
		StatusDialogClick();
	end,
	OnCancel = function()
		AccountLogin_Exit();
	end,
}

GlueDialogTypes["CONFIRM_PAID_SERVICE"] = {
	text = CONFIRM_PAID_SERVICE,
	button1 = DONE,
	button2 = CANCEL,
	OnAccept = function()
		-- need to get desired faction in case of pandaren doing faction change to another pandaren
		-- this will be nil in any other case
		CreateCharacter(CharacterCreateNameEdit:GetText(), PandarenFactionButtons_GetSelectedFaction());
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["OKAY_WITH_URL"] = {
	text = "",
	button1 = HELP,
	button2 = OKAY,
	OnAccept = function()
		LaunchURL(_G[GlueDialog.data]);
	end,
	OnCancel = function()
		StatusDialogClick();
	end,
}

GlueDialogTypes["CONNECTION_HELP"] = {
	text = "",
	button1 = HELP,
	button2 = OKAY,
	OnShow = function()
		VirtualKeypadFrame:Hide();
		StatusDialogClick();
	end,
	OnAccept = function()
		AccountLoginUI:Hide();
		ConnectionHelpFrame:Show();
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["CONNECTION_HELP_HTML"] = {
	text = "",
	button1 = HELP,
	button2 = OKAY,
	html = 1,
	OnShow = function()
		VirtualKeypadFrame:Hide();
		StatusDialogClick();
	end,
	OnAccept = function()
		AccountLoginUI:Hide();
		ConnectionHelpFrame:Show();
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["CLIENT_ACCOUNT_MISMATCH"] = {
	button1 = RETURN_TO_LOGIN,
	button2 = EXIT_GAME,
	html = 1,
	OnAccept = function()
		SetGlueScreen("login");
	end,
	OnCancel = function()
		PlaySound("gsTitleQuit");
		QuitGame();
	end,
}

GlueDialogTypes["CLIENT_TRIAL"] = {
	text = CLIENT_TRIAL,
	button1 = RETURN_TO_LOGIN,
	button2 = EXIT_GAME,
	html = 1,
	OnAccept = function()
		SetGlueScreen("login");
	end,
	OnCancel = function()
		PlaySound("gsTitleQuit");
		QuitGame();
	end,
}


GlueDialogTypes["SCANDLL_DOWNLOAD"] = {
	text = "",
	button1 = QUIT,
	button2 = nil,
	OnAccept = function()
		AccountLogin_Exit();
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["SCANDLL_ERROR"] = {
	text = "",
	button1 = SCANDLL_BUTTON_CONTINUEANYWAY,
	button2 = QUIT,
	OnAccept = function()
		GlueDialog:Hide();
		ScanDLLContinueAnyway();
		AccountLoginUI:Show();
	end,
	OnCancel = function()
		-- Opposite semantics
		AccountLogin_Exit();
	end,
}

GlueDialogTypes["SCANDLL_HACKFOUND"] = {
	text = "",
	button1 = SCANDLL_BUTTON_CONTINUEANYWAY,
	button2 = QUIT,
	html = 1,
	showAlert = 1,
	OnAccept = function()
		local formatString = _G["SCANDLL_MESSAGE_"..AccountLogin.hackType.."FOUND_CONFIRM"];
		GlueDialog_Show("SCANDLL_HACKFOUND_CONFIRM", format(formatString, AccountLogin.hackName, AccountLogin.hackURL));
	end,
	OnCancel = function()
		AccountLogin_Exit();
	end,
}

GlueDialogTypes["SCANDLL_HACKFOUND_NOCONTINUE"] = {
	text = "",
	button1 = QUIT,
	button2 = nil,
	html = 1,
	showAlert = 1,
	OnAccept = function()
		AccountLogin_Exit();
	end,
	OnCancel = function()
		AccountLogin_Exit();
	end,
}

GlueDialogTypes["SCANDLL_HACKFOUND_CONFIRM"] = {
	text = "",
	button1 = SCANDLL_BUTTON_CONTINUEANYWAY,
	button2 = QUIT,
	html = 1,
	showAlert = 1,
	OnAccept = function()
		GlueDialog:Hide();
		ScanDLLContinueAnyway();
		AccountLoginUI:Show();
	end,
	OnCancel = function()
		AccountLogin_Exit();
	end,
}

GlueDialogTypes["SERVER_SPLIT"] = {
	text = SERVER_SPLIT,
	button1 = SERVER_SPLIT_SERVER_ONE,
	button2 = SERVER_SPLIT_SERVER_TWO,
	button3 = SERVER_SPLIT_NOT_NOW,
	escapeHides = true;

	OnAccept = function()
		SetStateRequestInfo( 1 );
	end,
	OnCancel = function()
		SetStateRequestInfo( 2 );
	end,
	OnAlt = function()
		SetStateRequestInfo( 0 );
	end,
}

GlueDialogTypes["SERVER_SPLIT_WITH_CHOICE"] = {
	text = SERVER_SPLIT,
	button1 = SERVER_SPLIT_SERVER_ONE,
	button2 = SERVER_SPLIT_SERVER_TWO,
	button3 = SERVER_SPLIT_DONT_CHANGE,
	escapeHides = true;

	OnAccept = function()
		SetStateRequestInfo( 1 );
	end,
	OnCancel = function()
		SetStateRequestInfo( 2 );
	end,
	OnAlt = function()
		SetStateRequestInfo( 0 );
	end,
}

GlueDialogTypes["ACCOUNT_MSG"] = {
	text = "",
	button1 = OKAY,
	button2 = ACCOUNT_MESSAGE_BUTTON_READ,
	html = 1,
	escapeHides = true,

	OnShow = function()
		VirtualKeypadFrame:Hide();
		StatusDialogClick();
	end,
	OnAccept = function()
		ACCOUNT_MSG_NUM_AVAILABLE = ACCOUNT_MSG_NUM_AVAILABLE - 1;
		if ( ACCOUNT_MSG_NUM_AVAILABLE > 0 ) then
			ACCOUNT_MSG_CURRENT_INDEX = AccountMsg_GetIndexNextUnreadMsg(ACCOUNT_MSG_CURRENT_INDEX);
			ACCOUNT_MSG_BODY_LOADED = false;
			AccountMsg_LoadBody( ACCOUNT_MSG_CURRENT_INDEX );
		end
		StatusDialogClick();
	end,
	OnCancel = function()
		AccountMsg_SetMsgRead(ACCOUNT_MSG_CURRENT_INDEX);
		ACCOUNT_MSG_NUM_AVAILABLE = ACCOUNT_MSG_NUM_AVAILABLE - 1;
		if ( ACCOUNT_MSG_NUM_AVAILABLE > 0 ) then
			ACCOUNT_MSG_CURRENT_INDEX = AccountMsg_GetIndexNextUnreadMsg(ACCOUNT_MSG_CURRENT_INDEX);
			ACCOUNT_MSG_BODY_LOADED = false;
			AccountMsg_LoadBody( ACCOUNT_MSG_CURRENT_INDEX );
		end
		StatusDialogClick();
	end,
}

GlueDialogTypes["DECLINE_FAILED"] = {
	text = "",
	button1 = OKAY,
	button2 = nil,
	OnAccept = function()
		DeclensionFrame:Show();
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["REALM_LOCALE_WARNING"] = {
	text = REALM_TYPE_LOCALE_WARNING,
	button1 = OKAY,
	button2 = nil,
	OnAccept = function()
	end,
	OnCancel = function()
	end,
}

GlueDialogTypes["REALM_TOURNAMENT_WARNING"] = {
	text = REALM_TYPE_TOURNAMENT_WARNING,
	button1 = OKAY,
	button2 = nil,
	OnAccept = function()
	end,
	OnCancel = function()
	end,
}

function GlueDialog_Show(which, text, data, errorNumber)
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
	local showTitle = false;
	if ( errorNumber and errorNumber > 0 ) then
		showTitle = true;
		GlueDialogTitle:SetFormattedText(BNET_ERROR_CODE_TITLE, errorNumber);
		GlueDialogTitle:Show();
		glueText:ClearAllPoints();
		glueText:SetPoint("TOP", GlueDialogTitle, "BOTTOM", 0, -16);
	else
		GlueDialogTitle:Hide();
		glueText:ClearAllPoints();
		glueText:SetPoint("TOP", 0, -16);
	end
	
	-- Set the buttons of the dialog
	if ( dialogInfo.button3 ) then
		GlueDialogButton1:ClearAllPoints();
		GlueDialogButton2:ClearAllPoints();
		GlueDialogButton3:ClearAllPoints();
	
		if ( dialogInfo.displayVertical ) then
			GlueDialogButton3:SetPoint("BOTTOM", "GlueDialogBackground", "BOTTOM", 0, 16);
			GlueDialogButton2:SetPoint("BOTTOM", "GlueDialogButton3", "TOP", 0, 0);
			GlueDialogButton1:SetPoint("BOTTOM", "GlueDialogButton2", "TOP", 0, 0);
		else
			GlueDialogButton1:SetPoint("BOTTOMLEFT", "GlueDialogBackground", "BOTTOMLEFT", 60, 16);
			GlueDialogButton2:SetPoint("LEFT", "GlueDialogButton1", "RIGHT", -8, 0);
			GlueDialogButton3:SetPoint("LEFT", "GlueDialogButton2", "RIGHT", -8, 0);
		end

		GlueDialogButton2:SetText(dialogInfo.button2);
		GlueDialogButton2:Show();
		GlueDialogButton3:SetText(dialogInfo.button3);
		GlueDialogButton3:Show();
	elseif ( dialogInfo.button2 ) then
		GlueDialogButton1:ClearAllPoints();
		GlueDialogButton2:ClearAllPoints();
	
		if ( dialogInfo.displayVertical ) then
			GlueDialogButton2:SetPoint("BOTTOM", "GlueDialogBackground", "BOTTOM", 0, 16);
			GlueDialogButton1:SetPoint("BOTTOM", "GlueDialogButton2", "TOP", 0, 0);
		else
			GlueDialogButton1:SetPoint("BOTTOMRIGHT", "GlueDialogBackground", "BOTTOM", -6, 16);
			GlueDialogButton2:SetPoint("LEFT", "GlueDialogButton1", "RIGHT", 13, 0);
		end

		GlueDialogButton2:SetText(dialogInfo.button2);
		GlueDialogButton2:Show();
		GlueDialogButton3:Hide();
	else
		GlueDialogButton1:ClearAllPoints();
		GlueDialogButton1:SetPoint("BOTTOM", "GlueDialogBackground", "BOTTOM", 0, 16);
		GlueDialogButton2:Hide();
		GlueDialogButton3:Hide();
	end

	GlueDialogButton1:SetText(dialogInfo.button1);

	-- Set the miscellaneous variables for the dialog
	GlueDialog.which = which;
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

	-- size the width first
	if( dialogInfo.displayVertical ) then
		GlueDialogBackground:SetWidth(16 + GlueDialogButton1:GetWidth() + 16);
	elseif ( dialogInfo.button3 ) then
		local displayWidth = 45 + GlueDialogButton1:GetWidth() + 8 + GlueDialogButton2:GetWidth() + 8 + GlueDialogButton3:GetWidth() + 45;
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
	
	if ( showTitle ) then
		textHeight = textHeight + GlueDialogTitle:GetHeight() + 16;
	end

	-- now size the dialog box height
	if ( dialogInfo.hasEditBox ) then
		GlueDialogBackground:SetHeight(16 + textHeight + 8 + GlueDialogEditBox:GetHeight() + 8 + GlueDialogButton1:GetHeight() + 16);
	elseif( dialogInfo.displayVertical ) then
		local displayHeight = 16 + textHeight + 8 + GlueDialogButton1:GetHeight() + 16;
		if ( dialogInfo.button2 ) then
			displayHeight = displayHeight + 8 + GlueDialogButton2:GetHeight();
		end
		if ( dialogInfo.button3 ) then
			displayHeight = displayHeight + 8 + GlueDialogButton3:GetHeight();
		end
		GlueDialogBackground:SetHeight(displayHeight);
	else
		GlueDialogBackground:SetHeight(16 + textHeight + 8 + GlueDialogButton1:GetHeight() + 16);
	end
	
	GlueDialog:Show();
end

function GlueDialog_OnLoad(self)
	self:RegisterEvent("OPEN_STATUS_DIALOG");
	self:RegisterEvent("UPDATE_STATUS_DIALOG");
	self:RegisterEvent("CLOSE_STATUS_DIALOG");
	GlueDialogText.origWidth = GlueDialogText:GetWidth();
	GlueDialogBackground.origWidth = GlueDialogBackground:GetWidth();
	GlueDialogBackground.alertWidth = 600;
end

function GlueDialog_OnShow(self)
	local OnShow = GlueDialogTypes[self.which].OnShow;
	if ( OnShow ) then
		OnShow();
	end
end

function GlueDialog_OnUpdate(self, elapsed)
	for i=1, MAX_NUM_GLUE_DIALOG_BUTTONS do
		local button = _G[ "GlueDialogButton"..i ];
		if ( button and (CURRENT_GLUE_SCREEN == "login") or (CURRENT_GLUE_SCREEN == "realmwizard") or CURRENT_GLUE_SCREEN == "movie" ) then
--			button:SetNormalTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Up-Blue");
--			button:SetPushedTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Down-Blue");
--			button:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight-Blue");
			button:SetNormalTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Up");
			button:SetPushedTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Down");
			button:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight");
		else
			button:SetNormalTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Up");
			button:SetPushedTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Down");
			button:SetHighlightTexture("Interface\\Glues\\Common\\Glue-Panel-Button-Highlight");
		end
	end
end

function GlueDialog_OnEvent(self, event, arg1, arg2, arg3, arg4)
	if ( event == "OPEN_STATUS_DIALOG" ) then
		GlueDialog_Show(arg1, arg2, arg3, arg4);
	elseif ( event == "UPDATE_STATUS_DIALOG" and arg1 and (strlen(arg1) > 0) ) then
		GlueDialogText:SetText(arg1);
		local buttonText = nil;
		if ( arg2 ) then
			buttonText = arg2;
		elseif ( GlueDialogTypes[GlueDialog.which] ) then
			buttonText = GlueDialogTypes[GlueDialog.which].button1;
		end
		if ( buttonText ) then
			GlueDialogButton1:SetText(buttonText);
		end
		GlueDialogBackground:SetHeight(32 + GlueDialogText:GetHeight() + 8 + GlueDialogButton1:GetHeight() + 16);
	elseif ( event == "CLOSE_STATUS_DIALOG" ) then
		GlueDialog:Hide();
	end
end

function GlueDialog_OnHide()
--	PlaySound("igMainMenuClose");
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
	PlaySound("gsTitleOptionOK");
end

function GlueDialog_OnKeyDown(key)
	if ( key == "PRINTSCREEN" ) then
		Screenshot();
		return;
	end

	local info = GlueDialogTypes[GlueDialog.which];
	if ( not info or info.ignoreKeys ) then
		return;
	end

	if ( info and info.escapeHides ) then
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
