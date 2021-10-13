WorldMapMixin = {};

local TITLE_CANVAS_SPACER_FRAME_HEIGHT = 67;

function WorldMapMixin:SetupTitle()
	self.BorderFrame:SetTitle(MAP_AND_QUEST_LOG);
	self.BorderFrame.Bg:SetParent(self);
	self.BorderFrame.TopTileStreaks:Hide();

	self.BorderFrame:SetPortraitToAsset([[Interface\QuestFrame\UI-QuestLog-BookIcon]]);
end

function WorldMapMixin:SynchronizeDisplayState()
	if self:IsMaximized() then
		self.BorderFrame.TitleText:SetText(WORLD_MAP);
		GameTooltip:Hide();
		self.BlackoutFrame:Show();
		MaximizeUIPanel(self);
	else
		self.BorderFrame.TitleText:SetText(MAP_AND_QUEST_LOG);
		self.BlackoutFrame:Hide();
		RestoreUIPanelArea(self);
	end
end

function WorldMapMixin:Minimize()
	self.isMaximized = false;

	self:SetSize(self.minimizedWidth, self.minimizedHeight);

	SetUIPanelAttribute(self, "bottomClampOverride", nil);
	UpdateUIPanelPositions(self);

	self.BorderFrame:SetBorder("PortraitFrameTemplateMinimizable");
	self.BorderFrame:SetPortraitShown(true);

	self.BorderFrame.Tutorial:Show();
	self.NavBar:SetPoint("TOPLEFT", self.TitleCanvasSpacerFrame, "TOPLEFT", 64, -25);

	self:SynchronizeDisplayState();

	self:OnFrameSizeChanged();
end

function WorldMapMixin:Maximize()
	self.isMaximized = true;

	self.BorderFrame:SetBorder("ButtonFrameTemplateNoPortraitMinimizable");
	self.BorderFrame:SetPortraitShown(false);

	self.BorderFrame.Tutorial:Hide();
	self.NavBar:SetPoint("TOPLEFT", self.TitleCanvasSpacerFrame, "TOPLEFT", 8, -25);

	self:UpdateMaximizedSize();
	self:SynchronizeDisplayState();

	self:OnFrameSizeChanged();
end

function WorldMapMixin:SetupMinimizeMaximizeButton()
	self.minimizedWidth = 702;
	self.minimizedHeight = 534;
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
	UIPanelWindows[self:GetName()] = { area = "left", pushable = 0, xoffset = 0, yoffset = 0, whileDead = 1, minYOffset = 0, maximizePoint = "TOP" };

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
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("WORLD_MAP_OPEN");
	self:RegisterEvent("WORLD_MAP_CLOSE");

	self:AttachQuestLog();

	self:UpdateSpacerFrameAnchoring();
end

function WorldMapMixin:OnEvent(event, ...)
	MapCanvasMixin.OnEvent(self, event, ...);

	if event == "VARIABLES_LOADED" then
		if self:ShouldBeMinimized() then
			self:Minimize();
		else
			self:Maximize();
		end
	elseif event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" then
		if self:IsMaximized() then
			self:UpdateMaximizedSize();
		end
	elseif event == "WORLD_MAP_OPEN" then
		local mapID = ...;
		OpenWorldMap(mapID);
	elseif event == "WORLD_MAP_CLOSE" then
		HideUIPanel(self);
	end
end

function WorldMapMixin:AddStandardDataProviders()
	self:AddDataProvider(CreateFromMixins(MapExplorationDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(MapHighlightDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(WorldMap_EventOverlayDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(StorylineQuestDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(BattlefieldFlagDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(BonusObjectiveDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(VehicleDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(EncounterJournalDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(FogOfWarDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(DeathMapDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(QuestBlobDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(ScenarioDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(VignetteDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(QuestDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(InvasionDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(GossipDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(FlightPointDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(PetTamerDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(DigSiteDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(GarrisonPlotDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(DungeonEntranceDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(BannerDataProvider));
	self:AddDataProvider(CreateFromMixins(ContributionCollectorDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(MapLinkDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(SelectableGraveyardDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(AreaPOIDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(MapIndicatorQuestDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(QuestSessionDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(WaypointLocationDataProviderMixin));

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
	worldQuestDataProvider:SetUsesSpellEffect(true);
	worldQuestDataProvider:SetCheckBounties(true);
	worldQuestDataProvider:SetMarkActiveQuests(true);
	self:AddDataProvider(worldQuestDataProvider);

	local pinFrameLevelsManager = self:GetPinFrameLevelsManager();
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_MAP_EXPLORATION");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_EVENT_OVERLAY");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_GARRISON_PLOT");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_FOG_OF_WAR");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_QUEST_BLOB");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SCENARIO_BLOB");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_MAP_HIGHLIGHT");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DEBUG", 4);
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DIG_SITE");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_FLIGHT_POINT");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_INVASION");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_PET_TAMER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SELECTABLE_GRAVEYARD");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_GOSSIP");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_AREA_POI");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DEBUG");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_MAP_LINK");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_ENCOUNTER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_CONTRIBUTION_COLLECTOR");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_VIGNETTE", 200);
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_STORY_LINE");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SCENARIO");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_WORLD_QUEST", 500);
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_WORLD_QUEST_PING");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_ACTIVE_QUEST", C_QuestLog.GetMaxNumQuests());
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SUPER_TRACKED_QUEST");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_VEHICLE_BELOW_GROUP_MEMBER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_BONUS_OBJECTIVE");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_BATTLEFIELD_FLAG");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_WAYPOINT_LOCATION");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_GROUP_MEMBER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_VEHICLE_ABOVE_GROUP_MEMBER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_CORPSE");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_AREA_POI_BANNER");
end

function WorldMapMixin:AddOverlayFrames()
	self:AddOverlayFrame("WorldMapFloorNavigationFrameTemplate", "FRAME", "TOPLEFT", self:GetCanvasContainer(), "TOPLEFT", -15, 2);
	self:AddOverlayFrame("WorldMapTrackingOptionsButtonTemplate", "DROPDOWNTOGGLEBUTTON", "TOPRIGHT", self:GetCanvasContainer(), "TOPRIGHT", -4, -2);
	self:AddOverlayFrame("WorldMapTrackingPinButtonTemplate", "BUTTON", "TOPRIGHT", self:GetCanvasContainer(), "TOPRIGHT", -36, -2);
	self:AddOverlayFrame("WorldMapBountyBoardTemplate", "FRAME", nil, self:GetCanvasContainer());
	self:AddOverlayFrame("WorldMapActionButtonTemplate", "FRAME", nil, self:GetCanvasContainer());
	self:AddOverlayFrame("WorldMapZoneTimerTemplate", "FRAME", "BOTTOM", self:GetCanvasContainer(), "BOTTOM", 0, 20);
	self:AddOverlayFrame("WorldMapThreatFrameTemplate", "FRAME", "BOTTOMLEFT", self:GetCanvasContainer(), "BOTTOMLEFT", 0, 0);

	self.NavBar = self:AddOverlayFrame("WorldMapNavBarTemplate", "FRAME");
	self.NavBar:SetPoint("TOPLEFT", self.TitleCanvasSpacerFrame, "TOPLEFT", 64, -25);
	self.NavBar:SetPoint("BOTTOMRIGHT", self.TitleCanvasSpacerFrame, "BOTTOMRIGHT", -4, 9);

	self.SidePanelToggle = self:AddOverlayFrame("WorldMapSidePanelToggleTemplate", "BUTTON", "BOTTOMRIGHT", self:GetCanvasContainer(), "BOTTOMRIGHT", -2, 1);
end

function WorldMapMixin:OnMapChanged()
	MapCanvasMixin.OnMapChanged(self);
	self:RefreshOverlayFrames();
	self:RefreshQuestLog();

	if C_MapInternal then
		C_MapInternal.SetDebugMap(self:GetMapID());
	end
end

function WorldMapMixin:OnShow()
	local mapID = MapUtil.GetDisplayableMapForPlayer();
	self:SetMapID(mapID);
	MapCanvasMixin.OnShow(self);
	self:ResetZoom();

	DoEmote("READ", nil, true);
	PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN);

	PlayerMovementFrameFader.AddDeferredFrame(self, .5, 1.0, .5, function() return GetCVarBool("mapFade") and not self:IsMouseOver() end);
	self.BorderFrame.Tutorial:CheckAndShowTooltip();

	local miniWorldMap = GetCVarBool("miniWorldMap");
	local maximized = self:IsMaximized();
	if miniWorldMap ~= maximized then
		if miniWorldMap then
			self.BorderFrame.MaximizeMinimizeFrame:Minimize();
		else
			self.BorderFrame.MaximizeMinimizeFrame:Maximize();
		end
	end

	self:TriggerEvent("WorldMapOnShow");
end

function WorldMapMixin:OnHide()
	MapCanvasMixin.OnHide(self);

	CancelEmote();
	PlaySound(SOUNDKIT.IG_QUEST_LOG_CLOSE);

	PlayerMovementFrameFader.RemoveFrame(self);
	self.BorderFrame.Tutorial:CheckAndHideHelpInfo();

	self:OnUIClose();
	self:TriggerEvent("WorldMapOnHide");
	C_Map.CloseWorldMapInteraction();
end

function WorldMapMixin:RefreshOverlayFrames()
	if self.overlayFrames then
		for i, frame in ipairs(self.overlayFrames) do
			frame:Refresh();
		end
	end
end

function WorldMapMixin:AddOverlayFrame(templateName, templateType, anchorPoint, relativeFrame, relativePoint, offsetX, offsetY)
	local frame = CreateFrame(templateType, nil, self, templateName);
	if anchorPoint then
		frame:SetPoint(anchorPoint, relativeFrame, relativePoint, offsetX, offsetY);
	end
	frame.relativeFrame = relativeFrame or self;
	if not self.overlayFrames then
		self.overlayFrames = { };
	end
	tinsert(self.overlayFrames, frame);

	return frame;
end

function WorldMapMixin:SetOverlayFrameLocation(frame, location)
	frame:ClearAllPoints();
	if location == Enum.MapOverlayDisplayLocation.BottomLeft then
		frame:SetPoint("BOTTOMLEFT", frame.relativeFrame, 15, 15);
	elseif location == Enum.MapOverlayDisplayLocation.TopLeft then
		frame:SetPoint("TOPLEFT", frame.relativeFrame, 15, -15);
	elseif location == Enum.MapOverlayDisplayLocation.BottomRight then
		frame:SetPoint("BOTTOMRIGHT", frame.relativeFrame, -18, 15);
	elseif location == Enum.MapOverlayDisplayLocation.TopRight then
		frame:SetPoint("TOPRIGHT", frame.relativeFrame, -15, -15);
	end
end

function WorldMapMixin:UpdateMaximizedSize()
	assert(self:IsMaximized());

	local parentWidth, parentHeight = self:GetParent():GetSize();
	local SCREEN_BORDER_PIXELS = 30;
	parentWidth = parentWidth - SCREEN_BORDER_PIXELS;

	local spacerFrameHeight = TITLE_CANVAS_SPACER_FRAME_HEIGHT;
	local unclampedWidth = ((parentHeight - spacerFrameHeight) * self.minimizedWidth) / (self.minimizedHeight - spacerFrameHeight);
	local clampedWidth = math.min(parentWidth, unclampedWidth);

	local unclampedHeight = parentHeight;
	local clampHeight = ((parentHeight - spacerFrameHeight) * (clampedWidth / unclampedWidth)) + spacerFrameHeight;
	self:SetSize(math.floor(clampedWidth), math.floor(clampHeight));

	SetUIPanelAttribute(self, "bottomClampOverride", (unclampedHeight - clampHeight) / 2);

	UpdateUIPanelPositions(self);

	self:OnFrameSizeChanged();
end

function WorldMapMixin:UpdateSpacerFrameAnchoring()
	if self.QuestLog and self.QuestLog:IsShown() then
		self.TitleCanvasSpacerFrame:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3 - self.questLogWidth, -TITLE_CANVAS_SPACER_FRAME_HEIGHT);
	else
		self.TitleCanvasSpacerFrame:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -TITLE_CANVAS_SPACER_FRAME_HEIGHT);
	end
	self:OnFrameSizeChanged();
end

--[[ Help Plate ]] --
WorldMapTutorialMixin = { }

function WorldMapTutorialMixin:OnLoad()
	self.helpInfo = {
		FramePos = { x = 4,	y = -40 },
		FrameSize = { width = 985, height = 500	},
		[1] = { ButtonPos = { x = 350,	y = -180 }, HighLightBox = { x = 0, y = -30, width = 695, height = 464 }, ToolTipDir = "DOWN", ToolTipText = WORLD_MAP_TUTORIAL1 },
		[2] = { ButtonPos = { x = 350,	y = 16 }, HighLightBox = { x = 50, y = 16, width = 645, height = 44 }, ToolTipDir = "DOWN", ToolTipText = WORLD_MAP_TUTORIAL4 },
	};
end

function WorldMapTutorialMixin:OnHide()
	self:CheckAndHideHelpInfo();
end

function WorldMapTutorialMixin:CheckAndShowTooltip()
	if (not NewPlayerExperience or not NewPlayerExperience.IsActive) and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME) then
		if not HelpPlate_IsShowing(self.helpInfo) then
			HelpPlate_ShowTutorialPrompt(self.helpInfo, self);
			SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true);
		end
	end
end

function WorldMapTutorialMixin:CheckAndHideHelpInfo()
	if HelpPlate_IsShowing(self.helpInfo) then
		HelpPlate_Hide();
	end

	if HelpPlateTooltip_IsShowing(self.helpInfo) then
		HelpPlate_TooltipHide();
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, false);
	end
end

function WorldMapTutorialMixin:ToggleHelpInfo()
	local mapFrame = self:GetParent():GetParent();
	if ( mapFrame.QuestLog:IsShown() ) then
		self.helpInfo[3] = { ButtonPos = { x = 810,	y = -180 }, HighLightBox = { x = 700, y = 16, width = 285, height = 510 },	ToolTipDir = "DOWN", ToolTipText = WORLD_MAP_TUTORIAL2 };
	else
		self.helpInfo[3] = nil;
	end

	if ( not HelpPlate_IsShowing(self.helpInfo) and mapFrame:IsShown()) then
		HelpPlate_Show(self.helpInfo, mapFrame, self, true);
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true);
	else
		HelpPlate_Hide(true);
	end
end

-- ============================================ QUEST LOG ===============================================================================

function WorldMapMixin:AttachQuestLog()
	QuestMapFrame:SetParent(self);
	QuestMapFrame:SetFrameStrata("HIGH");
	QuestMapFrame:ClearAllPoints();
	QuestMapFrame:SetPoint("TOPRIGHT", -3, -25);
	QuestMapFrame:SetPoint("BOTTOMRIGHT", -3, 3);
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
function ToggleQuestLog()
	WorldMapFrame:HandleUserActionToggleQuestLog();
end

function ToggleWorldMap()
	WorldMapFrame:HandleUserActionToggleSelf();
end

function OpenWorldMap(mapID)
	WorldMapFrame:HandleUserActionOpenSelf(mapID);
end

function OpenQuestLog(mapID)
	WorldMapFrame:HandleUserActionOpenQuestLog(mapID);
end