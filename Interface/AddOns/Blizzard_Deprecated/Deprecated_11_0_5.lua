-- These are functions that were deprecated in 11.0.2 and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

C_TaskQuest.GetQuestsForPlayerByMapID = C_TaskQuest.GetQuestsOnMap;

do
	GetMerchantItemInfo = function(index)
		local info = C_MerchantFrame.GetItemInfo(index);
		if info then
			return info.name, info.texture, info.price, info.stackCount, info.numAvailable, info.isPurchasable, info.isUsable, info.hasExtendedCost, info.currencyID, info.spellID;
		end
	end
end

do
	C_ChallengeMode.GetCompletionInfo = function()
		local info = C_ChallengeMode.GetChallengeCompletionInfo();
		if info then
			return info.mapChallengeModeID, info.level, info.time, info.onTime, info.keystoneUpgradeLevels, info.practiceRun, info.oldOverallDungeonScore, info.newOverallDungeonScore, info.isAffixRecord, info.isMapRecord, 0, info.isEligibleForScore, info.members;
		end
	end
end

do
	C_MythicPlus.IsWeeklyRewardAvailable = function()
		return false;
	end
end
