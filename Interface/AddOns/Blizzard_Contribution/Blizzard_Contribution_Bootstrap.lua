local AddonName = ...;

function ContributionCollectionFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

local function RegisterWithPlayerInteractionManager()
	local frameInfo =
	{
		frame = "ContributionCollectionFrame",
		loadFunc = ContributionCollectionFrame_LoadUI,
	};

	RegisterPlayerInteraction(Enum.PlayerInteractionType.ContributionCollector, frameInfo);
end

RegisterWithPlayerInteractionManager();
