
function AddCommunitiesFlow_Toggle()
	if AddCommunitiesFlow_IsShown() then
		AddCommunitiesFlow_Hide();
	else
		CommunitiesAddDialog:SetAttribute("setshown", true);
	end
end

function AddCommunitiesFlow_Hide()
	CommunitiesAddDialog:SetAttribute("setshown", false);
	CommunitiesCreateDialog:SetAttribute("hide", true);
	CommunitiesAvatarPickerDialog:SetAttribute("hide", true);
end

function AddCommunitiesFlow_IsShown()
	return CommunitiesAddDialog:GetAttribute("shown") or CommunitiesCreateDialog:GetAttribute("shown") or CommunitiesAvatarPickerDialog:GetAttribute("shown");
end