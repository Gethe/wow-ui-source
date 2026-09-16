local AddonName = ...;

function AchievementFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function InspectAchievements(unit)
	if AchievementFrame_LoadUI() then
		AchievementFrame_DisplayComparison(unit);
	end
end

function ToggleAchievementFrame(stats)
	if AchievementFrame_LoadUI() then
		AchievementFrame_ToggleAchievementFrame(stats);
	end
end

function ShowAchievementFrameForAchievement(achievementID)
	if AchievementFrame_LoadUI() then
		if not AchievementFrame:IsShown() then
			AchievementFrame_ToggleAchievementFrame(false, C_AchievementInfo.IsGuildAchievement(achievementID));
		end

		AchievementFrame_SelectAchievement(achievementID);
	end
end
