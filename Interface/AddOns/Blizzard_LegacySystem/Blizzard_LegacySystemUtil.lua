LegacySystem = {};

function LegacySystem.GetFilteredChallenges()
	local result = {};
	local numResults = GetNumFilteredAchievements();
	for index = 1, numResults do
		result[GetFilteredAchievementID(index)] = true;
	end
	return result;
end

function LegacySystem.GetChallengeIndices(categoryID)
	local numAchievements, numCompleted, numIncomplete = GetCategoryNumAchievements(categoryID);
	local startOffset = 0;
	local count = numAchievements;
	local hideComplete = not LegacyChallengeFilters[ACHIEVEMENTFRAME_FILTER_COMPLETED].value;
	local hideIncomplete = not LegacyChallengeFilters[ACHIEVEMENTFRAME_FILTER_INCOMPLETE].value;

	if hideComplete then
		startOffset = numCompleted;
		count = numIncomplete;
	end

	if hideIncomplete then
		startOffset = 0;
		count = numCompleted;
	end

	return startOffset, count;
end

function LegacySystem.UpdateCurrencyInfo()
	local treeData = LegacyTreeData[1];
	local configID = C_Traits.GetConfigIDByTreeID(treeData.treeID);
	local treeCurrencyInfo = C_Traits.GetTreeCurrencyInfo(configID, treeData.treeID, true);
	local currencyInfo = treeCurrencyInfo and treeCurrencyInfo[1] or nil;

	currencyInfo.renownCurrency = C_MajorFactions.GetCurrentRenownLevel(Constants.LegacyConsts.LEGACY_REWARD_TRACK_FACTION_ID);

	EventRegistry:TriggerEvent("Legacy.UpdateCurrencyInfo", currencyInfo);
end
