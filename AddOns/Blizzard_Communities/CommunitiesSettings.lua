
function OpenCommunitiesSettingsDialog(clubId)
	CommunitiesSettingsDialog:SetClubId(clubId);
	CommunitiesSettingsDialog:Show();
end

function CloseCommunitiesSettingsDialog()
	CommunitiesSettingsDialog:Hide();
end

CommunitiesSettingsDialogMixin = {}

function CommunitiesSettingsDialogMixin:OnLoad()
	self.LookingForDropdown:Initialize(); 
	self.ClubFocusDropdown:Initialize(); 
	self.ClubFocusDropdown.GuildFocusDropdownLabel:SetFontObject(GameFontNormal);
	UIDropDownMenu_SetWidth(self.LookingForDropdown, 140);
	UIDropDownMenu_SetWidth(self.ClubFocusDropdown, 140);
	UIDropDownMenu_Initialize(self.LookingForDropdown, LookingForClubDropdownInitialize); 
	UIDropDownMenu_Initialize(self.ClubFocusDropdown, ClubFocusClubDropdownInitialize); 
end

function CommunitiesSettingsDialogMixin:OnShow()
	if self:GetClubType() == Enum.ClubType.BattleNet then
		self.DialogLabel:SetText(COMMUNITIES_SETTINGS_LABEL);
	else
		self.DialogLabel:SetText(COMMUNITIES_SETTINGS_CHARACTER_LABEL);
	end

	self:SetDisabledStateOnCommunityFinderOptions(not self.ShouldListClub.Button:GetChecked()); 
	CommunitiesFrame:RegisterDialogShown(self);
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
	self.Accept:SetEnabled(nameIsValid and shortNameIsValid);
	if self.Accept:IsMouseOver() then
		CommunitiesSettingsDialogAcceptButton_OnEnter(self.Accept);
	end
end

function CommunitiesSettingsDialogMixin:PostClub()
	if (not self.ShouldListClub.Button:GetChecked()) then 
		return; 
	end

	local clubInfo = C_Club.GetClubInfo(self.clubId);
	local specsInList = self.LookingForDropdown:GetSpecsList(); 

	local minItemLevel = self.MinIlvlOnly.EditBox:GetNumber();
	local description = self.Description.EditBox:GetText():gsub("\n",""); 
	local minimumLevel = 0; 

	if (self.MaxLevelOnly.Button:GetChecked()) then 
		minimumLevel = GetMaxLevelForExpansionLevel(LE_EXPANSION_BATTLE_FOR_AZEROTH);
	end 

	if(clubInfo) then 
		C_ClubFinder.PostClub(clubInfo.clubId, minimumLevel, minItemLevel, clubInfo.name, description, specsInList, Enum.ClubFinderRequestType.Community);
		self:Hide(); 
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
		self.LookingForDropdown.Label:SetTextColor(fontColor:GetRGB());
		self.ClubFocusDropdown.GuildFocusDropdownLabel:SetTextColor(fontColor:GetRGB());
		UIDropDownMenu_DisableDropDown(self.ClubFocusDropdown); 
		UIDropDownMenu_DisableDropDown(self.LookingForDropdown);
	else
		local fontColor = HIGHLIGHT_FONT_COLOR;
		self.AutoAcceptApplications.Label:SetTextColor(fontColor:GetRGB());
		self.MaxLevelOnly.Label:SetTextColor(fontColor:GetRGB());
		self.MinIlvlOnly.Label:SetTextColor(fontColor:GetRGB());
		self.LookingForDropdown.Label:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		self.ClubFocusDropdown.GuildFocusDropdownLabel:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
		UIDropDownMenu_EnableDropDown(self.ClubFocusDropdown); 
		UIDropDownMenu_EnableDropDown(self.LookingForDropdown);
	end 
end 

local function CommunitiesAvatarPickerDialog_OnOkay(self)
	local communitiesAvatarPickerDialog = self:GetParent();
	communitiesAvatarPickerDialog:Hide();
	CommunitiesSettingsDialog:SetAvatarId(communitiesAvatarPickerDialog:GetAvatarId());
	CommunitiesSettingsDialog:Show();
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end

local function CommunitiesAvatarPickerDialog_OnCancel(self)
	local communitiesAvatarPickerDialog = self:GetParent();
	communitiesAvatarPickerDialog:Hide();
	CommunitiesSettingsDialog:Show();
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
	else
		GameTooltip:Hide();
	end
end

function CommunitiesSettingsDialogAcceptButton_OnLeave(self)
	GameTooltip:Hide();
end

function CommunitiesSettingsDialogAcceptButton_OnClick(self)
	local communitiesSettingsDialog = self:GetParent();
	communitiesSettingsDialog:Hide();
	C_Club.EditClub(communitiesSettingsDialog:GetClubId(), communitiesSettingsDialog:GetName(), communitiesSettingsDialog:GetShortName(), communitiesSettingsDialog:GetDescription(), communitiesSettingsDialog:GetAvatarId(), communitiesSettingsDialog:GetMessageOfTheDay());
	communitiesSettingsDialog:PostClub(); 
end

function CommunitiesSettingsDialogDeleteButton_OnClick(self)
	local clubId = self:GetParent():GetClubId();
	if clubId then
		local clubInfo = C_Club.GetClubInfo(clubId);
		if clubInfo then
			StaticPopup_Show("CONFIRM_DESTROY_COMMUNITY", nil, nil, clubInfo);
		end
	end
end

function CommunitiesSettingsDialogCancelButton_OnClick(self)
	local communitiesSettingsDialog = self:GetParent();
	communitiesSettingsDialog:Hide();
end

function CommunitiesSettingsButton_OnClick(self)
	OpenCommunitiesSettingsDialog(self:GetParent():GetParent():GetSelectedClubId());
end
