WorldMapFloorNavigationFrameMixin = { }

function WorldMapFloorNavigationFrameMixin:RefreshMenu(mapID)
	if not mapID then
		return false;
	end

	local mapGroupID = C_Map.GetMapGroupID(mapID);
	if not mapGroupID then
		return false;
	end

	local mapGroupMembersInfo = C_Map.GetMapGroupMembersInfo(mapGroupID);
	if not mapGroupMembersInfo then
		return false;
	end

	local function IsSelected(mapGroupMemberInfo)
		return mapID == mapGroupMemberInfo.mapID;
	end

	local function SetSelected(mapGroupMemberInfo)
		self:GetParent():SetMapID(mapGroupMemberInfo.mapID);
	end

	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_WORLD_MAP_FLOOR_NAV");

		for index, mapGroupMemberInfo in ipairs(mapGroupMembersInfo) do
			local text = mapGroupMemberInfo.name;
			if self:ShouldShowTrackingIconOnFloor(C_EncounterJournal.GetEncountersOnMap(mapGroupMemberInfo.mapID)) then
				text = text..CreateAtlasMarkup("waypoint-mappin-minimap-tracked", 20, 20, 0, 0);
			end

			rootDescription:CreateRadio(text, IsSelected, SetSelected, mapGroupMemberInfo);
		end
	end);

	return true;
end

function WorldMapFloorNavigationFrameMixin:Refresh()
	local mapID = self:GetParent():GetMapID();
	local shown = self:RefreshMenu(mapID);
	self:SetShown(shown);
end

function WorldMapFloorNavigationFrameMixin:ShouldShowTrackingIconOnFloor(encountersOnFloor)
	if not ContentTrackingUtil.IsContentTrackingEnabled() or not GetCVarBool("contentTrackingFilter") then
		return false;
	end
	for index, mapEncounterInfo in ipairs(encountersOnFloor) do
		if ContentTrackingUtil.IsContentTrackedInEncounter(mapEncounterInfo.encounterID) then
			return true;
		end
	end
	return false;
end

local WorldMapFilterMixin = {};

function WorldMapFilterMixin:Init(text, cvarName, tooltipText, minimapTrackingFilter)
	self.text = text;
	self.tooltipText = tooltipText;
	self.cvarName = cvarName; -- It's ok for this to be nil, but it means the setting must be backed by a minimap tracking filter.
	self.minimapTrackingFilter = minimapTrackingFilter;
end

function WorldMapFilterMixin:GetText()
	return self.text;
end

function WorldMapFilterMixin:GetTooltipText()
	return self.tooltipText;
end

function WorldMapFilterMixin:Set(set)
	if self.cvarName then
		SetCVar(self.cvarName, set and "1" or "0");
	end

	if self.minimapTrackingFilter then
		self:SetTrackingFilter(set);
	end
end

function WorldMapFilterMixin:SetTrackingFilter(set)
	assertsafe(self.minimapTrackingFilter);
	MinimapUtil.SetTrackingFilterByFilterID(self.minimapTrackingFilter, set);
end

function WorldMapFilterMixin:Get()
	if self.cvarName and not GetCVarBool(self.cvarName) then
		return false;
	end

	if self.minimapTrackingFilter and C_Minimap.IsFilteredOut(self.minimapTrackingFilter) then
		return false;
	end

	return true;
end

function WorldMapFilterMixin:GetDefault()
	-- In this case, the default value should use a single source of truth which prefers cvar, but will fall back to the tracking filter.
	if self.cvarName then
		-- NOTE: This is not completely correct, but the :Set function will set the values to "1" or "0", legacy!
		return GetCVarDefault(self.cvarName) == "1";
	end

	if self.minimapTrackingFilter then
		return C_Minimap.GetDefaultTrackingValue(self.minimapTrackingFilter);
	end
end

function WorldMapFilterMixin:IsDefault()
	return self:Get() == self:GetDefault();
end

function WorldMapFilterMixin:ResetToDefault()
	if not self:IsDefault() then
		self:Set(self:GetDefault());
	end
end

WorldMapTrackingOptionsFilterCounterMixin = {};

function WorldMapTrackingOptionsFilterCounterMixin:OnEnter()
	self:TryShowTooltip();
end

function WorldMapTrackingOptionsFilterCounterMixin:TryShowTooltip()
	if (not self.activeFilters or #self.activeFilters < 1) then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
	GameTooltip_AddNormalLine(GameTooltip, WORLD_MAP_FILTER_COUNTER_TOOLTIP:format(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(table.concat(self.activeFilters, LIST_DELIMITER))));
	GameTooltip:Show();
end

function WorldMapTrackingOptionsFilterCounterMixin:OnLeave()
	GameTooltip_Hide();
end

function WorldMapTrackingOptionsFilterCounterMixin:FullRefresh()
	self:RefreshActiveFilterList();
	self:RefreshActiveFilterCounter();
	self:RefreshVisibility();
end

function WorldMapTrackingOptionsFilterCounterMixin:RefreshActiveFilterList()
	self.activeFilters = self:GetParent():GetActiveFilters();
end

function WorldMapTrackingOptionsFilterCounterMixin:RefreshActiveFilterCounter()
	local numActiveFilters = self.activeFilters and #self.activeFilters or 0;
	self.Count:SetText(numActiveFilters);
	self.Count:SetShown(numActiveFilters > 0);
end

function WorldMapTrackingOptionsFilterCounterMixin:RefreshVisibility()
	self:SetShown(self.activeFilters and #self.activeFilters > 0);
end

WorldMapTrackingOptionsButtonMixin = CreateFromMixins(WowDropdownFilterBehaviorMixin);

function WorldMapTrackingOptionsButtonMixin:OnLoad()
	WowDropdownFilterBehaviorMixin.OnLoad(self);

	self:BuildFilterTable();
end

function WorldMapTrackingOptionsButtonMixin:OnShow()
	WowDropdownFilterBehaviorMixin.OnShow(self);

	self:SetupMenu();

	self:RefreshFilterCounter();
	self:RefreshAccountCompletedQuestFilterTutorial();
end

local function IsFilterChecked(filter)
	return filter:Get();
end

local function SetFilterChecked(filter)
	local set = IsFilterChecked(filter);
	filter:Set(not set);
end

function WorldMapTrackingOptionsButtonMixin:GetActiveFilters()
	local activeFilters = {};
	for cvarName, filter in pairs(self:GetWorldMapFilters()) do
		-- A filter is considered "active" when it is unchecked, because that means we're not showing those items on the map
		local isFilterActive = not filter:Get();
		if isFilterActive then
			table.insert(activeFilters, filter:GetText());
		end
	end

	return activeFilters;
end

function WorldMapTrackingOptionsButtonMixin:RefreshFilterCounter()
	self.FilterCounter:FullRefresh();
	self.FilterCounterBanner:SetShown(self.FilterCounter:IsShown());
end

function WorldMapTrackingOptionsButtonMixin:SetupMenu()
	self:SetIsDefaultCallback(function()
		for cvarName, filter in pairs(self:GetWorldMapFilters()) do
			if not filter:IsDefault() then
				return false;
			end
		end

		return true;
	end);

	self:SetDefaultCallback(function()
		for cvarName, filter in pairs(self:GetWorldMapFilters()) do
			filter:ResetToDefault();
		end
		self:RefreshFilterCounter();
	end);

	DropdownButtonMixin.SetupMenu(self, function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_WORLD_MAP_TRACKING");

		local mapID = self:GetParent():GetMapID();
		local prof1, prof2, arch, fish, cook, firstAid = GetProfessions();

		rootDescription:CreateTitle(WORLD_MAP_FILTER_LABEL_SHOW);

		local function AddFilter(parent, cvarName)
			local filter = self:GetWorldMapFilter(cvarName);
			local checkbox = parent:CreateCheckbox(filter:GetText(), IsFilterChecked, function() SetFilterChecked(filter); self:RefreshFilterCounter(); end, filter);
			local tooltipText = filter:GetTooltipText();
			if tooltipText then
				checkbox:SetOnEnter(function(button)
					GameTooltip:ClearAllPoints();
					GameTooltip:SetPoint("RIGHT", button, "LEFT", -3, 0);
					GameTooltip:SetOwner(button, "ANCHOR_PRESERVE");
					GameTooltip_SetTitle(GameTooltip, filter:GetText());
					GameTooltip_AddNormalLine(GameTooltip, tooltipText);
					GameTooltip:Show();
				end);
				checkbox:SetOnLeave(function(button)
					GameTooltip:Hide();
				end);
			end
			return checkbox;
		end

		local function AddFilterWithNewIndicator(description, cvarName, tutorialBit)
			local filter = AddFilter(description, cvarName);
			filter:AddInitializer(function(button, description, menu)
				if not GetCVarBitfield("closedInfoFramesAccountWide", tutorialBit) then
					button.newFeatureFrame = MenuTemplates.AttachNewFeatureFrame(button);
					button.newFeatureFrame:SetPoint("RIGHT", button.leftTexture1, "LEFT", 0, 0);
				end

				button:SetScript("OnHide", function() SetCVarBitfield("closedInfoFramesAccountWide", tutorialBit, true); end)
			end);

			return filter;
		end

		if self:ShouldShowWorldQuestFilters(mapID) then
			local submenu = AddFilter(rootDescription, "questPOIWQ");

			submenu:CreateTitle(WORLD_MAP_FILTER_LABEL_WORLD_QUESTS_SUBMENU_TYPE);
			if C_Minimap.CanTrackBattlePets() then
				AddFilter(submenu, "showTamersWQ");
			end

			-- NOTE: For now, this filter is unconditionally added, but MapUtil (or map data) could be extended to support conditionally adding.
			AddFilter(submenu, "dragonRidingRacesFilterWQ");

			if prof1 or prof2 then
				AddFilter(submenu, "primaryProfessionsFilter");
			end

			if fish or cook or firstAid then
				AddFilter(submenu, "secondaryProfessionsFilter");
			end

			submenu:CreateTitle(WORLD_QUEST_REWARD_FILTERS_TITLE);

			if MapUtil.IsShadowlandsZoneMap(mapID) then
				AddFilter(submenu, "worldQuestFilterAnima");
			else
				AddFilter(submenu, "worldQuestFilterResources");
				AddFilter(submenu, "worldQuestFilterArtifactPower");
			end

			AddFilter(submenu, "worldQuestFilterProfessionMaterials");
			AddFilter(submenu, "worldQuestFilterGold");
			AddFilter(submenu, "worldQuestFilterEquipment");
			AddFilter(submenu, "worldQuestFilterReputation");
		end

		AddFilter(rootDescription, "questPOI");
		AddFilter(rootDescription, "dragonRidingRacesFilter");
		AddFilter(rootDescription, "showDungeonEntrancesOnMap");
		AddFilter(rootDescription, "showDelveEntrancesOnMap");
		AddFilter(rootDescription, "showTamers");
		AddFilterWithNewIndicator(rootDescription, "questPOILocalStory", LE_FRAME_TUTORIAL_ACCOUNT_LOCAL_STORIES_FILTER_SEEN);	
		AddFilter(rootDescription, "trivialQuests");
		AddFilterWithNewIndicator(rootDescription, "showAccountCompletedQuests", LE_FRAME_TUTORIAL_ACCOUNT_COMPLETED_QUESTS_FILTER_SEEN);
		AddFilter(rootDescription, "contentTrackingFilter");

		if arch then
			AddFilter(rootDescription, "digSites");
		end
	end);
end

function WorldMapTrackingOptionsButtonMixin:BuildFilterTable()
	self.worldMapFilters = {};

	local function AddFilter(text, cvarName, tooltipText, trackingFilter, cvarIsOnlyIndex)
		local actualCVarName = not cvarIsOnlyIndex and cvarName or nil;
		self.worldMapFilters[cvarName] = CreateAndInitFromMixin(WorldMapFilterMixin, text, actualCVarName, tooltipText, trackingFilter);
	end

	AddFilter(SHOW_QUEST_OBJECTIVES_ON_MAP_TEXT, "questPOI", QUEST_OBJECTIVES_FILTER_DESCRIPTION);
	AddFilter(SHOW_WORLD_QUESTS_ON_MAP_TEXT, "questPOIWQ", WORLD_QUESTS_FILTER_DESCRIPTION);
	AddFilter(SHOW_PET_BATTLES_ON_MAP_TEXT, "showTamers", PET_BATTLES_FILTER_DESCRIPTION);
	AddFilter(SHOW_PET_BATTLES_ON_MAP_TEXT, "showTamersWQ");
	AddFilter(SHOW_PRIMARY_PROFESSION_ON_MAP_TEXT, "primaryProfessionsFilter");
	AddFilter(SHOW_SECONDARY_PROFESSION_ON_MAP_TEXT, "secondaryProfessionsFilter");
	AddFilter(WORLD_QUEST_REWARD_FILTERS_ANIMA, "worldQuestFilterAnima");
	AddFilter(WORLD_QUEST_REWARD_FILTERS_RESOURCES, "worldQuestFilterResources");
	AddFilter(WORLD_QUEST_REWARD_FILTERS_ARTIFACT_POWER, "worldQuestFilterArtifactPower");
	AddFilter(WORLD_QUEST_REWARD_FILTERS_PROFESSION_MATERIALS, "worldQuestFilterProfessionMaterials");
	AddFilter(WORLD_QUEST_REWARD_FILTERS_GOLD, "worldQuestFilterGold");
	AddFilter(WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, "worldQuestFilterEquipment");
	AddFilter(WORLD_QUEST_REWARD_FILTERS_REPUTATION, "worldQuestFilterReputation");
	AddFilter(DRAGONRIDING_RACES_MAP_TOGGLE, "dragonRidingRacesFilter", SKYRIDING_RACES_FILTER_DESCRIPTION);
	AddFilter(DRAGONRIDING_RACES_MAP_TOGGLE, "dragonRidingRacesFilterWQ");
	AddFilter(SHOW_INSTANCE_ENTRANCES_ON_MAP_TEXT, "showDungeonEntrancesOnMap", INSTANCE_ENTRANCES_FILTER_DESCRIPTION);
	AddFilter(DELVES_SHOW_ENTRACES_ON_MAP_TEXT, "showDelveEntrancesOnMap", DELVE_ENTRANCES_FILTER_DESCRIPTION);
	AddFilter(CONTENT_TRACKING_MAP_TOGGLE, "contentTrackingFilter", TRACKED_ITEMS_FILTER_DESCRIPTION);
	AddFilter(ARCHAEOLOGY_SHOW_DIG_SITES, "digSites", SHOW_DIGSITES_FILTER_DESCRIPTION, Enum.MinimapTrackingFilter.Digsites);
	AddFilter(SHOW_LOCAL_STORY_OFFERS_ON_MAP_TEXT, "questPOILocalStory", LOCAL_STORIES_FILTER_DESCRIPTION);
	AddFilter(MINIMAP_TRACKING_TRIVIAL_QUESTS, "trivialQuests", TRIVIAL_QUESTS_FILTER_DESCRIPTION, Enum.MinimapTrackingFilter.TrivialQuests, true);
	AddFilter(MINIMAP_TRACKING_ACCOUNT_COMPLETED_QUESTS, "showAccountCompletedQuests", ACCOUNT_COMPLETED_QUESTS_FILTER_DESCRIPTION, Enum.MinimapTrackingFilter.AccountCompletedQuests, true);
end

function WorldMapTrackingOptionsButtonMixin:GetWorldMapFilters()
	return self.worldMapFilters;
end

function WorldMapTrackingOptionsButtonMixin:GetWorldMapFilter(cvarName)
	return self.worldMapFilters[cvarName];
end

function WorldMapTrackingOptionsButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, MAP_FILTER);
	GameTooltip:Show();
end

function WorldMapTrackingOptionsButtonMixin:OnMouseDown(button)
	self.Icon:SetAtlas("Map-Filter-Button-down");

	HelpTip:Acknowledge(self, ACCOUNT_COMPLETED_QUESTS_FILTER_TUTORIAL);
end

function WorldMapTrackingOptionsButtonMixin:OnMouseUp()
	self.Icon:SetAtlas("Map-Filter-Button");
end

function WorldMapTrackingOptionsButtonMixin:Refresh()
	self:GetParent():RefreshAllDataProviders();
end

function WorldMapTrackingOptionsButtonMixin:RefreshAccountCompletedQuestFilterTutorial()
	HelpTip:Hide(self, ACCOUNT_COMPLETED_QUESTS_FILTER_TUTORIAL);

	local tutorialAcknowledged = GetCVarBitfield("closedInfoFramesAccountWide", LE_FRAME_TUTORIAL_ACCOUNT_COMPLETED_QUESTS_FILTER);
	if tutorialAcknowledged then
		return;
	end

	local helpTipInfo = {
		text = ACCOUNT_COMPLETED_QUESTS_FILTER_TUTORIAL,
		buttonStyle = HelpTip.ButtonStyle.Close,
		cvarBitfield = "closedInfoFramesAccountWide",
		bitfieldFlag = LE_FRAME_TUTORIAL_ACCOUNT_COMPLETED_QUESTS_FILTER,
		targetPoint = HelpTip.Point.RightEdgeCenter,
		offsetX = -2,
		alignment = HelpTip.Alignment.Center,
		acknowledgeOnHide = false,
		checkCVars = true,
	};
	HelpTip:Show(self, helpTipInfo);
end

function WorldMapTrackingOptionsButtonMixin:ShouldShowWorldQuestFilters(mapID)
	return mapID and MapUtil.MapShouldShowWorldQuestFilters(mapID);
end

WorldMapTrackingPinButtonMixin = { };

function WorldMapTrackingPinButtonMixin:OnLoad()
	self:RegisterEvent("USER_WAYPOINT_UPDATED");
end

function WorldMapTrackingPinButtonMixin:OnEvent()
	self:SetActive(false);
end

function WorldMapTrackingPinButtonMixin:OnMouseDown(button)
	if self:IsEnabled() then
		self.Icon:SetPoint("TOPLEFT", 8, -8);
		self.IconOverlay:Show();
	end
end

function WorldMapTrackingPinButtonMixin:OnMouseUp()
	self.Icon:SetPoint("TOPLEFT", self, "TOPLEFT", 7, -6);
	self.IconOverlay:Hide();
end

function WorldMapTrackingPinButtonMixin:OnClick()
	local shouldSetActive = not self.isActive;
	self:SetActive(shouldSetActive);
	if shouldSetActive then
		PlaySound(SOUNDKIT.UI_MAP_WAYPOINT_BUTTON_CLICK_ON);
	else
		PlaySound(SOUNDKIT.UI_MAP_WAYPOINT_BUTTON_CLICK_OFF);
	end
end

function WorldMapTrackingPinButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, MAP_PIN);
	local mapID = self:GetParent():GetMapID();
	if C_Map.CanSetUserWaypointOnMap(mapID) then
		GameTooltip_AddNormalLine(GameTooltip, MAP_PIN_TOOLTIP);
		GameTooltip_AddBlankLineToTooltip(GameTooltip);
		GameTooltip_AddInstructionLine(GameTooltip, MAP_PIN_TOOLTIP_INSTRUCTIONS);
	else
		GameTooltip_AddErrorLine(GameTooltip, MAP_PIN_INVALID_MAP);
	end
	GameTooltip:Show();
end

function WorldMapTrackingPinButtonMixin:OnHide()
	self:SetActive(false);
end

function WorldMapTrackingPinButtonMixin:Refresh()
	local mapID = self:GetParent():GetMapID();
	if C_Map.CanSetUserWaypointOnMap(mapID) then
		self:Enable();
		self:DesaturateHierarchy(0);
	else
		self:Disable();
		self:DesaturateHierarchy(1);
	end
end

function WorldMapTrackingPinButtonMixin:SetActive(isActive)
	self.isActive = isActive;
	self.ActiveTexture:SetShown(isActive);
	self:GetParent():TriggerEvent("WaypointLocationToggleUpdate", isActive);
end

WorldMapNavBarMixin = { };

function WorldMapNavBarMixin:OnLoad()
	local homeData = {
		name = WORLD,
		OnClick = function(button)
			local TOPMOST = true;
			local cosmicMapInfo = MapUtil.GetMapParentInfo(self:GetParent():GetMapID(), Enum.UIMapType.Cosmic, TOPMOST);
			if cosmicMapInfo then
				self:GoToMap(cosmicMapInfo.mapID)
			end
		end,
	}
	NavBar_Initialize(self, "NavButtonTemplate", homeData, self.home, self.overflow);
end

function WorldMapNavBarMixin:GoToMap(mapID)
	self:GetParent():SetMapID(mapID);
end

function WorldMapNavBarMixin:Refresh()
	local hierarchy = { };
	local mapInfo = C_Map.GetMapInfo(self:GetParent():GetMapID());
	while mapInfo and mapInfo.parentMapID > 0 do
		local buttonData = {
			name = mapInfo.name,
			id = mapInfo.mapID,
			OnClick = WorldMapNavBarButtonMixin.OnClick,
		};
		-- Check if we are on a multifloor map belonging to a UIMapGroup, and if any map within the group should populate a dropdown
		local mapGroupID = C_Map.GetMapGroupID(mapInfo.mapID);
		if ( mapGroupID ) then
			local mapGroupMembersInfo = C_Map.GetMapGroupMembersInfo(mapGroupID);
			if ( mapGroupMembersInfo ) then
				for i, mapGroupMemberInfo in ipairs(mapGroupMembersInfo) do
					if ( C_Map.IsMapValidForNavBarDropdown(mapGroupMemberInfo.mapID) ) then
						buttonData.listFunc = WorldMapNavBarButtonMixin.GetDropdownList;
						break;
					end
				end
			end
		elseif ( C_Map.IsMapValidForNavBarDropdown(mapInfo.mapID) ) then
			buttonData.listFunc = WorldMapNavBarButtonMixin.GetDropdownList;
		end
		tinsert(hierarchy, 1, buttonData);
		mapInfo = C_Map.GetMapInfo(mapInfo.parentMapID);
	end

	NavBar_Reset(self);
	for i, buttonData in ipairs(hierarchy) do
		NavBar_AddButton(self, buttonData);
	end
end

WorldMapNavBarButtonMixin = { };

function WorldMapNavBarButtonMixin:GetDropdownList()
	local list = { };
	local mapInfo = C_Map.GetMapInfo(self.data.id);
	if ( mapInfo ) then
		local children = C_Map.GetMapChildrenInfo(mapInfo.parentMapID);
		if ( children ) then
			for i, childInfo in ipairs(children) do
				if ( C_Map.IsMapValidForNavBarDropdown(childInfo.mapID) ) then
					local entry = { text = childInfo.name, id = childInfo.mapID, func = function(button, mapID) self:GetParent():GoToMap(mapID); end };
					tinsert(list, entry);
				end
			end
			table.sort(list, function(entry1, entry2) return entry1.text < entry2.text; end);
		end
	end
	return list;
end

function WorldMapNavBarButtonMixin:OnClick()
	self:GetParent():GoToMap(self.data.id)
end

WorldMapSidePanelToggleMixin = { };

function WorldMapSidePanelToggleMixin:OnClick()
	self:GetParent():HandleUserActionToggleSidePanel();
	self:Refresh();
end

function WorldMapSidePanelToggleMixin:Refresh()
	if self:GetParent():IsSidePanelShown() then
		self.OpenButton:Hide();
		self.CloseButton:Show();
	else
		self.OpenButton:Show();
		self.CloseButton:Hide();
	end
end

WorldMapZoneTimerMixin = {};

function WorldMapZoneTimerMixin:OnUpdate(elapsed)
	local nextBattleTime = C_PvP.GetOutdoorPvPWaitTime(self:GetParent():GetMapID());
	if nextBattleTime and not IsInInstance() then
		local battleSec = nextBattleTime % 60;
		local battleMin = math.floor(nextBattleTime / 60) % 60;
		local battleHour = math.floor(nextBattleTime / 3600);
		self.TimeLabel:SetFormattedText(NEXT_BATTLE, battleHour, battleMin, battleSec);
		self.TimeLabel:Show();
	else
		self.TimeLabel:Hide();
	end
end

function WorldMapZoneTimerMixin:Refresh()
	-- nothing to do here
end

WorldMapThreatFrameMixin = {};

function WorldMapThreatFrameMixin:OnLoad()
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	self.dirtyModels = true;
end

function WorldMapThreatFrameMixin:OnShow()
	self:Refresh();
	self:RegisterEvent("QUEST_ACCEPTED");
	self:RegisterEvent("QUEST_REMOVED");
end

function WorldMapThreatFrameMixin:OnHide()
	self:UnregisterEvent("QUEST_ACCEPTED");
	self:UnregisterEvent("QUEST_REMOVED");
end

function WorldMapThreatFrameMixin:OnEvent(event)
	if event == "QUEST_ACCEPTED" or event == "QUEST_REMOVED" then
		self:Refresh();
	elseif event == "UI_MODEL_SCENE_INFO_UPDATED" then
		self.dirtyModels = true;
		if self:IsVisible() then
			self:RefreshModels();
		end
	end
end

local function DoActiveThreatMapsMatchBountySet(mapBountySetID)
	local threatMaps = C_QuestLog.GetActiveThreatMaps();
	if threatMaps then
		for i, mapID in ipairs(threatMaps) do
			local displayLocation, lockedQuestID, bountySetID = C_QuestLog.GetBountySetInfoForMapID(mapID);
			if bountySetID == mapBountySetID then
				return true;
			end
		end
	end
	return false;
end

function WorldMapThreatFrameMixin:Refresh()
	local show = false;
	if C_QuestLog.HasActiveThreats() then
		local mapID = self:GetParent():GetMapID();
		if mapID then
			local displayLocation, lockedQuestID, bountySetID = C_QuestLog.GetBountySetInfoForMapID(mapID);
			if displayLocation then
				show = DoActiveThreatMapsMatchBountySet(bountySetID);
			end
		end
	end

	if show then
		self.Background:Show();
		self.Eye:Show();

		if not self.threatQuests then
			self.threatQuests = C_TaskQuest.GetThreatQuests();
		end

		local haveActiveQuest = false;
		for i, questID in ipairs(self.threatQuests) do
			if C_TaskQuest.IsActive(questID) then
				haveActiveQuest = true;
				break;
			end
		end

		self.ModelSceneTop:SetShown(haveActiveQuest);
		self.ModelSceneBottom:SetShown(haveActiveQuest);
		if haveActiveQuest then
			self:RefreshModels();
		end
	else
		self.Background:Hide();
		self.Eye:Hide();
		self.ModelSceneTop:Hide();
		self.ModelSceneBottom:Hide();
	end
end

function WorldMapThreatFrameMixin:RefreshModels()
	if self.dirtyModels then
		self.dirtyModels = false;
		local forceUpdate = true;
		if not self.modelSceneInfoTop then
			self.modelSceneInfoTop = StaticModelInfo.CreateModelSceneEntry(313, 2387313);	-- SPELLS\\7FX_Argus_VoidOrb_State.m2
		end
		if not self.modelSceneInfoBottom then
			self.modelSceneInfoBottom = StaticModelInfo.CreateModelSceneEntry(312, 1715654);-- SPELLS\\8FX_Generic_Void_Shield.m2
		end
		StaticModelInfo.SetupModelScene(self.ModelSceneTop, self.modelSceneInfoTop, forceUpdate);
		StaticModelInfo.SetupModelScene(self.ModelSceneBottom, self.modelSceneInfoBottom, forceUpdate);
	end
end

function WorldMapThreatFrameMixin:SetNextMapForThreat()
	local threatMaps = C_QuestLog.GetActiveThreatMaps();
	if not threatMaps then
		return;
	end

	local currentMapID = self:GetParent():GetMapID();
	local mapIndex = 1;
	-- check if we're on the same map as a threat
	for i, mapID in ipairs(threatMaps) do
		if mapID == currentMapID then
			-- we want the next map
			mapIndex = i + 1;
			break;
		end
	end
	if mapIndex > #threatMaps then
		mapIndex = 1;
	end

	self:GetParent():SetMapID(threatMaps[mapIndex]);
end

WorldMapThreatEyeMixin = { };

function WorldMapThreatEyeMixin:OnShow()
	if not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_THREAT_ICON) then
		local helpTipInfo = {
			text = WORLD_MAP_THREATS_TOOLTIP,
			buttonStyle = HelpTip.ButtonStyle.Close,
			cvarBitfield = "closedInfoFrames",
			bitfieldFlag = LE_FRAME_TUTORIAL_WORLD_MAP_THREAT_ICON,
			targetPoint = HelpTip.Point.TopEdgeCenter,
			alignment = HelpTip.Alignment.Left,
			system = "WorldMap",
			systemPriority = 10,
		};
		HelpTip:Show(self, helpTipInfo);
	end
end

function WorldMapThreatEyeMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -9, -5);
	GameTooltip_SetTitle(GameTooltip, WORLD_MAP_THREATS);
	GameTooltip_AddColoredLine(GameTooltip, WORLD_MAP_THREATS_TOOLTIP, GREEN_FONT_COLOR);
	GameTooltip:Show();
	HelpTip:Acknowledge(self, WORLD_MAP_THREATS_TOOLTIP);
end

function WorldMapThreatEyeMixin:OnMouseDown()
	self:GetParent():SetNextMapForThreat();
end