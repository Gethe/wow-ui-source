local AddonName = ...;

function LegacySystemFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ToggleLegacySystemUI()
	if not LegacySystemFrame then
		if not LegacySystemFrame_LoadUI() then
			return;
		end
	end

	if LegacySystemFrame then
		ToggleFrame(LegacySystemFrame);
	end
end