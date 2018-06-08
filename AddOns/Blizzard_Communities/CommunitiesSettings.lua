
function OpenCommunitiesSettingsDialog(clubId)
	CommunitiesSettingsDialog:SetClubId(clubId);
	CommunitiesSettingsDialog:Show();
end

function CloseCommunitiesSettingsDialog()
	CommunitiesSettingsDialog:Hide();
end

CommunitiesSettingsDialogMixin = {}

function CommunitiesSettingsDialogMixin:OnLoad()
end

function CommunitiesSettingsDialogMixin:OnShow()
	if self:GetClubType() == Enum.ClubType.BattleNet then
		self.DialogLabel:SetText(COMMUNITIES_SETTINGS_LABEL);
	else
		self.DialogLabel:SetText(COMMUNITIES_SETTINGS_CHARACTER_LABEL);
	end
	
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
	local nameValid = strlenutf8(self.NameEdit:GetText()) >= 2;
	local shortNameValid = strlenutf8(self.ShortNameEdit:GetText()) >= 2;
	self.Accept:SetEnabled(nameValid and shortNameValid);
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

function CommunitiesSettingsDialogAcceptButton_OnClick(self)
	local communitiesSettingsDialog = self:GetParent();
	communitiesSettingsDialog:Hide();
	C_Club.EditClub(communitiesSettingsDialog:GetClubId(), communitiesSettingsDialog:GetName(), communitiesSettingsDialog:GetShortName(), communitiesSettingsDialog:GetDescription(), communitiesSettingsDialog:GetAvatarId(), communitiesSettingsDialog:GetMessageOfTheDay());
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
