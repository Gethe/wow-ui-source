local AddonName = ...;

function IslandsQueue_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

local function RegisterWithPlayerInteractionManager()
	local frameInfo =
	{
		frame = "IslandsQueueFrame",
		loadFunc = IslandsQueue_LoadUI,
	};

	RegisterPlayerInteraction(Enum.PlayerInteractionType.IslandQueue, frameInfo);
end

RegisterWithPlayerInteractionManager();
