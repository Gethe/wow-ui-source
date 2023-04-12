UIPanelWindows["FlightMapFrame"] = { area = "center", pushable = 1, showFailedFunc = CloseTaxiMap, allowOtherPanels = 1 };

FlightMapMixin = {};

function FlightMapMixin:SetupTitle()
	self.BorderFrame.Bg:SetColorTexture(0, 0, 0, 1);
	self.BorderFrame.Bg:SetParent(self);
	self.BorderFrame.TopTileStreaks:Hide();
	self:ResetTitleAndPortraitIcon();
end

function FlightMapMixin:ResetTitleAndPortraitIcon()
	self:UpdateTitleAndPortraitIcon(FLIGHT_MAP, [[Interface/Icons/icon_petfamily_flying]]);
end

function FlightMapMixin:UpdateTitleAndPortraitIcon(titleText, portraitIcon)
	self.BorderFrame:SetTitle(titleText);
	self.BorderFrame:SetPortraitToAsset(portraitIcon);
end

function FlightMapMixin:OnLoad()
	MapCanvasMixin.OnLoad(self);

	self:RegisterEvent("TAXIMAP_CLOSED");

	self:SetupTitle();

	self:SetShouldNavigateOnClick(true);
	self:SetShouldNavigateIgnoreZoneMapPositionData(true);

	self:SetShouldZoomInOnClick(true);
	self:SetShouldPanOnClick(false);

	self:AddStandardDataProviders();
end

function FlightMapMixin:OnCanvasScaleChanged()
	MapCanvasMixin.OnCanvasScaleChanged(self);
	local changed = false;
	local scale = self:GetCanvasZoomPercent();
	if ( scale < 0.5 ) then
		changed = self:GetPinFrameLevelsManager():ClearOverride("PIN_FRAME_LEVEL_GROUP_MEMBER");
	else
		changed = self:GetPinFrameLevelsManager():SetOverride("PIN_FRAME_LEVEL_GROUP_MEMBER", "PIN_FRAME_LEVEL_GROUP_MEMBER_ABOVE_FLIGHT");
	end
	if changed then
		self:ReapplyPinFrameLevels("PIN_FRAME_LEVEL_GROUP_MEMBER");
	end
end

function FlightMapMixin:AddStandardDataProviders()
	self:AddDataProvider(CreateFromMixins(FlightMap_ZoneSummaryDataProvider));
	self:AddDataProvider(CreateFromMixins(FlightMap_FlightPathDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(FlightMap_QuestDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(ClickToZoomDataProviderMixin));	-- no pins
	self:AddDataProvider(CreateFromMixins(ZoneLabelDataProviderMixin));	-- no pins
	self:AddDataProvider(CreateFromMixins(FlightMap_AreaPOIProviderMixin));
	self:AddDataProvider(CreateFromMixins(FlightMap_VignetteDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(QuestSessionDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(MapHighlightDataProviderMixin));

	local groupMembersDataProvider = CreateFromMixins(GroupMembersDataProviderMixin);
	groupMembersDataProvider:SetUnitPinSize("player", 0);
	groupMembersDataProvider:SetUnitPinSize("party", 13);
	groupMembersDataProvider:SetUnitPinSize("raid", 13);
	self:AddDataProvider(groupMembersDataProvider);

	local worldQuestDataProvider = CreateFromMixins(FlightMap_WorldQuestDataProviderMixin);
	worldQuestDataProvider:SetMatchWorldMapFilters(true);
	self:AddDataProvider(worldQuestDataProvider);

	local pinFrameLevelsManager = self:GetPinFrameLevelsManager();
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_VIGNETTE", 200);
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_WORLD_QUEST", 500);
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_AREA_POI");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_GROUP_MEMBER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_ACTIVE_QUEST");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SUPER_TRACKED_QUEST");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_FLIGHT_POINT");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_GROUP_MEMBER_ABOVE_FLIGHT");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_MAP_HIGHLIGHT");
end

function FlightMapMixin:OnShow()
	local mapID = GetTaxiMapID();

	self:SetMapID(mapID);

	MapCanvasMixin.OnShow(self);

	local playerPosition = C_Map.GetPlayerMapPosition(mapID, "player");
	local subMapInfo = playerPosition and C_Map.GetMapInfoAtPosition(mapID, playerPosition:GetXY()) or nil;
	if subMapInfo and (subMapInfo.mapID ~= mapID) and FlagsUtil.IsSet(subMapInfo.flags, Enum.UIMapFlag.FlightMapAutoZoom) then
		local centerX, centerY = MapUtil.GetMapCenterOnMap(subMapInfo.mapID, mapID);
		local ignoreScaleRatio = true;
		self:InstantPanAndZoom(self:GetScaleForMaxZoom(), centerX, centerY, ignoreScaleRatio);
	else
		self:ResetZoom();
	end

	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
end

function FlightMapMixin:OnHide()
	CloseTaxiMap();

	MapCanvasMixin.OnHide(self);
	PlaySound(SOUNDKIT.IG_MAINMENU_CLOSE);
end

function FlightMapMixin:OnEvent(event, ...)
	if event == "TAXIMAP_CLOSED" then
		HideUIPanel(self);
	end

	MapCanvasMixin.OnEvent(self, event, ...);
end
