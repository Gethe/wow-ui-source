local AddonName = ...;

function Kiosk_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function KioskFrame_HandlePlayerEnteringWorld(isInitialLogin, isUIReload)
	if Kiosk_LoadUI() then
		KioskFrame:HandlePlayerEnteringWorld(isInitialLogin, isUIReload);
	end
end
