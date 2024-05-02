-- Outbound loads under the global environment but needs to put the outbound table into the secure environment
local secureEnv = GetCurrentEnvironment();
SwapToGlobalEnvironment();
local CommunitiesOutbound = {};
secureEnv.CommunitiesOutbound = CommunitiesOutbound;
secureEnv = nil;	--This file shouldn't be calling back into secure code.

function CommunitiesOutbound.ShowGameTooltip(text, x, y, wrap)
	securecall("GameTooltip_SetBasicTooltip", GameTooltip, text, x, y, wrap);
end

function CommunitiesOutbound.HideGameTooltip()
	securecall("GameTooltip_Hide");
end

local function CommunitiesAvatarPicker_OnOkay(self)
	CommunitiesAvatarPickerDialog:Hide();
	CommunitiesCreateDialog_SetAvatarId(CommunitiesAvatarPickerDialog:GetAvatarId());
	CommunitiesCreateDialog_SetShown(true);
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end

local function CommunitiesAvatarPicker_OnCancel(self)
	CommunitiesAvatarPickerDialog:Hide();
	CommunitiesCreateDialog_SetShown(true);
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end

function CommunitiesOutbound.ShowAvatarPicker(clubType, avatarId)
	securecall("CommunitiesAvatarPicker_OpenDialog", clubType, avatarId, CommunitiesAvatarPicker_OnOkay, CommunitiesAvatarPicker_OnCancel);
end

function CommunitiesOutbound.HideAvatarPicker()
	securecall("CommunitiesAvatarPicker_CloseDialog");
end