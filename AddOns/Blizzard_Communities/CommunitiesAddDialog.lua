
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
Import("COMMUNITIES_ADD_DIALOG_CREATE_WOW_LABEL");
Import("COMMUNITIES_ADD_DIALOG_CREATE_WOW_LABEL_NO_FACTION");
Import("COMMUNITIES_ADD_DIALOG_CREATE_WOW_DESCRIPTION");
Import("COMMUNITIES_ADD_DIALOG_CREATE_WOW_DESCRIPTION_NO_FACTION");
Import("COMMUNITIES_ADD_DIALOG_CREATE_BNET_LABEL");
Import("COMMUNITIES_ADD_DIALOG_CREATE_BNET_DESCRIPTION");
Import("COMMUNITIES_ADD_DIALOG_INVITE_LINK_LABEL");
Import("COMMUNITIES_ADD_DIALOG_INVITE_LINK_DESCRIPTION");
Import("COMMUNITIES_ADD_DIALOG_INVITE_LINK_JOIN");
Import("COMMUNITIES_ADD_DIALOG_BATTLE_NET_LABEL");
Import("COMMUNITIES_ADD_DIALOG_WOW_LABEL");
Import("COMMUNITIES_ADD_DIALOG_LABEL");
Import("COMMUNITIES_CREATE_DIALOG_WOW_LABEL");
Import("COMMUNITIES_CREATE_DIALOG_BATTLE_NET_LABEL");
Import("COMMUNITIES_CREATE_DIALOG_ICON_SELECTION_BUTTON");
Import("COMMUNITIES_CREATE_DIALOG_AVATAR_PICKER_INSTRUCTIONS");
Import("COMMUNITIES_CREATE_DIALOG_NAME_INSTRUCTIONS");
Import("COMMUNITIES_CREATE_DIALOG_DESCRIPTION_INSTRUCTIONS");
Import("COMMUNITIES_CREATE_COMMUNITY");
Import("COMMUNITIES_CREATE_DIALOG_TYPE_LABEL");
Import("COMMUNITIES_CREATE_DIALOG_NAME_LABEL");
Import("COMMUNITIES_CREATE_DIALOG_DESCRIPTION_LABEL");
Import("COMMUNITIES_CREATE_DIALOG_ICON_LABEL");
Import("CANCEL");
Import("FEATURE_NOT_AVAILBLE_PANDAREN");
Import("OKAY");

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

-- Constants
local NUM_AVATAR_ICON_ROWS = 5;
local NUM_AVATAR_ICON_COLUMNS = 6;
local AVATAR_ICON_SIZE = 64;
local AVATAR_ICON_SPACING = 9;
local COMMUNITIES_AVATAR_PICKER_DIALOG_SCROLL_FRAME_EVENTS = {
	"AVATAR_LIST_UPDATED",
};

CommunitiesAddDialogMixin = {};

function CommunitiesAddDialogMixin:OnShow()
	self:SetAttribute("shown", true);
	local factionTag, localizedFactionName = UnitFactionGroup("player");
	self.CreateWoWCommunityLabel:SetText(COMMUNITIES_ADD_DIALOG_CREATE_WOW_LABEL:format(localizedFactionName));
	self.CreateWoWCommunityDescription:SetText(COMMUNITIES_ADD_DIALOG_CREATE_WOW_DESCRIPTION:format(localizedFactionName));
	
	self.CreateWoWCommunityButton:Enable();
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
	self.DescriptionFrame.EditBox:SetText("");
end

function CommunitiesCreateDialogMixin:OnShow()
	self:SetAttribute("shown", true);
	if self:GetClubType() == Enum.ClubType.BattleNet then
		self.DialogLabel:SetText(COMMUNITIES_CREATE_DIALOG_BATTLE_NET_LABEL);
	else
		local factionTag, localizedFactionName = UnitFactionGroup("player");
		self.DialogLabel:SetText(COMMUNITIES_CREATE_DIALOG_WOW_LABEL:format(localizedFactionName));
	end
end

function CommunitiesCreateDialogMixin:SetClubType(clubType)
	self.clubType = clubType;
	self.IconPreviewRing:SetAtlas(clubType == Enum.ClubType.BattleNet and "communities-ring-blue" or "communities-ring-gold");
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
	if name == "hide" then
		self:Hide();
	end
end

function CommunitiesCreateDialogMixin:OnHide()
	self:SetAttribute("shown", false);
	CommunitiesAvatarPickerDialog:Hide();
end

function CommunitiesCreateDialogMixin:CreateCommunity()
	local name = self.NameBox:GetText();
	local description = self.DescriptionFrame.EditBox:GetText();
	C_Club.CreateClub(name, description, self:GetClubType(), self:GetAvatarId());
end

CommunitiesAvatarPickerDialogMixin = {};

function CommunitiesAvatarPickerDialogMixin:OnShow()
	self:SetAttribute("shown", true);
end

function CommunitiesAvatarPickerDialogMixin:OnHide()
	self:SetAttribute("shown", false);
end

function CommunitiesAvatarPickerDialogMixin:OnAttributeChanged(name, value)
	if name == "hide" then
		self:Hide();
	end
end

function CommunitiesAvatarPickerDialogMixin:SetAvatarId(avatarId)
	self.avatarId = avatarId;
end

function CommunitiesAvatarPickerDialogMixin:GetAvatarId()
	return self.avatarId;
end

function CommunitiesAvatarPickerDialogMixin:SetClubType(clubType)
	self.clubType = clubType;
end

function CommunitiesAvatarPickerDialogMixin:GetClubType()
	return self.clubType;
end

CommunitiesAvatarPickerDialogScrollFrameMixin = {};

function CommunitiesAvatarPickerDialogScrollFrameMixin:OnLoad()
	self.ScrollBar.scrollStep = AVATAR_ICON_SIZE * NUM_AVATAR_ICON_COLUMNS;
	self.ScrollBar:ClearAllPoints();
	self.ScrollBar:SetPoint("TOPLEFT", self, "TOPRIGHT", 9, -1);
	self.ScrollBar:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 9, 14);
	self.ScrollBarTop:ClearAllPoints();
	self.ScrollBarTop:SetPoint("TOPLEFT", self, "TOPRIGHT", 0, 20);
	self.ScrollBarBottom:ClearAllPoints();
	self.ScrollBarBottom:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 0, -4);
	
	self.avatarButtons = {};
	for i = 1, NUM_AVATAR_ICON_ROWS do
		self.avatarButtons[i] = {};
		for j = 1, NUM_AVATAR_ICON_COLUMNS do
			local avatarButton = CreateFrame("BUTTON", nil, self, "AvatarButtonTemplate");
			self.avatarButtons[i][j] = avatarButton;
			local offset = AVATAR_ICON_SIZE + AVATAR_ICON_SPACING;
			avatarButton:SetPoint("TOPLEFT", (j - 1) * offset, (i - 1) * -offset);
		end
	end
end

function CommunitiesAvatarPickerDialogScrollFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, COMMUNITIES_AVATAR_PICKER_DIALOG_SCROLL_FRAME_EVENTS);
	FauxScrollFrame_SetOffset(self, 0);
	self.ScrollBar:SetValue(0);
	self.avatarIdList = C_Club.GetAvatarIdList(self:GetClubType());
	self:Refresh();
end

function CommunitiesAvatarPickerDialogScrollFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, COMMUNITIES_AVATAR_PICKER_DIALOG_SCROLL_FRAME_EVENTS);
end

function CommunitiesAvatarPickerDialogScrollFrameMixin:OnEvent(event, ...)
	if event == "AVATAR_LIST_UPDATED" then
		local clubType = ...;
		if clubType == self:GetClubType() then
			self.avatarIdList = C_Club.GetAvatarIdList(clubType);
			self:Refresh();
		end
	end
end

function CommunitiesAvatarPickerDialogScrollFrameMixin:OnVerticalScroll(offset)
	FauxScrollFrame_OnVerticalScroll(self, offset, AVATAR_ICON_SIZE, function() self:Refresh() end);
end

function CommunitiesAvatarPickerDialogScrollFrameMixin:GetAvatarId()
	return self:GetParent():GetAvatarId()
end

function CommunitiesAvatarPickerDialogScrollFrameMixin:GetClubType()
	return self:GetParent():GetClubType()
end

function CommunitiesAvatarPickerDialogScrollFrameMixin:Refresh()
	-- Force offset to be a proper multiple of 6 to avoid any shifting
	local offset = math.ceil(FauxScrollFrame_GetOffset(self) / NUM_AVATAR_ICON_COLUMNS) * NUM_AVATAR_ICON_COLUMNS;
	
	local numAvatars = self.avatarIdList and #self.avatarIdList or 0;
	local numShown = NUM_AVATAR_ICON_COLUMNS * NUM_AVATAR_ICON_ROWS;
	for i = 1, NUM_AVATAR_ICON_ROWS do
		for j = 1, NUM_AVATAR_ICON_COLUMNS do
			local avatarButton = self.avatarButtons[i][j];
			local avatarOffset = offset + j + (i - 1) * NUM_AVATAR_ICON_COLUMNS;
			if avatarOffset <= numAvatars then
				local avatarId = self.avatarIdList[avatarOffset];
				avatarButton.avatarId = avatarId;
				avatarButton.Selected:SetShown(self:GetAvatarId() == avatarButton.avatarId);
				C_Club.SetAvatarTexture(avatarButton.Icon, avatarId, self:GetClubType());
				avatarButton:Show();
			else
				avatarButton:Hide();
				numShown = numShown - 1;
			end
		end
	end
	
	FauxScrollFrame_Update(self, numAvatars, numShown, AVATAR_ICON_SIZE);
end

function CommunitiesAddDialogWoWButton_OnEnter(self)
	if not self:IsEnabled() then
		Outbound.ShowGameTooltip(FEATURE_NOT_AVAILBLE_PANDAREN, self:GetRight(), self:GetTop());
	end
end

function CommunitiesAddDialogWoWButton_OnLeave(self)
	Outbound.HideGameTooltip();
end

function CommunitiesAddDialogWoWButton_OnClick(self)
	self:GetParent():Hide();
	CommunitiesCreateDialog:SetClubType(Enum.ClubType.Character);
	CommunitiesCreateDialog:ClearText();
	CommunitiesCreateDialog:Show();
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
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
	CommunitiesAvatarPickerDialog:SetAvatarId(communitiesCreateDialog:GetAvatarId());
	CommunitiesAvatarPickerDialog:SetClubType(communitiesCreateDialog:GetClubType());
	CommunitiesAvatarPickerDialog:Show();
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

function CommunitiesAvatarPickerDialogOkayButton_OnClick(self)
	local communitiesAvatarPickerDialog = self:GetParent();
	communitiesAvatarPickerDialog:Hide();
	CommunitiesCreateDialog:SetAvatarId(communitiesAvatarPickerDialog:GetAvatarId());
	CommunitiesCreateDialog:Show();
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end

function CommunitiesAvatarPickerDialogCancelButton_OnClick(self)
	local communitiesAvatarPickerDialog = self:GetParent();
	communitiesAvatarPickerDialog:Hide();
	CommunitiesCreateDialog:Show();
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end