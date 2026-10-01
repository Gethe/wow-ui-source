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

local cachedCurrencyInfo = nil;

local function RefreshCachedCurrencyInfo()
	local treeID = LegacyTreeData[1].treeID;
	local configID = C_Traits.GetConfigIDByTreeID(treeID);
	if not configID then
		return nil;
	end

	-- Matches TalentFrameBaseMixin so the tree panel and summaries agree while changes are staged.
	local excludeStagedChanges = false;
	local treeCurrencyInfo = C_Traits.GetTreeCurrencyInfo(configID, treeID, excludeStagedChanges);
	local currencyInfo = treeCurrencyInfo and treeCurrencyInfo[1] or nil;
	if not currencyInfo then
		return nil;
	end

	currencyInfo.renownCurrency = C_MajorFactions.GetCurrentRenownLevel(Constants.LegacyConsts.LEGACY_REWARD_TRACK_FACTION_ID);
	cachedCurrencyInfo = currencyInfo;

	return currencyInfo;
end

function LegacySystem.UpdateCurrencyInfo()
	local currencyInfo = RefreshCachedCurrencyInfo();
	if currencyInfo then
		EventRegistry:TriggerEvent("Legacy.UpdateCurrencyInfo", currencyInfo);
	end
end

function LegacySystem.GetCurrencyInfo()
	return cachedCurrencyInfo or RefreshCachedCurrencyInfo();
end

function LegacySystem.RegisterCurrencyInfoCallback(owner, method)
	local currencyInfo = LegacySystem.GetCurrencyInfo();
	if currencyInfo then
		method(owner, currencyInfo);
	end

	EventRegistry:RegisterCallback("Legacy.UpdateCurrencyInfo", method, owner);
end
