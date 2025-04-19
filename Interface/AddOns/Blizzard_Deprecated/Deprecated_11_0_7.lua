-- These are functions that were deprecated in 11.0.2 and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

function QuestUtil.ShouldQuestIconsUseCampaignAppearance(questID)
	return C_QuestInfoSystem.GetQuestClassification(questID) == Enum.QuestClassification.Campaign;
end

function QuestUtil.IsFrequencyRecurring(frequency)
	return frequency == Enum.QuestFrequency.Daily or frequency == Enum.QuestFrequency.Weekly or frequency == Enum.QuestFrequency.ResetByScheduler;
end

function IsActiveQuestLegendary(questIndex)
	local questID = GetActiveQuestID(questIndex);
	return C_QuestInfoSystem.GetQuestClassification(questID) == Enum.QuestClassification.Legendary;
end

function C_QuestLog.IsLegendaryQuest(questID)
	return C_QuestInfoSystem.GetQuestClassification(questID) == Enum.QuestClassification.Legendary;
end

function C_QuestLog.IsQuestRepeatableType(questID)
	if C_QuestLog.IsWorldQuest(questID) then
		return true;
	end

	if C_QuestLog.IsRepeatableQuest(questID) then
		return true;
	end

	local classification = C_QuestInfoSystem.GetQuestClassification(questID);
	return classification == Enum.QuestClassification.Recurring or classification == Enum.QuestClassification.Calling;
end