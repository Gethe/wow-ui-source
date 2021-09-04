
function OpenCommunitiesSettingsDialog(clubId)
	CommunitiesSettingsDialog:SetClubId(clubId);
	CommunitiesSettingsDialog:UpdatedPostingInformationInit();
end

function CloseCommunitiesSettingsDialog()
	CommunitiesSettingsDialog:Hide();
end

CommunitiesSettingsDialogMixin = {}

function CommunitiesSettingsDialogMixin:UpdatedPostingInformationInit()
	self:RegisterEvent("CLUB_FINDER_RECRUITMENT_POST_RETURNED"); 
	if (self.clubId and self:GetClubType() == Enum.ClubType.Character) then 
		if(C_ClubFinder.RequestPostingInformationFromClubId(self.clubId)) then 
			self.waitingForResponseToShow = true;
		else 
			self:OnUpdatedPostingInformationRecieved();
		end 
	else 
		self:OnUpdatedPostingInformationRecieved();
	end
end 

function CommunitiesSettingsDialogMixin:OnUpdatedPostingInformationRecieved() 
	self:UnregisterEvent("CLUB_FINDER_RECRUITMENT_POST_RETURNED"); 
	self.waitingForResponseToShow = false; 
	if(not self:IsShown()) then 
		self:Show();
	end
end 

function CommunitiesSettingsDialogMixin:OnLoad()
	self.LookingForDropdown:Initialize(); 
	self.ClubFocusDropdown:Initialize(); 
	self.LanguageDropdown:Initialize(); 
	self.ClubFocusDropdown.Label:SetFontObject(GameFontNormal);
	UIDropDownMenu_SetWidth(self.LookingForDropdown, 150);
	UIDropDownMenu_SetWidth(self.ClubFocusDropdown, 150);
	UIDropDownMenu_SetWidth(self.LanguageDropdown, 150);
	UIDropDownMenu_Initialize(self.LookingForDropdown, LookingForClubDropdownInitialize); 
	UIDropDownMenu_Initialize(self.ClubFocusDropdown, ClubFocusClubDropdownInitialize); 
	UIDropDownMenu_Initialize(self.LanguageDropdown, ClubFinderLanguageDropdownInitialize);
	UIDropDownMenu_JustifyText(self.LookingForDropdown, "LEFT");
	UIDropDownMenu_JustifyText(self.ClubFocusDropdown, "LEFT");
	UIDropDownMenu_JustifyText(self.LanguageDropdown, "LEFT");
end

function CommunitiesSettingsDialogMixin:OnShow()
	local clubType = self:GetClubType();
	if clubType == Enum.ClubType.BattleNet then
		self.DialogLabel:SetText(COMMUNITIES_SETTINGS_LABEL);
	else
		self.DialogLabel:SetText(COMMUNITIES_SETTINGS_CHARACTER_LABEL);
	end

	local clubId = self:GetClubId()
	local myMemberInfo = C_Club.GetMemberInfoForSelf(clubId);
	local isProperRecruitingRole =  myMemberInfo and  myMemberInfo.role and (myMemberInfo.role == Enum.ClubRoleIdentifier.Owner or myMemberInfo.role == Enum.ClubRoleIdentifier.Leader);
	local isPostingBanned = C_ClubFinder.IsPostingBanned(clubId); 
	local shouldShowFinderOptions = C_ClubFinder.IsEnabled() and clubType == Enum.ClubType.Character and isProperRecruitingRole and C_ClubFinder.GetClubFinderDisableReason() == nil and not isPostingBanned;  
	self:HideOrShowCommunityFinderOptions(shouldShowFinderOptions);

	if (clubType == Enum.ClubType.Character) then 
		self:UpdateSettingsInfoFromClubInfo(); 
	end
	self:SetDisabledStateOnCommunityFinderOptions(not self.ShouldListClub.Button:GetChecked()); 

	HelpTip:Acknowledge(CommunitiesFrame, CLUB_FINDER_TUTORIAL_POSTING);
	HelpTip:Acknowledge(CommunitiesFrame, CLUB_FINDER_TUTORIAL_LANGUAGE_FILTER);

	self:RegisterEvent("CLUB_FINDER_POST_UPDATED");
	
	CommunitiesFrame:RegisterDialogShown(self);

end

function CommunitiesSettingsDialogMixin:OnHide() 
	self:UnregisterEvent("CLUB_FINDER_POST_UPDATED");
	self:UnregisterEvent("CLUB_FINDER_RECRUITMENT_POST_RETURNED"); 
end

function CommunitiesSettingsDialogMixin:OnEvent(event, ...)
	if (event == "CLUB_FINDER_POST_UPDATED") then 
		self:Hide(); 
	elseif (event == "CLUB_FINDER_RECRUITMENT_POST_RETURNED") then 
		if(self.waitingForResponseToShow) then 
			self:OnUpdatedPostingInformationRecieved();
		end
	end		
end

function CommunitiesSettingsDialogMixin:SetClubId(clubId)
	local clubInfo = C_Club.GetClubInfo(clubId);
	if clubInfo then
		self.clubId = clubId;
		self.clubType = clubInfo.clubType;
		self.IconPreviewRing:SetAtlas(self.clubType == Enum.ClubType.BattleNet and "communities-ring-blue" or "communities-ring-gold");
		self:SetAvatarId(clubInfo.avatarId);
		self.NameEdit:SetText(clubInfo.name);
		self.ShortNameEdit:SetText(clubInfo.shortName or "");
		self.Description.EditBox:SetText(clubInfo.description);
		self.Description.EditBox.Instructions:SetText(self.clubType == Enum.ClubType.BattleNet and COMMUNITIES_CREATE_DIALOG_DESCRIPTION_INSTRUCTIONS_BATTLE_NET or COMMUNITIES_CREATE_DIALOG_DESCRIPTION_INSTRUCTIONS);
		self.MessageOfTheDay.EditBox:SetText(clubInfo.broadcast);

		local clubPostingInfo = C_ClubFinder.GetRecruitingClubInfoFromClubID(clubId);
		if (clubPostingInfo) then
			self.clubPostingInfo = clubPostingInfo;
			-- TODO: Setup the UI to mirror the clubPostingInfo
		end
	end
end

function CommunitiesSettingsDialogMixin:GetClubId()
	return self.clubId;
end

function CommunitiesSettingsDialogMixin:GetClubType()
	return self.clubType;
end

function CommunitiesSettingsDialogMixin:SetAvatarId(avatarId)
	self.avatarId = avatarId;
	C_Club.SetAvatarTexture(self.IconPreview, avatarId, self.clubType);
end

function CommunitiesSettingsDialogMixin:GetAvatarId()
	return self.avatarId;
end

function CommunitiesSettingsDialogMixin:GetName()
	return self.NameEdit:GetText();
end

function CommunitiesSettingsDialogMixin:GetShortName()
	return self.ShortNameEdit:GetText();
end

function CommunitiesSettingsDialogMixin:GetDescription()
	return self.Description.EditBox:GetText();
end

function CommunitiesSettingsDialogMixin:GetMessageOfTheDay()
	return self.MessageOfTheDay.EditBox:GetText();
end

function CommunitiesSettingsDialogMixin:UpdateCreateButton()
	local name = self.NameEdit:GetText();
	local nameIsValid = C_Club.ValidateText(self:GetClubType(), name, Enum.ClubFieldType.ClubName) == Enum.ValidateNameResult.NameSuccess;
	local shortName = self.ShortNameEdit:GetText();
	local shortNameIsValid = C_Club.ValidateText(self:GetClubType(), shortName, Enum.ClubFieldType.ClubShortName) == Enum.ValidateNameResult.NameSuccess;
	local languageSelected = not self.LanguageDropdown.showAnyLanguage;
	local shouldListChecked =  self.ShouldListClub.Button:GetChecked();
	self.Accept:SetEnabled(nameIsValid and shortNameIsValid and (languageSelected or not shouldListChecked));
	if self.Accept:IsMouseOver() then
		CommunitiesSettingsDialogAcceptButton_OnEnter(self.Accept);
	end
end

function CommunitiesSettingsDialogMixin:PostClub(newName)
	if(not C_ClubFinder.IsEnabled()) then
		return true; 
	end 

	local clubInfo = C_Club.GetClubInfo(self.clubId);
	local specsInList = self.LookingForDropdown:GetSpecsList(); 
	local shouldHideNow = true; 
	
	C_ClubFinder.SetRecruitmentSettings(Enum.ClubFinderSettingFlags.MaxLevelOnly, self.MaxLevelOnly.Button:GetChecked()); 
	C_ClubFinder.SetRecruitmentSettings(Enum.ClubFinderSettingFlags.AutoAccept, self.AutoAcceptApplications.Button:GetChecked()); 
	C_ClubFinder.SetRecruitmentSettings(Enum.ClubFinderSettingFlags.EnableListing, self.ShouldListClub.Button:GetChecked());

	local minItemLevel = self.MinIlvlOnly.EditBox:GetNumber();
	local description = self.Description.EditBox:GetText(); 

	if(clubInfo and clubInfo.clubType == Enum.ClubType.Character) then 
		local postClubSuccessful = C_ClubFinder.PostClub(clubInfo.clubId, minItemLevel, newName, description, self:GetAvatarId(), specsInList, Enum.ClubFinderRequestType.Community);
		if (self.ShouldListClub.Button:GetChecked() and postClubSuccessful) then
			shouldHideNow = false;
		elseif(not postClubSuccessful) then 
			shouldHideNow = false;
		end
	end
	return shouldHideNow; 
end

function CommunitiesSettingsGetRecruitmentSettingByValue(value)
	local clubSettings = C_ClubFinder.GetClubRecruitmentSettings();
	if (value == Enum.ClubFinderSettingFlags.Dungeons) then 
		return clubSettings.playStyleDungeon;
	elseif (value == Enum.ClubFinderSettingFlags.Raids) then 
		return clubSettings.playStyleRaids;
	elseif (value == Enum.ClubFinderSettingFlags.PvP) then 
		return clubSettings.playStylePvp;
	elseif (value == Enum.ClubFinderSettingFlags.RP) then 
		return clubSettings.playStyleRP;
	elseif (value == Enum.ClubFinderSettingFlags.Social) then 
		return clubSettings.playStyleSocial;
	elseif (value == Enum.ClubFinderSettingFlags.MaxLevelOnly) then
		return clubSettings.maxLevelOnly; 
	elseif (value == Enum.ClubFinderSettingFlags.EnableListing) then
		return clubSettings.enableListing; 
	elseif (value == Enum.ClubFinderSettingFlags.AutoAccept) then
		return clubSettings.autoAccept; 
	end
end 

function CommunitiesSettingsDialogMixin:ResetClubFinderSettings()
	self.MinIlvlOnly.Button:SetChecked(false);
	self.MinIlvlOnly.EditBox:SetText(""); 
	self.MinIlvlOnly.EditBox.Text:Show();
	self.MaxLevelOnly.Button:SetChecked(false);
	self.AutoAcceptApplications.Button:SetChecked(false);
	self.ShouldListClub.Button:SetChecked(false);

	self.ClubFocusDropdown:Initialize(); 
	C_ClubFinder.SetRecruitmentSettings(Enum.ClubFinderSettingFlags.Social, true); --Initialize to this being on as default. 
	UIDropDownMenu_Initialize(self.ClubFocusDropdown, ClubFocusClubDropdownInitialize);
	self.ClubFocusDropdown:UpdateDropdownText(); 

	self.LookingForDropdown:Initialize(); 
	UIDropDownMenu_Initialize(self.LookingForDropdown, LookingForClubDropdownInitialize); 
	self.LookingForDropdown:UpdateDropdownText();

	UIDropDownMenu_Initialize(self.LanguageDropdown, ClubFinderLanguageDropdownInitialize);
	self.LanguageDropdown:SetLanguageChecked(self.LanguageDropdown.initLocale, true);
end 

function CommunitiesSettingsDialogMixin:CheckLanguageDropdownTutorial()
	local languageSelected = not self.LanguageDropdown.showAnyLanguage;
	local shouldListChecked =  self.ShouldListClub.Button:GetChecked();
	if languageSelected or not shouldListChecked then
		HelpTip:HideAll(self.LanguageDropdown);
	else
		local helpTipInfo = {
			text = CLUB_FINDER_TUTORIAL_LANGUAGE_SET,
			buttonStyle = HelpTip.ButtonStyle.None,
			targetPoint = HelpTip.Point.RightEdgeCenter,
			offsetX = -4,
			useParentStrata = true,
		};

		HelpTip:Show(self.LanguageDropdown, helpTipInfo);
	end

	self:UpdateCreateButton()
end

function CommunitiesSettingsDialogMixin:UpdateSettingsInfoFromClubInfo()
	local clubInfo = C_Club.GetClubInfo(self.clubId);
	self:ResetClubFinderSettings();
	if(clubInfo) then
		local clubPostingInfo = C_ClubFinder.GetRecruitingClubInfoFromClubID(clubInfo.clubId);
		if (clubPostingInfo) then
			if(clubPostingInfo.comment ~= "") then 
				self.Description.EditBox:SetText(clubPostingInfo.comment);
			end
			self.LookingForDropdown:SetCheckedList(clubPostingInfo.recruitingSpecIds);
			self.LookingForDropdown:UpdateDropdownText();

			C_ClubFinder.SetAllRecruitmentSettings(clubPostingInfo.recruitmentFlags);

			local index = C_ClubFinder.GetFocusIndexFromFlag(clubPostingInfo.recruitmentFlags);
			C_ClubFinder.SetRecruitmentSettings(index, true);
			UIDropDownMenu_Initialize(self.ClubFocusDropdown, ClubFocusClubDropdownInitialize)

			UIDropDownMenu_Initialize(self.LanguageDropdown, ClubFinderLanguageDropdownInitialize);
			if not clubPostingInfo.localeSet then
				self.LanguageDropdown:SetShowAnyLanguage(true);
			else
				self.LanguageDropdown:SetLanguageChecked(clubPostingInfo.recruitmentLocale, true);
			end

			if (clubPostingInfo.minILvl > 0) then 
				self.MinIlvlOnly.EditBox:SetText(clubPostingInfo.minILvl); 
				self.MinIlvlOnly.EditBox.Text:Hide();
				self.MinIlvlOnly.Button:SetChecked(true);
			else
				self.MinIlvlOnly.Button:SetChecked(false);
				self.MinIlvlOnly.EditBox:SetText(""); 
				self.MinIlvlOnly.EditBox.Text:Show();
			end
				

			local isMaxLevelChecked = CommunitiesSettingsGetRecruitmentSettingByValue(Enum.ClubFinderSettingFlags.MaxLevelOnly);
			self.MaxLevelOnly.Button:SetChecked(isMaxLevelChecked);

			local autoAccept = CommunitiesSettingsGetRecruitmentSettingByValue(Enum.ClubFinderSettingFlags.AutoAccept);
			self.AutoAcceptApplications.Button:SetChecked(autoAccept);

			local enableListing = CommunitiesSettingsGetRecruitmentSettingByValue(Enum.ClubFinderSettingFlags.EnableListing);
			-- Special case, where a posting could be banned, we don't want to allow the player to post again.
			if (C_ClubFinder.IsPostingBanned(clubInfo.clubId)) then
				self.ShouldListClub.Button:SetEnabled(false);
				self.ShouldListClub.Label:SetTextColor(LIGHTGRAY_FONT_COLOR:GetRGB());
				self:ResetClubFinderSettings();
			else
				self.ShouldListClub.Button:SetChecked(enableListing);
				self.ShouldListClub.Button:SetEnabled(true);
			end
		end
	end
end


function CommunitiesSettingsDialogMixin:SetDisabledStateOnCommunityFinderOptions(shouldDisable)
	self.AutoAcceptApplications.Button:SetEnabled(not shouldDisable);
	self.MaxLevelOnly.Button:SetEnabled(not shouldDisable); 
	self.MinIlvlOnly.Button:SetEnabled(not shouldDisable);
	if (shouldDisable) then 
		local fontColor = LIGHTGRAY_FONT_COLOR;
		self.AutoAcceptApplications.Label:SetTextColor(fontColor:GetRGB());
		self.MaxLevelOnly.Label:SetTextColor(fontColor:GetRGB());
		self.MinIlvlOnly.Label:SetTextColor(fontColor:GetRGB());
		UIDropDownMenu_DisableDropDown(self.ClubFocusDropdown); 
		UIDropDownMenu_DisableDropDown(self.LookingForDropdown);
		UIDropDownMenu_DisableDropDown(self.LanguageDropdown); 
	else
		local fontColor = HIGHLIGHT_FONT_COLOR;
		self.AutoAcceptApplications.Label:SetTextColor(fontColor:GetRGB());
		self.MaxLevelOnly.Label:SetTextColor(fontColor:GetRGB());
		self.MinIlvlOnly.Label:SetTextColor(fontColor:GetRGB());
		UIDropDownMenu_EnableDropDown(self.ClubFocusDropdown); 
		UIDropDownMenu_EnableDropDown(self.LookingForDropdown);
		UIDropDownMenu_EnableDropDown(self.LanguageDropdown);
	end 
	self:CheckLanguageDropdownTutorial();
end 

function CommunitiesSettingsDialogMixin:HideOrShowCommunityFinderOptions(shouldShow)
	local clubId = self:GetClubId();
	local isPostingBanned = C_ClubFinder.IsPostingBanned(clubId); 
	local isClubFinderEnabled = C_ClubFinder.IsEnabled()
	shouldShow = shouldShow and not isPostingBanned;

	if(shouldShow) then 
		self:SetHeight(740); 
	elseif (isPostingBanned and isClubFinderEnabled) then
		self:SetHeight(500); 
	else
		self:SetHeight(480); 
	end 

	self.MaxLevelOnly.Button:SetShown(shouldShow); 
	self.MinIlvlOnly.Button:SetShown(shouldShow);
	self.ClubFocusDropdown:SetShown(shouldShow);
	self.LookingForDropdown:SetShown(shouldShow);
	self.AutoAcceptApplications.Button:SetShown(shouldShow);
	self.AutoAcceptApplications.Label:SetShown(shouldShow);
	self.MaxLevelOnly.Label:SetShown(shouldShow);
	self.MinIlvlOnly.Label:SetShown(shouldShow);
	self.MinIlvlOnly.EditBox:SetShown(shouldShow);
	self.LookingForDropdown.Label:SetShown(shouldShow);
	self.ClubFocusDropdown.Label:SetShown(shouldShow);
	self.ShouldListClub:SetShown(shouldShow);
	self.ClubFinderPostingBannedError:SetText(CLUB_FINDER_BANNED_POSTING_WARNING:format(CLUB_FINDER_COMMUNITY_TYPE));
	self.ClubFinderPostingBannedError:SetShown(isPostingBanned and isClubFinderEnabled);
end 

local function CommunitiesAvatarPickerDialog_OnOkay(self)
	local communitiesAvatarPickerDialog = self:GetParent();
	communitiesAvatarPickerDialog:Hide();
	CommunitiesSettingsDialog:SetAvatarId(communitiesAvatarPickerDialog:GetAvatarId());
	CommunitiesSettingsDialog:UpdatedPostingInformationInit();
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end

local function CommunitiesAvatarPickerDialog_OnCancel(self)
	local communitiesAvatarPickerDialog = self:GetParent();
	communitiesAvatarPickerDialog:Hide();
	CommunitiesSettingsDialog:UpdatedPostingInformationInit();
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end

function CommunitiesSettingsDialogChangeAvatarButton_OnClick(self)
	local communitiesSettingsDialog = self:GetParent();
	communitiesSettingsDialog:Hide();
	CommunitiesAvatarPicker_OpenDialog(communitiesSettingsDialog:GetClubType(), communitiesSettingsDialog:GetAvatarId(), CommunitiesAvatarPickerDialog_OnOkay, CommunitiesAvatarPickerDialog_OnCancel);
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end
		
function CommunitiesSettingsDialogAcceptButton_OnEnter(self)
	local communitiesSettingsDialog = self:GetParent();
	local name = communitiesSettingsDialog.NameEdit:GetText();
	local nameErrorCode = C_Club.GetCommunityNameResultText(C_Club.ValidateText(communitiesSettingsDialog:GetClubType(), name, Enum.ClubFieldType.ClubName));
	local shortName = communitiesSettingsDialog.ShortNameEdit:GetText();
	local shortNameErrorCode = C_Club.GetCommunityNameResultText(C_Club.ValidateText(communitiesSettingsDialog:GetClubType(), shortName, Enum.ClubFieldType.ClubShortName));
	local languageSelected = not communitiesSettingsDialog.LanguageDropdown.showAnyLanguage;
	if nameErrorCode ~= nil and shortNameErrorCode ~= nil then
		local nameError = RED_FONT_COLOR:WrapTextInColorCode(nameErrorCode);
		local shortNameError = RED_FONT_COLOR:WrapTextInColorCode(shortNameErrorCode);
		GameTooltip_SetBasicTooltip(GameTooltip, COMMUNITIES_CREATE_DIALOG_NAME_AND_SHORT_NAME_ERROR:format(nameError, shortNameError), self:GetRight(), self:GetTop(), true);
	elseif nameErrorCode ~= nil then
		local nameError = RED_FONT_COLOR:WrapTextInColorCode(nameErrorCode);
		GameTooltip_SetBasicTooltip(GameTooltip, COMMUNITIES_CREATE_DIALOG_NAME_ERROR:format(nameError), self:GetRight(), self:GetTop(), true);
	elseif shortNameErrorCode ~= nil then
		local shortNameError = RED_FONT_COLOR:WrapTextInColorCode(shortNameErrorCode);
		GameTooltip_SetBasicTooltip(GameTooltip, COMMUNITIES_CREATE_DIALOG_SHORT_NAME_ERROR:format( shortNameError), self:GetRight(), self:GetTop(), true);
	elseif not languageSelected then
		GameTooltip_SetBasicTooltip(GameTooltip, RED_FONT_COLOR:WrapTextInColorCode(LFG_LIST_SELECT_A_CATEGORY), self:GetRight(), self:GetTop(), true);
	else
		GameTooltip:Hide();
	end
end

function CommunitiesSettingsDialogAcceptButton_OnLeave(self)
	GameTooltip:Hide();
end

function CommunitiesSettingsDialogAcceptButton_OnClick(self)
	local communitiesSettingsDialog = self:GetParent();
	C_Club.EditClub(communitiesSettingsDialog:GetClubId(), communitiesSettingsDialog:GetName(), communitiesSettingsDialog:GetShortName(), communitiesSettingsDialog:GetDescription(), communitiesSettingsDialog:GetAvatarId(), communitiesSettingsDialog:GetMessageOfTheDay());
	local shouldHideNow = communitiesSettingsDialog:PostClub(communitiesSettingsDialog:GetName());

	if (shouldHideNow) then 
		communitiesSettingsDialog:Hide();
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
end

function CommunitiesSettingsDialogDeleteButton_OnClick(self)
	local clubId = self:GetParent():GetClubId();
	if clubId then
		local clubInfo = C_Club.GetClubInfo(clubId);
		if clubInfo then
			StaticPopup_Show("CONFIRM_DESTROY_COMMUNITY", nil, nil, clubInfo);
		end
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
end

function CommunitiesSettingsDialogCancelButton_OnClick(self)
	local communitiesSettingsDialog = self:GetParent();
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
	communitiesSettingsDialog:Hide();
end

function CommunitiesSettingsButton_OnClick(self)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);

	if (not CommunitiesSettingsDialog:IsShown()) then 
		local communitiesFrame = self:GetParent():GetParent();
		OpenCommunitiesSettingsDialog(communitiesFrame:GetSelectedClubId());
		HelpTip:Acknowledge(communitiesFrame, CLUB_FINDER_TUTORIAL_POSTING);
	else 
		CloseCommunitiesSettingsDialog();
	end
end
