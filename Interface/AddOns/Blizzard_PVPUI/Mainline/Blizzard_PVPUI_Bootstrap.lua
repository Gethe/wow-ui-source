local AddonName = ...;

function PVPUI_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function TogglePVPUI()
	PVEFrame_ToggleFrame("PVPUIFrame", nil);
end
