QUEST_TIMER_FRAME_TOP_PADDING = 0;

QuestTimerButtonMixin = {};

function QuestTimerButtonMixin:OnClick()
	ShowUIPanel(QuestLogFrame);
	QuestLog_SetSelection(GetQuestIndexForTimer(self:GetID()));
	QuestLog_Update();
end

function QuestTimerButtonMixin:OnEnter()
	GameTooltip:SetOwner(self);
	GameTooltip:SetText(GetQuestLogTitle(GetQuestIndexForTimer(self:GetID())), 1.0, 1.0, 1.0);
	GameTooltip:Show();
end
