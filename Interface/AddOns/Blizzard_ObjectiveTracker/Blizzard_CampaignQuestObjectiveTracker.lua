local settings = {
	headerText = TRACKER_HEADER_CAMPAIGN_QUESTS,
	events = { "QUEST_LOG_UPDATE", "QUEST_WATCH_LIST_CHANGED" },
	lineTemplate = "ObjectiveTrackerAnimLineTemplate",
};

CampaignQuestObjectiveTrackerMixin = CreateFromMixins(QuestObjectiveTrackerMixin, settings);

function CampaignQuestObjectiveTrackerMixin:ShouldDisplayQuest(quest)
	return (quest:GetSortType() == QuestSortType.Campaign) and not quest:IsDisabledForSession();
end