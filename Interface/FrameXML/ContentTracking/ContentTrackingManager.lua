
local ContentTrackingManagerMixin = {};

function ContentTrackingManagerMixin:Init()
	self.typeToTrackableElementMap = {};
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
		AchievementFrameAchievements_UpdateTrackedAchievements();

		if isTracked then
			ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_ACHIEVEMENT_ADDED, id);
		else
			ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_ACHIEVEMENT);
		end
	elseif (trackableType == Enum.ContentTrackingType.Appearance) or (trackableType == Enum.ContentTrackingType.Mount) then
		ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_ADVENTURE);
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

function ContentTrackingManagerMixin:OnTrackingTargetInfoUpdate(targetType, targetID)
	local moduleWhoseCollapseChanged = nil;
	ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_TARGET_INFO, targetID, moduleWhoseCollapseChanged, targetType);
end

function ContentTrackingManagerMixin:OnTransmogSourceCollected(trackableID)
	-- If the source is currently showing in the objective tracker, the objective tracker will handle un-tracking the item after animations
	if not ADVENTURE_TRACKER_MODULE:IsShowingBlock(trackableID) then
		C_ContentTracking.StopTracking(Enum.ContentTrackingType.Appearance, trackableID);
	end
end

local ContentTrackingManager = CreateAndInitFromMixin(ContentTrackingManagerMixin);
EventRegistry:RegisterFrameEventAndCallback("CONTENT_TRACKING_UPDATE", ContentTrackingManager.OnContentTrackingUpdate, ContentTrackingManager);
EventRegistry:RegisterFrameEventAndCallback("TRACKING_TARGET_INFO_UPDATE", ContentTrackingManager.OnTrackingTargetInfoUpdate, ContentTrackingManager);
EventRegistry:RegisterFrameEventAndCallback("TRANSMOG_COLLECTION_SOURCE_ADDED", ContentTrackingManager.OnTransmogSourceCollected, ContentTrackingManager);


ContentTrackingUtil = {};

ContentTrackingUtil.IsTrackingModifierDown = IsShiftKeyDown;

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

function ContentTrackingUtil.OpenMapToTrackable(trackableType, trackableID)
	--First check if we are in the target encounter instance. If so, open the encounter map rather than world map
	local unused_targetType, targetID = C_ContentTracking.GetCurrentTrackingTarget(trackableType, trackableID);
	local encounterTrackingInfo = targetID and C_ContentTracking.GetEncounterTrackingInfo(targetID) or nil;
	if encounterTrackingInfo then
		local currentMapID = MapUtil.GetDisplayableMapForPlayer();
		local currentInstanceID = EJ_GetInstanceForMap(currentMapID);
		if currentInstanceID and encounterTrackingInfo.journalInstanceID == currentInstanceID then
			--This already opens to the map the player is on, if in the future we want to open to the floor the target is on, we can feed this function a mapID
			--EJ_SelectInstance(encounterTrackingInfo.journalInstanceID);
			--local _, _, _, _, _, _, targetMapID = EJ_GetInstanceInfo();
			OpenWorldMap();
			return;
		end
	end

	local unused_trackingResult, uiMapID = C_ContentTracking.GetBestMapForTrackable(trackableType, trackableID);
	-- TODO:: If unused_trackingResult is DataPending, should we give an error?
	if uiMapID then
		-- TODO:: ping?
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
