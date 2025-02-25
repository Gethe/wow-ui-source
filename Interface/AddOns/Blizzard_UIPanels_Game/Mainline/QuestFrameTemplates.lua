QuestAccountCompletedNoticeMixin = {};

function QuestAccountCompletedNoticeMixin:OnLoad()
	self:SetWidth(self.Text:GetStringWidth());
end

function QuestAccountCompletedNoticeMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddHighlightLine(GameTooltip, ACCOUNT_COMPLETED_QUEST_NOTICE);
	GameTooltip:Show();
end

function QuestAccountCompletedNoticeMixin:OnLeave()
	GameTooltip_Hide();
end

function QuestAccountCompletedNoticeMixin:Refresh(questID)
	self:SetShown(C_QuestLog.IsQuestFlaggedCompletedOnAccount(questID or GetQuestID()));
end