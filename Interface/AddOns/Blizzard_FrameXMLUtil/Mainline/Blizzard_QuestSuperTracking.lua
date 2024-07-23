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
	self.uiMapID = nil;
	self.worldQuests = nil;
	self.worldQuestsElite = nil;
	self.dungeons = nil;
	self.treasures = nil;

	local superTrackedQuestID = C_SuperTrack.GetSuperTrackedQuestID();
	self.superTrackedQuestID = superTrackedQuestID;
	self.superTrackedMapPinType, self.superTrackedMapPinTypeID = C_SuperTrack.GetSuperTrackedMapPin();
	self.superTrackedVignetteGUID = C_SuperTrack.GetSuperTrackedVignette();
	self.superTrackedContentType, self.superTrackedContentID = C_SuperTrack.GetSuperTrackedContent();

	if superTrackedQuestID then
		self.isComplete = C_QuestLog.ReadyForTurnIn(superTrackedQuestID);
		self.uiMapID, self.worldQuests, self.worldQuestsElite, self.dungeons, self.treasures = C_QuestLog.GetQuestAdditionalHighlights(superTrackedQuestID);
	end

	EventRegistry:TriggerEvent("Supertracking.OnChanged", self);
end

function SuperTrackEventMixin:GetSuperTrackedMapPin()
	return self.superTrackedMapPinType, self.superTrackedMapPinTypeID;
end

function SuperTrackEventMixin:GetSuperTrackedQuestID()
	return self.superTrackedQuestID;
end

function SuperTrackEventMixin:GetSuperTrackedVignette()
	return self.superTrackedVignetteGUID;
end

function SuperTrackEventMixin:GetSuperTrackedContent()
	return self.superTrackedContentType, self.superTrackedContentID;
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

-- Global query functions that prefer to use a supertrack cache, but will fall back to the Lua binding
local function GetSupertrackedData(supertracker, apiName)
	if supertracker then
		return supertracker[apiName](supertracker);
	end

	return C_SuperTrack[apiName]();
end

function QuestSuperTracking_GetSuperTrackedQuestID(supertracker)
	return GetSupertrackedData(supertracker, "GetSuperTrackedQuestID");
end

function QuestSuperTracking_GetSuperTrackedContent(supertracker)
	return GetSupertrackedData(supertracker, "GetSuperTrackedContent");
end

function QuestSuperTracking_GetSuperTrackedMapPin(supertracker)
	return GetSupertrackedData(supertracker, "GetSuperTrackedMapPin");
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