local AddonName = ...;

function ObliterumForgeFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

local function RegisterWithPlayerInteractionManager()
	local frameInfo =
	{
		frame = "ObliterumForgeFrame",
		loadFunc = ObliterumForgeFrame_LoadUI,
	};

	RegisterPlayerInteraction(Enum.PlayerInteractionType.ObliterumForge, frameInfo);
end

RegisterWithPlayerInteractionManager();
