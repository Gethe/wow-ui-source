WorldMapFloorNavigationFrameMixin = { }

function WorldMapFloorNavigationFrameMixin:OnLoad()
	UIDropDownMenu_SetWidth(self, 130);
end

function WorldMapFloorNavigationFrameMixin:Refresh()
	local mapID = self:GetParent():GetMapID();
	local mapGroupID = C_Map.GetMapGroupID(mapID);
	if mapGroupID then
		UIDropDownMenu_Initialize(self, self.InitializeDropDown);
		UIDropDownMenu_SetSelectedValue(self, mapID);
		self:Show();
	else
		self:Hide();
	end
end

function WorldMapFloorNavigationFrameMixin:InitializeDropDown()
	local mapID = self:GetParent():GetMapID();

	local mapGroupID = C_Map.GetMapGroupID(mapID);
	if not mapGroupID then
		return;
	end

	local mapGroupMembersInfo = C_Map.GetMapGroupMembersInfo(mapGroupID);
	if not mapGroupMembersInfo then
		return;
	end

	local function GoToMap(button)
		self:GetParent():SetMapID(button.value);
	end

	local info = UIDropDownMenu_CreateInfo();
	for i, mapGroupMemberInfo in ipairs(mapGroupMembersInfo) do
		info.text = mapGroupMemberInfo.name;
		if self:ShouldShowTrackingIconOnFloor(C_EncounterJournal.GetEncountersOnMap(mapGroupMemberInfo.mapID)) then
			info.text = info.text..CreateAtlasMarkup("waypoint-mappin-minimap-tracked", 20, 20, 0, 0);
		end
		info.value = mapGroupMemberInfo.mapID;
		info.func = GoToMap;
		info.checked = (mapID == mapGroupMemberInfo.mapID);
		UIDropDownMenu_AddButton(info);
	end
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

function WorldMapFilterMixin:Init(text, cvarName, minimapTrackingFilter)
	self.text = text;
	self.cvarName = cvarName; -- It's ok for this to be nil, but it means the setting must be backed by a minimap tracking filter.
	self.minimapTrackingFilter = minimapTrackingFilter;
end

function WorldMapFilterMixin:GetText()
	return self.text;
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
	local filter = self.minimapTrackingFilter;

	for id = 1, C_Minimap.GetNumTrackingTypes() do
		local filterInfo = C_Minimap.GetTrackingFilter(id);
		if filterInfo and filterInfo.filterID == filter then
			C_Minimap.SetTracking(id, set);
			return;
		end
	end
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

WorldMapTrackingOptionsButtonMixin = { };

function WorldMapTrackingOptionsButtonMixin:OnLoad()
	local function InitializeDropDown(dropdown, level)
		self:InitializeDropDown(dropdown, level);
	end
	UIDropDownMenu_SetInitializeFunction(self.DropDown, InitializeDropDown);
	UIDropDownMenu_SetDisplayMode(self.DropDown, "MENU");

	UIResettableDropdownButtonMixin.OnLoad(self);
	self:SetResetFunction(GenerateClosure(self.ResetTrackingOptions, self));

	self:BuildFilterTable();
end

function WorldMapTrackingOptionsButtonMixin:BuildFilterTable()
	self.worldMapFilters = {};

	local function AddFilter(text, cvarName, trackingFilter, cvarIsOnlyIndex)
		local actualCVarName = not cvarIsOnlyIndex and cvarName or nil;
		self.worldMapFilters[cvarName] = CreateAndInitFromMixin(WorldMapFilterMixin, text, actualCVarName, trackingFilter);
	end

	AddFilter(SHOW_QUEST_OBJECTIVES_ON_MAP_TEXT, "questPOI");
	AddFilter(SHOW_WORLD_QUESTS_ON_MAP_TEXT, "questPOIWQ");
	AddFilter(SHOW_PET_BATTLES_ON_MAP_TEXT, "showTamers");
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
	AddFilter(DRAGONRIDING_RACES_MAP_TOGGLE, "dragonRidingRacesFilter");
	AddFilter(DRAGONRIDING_RACES_MAP_TOGGLE, "dragonRidingRacesFilterWQ");
	AddFilter(SHOW_DUNGEON_ENTRACES_ON_MAP_TEXT, "showDungeonEntrancesOnMap");
	AddFilter(CONTENT_TRACKING_MAP_TOGGLE, "contentTrackingFilter");
	AddFilter(ARCHAEOLOGY_SHOW_DIG_SITES, "digSites", Enum.MinimapTrackingFilter.Digsites);
	AddFilter(MINIMAP_TRACKING_TRIVIAL_QUESTS, "trivialQuests", Enum.MinimapTrackingFilter.TrivialQuests, true);
	AddFilter(MINIMAP_TRACKING_ACCOUNT_COMPLETED_QUESTS, "showAccountCompletedQuests", Enum.MinimapTrackingFilter.AccountCompletedQuests, true);
end

function WorldMapTrackingOptionsButtonMixin:GetWorldMapFilters()
	return self.worldMapFilters;
end

function WorldMapTrackingOptionsButtonMixin:GetWorldMapFilter(cvarName)
	return self.worldMapFilters[cvarName];
end

function WorldMapTrackingOptionsButtonMixin:IsUsingDefaultFilters()
	for cvarName, filter in pairs(self:GetWorldMapFilters()) do
		if not filter:IsDefault() then
			return false;
		end
	end

	return true;
end

function WorldMapTrackingOptionsButtonMixin:ResetTrackingOptions()
	for cvarName, filter in pairs(self:GetWorldMapFilters()) do
		filter:ResetToDefault();
	end
end

function WorldMapTrackingOptionsButtonMixin:GenerateCheckBoxFilterTable(cvarName)
	local entry = self:GetWorldMapFilter(cvarName);

	local function SetFilter(set)
		if (set) then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		else
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		end

		entry:Set(set);
		self:Refresh();
	end

	local function GetFilter()
		return entry:Get();
	end

	return { type = FilterComponent.Checkbox, text = entry:GetText(), set = SetFilter , isSet = GetFilter };
end

function WorldMapTrackingOptionsButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_SetTitle(GameTooltip, MAP_FILTER);
	GameTooltip:Show();
end

function WorldMapTrackingOptionsButtonMixin:OnMouseDown(button)
	self.Icon:SetAtlas("Map-Filter-Button-down");

	local mapID = self:GetParent():GetMapID();
	if not mapID then
		return;
	end

	ToggleDropDownMenu(1, nil, self.DropDown, self, 0, -5);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function WorldMapTrackingOptionsButtonMixin:OnMouseUp()
	self.Icon:SetAtlas("Map-Filter-Button");
end

function WorldMapTrackingOptionsButtonMixin:Refresh()
	self:GetParent():RefreshAllDataProviders();
end

function WorldMapTrackingOptionsButtonMixin:ShouldShowWorldQuestFilters(mapID)
	if not mapID or not MapUtil.MapShouldShowWorldQuestFilters(mapID) then
		return false;
	end

	return true;
end

function WorldMapTrackingOptionsButtonMixin:AddFilter(filters, filterNameOrFilter)
	if type(filterNameOrFilter) == "string" then
		table.insert(filters, self:GenerateCheckBoxFilterTable(filterNameOrFilter));
	else
		table.insert(filters, filterNameOrFilter);
	end
end

function WorldMapTrackingOptionsButtonMixin:BuildWorldQuestFilterSubMenu(mapID)
	local filters = {};
	self:AddFilter(filters, { type = FilterComponent.Title, text = WORLD_MAP_FILTER_LABEL_WORLD_QUESTS_SUBMENU_TYPE });
	self:AddFilter(filters, "questPOIWQ");

	if C_Minimap.CanTrackBattlePets() then
		self:AddFilter(filters, "showTamersWQ");
	end

	-- NOTE: For now, this filter is unconditionally added, but MapUtil (or map data) could be extended to support conditionally adding.
	self:AddFilter(filters, "dragonRidingRacesFilterWQ");

	local prof1, prof2, arch, fish, cook, firstAid = GetProfessions();

	if prof1 or prof2 then
		self:AddFilter(filters, "primaryProfessionsFilter");
	end

	if fish or cook or firstAid then
		self:AddFilter(filters, "secondaryProfessionsFilter");
	end

	self:AddFilter(filters, { type = FilterComponent.Title, text = WORLD_QUEST_REWARD_FILTERS_TITLE, });

	-- TODO:: Further adjustments to more cleanly determine filters per map and make this future-proof.
	if MapUtil.IsShadowlandsZoneMap(mapID) then
		self:AddFilter(filters, "worldQuestFilterAnima");
	else
		self:AddFilter(filters, "worldQuestFilterResources");
		self:AddFilter(filters, "worldQuestFilterArtifactPower");
	end

	self:AddFilter(filters, "worldQuestFilterProfessionMaterials");
	self:AddFilter(filters, "worldQuestFilterGold");
	self:AddFilter(filters, "worldQuestFilterEquipment");
	self:AddFilter(filters, "worldQuestFilterReputation");

	return filters;
end

function WorldMapTrackingOptionsButtonMixin:BuildFilters(mapID)
	local filters = {};
	self:AddFilter(filters, { type = FilterComponent.Title, text = WORLD_MAP_FILTER_LABEL_SHOW });

	if self:ShouldShowWorldQuestFilters(mapID) then
		self:AddFilter(filters, { type = FilterComponent.Submenu, text = WORLD_MAP_FILTER_LABEL_WORLD_QUESTS_SUBMENU, value = 1, childrenInfo = { filters = self:BuildWorldQuestFilterSubMenu(mapID), } });
	end

	self:AddFilter(filters, "questPOI");
	self:AddFilter(filters, "dragonRidingRacesFilter");
	self:AddFilter(filters, "showDungeonEntrancesOnMap");
	self:AddFilter(filters, "showTamers");
	self:AddFilter(filters, "trivialQuests");
	self:AddFilter(filters, "showAccountCompletedQuests");
	self:AddFilter(filters, "contentTrackingFilter");

	local prof1, prof2, arch, fish, cook, firstAid = GetProfessions();
	if arch then
		self:AddFilter(filters, "digSites");
	end

	return filters;
end

function WorldMapTrackingOptionsButtonMixin:InitializeDropDown(dropdown, level)
	local filterSystem = {
		onUpdate = GenerateClosure(self.UpdateResetFiltersVisibility, self),
		filters = self:BuildFilters(self:GetParent():GetMapID()),
	};

	FilterDropDownSystem.Initialize(dropdown, filterSystem, level);
end

function WorldMapTrackingOptionsButtonMixin:UpdateResetFiltersVisibility()
	self.ResetButton:SetShown(not self:IsUsingDefaultFilters());
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
	self.Icon:SetPoint("TOPLEFT", self, "TOPLEFT", 6, -6);
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
					if ( C_Map.IsMapValidForNavBarDropDown(mapGroupMemberInfo.mapID) ) then
						buttonData.listFunc = WorldMapNavBarButtonMixin.GetDropDownList;
						break;
					end
				end
			end	
		elseif ( C_Map.IsMapValidForNavBarDropDown(mapInfo.mapID) ) then
			buttonData.listFunc = WorldMapNavBarButtonMixin.GetDropDownList;
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

function WorldMapNavBarButtonMixin:GetDropDownList()
	local list = { };
	local mapInfo = C_Map.GetMapInfo(self.data.id);
	if ( mapInfo ) then
		local children = C_Map.GetMapChildrenInfo(mapInfo.parentMapID);
		if ( children ) then
			for i, childInfo in ipairs(children) do
				if ( C_Map.IsMapValidForNavBarDropDown(childInfo.mapID) ) then
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