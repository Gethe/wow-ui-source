local QuestMixin = {};

function QuestMixin:Init(questID)
	self.questID = questID;
	local questLogIndex = C_QuestLog.GetLogIndexForQuestID(questID); -- may not exist, if it doesn't then you get minimal info

	if questLogIndex then
		Mixin(self, C_QuestLog.GetInfo(questLogIndex));

		-- Remove all dynamic data that could become stale
		self.questLogIndex = nil;
		self.isCollapsed = nil;
		self.isOnMap = nil;
		self.hasLocalPOI = nil;
	end

	self.title = QuestUtils_GetQuestName(questID);
	self.requiredMoney = C_QuestLog.GetRequiredMoney(questID);
	self.isRepeatable = C_QuestLog.IsRepeatableQuest(questID);
	self.isLegendary = C_QuestLog.IsLegendaryQuest(questID);
end

function QuestMixin:GetID()
	return self.questID;
end

function QuestMixin:GetQuestLogIndex()
	return C_QuestLog.GetLogIndexForQuestID(self:GetID());
end

function QuestMixin:IsComplete()
	return C_QuestLog.IsComplete(self:GetID());
end

function QuestMixin:IsDisabledForSession()
	return C_QuestLog.IsQuestDisabledForSession(self:GetID());
end

function QuestMixin:IsCampaign()
	return self.campaignID ~= nil;
end

function QuestMixin:IsRepeatableQuest()
	return self.isRepeatable;
end

function QuestMixin:IsLegendary()
	return self.isLegendary;
end

function QuestMixin:IsOnMap()
	return C_QuestLog.IsOnMap(self:GetID());
end

QuestCache = ObjectCache_Create(QuestMixin);