local AddonName = ...;

function AzeriteRespecFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

local function RegisterWithPlayerInteractionManager()
	local frameInfo =
	{
		frame = "AzeriteRespecFrame",
		loadFunc = AzeriteRespecFrame_LoadUI,
	};

	RegisterPlayerInteraction(Enum.PlayerInteractionType.AzeriteRespec, frameInfo);
end

RegisterWithPlayerInteractionManager();
