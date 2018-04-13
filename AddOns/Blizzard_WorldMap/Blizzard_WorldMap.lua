WorldMapMixin = {};

function WorldMapMixin:SetupTitle()
	self.BorderFrame.TitleText:SetText(MAP_AND_QUEST_LOG);
	self.BorderFrame.Bg:SetColorTexture(0, 0, 0, 1);
	self.BorderFrame.Bg:SetParent(self);
	self.BorderFrame.TopTileStreaks:Hide();

	SetPortraitToTexture(self.BorderFrame.portrait, [[Interface\QuestFrame\UI-QuestLog-BookIcon]]);
end

function WorldMapMixin:Minimize()
	self.isMaximized = false;

	self:SetSize(self.minimizedWidth, self.minimizedHeight);

	SetUIPanelAttribute(self, "bottomClampOverride", nil);

	ButtonFrameTemplate_ShowPortrait(self.BorderFrame);

	UpdateUIPanelPositions(self);

	self.BorderFrame.MaximizeMinimizeFrame.MinimizeButton:Hide();
	self.BorderFrame.MaximizeMinimizeFrame.MaximizeButton:Show();
	
	self:OnFrameSizeChanged();
end

function WorldMapMixin:Maximize()
	self.isMaximized = true;

	ButtonFrameTemplate_HidePortrait(self.BorderFrame);

	self:UpdateMaximizedSize();

	self.BorderFrame.MaximizeMinimizeFrame.MinimizeButton:Show();
	self.BorderFrame.MaximizeMinimizeFrame.MaximizeButton:Hide();
	
	self:OnFrameSizeChanged();
end

function WorldMapMixin:SetupMinimizeMaximizeButton()
	self.isMinimizedCvar = "miniWorldMap";
	self.minimizedWidth = 702;
	self.minimizedHeight = 536;
	self.questLogWidth = 290;

	local function OnMaximize()
		self:HandleUserActionMaximizeSelf();
	end
	
	self.BorderFrame.MaximizeMinimizeFrame:SetOnMaximizedCallback(OnMaximize);
	
	local function OnMinimize()
		self:HandleUserActionMinimizeSelf();
	end
	
	self.BorderFrame.MaximizeMinimizeFrame:SetOnMinimizedCallback(OnMinimize);
end

function WorldMapMixin:IsMaximized()
	return self.isMaximized;
end

function WorldMapMixin:OnLoad()
	UIPanelWindows[self:GetName()] = { area = "left", pushable = 0, xoffset = 0, yoffset = -45, whileDead = 1, minYOffset = 0 };

	MapCanvasMixin.OnLoad(self);

	self:SetupTitle();
	self:SetupMinimizeMaximizeButton();

	self:SetShouldZoomInOnClick(false);
	self:SetShouldPanOnClick(false);
	self:SetShouldNavigateOnClick(true);
	self:SetShouldZoomInstantly(true);

	self:AddStandardDataProviders();
	self:AddOverlayFrames();
	
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
end

function WorldMapMixin:OnEvent(event, ...)
	MapCanvasMixin.OnEvent(self, event, ...);

	if event == "VARIABLES_LOADED" then
		if self:ShouldBeMinimized() then
			self:Minimize();
		else
			self:Maximize();
		end
	elseif event == "DISPLAY_SIZE_CHANGED" then
		if self:IsMaximized() then
			self:UpdateMaximizedSize();
		end
	end
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
	self:AddDataProvider(CreateFromMixins(ScenarioDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(LandmarkDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(VignetteDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(QuestDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(InvasionDataProviderMixin));

	if IsGMClient() then
		self:AddDataProvider(CreateFromMixins(WorldMap_DebugDataProviderMixin));
	end

	local areaLabelDataProvider = CreateFromMixins(AreaLabelDataProviderMixin);	-- no pins
	areaLabelDataProvider:SetOffsetY(-10);
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
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_INVASION");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_VIGNETTE", 100);
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_ENCOUNTER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_STORY_LINE");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SCENARIO");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_WORLD_QUEST", 500);
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_ACTIVE_QUEST", C_QuestLog.GetMaxNumQuests());
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

function WorldMapMixin:AddOverlayFrames()
	do
		local navBar = self:AddOverlayFrame("WorldMapNavBarTemplate", "FRAME");
		navBar:SetPoint("TOPLEFT", self.TitleCanvasSpacerFrame, "TOPLEFT", 64, -25);
		navBar:SetPoint("BOTTOMRIGHT", self.TitleCanvasSpacerFrame, "BOTTOMRIGHT", -4, 9);
	end

	self:AddOverlayFrame("WorldMapFloorNavigationFrameTemplate", "FRAME", "TOPLEFT", self:GetCanvasContainer(), "TOPLEFT", -15, 2);
	self:AddOverlayFrame("WorldMapTrackingOptionsButtonTemplate", "BUTTON", "TOPRIGHT", self:GetCanvasContainer(), "TOPRIGHT", -4, -2);
	self:AddOverlayFrame("WorldMapBountyBoardTemplate", "FRAME");
	self:AddOverlayFrame("WorldMapActionButtonTemplate", "FRAME");
	self.SidePanelToggle = self:AddOverlayFrame("WorldMapSidePanelToggleTemplate", "BUTTON", "BOTTOMRIGHT", self:GetCanvasContainer(), "BOTTOMRIGHT", -2, 1);
end

function WorldMapMixin:OnMapChanged()
	MapCanvasMixin.OnMapChanged(self);
	self:RefreshOverlayFrames();
end

function WorldMapMixin:OnShow()
	local mapID = C_Map.GetBestMapForUnit("player");
	C_Map.SetMap(mapID);
	self:SetMapID(mapID);
	MapCanvasMixin.OnShow(self);
	self:ResetZoom();

	DoEmote("READ", nil, true);
	PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN);

	PlayerMovementFrameFader.AddDeferredFrame(self, .5, 1.0, .5, function() return GetCVarBool("mapFade") and not self:IsMouseOver() end);
end

function WorldMapMixin:OnHide()
	MapCanvasMixin.OnHide(self);

	CancelEmote();
	PlaySound(SOUNDKIT.IG_QUEST_LOG_CLOSE);

	PlayerMovementFrameFader.RemoveFrame(self);
end

function WorldMapMixin:RefreshOverlayFrames()
	if self.overlayFrames then
		for i, frame in ipairs(self.overlayFrames) do
			frame:Refresh();
		end
	end
end

function WorldMapMixin:AddOverlayFrame(templateName, templateType, anchorPoint, relativeTo, relativePoint, offsetX, offsetY)
	local frame = CreateFrame(templateType, nil, self, templateName);
	if anchorPoint then
		frame:SetPoint(anchorPoint, relativeTo, relativePoint, offsetX, offsetY);
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

function WorldMapMixin:UpdateMaximizedSize()
	assert(self:IsMaximized());

	local parentWidth, parentHeight = self:GetParent():GetSize();
	local SCREEN_BORDER_PIXELS = 30;
	parentWidth = parentWidth - SCREEN_BORDER_PIXELS;

	local spacerFrameHeight = self.TitleCanvasSpacerFrame:GetHeight();
	local unclampedWidth = ((parentHeight - spacerFrameHeight) * self.minimizedWidth) / (self.minimizedHeight - spacerFrameHeight);
	local clampedWidth = math.min(parentWidth, unclampedWidth);

	local unclampedHeight = parentHeight;
	local clampHeight = ((parentHeight - spacerFrameHeight) * (clampedWidth / unclampedWidth)) + spacerFrameHeight;
	self:SetSize(clampedWidth, clampHeight);

	SetUIPanelAttribute(self, "bottomClampOverride", (unclampedHeight - clampHeight) / 2);

	UpdateUIPanelPositions(self);

	self:OnFrameSizeChanged();
end

function WorldMapMixin:UpdateSpacerFrameAnchoring()
	if self.QuestLog and self.QuestLog:IsShown() then
		self.TitleCanvasSpacerFrame:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3 - self.questLogWidth, -67);
	else
		self.TitleCanvasSpacerFrame:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -67);
	end
	self:OnFrameSizeChanged();
end

-- ============================================ QUEST LOG ===============================================================================

function WorldMapMixin:Switch()
	QuestMapFrame:SetParent(self);
	QuestMapFrame:SetFrameStrata("HIGH");
	QuestMapFrame:ClearAllPoints();
	QuestMapFrame:SetPoint("TOPRIGHT", -6, -66);
	QuestMapFrame:Hide();
	self.QuestLog = QuestMapFrame;
	
	ToggleQuestLog = function()
		self:HandleUserActionToggleQuestLog();
	end
	
	ToggleWorldMap = function()
		self:HandleUserActionToggleSelf();
	end
	
	OpenWorldMap = function(mapID)
		self:HandleUserActionOpenSelf(mapID);
	end
	
	OpenQuestLog = function(mapID)
		self:HandleUserActionOpenQuestLog(mapID);
	end	
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
