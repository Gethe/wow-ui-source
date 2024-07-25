
SHOW_KOREAN_RATINGS = SHOW_KOREAN_RATINGS or nil;
SHOW_CHINA_AGE_APPROPRIATENESS_WARNING = SHOW_CHINA_AGE_APPROPRIATENESS_WARNING or nil;

function ShouldShowRegulationOverlay()
	return SHOW_KOREAN_RATINGS or (SHOW_CHINA_AGE_APPROPRIATENESS_WARNING and not C_Login.WasEverLauncherLogin());
end

local selectedSavedAccount = nil;

AccountLoginEditBoxBehaviorMixin = {}

function AccountLoginEditBoxBehaviorMixin:OnKeyDown(key)
	EventRegistry:TriggerEvent("AccountLogin.OnKeyDown", key);
end

function AccountLogin_OnLoad(self)
	local version, internalVersion, date, _, versionType, buildType = GetBuildInfo();
	self.UI.ClientVersion:SetFormattedText(VERSION_TEMPLATE, versionType, version, internalVersion, buildType, date);

	SetLoginScreenModel(LoginBackgroundModel);
	AccountLogin_UpdateSavedData(self);

	self:RegisterEvent("SCREEN_FIRST_DISPLAYED");
	self:RegisterEvent("LOGIN_STATE_CHANGED");
	self:RegisterEvent("LAUNCHER_LOGIN_STATUS_CHANGED");
	self:RegisterEvent("SHOULD_RECONNECT_TO_REALM_LIST");

	AccountLogin_CheckLoginState(self);

	local year = date:sub(#date - 3, #date);
	self.UI.BlizzDisclaimer:SetText(BLIZZ_DISCLAIMER_FORMAT:format(year));

	self.UI.MenuButton:SetScript("OnClick", GenerateFlatClosure(GlueMenuFrameUtil.ShowMenu));

	local defaultText = nil;
	self.UI.AccountsDropdown:SetWidth(234);

	AccountLoginDropdown_SetupList();
end

function AccountLogin_OnEvent(self, event, ...)
	if ( event == "SCREEN_FIRST_DISPLAYED" ) then
		AccountLogin_Update();
		AccountLogin_CheckAutoLogin();
	elseif ( event == "LOGIN_STATE_CHANGED" ) then
		AccountLogin_CheckLoginState(self);
		AccountLogin_Update();
	elseif ( event == "LAUNCHER_LOGIN_STATUS_CHANGED" ) then
		AccountLogin_Update();
	elseif ( event == "SHOULD_RECONNECT_TO_REALM_LIST" ) then
		ReconnectToRealmList();
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
		local authType = C_Login.GetExtraAuthInfo();
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
	if ( ShouldShowRegulationOverlay() ) then
		showButtonsAndStuff = false;
		if ( SHOW_KOREAN_RATINGS ) then
			KoreanRatings:Show();
		elseif ( SHOW_CHINA_AGE_APPROPRIATENESS_WARNING ) then
			ChinaAgeAppropriatenessWarning:Show();
		end
	else
		KoreanRatings:Hide();
		ChinaAgeAppropriatenessWarning:Hide();
	end

	local isLauncherLogin = C_Login.IsLauncherLogin();
	if ( isLauncherLogin ) then
		showButtonsAndStuff = false;
	end

	local shouldSuppressServerAlert = isLauncherLogin or ShouldShowRegulationOverlay();
	ServerAlertFrame:SetSuppressed(shouldSuppressServerAlert);

	EventRegistry:TriggerEvent("AccountLogin.Update", showButtonsAndStuff);

	local isReconnectMode = C_Login.IsReconnectLoginPossible();
	for _, region in pairs(AccountLogin.UI.NormalLoginRegions) do
		region:SetShown(showButtonsAndStuff);
	end
	for _, region in pairs(AccountLogin.UI.ManualLoginRegions) do
		region:SetShown(showButtonsAndStuff and not isReconnectMode);
	end
	for _, region in pairs(AccountLogin.UI.ReconnectLoginRegions) do
		region:SetShown(showButtonsAndStuff and isReconnectMode);
	end

	if (HIDE_SAVE_ACCOUNT_NAME_CHECKBUTTON) then
		AccountLogin.UI.SaveAccountNameCheckButton:Hide();
	end

	if (GetSavedAccountName() ~= "" and GetSavedAccountList() ~= "" and not isReconnectMode) then
		AccountLogin.UI.PasswordEditBox:SetPoint("TOP", AccountLogin.UI.AccountsDropdown, "BOTTOM", 0, -30);
		AccountLogin.UI.AccountsDropdown:SetShown(showButtonsAndStuff);

		if showButtonsAndStuff then
			-- Account list information may have changed so we need to regenerate the menu.
			AccountLogin.UI.AccountsDropdown:GenerateMenu();
		end
	else
		AccountLogin.UI.PasswordEditBox:SetPoint("TOP", AccountLogin.UI.AccountEditBox, "BOTTOM", 0, -30);
		AccountLogin.UI.AccountsDropdown:Hide();
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

	AccountLoginDropdown_SetupList();
end

function AccountLogin_OnKeyDown(self, key)
	-- Reconnect button isn't an edit box, so can't respond to these on its own.
	if key == "ENTER" then
		local reconnectButton = self.UI.ReconnectLoginButton;
		if reconnectButton:IsShown() and reconnectButton:IsEnabled() and C_Login.IsLoginReady() then
			AccountLogin_ReconnectLogin();
		end
	elseif ( key == "ESCAPE" ) then
		AccountLogin_OnEscapePressed();
	elseif key == "TAB" then
		local switchButton = self.UI.ReconnectSwitchButton;
		if switchButton:IsShown() and switchButton:IsEnabled() then
			AccountLogin_ClearReconnectLogin();
		end
	end

	EventRegistry:TriggerEvent("AccountLogin.OnKeyDown", key);
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
		if ( AccountLogin.UI.AccountsDropdown:IsShown() ) then
			local accountStr = AccountLogin_GetPendingSavedAccountString();
			C_Login.SelectGameAccount(accountStr);
		end
	end

	AccountLogin.UI.PasswordEditBox:SetText("");
	if ( AccountLogin.UI.SaveAccountNameCheckButton:IsControlChecked() ) then
		SetSavedAccountName(AccountLogin.UI.AccountEditBox:GetText());
	else
		SetSavedAccountName("");
		SetUsesToken(false);
	end
end

function AccountLogin_ReconnectLogin()
	C_Login.ClearLastError();
	PlaySound(SOUNDKIT.GS_LOGIN);
	C_Login.ReconnectLogin();
end

function AccountLogin_ClearReconnectLogin()
	C_Login.ClearReconnectLogin();
	AccountLogin_Update();
end

function AccountLogin_OnEscapePressed()
	if GlueParent_IsSecondaryScreenOpen("options") then
		GlueParent_CloseSecondaryScreen();
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

AccountNameMixin = {};

function AccountNameMixin:Init(elementData)
	self:SetText(elementData.name);
	self:SetSelected(elementData.selected);
end

function AccountNameMixin:SetSelected(selected)
	self.BGHighlight:SetShown(selected);
end

function WoWAccountSelect_UpdateSelection(self)
	self.Background.Container.ScrollBox:ForEachFrame(function(button, elementData)
		button:SetSelected(elementData.index == self.selectedAccount);
	end);
end

function WoWAccountSelect_OnLoad(self)
	local view = CreateScrollBoxListLinearView();

	local function Initializer(button, elementData)
		button:Init(elementData);
		button:SetSelected(self.selectedAccount == elementData.index);

		button:SetScript("OnClick", function()
			self.selectedAccount = elementData.index;
			WoWAccountSelect_UpdateSelection(self);
		end);

		button:SetScript("OnDoubleClick", function()
			WoWAccountSelect_SelectAccount(elementData.index);
		end);
	end
	view:SetElementInitializer("AccountNameButtonTemplate", Initializer);

	self.Background.Container.ScrollBox:Init(view);
end

function WoWAccountSelect_OnShow(self)
	AccountLogin.UI.AccountEditBox:SetFocus();
	AccountLogin.UI.AccountEditBox:ClearFocus();
	self.selectedAccount = 1;
	WoWAccountSelect_Update(self);
end

function WoWAccountSelect_SelectAccount(selectedIndex)
	local dialog = AccountLogin.UI.WoWAccountSelectDialog;
	dialog:Hide();

	C_Login.SelectGameAccount(dialog.gameAccounts[selectedIndex]);
end

function WoWAccountSelect_Update(self)
	self.gameAccounts = C_Login.GetGameAccounts();

	local dataProvider = CreateDataProvider();
	for index, name in ipairs(self.gameAccounts) do
		dataProvider:Insert({index = index, name = name});
	end
	self.Background.Container.ScrollBox:SetDataProvider(dataProvider);

	self.Background:SetSize(275, 265);
	self.Background.AcceptButton:SetPoint("BOTTOMLEFT", 15, 12);
	self.Background.CancelButton:SetPoint("BOTTOMRIGHT", -15, 12);
	self.Background.Container:SetPoint("BOTTOMRIGHT", -16, 36);
end

function WoWAccountSelect_OnKeyDown(self, key)
	if ( key == "ESCAPE" ) then
		WoWAccountSelect_OnCancel(self);
	elseif ( key == "UP" ) then
		self.selectedAccount = max(1, self.selectedAccount - 1);
		WoWAccountSelect_UpdateSelection(self);
	elseif ( key == "DOWN" ) then
		self.selectedAccount = min(#self.gameAccounts, self.selectedAccount + 1);
		WoWAccountSelect_UpdateSelection(self);
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

local function AccountLogin_GetSavedAccountList()
	local accounts = {};

	for str in string.gmatch(GetSavedAccountList(), "([%w!]+)|?") do
		local selected = strsub(str, 1, 1) == "!";
		if selected then
			str = strsub(str, 2, #str);
		end

		table.insert(accounts, {str = str, selected = selected});
	end

	return accounts;
end

function AccountLogin_GetPendingSavedAccountString()
	return selectedSavedAccount.str;
end

do
	local function IsSelected(account)
		return selectedSavedAccount and (selectedSavedAccount.str == account.str);
	end

	local function SetSelected(account)
		selectedSavedAccount = account;
	end
	
	function AccountLoginDropdown_SetupList()
		selectedSavedAccount = FindValueInTableIf(AccountLogin_GetSavedAccountList(), function(account)
			return account.selected;
		end);
	
		AccountLogin.UI.AccountsDropdown:SetupMenu(function(dropdown, rootDescription)
			rootDescription:SetTag("MENU_ACCOUNT_LOGIN");

			for index, account in ipairs(AccountLogin_GetSavedAccountList()) do
				rootDescription:CreateRadio(account.str, IsSelected, SetSelected, account);
			end
		end);
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
	return not ShouldShowRegulationOverlay() and ((C_Login.IsLauncherLogin() and not C_Login.AttemptedLauncherLogin()) or Kiosk.GetKioskLoginInfo()) and AccountLogin:IsVisible();
end

function AccountLogin_CheckAutoLogin()
	if ( AccountLogin_CanAutoLogin() ) then
		if ( AccountLogin.timerFinished ) then
			local accountName, password, realmAddr = Kiosk.GetKioskLoginInfo();
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

KoreanRatingsMixin = {};

local KOREAN_RATINGS_AUTO_CLOSE_TIMER; -- seconds until automatically closing
function KoreanRatingsMixin:OnLoad()
	if ( WasScreenFirstDisplayed() ) then
		self:ScreenDisplayed();
	else
		self:RegisterEvent("SCREEN_FIRST_DISPLAYED");
	end
end

function KoreanRatingsMixin:OnEvent(event, ...)
	if ( event == "SCREEN_FIRST_DISPLAYED" ) then
		self:ScreenDisplayed();
		self:UnregisterEvent("SCREEN_FIRST_DISPLAYED");
	end
end

function KoreanRatingsMixin:ScreenDisplayed()
	self:SetScript("OnUpdate", self.OnUpdate);
end

function KoreanRatingsMixin:OnShow()
	self.locked = true;
	KOREAN_RATINGS_AUTO_CLOSE_TIMER = 3;
	KoreanRatingsText:SetTextHeight(10); -- this is just dumb ... sort out this bug later.
	KoreanRatingsText:SetTextHeight(50);
end

function KoreanRatingsMixin:OnUpdate(elapsed)
	KOREAN_RATINGS_AUTO_CLOSE_TIMER = KOREAN_RATINGS_AUTO_CLOSE_TIMER - elapsed;
	if ( KOREAN_RATINGS_AUTO_CLOSE_TIMER <= 0 ) then
		SHOW_KOREAN_RATINGS = false;

		if PhotosensitivityWarningFrame:GetLockedByOtherWarning() then
			KoreanRatings:Hide();
			PhotosensitivityWarningFrame:TryShow();
		else
			AccountLogin_Update();
			AccountLogin_CheckAutoLogin();
		end
	end
end

function ChinaAgeAppropriatenessWarning_Close()
	SHOW_CHINA_AGE_APPROPRIATENESS_WARNING = false;
	if PhotosensitivityWarningFrame:GetLockedByOtherWarning() then
		ChinaAgeAppropriatenessWarning:Hide();
		PhotosensitivityWarningFrame:TryShow();
	else
		AccountLogin_Update();
		AccountLogin_CheckAutoLogin();
	end
end

SaveAccountNameCheckButton = {};

function SaveAccountNameCheckButton:OnLoad()
	ResizeCheckButtonMixin.OnLoad(self);

	self:SetControlChecked(GetSavedAccountName() ~= "");

	local function OnBoxToggled(isChecked, unused_isUserInput)
		if isChecked then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		else
			SetSavedAccountName("");
			ClearSavedAccountList();
			AccountLogin_UpdateSavedData(AccountLogin);
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		end

		AccountLogin_Update();
	end

	self:SetCallback(OnBoxToggled);
end
