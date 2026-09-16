QUEST_TIMER_FRAME_TOP_PADDING = 18;

QuestTimerButtonMixin = {};

function QuestTimerButtonMixin:OnClick()
	QuestMapFrame_OpenToQuestDetails(self.questID);
end

function QuestTimerButtonMixin:OnEnter()
	GameTooltip:SetOwner(self);
	local questIndex = C_QuestLog.GetLogIndexForQuestID(self.questID);
	local title = C_QuestLog.GetTitleForLogIndex(questIndex);
	if title then
		GameTooltip:SetText(title, 1.0, 1.0, 1.0);
	end
	GameTooltip:Show();
end
