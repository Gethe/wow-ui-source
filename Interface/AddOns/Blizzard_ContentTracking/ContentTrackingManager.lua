
local ContentTrackingManagerMixin = {};

function ContentTrackingManagerMixin:Init()
	self.typeToTrackableElementMap = {};
	self.isEnabled = C_ContentTracking.GetCollectableSourceTrackingEnabled();
end

function ContentTrackingManagerMixin:GetTrackableElementsList(trackableType, trackableID)
	local trackableElementMap = GetOrCreateTableEntry(self.typeToTrackableElementMap, trackableType);
	return GetOrCreateTableEntry(trackableElementMap, trackableID);
end

function ContentTrackingManagerMixin:RegisterTrackableElement(element, trackableType, trackableID)
	local trackableElements = self:GetTrackableElementsList(trackableType, trackableID);
	trackableElements[element] = true;
end

function ContentTrackingManagerMixin:UnregisterTrackableElement(element, trackableType, trackableID)
	local trackableElements = self:GetTrackableElementsList(trackableType, trackableID);
	trackableElements[element] = nil;

	if TableIsEmpty(trackableElements) then
		self.typeToTrackableElementMap[trackableType][trackableID] = nil;
	end
end

function ContentTrackingManagerMixin:OnContentTrackingUpdate(trackableType, id, isTracked)
	if trackableType == Enum.ContentTrackingType.Achievement then
		if AchievementFrameAchievements_UpdateTrackedAchievements then
			AchievementFrameAchievements_UpdateTrackedAchievements();
		end
	elseif (trackableType == Enum.ContentTrackingType.Appearance) or (trackableType == Enum.ContentTrackingType.Mount) then
		AdventureObjectiveTracker:MarkDirty();
	end

	local trackableElementMap = self.typeToTrackableElementMap[trackableType];
	if trackableElementMap then
		local trackableElements = trackableElementMap[id];
		if trackableElements then
			for trackableElement, isTracking in pairs(trackableElements) do
				trackableElement:UpdateTrackingCheckmark();
			end
		end
	end
end

function ContentTrackingManagerMixin:OnContentTrackingToggled(isEnabled)
	self.isEnabled = isEnabled;
	AdventureObjectiveTracker:MarkDirty();
end

local ContentTrackingManager = CreateAndInitFromMixin(ContentTrackingManagerMixin);
EventRegistry:RegisterFrameEventAndCallback("CONTENT_TRACKING_UPDATE", ContentTrackingManager.OnContentTrackingUpdate, ContentTrackingManager);
EventRegistry:RegisterFrameEventAndCallback("CONTENT_TRACKING_IS_ENABLED_UPDATE", ContentTrackingManager.OnContentTrackingToggled, ContentTrackingManager);

ContentTrackingUtil = {};

local CombinedIDOffset = 1000;

ContentTrackingUtil.IsTrackingModifierDown = IsShiftKeyDown;

function ContentTrackingUtil.IsContentTrackingEnabled()
	return ContentTrackingManager.isEnabled;
end

function ContentTrackingUtil.RegisterTrackableElement(element, trackableType, trackableID)
	ContentTrackingManager:RegisterTrackableElement(element, trackableType, trackableID);
end

function ContentTrackingUtil.UnregisterTrackableElement(element, trackableType, trackableID)
	ContentTrackingManager:UnregisterTrackableElement(element, trackableType, trackableID);
end

function ContentTrackingUtil.ProcessChatLink(unused_trackableType, unused_trackableID)
	if IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() then
		-- Until we can link trackables, display an error instead.
		UIErrorsFrame:AddExternalErrorMessage(CONTENT_TRACKING_CHAT_LINK_ERROR_TEXT);
		return true;
	end

	return false;
end

function ContentTrackingUtil.GetTrackingMapInfoByEncounterID(encounterID)
	local trackedEncounterMapInfos = {};
	for i, trackableType in ipairs(C_ContentTracking.GetCollectableSourceTypes()) do
		local trackedIDs = C_ContentTracking.GetTrackedIDs(trackableType);
		for j, trackableID in ipairs(trackedIDs) do
			local targetType, targetID = C_ContentTracking.GetCurrentTrackingTarget(trackableType, trackableID);
			if targetType == Enum.ContentTrackingTargetType.JournalEncounter then
				local encounterTrackingInfo = targetID and C_ContentTracking.GetEncounterTrackingInfo(targetID) or nil;
				if encounterTrackingInfo and encounterTrackingInfo.journalEncounterID == encounterID then
					local mapInfo = {};
					mapInfo.trackableID = trackableID;
					mapInfo.trackableType = trackableType;
					mapInfo.targetType = targetType;
					mapInfo.targetID = targetID;
					mapInfo.difficultyID = encounterTrackingInfo.difficultyID;
					table.insert(trackedEncounterMapInfos, mapInfo);
				end
			end
		end
	end
	
	return trackedEncounterMapInfos;
end

function ContentTrackingUtil.IsContentTrackedInEncounter(encounterID)
	for i, trackableType in ipairs(C_ContentTracking.GetCollectableSourceTypes()) do
		local trackedIDs = C_ContentTracking.GetTrackedIDs(trackableType);
		for j, trackableID in ipairs(trackedIDs) do
			local targetType, targetID = C_ContentTracking.GetCurrentTrackingTarget(trackableType, trackableID);
			if targetType == Enum.ContentTrackingTargetType.JournalEncounter then
				local encounterTrackingInfo = targetID and C_ContentTracking.GetEncounterTrackingInfo(targetID) or nil;
				if encounterTrackingInfo then
					if encounterID == encounterTrackingInfo.journalEncounterID then
						return true;
					end
				end
			end
		end
	end
	
	return false;
end

function ContentTrackingUtil.OpenMapToTrackable(trackableType, trackableID)
	--First check if we are in the target encounter instance. If so, open the encounter map rather than world map
	local unused_targetType, targetID = C_ContentTracking.GetCurrentTrackingTarget(trackableType, trackableID);
	local encounterTrackingInfo = targetID and C_ContentTracking.GetEncounterTrackingInfo(targetID) or nil;
	if encounterTrackingInfo and AdventureGuideUtil.IsInInstance(encounterTrackingInfo.journalInstanceID) then
		--This already opens to the map the player is on, if in the future we want to open to the floor the target is on, we can feed this function a mapID
		--EJ_SelectInstance(encounterTrackingInfo.journalInstanceID);
		--local _, _, _, _, _, _, targetMapID = EJ_GetInstanceInfo();
		if not WorldMapFrame:IsShown() then
			OpenWorldMap();
		else
			WorldMapFrame:SetMapID(MapUtil.GetDisplayableMapForPlayer());
		end
		return;
	end

	local unused_trackingResult, uiMapID = C_ContentTracking.GetBestMapForTrackable(trackableType, trackableID);
	if uiMapID then
		OpenWorldMap(uiMapID);
	end
end

function ContentTrackingUtil.DisplayTrackingError(trackingError)
	if trackingError == Enum.ContentTrackingError.Untrackable then
		UIErrorsFrame:AddExternalErrorMessage(CONTENT_TRACKING_UNTRACKABLE_ERROR_TEXT);
	elseif trackingError == Enum.ContentTrackingError.MaxTracked then
		UIErrorsFrame:AddExternalErrorMessage(CONTENT_TRACKING_MAXTRACKED_ERROR_TEXT);
	elseif trackingError == Enum.ContentTrackingError.AlreadyTracked then
		UIErrorsFrame:AddExternalErrorMessage(CONTENT_TRACKING_ALREADYTRACKED_ERROR_TEXT);
	end
end

function ContentTrackingUtil.MakeCombinedID(trackableType, trackableID)
	return (trackableID * CombinedIDOffset) + trackableType;
end

function ContentTrackingUtil.SplitCombinedID(combinedTrackableID)
	local trackableType = (combinedTrackableID % CombinedIDOffset);
	local trackableID = math.floor(combinedTrackableID / CombinedIDOffset);
	return trackableType, trackableID;
end