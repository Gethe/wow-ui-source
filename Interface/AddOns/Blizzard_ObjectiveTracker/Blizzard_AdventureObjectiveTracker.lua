
-- Which tracking targets we expect will have a 3d position to navigate to.
local NavigableContentTrackingTargets = {
	[Enum.ContentTrackingTargetType.Vendor] = true,
	[Enum.ContentTrackingTargetType.JournalEncounter] = true,
};

local settings = {
	headerText = ADVENTURE_TRACKING_MODULE_HEADER_TEXT,
	events = { "CONTENT_TRACKING_UPDATE", "TRANSMOG_COLLECTION_SOURCE_ADDED", "SUPER_TRACKING_CHANGED", "TRACKING_TARGET_INFO_UPDATE" },
	lineTemplate = "ObjectiveTrackerAnimLineTemplate",
	blockTemplate = "ObjectiveTrackerAnimBlockTemplate",
};

AdventureObjectiveTrackerMixin = CreateFromMixins(ObjectiveTrackerModuleMixin, settings);

function AdventureObjectiveTrackerMixin:InitModule()
	-- POIButtonOwnerTemplate
	self:Init();
end

function AdventureObjectiveTrackerMixin:OnEvent(event, ...)
	self.lastEvent = event;
	if event == "TRANSMOG_COLLECTION_SOURCE_ADDED" then
		local transmogSourceId = ...;
		if C_ContentTracking.IsTracking(Enum.ContentTrackingType.Appearance, transmogSourceId) then
			self:OnTrackableItemCollected(Enum.ContentTrackingType.Appearance, transmogSourceId);
		end
	elseif event == "SUPER_TRACKING_CHANGED" then
		-- Before, processing this would not call StopTrackingCollectedItems, which now always happens in the Refresh.
		-- Not sure if this will cause problems.
		self:MarkDirty();
	elseif event == "CONTENT_TRACKING_UPDATE" then
		local trackableType, trackableID, added = ...;
		if trackableType == Enum.ContentTrackingType.Appearance then
			if added then
				local blockKey = ContentTrackingUtil.MakeCombinedID(trackableType, trackableID);
				self:SetNeedsFanfare(blockKey);
			end
			self:MarkDirty();
		end
	elseif event == "TRACKING_TARGET_INFO_UPDATE" then
		self:MarkDirty();
	end
end

function AdventureObjectiveTrackerMixin:OnBlockHeaderClick(block, mouseButton)
	if not ContentTrackingUtil.ProcessChatLink(block.trackableType, block.trackableID) then
		if mouseButton ~= "RightButton" then
			if ContentTrackingUtil.IsTrackingModifierDown() then
				C_ContentTracking.StopTracking(block.trackableType, block.trackableID, Enum.ContentTrackingStopType.Manual);
			elseif (block.trackableType == Enum.ContentTrackingType.Appearance) and IsModifiedClick("DRESSUP") then
				DressUpVisual(block.trackableID);
			elseif block.targetType == Enum.ContentTrackingTargetType.Achievement then
				OpenAchievementFrameToAchievement(block.targetID);
			elseif block.targetType == Enum.ContentTrackingTargetType.Profession then
				self:ClickProfessionTarget(block.targetID);
			else
				ContentTrackingUtil.OpenMapToTrackable(block.trackableType, block.trackableID);
			end

			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		else
			MenuUtil.CreateContextMenu(self:GetContextMenuParent(), function(owner, rootDescription)
				rootDescription:SetTag("MENU_OBJECTIVE_TRACKER", block);

				rootDescription:CreateTitle(block.name);
				if block.trackableType == Enum.ContentTrackingType.Appearance then
					rootDescription:CreateButton(CONTENT_TRACKING_OPEN_JOURNAL_OPTION, function()
						self:OpenToAppearance(block.trackableID);
					end);
				end
				rootDescription:CreateButton(OBJECTIVES_STOP_TRACKING, function()
					self:Untrack(block.trackableType, block.trackableID);
				end);
			end);
		end
	end
end

function AdventureObjectiveTrackerMixin:OnBlockHeaderEnter(block)
	if block.trackableType == Enum.ContentTrackingType.Appearance then
		local function UpdateCursor()
			if IsModifiedClick("DRESSUP") then
				ShowInspectCursor();
			else
				ResetCursor();
			end
		end

		if not self.updateFrame then
			self.updateFrame = CreateFrame("FRAME");
		end

		self.updateFrame:SetScript("OnUpdate", UpdateCursor);

		UpdateCursor();
	else
		ResetCursor();
	end
end

function AdventureObjectiveTrackerMixin:OnBlockHeaderLeave(block)
	if self.updateFrame then
		self.updateFrame:SetScript("OnUpdate", nil);
	end

	ResetCursor();
end

function AdventureObjectiveTrackerMixin:GetDebugReportInfo(block)
	return { debugType = "AdventureTracked", trackableType = block.trackableType, id = block.trackableID, };
end

function AdventureObjectiveTrackerMixin:ClickProfessionTarget(recipeID)
	if not ProfessionsUtil.OpenProfessionFrameToRecipe(recipeID) then
		UIErrorsFrame:AddExternalErrorMessage(ADVENTURE_TRACKING_OPEN_PROFESSION_ERROR_TEXT)
	end
end

function AdventureObjectiveTrackerMixin:OpenToAppearance(appearanceID)
	TransmogUtil.OpenCollectionToItem(appearanceID);
end

function AdventureObjectiveTrackerMixin:Untrack(trackableType, id)
	C_ContentTracking.StopTracking(trackableType, id, Enum.ContentTrackingStopType.Manual);
end

function AdventureObjectiveTrackerMixin:ProcessTrackingEntry(trackableType, trackableID)
	local targetType, targetID = C_ContentTracking.GetCurrentTrackingTarget(trackableType, trackableID);
	if targetType then
		local block = self:GetBlock(ContentTrackingUtil.MakeCombinedID(trackableType, trackableID));
		block.trackableID = trackableID;
		block.trackableType = trackableType;

		local title = C_ContentTracking.GetTitle(trackableType, trackableID);
		block.name = title;
		block:SetHeader(title);

		block.targetType = targetType;
		block.targetID = targetID;

		local ignoreWaypoint = true;
		local trackingResult, uiMapID = C_ContentTracking.GetBestMapForTrackable(trackableType, trackableID, ignoreWaypoint);
		block.endLocationUIMap = (trackingResult == Enum.ContentTrackingResult.Success) and uiMapID or nil;

		local objectiveText = C_ContentTracking.GetObjectiveText(targetType, targetID);
		if objectiveText then
			block.objective = block:AddObjective(1, objectiveText, LINE_TYPE_ANIM, true, OBJECTIVE_DASH_STYLE_SHOW, OBJECTIVE_TRACKER_COLOR["Normal"]);
		else
			block.objective = block:AddObjective(1, CONTENT_TRACKING_RETRIEVING_INFO, LINE_TYPE_ANIM, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Normal"]);
		end

		if NavigableContentTrackingTargets[targetType] then
			-- If data is still pending, show nothing extra and wait for it to load.
			if objectiveText and (trackingResult ~= Enum.ContentTrackingResult.DataPending) then
				if not block.endLocationUIMap then
					block:AddObjective(2, CONTENT_TRACKING_LOCATION_UNAVAILABLE, nil, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Normal"]);
				else
					local navigableTrackingResult, isNavigable = C_ContentTracking.IsNavigable(trackableType, trackableID);
					if (navigableTrackingResult == Enum.ContentTrackingResult.Failure) or
						(navigableTrackingResult == Enum.ContentTrackingResult.Success and not isNavigable) then
						block:AddObjective(2, CONTENT_TRACKING_ROUTE_UNAVAILABLE, nil, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Normal"]);
					else
						local superTrackedType, superTrackedID = C_SuperTrack.GetSuperTrackedContent();
						if (trackableType == superTrackedType) and (trackableID == superTrackedID) then
							local waypointText = C_ContentTracking.GetWaypointText(trackableType, trackableID);
							if waypointText then
								local formattedText = OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION:format(waypointText);
								block:AddObjective(2, formattedText, nil, nil, OBJECTIVE_DASH_STYLE_SHOW, OBJECTIVE_TRACKER_COLOR["Normal"]);
							end
						end
					end
				end
			end
		end

		if not self:LayoutBlock(block) then
			return false;
		end
		
		if ObjectiveTrackerManager:CanShowPOIs(self) then
			local poiButton = self:GetButtonForTrackable(trackableType, trackableID);
			if poiButton then
				poiButton:SetPoint("TOPRIGHT", block.HeaderText, "TOPLEFT", -7, 5);
				block.poiButton = poiButton;
			end
		end
	end
	
	return true;
end

function AdventureObjectiveTrackerMixin:OnFreeBlock(block)
	block.trackableType = nil;
	block.name = nil;
	block.targetType = nil;
	block.targetID = nil;
	block.endLocationUIMap = nil;
	block.objective = nil;
	block.poiButton = nil;
end

function AdventureObjectiveTrackerMixin:EnumerateTrackables(callback)
	for i, trackableType in ipairs(C_ContentTracking.GetCollectableSourceTypes()) do
		local trackedIDs = C_ContentTracking.GetTrackedIDs(trackableType);
		for j, trackableID in ipairs(trackedIDs) do
			if not callback(trackableType, trackableID) then
				break;
			end
		end
	end
end

function AdventureObjectiveTrackerMixin:StopTrackingCollectedItems()
	if not self.collectedIds then
		return;
	end

	local removingCollectedObjective = false;
	for trackableId, trackableType in pairs(self.collectedIds) do
		C_ContentTracking.StopTracking(trackableType, trackableId, Enum.ContentTrackingStopType.Collected);
		removingCollectedObjective = true;
	end
	if removingCollectedObjective then
		PlaySound(SOUNDKIT.CONTENT_TRACKING_OBJECTIVE_TRACKING_END);
	end
	self.collectedIds = nil;
end

function AdventureObjectiveTrackerMixin:OnTrackableItemCollected(trackableType, trackableID)
	local block = self:GetExistingBlock(ContentTrackingUtil.MakeCombinedID(trackableType, trackableID));

	local info = C_TransmogCollection.GetSourceInfo(trackableID);
	local icon = C_TransmogCollection.GetSourceIcon(trackableID);
	local item = Item:CreateFromItemID(info.itemID);

	local rewards = { };
	local t = { };
	t.label = item:GetItemName();
	t.texture = icon;
	t.count = 1;
	t.font = "GameFontHighlightSmall";
	table.insert(rewards, t);
	
	local callback = nil;
	if block then
		if block.objective then
			block.objective.Dash:Hide();
			block.objective:SetState(ObjectiveTrackerAnimLineState.Completing);
		end
		self:AddBlockToCache(block);
		if block.poiButton then
			block.poiButton:Hide();
		end
		callback = GenerateClosure(self.OnShowRewardsToastDone, self, block);
	end

	ObjectiveTrackerManager:ShowRewardsToast(rewards, self, block, COLLECTED, callback);

	if not self.collectedIds then
		self.collectedIds = { };
	end
	self.collectedIds[trackableID] = trackableType;
end

function AdventureObjectiveTrackerMixin:OnShowRewardsToastDone(block)
	self:RemoveBlockFromCache(block);
end

function AdventureObjectiveTrackerMixin:LayoutContents()
	-- POIButtonOwnerTemplate
	self:ResetUsage();

	if not ContentTrackingUtil.IsContentTrackingEnabled() then
		return;
	end
	
	self:StopTrackingCollectedItems();
	self:EnumerateTrackables(GenerateClosure(self.ProcessTrackingEntry, self));
end