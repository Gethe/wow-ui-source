
NUM_WORLDMAP_POIS = 0;
NUM_WORLDMAP_WORLDEFFECT_POIS = 0;
NUM_WORLDMAP_SCENARIO_POIS = 0;
NUM_WORLDMAP_TASK_POIS = 0;
NUM_WORLDMAP_GRAVEYARDS = 0;
NUM_WORLDMAP_OVERLAYS = 0;
NUM_WORLDMAP_FLAGS = 4;
NUM_WORLDMAP_DEBUG_ZONEMAP = 0;
NUM_WORLDMAP_DEBUG_OBJECTS = 0;
WORLDMAP_COSMIC_ID = -1;
WORLDMAP_AZEROTH_ID = 0;
WORLDMAP_OUTLAND_ID = 3;
WORLDMAP_MAELSTROM_ID = 5;
WORLDMAP_DRAENOR_ID = 7;
MAELSTROM_ZONES_ID = { TheMaelstrom = 737, Deepholm = 640, Kezan = 605, TheLostIsles = 544 };
MAELSTROM_ZONES_LEVELS = { 
				TheMaelstrom = {minLevel = 0, maxLevel = 0}, 
				Deepholm = {minLevel = 82, maxLevel = 83, petMinLevel= 22, petMaxLevel = 23}, 
				Kezan = {minLevel = 1, maxLevel = 5}, 
				TheLostIsles = {minLevel = 5, maxLevel = 12} };
WORLDMAP_WINTERGRASP_ID = 501;
WORLDMAP_WINTERGRASP_POI_AREAID = 4197;
WORLDMAP_WINDOWED_SIZE = 0.695;		-- size corresponds to ratio value
WORLDMAP_FULLMAP_SIZE = 1.0;
local EJ_QUEST_POI_MINDIS_SQR = 2500;

local QUEST_POI_FRAME_INSET = 12;		-- roughly half the width/height of a POI icon
local QUEST_POI_FRAME_WIDTH;
local QUEST_POI_FRAME_HEIGHT;

local PLAYER_ARROW_SIZE_WINDOW = 40;
local PLAYER_ARROW_SIZE_FULL_WITH_QUESTS = 38;
local PLAYER_ARROW_SIZE_FULL_NO_QUESTS = 28;

AREA_NAME_FONT_COLOR = CreateColor(1.0, 0.9294, 0.7607);
AREA_DESCRIPTION_FONT_COLOR = HIGHLIGHT_FONT_COLOR;

INVASION_FONT_COLOR = CreateColor(0.78, 1, 0);
INVASION_DESCRIPTION_FONT_COLOR = CreateColor(1, 0.973, 0.035);

WORLD_MAP_MAX_ALPHA = 1;
WORLD_MAP_MIN_ALPHA = 0.2;

BAD_BOY_UNITS = {};
BAD_BOY_COUNT = 0;

local STORYLINE_FRAMES = { };

MAP_VEHICLES = {};
VEHICLE_TEXTURES = {};
VEHICLE_TEXTURES["Drive"] = {
	"Interface\\Minimap\\Vehicle-Ground-Unoccupied",
	"Interface\\Minimap\\Vehicle-Ground-Occupied",
	width=45,
	height=45,
};
VEHICLE_TEXTURES["Fly"] = {
	"Interface\\Minimap\\Vehicle-Air-Unoccupied",
	"Interface\\Minimap\\Vehicle-Air-Occupied",
	width=45,
	height=45,
};
VEHICLE_TEXTURES["Airship Horde"] = {
	"Interface\\Minimap\\Vehicle-Air-Horde",
	"Interface\\Minimap\\Vehicle-Air-Horde",
	width=64,
	height=64,
};
VEHICLE_TEXTURES["Airship Alliance"] = {
	"Interface\\Minimap\\Vehicle-Air-Alliance",
	"Interface\\Minimap\\Vehicle-Air-Alliance",
	width=64,
	height=64,
};
VEHICLE_TEXTURES["Carriage"] = {
	"Interface\\Minimap\\Vehicle-Carriage",
	"Interface\\Minimap\\Vehicle-Carriage",
	width=64,
	height=64,
};
VEHICLE_TEXTURES["Mogu"] = {
	"Interface\\Minimap\\Vehicle-Mogu",
	"Interface\\Minimap\\Vehicle-Mogu",
	width=64,
	height=64,
};
VEHICLE_TEXTURES["Grummle Convoy"] = {
	"Interface\\Minimap\\Vehicle-GrummleConvoy",
	"Interface\\Minimap\\Vehicle-GrummleConvoy",
	width=64,
	height=64,
};
VEHICLE_TEXTURES["Minecart"] = {
	"Interface\\Minimap\\Vehicle-SilvershardMines-MineCart",
	"Interface\\Minimap\\Vehicle-SilvershardMines-MineCart",
	width=64,
	height=64,
	belowPlayerBlips = true,
};
VEHICLE_TEXTURES["Minecart Red"] = {
	"Interface\\Minimap\\Vehicle-SilvershardMines-MineCartRed",
	"Interface\\Minimap\\Vehicle-SilvershardMines-MineCartRed",
	width=64,
	height=64,
	belowPlayerBlips = true,
};
VEHICLE_TEXTURES["Minecart Blue"] = {
	"Interface\\Minimap\\Vehicle-SilvershardMines-MineCartBlue",
	"Interface\\Minimap\\Vehicle-SilvershardMines-MineCartBlue",
	width=64,
	height=64,
	belowPlayerBlips = true,
};
VEHICLE_TEXTURES["Arrow"] = {
	"Interface\\Minimap\\Vehicle-SilvershardMines-Arrow",
	"Interface\\Minimap\\Vehicle-SilvershardMines-Arrow",
	width=64,
	height=64,
};
VEHICLE_TEXTURES["Trap Gold"] = {
	"Interface\\Minimap\\Vehicle-Trap-Gold",
	"Interface\\Minimap\\Vehicle-Trap-Gold",
	width=32,
	height=32,
};
VEHICLE_TEXTURES["Trap Grey"] = {
	"Interface\\Minimap\\Vehicle-Trap-Grey",
	"Interface\\Minimap\\Vehicle-Trap-Grey",
	width=32,
	height=32,
};
VEHICLE_TEXTURES["Trap Red"] = {
	"Interface\\Minimap\\Vehicle-Trap-Red",
	"Interface\\Minimap\\Vehicle-Trap-Red",
	width=32,
	height=32,
};
VEHICLE_TEXTURES["Hammer Gold 0"] = {
	"Interface\\Minimap\\Vehicle-HammerGold",
	"Interface\\Minimap\\Vehicle-HammerGold",
	width=32,
	height=32,
};
VEHICLE_TEXTURES["Hammer Gold 1"] = {
	"Interface\\Minimap\\Vehicle-HammerGold-1",
	"Interface\\Minimap\\Vehicle-HammerGold-1",
	width=32,
	height=32,
};
VEHICLE_TEXTURES["Hammer Gold 2"] = {
	"Interface\\Minimap\\Vehicle-HammerGold-2",
	"Interface\\Minimap\\Vehicle-HammerGold-2",
	width=32,
	height=32,
};
VEHICLE_TEXTURES["Hammer Gold 3"] = {
	"Interface\\Minimap\\Vehicle-HammerGold-3",
	"Interface\\Minimap\\Vehicle-HammerGold-3",
	width=32,
	height=32,
};
VEHICLE_TEXTURES["Cart Horde"] = {
	"Interface\\Minimap\\Vehicle-HordeCart",
	"Interface\\Minimap\\Vehicle-HordeCart",
	width=32,
	height=32,
	belowPlayerBlips = true,
};
VEHICLE_TEXTURES["Cart Alliance"] = {
	"Interface\\Minimap\\Vehicle-AllianceCart",
	"Interface\\Minimap\\Vehicle-AllianceCart",
	width=32,
	height=32,
	belowPlayerBlips = true,
};

WORLDMAP_DEBUG_ICON_INFO = {};
WORLDMAP_DEBUG_ICON_INFO[1] = { size =  6, r = 0.0, g = 1.0, b = 0.0 };
WORLDMAP_DEBUG_ICON_INFO[2] = { size = 16, r = 1.0, g = 1.0, b = 0.5 };
WORLDMAP_DEBUG_ICON_INFO[3] = { size = 32, r = 1.0, g = 1.0, b = 0.5 };
WORLDMAP_DEBUG_ICON_INFO[4] = { size = 64, r = 1.0, g = 0.6, b = 0.0 };

WORLDMAP_SETTINGS = {
	opacity = 0,
	locked = true,
	size = WORLDMAP_FULLMAP_SIZE,
	
};

WORLD_MAP_POI_FRAME_LEVEL_OFFSETS = {
	DUNGEON_ENTRANCE = 100,
	LANDMARK = 200,

	BONUS_OBJECTIVE = 500,
	INVASION = 700,

	SCENARIO = 1000,
	STORY_LINE = 1000,

	TRACKED_QUEST = 1200,
	WORLD_QUEST = 1200,
}

local WorldEffectPOITooltips = {};
local ScenarioPOITooltips = {};

local WorldMapOverlayHighlights = {};

function ToggleWorldMap()
	WorldMapFrame.questLogMode = nil;
	local shouldBeWindowed = GetCVarBool("miniWorldMap");
	local isWindowed = WorldMapFrame_InWindowedMode();
	if ( WorldMapFrame:IsShown() ) then
		if ( isWindowed == shouldBeWindowed ) then
			if ( QuestMapFrame:IsShown() and not GetCVarBool("questLogOpen") ) then
				QuestMapFrame_Close();
			else
				ToggleFrame(WorldMapFrame);
			end
		elseif ( isWindowed ) then
			WorldMap_ToggleSizeUp();
		else
			ToggleFrame(WorldMapFrame);
		end
	else
		if ( shouldBeWindowed ) then
			if ( not isWindowed ) then
				WorldMap_ToggleSizeDown();
			end
		else
			if ( WorldMapFrame_InWindowedMode() ) then
				WorldMap_ToggleSizeUp();
			end		
		end
		ToggleFrame(WorldMapFrame);
		if ( GetCVarBool("questLogOpen") ) then
			if ( WorldMapFrame_InWindowedMode() ) then
				QuestMapFrame_Open();
			end
		else
			QuestMapFrame_Close();
		end		
	end
end

function WorldMapFrame_InWindowedMode()
	return WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE;
end

function WorldMapFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("WORLD_MAP_UPDATE");
	self:RegisterEvent("CLOSE_WORLD_MAP");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("REQUEST_CEMETERY_LIST_RESPONSE");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("RESEARCH_ARTIFACT_DIG_SITE_UPDATED");
	self:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED");
	self:RegisterEvent("PLAYER_STARTED_MOVING");
	self:RegisterEvent("PLAYER_STOPPED_MOVING");
	self:RegisterEvent("QUESTLINE_UPDATE");
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("WORLD_QUEST_COMPLETED_BY_SPELL");
	
	self:SetClampRectInsets(0, 0, 0, -60);				-- don't overlap the xp/rep bars
	self.poiHighlight = nil;
	self.areaName = nil;
	
	-- RE: Bug ID: 345647 - Texture errors occur after entering the Nexus and relogging.
	-- The correct GetMapInfo() data is not yet available here, so don't try preloading incorrect map textures.
	--WorldMapFrame_Update();

	--[[ Hide the world behind the map when we're in widescreen mode
	local width = GetScreenWidth();
	local height = GetScreenHeight();
	
	if ( width / height < 4 / 3 ) then
		width = width * 1.25;
		height = height * 1.25;
	end
	
	BlackoutWorld:SetWidth( width );
	BlackoutWorld:SetHeight( height );
	]]

	-- setup the zone minimap button
	WorldMapLevelDropDown_Update();

	local homeData = {
		name = WORLD,
		OnClick = WorldMapNavBar_OnButtonSelect,
		listFunc = WorldMapNavBar_GetSibling,
		id = WORLDMAP_COSMIC_ID,
		isContinent = true,
	}
	NavBar_Initialize(self.NavBar, "NavButtonTemplate", homeData, self.navBar.home, self.navBar.overflow);

	ButtonFrameTemplate_HidePortrait(WorldMapFrame.BorderFrame);
	WorldMapFrame.BorderFrame.TitleText:SetText(MAP_AND_QUEST_LOG);
	WorldMapFrame.BorderFrame.portrait:SetTexture("Interface\\QuestFrame\\UI-QuestLog-BookIcon");
	WorldMapFrame.BorderFrame.CloseButton:SetScript("OnClick", function() HideUIPanel(WorldMapFrame); end);
	
	QUEST_POI_FRAME_WIDTH = WorldMapDetailFrame:GetWidth() * WORLDMAP_FULLMAP_SIZE;
	QUEST_POI_FRAME_HEIGHT = WorldMapDetailFrame:GetHeight() * WORLDMAP_FULLMAP_SIZE;
	QuestPOI_Initialize(WorldMapPOIFrame, WorldMapPOIButton_Init);
	
	WorldMapPlayerUpper:EnableMouse(false);
	WorldMapFrame.UIElementsFrame.BountyBoard:SetSelectedBountyChangedCallback(WorldMapFrame_SetBonusObjectivesDirty);
	WorldMapFrame.UIElementsFrame.ActionButton:SetOnCastChangedCallback(WorldMapFrame_SetBonusObjectivesDirty);
end

function WorldMapFrame_SetBonusObjectivesDirty() 
	WorldMapFrame.bonusObjectiveUpdateTimeLeft = 0;
end

function WorldMapFrame_OnShow(self)
	if ( WORLDMAP_SETTINGS.size ~= WORLDMAP_WINDOWED_SIZE ) then
		SetupFullscreenScale(self);
		-- pet battle level size adjustment
		WorldMapFrameAreaPetLevels:SetFontObject("TextStatusBarTextLarge")
	else
		-- pet battle level size adjustment
		WorldMapFrameAreaPetLevels:SetFontObject("SubZoneTextFont");
	end

	-- check to show the help plate
	if ( (not NewPlayerExperience or not NewPlayerExperience.IsActive) and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME) ) then
		local helpPlate = WorldMapFrame_HelpPlate;
		if ( helpPlate and not HelpPlate_IsShowing(helpPlate) ) then
			HelpPlate_ShowTutorialPrompt( helpPlate, WorldMapFrame.MainHelpButton );
			SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true );
		end
	end

	UpdateMicroButtons();
	if (not WorldMapFrame.toggling) then
		SetMapToCurrentZone();
	else
		WorldMapFrame.toggling = false;
	end
	PlaySound("igQuestLogOpen");
	CloseDropDownMenus();
	WorldMapFrame_UpdateUnits("WorldMapRaid", "WorldMapParty");
	DoEmote("READ", nil, true);
	
	WorldMapFrame.fadeOut = false;
end

function WorldMapFrame_OnHide(self)
	HelpPlate_Hide();
	UpdateMicroButtons();
	CloseDropDownMenus();
	PlaySound("igQuestLogClose");
	WorldMap_ClearTextures();
	if ( not self.toggling ) then
		if ( QuestMapFrame:IsShown() ) then
			QuestMapFrame_CheckTutorials();
		end
		QuestMapFrame_CloseQuestDetails();		
	end
	if ( WorldMapScrollFrame.zoomedIn ) then
		WorldMapScrollFrame_ResetZoom();
	end
	WorldMapPing.Ping:Stop();
	if ( self.showOnHide ) then
		ShowUIPanel(self.showOnHide);
		self.showOnHide = nil;
	end
	-- forces WatchFrame event via the WORLD_MAP_UPDATE event, needed to restore the POIs in the tracker to the current zone
	if (not WorldMapFrame.toggling) then
		WorldMapFrame.fromJournal = false;
		WorldMapFrame.hasBosses = false;
		SetMapToCurrentZone();
	end
	CancelEmote();
	self.mapID = nil;
	
	self.AnimAlphaOut:Stop();
	self.AnimAlphaIn:Stop();
	self:SetAlpha(WORLD_MAP_MAX_ALPHA);

	self.bonusObjectiveUpdateTimeLeft = nil;

	WorldMapOverlayHighlights = {};

	self.UIElementsFrame.ActionButton:SetMapAreaID(nil);
	self.UIElementsFrame.ActionButton:SetHasWorldQuests(false);
end

function WorldMapFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( self:IsShown() ) then
			HideUIPanel(WorldMapFrame);
		end
	elseif ( event == "WORLD_MAP_UPDATE" or event == "REQUEST_CEMETERY_LIST_RESPONSE" or event == "QUESTLINE_UPDATE" ) then
		if ( not self.blockWorldMapUpdate and self:IsShown() ) then
			-- if we are exiting a micro dungeon we should update the world map
			if (event == "REQUEST_CEMETERY_LIST_RESPONSE") then
				local _, _, _, isMicroDungeon = GetMapInfo();
				if (isMicroDungeon) then
					SetMapToCurrentZone();
				end
			end
			WorldMapFrame_UpdateMap();
		end
		if ( event == "WORLD_MAP_UPDATE" ) then
			local mapID = GetCurrentMapAreaID();
			if ( mapID ~= self.mapID) then
				self.mapID = mapID;
				WorldMapPing.Ping:Stop();
				local playerX, playerY = GetPlayerMapPosition("player");
				if ( playerX ~= 0 or playerY ~= 0 ) then
					WorldMapPing.Ping:Play();
				end
			end
			if ( QuestMapFrame.DetailsFrame.questMapID and QuestMapFrame.DetailsFrame.questMapID ~= GetCurrentMapAreaID() ) then
				QuestMapFrame_CloseQuestDetails();
			else
				QuestMapFrame_UpdateAll();
			end
			if ( WorldMapScrollFrame.zoomedIn ) then
				if ( WorldMapScrollFrame.continent ~= GetCurrentMapContinent() or WorldMapScrollFrame.mapID ~= GetCurrentMapAreaID() ) then
					WorldMapScrollFrame_ResetZoom();
				end				
			end
		end
	elseif ( event == "RESEARCH_ARTIFACT_DIG_SITE_UPDATED" ) then
		if ( self:IsShown() ) then
			RefreshWorldMap();
		end
	elseif ( event == "CLOSE_WORLD_MAP" ) then
		HideUIPanel(self);
	elseif ( event == "VARIABLES_LOADED" ) then
		WORLD_MAP_MIN_ALPHA = tonumber(GetCVar("mapAnimMinAlpha"));
		WORLDMAP_SETTINGS.locked = GetCVarBool("lockedWorldMap");
		WORLDMAP_SETTINGS.opacity = (tonumber(GetCVar("worldMapOpacity")));
		if ( GetCVarBool("miniWorldMap") ) then
			WorldMap_ToggleSizeDown();
			if ( GetCVarBool("questLogOpen") ) then
				QuestMapFrame_Show();
			end
		else
			--WorldMapBlobFrame:SetScale(WORLDMAP_QUESTLIST_SIZE);
			--ScenarioPOIFrame:SetScale(WORLDMAP_FULLMAP_SIZE);	--If we ever need to add objectives on the map itself we should adjust this value
		end
		if ( GetCVarBool("digSites") ) then
			WorldMapArchaeologyDigSites:Show();
		else
			WorldMapArchaeologyDigSites:Hide();
		end
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		if ( self:IsShown() ) then
			WorldMapFrame_UpdateUnits("WorldMapRaid", "WorldMapParty");
		end
	elseif ( event == "DISPLAY_SIZE_CHANGED" ) then
		--if ( WatchFrame.showObjectives and self:IsShown() ) then
		--	WorldMapFrame_UpdateQuests();
		--end
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		EncounterJournal_UpdateMapButtonPortraits();
	elseif ( event == "SUPER_TRACKED_QUEST_CHANGED" ) then
		local questID = ...;
		WorldMapFrame_SetBonusObjectivesDirty();
		WorldMapPOIFrame_SelectPOI(questID);
	elseif ( event == "PLAYER_STARTED_MOVING" ) then
		if ( GetCVarBool("mapFade") ) then
			WorldMapFrame_AnimAlphaOut(self, true);
			WorldMapFrame.fadeOut = true;
		end
	elseif ( event == "PLAYER_STOPPED_MOVING" ) then
		WorldMapFrame_AnimAlphaIn(self, true);
		WorldMapFrame.fadeOut = false;
	elseif ( event == "QUEST_LOG_UPDATE" ) then
		if WorldMapFrame:IsVisible() then
			WorldMap_UpdateQuestBonusObjectives();
			WorldMapFrame_UpdateOverlayLocations();
		end
	elseif ( event == "WORLD_QUEST_COMPLETED_BY_SPELL" ) then
		if WorldMapFrame:IsVisible() then
			WorldMapFrame_SetBonusObjectivesDirty();
		end
	end
end

function WorldMapFrame_OnUserChangedSuperTrackedQuest(questID)
	if ( WorldMapFrame:IsShown() ) then
		local mapID, floorNumber = GetQuestWorldMapAreaID(questID);
		if ( mapID ~= 0 ) then
			SetMapByID(mapID);
			if ( floorNumber ~= 0 ) then
				SetDungeonMapLevel(floorNumber);
			end
		end
	end
end

function WorldMapFrame_AnimAlphaIn(self, useStartDelay)
	WorldMapFrame_AnimateAlpha(self, useStartDelay, self.AnimAlphaIn, self.AnimAlphaOut, WORLD_MAP_MIN_ALPHA, WORLD_MAP_MAX_ALPHA);
end

function WorldMapFrame_AnimAlphaOut(self, useStartDelay)
	WorldMapFrame_AnimateAlpha(self, useStartDelay, self.AnimAlphaOut, self.AnimAlphaIn, WORLD_MAP_MAX_ALPHA, WORLD_MAP_MIN_ALPHA);
end

function WorldMapFrame_AnimateAlpha(self, useStartDelay, anim, otherAnim, startAlpha, endAlpha)
	if ( not WorldMapFrame_InWindowedMode() or not self:IsShown() ) then
		return;
	end

	if ( anim:IsPlaying() or self:GetAlpha() == endAlpha ) then
		otherAnim:Stop();
		return;
	end
	
	local startDelay = 0;
	if ( useStartDelay ) then
		startDelay = tonumber(GetCVar("mapAnimStartDelay"));
	end

	if ( otherAnim:IsPlaying() ) then
		startDelay = 0;
		startAlpha = self:GetAlpha();
		otherAnim:Stop();
		self:SetAlpha(startAlpha);
	end

	local duration = ((endAlpha - startAlpha) / (WORLD_MAP_MAX_ALPHA - WORLD_MAP_MIN_ALPHA)) * tonumber(GetCVar("mapAnimDuration"));
	anim.Alpha:SetFromAlpha(startAlpha);
	anim.Alpha:SetToAlpha(endAlpha);
	anim.Alpha:SetDuration(abs(duration));
	anim.Alpha:SetStartDelay(startDelay);
	anim:Play();	
end

local TIME_BETWEEN_BONUS_OBJECTIVE_REFRESH_SECS = 10;
function WorldMapFrame_OnUpdate(self, elapsed)

	local nextBattleTime = GetOutdoorPVPWaitTime();
	if ( nextBattleTime and not IsInInstance()) then
		local battleSec = mod(nextBattleTime, 60);
		local battleMin = mod(floor(nextBattleTime / 60), 60);
		local battleHour = floor(nextBattleTime / 3600);
		WorldMapZoneInfo:SetFormattedText(NEXT_BATTLE, battleHour, battleMin, battleSec);
		WorldMapZoneInfo:Show();
	else
		WorldMapZoneInfo:Hide();
	end
	
	if ( WorldMapFrame_InWindowedMode() and IsPlayerMoving() and GetCVarBool("mapFade") and WorldMapFrame.fadeOut ) then
		if ( self:IsMouseOver() ) then
			WorldMapFrame_AnimAlphaIn(self);
			self.wasMouseOver = true;
		elseif ( self.wasMouseOver ) then
			WorldMapFrame_AnimAlphaOut(self);
			self.wasMouseOver = nil;
		end
	end

	self.bonusObjectiveUpdateTimeLeft = (self.bonusObjectiveUpdateTimeLeft or TIME_BETWEEN_BONUS_OBJECTIVE_REFRESH_SECS) - elapsed;
	if ( self.bonusObjectiveUpdateTimeLeft <= 0 ) then
		WorldMap_UpdateQuestBonusObjectives();
		self.bonusObjectiveUpdateTimeLeft = TIME_BETWEEN_BONUS_OBJECTIVE_REFRESH_SECS;
	end
end

function WorldMapFrame_OnKeyDown(self, key)
	local binding = GetBindingFromClick(key)
	if ((binding == "TOGGLEWORLDMAP") or (binding == "TOGGLEGAMEMENU")) then
		RunBinding("TOGGLEWORLDMAP");
	elseif ( binding == "SCREENSHOT" ) then
		RunBinding("SCREENSHOT");
	elseif ( binding == "MOVIE_RECORDING_STARTSTOP" ) then
		RunBinding("MOVIE_RECORDING_STARTSTOP");
	elseif ( binding == "TOGGLEWORLDMAPSIZE" ) then
		RunBinding("TOGGLEWORLDMAPSIZE");
	elseif ( binding == "TOGGLEQUESTLOG" ) then
		RunBinding("TOGGLEQUESTLOG");
	end
end

-----------------------------------------------------------------
-- Draw quest bonus objectives
-----------------------------------------------------------------
local function ApplyTextureToPOI(texture, width, height)
	texture:SetTexCoord(0, 1, 0, 1);
	texture:ClearAllPoints();
	texture:SetPoint("CENTER", texture:GetParent());
	texture:SetSize(width or 32, height or 32);
end

local function ApplyAtlasTexturesToPOI(button, normal, pushed, highlight, width, height)
	button:SetSize(20, 20);
	button:SetNormalAtlas(normal);
	ApplyTextureToPOI(button:GetNormalTexture(), width, height);

	button:SetPushedAtlas(pushed);
	ApplyTextureToPOI(button:GetPushedTexture(), width, height);

	button:SetHighlightAtlas(highlight);
	ApplyTextureToPOI(button:GetHighlightTexture(), width, height);

	if button.SelectedGlow then
		button.SelectedGlow:SetAtlas(pushed);
		ApplyTextureToPOI(button.SelectedGlow, width, height);
	end
end

local function ApplyStandardTexturesToPOI(button, selected)
	button:SetSize(20, 20);
	button:SetNormalTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
	ApplyTextureToPOI(button:GetNormalTexture());
	if selected then
		button:GetNormalTexture():SetTexCoord(0.500, 0.625, 0.375, 0.5);
	else
		button:GetNormalTexture():SetTexCoord(0.875, 1, 0.375, 0.5);
	end
	

	button:SetPushedTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
	ApplyTextureToPOI(button:GetPushedTexture());
	if selected then
		button:GetPushedTexture():SetTexCoord(0.375, 0.500, 0.375, 0.5);
	else
		button:GetPushedTexture():SetTexCoord(0.750, 0.875, 0.375, 0.5);
	end

	button:SetHighlightTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons");
	ApplyTextureToPOI(button:GetHighlightTexture());
	button:GetHighlightTexture():SetTexCoord(0.625, 0.750, 0.875, 1);
end

WORLD_QUEST_ICONS_BY_PROFESSION = {
	[129] = "worldquest-icon-firstaid",
	[164] = "worldquest-icon-blacksmithing",
	[165] = "worldquest-icon-leatherworking",
	[171] = "worldquest-icon-alchemy",
	[182] = "worldquest-icon-herbalism",
	[186] = "worldquest-icon-mining",
	[202] = "worldquest-icon-engineering",
	[333] = "worldquest-icon-enchanting",
	[755] = "worldquest-icon-jewelcrafting",
	[773] = "worldquest-icon-inscription",
	[794] = "worldquest-icon-archaeology",
	[356] = "worldquest-icon-fishing",
	[185] = "worldquest-icon-cooking",
	[197] = "worldquest-icon-tailoring",
	[393] = "worldquest-icon-skinning",
};

function WorldMap_SetupWorldQuestButton(button, worldQuestType, rarity, isElite, tradeskillLineIndex, inProgress, selected, isCriteria, isSpellTarget)
	button.Glow:SetShown(selected);

	if rarity == LE_WORLD_QUEST_QUALITY_COMMON then
		ApplyStandardTexturesToPOI(button, selected);
	elseif rarity == LE_WORLD_QUEST_QUALITY_RARE then
		ApplyAtlasTexturesToPOI(button, "worldquest-questmarker-rare", "worldquest-questmarker-rare-down", "worldquest-questmarker-rare", 18, 18);
	elseif rarity == LE_WORLD_QUEST_QUALITY_EPIC then
		ApplyAtlasTexturesToPOI(button, "worldquest-questmarker-epic", "worldquest-questmarker-epic-down", "worldquest-questmarker-epic", 18, 18);
	end

	if ( button.SelectedGlow ) then
		button.SelectedGlow:SetShown(rarity ~= LE_WORLD_QUEST_QUALITY_COMMON and selected);
	end

	if ( isElite ) then
		button.Underlay:SetAtlas("worldquest-questmarker-dragon");
		button.Underlay:Show();
	else
		button.Underlay:Hide();
	end

	local tradeskillLineID = tradeskillLineIndex and select(7, GetProfessionInfo(tradeskillLineIndex));
	if ( worldQuestType == LE_QUEST_TAG_TYPE_PVP ) then
		if ( inProgress ) then
			button.Texture:SetAtlas("worldquest-questmarker-questionmark");
			button.Texture:SetSize(10, 15);
		else
			button.Texture:SetAtlas("worldquest-icon-pvp-ffa", true);
		end
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_PET_BATTLE ) then
		if ( inProgress ) then
			button.Texture:SetAtlas("worldquest-questmarker-questionmark");
			button.Texture:SetSize(10, 15);
		else
			button.Texture:SetAtlas("worldquest-icon-petbattle", true);
		end
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_PROFESSION and WORLD_QUEST_ICONS_BY_PROFESSION[tradeskillLineID] ) then
		if ( inProgress ) then
			button.Texture:SetAtlas("worldquest-questmarker-questionmark");
			button.Texture:SetSize(10, 15);
		else
			button.Texture:SetAtlas(WORLD_QUEST_ICONS_BY_PROFESSION[tradeskillLineID], true);
		end
	elseif ( worldQuestType == LE_QUEST_TAG_TYPE_WORLD_BOSS ) then
		if ( inProgress ) then
			button.Texture:SetAtlas("worldquest-questmarker-questionmark");
			button.Texture:SetSize(10, 15);
		else
			button.Texture:SetAtlas("worldquest-icon-dungeon", true);
		end
	else
		if ( inProgress ) then
			button.Texture:SetAtlas("worldquest-questmarker-questionmark");
			button.Texture:SetSize(10, 15);
		else
			button.Texture:SetAtlas("worldquest-questmarker-questbang");
			button.Texture:SetSize(6, 15);
		end
	end

	if ( button.TimeLowFrame ) then
		if ( timeLeftMinutes and timeLeftMinutes <= WORLD_QUESTS_TIME_LOW_MINUTES ) then
			button.TimeLowFrame:Show();
		else
			button.TimeLowFrame:Hide();
		end
	end

	if ( button.CriteriaMatchGlow ) then
		if ( isCriteria ) then
			if ( isElite ) then
				button.CriteriaMatchGlow:SetAtlas("worldquest-questmarker-dragon-glow", true);
				button.CriteriaMatchGlow:SetPoint("CENTER", 0, -1);
			else
				button.CriteriaMatchGlow:SetAtlas("worldquest-questmarker-glow", true);
				button.CriteriaMatchGlow:SetPoint("CENTER", 0, 0);
			end
			button.CriteriaMatchGlow:Show();
		else
			button.CriteriaMatchGlow:Hide();
		end
	end

	if ( button.SpellTargetGlow ) then
		button.SpellTargetGlow:SetShown(isSpellTarget);
	end
end

function WorldMap_DoesWorldQuestInfoPassFilters(info, ignoreTypeFilters, ignoreTimeRequirement)
	if ( not ignoreTypeFilters ) then
		local tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex = GetQuestTagInfo(info.questId);

		if ( worldQuestType == LE_QUEST_TAG_TYPE_PROFESSION ) then
			local prof1, prof2, arch, fish, cook, firstAid = GetProfessions();

			if ( tradeskillLineIndex == prof1 or tradeskillLineIndex == prof2 ) then
				if ( not GetCVarBool("primaryProfessionsFilter") ) then
					return false;
				end
			end

			if ( tradeskillLineIndex == fish or tradeskillLineIndex == cook or tradeskillLineIndex == firstAid ) then
				if ( not GetCVarBool("secondaryProfessionsFilter") ) then
					return false;
				end
			end
		elseif ( worldQuestType == LE_QUEST_TAG_TYPE_PET_BATTLE ) then
			if ( not GetCVarBool("showTamers") ) then
				return false;
			end
		end
	end

	if ( not ignoreTimeRequirement ) then
		local timeLeftMinutes = C_TaskQuest.GetQuestTimeLeftMinutes(info.questId);
		if ( timeLeftMinutes and timeLeftMinutes <= WORLD_QUESTS_TIME_CRITICAL_MINUTES and not info.inProgress ) then
			return false;
		end
	end

	return true;
end

function WorldMap_TryCreatingWorldQuestPOI(info, taskIconIndex)
	if ( WorldMap_IsWorldQuestSuppressed(info.questId) or not WorldMap_DoesWorldQuestInfoPassFilters(info) ) then
		return nil;
	end

	local tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex = GetQuestTagInfo(info.questId);

	local taskPOI = WorldMap_GetOrCreateTaskPOI(taskIconIndex);
	local selected = info.questId == GetSuperTrackedQuestID();

	local isCriteria = WorldMapFrame.UIElementsFrame.BountyBoard:IsWorldQuestCriteriaForSelectedBounty(info.questId);
	local isSpellTarget = SpellCanTargetQuest() and IsQuestIDValidSpellTarget(info.questId);

	taskPOI.worldQuest = true;
	taskPOI.Texture:SetDrawLayer("OVERLAY");

	WorldMap_SetupWorldQuestButton(taskPOI, worldQuestType, rarity, isElite, tradeskillLineIndex, info.inProgress, selected, isCriteria, isSpellTarget)

	return taskPOI;
end

function WorldMap_TryCreatingBonusObjectivePOI(info, taskIconIndex)
	local taskPOI = WorldMap_GetOrCreateTaskPOI(taskIconIndex);
	taskPOI:SetSize(24, 24);
	taskPOI:SetNormalTexture(nil);
	taskPOI:SetPushedTexture(nil);
	taskPOI:SetHighlightTexture(nil);
	taskPOI.Underlay:Hide();
	taskPOI.Texture:SetAtlas("QuestBonusObjective");
	taskPOI.Texture:SetSize(24, 24);
	taskPOI.Texture:SetDrawLayer("BACKGROUND");
	taskPOI.TimeLowFrame:Hide();
	taskPOI.CriteriaMatchGlow:Hide();
	taskPOI.SpellTargetGlow:Hide();
	taskPOI.Glow:Hide();
	taskPOI.SelectedGlow:Hide();
	taskPOI.worldQuest = false;

	return taskPOI;
end

function WorldMap_UpdateQuestBonusObjectives()
	local mapAreaID = GetCurrentMapAreaID();
	local taskInfo = C_TaskQuest.GetQuestsForPlayerByMapID(mapAreaID);
	local numTaskPOIs = 0;
	if(taskInfo ~= nil) then
		numTaskPOIs = #taskInfo;
	end

	--Ensure the button pool is big enough for all the world effect POI's
	if ( NUM_WORLDMAP_TASK_POIS < numTaskPOIs ) then
		for i=NUM_WORLDMAP_TASK_POIS+1, numTaskPOIs do
			WorldMap_GetOrCreateTaskPOI(i);
		end
		NUM_WORLDMAP_TASK_POIS = numTaskPOIs;
	end

	local hasWorldQuests = false;
	local taskIconIndex = 1;
	if ( numTaskPOIs > 0 ) then
		for i, info  in ipairs(taskInfo) do
			if ( HaveQuestData(info.questId) ) then
				local taskPOI;
				local isWorldQuest = QuestMapFrame_IsQuestWorldQuest(info.questId);
				if ( isWorldQuest ) then
					taskPOI = WorldMap_TryCreatingWorldQuestPOI(info, taskIconIndex);
				else
					taskPOI = WorldMap_TryCreatingBonusObjectivePOI(info, taskIconIndex);
				end

				if ( taskPOI ) then
					WorldMapPOIFrame_AnchorPOI(taskPOI, info.x, info.y, isWorldQuest and WORLD_MAP_POI_FRAME_LEVEL_OFFSETS.WORLD_QUEST or WORLD_MAP_POI_FRAME_LEVEL_OFFSETS.BONUS_OBJECTIVE);
					taskPOI.questID = info.questId;
					taskPOI.numObjectives = info.numObjectives;
					taskPOI:Show();

					taskIconIndex = taskIconIndex + 1;

					if ( isWorldQuest ) then
						hasWorldQuests = true;
					end
				end
			end
		end
	end
	
	-- Hide unused icons in the pool
	for i = taskIconIndex, NUM_WORLDMAP_TASK_POIS do
		_G["WorldMapFrameTaskPOI"..i]:Hide();
	end

	WorldMapFrame.UIElementsFrame.ActionButton:SetHasWorldQuests(hasWorldQuests);
end

function WorldMap_DrawWorldEffects()
	-----------------------------------------------------------------
	-- Draw quest POI world effects
	-----------------------------------------------------------------
	-- local numPOIWorldEffects = GetNumQuestPOIWorldEffects();
	
	-- --Ensure the button pool is big enough for all the world effect POI's
	-- if ( NUM_WORLDMAP_WORLDEFFECT_POIS < numPOIWorldEffects ) then
		-- for i=NUM_WORLDMAP_WORLDEFFECT_POIS+1, numPOIWorldEffects do
			-- WorldMap_CreateWorldEffectPOI(i);
		-- end
		-- NUM_WORLDMAP_WORLDEFFECT_POIS = numPOIWorldEffects;
	-- end
	
	-- -- Process every button in the world event POI pool
	-- for i=1,NUM_WORLDMAP_WORLDEFFECT_POIS do
		
		-- local worldEventPOIName = "WorldMapFrameWorldEffectPOI"..i;
		-- local worldEventPOI = _G[worldEventPOIName];
		
		-- -- Draw if used
		-- if ( (i <= numPOIWorldEffects) and (WatchFrame.showObjectives == true)) then
			-- local name, textureIndex, x, y  = GetQuestPOIWorldEffectInfo(i);	
			-- if (textureIndex) then -- could be outside this map
				-- local x1, x2, y1, y2 = GetObjectIconTextureCoords(textureIndex);
				-- _G[worldEventPOIName.."Texture"]:SetTexCoord(x1, x2, y1, y2);
				-- WorldMapPOIFrame_AnchorPOI(worldEventPOI, x, y);
				-- worldEventPOI.name = worldEventPOIName;		
				-- worldEventPOI:Show();
				-- WorldEffectPOITooltips[worldEventPOIName] = name;
			-- else
				-- worldEventPOI:Hide();
			-- end
		-- else
			-- -- Hide if unused
			-- worldEventPOI:Hide();
		-- end		
	-- end
	
	-----------------------------------------------------------------
	-- Draw scenario POIs
	-----------------------------------------------------------------
	local scenarioIconInfo = C_Scenario.GetScenarioIconInfo();
	local numScenarioPOIs = 0;
	if(scenarioIconInfo ~= nil) then
		numScenarioPOIs = #scenarioIconInfo;
	end
	
	--Ensure the button pool is big enough for all the world effect POI's
	if ( NUM_WORLDMAP_SCENARIO_POIS < numScenarioPOIs ) then
		for i=NUM_WORLDMAP_SCENARIO_POIS+1, numScenarioPOIs do
			WorldMap_CreateScenarioPOI(i);
		end
		NUM_WORLDMAP_SCENARIO_POIS = numScenarioPOIs;
	end
	
	-- Draw scenario icons
	local scenarioIconCount = 1;
	if( GetCVarBool("questPOI") and (scenarioIconInfo ~= nil))then
		for _, info  in pairs(scenarioIconInfo) do
		
			--textureIndex, x, y, name
			local textureIndex = info.index;
			local x = info.x;
			local y = info.y;
			local name = info.description;
			
			local scenarioPOIName = "WorldMapFrameScenarioPOI"..scenarioIconCount;
			local scenarioPOI = _G[scenarioPOIName];
			
			local x1, x2, y1, y2 = GetObjectIconTextureCoords(textureIndex);
			_G[scenarioPOIName.."Texture"]:SetTexCoord(x1, x2, y1, y2);
			WorldMapPOIFrame_AnchorPOI(scenarioPOI, x, y, WORLD_MAP_POI_FRAME_LEVEL_OFFSETS.SCENARIO);
			scenarioPOI.name = scenarioPOIName;		
			scenarioPOI:Show();
			ScenarioPOITooltips[scenarioPOIName] = name;
				
			scenarioIconCount = scenarioIconCount + 1;
		end
	end
	
	-- Hide unused icons in the pool
	for i=scenarioIconCount, NUM_WORLDMAP_SCENARIO_POIS do
		local scenarioPOIName = "WorldMapFrameScenarioPOI"..i;
		local scenarioPOI = _G[scenarioPOIName];
		scenarioPOI:Hide();
	end
end

function WorldMap_ShouldShowLandmark(landmarkType)
	if not landmarkType then
		return false;
	end

	if landmarkType == LE_MAP_LANDMARK_TYPE_DIGSITE then
		return GetCVarBool("digSites");
	end

	if landmarkType == LE_MAP_LANDMARK_TYPE_TAMER then
		return GetCVarBool("showTamers");
	end

	return true;
end

function WorldMap_GetFrameLevelForLandmark(landmarkType)
	if landmarkType == LE_MAP_LANDMARK_TYPE_INVASION then
		return WORLD_MAP_POI_FRAME_LEVEL_OFFSETS.INVASION;
	elseif landmarkType == LE_MAP_LANDMARK_TYPE_DUNGEON_ENTRANCE then
		return WORLD_MAP_POI_FRAME_LEVEL_OFFSETS.DUNGEON_ENTRANCE;
	end
	return WORLD_MAP_POI_FRAME_LEVEL_OFFSETS.LANDMARK;
end

function WorldMap_UpdateLandmarks()
	local numPOIs = GetNumMapLandmarks();
	if ( NUM_WORLDMAP_POIS < numPOIs ) then
		for i=NUM_WORLDMAP_POIS+1, numPOIs do
			WorldMap_CreatePOI(i);
		end
		NUM_WORLDMAP_POIS = numPOIs;
	end
	local numGraveyards = 0;
	local currentGraveyard = GetCemeteryPreference();
    local mapID = GetCurrentMapAreaID();
	for i=1, NUM_WORLDMAP_POIS do
		local worldMapPOIName = "WorldMapFramePOI"..i;
		local worldMapPOI = _G[worldMapPOIName];
		if ( i <= numPOIs ) then
			local landmarkType, name, description, textureIndex, x, y, mapLinkID, inBattleMap, graveyardID, areaID, poiID, isObjectIcon, atlasIcon = GetMapLandmarkInfo(i);
			if( not WorldMap_ShouldShowLandmark(landmarkType) or (mapID ~= WORLDMAP_WINTERGRASP_ID and areaID == WORLDMAP_WINTERGRASP_POI_AREAID) ) then
				worldMapPOI:Hide();
			else
				WorldMapPOIFrame_AnchorPOI(worldMapPOI, x, y, WorldMap_GetFrameLevelForLandmark(landmarkType));
				if ( landmarkType == LE_MAP_LANDMARK_TYPE_NORMAL and WorldMap_IsSpecialPOI(poiID) ) then	--We have special handling for Isle of the Thunder King
					WorldMap_HandleSpecialPOI(worldMapPOI, poiID);
				else
					WorldMap_ResetPOI(worldMapPOI, isObjectIcon, atlasIcon);

					if (not atlasIcon) then
						local x1, x2, y1, y2
						if (isObjectIcon) then
							x1, x2, y1, y2 = GetObjectIconTextureCoords(textureIndex);
						else
							x1, x2, y1, y2 = GetPOITextureCoords(textureIndex);
						end
						worldMapPOI.Texture:SetTexCoord(x1, x2, y1, y2);
						worldMapPOI.HighlightTexture:SetTexCoord(x1, x2, y1, y2);
					else
						worldMapPOI.Texture:SetTexCoord(0, 1, 0, 1);
						worldMapPOI.HighlightTexture:SetTexCoord(0, 1, 0, 1);
					end

					worldMapPOI.name = name;
					worldMapPOI.description = description;
					worldMapPOI.mapLinkID = mapLinkID;
					worldMapPOI.poiID = poiID;
					worldMapPOI.landmarkType = landmarkType;
					if ( graveyardID and graveyardID > 0 ) then
						worldMapPOI.graveyard = graveyardID;
						numGraveyards = numGraveyards + 1;
						local graveyard = WorldMap_GetGraveyardButton(numGraveyards);
						graveyard:SetPoint("CENTER", worldMapPOI);
						graveyard:SetFrameLevel(worldMapPOI:GetFrameLevel() - 1);
						graveyard:Show();
						if ( currentGraveyard == graveyardID ) then
							graveyard.texture:SetTexture("Interface\\WorldMap\\GravePicker-Selected");
						else
							graveyard.texture:SetTexture("Interface\\WorldMap\\GravePicker-Unselected");
						end
						worldMapPOI:Hide();		-- lame way to force tooltip redraw
					else
						worldMapPOI.graveyard = nil;
					end
					worldMapPOI:Show();	
				end
			end
		else
			worldMapPOI:Hide();
		end
	end
	if ( numGraveyards > NUM_WORLDMAP_GRAVEYARDS ) then
		NUM_WORLDMAP_GRAVEYARDS = numGraveyards;
	else
		for i = numGraveyards + 1, NUM_WORLDMAP_GRAVEYARDS do
			_G["WorldMapFrameGraveyard"..i]:Hide();
		end
	end
end

function WorldMapFrame_Update()
	local mapName, textureHeight, _, isMicroDungeon, microDungeonMapName = GetMapInfo();
	if (isMicroDungeon and (not microDungeonMapName or microDungeonMapName == "")) then
		return;
	end
	
	if ( not mapName ) then
		if ( GetCurrentMapContinent() == WORLDMAP_COSMIC_ID ) then
			mapName = "Cosmic";
			OutlandButton:Show();
			AzerothButton:Show();
			DraenorButton:Show();
		else
			-- Temporary Hack (Temporary meaning 11 yrs, haha)
			mapName = "World";
			OutlandButton:Hide();
			AzerothButton:Hide();
			DraenorButton:Hide();
		end
		DeepholmButton:Hide();
		KezanButton:Hide();
		LostIslesButton:Hide();
		TheMaelstromButton:Hide();
	else
		OutlandButton:Hide();
		AzerothButton:Hide();
		DraenorButton:Hide();
		if ( GetCurrentMapContinent() == WORLDMAP_MAELSTROM_ID and GetCurrentMapZone() == 0 ) then
			DeepholmButton:Show();
			KezanButton:Show();
			LostIslesButton:Show();
			TheMaelstromButton:Show();
		else
			DeepholmButton:Hide();
			KezanButton:Hide();
			LostIslesButton:Hide();
			TheMaelstromButton:Hide();
		end
	end
	
	local dungeonLevel = GetCurrentMapDungeonLevel();
	if (DungeonUsesTerrainMap()) then
		dungeonLevel = dungeonLevel - 1;
	end
	
	local mapWidth = WorldMapDetailFrame:GetWidth();
	local mapHeight = WorldMapDetailFrame:GetHeight();

	local mapID, isContinent = GetCurrentMapAreaID();

	local fileName;

	local path;
	if (not isMicroDungeon) then
		path = "Interface\\WorldMap\\"..mapName.."\\";
		fileName = mapName;
	else
		path = "Interface\\WorldMap\\MicroDungeon\\"..mapName.."\\"..microDungeonMapName.."\\";
		fileName = microDungeonMapName;
	end
	
	if ( dungeonLevel > 0 ) then
		fileName = fileName..dungeonLevel.."_";
	end
	
	local numOfDetailTiles = GetNumberOfDetailTiles();
	for i=1, numOfDetailTiles do
		local texName = path..fileName..i;
		_G["WorldMapDetailTile"..i]:SetTexture(texName);
	end
	--WorldMapHighlight:Hide();

	WorldMap_UpdateLandmarks();
	WorldMap_DrawWorldEffects();
	WorldMapFrame.UIElementsFrame.BountyBoard:SetMapAreaID(mapID);
	WorldMapFrame.UIElementsFrame.ActionButton:SetMapAreaID(mapID);
	WorldMapFrame_UpdateOverlayLocations();
	WorldMap_UpdateQuestBonusObjectives();

	-- Setup the overlays
	local textureCount = 0;
	WorldMapOverlayHighlights = {};

	for i=1, GetNumMapOverlays() do
		local textureName, textureWidth, textureHeight, offsetX, offsetY, isShownByMouseOver = GetMapOverlayInfo(i);
		if ( textureName and textureName ~= "" ) then
			local numTexturesWide = ceil(textureWidth/256);
			local numTexturesTall = ceil(textureHeight/256);
			local neededTextures = textureCount + (numTexturesWide * numTexturesTall);
			if ( neededTextures > NUM_WORLDMAP_OVERLAYS ) then
				for j=NUM_WORLDMAP_OVERLAYS+1, neededTextures do
					WorldMapDetailFrame:CreateTexture("WorldMapOverlay"..j, "ARTWORK");
				end
				NUM_WORLDMAP_OVERLAYS = neededTextures;
			end
			local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight;
			for j=1, numTexturesTall do
				if ( j < numTexturesTall ) then
					texturePixelHeight = 256;
					textureFileHeight = 256;
				else
					texturePixelHeight = mod(textureHeight, 256);
					if ( texturePixelHeight == 0 ) then
						texturePixelHeight = 256;
					end
					textureFileHeight = 16;
					while(textureFileHeight < texturePixelHeight) do
						textureFileHeight = textureFileHeight * 2;
					end
				end
				for k=1, numTexturesWide do
					textureCount = textureCount + 1;
					local texture = _G["WorldMapOverlay"..textureCount];
					if ( k < numTexturesWide ) then
						texturePixelWidth = 256;
						textureFileWidth = 256;
					else
						texturePixelWidth = mod(textureWidth, 256);
						if ( texturePixelWidth == 0 ) then
							texturePixelWidth = 256;
						end
						textureFileWidth = 16;
						while(textureFileWidth < texturePixelWidth) do
							textureFileWidth = textureFileWidth * 2;
						end
					end
					texture:SetWidth(texturePixelWidth);
					texture:SetHeight(texturePixelHeight);
					texture:SetTexCoord(0, texturePixelWidth/textureFileWidth, 0, texturePixelHeight/textureFileHeight);
					texture:SetPoint("TOPLEFT", offsetX + (256 * (k-1)), -(offsetY + (256 * (j - 1))));
					texture:SetTexture(textureName..(((j - 1) * numTexturesWide) + k));

					if isShownByMouseOver == true then
						-- keep track of the textures to show by mouseover
						texture:Hide();
						if ( not WorldMapOverlayHighlights[i] ) then
							WorldMapOverlayHighlights[i] = { };
						end
						table.insert(WorldMapOverlayHighlights[i], texture);
					else
						texture:Show();
					end

				end
			end
		end
	end
	for i=textureCount+1, NUM_WORLDMAP_OVERLAYS do
		_G["WorldMapOverlay"..i]:Hide();
	end

	-- Show debug zone map if available
	local numDebugZoneMapTextures = 0;
	if ( HasDebugZoneMap() ) then
		local ZONEMAP_SIZE = 1024;
		for y=1, ZONEMAP_SIZE do
			for x=1, ZONEMAP_SIZE do
				local id, minX, minY, maxX, maxY, r, g, b, a = GetDebugZoneMap(x, y);
				if ( id ) then
					if ( not WorldMapDetailFrame.zoneMap ) then
						WorldMapDetailFrame.zoneMap = {};
					end

					numDebugZoneMapTextures = numDebugZoneMapTextures + 1;
					local texture = WorldMapDetailFrame.zoneMap[numDebugZoneMapTextures];
					if ( not texture ) then
						texture = WorldMapDetailFrame:CreateTexture(nil, "OVERLAY");
						texture:SetColorTexture(1, 1, 1);
						WorldMapDetailFrame.zoneMap[numDebugZoneMapTextures] = texture;
					end

					texture:SetVertexColor(r, g, b, a);
					minX = minX * mapWidth;
					minY = -minY * mapHeight;
					texture:SetPoint("TOPLEFT", "WorldMapDetailFrame", "TOPLEFT", minX, minY);
					maxX = maxX * mapWidth;
					maxY = -maxY * mapHeight;
					texture:SetPoint("BOTTOMRIGHT", "WorldMapDetailFrame", "TOPLEFT", maxX, maxY);
					texture:Show();
				end
			end
		end
	end
	for i=numDebugZoneMapTextures+1, NUM_WORLDMAP_DEBUG_ZONEMAP do
		WorldMapDetailFrame.zoneMap[i]:Hide();
	end
	NUM_WORLDMAP_DEBUG_ZONEMAP = numDebugZoneMapTextures;
	
	-- Setup any debug objects
	local baseLevel = WorldMapButton:GetFrameLevel() + 1;
	local numDebugObjects = GetNumMapDebugObjects();
	if ( NUM_WORLDMAP_DEBUG_OBJECTS < numDebugObjects ) then
		for i=NUM_WORLDMAP_DEBUG_OBJECTS+1, numDebugObjects do
			CreateFrame("Frame", "WorldMapDebugObject"..i, WorldMapButton, "WorldMapDebugObjectTemplate");
		end
		NUM_WORLDMAP_DEBUG_OBJECTS = numDebugObjects;
	end
	textureCount = 0;
	for i=1, numDebugObjects do
		local name, size, x, y = GetMapDebugObjectInfo(i);
		if ( (x ~= 0 or y ~= 0) and (size > 1 or GetCurrentMapZone() ~= WORLDMAP_AZEROTH_ID) ) then
			textureCount = textureCount + 1;
			local frame = _G["WorldMapDebugObject"..textureCount];
			frame.index = i;
			frame.name = name;

			local info = WORLDMAP_DEBUG_ICON_INFO[size];
			if ( GetCurrentMapZone() == WORLDMAP_AZEROTH_ID ) then
				frame:SetWidth(info.size / 2);
				frame:SetHeight(info.size / 2);
			else
				frame:SetWidth(info.size);
				frame:SetHeight(info.size);
			end
			frame.texture:SetVertexColor(info.r, info.g, info.b, 0.5);

			x = x * mapWidth;
			y = -y * mapHeight;
			frame:SetFrameLevel(baseLevel + (4 - size));
			frame:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", x, y);
			frame:Show();
		end
	end
	for i=textureCount+1, NUM_WORLDMAP_DEBUG_OBJECTS do
		_G["WorldMapDebugObject"..i]:Hide();
	end
	
	EncounterJournal_AddMapButtons();
	
	-- position storyline quests, but not on continent or "world" maps
	local numUsedStoryLineFrames = 0;
	if ( not isContinent and mapID > 0 ) then
		for i = 1, C_Questline.GetNumAvailableQuestlines() do
			local questLineName, questName, continentID, x, y, questlineMapID = C_Questline.GetQuestlineInfoByIndex(i);
			if ( questLineName and questlineMapID == mapID and x > 0 and y > 0 ) then
				numUsedStoryLineFrames = numUsedStoryLineFrames + 1;
				local frame = STORYLINE_FRAMES[numUsedStoryLineFrames];
				if ( not frame ) then
					frame = CreateFrame("FRAME", "WorldMapStoryLine"..numUsedStoryLineFrames, WorldMapPOIFrame, "WorldMapStoryLineTemplate");
					STORYLINE_FRAMES[numUsedStoryLineFrames] = frame;
				end
				frame.index = i;
				WorldMapPOIFrame_AnchorPOI(frame, x, y, WORLD_MAP_POI_FRAME_LEVEL_OFFSETS.STORY_LINE);
				frame:Show();
			end
		end
	end
	for i = numUsedStoryLineFrames + 1, #STORYLINE_FRAMES do
		STORYLINE_FRAMES[i]:Hide();
	end

	WorldMapFrame_UpdateInvasion();
end

function WorldMapFrame_SetOverlayLocation(frame, location)
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

function WorldMapFrame_UpdateOverlayLocations()
	local bountyBoard = WorldMapFrame.UIElementsFrame.BountyBoard;
	local bountyBoardLocation = bountyBoard:GetDisplayLocation();
	if bountyBoardLocation then
		WorldMapFrame_SetOverlayLocation(bountyBoard, bountyBoardLocation);
	end

	local actionButton = WorldMapFrame.UIElementsFrame.ActionButton;
	local useAlternateLocation = bountyBoardLocation == LE_MAP_OVERLAY_DISPLAY_LOCATION_BOTTOM_RIGHT;
	local actionButtonLocation = actionButton:GetDisplayLocation(useAlternateLocation);
	if actionButtonLocation then
		WorldMapFrame_SetOverlayLocation(actionButton, actionButtonLocation);
	end
end

function WorldMapFrame_OnInvasionLabelVisibilityChanged(visible)
	if visible then
		WorldMapFrameAreaLabelTexture:SetAtlas("legioninvasion-map-icon-portal-large");
		WorldMapFrameAreaLabelTexture:SetSize(77, 81);
		WorldMapFrameAreaLabelTexture:Show();
	else
		WorldMapFrameAreaLabelTexture:Hide();
	end
end

function WorldMapFrame_UpdateInvasion()
	local mapID, isContinent = GetCurrentMapAreaID();
	local name, timeLeftMinutes, rewardQuestID;
	if not isContinent then
		name, timeLeftMinutes, rewardQuestID = GetInvasionInfoByMapAreaID(mapID);
	end

	if name then
		WorldMapInvasionOverlay:Show();
		local descriptionLabel;
		if timeLeftMinutes and mapID ~= GetPlayerMapAreaID("player") then -- only show the timer if you're not in that zone
			local hoursLeft = math.floor(timeLeftMinutes / 60);
			local minutesLeft = timeLeftMinutes % 60;
			descriptionLabel = INVASION_TIME_FORMAT:format(hoursLeft, minutesLeft)
		end
		WorldMapFrame_SetAreaLabel(WORLDMAP_AREA_LABEL_TYPE.INVASION, MAP_UNDER_INVASION, descriptionLabel, INVASION_FONT_COLOR, INVASION_DESCRIPTION_FONT_COLOR, WorldMapFrame_OnInvasionLabelVisibilityChanged);
	else
		WorldMapInvasionOverlay:Hide();
		WorldMapFrame_ClearAreaLabel(WORLDMAP_AREA_LABEL_TYPE.INVASION);
	end
end

function WorldMapFrame_UpdateUnits(raidUnitPrefix, partyUnitPrefix)
	for i=1, MAX_RAID_MEMBERS do
		local partyMemberFrame = _G["WorldMapRaid"..i];
		if ( partyMemberFrame:IsShown() ) then
			WorldMapUnit_Update(partyMemberFrame);
		end
	end
	for i=1, MAX_PARTY_MEMBERS do
		local partyMemberFrame = _G["WorldMapParty"..i];
		if ( partyMemberFrame:IsShown() ) then
			WorldMapUnit_Update(partyMemberFrame);
		end
	end
end

WORLDMAP_AREA_LABEL_TYPE = {
	-- Where their value is the priority (lower numbers are trumped by larger)
	INVASION = 1,
	AREA_NAME = 2,
	POI = 3,
};

do
	local areaLabelInfoByType = {};
	local areaLabelsDirty = false;
	function WorldMapFrame_SetAreaLabel(areaLabelType, name, description, nameColor, descriptionColor, callback)
		if not areaLabelInfoByType[areaLabelType] then
			areaLabelInfoByType[areaLabelType] = {};
		end

		local areaLabelInfo = areaLabelInfoByType[areaLabelType];
		if areaLabelInfo.name ~= name or areaLabelInfo.description ~= description or not AreColorsEqual(areaLabelInfo.nameColor, nameColor) or not AreColorsEqual(areaLabelInfo.descriptionColor, descriptionColor) or areaLabelInfo.callback ~= callback then
			areaLabelInfo.name = name;
			areaLabelInfo.description = description;
			areaLabelInfo.nameColor = nameColor;
			areaLabelInfo.descriptionColor = descriptionColor;
			areaLabelInfo.callback = callback;
			
			areaLabelsDirty = true;
		end
	end

	function WorldMapFrame_ClearAreaLabel(areaLabelType)
		if areaLabelInfoByType[areaLabelType] then
			WorldMapFrame_SetAreaLabel(areaLabelType, nil);
		end
	end

	local pendingOnHideCallback;
	function WorldMapFrame_EvaluateAreaLabels()
		if not areaLabelsDirty then
			return;
		end
		areaLabelsDirty = false;

		local highestPriorityAreaLabelType;

		for areaLabelName, areaLabelType in pairs(WORLDMAP_AREA_LABEL_TYPE) do
			local areaLabelInfo = areaLabelInfoByType[areaLabelType];
			if areaLabelInfo and areaLabelInfo.name then
				if not highestPriorityAreaLabelType or areaLabelType > highestPriorityAreaLabelType then
					highestPriorityAreaLabelType = areaLabelType;
				end
			end
		end

		if pendingOnHideCallback then
			pendingOnHideCallback(false);
			pendingOnHideCallback = nil;
		end

		if highestPriorityAreaLabelType then
			local areaLabelInfo = areaLabelInfoByType[highestPriorityAreaLabelType];
			WorldMapFrameAreaLabel:SetText(areaLabelInfo.name);
			WorldMapFrameAreaDescription:SetText(areaLabelInfo.description);

			if areaLabelInfo.nameColor then
				WorldMapFrameAreaLabel:SetVertexColor(areaLabelInfo.nameColor:GetRGB());
			else
				WorldMapFrameAreaLabel:SetVertexColor(AREA_NAME_FONT_COLOR:GetRGB());
			end

			if areaLabelInfo.descriptionColor then
				WorldMapFrameAreaDescription:SetVertexColor(areaLabelInfo.descriptionColor:GetRGB());
			else
				WorldMapFrameAreaDescription:SetVertexColor(AREA_DESCRIPTION_FONT_COLOR:GetRGB());
			end

			if areaLabelInfo.callback then
				areaLabelInfo.callback(true);
				pendingOnHideCallback = areaLabelInfo.callback;
			end
		else
			WorldMapFrameAreaLabel:SetText("");
			WorldMapFrameAreaDescription:SetText("");
		end
	end
end

function WorldMap_DoesLandMarkTypeShowHighlights(landmarkType)
	return landmarkType == LE_MAP_LANDMARK_TYPE_NORMAL
		or landmarkType == LE_MAP_LANDMARK_TYPE_TAMER
		or landmarkType == LE_MAP_LANDMARK_TYPE_GOSSIP
		or landmarkType == LE_MAP_LANDMARK_TYPE_TAXINODE
		or landmarkType == LE_MAP_LANDMARK_TYPE_VIGNETTE
		or landmarkType == LE_MAP_LANDMARK_TYPE_INVASION;
end

function WorldMapPOI_OnEnter(self)
	WorldMapFrame.poiHighlight = true;
	if ( self.specialPOIInfo and self.specialPOIInfo.onEnter ) then
		self.specialPOIInfo.onEnter(self, self.specialPOIInfo);
	else
		self.HighlightTexture:SetShown(WorldMap_DoesLandMarkTypeShowHighlights(self.landmarkType));
		if ( self.description and #self.description > 0 ) then
			WorldMapFrame_SetAreaLabel(WORLDMAP_AREA_LABEL_TYPE.POI, self.name, self.description);
		else
			WorldMapFrame_SetAreaLabel(WORLDMAP_AREA_LABEL_TYPE.POI, self.name);

			-- need localization
			if ( self.graveyard ) then
				WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");
				if ( self.graveyard == GetCemeteryPreference() ) then
					WorldMapTooltip:SetText(GRAVEYARD_SELECTED);
					WorldMapTooltip:AddLine(GRAVEYARD_SELECTED_TOOLTIP, 1, 1, 1, true);
					WorldMapTooltip:Show();
				else
					WorldMapTooltip:SetText(GRAVEYARD_ELIGIBLE);
					WorldMapTooltip:AddLine(GRAVEYARD_ELIGIBLE_TOOLTIP, 1, 1, 1, true);
					WorldMapTooltip:Show();
				end
			end
		end

		if self.landmarkType == LE_MAP_LANDMARK_TYPE_INVASION then
			local name, timeLeftMinutes, rewardQuestID = GetInvasionInfo(self.poiID);

			WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");
			WorldMapTooltip:SetText(name, HIGHLIGHT_FONT_COLOR:GetRGB());

			if timeLeftMinutes then
				local color = NORMAL_FONT_COLOR;
				local displayTimeMinutes = timeLeftMinutes - WORLD_QUESTS_TIME_CRITICAL_MINUTES;
				if ( displayTimeMinutes <= 0 ) then
					-- Grace period, show the actual time left
					displayTimeMinutes = timeLeftMinutes;
					color = RED_FONT_COLOR;
				end

				local timeString = SecondsToTime(displayTimeMinutes * 60);
				WorldMapTooltip:AddLine(BONUS_OBJECTIVE_TIME_LEFT:format(timeString), color:GetRGB());
			end

			if rewardQuestID then
				if not HaveQuestData(rewardQuestID) then
					WorldMapTooltip:AddLine(RETRIEVING_DATA, RED_FONT_COLOR:GetRGB());
				else
					WorldMap_AddQuestRewardsToTooltip(rewardQuestID);
				end
			end

			WorldMapTooltip:Show();
		end
	end
end

function WorldMapPOI_OnLeave(self)
	WorldMapFrame.poiHighlight = nil;
	if ( self.specialPOIInfo and self.specialPOIInfo.onLeave ) then
		self.specialPOIInfo.onLeave(self, self.specialPOIInfo);
	else
		WorldMapFrame_ClearAreaLabel(WORLDMAP_AREA_LABEL_TYPE.POI);
		WorldMapTooltip:Hide();
	end

	self.HighlightTexture:Hide();
end

function WorldMap_ThunderIslePOI_OnEnter(self, poiInfo)
	WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");
	local tag = "THUNDER_ISLE";
	local phase = poiInfo.phase;

	local title = MapBarFrame_GetString("TITLE", tag, phase);
	if ( poiInfo.active ) then
		local tooltipText = MapBarFrame_GetString("TOOLTIP", tag, phase);
		local percentage = math.floor(100 * C_MapBar.GetCurrentValue() / C_MapBar.GetMaxValue());
		WorldMapTooltip:SetText(format(MAP_BAR_TOOLTIP_TITLE, title, percentage), 1, 1, 1);
		WorldMapTooltip:AddLine(tooltipText, nil, nil, nil, true);
		WorldMapTooltip:Show();
	else
		local disabledText = MapBarFrame_GetString("LOCKED", tag, phase);
		WorldMapTooltip:SetText(title, 1, 1, 1);
		WorldMapTooltip:AddLine(disabledText, nil, nil, nil, true);
		WorldMapTooltip:Show();
	end
end

function WorldMap_ThunderIslePOI_OnLeave(self, poiInfo)
	WorldMapTooltip:Hide();
end

function WorldMap_HandleThunderIslePOI(poiFrame, poiInfo)
	poiFrame:SetSize(64, 64);
	poiFrame.Texture:SetSize(64, 64);
	
	poiFrame.Texture:SetTexCoord(0, 1, 0, 1);
	if ( poiInfo.active ) then
		poiFrame.Texture:SetTexture("Interface\\WorldMap\\MapProgress\\mappoi-mogu-on");
	else
		poiFrame.Texture:SetTexture("Interface\\WorldMap\\MapProgress\\mappoi-mogu-off");
	end
end

SPECIAL_POI_INFO = {
	[2943] = { phase = 0, active = true },
	[2944] = { phase = 0, active = true },
	[2925] = { phase = 1, active = true },
	[2927] = { phase = 1, active = false },
	[2945] = { phase = 1, active = true },
	[2949] = { phase = 1, active = false },
	[2937] = { phase = 2, active = true },
	[2938] = { phase = 2, active = false },
	[2946] = { phase = 2, active = true },
	[2950] = { phase = 2, active = false },
	[2939] = { phase = 3, active = true },
	[2940] = { phase = 3, active = false },
	[2947] = { phase = 3, active = true },
	[2951] = { phase = 3, active = false },
	[2941] = { phase = 4, active = true },
	[2942] = { phase = 4, active = false },
	[2948] = { phase = 4, active = true },
	[2952] = { phase = 4, active = false },
	--If you add another special POI, make sure to change the setup below
};

for k, v in pairs(SPECIAL_POI_INFO) do
	v.handleFunc = WorldMap_HandleThunderIslePOI;
	v.onEnter = WorldMap_ThunderIslePOI_OnEnter;
	v.onLeave = WorldMap_ThunderIslePOI_OnLeave;
end

function WorldMap_IsSpecialPOI(poiID)
	if ( SPECIAL_POI_INFO[poiID] ) then
		return true;
	else
		return false;
	end
end

function WorldMap_HandleSpecialPOI(poiFrame, poiID)
	local poiInfo = SPECIAL_POI_INFO[poiID];
	poiFrame.specialPOIInfo = poiInfo;
	if ( poiInfo and poiInfo.handleFunc ) then
		poiInfo.handleFunc(poiFrame, poiInfo)
		poiFrame:Show();
	else
		poiFrame:Hide();
	end
end

function WorldEffectPOI_OnEnter(self)
	if(WorldEffectPOITooltips[self.name] ~= nil) then
		WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");
		WorldMapTooltip:SetText(WorldEffectPOITooltips[self.name]);
		WorldMapTooltip:Show();
	end
end

function WorldEffectPOI_OnLeave()
	WorldMapTooltip:Hide();
end

local g_supressedWorldQuestTimeStamps = {};
function WorldMap_AddWorldQuestSuppression(questID)
	g_supressedWorldQuestTimeStamps[questID] = GetTime();
	WorldMapFrame_SetBonusObjectivesDirty();
end

local WORLD_QUEST_SUPPRESSION_TIME_SECS = 60.0;
function WorldMap_IsWorldQuestSuppressed(questID)
	local lastSuppressedTime = g_supressedWorldQuestTimeStamps[questID];
	if lastSuppressedTime then
		if GetTime() - lastSuppressedTime < WORLD_QUEST_SUPPRESSION_TIME_SECS then
			return true;
		end
		g_supressedWorldQuestTimeStamps[questID] = nil;
	end
	return false;
end

function WorldMap_OnWorldQuestCompletedBySpell(questID)
	local mapAreaID = GetCurrentMapAreaID();
	local x, y = C_TaskQuest.GetQuestLocation(questID, mapAreaID);
	if x and y then
		WorldMap_AddWorldQuestSuppression(questID);
		local spellID, spellVisualKitID = GetWorldMapActionButtonSpellInfo();
		if spellVisualKitID then
			WorldMapPOIFrame_AnchorPOI(WorldMapPOIFrame.WorldQuestCompletedBySpellModel, x, y, 5000);
			WorldMapPOIFrame.WorldQuestCompletedBySpellModel:SetCameraTarget(0, 0, 0);
			WorldMapPOIFrame.WorldQuestCompletedBySpellModel:SetCameraPosition(0, 0, 25);
			WorldMapPOIFrame.WorldQuestCompletedBySpellModel:SetSpellVisualKit(spellVisualKitID);
		end
	end
end

function WorldMap_AddQuestTimeToTooltip(questID)
	local timeLeftMinutes = C_TaskQuest.GetQuestTimeLeftMinutes(questID);
	if ( timeLeftMinutes ) then
		local color = NORMAL_FONT_COLOR;
		local timeString;
		if ( timeLeftMinutes <= WORLD_QUESTS_TIME_CRITICAL_MINUTES ) then
			-- Grace period, show the actual time left
			color = RED_FONT_COLOR;
			timeString = SecondsToTime(timeLeftMinutes * 60);
		elseif timeLeftMinutes <= 60 + WORLD_QUESTS_TIME_CRITICAL_MINUTES then
			timeString = SecondsToTime((timeLeftMinutes - WORLD_QUESTS_TIME_CRITICAL_MINUTES) * 60);
		elseif timeLeftMinutes < 24 * 60 + WORLD_QUESTS_TIME_CRITICAL_MINUTES then
			timeString = D_HOURS:format(math.floor(timeLeftMinutes - WORLD_QUESTS_TIME_CRITICAL_MINUTES) / 60);
		else
			timeString = D_DAYS:format(math.floor(timeLeftMinutes - WORLD_QUESTS_TIME_CRITICAL_MINUTES) / 1440);
		end

		WorldMapTooltip:AddLine(BONUS_OBJECTIVE_TIME_LEFT:format(timeString), color.r, color.g, color.b);
	end
end

function WorldMap_AddQuestRewardsToTooltip(questID)
	if ( GetQuestLogRewardXP(questID) > 0 or GetNumQuestLogRewardCurrencies(questID) > 0 or GetNumQuestLogRewards(questID) > 0 or GetQuestLogRewardMoney(questID) > 0 or GetQuestLogRewardArtifactXP(questID) > 0 ) then
		WorldMapTooltip:AddLine(" ");
		WorldMapTooltip:AddLine(QUEST_REWARDS, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		local hasAnySingleLineRewards = false;
		-- xp
		local xp = GetQuestLogRewardXP(questID);
		if ( xp > 0 ) then
			WorldMapTooltip:AddLine(BONUS_OBJECTIVE_EXPERIENCE_FORMAT:format(xp), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			hasAnySingleLineRewards = true;
		end
		-- money
		local money = GetQuestLogRewardMoney(questID);
		if ( money > 0 ) then
			SetTooltipMoney(WorldMapTooltip, money, nil);
			hasAnySingleLineRewards = true;
		end	
		local artifactXP = GetQuestLogRewardArtifactXP(questID);
		if ( artifactXP > 0 ) then
			WorldMapTooltip:AddLine(BONUS_OBJECTIVE_ARTIFACT_XP_FORMAT:format(artifactXP), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			hasAnySingleLineRewards = true;
		end
		-- currency		
		local numQuestCurrencies = GetNumQuestLogRewardCurrencies(questID);
		for i = 1, numQuestCurrencies do
			local name, texture, numItems = GetQuestLogRewardCurrencyInfo(i, questID);
			local text = BONUS_OBJECTIVE_REWARD_WITH_COUNT_FORMAT:format(texture, numItems, name);
			WorldMapTooltip:AddLine(text, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			hasAnySingleLineRewards = true;
		end

		-- items
		local numQuestRewards = GetNumQuestLogRewards(questID);
		if numQuestRewards > 0 then
			if ( hasAnySingleLineRewards ) then
				WorldMapTooltip:AddLine(" ");
			end

			if not EmbeddedItemTooltip_SetItemByQuestReward(WorldMapTooltip.ItemTooltip, 1, questID) then  -- Only support one currently
				WorldMapTooltip:AddLine(RETRIEVING_DATA, RED_FONT_COLOR:GetRGB());
			end
		end
	end
end

function TaskPOI_OnEnter(self)
	WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");

	if ( not HaveQuestData(self.questID) ) then
		WorldMapTooltip:SetText(RETRIEVING_DATA, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
		WorldMapTooltip:Show();
		return;
	end

	local title, factionID = C_TaskQuest.GetQuestInfoByQuestID(self.questID);

	if ( self.worldQuest ) then
		local tagID, tagName, worldQuestType, rarity, isElite, tradeskillLineIndex = GetQuestTagInfo(self.questID);
		local color = WORLD_QUEST_QUALITY_COLORS[rarity];
		WorldMapTooltip:SetText(title, color.r, color.g, color.b);

		if ( factionID ) then
			local factionName = GetFactionInfoByID(factionID);
			if ( factionName ) then
				WorldMapTooltip:AddLine(factionName);
			end
		end

		WorldMap_AddQuestTimeToTooltip(self.questID);
	else
		WorldMapTooltip:SetText(title);
	end

	for objectiveIndex = 1, self.numObjectives do
		local objectiveText, objectiveType, finished = GetQuestObjectiveInfo(self.questID, objectiveIndex, false);
		if ( objectiveText and #objectiveText > 0 ) then
			local color = finished and GRAY_FONT_COLOR or HIGHLIGHT_FONT_COLOR;
			WorldMapTooltip:AddLine(QUEST_DASH .. objectiveText, color.r, color.g, color.b, true);
		end
	end

	local percent = C_TaskQuest.GetQuestProgressBarInfo(self.questID);
	if ( percent ) then
		GameTooltip_InsertFrame(WorldMapTooltip, WorldMapTaskTooltipStatusBar);
		WorldMapTaskTooltipStatusBar.Bar:SetValue(percent);
		WorldMapTaskTooltipStatusBar.Bar.Label:SetFormattedText(PERCENTAGE_STRING, percent);
	end

	WorldMap_AddQuestRewardsToTooltip(self.questID);

	if ( self.worldQuest and WorldMapTooltip.AddDebugWorldQuestInfo ) then
		WorldMapTooltip:AddDebugWorldQuestInfo(self.questID);
	end

	WorldMapTooltip:Show();
end

function TaskPOI_OnLeave(self)
	WorldMapTooltip:Hide();
end

function TaskPOI_OnClick(self, button)
	if self.worldQuest then
		if SpellCanTargetQuest() then
			if IsQuestIDValidSpellTarget(self.questID) then
				UseWorldMapActionButtonSpellOnQuest(self.questID);
				-- Assume success for responsiveness
				WorldMap_OnWorldQuestCompletedBySpell(self.questID);
			else
				UIErrorsFrame:AddMessage(WORLD_QUEST_CANT_COMPLETE_BY_SPELL, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b);
			end
		else
			PlaySound("igMainMenuOptionCheckBoxOn");
			if IsShiftKeyDown() then
				if IsWorldQuestHardWatched(self.questID) or (IsWorldQuestWatched(self.questID) and GetSuperTrackedQuestID() == self.questID) then
					BonusObjectiveTracker_UntrackWorldQuest(self.questID);
				else
					BonusObjectiveTracker_TrackWorldQuest(self.questID, true);
				end
			else
				if IsWorldQuestHardWatched(self.questID) then
					SetSuperTrackedQuestID(self.questID);
				else
					BonusObjectiveTracker_TrackWorldQuest(self.questID);
				end
			end
		end
	end
end

function WorldMapTooltip_OnSizeChanged(tooltip)
	if tooltip.ItemTooltip:IsShown() then
		WorldMapTooltip.BackdropFrame:SetPoint("BOTTOM", WorldMapTooltip.ItemTooltip, 0, -13);
		
		if WorldMapTooltip:GetWidth() > WorldMapTooltip.ItemTooltip:GetWidth() + 6 then
			WorldMapTooltip.BackdropFrame:SetPoint("RIGHT", WorldMapTooltip);
		else
			WorldMapTooltip.BackdropFrame:SetPoint("RIGHT", WorldMapTooltip.ItemTooltip);
		end
	else
		WorldMapTooltip.BackdropFrame:SetPoint("BOTTOM", WorldMapTooltip);
		WorldMapTooltip.BackdropFrame:SetPoint("RIGHT", WorldMapTooltip);
	end
end

function ScenarioPOI_OnEnter(self)
	if(ScenarioPOITooltips[self.name] ~= nil) then
		WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");
		WorldMapTooltip:SetText(ScenarioPOITooltips[self.name]);
		WorldMapTooltip:Show();
	end
end

function ScenarioPOI_OnLeave()
	WorldMapTooltip:Hide();
end

function WorldMapPOI_OnClick(self, button)
	if ( self.mapLinkID ) then
		if self.landmarkType == LE_MAP_LANDMARK_TYPE_DUNGEON_ENTRANCE then
			if not EncounterJournal or not EncounterJournal:IsShown() then
				ToggleEncounterJournal();
			end
			EncounterJournal_ListInstances();
			EncounterJournal_DisplayInstance(self.mapLinkID);
		else
			ClickLandmark(self.mapLinkID);
		end
	elseif ( self.graveyard ) then
		SetCemeteryPreference(self.graveyard);
		WorldMapFrame_Update();
	else
		WorldMapButton_OnClick(WorldMapButton, button);
	end
end

function WorldMap_CreatePOI(index, isObjectIcon, atlasIcon)
	local button = CreateFrame("Button", "WorldMapFramePOI"..index, WorldMapPOIFrame);
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	button:SetScript("OnEnter", WorldMapPOI_OnEnter);
	button:SetScript("OnLeave", WorldMapPOI_OnLeave);
	button:SetScript("OnClick", WorldMapPOI_OnClick);

	button.UpdateTooltip = WorldMapPOI_OnEnter;

	button.Texture = button:CreateTexture(button:GetName().."Texture", "BACKGROUND");
	button.HighlightTexture = button:CreateTexture(button:GetName().."HighlightTexture", "HIGHLIGHT");
	button.HighlightTexture:SetBlendMode("ADD");
	button.HighlightTexture:SetAlpha(.4);
	button.HighlightTexture:SetAllPoints(button.Texture);
	
	WorldMap_ResetPOI(button, isObjectIcon, atlasIcon);
end

function WorldMap_ResetPOI(button, isObjectIcon, atlasIcon)
	if (atlasIcon) then
		button.Texture:SetAtlas(atlasIcon, true);
		if button.HighlightTexture then
			button.HighlightTexture:SetAtlas(atlasIcon, true);
		end
		button:SetSize(button.Texture:GetSize());
		button.Texture:SetPoint("CENTER", 0, 0);
	elseif (isObjectIcon == true) then
		button:SetWidth(32);
		button:SetHeight(32);
		button.Texture:SetWidth(28);
		button.Texture:SetHeight(28);
		button.Texture:SetPoint("CENTER", 0, 0);
		button.Texture:SetTexture("Interface\\Minimap\\ObjectIconsAtlas");
		if button.HighlightTexture then
			button.HighlightTexture:SetTexture("Interface\\Minimap\\ObjectIconsAtlas");
		end
	else
		button:SetWidth(32);
		button:SetHeight(32);
		button.Texture:SetWidth(16);
		button.Texture:SetHeight(16);
		button.Texture:SetPoint("CENTER", 0, 0);
		button.Texture:SetTexture("Interface\\Minimap\\POIIcons");
		if button.HighlightTexture then
			button.HighlightTexture:SetTexture("Interface\\Minimap\\POIIcons");
		end
	end

	button.specialPOIInfo = nil;
end

function WorldMap_CreateWorldEffectPOI(index)
	local button = CreateFrame("Button", "WorldMapFrameWorldEffectPOI"..index, WorldMapPOIFrame);
	button:SetWidth(32);
	button:SetHeight(32);
	button:SetScript("OnEnter", WorldEffectPOI_OnEnter);
	button:SetScript("OnLeave", WorldEffectPOI_OnLeave);
	
	local texture = button:CreateTexture(button:GetName().."Texture", "BACKGROUND");
	texture:SetWidth(16);
	texture:SetHeight(16);
	texture:SetPoint("CENTER", 0, 0);
	texture:SetTexture("Interface\\Minimap\\ObjectIconsAtlas");
end

function WorldMap_GetOrCreateTaskPOI(index)
	local existingButton = _G["WorldMapFrameTaskPOI"..index];
	if existingButton then
		return existingButton;
	end

	local button = CreateFrame("Button", "WorldMapFrameTaskPOI"..index, WorldMapPOIFrame);
	button:SetFlattensRenderLayers(true);
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	button:SetScript("OnEnter", TaskPOI_OnEnter);
	button:SetScript("OnLeave", TaskPOI_OnLeave);
	button:SetScript("OnClick", TaskPOI_OnClick);

	button.UpdateTooltip = TaskPOI_OnEnter;
	
	button.Texture = button:CreateTexture(button:GetName().."Texture", "BACKGROUND");

	button.Glow = button:CreateTexture(button:GetName().."Glow", "BACKGROUND", -2);
	button.Glow:SetSize(50, 50);
	button.Glow:SetPoint("CENTER");
	button.Glow:SetTexture("Interface/WorldMap/UI-QuestPoi-IconGlow.tga");
	button.Glow:SetBlendMode("ADD");

	button.SelectedGlow = button:CreateTexture(button:GetName().."SelectedGlow", "OVERLAY", 2);
	button.SelectedGlow:SetBlendMode("ADD");

	button.CriteriaMatchGlow = button:CreateTexture(button:GetName().."CriteriaMatchGlow", "BACKGROUND", -1);
	button.CriteriaMatchGlow:SetAlpha(.6);
	button.CriteriaMatchGlow:SetBlendMode("ADD");
	
	button.SpellTargetGlow = button:CreateTexture(button:GetName().."SpellTargetGlow", "OVERLAY", 1);
	button.SpellTargetGlow:SetAtlas("worldquest-questmarker-abilityhighlight", true);
	button.SpellTargetGlow:SetAlpha(.6);
	button.SpellTargetGlow:SetBlendMode("ADD");
	button.SpellTargetGlow:SetPoint("CENTER", 0, 0);

	button.Underlay = button:CreateTexture(button:GetName().."Underlay", "BACKGROUND");
	button.Underlay:SetWidth(34);
	button.Underlay:SetHeight(34);
	button.Underlay:SetPoint("CENTER", 0, -1);

	button.TimeLowFrame = CreateFrame("Frame", nil, button);
	button.TimeLowFrame:SetSize(22, 22);
	button.TimeLowFrame:SetPoint("CENTER", -10, -10);
	button.TimeLowFrame.Texture = button.TimeLowFrame:CreateTexture(nil, "OVERLAY");
	button.TimeLowFrame.Texture:SetAllPoints(button.TimeLowFrame);
	button.TimeLowFrame.Texture:SetAtlas("worldquest-icon-clock");

	WorldMap_ResetPOI(button, true, false);

	return button;
end

function WorldMap_CreateScenarioPOI(index)
	local button = CreateFrame("Button", "WorldMapFrameScenarioPOI"..index, WorldMapPOIFrame);
	button:SetWidth(32);
	button:SetHeight(32);
	button:SetScript("OnEnter", ScenarioPOI_OnEnter);
	button:SetScript("OnLeave", ScenarioPOI_OnLeave);
	
	local texture = button:CreateTexture(button:GetName().."Texture", "BACKGROUND");
	texture:SetWidth(16);
	texture:SetHeight(16);
	texture:SetPoint("CENTER", 0, 0);
	texture:SetTexture("Interface\\Minimap\\ObjectIconsAtlas");
end

function WorldMap_GetGraveyardButton(index)
	local frameName = "WorldMapFrameGraveyard"..index;
	local button = _G[frameName];
	if ( not button ) then
		button = CreateFrame("Button", frameName, WorldMapPOIFrame);
		button:SetWidth(32);
		button:SetHeight(32);
		button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
		button:SetScript("OnEnter", nil);
		button:SetScript("OnLeave", nil);
		button:SetScript("OnClick", nil);
		
		local texture = button:CreateTexture(button:GetName().."Texture", "ARTWORK");
		texture:SetWidth(48);
		texture:SetHeight(48);
		texture:SetPoint("CENTER", 0, 0);
		button.texture = texture;
	end
	return button;
end

function WorldMapLevelDropDown_Update()
	UIDropDownMenu_Initialize(WorldMapLevelDropDown, WorldMapLevelDropDown_Initialize);
	UIDropDownMenu_SetWidth(WorldMapLevelDropDown, 130);

	local dungeonLevels = { GetNumDungeonMapLevels() };
	if ( #dungeonLevels == 0 ) then
		UIDropDownMenu_ClearAll(WorldMapLevelDropDown);
		WorldMapLevelDropDown:Hide();
	else
		local level = GetCurrentMapDungeonLevel();
		if (DungeonUsesTerrainMap()) then
			level = level - 1;
		end

		-- find the current floor in the list of levels, that's its ID in the dropdown
		local levelID = 1;
		for id, floorNum in ipairs(dungeonLevels) do
			if (floorNum == level) then
				levelID = id;
			end
		end

		UIDropDownMenu_SetSelectedID(WorldMapLevelDropDown, levelID);
		WorldMapLevelDropDown:Show();
		if ( WORLDMAP_SETTINGS.size ~= WORLDMAP_WINDOWED_SIZE ) then
		end
	end
end

function WorldMapLevelDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	local level = GetCurrentMapDungeonLevel();
	if (DungeonUsesTerrainMap()) then
		level = level - 1;
	end
		
	local mapname = strupper(GetMapInfo() or "");
	local dungeonLevels = { GetNumDungeonMapLevels() };
		
	for i, floorNum in ipairs(dungeonLevels) do
		local floornameToken = "DUNGEON_FLOOR_" .. mapname .. floorNum;
		local floorname =_G[floornameToken];
		info.text = floorname or string.format(FLOOR_NUMBER, i);
		info.func = WorldMapLevelButton_OnClick;
		info.checked = (floorNum == level);
		UIDropDownMenu_AddButton(info);
	end
end

function WorldMapLevelButton_OnClick(self)
	local dropDownID = self:GetID();
	UIDropDownMenu_SetSelectedID(WorldMapLevelDropDown, dropDownID);

	local dungeonLevels = { GetNumDungeonMapLevels() };
	if (dropDownID <= #dungeonLevels) then
		local level = dungeonLevels[dropDownID];
		if (DungeonUsesTerrainMap()) then
			level = level + 1;
		end
		SetDungeonMapLevel(level);
		WorldMapScrollFrame_ResetZoom()
	end
end

function WorldMapZoomOutButton_OnClick()
	PlaySound("igMainMenuOptionCheckBoxOn");
	WorldMapTooltip:Hide();
	
	-- check if code needs to zoom out before going to the continent map
	if ( ZoomOut() ~= nil ) then
		return;
	elseif ( GetCurrentMapContinent() == WORLDMAP_AZEROTH_ID ) then
		SetMapZoom(WORLDMAP_COSMIC_ID);
	elseif ( GetCurrentMapContinent() == WORLDMAP_OUTLAND_ID or GetCurrentMapContinent() == WORLDMAP_DRAENOR_ID ) then
		SetMapZoom(WORLDMAP_COSMIC_ID);
	else
		SetMapZoom(WORLDMAP_AZEROTH_ID);
	end
end

function WorldMapButton_OnClick(button, mouseButton)
	if ( WorldMapButton.ignoreClick ) then
		WorldMapButton.ignoreClick = false;
		return;
	end
	CloseDropDownMenus();
	if ( mouseButton == "LeftButton" ) then
		local x, y = GetCursorPosition();
		x = x / button:GetEffectiveScale();
		y = y / button:GetEffectiveScale();

		local centerX, centerY = button:GetCenter();
		local width = button:GetWidth();
		local height = button:GetHeight();
		local adjustedY = (centerY + (height/2) - y) / height;
		local adjustedX = (x - (centerX - (width/2))) / width;
		ProcessMapClick( adjustedX, adjustedY);
	elseif ( mouseButton == "RightButton" ) then
		WorldMapZoomOutButton_OnClick();
	elseif ( GetBindingFromClick(mouseButton) ==  "TOGGLEWORLDMAP" ) then
		ToggleWorldMap();
	end
end

function WorldMapFakeButton_OnClick(button, mouseButton)
	if ( WorldMapButton.ignoreClick ) then
		WorldMapButton.ignoreClick = false;
		return;
	end
	if ( mouseButton == "LeftButton" ) then
		if ( button.zoneID ) then
			SetMapByID(button.zoneID);
		elseif ( button.continent ) then
			SetMapZoom(button.continent);
		end
	else
		WorldMapZoomOutButton_OnClick();
	end
end

local BLIP_TEX_COORDS = {
	["WARRIOR"]		 = { 0, 0.125, 0, 0.25 },
	["PALADIN"]		 = { 0.125, 0.25, 0, 0.25 },
	["HUNTER"]		 = { 0.25, 0.375, 0, 0.25 },
	["ROGUE"]		 = { 0.375, 0.5, 0, 0.25 },
	["PRIEST"]		 = { 0.5, 0.625, 0, 0.25 },
	["DEATHKNIGHT"]	 = { 0.625, 0.75, 0, 0.25 },
	["SHAMAN"]		 = { 0.75, 0.875, 0, 0.25 },
	["MAGE"]		 = { 0.875, 1, 0, 0.25 },
	["WARLOCK"]		 = { 0, 0.125, 0.25, 0.5 },
	["DRUID"]		 = { 0.25, 0.375, 0.25, 0.5 },
	["MONK"]		 = { 0.125, 0.25, 0.25, 0.5 },
	["DEMONHUNTER"]	 = { 0.375, 0.5, 0.25, 0.5 },
}

local BLIP_RAID_Y_OFFSET = 0.5;

function WorldMapButton_OnUpdate(self, elapsed)
	local x, y = GetCursorPosition();
	if ( WorldMapScrollFrame.panning ) then
		WorldMapScrollFrame_OnPan(x, y);
	end
	x = x / self:GetEffectiveScale();
	y = y / self:GetEffectiveScale();

	local centerX, centerY = self:GetCenter();
	local width = self:GetWidth();
	local height = self:GetHeight();
	local adjustedY = (centerY + (height/2) - y ) / height;
	local adjustedX = (x - (centerX - (width/2))) / width;
	
	local name, fileName, texPercentageX, texPercentageY, textureX, textureY, scrollChildX, scrollChildY, minLevel, maxLevel, petMinLevel, petMaxLevel
	if ( self:IsMouseOver() ) then
		name, fileName, texPercentageX, texPercentageY, textureX, textureY, scrollChildX, scrollChildY, minLevel, maxLevel, petMinLevel, petMaxLevel = UpdateMapHighlight( adjustedX, adjustedY );

		for index,textures in pairs(WorldMapOverlayHighlights) do
			local isHighlighted = IsMapOverlayHighlighted(index, adjustedX, adjustedY);
			for _,texture in pairs(textures) do
				if (isHighlighted == true) then
					texture:Show();
				else
					texture:Hide();
				end
			end
		end
	end
	
	WorldMapFrameAreaPetLevels:SetText(""); --make sure pet level is cleared
	
	local effectiveAreaName = name;
	WorldMapFrame_ClearAreaLabel(WORLDMAP_AREA_LABEL_TYPE.AREA_NAME);

	if ( not WorldMapFrame.poiHighlight ) then
		WorldMapFrame_UpdateInvasion();

		if ( WorldMapFrame.maelstromZoneText ) then
			effectiveName = WorldMapFrame.maelstromZoneText;

			minLevel = WorldMapFrame.minLevel;
			name = WorldMapFrame.maelstromZone
			maxLevel = WorldMapFrame.maxLevel;
			petMinLevel = WorldMapFrame.petMinLevel;
			petMaxLevel = WorldMapFrame.petMaxLevel;
		end
		if (name and minLevel and maxLevel and minLevel > 0 and maxLevel > 0) then
			local playerLevel = UnitLevel("player");
			local color;
			if (playerLevel < minLevel) then
				color = GetQuestDifficultyColor(minLevel);
			elseif (playerLevel > maxLevel) then
				--subtract 2 from the maxLevel so zones entirely below the player's level won't be yellow
				color = GetQuestDifficultyColor(maxLevel - 2); 
			else
				color = QuestDifficultyColors["difficult"];
			end
			color = ConvertRGBtoColorString(color);
			if (minLevel ~= maxLevel) then
				effectiveAreaName = effectiveAreaName..color.." ("..minLevel.."-"..maxLevel..")"..FONT_COLOR_CODE_CLOSE;
			else
				effectiveAreaName = effectiveAreaName..color.." ("..maxLevel..")"..FONT_COLOR_CODE_CLOSE;
			end
		end

		WorldMapFrame_SetAreaLabel(WORLDMAP_AREA_LABEL_TYPE.AREA_NAME, effectiveAreaName);

		local _, _, _, _, locked = C_PetJournal.GetPetLoadOutInfo(1);
		if (not locked and GetCVarBool("showTamers")) then --don't show pet levels for people who haven't unlocked battle petting
			if (petMinLevel and petMaxLevel and petMinLevel > 0 and petMaxLevel > 0) then 
				local teamLevel = C_PetJournal.GetPetTeamAverageLevel();
				local color
				if (teamLevel) then
					if (teamLevel < petMinLevel) then
						--add 2 to the min level because it's really hard to fight higher level pets
						color = GetRelativeDifficultyColor(teamLevel, petMinLevel + 2);
					elseif (teamLevel > petMaxLevel) then
						color = GetRelativeDifficultyColor(teamLevel, petMaxLevel); 
					else
						--if your team is in the level range, no need to call the function, just make it yellow
						color = QuestDifficultyColors["difficult"];
					end
				else
					--If you unlocked pet battles but have no team, level ranges are meaningless so make them grey
					color = QuestDifficultyColors["header"];
				end
				color = ConvertRGBtoColorString(color);
				if (petMinLevel ~= petMaxLevel) then
					WorldMapFrameAreaPetLevels:SetText(WORLD_MAP_WILDBATTLEPET_LEVEL..color.."("..petMinLevel.."-"..petMaxLevel..")"..FONT_COLOR_CODE_CLOSE);
				else
					WorldMapFrameAreaPetLevels:SetText(WORLD_MAP_WILDBATTLEPET_LEVEL..color.."("..petMaxLevel..")"..FONT_COLOR_CODE_CLOSE);
				end
			end
		end
	end
	if ( fileName ) then
		WorldMapHighlight:SetTexCoord(0, texPercentageX, 0, texPercentageY);
		WorldMapHighlight:SetTexture("Interface\\WorldMap\\"..fileName.."\\"..fileName.."Highlight");
		textureX = textureX * width;
		textureY = textureY * height;
		scrollChildX = scrollChildX * width;
		scrollChildY = -scrollChildY * height;
		if ( (textureX > 0) and (textureY > 0) ) then
			WorldMapHighlight:SetWidth(textureX);
			WorldMapHighlight:SetHeight(textureY);
			WorldMapHighlight:SetPoint("TOPLEFT", "WorldMapDetailFrame", "TOPLEFT", scrollChildX, scrollChildY);
			WorldMapHighlight:Show();
			--WorldMapFrameAreaLabel:SetPoint("TOP", "WorldMapHighlight", "TOP", 0, 0);
		end
		
	else
		WorldMapHighlight:Hide();
	end
	
	local playersFrameWidth = WorldMapPlayersFrame:GetWidth();
	local playersFrameHeight = WorldMapPlayersFrame:GetHeight();

	--Position player
	local playerX, playerY = GetPlayerMapPosition("player");
	if ( (playerX == 0 and playerY == 0) ) then
		WorldMapPlayerLower:Hide();
		WorldMapPlayerUpper:Hide();
	else
		playerX = playerX * playersFrameWidth;
		playerY = -playerY * playersFrameHeight;

		-- Position clear button to detect mouseovers
		WorldMapPlayerLower:Show();
		WorldMapPlayerUpper:Show();
		WorldMapPlayerLower:SetPoint("CENTER", WorldMapPlayersFrame, "TOPLEFT", playerX, playerY);
		WorldMapPlayerUpper:SetPoint("CENTER", WorldMapPlayersFrame, "TOPLEFT", playerX, playerY);
		UpdateWorldMapArrow(WorldMapPlayerLower.icon);
		UpdateWorldMapArrow(WorldMapPlayerUpper.icon);
		WorldMapPing:SetPoint("CENTER", WorldMapPlayersFrame, "TOPLEFT", playerX, playerY);
	end

	--Position groupmates
	if ( IsInRaid() ) then
		for i=1, MAX_PARTY_MEMBERS do
			local partyMemberFrame = _G["WorldMapParty"..i];
			partyMemberFrame:Hide();
		end
		for i=1, MAX_RAID_MEMBERS do
			local unit = "raid"..i;
			local partyX, partyY = GetPlayerMapPosition(unit);
			local partyMemberFrame = _G["WorldMapRaid"..i];
			if ( (partyX == 0 and partyY == 0) or UnitIsUnit(unit, "player") ) then
				partyMemberFrame:Hide();
			else
				partyX = partyX * playersFrameWidth;
				partyY = -partyY * playersFrameHeight;
				partyMemberFrame:SetPoint("CENTER", WorldMapPlayersFrame, "TOPLEFT", partyX, partyY);
				local class = select(2, UnitClass(unit));
				if ( class ) then
					if ( UnitInParty(unit) ) then
						partyMemberFrame.icon:SetTexCoord(
							BLIP_TEX_COORDS[class][1],
							BLIP_TEX_COORDS[class][2],
							BLIP_TEX_COORDS[class][3],
							BLIP_TEX_COORDS[class][4]
						);
					else
						partyMemberFrame.icon:SetTexCoord(
							BLIP_TEX_COORDS[class][1],
							BLIP_TEX_COORDS[class][2],
							BLIP_TEX_COORDS[class][3] + BLIP_RAID_Y_OFFSET,
							BLIP_TEX_COORDS[class][4] + BLIP_RAID_Y_OFFSET
						);
					end
				end
				partyMemberFrame.name = nil;
				partyMemberFrame.unit = unit;
				partyMemberFrame:Show();
			end
		end
	else
		for i=1, MAX_RAID_MEMBERS do
			local partyMemberFrame = _G["WorldMapRaid"..i];
			partyMemberFrame:Hide();
		end
		for i=1, MAX_PARTY_MEMBERS do
			local unit = "party"..i;
			local partyX, partyY = GetPlayerMapPosition(unit);
			local partyMemberFrame = _G["WorldMapParty"..i];
			if ( partyX == 0 and partyY == 0 ) then
				partyMemberFrame:Hide();
			else
				partyX = partyX * playersFrameWidth;
				partyY = -partyY * playersFrameHeight;
				partyMemberFrame:SetPoint("CENTER", WorldMapPlayersFrame, "TOPLEFT", partyX, partyY);
				local class = select(2, UnitClass(unit));
				if ( class ) then
					partyMemberFrame.icon:SetTexCoord(
						BLIP_TEX_COORDS[class][1],
						BLIP_TEX_COORDS[class][2],
						BLIP_TEX_COORDS[class][3],
						BLIP_TEX_COORDS[class][4]
					);
				end
				partyMemberFrame:Show();
			end
		end
	end

	-- Position flags
	local numFlags = GetNumBattlefieldFlagPositions();
	for i=1, numFlags do
		local flagX, flagY, flagToken = GetBattlefieldFlagPosition(i);
		local flagFrameName = "WorldMapFlag"..i;
		local flagFrame = _G[flagFrameName];
		if ( flagX == 0 and flagY == 0 ) then
			flagFrame:Hide();
		else
			flagX = flagX * WorldMapDetailFrame:GetWidth();
			flagY = -flagY * WorldMapDetailFrame:GetHeight();
			flagFrame:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", flagX, flagY);
			local flagTexture = _G[flagFrameName.."Texture"];
			flagTexture:SetTexture("Interface\\WorldStateFrame\\"..flagToken);
			flagFrame:Show();
		end
	end
	for i=numFlags+1, NUM_WORLDMAP_FLAGS do
		local flagFrame = _G["WorldMapFlag"..i];
		flagFrame:Hide();
	end

	-- Position corpse
	local corpseX, corpseY = GetCorpseMapPosition();
	if ( corpseX == 0 and corpseY == 0 ) then
		WorldMapCorpse:Hide();
	else
		corpseX = corpseX * WorldMapDetailFrame:GetWidth();
		corpseY = -corpseY * WorldMapDetailFrame:GetHeight();
		
		WorldMapCorpse:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", corpseX, corpseY);
		WorldMapCorpse:Show();
	end

	-- Position Death Release marker
	local deathReleaseX, deathReleaseY = GetDeathReleasePosition();
	if ((deathReleaseX == 0 and deathReleaseY == 0) or UnitIsGhost("player")) then
		WorldMapDeathRelease:Hide();
	else
		deathReleaseX = deathReleaseX * WorldMapDetailFrame:GetWidth();
		deathReleaseY = -deathReleaseY * WorldMapDetailFrame:GetHeight();
		
		WorldMapDeathRelease:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", deathReleaseX, deathReleaseY);
		WorldMapDeathRelease:Show();
	end
	
	-- position vehicles
	local numVehicles;
	if ( GetCurrentMapContinent() == WORLDMAP_AZEROTH_ID or (GetCurrentMapContinent() ~= -1 and GetCurrentMapZone() == 0) ) then
		-- Hide vehicles on the worldmap and continent maps
		numVehicles = 0;
	else
		numVehicles = GetNumBattlefieldVehicles();
	end
	local totalVehicles = #MAP_VEHICLES;
	local playerBlipFrameLevel = WorldMapRaid1:GetFrameLevel();
	local index = 0;
	for i=1, numVehicles do
		if (i > totalVehicles) then
			local vehicleName = "WorldMapVehicles"..i;
			MAP_VEHICLES[i] = CreateFrame("FRAME", vehicleName, WorldMapPOIFrame, "WorldMapVehicleTemplate");
			MAP_VEHICLES[i].texture = _G[vehicleName.."Texture"];
		end
		local vehicleX, vehicleY, unitName, isPossessed, vehicleType, orientation, isPlayer, isAlive = GetBattlefieldVehicleInfo(i);
		if ( vehicleX and isAlive and not isPlayer and VEHICLE_TEXTURES[vehicleType]) then
			local mapVehicleFrame = MAP_VEHICLES[i];
			vehicleX = vehicleX * WorldMapDetailFrame:GetWidth();
			vehicleY = -vehicleY * WorldMapDetailFrame:GetHeight();
			mapVehicleFrame.texture:SetRotation(orientation);
			mapVehicleFrame.texture:SetTexture(WorldMap_GetVehicleTexture(vehicleType, isPossessed));
			mapVehicleFrame:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", vehicleX, vehicleY);
			mapVehicleFrame:SetWidth(VEHICLE_TEXTURES[vehicleType].width);
			mapVehicleFrame:SetHeight(VEHICLE_TEXTURES[vehicleType].height);
			mapVehicleFrame.name = unitName;
			if ( VEHICLE_TEXTURES[vehicleType].belowPlayerBlips ) then
				mapVehicleFrame:SetFrameLevel(playerBlipFrameLevel - 1);
			else
				mapVehicleFrame:SetFrameLevel(playerBlipFrameLevel + 1);
			end
			mapVehicleFrame:Show();
			index = i;	-- save for later
		else
			MAP_VEHICLES[i]:Hide();
		end
		
	end
	if (index < totalVehicles) then
		for i=index+1, totalVehicles do
			MAP_VEHICLES[i]:Hide();
		end
	end

	WorldMapFrame_EvaluateAreaLabels();
end

function WorldMapPing_OnPlay(self)
	WorldMapPing:Show();
	self.loopCount = 0;
end

function WorldMapPing_OnLoop(self, loopState)
	self.loopCount = self.loopCount + 1;
	if ( self.loopCount >= 3 ) then
		self:Stop();
	end
end

function WorldMapPing_OnStop(self)
	WorldMapPing:Hide();
end

function WorldMap_GetVehicleTexture(vehicleType, isPossessed)
	if ( not vehicleType ) then
		return;
	end
	if ( not isPossessed ) then
		isPossessed = 1;
	else
		isPossessed = 2;
	end
	if ( not VEHICLE_TEXTURES[vehicleType]) then
		return;
	end
	return VEHICLE_TEXTURES[vehicleType][isPossessed];
end

function WorldMap_ClearTextures()
	for i=1, NUM_WORLDMAP_OVERLAYS do
		_G["WorldMapOverlay"..i]:SetTexture(nil);
	end
	local numOfDetailTiles = GetNumberOfDetailTiles();
	for i=1, numOfDetailTiles do
		_G["WorldMapDetailTile"..i]:SetTexture(nil);
	end
end

function WorldMapUnit_OnEnter(self, motion)
	-- Adjust the tooltip based on which side the unit button is on
	local x, y = self:GetCenter();
	local parentX, parentY = self:GetParent():GetCenter();
	if ( x > parentX ) then
		WorldMapTooltip:SetOwner(self, "ANCHOR_LEFT");
	else
		WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end

	-- See which POI's are in the same region and include their names in the tooltip
	local unitButton;
	local newLineString = "";
	local tooltipText = "";

	-- Check player
	if ( WorldMapPlayerUpper:IsMouseOver() ) then
		if ( PlayerIsPVPInactive(WorldMapPlayerUpper.unit) ) then
			tooltipText = format(PLAYER_IS_PVP_AFK, UnitName(WorldMapPlayerUpper.unit));
		else
			tooltipText = UnitName(WorldMapPlayerUpper.unit);
		end
		newLineString = "\n";
	end
	-- Check party
	for i=1, MAX_PARTY_MEMBERS do
		unitButton = _G["WorldMapParty"..i];
		if ( unitButton:IsVisible() and unitButton:IsMouseOver() ) then
			if ( PlayerIsPVPInactive(unitButton.unit) ) then
				tooltipText = tooltipText..newLineString..format(PLAYER_IS_PVP_AFK, UnitName(unitButton.unit));
			else
				tooltipText = tooltipText..newLineString..UnitName(unitButton.unit);
			end
			newLineString = "\n";
		end
	end
	-- Check Raid
	for i=1, MAX_RAID_MEMBERS do
		unitButton = _G["WorldMapRaid"..i];
		if ( unitButton:IsVisible() and unitButton:IsMouseOver() ) then
			if ( unitButton.name ) then
				-- Handle players not in your raid or party, but on your team
				if ( PlayerIsPVPInactive(unitButton.name) ) then
					tooltipText = tooltipText..newLineString..format(PLAYER_IS_PVP_AFK, unitButton.name);
				else
					tooltipText = tooltipText..newLineString..unitButton.name;		
				end
			else
				if ( PlayerIsPVPInactive(unitButton.unit) ) then
					tooltipText = tooltipText..newLineString..format(PLAYER_IS_PVP_AFK, UnitName(unitButton.unit));
				else
					tooltipText = tooltipText..newLineString..UnitName(unitButton.unit);
				end
			end
			newLineString = "\n";
		end
	end
	-- Check Vehicles
	local numVehicles = GetNumBattlefieldVehicles();
	for _, v in pairs(MAP_VEHICLES) do
		if ( v:IsVisible() and v:IsMouseOver() ) then
			if ( v.name ) then
				tooltipText = tooltipText..newLineString..v.name;
			end
			newLineString = "\n";
		end
	end
	-- Check debug objects
	for i = 1, NUM_WORLDMAP_DEBUG_OBJECTS do
		unitButton = _G["WorldMapDebugObject"..i];
		if ( unitButton:IsVisible() and unitButton:IsMouseOver() ) then
			tooltipText = tooltipText..newLineString..unitButton.name;
			newLineString = "\n";
		end
	end
	WorldMapTooltip:SetText(tooltipText);
	WorldMapTooltip:Show();
end

function WorldMapUnit_OnLeave(self, motion)
	WorldMapTooltip:Hide();
end

function WorldMapUnit_OnEvent(self, event, ...)
	if ( event == "UNIT_AURA" ) then
		if ( self.unit ) then
			local unit = ...;
			if ( self.unit == unit ) then
				WorldMapUnit_Update(self);
			end
		end
	end
end

function WorldMapUnit_OnMouseUp(self, mouseButton, raidUnitPrefix, partyUnitPrefix)
	if ( GetCVar("enablePVPNotifyAFK") == "0" ) then
		return;
	end

	if ( mouseButton == "RightButton" ) then
		BAD_BOY_COUNT = 0;

		local inInstance, instanceType = IsInInstance();
		if ( instanceType == "pvp" or  IsInActiveWorldPVP() ) then
			--Check Raid
			local unitButton;
			for i=1, MAX_RAID_MEMBERS do
				unitButton = _G[raidUnitPrefix..i];
				if ( unitButton.unit and unitButton:IsVisible() and unitButton:IsMouseOver() and
					 not PlayerIsPVPInactive(unitButton.unit) ) then
					BAD_BOY_COUNT = BAD_BOY_COUNT + 1;
					BAD_BOY_UNITS[BAD_BOY_COUNT] = unitButton.unit;
				end
			end
			if ( BAD_BOY_COUNT > 0 ) then
				-- Check party
				for i=1, MAX_PARTY_MEMBERS do
					unitButton = _G[partyUnitPrefix..i];
					if ( unitButton.unit and unitButton:IsVisible() and unitButton:IsMouseOver() and
						 not PlayerIsPVPInactive(unitButton.unit) ) then
						BAD_BOY_COUNT = BAD_BOY_COUNT + 1;
						BAD_BOY_UNITS[BAD_BOY_COUNT] = unitButton.unit;
					end
				end
			end
		end

		if ( BAD_BOY_COUNT > 0 ) then
			UIDropDownMenu_Initialize( WorldMapUnitDropDown, WorldMapUnitDropDown_Initialize, "MENU");
			ToggleDropDownMenu(1, nil, WorldMapUnitDropDown, self:GetName(), 0, -5);
		end
	end
end

function WorldMapUnit_OnShow(self)
	self:RegisterEvent("UNIT_AURA");
	WorldMapUnit_Update(self);
end

function WorldMapUnit_OnHide(self)
	self:UnregisterEvent("UNIT_AURA");
end

function WorldMapUnit_Update(self)
	-- check for pvp inactivity (pvp inactivity is a debuff so make sure you call this when you get a UNIT_AURA event)
	local player = self.unit or self.name;
	if ( player and PlayerIsPVPInactive(player) ) then
		self.icon:SetVertexColor(0.5, 0.2, 0.8);
	else
		self.icon:SetVertexColor(1.0, 1.0, 1.0);
	end
end

function WorldMapUnitDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.text = PVP_REPORT_AFK;
	info.notClickable = 1;
	info.isTitle = 1;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);

	if ( BAD_BOY_COUNT > 0 ) then
		for i=1, BAD_BOY_COUNT do
			info = UIDropDownMenu_CreateInfo();
			info.func = WorldMapUnitDropDown_OnClick;
			info.arg1 = BAD_BOY_UNITS[i];
			info.text = UnitName( BAD_BOY_UNITS[i] );
			info.notCheckable = true;
			UIDropDownMenu_AddButton(info);
		end
		
		if ( BAD_BOY_COUNT > 1 ) then
			info = UIDropDownMenu_CreateInfo();
			info.func = WorldMapUnitDropDown_ReportAll_OnClick;
			info.text = PVP_REPORT_AFK_ALL;
			info.notCheckable = true;
			UIDropDownMenu_AddButton(info);
		end
	end

	info = UIDropDownMenu_CreateInfo();
	info.text = CANCEL;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);
end

function WorldMapUnitDropDown_OnClick(self, unit)
	ReportPlayerIsPVPAFK(unit);
end

function WorldMapUnitDropDown_ReportAll_OnClick()
	if ( BAD_BOY_COUNT > 0 ) then
		for i=1, BAD_BOY_COUNT do
			ReportPlayerIsPVPAFK(BAD_BOY_UNITS[i]);
		end
	end
end

function WorldMapFrame_ToggleWindowSize()
	-- close the frame first so the UI panel system can do its thing	
	WorldMapFrame.toggling = true;
	ToggleFrame(WorldMapFrame);
	-- apply magic
	if ( WorldMapFrame_InWindowedMode() ) then
		if ( not WorldMapFrame.questLogMode ) then
			SetCVar("miniWorldMap", 0);
		end
		WorldMap_ToggleSizeUp();
	else
		if ( not WorldMapFrame.questLogMode ) then
			SetCVar("miniWorldMap", 1);
		end
		WorldMap_ToggleSizeDown();
		if ( GetCVarBool("questLogOpen") or WorldMapFrame.questLogMode ) then
			QuestMapFrame_Show();
		end
	end	
	-- reopen the frame
	WorldMapFrame.blockWorldMapUpdate = true;
	ToggleFrame(WorldMapFrame);
	WorldMapFrame.blockWorldMapUpdate = nil;
	WorldMapFrame_UpdateMap();
	QuestMapFrame_UpdateAll();	
end

function WorldMap_ToggleSizeUp()
	QuestMapFrame_Hide();
	WorldMapFrame.UIElementsFrame.OpenQuestPanelButton:Hide();
	HelpPlate_Hide();
	WorldMapFrame.MainHelpButton:Hide();
	WORLDMAP_SETTINGS.size = WORLDMAP_FULLMAP_SIZE;
	-- adjust main frame
	WorldMapFrame:SetParent(nil);
	WorldMapTooltip:SetFrameStrata("TOOLTIP");	
	WorldMapPlayerLower:SetFrameStrata("HIGH");
	WorldMapPlayerUpper:SetFrameStrata("FULLSCREEN");
	WorldMapFrame:ClearAllPoints();
	WorldMapFrame:SetAllPoints();
	SetUIPanelAttribute(WorldMapFrame, "area", "full");
	SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", false);
	WorldMapFrame:EnableKeyboard(true);
	-- adjust map frames
	WorldMapDetailFrame:SetScale(WORLDMAP_FULLMAP_SIZE);
	WorldMapFrame.BorderFrame:SetSize(1022, 766);	
	WorldMapFrameAreaFrame:SetScale(WORLDMAP_FULLMAP_SIZE);
	WorldMapPlayersFrame:SetScale(WORLDMAP_FULLMAP_SIZE);	
	WorldMapBlobFrame_ResetHitTranslations();
	QUEST_POI_FRAME_WIDTH = WorldMapDetailFrame:GetWidth() * WORLDMAP_FULLMAP_SIZE;
	QUEST_POI_FRAME_HEIGHT = WorldMapDetailFrame:GetHeight() * WORLDMAP_FULLMAP_SIZE;
	-- show big window elements
	BlackoutWorld:Show();
	
	WorldMapFrame.BorderFrame.Inset:SetPoint("TOPLEFT", 5, -63);
	WorldMapFrame.BorderFrame.Inset:SetPoint("BOTTOMRIGHT", -7, 28);
	WorldMapScrollFrame:ClearAllPoints();
	WorldMapScrollFrame:SetPoint("TOP", 0, -68);
	WorldMapScrollFrame:SetSize(1002, 668);
	
	ButtonFrameTemplate_HidePortrait(WorldMapFrame.BorderFrame);
	WorldMapFrame.NavBar:SetPoint("TOPLEFT", WorldMapFrame.BorderFrame, 10, -23);
	WorldMapFrame.NavBar:SetWidth(1000);	
	WorldMapFrameSizeDownButton:Show();
	-- hide small window elements
	WorldMapTitleButton:Hide();
	WorldMapFrameSizeUpButton:Hide();
	ToggleMapFramerate();
	-- floor dropdown
    --WorldMapLevelDropDown:SetPoint("TOPLEFT", WorldMapDetailFrame, -18, 2);
	-- tiny adjustments	
	
	if (GetCVarBool("questPOI")) then
		WorldMapPlayerLower:SetSize(PLAYER_ARROW_SIZE_FULL_WITH_QUESTS,PLAYER_ARROW_SIZE_FULL_WITH_QUESTS);
		WorldMapPlayerUpper:SetSize(PLAYER_ARROW_SIZE_FULL_WITH_QUESTS,PLAYER_ARROW_SIZE_FULL_WITH_QUESTS);
	else
		WorldMapPlayerLower:SetSize(PLAYER_ARROW_SIZE_FULL_NO_QUESTS,PLAYER_ARROW_SIZE_FULL_NO_QUESTS);
		WorldMapPlayerUpper:SetSize(PLAYER_ARROW_SIZE_FULL_NO_QUESTS,PLAYER_ARROW_SIZE_FULL_NO_QUESTS);
	end
	MapBarFrame_UpdateLayout(MapBarFrame);
end

function WorldMap_ToggleSizeDown()
	WorldMapFrame.UIElementsFrame.OpenQuestPanelButton:Show();
	WorldMapFrame.MainHelpButton:Show();
	WORLDMAP_SETTINGS.size = WORLDMAP_WINDOWED_SIZE;
	-- adjust main frame
	WorldMapFrame:SetParent(UIParent);
	WorldMapFrame:SetFrameStrata("HIGH");
	WorldMapTooltip:SetFrameStrata("TOOLTIP");
	WorldMapPlayerLower:SetFrameStrata("HIGH");
	WorldMapPlayerUpper:SetFrameStrata("FULLSCREEN");
	WorldMapFrame:EnableKeyboard(false);
	-- adjust map frames
	WorldMapDetailFrame:SetScale(WORLDMAP_WINDOWED_SIZE);
	WorldMapFrameAreaFrame:SetScale(WORLDMAP_WINDOWED_SIZE);
	WorldMapPlayersFrame:SetScale(WORLDMAP_WINDOWED_SIZE);
	WorldMapBlobFrame_ResetHitTranslations();
	QUEST_POI_FRAME_WIDTH = WorldMapDetailFrame:GetWidth() * WORLDMAP_WINDOWED_SIZE;
	QUEST_POI_FRAME_HEIGHT = WorldMapDetailFrame:GetHeight() * WORLDMAP_WINDOWED_SIZE;
	-- hide big window elements
	BlackoutWorld:Hide();
	WorldMapFrameSizeDownButton:Hide();
	ToggleMapFramerate();	
	-- show small window elements
	WorldMapTitleButton:Show();
	WorldMapFrameSizeUpButton:Show();
	-- floor dropdown
    --WorldMapLevelDropDown:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -18, 2);

	-- tiny adjustments
	-- pet battle level size adjustment
	WorldMapFrameAreaPetLevels:SetFontObject("SubZoneTextFont");
	-- user-movable
	WorldMapFrame:ClearAllPoints();
	SetUIPanelAttribute(WorldMapFrame, "area", "center");
	SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true);
	WorldMapFrame:SetMovable(true);
	WorldMapFrame:SetSize(702, 534);
	WorldMapFrame.BorderFrame:SetSize(702, 534);
	
	WorldMapFrame.BorderFrame.Inset:SetPoint("TOPLEFT", 0, -63);
	WorldMapFrame.BorderFrame.Inset:SetPoint("BOTTOMRIGHT", -2, 1);
	ButtonFrameTemplate_ShowPortrait(WorldMapFrame.BorderFrame);
	WorldMapFrame.NavBar:SetPoint("TOPLEFT", WorldMapFrame.BorderFrame, 64, -23);
	WorldMapFrame.NavBar:SetWidth(628);

	WorldMapFrame:SetPoint("TOPLEFT", WorldMapScreenAnchor, 0, 0);
	WorldMapScrollFrame:ClearAllPoints();
	WorldMapScrollFrame:SetPoint("TOPLEFT", 3, -68);
	WorldMapScrollFrame:SetSize(696, 464);
	WorldMapPlayerLower:SetSize(PLAYER_ARROW_SIZE_WINDOW,PLAYER_ARROW_SIZE_WINDOW);
	WorldMapPlayerUpper:SetSize(PLAYER_ARROW_SIZE_WINDOW,PLAYER_ARROW_SIZE_WINDOW);
	MapBarFrame_UpdateLayout(MapBarFrame);
end

function WorldMapFrame_UpdateMap()
	WorldMapFrame_Update();
	WorldMapLevelDropDown_Update();
	WorldMapNavBar_Update();
end

function ScenarioPOIFrame_OnUpdate()
	ScenarioPOIFrame:DrawNone();
	if( GetCVarBool("questPOI") ) then
		ScenarioPOIFrame:DrawAll();
	end
end

function ArchaeologyDigSiteFrame_OnUpdate()
	WorldMapArchaeologyDigSites:DrawNone();
	local numEntries = ArchaeologyMapUpdateAll();
	for i = 1, numEntries do
		local blobID = ArcheologyGetVisibleBlobID(i);
		WorldMapArchaeologyDigSites:DrawBlob(blobID, true);
	end
end

function WorldMapQuestPOI_SetTooltip(poiButton, questLogIndex, numObjectives)
	local title = GetQuestLogTitle(questLogIndex);
	WorldMapTooltip:SetOwner(poiButton or WorldMapPOIFrame, "ANCHOR_CURSOR_RIGHT", 5, 2);
	WorldMapTooltip:SetText(title);
	if ( poiButton and poiButton.style ~= "numeric" ) then
		local completionText = GetQuestLogCompletionText(questLogIndex) or QUEST_WATCH_QUEST_READY;
		WorldMapTooltip:AddLine("- "..completionText, 1, 1, 1, true);
	else
		local text, finished, objectiveType;
		local numItemDropTooltips = GetNumQuestItemDrops(questLogIndex);
		if(numItemDropTooltips and numItemDropTooltips > 0) then
			for i = 1, numItemDropTooltips do
				text, objectiveType, finished = GetQuestLogItemDrop(i, questLogIndex);
				if ( text and not finished ) then
					WorldMapTooltip:AddLine(QUEST_DASH..text, 1, 1, 1, true);
				end
			end
		else
			local numPOITooltips = WorldMapBlobFrame:GetNumTooltips();
			numObjectives = numObjectives or GetNumQuestLeaderBoards(questLogIndex);
			for i = 1, numObjectives do
				if(numPOITooltips and (numPOITooltips == numObjectives)) then
					local questPOIIndex = WorldMapBlobFrame:GetTooltipIndex(i);
					text, objectiveType, finished = GetQuestPOILeaderBoard(questPOIIndex, questLogIndex);
				else
					text, objectiveType, finished = GetQuestLogLeaderBoard(i, questLogIndex);
				end
				if ( text and not finished ) then
					WorldMapTooltip:AddLine(QUEST_DASH..text, 1, 1, 1, true);
				end
			end		
		end
	end
	WorldMapTooltip:Show();
end

function WorldMapQuestPOI_AppendTooltip(poiButton, questLogIndex)
	local title = GetQuestLogTitle(questLogIndex);
	WorldMapTooltip:AddLine(" ");
	WorldMapTooltip:AddLine(title);
	if ( poiButton and poiButton.style ~= "numeric" ) then
		local completionText = GetQuestLogCompletionText(questLogIndex) or QUEST_WATCH_QUEST_READY;
		WorldMapTooltip:AddLine("- "..completionText, 1, 1, 1, true);
	else
		local text, finished, objectiveType;
		local numItemDropTooltips = GetNumQuestItemDrops(questLogIndex);
		if(numItemDropTooltips and numItemDropTooltips > 0) then
			for i = 1, numItemDropTooltips do
				text, objectiveType, finished = GetQuestLogItemDrop(i, questLogIndex);
				if ( text and not finished ) then
					WorldMapTooltip:AddLine(QUEST_DASH..text, 1, 1, 1, true);
				end
			end
		else
			local numPOITooltips = WorldMapBlobFrame:GetNumTooltips();
			local numObjectives = GetNumQuestLeaderBoards(questLogIndex);
			for i = 1, numObjectives do
				if(numPOITooltips and (numPOITooltips == numObjectives)) then
					local questPOIIndex = WorldMapBlobFrame:GetTooltipIndex(i);
					text, objectiveType, finished = GetQuestPOILeaderBoard(questPOIIndex, questLogIndex);
				else
					text, objectiveType, finished = GetQuestLogLeaderBoard(i, questLogIndex);
				end
				if ( text and not finished ) then
					WorldMapTooltip:AddLine(QUEST_DASH..text, 1, 1, 1, true);
				end
			end		
		end
	end
	WorldMapTooltip:Show();
end

function WorldMapBlobFrame_OnLoad(self)
	self:SetFillTexture("Interface\\WorldMap\\UI-QuestBlob-Inside");
	self:SetBorderTexture("Interface\\WorldMap\\UI-QuestBlob-Outside");
	self:SetFillAlpha(128);
	self:SetBorderAlpha(192);
	self:SetBorderScalar(1.0);
end

-- for when we need to wait a frame
function WorldMapBlobFrame_DelayedUpdateBlobs()	
	WorldMapBlobFrame.updateBlobs = true;
end

function WorldMapBlobFrame_OnUpdate(self)
	if ( self.updateBlobs ) then
		WorldMapBlobFrame_UpdateBlobs();
		self.updateBlobs = nil;
	end

	if ( not WorldMapBlobFrame:IsMouseOver() ) then
		return;
	end
	if ( WorldMapTooltip:IsShown() and WorldMapTooltip:GetOwner() ~= WorldMapPOIFrame ) then
		return;
	end

	if ( not self.scale ) then
		WorldMapBlobFrame_CalculateHitTranslations();
	end
	
	local cursorX, cursorY = GetCursorPosition();
	local frameX = cursorX / self.scale - self.offsetX;
	local frameY = - cursorY / self.scale + self.offsetY;	
	local adjustedX = frameX / QUEST_POI_FRAME_WIDTH;
	local adjustedY = frameY / QUEST_POI_FRAME_HEIGHT;

	local questLogIndex, numObjectives = self:UpdateMouseOverTooltip(adjustedX, adjustedY);
	if ( numObjectives ) then
		WorldMapQuestPOI_SetTooltip(nil, questLogIndex, numObjectives);
	else
		WorldMapTooltip:Hide();
	end
end

function WorldMapBlobFrame_ResetHitTranslations()
	WorldMapBlobFrame.scale = nil;
end

function WorldMapBlobFrame_CalculateHitTranslations()
	local self = WorldMapBlobFrame;	
	if ( WorldMapFrame_InWindowedMode() ) then
		self.scale = UIParent:GetScale();
	else
		self.scale = WorldMapFrame:GetScale();
	end
	self.offsetX = WorldMapScrollFrame:GetLeft() - WorldMapScrollFrame:GetHorizontalScroll();
	self.offsetY = WorldMapScrollFrame:GetTop() + WorldMapScrollFrame:GetVerticalScroll();
end

function WorldMapFrame_ResetQuestColors()
	-- FIXME
end

--- advanced options ---

function WorldMapTitleButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonDown", "LeftButtonUp", "RightButtonUp");
	self:RegisterForDrag("LeftButton");
	UIDropDownMenu_Initialize(WorldMapTitleDropDown, WorldMapTitleDropDown_Initialize, "MENU");
end

function WorldMapTitleButton_OnClick(self, button)
	PlaySound("UChatScrollButton");
	
	-- If Rightclick bring up the options menu
	if ( button == "RightButton" ) then
		ToggleDropDownMenu(1, nil, WorldMapTitleDropDown, "cursor", 0, 0);
		return;
	end

	-- Close all dropdowns
	CloseDropDownMenus();
end

function WorldMapTitleButton_OnDragStart()
	if ( not WORLDMAP_SETTINGS.locked ) then
		WorldMapScreenAnchor:ClearAllPoints();
		WorldMapFrame:ClearAllPoints();
		WorldMapFrame:StartMoving();	
	end
end

function WorldMapTitleButton_OnDragStop()
	if ( not WORLDMAP_SETTINGS.locked ) then
		WorldMapFrame:StopMovingOrSizing();
		WorldMapBlobFrame_ResetHitTranslations();
		-- move the anchor
		WorldMapScreenAnchor:StartMoving();
		WorldMapScreenAnchor:SetPoint("TOPLEFT", WorldMapFrame);
		WorldMapScreenAnchor:StopMovingOrSizing();
	end
end

function WorldMapTitleDropDown_Initialize()
	local checked;
	local info = UIDropDownMenu_CreateInfo();
	info.isNotRadio = true;
	info.notCheckable = true;
	-- Lock/Unlock
	info.func = WorldMapTitleDropDown_ToggleLock;
	if ( WORLDMAP_SETTINGS.locked ) then
		info.text = UNLOCK_FRAME;
	else
		info.text = LOCK_FRAME;
	end
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	-- Reset
	info.func = WorldMapTitleDropDown_ResetPosition;
	info.text = RESET_POSITION;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
end

function WorldMapTitleDropDown_ToggleLock()
	WORLDMAP_SETTINGS.locked = not WORLDMAP_SETTINGS.locked;
	if ( WORLDMAP_SETTINGS.locked ) then
		SetCVar("lockedWorldMap", 1);
	else
		SetCVar("lockedWorldMap", 0);
	end
end

function WorldMapTitleDropDown_ResetPosition()
	WorldMapFrame:ClearAllPoints();
	WorldMapFrame:SetPoint("TOPLEFT", 10, -118);
	WorldMapScreenAnchor:ClearAllPoints();
	WorldMapScreenAnchor:StartMoving();
	WorldMapScreenAnchor:SetPoint("TOPLEFT", WorldMapFrame);
	WorldMapScreenAnchor:StopMovingOrSizing();
end

-- *****************************************************************************************************
-- ***** PAN AND ZOOM
-- *****************************************************************************************************
local MAX_ZOOM = 1.495;

function WorldMapScrollFrame_OnMouseWheel(self, delta)
	local scrollFrame = WorldMapScrollFrame;
	local oldScrollH = scrollFrame:GetHorizontalScroll();
	local oldScrollV = scrollFrame:GetVerticalScroll();

	-- get the mouse position on the frame, with 0,0 at top left
	local cursorX, cursorY = GetCursorPosition();
	local relativeFrame;
	if ( WorldMapFrame_InWindowedMode() ) then
		relativeFrame = UIParent;
	else
		relativeFrame = WorldMapFrame;
	end
	local frameX = cursorX / relativeFrame:GetScale() - scrollFrame:GetLeft();
	local frameY = scrollFrame:GetTop() - cursorY / relativeFrame:GetScale();

	local oldScale = WorldMapDetailFrame:GetScale();
	local newScale = oldScale + delta * 0.3;
	newScale = max(WORLDMAP_SETTINGS.size, newScale);
	newScale = min(MAX_ZOOM, newScale);
	WorldMapDetailFrame:SetScale(newScale);
	QUEST_POI_FRAME_WIDTH = WorldMapDetailFrame:GetWidth() * newScale;
	QUEST_POI_FRAME_HEIGHT = WorldMapDetailFrame:GetHeight() * newScale;

	scrollFrame.maxX = QUEST_POI_FRAME_WIDTH - 1002 * WORLDMAP_SETTINGS.size;
	scrollFrame.maxY = QUEST_POI_FRAME_HEIGHT - 668 * WORLDMAP_SETTINGS.size;
	scrollFrame.zoomedIn = abs(WorldMapDetailFrame:GetScale() - WORLDMAP_SETTINGS.size) > 0.05;
	scrollFrame.continent = GetCurrentMapContinent();
	scrollFrame.mapID = GetCurrentMapAreaID();

	-- figure out new scroll values
	local scaleChange = newScale / oldScale;
	local newScrollH = scaleChange * ( frameX + oldScrollH ) - frameX;
	local newScrollV = scaleChange * ( frameY + oldScrollV ) - frameY;
	-- clamp scroll values
	newScrollH = min(newScrollH, scrollFrame.maxX);
	newScrollH = max(0, newScrollH);
	newScrollV = min(newScrollV, scrollFrame.maxY);
	newScrollV = max(0, newScrollV);
	-- set scroll values
	scrollFrame:SetHorizontalScroll(newScrollH);
	scrollFrame:SetVerticalScroll(newScrollV);

	WorldMapFrame_Update();
	WorldMapScrollFrame_ReanchorQuestPOIs();
	WorldMapBlobFrame_ResetHitTranslations();
	WorldMapBlobFrame_DelayedUpdateBlobs();
end

function WorldMapScrollFrame_ResetZoom()
	WorldMapScrollFrame.panning = false;
	WorldMapDetailFrame:SetScale(WORLDMAP_SETTINGS.size);
	QUEST_POI_FRAME_WIDTH = WorldMapDetailFrame:GetWidth() * WORLDMAP_SETTINGS.size;
	QUEST_POI_FRAME_HEIGHT = WorldMapDetailFrame:GetHeight() * WORLDMAP_SETTINGS.size;	
	WorldMapScrollFrame:SetHorizontalScroll(0);
	WorldMapScrollFrame:SetVerticalScroll(0);
	WorldMapScrollFrame.zoomedIn = false;
	WorldMapFrame_Update();
	WorldMapScrollFrame_ReanchorQuestPOIs();
	WorldMapBlobFrame_ResetHitTranslations();
	WorldMapBlobFrame_DelayedUpdateBlobs();
end

function WorldMapScrollFrame_ReanchorQuestPOIs()
	for _, poiType in pairs(WorldMapPOIFrame.poiTable) do
		for _, poiButton in pairs(poiType) do
			if ( poiButton.used ) then
				local _, posX, posY = QuestPOIGetIconInfo(poiButton.questID);
				WorldMapPOIFrame_AnchorPOI(poiButton, posX, posY, WORLD_MAP_POI_FRAME_LEVEL_OFFSETS.TRACKED_QUEST);			
			end
		end
	end
end

function WorldMapScrollFrame_OnPan(cursorX, cursorY)
	local dx = WorldMapScrollFrame.cursorX - cursorX;
	local dy = cursorY - WorldMapScrollFrame.cursorY;
	if ( abs(dx) >= 1 or abs(dy) >= 1 ) then
		WorldMapScrollFrame.moved = true;	
		local x = max(0, dx + WorldMapScrollFrame.x);
		x = min(x, WorldMapScrollFrame.maxX);
		WorldMapScrollFrame:SetHorizontalScroll(x);
		local y = max(0, dy + WorldMapScrollFrame.y);
		y = min(y, WorldMapScrollFrame.maxY);
		WorldMapScrollFrame:SetVerticalScroll(y);
		WorldMapBlobFrame_ResetHitTranslations();
		WorldMapBlobFrame_DelayedUpdateBlobs();
	end
end

function WorldMapButton_OnMouseDown(self, button)
	if ( button == "LeftButton" and WorldMapScrollFrame.zoomedIn ) then
		WorldMapScrollFrame.panning = true;
		local x, y = GetCursorPosition();		
		WorldMapScrollFrame.cursorX = x;
		WorldMapScrollFrame.cursorY = y;
		WorldMapScrollFrame.x = WorldMapScrollFrame:GetHorizontalScroll();
		WorldMapScrollFrame.y = WorldMapScrollFrame:GetVerticalScroll();
		WorldMapScrollFrame.moved = false;
	end
end

function WorldMapButton_OnMouseUp(self, button)
	if ( button == "LeftButton" and WorldMapScrollFrame.panning ) then
		WorldMapScrollFrame.panning = false;
		if ( WorldMapScrollFrame.moved ) then
			WorldMapButton.ignoreClick = true;
		end
	end
end

-- *****************************************************************************************************
-- ***** POI FRAME
-- *****************************************************************************************************

function WorldMapPOIFrame_AnchorPOI(poiButton, posX, posY, frameLevelOffset)
	if ( posX and posY ) then
		posX = posX * QUEST_POI_FRAME_WIDTH;
		posY = posY * QUEST_POI_FRAME_HEIGHT;
		-- keep outlying POIs within map borders
		if ( posY < QUEST_POI_FRAME_INSET ) then
			posY = QUEST_POI_FRAME_INSET;
		elseif ( posY > QUEST_POI_FRAME_HEIGHT - 12 ) then
			posY = QUEST_POI_FRAME_HEIGHT - 12;
		end
		if ( posX < QUEST_POI_FRAME_INSET ) then
			posX = QUEST_POI_FRAME_INSET;
		elseif ( posX > QUEST_POI_FRAME_WIDTH - 12 ) then
			posX = QUEST_POI_FRAME_WIDTH - 12;
		end
		poiButton:SetPoint("CENTER", WorldMapPOIFrame, "TOPLEFT", posX, -posY);
		poiButton:SetFrameLevel(poiButton:GetParent():GetFrameLevel() + frameLevelOffset);
	end
end

function WorldMapPOIFrame_Update(poiTable)
	QuestPOI_ResetUsage(WorldMapPOIFrame);
	local detailQuestID = QuestMapFrame_GetDetailQuestID();
	local poiButton;
	for index, questID in pairs(poiTable) do
		if ( not detailQuestID or questID == detailQuestID ) then
			local _, posX, posY = QuestPOIGetIconInfo(questID);
			if ( posX and posY ) then
				local storyQuest = IsStoryQuest(questID);
				if ( IsQuestComplete(questID) ) then
					poiButton = QuestPOI_GetButton(WorldMapPOIFrame, questID, "map", nil, storyQuest);
				else
					-- if a quest is being viewed there is only going to be one POI and it's going to have number 1
					poiButton = QuestPOI_GetButton(WorldMapPOIFrame, questID, "numeric", (detailQuestID and 1) or index, storyQuest);
				end
				WorldMapPOIFrame_AnchorPOI(poiButton, posX, posY, WORLD_MAP_POI_FRAME_LEVEL_OFFSETS.TRACKED_QUEST);
			end
		end
	end
	WorldMapPOIFrame_SelectPOI(GetSuperTrackedQuestID());
	QuestPOI_HideUnusedButtons(WorldMapPOIFrame);
end

function WorldMapPOIFrame_SelectPOI(questID)
	-- POIs can overlap each other, bring the selection to the top
	local poiButton = QuestPOI_FindButton(WorldMapPOIFrame, questID);
	if ( poiButton ) then
		QuestPOI_SelectButton(poiButton);
		poiButton:Raise();
	else
		QuestPOI_ClearSelection(WorldMapPOIFrame);
	end
	WorldMapBlobFrame_UpdateBlobs();	
end

function WorldMapBlobFrame_UpdateBlobs()
	WorldMapBlobFrame:DrawNone();
	-- always draw the blob for either the quest being viewed or the supertracked
	local questID = QuestMapFrame_GetDetailQuestID() or GetSuperTrackedQuestID();
	-- see if there is a poiButton for it (no button == not on viewed map)
	local poiButton = QuestPOI_FindButton(WorldMapPOIFrame, questID);
	if ( poiButton and not IsQuestComplete(questID) ) then
		WorldMapBlobFrame:DrawBlob(questID, true);
	end
end

function WorldMapPOIButton_Init(self)
	self:SetScript("OnEnter", WorldMapPOIButton_OnEnter);
	self:SetScript("OnLeave", WorldMapPOIButton_OnLeave);
end

BLOB_OVERLAP_DELTA = math.pow(0.005, 2);

function WorldMapPOIButton_OnEnter(self)
	WorldMapQuestPOI_SetTooltip(self, GetQuestLogIndexByID(self.questID));

	local _, posX, posY = QuestPOIGetIconInfo(self.questID);
	for _, poiType in pairs(WorldMapPOIFrame.poiTable) do
		for _, poiButton in pairs(poiType) do
			if ( poiButton ~= self and poiButton.used ) then
				local _, otherPosX, otherPosY = QuestPOIGetIconInfo(poiButton.questID);

				if ((math.pow(posX - otherPosX, 2) + math.pow(posY - otherPosY, 2)) < BLOB_OVERLAP_DELTA) then
					WorldMapQuestPOI_AppendTooltip(poiButton, GetQuestLogIndexByID(poiButton.questID));
				end
			end
		end
	end
end

function WorldMapPOIButton_OnLeave(self)
	WorldMapTooltip:Hide();
end

-- *****************************************************************************************************
-- ***** ENCOUNTER JOURNAL STUFF
-- *****************************************************************************************************

function EncounterJournal_AddMapButtons()
	local left = WorldMapBossButtonFrame:GetLeft();
	local right = WorldMapBossButtonFrame:GetRight();
	local top = WorldMapBossButtonFrame:GetTop();
	local bottom = WorldMapBossButtonFrame:GetBottom();

	if not left or not right or not top or not bottom then
		--This frame is resizing
		WorldMapBossButtonFrame.ready = false;
		WorldMapBossButtonFrame:SetScript("OnUpdate", EncounterJournal_AddMapButtons);
		return;
	else
		WorldMapBossButtonFrame:SetScript("OnUpdate", nil);
	end
	
	local width = WorldMapDetailFrame:GetWidth();
	local height = WorldMapDetailFrame:GetHeight();

	local bossButton, questPOI, displayInfo, _;
	local index = 1;
	local x, y, instanceID, name, description, encounterID = EJ_GetMapEncounter(index, WorldMapFrame.fromJournal);
	while name do
		bossButton = _G["EJMapButton"..index];
		if not bossButton then -- create button
			bossButton = CreateFrame("Button", "EJMapButton"..index, WorldMapBossButtonFrame, "EncounterMapButtonTemplate");
		end
	
		bossButton.instanceID = instanceID;
		bossButton.encounterID = encounterID;
		bossButton.tooltipTitle = name;
		bossButton.tooltipText = description;
		bossButton:SetPoint("CENTER", WorldMapBossButtonFrame, "BOTTOMLEFT", x*width, y*height);
		_, _, _, displayInfo = EJ_GetCreatureInfo(1, encounterID);
		bossButton.displayInfo = displayInfo;
		if ( displayInfo ) then
			SetPortraitTexture(bossButton.bgImage, displayInfo);
		else 
			bossButton.bgImage:SetTexture("DoesNotExist");
		end
		bossButton:Show();
		index = index + 1;
		x, y, instanceID, name, description, encounterID = EJ_GetMapEncounter(index, WorldMapFrame.fromJournal);
	end
	
	WorldMapFrame.hasBosses = index ~= 1;
	
	bossButton = _G["EJMapButton"..index];
	while bossButton do
		bossButton:Hide();
		index = index + 1;
		bossButton = _G["EJMapButton"..index];
	end
	
	WorldMapBossButtonFrame.ready = true;
	EncounterJournal_CheckQuestButtons();
end

function EncounterJournal_UpdateMapButtonPortraits()
	if ( WorldMapFrame:IsShown() ) then
		local index = 1;
		local bossButton = _G["EJMapButton"..index];
		while ( bossButton and bossButton:IsShown() ) do
			SetPortraitTexture(bossButton.bgImage, bossButton.displayInfo);
			index = index + 1;
			bossButton = _G["EJMapButton"..index];
		end
	end
end

function EncounterJournal_CheckQuestButtons()
	if not WorldMapBossButtonFrame.ready then
		return;
	end
	
	--Validate that there are no quest button intersection
	local questI, bossI = 1, 1;
	local bossButton = _G["EJMapButton"..bossI];
	local questPOI = _G["poiWorldMapPOIFrame1_"..questI];
	while bossButton and bossButton:IsShown() do
		while questPOI and questPOI:IsShown() do
			local qx,qy = questPOI:GetCenter();
			local bx,by = bossButton:GetCenter();
			if not qx or not qy or not bx or not by then
				_G["EJMapButton1"]:SetScript("OnUpdate", EncounterJournal_CheckQuestButtons);
				return;
			end
			
			local xdis = abs(bx-qx);
			local ydis = abs(by-qy);
			local disSqr = xdis*xdis + ydis*ydis;
			
			if EJ_QUEST_POI_MINDIS_SQR > disSqr then
				questPOI:SetPoint("CENTER", bossButton, "BOTTOMRIGHT",  -15, 15);
			end
			questI = questI + 1;
			questPOI = _G["poiWorldMapPOIFrame1_"..questI];
		end
		questI = 1;
		bossI = bossI + 1;
		bossButton = _G["EJMapButton"..bossI];
		questPOI = _G["poiWorldMapPOIFrame1_"..questI];
	end
	if _G["EJMapButton1"] then
		_G["EJMapButton1"]:SetScript("OnUpdate", nil);
	end
end

-- *****************************************************************************************************
-- ***** MAP TRACKING DROPDOWN
-- *****************************************************************************************************

function WorldMapTrackingOptionsDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	info.isTitle = true;
	info.text = WORLD_MAP_FILTER_TITLE;
	UIDropDownMenu_AddButton(info);
	info.isTitle = nil;
	info.disabled = nil;

	info.text = SHOW_QUEST_OBJECTIVES_ON_MAP_TEXT;
	info.value = "quests";
	info.func = WorldMapTrackingOptionsDropDown_OnClick;
	info.checked = GetCVarBool("questPOI");
	info.isNotRadio = true;
	info.keepShownOnClick = true;
	UIDropDownMenu_AddButton(info);

	local prof1, prof2, arch, fish, cook, firstAid = GetProfessions();
	if arch then
		info.text = ARCHAEOLOGY_SHOW_DIG_SITES;
		info.value = "digsites";
		info.checked = GetCVarBool("digSites");
		UIDropDownMenu_AddButton(info);
	end

	if CanTrackBattlePets() then
		info.text = SHOW_PET_BATTLES_ON_MAP_TEXT;
		info.value = "tamers";
		info.checked = GetCVarBool("showTamers");
		UIDropDownMenu_AddButton(info);
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
end

function WorldMapTrackingOptionsDropDown_OnClick(self)
	local checked = self.checked;
	local value = self.value;
	
	if (checked) then
		PlaySound("igMainMenuOptionCheckBoxOn");
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
	end
	
	if (value == "quests") then
		SetCVar("questPOI", checked and "1" or "0");
		QuestMapFrame_UpdateAll();
	elseif (value == "digsites") then
		if (checked) then
			WorldMapArchaeologyDigSites:Show();
		else
			WorldMapArchaeologyDigSites:Hide();
		end
		SetCVar("digSites", checked and "1" or "0");
		WorldMapFrame_Update();
	elseif (value == "tamers") then
		SetCVar("showTamers", checked and "1" or "0");
		WorldMapFrame_Update();
	elseif (value == "primaryProfessionsFilter" or value == "secondaryProfessionsFilter") then
		SetCVar(value, checked and "1" or "0");
		WorldMapFrame_Update();
	end
end

-- *****************************************************************************************************
-- ***** NAV BAR
-- *****************************************************************************************************

local SIBLING_MENU_DATA = { };
local SIBLING_MENU_PARENT_ID;
local SIBLING_MENU_PARENT_IS_CONTINENT;

local BROKEN_ISLES_ID = 8;

function IsMapAllowedInKioskMode(id)
	return id ~= BROKEN_ISLES_ID;
end

function WorldMapNavBar_LoadSiblings(parentID, isContinent, doSort, ...)
	if ( parentID == SIBLING_MENU_PARENT_ID ) then
		-- we already have this loaded
		return;
	end

	wipe(SIBLING_MENU_DATA);
	local count = select("#", ...);
	for i = 1, count, 2 do
		local id = select(i, ...);
		local name = select(i+1, ...);
		local allowed = true;
		if (IsKioskModeEnabled()) then
			allowed = IsMapAllowedInKioskMode(id);
		end
		if ( name and allowed ) then
			local t = { id = id, name = name };
			tinsert(SIBLING_MENU_DATA, t);
		end
	end
	if ( doSort ) then
		table.sort(SIBLING_MENU_DATA, WorldMapNavBar_SortSiblings);
	end
	SIBLING_MENU_PARENT_ID = parentID;
	SIBLING_MENU_PARENT_IS_CONTINENT = isContinent;
end

function WorldMapNavBar_SortSiblings(map1, map2)
	return map1.name < map2.name;
end

function WorldMapNavBar_OnButtonSelect(self, button)
	if ( self.data.isContinent ) then
		SetMapZoom(self.data.id);
	else
		SetMapByID(self.data.id);
	end
end

function WorldMapNavBar_SelectSibling(self, index, navBar)
	if ( SIBLING_MENU_PARENT_IS_CONTINENT ) then
		SetMapZoom(SIBLING_MENU_DATA[index].id);
	else
		SetMapByID(SIBLING_MENU_DATA[index].id);
	end
end

function WorldMapNavBar_GetSibling(self, index)
	if ( self.data.isContinent ) then
		if ( self.data.id ~= WORLDMAP_COSMIC_ID ) then
			-- storing continent index as a negative ID to prevent collision with map ID
			-- this is only used for SIBLING_MENU_PARENT_ID comparisons
			local continentID = -self.data.id;
			-- for Azeroth or Outland, add them both
			if ( self.data.id == WORLDMAP_OUTLAND_ID or self.data.id == WORLDMAP_AZEROTH_ID or self.data.id == WORLDMAP_DRAENOR_ID ) then
				WorldMapNavBar_LoadSiblings(continentID, true, true, WORLDMAP_OUTLAND_ID, GetContinentName(WORLDMAP_OUTLAND_ID), WORLDMAP_AZEROTH_ID, AZEROTH, WORLDMAP_DRAENOR_ID, GetContinentName(WORLDMAP_DRAENOR_ID));
			else
				local continentData = { GetMapContinents() };		-- mapID1, mapName1, mapID2, mapName2, ...
				-- SetMap needs index for continent so replace the IDs
				local index = 0;
				for i = 1, #continentData, 2 do
					index = index + 1;
					continentData[i] = index;
					-- this list is meant for continents on Azeroth so remove Outland
					if ( index == WORLDMAP_OUTLAND_ID or index == WORLDMAP_DRAENOR_ID ) then
						continentData[i + 1] = nil;
					end
				end
				WorldMapNavBar_LoadSiblings(continentID, true, true, unpack(continentData));
			end
		end
	else
		local parentData = self.navParent.data;
		-- if this button is right after a continent button then it's a regular zone
		if ( parentData.isContinent ) then
			-- this zone data is already sorted
			WorldMapNavBar_LoadSiblings(parentData.id, false, false, GetMapZones(parentData.id));
		else
			-- this is a "subzone", like Northshire
			WorldMapNavBar_LoadSiblings(parentData.id, false, true, GetMapSubzones(parentData.id));
		end
	end
	if ( SIBLING_MENU_DATA[index] ) then
		return SIBLING_MENU_DATA[index].name, WorldMapNavBar_SelectSibling;
	end
end

function WorldMapNavBar_Update()
	local parentData = GetMapHierarchy();
	local currentContinent = GetCurrentMapContinent();
	-- if the last parent is not a continent and we're not on the cosmic view we need to add the current continent
	local haveParentContinent = parentData[#parentData] and parentData[#parentData].isContinent;
	if ( not haveParentContinent and currentContinent ~= WORLDMAP_COSMIC_ID ) then
		local continentData = { };
		if ( currentContinent == WORLDMAP_AZEROTH_ID ) then
			continentData.name = AZEROTH;
		else
			continentData.name = GetContinentName(currentContinent);
		end
		continentData.id = currentContinent;
		continentData.isContinent = true;
		tinsert(parentData, continentData);
	elseif ( haveParentContinent ) then
		currentContinent = parentData[#parentData] and parentData[#parentData].id;
	end
	-- most continents have Azeroth as a parent
	if ( currentContinent ~= WORLDMAP_COSMIC_ID and currentContinent ~= WORLDMAP_AZEROTH_ID and currentContinent ~= WORLDMAP_OUTLAND_ID and currentContinent ~= WORLDMAP_DRAENOR_ID ) then
		local continentData = { };
		continentData.name = AZEROTH;
		continentData.id = WORLDMAP_AZEROTH_ID;
		continentData.isContinent = true;
		tinsert(parentData, continentData);		
	end

	local mapID, isContinent = GetCurrentMapAreaID();	
	-- time to add the buttons
	NavBar_Reset(WorldMapFrame.NavBar);
	for i = #parentData, 1, -1 do
		local id = parentData[i].id;
		-- might get self back as part of hierarchy in the case of dungeon maps - see Dalaran floor The Underbelly
		if ( id and id ~= mapID ) then
			local buttonData = {
				name = parentData[i].name,
				id = parentData[i].id,
				isContinent = parentData[i].isContinent,
				OnClick = WorldMapNavBar_OnButtonSelect,
				listFunc = WorldMapNavBar_GetSibling,
			}
			NavBar_AddButton(WorldMapFrame.NavBar, buttonData);
		end
	end
	-- add the current map unless it's a continent
	if ( mapID and mapID ~= -1 and not isContinent ) then
		local buttonData = {
			name = GetMapNameByID(mapID),
			id = mapID,
			isContinent = false,
			OnClick = WorldMapNavBar_OnButtonSelect,
		}
		-- only do a dropdown menu if its parent is not a continent
		if ( parentData[1] and parentData[1].isContinent ) then
			buttonData.listFunc = WorldMapNavBar_GetSibling;
		end
		NavBar_AddButton(WorldMapFrame.NavBar, buttonData);
	end
end

-- *****************************************************************************************************
-- ***** HELP PLATE STUFF
-- *****************************************************************************************************

WorldMapFrame_HelpPlate = {
	FramePos = { x = 4,	y = -40 },
	FrameSize = { width = 985, height = 500	},
	[1] = { ButtonPos = { x = 350,	y = -180 }, HighLightBox = { x = 0, y = -30, width = 695, height = 470 },		ToolTipDir = "DOWN",		ToolTipText = WORLD_MAP_TUTORIAL1 },
	[2] = { ButtonPos = { x = 350,	y = 16 }, HighLightBox = { x = 50, y = 16, width = 645, height = 44 },	ToolTipDir = "DOWN",	ToolTipText = WORLD_MAP_TUTORIAL4 },
}

function WorldMapFrame_ToggleTutorial()
	local helpPlate = WorldMapFrame_HelpPlate;
	
	if ( QuestMapFrame:IsShown() ) then
		helpPlate[3] = { ButtonPos = { x = 810,	y = -180 }, HighLightBox = { x = 700, y = -30, width = 285, height = 470 },	ToolTipDir = "DOWN",	ToolTipText = WORLD_MAP_TUTORIAL2 };
		helpPlate[4] = { ButtonPos = { x = 810,	y = 16 }, HighLightBox = { x = 700, y = 16, width = 285, height = 44 },	ToolTipDir = "DOWN",	ToolTipText = WORLD_MAP_TUTORIAL3 };
	else
		helpPlate[3] = nil;
		helpPlate[4] = nil;
	end
		
	if ( helpPlate and not HelpPlate_IsShowing(helpPlate) and WorldFrame:IsShown()) then
		HelpPlate_Show( helpPlate, WorldMapFrame, WorldMapFrame.MainHelpButton, true );
		SetCVarBitfield( "closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true );
	else
		HelpPlate_Hide(true);
	end
end
