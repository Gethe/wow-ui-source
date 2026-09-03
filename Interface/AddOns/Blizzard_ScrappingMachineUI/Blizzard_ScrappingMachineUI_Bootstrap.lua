local AddonName = ...;

function ScrappingMachineFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

local function RegisterWithPlayerInteractionManager()
	local frameInfo =
	{
		frame = "ScrappingMachineFrame",
		loadFunc = ScrappingMachineFrame_LoadUI,
	};

	RegisterPlayerInteraction(Enum.PlayerInteractionType.ScrappingMachine, frameInfo);
end

RegisterWithPlayerInteractionManager();
