NUM_WORLDMAP_POIS = 0;
NUM_WORLDMAP_WORLDEFFECT_POIS = 0;
NUM_WORLDMAP_SCENARIO_POIS = 0;
NUM_WORLDMAP_GRAVEYARDS = 0;
NUM_WORLDMAP_OVERLAYS = 0;
NUM_WORLDMAP_FLAGS = 4;
NUM_WORLDMAP_DEBUG_ZONEMAP = 0;
NUM_WORLDMAP_DEBUG_OBJECTS = 0;
WORLDMAP_COSMIC_ID = -1;
WORLDMAP_WORLD_ID = 0;
WORLDMAP_OUTLAND_ID = 3;
WORLDMAP_MAELSTROM_ID = 5;
MAELSTROM_ZONES_ID = { TheMaelstrom = 737, Deepholm = 640, Kezan = 605, TheLostIsles = 544 };
MAELSTROM_ZONES_LEVELS = { 
				TheMaelstrom = {minLevel = 0, maxLevel = 0}, 
				Deepholm = {minLevel = 82, maxLevel = 83, petMinLevel= 22, petMaxLevel = 23}, 
				Kezan = {minLevel = 1, maxLevel = 5}, 
				TheLostIsles = {minLevel = 5, maxLevel = 12} };
WORLDMAP_WINTERGRASP_ID = 501;
WORLDMAP_WINTERGRASP_POI_AREAID = 4197;
QUESTFRAME_MINHEIGHT = 34;
QUESTFRAME_PADDING = 19;
WORLDMAP_POI_FRAMELEVEL = 100;		-- needs to be one the highest frames in the MEDIUM strata
WORLDMAP_WINDOWED_SIZE = 0.573;		-- size corresponds to ratio value
WORLDMAP_QUESTLIST_SIZE = 0.691;
WORLDMAP_FULLMAP_SIZE = 1.0;
local EJ_QUEST_POI_MINDIS_SQR = 2500;

local WORLDMAP_POI_MIN_X = 12;
local WORLDMAP_POI_MIN_Y = -12;
local WORLDMAP_POI_MAX_X;			-- changes based on current scale, see WorldMapFrame_SetPOIMaxBounds
local WORLDMAP_POI_MAX_Y;			-- changes based on current scale, see WorldMapFrame_SetPOIMaxBounds

local PLAYER_ARROW_SIZE_WINDOW = 40;
local PLAYER_ARROW_SIZE_FULL_WITH_QUESTS = 38;
local PLAYER_ARROW_SIZE_FULL_NO_QUESTS = 28;

BAD_BOY_UNITS = {};
BAD_BOY_COUNT = 0;

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
};
VEHICLE_TEXTURES["Minecart Red"] = {
	"Interface\\Minimap\\Vehicle-SilvershardMines-MineCartRed",
	"Interface\\Minimap\\Vehicle-SilvershardMines-MineCartRed",
	width=64,
	height=64,
};
VEHICLE_TEXTURES["Minecart Blue"] = {
	"Interface\\Minimap\\Vehicle-SilvershardMines-MineCartBlue",
	"Interface\\Minimap\\Vehicle-SilvershardMines-MineCartBlue",
	width=64,
	height=64,
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

WORLDMAP_DEBUG_ICON_INFO = {};
WORLDMAP_DEBUG_ICON_INFO[1] = { size =  6, r = 0.0, g = 1.0, b = 0.0 };
WORLDMAP_DEBUG_ICON_INFO[2] = { size = 16, r = 1.0, g = 1.0, b = 0.5 };
WORLDMAP_DEBUG_ICON_INFO[3] = { size = 32, r = 1.0, g = 1.0, b = 0.5 };
WORLDMAP_DEBUG_ICON_INFO[4] = { size = 64, r = 1.0, g = 0.6, b = 0.0 };

WORLDMAP_SETTINGS = {
	opacity = 0,
	locked = true,
	selectedQuest = nil,
	superTrackedQuestID = 0,
	size = WORLDMAP_QUESTLIST_SIZE
};

local WorldEffectPOITooltips = {};
local ScenarioPOITooltips = {};

function WorldMapFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("WORLD_MAP_UPDATE");
	self:RegisterEvent("CLOSE_WORLD_MAP");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("GROUP_ROSTER_UPDATE");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("QUEST_LOG_UPDATE");
	self:RegisterEvent("QUEST_POI_UPDATE");
	self:RegisterEvent("SKILL_LINES_CHANGED");
	self:RegisterEvent("REQUEST_CEMETERY_LIST_RESPONSE");
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE");
	self:RegisterEvent("ARTIFACT_DIG_SITE_UPDATED");
	
	self:SetClampRectInsets(0, 0, 0, -60);				-- don't overlap the xp/rep bars
	self.poiHighlight = nil;
	self.areaName = nil;
	WorldMapFrameTexture18:SetVertexColor(0, 0, 0);		-- this texture just needs to be a black line
	WorldMapFrame_Update();

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
	UIDropDownMenu_Initialize(WorldMapZoneMinimapDropDown, WorldMapZoneMinimapDropDown_Initialize);
	UIDropDownMenu_SetWidth(WorldMapZoneMinimapDropDown, 150);
	WorldMapZoneMinimapDropDown_Update();
	WorldMapLevelDropDown_Update();

	-- font stuff for objectives text
	local refFrame = WorldMapFrame_GetQuestFrame(0);
	local _, fontHeight = refFrame.objectives:GetFont();
	refFrame.lineSpacing = refFrame.objectives:GetSpacing();
	refFrame.lineHeight = fontHeight + refFrame.lineSpacing;
	
	WorldMapFrame_ResetFrameLevels();
	WorldMapDetailFrame:SetScale(WORLDMAP_QUESTLIST_SIZE);
	WorldMapButton:SetScale(WORLDMAP_QUESTLIST_SIZE);
	WorldMapFrame_SetPOIMaxBounds();
	WorldMapQuestDetailScrollChildFrame:SetScale(0.9);
	WorldMapQuestRewardScrollChildFrame:SetScale(0.9);
	WorldMapFrame.numQuests = 0;
	WatchFrame.showObjectives = WorldMapQuestShowObjectives:GetChecked();
	WorldMapPOIFrame.allowBlobTooltip = true;
	-- scrollframes
	WorldMapQuestDetailScrollFrame.scrollBarHideable = true;
	WorldMapQuestRewardScrollFrame.scrollBarHideable = true;
	ScrollBar_AdjustAnchors(WorldMapQuestDetailScrollFrameScrollBar, 1, -2);
	WorldMapQuestDetailScrollFrameScrollBarTrack:SetAlpha(0.4);
	ScrollBar_AdjustAnchors(WorldMapQuestRewardScrollFrameScrollBar, 1, -2);
	WorldMapQuestRewardScrollFrameScrollBarTrack:SetAlpha(0.4);
end

function WorldMapFrame_OnShow(self)
	if ( WORLDMAP_SETTINGS.size ~= WORLDMAP_WINDOWED_SIZE ) then
		SetupFullscreenScale(self);
		WorldMap_LoadTextures();
		-- pet battle level size adjustment
		WorldMapFrameAreaPetLevels:SetFontObject("TextStatusBarTextLarge")
		if ( not WatchFrame.showObjectives and WORLDMAP_SETTINGS.size ~= WORLDMAP_FULLMAP_SIZE ) then
			WorldMapFrame_SetFullMapView();
		end
	else
		-- pet battle level size adjustment
		WorldMapFrameAreaPetLevels:SetFontObject("SubZoneTextFont");
	end

	-- Save the superTrackedQuestID to restore on map close
	WORLDMAP_SETTINGS.superTrackedQuestID = GetSuperTrackedQuestID();

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
end

function WorldMapFrame_OnHide(self)
	if ( OpacityFrame:IsShown() and OpacityFrame.saveOpacityFunc and OpacityFrame.saveOpacityFunc == WorldMapFrame_SaveOpacity ) then
		WorldMapFrame_SaveOpacity();
		OpacityFrame.saveOpacityFunc = nil;
		OpacityFrame:Hide();
	end
	
	self.fromJournal = false;
	
	UpdateMicroButtons();
	CloseDropDownMenus();
	PlaySound("igQuestLogClose");
	WorldMap_ClearTextures();
	WorldMapPing.Ping:Stop();
	if ( self.showOnHide ) then
		ShowUIPanel(self.showOnHide);
		self.showOnHide = nil;
	end
	-- forces WatchFrame event via the WORLD_MAP_UPDATE event, needed to restore the POIs in the tracker to the current zone
	if (not WorldMapFrame.toggling) then
		SetMapToCurrentZone();
	end
	CancelEmote();
	if ( WORLDMAP_SETTINGS.superTrackedQuestID > 0 ) then
		SetSuperTrackedQuestID(WORLDMAP_SETTINGS.superTrackedQuestID);
		QuestPOI_SelectButtonByQuestId("WatchFrameLines", WORLDMAP_SETTINGS.superTrackedQuestID, true);
		WORLDMAP_SETTINGS.superTrackedQuestID = 0;
	end
	self.mapID = nil;
end

function WorldMapFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( self:IsShown() ) then
			HideUIPanel(WorldMapFrame);
		end
	elseif ( event == "WORLD_MAP_UPDATE" or event == "REQUEST_CEMETERY_LIST_RESPONSE" ) then
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
		end
	elseif ( event == "ARTIFACT_DIG_SITE_UPDATED" ) then
		if ( self:IsShown() ) then
			RefreshWorldMap();
		end
	elseif ( event == "CLOSE_WORLD_MAP" ) then
		HideUIPanel(self);
	elseif ( event == "VARIABLES_LOADED" ) then
		WorldMapZoneMinimapDropDown_Update();
		WORLDMAP_SETTINGS.locked = GetCVarBool("lockedWorldMap");
		WORLDMAP_SETTINGS.opacity = (tonumber(GetCVar("worldMapOpacity")));
		if ( GetCVarBool("miniWorldMap") ) then
			WorldMap_ToggleSizeDown();
		else
			WorldMapBlobFrame:SetScale(WORLDMAP_QUESTLIST_SIZE);
			ScenarioPOIFrame:SetScale(WORLDMAP_FULLMAP_SIZE);	--If we ever need to add objectives on the map itself we should adjust this value
		end
		WorldMapQuestShowObjectives:SetChecked(GetCVarBool("questPOI"));
		WorldMapQuestShowObjectives_Toggle();
	elseif ( event == "GROUP_ROSTER_UPDATE" ) then
		if ( self:IsShown() ) then
			WorldMapFrame_UpdateUnits("WorldMapRaid", "WorldMapParty");
		end
	elseif ( event == "DISPLAY_SIZE_CHANGED" ) then
		WorldMapQuestShowObjectives_AdjustPosition();
		if ( WatchFrame.showObjectives and self:IsShown() ) then
			WorldMapFrame_UpdateQuests();
		end
	elseif ( ( event == "QUEST_LOG_UPDATE" or event == "QUEST_POI_UPDATE" ) and self:IsShown() ) then
		WorldMapFrame_DisplayQuests();
		WorldMapQuestFrame_UpdateMouseOver();
	elseif  ( event == "SKILL_LINES_CHANGED" ) then
		local _, _, arch = GetProfessions();
		if arch then
			WorldMapShowDigSites:Show();
			local showDig = GetCVarBool("digSites");
			WorldMapShowDigSites:SetChecked(showDig);
			if showDig then
				WorldMapArchaeologyDigSites:Show();
			else
				WorldMapArchaeologyDigSites:Hide();
			end
		else
			WorldMapShowDigSites:Hide();
		end
	elseif ( event == "UNIT_PORTRAIT_UPDATE" ) then
		EncounterJournal_UpdateMapButtonPortraits();
	end
end

function WorldMapFrame_OnUpdate(self)
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
	end
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
				-- local x1, x2, y1, y2 = GetWorldEffectTextureCoords(textureIndex);
				-- _G[worldEventPOIName.."Texture"]:SetTexCoord(x1, x2, y1, y2);
				-- x = x * WorldMapButton:GetWidth();
				-- y = -y * WorldMapButton:GetHeight();
				-- worldEventPOI:SetPoint("CENTER", "WorldMapButton", "TOPLEFT", x, y );
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
	if((WatchFrame.showObjectives == true) and (scenarioIconInfo ~= nil))then
		for _, info  in next, scenarioIconInfo do
		
			--textureIndex, x, y, name
			local textureIndex = info.index;
			local x = info.x;
			local y = info.y;
			local name = info.description;
			
			local scenarioPOIName = "WorldMapFrameScenarioPOI"..scenarioIconCount;
			local scenarioPOI = _G[scenarioPOIName];
			
			local x1, x2, y1, y2 = GetWorldEffectTextureCoords(textureIndex);
			_G[scenarioPOIName.."Texture"]:SetTexCoord(x1, x2, y1, y2);
			x = x * WorldMapButton:GetWidth();
			y = -y * WorldMapButton:GetHeight();
			scenarioPOI:SetPoint("CENTER", "WorldMapButton", "TOPLEFT", x, y );
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
		else
			-- Temporary Hack (Temporary meaning 6 yrs, haha)
			mapName = "World";
			OutlandButton:Hide();
			AzerothButton:Hide();
		end
		DeepholmButton:Hide();
		KezanButton:Hide();
		LostIslesButton:Hide();
		TheMaelstromButton:Hide();
	else
		OutlandButton:Hide();
		AzerothButton:Hide();
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

	-- Enable/Disable zoom out button
	if ( IsZoomOutAvailable() ) then
		WorldMapZoomOutButton:Enable();
	else
		WorldMapZoomOutButton:Disable();
	end

	-- Setup the POI's
	local numPOIs = GetNumMapLandmarks();
	if ( NUM_WORLDMAP_POIS < numPOIs ) then
		for i=NUM_WORLDMAP_POIS+1, numPOIs do
			WorldMap_CreatePOI(i);
		end
		NUM_WORLDMAP_POIS = numPOIs;
	end
	local numGraveyards = 0;
	local currentGraveyard = GetCemeteryPreference();
	for i=1, NUM_WORLDMAP_POIS do
		local worldMapPOIName = "WorldMapFramePOI"..i;
		local worldMapPOI = _G[worldMapPOIName];
		if ( i <= numPOIs ) then
			local name, description, textureIndex, x, y, mapLinkID, inBattleMap, graveyardID, areaID, poiID = GetMapLandmarkInfo(i);
			if( (GetCurrentMapAreaID() ~= WORLDMAP_WINTERGRASP_ID) and (areaID == WORLDMAP_WINTERGRASP_POI_AREAID) ) then
				worldMapPOI:Hide();
			else
				x = x * WorldMapButton:GetWidth();
				y = -y * WorldMapButton:GetHeight();
				worldMapPOI:SetPoint("CENTER", "WorldMapButton", "TOPLEFT", x, y );
				if ( WorldMap_IsSpecialPOI(poiID) ) then	--We have special handling for Isle of the Thunder King
					WorldMap_HandleSpecialPOI(worldMapPOI, poiID);
				else
					WorldMap_ResetPOI(worldMapPOI);

					local x1, x2, y1, y2 = GetPOITextureCoords(textureIndex);
					_G[worldMapPOIName.."Texture"]:SetTexCoord(x1, x2, y1, y2);
					worldMapPOI.name = name;
					worldMapPOI.description = description;
					worldMapPOI.mapLinkID = mapLinkID;
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
	
	WorldMap_DrawWorldEffects();

	-- Setup the overlays
	local textureCount = 0;
	for i=1, GetNumMapOverlays() do
		local textureName, textureWidth, textureHeight, offsetX, offsetY = GetMapOverlayInfo(i);
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
					texture:Show();
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
		local ZONEMAP_SIZE = 32;
		local mapW = WorldMapDetailFrame:GetWidth();
		local mapH = WorldMapDetailFrame:GetHeight();
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
						texture:SetTexture(1, 1, 1);
						WorldMapDetailFrame.zoneMap[numDebugZoneMapTextures] = texture;
					end

					texture:SetVertexColor(r, g, b, a);
					minX = minX * mapW;
					minY = -minY * mapH;
					texture:SetPoint("TOPLEFT", "WorldMapDetailFrame", "TOPLEFT", minX, minY);
					maxX = maxX * mapW;
					maxY = -maxY * mapH;
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
		if ( (x ~= 0 or y ~= 0) and (size > 1 or GetCurrentMapZone() ~= WORLDMAP_WORLD_ID) ) then
			textureCount = textureCount + 1;
			local frame = _G["WorldMapDebugObject"..textureCount];
			frame.index = i;
			frame.name = name;

			local info = WORLDMAP_DEBUG_ICON_INFO[size];
			if ( GetCurrentMapZone() == WORLDMAP_WORLD_ID ) then
				frame:SetWidth(info.size / 2);
				frame:SetHeight(info.size / 2);
			else
				frame:SetWidth(info.size);
				frame:SetHeight(info.size);
			end
			frame.texture:SetVertexColor(info.r, info.g, info.b, 0.5);

			x = x * WorldMapDetailFrame:GetWidth();
			y = -y * WorldMapDetailFrame:GetHeight();
			frame:SetFrameLevel(baseLevel + (4 - size));
			frame:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", x, y);
			frame:Show();
		end
	end
	for i=textureCount+1, NUM_WORLDMAP_DEBUG_OBJECTS do
		_G["WorldMapDebugObject"..i]:Hide();
	end
	
	EncounterJournal_AddMapButtons();
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

function WorldMapPOI_OnEnter(self)
	WorldMapFrame.poiHighlight = 1;
	if ( self.specialPOIInfo and self.specialPOIInfo.onEnter ) then
		self.specialPOIInfo.onEnter(self, self.specialPOIInfo);
	else
		if ( self.description and strlen(self.description) > 0 ) then
			WorldMapFrameAreaLabel:SetText(self.name);
			WorldMapFrameAreaDescription:SetText(self.description);
		else
			WorldMapFrameAreaLabel:SetText(self.name);
			WorldMapFrameAreaDescription:SetText("");
			-- need localization
			if ( self.graveyard ) then
				WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");
				if ( self.graveyard == GetCemeteryPreference() ) then
					WorldMapTooltip:SetText(GRAVEYARD_SELECTED);
					WorldMapTooltip:AddLine(GRAVEYARD_SELECTED_TOOLTIP, 1, 1, 1, 1);
					WorldMapTooltip:Show();
				else
					WorldMapTooltip:SetText(GRAVEYARD_ELIGIBLE);
					WorldMapTooltip:AddLine(GRAVEYARD_ELIGIBLE_TOOLTIP, 1, 1, 1, 1);
					WorldMapTooltip:Show();
				end
			end
		end
	end
end

function WorldMapPOI_OnLeave(self)
	WorldMapFrame.poiHighlight = nil;
	if ( self.specialPOIInfo and self.specialPOIInfo.onLeave ) then
		self.specialPOIInfo.onLeave(self, self.specialPOIInfo);
	else
		WorldMapFrameAreaLabel:SetText(WorldMapFrame.areaName);
		WorldMapFrameAreaDescription:SetText("");
		WorldMapTooltip:Hide();
	end
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
		WorldMapTooltip.WE_using = true;
	end
end

function WorldEffectPOI_OnLeave()
	WorldMapFrame.poiHighlight = nil;
	WorldMapFrameAreaLabel:SetText(WorldMapFrame.areaName);
	WorldMapFrameAreaDescription:SetText("");
	WorldMapTooltip:Hide();
	WorldMapTooltip.WE_using = false;
end

function ScenarioPOI_OnEnter(self)
	if(ScenarioPOITooltips[self.name] ~= nil) then
		WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");
		WorldMapTooltip:SetText(ScenarioPOITooltips[self.name]);
		WorldMapTooltip:Show();
		WorldMapTooltip.WE_using = true;
	end
end

function ScenarioPOI_OnLeave()
	WorldMapFrame.poiHighlight = nil;
	WorldMapFrameAreaLabel:SetText(WorldMapFrame.areaName);
	WorldMapFrameAreaDescription:SetText("");
	WorldMapTooltip:Hide();
	WorldMapTooltip.WE_using = false;
end

function WorldMapPOI_OnClick(self, button)
	if ( self.mapLinkID ) then
		ClickLandmark(self.mapLinkID);
	elseif ( self.graveyard ) then
		SetCemeteryPreference(self.graveyard);
		WorldMapFrame_Update();
	else
		WorldMapButton_OnClick(WorldMapButton, button);
	end
end

function WorldMap_CreatePOI(index)
	local button = CreateFrame("Button", "WorldMapFramePOI"..index, WorldMapButton);
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	button:SetScript("OnEnter", WorldMapPOI_OnEnter);
	button:SetScript("OnLeave", WorldMapPOI_OnLeave);
	button:SetScript("OnClick", WorldMapPOI_OnClick);

	button.Texture = button:CreateTexture(button:GetName().."Texture", "BACKGROUND");

	WorldMap_ResetPOI(button);
end

function WorldMap_ResetPOI(button)
	button:SetWidth(32);
	button:SetHeight(32);
	button.Texture:SetWidth(16);
	button.Texture:SetHeight(16);
	button.Texture:SetPoint("CENTER", 0, 0);
	button.Texture:SetTexture("Interface\\Minimap\\POIIcons");

	button.specialPOIInfo = nil;
end

function WorldMap_CreateWorldEffectPOI(index)
	local button = CreateFrame("Button", "WorldMapFrameWorldEffectPOI"..index, WorldMapButton);
	button:SetWidth(32);
	button:SetHeight(32);
	button:SetScript("OnEnter", WorldEffectPOI_OnEnter);
	button:SetScript("OnLeave", WorldEffectPOI_OnLeave);
	
	local texture = button:CreateTexture(button:GetName().."Texture", "BACKGROUND");
	texture:SetWidth(16);
	texture:SetHeight(16);
	texture:SetPoint("CENTER", 0, 0);
	texture:SetTexture("Interface\\Minimap\\OBJECTICONS");
end

function WorldMap_CreateScenarioPOI(index)
	local button = CreateFrame("Button", "WorldMapFrameScenarioPOI"..index, WorldMapButton);
	button:SetWidth(32);
	button:SetHeight(32);
	button:SetScript("OnEnter", ScenarioPOI_OnEnter);
	button:SetScript("OnLeave", ScenarioPOI_OnLeave);
	
	local texture = button:CreateTexture(button:GetName().."Texture", "BACKGROUND");
	texture:SetWidth(16);
	texture:SetHeight(16);
	texture:SetPoint("CENTER", 0, 0);
	texture:SetTexture("Interface\\Minimap\\OBJECTICONS");
end

function WorldMap_GetGraveyardButton(index)
	-- everything here is temp
	local frameName = "WorldMapFrameGraveyard"..index;
	local button = _G[frameName];
	if ( not button ) then
		button = CreateFrame("Button", frameName, WorldMapButton);
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

function WorldMapContinentsDropDown_Update()
	UIDropDownMenu_Initialize(WorldMapContinentDropDown, WorldMapContinentsDropDown_Initialize);
	UIDropDownMenu_SetWidth(WorldMapContinentDropDown, 130);

	if ( (GetCurrentMapContinent() == WORLDMAP_WORLD_ID) or (GetCurrentMapContinent() == WORLDMAP_COSMIC_ID) ) then
		UIDropDownMenu_ClearAll(WorldMapContinentDropDown);
	else
		UIDropDownMenu_SetSelectedID(WorldMapContinentDropDown,GetCurrentMapContinent());
	end
end

function WorldMapContinentsDropDown_Initialize()
	WorldMapFrame_LoadContinents(GetMapContinents());
end

function WorldMapFrame_LoadContinents(...)
	local info = UIDropDownMenu_CreateInfo();
	for i=1, select("#", ...), 1 do
		info.text = select(i, ...);
		info.func = WorldMapContinentButton_OnClick;
		info.checked = nil;
		UIDropDownMenu_AddButton(info);
	end
end

function WorldMapZoneDropDown_Update()
	UIDropDownMenu_Initialize(WorldMapZoneDropDown, WorldMapZoneDropDown_Initialize);
	UIDropDownMenu_SetWidth(WorldMapZoneDropDown, 130);

	if ( (GetCurrentMapContinent() == WORLDMAP_WORLD_ID) or (GetCurrentMapContinent() == WORLDMAP_COSMIC_ID) ) then
		UIDropDownMenu_ClearAll(WorldMapZoneDropDown);
	else
		UIDropDownMenu_SetSelectedID(WorldMapZoneDropDown, GetCurrentMapZone());
	end
end

function WorldMapZoneDropDown_Initialize()
	WorldMapFrame_LoadZones(GetMapZones(GetCurrentMapContinent()));
end

function WorldMapFrame_LoadZones(...)
	local info = UIDropDownMenu_CreateInfo();
	for i=1, select("#", ...), 1 do
		info.text = select(i, ...);
		info.func = WorldMapZoneButton_OnClick;
		info.checked = nil;
		UIDropDownMenu_AddButton(info);
	end
end

function WorldMapLevelDropDown_Update()
	UIDropDownMenu_Initialize(WorldMapLevelDropDown, WorldMapLevelDropDown_Initialize);
	UIDropDownMenu_SetWidth(WorldMapLevelDropDown, 130);

	if ( (GetNumDungeonMapLevels() == 0) ) then
		UIDropDownMenu_ClearAll(WorldMapLevelDropDown);
		WorldMapLevelDropDown:Hide();
		WorldMapLevelUpButton:Hide();
		WorldMapLevelDownButton:Hide();
	else
		local floorMapCount, firstFloor = GetNumDungeonMapLevels();
		local levelID = GetCurrentMapDungeonLevel() - firstFloor + 1;

		UIDropDownMenu_SetSelectedID(WorldMapLevelDropDown, levelID);
		WorldMapLevelDropDown:Show();
		if ( WORLDMAP_SETTINGS.size ~= WORLDMAP_WINDOWED_SIZE ) then
			WorldMapLevelUpButton:Show();
			WorldMapLevelDownButton:Show();
		end
	end
end

function WorldMapLevelDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	local level = GetCurrentMapDungeonLevel();
	
	local mapname = strupper(GetMapInfo() or "");
	
	local usesTerrainMap = DungeonUsesTerrainMap();
	local floorMapCount, firstFloor = GetNumDungeonMapLevels();
	local _, _, _, isMicroDungeon = GetMapInfo();
	
	local lastFloor = firstFloor + floorMapCount - 1;
	
	for i=firstFloor, lastFloor do
		local floorNum = i;
		if (usesTerrainMap) then
			floorNum = i - 1;
		end

		local floorname =_G["DUNGEON_FLOOR_" .. mapname .. floorNum];
		info.text = floorname or string.format(FLOOR_NUMBER, i - firstFloor + 1);
		info.func = WorldMapLevelButton_OnClick;
		info.checked = (i == level);
		UIDropDownMenu_AddButton(info);
	end
end

function WorldMapLevelButton_OnClick(self)
	UIDropDownMenu_SetSelectedID(WorldMapLevelDropDown, self:GetID());

	local floorMapCount, firstFloor = GetNumDungeonMapLevels();
	local level = firstFloor + self:GetID() - 1;
	
	SetDungeonMapLevel(level);
end

function WorldMapLevelUp_OnClick(self)
	CloseDropDownMenus();
	local currMapLevel = GetCurrentMapDungeonLevel();
	SetDungeonMapLevel(currMapLevel - 1);
	local newMapLevel = GetCurrentMapDungeonLevel();
	if ( currMapLevel ~= newMapLevel ) then
		local floorMapCount, firstFloor = GetNumDungeonMapLevels();
		UIDropDownMenu_SetSelectedID(WorldMapLevelDropDown, newMapLevel - firstFloor + 1);
	end
	PlaySound("UChatScrollButton");
end

function WorldMapLevelDown_OnClick(self)
	CloseDropDownMenus();
	local currMapLevel = GetCurrentMapDungeonLevel();
	SetDungeonMapLevel(currMapLevel + 1);
	local newMapLevel = GetCurrentMapDungeonLevel();
	if ( currMapLevel ~= newMapLevel ) then
		local floorMapCount, firstFloor = GetNumDungeonMapLevels();
		UIDropDownMenu_SetSelectedID(WorldMapLevelDropDown, newMapLevel - firstFloor + 1);
	end
	PlaySound("UChatScrollButton");
end

function WorldMapContinentButton_OnClick(self)
	UIDropDownMenu_SetSelectedID(WorldMapContinentDropDown, self:GetID());
	SetMapZoom(self:GetID());
end

function WorldMapZoneButton_OnClick(self)
	UIDropDownMenu_SetSelectedID(WorldMapZoneDropDown, self:GetID());
	SetMapZoom(GetCurrentMapContinent(), self:GetID());
end

function WorldMapZoomOutButton_OnClick()
	PlaySound("igMainMenuOptionCheckBoxOn");
	WorldMapTooltip:Hide();
	
	-- check if code needs to zoom out before going to the continent map
	if ( ZoomOut() ~= nil ) then
		return;
	elseif ( GetCurrentMapZone() ~= WORLDMAP_WORLD_ID ) then
		SetMapZoom(GetCurrentMapContinent());
	elseif ( GetCurrentMapContinent() == WORLDMAP_WORLD_ID ) then
		SetMapZoom(WORLDMAP_COSMIC_ID);
	elseif ( GetCurrentMapContinent() == WORLDMAP_OUTLAND_ID ) then
		SetMapZoom(WORLDMAP_COSMIC_ID);
	else
		SetMapZoom(WORLDMAP_WORLD_ID);
	end
end

function WorldMapZoneMinimapDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	local value = GetCVar("showBattlefieldMinimap");

	info.value = "0";
	info.text = WorldMapZoneMinimapDropDown_GetText(info.value);
	info.func = WorldMapZoneMinimapDropDown_OnClick;
	if ( value == info.value ) then
		info.checked = 1;
		UIDropDownMenu_SetText(WorldMapZoneMinimapDropDown, info.text);
	else
		info.checked = nil;
	end
	UIDropDownMenu_AddButton(info);

	info.value = "1";
	info.text = WorldMapZoneMinimapDropDown_GetText(info.value);
	info.func = WorldMapZoneMinimapDropDown_OnClick;
	if ( value == info.value ) then
		info.checked = 1;
		UIDropDownMenu_SetText(WorldMapZoneMinimapDropDown, info.text);
	else
		info.checked = nil;
	end
	UIDropDownMenu_AddButton(info);

	info.value = "2";
	info.text = WorldMapZoneMinimapDropDown_GetText(info.value);
	info.func = WorldMapZoneMinimapDropDown_OnClick;
	if ( value == info.value ) then
		info.checked = 1;
		UIDropDownMenu_SetText(WorldMapZoneMinimapDropDown, info.text);
	else
		info.checked = nil;
	end
	UIDropDownMenu_AddButton(info);
end

function WorldMapZoneMinimapDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(WorldMapZoneMinimapDropDown, self.value);
	SetCVar("showBattlefieldMinimap", self.value);

	if ( WorldStateFrame_CanShowBattlefieldMinimap() ) then
		if ( not BattlefieldMinimap ) then
			BattlefieldMinimap_LoadUI();
		end
		BattlefieldMinimap:Show();
	else
		if ( BattlefieldMinimap ) then
			BattlefieldMinimap:Hide();
		end
	end
end

function WorldMapZoneMinimapDropDown_GetText(value)
	if ( value == "0" ) then
		return BATTLEFIELD_MINIMAP_SHOW_NEVER;
	end
	if ( value == "1" ) then
		return BATTLEFIELD_MINIMAP_SHOW_BATTLEGROUNDS;
	end
	if ( value == "2" ) then
		return BATTLEFIELD_MINIMAP_SHOW_ALWAYS;
	end

	return nil;
end

function WorldMapZoneMinimapDropDown_Update()
	UIDropDownMenu_SetSelectedValue(WorldMapZoneMinimapDropDown, GetCVar("showBattlefieldMinimap"));
	UIDropDownMenu_SetText(WorldMapZoneMinimapDropDown, WorldMapZoneMinimapDropDown_GetText(GetCVar("showBattlefieldMinimap")));
end

function WorldMapButton_OnClick(button, mouseButton)
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
		ToggleFrame(WorldMapFrame);
	end
end

local BLIP_TEX_COORDS = {
["WARRIOR"] = { 0, 0.125, 0, 0.25 },
["PALADIN"] = { 0.125, 0.25, 0, 0.25 },
["HUNTER"] = { 0.25, 0.375, 0, 0.25 },
["ROGUE"] = { 0.375, 0.5, 0, 0.25 },
["PRIEST"] = { 0.5, 0.625, 0, 0.25 },
["DEATHKNIGHT"] = { 0.625, 0.75, 0, 0.25 },
["SHAMAN"] = { 0.75, 0.875, 0, 0.25 },
["MAGE"] = { 0.875, 1, 0, 0.25 },
["WARLOCK"] = { 0, 0.125, 0.25, 0.5 },
["DRUID"] = { 0.25, 0.375, 0.25, 0.5 },
["MONK"] = { 0.125, 0.25, 0.25, 0.5 }
}

local BLIP_RAID_Y_OFFSET = 0.5;

function WorldMapButton_OnUpdate(self, elapsed)
	local x, y = GetCursorPosition();
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
	end
	
	WorldMapFrameAreaPetLevels:SetText(""); --make sure pet level is cleared
	
	WorldMapFrame.areaName = name;
	if ( not WorldMapFrame.poiHighlight ) then
		if ( WorldMapFrame.maelstromZoneText ) then
			WorldMapFrameAreaLabel:SetText(WorldMapFrame.maelstromZoneText);
			name = WorldMapFrame.maelstromZoneText;
			minLevel = WorldMapFrame.minLevel;
			maxLevel = WorldMapFrame.maxLevel;
			petMinLevel = WorldMapFrame.petMinLevel;
			petMaxLevel = WorldMapFrame.petMaxLevel;
		else
			WorldMapFrameAreaLabel:SetText(name);
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
				WorldMapFrameAreaLabel:SetText(WorldMapFrameAreaLabel:GetText()..color.." ("..minLevel.."-"..maxLevel..")");
			else
				WorldMapFrameAreaLabel:SetText(WorldMapFrameAreaLabel:GetText()..color.." ("..maxLevel..")");
			end
		end
		local _, _, _, _, locked = C_PetJournal.GetPetLoadOutInfo(1);
		if (not locked) then --don't show pet levels for people who haven't unlocked battle petting
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
					WorldMapFrameAreaPetLevels:SetText(WORLD_MAP_WILDBATTLEPET_LEVEL..color.."("..petMinLevel.."-"..petMaxLevel..")");
				else
					WorldMapFrameAreaPetLevels:SetText(WORLD_MAP_WILDBATTLEPET_LEVEL..color.."("..petMaxLevel..")");
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
	--Position player
	local playerX, playerY = GetPlayerMapPosition("player");
	if ( (playerX == 0 and playerY == 0) ) then
		WorldMapPlayerLower:Hide();
		WorldMapPlayerUpper:Hide();
	else
		playerX = playerX * WorldMapDetailFrame:GetWidth();
		playerY = -playerY * WorldMapDetailFrame:GetHeight();

		-- Position clear button to detect mouseovers
		WorldMapPlayerLower:Show();
		WorldMapPlayerUpper:Show();
		WorldMapPlayerLower:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", playerX, playerY);
		WorldMapPlayerUpper:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", playerX, playerY);
		UpdateWorldMapArrow(WorldMapPlayerLower.icon);
		UpdateWorldMapArrow(WorldMapPlayerUpper.icon);
		WorldMapPing:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", playerX, playerY);
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
				partyX = partyX * WorldMapDetailFrame:GetWidth();
				partyY = -partyY * WorldMapDetailFrame:GetHeight();
				partyMemberFrame:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", partyX, partyY);
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
				partyX = partyX * WorldMapDetailFrame:GetWidth();
				partyY = -partyY * WorldMapDetailFrame:GetHeight();
				partyMemberFrame:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", partyX, partyY);
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
	if ( GetCurrentMapContinent() == WORLDMAP_WORLD_ID or (GetCurrentMapContinent() ~= -1 and GetCurrentMapZone() == 0) ) then
		-- Hide vehicles on the worldmap and continent maps
		numVehicles = 0;
	else
		numVehicles = GetNumBattlefieldVehicles();
	end
	local totalVehicles = #MAP_VEHICLES;
	local index = 0;
	for i=1, numVehicles do
		if (i > totalVehicles) then
			local vehicleName = "WorldMapVehicles"..i;
			MAP_VEHICLES[i] = CreateFrame("FRAME", vehicleName, WorldMapButton, "WorldMapVehicleTemplate");
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

local WORLDMAP_TEXTURES_TO_LOAD = {
	{	
		name="WorldMapFrameTexture1", 
		file="Interface\\WorldMap\\UI-WorldMap-Top1",
	},
	{	
		name="WorldMapFrameTexture2", 
		file="Interface\\WorldMap\\UI-WorldMap-Top2",
	},
	{	
		name="WorldMapFrameTexture3", 
		file="Interface\\WorldMap\\UI-WorldMap-Top3",
	},
	{	
		name="WorldMapFrameTexture4", 
		file="Interface\\WorldMap\\UI-WorldMap-Top4",
	},
	{	
		name="WorldMapFrameTexture5", 
		file="Interface\\WorldMap\\UI-WorldMap-Middle1",
	},
	{	
		name="WorldMapFrameTexture6", 
		file="Interface\\WorldMap\\UI-WorldMap-Middle2",
	},
	{	
		name="WorldMapFrameTexture7", 
		file="Interface\\WorldMap\\UI-WorldMap-Middle3",
	},
	{	
		name="WorldMapFrameTexture8", 
		file="Interface\\WorldMap\\UI-WorldMap-Middle4",
	},
	{	
		name="WorldMapFrameTexture9", 
		file="Interface\\WorldMap\\UI-WorldMap-Bottom1",
	},
	{	
		name="WorldMapFrameTexture10", 
		file="Interface\\WorldMap\\UI-WorldMap-Bottom2",
	},
	{	
		name="WorldMapFrameTexture11", 
		file="Interface\\WorldMap\\UI-WorldMap-Bottom3",
	},
	{	
		name="WorldMapFrameTexture12", 
		file="Interface\\WorldMap\\UI-WorldMap-Bottom4",
	},
	{	
		name="WorldMapFrameTexture13", 
		file="Interface\\WorldMap\\UI-WorldMap-Bottom1-full",
	},
	{	
		name="WorldMapFrameTexture14", 
		file="Interface\\WorldMap\\UI-WorldMap-Bottom3-full",
	},
	{	
		name="WorldMapFrameTexture15", 
		file="Interface\\WorldMap\\UI-WorldMap-Bottom4-full",
	},
	{	
		name="WorldMapFrameTexture16", 
		file="Interface\\WorldMap\\UI-WorldMap-Top3-full",
	},
	{	
		name="WorldMapFrameTexture17", 
		file="Interface\\WorldMap\\UI-WorldMap-Top4-full",
	},
	{	
		name="WorldMapFrameTexture18", 
		file="Interface\\WorldMap\\UI-WorldMap-Top3-full",	-- vertex color is set to 0 in WorldMapFrame_OnLoad
	},	
}

function WorldMap_LoadTextures()
	for k, v in pairs(WORLDMAP_TEXTURES_TO_LOAD) do
		_G[v.name]:SetTexture(v.file);
	end
end

function WorldMap_ClearTextures()
	for i=1, NUM_WORLDMAP_OVERLAYS do
		_G["WorldMapOverlay"..i]:SetTexture(nil);
	end
	local numOfDetailTiles = GetNumberOfDetailTiles();
	for i=1, numOfDetailTiles do
		_G["WorldMapFrameTexture"..i]:SetTexture(nil);
		_G["WorldMapDetailTile"..i]:SetTexture(nil);
	end
	for i = numOfDetailTiles + 1, numOfDetailTiles + NUM_WORLDMAP_PATCH_TILES do
		_G["WorldMapFrameTexture"..i]:SetTexture(nil);
	end
end


function WorldMapUnit_OnLoad(self)
	self:SetFrameLevel(self:GetFrameLevel() + 1);
end

function WorldMapUnit_OnEnter(self, motion)
	WorldMapPOIFrame.allowBlobTooltip = false;
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
	WorldMapPOIFrame.allowBlobTooltip = true;
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
	if ( WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE ) then
		SetCVar("miniWorldMap", 0);
		WorldMap_ToggleSizeUp();
	else
		SetCVar("miniWorldMap", 1);
		WorldMap_ToggleSizeDown();
	end	
	-- reopen the frame
	WorldMapFrame.blockWorldMapUpdate = true;
	ToggleFrame(WorldMapFrame);
	WorldMapFrame.blockWorldMapUpdate = nil;
	WorldMapFrame_UpdateMap();
end

function WorldMap_ToggleSizeUp()
	WORLDMAP_SETTINGS.size = WORLDMAP_QUESTLIST_SIZE;
	-- adjust main frame
	WorldMapFrame:SetParent(nil);
	WorldMapFrame_ResetFrameLevels();
	WorldMapFrame:ClearAllPoints();
	WorldMapFrame:SetAllPoints();
	SetUIPanelAttribute(WorldMapFrame, "area", "full");
	SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", false);
	WorldMapFrame:EnableMouse(true);
	WorldMapFrame:EnableKeyboard(true);
	-- adjust map frames
	WorldMapPositioningGuide:ClearAllPoints();
	WorldMapPositioningGuide:SetPoint("CENTER");		
	WorldMapDetailFrame:SetScale(WORLDMAP_QUESTLIST_SIZE);
	WorldMapDetailFrame:SetPoint("TOPLEFT", WorldMapPositioningGuide, "TOP", -726, -99);
	WorldMapButton:SetScale(WORLDMAP_QUESTLIST_SIZE);
	WorldMapFrameAreaFrame:SetScale(WORLDMAP_QUESTLIST_SIZE);
	WorldMapBlobFrame:SetScale(WORLDMAP_QUESTLIST_SIZE);
	WorldMapBlobFrame.xRatio = nil;		-- force hit recalculations
	ScenarioPOIFrame:SetScale(WORLDMAP_FULLMAP_SIZE);	--If we ever need to add objectives on the map itself we should adjust this value
	-- show big window elements
	BlackoutWorld:Show();
	WorldMapZoneMinimapDropDown:Show();
	WorldMapZoomOutButton:Show();
	WorldMapZoneDropDown:Show();
	WorldMapContinentDropDown:Show();
	WorldMapQuestScrollFrame:Show();
	WorldMapQuestDetailScrollFrame:Show();
	WorldMapQuestRewardScrollFrame:Show();		
	WorldMapFrameSizeDownButton:Show();
	-- hide small window elements
	WorldMapTitleButton:Hide();
	WorldMapFrameMiniBorderLeft:Hide();
	WorldMapFrameMiniBorderRight:Hide();		
	WorldMapFrameSizeUpButton:Hide();
	ToggleMapFramerate();
	-- floor dropdown
    WorldMapLevelDropDown:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", 780, 34);
    WorldMapLevelDropDown.header:Show();
	-- tiny adjustments	
	WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapPositioningGuide, 4, 4);
	WorldMapFrameSizeDownButton:SetPoint("TOPRIGHT", WorldMapPositioningGuide, -16, 4);
	WorldMapTrackQuest:SetPoint("BOTTOMLEFT", WorldMapPositioningGuide, "BOTTOMLEFT", 16, 4);
	WorldMapFrameTitle:ClearAllPoints();
	WorldMapFrameTitle:SetPoint("CENTER", 0, 372);
	WorldMapTooltip:SetFrameStrata("TOOLTIP");
	
	WorldMapFrame_SetOpacity(0);
	WorldMapFrame_SetPOIMaxBounds();
	WorldMapQuestShowObjectives_AdjustPosition();
	if ( WorldMapQuestShowObjectives:GetChecked() ) then
		WorldMapPlayerLower:SetSize(PLAYER_ARROW_SIZE_FULL_WITH_QUESTS,PLAYER_ARROW_SIZE_FULL_WITH_QUESTS);
		WorldMapPlayerUpper:SetSize(PLAYER_ARROW_SIZE_FULL_WITH_QUESTS,PLAYER_ARROW_SIZE_FULL_WITH_QUESTS);
	else
		WorldMapPlayerLower:SetSize(PLAYER_ARROW_SIZE_FULL_NO_QUESTS,PLAYER_ARROW_SIZE_FULL_NO_QUESTS);
		WorldMapPlayerUpper:SetSize(PLAYER_ARROW_SIZE_FULL_NO_QUESTS,PLAYER_ARROW_SIZE_FULL_NO_QUESTS);
	end
	MapBarFrame_UpdateLayout(MapBarFrame);
end

function WorldMap_ToggleSizeDown()
	WORLDMAP_SETTINGS.size = WORLDMAP_WINDOWED_SIZE;
	-- adjust main frame
	WorldMapFrame:SetParent(UIParent);
	WorldMapFrame_ResetFrameLevels();
	WorldMapFrame:EnableMouse(false);
	WorldMapFrame:EnableKeyboard(false);
	-- adjust map frames
	WorldMapPositioningGuide:ClearAllPoints();
	WorldMapPositioningGuide:SetAllPoints();		
	WorldMapDetailFrame:SetScale(WORLDMAP_WINDOWED_SIZE);
	WorldMapButton:SetScale(WORLDMAP_WINDOWED_SIZE);
	WorldMapFrameAreaFrame:SetScale(WORLDMAP_WINDOWED_SIZE);
	WorldMapBlobFrame:SetScale(WORLDMAP_WINDOWED_SIZE);
	WorldMapBlobFrame.xRatio = nil;		-- force hit recalculations
	ScenarioPOIFrame:SetScale(WORLDMAP_WINDOWED_SIZE);
	-- hide big window elements
	BlackoutWorld:Hide();
	WorldMapZoneMinimapDropDown:Hide();
	WorldMapZoomOutButton:Hide();
	WorldMapZoneDropDown:Hide();
	WorldMapContinentDropDown:Hide();
	WorldMapLevelUpButton:Hide();
	WorldMapLevelDownButton:Hide();
	WorldMapQuestScrollFrame:Hide();
	WorldMapQuestDetailScrollFrame:Hide();
	WorldMapQuestRewardScrollFrame:Hide();		
	WorldMapFrameSizeDownButton:Hide();
	ToggleMapFramerate();	
	-- show small window elements
	WorldMapTitleButton:Show();
	WorldMapFrameMiniBorderLeft:Show();
	WorldMapFrameMiniBorderRight:Show();		
	WorldMapFrameSizeUpButton:Show();
	-- floor dropdown
    WorldMapLevelDropDown:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPLEFT", -19, 3);

	WorldMapLevelDropDown:SetFrameLevel(WORLDMAP_POI_FRAMELEVEL + 2);
	WorldMapLevelDropDown.header:Hide();
	-- tiny adjustments
	WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapFrameMiniBorderRight, "TOPRIGHT", -44, 5);
	WorldMapFrameSizeDownButton:SetPoint("TOPRIGHT", WorldMapFrameMiniBorderRight, "TOPRIGHT", -66, 5);
	WorldMapTrackQuest:SetPoint("BOTTOMLEFT", WorldMapDetailFrame, "BOTTOMLeft", 2, -26);
	WorldMapFrameTitle:ClearAllPoints();
	WorldMapFrameTitle:SetPoint("TOP", WorldMapDetailFrame, 0, 20);
	WorldMapTooltip:SetFrameStrata("TOOLTIP");
	-- pet battle level size adjustment
	WorldMapFrameAreaPetLevels:SetFontObject("SubZoneTextFont");
	-- user-movable
	WorldMapFrame:ClearAllPoints();
	SetUIPanelAttribute(WorldMapFrame, "area", "center");
	SetUIPanelAttribute(WorldMapFrame, "allowOtherPanels", true);
	WorldMapFrame:SetMovable("true");
	WorldMapFrame:SetWidth(593);
	WorldMapFrame:SetHeight(437);
	WorldMapFrame:SetPoint("TOPLEFT", WorldMapScreenAnchor, 0, 0);
	WorldMapFrameMiniBorderLeft:SetPoint("TOPLEFT", 0, 0);
	WorldMapDetailFrame:SetPoint("TOPLEFT", 19, -42);
	
	WorldMapFrame_SetOpacity(WORLDMAP_SETTINGS.opacity);
	WorldMapFrame_SetPOIMaxBounds();
	WorldMapQuestShowObjectives_AdjustPosition();
	WorldMapPlayerLower:SetSize(PLAYER_ARROW_SIZE_WINDOW,PLAYER_ARROW_SIZE_WINDOW);
	WorldMapPlayerUpper:SetSize(PLAYER_ARROW_SIZE_WINDOW,PLAYER_ARROW_SIZE_WINDOW);
	MapBarFrame_UpdateLayout(MapBarFrame);
end

function WorldMapFrame_ResetFrameLevels()
	WorldMapFrame:SetFrameLevel(WORLDMAP_POI_FRAMELEVEL - 13);
	WorldMapDetailFrame:SetFrameLevel(WORLDMAP_POI_FRAMELEVEL - 12);
	WorldMapBlobFrame:SetFrameLevel(WORLDMAP_POI_FRAMELEVEL - 11);
	WorldMapButton:SetFrameLevel(WORLDMAP_POI_FRAMELEVEL - 10);
	WorldMapPOIFrame:SetFrameLevel(WORLDMAP_POI_FRAMELEVEL);
    for i=1, MAX_PARTY_MEMBERS do
        _G["WorldMapParty"..i]:SetFrameLevel(WORLDMAP_POI_FRAMELEVEL + 100 - 1);
    end
end

function WorldMapQuestShowObjectives_Toggle()
	if ( WorldMapQuestShowObjectives:GetChecked() ) then
		WatchFrame.showObjectives = true;
		QuestLogFrameShowMapButton:Show();		
	else
		WatchFrame.showObjectives = nil;
		WatchFrame_Update();
		QuestLogFrameShowMapButton:Hide();	
	end
	WorldMapFrame_Update();
end

function WorldMapQuestShowObjectives_AdjustPosition()
	if ( WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE ) then
		WorldMapQuestShowObjectives:SetPoint("BOTTOMRIGHT", WorldMapDetailFrame, "BOTTOMRIGHT", -3 - WorldMapQuestShowObjectivesText:GetWidth(), -26);
	else
		WorldMapQuestShowObjectives:SetPoint("BOTTOMRIGHT", WorldMapPositioningGuide, "BOTTOMRIGHT", -15 - WorldMapQuestShowObjectivesText:GetWidth(), 4);
	end
end

function WorldMapFrame_DisplayQuests(selectQuestId)
	if ( WorldMapFrame_UpdateQuests() > 0 ) then
		-- if a quest id wasn't passed in, try to select either current supertracked quest or original supertracked (saved when map was opened)
		if ( not WorldMapFrame_SelectQuestById(selectQuestId) and not WorldMapFrame_SelectQuestById(GetSuperTrackedQuestID())
			and not WorldMapFrame_SelectQuestById(WORLDMAP_SETTINGS.superTrackedQuestID) ) then
			-- quest id wasn't found on this map, select the first quest
			if ( WorldMapQuestFrame1 ) then
				WorldMapFrame_SelectQuestFrame(WorldMapQuestFrame1);
			end
		end
		if ( WORLDMAP_SETTINGS.size == WORLDMAP_FULLMAP_SIZE ) then
			WorldMapFrame_SetQuestMapView();
		end
		WorldMapBlobFrame:Show();
		WorldMapPOIFrame:Show();		
		WorldMapTrackQuest:Show();		
	else
		if ( WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE ) then
			WorldMapFrame_SetFullMapView();
		end
		WorldMapBlobFrame:Hide();
		WorldMapPOIFrame:Hide();		
		WorldMapTrackQuest:Hide();
	end
end

function WorldMapFrame_SelectQuestById(questId)
	if ( not questId or questId <= 0 ) then
		return false;
	end

	local questFrame;
	for i = 1, MAX_NUM_QUESTS do
		questFrame = _G["WorldMapQuestFrame"..i];
		if ( not questFrame ) then
			break
		elseif ( questFrame.questId == questId ) then
			WorldMapFrame_SelectQuestFrame(questFrame);
			return true;
		end
	end
	return false;
end

function WorldMapFrame_SetQuestMapView()
	WORLDMAP_SETTINGS.size = WORLDMAP_QUESTLIST_SIZE;
	WorldMapDetailFrame:SetScale(WORLDMAP_QUESTLIST_SIZE);
	WorldMapButton:SetScale(WORLDMAP_QUESTLIST_SIZE);
	WorldMapFrameAreaFrame:SetScale(WORLDMAP_QUESTLIST_SIZE);
	WorldMapDetailFrame:SetPoint("TOPLEFT", WorldMapPositioningGuide, "TOP", -726, -99);
	WorldMapQuestDetailScrollFrame:Show();
	WorldMapQuestRewardScrollFrame:Show();
	WorldMapQuestScrollFrame:Show();
	local numOfDetailTiles = GetNumberOfDetailTiles();
	for i = numOfDetailTiles + 1, numOfDetailTiles + NUM_WORLDMAP_PATCH_TILES do
		_G["WorldMapFrameTexture"..i]:Hide();
	end
	EncounterJournal_AddMapButtons();
	-- pet battle level size adjustment
	WorldMapFrameAreaPetLevels:SetFontObject("PVPInfoTextFont")
	WorldMapPlayerLower:SetSize(PLAYER_ARROW_SIZE_FULL_WITH_QUESTS,PLAYER_ARROW_SIZE_FULL_WITH_QUESTS);
	WorldMapPlayerUpper:SetSize(PLAYER_ARROW_SIZE_FULL_WITH_QUESTS,PLAYER_ARROW_SIZE_FULL_WITH_QUESTS);
	MapBarFrame_UpdateLayout(MapBarFrame);
end

function WorldMapFrame_SetFullMapView()
	WORLDMAP_SETTINGS.size = WORLDMAP_FULLMAP_SIZE;
	WorldMapDetailFrame:SetScale(WORLDMAP_FULLMAP_SIZE);
	WorldMapButton:SetScale(WORLDMAP_FULLMAP_SIZE);
	WorldMapFrameAreaFrame:SetScale(WORLDMAP_FULLMAP_SIZE);
	WorldMapDetailFrame:SetPoint("TOPLEFT", WorldMapPositioningGuide, "TOP", -502, -69);
	WorldMapQuestDetailScrollFrame:Hide();
	WorldMapQuestRewardScrollFrame:Hide();
	WorldMapQuestScrollFrame:Hide();
	local numOfDetailTiles = GetNumberOfDetailTiles();
	for i = numOfDetailTiles + 1, numOfDetailTiles + NUM_WORLDMAP_PATCH_TILES do
		_G["WorldMapFrameTexture"..i]:Show();
	end
	EncounterJournal_AddMapButtons();
	-- pet battle level size adjustment
	WorldMapFrameAreaPetLevels:SetFontObject("TextStatusBarTextLarge");
	WorldMapPlayerLower:SetSize(PLAYER_ARROW_SIZE_FULL_NO_QUESTS,PLAYER_ARROW_SIZE_FULL_NO_QUESTS);
	WorldMapPlayerUpper:SetSize(PLAYER_ARROW_SIZE_FULL_NO_QUESTS,PLAYER_ARROW_SIZE_FULL_NO_QUESTS);
	MapBarFrame_UpdateLayout(MapBarFrame);
end

function WorldMapFrame_UpdateMap(questId)
	WorldMapFrame_Update();
	WorldMapContinentsDropDown_Update();
	WorldMapZoneDropDown_Update();
	WorldMapLevelDropDown_Update();
	WorldMapFrame_SetMapName();
	if ( WatchFrame.showObjectives ) then
		WorldMapFrame_DisplayQuests(questId);
	end
end

function ScenarioPOIFrame_OnUpdate()
	ScenarioPOIFrame:DrawNone();
	if(WatchFrame.showObjectives == true) then
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

function WorldMapFrame_UpdateQuests()
	local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily;
	local questId, questLogIndex, startEvent;
	local questFrame;
	local lastFrame;
	local refFrame = WorldMapQuestFrame0;
	local questCount = 0;
	local numObjectives, requiredMoney;
	local text, _, finished;
	local playerMoney = GetMoney();
	
	local numPOINumeric = 0;
	local numPOICompleteSwap = 0;
	
	local numEntries = QuestMapUpdateAllQuests();
	WorldMapFrame_ClearQuestPOIs();
	QuestPOIUpdateIcons();

	if ( WorldMapQuestScrollFrame.highlightedFrame ) then
		WorldMapQuestScrollFrame.highlightedFrame.ownPOI:UnlockHighlight();
	end
	QuestPOI_HideAllButtons("WorldMapQuestScrollChildFrame");
	-- clear blobs
	WorldMapBlobFrame:DrawNone();
	-- populate quest frames
	for i = 1, numEntries do
		questId, questLogIndex = QuestPOIGetQuestIDByVisibleIndex(i);
		if ( questLogIndex and questLogIndex > 0 ) then
			questCount = questCount + 1;
			title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, questId, startEvent = GetQuestLogTitle(questLogIndex);
			requiredMoney = GetQuestLogRequiredMoney(questLogIndex);
			numObjectives = GetNumQuestLeaderBoards(questLogIndex);
			if ( isComplete and isComplete < 0 ) then
				isComplete = false;
			elseif ( numObjectives == 0 and playerMoney >= requiredMoney and not startEvent) then
				isComplete = true;
			end
			questFrame = WorldMapFrame_GetQuestFrame(questCount, isComplete);
			if ( lastFrame ) then
				questFrame:SetPoint("TOPLEFT", lastFrame, "BOTTOMLEFT", 0, 0);
			else
				questFrame:SetPoint("TOPLEFT", WorldMapQuestScrollChildFrame, "TOPLEFT", 2, 0);
			end
			-- set up indexes
			questFrame.questId = questId;
			questFrame.questLogIndex = questLogIndex;
			questFrame.completed = isComplete;
			questFrame.level = level;		-- for difficulty color
			-- display map POI
			WorldMapFrame_DisplayQuestPOI(questFrame, isComplete);
			-- set quest text
			questFrame.title:SetText(title);
			if ( IsQuestWatched(questLogIndex) ) then
				questFrame.title:SetWidth(224);
				questFrame.check:Show();
			else
				questFrame.title:SetWidth(240);
				questFrame.check:Hide();
			end
			numObjectives = GetNumQuestLeaderBoards(questLogIndex);
			if ( isComplete ) then
				numPOICompleteSwap = numPOICompleteSwap + 1;
				questFrame.objectives:SetText(GetQuestLogCompletionText(questLogIndex));
				questFrame.dashes:SetText(QUEST_DASH);
			else
				numPOINumeric = numPOINumeric + 1;
				local questText = "";
				local dashText = "";
				local reversedText;
				local numLines;
				for j = 1, numObjectives do
					local text, objectiveType, finished = GetQuestLogLeaderBoard(j, questLogIndex);
					if ( text and not finished ) then
						reversedText = ReverseQuestObjective(text, objectiveType);
						questText = questText..reversedText.."|n";
						refFrame.objectives:SetText(reversedText);
						-- need to add 1 spacing's worth to height because for n number of lines there are n-1 spacings
						numLines = (refFrame.objectives:GetHeight() + refFrame.lineSpacing) / refFrame.lineHeight;
						-- round numLines to the closest integer
						numLines = floor(numLines + 0.5);
						dashText = dashText..QUEST_DASH..string.rep("|n", numLines);
					end
				end
				if ( requiredMoney > playerMoney ) then
					questText = questText.."- "..GetMoneyString(playerMoney).." / "..GetMoneyString(requiredMoney);
					dashText = dashText..QUEST_DASH;
				end				
				questFrame.objectives:SetText(questText);
				questFrame.dashes:SetText(dashText);
			end
			-- difficulty
			if ( MAP_QUEST_DIFFICULTY == "1" ) then
				local color = GetQuestDifficultyColor(level);
				questFrame.title:SetTextColor(color.r, color.g, color.b);
			end
			-- size and show
			questFrame:SetHeight(max(questFrame.title:GetHeight() + questFrame.objectives:GetHeight() + QUESTFRAME_PADDING, QUESTFRAME_MINHEIGHT));
			questFrame:Show();
			lastFrame = questFrame;
		end
	end
	WorldMapFrame.numQuests = questCount;
	-- hide frames not being used for this map
	for i = questCount + 1, MAX_NUM_QUESTS do
		questFrame = _G["WorldMapQuestFrame"..i];
		if ( not questFrame ) then
			break;
		end		
		questFrame:Hide();
		questFrame.questId = 0;
	end
	QuestPOI_HideButtons("WorldMapPOIFrame", QUEST_POI_NUMERIC, numPOINumeric + 1);
	QuestPOI_HideButtons("WorldMapPOIFrame", QUEST_POI_COMPLETE_SWAP, numPOICompleteSwap + 1);
	
	EncounterJournal_CheckQuestButtons();
	return questCount;
end

function WorldMapFrame_SelectQuestFrame(questFrame, userAction)
	local poiIcon;
	local color;
	-- clear current selection	
	if ( WORLDMAP_SETTINGS.selectedQuest ) then
		local currentSelection = WORLDMAP_SETTINGS.selectedQuest;
		poiIcon = currentSelection.poiIcon;
		QuestPOI_DeselectButton(poiIcon);
		QuestPOI_DeselectButtonByParent("WorldMapQuestScrollChildFrame");
		WorldMapBlobFrame:DrawBlob(currentSelection.questId, false);
		if ( MAP_QUEST_DIFFICULTY == "1" ) then
			color = GetQuestDifficultyColor(currentSelection.level);
			currentSelection.title:SetTextColor(color.r, color.g, color.b);
		end
		poiIcon:SetFrameLevel(WORLDMAP_POI_FRAMELEVEL);
	end
	WORLDMAP_SETTINGS.selectedQuest = questFrame;
	-- Change the supertrackedquestID on user action
	if ( userAction ) then
		WORLDMAP_SETTINGS.superTrackedQuestID = questFrame.questId;
	end
	SetSuperTrackedQuestID(questFrame.questId);
	WorldMapQuestSelectedFrame:SetPoint("TOPLEFT", questFrame, "TOPLEFT", -10, 0);
	WorldMapQuestSelectedFrame:SetHeight(questFrame:GetHeight());
	WorldMapQuestSelectedFrame:Show();
	poiIcon = questFrame.poiIcon;
	QuestPOI_SelectButton(poiIcon);
	QuestPOI_SelectButton(questFrame.ownPOI);
	poiIcon:SetFrameLevel(WORLDMAP_POI_FRAMELEVEL + 1);
	-- colors
	if ( MAP_QUEST_DIFFICULTY == "1" ) then
		questFrame.title:SetTextColor(1, 1, 1);
		color = GetQuestDifficultyColor(questFrame.level);
		WorldMapQuestSelectBar:SetVertexColor(color.r, color.g, color.b);
	end
	-- only display quest info if worldmap frame is embiggened
	if ( WORLDMAP_SETTINGS.size ~= WORLDMAP_WINDOWED_SIZE ) then
		SelectQuestLogEntry(questFrame.questLogIndex);
		QuestInfo_Display(QUEST_TEMPLATE_MAP1, WorldMapQuestDetailScrollChildFrame);
		WorldMapQuestDetailScrollFrameScrollBar:SetValue(0);
		ScrollFrame_OnScrollRangeChanged(WorldMapQuestDetailScrollFrame);
		QuestInfo_Display(QUEST_TEMPLATE_MAP2, WorldMapQuestRewardScrollChildFrame);
		WorldMapQuestRewardScrollFrameScrollBar:SetValue(0);
		ScrollFrame_OnScrollRangeChanged(WorldMapQuestRewardScrollFrame);
	else
		-- need to select the appropriate poi in the objectives tracker
		QuestPOI_SelectButtonByQuestId("WatchFrameLines", questFrame.questId, true);
	end	
	-- track quest checkbark
	WorldMapTrackQuest:SetChecked(IsQuestWatched(questFrame.questLogIndex));
	-- quest blob
	if ( questFrame.completed ) then
		WorldMapBlobFrame:DrawBlob(questFrame.questId, false);
	else
		WorldMapBlobFrame:DrawBlob(questFrame.questId, true);
	end
	
	WorldMap_DrawWorldEffects();
end

local numCompletedQuests = 0;
function WorldMapFrame_ClearQuestPOIs()
	QuestPOI_HideButtons("WorldMapPOIFrame", QUEST_POI_NUMERIC, 1);
	QuestPOI_HideButtons("WorldMapPOIFrame", QUEST_POI_COMPLETE_SWAP, 1);
	numCompletedQuests = 0;
end

function WorldMapFrame_DisplayQuestPOI(questFrame, isComplete)
	local index = questFrame.index;
	local poiButton;
	if ( isComplete ) then
		poiButton = QuestPOI_DisplayButton("WorldMapPOIFrame", QUEST_POI_COMPLETE_SWAP, questFrame.completedIndex, questFrame.questId);
	else
		poiButton = QuestPOI_DisplayButton("WorldMapPOIFrame", QUEST_POI_NUMERIC, index - numCompletedQuests, questFrame.questId);
	end
	questFrame.poiIcon = poiButton;
	local _, posX, posY, objective = QuestPOIGetIconInfo(questFrame.questId);
	if ( posX and posY ) then
		local POIscale;
		if ( WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE ) then
			POIscale = WORLDMAP_WINDOWED_SIZE;
		else
			POIscale = WORLDMAP_QUESTLIST_SIZE;
		end
		posX = posX * WorldMapDetailFrame:GetWidth() * POIscale;
		posY = -posY * WorldMapDetailFrame:GetHeight() * POIscale;
		-- keep outlying POIs within map borders
		if ( posY > WORLDMAP_POI_MIN_Y ) then
			posY = WORLDMAP_POI_MIN_Y;
		elseif ( posY < WORLDMAP_POI_MAX_Y ) then
			posY = WORLDMAP_POI_MAX_Y
		end
		if ( posX < WORLDMAP_POI_MIN_X ) then
			posX = WORLDMAP_POI_MIN_X;
		elseif ( posX > WORLDMAP_POI_MAX_X ) then
			posX = WORLDMAP_POI_MAX_X;
		end
		poiButton:SetPoint("CENTER", "WorldMapPOIFrame", "TOPLEFT", posX, posY);
	end
	poiButton.quest = questFrame;
end

function WorldMapFrame_SetPOIMaxBounds()
	WORLDMAP_POI_MAX_Y = WorldMapDetailFrame:GetHeight() * -WORLDMAP_SETTINGS.size + 12;
	WORLDMAP_POI_MAX_X = WorldMapDetailFrame:GetWidth() * WORLDMAP_SETTINGS.size + 12;
end

function WorldMapFrame_GetQuestFrame(index, isComplete)
	local frame = _G["WorldMapQuestFrame"..index];
	if ( not frame ) then
		frame = CreateFrame("Frame", "WorldMapQuestFrame"..index, WorldMapQuestScrollChildFrame, "WorldMapQuestFrameTemplate");
		frame.index = index;
	end
	
	local poiButton;
	if ( isComplete ) then
		numCompletedQuests = numCompletedQuests + 1;
		poiButton = QuestPOI_DisplayButton("WorldMapQuestScrollChildFrame", QUEST_POI_COMPLETE_IN, numCompletedQuests, 0);
		frame.completedIndex = numCompletedQuests;
	else
		poiButton = QuestPOI_DisplayButton("WorldMapQuestScrollChildFrame", QUEST_POI_NUMERIC, index - numCompletedQuests, 0);
	end
	poiButton:SetPoint("TOPLEFT", frame, 4, 0);
	frame.ownPOI = poiButton;
	return frame;
end

function WorldMapQuestFrame_OnEnter(self)
	self.ownPOI:LockHighlight();
	WorldMapQuestScrollFrame.highlightedFrame = self;
	if ( WORLDMAP_SETTINGS.selectedQuest == self ) then
		return;
	end
	WorldMapQuestHighlightedFrame:SetPoint("TOPLEFT", self, "TOPLEFT", -10, -1);
	WorldMapQuestHighlightedFrame:SetHeight(self:GetHeight() - 2);
	if ( MAP_QUEST_DIFFICULTY == "1" ) then
		local color = GetQuestDifficultyColor(self.level);
		self.title:SetTextColor(1, 1, 1);
		WorldMapQuestHighlightBar:SetVertexColor(color.r, color.g, color.b);
	end	
	WorldMapQuestHighlightedFrame:Show();
	if ( not self.completed ) then
		WorldMapBlobFrame:DrawBlob(self.questId, true);
	end
end

function WorldMapQuestFrame_OnLeave(self)
	self.ownPOI:UnlockHighlight();
	WorldMapQuestScrollFrame.highlightedFrame = nil;
	if ( WORLDMAP_SETTINGS.selectedQuest == self ) then
		return;
	end
	if ( MAP_QUEST_DIFFICULTY == "1" ) then
		local color = GetQuestDifficultyColor(self.level);
		self.title:SetTextColor(color.r, color.g, color.b);
	end		
	WorldMapQuestHighlightedFrame:Hide();
	if ( not self.completed ) then
		WorldMapBlobFrame:DrawBlob(self.questId, false);
	end
end

function WorldMapQuestFrame_OnMouseDown(self)
	self.title:SetPoint("TOPLEFT", 35, -9);
	self.ownPOI:SetButtonState("PUSHED");
	QuestPOIButton_OnMouseDown(self.ownPOI);	
end

function WorldMapQuestFrame_OnMouseUp(self)
	self.title:SetPoint("TOPLEFT", 34, -8);
	self.ownPOI:SetButtonState("NORMAL");
	QuestPOIButton_OnMouseUp(self.ownPOI);
	if ( self:IsMouseOver() ) then
		if ( WORLDMAP_SETTINGS.selectedQuest ~= self ) then
			WorldMapQuestHighlightedFrame:Hide();
			PlaySound("igMainMenuOptionCheckBoxOn");
		end
		WorldMapFrame_SelectQuestFrame(self, true);
		if ( IsShiftKeyDown() ) then
			local isChecked = not WorldMapTrackQuest:GetChecked();
			WorldMapTrackQuest:SetChecked(isChecked);		
			WorldMapTrackQuest_Toggle(isChecked);
			WorldMapQuestFrame_UpdateMouseOver();			
		end		
	end
end

function WorldMapQuestFrame_UpdateMouseOver()
	if ( WorldMapQuestScrollFrame:IsMouseOver() ) then
		for i = 1, WorldMapFrame.numQuests do
			local questFrame = _G["WorldMapQuestFrame"..i];
			if ( questFrame:IsMouseOver() ) then
				WorldMapQuestFrame_OnEnter(questFrame);
				break;
			end
		end
	end
end

function WorldMapQuestPOI_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	if ( self.quest ~= WORLDMAP_SETTINGS.selectedQuest ) then
		if ( WORLDMAP_SETTINGS.selectedQuest ) then
			WorldMapBlobFrame:DrawBlob(GetSuperTrackedQuestID(), false);
		end
	end
	WorldMapFrame_SelectQuestFrame(self.quest, true);
	if ( IsShiftKeyDown() ) then
		local isChecked = not WorldMapTrackQuest:GetChecked();
		WorldMapTrackQuest:SetChecked(isChecked);		
		WorldMapTrackQuest_Toggle(isChecked);
	end
end

function WorldMapQuestPOI_OnEnter(self)
	WorldMapPOIFrame.allowBlobTooltip = false;
	WorldMapQuestPOI_SetTooltip(self, self.quest.questLogIndex);	
end

function WorldMapQuestPOI_OnLeave(self)
	WorldMapPOIFrame.allowBlobTooltip = true;
end

function WorldMapQuestPOI_SetTooltip(poiButton, questLogIndex, numObjectives)
	local title = GetQuestLogTitle(questLogIndex);
	WorldMapTooltip:SetOwner(WorldMapFrame, "ANCHOR_CURSOR_RIGHT", 5, 2);
	WorldMapTooltip:SetText(title);
	if ( poiButton and poiButton.type == QUEST_POI_COMPLETE_SWAP ) then
		if ( poiButton.type == QUEST_POI_COMPLETE_SWAP ) then
			WorldMapTooltip:AddLine("- "..GetQuestLogCompletionText(questLogIndex), 1, 1, 1, 1);
		else
			local numObjectives = GetNumQuestLeaderBoards(questLogIndex);
			for i = 1, numObjectives do
				local text, objectiveType, finished = GetQuestLogLeaderBoard(i, questLogIndex);
				if ( text and not finished ) then
					WorldMapTooltip:AddLine("- "..ReverseQuestObjective(text, objectiveType), 1, 1, 1, 1);
				end
			end
		end
	else
		local text, finished, objectiveType;
		local numItemDropTooltips = GetNumQuestItemDrops(questLogIndex);
		if(numItemDropTooltips and numItemDropTooltips > 0) then
			for i = 1, numItemDropTooltips do
				text, objectiveType, finished = GetQuestLogItemDrop(i, questLogIndex);
				if ( text and not finished ) then
					WorldMapTooltip:AddLine("- "..ReverseQuestObjective(text, objectiveType), 1, 1, 1, 1);
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
					WorldMapTooltip:AddLine("- "..ReverseQuestObjective(text, objectiveType), 1, 1, 1, 1);
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

function WorldMapBlobFrame_OnUpdate(self)
	if ( not WorldMapPOIFrame.allowBlobTooltip or not WorldMapDetailFrame:IsMouseOver() ) then
		return;
	end
	if ( not self.xRatio ) then
		WorldMapBlobFrame_CalculateHitTranslations();
	end
	local x, y = GetCursorPosition();
	local adjustedX = x / self.xRatio - self.xOffset;
	local adjustedY = self.yOffset - y / self.yRatio;
	local questLogIndex, numObjectives = self:UpdateMouseOverTooltip(adjustedX, adjustedY);
	if(numObjectives) then
		WorldMapTooltip:SetOwner(WorldMapFrame, "ANCHOR_CURSOR");
		WorldMapQuestPOI_SetTooltip(nil, questLogIndex, numObjectives);
	elseif(not WorldMapTooltip.EJ_using) and (not WorldMapTooltip.WE_using) and (not WorldMapTooltip.MB_using) then
		WorldMapTooltip:Hide();
	end
end

function WorldMapBlobFrame_CalculateHitTranslations()
	local self = WorldMapBlobFrame;
	local centerX, centerY = self:GetCenter();
	local width = self:GetWidth();
	local height = self:GetHeight();
	local scale = self:GetEffectiveScale();
	self.yOffset = centerY / height + 0.5;
	self.yRatio = height * scale;
	self.xOffset = centerX / width - 0.5;
	self.xRatio = width * scale;
end

function WorldMapFrame_ResetQuestColors()
	if ( MAP_QUEST_DIFFICULTY == "0" ) then
		WorldMapQuestSelectBar:SetVertexColor(1, 0.824, 0);
		WorldMapQuestHighlightBar:SetVertexColor(0.243, 0.570, 1);
		for i = 1, MAX_NUM_QUESTS do
			local questFrame = _G["WorldMapQuestFrame"..i];
			if ( not questFrame ) then
				break;
			end
			questFrame.title:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
		end
	end
end

function WorldMap_OpenToQuest(questID, frameToShowOnClose)
	WorldMapFrame.blockWorldMapUpdate = true;
	ShowUIPanel(WorldMapFrame);	
	local mapID, floorNumber = GetQuestWorldMapAreaID(questID);
	if ( mapID ~= 0 ) then
		SetMapByID(mapID);
		if ( floorNumber ~= 0 ) then
			SetDungeonMapLevel(floorNumber);
		end
	end
	WorldMapFrame.blockWorldMapUpdate = nil;
	WorldMapFrame_UpdateMap(questID);	
end

function WorldMapFrame_SetMapName()
	local mapName = WORLD_MAP;
	if ( WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE ) then
		local zoneId = UIDropDownMenu_GetSelectedID(WorldMapZoneDropDown);
		-- zoneId is nil for instances, Azeroth, or the cosmic view, in which case we'll keep the "World Map" title
		if ( zoneId ) then
			if ( zoneId > 0 ) then
				mapName = UIDropDownMenu_GetText(WorldMapZoneDropDown);
			elseif ( UIDropDownMenu_GetSelectedID(WorldMapContinentDropDown) > 0 ) then
				mapName = UIDropDownMenu_GetText(WorldMapContinentDropDown);
			end
		end
	end
	WorldMapFrameTitle:SetText(mapName);
end

--- advanced options ---

function WorldMapTitleButton_OnLoad(self)
	self:RegisterForClicks("LeftButtonDown", "LeftButtonUp", "RightButtonUp");
	self:RegisterForDrag("LeftButton");
	UIDropDownMenu_Initialize(WorldMapTitleDropDown, WorldMapTitleDropDown_Initialize, "MENU");
end

function WorldMapTitleButton_OnClick(self, button)
	PlaySound("UChatScrollButton");

	-- hide the opacity frame on any click
	if ( OpacityFrame:IsShown() and OpacityFrame.saveOpacityFunc and OpacityFrame.saveOpacityFunc == WorldMapFrame_SaveOpacity ) then
		WorldMapFrame_SaveOpacity();
		OpacityFrame.saveOpacityFunc = nil;
		OpacityFrame:Hide();
	end
	
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
		if ( WORLDMAP_SETTINGS.selectedQuest ) then
			WorldMapBlobFrame:DrawBlob(GetSuperTrackedQuestID(), false);
		end
		WorldMapScreenAnchor:ClearAllPoints();
		WorldMapFrame:ClearAllPoints();
		WorldMapFrame:StartMoving();	
	end
end

function WorldMapTitleButton_OnDragStop()
	if ( not WORLDMAP_SETTINGS.locked ) then
		WorldMapFrame:StopMovingOrSizing();
		WorldMapBlobFrame_CalculateHitTranslations();
		if ( WORLDMAP_SETTINGS.selectedQuest and not WORLDMAP_SETTINGS.selectedQuest.completed ) then
			WorldMapBlobFrame:DrawBlob(GetSuperTrackedQuestID(), true);
		end		
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
	-- Opacity
	info.text = CHANGE_OPACITY;
	info.func = WorldMapTitleDropDown_ToggleOpacity;
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

function WorldMapTitleDropDown_ToggleOpacity()
	if ( OpacityFrame:IsShown() ) then
		OpacityFrame:Hide();
		return;
	end
	OpacityFrame:ClearAllPoints();
	if ( WorldMapFrame:GetCenter() < GetScreenWidth() / 2 ) then
		OpacityFrame:SetPoint("TOPLEFT", WorldMapDetailFrame, "TOPRIGHT", 5, 10);
	else
		OpacityFrame:SetPoint("TOPRIGHT", WorldMapDetailFrame, "TOPLEFT", -5, 10);
	end
	OpacityFrame.opacityFunc = WorldMapFrame_ChangeOpacity;
	OpacityFrame.saveOpacityFunc = WorldMapFrame_SaveOpacity;
	OpacityFrame:Show();
	OpacityFrameSlider:SetValue(WORLDMAP_SETTINGS.opacity);	
end

function WorldMapTitleDropDown_ResetPosition()
	WorldMapFrame:ClearAllPoints();
	WorldMapFrame:SetPoint("TOPLEFT", 10, -118);
	WorldMapScreenAnchor:ClearAllPoints();
	WorldMapScreenAnchor:StartMoving();
	WorldMapScreenAnchor:SetPoint("TOPLEFT", WorldMapFrame);
	WorldMapScreenAnchor:StopMovingOrSizing();
end

function WorldMapFrame_ChangeOpacity()
	WORLDMAP_SETTINGS.opacity = OpacityFrameSlider:GetValue();
	WorldMapFrame_SetOpacity(WORLDMAP_SETTINGS.opacity);
end

function WorldMapFrame_SaveOpacity()
	SetCVar("worldMapOpacity", OpacityFrameSlider:GetValue());
end

function WorldMapFrame_SetOpacity(opacity)
	local alpha;
	-- set border alphas
	alpha = 0.5 + (1.0 - opacity) * 0.50;
	WorldMapFrameMiniBorderLeft:SetAlpha(alpha);
	WorldMapFrameMiniBorderRight:SetAlpha(alpha);
	WorldMapFrameSizeUpButton:SetAlpha(alpha);
	WorldMapFrameCloseButton:SetAlpha(alpha);
	-- set map alpha
	alpha = 0.35 + (1.0 - opacity) * 0.65;
	WorldMapDetailFrame:SetAlpha(alpha);
	-- set blob alpha
	alpha = 0.45 + (1.0 - opacity) * 0.55;
	WorldMapPOIFrame:SetAlpha(alpha);
	WorldMapBlobFrame:SetFillAlpha(128 * alpha);
	WorldMapBlobFrame:SetBorderAlpha(192 * alpha);
end

function WorldMapTrackQuest_Toggle(isChecked)
	local questIndex = WORLDMAP_SETTINGS.selectedQuest.questLogIndex;
	local questId = GetSuperTrackedQuestID();
	if ( isChecked ) then
		if ( GetNumQuestWatches() > MAX_WATCHABLE_QUESTS ) then
			UIErrorsFrame:AddMessage(format(QUEST_WATCH_TOO_MANY, MAX_WATCHABLE_QUESTS), 1.0, 0.1, 0.1, 1.0);
			WorldMapTrackQuest:SetChecked(false);
			return;
		end
		if ( LOCAL_MAP_QUESTS["zone"] == GetCurrentMapZone() ) then
			LOCAL_MAP_QUESTS[questId] = true;
		end
		AddQuestWatch(questIndex);	
	else
		LOCAL_MAP_QUESTS[questId] = nil;
		RemoveQuestWatch(questIndex);
	end
	WatchFrame_Update();
	WorldMapFrame_DisplayQuests(questId);
end




--- For EJ boss butons
--- For EJ boss butons
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
	
	local scale = WorldMapDetailFrame:GetScale();
	local width = WorldMapDetailFrame:GetWidth() * scale;
	local height = WorldMapDetailFrame:GetHeight() * scale;

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
	
	if (index == 1) then --not looking at dungeon map
		WorldMapQuestShowObjectives:Show();
		WorldMapShowDropDown:Hide();
	else
		WorldMapQuestShowObjectives:Hide();
		WorldMapShowDropDown:Show();
	end
	if (not GetCVarBool("showBosses")) then
		index = 1;
	end
	
	bossButton = _G["EJMapButton"..index];
	while bossButton do
		bossButton:Hide();
		index = index + 1;
		bossButton = _G["EJMapButton"..index];
	end
	
	WorldMapBossButtonFrame.ready = true;
	EncounterJournal_CheckQuestButtons();
end

--- For EJ boss butons
--- For EJ boss butons	
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

--- For EJ boss butons
--- For EJ boss butons
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


-- functions to deal with map options dropdown that shows up when looking at a dungeon map

function WorldMapShowDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, WorldMapShowDropDown_Initialize);
	UIDropDownMenu_SetText(self, MAP_OPTIONS_TEXT);
	UIDropDownMenu_SetWidth(self, 150);
end


function WorldMapShowDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();

	-- Show quests button
	info.text = SHOW_QUEST_OBJECTIVES_ON_MAP_TEXT;
	info.value = "quests";
	info.func = WorldMapShowDropDown_OnClick;
	info.checked = GetCVarBool("questPOI");
	info.isNotRadio = true;
	info.keepShownOnClick = 1;
	UIDropDownMenu_AddButton(info);

	-- Show bosses button
	info.text = SHOW_BOSSES_ON_MAP_TEXT;
	info.value = "bosses";
	info.func = WorldMapShowDropDown_OnClick;
	info.checked = GetCVarBool("showBosses");
	info.isNotRadio = true;
	info.keepShownOnClick = 1;
	UIDropDownMenu_AddButton(info);
end


function WorldMapShowDropDown_OnClick(self)
	if (self.value == "quests") then
		WorldMapQuestShowObjectives:Click()
	end
	if (self.value == "bosses") then
		if (self.checked) then
			SetCVar("showBosses", "1");
		else
			SetCVar("showBosses", "0");
		end
		WorldMapFrame_Update();
	end
end
