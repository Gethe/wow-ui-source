
function CommunitiesAddDialog_SetShown(shown)
	CommunitiesAddDialog:SetAttribute("setshown", shown);
end

function CommunitiesCreateDialog_Hide()
	CommunitiesCreateDialog:SetAttribute("hide", true); -- The actual value doesn't matter.
end

function AddCommunitiesDialog_IsShown()
	return CommunitiesAddDialog:GetAttribute("shown") or CommunitiesCreateDialog:GetAttribute("shown");
end

function CommunitiesAddButton_OnClick(self)
	if AddCommunitiesDialog_IsShown() then
		CommunitiesAddDialog_SetShown(false);
		CommunitiesCreateDialog_Hide();
	else
		CommunitiesAddDialog_SetShown(true);
	end
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK);
end

function CommunitiesAddButton_OnHide(self)
	CommunitiesAddDialog_SetShown(false);
	CommunitiesCreateDialog_Hide();
end