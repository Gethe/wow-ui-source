
---------------
--NOTE - Please do not change this section without understanding the full implications of the secure environment
--We usually don't want to call out of this environment from this file. Calls should usually go through Outbound
local _, tbl = ...;
tbl.SecureCapsuleGet = SecureCapsuleGet;

local function Import(name)
	tbl[name] = tbl.SecureCapsuleGet(name);
end

setfenv(1, tbl);
----------------

--Imports
Import("COMMUNITIES_ADD_DIALOG_CREATE_BNET_LABEL");
Import("COMMUNITIES_ADD_DIALOG_CREATE_BNET_DESCRIPTION");
Import("COMMUNITIES_ADD_DIALOG_INVITE_LINK_LABEL");
Import("COMMUNITIES_ADD_DIALOG_INVITE_LINK_DESCRIPTION");
Import("COMMUNITIES_ADD_DIALOG_INVITE_LINK_JOIN");
Import("COMMUNITIES_ADD_DIALOG_BATTLE_NET_LABEL");
Import("COMMUNITIES_ADD_DIALOG_WOW_LABEL");
Import("COMMUNITIES_ADD_DIALOG_LABEL");
Import("COMMUNITIES_CREATE_DIALOG_BATTLE_NET_LABEL");
Import("COMMUNITIES_CREATE_DIALOG_ICON_SELECTION_BUTTON");
Import("COMMUNITIES_CREATE_DIALOG_AVATAR_PICKER_INSTRUCTIONS");
Import("COMMUNITIES_CREATE_DIALOG_NAME_INSTRUCTIONS_BATTLE_NET");
Import("COMMUNITIES_CREATE_DIALOG_DESCRIPTION_INSTRUCTIONS_BATTLE_NET");
Import("COMMUNITIES_CREATE_GROUP");
Import("COMMUNITIES_CREATE_DIALOG_TYPE_LABEL");
Import("COMMUNITIES_SETTINGS_NAME_LABEL");
Import("COMMUNITIES_CREATE_DIALOG_NAME_LABEL");
Import("COMMUNITIES_CREATE_DIALOG_NAME_LABEL_BATTLE_NET");
Import("COMMUNITIES_CREATE_DIALOG_DESCRIPTION_LABEL_BATTLE_NET");
Import("COMMUNITIES_CREATE_DIALOG_ICON_LABEL");
Import("COMMUNITIES_CREATE_DIALOG_SHORT_NAME_LABEL");
Import("COMMUNITIES_CREATE_DIALOG_SHORT_NAME_INSTRUCTIONS");
Import("COMMUNITIES_CREATE_DIALOG_SHORT_NAME_INSTRUCTIONS_TOOLTIP");
Import("COMMUNITIES_CREATE_DIALOG_NAME_AND_SHORT_NAME_ERROR");
Import("COMMUNITIES_CREATE_DIALOG_NAME_ERROR");
Import("COMMUNITIES_CREATE_DIALOG_SHORT_NAME_ERROR");
Import("COMMUNITY_TYPE_UNAVAILABLE");
Import("CANCEL");
Import("FEATURE_NOT_AVAILBLE_PANDAREN");
Import("OKAY");
Import("RED_FONT_COLOR");

Import("C_Club");
Import("CreateFrame");
Import("Enum");
Import("FrameUtil");
Import("math");
Import("PlaySound");
Import("SOUNDKIT");
Import("strlenutf8");
Import("tonumber");
Import("UnitFactionGroup");

CommunitiesAddDialogMixin = {};

function CommunitiesAddDialogMixin:OnShow()
	self:SetAttribute("shown", true);
	self.CreateBattleNetGroupButton:SetEnabled(C_Club.ShouldAllowClubType(Enum.ClubType.BattleNet));
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
	self.DialogLabel:SetText(COMMUNITIES_CREATE_DIALOG_BATTLE_NET_LABEL);
end

function CommunitiesCreateDialogMixin:Initialize()
	self.IconPreviewRing:SetAtlas("communities-ring-blue");
	self.NameBox.Instructions:SetText(COMMUNITIES_CREATE_DIALOG_NAME_INSTRUCTIONS_BATTLE_NET);
	self.ShortNameBox.Instructions:SetText(COMMUNITIES_CREATE_DIALOG_SHORT_NAME_INSTRUCTIONS);
	self.DescriptionLabel:SetText(COMMUNITIES_CREATE_DIALOG_DESCRIPTION_LABEL_BATTLE_NET);
	self.DescriptionFrame.EditBox.Instructions:SetText(COMMUNITIES_CREATE_DIALOG_DESCRIPTION_INSTRUCTIONS_BATTLE_NET);
	self.CreateButton:SetText(COMMUNITIES_CREATE_GROUP);
	local avatarIdList = C_Club.GetAvatarIdList(Enum.ClubType.BattleNet);
	if avatarIdList then
		self:SetAvatarId(avatarIdList[math.random(1, #avatarIdList)]);
	else
		-- TODO:: Is there anything better we can do here?
		self:SetAvatarId(1);
	end
end

function CommunitiesCreateDialogMixin:SetAvatarId(avatarId)
	self.avatarId = avatarId;
	C_Club.SetAvatarTexture(self.IconPreview, avatarId, Enum.ClubType.BattleNet);
end

function CommunitiesCreateDialogMixin:GetAvatarId()
	return self.avatarId;
end

function CommunitiesCreateDialogMixin:OnAttributeChanged(name, value)
	if name == "setshown" then
		self:SetShown(value);
	elseif name == "setavatarid" then
		self:SetAvatarId(value);
	end
end

function CommunitiesCreateDialogMixin:OnHide()
	self:SetAttribute("shown", false);
	Outbound.HideAvatarPicker();
end

function CommunitiesCreateDialogMixin:CreateCommunity()
	local name = self.NameBox:GetText();
	local shortName = self.ShortNameBox:GetText();
	local description = self.DescriptionFrame.EditBox:GetText();
	C_Club.CreateClub(name, shortName, description, Enum.ClubType.BattleNet, self:GetAvatarId());
end

function CommunitiesCreateDialogMixin:UpdateCreateButton()
	local name = self.NameBox:GetText();
	local nameIsValid = C_Club.ValidateText(Enum.ClubType.BattleNet, name, Enum.ClubFieldType.ClubName) == Enum.ValidateNameResult.NameSuccess;
	local shortName = self.ShortNameBox:GetText();
	local shortNameIsValid = C_Club.ValidateText(Enum.ClubType.BattleNet, shortName, Enum.ClubFieldType.ClubShortName) == Enum.ValidateNameResult.NameSuccess;
	self.CreateButton:SetEnabled(nameIsValid and shortNameIsValid);
	if self.CreateButton:IsMouseOver() then
		CommunitiesCreateDialogCreateButton_OnEnter(self.CreateButton);
	end
end

function CommunitiesAddDialogBattleNetButton_OnEnter(self)
	if not self:IsEnabled() then
		Outbound.ShowGameTooltip(COMMUNITY_TYPE_UNAVAILABLE, self:GetRight(), self:GetTop());
	end
end

function CommunitiesAddDialogBattleNetButton_OnClick(self)
	self:GetParent():Hide();
	CommunitiesCreateDialog:Initialize();
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
	Outbound.ShowAvatarPicker(Enum.ClubType.BattleNet, communitiesCreateDialog:GetAvatarId());
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
	local nameErrorCode = C_Club.GetCommunityNameResultText(C_Club.ValidateText(Enum.ClubType.BattleNet, name, Enum.ClubFieldType.ClubName));
	local shortName = createDialog.ShortNameBox:GetText();
	local shortNameErrorCode = C_Club.GetCommunityNameResultText(C_Club.ValidateText(Enum.ClubType.BattleNet, shortName, Enum.ClubFieldType.ClubShortName));
	if nameErrorCode ~= nil and shortNameErrorCode ~= nil then
		local nameError = RED_FONT_COLOR:WrapTextInColorCode(nameErrorCode);
		local shortNameError = RED_FONT_COLOR:WrapTextInColorCode(shortNameErrorCode);
		Outbound.ShowGameTooltip(COMMUNITIES_CREATE_DIALOG_NAME_AND_SHORT_NAME_ERROR:format(nameError, shortNameError), self:GetRight(), self:GetTop(), true);
	elseif nameErrorCode ~= nil then
		local nameError = RED_FONT_COLOR:WrapTextInColorCode(nameErrorCode);
		Outbound.ShowGameTooltip(COMMUNITIES_CREATE_DIALOG_NAME_ERROR:format(nameError), self:GetRight(), self:GetTop(), true);
	elseif shortNameErrorCode ~= nil then
		local shortNameError = RED_FONT_COLOR:WrapTextInColorCode(shortNameErrorCode);
		Outbound.ShowGameTooltip(COMMUNITIES_CREATE_DIALOG_SHORT_NAME_ERROR:format(shortNameError), self:GetRight(), self:GetTop(), true);
	else
		Outbound.HideGameTooltip();
	end
end

function CommunitiesCreateDialogCreateButton_OnLeave(self)
	Outbound.HideGameTooltip();
end
