
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
