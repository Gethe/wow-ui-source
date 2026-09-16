local AddonName = ...;

function SoulbindViewer_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

local function ShowSoulbindViewer()
	SoulbindViewer:Open();
end

local function RegisterWithPlayerInteractionManager()
	local frameInfo =
	{
		frame = "SoulbindViewer",
		loadFunc = SoulbindViewer_LoadUI,
		showFunc = ShowSoulbindViewer,
	};

	RegisterPlayerInteraction(Enum.PlayerInteractionType.Soulbind, frameInfo);
end

RegisterWithPlayerInteractionManager();
