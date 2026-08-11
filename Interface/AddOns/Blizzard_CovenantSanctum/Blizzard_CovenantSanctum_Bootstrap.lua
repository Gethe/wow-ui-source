local AddonName = ...;

function CovenantSanctum_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

local function ShowCovenantSanctumFrame()
	CovenantSanctumFrame:InteractionStarted();
end

local function RegisterWithPlayerInteractionManager()
	local frameInfo =
	{
		frame = "CovenantSanctumFrame",
		loadFunc = CovenantSanctum_LoadUI,
		showFunc = ShowCovenantSanctumFrame,
	};

	RegisterPlayerInteraction(Enum.PlayerInteractionType.CovenantSanctum, frameInfo);
end

RegisterWithPlayerInteractionManager();
