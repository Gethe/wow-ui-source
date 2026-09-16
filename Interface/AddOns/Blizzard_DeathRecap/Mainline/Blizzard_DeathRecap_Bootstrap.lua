local AddonName = ...;

function DeathRecap_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function OpenDeathRecapUI(id)
	if DeathRecap_LoadUI() then
		DeathRecapFrame:OpenRecap(id);
	end
end
