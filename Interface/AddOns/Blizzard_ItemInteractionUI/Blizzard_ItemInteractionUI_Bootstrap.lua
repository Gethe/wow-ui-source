local AddonName = ...;

function ItemInteraction_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

local function RegisterWithPlayerInteractionManager()
	local frameInfo =
	{
		frame = "ItemInteractionFrame",
		loadFunc = ItemInteraction_LoadUI,
	};

	RegisterPlayerInteraction(Enum.PlayerInteractionType.ItemInteraction, frameInfo);
end

RegisterWithPlayerInteractionManager();
