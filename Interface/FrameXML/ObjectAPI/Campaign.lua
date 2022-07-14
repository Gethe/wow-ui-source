local CampaignMixin = {};

function CampaignMixin:Init(campaignID)
	self.campaignID = campaignID;
	self.chapterIDs = C_CampaignInfo.GetChapterIDs(campaignID) or {};
	self.usesNormalQuestIcons = C_CampaignInfo.UsesNormalQuestIcons(campaignID);
	Mixin(self, C_CampaignInfo.GetCampaignInfo(campaignID));

	self:SortQuestLines();
end

function CampaignMixin:GetState()
	return C_CampaignInfo.GetState(self:GetID());
end

function CampaignMixin:IsVisible()
	return self:GetState() ~= Enum.CampaignState.Invalid;
end

function CampaignMixin:IsComplete()
	if self.isComplete then
		return true;
	end

	self.isComplete = self:GetState() == Enum.CampaignState.Complete;
	return self.isComplete;
end

function CampaignMixin:GetCurrentChapterID()
	return C_CampaignInfo.GetCurrentChapterID(self:GetID());
end

function CampaignMixin:GetID()
	return self.campaignID;
end

local function CompareQuestLines(line1, line2)
	local info1 = CampaignChapterCache:Get(line1);
	local info2 = CampaignChapterCache:Get(line2);

	if info1 and info2 then
		return info1.orderIndex < info2.orderIndex;
	end

	return info1 ~= nil;
end

function CampaignMixin:SortQuestLines()
	table.sort(self.chapterIDs, CompareQuestLines);
end

function CampaignMixin:GetChapterCount()
	return #self.chapterIDs;
end

function CampaignMixin:GetCompletedChapterCount()
	local count = 0;
	for index, chapterID in ipairs (self.chapterIDs) do
		if CampaignChapterCache:Get(chapterID):IsComplete() then
			count = count + 1;
		end
	end

	return count;
end

function CampaignMixin:GetFailureReason()
	return C_CampaignInfo.GetFailureReason(self:GetID());
end

function CampaignMixin:UsesNormalQuestIcons()
	return self.usesNormalQuestIcons;
end

CampaignCache = ObjectCache_Create(CampaignMixin);
