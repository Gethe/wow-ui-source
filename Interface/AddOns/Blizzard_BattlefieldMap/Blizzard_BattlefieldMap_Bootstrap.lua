local AddonName = ...;

function BattlefieldMap_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function BattlefieldMap_ToggleUI()
	if BattlefieldMap_LoadUI() then
		BattlefieldMapFrame:Toggle();
	end
end
