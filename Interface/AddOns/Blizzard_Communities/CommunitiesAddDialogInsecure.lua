
function AddCommunitiesFlow_Toggle()
	if AddCommunitiesFlow_IsShown() then
		AddCommunitiesFlow_Hide();
	else
		CommunitiesAddDialog:SetAttribute("setshown", true);
	end
end

function AddCommunitiesFlow_Hide()
	CommunitiesAddDialog:SetAttribute("setshown", false);
	CommunitiesCreateDialog:SetAttribute("setshown", false);
	CommunitiesAvatarPicker_CloseDialog();
end

function AddCommunitiesFlow_IsShown()
	return CommunitiesAddDialog:GetAttribute("shown") or CommunitiesCreateDialog:GetAttribute("shown") or CommunitiesAvatarPicker_IsShown();
end

function CommunitiesCreateDialog_SetAvatarId(avatarId)
	CommunitiesCreateDialog:SetAttribute("setavatarid", avatarId);
end

function CommunitiesCreateDialog_SetShown(shown)
	CommunitiesCreateDialog:SetAttribute("setshown", shown);
end

function CommunitiesCreateDialog_SetClubType(clubType)
	CommunitiesCreateDialog:SetAttribute("setclubtype", clubType);
end

function CommunitiesCreateDialog_ClearText()
	CommunitiesCreateDialog:SetAttribute("cleartext", true);
end

function CommunitiesCreateCommunityDialog()
	CommunitiesCreateDialog_SetClubType(Enum.ClubType.Character);
	CommunitiesCreateDialog_ClearText();
	CommunitiesCreateDialog_SetShown(true);
end

function CommunitiesCreateBattleNetDialog()
	CommunitiesCreateDialog_SetClubType(Enum.ClubType.BattleNet);
	CommunitiesCreateDialog_ClearText();
	CommunitiesCreateDialog_SetShown(true);
end
