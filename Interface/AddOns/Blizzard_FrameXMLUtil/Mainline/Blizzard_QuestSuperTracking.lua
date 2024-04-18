local PENDING_QUEST_ID;
local SuperTrackEventFrame = nil;

local SuperTrackEventMixin = {};

function SuperTrackEventMixin:OnLoad()
	self:SetScript("OnEvent", SuperTrackEventMixin.OnEvent);
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("SUPER_TRACKING_CHANGED");
	self:RegisterEvent("QUEST_ACCEPTED");
	self:RegisterEvent("QUEST_WATCH_LIST_CHANGED");

	self:CacheCurrentSuperTrackInfo();
end

function SuperTrackEventMixin:OnEvent(event, ...)
	if event == "QUEST_LOG_UPDATE" then
		self:CheckUpdateSuperTracked();
	elseif event == "SUPER_TRACKING_CHANGED" then
		self:CacheCurrentSuperTrackInfo();
	elseif event == "QUEST_ACCEPTED" then
		local questID = ...;
		self:OnQuestAccepted(questID);
	elseif event == "QUEST_WATCH_LIST_CHANGED" then
		local questID, tracked = ...;
		self:OnQuestWatchChanged(questID, tracked);
	end
end

function SuperTrackEventMixin:CheckUpdateSuperTracked()
	local superTrackQuestID = C_SuperTrack.GetSuperTrackedQuestID();
	if superTrackQuestID and superTrackQuestID == self:GetCachedSuperTrackedQuestID() then
		if C_QuestLog.ReadyForTurnIn(superTrackQuestID) and not self.isComplete then
			QuestSuperTracking_ChooseClosestQuest();
		end
	end
end

function SuperTrackEventMixin:CacheCurrentSuperTrackInfo()
	self.superTrackQuestID = C_SuperTrack.GetSuperTrackedQuestID();
	self.isComplete = nil;
	if self.superTrackQuestID then
		self.isComplete = C_QuestLog.ReadyForTurnIn(self.superTrackQuestID);
		self.uiMapID, self.worldQuests, self.worldQuestsElite, self.dungeons, self.treasures = C_QuestLog.GetQuestAdditionalHighlights(self.superTrackQuestID);
	end

	EventRegistry:TriggerEvent("Supertracking.OnChanged", self);
end

function SuperTrackEventMixin:GetCachedSuperTrackedQuestID()
	return self.superTrackQuestID;
end

function SuperTrackEventMixin:OnQuestAccepted(questID)
	if self:AllowAutoSuperTrackQuest(questID) then
		C_SuperTrack.SetSuperTrackedQuestID(questID);
	end
end

function SuperTrackEventMixin:OnQuestWatchChanged(questID, tracked)
	-- These can be nil, explicitly checking
	if tracked == false then
		if questID == self:GetCachedSuperTrackedQuestID() then
			QuestSuperTracking_ChooseClosestQuest();
		end
	end
end

function SuperTrackEventMixin:AllowAutoSuperTrackQuest(questID)
	return not QuestUtils_IsQuestWorldQuest(questID) and not QuestUtils_IsQuestBonusObjective(questID);
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

function QuestSuperTracking_OnQuestTracked(questID)
	-- We should supertrack quest if it got added to the top of the tracker
	-- First check if we have POI info. Could be missing if 1) we didn't know about this quest before, 2) just doesn't have POIs
	if QuestHasPOIInfo(questID) then
		-- now check if quest is at the top of the tracker
		if C_QuestLog.GetQuestIDForQuestWatchIndex(1) == questID then
			C_SuperTrack.SetSuperTrackedQuestID(questID);
		end
		PENDING_QUEST_ID = nil;
	else
		-- no POI info, could be arriving later
		PENDING_QUEST_ID = questID;
	end
end

function QuestSuperTracking_ChooseClosestQuest()
	local closestQuestID;

	local minDistSqr = math.huge;
	for i = 1, C_QuestLog.GetNumWorldQuestWatches() do
		local watchedWorldQuestID = C_QuestLog.GetQuestIDForWorldQuestWatchIndex(i);
		if watchedWorldQuestID then
			local distanceSq = C_QuestLog.GetDistanceSqToQuest(watchedWorldQuestID);
			if distanceSq and distanceSq <= minDistSqr then
				minDistSqr = distanceSq;
				closestQuestID = watchedWorldQuestID;
			end
		end
	end

	if not closestQuestID then
		for i = 1, C_QuestLog.GetNumQuestWatches() do
			local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(i);
			if ( questID and QuestHasPOIInfo(questID) ) then
				local distSqr, onContinent = C_QuestLog.GetDistanceSqToQuest(questID);
				if onContinent and distSqr <= minDistSqr then
					minDistSqr = distSqr;
					closestQuestID = questID;
				end
			end
		end
	end

	-- If nothing with POI data is being tracked expand search to quest log
	if not closestQuestID then
		for questLogIndex = 1, C_QuestLog.GetNumQuestLogEntries() do
			local info = C_QuestLog.GetInfo(questLogIndex);
			if info and not info.isHeader and not info.isHidden and QuestHasPOIInfo(info.questID) then
				local distSqr, onContinent = C_QuestLog.GetDistanceSqToQuest(info.questID);
				if onContinent and distSqr <= minDistSqr then
					minDistSqr = distSqr;
					closestQuestID = questID;
				end
			end
		end
	end

	-- Supertrack if we have a valid quest
	if ( closestQuestID ) then
		C_SuperTrack.SetSuperTrackedQuestID(closestQuestID);
	else
		C_SuperTrack.SetSuperTrackedQuestID(0);
	end
end

function QuestSuperTracking_IsSuperTrackedQuestValid()
	local trackedQuestID = C_SuperTrack.GetSuperTrackedQuestID();
	if not trackedQuestID then
		return false;
	end

	if not C_QuestLog.GetLogIndexForQuestID(trackedQuestID) then
		-- Might be a tracked world quest that isn't in our log yet
		if QuestUtils_IsQuestWorldQuest(trackedQuestID) and QuestUtils_IsQuestWatched(trackedQuestID) then
			return C_TaskQuest.IsActive(trackedQuestID);
		end
		return false;
	end

	return true;
end

function QuestSuperTracking_CheckSelection()
	if C_SuperTrack.IsSuperTrackingQuest() or not C_SuperTrack.IsSuperTrackingAnything() then
		if not QuestSuperTracking_IsSuperTrackedQuestValid() then
			QuestSuperTracking_ChooseClosestQuest();
		end
	end
end