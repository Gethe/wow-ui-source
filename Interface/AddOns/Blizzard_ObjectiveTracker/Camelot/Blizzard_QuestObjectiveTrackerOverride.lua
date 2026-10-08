function QuestObjectiveTrackerMixin:CanShowTimerBar()
	return false;
end

function QuestObjectiveTrackerMixin:GetQuestTagText(questID)
	return QuestUtilsOverrides.GetQuestTagText(questID);
end
