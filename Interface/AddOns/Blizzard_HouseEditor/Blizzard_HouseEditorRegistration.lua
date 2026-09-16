do
	local attributes = 
	{ 
		area = "full",
		pushable = 0,
	};
	RegisterUIPanel(HouseEditorFrame, attributes);
end

local function HouseEditorFrame_EscapePressed()
	if HouseEditorFrame:IsShown() then
		HouseEditorFrame:HandleEscape();
		return true;
	end

	return false;
end

-- Executes before the Framework priority to ensure visibility of UIParent is
-- not restored while housing is in use.
RegisterGameMenuEscHandler(GameMenuEscPriority.FrameworkPre, HouseEditorFrame_EscapePressed);
