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
			rootDescription:CreateRadio(mapGroupMemberInfo.name, IsSelected, SetSelected, mapGroupMemberInfo);
		end
	end);

	return true;
end

function WorldMapFloorNavigationFrameMixin:Refresh()
	local mapID = self:GetParent():GetMapID();
	local shown = self:RefreshMenu(mapID);
	self:SetShown(shown);
end

WorldMapTrackingOptionsButtonMixin = { };

function WorldMapTrackingOptionsButtonMixin:OnShow()
	local function IsSelected(cvar)
		return GetCVarBool(cvar);
	end

	local function SetSelected(cvar)
		self:OnSelection(cvar, not IsSelected(cvar));
	end

	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_WORLD_MAP_TRACKING");

		rootDescription:CreateTitle(WORLD_MAP_FILTER_TITLE);
		rootDescription:CreateCheckbox(SHOW_QUEST_OBJECTIVES_ON_MAP_TEXT, IsSelected, SetSelected, "questPOI");

		local prof1, prof2, arch, fish, cook, firstAid = GetProfessions();
		if arch then
			rootDescription:CreateCheckbox(ARCHAEOLOGY_SHOW_DIG_SITES, IsSelected, SetSelected, "digSites");
		end

		local mapID = self:GetParent():GetMapID();
		if not mapID or not MapUtil.MapHasEmissaries(mapID) then
			return;
		end

		if prof1 or prof2 then
			rootDescription:CreateCheckbox(SHOW_PRIMARY_PROFESSION_ON_MAP_TEXT, IsSelected, SetSelected, "primaryProfessionsFilter");
		end

		if fish or cook or firstAid then
			rootDescription:CreateCheckbox(SHOW_SECONDARY_PROFESSION_ON_MAP_TEXT, IsSelected, SetSelected, "secondaryProfessionsFilter");
		end

		rootDescription:CreateDivider();

		rootDescription:CreateTitle(WORLD_QUEST_REWARD_FILTERS_TITLE);
		rootDescription:CreateCheckbox(WORLD_QUEST_REWARD_FILTERS_RESOURCES, IsSelected, SetSelected, "worldQuestFilterResources");
		rootDescription:CreateCheckbox(WORLD_QUEST_REWARD_FILTERS_ARTIFACT_POWER, IsSelected, SetSelected, "worldQuestFilterArtifactPower");
		rootDescription:CreateCheckbox(WORLD_QUEST_REWARD_FILTERS_GOLD, IsSelected, SetSelected, "worldQuestFilterGold");
		rootDescription:CreateCheckbox(WORLD_QUEST_REWARD_FILTERS_EQUIPMENT, IsSelected, SetSelected, "worldQuestFilterEquipment");
	end);
end

function WorldMapTrackingOptionsButtonMixin:OnMouseDown()
	self.Icon:SetPoint("TOPLEFT", 8, -8);
	self.IconOverlay:Show();
end

function WorldMapTrackingOptionsButtonMixin:OnMouseUp()
	self.Icon:SetPoint("TOPLEFT", self, "TOPLEFT", 6, -6);
	self.IconOverlay:Hide();
end

function WorldMapTrackingOptionsButtonMixin:Refresh()
	-- nothing to do here
end

function WorldMapTrackingOptionsButtonMixin:OnSelection(cvar, checked)
	if (cvar == "questPOI") then
		SetCVar("questPOI", checked and "1" or "0", "QUEST_POI");
	elseif (cvar == "digSites") then
		SetCVar("digSites", checked and "1" or "0", "SHOW_DIG_SITES");
	elseif (cvar == "tamers") then
		SetCVar("showTamers", checked and "1" or "0", "SHOW_TAMERS");
	elseif (cvar == "primaryProfessionsFilter" or cvar == "secondaryProfessionsFilter") then
		SetCVar(cvar, checked and "1" or "0");
	elseif (cvar == "worldQuestFilterResources" or cvar == "worldQuestFilterArtifactPower" or
			cvar == "worldQuestFilterProfessionMaterials" or cvar == "worldQuestFilterGold" or
			cvar == "worldQuestFilterEquipment") then
		-- World quest reward filter cvars
		SetCVar(cvar, checked and "1" or "0");
	end
	self:GetParent():RefreshAllDataProviders();
end

WorldMapNavBarMixin = { };

local function IsMapValidForNavBarDropdown(mapInfo)
	return mapInfo.mapType == Enum.UIMapType.World or mapInfo.mapType == Enum.UIMapType.Continent or mapInfo.mapType == Enum.UIMapType.Zone;
end

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
		if ( IsMapValidForNavBarDropdown(mapInfo) ) then
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
				if ( IsMapValidForNavBarDropdown(childInfo) ) then
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
	--[[if self:GetParent():IsSidePanelShown() then
		self.OpenButton:Hide();
		self.CloseButton:Show();
	else]]
		self.OpenButton:Show();
		self.CloseButton:Hide();
	--end
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