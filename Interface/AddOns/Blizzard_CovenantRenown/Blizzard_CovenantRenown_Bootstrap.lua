local AddonName = ...;

function CovenantRenown_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ToggleCovenantRenown()
	if CovenantRenown_LoadUI() then
		ToggleFrame(CovenantRenownFrame);
	end
end

local function RegisterWithPlayerInteractionManager()
	local frameInfo =
	{
		frame = "CovenantRenownFrame",
		loadFunc = CovenantRenown_LoadUI,
	};

	RegisterPlayerInteraction(Enum.PlayerInteractionType.Renown, frameInfo);
end

RegisterWithPlayerInteractionManager();
