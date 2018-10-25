NUM_WORLDMAP_DETAIL_TILES = 12;
NUM_WORLDMAP_POIS = 0;
NUM_WORLDMAP_POI_COLUMNS = 8;
WORLDMAP_POI_TEXTURE_WIDTH = 128;
NUM_WORLDMAP_OVERLAYS = 0;
NUM_WORLDMAP_FLAGS = 2;

local PLAYER_ARROW_SIZE_WINDOW = 40;
local PLAYER_ARROW_SIZE_FULL_WITH_QUESTS = 38;
local PLAYER_ARROW_SIZE_FULL_NO_QUESTS = 28;
local GROUP_MEMBER_SIZE_FULL = 16;
local RAID_MEMBER_SIZE_FULL = GROUP_MEMBER_SIZE_FULL * 0.75;

function SetMapTooltipPosition(tooltipFrame, owner, useMouseAnchor)
	local centerX = WorldMapDetailFrame:GetCenter();
	local comparisonX;

	if useMouseAnchor then
		comparisonX = GetCursorPosition();
		comparisonX = comparisonX / UIParent:GetEffectiveScale();
	else
		comparisonX = owner:GetCenter();
	end

	if ( comparisonX > centerX ) then
		tooltipFrame:SetOwner(owner, useMouseAnchor and "ANCHOR_CURSOR_LEFT" or "ANCHOR_LEFT");
	else
		tooltipFrame:SetOwner(owner, useMouseAnchor and "ANCHOR_CURSOR_RIGHT" or "ANCHOR_RIGHT");
	end
end

function WorldMapFrame_UpdateBlackout()
	-- Hide the world behind the map when we're in widescreen mode
	local width = GetScreenWidth();
	local height = GetScreenHeight();

	if ( width / height < 4 / 3 ) then
		width = width * 1.25;
		height = height * 1.25;
	end

	BlackoutWorld:SetWidth( width );
	BlackoutWorld:SetHeight( height );
end

function WorldMapFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("WORLD_MAP_UPDATE");
	self:RegisterEvent("CLOSE_WORLD_MAP");
	self:RegisterEvent("WORLD_MAP_NAME_UPDATE");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self.poiHighlight = nil;
	self.areaName = nil;
	--CreateWorldMapArrowFrame(WorldMapFrame);
	WorldMapFrame_Update();

	WorldMapFrame_UpdateBlackout();

	WorldMapUnitPositionFrame:SetPlayerPingTexture(1, "Interface\\minimap\\UI-Minimap-Ping-Center", 32, 32);
	WorldMapUnitPositionFrame:SetPlayerPingTexture(2, "Interface\\minimap\\UI-Minimap-Ping-Expand", 32, 32);
	WorldMapUnitPositionFrame:SetPlayerPingTexture(3, "Interface\\minimap\\UI-Minimap-Ping-Rotate", 70, 70);

	WorldMapUnitPositionFrame:SetMouseOverUnitExcluded("player", true);
	WorldMapUnitPositionFrame:SetPinTexture("player", "Interface\\WorldMap\\WorldMapArrow");
	WorldMapUnitPositionFrame:SetPinTexture("party", "Interface\\WorldMap\\WorldMapPartyIcon");
	WorldMapUnitPositionFrame:SetPinTexture("raid", "Interface\\WorldMap\\WorldMapPartyIcon");
	WorldMapUnitPositionFrame:SetUseClassColor("party", false);
	WorldMapUnitPositionFrame:SetUseClassColor("raid", false);

	if (GetCVarBool("questPOI")) then
		WorldMapUnitPositionFrame:SetPinSize("player", PLAYER_ARROW_SIZE_FULL_WITH_QUESTS);
	else
		WorldMapUnitPositionFrame:SetPinSize("player", PLAYER_ARROW_SIZE_FULL_NO_QUESTS);
	end
	WorldMapUnitPositionFrame:SetPinSize("party", GROUP_MEMBER_SIZE_FULL);
	WorldMapUnitPositionFrame:SetPinSize("raid", RAID_MEMBER_SIZE_FULL);
end

function WorldMapFrame_OnEvent(self, event, ...)
	-- FIX ME FOR 1.13
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( self:IsVisible() ) then
			HideUIPanel(WorldMapFrame);
		end
	end
	if ( event == "WORLD_MAP_UPDATE" ) then
		if ( self:IsVisible() ) then
			WorldMapFrame_Update();
			WorldMapUnitPositionFrame:Show();
			WorldMapUnitPositionFrame:StartPlayerPing(2, .25);
		end
	elseif ( event == "CLOSE_WORLD_MAP" ) then
		HideUIPanel(self);
	elseif ( event == "DISPLAY_SIZE_CHANGED" ) then
		WorldMapFrame_UpdateBlackout();
	end
end

function WorldMapFrame_OnKeyDown(self, key)
	local binding = GetBindingFromClick(key)
	if ((binding == "TOGGLEWORLDMAP") or (binding == "TOGGLEGAMEMENU")) then
		RunBinding("TOGGLEWORLDMAP");
	elseif ( binding == "SCREENSHOT" ) then
		RunBinding("SCREENSHOT");
	end
end

function WorldMapFrame_Update()
	local mapFileName, textureHeight = GetMapInfo();
	if ( not mapFileName ) then
		-- Temporary Hack
		mapFileName = "World";
	end
	for i=1, NUM_WORLDMAP_DETAIL_TILES, 1 do
		_G["WorldMapDetailTile"..i]:SetTexture("Interface\\WorldMap\\"..mapFileName.."\\"..mapFileName..i);
	end		
	--WorldMapHighlight:Hide();

	-- Enable/Disable zoom out button
	if ( GetCurrentMapContinent() == 0 ) then
		WorldMapZoomOutButton:Disable();
	else
		WorldMapZoomOutButton:Enable();
	end

	-- Setup the POI's
	local numPOIs = GetNumMapLandmarks();
	local name, description, textureIndex, x, y;
	local worldMapPOI;
	local x1, x2, y1, y2;

	if ( NUM_WORLDMAP_POIS < numPOIs ) then
		for i=NUM_WORLDMAP_POIS+1, numPOIs do
			WorldMap_CreatePOI(i);
		end
		NUM_WORLDMAP_POIS = numPOIs;
	end
	for i=1, NUM_WORLDMAP_POIS do
		worldMapPOI = _G["WorldMapFramePOI"..i];
		if ( i <= numPOIs ) then
			name, description, textureIndex, x, y = GetMapLandmarkInfo(i);
			x1, x2, y1, y2 = WorldMap_GetPOITextureCoords(textureIndex);
			_G[worldMapPOI:GetName().."Texture"]:SetTexCoord(x1, x2, y1, y2);
			x = x * WorldMapButton:GetWidth();
			y = -y * WorldMapButton:GetHeight();
			worldMapPOI:SetPoint("CENTER", "WorldMapButton", "TOPLEFT", x, y );
			worldMapPOI.name = name;
			worldMapPOI.description = description;
			worldMapPOI:Show();
		else
			worldMapPOI:Hide();
		end
	end

	-- Setup the overlays
	local numOverlays = GetNumMapOverlays();
	local textureName, textureWidth, textureHeight, offsetX, offsetY, isShownByMouseOver;
	local textureCount = 0, neededTextures;
	local texture;
	local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight;
	local numTexturesWide, numTexturesTall;
	for i=1, numOverlays do
		textureName, textureWidth, textureHeight, offsetX, offsetY, isShownByMouseOver = GetMapOverlayInfo(i);
		numTexturesWide = ceil(textureWidth/256);
		numTexturesTall = ceil(textureHeight/256);
		neededTextures = textureCount + (numTexturesWide * numTexturesTall);
		if ( neededTextures > NUM_WORLDMAP_OVERLAYS ) then
			for j=NUM_WORLDMAP_OVERLAYS+1, neededTextures do
				WorldMapDetailFrame:CreateTexture("WorldMapOverlay"..j, "ARTWORK");
			end
			NUM_WORLDMAP_OVERLAYS = neededTextures;
		end
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
				texture = _G["WorldMapOverlay"..textureCount];
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
	for i=textureCount+1, NUM_WORLDMAP_OVERLAYS do
		_G["WorldMapOverlay"..i]:Hide();
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

function WorldMapPOI_OnLeave(self)
	WorldMapFrame.poiHighlight = nil;
	WorldMapFrameAreaLabel:SetText(WorldMapFrame.areaName);
	WorldMapFrameAreaDescription:SetText("");
end

function WorldMapPOI_OnClick(self, button)
	WorldMapButton_OnClick(WorldMapButton, button);
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

function WorldMapContinentsDropDown_OnLoad(self)
	UIDropDownMenu_Initialize(self, WorldMapContinentsDropDown_Initialize);
	UIDropDownMenu_SetWidth(self, 130);
end

function WorldMapContinentsDropDown_Initialize()
	WorldMapFrame_LoadContinents(GetMapContinents());
end

function WorldMapFrame_LoadContinents(...)
	local info;
	local count = select("#", ...);
	for i=1, count, 2 do
		info = {};
		info.text = select(i + 1, ...);
		info.func = WorldMapContinentButton_OnClick;
		UIDropDownMenu_AddButton(info);
	end
end

function WorldMapZoneDropDown_OnLoad(self)
	self:RegisterEvent("WORLD_MAP_UPDATE");
	UIDropDownMenu_Initialize(self, WorldMapZoneDropDown_Initialize);
	UIDropDownMenu_SetWidth(self, 130);
end

function WorldMapZoneDropDown_Initialize()
	WorldMapFrame_LoadZones(GetMapZones(GetCurrentMapContinent()));
end

function WorldMapFrame_LoadZones(...)
	local info;
	local count = select("#", ...);
	for i=1, count, 2 do
		info = {};
		info.text = select(i + 1, ...);
		info.func = WorldMapZoneButton_OnClick;
		UIDropDownMenu_AddButton(info);
	end
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
	if ( GetCurrentMapZone() ~= 0 ) then
		SetMapZoom(GetCurrentMapContinent());
	else
		SetMapZoom(0);
	end
end

function WorldMap_UpdateZoneDropDownText()
	if ( GetCurrentMapZone() == 0 ) then
		UIDropDownMenu_ClearAll(WorldMapZoneDropDown);
	else
		UIDropDownMenu_SetSelectedID(WorldMapZoneDropDown, GetCurrentMapZone());
	end
end

function WorldMap_UpdateContinentDropDownText()
	if ( GetCurrentMapContinent() == 0 ) then
		UIDropDownMenu_ClearAll(WorldMapContinentDropDown);
	else
		UIDropDownMenu_SetSelectedID(WorldMapContinentDropDown,GetCurrentMapContinent());
	end
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
	else
		WorldMapZoomOutButton_OnClick();
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
	WorldMapUnitPositionFrame:UpdatePlayerPins();

	--UpdateWorldMapArrowFrames();
--	local playerX, playerY = GetPlayerMapPosition("player");
--	if ( playerX == 0 and playerY == 0 ) then
--		--ShowWorldMapArrowFrame(nil);
--		WorldMapPing:Hide();
--	else
--		playerX = playerX * WorldMapDetailFrame:GetWidth();
--		playerY = -playerY * WorldMapDetailFrame:GetHeight();
--		--PositionWorldMapArrowFrame("CENTER", "WorldMapDetailFrame", "TOPLEFT", playerX, playerY);
--		--ShowWorldMapArrowFrame(1);
--
--		-- Position clear button to detect mouseovers
--		WorldMapPlayer:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", playerX, playerY);
--
--		-- Position player ping if its shown
--		if ( WorldMapPing:IsVisible() ) then
--			WorldMapPing:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", playerX-7, playerY-9);
--			-- If ping has a timer greater than 0 count it down, otherwise fade it out
--			if ( WorldMapPing.timer > 0 ) then
--				WorldMapPing.timer = WorldMapPing.timer - elapsed;
--				if ( WorldMapPing.timer <= 0 ) then
--					WorldMapPing.fadeOut = 1;
--					WorldMapPing.fadeOutTimer = MINIMAPPING_FADE_TIMER;
--				end
--			elseif ( WorldMapPing.fadeOut ) then
--				WorldMapPing.fadeOutTimer = WorldMapPing.fadeOutTimer - elapsed;
--				if ( WorldMapPing.fadeOutTimer > 0 ) then
--					WorldMapPing:SetAlpha(255 * (WorldMapPing.fadeOutTimer/MINIMAPPING_FADE_TIMER))
--				else
--					WorldMapPing.fadeOut = nil;
--					WorldMapPing:Hide();
--				end
--			end
--		end
--	end
--
--	--Position groupmates
--	local partyX, partyY, partyMemberFrame;
--	local playerCount = 0;
--	if ( IsInRaid() ) then
--		for i=1, MAX_PARTY_MEMBERS do
--			partyMemberFrame = _G["WorldMapParty"..i];
--			partyMemberFrame:Hide();
--		end
--		for i=1, MAX_RAID_MEMBERS do
--			local unit = "raid"..i;
--			partyX, partyY = GetPlayerMapPosition(unit);
--			partyMemberFrame = _G["WorldMapRaid"..playerCount + 1];
--			if ( (partyX ~= 0 or partyY ~= 0) and not UnitIsUnit(unit, "player") ) then
--				partyX = partyX * WorldMapDetailFrame:GetWidth();
--				partyY = -partyY * WorldMapDetailFrame:GetHeight();
--				partyMemberFrame:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", partyX, partyY);
--				partyMemberFrame.name = nil;
--				partyMemberFrame.unit = unit;
--				partyMemberFrame:Show();
--				playerCount = playerCount + 1;
--			end
--		end
--	else
--		for i=1, MAX_PARTY_MEMBERS do
--			partyX, partyY = GetPlayerMapPosition("party"..i);
--			partyMemberFrame = _G["WorldMapParty"..i];
--			if ( partyX == 0 and partyY == 0 ) then
--				partyMemberFrame:Hide();
--			else
--				partyX = partyX * WorldMapDetailFrame:GetWidth();
--				partyY = -partyY * WorldMapDetailFrame:GetHeight();
--				partyMemberFrame:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", partyX, partyY);
--				partyMemberFrame:Show();
--			end
--		end
--	end
	-- Position Team Members
--	local numTeamMembers = GetNumBattlefieldPositions();
--	for i=playerCount+1, MAX_RAID_MEMBERS do
--		partyX, partyY, name = GetBattlefieldPosition(i - playerCount);
--		partyMemberFrame = _G["WorldMapRaid"..i];
--		if ( partyX == 0 and partyY == 0 ) then
--			partyMemberFrame:Hide();
--		else
--			partyX = partyX * WorldMapDetailFrame:GetWidth();
--			partyY = -partyY * WorldMapDetailFrame:GetHeight();
--			partyMemberFrame:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", partyX, partyY);
--			partyMemberFrame.name = name;
--			partyMemberFrame:Show();
--		end
--	end

	-- Position flags
	local flagX, flagY, flagToken, flagFrame, flagTexture;
	local numFlags = GetNumBattlefieldFlagPositions();
	for i=1, numFlags do
		flagX, flagY, flagToken = GetBattlefieldFlagPosition(i);
		flagFrame = _G["WorldMapFlag"..i];
		flagTexture = _G["WorldMapFlag"..i.."Texture"];
		if ( flagX == 0 and flagY == 0 ) then
			flagFrame:Hide();
		else
			flagX = flagX * WorldMapDetailFrame:GetWidth();
			flagY = -flagY * WorldMapDetailFrame:GetHeight();
			flagFrame:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", flagX, flagY);
			flagTexture:SetTexture("Interface\\WorldStateFrame\\"..flagToken);
			flagFrame:Show();
		end
	end
	for i=numFlags+1, NUM_WORLDMAP_FLAGS do
		flagFrame = _G["WorldMapFlag"..i];
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

	WorldMapUnitPositionFrame:UpdateTooltips(WorldMapTooltip);
end

function WorldMapUnit_OnEnter(self)
	-- Adjust the tooltip based on which side the unit button is on
--	local x, y = self:GetCenter();
--	local parentX, parentY = self:GetParent():GetCenter();
--	if ( x > parentX ) then
--		WorldMapTooltip:SetOwner(self, "ANCHOR_LEFT");
--	else
--		WorldMapTooltip:SetOwner(self, "ANCHOR_RIGHT");
--	end
	
	-- See which POI's are in the same region and include their names in the tooltip
--	local unitButton;
--	local newLineString = "";
--	local tooltipText = "";
--	
--	-- Check player
--	if ( MouseIsOver(WorldMapPlayer) ) then
--		tooltipText = UnitName(WorldMapPlayer.unit);
--		newLineString = "\n";
--	end
--	-- Check party
--	for i=1, MAX_PARTY_MEMBERS do
--		unitButton = _G["WorldMapParty"..i];
--		if ( unitButton:IsVisible() and MouseIsOver(unitButton) ) then
--			tooltipText = tooltipText..newLineString..UnitName(unitButton.unit);
--			newLineString = "\n";
--		end
--	end
--	--Check Raid
--	for i=1, MAX_RAID_MEMBERS do
--		unitButton = _G["WorldMapRaid"..i];
--		if ( unitButton:IsVisible() and MouseIsOver(unitButton) ) then
--			-- Handle players not in your raid or party, but on your team
--			if ( unitButton.name ) then
--				tooltipText = tooltipText..newLineString..unitButton.name;		
--			else
--				tooltipText = tooltipText..newLineString..UnitName(unitButton.unit);
--			end
--			newLineString = "\n";
--		end
--	end
--	WorldMapTooltip:SetText(tooltipText);
--	WorldMapTooltip:Show();
end

-- function WorldMapFrame_PingPlayerPosition()
-- 	WorldMapPing:SetAlpha(255);
-- 	WorldMapPing:Show();
-- 	--PlaySound("MapPing");
-- 	WorldMapPing.timer = 1;
-- end

function ToggleWorldMap()
	if ( WorldMapFrame:IsVisible() ) then
		HideUIPanel(WorldMapFrame);
	else
		ShowUIPanel(WorldMapFrame);
	end
end
