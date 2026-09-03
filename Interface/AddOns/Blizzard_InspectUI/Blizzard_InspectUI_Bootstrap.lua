local AddonName = ...;

function InspectFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function InspectUnit(unit)
	if InspectFrame_LoadUI() then
		if ( PlayerSpellsFrame and PlayerSpellsFrame:IsInspecting() ) then
			HideUIPanel(PlayerSpellsFrame);
		end

		InspectFrame_Show(unit);
	end
end
