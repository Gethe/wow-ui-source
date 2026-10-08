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

function ShowAchievementFrameForAchievement(achievementID, closeOtherWindows)
	if AchievementFrame_LoadUI() then
		if not AchievementFrame:IsShown() then
			if closeOtherWindows then
				CloseAllWindows();
			end

			AchievementFrame_ToggleAchievementFrame(false, C_AchievementInfo.IsGuildAchievement(achievementID));
		end

		AchievementFrame_SelectAchievement(achievementID);
	end
end
