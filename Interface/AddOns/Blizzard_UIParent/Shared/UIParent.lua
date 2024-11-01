function OpenAchievementFrameToAchievement(achievementID)
	if ( not AchievementFrame ) then
		AchievementFrame_LoadUI();
	end
	if ( not AchievementFrame:IsShown() ) then
		AchievementFrame_ToggleAchievementFrame(false, C_AchievementInfo.IsGuildAchievement(achievementID));
	end

	AchievementFrame_SelectAchievement(achievementID);
end

function ToggleLFGFrame()
	if (C_LFGList.GetPremadeGroupFinderStyle() == Enum.PremadeGroupFinderStyle.Vanilla) then
		if (not C_AddOns.IsAddOnLoaded("Blizzard_LookingForGroupUI")) then
			return;
		end

		ToggleLFGParentFrame();
	else
		PVEFrame_ToggleFrame();
	end
end