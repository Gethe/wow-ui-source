FADE_IN_TIME = 2;
DEFAULT_TOOLTIP_COLOR = {0.8, 0.8, 0.8, 0.09, 0.09, 0.09};
MAX_PIN_LENGTH = 10;

function AccountLogin_OnLoad(self)
	TOSFrame.noticeType = "EULA";

	self:RegisterEvent("SHOW_SERVER_ALERT");
	self:RegisterEvent("SHOW_SURVEY_NOTIFICATION");
	self:RegisterEvent("CLIENT_ACCOUNT_MISMATCH");
	self:RegisterEvent("CLIENT_TRIAL");
	self:RegisterEvent("SCANDLL_ERROR");
	self:RegisterEvent("SCANDLL_FINISHED");
	self:RegisterEvent("LAUNCHER_LOGIN_STATUS_CHANGED");

	local versionType, buildType, version, internalVersion, date = GetBuildInfo();
	AccountLoginVersion:SetFormattedText(VERSION_TEMPLATE, versionType, version, internalVersion, buildType, date);

	-- Color edit box backdrops
	local backdropColor = DEFAULT_TOOLTIP_COLOR;
	AccountLoginAccountEdit:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3]);
	AccountLoginAccountEdit:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6]);
	AccountLoginPasswordEdit:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3]);
	AccountLoginPasswordEdit:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6]);
	AccountLoginTokenEdit:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3]);
	AccountLoginTokenEdit:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6]);
	TokenEnterDialogBackgroundEdit:SetBackdropBorderColor(backdropColor[1], backdropColor[2], backdropColor[3]);
	TokenEnterDialogBackgroundEdit:SetBackdropColor(backdropColor[4], backdropColor[5], backdropColor[6]);

	SetLoginScreenModel(AccountLogin);
	AccountLogin_UpdateLoginType();
end

function AccountLogin_OnShow(self)	
	AccountLoginLogo:SetTexture(EXPANSION_LOGOS[GetClientDisplayExpansionLevel()]);

	-- special code for BlizzCon
	if (IsBlizzCon()) then
		local account = GetCVar("accountName");
		DefaultServerLogin(account, "blizzcon11");
		AccountLoginUI:Hide();
		return;
	end

	self:SetSequence(0);
	PlayGlueMusic(EXPANSION_GLUE_MUSIC[GetClientDisplayExpansionLevel()]);
	PlayGlueAmbience(GlueAmbienceTracks["DARKPORTAL"], 4.0);

	-- Try to show the EULA or the TOS
	AccountLogin_ShowUserAgreements();
	
	local serverName = GetServerName();
	if(serverName) then
		AccountLoginRealmName:SetText(serverName);
	else
		AccountLoginRealmName:Hide()
	end

	local accountName = GetSavedAccountName();
	
	AccountLoginAccountEdit:SetText(accountName);
	AccountLoginPasswordEdit:SetText("");
	AccountLoginTokenEdit:SetText("");
	--[[if ( accountName and accountName ~= "" and GetUsesToken() ) then
		AccountLoginTokenEdit:Show()
	else
		AccountLoginTokenEdit:Hide()
	end]]
	
	AccountLogin_SetupAccountListDDL();
	
	if ( accountName == "" ) then
		AccountLogin_FocusAccountName();
	else
		AccountLogin_FocusPassword();
	end

	ACCOUNT_MSG_NUM_AVAILABLE = 0;
	ACCOUNT_MSG_PRIORITY = 0;
	ACCOUNT_MSG_HEADERS_LOADED = false;
	ACCOUNT_MSG_BODY_LOADED = false;
	ACCOUNT_MSG_CURRENT_INDEX = nil;
	CHARACTER_SELECT_BACK_FROM_CREATE = false;
	AccountLogin_UpdateLoginType();
end

function AccountLogin_OnHide(self)
	--Stop the sounds from the login screen (like the dragon roaring etc)
	StopAllSFX( 1.0 );
	if ( not AccountLoginSaveAccountName:GetChecked() ) then
		SetSavedAccountList("");
	end
end

function AccountLogin_FocusPassword()
	AccountLoginPasswordEdit:SetFocus();
end

function AccountLogin_FocusAccountName()
	AccountLoginAccountEdit:SetFocus();
end

function AccountLogin_OnKeyDown(key)
	if ( key == "ESCAPE" ) then
		if ( ConnectionHelpFrame:IsShown() ) then
			ConnectionHelpFrame:Hide();
			AccountLoginUI:Show();
		elseif ( SurveyNotificationFrame:IsShown() ) then
			-- do nothing
		else
			AccountLogin_Exit();
		end
	elseif ( key == "ENTER" ) then
		if ( not TOSAccepted() ) then
			return;
		elseif ( TOSFrame:IsShown() or ConnectionHelpFrame:IsShown() ) then
			return;
		elseif ( SurveyNotificationFrame:IsShown() ) then
			AccountLogin_SurveyNotificationDone(1);
		end
		AccountLogin_Login();
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function AccountLogin_OnEvent(event, arg1, arg2, arg3)
	if ( event == "SHOW_SERVER_ALERT" ) then
		ServerAlertText:SetText(arg1);
		ServerAlertFrame:Show();
	elseif ( event == "SHOW_SURVEY_NOTIFICATION" ) then
		AccountLogin_ShowSurveyNotification();
	elseif ( event == "CLIENT_ACCOUNT_MISMATCH" ) then
		local accountExpansionLevel = arg1;
		local installationExpansionLevel = arg2;
		if ( accountExpansionLevel == 1 ) then
			GlueDialog_Show("CLIENT_ACCOUNT_MISMATCH", CLIENT_ACCOUNT_MISMATCH_BC);
		elseif (accountExpansionLevel == 2) then
			GlueDialog_Show("CLIENT_ACCOUNT_MISMATCH", CLIENT_ACCOUNT_MISMATCH_LK);
		else
			GlueDialog_Show("CLIENT_ACCOUNT_MISMATCH", CLIENT_ACCOUNT_MISMATCH_CC);
		end
	elseif ( event == "CLIENT_TRIAL" ) then
		GlueDialog_Show("CLIENT_TRIAL");
	elseif ( event == "SCANDLL_ERROR" ) then
		GlueDialog:Hide();
		ScanDLLContinueAnyway();
		AccountLoginUI:Show();
	elseif ( event == "SCANDLL_FINISHED" ) then
		if ( arg1 == "OK" ) then
			GlueDialog:Hide();
			AccountLoginUI:Show();
		else
			AccountLogin.hackURL = _G["SCANDLL_URL_"..arg1];
			AccountLogin.hackName = arg2;
			AccountLogin.hackType = arg1;
			local formatString = _G["SCANDLL_MESSAGE_"..arg1];
			if ( arg3 == 1 ) then
				formatString = _G["SCANDLL_MESSAGE_HACKNOCONTINUE"];
			end
			local msg = format(formatString, AccountLogin.hackName, AccountLogin.hackURL);
			if ( arg3 == 1 ) then
				GlueDialog_Show("SCANDLL_HACKFOUND_NOCONTINUE", msg);
			else
				GlueDialog_Show("SCANDLL_HACKFOUND", msg);
			end
			PlaySoundFile("Sound\\Creature\\MobileAlertBot\\MobileAlertBotIntruderAlert01.wav");
		end
	elseif ( event == "LAUNCHER_LOGIN_STATUS_CHANGED" ) then
		AccountLogin_UpdateLoginType();
	end
end

function AccountLogin_Login()
	PlaySound("gsLogin");
	DefaultServerLogin(AccountLoginAccountEdit:GetText(), AccountLoginPasswordEdit:GetText());
	AccountLoginPasswordEdit:SetText("");

	if ( AccountLoginSaveAccountName:GetChecked() ) then
		SetSavedAccountName(AccountLoginAccountEdit:GetText());
	else
		SetSavedAccountName("");
		SetUsesToken(false);
	end
end

function AccountLogin_TOS()
	if ( not GlueDialog:IsShown() ) then
		PlaySound("gsLoginNewAccount");
		AccountLoginUI:Hide();
		TOSFrame:Show();
		TOSScrollFrameScrollBar:SetValue(0);		
		TOSScrollFrame:Show();
		TOSFrameTitle:SetText(TOS_FRAME_TITLE);
		TOSText:Show();
		CinematicsFrame:Hide();
	end
end

function AccountLogin_ManageAccount()
	PlaySound("gsLoginNewAccount");
	LaunchURL(AUTH_NO_TIME_URL);
end

function AccountLogin_LaunchCommunitySite()
	PlaySound("gsLoginNewAccount");
	LaunchURL(COMMUNITY_URL);
end

function AccountLogin_Credits()
	CreditsFrame.creditsType = GetClientDisplayExpansionLevel() + 1;	--Expansion levels are off by one from credits indices.
	CreditsFrame.maxCreditsType = GetClientDisplayExpansionLevel() + 1;
	PlaySound("gsTitleCredits");
	SetGlueScreen("credits");
	CinematicsFrame:Hide();
end

function AccountLogin_Cinematics()
	if ( not GlueDialog:IsShown() ) then
		PlaySound("gsLoginNewAccount");
		if ( CinematicsFrame.numMovies > 1 ) then
			CinematicsFrame:Show();
		else
			MovieFrame.version = 1;
			SetGlueScreen("movie");
		end
	end
end

function AccountLogin_Options()
	PlaySound("gsTitleOptions");
	VideoOptionsFrame:Show();
	CinematicsFrame:Hide();
end

function AccountLogin_Exit()
--	PlaySound("gsTitleQuit");
	QuitGame();
end

function AccountLogin_ShowSurveyNotification()
	GlueDialog:Hide();
	AccountLoginUI:Hide();
	SurveyNotificationAccept:Enable();
	SurveyNotificationDecline:Enable();
	SurveyNotificationFrame:Show();
end

function AccountLogin_SurveyNotificationDone(accepted)
	SurveyNotificationFrame:Hide();
	SurveyNotificationAccept:Disable();
	SurveyNotificationDecline:Disable();
	SurveyNotificationDone(accepted);
	AccountLoginUI:Show();
end

function AccountLogin_ShowUserAgreements()
	TOSScrollFrame:Hide();
	EULAScrollFrame:Hide();
	TerminationScrollFrame:Hide();
	ScanningScrollFrame:Hide();
	ContestScrollFrame:Hide();
	TOSText:Hide();
	EULAText:Hide();
	TerminationText:Hide();
	ScanningText:Hide();
	KoreanRatings:Hide();
	if ( not EULAAccepted() ) then
		if ( ShowEULANotice() ) then
			TOSNotice:SetText(EULA_NOTICE);
			TOSNotice:Show();
		end
		AccountLoginUI:Hide();
		TOSFrame.noticeType = "EULA";
		TOSFrameTitle:SetText(EULA_FRAME_TITLE);
		TOSFrameHeader:SetWidth(TOSFrameTitle:GetWidth());
		EULAScrollFrame:Show();
		EULAText:Show();
		TOSFrame:Show();
	elseif ( not TOSAccepted() ) then
		if ( ShowTOSNotice() ) then
			TOSNotice:SetText(TOS_NOTICE);
			TOSNotice:Show();
		end
		AccountLoginUI:Hide();
		TOSFrame.noticeType = "TOS";
		TOSFrameTitle:SetText(TOS_FRAME_TITLE);
		TOSFrameHeader:SetWidth(TOSFrameTitle:GetWidth());
		TOSScrollFrame:Show();
		TOSText:Show();
		TOSFrame:Show();
	elseif ( not TerminationWithoutNoticeAccepted() and SHOW_TERMINATION_WITHOUT_NOTICE_AGREEMENT ) then
		if ( ShowTerminationWithoutNoticeNotice() ) then
			TOSNotice:SetText(TERMINATION_WITHOUT_NOTICE_NOTICE);
			TOSNotice:Show();
		end
		AccountLoginUI:Hide();
		TOSFrame.noticeType = "TERMINATION";
		TOSFrameTitle:SetText(TERMINATION_WITHOUT_NOTICE_FRAME_TITLE);
		TOSFrameHeader:SetWidth(TOSFrameTitle:GetWidth());
		TerminationScrollFrame:Show();
		TerminationText:Show();
		TOSFrame:Show();
	elseif ( not ScanningAccepted() and SHOW_SCANNING_AGREEMENT ) then
		if ( ShowScanningNotice() ) then
			TOSNotice:SetText(SCANNING_NOTICE);
			TOSNotice:Show();
		end
		AccountLoginUI:Hide();
		TOSFrame.noticeType = "SCAN";
		TOSFrameTitle:SetText(SCAN_FRAME_TITLE);
		TOSFrameHeader:SetWidth(TOSFrameTitle:GetWidth());
		ScanningScrollFrame:Show();
		ScanningText:Show();
		TOSFrame:Show();
	elseif ( not ContestAccepted() and SHOW_CONTEST_AGREEMENT ) then
		if ( ShowContestNotice() ) then
			TOSNotice:SetText(CONTEST_NOTICE);
			TOSNotice:Show();
		end
		AccountLoginUI:Hide();
		TOSFrame.noticeType = "CONTEST";
		TOSFrameTitle:SetText(CONTEST_FRAME_TITLE);
		TOSFrameHeader:SetWidth(TOSFrameTitle:GetWidth());
		ContestScrollFrame:Show();
		ContestText:Show();
		TOSFrame:Show();
	elseif (SHOW_KOREAN_RATINGS) then
		AccountLoginUI:Hide();
		TOSFrame:Hide();
		KoreanRatings:Show();
	elseif ( not IsScanDLLFinished() ) then
		AccountLoginUI:Hide();
		TOSFrame:Hide();
		local dllURL = "";
		if ( IsWindowsClient() ) then
			if ( Is64BitClient() ) then
				dllURL = SCANDLL_URL_WIN64_SCAN_DLL;
			else
				dllURL = SCANDLL_URL_WIN32_SCAN_DLL;
			end
		end
		ScanDLLStart(SCANDLL_URL_LAUNCHER_TXT, dllURL);
	else
		AccountLoginUI:Show();
		TOSFrame:Hide();
	end
end

function AccountLogin_UpdateAcceptButton(scrollFrame, isAcceptedFunc, noticeType)
	local scrollbar = _G[scrollFrame:GetName().."ScrollBar"];
	local min, max = scrollbar:GetMinMaxValues();

	-- HACK: scrollbars do not handle max properly
	-- DO NOT CHANGE - without speaking to Mikros/Barris/Thompson
	if (scrollbar:GetValue() >= max - 20) then
		TOSAccept:Enable();
	else
		if ( not isAcceptedFunc() and TOSFrame.noticeType == noticeType ) then
			TOSAccept:Disable();
		end
	end
end																

function AccountLogin_UpdateLoginType()
	if ( IsLauncherLogin() ) then
		AccountLoginNormalLoginFrame:Hide();
		AccountLoginLauncherLoginFrame:Show();

		if ( GetSavedAccountListSSO() ~= "" ) then
			AccountLoginLauncherChangeAccountButton:Show();
			AccountLoginLauncherPlayButton:SetPoint("BOTTOM", AccountLoginLauncherChangeAccountButton, "TOP", 0, 10);
			AccountLoginLauncherLogoutButton:SetPoint("BOTTOM", AccountLoginLauncherLoginFrame, "BOTTOM", 0, 115);
		else
			AccountLoginLauncherChangeAccountButton:Hide();
			AccountLoginLauncherPlayButton:SetPoint("BOTTOM", AccountLoginLauncherLogoutButton, "TOP", 0, 10);
			AccountLoginLauncherLogoutButton:SetPoint("BOTTOM", AccountLoginLauncherLoginFrame, "BOTTOM", 0, 170);
		end
	else
		AccountLoginNormalLoginFrame:Show();
		AccountLoginLauncherLoginFrame:Hide();
	end
end

function ChangedOptionsDialog_OnShow(self)
	if ( not ShowChangedOptionWarnings() ) then
		self:Hide();
		return;
	end

	local options = ChangedOptionsDialog_BuildWarningsString(GetChangedOptionWarnings());
	if ( options == "" ) then
		self:Hide();
		return;
	end

	-- set text
	ChangedOptionsDialogText:SetText(options);

	-- resize the background to fit the text
	local textHeight = ChangedOptionsDialogText:GetHeight();
	local titleHeight = ChangedOptionsDialogTitle:GetHeight();
	local buttonHeight = ChangedOptionsDialogOkayButton:GetHeight();
	ChangedOptionsDialogBackground:SetHeight(26 + titleHeight + 16 + textHeight + 8 + buttonHeight + 16);
	self:Raise();
end

function ChangedOptionsDialog_OnKeyDown(self,key)
	if ( key == "PRINTSCREEN" ) then
		Screenshot();
		return;
	end

	if ( key == "ESCAPE" or key == "ENTER" ) then
		ChangedOptionsDialogOkayButton:Click();
	end
end

function ChangedOptionsDialog_BuildWarningsString(...)
	local options = "";
	for i=1, select("#", ...) do
		if ( i == 1 ) then
			options = select(1, ...);
		else
			options = options.."\n\n"..select(i, ...);
		end
	end
	return options;
end

-- Virtual keypad functions
function VirtualKeypadFrame_OnEvent(event, ...)
	if ( event == "PLAYER_ENTER_PIN" ) then
		for i=1, 10 do
			_G["VirtualKeypadButton"..i]:SetText(select(i,...));
		end							
	end
	-- Randomize location to prevent hacking (yeah right)
	local xPadding = 5;
	local yPadding = 10;
	local xPos = random(xPadding, GlueParent:GetWidth()-VirtualKeypadFrame:GetWidth()-xPadding);
	local yPos = random(yPadding, GlueParent:GetHeight()-VirtualKeypadFrame:GetHeight()-yPadding);
	VirtualKeypadFrame:SetPoint("TOPLEFT", GlueParent, "TOPLEFT", xPos, -yPos);
	
	VirtualKeypadFrame:Show();
	VirtualKeypad_UpdateButtons();
end

function VirtualKeypadButton_OnClick(self)
	local text = VirtualKeypadText:GetText();
	if ( not text ) then
		text = "";
	end
	VirtualKeypadText:SetText(text.."*");
	VirtualKeypadFrame.PIN = VirtualKeypadFrame.PIN..self:GetID();
	VirtualKeypad_UpdateButtons();
end

function VirtualKeypadOkayButton_OnClick()
	local PIN = VirtualKeypadFrame.PIN;
	local numNumbers = strlen(PIN);
	local pinNumber = {};
	for i=1, MAX_PIN_LENGTH do
		if ( i <= numNumbers ) then
			pinNumber[i] = strsub(PIN,i,i);
		else
			pinNumber[i] = nil;
		end
	end
	PINEntered(pinNumber[1] , pinNumber[2], pinNumber[3], pinNumber[4], pinNumber[5], pinNumber[6], pinNumber[7], pinNumber[8], pinNumber[9], pinNumber[10]);
	VirtualKeypadFrame:Hide();
end

function VirtualKeypad_UpdateButtons()
	local numNumbers = strlen(VirtualKeypadFrame.PIN);
	if ( numNumbers >= 4 and numNumbers <= MAX_PIN_LENGTH ) then
		VirtualKeypadOkayButton:Enable();
	else
		VirtualKeypadOkayButton:Disable();
	end
	if ( numNumbers == 0 ) then
		VirtualKeypadBackButton:Disable();
	else
		VirtualKeypadBackButton:Enable();
	end
	if ( numNumbers >= MAX_PIN_LENGTH ) then
		for i=1, MAX_PIN_LENGTH do
			_G["VirtualKeypadButton"..i]:Disable();
		end
	else
		for i=1, MAX_PIN_LENGTH do
			_G["VirtualKeypadButton"..i]:Enable();
		end
	end
end

-- TOKEN SYSTEM
function TokenEntryOkayButton_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTER_TOKEN");
end

function TokenEntryOkayButton_OnEvent(self, event)
	if (event == "PLAYER_ENTER_TOKEN") then
		if ( AccountLoginSaveAccountName:GetChecked() ) then
			if ( GetUsesToken() ) then
				if ( AccountLoginTokenEdit:GetText() ~= "" ) then
					TokenEntered(AccountLoginTokenEdit:GetText());
					AccountLoginTokenEdit:SetText("");
					return;
				end
			else
				SetUsesToken(true);
			end
		end
		self:Show();
	end
end

function TokenEntryOkayButton_OnShow()
	TokenEnterDialogBackgroundEdit:SetText("");
	TokenEnterDialogBackgroundEdit:SetFocus();
end

function TokenEntryOkayButton_OnHide()
	if ( accountName == "" ) then
		AccountLogin_FocusAccountName();
	else
		AccountLogin_FocusPassword();
	end
end

function TokenEntryOkayButton_OnKeyDown(self, key)
	if ( key == "ENTER" ) then
		TokenEntry_Okay(self);
	elseif ( key == "ESCAPE" ) then
		TokenEntry_Cancel(self);
	end
end

function TokenEntry_Okay(self)
	TokenEntered(TokenEnterDialogBackgroundEdit:GetText());
	TokenEnterDialog:Hide();
end

function TokenEntry_Cancel(self)
	TokenEnterDialog:Hide();
	CancelLogin();
end

-- WOW Account selection
function WoWAccountSelect_OnLoad(self)
	self:RegisterEvent("GAME_ACCOUNTS_UPDATED");
	self:RegisterEvent("OPEN_STATUS_DIALOG");
	WoWAccountSelectDialogBackgroundContainerScrollFrame.offset = 0
	CURRENT_SELECTED_WOW_ACCOUNT = 1;
end

function WoWAccountSelect_OnShow (self)
	AccountLoginAccountEdit:SetFocus();
	AccountLoginAccountEdit:ClearFocus();
	CURRENT_SELECTED_WOW_ACCOUNT = 1;
	WoWAccountSelect_Update();
end

function WoWAccountSelectButton_OnClick(self)
	CURRENT_SELECTED_WOW_ACCOUNT = self:GetID();
	WoWAccountSelect_Update();
end

function WoWAccountSelectButton_OnDoubleClick(self)
	WoWAccountSelect_SelectAccount(self:GetID());
end

function WoWAccountSelect_OnEvent(self, event)
	if ( event == "GAME_ACCOUNTS_UPDATED" ) then
		if ( IsLauncherLogin() ) then
			--Construct the account list
			local str = WoWAccountSelect_GetAccountList(nil);

			local accountList = GetSavedAccountListSSO();
			--If the constructed list doesn't match our old one, we're no longer saving
			if ( str == string.gsub(accountList, "!", "") ) then
				--Figure out which index is selected
				local idx;
				local list = {string.split("|", accountList)};
				for k = 1, #list do
					local v = list[k];
					if ( string.sub(v, 1, 1) == "!" ) then
						idx = k;
					end
				end

				if ( idx ) then
					WoWAccountSelect_SelectAccount(idx);
					return;
				end
			end
				
			self:Show();
		else
			local str, selectedIndex, selectedName = ""
			for i = 1, GetNumGameAccounts() do
				local name = GetGameAccountInfo(i);
				if ( name == GlueDropDownMenu_GetText(AccountLoginDropDown) ) then
					selectedName = name;
					selectedIndex = i;
				end
				str = str .. name .. "|";
			end
			
			if ( str == string.gsub(GetSavedAccountList(), "!", "") and selectedIndex ) then
				WoWAccountSelect_SelectAccount(selectedIndex);
				return;
			else
				self:Show();
			end
		end
	else
		self:Hide();
	end
end

function WoWAccountSelect_SelectAccount(selectedIndex)
	if ( IsLauncherLogin() ) then
		if ( WoWAccountSelectDialogBackgroundSaveAccountButton:GetChecked() ) then
			local str = WoWAccountSelect_GetAccountList(selectedIndex);
			SetSavedAccountListSSO(str);
		else
			SetSavedAccountListSSO("");
		end
	else
		if ( AccountLoginSaveAccountName:GetChecked() ) then
			local str = WoWAccountSelect_GetAccountList(selectedIndex);
			SetSavedAccountList(str);
		else
			SetSavedAccountList("");
		end
	end
	WoWAccountSelectDialog:Hide();
	SetGameAccount(selectedIndex);
end

function WoWAccountSelect_GetAccountList(selectedIndex)
	local count = GetNumGameAccounts();
	
	local str = ""
	for i = 1, count do
		local name = GetGameAccountInfo(i);
		if ( i == selectedIndex ) then
			str = str .. "!" .. name .. "|";
		else
			str = str .. name .. "|";
		end
	end
	return str;
end

ACCOUNTNAME_BUTTON_HEIGHT = 20;

function WoWAccountSelect_OnVerticalScroll (self, offset)
	local scrollbar = _G[self:GetName().."ScrollBar"];
	scrollbar:SetValue(offset);
	WoWAccountSelectDialogBackgroundContainerScrollFrame.offset = floor((offset / ACCOUNTNAME_BUTTON_HEIGHT) + 0.5);
	WoWAccountSelect_Update();
end

MAX_ACCOUNTS_DISPLAYED = 8;
function WoWAccountSelect_Update()
    local count = GetNumGameAccounts();
	
	local offset = WoWAccountSelectDialogBackgroundContainerScrollFrame.offset;
	for index=1, MAX_ACCOUNTS_DISPLAYED do
		local button = _G["WoWAccountSelectDialogBackgroundContainerButton" .. index];
		local name, regionID = GetGameAccountInfo(index + offset);
		button:SetButtonState("NORMAL");
		button.BG_Highlight:Hide();
		if ( name ) then
			button:SetID(index + offset);
			button:SetText(name);
			button.regionID = regionID;
			button:Show();
			if ( index == CURRENT_SELECTED_WOW_ACCOUNT) then
				button.BG_Highlight:Show();
			end
		else
			button:Hide();
		end
	end

	local offset = 0;
	if ( IsLauncherLogin() ) then
		offset = 20;
		WoWAccountSelectDialogBackgroundSaveAccountButton:Show();
		WoWAccountSelectDialogBackgroundSaveAccountText:Show();
	else
		WoWAccountSelectDialogBackgroundSaveAccountButton:Hide();
		WoWAccountSelectDialogBackgroundSaveAccountText:Hide();
	end
	WoWAccountSelectDialogBackground:SetSize(275, 265 + offset);
	WoWAccountSelectDialogBackgroundAcceptButton:SetPoint("BOTTOMLEFT", 8, 6 + offset);
	WoWAccountSelectDialogBackgroundCancelButton:SetPoint("BOTTOMRIGHT", -8, 6 + offset);
	WoWAccountSelectDialogBackgroundContainer:SetPoint("BOTTOMRIGHT", -16, 36 + offset);
	
	GlueScrollFrame_Update(WoWAccountSelectDialogBackgroundContainerScrollFrame, count, MAX_ACCOUNTS_DISPLAYED, ACCOUNTNAME_BUTTON_HEIGHT);
end

function WoWAccountSelect_AccountButton_OnClick(self, button)
	CURRENT_SELECTED_WOW_ACCOUNT = self:GetID();
	WoWAccountSelect_Accept();
end

function WoWAccountSelect_OnKeyDown(self, key)
	if ( key == "ESCAPE" ) then
		WoWAccountSelect_OnCancel(self);
	elseif ( key == "UP" ) then
		CURRENT_SELECTED_WOW_ACCOUNT = max(1, CURRENT_SELECTED_WOW_ACCOUNT - 1);
		WoWAccountSelect_Update()
	elseif ( key == "DOWN" ) then
		CURRENT_SELECTED_WOW_ACCOUNT = min(GetNumGameAccounts(), CURRENT_SELECTED_WOW_ACCOUNT + 1);
		WoWAccountSelect_Update()
	elseif ( key == "ENTER" ) then
		WoWAccountSelect_SelectAccount(CURRENT_SELECTED_WOW_ACCOUNT);
	elseif ( key == "PRINTSCREEN" ) then
		Screenshot();
	end
end

function WoWAccountSelect_OnCancel (self)
	self:Hide();
	GlueDialog:Hide();
	CancelLogin();
end

function WoWAccountSelect_Accept()
	WoWAccountSelect_SelectAccount(CURRENT_SELECTED_WOW_ACCOUNT);
end

function AccountLoginDropDown_OnClick(self)
	GlueDropDownMenu_SetSelectedValue(AccountLoginDropDown, self.value);
end

function AccountLoginDropDown_Initialize()
	local selectedValue = GlueDropDownMenu_GetSelectedValue(AccountLoginDropDown);
	local info;

	for i = 1, #AccountList do
		AccountList[i].checked = (AccountList[i].text == selectedValue);
		GlueDropDownMenu_AddButton(AccountList[i]);
	end
end

AccountList = {};
function AccountLogin_SetupAccountListDDL()
	if ( GetSavedAccountName() ~= "" and GetSavedAccountList() ~= "" ) then
		AccountLoginPasswordEdit:SetPoint("BOTTOM", 0, 255);
		AccountLoginLoginButton:SetPoint("BOTTOM", 0, 150);
		AccountLoginDropDown:Show();
	else
		AccountLoginPasswordEdit:SetPoint("BOTTOM", 0, 275);
		AccountLoginLoginButton:SetPoint("BOTTOM", 0, 170);
		AccountLoginDropDown:Hide();
		return;
	end
	
	AccountList = {};
	local i = 1;
	for str in string.gmatch(GetSavedAccountList(), "([%w!]+)|?") do
		local selected = false;
		if ( strsub(str, 1, 1) == "!" ) then
			selected = true;
			str = strsub(str, 2, #str);
			GlueDropDownMenu_SetSelectedName(AccountLoginDropDown, str);
			GlueDropDownMenu_SetText(AccountLoginDropDown, str);
		end
		AccountList[i] = { ["text"] = str, ["value"] = str, ["selected"] = selected, func = AccountLoginDropDown_OnClick };
		i = i + 1;
	end
end

function CinematicsFrame_OnLoad(self)
	CinematicsFrame.numMovies = GetClientDisplayExpansionLevel() + 1;
	local button;
	local height = 80;
	for i = 1, CinematicsFrame.numMovies do
		button = _G["CinematicsButton"..i];
		if ( not button ) then
			break;
		end
		button:Show();
		height = height + button:GetHeight() + 8;
	end
	CinematicsFrame:SetHeight(height);
end

function CinematicsFrame_IsMovieListLocal(id)
	local movieList = MovieList[id];
	if (not movieList) then return false; end
	for _, movieId in ipairs(movieList) do
		if (not IsMovieLocal(movieId)) then 
			return false;
		end
	end
	return true;
end

function CinematicsFrame_IsMovieListPlayable(id)
	local movieList = MovieList[id];
	if (not movieList) then return false; end
	for _, movieId in ipairs(movieList) do
		if (not IsMoviePlayable(movieId)) then 
			return false;
		end
	end
	return true;
end

function CinematicsFrame_GetMovieDownloadProgress(id)
	local movieList = MovieList[id];
	if (not movieList) then return; end
	
	local anyInProgress = false;
	local allDownloaded = 0;
	local allTotal = 0;
	for _, movieId in ipairs(movieList) do
		local inProgress, downloaded, total = GetMovieDownloadProgress(movieId);
		anyInProgress = anyInProgress or inProgress;
		allDownloaded = allDownloaded + downloaded;
		allTotal = allTotal + total;
	end
	
	return anyInProgress, allDownloaded, allTotal;
end

function CinematicsButton_Update(self)
	local movieId = self:GetID();
	if (CinematicsFrame_IsMovieListLocal(movieId)) then
		self:GetNormalTexture():SetDesaturated(nil);
		self:GetPushedTexture():SetDesaturated(nil);
		self.PlayButton:Show();
		self.DownloadIcon:Hide();
		self.StreamingIcon:Hide();
		self.StatusBar:Hide();
		self:SetScript("OnUpdate", nil);
		self.isLocal = true;
	else
		local inProgress, downloaded, total = CinematicsFrame_GetMovieDownloadProgress(movieId);
		local isPlayable = CinematicsFrame_IsMovieListPlayable(movieId);
		
		-- HACK - When you pause the download, sometimes the progress will appear to rewind temporarily (bug with the API?)
		-- This ensures that the progress bar never goes backwards
		downloaded = max(downloaded, self.downloaded or 0);
		
		self.inProgress = inProgress;
		self.downloaded = downloaded;
		self.total = total;
		self.isLocal = false;
		self.isPlayable = isPlayable;
		
		if (inProgress or (downloaded/total) > 0.1) then
			self.StatusBar:SetMinMaxValues(0, total);
			self.StatusBar:SetValue(downloaded);
			self.StatusBar:Show();
		else 
			self.StatusBar:Hide();
		end

		if (isPlayable and inProgress) then
			self:GetNormalTexture():SetDesaturated(nil);
			self:GetPushedTexture():SetDesaturated(nil);
			self.PlayButton:Show();
			self.DownloadIcon:Hide();
			self.StreamingIcon:Hide();
			self.StatusBar:SetStatusBarColor(0, 0.8, 0);
			self:SetScript("OnUpdate", CinematicsButton_Update);
		elseif (inProgress) then
			self:GetNormalTexture():SetDesaturated(1);
			self:GetPushedTexture():SetDesaturated(1);
			self.PlayButton:Hide();
			self.DownloadIcon:Hide();
			self.StreamingIcon:Show();
			self.StreamingIcon.Loop:Play();
			self.StatusBar:SetStatusBarColor(0, 0.8, 0);
			self:SetScript("OnUpdate", CinematicsButton_Update);
		else
			self:GetNormalTexture():SetDesaturated(1);
			self:GetPushedTexture():SetDesaturated(1);
			self.PlayButton:Hide();
			self.DownloadIcon:Show();
			self.StreamingIcon:Hide();
			self.StatusBar:SetStatusBarColor(0.6, 0.6, 0.6);
			self:SetScript("OnUpdate", nil);
		end
	end
	
	if (self.mouseIsOverMe) then
		CinematicsButton_OnEnter(self);
	end
end

function CinematicsFrame_OnShow(self)
	for i = 1, CinematicsFrame.numMovies do
		local button = _G["CinematicsButton"..i];
		if ( not button ) then
			break;
		end
		button:Show();
		CinematicsButton_Update(button);
	end
end

function CinematicsFrame_OnKeyDown(key)
	if ( key == "PRINTSCREEN" ) then
		Screenshot();
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
		CinematicsFrame:Hide();
	end	
end

function CinematicsButton_OnClick(self)
	if (self.isLocal or (self.inProgress and self.isPlayable)) then
		CinematicsFrame:Hide();
		PlaySound("gsTitleOptionOK");
		MovieFrame.version = self:GetID();
		MovieFrame.showError = true;
		SetGlueScreen("movie");
	else
		local inProgress, downloaded, total = CinematicsFrame_GetMovieDownloadProgress(self:GetID());
		if (inProgress) then
			local movieList = MovieList[self:GetID()];
			if (movieList) then
				for _, movieId in ipairs(movieList) do
					if (not IsMovieLocal(movieId)) then 
						CancelPreloadingMovie(movieId);
					end
				end
			end
		else
			local movieList = MovieList[self:GetID()];
			if (movieList) then
				for _, movieId in ipairs(movieList) do
					if (not IsMovieLocal(movieId)) then 
						PreloadMovie(movieId);
					end
				end
			end
		end
		CinematicsButton_Update(self);
	end
end

function CinematicsButton_OnEnter(self)
	self.mouseIsOverMe = true;
	if (self.isLocal or (self.inProgress and self.isPlayable)) then
		GlueTooltip:Hide();
	else
		if (self.inProgress) then
			GlueTooltip:SetText(format(CINEMATIC_DOWNLOADING, self.downloaded/self.total*100));
			GlueTooltip:AddLine(CINEMATIC_DOWNLOADING_DETAILS, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1, true);
			GlueTooltip:AddLine(CINEMATIC_CLICK_TO_PAUSE, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		else
			GlueTooltip:SetText(CINEMATIC_UNAVAILABLE);
			GlueTooltip:AddLine(CINEMATIC_UNAVAILABLE_DETAILS, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1, true);
			GlueTooltip:AddLine(CINEMATIC_CLICK_TO_DOWNLOAD, GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		end
		
		GlueTooltip:SetOwner(self);
		GlueTooltip:Show();
	end
end

KOREAN_RATINGS_TIMER = 3; -- seconds it needs to display
function KoreanRatings_OnShow(self)
	AccountLoginUI:Hide();
	KOREAN_RATINGS_TIMER = 3 + LOGIN_FADE_IN;
	self.locked = true;
	KoreanRatingsOK:Disable();
	KoreanRatingsText:SetTextHeight(10); -- this is just dumb ... sort out this bug later.
	KoreanRatingsText:SetTextHeight(50);
end
function KoreanRatings_OnUpdate(self, elapsed)
	KOREAN_RATINGS_TIMER = KOREAN_RATINGS_TIMER - elapsed;
	if ( KOREAN_RATINGS_TIMER <= 0 ) then
		self.locked = false;
			KoreanRatingsOK:Enable();
	end	
end
function KoreanRatings_UserInput(self)
	if ( not self.locked ) then
		SHOW_KOREAN_RATINGS = false;
		AccountLogin_ShowUserAgreements();
	end
end
