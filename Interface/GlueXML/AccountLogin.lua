function AccountLogin_OnLoad(self)
	local versionType, buildType, version, internalVersion, date = GetBuildInfo();
	self.UI.ClientVersion:SetFormattedText(VERSION_TEMPLATE, versionType, version, internalVersion, buildType, date);

	SetLoginScreenModel(LoginBackgroundModel);
	AccountLogin_UpdateSavedData(self);

	self:RegisterEvent("SCREEN_FIRST_DISPLAYED");
	self:RegisterEvent("LOGIN_STATE_CHANGED");
	self:RegisterEvent("LAUNCHER_LOGIN_STATUS_CHANGED");
	self:RegisterEvent("SHOULD_RECONNECT_TO_REALM_LIST");

	AccountLogin_CheckLoginState(self);
end

function AccountLogin_OnEvent(self, event, ...)
	if ( event == "SCREEN_FIRST_DISPLAYED" ) then
		AccountLogin_Update();
		AccountLogin_CheckAutoLogin();
	elseif ( event == "LOGIN_STATE_CHANGED" ) then
		AccountLogin_CheckLoginState(self);
	elseif ( event == "LAUNCHER_LOGIN_STATUS_CHANGED" ) then
		AccountLogin_Update();
	elseif ( event == "SHOULD_RECONNECT_TO_REALM_LIST" ) then
		C_LoginUI.ReconnectToRealmList();
	end
end

function AccountLogin_CheckLoginState(self)
	local auroraState, connectedToWoW, wowConnectionState, hasRealmList, waitingForRealmList = C_Login.GetState();

	-- account select dialog
	self.UI.WoWAccountSelectDialog:SetShown(auroraState == LE_AURORA_STATE_SELECT_ACCOUNT);

	--captcha
	self.UI.CaptchaEntryDialog:SetShown(auroraState == LE_AURORA_STATE_ENTER_CAPTCHA);

	-- authenticator
	local tokenEntryShown = false;
	if ( auroraState == LE_AURORA_STATE_ENTER_EXTRA_AUTH ) then
		authType = C_Login.GetExtraAuthInfo();
		if ( authType == LE_AUTH_AUTHENTICATOR ) then
			tokenEntryShown = true;
		end
	end

	if ( auroraState == LE_AURORA_STATE_LEGAL_AGREEMENT ) then
		GlueDialog_Show("OKAY_LEGAL_REDIRECT");
	end

	self.UI.TokenEntryDialog:SetShown(tokenEntryShown);
end

function AccountLogin_OnShow(self)
	SetExpansionLogo(self.UI.GameLogo, GetClientDisplayExpansionLevel());
	self.UI.AccountEditBox:SetText("");
	AccountLogin_UpdateSavedData(self);

	AccountLogin_Update();
	AccountLogin_CheckAutoLogin();
end

function AccountLogin_Update()
	local showButtonsAndStuff = true;
    local shouldCheckSystemReqs = true;
	if ( SHOW_KOREAN_RATINGS ) then
		KoreanRatings:Show();
		showButtonsAndStuff = false;
	else
		KoreanRatings:Hide();
	end

	if ( C_Login.IsLauncherLogin() ) then
		ServerAlert_Disable(ServerAlertFrame);
		showButtonsAndStuff = false;
        shouldCheckSystemReqs = false;
	else
		ServerAlert_Enable(ServerAlertFrame);
	end

	EventRegistry:TriggerEvent("AccountLogin.Update", showButtonsAndStuff);

	for _, region in pairs(AccountLogin.UI.NormalLoginRegions) do
		region:SetShown(showButtonsAndStuff);
	end
	if (HIDE_SAVE_ACCOUNT_NAME_CHECKBUTTON) then
		AccountLogin.UI.SaveAccountNameCheckButton:Hide();
	end
	if ( AccountLogin.UI.AccountsDropDown.active ) then
		AccountLogin.UI.AccountsDropDown:SetShown(showButtonsAndStuff);
	end
end

function AccountLogin_UpdateSavedData(self)
	local accountName = GetSavedAccountName();
	if ( accountName == "" ) then
		AccountLogin_FocusAccount();
	else
		self.UI.AccountEditBox:SetText(accountName);
		AccountLogin_FocusPassword();
	end
	if ( GetSavedAccountName() ~= "" and GetSavedAccountList() ~= "" ) then
		AccountLogin.UI.PasswordEditBox:SetPoint("BOTTOM", 0, 255);
		AccountLogin.UI.LoginButton:SetPoint("BOTTOM", 0, 160);
		AccountLogin.UI.AccountsDropDown:Show();
		AccountLogin.UI.AccountsDropDown.active = true;
	else
		AccountLogin.UI.PasswordEditBox:SetPoint("BOTTOM", 0, 275);
		AccountLogin.UI.LoginButton:SetPoint("BOTTOM", 0, 180);
		AccountLogin.UI.AccountsDropDown:Hide();
		AccountLogin.UI.AccountsDropDown.active = false;
	end
	AccountLoginDropDown_SetupList();
end

function AccountLogin_Login()
	C_Login.ClearLastError();
	PlaySound(SOUNDKIT.GS_LOGIN);

	if ( AccountLogin.UI.AccountEditBox:GetText() == "" ) then
		GlueDialog_Show("OKAY", LOGIN_ENTER_NAME);
	elseif ( AccountLogin.UI.PasswordEditBox:GetText() == "" ) then
		GlueDialog_Show("OKAY", LOGIN_ENTER_PASSWORD);
	else
		local username = AccountLogin.UI.AccountEditBox:GetText();
		C_Login.Login(string.gsub(username, "||", "|"), AccountLogin.UI.PasswordEditBox);
		if ( AccountLoginDropDown:IsShown() ) then
			C_Login.SelectGameAccount(UIDropDownMenu_GetSelectedValue(AccountLoginDropDown));
		end
	end

	AccountLogin.UI.PasswordEditBox:SetText("");
	if ( AccountLogin.UI.SaveAccountNameCheckButton:GetChecked() ) then
		SetSavedAccountName(AccountLogin.UI.AccountEditBox:GetText());
	else
		SetSavedAccountName("");
		SetUsesToken(false);
	end
end

function AccountLogin_Exit()
	QuitGame();
end

function AccountLogin_FocusPassword()
	AccountLogin.UI.PasswordEditBox:SetFocus();
end

function AccountLogin_FocusAccount()
	AccountLogin.UI.AccountEditBox:SetFocus();
end

function AccountLogin_OnEditFocusGained(self, userAction)
	if ( userAction ) then
		self:HighlightText();
	end
end

function AccountLogin_OnEditFocusLost(self, userAction)
	self:HighlightText(0, 0);
end

-- =============================================================
-- Account select
-- =============================================================

function WoWAccountSelect_OnLoad(self)
	self.Background.Container.ScrollFrame.offset = 0
end

function WoWAccountSelect_OnShow(self)
	AccountLogin.UI.AccountEditBox:SetFocus();
	AccountLogin.UI.AccountEditBox:ClearFocus();
	self.selectedAccount = 1;
	WoWAccountSelect_Update();
end

function WoWAccountSelectButton_OnClick(self)
	AccountLogin.UI.WoWAccountSelectDialog.selectedAccount = self.index;
	WoWAccountSelect_Update();
end

function WoWAccountSelectButton_OnDoubleClick(self)
	WoWAccountSelect_SelectAccount(self.index);
end

function WoWAccountSelect_SelectAccount(selectedIndex)
	AccountLogin.UI.WoWAccountSelectDialog:Hide();

	local dialog = AccountLogin.UI.WoWAccountSelectDialog;
	C_Login.SelectGameAccount(dialog.gameAccounts[selectedIndex]);
end

function WoWAccountSelect_OnVerticalScroll(self, offset)
	local scrollbar = _G[self:GetName().."ScrollBar"];
	scrollbar:SetValue(offset);
	AccountLogin.UI.WoWAccountSelectDialog.Background.Container.ScrollFrame.offset = floor((offset / ACCOUNTNAME_BUTTON_HEIGHT) + 0.5);
	WoWAccountSelect_Update();
end

function WoWAccountSelect_Update()
	local self = AccountLogin.UI.WoWAccountSelectDialog;
	self.gameAccounts = C_Login.GetGameAccounts();
	local offset = self.Background.Container.ScrollFrame.offset;
	for index=1, MAX_ACCOUNTNAME_DISPLAYED do
		local button = self.Background.Container.Buttons[index];
		local name = self.gameAccounts[index + offset];
		button:SetButtonState("NORMAL");
		button.BGHighlight:Hide();
		if ( name ) then
			button.index = index + offset;
			button:SetText(name);
			button:Show();
			if ( index + offset == self.selectedAccount ) then
				button.BGHighlight:Show();
			end
		else
			button:Hide();
		end
	end

	self.Background:SetSize(275, 265);
	self.Background.AcceptButton:SetPoint("BOTTOMLEFT", 15, 12);
	self.Background.CancelButton:SetPoint("BOTTOMRIGHT", -15, 12);
	self.Background.Container:SetPoint("BOTTOMRIGHT", -16, 36);

	GlueScrollFrame_Update(self.Background.Container.ScrollFrame, #self.gameAccounts, MAX_ACCOUNTNAME_DISPLAYED, ACCOUNTNAME_BUTTON_HEIGHT);
end

function WoWAccountSelect_OnKeyDown(self, key)
	if ( key == "ESCAPE" ) then
		WoWAccountSelect_OnCancel(self);
	elseif ( key == "UP" ) then
		self.selectedAccount = max(1, self.selectedAccount - 1);
		WoWAccountSelect_Update()
	elseif ( key == "DOWN" ) then
		self.selectedAccount = min(#self.gameAccounts, self.selectedAccount + 1);
		WoWAccountSelect_Update()
	elseif ( key == "ENTER" ) then
		WoWAccountSelect_SelectAccount(self.selectedAccount);
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function WoWAccountSelect_OnCancel()
	AccountLogin.UI.WoWAccountSelectDialog:Hide();
	C_Login.DisconnectFromServer();
end

function WoWAccountSelect_OnAccept()
	WoWAccountSelect_SelectAccount(AccountLogin.UI.WoWAccountSelectDialog.selectedAccount);
end

-- =============================================================
-- Accounts dropdown
-- =============================================================

function AccountLoginDropDown_OnLoad(self)
	UIDropDownMenu_SetWidth(self, 174);
	UIDropDownMenu_SetSelectedValue(self, 1);
	AccountLoginDropDownText:SetJustifyH("LEFT");
	AccountLoginDropDown_SetupList();
	UIDropDownMenu_Initialize(self, AccountLoginDropDown_Initialize);
end

function AccountLoginDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(AccountLoginDropDown, self.value);
end

function AccountLoginDropDown_Initialize()
	local selectedValue = UIDropDownMenu_GetSelectedValue(AccountLoginDropDown);
	local list = AccountLoginDropDown.list;
	for i = 1, #list do
		list[i].checked = (list[i].text == selectedValue);
		UIDropDownMenu_AddButton(list[i]);
	end
end

function AccountLoginDropDown_SetupList()
	AccountLoginDropDown.list = {};
	local i = 1;
	for str in string.gmatch(GetSavedAccountList(), "([%w!]+)|?") do
		local selected = false;
		if ( strsub(str, 1, 1) == "!" ) then
			selected = true;
			str = strsub(str, 2, #str);
			UIDropDownMenu_SetSelectedValue(AccountLoginDropDown, str);
			UIDropDownMenu_SetText(AccountLoginDropDown, str);
		end
		AccountLoginDropDown.list[i] = { ["text"] = str, ["value"] = str, ["selected"] = selected, func = AccountLoginDropDown_OnClick };
		i = i + 1;
	end
end

-- =============================================================
-- Token entry
-- =============================================================

function TokenEntry_OnShow(self)
	self.Background.EditBox:SetText("");
	self.Background.EditBox:SetFocus();
end

function TokenEntry_OnHide()
	AccountLogin_FocusPassword();
end

function TokenEntry_OnKeyDown(self, key)
	if ( key == "ENTER" ) then
		TokenEntry_Okay(self);
	elseif ( key == "ESCAPE" ) then
		TokenEntry_Cancel(self);
	end
end

function TokenEntry_Okay(self)
	C_Login.SubmitExtraAuthInfo(AccountLogin.UI.TokenEntryDialog.Background.EditBox:GetText());
	AccountLogin.UI.TokenEntryDialog:Hide();
end

function TokenEntry_Cancel(self)
	AccountLogin.UI.TokenEntryDialog:Hide();
	C_Login.DisconnectFromServer();
end


-- =============================================================
-- Captcha entry
-- =============================================================

function CaptchaEntry_OnShow(self)
	self.Background.EditBox:SetText("");
	self.Background.EditBox:SetFocus();

	local success, width, height = C_Login.SetCaptchaTexture(self.Background.CaptchaImage);
	if ( not success ) then
		C_Login.DisconnectFromServer();
		GlueDialog_Show("OKAY", CAPTCHA_LOADING_FAILED);
		return;
	end

	self.Background.CaptchaImage:SetSize(width, height);
	self.Background:SetWidth(math.max(width + 40, 372));
	self.Background:SetHeight(self.Background.Title:GetTop() - self.Background.OkayButton:GetBottom() + 42);
end

function CaptchaEntry_OnHide()
	AccountLogin_FocusPassword();
end

function CaptchaEntry_OnKeyDown(self, key)
	if ( key == "ENTER" ) then
		CaptchaEntry_Okay(self);
	elseif ( key == "ESCAPE" ) then
		CaptchaEntry_Cancel(self);
	end
end

function CaptchaEntry_Okay(self)
	C_Login.SubmitCaptcha(AccountLogin.UI.CaptchaEntryDialog.Background.EditBox:GetText());
	AccountLogin.UI.CaptchaEntryDialog:Hide();
end

function CaptchaEntry_Cancel(self)
	C_Login.DisconnectFromServer();
end

-- =============================================================
-- Autologin
-- =============================================================

function AccountLogin_StartAutoLoginTimer()
	AccountLogin.timerStarted = true;
	C_Timer.After(AUTO_LOGIN_WAIT_TIME, AccountLogin_OnTimerFinished);
end

function AccountLogin_OnTimerFinished()
	AccountLogin.timerFinished = true;
	AccountLogin_CheckAutoLogin();
end

function AccountLogin_CanAutoLogin()
	return not SHOW_KOREAN_RATINGS and ((C_Login.IsLauncherLogin() and not C_Login.AttemptedLauncherLogin()) or GetKioskLoginInfo()) and AccountLogin:IsVisible();
end

function AccountLogin_CheckAutoLogin()
	if ( AccountLogin_CanAutoLogin() ) then
		if ( AccountLogin.timerFinished ) then
			local accountName, password, realmAddr = GetKioskLoginInfo();
			if (accountName and password) then
				SetKioskAutoRealmAddress(realmAddr);
				AccountLogin.UI.PasswordEditBox:SetText(password);
				C_Login.Login(accountName, AccountLogin.UI.PasswordEditBox);
			else
				C_Login.SetAttemptedLauncherLogin();
				if ( not C_Login.LauncherLogin() ) then
					C_Login.CancelLauncherLogin();
				end
			end
		elseif ( not AccountLogin.timerStarted ) then
			GlueDialog_Show("CANCEL", LOGIN_STATE_CONNECTING);
			if ( WasScreenFirstDisplayed() ) then
				AccountLogin_StartAutoLoginTimer();
			end
		end
	end
end

-- =============================================================
-- Buttons
-- =============================================================

function AccountLogin_ManageAccount()
	PlaySound(SOUNDKIT.GS_LOGIN_NEW_ACCOUNT);
	LaunchURL(AUTH_NO_TIME_URL);
end

function AccountLogin_LaunchCommunitySite()
	PlaySound(SOUNDKIT.GS_LOGIN_NEW_ACCOUNT);
	LaunchURL(COMMUNITY_URL);
end

-- =============================================================
-- Korean Ratings
-- =============================================================

local KOREAN_RATINGS_AUTO_CLOSE_TIMER; -- seconds until automatically closing
function KoreanRatings_OnLoad(self)
	if ( WasScreenFirstDisplayed() ) then
		KoreanRatings_ScreenDisplayed(self);
	else
		self:RegisterEvent("SCREEN_FIRST_DISPLAYED");
	end
end

function KoreanRatings_OnEvent(self, event, ...)
	if ( event == "SCREEN_FIRST_DISPLAYED" ) then
		KoreanRatings_ScreenDisplayed(self);
		self:UnregisterEvent("SCREEN_FIRST_DISPLAYED");
	end
end

function KoreanRatings_ScreenDisplayed(self)
	self:SetScript("OnUpdate", KoreanRatings_OnUpdate);
end

function KoreanRatings_OnShow(self)
	self.locked = true;
	KOREAN_RATINGS_AUTO_CLOSE_TIMER = 3;
	KoreanRatingsText:SetTextHeight(10); -- this is just dumb ... sort out this bug later.
	KoreanRatingsText:SetTextHeight(50);
end

function KoreanRatings_OnUpdate(self, elapsed)
	KOREAN_RATINGS_AUTO_CLOSE_TIMER = KOREAN_RATINGS_AUTO_CLOSE_TIMER - elapsed;
	if ( KOREAN_RATINGS_AUTO_CLOSE_TIMER <= 0 ) then
		SHOW_KOREAN_RATINGS = false;
		AccountLogin_Update();
		AccountLogin_CheckAutoLogin();
	end
end
