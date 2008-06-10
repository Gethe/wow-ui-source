NUM_WORLDMAP_DETAIL_TILES = 12;
NUM_WORLDMAP_POIS = 0;
NUM_WORLDMAP_POI_COLUMNS = 8;
WORLDMAP_POI_TEXTURE_WIDTH = 128;
NUM_WORLDMAP_OVERLAYS = 0;
NUM_WORLDMAP_FLAGS = 2;

function WorldMapFrame_OnLoad()
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("WORLD_MAP_UPDATE");
	this:RegisterEvent("CLOSE_WORLD_MAP");
	this:RegisterEvent("WORLD_MAP_NAME_UPDATE");
	this.poiHighlight = nil;
	this.areaName = nil;
	CreateWorldMapArrowFrame(WorldMapFrame);
	WorldMapFrame_Update();

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

function WorldMapFrame_OnEvent()
	-- FIX ME FOR 1.13
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( this:IsVisible() ) then
			HideUIPanel(WorldMapFrame);
		end
	end
	if ( event == "WORLD_MAP_UPDATE" ) then
		if ( this:IsVisible() ) then
			WorldMapFrame_Update();
		end
	elseif ( event == "CLOSE_WORLD_MAP" ) then
		HideUIPanel(this);
	end
end

function WorldMapFrame_Update()
	local mapFileName, textureHeight = GetMapInfo();
	if ( not mapFileName ) then
		-- Temporary Hack
		mapFileName = "World";
	end
	for i=1, NUM_WORLDMAP_DETAIL_TILES, 1 do
		getglobal("WorldMapDetailTile"..i):SetTexture("Interface\\WorldMap\\"..mapFileName.."\\"..mapFileName..i);
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
		worldMapPOI = getglobal("WorldMapFramePOI"..i);
		if ( i <= numPOIs ) then
			name, description, textureIndex, x, y = GetMapLandmarkInfo(i);
			x1, x2, y1, y2 = WorldMap_GetPOITextureCoords(textureIndex);
			getglobal(worldMapPOI:GetName().."Texture"):SetTexCoord(x1, x2, y1, y2);
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
	local textureName, textureWidth, textureHeight, offsetX, offsetY, mapPointX, mapPointY;
	local textureCount = 0, neededTextures;
	local texture;
	local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight;
	local numTexturesWide, numTexturesTall;
	for i=1, numOverlays do
		textureName, textureWidth, textureHeight, offsetX, offsetY, mapPointX, mapPointY = GetMapOverlayInfo(i);
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
				texture = getglobal("WorldMapOverlay"..textureCount);
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
		getglobal("WorldMapOverlay"..i):Hide();
	end
end

function WorldMapPOI_OnEnter()
	WorldMapFrame.poiHighlight = 1;
	if ( this.description and strlen(this.description) > 0 ) then
		WorldMapFrameAreaLabel:SetText(this.name);
		WorldMapFrameAreaDescription:SetText(this.description);
	else
		WorldMapFrameAreaLabel:SetText(this.name);
		WorldMapFrameAreaDescription:SetText("");
	end
end

function WorldMapPOI_OnLeave()
	WorldMapFrame.poiHighlight = nil;
	WorldMapFrameAreaLabel:SetText(WorldMapFrame.areaName);
	WorldMapFrameAreaDescription:SetText("");
end

function WorldMapPOI_OnClick()
	WorldMapButton_OnClick(arg1, WorldMapButton);
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

function WorldMapContinentsDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, WorldMapContinentsDropDown_Initialize);
	UIDropDownMenu_SetWidth(130);
end

function WorldMapContinentsDropDown_Initialize()
	WorldMapFrame_LoadContinents(GetMapContinents());
end

function WorldMapFrame_LoadContinents(...)
	local info;
	for i=1, arg.n, 1 do
		info = {};
		info.text = arg[i];
		info.func = WorldMapContinentButton_OnClick;
		UIDropDownMenu_AddButton(info);
	end
end

function WorldMapZoneDropDown_OnLoad()
	this:RegisterEvent("WORLD_MAP_UPDATE");
	UIDropDownMenu_Initialize(this, WorldMapZoneDropDown_Initialize);
	UIDropDownMenu_SetWidth(130);
end

function WorldMapZoneDropDown_Initialize()
	WorldMapFrame_LoadZones(GetMapZones(GetCurrentMapContinent()));
end

function WorldMapFrame_LoadZones(...)
	local info;
	for i=1, arg.n, 1 do
		info = {};
		info.text = arg[i];
		info.func = WorldMapZoneButton_OnClick;
		UIDropDownMenu_AddButton(info);
	end
end

function WorldMapContinentButton_OnClick()
	UIDropDownMenu_SetSelectedID(WorldMapContinentDropDown, this:GetID());
	SetMapZoom(this:GetID());
end

function WorldMapZoneButton_OnClick()
	UIDropDownMenu_SetSelectedID(WorldMapZoneDropDown, this:GetID());
	SetMapZoom(GetCurrentMapContinent(), this:GetID());
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

function WorldMapButton_OnClick(mouseButton, button)
	CloseDropDownMenus();
	if ( mouseButton == "LeftButton" ) then
		if ( not button ) then
			button = this;
		end
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

function WorldMapButton_OnUpdate(elapsed)
	local x, y = GetCursorPosition();
	x = x / this:GetEffectiveScale();
	y = y / this:GetEffectiveScale();

	local centerX, centerY = this:GetCenter();
	local width = this:GetWidth();
	local height = this:GetHeight();
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
	if ( playerX == 0 and playerY == 0 ) then
		ShowWorldMapArrowFrame(nil);
		WorldMapPing:Hide();
	else
		playerX = playerX * WorldMapDetailFrame:GetWidth();
		playerY = -playerY * WorldMapDetailFrame:GetHeight();
		PositionWorldMapArrowFrame("CENTER", "WorldMapDetailFrame", "TOPLEFT", playerX, playerY);
		ShowWorldMapArrowFrame(1);

		-- Position clear button to detect mouseovers
		WorldMapPlayer:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", playerX, playerY);

		-- Position player ping if its shown
		if ( WorldMapPing:IsVisible() ) then
			WorldMapPing:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", playerX-7, playerY-9);
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
	local partyX, partyY, partyMemberFrame;
	local playerCount = 0;
	if ( GetNumRaidMembers() > 0 ) then
		for i=1, MAX_PARTY_MEMBERS do
			partyMemberFrame = getglobal("WorldMapParty"..i);
			partyMemberFrame:Hide();
		end
		for i=1, MAX_RAID_MEMBERS do
			local unit = "raid"..i;
			partyX, partyY = GetPlayerMapPosition(unit);
			partyMemberFrame = getglobal("WorldMapRaid"..playerCount + 1);
			if ( (partyX ~= 0 or partyY ~= 0) and not UnitIsUnit(unit, "player") ) then
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
			partyX, partyY = GetPlayerMapPosition("party"..i);
			partyMemberFrame = getglobal("WorldMapParty"..i);
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
		partyX, partyY, name = GetBattlefieldPosition(i - playerCount);
		partyMemberFrame = getglobal("WorldMapRaid"..i);
		if ( partyX == 0 and partyY == 0 ) then
			partyMemberFrame:Hide();
		else
			partyX = partyX * WorldMapDetailFrame:GetWidth();
			partyY = -partyY * WorldMapDetailFrame:GetHeight();
			partyMemberFrame:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", partyX, partyY);
			partyMemberFrame.name = name;
			partyMemberFrame:Show();
		end
	end

	-- Position flags
	local flagX, flagY, flagToken, flagFrame, flagTexture;
	local numFlags = GetNumBattlefieldFlagPositions();
	for i=1, numFlags do
		flagX, flagY, flagToken = GetBattlefieldFlagPosition(i);
		flagFrame = getglobal("WorldMapFlag"..i);
		flagTexture = getglobal("WorldMapFlag"..i.."Texture");
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
		flagFrame = getglobal("WorldMapFlag"..i);
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

end

function WorldMapUnit_OnEnter()
	-- Adjust the tooltip based on which side the unit button is on
	local x, y = this:GetCenter();
	local parentX, parentY = this:GetParent():GetCenter();
	if ( x > parentX ) then
		WorldMapTooltip:SetOwner(this, "ANCHOR_LEFT");
	else
		WorldMapTooltip:SetOwner(this, "ANCHOR_RIGHT");
	end
	
	-- See which POI's are in the same region and include their names in the tooltip
	local unitButton;
	local newLineString = "";
	local tooltipText = "";
	
	-- Check player
	if ( MouseIsOver(WorldMapPlayer) ) then
		tooltipText = UnitName(WorldMapPlayer.unit);
		newLineString = "\n";
	end
	-- Check party
	for i=1, MAX_PARTY_MEMBERS do
		unitButton = getglobal("WorldMapParty"..i);
		if ( unitButton:IsVisible() and MouseIsOver(unitButton) ) then
			tooltipText = tooltipText..newLineString..UnitName(unitButton.unit);
			newLineString = "\n";
		end
	end
	--Check Raid
	for i=1, MAX_RAID_MEMBERS do
		unitButton = getglobal("WorldMapRaid"..i);
		if ( unitButton:IsVisible() and MouseIsOver(unitButton) ) then
			-- Handle players not in your raid or party, but on your team
			if ( unitButton.name ) then
				tooltipText = tooltipText..newLineString..unitButton.name;		
			else
				tooltipText = tooltipText..newLineString..UnitName(unitButton.unit);
			end
			newLineString = "\n";
		end
	end
	WorldMapTooltip:SetText(tooltipText);
	WorldMapTooltip:Show();
end

function WorldMapFrame_PingPlayerPosition()
	WorldMapPing:SetAlpha(255);
	WorldMapPing:Show();
	--PlaySound("MapPing");
	WorldMapPing.timer = 1;
end

function ToggleWorldMap()
	if ( WorldMapFrame:IsVisible() ) then
		HideUIPanel(WorldMapFrame);
	else
		ShowUIPanel(WorldMapFrame);
	end
end
