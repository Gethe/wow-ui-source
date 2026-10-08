ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS = 0; -- override to not process achievement summary updates

local function CanShowLegacyChallenges()
	if C_GameRules.IsGameRuleActive(Enum.GameRule.AchievementsPanelDisabled) then
		return false;
	end

	local renownLevel = C_MajorFactions.GetCurrentRenownLevel(Constants.LegacyConsts.LEGACY_REWARD_TRACK_FACTION_ID);
	return renownLevel > 0;
end

-- Camelot surfaces achievements as Legacy Challenges; the remaining overrides are in Blizzard_LegacySystem/Blizzard_LegacyAchievementOverrides.lua.
function AchievementFrame_ToggleAchievementFrame(_toggleStatFrame, _toggleGuildView)
	if CanShowLegacyChallenges() then
		ToggleLegacyChallenges();
	end
end

function ShowAchievementFrameForAchievement(achievementID, closeOtherWindows)
	if CanShowLegacyChallenges() then
		ShowLegacyChallenge(achievementID, closeOtherWindows);
	end
end
