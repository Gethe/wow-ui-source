local AddonName = ...;

function WeeklyRewards_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function WeeklyRewards_ShowUI()
	if WeeklyRewards_LoadUI() then
		local force = true;
		ShowUIPanel(WeeklyRewardsFrame, force);
	end
end

local function RegisterWithPlayerInteractionManager()
	local frameInfo =
	{
		frame = "WeeklyRewardsFrame",
		loadFunc = WeeklyRewards_LoadUI,
		showFunc = WeeklyRewards_ShowUI,
	};

	RegisterPlayerInteraction(Enum.PlayerInteractionType.WeeklyRewards, frameInfo);
end

RegisterWithPlayerInteractionManager();
