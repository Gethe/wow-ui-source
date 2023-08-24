
-- Which tracking targets we expect will have a 3d position to navigate to.
local NavigableContentTrackingTargets = {
	[Enum.ContentTrackingTargetType.Vendor] = true,
	[Enum.ContentTrackingTargetType.JournalEncounter] = true,
};


ADVENTURE_TRACKER_MODULE = ObjectiveTracker_GetModuleInfoTable("ADVENTURE_TRACKER_MODULE");
ADVENTURE_TRACKER_MODULE.updateReasonModule = 	OBJECTIVE_TRACKER_UPDATE_MODULE_ADVENTURE;
ADVENTURE_TRACKER_MODULE.updateReasonEvents = 	OBJECTIVE_TRACKER_UPDATE_TARGET_INFO +
												OBJECTIVE_TRACKER_UPDATE_TRANSMOG_COLLECTED +
												OBJECTIVE_TRACKER_UPDATE_SUPER_TRACK_CHANGED;
ADVENTURE_TRACKER_MODULE:SetHeader(ObjectiveTrackerFrame.BlocksFrame.AdventureHeader, ADVENTURE_TRACKING_MODULE_HEADER_TEXT, nil);

local LINE_TYPE_ANIM = { template = "QuestObjectiveAnimLineTemplate", freeLines = { } };

function ADVENTURE_TRACKER_MODULE:OnBlockHeaderClick(block, mouseButton)
	if not ContentTrackingUtil.ProcessChatLink(block.trackableType, block.trackableID) then
		if mouseButton ~= "RightButton" then
			CloseDropDownMenus();

			if ContentTrackingUtil.IsTrackingModifierDown() then
				C_ContentTracking.StopTracking(block.trackableType, block.trackableID, Enum.ContentTrackingStopType.Manual);
			elseif (block.trackableType == Enum.ContentTrackingType.Appearance) and IsModifiedClick("DRESSUP") then
				DressUpVisual(block.trackableID);
			elseif block.targetType == Enum.ContentTrackingTargetType.Achievement then
				OpenAchievementFrameToAchievement(block.targetID);
			elseif block.targetType == Enum.ContentTrackingTargetType.Profession then
				AdventureObjectiveTracker_ClickProfessionTarget(block.targetID);
			else
				ContentTrackingUtil.OpenMapToTrackable(block.trackableType, block.trackableID);
			end

			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		else
			ObjectiveTracker_ToggleDropDown(block, AdventureObjectiveTracker_OnOpenDropDown);
		end
	end
end

function ADVENTURE_TRACKER_MODULE:OnBlockHeaderEnter(block)
	DEFAULT_OBJECTIVE_TRACKER_MODULE:OnBlockHeaderEnter(block);

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

function ADVENTURE_TRACKER_MODULE:OnBlockHeaderLeave(block)
	DEFAULT_OBJECTIVE_TRACKER_MODULE:OnBlockHeaderLeave(block);

	if self.updateFrame then
		self.updateFrame:SetScript("OnUpdate", nil);
	end

	ResetCursor();
end

function ADVENTURE_TRACKER_MODULE:GetDebugReportInfo(block)
	return { debugType = "AdventureTracked", trackableType = block.trackableType, id = block.trackableID, };
end

function AdventureObjectiveTracker_ClickProfessionTarget(recipeID)
	if not ProfessionsUtil.OpenProfessionFrameToRecipe(recipeID) then
		UIErrorsFrame:AddExternalErrorMessage(ADVENTURE_TRACKING_OPEN_PROFESSION_ERROR_TEXT)
	end
end

function AdventureObjectiveTracker_OnOpenDropDown(self)
	local block = self.activeFrame;

	local info = UIDropDownMenu_CreateInfo();
	info.text = block.name;
	info.isTitle = 1;
	info.notCheckable = 1;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);

	info = UIDropDownMenu_CreateInfo();
	info.notCheckable = 1;

	if block.trackableType == Enum.ContentTrackingType.Appearance then
		info.text = CONTENT_TRACKING_OPEN_JOURNAL_OPTION;
		info.func = AdventureObjectiveTracker_OpenToAppearance;
		info.arg1 = block.trackableID;
		info.checked = false;
		UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
	end

	info.text = OBJECTIVES_STOP_TRACKING;
	info.func = AdventureObjectiveTracker_Untrack;
	info.arg1 = block.trackableType;
	info.arg2 = block.trackableID;
	info.checked = false;
	UIDropDownMenu_AddButton(info, UIDROPDOWN_MENU_LEVEL);
end

function AdventureObjectiveTracker_OpenToAppearance(unused_dropDownButton, appearanceID)
	TransmogUtil.OpenCollectionToItem(appearanceID);
end

function AdventureObjectiveTracker_Untrack(unused_dropDownButton, trackableType, id)
	C_ContentTracking.StopTracking(trackableType, id, Enum.ContentTrackingStopType.Manual);
end

function AdventureObjectiveTracker_AnimateReward(trackableID, anchor, posIndex, trackerModule)
	local info = C_TransmogCollection.GetSourceInfo(trackableID);
	local icon = C_TransmogCollection.GetSourceIcon(trackableID);
	local item = Item:CreateFromItemID(info.itemID);

	local rewardData = { };
	rewardData.posIndex = posIndex
	rewardData.rewards = { };

	local t = { };
	t.label = item:GetItemName();
	t.texture = icon;
	t.count = 1;
	t.font = "GameFontHighlightSmall";
	table.insert(rewardData.rewards, t);
	
	AdventureObjectiveTrackerBonusRewardsFrame:AnimateRewardOnAnchor(anchor, rewardData, trackableID, trackerModule);
end

function ADVENTURE_TRACKER_MODULE:UpdatePOI(trackableType, trackableID)
	local block = self:GetExistingBlock(ContentTrackingUtil.MakeCombinedID(trackableType, trackableID));
	if not block or not block.endLocationUIMap then
		-- Don't show a poiButton for trackables that have no location.
		return true;
	end

	if block then
		local poiButton = ObjectiveTrackerFrame.BlocksFrame:GetButtonForTrackable(trackableType, trackableID);
		if poiButton then
			poiButton:SetPoint("TOPRIGHT", block.HeaderText, "TOPLEFT", -6, 2);
		end
	end

	return true;
end

function ADVENTURE_TRACKER_MODULE:UpdatePOIs(unused_numPOINumeric)
	self:EnumerateTrackables(GenerateClosure(self.UpdatePOI, self));
	return 0;
end

function ADVENTURE_TRACKER_MODULE:ProcessTrackingEntry(trackableType, trackableID)
	local targetType, targetID = C_ContentTracking.GetCurrentTrackingTarget(trackableType, trackableID);
	if targetType then
		local block = self:GetBlock(ContentTrackingUtil.MakeCombinedID(trackableType, trackableID));
		block.trackableID = trackableID;
		block.trackableType = trackableType;

		local title = C_ContentTracking.GetTitle(trackableType, trackableID);
		block.name = title;
		self:SetBlockHeader(block, title);

		block.targetType = targetType;
		block.targetID = targetID;

		local ignoreWaypoint = true;
		local trackingResult, uiMapID = C_ContentTracking.GetBestMapForTrackable(trackableType, trackableID, ignoreWaypoint);
		block.endLocationUIMap = (trackingResult == Enum.ContentTrackingResult.Success) and uiMapID or nil;

		local objectiveText = C_ContentTracking.GetObjectiveText(targetType, targetID);
		if objectiveText then
			block.objective = self:AddObjective(block, 1, objectiveText, LINE_TYPE_ANIM, true, OBJECTIVE_DASH_STYLE_SHOW, OBJECTIVE_TRACKER_COLOR["Normal"]);
		else
			block.objective = self:AddObjective(block, 1, CONTENT_TRACKING_RETRIEVING_INFO, LINE_TYPE_ANIM, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Normal"]);
		end

		if NavigableContentTrackingTargets[targetType] then
			-- If data is still pending, show nothing extra and wait for it to load.
			if objectiveText and (trackingResult ~= Enum.ContentTrackingResult.DataPending) then
				if not block.endLocationUIMap then
					self:AddObjective(block, 2, CONTENT_TRACKING_LOCATION_UNAVAILABLE, nil, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Normal"]);
				else
					local navigableTrackingResult, isNavigable = C_ContentTracking.IsNavigable(trackableType, trackableID);
					if (navigableTrackingResult == Enum.ContentTrackingResult.Failure) or
						(navigableTrackingResult == Enum.ContentTrackingResult.Success and not isNavigable) then
						self:AddObjective(block, 2, CONTENT_TRACKING_ROUTE_UNAVAILABLE, nil, nil, OBJECTIVE_DASH_STYLE_HIDE, OBJECTIVE_TRACKER_COLOR["Normal"]);
					else
						local superTrackedType, superTrackedID = C_SuperTrack.GetSuperTrackedContent();
						if (trackableType == superTrackedType) and (trackableID == superTrackedID) then
							local waypointText = C_ContentTracking.GetWaypointText(trackableType, trackableID);
							if waypointText then
								local formattedText = OPTIONAL_QUEST_OBJECTIVE_DESCRIPTION:format(waypointText);
								self:AddObjective(block, 2, formattedText, nil, nil, OBJECTIVE_DASH_STYLE_SHOW, OBJECTIVE_TRACKER_COLOR["Normal"]);
							end
						end
					end
				end
			end
		end

		block.objective.Glow.Anim:SetScript("OnFinished" ,
			function() 
				block.objective.FadeOutAnim:Play();
			end
		);

		block.objective.FadeOutAnim:SetScript("OnFinished" ,
			function() 
				block.module:FreeLine(block, block.objective);
			end
		);

		block:SetHeight(block.height);

		if ObjectiveTracker_AddBlock(block) then
			block:Show();
			self:FreeUnusedLines(block);
		else
			block.used = false;
			return false;
		end
	end

	return true;
end

function ADVENTURE_TRACKER_MODULE:OnFreeBlock(block)
	block.trackableType = nil;
	block.name = nil;
	block.targetType = nil;
	block.targetID = nil;
	block.endLocationUIMap = nil;
	block.objective = nil;
end

function ADVENTURE_TRACKER_MODULE:OnFreeTypedLine(line)
	if line.Glow then
		line.Glow.Anim:SetScript("OnFinished" , nil);
		line.FadeOutAnim:SetScript("OnFinished" , nil);
	end
	QUEST_TRACKER_MODULE:OnFreeTypedLine(line);
end

function ADVENTURE_TRACKER_MODULE:EnumerateTrackables(callback)
	for i, trackableType in ipairs(C_ContentTracking.GetCollectableSourceTypes()) do
		local trackedIDs = C_ContentTracking.GetTrackedIDs(trackableType);
		for j, trackableID in ipairs(trackedIDs) do
			if not callback(trackableType, trackableID) then
				break;
			end
		end
	end
end

function ADVENTURE_TRACKER_MODULE:StopTrackingCollectedItems()
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

function ADVENTURE_TRACKER_MODULE:OnTrackableItemCollected(trackableType, trackableID)
	local block = self:GetBlock(ContentTrackingUtil.MakeCombinedID(trackableType, trackableID));

	if block and block.objective then
		block.objective.Check:Show();
		block.objective.Sheen.Anim:Play();
		block.objective.Glow.Anim:Play();
		block.objective.CheckFlash.Anim:Play();
		block.objective.block = block;
		block.objective.state = "ANIMATING";
		AdventureObjectiveTracker_AnimateReward(trackableID, block, block.posIndex, self);
		PlaySound(SOUNDKIT.CONTENT_TRACKING_ITEM_ACQUIRED_TOAST);
	elseif C_ContentTracking.IsTracking(trackableType, trackableID) and self.lastBlock then
		--If no block is found, but we are tracking the item, and the last block is visible, show animation at the bottom of the tracker module
		AdventureObjectiveTracker_AnimateReward(trackableID, self.lastBlock, 0, self);
		AdventureObjectiveTrackerBonusRewardsFrame:SetPoint("TOPRIGHT", self.lastBlock, "BOTTOMLEFT");
		PlaySound(SOUNDKIT.CONTENT_TRACKING_ITEM_ACQUIRED_TOAST);
	elseif C_ContentTracking.IsTracking(trackableType, trackableID) and (ObjectiveTrackerBlocksFrame.AdventureHeader:IsShown() and self:IsCollapsed()) then
		--If no block is found, but we are tracking the item, and the header is visible and collapsed, show animation next to the module header
		AdventureObjectiveTracker_AnimateReward(trackableID, ObjectiveTrackerBlocksFrame.AdventureHeader, 0, self);
		AdventureObjectiveTrackerBonusRewardsFrame:SetPoint("TOPRIGHT", ObjectiveTrackerBlocksFrame.AdventureHeader, "TOPLEFT");
		PlaySound(SOUNDKIT.CONTENT_TRACKING_ITEM_ACQUIRED_TOAST);
	elseif C_ContentTracking.IsTracking(trackableType, trackableID) then
		--If no block or header is found, but we are tracking the item, show animation at the bottom of the objective tracker
		AdventureObjectiveTracker_AnimateReward(trackableID, ObjectiveTrackerFrame, 0, self);
		AdventureObjectiveTrackerBonusRewardsFrame:SetPoint("TOPRIGHT", ObjectiveTrackerFrame, "BOTTOMLEFT", 20, 16);
		PlaySound(SOUNDKIT.CONTENT_TRACKING_ITEM_ACQUIRED_TOAST);
	end

	if not self.collectedIds then
		self.collectedIds = { };
	end
	self.collectedIds[trackableID] = trackableType;
end

function ADVENTURE_TRACKER_MODULE:RefreshAll()
	self:BeginLayout();
	self:EnumerateTrackables(GenerateClosure(self.ProcessTrackingEntry, self));
	self:EndLayout();
end

function ADVENTURE_TRACKER_MODULE:Update()
	if not ContentTrackingUtil.IsContentTrackingEnabled() then
		self:BeginLayout();
		self:EndLayout();
		return;
	end

	if OBJECTIVE_TRACKER_UPDATE_REASON == OBJECTIVE_TRACKER_UPDATE_SUPER_TRACK_CHANGED then
		self:RefreshAll();
		return;
	elseif OBJECTIVE_TRACKER_UPDATE_REASON == OBJECTIVE_TRACKER_UPDATE_TRANSMOG_COLLECTED then
		self:OnTrackableItemCollected(Enum.ContentTrackingType.Appearance, OBJECTIVE_TRACKER_UPDATE_ID);
		return;
	end

	self:StopTrackingCollectedItems();
	self:RefreshAll();
end
