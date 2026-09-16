local QuestMixin = {};

function QuestMixin:Init(questID)
	self.questID = questID;
	self:CheckRefresh();

	self.title = "";
	self.requiredMoney = 0;
	self.isRepeatable = false;
	self.isLegendary = false;

	QuestEventListener:AddCallback(questID, function()
		self.title = QuestUtils_GetQuestName(questID);
		self.requiredMoney = C_QuestLog.GetRequiredMoney(questID);
		self.isRepeatable = C_QuestLog.IsRepeatableQuest(questID);
		self.isLegendary = C_QuestInfoSystem.GetQuestClassification(questID) == Enum.QuestClassification.Legendary;
	end);
end

function QuestMixin:CheckRefresh()
	if self.hasQuestLogInfo then
		return;
	end

	local questLogIndex = C_QuestLog.GetLogIndexForQuestID(self.questID); -- may not exist, if it doesn't then you get minimal info
	if questLogIndex then
		local questLogInfo = C_QuestLog.GetInfo(questLogIndex);
		if questLogInfo then
			self.hasQuestLogInfo = true;

			Mixin(self, questLogInfo);

			-- Remove all dynamic data that could become stale
			self.questLogIndex = nil;
			self.isOnMap = nil;
			self.isCollapsed = nil;
			self.hasLocalPOI = nil;
		end
	end
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
	return self:GetCampaignID() ~= 0;
end

function QuestMixin:GetCampaignID()
	if self.campaignID == nil then
		self.campaignID = C_CampaignInfo.GetCampaignID(self:GetID());
	end

	return self.campaignID;
end

function QuestMixin:IsCalling()
	if self.isCalling == nil then
		self.isCalling = self:GetQuestClassification() == Enum.QuestClassification.Calling;
	end

	return self.isCalling;
end

function QuestMixin:IsImportant()
	if self.isImportant == nil then
		self.isImportant = C_QuestLog.IsImportantQuest(self:GetID());
	end

	return self.isImportant;
end

function QuestMixin:IsMeta()
	if self.isMeta == nil then
		self.isMeta = C_QuestLog.IsMetaQuest(self:GetID());
	end

	return self.isMeta;
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

function QuestMixin:GetQuestClassification()
	-- This could change at runtime
	return C_QuestInfoSystem.GetQuestClassification(self:GetID());
end

QuestCache = ObjectCache_Create(QuestMixin);