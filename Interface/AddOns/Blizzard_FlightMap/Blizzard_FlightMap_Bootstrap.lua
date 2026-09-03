local AddonName = ...;

function FlightMap_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ShowFlightMapFrame()
	if FlightMap_LoadUI() then
		ShowUIPanel(FlightMapFrame);
	end
end
