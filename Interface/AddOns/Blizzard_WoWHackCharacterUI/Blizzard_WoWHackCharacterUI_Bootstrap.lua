local AddonName = ...;

function WoWHackCharacterUI_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ToggleWoWHackCharacterUI()
	if WoWHackCharacterUI_LoadUI() then
		ToggleFrame(WoWHackCharacterUI);
	end
end
