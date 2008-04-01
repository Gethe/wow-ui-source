NUM_WORLDMAP_DETAIL_TILES = 12;
NUM_WORLDMAP_POIS = 32;
NUM_WORLDMAP_POI_COLUMNS = 4;
WORLDMAP_POI_TEXTURE_WIDTH = 64;
NUM_WORLDMAP_OVERLAYS = 40;

function WorldMapFrame_OnLoad()
	this:RegisterEvent("WORLD_MAP_UPDATE");
	this:RegisterEvent("CLOSE_WORLD_MAP");
	this.poiHighlight = nil;
	this.areaName = nil;
	WorldMapFrame_Update();
end

function WorldMapFrame_OnEvent()
	if ( event == "WORLD_MAP_UPDATE" ) then
		WorldMapFrame_Update();
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
	local name, textureIndex, x, y;
	local worldMapPOI;
	local x1, x2, y1, y2;
	-- To be removed... eventually
	if ( numPOIs > NUM_WORLDMAP_POIS ) then
		message("Not enough POI buttons, add more to the XML");
	end
	for i=1, NUM_WORLDMAP_POIS, 1 do
		worldMapPOI = getglobal("WorldMapFramePOI"..i);
		if ( i <= numPOIs ) then
			name, textureIndex, x, y = GetMapLandmarkInfo(i);
			x1, x2, y1, y2 = WorldMap_GetPOITextureCoords(textureIndex);
			getglobal(worldMapPOI:GetName().."Texture"):SetTexCoord(x1, x2, y1, y2);
			x = x * WorldMapButton:GetWidth();
			y = -y * WorldMapButton:GetHeight();
			worldMapPOI:SetPoint("CENTER", "WorldMapButton", "TOPLEFT", x, y );
			worldMapPOI.name = name;
			worldMapPOI:Show();
		else
			worldMapPOI:Hide();
		end
	end
	
	-- Overlay stuff
	local numOverlays = GetNumMapOverlays();
	local textureName, textureWidth, textureHeight, offsetX, offsetY, mapPointX, mapPointY;
	local textureCount = 1;
	local texture;
	local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight;
	local numTexturesWide, numTexturesTall;
	for i=1, numOverlays do
		textureName, textureWidth, textureHeight, offsetX, offsetY, mapPointX, mapPointY = GetMapOverlayInfo(i);
		numTexturesWide = ceil(textureWidth/256);
		numTexturesTall = ceil(textureHeight/256);
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
				if ( textureCount > NUM_WORLDMAP_OVERLAYS ) then
					message("Too many worldmap overlays!");
					return;
				end
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
				texture:ClearAllPoints();
				texture:SetPoint("TOPLEFT", "WorldMapDetailFrame", "TOPLEFT", offsetX + (256 * (k-1)), -(offsetY + (256 * (j - 1))));
				texture:SetTexture(textureName..(((j - 1) * numTexturesWide) + k));
				texture:Show();
				textureCount = textureCount +1;
			end
		end
	end
	for i=textureCount, NUM_WORLDMAP_OVERLAYS do
		getglobal("WorldMapOverlay"..i):Hide();
	end
end

function WorldMap_GetPOITextureCoords(index)
	local worldMapIconDimension = WorldMapFramePOI1Texture:GetWidth();
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
		x = x / button:GetScale();
		y = y / button:GetScale();

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

function WorldMapButton_OnUpdate()
	local x, y = GetCursorPosition();
	x = x / this:GetScale();
	y = y / this:GetScale();

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
	local playerX, playerY = GetPlayerMapPosition("player");
	if ( playerX == 0 and playerY == 0 ) then
		WorldMapPlayer:Hide();
	else
		playerX = playerX * WorldMapDetailFrame:GetWidth();
		playerY = -playerY * WorldMapDetailFrame:GetHeight();
		
		WorldMapPlayer:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", playerX, playerY);
		WorldMapPlayer:Show();
	end
	--Position groupmates
	local partyX, partyY, partyMemberFrame;
	for i=1, MAX_PARTY_MEMBERS, 1 do
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
	--Position corpse
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

function ToggleWorldMap()
	if ( WorldMapFrame:IsVisible() ) then
		HideUIPanel(WorldMapFrame);
	else
		SetupWorldMapScale();
		ShowUIPanel(WorldMapFrame);
	end
end