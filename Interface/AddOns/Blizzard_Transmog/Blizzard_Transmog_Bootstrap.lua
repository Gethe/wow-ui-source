local AddonName = ...;

function Transmog_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

local function RegisterWithPlayerInteractionManager()
	local frameInfo =
	{
		frame = "TransmogFrame",
		loadFunc = Transmog_LoadUI,
	};

	RegisterPlayerInteraction(Enum.PlayerInteractionType.Transmogrifier, frameInfo);
end

RegisterWithPlayerInteractionManager();
