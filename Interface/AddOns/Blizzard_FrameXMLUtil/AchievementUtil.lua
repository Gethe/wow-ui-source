
AchievementUtil = {};

local CRITERIA_TYPE_ACHIEVEMENT_EARNED = 8;
local CRITERIA_TYPE_REPUTATION_GAINED = 46;
local COUNT_HIDDEN_CRITERIA = true;

function AchievementUtil.IsCriteriaAchievementEarned(achievementID, criteriaIndex)
	local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(achievementID, criteriaIndex);
	return criteriaType == CRITERIA_TYPE_ACHIEVEMENT_EARNED;
end

function AchievementUtil.IsCriteriaReputationGained(achievementID, criteriaIndex, checkCriteriaAchievement, countHiddenCriteria)
	local criteriaString, criteriaType, completed, quantity, reqQuantity, charName, flags, assetID, quantityString = GetAchievementCriteriaInfo(achievementID, criteriaIndex, countHiddenCriteria);
	if criteriaType == CRITERIA_TYPE_REPUTATION_GAINED then
		return true;
	end
	if checkCriteriaAchievement and criteriaType == CRITERIA_TYPE_ACHIEVEMENT_EARNED then
		local numCriteria = GetAchievementNumCriteria(assetID, COUNT_HIDDEN_CRITERIA);
		for i = 1, numCriteria do
			if AchievementUtil.IsCriteriaReputationGained(assetID, i, checkCriteriaAchievement, COUNT_HIDDEN_CRITERIA) then
				return true;
			end
		end
	end
	return false;
end

local FEAT_OF_STRENGTH_ID = 81;
local GUILD_FEAT_OF_STRENGTH_ID = 15093;

function AchievementUtil.IsCategoryFeatOfStrength(category)
	if category == FEAT_OF_STRENGTH_ID or category == GUILD_FEAT_OF_STRENGTH_ID then
		return true;
	end

	local _, parentCategory = GetCategoryInfo(category);
	return parentCategory and AchievementUtil.IsCategoryFeatOfStrength(parentCategory) or false;
end

function AchievementUtil.IsFeatOfStrength(achievementID)
	local category = GetAchievementCategory(achievementID);
	return category and AchievementUtil.IsCategoryFeatOfStrength(category) or false;
end