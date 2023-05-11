
-- TODO:: Replace these with global strings.
CONTENT_TRACKING_CHECKMARK_TOOLTIP_TITLE = "Currently tracked";
ADVENTURE_TRACKING_MODULE_HEADER_TEXT = "Collections";
ADVENTURE_TRACKING_OPEN_PROFESSION_ERROR_TEXT = "You don't know this profession";
CONTENT_TRACKING_UNTRACKABLE_ERROR_TEXT = "This item can't be tracked";
CONTENT_TRACKING_MAXTRACKED_ERROR_TEXT = "Too many items of this type tracked";
CONTENT_TRACKING_ALREADYTRACKED_ERROR_TEXT = "Already tracked";

-- These aren't used in Lua anymore.
-- CONTENT_TRACKING_BOSS_DROP_FORMAT = "Boss Drop: %s in %s (%s)";
-- CONTENT_TRACKING_BOSS_DROP_MINIMAL_FORMAT = "Boss Drop: %s in %s";
-- CONTENT_TRACKING_VENDOR_COST_ZONE_FORMAT = "Vendor: %s in %s. Costs %s";
-- CONTENT_TRACKING_VENDOR_COST_FORMAT = "Vendor: %s. Costs %s";
-- CONTENT_TRACKING_VENDOR_ZONE_FORMAT = "Vendor: %s in %s.";
-- CONTENT_TRACKING_VENDOR_FORMAT = "Vendor: %s.";
-- CONTENT_TRACKING_ACHIEVEMENT_FORMAT = "Achievement: \"%s\"";
-- CONTENT_TRACKING_PROFESSION_FORMAT = "Profession: %s";

CONTENT_TRACKING_CHAT_LINK_ERROR_TEXT = "This can't be linked in chat";
CONTENT_TRACKING_OPEN_JOURNAL_OPTION = "Open Collection Journal";
CONTENT_TRACKING_OBJECTIVE_FORMAT = "- %s";
CONTENT_TRACKING_RETRIEVING_INFO = "|cffff0000Retrieving information...|r";
CONTENT_TRACKING_LOCATION_UNAVAILABLE = "|cffff0000Location unavailable.|r";
CONTENT_TRACKING_ROUTE_UNAVAILABLE = "|cffff0000Route unavailable.|r";
CONTENT_TRACKING_TRACKABLE_TOOLTIP_PROMPT = "<Shift click to track this item>";
CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT = "<Shift click to stop tracking>";
CONTENT_TRACKING_UNTRACKABLE_TOOLTIP_PROMPT = "Tracking unavailable for this item";
CONTENT_TRACKING_MAP_TOGGLE = "Tracked Items";

WARDROBE_SHORTCUTS_TUTORIAL_1 = "Interface Shortcuts\n\n|cFFFFD200[Right Click]|r\nFavorite an appearance\n\n|cFFFFD200[Ctrl Click]|r\nPreview appearance\n\n";
WARDROBE_SHORTCUTS_TUTORIAL_2 = "|cFFFFD200[Shift Click]|r";
WARDROBE_SHORTCUTS_TUTORIAL_3 = "Track or untrack an item\n";
WARDROBE_TRACKING_TUTORIAL = "You have not collected this appearance yet! Shift Click to begin tracking it."

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
