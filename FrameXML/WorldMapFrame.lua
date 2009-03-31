NUM_WORLDMAP_DETAIL_TILES = 12;
NUM_WORLDMAP_POIS = 0;
NUM_WORLDMAP_POI_COLUMNS = 16;
WORLDMAP_POI_TEXTURE_WIDTH = 256;
NUM_WORLDMAP_OVERLAYS = 0;
NUM_WORLDMAP_FLAGS = 2;
NUM_WORLDMAP_DEBUG_ZONEMAP = 0;
NUM_WORLDMAP_DEBUG_OBJECTS = 0;
WORLDMAP_COSMIC_ID = -1;
WORLDMAP_WORLD_ID = 0;
WORLDMAP_OUTLAND_ID = 3;
WORLDMAP_WINTERGRASP_ID = 502;

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

WORLDMAP_DEBUG_ICON_INFO = {};
WORLDMAP_DEBUG_ICON_INFO[1] = { size =  6, r = 0.0, g = 1.0, b = 0.0 };
WORLDMAP_DEBUG_ICON_INFO[2] = { size = 16, r = 1.0, g = 1.0, b = 0.5 };
WORLDMAP_DEBUG_ICON_INFO[3] = { size = 32, r = 1.0, g = 1.0, b = 0.5 };
WORLDMAP_DEBUG_ICON_INFO[4] = { size = 64, r = 1.0, g = 0.6, b = 0.0 };


function WorldMapFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("WORLD_MAP_UPDATE");
	self:RegisterEvent("CLOSE_WORLD_MAP");
	self:RegisterEvent("WORLD_MAP_NAME_UPDATE");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("RAID_ROSTER_UPDATE");

	self.poiHighlight = nil;
	self.areaName = nil;
	CreateWorldMapArrowFrame(WorldMapFrame);
	InitWorldMapPing(WorldMapFrame);
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

	-- PlayerArrowEffectFrame is created in code: CWorldMap::CreatePlayerArrowFrame()
	PlayerArrowEffectFrame:SetFrameLevel(WorldMapParty1:GetFrameLevel() + 1);
	PlayerArrowEffectFrame:SetAlpha(0.65);
end

function WorldMapFrame_OnShow(self)
	SetupFullscreenScale(self);
	UpdateMicroButtons();
	SetMapToCurrentZone();
	PlaySound("igQuestLogOpen");
	CloseDropDownMenus();
	WorldMapFrame_PingPlayerPosition();
	WorldMap_LoadTextures();
	WorldMapFrame_UpdateUnits("WorldMapRaid", "WorldMapParty");
end

function WorldMapFrame_OnHide(self)
	UpdateMicroButtons();
	PlaySound("igQuestLogClose");
	WorldMap_ClearTextures();
end

function WorldMapFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( self:IsShown() ) then
			HideUIPanel(WorldMapFrame);
		end
	elseif ( event == "WORLD_MAP_UPDATE" ) then
		if ( self:IsShown() ) then
			WorldMapFrame_Update();
			WorldMapContinentsDropDown_Update();
			WorldMapZoneDropDown_Update();
			WorldMapLevelDropDown_Update();
		end
	elseif ( event == "CLOSE_WORLD_MAP" ) then
		HideUIPanel(self);
	elseif ( event == "VARIABLES_LOADED" ) then
		WorldMapZoneMinimapDropDown_Update();
	elseif ( event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" ) then
		if ( self:IsShown() ) then
			WorldMapFrame_UpdateUnits("WorldMapRaid", "WorldMapParty");
		end
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
	end
end

function WorldMapFrame_Update()
	local mapFileName, textureHeight = GetMapInfo();
	if ( not mapFileName ) then
		if ( GetCurrentMapContinent() == WORLDMAP_COSMIC_ID ) then
			mapFileName = "Cosmic";
			OutlandButton:Show();
			AzerothButton:Show();
		else
			-- Temporary Hack (Temporary meaning 2 yrs, haha)
			mapFileName = "World";
			OutlandButton:Hide();
			AzerothButton:Hide();
		end
	else
		OutlandButton:Hide();
		AzerothButton:Hide();
	end

	local texName;
	local dungeonLevel = GetCurrentMapDungeonLevel();
	for i=1, NUM_WORLDMAP_DETAIL_TILES do
		if ( dungeonLevel > 0 ) then
			texName = "Interface\\WorldMap\\"..mapFileName.."\\"..mapFileName..dungeonLevel.."_"..i;
		else
			texName = "Interface\\WorldMap\\"..mapFileName.."\\"..mapFileName..i;
		end
		_G["WorldMapDetailTile"..i]:SetTexture(texName);
	end		
	--WorldMapHighlight:Hide();

	-- Enable/Disable zoom out button
	if ( (GetCurrentMapContinent() == WORLDMAP_COSMIC_ID) and (GetCurrentMapDungeonLevel() <= 0) ) then
		WorldMapZoomOutButton:Disable();
	else
		WorldMapZoomOutButton:Enable();
	end

	local nextBattleTime = GetWintergraspWaitTime();
	if ( nextBattleTime and (GetCurrentMapAreaID() == WORLDMAP_WINTERGRASP_ID) ) then
		local battleSec = mod(nextBattleTime, 60);
		local battleMin = mod(floor(nextBattleTime / 60), 60);
		local battleHour = floor(nextBattleTime / 3600);
		WorldMapZoneInfo:SetFormattedText(NEXT_BATTLE, battleHour, battleMin, battleSec);
		WorldMapZoneInfo:Show();
	else
		WorldMapZoneInfo:Hide();
	end

	-- Setup the POI's
	local numPOIs = GetNumMapLandmarks();
	if ( NUM_WORLDMAP_POIS < numPOIs ) then
		for i=NUM_WORLDMAP_POIS+1, numPOIs do
			WorldMap_CreatePOI(i);
		end
		NUM_WORLDMAP_POIS = numPOIs;
	end
	for i=1, NUM_WORLDMAP_POIS do
		local worldMapPOIName = "WorldMapFramePOI"..i;
		local worldMapPOI = _G[worldMapPOIName];
		if ( i <= numPOIs ) then
			local name, description, textureIndex, x, y, mapLinkID = GetMapLandmarkInfo(i);
			local x1, x2, y1, y2 = WorldMap_GetPOITextureCoords(textureIndex);
			_G[worldMapPOIName.."Texture"]:SetTexCoord(x1, x2, y1, y2);
			x = x * WorldMapButton:GetWidth();
			y = -y * WorldMapButton:GetHeight();
			worldMapPOI:SetPoint("CENTER", "WorldMapButton", "TOPLEFT", x, y );
			worldMapPOI.name = name;
			worldMapPOI.description = description;
			worldMapPOI.mapLinkID = mapLinkID;
			worldMapPOI:Show();
		else
			worldMapPOI:Hide();
		end
	end

	-- Setup the overlays
	local textureCount = 0;
	for i=1, GetNumMapOverlays() do
		local textureName, textureWidth, textureHeight, offsetX, offsetY, mapPointX, mapPointY = GetMapOverlayInfo(i);
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
	if ( self.description and strlen(self.description) > 0 ) then
		WorldMapFrameAreaLabel:SetText(self.name);
		WorldMapFrameAreaDescription:SetText(self.description);
	else
		WorldMapFrameAreaLabel:SetText(self.name);
		WorldMapFrameAreaDescription:SetText("");
	end
end

function WorldMapPOI_OnLeave()
	WorldMapFrame.poiHighlight = nil;
	WorldMapFrameAreaLabel:SetText(WorldMapFrame.areaName);
	WorldMapFrameAreaDescription:SetText("");
end

function WorldMapPOI_OnClick(self, button)
	if ( self.mapLinkID ) then
		ClickLandmark(self.mapLinkID);
	else
		WorldMapButton_OnClick(WorldMapButton, button);
	end
end

function WorldMap_CreatePOI(index)
	local button = CreateFrame("Button", "WorldMapFramePOI"..index, WorldMapButton);
	button:SetWidth(32);
	button:SetHeight(32);
	button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	button:SetScript("OnEnter", WorldMapPOI_OnEnter);
	button:SetScript("OnLeave", WorldMapPOI_OnLeave);
	button:SetScript("OnClick", WorldMapPOI_OnClick);

	local texture = button:CreateTexture(button:GetName().."Texture", "BACKGROUND");
	texture:SetWidth(16);
	texture:SetHeight(16);
	texture:SetPoint("CENTER", 0, 0);
	texture:SetTexture("Interface\\Minimap\\POIIcons");
end

function WorldMap_GetPOITextureCoords(index)
	local worldMapIconDimension = 16;
	local xCoord1, xCoord2, yCoord1, yCoord2; 
	local coordIncrement = worldMapIconDimension / WORLDMAP_POI_TEXTURE_WIDTH;
	xCoord1 = mod(index , NUM_WORLDMAP_POI_COLUMNS) * coordIncrement;
	xCoord2 = xCoord1 + coordIncrement;
	yCoord1 = floor(index / NUM_WORLDMAP_POI_COLUMNS) * coordIncrement;
	yCoord2 = yCoord1 + coordIncrement;
	return xCoord1, xCoord2, yCoord1, yCoord2;
end

function WorldMapContinentsDropDown_Update()
	UIDropDownMenu_Initialize(WorldMapContinentDropDown, WorldMapContinentsDropDown_Initialize);
	UIDropDownMenu_SetWidth(WorldMapContinentDropDown, 130);

	if ( (GetCurrentMapContinent() == 0) or (GetCurrentMapContinent() == WORLDMAP_COSMIC_ID) ) then
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

	if ( (GetCurrentMapContinent() == 0) or (GetCurrentMapContinent() == WORLDMAP_COSMIC_ID) ) then
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
		UIDropDownMenu_SetSelectedID(WorldMapLevelDropDown, GetCurrentMapDungeonLevel());
		WorldMapLevelDropDown:Show();
		WorldMapLevelUpButton:Show();
		WorldMapLevelDownButton:Show();
	end
end

function WorldMapLevelDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	local level = GetCurrentMapDungeonLevel();
	
	local mapname = strupper(GetMapInfo() or "");
	
	for i=1, GetNumDungeonMapLevels() do
		local floorname =_G["DUNGEON_FLOOR_" .. mapname .. i];
		info.text = floorname or string.format(FLOOR_NUMBER, i);
		info.func = WorldMapLevelButton_OnClick;
		info.checked = (i == level);
		UIDropDownMenu_AddButton(info);
	end
end

function WorldMapLevelButton_OnClick(self)
	UIDropDownMenu_SetSelectedID(WorldMapLevelDropDown, self:GetID());
	SetDungeonMapLevel(self:GetID());
end

function WorldMapLevelUp_OnClick(self)
	SetDungeonMapLevel(GetCurrentMapDungeonLevel() - 1);
	UIDropDownMenu_SetSelectedID(WorldMapLevelDropDown, GetCurrentMapDungeonLevel());
	PlaySound("UChatScrollButton");
end

function WorldMapLevelDown_OnClick(self)
	SetDungeonMapLevel(GetCurrentMapDungeonLevel() + 1);
	UIDropDownMenu_SetSelectedID(WorldMapLevelDropDown, GetCurrentMapDungeonLevel());
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
	if ( GetCurrentMapZone() ~= WORLDMAP_WORLD_ID ) then
		SetMapZoom(GetCurrentMapContinent());
	elseif ( GetCurrentMapContinent() == WORLDMAP_WORLD_ID ) then
		SetMapZoom(WORLDMAP_COSMIC_ID);
	elseif ( GetCurrentMapDungeonLevel() > 0 ) then
		ZoomOut();
	elseif ( GetCurrentMapContinent() == WORLDMAP_COSMIC_ID ) then
		return;
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

function WorldMapButton_OnUpdate(self, elapsed)
	local x, y = GetCursorPosition();
	x = x / self:GetEffectiveScale();
	y = y / self:GetEffectiveScale();

	local centerX, centerY = self:GetCenter();
	local width = self:GetWidth();
	local height = self:GetHeight();
	local adjustedY = (centerY + (height/2) - y ) / height;
	local adjustedX = (x - (centerX - (width/2))) / width;
	local name, fileName, texPercentageX, texPercentageY, textureX, textureY, scrollChildX, scrollChildY = UpdateMapHighlight( adjustedX, adjustedY );

	WorldMapFrame.areaName = name;
	if ( not WorldMapFrame.poiHighlight ) then
		WorldMapFrameAreaLabel:SetText(name);
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
	UpdateWorldMapArrowFrames();
	local playerX, playerY = GetPlayerMapPosition("player");
	if ( (playerX == 0 and playerY == 0) ) then
		ShowWorldMapArrowFrame(nil);
		WorldMapPing:Hide();
		WorldMapPlayer:Hide();
	else
		playerX = playerX * WorldMapDetailFrame:GetWidth();
		playerY = -playerY * WorldMapDetailFrame:GetHeight();
		PositionWorldMapArrowFrame("CENTER", "WorldMapDetailFrame", "TOPLEFT", playerX, playerY);
		ShowWorldMapArrowFrame(1);

		-- Position clear button to detect mouseovers
		WorldMapPlayer:Show();
		WorldMapPlayer:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", playerX, playerY);

		-- Position player ping if its shown
		if ( WorldMapPing:IsShown() ) then
			WorldMapPing:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", playerX, playerY);
			-- If ping has a timer greater than 0 count it down, otherwise fade it out
			if ( WorldMapPing.timer > 0 ) then
				WorldMapPing.timer = WorldMapPing.timer - elapsed;
				if ( WorldMapPing.timer <= 0 ) then
					WorldMapPing.fadeOut = 1;
					WorldMapPing.fadeOutTimer = MINIMAPPING_FADE_TIMER;
				end
			elseif ( WorldMapPing.fadeOut ) then
				WorldMapPing.fadeOutTimer = WorldMapPing.fadeOutTimer - elapsed;
				if ( WorldMapPing.fadeOutTimer > 0 ) then
					WorldMapPing:SetAlpha(255 * (WorldMapPing.fadeOutTimer/MINIMAPPING_FADE_TIMER))
				else
					WorldMapPing.fadeOut = nil;
					WorldMapPing:Hide();
				end
			end
		end
	end

	--Position groupmates
	local playerCount = 0;
	if ( GetNumRaidMembers() > 0 ) then
		for i=1, MAX_PARTY_MEMBERS do
			local partyMemberFrame = _G["WorldMapParty"..i];
			partyMemberFrame:Hide();
		end
		for i=1, MAX_RAID_MEMBERS do
			local unit = "raid"..i;
			local partyX, partyY = GetPlayerMapPosition(unit);
			local partyMemberFrame = _G["WorldMapRaid"..(playerCount + 1)];
			if ( (partyX == 0 and partyY == 0) or UnitIsUnit(unit, "player") ) then
				partyMemberFrame:Hide();
			else
				partyX = partyX * WorldMapDetailFrame:GetWidth();
				partyY = -partyY * WorldMapDetailFrame:GetHeight();
				partyMemberFrame:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", partyX, partyY);
				partyMemberFrame.name = nil;
				partyMemberFrame.unit = unit;
				partyMemberFrame:Show();
				playerCount = playerCount + 1;
			end
		end
	else
		for i=1, MAX_PARTY_MEMBERS do
			local partyX, partyY = GetPlayerMapPosition("party"..i);
			local partyMemberFrame = _G["WorldMapParty"..i];
			if ( partyX == 0 and partyY == 0 ) then
				partyMemberFrame:Hide();
			else
				partyX = partyX * WorldMapDetailFrame:GetWidth();
				partyY = -partyY * WorldMapDetailFrame:GetHeight();
				partyMemberFrame:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", partyX, partyY);
				partyMemberFrame:Show();
			end
		end
	end
	-- Position Team Members
	local numTeamMembers = GetNumBattlefieldPositions();
	for i=playerCount+1, MAX_RAID_MEMBERS do
		local partyX, partyY, name = GetBattlefieldPosition(i - playerCount);
		local partyMemberFrame = _G["WorldMapRaid"..i];
		if ( partyX == 0 and partyY == 0 ) then
			partyMemberFrame:Hide();
		else
			partyX = partyX * WorldMapDetailFrame:GetWidth();
			partyY = -partyY * WorldMapDetailFrame:GetHeight();
			partyMemberFrame:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", partyX, partyY);
			partyMemberFrame.name = name;
			partyMemberFrame.unit = nil;
			partyMemberFrame:Show();
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

function WorldMapFrame_PingPlayerPosition()
	WorldMapPing:SetAlpha(255);
	WorldMapPing:Show();
	--PlaySound("MapPing");
	WorldMapPing.timer = 1;
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
	for i=1, NUM_WORLDMAP_DETAIL_TILES do
		_G["WorldMapFrameTexture"..i]:SetTexture(nil);
		_G["WorldMapDetailTile"..i]:SetTexture(nil);
	end
end


function WorldMapUnit_OnLoad(self)
	self:SetFrameLevel(self:GetFrameLevel() + 1);
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
	if ( MouseIsOver(WorldMapPlayer) ) then
		if ( PlayerIsPVPInactive(WorldMapPlayer.unit) ) then
			tooltipText = format(PLAYER_IS_PVP_AFK, UnitName(WorldMapPlayer.unit));
		else
			tooltipText = UnitName(WorldMapPlayer.unit);
		end
		newLineString = "\n";
	end
	-- Check party
	for i=1, MAX_PARTY_MEMBERS do
		unitButton = _G["WorldMapParty"..i];
		if ( unitButton:IsVisible() and MouseIsOver(unitButton) ) then
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
		if ( unitButton:IsVisible() and MouseIsOver(unitButton) ) then
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
		if ( v:IsVisible() and MouseIsOver(v) ) then
			if ( v.name ) then
				tooltipText = tooltipText..newLineString..v.name;
			end
			newLineString = "\n";
		end
	end
	-- Check debug objects
	for i = 1, NUM_WORLDMAP_DEBUG_OBJECTS do
		unitButton = _G["WorldMapDebugObject"..i];
		if ( unitButton:IsVisible() and MouseIsOver(unitButton) ) then
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
		if ( instanceType == "pvp" ) then
			--Check Raid
			local unitButton;
			for i=1, MAX_RAID_MEMBERS do
				unitButton = _G[raidUnitPrefix..i];
				if ( unitButton.unit and unitButton:IsVisible() and MouseIsOver(unitButton) and
					 not PlayerIsPVPInactive(unitButton.unit) ) then
					BAD_BOY_COUNT = BAD_BOY_COUNT + 1;
					BAD_BOY_UNITS[BAD_BOY_COUNT] = unitButton.unit;
				end
			end
			if ( BAD_BOY_COUNT > 0 ) then
				-- Check party
				for i=1, MAX_PARTY_MEMBERS do
					unitButton = _G[partyUnitPrefix..i];
					if ( unitButton.unit and unitButton:IsVisible() and MouseIsOver(unitButton) and
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
	UIDropDownMenu_AddButton(info);

	if ( BAD_BOY_COUNT > 0 ) then
		for i=1, BAD_BOY_COUNT do
			info = UIDropDownMenu_CreateInfo();
			info.func = WorldMapUnitDropDown_OnClick;
			info.arg1 = BAD_BOY_UNITS[i];
			info.text = UnitName( BAD_BOY_UNITS[i] );
			UIDropDownMenu_AddButton(info);
		end
		
		if ( BAD_BOY_COUNT > 1 ) then
			info = UIDropDownMenu_CreateInfo();
			info.func = WorldMapUnitDropDown_ReportAll_OnClick;
			info.text = PVP_REPORT_AFK_ALL;
			UIDropDownMenu_AddButton(info);
		end
	end

	info = UIDropDownMenu_CreateInfo();
	info.text = CANCEL;
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
