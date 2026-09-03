local AddonName = ...;

function ChromieTimeFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

local function RegisterWithPlayerInteractionManager()
	local frameInfo =
	{
		frame = "ChromieTimeFrame",
		loadFunc = ChromieTimeFrame_LoadUI,
	};

	RegisterPlayerInteraction(Enum.PlayerInteractionType.ChromieTime, frameInfo);
end

RegisterWithPlayerInteractionManager();
