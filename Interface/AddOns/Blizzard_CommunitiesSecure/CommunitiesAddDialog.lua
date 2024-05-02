
CommunitiesAddDialogMixin = {};

function CommunitiesAddDialogMixin:OnShow()
	self:SetAttribute("shown", true);
	local factionTag, localizedFactionName = UnitFactionGroup("player");
	self.CreateWoWCommunityLabel:SetText(COMMUNITIES_ADD_DIALOG_CREATE_WOW_LABEL:format(localizedFactionName));
	self.CreateWoWCommunityDescription:SetText(COMMUNITIES_ADD_DIALOG_CREATE_WOW_DESCRIPTION:format(localizedFactionName));
	
	self.CreateWoWCommunityButton:SetEnabled(C_Club.ShouldAllowClubType(Enum.ClubType.Character) and not IsVeteranTrialAccount() and not C_ClassTrial.IsClassTrialCharacter());
	self.CreateWoWCommunityButton.FactionIcon:Show();
	if factionTag == "Horde" then
		self.CreateWoWCommunityButton.FactionIcon:SetAtlas("communities-create-button-wow-horde", true);
	elseif factionTag == "Alliance" then
		self.CreateWoWCommunityButton.FactionIcon:SetAtlas("communities-create-button-wow-alliance", true);
	else
		self.CreateWoWCommunityButton:Disable();
		self.CreateWoWCommunityButton.FactionIcon:Hide();
		self.CreateWoWCommunityLabel:SetText(COMMUNITIES_ADD_DIALOG_CREATE_WOW_LABEL_NO_FACTION);
		self.CreateWoWCommunityDescription:SetText(COMMUNITIES_ADD_DIALOG_CREATE_WOW_DESCRIPTION_NO_FACTION);
	end
	
	self.CreateBattleNetGroupButton:SetEnabled(C_Club.ShouldAllowClubType(Enum.ClubType.BattleNet));

	self.InviteLinkBox:SetFocus();
end

function CommunitiesAddDialogMixin:OnAttributeChanged(name, value)
	if name == "setshown" then
		self:SetShown(value);
	end
end

function CommunitiesAddDialogMixin:OnHide()
	self:SetAttribute("shown", false);
	self.InviteLinkBox:SetText("");
end

CommunitiesCreateDialogMixin = {};

function CommunitiesCreateDialogMixin:ClearText()
	self.NameBox:SetText("");
	self.ShortNameBox:SetText("");
	self.DescriptionFrame.EditBox:SetText("");
end

function CommunitiesCreateDialogMixin:OnShow()
	self:SetAttribute("shown", true);
	if self:GetClubType() == Enum.ClubType.BattleNet then
		self.DialogLabel:SetText(COMMUNITIES_CREATE_DIALOG_BATTLE_NET_LABEL);
	else
		self.DialogLabel:SetText(COMMUNITIES_CREATE_DIALOG_WOW_LABEL);
	end
end

function CommunitiesCreateDialogMixin:SetClubType(clubType)
	self.clubType = clubType;
	local isBnet = clubType == Enum.ClubType.BattleNet;
	self.IconPreviewRing:SetAtlas(isBnet and "communities-ring-blue" or "communities-ring-gold");
	self.NameBox.Instructions:SetText(isBnet and COMMUNITIES_CREATE_DIALOG_NAME_INSTRUCTIONS_BATTLE_NET or COMMUNITIES_CREATE_DIALOG_NAME_INSTRUCTIONS);
	self.ShortNameBox.Instructions:SetText(isBnet and COMMUNITIES_CREATE_DIALOG_SHORT_NAME_INSTRUCTIONS or COMMUNITIES_CREATE_DIALOG_SHORT_NAME_INSTRUCTIONS_CHARACTER);
	self.DescriptionLabel:SetText(isBnet and COMMUNITIES_CREATE_DIALOG_DESCRIPTION_LABEL_BATTLE_NET or COMMUNITIES_CREATE_DIALOG_DESCRIPTION_LABEL);
	self.DescriptionFrame.EditBox.Instructions:SetText(isBnet and COMMUNITIES_CREATE_DIALOG_DESCRIPTION_INSTRUCTIONS_BATTLE_NET or COMMUNITIES_CREATE_DIALOG_DESCRIPTION_INSTRUCTIONS);
	self.CreateButton:SetText(isBnet and COMMUNITIES_CREATE_GROUP or COMMUNITIES_CREATE_COMMUNITY);
	local avatarIdList = C_Club.GetAvatarIdList(clubType);
	if avatarIdList then
		self:SetAvatarId(avatarIdList[math.random(1, #avatarIdList)]);
	else
		-- TODO:: Is there anything better we can do here?
		self:SetAvatarId(1);
	end
end

function CommunitiesCreateDialogMixin:GetClubType()
	return self.clubType;
end

function CommunitiesCreateDialogMixin:SetAvatarId(avatarId)
	self.avatarId = avatarId;
	C_Club.SetAvatarTexture(self.IconPreview, avatarId, self.clubType);
end

function CommunitiesCreateDialogMixin:GetAvatarId()
	return self.avatarId;
end

function CommunitiesCreateDialogMixin:OnAttributeChanged(name, value)
	if name == "setshown" then
		self:SetShown(value);
	elseif name == "setavatarid" then
		self:SetAvatarId(value);
	elseif name == "setclubtype" then
		self:SetClubType(value);
	elseif name == "cleartext" then
		self:ClearText();
	end
end

function CommunitiesCreateDialogMixin:OnHide()
	self:SetAttribute("shown", false);
	CommunitiesOutbound.HideAvatarPicker();
end

function CommunitiesCreateDialogMixin:CreateCommunity()
	local name = self.NameBox:GetText();
	local shortName = self.ShortNameBox:GetText();
	local description = self.DescriptionFrame.EditBox:GetText();
	C_Club.CreateClub(name, shortName, description, self:GetClubType(), self:GetAvatarId());
end

function CommunitiesCreateDialogMixin:UpdateCreateButton()
	local name = self.NameBox:GetText();
	local nameIsValid = C_Club.ValidateText(self:GetClubType(), name, Enum.ClubFieldType.ClubName) == Enum.ValidateNameResult.Success;
	local shortName = self.ShortNameBox:GetText();
	local shortNameIsValid = C_Club.ValidateText(self:GetClubType(), shortName, Enum.ClubFieldType.ClubShortName) == Enum.ValidateNameResult.Success;
	self.CreateButton:SetEnabled(nameIsValid and shortNameIsValid);
	if self.CreateButton:IsMouseOver() then
		CommunitiesCreateDialogCreateButton_OnEnter(self.CreateButton);
	end
end

function CommunitiesAddDialogWoWButton_OnEnter(self)
	if not self:IsEnabled() then
		if not C_Club.ShouldAllowClubType(Enum.ClubType.Character) then
			CommunitiesOutbound.ShowGameTooltip(COMMUNITY_TYPE_UNAVAILABLE, self:GetRight(), self:GetTop());
		elseif IsVeteranTrialAccount() then 
			CommunitiesOutbound.ShowGameTooltip(CLUB_FINDER_DISABLE_REASON_VETERAN_TRIAL, self:GetRight(), self:GetTop());
		else
			CommunitiesOutbound.ShowGameTooltip(FEATURE_NOT_AVAILBLE_PANDAREN, self:GetRight(), self:GetTop());
		end
	end
end

function CommunitiesAddDialogWoWButton_OnLeave(self)
	CommunitiesOutbound.HideGameTooltip();
end

function CommunitiesAddDialogWoWButton_OnClick(self)
	self:GetParent():Hide();
	CommunitiesCreateDialog:SetClubType(Enum.ClubType.Character);
	CommunitiesCreateDialog:ClearText();
	CommunitiesCreateDialog:Show();
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end

function CommunitiesAddDialogBattleNetButton_OnEnter(self)
	if not self:IsEnabled() then
		CommunitiesOutbound.ShowGameTooltip(COMMUNITY_TYPE_UNAVAILABLE, self:GetRight(), self:GetTop());
	end
end

function CommunitiesAddDialogBattleNetButton_OnClick(self)
	self:GetParent():Hide();
	CommunitiesCreateDialog:SetClubType(Enum.ClubType.BattleNet);
	CommunitiesCreateDialog:ClearText();
	CommunitiesCreateDialog:Show();
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end

function CommunitiesAddDialogJoinButton_OnClick(self)
	local inviteText = self:GetParent().InviteLinkBox:GetText();
	if inviteText ~= "" then
		C_Club.RedeemTicket(inviteText);
		self:GetParent():Hide();
	end
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end

function CommunitiesCreateDialogChangeAvatarButton_OnClick(self)
	local communitiesCreateDialog = self:GetParent();
	communitiesCreateDialog:Hide();
	CommunitiesOutbound.ShowAvatarPicker(communitiesCreateDialog:GetClubType(), communitiesCreateDialog:GetAvatarId());
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end

function CommunitiesCreateDialogCancelButton_OnClick(self)
	local CommunitiesCreateDialog = self:GetParent();
	CommunitiesCreateDialog:Hide();
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end

function CommunitiesCreateDialogCreateButton_OnClick(self)
	local CommunitiesCreateDialog = self:GetParent();
	CommunitiesCreateDialog:CreateCommunity();
	CommunitiesCreateDialog:Hide();
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end

function CommunitiesCreateDialogCreateButton_OnEnter(self)
	local createDialog = self:GetParent();
	local name = createDialog.NameBox:GetText();
	local nameErrorCode = C_Club.GetCommunityNameResultText(C_Club.ValidateText(createDialog:GetClubType(), name, Enum.ClubFieldType.ClubName));
	local shortName = createDialog.ShortNameBox:GetText();
	local shortNameErrorCode = C_Club.GetCommunityNameResultText(C_Club.ValidateText(createDialog:GetClubType(), shortName, Enum.ClubFieldType.ClubShortName));
	if nameErrorCode ~= nil and shortNameErrorCode ~= nil then
		local nameError = RED_FONT_COLOR:WrapTextInColorCode(nameErrorCode);
		local shortNameError = RED_FONT_COLOR:WrapTextInColorCode(shortNameErrorCode);
		CommunitiesOutbound.ShowGameTooltip(COMMUNITIES_CREATE_DIALOG_NAME_AND_SHORT_NAME_ERROR:format(nameError, shortNameError), self:GetRight(), self:GetTop(), true);
	elseif nameErrorCode ~= nil then
		local nameError = RED_FONT_COLOR:WrapTextInColorCode(nameErrorCode);
		CommunitiesOutbound.ShowGameTooltip(COMMUNITIES_CREATE_DIALOG_NAME_ERROR:format(nameError), self:GetRight(), self:GetTop(), true);
	elseif shortNameErrorCode ~= nil then
		local shortNameError = RED_FONT_COLOR:WrapTextInColorCode(shortNameErrorCode);
		CommunitiesOutbound.ShowGameTooltip(COMMUNITIES_CREATE_DIALOG_SHORT_NAME_ERROR:format(shortNameError), self:GetRight(), self:GetTop(), true);
	else
		CommunitiesOutbound.HideGameTooltip();
	end
end

function CommunitiesCreateDialogCreateButton_OnLeave(self)
	CommunitiesOutbound.HideGameTooltip();
end
