local SuperTrackEventFrame = nil;

local SuperTrackEventMixin = {};

function SuperTrackEventMixin:OnLoad()
	self:SetScript("OnEvent", SuperTrackEventMixin.OnEvent);
	self:RegisterEvent("SUPER_TRACKING_CHANGED");
	self:RegisterEvent("QUEST_ACCEPTED");
	self:RegisterEvent("QUEST_WATCH_LIST_CHANGED");
	self:RegisterEvent("QUEST_TURNED_IN");

	self:CacheCurrentSuperTrackInfo();
end

function SuperTrackEventMixin:OnEvent(event, ...)
	if event == "SUPER_TRACKING_CHANGED" then
		self:CacheCurrentSuperTrackInfo();
	elseif event == "QUEST_ACCEPTED" then
		local questID = ...;
		self:OnQuestAccepted(questID);
	elseif event == "QUEST_WATCH_LIST_CHANGED" then
		local questID, tracked = ...;
		self:OnQuestWatchChanged(questID, tracked);
	elseif event == "QUEST_TURNED_IN" then
		local questID, xp, money = ...;
		self:OnQuestTurnedIn(questID);
	end
end

function SuperTrackEventMixin:ClearMatchingSuperTrackedQuest(questID)
	if questID == C_SuperTrack.GetSuperTrackedQuestID() then
		C_SuperTrack.SetSuperTrackedQuestID(0);
	end
end

function SuperTrackEventMixin:OnQuestTurnedIn(questID)
	self:ClearMatchingSuperTrackedQuest(questID);
end

function SuperTrackEventMixin:CacheCurrentSuperTrackInfo()
	self.isComplete = nil;
	local supertrackedQuestID = C_SuperTrack.GetSuperTrackedQuestID();
	if supertrackedQuestID then
		self.isComplete = C_QuestLog.ReadyForTurnIn(supertrackedQuestID);
		self.uiMapID, self.worldQuests, self.worldQuestsElite, self.dungeons, self.treasures = C_QuestLog.GetQuestAdditionalHighlights(supertrackedQuestID);
	end

	EventRegistry:TriggerEvent("Supertracking.OnChanged", self);
end

function SuperTrackEventMixin:OnQuestAccepted(questID)
	QuestUtil.CheckAutoSuperTrackQuest(questID);
end

function SuperTrackEventMixin:OnQuestWatchChanged(questID, tracked)
	-- These can be nil, explicitly checking
	if tracked == false then
		self:ClearMatchingSuperTrackedQuest(questID);
	end
end

function QuestSuperTracking_ShouldHighlightWorldQuests(uiMapID)
	return SuperTrackEventFrame.uiMapID == uiMapID and SuperTrackEventFrame.worldQuests;
end

function QuestSuperTracking_ShouldHighlightWorldQuestsElite(uiMapID)
	return SuperTrackEventFrame.uiMapID == uiMapID and SuperTrackEventFrame.worldQuestsElite;
end

function QuestSuperTracking_ShouldHighlightDungeons(uiMapID)
	return SuperTrackEventFrame.uiMapID == uiMapID and SuperTrackEventFrame.dungeons;
end

function QuestSuperTracking_ShouldHighlightTreasures(uiMapID)
	return SuperTrackEventFrame.uiMapID == uiMapID and SuperTrackEventFrame.treasures;
end

function QuestSuperTracking_Initialize()
	assert(SuperTrackEventFrame == nil);
	SuperTrackEventFrame = Mixin(CreateFrame("FRAME"), SuperTrackEventMixin);
	SuperTrackEventFrame:OnLoad();
end

QuestSuperTracking_Initialize(); -- TODO: Rewrite, use EventRegistry