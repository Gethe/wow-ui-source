do
	local attributes = 
	{ 
		area = "left",
		xoffset = 35,
		pushable = 1,
		allowOtherPanels = 1,
		checkFit = 1,
	};
	RegisterUIPanel(ProfessionsFrame, attributes);
end

do
	local attributes = 
	{ 
		area = "left",
		xoffset = 35,
		pushable = 1,
		allowOtherPanels = 1,
		checkFit = 1,
	};
	RegisterUIPanel(InspectRecipeFrame, attributes);
end

local function ProfessionsFrame_EscapePressed()
	if ProfessionsFrame:IsShown() then
		ProfessionsFrame:CheckConfirmClose();
		return true;
	end

	return false;
end

RegisterGameMenuEscHandler(GameMenuEscPriority.AddOn, ProfessionsFrame_EscapePressed);