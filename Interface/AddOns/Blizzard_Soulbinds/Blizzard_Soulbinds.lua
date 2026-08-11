do
	local attributes = 
	{ 
		area = "doublewide",
		xoffset = 35,
		pushable = 0,
		allowOtherPanels = 1,
		checkFit = 1,
	};
	RegisterUIPanel(SoulbindViewer, attributes);
end

local function SoulbindViewer_EscapePressed()
	if SoulbindViewer:IsShown() then
		return SoulbindViewer:HandleEscape();
	end

	return false;
end

RegisterGameMenuEscHandler(GameMenuEscPriority.AddOn, SoulbindViewer_EscapePressed);