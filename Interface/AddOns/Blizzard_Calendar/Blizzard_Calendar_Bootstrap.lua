local AddonName = ...;

function Calendar_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ToggleCalendar()
	if Calendar_LoadUI() then
		Calendar_Toggle();
	end
end
