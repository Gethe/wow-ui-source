local CampaignChapterMixin = {};

function CampaignChapterMixin:Init(chapterID)
	self.chapterID = chapterID;
	Mixin(self, C_CampaignInfo.GetCampaignChapterInfo(chapterID));
end

function CampaignChapterMixin:IsComplete()
	if self.isComplete then
		return true;
	end

	self.isComplete = C_QuestLine.IsComplete(self.chapterID);
	return self.isComplete;
end

function CampaignChapterMixin:GetID()
	return self.chapterID;
end

function CampaignChapterMixin:IsInProgress()
	local quests = C_QuestLine.GetQuestLineQuests(self:GetID());
	for index, questID in ipairs(quests) do
		if C_QuestLog.IsOnQuest(questID) or C_QuestLog.IsQuestFlaggedCompleted(questID) then
			return true;
		end
	end

	return false;
end

CampaignChapterCache = ObjectCache_Create(CampaignChapterMixin);