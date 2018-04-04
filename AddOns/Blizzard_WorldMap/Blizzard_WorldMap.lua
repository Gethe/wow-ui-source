WorldMapMixin = {};

function WorldMapMixin:SetupTitle()
	self.BorderFrame.TitleText:SetText("World Map");
	self.BorderFrame.Bg:SetColorTexture(0, 0, 0, 1);
	self.BorderFrame.Bg:SetParent(self);
	self.BorderFrame.TopTileStreaks:Hide();

	SetPortraitToTexture(self.BorderFrame.portrait, [[Interface/Icons/icon_petfamily_flying]]);
end

function WorldMapMixin:OnLoad()
	MapCanvasMixin.OnLoad(self);

	self:SetupTitle();

	self:SetShouldZoomInOnClick(false);
	self:SetShouldPanOnClick(false);
	self:SetShouldNavigateOnClick(true);
	self:SetShouldZoomInstantly(true);

	self:AddStandardDataProviders();

	self:AddOverlayFrame("WorldMapFloorNavigationFrameTemplate", "FRAME", "TOPLEFT", 20, -20);
	self:AddOverlayFrame("WorldMapTrackingOptionsButtonTemplate", "BUTTON", "TOPRIGHT", -4, -20);
	self:AddOverlayFrame("WorldMapBountyBoardTemplate", "FRAME");
	self:AddOverlayFrame("WorldMapActionButtonTemplate", "FRAME");
	self:AddOverlayFrame("WorldMapNavBarTemplate", "FRAME", "TOPLEFT", 0, 40);
end

function WorldMapMixin:AddStandardDataProviders()
	self:AddDataProvider(CreateFromMixins(MapOverlaysDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(MapHighlightDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(WorldMap_InvasionDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(StorylineQuestDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(BattlefieldFlagDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(BonusObjectiveDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(VehicleDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(EncounterJournalDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(FogOfWarDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(DeathMapDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(QuestBlobDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(WorldMap_DebugDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(ScenarioDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(LandmarkDataProviderMixin));

	local areaLabelDataProvider = CreateFromMixins(AreaLabelDataProviderMixin);	-- no pins
	areaLabelDataProvider:SetContentsScale(0.695);
	areaLabelDataProvider:SetOffsetY(-41);
	self:AddDataProvider(areaLabelDataProvider);

	local groupMembersDataProvider = CreateFromMixins(GroupMembersDataProviderMixin);
	self:AddDataProvider(groupMembersDataProvider);

	local worldQuestDataProvider = CreateFromMixins(WorldMap_WorldQuestDataProviderMixin);
	worldQuestDataProvider:SetMatchWorldMapFilters(true);
	self:AddDataProvider(worldQuestDataProvider);

	local pinFrameLevelsManager = self:GetPinFrameLevelsManager();
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_MAP_OVERLAY");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_QUEST_BLOB");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SCENARIO_BLOB");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_MAP_HIGHLIGHT");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DEBUG", 4);
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_LANDMARK");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_ENCOUNTER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_STORY_LINE");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SCENARIO");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_WORLD_QUEST", 500);
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_ACTIVE_QUEST");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SUPER_TRACKED_QUEST");	
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_AREA_POI");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_VEHICLE_BELOW_GROUP_MEMBER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_BONUS_OBJECTIVE");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_BATTLEFIELD_FLAG");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_GROUP_MEMBER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_VEHICLE_ABOVE_GROUP_MEMBER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_CORPSE");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_AREA_POI_BANNER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_FOG_OF_WAR");
end

function WorldMapMixin:OnMapChanged()
	MapCanvasMixin.OnMapChanged(self);
	self:RefreshOverlayFrames();
end

function WorldMapMixin:OnShow()
	local mapID = C_Map.GetCurrentMapID();
	self:SetMapID(mapID);
	MapCanvasMixin.OnShow(self);
	self:ResetZoom();
end

function WorldMapMixin:OnHide()
	MapCanvasMixin.OnHide(self);
end

function WorldMapMixin:RefreshOverlayFrames()
	if self.overlayFrames then
		for i, frame in ipairs(self.overlayFrames) do
			frame:Refresh();
		end
	end
end

function WorldMapMixin:AddOverlayFrame(templateName, templateType, anchorPoint, offsetX, offsetY)
	local frame = CreateFrame(templateType, nil, self, templateName);
	frame:SetFrameStrata("HIGH");
	if anchorPoint then
		frame:SetPoint(anchorPoint, offsetX, offsetY);
	end

	if not self.overlayFrames then
		self.overlayFrames = { };
	end
	tinsert(self.overlayFrames, frame);

	return frame;
end

function WorldMapMixin:SetOverlayFrameLocation(frame, location)
	frame:ClearAllPoints();
	if location == LE_MAP_OVERLAY_DISPLAY_LOCATION_BOTTOM_LEFT then
		frame:SetPoint("BOTTOMLEFT", 15, 15);
	elseif location == LE_MAP_OVERLAY_DISPLAY_LOCATION_TOP_LEFT then
		frame:SetPoint("TOPLEFT", 15, -15);
	elseif location == LE_MAP_OVERLAY_DISPLAY_LOCATION_BOTTOM_RIGHT then
		frame:SetPoint("BOTTOMRIGHT", -18, 15);
	elseif location == LE_MAP_OVERLAY_DISPLAY_LOCATION_TOP_RIGHT then
		frame:SetPoint("TOPRIGHT", -15, -15);
	end
end