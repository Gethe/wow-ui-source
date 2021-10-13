--If any of these functions call out of this file, they should be using securecall. Be very wary of using return values.
local _, tbl = ...;
local Outbound = {};
tbl.Outbound = Outbound;
tbl = nil;	--This file shouldn't be calling back into secure code.

function Outbound.ShowGameTooltip(text, x, y, wrap)
	securecall("GameTooltip_SetBasicTooltip", GameTooltip, text, x, y, wrap);
end

function Outbound.HideGameTooltip()
	securecall("GameTooltip_Hide");
end

local function CommunitiesAvatarPicker_OnOkay(self)
	local communitiesAvatarPickerDialog = self:GetParent();
	communitiesAvatarPickerDialog:Hide();
	CommunitiesCreateDialog_SetAvatarId(communitiesAvatarPickerDialog:GetAvatarId());
	CommunitiesCreateDialog_SetShown(true);
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end

local function CommunitiesAvatarPicker_OnCancel(self)
	local communitiesAvatarPickerDialog = self:GetParent();
	communitiesAvatarPickerDialog:Hide();
	CommunitiesCreateDialog_SetShown(true);
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end

function Outbound.ShowAvatarPicker(clubType, avatarId)
	securecall("CommunitiesAvatarPicker_OpenDialog", clubType, avatarId, CommunitiesAvatarPicker_OnOkay, CommunitiesAvatarPicker_OnCancel);
end

function Outbound.HideAvatarPicker()
	securecall("CommunitiesAvatarPicker_CloseDialog");
end