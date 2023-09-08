WorldMapMixin = {};

function WorldMapMixin:SynchronizeDisplayState()
	if self:IsMaximized() then
		MaximizeUIPanel(self);
	else
		RestoreUIPanelArea(self);
	end
end

--TODO: Implement minimize/maximize
function WorldMapMixin:Minimize()
	self.isMaximized = false;

	UpdateUIPanelPositions(self);

	self:SynchronizeDisplayState();

	self:OnFrameSizeChanged();
end

function WorldMapMixin:Maximize()
	self.isMaximized = true;

	self:UpdateMaximizedSize();
	self:SynchronizeDisplayState();

	self:OnFrameSizeChanged();
end

function WorldMapMixin:IsMaximized()
	return self.isMaximized;
end

function WorldMapMixin:OnLoad()
	UIPanelWindows[self:GetName()] = { area = "center", pushable = 0, xoffset = 0, yoffset = 0, whileDead = 1, minYOffset = 0, maximizePoint = "CENTER" };

	MapCanvasMixin.OnLoad(self);

	self:SetShouldZoomInOnClick(false);
	self:SetShouldPanOnClick(false);
	self:SetShouldNavigateOnClick(true);
	self:SetShouldZoomInstantly(true);

	self:AddStandardDataProviders();

	self:SetMapID(C_Map.GetFallbackWorldMapID());

	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");

	self:AttachQuestLog();
end

function WorldMapMixin:OnEvent(event, ...)
	MapCanvasMixin.OnEvent(self, event, ...);

	if event == "VARIABLES_LOADED" then
		WorldMapZoneMinimapDropDown_Update();
		if(GetCVarBool("questHelper")) then
			WatchFrame.showObjectives = GetCVarBool("questPOI");
			WorldMapQuestShowObjectives:Show();
			WorldMapQuestShowObjectives:SetChecked(GetCVarBool("questPOI"));
		end
	elseif event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" then
		if self:IsMaximized() then
			self:UpdateMaximizedSize();
		end
	end
end

function WorldMapMixin:AddStandardDataProviders()
	self:AddDataProvider(CreateFromMixins(MapExplorationDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(MapHighlightDataProviderMixin));
	--self:AddDataProvider(CreateFromMixins(WorldMap_InvasionDataProviderMixin));
	--self:AddDataProvider(CreateFromMixins(StorylineQuestDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(BattlefieldFlagDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(BonusObjectiveDataProviderMixin));
	if ClassicExpansionAtLeast(LE_EXPANSION_WRATH_OF_THE_LICH_KING) then
		self:AddDataProvider(CreateFromMixins(VehicleDataProviderMixin));
	end
	--self:AddDataProvider(CreateFromMixins(EncounterJournalDataProviderMixin));
	--self:AddDataProvider(CreateFromMixins(FogOfWarDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(DeathMapDataProviderMixin));
	if ClassicExpansionAtLeast(LE_EXPANSION_WRATH_OF_THE_LICH_KING) then
		self:AddDataProvider(CreateFromMixins(QuestBlobDataProviderMixin));
	end
	--self:AddDataProvider(CreateFromMixins(ScenarioDataProviderMixin));
	--self:AddDataProvider(CreateFromMixins(VignetteDataProviderMixin));
	if ClassicExpansionAtLeast(LE_EXPANSION_WRATH_OF_THE_LICH_KING) then
		self:AddDataProvider(CreateFromMixins(QuestDataProviderMixin));
	end
	--self:AddDataProvider(CreateFromMixins(InvasionDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(GossipDataProviderMixin));
	--self:AddDataProvider(CreateFromMixins(FlightPointDataProviderMixin));
	--self:AddDataProvider(CreateFromMixins(PetTamerDataProviderMixin));
	--self:AddDataProvider(CreateFromMixins(DigSiteDataProviderMixin));
	--self:AddDataProvider(CreateFromMixins(GarrisonPlotDataProviderMixin));
	--self:AddDataProvider(CreateFromMixins(DungeonEntranceDataProviderMixin));
	--self:AddDataProvider(CreateFromMixins(BannerDataProvider));
	--self:AddDataProvider(CreateFromMixins(ContributionCollectorDataProviderMixin));
	--self:AddDataProvider(CreateFromMixins(MapLinkDataProviderMixin));
	--self:AddDataProvider(CreateFromMixins(SelectableGraveyardDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(AreaPOIDataProviderMixin));

	if IsGMClient() then
		self:AddDataProvider(CreateFromMixins(WorldMap_DebugDataProviderMixin));
	end

	local areaLabelDataProvider = CreateFromMixins(AreaLabelDataProviderMixin);	-- no pins
	areaLabelDataProvider:SetOffsetY(-10);
	self:AddDataProvider(areaLabelDataProvider);

	local groupMembersDataProvider = CreateFromMixins(GroupMembersDataProviderMixin);
	self:AddDataProvider(groupMembersDataProvider);

	--[[local worldQuestDataProvider = CreateFromMixins(WorldMap_WorldQuestDataProviderMixin);
	worldQuestDataProvider:SetMatchWorldMapFilters(true);
	worldQuestDataProvider:SetUsesSpellEffect(true);
	worldQuestDataProvider:SetCheckBounties(true);
	worldQuestDataProvider:SetMarkActiveQuests(true);
	self:AddDataProvider(worldQuestDataProvider);]]

	local pinFrameLevelsManager = self:GetPinFrameLevelsManager();
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_MAP_EXPLORATION");
	--pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_GARRISON_PLOT");
	--pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_FOG_OF_WAR");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_QUEST_BLOB");
	--pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SCENARIO_BLOB");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_MAP_HIGHLIGHT");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DEBUG", 4);
	--pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DIG_SITE");
	--pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE");
	--pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_FLIGHT_POINT");
	--pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_INVASION");
	--pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_PET_TAMER");
	--pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SELECTABLE_GRAVEYARD");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_GOSSIP");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_AREA_POI");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DEBUG");
	--pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_MAP_LINK");
	--pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_ENCOUNTER");
	--pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_CONTRIBUTION_COLLECTOR");
	--pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_VIGNETTE", 200);
	--pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_STORY_LINE");
	--pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SCENARIO");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_WORLD_QUEST_PING");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_WORLD_QUEST", 500);
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_ACTIVE_QUEST", C_QuestLog.GetMaxNumQuests());
	--pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SUPER_TRACKED_QUEST");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_VEHICLE_BELOW_GROUP_MEMBER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_BONUS_OBJECTIVE");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_BATTLEFIELD_FLAG");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_GROUP_MEMBER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_VEHICLE_ABOVE_GROUP_MEMBER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_CORPSE");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_AREA_POI_BANNER");
end

function WorldMapMixin:OnMapChanged()
	MapCanvasMixin.OnMapChanged(self);
	self:RefreshQuestLog();

	if C_MapInternal then
		C_MapInternal.SetDebugMap(self:GetMapID());
	end

	CloseDropDownMenus();

	-- Enable/Disable zoom out button
	self.continentInfo = self:GetCurrentMapContinent();
	if (self.continentInfo) then
		WorldMapZoomOutButton:Enable();
	else
		WorldMapZoomOutButton:Disable();
	end

	-- Update dropdown text.
	WorldMapContinentDropDown_Update(self.ContinentDropDown);
	WorldMapZoneDropDown_Update(self.ZoneDropDown);
end

function WorldMapMixin:OnShow()
	local mapID = MapUtil.GetDisplayableMapForPlayer();
	self:SetMapID(mapID);
	MapCanvasMixin.OnShow(self);
	self:ResetZoom();

	PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN);

	WorldMapZoneMinimapDropDown_Update();

	--TODO: Implement minimize/maximize
	--[[local miniWorldMap = GetCVarBool("miniWorldMap");
	local maximized = self:IsMaximized();
	if miniWorldMap ~= maximized then
		if miniWorldMap then
			self.BorderFrame.MaximizeMinimizeFrame:Minimize();
		else
			self.BorderFrame.MaximizeMinimizeFrame:Maximize();
		end
	end]]
end

function WorldMapMixin:OnHide()
	MapCanvasMixin.OnHide(self);

	PlaySound(SOUNDKIT.IG_QUEST_LOG_CLOSE);
end

function WorldMapMixin:UpdateMaximizedSize()
	assert(self:IsMaximized());

	--TODO: Implement minimize/maximize
	--[[local parentWidth, parentHeight = self:GetParent():GetSize();
	local SCREEN_BORDER_PIXELS = 30;
	parentWidth = parentWidth - SCREEN_BORDER_PIXELS;

	local unclampedWidth = ((parentHeight) * self.minimizedWidth) / (self.minimizedHeight);
	local clampedWidth = math.min(parentWidth, unclampedWidth);

	local unclampedHeight = parentHeight;
	local clampHeight = ((parentHeight) * (clampedWidth / unclampedWidth));
	self:SetSize(math.floor(clampedWidth), math.floor(clampHeight));

	SetUIPanelAttribute(self, "bottomClampOverride", (unclampedHeight - clampHeight) / 2);]]

	UpdateUIPanelPositions(self);

	self:OnFrameSizeChanged();
end

function WorldMapMixin:GetCurrentMapContinent()
	local mapID = self:GetMapID();

	if (mapID) then
		local mapInfo = C_Map.GetMapInfo(mapID);
		if ( not mapInfo or mapInfo.mapType <= Enum.UIMapType.World) then
			-- If we are above the continent level (e.g. World), return nil.
			return nil;
		elseif (mapInfo.mapType == Enum.UIMapType.Continent) then
			-- Easy case; we're on the continent level.
			return mapInfo;
		else
			-- If we're in a zone, find our parent continent.
			local continentInfo = MapUtil.GetMapParentInfo(mapID, Enum.UIMapType.Continent);
			return continentInfo;
		end
	end

	return nil;
end

-- ============================================ QUEST LOG ===============================================================================

function WorldMapMixin:AttachQuestLog()
	QuestMapFrame:SetParent(self);
	QuestMapFrame:SetFrameStrata("HIGH");
	QuestMapFrame:ClearAllPoints();
	QuestMapFrame:SetPoint("TOPRIGHT", -34, -64);
	QuestMapFrame:SetPoint("BOTTOMRIGHT", -34, 26);
	QuestMapFrame:Hide();
	self.QuestLog = QuestMapFrame;
end

function WorldMapMixin:SetHighlightedQuestID(questID)
	self:TriggerEvent("SetHighlightedQuestID", questID);
end

function WorldMapMixin:ClearHighlightedQuestID()
	self:TriggerEvent("ClearHighlightedQuestID");
end

function WorldMapMixin:SetFocusedQuestID(questID)
	self:TriggerEvent("SetFocusedQuestID", questID);
end

function WorldMapMixin:ClearFocusedQuestID()
	self:TriggerEvent("ClearFocusedQuestID");
end

function WorldMapMixin:PingQuestID(questID)
	if self:IsVisible() then
		self:TriggerEvent("PingQuestID", questID);
	end
end

-- ============================================ GLOBAL API ===============================================================================
function ToggleWorldMap()
	WorldMapFrame:HandleUserActionToggleSelf();
end

function OpenWorldMap(mapID)
	WorldMapFrame:HandleUserActionOpenSelf(mapID);
end

-- ============================================ DROPDOWNS ===============================================================================

-- Cache variables so that we don't have to recompute the dropdown buttons more than once.
local continentDropDownButtons = nil;
local zoneDropDownCache = { }; -- Key is continent ID; value is a list of buttons.

function WorldMapContinentDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, WorldMapContinentDropDown_Initialize);
	UIDropDownMenu_SetWidth(self, 130);
end

function WorldMapContinentDropDown_Initialize(self)
	local mapID = _G["WorldMapFrame"]:GetMapID();
	if (mapID) then
		-- Work our way back up to the top (Cosmic), then move down to find the continents.
		local azerothMapInfo = MapUtil.GetMapParentInfo(mapID, Enum.UIMapType.Cosmic, TOPMOST);
		if (azerothMapInfo.mapID) then

			-- If we don't have a cached button list, we'll need to create it here.
			if (not continentDropDownButtons) then
				continentDropDownButtons = { };
				-- Get the continents.
				local continents = { };
				local topLevelChildren = C_Map.GetMapChildrenInfo(azerothMapInfo.mapID);
				-- The top level (Cosmic) can have both Continent and World children.
				-- We want to add the Continent children to our list of Continents,
				-- and we want to query the Worlds for any Continents they might have.
				if (topLevelChildren) then
					for i, mapInfo in ipairs(topLevelChildren) do
						if (mapInfo.mapType == Enum.UIMapType.Continent) then
							tinsert(continents, mapInfo);
						end
						if (mapInfo.mapType == Enum.UIMapType.World) then
							local worldChildren = C_Map.GetMapChildrenInfo(mapInfo.mapID);
							if (worldChildren) then
								for k, worldChild in ipairs(worldChildren) do
									if (worldChild.mapType == Enum.UIMapType.Continent) then
										tinsert(continents, worldChild);
									end
								end
							end
						end
					end
				end
				if ( continents ) then
					local info;
					for i, continentInfo in ipairs(continents) do
						-- We'll only add Continent-type maps to our dropdown.
						if (continentInfo.mapType == Enum.UIMapType.Continent) then
							info = {};
							info.value = continentInfo.mapID;
							info.text = continentInfo.name;
							info.func = function(self) _G["WorldMapFrame"]:SetMapID(self.value); end;
							info.checked = function(self)  if (_G["WorldMapFrame"].continentInfo) then return _G["WorldMapFrame"].continentInfo.mapID == self.value; end end;
							info.classicChecks = true;

							-- Save our button list.
							tinsert(continentDropDownButtons, info);
						end
					end
				end
			end

			for i, entry in ipairs(continentDropDownButtons) do
				UIDropDownMenu_AddButton(entry);
			end
		end
	end
end

function WorldMapContinentDropDown_Update(self)
	local continentInfo = _G["WorldMapFrame"].continentInfo;
	if (continentInfo) then
		--[[
			HACK: This panel is in unusual situation of 1. having two drop downs and 2. needing to change the text display for the drop downs outside of an OnClick.
			Unfortunately, UIDropDownMenu doesn't handle this setup very well, so functions like UIDropDownMenu_SetSelectedValue won't work.

			One potential fix is to call _Initialize before the value is set each time, but that tanks performance when changing maps.
			So we'll go with the hacky way, and just set the raw text value rather than using the DropDown functions.
		]]
		self.Text:SetText(continentInfo.name);
	else
		UIDropDownMenu_ClearAll(self);
	end
end

function WorldMapZoneDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, WorldMapZoneDropDown_Initialize);
	UIDropDownMenu_SetWidth(self, 130);
end

function WorldMapZoneDropDown_Initialize(self)
	-- Start at the current continent and work our way down.
	local continentInfo = _G["WorldMapFrame"].continentInfo;
	if (continentInfo) then

		-- If we don't have a cached button list, we'll need to create it here.
		if (not zoneDropDownCache[continentInfo.mapID]) then
			local zones = C_Map.GetMapChildrenInfo(continentInfo.mapID);
			if (zones) then
				local info;
				local list = {};
				for i, zoneInfo in ipairs(zones) do
					info = {};
					info.value = zoneInfo.mapID;
					info.text = zoneInfo.name;
					info.func = function(self) _G["WorldMapFrame"]:SetMapID(self.value); end;
					info.checked = function(self) return _G["WorldMapFrame"]:GetMapID() == self.value; end;
					info.classicChecks = true;
					tinsert(list, info);
				end
				table.sort(list, function(entry1, entry2) return entry1.text < entry2.text; end);

				-- Save our button list.
				tinsert(zoneDropDownCache, continentInfo.mapID, list);
			end
		end

		for i, entry in ipairs(zoneDropDownCache[continentInfo.mapID]) do
			UIDropDownMenu_AddButton(entry);
		end
	end
end

function WorldMapZoneMinimapDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, WorldMapZoneMinimapDropDown_Initialize);
	UIDropDownMenu_SetWidth(self, 130);
end

function WorldMapZoneMinimapDropDown_Initialize()
	for index = 1, 3 do
		local info = UIDropDownMenu_CreateInfo();
		info.value = tostring(index - 1);
		info.text = WorldMapZoneMinimapDropDown_GetText(info.value);
		info.func = WorldMapZoneMinimapDropDown_OnClick;
		info.classicChecks = true;
		-- info.checked skipped because the checked property is assigned
		-- in the dropdown by selection comparison
		UIDropDownMenu_AddButton(info);
	end
end

function WorldMapZoneMinimapDropDown_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT");
	local bindingKeyStr = GetBindingKey("TOGGLEBATTLEFIELDMINIMAP");
	local text = TOGGLE_BATTLEFIELDMINIMAP_TOOLTIP_NO_SHORTCUT;
	if(bindingKeyStr) then
		text = TOGGLE_BATTLEFIELDMINIMAP_TOOLTIP:format(bindingKeyStr);
	end
	GameTooltip:SetText(text, nil, nil, nil, nil, 1);
	GameTooltip:Show();
end

function WorldMapZoneMinimapDropDown_OnLeave(self)
	GameTooltip:Hide();
end

function WorldMapZoneMinimapDropDown_GetText(value)
	if ( value == "0" ) then
		return BATTLEFIELD_MINIMAP_SHOW_NEVER;
	elseif ( value == "1" ) then
		return BATTLEFIELD_MINIMAP_SHOW_BATTLEGROUNDS;
	elseif ( value == "2" ) then
		return BATTLEFIELD_MINIMAP_SHOW_ALWAYS;
	end
	return nil;
end

function WorldMapZoneMinimapDropDown_Update()
	local value = GetCVar("showBattlefieldMinimap");
	UIDropDownMenu_SetSelectedValue(WorldMapZoneMinimapDropDown, value);
	UIDropDownMenu_SetText(WorldMapZoneMinimapDropDown, WorldMapZoneMinimapDropDown_GetText(value));
end

function WorldMapZoneMinimapDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(WorldMapZoneMinimapDropDown, self.value);
	SetCVar("showBattlefieldMinimap", self.value);

	if ( DoesInstanceTypeMatchBattlefieldMapSettings()) then
		if ( not BattlefieldMapFrame ) then
			BattlefieldMap_LoadUI();
		end
		BattlefieldMapFrame:Show();
	else
		if ( BattlefieldMapFrame ) then
			BattlefieldMapFrame:Hide();
		end
	end
end

function WorldMapZoneDropDown_Update(self)
	UIDropDownMenu_ClearAll(self);

	local mapID = _G["WorldMapFrame"]:GetMapID();
	if (mapID) then
		local mapInfo = C_Map.GetMapInfo(mapID);
		if (mapInfo.mapType > Enum.UIMapType.Continent) then
			--[[
				HACK: This panel is in unusual situation of 1. having two drop downs and 2. needing to change the text display for the drop downs outside of an OnClick.
				Unfortunately, UIDropDownMenu doesn't handle this setup very well, so functions like UIDropDownMenu_SetSelectedValue won't work.

				One potential fix is to call _Initialize before the value is set each time, but that tanks performance when changing maps.
				So we'll go with the hacky way, and just set the raw text value rather than using the DropDown functions.
			]]
			self.Text:SetText(mapInfo.name);
		end
	end
end

function DoesInstanceTypeMatchBattlefieldMapSettings()
	local instanceType = GetBattlefieldMapInstanceType();
	local value = GetCVar("showBattlefieldMinimap");

	if instanceType == "pvp" then
		return value == "1" or value == "2";
	elseif instanceType == "none" then
		return value == "2";
	end
	return false;
end

-- ============================================ QUEST HELPER ===============================================================================
function WorldMapQuestShowObjectives_Toggle()
	local isChecked = WorldMapQuestShowObjectives:GetChecked();

	if ( isChecked ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		WatchFrame.showObjectives = true;
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
		WatchFrame.showObjectives = nil;
		WatchFrame_Update();
	end
	QuestLog_UpdateMapButton();
	SetCVar("questPOI", isChecked);
end

function WorldMapTrackQuest_Toggle()
	local isChecked =  WorldMapTrackQuest:GetChecked();
	if ( isChecked ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end				

	local questID = QuestMapFrame.DetailsFrame.questID;
	local questIndex = GetQuestLogIndexByID(questID);
	_QuestLog_ToggleQuestWatch(questIndex);

	QuestMapFrame_ShowQuestDetails(questID);
end