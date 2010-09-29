
BATTLEFIELD_TAB_SHOW_DELAY = 0.2;
BATTLEFIELD_TAB_FADE_TIME = 0.15;
DEFAULT_BATTLEFIELD_TAB_ALPHA = 0.75;
DEFAULT_POI_ICON_SIZE = 12;
BATTLEFIELD_MINIMAP_UPDATE_RATE = 0.1;
NUM_BATTLEFIELDMAP_POIS = 0;
NUM_BATTLEFIELDMAP_OVERLAYS = 0;

local BattlefieldMinimapDefaults = {
	opacity = 0.7,
	locked = true,
	showPlayers = true,
};

BG_VEHICLES = {};


function BattlefieldMinimap_Toggle()
	if ( BattlefieldMinimap:IsShown() ) then
		SetCVar("showBattlefieldMinimap", "0");
		BattlefieldMinimap:Hide();
		WorldMapZoneMinimapDropDown_Update();
	else
		local _, instanceType = IsInInstance();
		if ( instanceType == "pvp" ) then
			SetCVar("showBattlefieldMinimap", "1");
			BattlefieldMinimap:Show();
			WorldMapZoneMinimapDropDown_Update();
		elseif ( instanceType ~= "arena" ) then
			SetCVar("showBattlefieldMinimap", "2");
			BattlefieldMinimap:Show();
			WorldMapZoneMinimapDropDown_Update();
		end
	end
end

function BattlefieldMinimap_OnLoad (self)
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("ZONE_CHANGED");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("PLAYER_LOGOUT");
	self:RegisterEvent("WORLD_MAP_UPDATE");
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA");
	self:RegisterEvent("PARTY_MEMBERS_CHANGED");
	self:RegisterEvent("RAID_ROSTER_UPDATE");

	CreateMiniWorldMapArrowFrame(BattlefieldMinimap);

	BattlefieldMinimap.updateTimer = 0;
	-- PlayerMiniArrowEffectFrame is created in code: CWorldMap::CreateMiniPlayerArrowFrame()
	PlayerMiniArrowEffectFrame:SetFrameLevel(WorldMapParty1:GetFrameLevel() + 1);
	PlayerMiniArrowEffectFrame:SetAlpha(0.65);
end

function BattlefieldMinimap_OnShow(self)
	SetMapToCurrentZone();
	BattlefieldMinimap_Update();
	BattlefieldMinimap_UpdateOpacity(BattlefieldMinimapOptions.opacity);
	BattlefieldMinimapTab:Show();
	WorldMapFrame_UpdateUnits("BattlefieldMinimapRaid", "BattlefieldMinimapParty");
end

function BattlefieldMinimap_OnHide(self)
	BattlefieldMinimapTab:Hide();
	BattlefieldMinimap_ClearTextures();
end

function BattlefieldMinimap_OnEvent(self, event, ...)
	if ( event == "ADDON_LOADED" ) then
		local arg1 = ...;
		if ( arg1 == "Blizzard_BattlefieldMinimap" ) then
			if ( not BattlefieldMinimapOptions ) then
				BattlefieldMinimapOptions = BattlefieldMinimapDefaults;
			end

			if ( BattlefieldMinimapOptions.position ) then
				BattlefieldMinimapTab:SetPoint("CENTER", "UIParent", "BOTTOMLEFT", BattlefieldMinimapOptions.position.x, BattlefieldMinimapOptions.position.y);
				BattlefieldMinimapTab:SetUserPlaced(true);
			else
				BattlefieldMinimapTab:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMRIGHT", -225-CONTAINER_OFFSET_X, BATTLEFIELD_TAB_OFFSET_Y);
			end

			UIDropDownMenu_Initialize(BattlefieldMinimapTabDropDown, BattlefieldMinimapTabDropDown_Initialize, "MENU");

			OpacityFrameSlider:SetValue(BattlefieldMinimapOptions.opacity);
			BattlefieldMinimap_UpdateOpacity();
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA") then
		if ( BattlefieldMinimap:IsShown() ) then
			if ( not WorldMapFrame:IsShown() ) then
				SetMapToCurrentZone();
				BattlefieldMinimap_Update();
			end
		end
	elseif ( event == "PLAYER_LOGOUT" ) then
		if ( BattlefieldMinimapTab:IsUserPlaced() ) then
			if ( not BattlefieldMinimapOptions.position ) then
				BattlefieldMinimapOptions.position = {};
			end
			BattlefieldMinimapOptions.position.x, BattlefieldMinimapOptions.position.y = BattlefieldMinimapTab:GetCenter();
			BattlefieldMinimapTab:SetUserPlaced(false);
		else
			BattlefieldMinimapOptions.position = nil;
		end
	elseif ( event == "WORLD_MAP_UPDATE" ) then
		if ( BattlefieldMinimap:IsVisible() ) then
			BattlefieldMinimap_Update();
		end
	elseif ( event == "PARTY_MEMBERS_CHANGED" or event == "RAID_ROSTER_UPDATE" ) then
		if ( self:IsShown() ) then
			WorldMapFrame_UpdateUnits("BattlefieldMinimapRaid", "BattlefieldMinimapParty");
		end
	end
end

function BattlefieldMinimap_Update()
	-- Fill in map tiles
	local mapFileName, textureHeight = GetMapInfo();
	if ( not mapFileName ) then
		if ( GetCurrentMapContinent() == WORLDMAP_COSMIC_ID ) then
			mapFileName = "Cosmic";
		else
			-- Temporary Hack (copy of a "temporary" 6 year hack)
			mapFileName = "World";
		end
	end
	local texName;
	local dungeonLevel = GetCurrentMapDungeonLevel();
	if (DungeonUsesTerrainMap()) then
		dungeonLevel = dungeonLevel - 1;
	end
	local completeMapFileName;
	if ( dungeonLevel > 0 ) then
		completeMapFileName = mapFileName..dungeonLevel.."_";
	else
		completeMapFileName = mapFileName;
	end
	for i=1, NUM_WORLDMAP_DETAIL_TILES do
		texName = "Interface\\WorldMap\\"..mapFileName.."\\"..completeMapFileName..i;
		_G["BattlefieldMinimap"..i]:SetTexture(texName);
	end

	-- Setup the POI's
	local iconSize = DEFAULT_POI_ICON_SIZE * GetBattlefieldMapIconScale();
	local numPOIs = GetNumMapLandmarks();
	if ( NUM_BATTLEFIELDMAP_POIS < numPOIs ) then
		for i=NUM_BATTLEFIELDMAP_POIS+1, numPOIs do
			BattlefieldMinimap_CreatePOI(i);
		end
		NUM_BATTLEFIELDMAP_POIS = numPOIs;
	end
	for i=1, NUM_BATTLEFIELDMAP_POIS do
		local battlefieldPOIName = "BattlefieldMinimapPOI"..i;
		local battlefieldPOI = _G[battlefieldPOIName];
		if ( i <= numPOIs ) then
			local name, description, textureIndex, x, y, maplinkID, showInBattleMap = GetMapLandmarkInfo(i);
			if ( showInBattleMap ) then
				local x1, x2, y1, y2 = WorldMap_GetPOITextureCoords(textureIndex);
				_G[battlefieldPOIName.."Texture"]:SetTexCoord(x1, x2, y1, y2);
				x = x * BattlefieldMinimap:GetWidth();
				y = -y * BattlefieldMinimap:GetHeight();
				battlefieldPOI:SetPoint("CENTER", "BattlefieldMinimap", "TOPLEFT", x, y );
				battlefieldPOI:SetWidth(iconSize);
				battlefieldPOI:SetHeight(iconSize);
				battlefieldPOI:Show();
			else
				battlefieldPOI:Hide();
			end
		else
			battlefieldPOI:Hide();
		end
	end

	-- Setup the overlays
	local numOverlays = GetNumMapOverlays();
	local textureCount = 0;
	-- Use this value to scale the texture sizes and offsets
	local battlefieldMinimapScale = BattlefieldMinimap1:GetWidth()/256;
	for i=1, numOverlays do
		local textureName, textureWidth, textureHeight, offsetX, offsetY = GetMapOverlayInfo(i);
		if (textureName ~= "" or textureWidth == 0 or textureHeight == 0) then
			local numTexturesWide = ceil(textureWidth/256);
			local numTexturesTall = ceil(textureHeight/256);
			local neededTextures = textureCount + (numTexturesWide * numTexturesTall);
			if ( neededTextures > NUM_BATTLEFIELDMAP_OVERLAYS ) then
				for j=NUM_BATTLEFIELDMAP_OVERLAYS+1, neededTextures do
					BattlefieldMinimap:CreateTexture("BattlefieldMinimapOverlay"..j, "ARTWORK");
				end
				NUM_BATTLEFIELDMAP_OVERLAYS = neededTextures;
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
					local texture = _G["BattlefieldMinimapOverlay"..textureCount];
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
					texture:SetWidth(texturePixelWidth*battlefieldMinimapScale);
					texture:SetHeight(texturePixelHeight*battlefieldMinimapScale);
					texture:SetTexCoord(0, texturePixelWidth/textureFileWidth, 0, texturePixelHeight/textureFileHeight);
					texture:SetPoint("TOPLEFT", "BattlefieldMinimap", "TOPLEFT", (offsetX + (256 * (k-1)))*battlefieldMinimapScale, -((offsetY + (256 * (j - 1)))*battlefieldMinimapScale));
					texture:SetTexture(textureName..(((j - 1) * numTexturesWide) + k));
					texture:SetAlpha(1 - ( BattlefieldMinimapOptions.opacity or 0 ));
					texture:Show();
				end
			end
		end
	end
	for i=textureCount+1, NUM_BATTLEFIELDMAP_OVERLAYS do
		_G["BattlefieldMinimapOverlay"..i]:Hide();
	end
end

function BattlefieldMinimap_ClearTextures()
	for i=1, NUM_BATTLEFIELDMAP_OVERLAYS do
		_G["BattlefieldMinimapOverlay"..i]:SetTexture(nil);
	end
	for i=1, NUM_WORLDMAP_DETAIL_TILES do
		_G["BattlefieldMinimap"..i]:SetTexture(nil);
	end
end

function BattlefieldMinimap_CreatePOI(index)
	local frame = CreateFrame("Frame", "BattlefieldMinimapPOI"..index, BattlefieldMinimap);
	frame:SetWidth(DEFAULT_POI_ICON_SIZE);
	frame:SetHeight(DEFAULT_POI_ICON_SIZE);

	local texture = frame:CreateTexture(frame:GetName().."Texture", "BACKGROUND");
	texture:SetAllPoints(frame);
	texture:SetTexture("Interface\\Minimap\\POIIcons");
end

function BattlefieldMinimap_OnUpdate(self, elapsed)
	-- Throttle updates
	if ( BattlefieldMinimap.updateTimer < 0 ) then
		BattlefieldMinimap.updateTimer = BATTLEFIELD_MINIMAP_UPDATE_RATE;
	else
		BattlefieldMinimap.updateTimer = BattlefieldMinimap.updateTimer - elapsed;
	end
	
	--Position player
	UpdateWorldMapArrowFrames();
	local playerX, playerY = GetPlayerMapPosition("player");
	if ( playerX == 0 and playerY == 0 and not WorldMapFrame:IsShown() ) then
		SetMapToCurrentZone();
		playerX, playerY = GetPlayerMapPosition("player");
	end
	if ( playerX == 0 and playerY == 0 ) then
		ShowMiniWorldMapArrowFrame(nil);
	else
		playerX = playerX * BattlefieldMinimap:GetWidth();
		playerY = -playerY * BattlefieldMinimap:GetHeight();
		PositionMiniWorldMapArrowFrame("CENTER", "BattlefieldMinimap", "TOPLEFT", playerX, playerY);
		ShowMiniWorldMapArrowFrame(1);
	end
	
	-- If resizing the frame then scale everything accordingly
	if ( BattlefieldMinimap.resizing ) then
		local sizeUnit = BattlefieldMinimap:GetWidth()/4;
		local mapPiece;
		for i=1, NUM_WORLDMAP_DETAIL_TILES do
			mapPiece = _G["BattlefieldMinimap"..i];
			mapPiece:SetWidth(sizeUnit);
			mapPiece:SetHeight(sizeUnit);
		end
		local numPOIs = GetNumMapLandmarks();
		for i=1, NUM_BATTLEFIELDMAP_POIS, 1 do
			local battlefieldPOIName = "BattlefieldMinimapPOI"..i;
			local battlefieldPOI = _G[battlefieldPOIName];
			if ( i <= numPOIs ) then
				local name, description, textureIndex, x, y, maplinkID,showInBattleMap = GetMapLandmarkInfo(i);
				if ( showInBattleMap ) then
					local x1, x2, y1, y2 = WorldMap_GetPOITextureCoords(textureIndex);
					_G[battlefieldPOIName.."Texture"]:SetTexCoord(x1, x2, y1, y2);
					x = x * BattlefieldMinimap:GetWidth();
					y = -y * BattlefieldMinimap:GetHeight();
					battlefieldPOI:SetPoint("CENTER", "BattlefieldMinimap", "TOPLEFT", x, y );
					battlefieldPOI:Show();
				else
					battlefieldPOI:Hide();
				end
			else
				battlefieldPOI:Hide();
			end
		end
	end

	if ( not BattlefieldMinimapOptions.showPlayers ) then
		for i=1, MAX_PARTY_MEMBERS do
			_G["BattlefieldMinimapParty"..i]:Hide();
		end
		for i=1, MAX_RAID_MEMBERS do
			_G["BattlefieldMinimapRaid"..i]:Hide();
		end
		wipe(BG_VEHICLES);
	else
		--Position groupmates
		local playerCount = 0;
		if ( GetNumRaidMembers() > 0 ) then
			for i=1, MAX_PARTY_MEMBERS do
				local partyMemberFrame = _G["BattlefieldMinimapParty"..i];
				partyMemberFrame:Hide();
			end
			for i=1, MAX_RAID_MEMBERS do
				local unit = "raid"..i;
				local partyX, partyY = GetPlayerMapPosition(unit);
				local partyMemberFrame = _G["BattlefieldMinimapRaid"..(playerCount + 1)];
				if ( (partyX ~= 0 or partyY ~= 0) and not UnitIsUnit("raid"..i, "player") ) then
					partyX = partyX * BattlefieldMinimap:GetWidth();
					partyY = -partyY * BattlefieldMinimap:GetHeight();
					partyMemberFrame:SetPoint("CENTER", "BattlefieldMinimap", "TOPLEFT", partyX, partyY);
					partyMemberFrame.name = nil;
					partyMemberFrame.unit = unit;
					partyMemberFrame:Show();
					playerCount = playerCount + 1;
				end
			end
		else
			for i=1, MAX_PARTY_MEMBERS do
				local partyX, partyY = GetPlayerMapPosition("party"..i);
				local partyMemberFrame = _G["BattlefieldMinimapParty"..i];
				if ( partyX == 0 and partyY == 0 ) then
					partyMemberFrame:Hide();
				else
					partyX = partyX * BattlefieldMinimap:GetWidth();
					partyY = -partyY * BattlefieldMinimap:GetHeight();
					partyMemberFrame:SetPoint("CENTER", "BattlefieldMinimap", "TOPLEFT", partyX, partyY);
					partyMemberFrame:Show();
				end
			end
		end
		-- Position Team Members
		local numTeamMembers = GetNumBattlefieldPositions();
		for i=playerCount+1, MAX_RAID_MEMBERS do
			local partyX, partyY, name = GetBattlefieldPosition(i - playerCount);
			local partyMemberFrame = _G["BattlefieldMinimapRaid"..i];
			if ( partyX == 0 and partyY == 0 ) then
				partyMemberFrame:Hide();
			else
				partyX = partyX * BattlefieldMinimap:GetWidth();
				partyY = -partyY * BattlefieldMinimap:GetHeight();
				partyMemberFrame:SetPoint("CENTER", "BattlefieldMinimap", "TOPLEFT", partyX, partyY);
				partyMemberFrame.name = name;
				partyMemberFrame.unit = nil;
				partyMemberFrame:Show();
			end
		end

		-- Position flags
		local numFlags = GetNumBattlefieldFlagPositions();
		for i=1, NUM_WORLDMAP_FLAGS do
			local flagFrameName = "BattlefieldMinimapFlag"..i;
			local flagFrame = _G[flagFrameName];
			if ( i <= numFlags ) then
				local flagX, flagY, flagToken = GetBattlefieldFlagPosition(i);
				local flagTexture = _G[flagFrameName.."Texture"];
				if ( flagX == 0 and flagY == 0 ) then
					flagFrame:Hide();
				else
					flagX = flagX * BattlefieldMinimap:GetWidth();
					flagY = -flagY * BattlefieldMinimap:GetHeight();
					flagFrame:SetPoint("CENTER", "BattlefieldMinimap", "TOPLEFT", flagX, flagY);
					local flagTexture = _G[flagFrameName.."Texture"];
					flagTexture:SetTexture("Interface\\WorldStateFrame\\"..flagToken);
					flagFrame:Show();
				end
			else
				flagFrame:Hide();
			end
		end

		-- position vehicles
		local numVehicles = GetNumBattlefieldVehicles();
		local totalVehicles = #BG_VEHICLES;
		local index = 0;
		for i=1, numVehicles do
			if (i > totalVehicles) then
				local vehicleName = "BattlefieldMinimap"..i;
				BG_VEHICLES[i] = CreateFrame("FRAME", vehicleName, BattlefieldMinimap, "WorldMapVehicleTemplate");
				BG_VEHICLES[i].texture = _G[vehicleName.."Texture"];
				BG_VEHICLES[i]:SetWidth(30 * GetBattlefieldMapIconScale());
				BG_VEHICLES[i]:SetHeight(30 * GetBattlefieldMapIconScale());
			end
			local vehicleX, vehicleY, unitName, isPossessed, vehicleType, orientation, isPlayer = GetBattlefieldVehicleInfo(i);
			-- If vehicle has position and isn't the player
			if ( vehicleX and not isPlayer)  then
				vehicleX = vehicleX * BattlefieldMinimap:GetWidth();
				vehicleY = -vehicleY * BattlefieldMinimap:GetHeight();
				BG_VEHICLES[i].texture:SetTexture(WorldMap_GetVehicleTexture(vehicleType, isPossessed));
				BG_VEHICLES[i].texture:SetRotation( orientation );
				BG_VEHICLES[i]:SetPoint("CENTER", "BattlefieldMinimap", "TOPLEFT", vehicleX, vehicleY);
				BG_VEHICLES[i]:Show();
				index = i;	-- save for later
			else
				BG_VEHICLES[i]:Hide();
			end
		end
		if (index < totalVehicles) then
			for i=index+1, totalVehicles do
				BG_VEHICLES[i]:Hide();
			end
		end	
	end

	-- Fadein tab if mouse is over
	if ( BattlefieldMinimap:IsMouseOver(45, -10, -5, 5) ) then
		local xPos, yPos = GetCursorPosition();
		-- If mouse is hovering don't show the tab until the elapsed time reaches the tab show delay
		if ( BattlefieldMinimap.hover ) then
			if ( (BattlefieldMinimap.oldX == xPos and BattlefieldMinimap.oldy == yPos) ) then
				BattlefieldMinimap.hoverTime = BattlefieldMinimap.hoverTime + elapsed;
			else
				BattlefieldMinimap.hoverTime = 0;
				BattlefieldMinimap.oldX = xPos;
				BattlefieldMinimap.oldy = yPos;
			end
			if ( BattlefieldMinimap.hoverTime > BATTLEFIELD_TAB_SHOW_DELAY ) then
				-- If the battlefieldtab's alpha is less than the current default, then fade it in 
				if ( not BattlefieldMinimap.hasBeenFaded and (BattlefieldMinimap.oldAlpha and BattlefieldMinimap.oldAlpha < DEFAULT_BATTLEFIELD_TAB_ALPHA) ) then
					UIFrameFadeIn(BattlefieldMinimapTab, BATTLEFIELD_TAB_FADE_TIME, BattlefieldMinimap.oldAlpha, DEFAULT_BATTLEFIELD_TAB_ALPHA);
					-- Set the fact that the chatFrame has been faded so we don't try to fade it again
					BattlefieldMinimap.hasBeenFaded = 1;
				end
			end
		else
			-- Start hovering counter
			BattlefieldMinimap.hover = 1;
			BattlefieldMinimap.hoverTime = 0;
			BattlefieldMinimap.hasBeenFaded = nil;
			CURSOR_OLD_X, CURSOR_OLD_Y = GetCursorPosition();
			-- Remember the oldAlpha so we can return to it later
			if ( not BattlefieldMinimap.oldAlpha ) then
				BattlefieldMinimap.oldAlpha = BattlefieldMinimapTab:GetAlpha();
			end
		end
	else
		-- If the tab's alpha was less than the current default, then fade it back out to the oldAlpha
		if ( BattlefieldMinimap.hasBeenFaded and BattlefieldMinimap.oldAlpha and BattlefieldMinimap.oldAlpha < DEFAULT_BATTLEFIELD_TAB_ALPHA ) then
			UIFrameFadeOut(BattlefieldMinimapTab, BATTLEFIELD_TAB_FADE_TIME, DEFAULT_BATTLEFIELD_TAB_ALPHA, BattlefieldMinimap.oldAlpha);
			BattlefieldMinimap.hover = nil;
			BattlefieldMinimap.hasBeenFaded = nil;
		end
		BattlefieldMinimap.hoverTime = 0;
	end
end


function BattlefieldMinimapTab_OnClick(self, button)
	PlaySound("UChatScrollButton");

	-- If Rightclick bring up the options menu
	if ( button == "RightButton" ) then
		ToggleDropDownMenu(1, nil, BattlefieldMinimapTabDropDown, self:GetName(), 0, 0);
		return;
	end

	-- Close all dropdowns
	CloseDropDownMenus();

	-- If frame is not locked then allow the frame to be dragged or dropped
	if ( self:GetButtonState() == "PUSHED" ) then
		BattlefieldMinimapTab:StopMovingOrSizing();
	else
		-- If locked don't allow any movement
		if ( BattlefieldMinimapOptions.locked ) then
			return;
		else
			BattlefieldMinimapTab:StartMoving();
		end
	end
	ValidateFramePosition(BattlefieldMinimapTab);
end

function BattlefieldMinimapTabDropDown_Initialize()
	local checked;
	local info = UIDropDownMenu_CreateInfo();

	-- Show battlefield players
	info.text = SHOW_BATTLEFIELDMINIMAP_PLAYERS;
	info.func = BattlefieldMinimapTabDropDown_TogglePlayers;
	info.checked = BattlefieldMinimapOptions.showPlayers;
	info.isNotRadio = true;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

	-- Battlefield minimap lock
	info.text = LOCK_BATTLEFIELDMINIMAP;
	info.func = BattlefieldMinimapTabDropDown_ToggleLock;
	info.checked = BattlefieldMinimapOptions.locked;
	info.isNotRadio = true;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

	-- Opacity
	info.text = BATTLEFIELDMINIMAP_OPACITY_LABEL;
	info.func = BattlefieldMinimapTabDropDown_ShowOpacity;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
end

function BattlefieldMinimapTabDropDown_TogglePlayers()
	BattlefieldMinimapOptions.showPlayers = not BattlefieldMinimapOptions.showPlayers;
end

function BattlefieldMinimapTabDropDown_ToggleLock()
	BattlefieldMinimapOptions.locked = not BattlefieldMinimapOptions.locked;
end

function BattlefieldMinimapTabDropDown_ShowOpacity()
	OpacityFrame:ClearAllPoints();
	OpacityFrame:SetPoint("TOPRIGHT", "BattlefieldMinimap", "TOPLEFT", 0, 7);
	OpacityFrame.opacityFunc = BattlefieldMinimap_UpdateOpacity;
	OpacityFrame:Show();
	OpacityFrameSlider:SetValue(BattlefieldMinimapOptions.opacity);
end

function BattlefieldMinimap_UpdateOpacity(opacity)
	BattlefieldMinimapOptions.opacity = opacity or OpacityFrameSlider:GetValue();
	local alpha = 1.0 - BattlefieldMinimapOptions.opacity;
	BattlefieldMinimapBackground:SetAlpha(alpha);
	for i=1, NUM_WORLDMAP_DETAIL_TILES do
		_G["BattlefieldMinimap"..i]:SetAlpha(alpha);
	end
	if ( alpha >= 0.15 ) then
		alpha = alpha - 0.15;
	end
	for i=1, NUM_BATTLEFIELDMAP_OVERLAYS do
		_G["BattlefieldMinimapOverlay"..i]:SetAlpha(alpha);
	end
	BattlefieldMinimapCloseButton:SetAlpha(alpha);
	BattlefieldMinimapCorner:SetAlpha(alpha);
end


function BattlefieldMinimapUnit_OnEnter(self, motion)
	-- Adjust the tooltip based on which side the unit button is on
	local x, y = self:GetCenter();
	local parentX, parentY = self:GetParent():GetCenter();
	if ( x > parentX ) then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	end
	
	-- See which POI's are in the same region and include their names in the tooltip
	local unitButton;
	local newLineString = "";
	local tooltipText = "";
	
	-- Check party
	for i=1, MAX_PARTY_MEMBERS do
		unitButton = _G["BattlefieldMinimapParty"..i];
		if ( unitButton:IsVisible() and unitButton:IsMouseOver() ) then
			if ( PlayerIsPVPInactive(unitButton.unit) ) then
				tooltipText = tooltipText..newLineString..format(PLAYER_IS_PVP_AFK, UnitName(unitButton.unit));
			else
				tooltipText = tooltipText..newLineString..UnitName(unitButton.unit);
			end
			newLineString = "\n";
		end
	end
	--Check Raid
	for i=1, MAX_RAID_MEMBERS do
		unitButton = _G["BattlefieldMinimapRaid"..i];
		if ( unitButton:IsVisible() and unitButton:IsMouseOver() ) then
			-- Handle players not in your raid or party, but on your team
			if ( unitButton.name ) then
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
	GameTooltip:SetText(tooltipText);
	GameTooltip:Show();
end
