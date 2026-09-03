local AddonName = ...;

function AlliedRaces_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

local function RegisterWithPlayerInteractionManager()
	RegisterPlayerInteraction(Enum.PlayerInteractionType.AlliedRaceDetailsGiver,
		{
			frame = "AlliedRacesFrame",
			loadFunc = AlliedRaces_LoadUI,
			showFunc = nop,
		});
end

RegisterWithPlayerInteractionManager();

function AlliedRacesFrame_TryShow(raceID)
	if AlliedRaces_LoadUI() then
		AlliedRacesFrame:LoadRaceData(raceID);
		ShowUIPanel(AlliedRacesFrame);
	end
end
