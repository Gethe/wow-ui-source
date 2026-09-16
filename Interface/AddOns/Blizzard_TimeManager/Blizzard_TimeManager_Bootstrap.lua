local AddonName = ...;

function TimeManager_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ToggleTimeManager()
	if TimeManager_LoadUI() then
		TimeManager_Toggle();
	end
end
