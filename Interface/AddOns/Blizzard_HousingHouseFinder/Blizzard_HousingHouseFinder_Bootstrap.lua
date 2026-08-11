local AddonName = ...;

function HouseFinderFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

local function RegisterWithPlayerInteractionManager()
	local frameInfo =
	{
		frame = "HouseFinderFrame",
		loadFunc = HouseFinderFrame_LoadUI,
	};

	RegisterPlayerInteraction(Enum.PlayerInteractionType.OpenHouseFinder, frameInfo);
end

RegisterWithPlayerInteractionManager();
