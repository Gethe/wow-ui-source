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
		info.value = mapGroupMemberInfo.mapID;
		info.func = GoToMap;
		info.checked = (mapID == mapGroupMemberInfo.mapID);
		UIDropDownMenu_AddButton(info);
	end
end

WorldMapTrackingOptionsButtonMixin = { };

function WorldMapTrackingOptionsButtonMixin:OnLoad()
	local function InitializeDropDown(self)
		self:GetParent():InitializeDropDown();
	end
	UIDropDownMenu_Initialize(self.DropDown, InitializeDropDown, "MENU");
end

function WorldMapTrackingOptionsButtonMixin:OnClick()
	local mapID = self:GetParent():GetMapID();
	if not mapID then
		return;
	end
	self.DropDown.mapID = mapID;
	ToggleDropDownMenu(1, nil, self.DropDown, self, 0, -5);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
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

function WorldMapTrackingOptionsButtonMixin:OnSelection(value, checked)
	if (checked) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end

	if (value == "quests") then
		SetCVar("questPOI", checked and "1" or "0", "QUEST_POI");
	elseif (value == "digsites") then
		SetCVar("digSites", checked and "1" or "0", "SHOW_DIG_SITES");
	elseif (value == "tamers") then
		SetCVar("showTamers", checked and "1" or "0", "SHOW_TAMERS");
	elseif (value == "primaryProfessionsFilter" or value == "secondaryProfessionsFilter") then
		SetCVar(value, checked and "1" or "0");
	elseif (value == "worldQuestFilterResources" or value == "worldQuestFilterArtifactPower" or
			value == "worldQuestFilterProfessionMaterials" or value == "worldQuestFilterGold" or
			value == "worldQuestFilterEquipment") then
		-- World quest reward filter cvars
		SetCVar(value, checked and "1" or "0");
	end
	self:GetParent():RefreshAllDataProviders();
end

function WorldMapTrackingOptionsButtonMixin:InitializeDropDown()
	local function OnSelection(button)
		self:OnSelection(button.value, button.checked);
	end
	
	local info = UIDropDownMenu_CreateInfo();

	info.isTitle = true;
	info.notCheckable = true;
	info.text = WORLD_MAP_FILTER_TITLE;
	UIDropDownMenu_AddButton(info);

	info.isTitle = nil;
	info.disabled = nil;
	info.notCheckable = nil;
	info.isNotRadio = true;
	info.keepShownOnClick = true;
	info.func = OnSelection;

	info.text = SHOW_QUEST_OBJECTIVES_ON_MAP_TEXT;
	info.value = "quests";
	info.checked = GetCVarBool("questPOI");
	UIDropDownMenu_AddButton(info);

	--[[local prof1, prof2, arch, fish, cook, firstAid = GetProfessions();
	if arch then
		info.text = ARCHAEOLOGY_SHOW_DIG_SITES;
		info.value = "digsites";
		info.checked = GetCVarBool("digSites");
		UIDropDownMenu_AddButton(info);
	end]]

	--[[if CanTrackBattlePets() then
		info.text = SHOW_PET_BATTLES_ON_MAP_TEXT;
		info.value = "tamers";
		info.checked = GetCVarBool("showTamers");
		UIDropDownMenu_AddButton(info);
	end]]

	-- If we aren't on a map which has emissaries don't show the world quest reward filter options.
	local mapID = self:GetParent():GetMapID();
	if not mapID or not MapUtil.MapHasEmissaries(mapID) then
		return;
	end

	if prof1 or prof2 then
		info.text = SHOW_PRIMARY_PROFESSION_ON_MAP_TEXT;
		info.value = "primaryProfessionsFilter";
		info.checked = GetCVarBool("primaryProfessionsFilter");
		UIDropDownMenu_AddButton(info);
	end

	if fish or cook or firstAid then
		info.text = SHOW_SECONDARY_PROFESSION_ON_MAP_TEXT;
		info.value = "secondaryProfessionsFilter";
		info.checked = GetCVarBool("secondaryProfessionsFilter");
		UIDropDownMenu_AddButton(info);
	end

	UIDropDownMenu_AddSeparator();

	info = UIDropDownMenu_CreateInfo();
	info.isTitle = true;
	info.notCheckable = true;
	info.text = WORLD_QUEST_REWARD_FILTERS_TITLE;
	UIDropDownMenu_AddButton(info);
	info.text = nil;

	info.isTitle = nil;
	info.disabled = nil;
	info.notCheckable = nil;
	info.isNotRadio = true;
	info.keepShownOnClick = true;
	info.func = OnSelection;

	info.text = WORLD_QUEST_REWARD_FILTERS_RESOURCES;
	info.value = "worldQuestFilterResources";
	info.checked = GetCVarBool("worldQuestFilterResources");
	UIDropDownMenu_AddButton(info);

	info.text = WORLD_QUEST_REWARD_FILTERS_ARTIFACT_POWER;
	info.value = "worldQuestFilterArtifactPower";
	info.checked = GetCVarBool("worldQuestFilterArtifactPower");
	UIDropDownMenu_AddButton(info);

	info.text = WORLD_QUEST_REWARD_FILTERS_PROFESSION_MATERIALS;
	info.value = "worldQuestFilterProfessionMaterials";
	info.checked = GetCVarBool("worldQuestFilterProfessionMaterials");
	UIDropDownMenu_AddButton(info);

	info.text = WORLD_QUEST_REWARD_FILTERS_GOLD;
	info.value = "worldQuestFilterGold";
	info.checked = GetCVarBool("worldQuestFilterGold");
	UIDropDownMenu_AddButton(info);

	info.text = WORLD_QUEST_REWARD_FILTERS_EQUIPMENT;
	info.value = "worldQuestFilterEquipment";
	info.checked = GetCVarBool("worldQuestFilterEquipment");
	UIDropDownMenu_AddButton(info);
end

WorldMapNavBarMixin = { };

local function IsMapValidForNavBarDropDown(mapInfo)
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
		if ( IsMapValidForNavBarDropDown(mapInfo) ) then
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
				if ( IsMapValidForNavBarDropDown(childInfo) ) then
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
	--[[local nextBattleTime = C_PvP.GetOutdoorPvPWaitTime(self:GetParent():GetMapID());
	if nextBattleTime and not IsInInstance() then
		local battleSec = nextBattleTime % 60;
		local battleMin = math.floor(nextBattleTime / 60) % 60;
		local battleHour = math.floor(nextBattleTime / 3600);
		self.TimeLabel:SetFormattedText(NEXT_BATTLE, battleHour, battleMin, battleSec);
		self.TimeLabel:Show();
	else
		self.TimeLabel:Hide();
	end]]
end

function WorldMapZoneTimerMixin:Refresh()
	-- nothing to do here
end