local AddonName = ...;

function PerksProgramFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ShowPerksProgramFrame()
	if PerksProgramFrame_LoadUI() then
		ShowUIPanel(PerksProgramFrame);
	end
end
