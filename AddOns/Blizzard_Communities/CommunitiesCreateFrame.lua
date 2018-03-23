
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
Import("C_Club");
Import("CANCEL");
Import("COMMUNITIES_CREATE_COMMUNITY");
Import("CREATE_COMMUNITY_DIALOG_DESCRIPTION_INSTRUCTIONS");
Import("CREATE_COMMUNITY_DIALOG_TYPE_LABEL");
Import("CREATE_COMMUNITY_DIALOG_NAME_LABEL");
Import("CREATE_COMMUNITY_DIALOG_DESCRIPTION_LABEL");
Import("CREATE_COMMUNITY_DIALOG_ICON_LABEL");
Import("Enum");
Import("tonumber");

CommunitiesCreateDialogMixin = {};

function CommunitiesCreateDialogMixin:OnShow()
	self:SetAttribute("shown", true);
end

function CommunitiesCreateDialogMixin:OnAttributeChanged(name, value)
	--Note - Setting attributes is how the external UI should communicate with this frame. That way, their taint won't be spread to this code.
	if name == "setshown" then
		self:SetShown(value);
	end
end

function CommunitiesCreateDialogMixin:OnHide()
	self:SetAttribute("shown", false);
	self.NameBox:SetText("");
	self.DescriptionFrame.EditBox:SetText("");
	self.TypeCheckBox:SetChecked(false);
end

function CommunitiesCreateDialogMixin:CreateCommunity()
	local name = self.NameBox:GetText();
	local description = self.DescriptionFrame.EditBox:GetText();
	local avatarId = tonumber(self.AvatarSelectionBox:GetText());
	local clubType = self.TypeCheckBox:GetChecked() and Enum.ClubType.Character or Enum.ClubType.BattleNet;
	C_Club.CreateClub(name, description, clubType, avatarId);
end

function CommunitiesCreateDialogCancelButton_OnClick(self)
	local CommunitiesCreateDialog = self:GetParent();
	CommunitiesCreateDialog:Hide();
end

function CommunitiesCreateDialogCreateButton_OnClick(self)
	local CommunitiesCreateDialog = self:GetParent();
	CommunitiesCreateDialog:CreateCommunity();
	CommunitiesCreateDialog:Hide();
end