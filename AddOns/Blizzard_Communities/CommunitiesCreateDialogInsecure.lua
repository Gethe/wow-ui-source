
function CommunitiesCreateFrame_SetShown(shown)
	CommunitiesCreateDialog:SetAttribute("setshown", shown);
end

function CommunitiesCreateFrame_IsShown()
	return CommunitiesCreateDialog:GetAttribute("shown");
end

function CommunitiesCreateButton_OnClick(self)
	CommunitiesCreateFrame_SetShown(true);
end

function CommunitiesCreateButton_OnHide(self)
	CommunitiesCreateFrame_SetShown(false);
end