
local function ShouldWoWLabsAreaBeActive()
	return WoWLabsAreaDataProviderMixin and C_GameRules.IsGameRuleActive(Enum.GameRule.PlunderstormAreaSelection);
end

WorldMapMixin = {};

--[[
	Boolean flag that identifies this frame as having updated jump hints, no longer
	using legacy FrameControlsManager jump hints only displayed on targets.
	See FrameControlsManager:RefreshJumpHints
]]
WorldMapMixin.useFooterJumpHints = true;

-- Text to display next to jump hints on other frames, if the jump takes them here
function WorldMapMixin:GetJumpHintLabel()
	return WORLD_MAP;
end

local TITLE_CANVAS_SPACER_FRAME_HEIGHT = 67;
local MAP_FOCUS = "Map";
local QUEST_FOCUS = "Quest";
local DETAILS_FOCUS = "Details";

function WorldMapMixin:SetupTitle()
	self.BorderFrame:SetTitle(MAP_AND_QUEST_LOG);
	self.BorderFrame.Bg:SetParent(self);
	self.BorderFrame.TopTileStreaks:Hide();

	self.BorderFrame:SetPortraitToAsset([[Interface\QuestFrame\UI-QuestLog-BookIcon]]);
end

function WorldMapMixin:SynchronizeDisplayState()
	if self:IsMaximized() then
		self.BorderFrame:SetTitle(WORLD_MAP);
		GameTooltip:Hide();
		self.BlackoutFrame:Show();
		MaximizeUIPanel(self);
	else
		self.BorderFrame:SetTitle(MAP_AND_QUEST_LOG);
		self.BlackoutFrame:Hide();
		RestoreUIPanelArea(self);
	end

	if InputUtil.IsGamepadUIEnabled() then
		-- Reposition gamepad footer and input callouts.
		self:UpdateStateChangeIndicators();
		self.ScrollContainer:RefreshGamepadScrollSpeed();
	end
end

function WorldMapMixin:Minimize()
	self.isMaximized = false;
	EventRegistry:TriggerEvent("WorldMapMinimized");

	self:SetSize(self.minimizedWidth, self.minimizedHeight);

	SetUIPanelAttribute(self, "bottomClampOverride", nil);
	UpdateUIPanelPositions(self);

	self.BorderFrame:SetBorder("PortraitFrameTemplateMinimizable");
	self.BorderFrame:SetPortraitShown(true);

	self:SetTutorialButtonShown(true);
	self.NavBar:SetPoint("TOPLEFT", self.TitleCanvasSpacerFrame, "TOPLEFT", 64, -25);

	self:SynchronizeDisplayState();

	self:OnFrameSizeChanged();
end

function WorldMapMixin:Maximize()
	self.isMaximized = true;
	EventRegistry:TriggerEvent("WorldMapMaximized");

	self.BorderFrame:SetBorder("ButtonFrameTemplateNoPortraitMinimizable");
	self.BorderFrame:SetPortraitShown(false);

	self:SetTutorialButtonShown(false);
	self.NavBar:SetPoint("TOPLEFT", self.TitleCanvasSpacerFrame, "TOPLEFT", 8, -25);

	self:UpdateMaximizedSize();
	self:SynchronizeDisplayState();

	self:OnFrameSizeChanged();
end

function WorldMapMixin:SetTutorialButtonShown(shown)
	local worldMapHelpPlateDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.WorldMapHelpPlateDisabled);
	if worldMapHelpPlateDisabled or InputUtil.IsGamepadUIEnabled() then
		return;
	end

	self.BorderFrame.Tutorial:SetShown(shown);
end

function WorldMapMixin:CheckAndShowTutorialTooltip()
	local worldMapHelpPlateDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.WorldMapHelpPlateDisabled);
	if worldMapHelpPlateDisabled then
		return;
	end

	self.BorderFrame.Tutorial:CheckAndShowTooltip();
end

function WorldMapMixin:CheckAndHideTutorialHelpInfo()
	local worldMapHelpPlateDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.WorldMapHelpPlateDisabled);
	if worldMapHelpPlateDisabled then
		return;
	end

	self.BorderFrame.Tutorial:CheckAndHideHelpInfo();
end

function WorldMapMixin:SetupMinimizeMaximizeButton()
	self.minimizedWidth = 702;
	self.minimizedHeight = 534;
	self.questLogWidth = 333;

	local function OnMaximize()
		self:HandleUserActionMaximizeSelf();
	end

	self.BorderFrame.MaximizeMinimizeFrame:SetOnMaximizedCallback(OnMaximize);

	local function OnMinimize()
		self:HandleUserActionMinimizeSelf();
	end

	self.BorderFrame.MaximizeMinimizeFrame:SetOnMinimizedCallback(OnMinimize);

	local maximizeWorldMapDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.MaximizeWorldMapDisabled);
	if maximizeWorldMapDisabled then
		self.BorderFrame.MaximizeMinimizeFrame:Hide();
	end
end

function WorldMapMixin:IsMaximized()
	return self.isMaximized == true;
end

function WorldMapMixin:IsMinimized()
	return self.isMaximized == false;
end

function WorldMapMixin:OnLoad()
	RegisterUIPanel(self, { area = "left", pushable = 0, xoffset = 0, yoffset = 0, whileDead = 1, minYOffset = 0, maximizePoint = "TOP", allowOtherPanels = 1 });

	self.needUpdateDisplayState = true;

	MapCanvasMixin.OnLoad(self);

	self:SetupTitle();
	self:SetupMinimizeMaximizeButton();

	self:SetShouldZoomInOnClick(false);
	self:SetShouldPanOnClick(false);
	self:SetShouldNavigateOnClick(true);
	self:SetShouldZoomInstantly(true);

	self:AddStandardDataProviders();
	self:AddOverlayFrames();

	if ShouldWoWLabsAreaBeActive() then
		self:RegisterEvent("PLAYER_ENTERING_WORLD");
	end

	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("WORLD_MAP_OPEN");

	self:AttachQuestLog();

	self:UpdateSpacerFrameAnchoring();

	local worldMapHelpPlateDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.WorldMapHelpPlateDisabled);
	if worldMapHelpPlateDisabled then
		self.BorderFrame.Tutorial:Hide();
	end

	self:RegisterForTransitions();
end

function WorldMapMixin:OnEvent(event, ...)
	MapCanvasMixin.OnEvent(self, event, ...);

	if event == "PLAYER_ENTERING_WORLD" then
		-- Query data for WoWLabsAreaDataProviderMixin.
		C_WowLabsDataManager.QuerySelectedWoWLabsArea();
		C_WowLabsDataManager.QueryWoWLabsAreaInfo();
	elseif event == "VARIABLES_LOADED" then
		self.needUpdateDisplayState = true;
	elseif event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" then
		if self:IsMaximized() then
			self:UpdateMaximizedSize();
		end
	elseif event == "WORLD_MAP_OPEN" then
		local mapID = ...;
		OpenWorldMap(mapID);
	end
end

function WorldMapMixin:AddStandardDataProviders()
	self:AddDataProvider(CreateFromMixins(MapExplorationDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(MapHighlightDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(WorldMap_EventOverlayDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(QuestOfferDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(BattlefieldFlagDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(BonusObjectiveDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(VehicleDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(FogOfWarDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(DeathMapDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(QuestBlobDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(ScenarioDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(VignetteDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(QuestDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(ContentTrackingDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(InvasionDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(GossipDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(FlightPointDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(PetTamerDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(DigSiteDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(GarrisonPlotDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(DungeonEntranceDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(DelveEntranceDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(BannerDataProvider));
	self:AddDataProvider(CreateFromMixins(ContributionCollectorDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(MapLinkDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(SelectableGraveyardDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(AreaPOIDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(AreaPOIEventDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(QuestSessionDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(WaypointLocationDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(DragonridingRaceDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(SuperTrackWaypointDataProviderMixin));
	self:AddDataProvider(CreateFromMixins(NeighborhoodMapDataProviderMixin));

	-- Encounter Journal does not exist in all game types.
	if EncounterJournalDataProviderMixin then
		self:AddDataProvider(CreateFromMixins(EncounterJournalDataProviderMixin));
	end

	if C_GameRules.IsGameRuleActive(Enum.GameRule.MapPlunderstormCircle) then
		self:AddDataProvider(CreateFromMixins(PlunderstormCircleDataProviderMixin));
	end

	-- WoWLabs areas only appear when in WoWLabs since these feature(s) aren't fully data-driven yet.
	if ShouldWoWLabsAreaBeActive() then
		self:AddDataProvider(CreateFromMixins(WoWLabsAreaDataProviderMixin));
	end

	if IsGMClient() then
		self:AddDataProvider(CreateFromMixins(WorldMap_DebugDataProviderMixin));
	end

	local areaLabelDataProvider = CreateFromMixins(AreaLabelDataProviderMixin);	-- no pins
	local areaLabelOffsetY = InputUtil.IsGamepadUIEnabled() and -40 or -10; -- Gamepad UI uses a prompt at the top and needs more offset.
	areaLabelDataProvider:SetOffsetY(areaLabelOffsetY);
	self:AddDataProvider(areaLabelDataProvider);

	local groupMembersDataProvider = CreateFromMixins(GroupMembersDataProviderMixin);
	self:AddDataProvider(groupMembersDataProvider);

	local worldQuestDataProvider = CreateFromMixins(WorldMap_WorldQuestDataProviderMixin);
	worldQuestDataProvider:SetMatchWorldMapFilters(true);
	worldQuestDataProvider:SetUsesSpellEffect(true);
	worldQuestDataProvider:SetCheckBounties(true);
	self:AddDataProvider(worldQuestDataProvider);

	local pinFrameLevelsManager = self:GetPinFrameLevelsManager();
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_WOW_LABS_AREA");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_MAP_EXPLORATION");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_PLUNDERSTORM_CIRCLE");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_EVENT_OVERLAY");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_GARRISON_PLOT");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_FOG_OF_WAR");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_QUEST_BLOB");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SCENARIO_BLOB");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_MAP_HIGHLIGHT");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DEBUG", 4);
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DIG_SITE");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DUNGEON_ENTRANCE");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DELVE_ENTRANCE");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_FLIGHT_POINT");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_NEIGHBORHOOD_MAP_OBJECTS");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_INVASION");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_PET_TAMER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SELECTABLE_GRAVEYARD");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DRAGONRIDING_RACE");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_AREA_POI");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_GOSSIP");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_DEBUG");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_MAP_LINK");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_ENCOUNTER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_CONTRIBUTION_COLLECTOR");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_VIGNETTE", 200);
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_QUEST_OFFER", QuestOfferDataProviderMixin.PIN_LEVEL_RANGE);
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SCENARIO");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_BONUS_OBJECTIVE");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_WORLD_QUEST", 500);
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_AREA_POI_EVENT");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_QUEST_PING");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_TRACKED_CONTENT");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_ACTIVE_QUEST", C_QuestLog.GetMaxNumQuests());
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SUPER_TRACKED_CONTENT");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_SUPER_TRACKED_QUEST");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_VEHICLE_BELOW_GROUP_MEMBER");

	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_BATTLEFIELD_FLAG");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_WAYPOINT_LOCATION");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_GROUP_MEMBER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_VEHICLE_ABOVE_GROUP_MEMBER");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_CORPSE");
	pinFrameLevelsManager:AddFrameLevel("PIN_FRAME_LEVEL_AREA_POI_BANNER");
end

function WorldMapMixin:AddOverlayFrames()
	local floorDropdown = self:AddOverlayFrame("WorldMapFloorNavigationFrameTemplate", "DROPDOWNBUTTON", "TOPLEFT", self:GetCanvasContainer(), "TOPLEFT", 2, 0);
	floorDropdown:SetWidth(160);

	local topRightButtonPoolYOffset = -2;
	local topRightButtonPoolYOffsetAmount = -32;
	local worldTrackingOptionsDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.WorldMapTrackingOptionsDisabled);
	if not worldTrackingOptionsDisabled then
		self.WorldMapTrackingOptionsButton = self:AddOverlayFrame("WorldMapTrackingOptionsButtonTemplate", "DROPDOWNBUTTON", "TOPRIGHT", self:GetCanvasContainer(), "TOPRIGHT", -4, topRightButtonPoolYOffset);
		self.WorldMapTrackingOptionsButton.DefaultYOffset = topRightButtonPoolYOffset;
		topRightButtonPoolYOffset = topRightButtonPoolYOffset + topRightButtonPoolYOffsetAmount;
	end

	local worldMapTrackingPinDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.WorldMapTrackingPinDisabled);
	if not worldMapTrackingPinDisabled then
		self.WorldMapTrackingPinButton = self:AddOverlayFrame("WorldMapTrackingPinButtonTemplate", "BUTTON", "TOPRIGHT", self:GetCanvasContainer(), "TOPRIGHT", -4, topRightButtonPoolYOffset);
		topRightButtonPoolYOffset = topRightButtonPoolYOffset + topRightButtonPoolYOffsetAmount;
	end

	local bountyBoard = self:AddOverlayFrame("WorldMapBountyBoardTemplate", "FRAME", nil, self:GetCanvasContainer());
	local actionButton = self:AddOverlayFrame("WorldMapActionButtonTemplate", "FRAME", nil, self:GetCanvasContainer());
	self:AddOverlayFrame("WorldMapZoneTimerTemplate", "FRAME", "BOTTOM", self:GetCanvasContainer(), "BOTTOM", 0, 20);
	local threatFrame = self:AddOverlayFrame("WorldMapThreatFrameTemplate", "FRAME", "BOTTOMLEFT", self:GetCanvasContainer(), "BOTTOMLEFT", 0, 0);
	local activityTracker = self:AddOverlayFrame("WorldMapActivityTrackerTemplate", "BUTTON", "BOTTOMLEFT", self:GetCanvasContainer(), "BOTTOMLEFT", 0, 0);

	self.NavBar = self:AddOverlayFrame("WorldMapNavBarTemplate", "FRAME");
	self.NavBar:SetPoint("TOPLEFT", self.TitleCanvasSpacerFrame, "TOPLEFT", 64, -25);
	self.NavBar:SetPoint("BOTTOMRIGHT", self.TitleCanvasSpacerFrame, "BOTTOMRIGHT", WorldMapConstants.NAVBAR_X_OFFSET, 9);

	local questLogPanelDisabled = C_GameRules.IsGameRuleActive(Enum.GameRule.QuestLogPanelDisabled);
	if not questLogPanelDisabled then
		self.SidePanelToggle = self:AddOverlayFrame("WorldMapSidePanelToggleTemplate", "BUTTON", "BOTTOMRIGHT", self:GetCanvasContainer(), "BOTTOMRIGHT", -2, 1);
	end

	local coordsPanel = self:AddOverlayFrame("WorldMapCoordsPanelTemplate", "FRAME", "BOTTOMLEFT", self:GetCanvasContainer(), "BOTTOMLEFT", 68, 2);
	local requiresBottomLeft = true;
	--ordered from largest to smallest, so that the smaller ones don't overlap the larger ones
	coordsPanel:AttachToNeighbor(bountyBoard, 8, 2, requiresBottomLeft);
	coordsPanel:AttachToNeighbor(actionButton, 8, 2, requiresBottomLeft);
	coordsPanel:AttachToNeighbor(activityTracker, 8, 2);
	coordsPanel:AttachToNeighbor(threatFrame, -177, 2);
	
	self:AdjustOverlayFrames();
end

function WorldMapMixin:AdjustOverlayFrames()
	--overriden elsewhere
end

function WorldMapMixin:OnMapChanged()
	MapCanvasMixin.OnMapChanged(self);
	self:RefreshOverlayFrames();
	self:RefreshQuestLog();

	if InputUtil.IsGamepadUIEnabled() then
		self.worldMapFooter:Refresh();
	end

	if C_MapInternal then
		C_MapInternal.SetDebugMap(self:GetMapID());
	end
end

function WorldMapMixin:OnShow()
	if self.needUpdateDisplayState then
		local displayState = self:GetOpenDisplayState();
		self:SetDisplayState(displayState);
		self.needUpdateDisplayState = nil;
	end

	local frameStrata = C_GameRules.GetGameRuleAsFrameStrata(Enum.GameRule.WorldMapFrameStrata);
	if frameStrata and frameStrata ~= "UNKNOWN" then
		self:SetFrameStrata(frameStrata);
	end

	local mapID = MapUtil.GetDisplayableMapForPlayer();
	self:SetMapID(mapID);
	MapCanvasMixin.OnShow(self);
	self:ResetZoom();

	C_ChatInfo.PerformEmote("READ", nil, true);
	PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN);

	PlayerMovementFrameFader.AddDeferredFrame(self, .5, 1.0, .5, function() return GetCVarBool("mapFade") and not self:IsMouseOver() end);
	self:CheckAndShowTutorialTooltip();

	local miniWorldMap = GetCVarBool("miniWorldMap");
	local maximized = self:IsMaximized();
	if miniWorldMap ~= maximized then
		if miniWorldMap then
			self.BorderFrame.MaximizeMinimizeFrame:Minimize();
		else
			self.BorderFrame.MaximizeMinimizeFrame:Maximize();
		end
	end

	EventRegistry:TriggerEvent("WorldMapOnShow");
end

function WorldMapMixin:OnHide()
	MapCanvasMixin.OnHide(self);

	C_ChatInfo.CancelEmote();
	PlaySound(SOUNDKIT.IG_QUEST_LOG_CLOSE);

	PlayerMovementFrameFader.RemoveFrame(self);
	self:CheckAndHideTutorialHelpInfo();

	self:OnUIClose();
	EventRegistry:TriggerEvent("WorldMapOnHide");
	C_Map.CloseWorldMapInteraction();

	UpdateMicroButtons();

	if InputUtil.IsGamepadUIEnabled() then
		self.currentFocus = nil;
		self:ClearBindings();
	end
end

local function SecureRefreshOverlayFrame(_, frame)
	frame:Refresh();
end

local function SecurePostRefreshOverlayFrame(_, frame)
	if frame.PostRefresh then
		frame:PostRefresh();
	end
end

function WorldMapMixin:RefreshOverlayFrames()
	if self.overlayFrames then
		secureexecuterange(self.overlayFrames, SecureRefreshOverlayFrame);
		secureexecuterange(self.overlayFrames, SecurePostRefreshOverlayFrame);
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

function WorldMapMixin:OnCanvasScaleChanged()
	MapCanvasMixin.OnCanvasScaleChanged(self);

	if InputUtil.IsGamepadUIEnabled() then
		local canvas = self:GetCanvas();
		local width, height = canvas:GetSize();
		local canvasScale = self:GetCanvasScale();
	end
end

function WorldMapMixin:IsCanvasMouseFocus()
	local mouseFocus = MapCanvasMixin.IsCanvasMouseFocus(self);

	local gamepadFocus = false;
	if InputUtil.IsGamepadUIEnabled() then
		gamepadFocus = self.currentFocus == MAP_FOCUS;
	end

	return mouseFocus or gamepadFocus;
end

function WorldMapMixin:IsQuestLogEmpty()
	return (C_QuestLog.GetNumQuestLogEntries() == 0);
end

function WorldMapMixin:OnOpenQuestDetails()
	if InputUtil.IsGamepadUIEnabled() then
		self.refocusQuestButton = SmartNavigation:GetCurrentButton();
		self:FocusDetails();
	end
end

function WorldMapMixin:CloseQuestDetails()
	if InputUtil.IsGamepadUIEnabled() then
		QuestMapFrame.QuestsFrame.DetailsFrame.BackFrame.BackButton:Click();
	end
end

function WorldMapMixin:OnCloseQuestDetails()
	if InputUtil.IsGamepadUIEnabled() then
		if self:IsShown() and self.currentFocus == DETAILS_FOCUS then
			self:FocusQuests();
			if self.refocusQuestButton then
				SmartNavigation:SelectButton(self.refocusQuestButton);
				self.refocusQuestButton = nil;
			else
				SmartNavigation:SelectFirstButton();
			end
		end
	end
end

function WorldMapMixin:ClearBindings()
	self.ScrollContainer:SetGamepadFocus(false);
	self.ScrollContainer:GamepadZoom(0);
	SmartNavigation:SetRightStickScrollingEnabled(false);
	GamepadMode.DeactivateBindingGroup(self.questDetailCursorBindings);
end

function WorldMapMixin:FocusQuestLog()
	if (QuestMapFrame.DetailsFrame:IsShown()) then
		self:FocusDetails();
	else
		self:FocusQuests();
	end
end

-- The world map input set is shared between normal and full map, but full map should not handle this transition.
function WorldMapMixin:FocusQuestLogFromMap()
	if (not self:IsMaximized() and not self:IsQuestLogEmpty()) then
		self:FocusQuestLog();
	end
end

function WorldMapMixin:FocusQuests()
	if (self:IsQuestLogEmpty()) then
		self:FocusMap();
		return;
	end

	if self.SidePanelToggle and not self.QuestLog:IsShown() then
		self.SidePanelToggle:OnClick(); -- Expand the Quest Log.
	end

	self:ClearBindings();
	SmartNavigation:RefreshButtonGroups(self);
	SmartNavigation:EnterFocusGroup(QUEST_FOCUS);
	self.currentFocus = QUEST_FOCUS;
	SmartNavigation:ActivateBinding();
	SmartNavigation:SetRightStickScrollingEnabled(true);
	SmartNavigation:SuspendCursor(false);
	SmartNavigation:ShowCursor(true);
	SmartNavigation:SetScrollFrameForFrame(self, self.QuestLog.QuestsFrame.ScrollFrame);
	GamepadScrollBarHint:SetOwner(self.QuestLog.QuestsFrame.ScrollFrame.ScrollBar.Track.Thumb, "CENTER");
	GamepadScrollBarHint:Show();

	self:UpdateStateChangeIndicators();
end

function WorldMapMixin:FocusDetails()
	self:ClearBindings();
	SmartNavigation:RefreshButtonGroups(self);
	SmartNavigation:EnterFocusGroup(QUEST_FOCUS); -- Details needs to be tracked as its own state, but intentionally does not have its own focus group.
	self.currentFocus = DETAILS_FOCUS;
	SmartNavigation:ActivateBinding();
	SmartNavigation:SetRightStickScrollingEnabled(true);

	GamepadMode.ActivateBindingGroup(self.questDetailCursorBindings);
	SmartNavigation:SetScrollFrameForFrame(self, self.QuestLog.DetailsFrame.ScrollFrame);
	GamepadScrollBarHint:SetOwner( self.QuestLog.DetailsFrame.ScrollFrame.ScrollBar.Track.Thumb, "CENTER");
	GamepadScrollBarHint:Show();
	QuestMapDetailsScrollFrame:SetVerticalScroll(0);

	self:UpdateStateChangeIndicators();
end

function WorldMapMixin:FocusMap()
	self:ClearBindings();
	self.ScrollContainer:SetGamepadFocus(true);
	SmartNavigation:EnterFocusGroup(MAP_FOCUS);
	self.currentFocus = MAP_FOCUS;
	SmartNavigation:HideCursor();
	SmartNavigation:DeactivateBinding();

	self:UpdateStateChangeIndicators();
end

function WorldMapMixin:IsQuestFocused()
	return self.currentFocus == QUEST_FOCUS;
end

function WorldMapMixin:IsQuestDetailsFocused()
	return self.currentFocus == DETAILS_FOCUS;
end

function WorldMapMixin:IsMapFocused()
	return self.currentFocus == MAP_FOCUS;
end

function WorldMapMixin:ToggleFullMap()
	if self:IsMaximized() then
		self.BorderFrame.MaximizeMinimizeFrame:Minimize();
	else
		self.BorderFrame.MaximizeMinimizeFrame:Maximize();
	end

	if InputUtil.IsGamepadUIEnabled() then
		if self:IsMaximized() then
			GamepadMode.FrameControlsManager:ToggleFrameControls(false);
		else
			GamepadMode.FrameControlsManager:ToggleFrameControls(true);
		end
		self:UpdateStateChangeIndicators();
	end
end

function WorldMapMixin:HideQuests()
	if self.SidePanelToggle and self.QuestLog:IsShown() then
		self.SidePanelToggle:OnClick(); -- Collapse the Quest Log.
	end
end

function WorldMapMixin:ShowQuests()
	if self.SidePanelToggle and not self.QuestLog:IsShown() then
		self.SidePanelToggle:OnClick();
	end
end

function WorldMapMixin:GamepadPanSpeed(x, y)
	local magnitude = math.min(math.sqrt(x * x + y * y), 1.0);
	self.ScrollContainer:SetGamepadPanMagnitude(magnitude);
end

function WorldMapMixin:GetZoomVelocityFromMagnitude(magnitude)
	return magnitude ^ 1.8;
end

function WorldMapMixin:GamepadZoom(x, y)
	local magnitude = math.abs(y);
	local velocity = self:GetZoomVelocityFromMagnitude(magnitude);

	self.ScrollContainer:SetGamepadZoom(y >= 0 and velocity or -velocity);
end

function WorldMapMixin:GamepadMapClick()
	self:ClickHoveredPins();
	self:NavigateToGamepadCursor();
end

function WorldMapMixin:GamepadBack()
	if self:IsMaximized() then
		self:Minimize();
		return;
	elseif QuestMapFrame.DetailsFrame:IsShown() then
		self:CloseQuestDetails();
		return;
	end

	SmartNavigation:AttemptClose();
end

function WorldMapMixin:GamepadMapUp()
	local poiPin = self:GetHoveredPin();
	local shouldGoUp = true;
	local detailsShown = QuestMapFrame.DetailsFrame:IsShown();

	if detailsShown then
		self:CloseQuestDetails();
	end

	if poiPin then
		if poiPin.pinTemplate == "QuestPinTemplate" then
			if not detailsShown then
				QuestMapFrame_ShowQuestDetails(poiPin:GetQuestID())
				self:FocusMap();
			end
			shouldGoUp = false;
		elseif poiPin.pinTemplate == "WaypointLocationPinTemplate" then
			local activeChatFrame = FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK);
			if activeChatFrame and activeChatFrame:IsShown() then
				activeChatFrame:SetGamepadFocus();
			end
			ChatFrameUtil.InsertLink(C_Map.GetUserWaypointHyperlink());
			PlaySound(SOUNDKIT.UI_MAP_WAYPOINT_CHAT_SHARE);
			shouldGoUp = false;
		end
	end

	if shouldGoUp then
		self:NavigateToParentMap();
	end
end

function WorldMapMixin:GamepadTryPlaceWaypoint()
	if not C_GameRules.IsGameRuleActive(Enum.GameRule.WorldMapTrackingPinDisabled) then
		local mapID = self:GetMapID();
		local posVector = C_Map.GetUserWaypointPositionForMap(mapID);
		local currentX, currentY = self:GetNormalizedGamepadCursorPosition();
		local shouldPlaceCursor = true;
		if posVector then
			local waypointX, waypointY = posVector:GetXY();
			local diffX = math.abs(waypointX - currentX);
			local diffY = math.abs(waypointY - currentY);
			shouldPlaceCursor = diffX > 0.03 or diffY > 0.03;
		end

		if shouldPlaceCursor then
			local uiMapPoint = UiMapPoint.CreateFromCoordinates(mapID, currentX, currentY);
			C_Map.SetUserWaypoint(uiMapPoint);
			C_SuperTrack.SetSuperTrackedUserWaypoint(false);
			PlaySound(SOUNDKIT.UI_MAP_WAYPOINT_CLICK_TO_PLACE);
		else
			C_Map.ClearUserWaypoint();
			C_SuperTrack.SetSuperTrackedUserWaypoint(false);
			PlaySound(SOUNDKIT.UI_MAP_WAYPOINT_REMOVE);
		end
	end
end

function WorldMapMixin:OnButtonSelected(inButton)
	self.QuestLog:OnButtonSelected(inButton);
end

local function IsSubMenuFocused()
	local focusedButton = SmartNavigation:GetCurrentButton();
	if focusedButton then
		-- Sub-menus do not deactivate their parent, to preserve the main frame's state.
		return focusedButton:GetParent().skipFrameDeactivation;
	end
	return false;
end

function WorldMapMixin:OnHitLeftEdge()
	if (self.currentFocus == QUEST_FOCUS or self.currentFocus == DETAILS_FOCUS) and not IsSubMenuFocused() then
		self:FocusMap();
	end
end

function WorldMapMixin:ActivateRewardsCursor()
	local rewardsFrame = MapQuestInfoRewardsFrame;
	if rewardsFrame:IsShown() and rewardsFrame.RewardButtons then
		SmartNavigation:SuspendCursor(false);
		GamepadMode.DeactivateBindingGroup(self.questDetailCursorBindings);
		local firstRewardButton = rewardsFrame.RewardButtons[1];
		SmartNavigation:SelectButton(firstRewardButton);
		self.rewardCursorActive = true;
	end
end

function WorldMapMixin:DeactivateRewardsCursor()
	if (self.rewardCursorActive) then
		SmartNavigation:SuspendCursor(true);
		GamepadMode.ActivateBindingGroup(self.questDetailCursorBindings);
		self.rewardCursorActive = false;
	end
end

function WorldMapMixin:HideStateChangeIndicators()
	self.questLogFooter:HideAndDeactivateBindings();
	self.questDetailsFooter:HideAndDeactivateBindings();
	self.worldMapFooter:HideAndDeactivateBindings();
	GamepadMode.DeactivateBindingGroup(self.worldMapCursorBindings);
	GamepadMode.DeactivateBindingGroup(self.questLogTooltipBindings);

	self.currentNavBarIndex = nil;
	self.NavBar.GamepadPreviousAreaIcon:Hide();
	self.NavBar.GamepadNextAreaIcon:Hide();

	if self.SidePanelToggle then
		self.SidePanelToggle:Hide();
	end
end

function WorldMapMixin:UpdateStateChangeIndicators()
	self:HideStateChangeIndicators();

	-- Ignore the frame focus glow in maximized mode, no other frames can be shown.
	if self:IsMaximized() then
		self.BorderFrame.FrameGlow:Hide();
	else
		self.BorderFrame.FrameGlow:Show();
	end

	local focus = self.currentFocus;
	local activeFooter = nil;

	if (focus == QUEST_FOCUS) then
		activeFooter = self.questLogFooter;
		GamepadMode.ActivateBindingGroup(self.questLogTooltipBindings);
	elseif (focus == DETAILS_FOCUS) then
		activeFooter = self.questDetailsFooter;
	elseif (focus == MAP_FOCUS) then
		activeFooter = self.worldMapFooter;
		GamepadMode.ActivateBindingGroup(self.worldMapCursorBindings);
	end

	if activeFooter then
		activeFooter:ShowAndActivateBindings();

		-- Reposition elements that are shown in both normal and full-screen layouts.
		local inputLegend = activeFooter.inputLegend;
		inputLegend:ClearAllPoints();

		if self:IsMaximized() then
			inputLegend:SetPoint("BOTTOM", self, "BOTTOM", 0, 20);
		else
			activeFooter:ApplyInputLegendAttachment();
		end
	end
end

function WorldMapMixin:IsTrackFocusContextActionValid()
	local focusedButton = SmartNavigation:GetCurrentButton();
	if (focusedButton.questID) then
		return true;
	else
		return false;
	end
end

function WorldMapMixin:TrackSelectedQuest()
	local questID = nil;
	if (self.currentFocus == QUEST_FOCUS) then
		local focusedButton = SmartNavigation:GetCurrentButton();
		if (focusedButton) then
			questID = focusedButton.questID;
		end
	else
		questID = QuestMapFrame.DetailsFrame.questID;
	end

	if (questID) then
		QuestMapQuestOptions_TrackQuest(questID);
	end
end

function WorldMapMixin:FocusSelectedQuest()
	local questID = nil;
	if (self.currentFocus == QUEST_FOCUS) then
		local focusedButton = SmartNavigation:GetCurrentButton();
		if (focusedButton) then
			questID = focusedButton.questID;
		end
	else
		questID = QuestMapFrame.DetailsFrame.questID;
	end

	if (questID == C_SuperTrack.GetSuperTrackedQuestID()) then
		C_SuperTrack.ClearAllSuperTracked();
	else
		C_SuperTrack.SetSuperTrackedQuestID(questID);
	end
end

function WorldMapMixin:OpenQuestOptions()
	if (self.currentFocus == QUEST_FOCUS) then
		local focusedButton = SmartNavigation:GetCurrentButton();
		if (focusedButton) then
			if (focusedButton.questID) then
				QuestMapLogTitleButton_OnClick(focusedButton, "RightButton");
			else
				QuestMapLogHeaderButton_CreateContextMenu(focusedButton);
			end
		end
	else
		local questID = QuestMapFrame.DetailsFrame.questID;
		local questButton = QuestLogQuests_GetQuestButton(questID);
		SmartNavigation:SuspendCursor(false);
		self:ClearBindings();
		QuestMapLogTitleButton_CreateContextMenu(questButton, self);
	end
end

function WorldMapMixin:SelectArea()
	local focusedButton = SmartNavigation:GetCurrentButton();
	if focusedButton then
		focusedButton:Click();
	end
end

function WorldMapMixin:SelectFilters()
	local focusedButton = SmartNavigation:GetCurrentButton();
	if focusedButton and focusedButton.OpenMenu then
		focusedButton:OpenMenu();
	end
end

function WorldMapMixin:UpdateNavBarGamepadIconAnchors()
	local numButtons = NavBar_GetNumButtons(self.NavBar);
	if numButtons == 0 then
		return;
	end

	local firstButton = NavBar_GetButton(self.NavBar, 1);
	local lastButton = NavBar_GetButton(self.NavBar, numButtons);

	self.NavBar.GamepadPreviousAreaIcon:ClearAllPoints();
	self.NavBar.GamepadPreviousAreaIcon:SetPoint("RIGHT", firstButton, "LEFT", 0, -9);

	self.NavBar.GamepadNextAreaIcon:ClearAllPoints();
	self.NavBar.GamepadNextAreaIcon:SetPoint("LEFT", lastButton, "RIGHT", 15, -9);
end

function WorldMapMixin:UpdateNavBarGamepadIconState()
	local numButtons = NavBar_GetNumButtons(self.NavBar);
	local index = self.currentNavBarIndex;

	self.NavBar.GamepadPreviousAreaIcon:Show();
	self.NavBar.GamepadNextAreaIcon:Show();

	-- First nav bar button does not have dropdown
	self.NavBar.GamepadPreviousAreaIcon:SetEnabled(index > 2);
	self.NavBar.GamepadNextAreaIcon:SetEnabled(index < numButtons);
end

function WorldMapMixin:OpenAreaDropdownList(index)
	local areaButton = NavBar_GetButton(self.NavBar, index);

	if areaButton and areaButton.MenuArrowButton and areaButton.MenuArrowButton.OpenMenu then
		if not areaButton.gamepadCloseCallbackRegistered then
			areaButton.MenuArrowButton:RegisterCallback(
				areaButton.MenuArrowButton.Event.OnMenuClose,
				self.OnAreaDropdownClosed,
				self
			);

			areaButton.gamepadCloseCallbackRegistered = true;
		end

		areaButton.MenuArrowButton:OpenMenu();

		self.currentNavBarIndex = index;
		GamepadMode.ActivateBindingGroup(self.navBarBindings);
		self:UpdateNavBarGamepadIconState();
	end
end

function WorldMapMixin:OpenCurrentAreaDropdownList()
	self:UpdateNavBarGamepadIconAnchors();

	local currentMapIndex = NavBar_GetNumButtons(self.NavBar);
	self:OpenAreaDropdownList(currentMapIndex);
end

function WorldMapMixin:OpenPreviousDropdownList()
	if not self.currentNavBarIndex then
		return;
	end

	local previousIndex = self.currentNavBarIndex - 1;
	if previousIndex >= 1 then
		self:OpenAreaDropdownList(previousIndex);
	end
end

function WorldMapMixin:OpenNextDropdownList()
	if not self.currentNavBarIndex then
		return;
	end

	local nextIndex = self.currentNavBarIndex + 1;
	if nextIndex <= NavBar_GetNumButtons(self.NavBar) then
		self:OpenAreaDropdownList(nextIndex);
	end
end

function WorldMapMixin:OnAreaDropdownClosed()
	self.currentNavBarIndex = nil;
	GamepadMode.DeactivateBindingGroup(self.navBarBindings);

	self.NavBar.GamepadPreviousAreaIcon:Hide();
	self.NavBar.GamepadNextAreaIcon:Hide();
end

function WorldMapMixin:IsCurrentAreaDropdownContextValid()
	local currentMapIndex = NavBar_GetNumButtons(self.NavBar);
	local currentAreaButton = NavBar_GetButton(self.NavBar, currentMapIndex);

	return currentAreaButton and currentAreaButton.MenuArrowButton;
end

function WorldMapMixin:ResetMapFilters()
	local focusedButton = SmartNavigation:GetCurrentButton();
	if focusedButton and focusedButton.ResetButton then
		focusedButton.ResetButton:Click();
	end
end

function WorldMapMixin:FocusSearchBox()
	local searchBox = QuestScrollFrame.SearchBox;
	if not searchBox:HasFocus() then
		SmartNavigation:SelectButton(searchBox);
		searchBox:SetFocus();
	else
		searchBox:ClearFocus();
	end
end

-- Return the map frame to normal size before handling bindings that focus or overlay something on top.
function WorldMapMixin:HandleUnfocus()
	if self:IsMaximized() then
		self:ToggleFullMap();
	end
	RunBinding("TOGGLEUIFOCUS");
end

function WorldMapMixin:TryOpenFilter()
	local filter;
	if self.currentFocus == MAP_FOCUS then
		filter = self.WorldMapTrackingOptionsButton;
	elseif self.currentFocus == QUEST_FOCUS then
		filter = QuestScrollFrame.SettingsDropdown;
	end

	if filter and not filter:IsMenuOpen() then
		filter:MouseDown();
		filter:MouseUp();
		return true;
	end
end

function WorldMapMixin:HandleMainMenu()
	if self:TryOpenFilter() then
		return;
	end

	if self:IsMaximized() then
		self:ToggleFullMap();
	end
	RunBinding("OPENRADIAL");
end

function WorldMapMixin:SetupGamepad()
	self.SmartNavigationOnSelect = self.OnButtonSelected;
	self.CloseButton = self.BorderFrame.CloseButton;
	self.currentFocus = nil;

	SmartNavigation_MarkFrameSubSection(self.QuestLog, QUEST_FOCUS);
	SmartNavigation_MarkFrameSubSection(self.ScrollContainer, MAP_FOCUS);

	-- Quest Log actions.
	local questOptions = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_TOP, GenerateClosure(self.OpenQuestOptions, self), CONTEXT_ACTION_LABEL_MORE_ACTIONS);
	questOptions:AddButtonContext("ButtonContext_QuestLogHeader");
	questOptions:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);

	local focusMap = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_DPAD_LEFT, GenerateClosure(self.FocusMap, self), WORLD_MAP);
	focusMap:AddCondition(GenerateClosure(self.IsMinimized, self));
	focusMap:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);

	local focusSearch = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_MENU_LEFT, GenerateClosure(self.FocusSearchBox, self));
	focusSearch:SetCustomPromptFrame(QuestScrollFrame.GamepadSearchFocusIcon);

	local settingsDropdown = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_MENU_RIGHT, GenerateClosure(self.HandleMainMenu, self));
	settingsDropdown:SetCustomPromptFrame(QuestScrollFrame.GamepadSettingsFocusIcon);

	self.questLogFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "QuestLogFooter");
	self.questLogFooter:AddStandardSelectPrompt();
	self.questLogFooter:AddStandardBackPrompt();
	self.questLogFooter:AddPromptedBinding(questOptions);
	self.questLogFooter:AddPromptedBinding(focusMap);
	self.questLogFooter:AddPromptedBinding(focusSearch);
	self.questLogFooter:AddPromptedBinding(settingsDropdown);
	self.questLogFooter:AddStandardFrameControlManagerBindings(self);
	self.questLogFooter:Finalize();
	
	self.questLogTooltipBindings = GamepadMode.CreateBindingGroup("questLogTooltipBindings");
	self.questLogTooltipBindings:AddFunctionBinding(GAMEPAD_FACE_LEFT, GenerateClosure(self.FocusSelectedQuest, self));
	self.questLogTooltipBindings:AddFunctionBinding(GAMEPAD_FACE_TOP, GenerateClosure(self.OpenQuestOptions, self));

	-- Quest Details actions.
	local questDetailsFocusPage = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_LEFT, GenerateClosure(self.FocusSelectedQuest, self), CONTEXT_ACTION_LABEL_FOCUS);
	local questDetailsOptionsPage = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_TOP, GenerateClosure(self.OpenQuestOptions, self), CONTEXT_ACTION_LABEL_OPTIONS);
	local questDetailsFocusMap = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_DPAD_LEFT, GenerateClosure(self.FocusMap, self), WORLD_MAP);
	local questDetailsBackPage = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_RIGHT, GenerateClosure(self.CloseQuestDetails, self), FRAME_ACTION_BACK);

	self.questDetailsFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "QuestDetailsFooter");
	self.questDetailsFooter:AddPromptedBinding(questDetailsFocusPage);
	self.questDetailsFooter:AddPromptedBinding(questDetailsOptionsPage);
	self.questDetailsFooter:AddPromptedBinding(questDetailsFocusMap);
	self.questDetailsFooter:AddPromptedBinding(questDetailsBackPage);
	self.questDetailsFooter:Finalize();

	-- World Map actions.
	local changeMap = GamepadSharedUtility.CreateDoublePromptedBinding(GAMEPAD_FACE_BOTTOM, GAMEPAD_FACE_LEFT, GenerateClosure(self.GamepadMapClick, self), GenerateClosure(self.GamepadMapUp, self), FRAME_ACTION_CHANGE_MAP)
	local closeWorldMap = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_RIGHT, GenerateClosure(self.GamepadBack, self), FRAME_ACTION_BACK);

	local focusQuests = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_DPAD_RIGHT, GenerateClosure(self.FocusQuestLogFromMap, self), QUESTS_LABEL);
	focusQuests:AddCondition(GenerateClosure(self.IsMinimized, self));
	focusQuests:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);

	self.navBarBindings = GamepadMode.CreateBindingGroup("WorldMapNavBarBindings");
	self.navBarBindings:AddFunctionBinding(GAMEPAD_SHOULDER_LEFT, GenerateClosure(self.OpenPreviousDropdownList, self));
	self.navBarBindings:AddFunctionBinding(GAMEPAD_SHOULDER_RIGHT, GenerateClosure(self.OpenNextDropdownList, self));

	local showFullMap = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_DPAD_BOTTOM, GenerateClosure(self.ToggleFullMap, self), FRAME_ACTION_OPEN_FULLMAP);
	showFullMap:AddCondition(GenerateClosure(self.IsMinimized, self));
	showFullMap:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);

	local showSmallMap = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_DPAD_TOP, GenerateClosure(self.ToggleFullMap, self), FRAME_ACTION_OPEN_MAP);
	showSmallMap:AddCondition(GenerateClosure(self.IsMaximized, self));
	showSmallMap:SetVisibilityType(PromptedBindingMixin.VISIBILITY_TYPE.ONLY_IF_USABLE);
	
	local mapMarker = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_LEFT_PRESS, GenerateClosure(self.GamepadTryPlaceWaypoint, self), FRAME_ACTION_MAP_MARKER);
	local mapZoom = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_STICK_RIGHT_VERTICAL, nil, FRAME_ACTION_ZOOM);

	local areaDropdown = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_FACE_TOP, GenerateClosure(self.OpenCurrentAreaDropdownList, self), CONTEXT_ACTION_LABEL_MORE_ACTIONS);
	areaDropdown:AddCondition(GenerateClosure(self.IsCurrentAreaDropdownContextValid, self));

	local filterDropdown = GamepadSharedUtility.CreatePromptedBinding(GAMEPAD_MENU_RIGHT, GenerateClosure(self.HandleMainMenu, self));
	filterDropdown:SetCustomPromptFrame(self.WorldMapTrackingOptionsButton.GamepadFocusIcon);

	self.worldMapFooter = GamepadSharedUtility.CreatePromptedBindingFooter(self, "WorldMapFooter");
	self.worldMapFooter:AddPromptedBinding(changeMap);
	self.worldMapFooter:AddPromptedBinding(closeWorldMap);
	self.worldMapFooter:AddPromptedBinding(focusQuests);
	self.worldMapFooter:AddPromptedBinding(showFullMap);
	self.worldMapFooter:AddPromptedBinding(showSmallMap);
	self.worldMapFooter:AddPromptedBinding(mapMarker);
	self.worldMapFooter:AddPromptedBinding(mapZoom);
	self.worldMapFooter:AddPromptedBinding(areaDropdown);
	self.worldMapFooter:AddPromptedBinding(filterDropdown);
	self.worldMapFooter:AddFunctionBinding(GAMEPAD_MENU_LEFT,GenerateClosure(self.HandleUnfocus, self));
	self.worldMapFooter:Finalize();

	self.worldMapCursorBindings = GamepadMode.CreateBindingGroup("WorldMapCursorBindings");
	self.worldMapCursorBindings:AddAxisBinding(GAMEPAD_STICK_LEFT, GenerateClosure(self.GamepadPanSpeed, self));
	self.worldMapCursorBindings:AddAxisBinding(GAMEPAD_STICK_RIGHT, GenerateClosure(self.GamepadZoom, self));

	local activateRewardsFunction = GenerateClosure(self.ActivateRewardsCursor, self)
	self.questDetailCursorBindings = GamepadMode.CreateBindingGroup("WorldMapQuestDetailCursorBindings");
	self.questDetailCursorBindings:AddFunctionBinding(GAMEPAD_DPAD_TOP, activateRewardsFunction);
	self.questDetailCursorBindings:AddFunctionBinding(GAMEPAD_DPAD_RIGHT, activateRewardsFunction);
	self.questDetailCursorBindings:AddFunctionBinding(GAMEPAD_DPAD_BOTTOM, activateRewardsFunction);
	self.questDetailCursorBindings:AddFunctionBinding(GAMEPAD_DPAD_LEFT, GenerateClosure(self.OnHitLeftEdge, self));

	-- Create map canvas drop shadow
	local canvas = self:GetCanvas();
	self.GamepadMapDropShadow = canvas:CreateTexture(nil, "BACKGROUND");
	self.GamepadMapDropShadow:SetAtlas("gamepad-mapquestlog-maps-dropshadow", true);
	self.GamepadMapDropShadow:SetPoint("CENTER", canvas);
	self.GamepadMapDropShadow:Hide();

	-- Create map trim texture.
	self.GamepadMapTrimTexture = canvas:CreateTexture(nil, "BACKGROUND", nil, -8);
	self.GamepadMapTrimTexture:SetAtlas("gamepad-mapquestlog-map-universaltrim", true);
	self.GamepadMapTrimTexture:SetPoint("CENTER", canvas);
	self.GamepadMapTrimTexture:Hide();
end

function WorldMapMixin:FocusGamepad()
	SmartNavigation:RegisterCallback("HitLeftEdge", self.OnHitLeftEdge, self);

	if self.currentFocus == MAP_FOCUS then
		self:FocusMap();
	elseif self.currentFocus == DETAILS_FOCUS or QuestMapFrame.DetailsFrame:IsShown() then
		self:FocusDetails();
	elseif self.currentFocus == QUEST_FOCUS then
		self:FocusQuests();
	else
		self:FocusMap();
	end

	self:UpdateStateChangeIndicators();
end

function WorldMapMixin:UnfocusGamepad()
	SmartNavigation:UnregisterCallback("HitLeftEdge", self);
	SmartNavigation:UnregisterCallback("HitBottomEdge", self);
	SmartNavigation:UnregisterCallback("HitRightEdge", self);
	SmartNavigation:SuspendCursor(false);
	self:ClearBindings();
	self:HideStateChangeIndicators();
end

function WorldMapMixin:InitializeGamepad()
	self.GamepadMapDropShadow:Show();
	self.GamepadMapTrimTexture:Show();

	-- Hide unnecessary Map/Quest elements for gamepad.
	self.CloseButton:Hide();
	self.BorderFrame.MaximizeMinimizeFrame:Hide();
	self.BorderFrame.Tutorial:Hide();

	if self.WorldMapTrackingPinButton then
		self.WorldMapTrackingPinButton:Hide();
	end

	QuestMapFrame.QuestsFrame.DetailsFrame.BackFrame.BackButton:Hide();
	QuestMapFrame.QuestsFrame.DetailsFrame.AbandonButton:Hide();
	QuestMapFrame.QuestsFrame.DetailsFrame.ShareButton:Hide();
	QuestMapFrame.QuestsFrame.DetailsFrame.TrackButton:Hide();

	QuestScrollFrame.SearchBox:ClearAllPoints();
	QuestScrollFrame.SearchBox:SetPoint("BOTTOMRIGHT", QuestScrollFrame.Contents, "TOP", 25, 7);

	self.WorldMapTrackingOptionsButton:SetPoint("LEFT", self.NavBar, "RIGHT", 19, -2);

	QuestMapDetailsScrollFrame:RegisterCallback("OnVerticalScroll", GenerateClosure(self.DeactivateRewardsCursor, self));
end

function WorldMapMixin:UninitializeGamepad()
	self.GamepadMapDropShadow:Hide();
	self.GamepadMapTrimTexture:Hide();

	-- Show Map/Quest elements hidden for gamepad.
	QuestMapFrame.QuestsTab:Show();
	QuestMapFrame.MapLegendTab:Show();
	self.CloseButton:Show();
	self.BorderFrame.MaximizeMinimizeFrame:Show();
	self.BorderFrame.Tutorial:Show();

	if self.WorldMapTrackingPinButton then
		self.WorldMapTrackingPinButton:Show();
	end

	QuestMapFrame.QuestsFrame.DetailsFrame.BackFrame.BackButton:Show();
	QuestMapFrame.QuestsFrame.DetailsFrame.AbandonButton:Show();
	QuestMapFrame.QuestsFrame.DetailsFrame.ShareButton:Show();
	QuestMapFrame.QuestsFrame.DetailsFrame.TrackButton:Show();

	self.WorldMapTrackingOptionsButton:SetPoint("TOPRIGHT", self.WorldMapTrackingOptionsButton.relativeFrame, -4, self.WorldMapTrackingOptionsButton.DefaultYOffset);

	QuestMapDetailsScrollFrame:UnregisterCallback("OnVerticalScroll", self);
end

function WorldMapMixin:RegisterForTransitions()
	InputUtil.RegisterForInterfaceTransitions(self, nil);
	InputUtil.RegisterGamepadSetup(self, GenerateClosure(self.SetupGamepad, self));
	InputUtil.RegisterGamepadInit(self, GenerateClosure(self.InitializeGamepad, self));
	InputUtil.RegisterGamepadUninit(self, GenerateClosure(self.UninitializeGamepad, self));
end

--[[ Help Plate ]] --
WorldMapTutorialMixin = { }

function WorldMapTutorialMixin:OnLoad()
	self.helpInfo = {
		FramePos = { x = 4,	y = -26 },
		FrameSize = { width = 1028, height = 500	},
		[1] = { ButtonPos = { x = 350,	y = -180 }, HighLightBox = { x = 0, y = -44, width = 695, height = 464 }, ToolTipDir = "DOWN", ToolTipText = WORLD_MAP_TUTORIAL1 },
		[2] = { ButtonPos = { x = 350,	y = 16 }, HighLightBox = { x = 50, y = 2, width = 645, height = 44 }, ToolTipDir = "DOWN", ToolTipText = WORLD_MAP_TUTORIAL4 },
	};
end

function WorldMapTutorialMixin:OnHide()
	self:CheckAndHideHelpInfo();
end

function WorldMapTutorialMixin:CheckAndShowTooltip()
	if (not NewPlayerExperience or not NewPlayerExperience.IsActive) and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME) then
		if not HelpPlate.IsShowingHelpInfo(self.helpInfo) then
			HelpPlate.ShowTutorialTooltip(self.helpInfo, self);
			SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true);
		end
	end
end

function WorldMapTutorialMixin:CheckAndHideHelpInfo()
	if HelpPlate.IsShowingHelpInfo(self.helpInfo) then
		HelpPlate.Hide();
	end

	if HelpPlate.IsShowingTutorialTooltip(self.helpInfo) then
		HelpPlate.HideTooltip();
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, false);
	end
end

function WorldMapTutorialMixin:ToggleHelpInfo()
	local mapFrame = self:GetParent():GetParent();
	if ( not HelpPlate.IsShowingHelpInfo(self.helpInfo) and mapFrame:IsShown()) then
		self:SetHelpInfo3();
		HelpPlate.Show(self.helpInfo, mapFrame, self);
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true);
		EventRegistry:RegisterCallback("QuestLog.SetDisplayMode", self.UpdateHelpInfo, self);
	else
		HelpPlate.Hide(true);
		EventRegistry:UnregisterCallback("QuestLog.SetDisplayMode", self);
	end
end

function WorldMapTutorialMixin:UpdateHelpInfo()
	if not HelpPlate.IsShowingHelpInfo(self.helpInfo) then
		return;
	end

	self:SetHelpInfo3();
	local mapFrame = self:GetParent():GetParent();
		HelpPlate.Show(self.helpInfo, mapFrame, self);
end

function WorldMapTutorialMixin:SetHelpInfo3()
	local mapFrame = self:GetParent():GetParent();
	local shownQuestLog = mapFrame.QuestLog and mapFrame.QuestLog:IsShown();
	local questLogHelpText = shownQuestLog and mapFrame.QuestLog.GetHelpInfoText and mapFrame.QuestLog:GetHelpInfoText();
	if questLogHelpText then
		self.helpInfo[3] = { ButtonPos = { x = 810,	y = -180 }, HighLightBox = { x = 700, y = 2, width = 328, height = 510 },	ToolTipDir = "DOWN", ToolTipText = questLogHelpText };
	else
		self.helpInfo[3] = nil;
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

-- ============================================ GLOBAL API ===============================================================================
function ToggleQuestLog()
	if C_GameRules.IsGameRuleActive(Enum.GameRule.WorldMapDisabled) then
		return;
	end

	WorldMapFrame:HandleUserActionToggleQuestLog();
end

function ToggleWorldMap()
	if C_GameRules.IsGameRuleActive(Enum.GameRule.WorldMapDisabled) then
		return;
	end

	WorldMapFrame:HandleUserActionToggleSelf();
end

function OpenWorldMap(mapID)
	if C_GameRules.IsGameRuleActive(Enum.GameRule.WorldMapDisabled) then
		return;
	end

	WorldMapFrame:HandleUserActionOpenSelf(mapID);
end

function OpenQuestLog(mapID)
	if C_GameRules.IsGameRuleActive(Enum.GameRule.WorldMapDisabled) then
		return;
	end

	WorldMapFrame:HandleUserActionOpenQuestLog(mapID);
end

function OpenMapToEventPoi(areaPoiID)
	if C_GameRules.IsGameRuleActive(Enum.GameRule.WorldMapDisabled) then
		return;
	end

	local mapID = C_EventScheduler.GetEventUiMapID(areaPoiID);
	if mapID then
		OpenWorldMap(mapID);
		EventRegistry:TriggerEvent("PingAreaPOIEvent", areaPoiID);
	end
end

function OpenMapToUserWaypoint()
	local waypoint = C_Map.GetUserWaypoint();
	if waypoint then
		OpenWorldMap(waypoint.uiMapID);
		EventRegistry:TriggerEvent("MapCanvas.PingWaypointLocation");
	end
end

