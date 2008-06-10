
BATTLEFIELD_TAB_SHOW_DELAY = 0.2;
BATTLEFIELD_TAB_FADE_TIME = 0.15;
DEFAULT_BATTLEFIELD_TAB_ALPHA = 0.75;
DEFAULT_POI_ICON_SIZE = 12;
BATTLEFIELD_MINIMAP_UPDATE_RATE = 0.1;
NUM_BATTLEFIELDMAP_POIS = 0;
NUM_BATTLEFIELDMAP_OVERLAYS = 0;

BattlefieldMinimapDefaults = {
	opacity = 0.7,
	locked = true,
	showPlayers = true,
};

function BattlefieldMinimap_Toggle()
	if ( BattlefieldMinimap:IsVisible() ) then
		BattlefieldMinimap:Hide();
		SHOW_BATTLEFIELD_MINIMAP = "0";
	else
		if ( ( MiniMapBattlefieldFrame.status == "active" ) or ( GetNumWorldStateUI() > 0 ) ) then
			SHOW_BATTLEFIELD_MINIMAP = "1";
			BattlefieldMinimap:Show();
		end
	end
end

function BattlefieldMinimap_OnLoad()
	this:RegisterEvent("ADDON_LOADED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("PLAYER_LOGOUT");
	this:RegisterEvent("WORLD_MAP_UPDATE");

	CreateMiniWorldMapArrowFrame(BattlefieldMinimap);

	BattlefieldMinimap.updateTimer = 0;
end

function BattlefieldMinimap_OnEvent(event)
	if ( event == "ADDON_LOADED" ) then
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

			UIDropDownMenu_Initialize(BattlefieldMinimapTabDropDown, BattlefieldMinimapDropDown_Initialize, "MENU");

			OpacityFrameSlider:SetValue(BattlefieldMinimapOptions.opacity);
			BattlefieldMinimap_SetOpacity();
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		if ( ( MiniMapBattlefieldFrame.status ~= "active" ) and ( GetNumWorldStateUI() == 0 ) ) then
			BattlefieldMinimap:Hide();
		elseif ( BattlefieldMinimap:IsShown() ) then
			SetMapToCurrentZone();
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
	end
end

function BattlefieldMinimap_Update()
	-- Fill in map tiles
	local mapFileName, textureHeight = GetMapInfo();
	if ( not mapFileName ) then
		return;
	end
	for i=1, NUM_WORLDMAP_DETAIL_TILES do
		getglobal("BattlefieldMinimap"..i):SetTexture("Interface\\WorldMap\\"..mapFileName.."\\"..mapFileName..i);
	end

	-- Setup the POI's
	local numPOIs = GetNumMapLandmarks();
	local name, description, textureIndex, x, y;
	local battlefieldPOI;
	local x1, x2, y1, y2;
	if ( NUM_BATTLEFIELDMAP_POIS < numPOIs ) then
		for i=NUM_BATTLEFIELDMAP_POIS+1, numPOIs do
			BattlefieldMinimap_CreatePOI(i);
		end
		NUM_BATTLEFIELDMAP_POIS = numPOIs;
	end
	for i=1, NUM_BATTLEFIELDMAP_POIS, 1 do
		battlefieldPOI = getglobal("BattlefieldMinimapPOI"..i);
		if ( i <= numPOIs ) then
			name, description, textureIndex, x, y = GetMapLandmarkInfo(i);
			x1, x2, y1, y2 = WorldMap_GetPOITextureCoords(textureIndex);
			getglobal(battlefieldPOI:GetName().."Texture"):SetTexCoord(x1, x2, y1, y2);
			x = x * BattlefieldMinimap:GetWidth();
			y = -y * BattlefieldMinimap:GetHeight();
			battlefieldPOI:SetPoint("CENTER", "BattlefieldMinimap", "TOPLEFT", x, y );
			battlefieldPOI:SetWidth(DEFAULT_POI_ICON_SIZE * GetBattlefieldMapIconScale());
			battlefieldPOI:SetHeight(DEFAULT_POI_ICON_SIZE * GetBattlefieldMapIconScale());
			battlefieldPOI:Show();
		else
			battlefieldPOI:Hide();
		end
	end

	-- Setup the overlays
	local numOverlays = GetNumMapOverlays();
	local textureName, textureWidth, textureHeight, offsetX, offsetY, mapPointX, mapPointY;
	local textureCount = 0, neededTextures;
	local texture;
	local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight;
	local numTexturesWide, numTexturesTall;
	-- Use this value to scale the texture sizes and offsets
	local battlefieldMinimapScale = BattlefieldMinimap1:GetWidth()/256;
	for i=1, numOverlays do
		textureName, textureWidth, textureHeight, offsetX, offsetY, mapPointX, mapPointY = GetMapOverlayInfo(i);
		numTexturesWide = ceil(textureWidth/256);
		numTexturesTall = ceil(textureHeight/256);
		neededTextures = textureCount + (numTexturesWide * numTexturesTall);
		if ( neededTextures > NUM_BATTLEFIELDMAP_OVERLAYS ) then
			for j=NUM_BATTLEFIELDMAP_OVERLAYS+1, neededTextures do
				BattlefieldMinimap:CreateTexture("BattlefieldMinimapOverlay"..j, "ARTWORK");
			end
			NUM_BATTLEFIELDMAP_OVERLAYS = neededTextures;
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
				texture = getglobal("BattlefieldMinimapOverlay"..textureCount);
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
				texture:Show();
			end
		end
	end
	for i=textureCount+1, NUM_BATTLEFIELDMAP_OVERLAYS do
		getglobal("BattlefieldMinimapOverlay"..i):Hide();
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

function BattlefieldMinimap_OnUpdate(elapsed)
	-- Throttle updates
	if ( BattlefieldMinimap.updateTimer < 0 ) then
		BattlefieldMinimap.updateTimer = BATTLEFIELD_MINIMAP_UPDATE_RATE;
	else
		BattlefieldMinimap.updateTimer = BattlefieldMinimap.updateTimer - elapsed;
	end
	
	--Position player
	UpdateWorldMapArrowFrames();
	local playerX, playerY = GetPlayerMapPosition("player");
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
		for i=1, 12 do
			mapPiece = getglobal("BattlefieldMinimap"..i);
			mapPiece:SetWidth(sizeUnit);
			mapPiece:SetHeight(sizeUnit);
		end
		local numPOIs = GetNumMapLandmarks();
		local name, description, textureIndex, x, y;
		local battlefieldPOI;
		local x1, x2, y1, y2;
		local battlefieldPOI;
		for i=1, NUM_BATTLEFIELDMAP_POIS, 1 do
			battlefieldPOI = getglobal("BattlefieldMinimapPOI"..i);
			if ( i <= numPOIs ) then
				name, description, textureIndex, x, y = GetMapLandmarkInfo(i);
				x1, x2, y1, y2 = WorldMap_GetPOITextureCoords(textureIndex);
				getglobal(battlefieldPOI:GetName().."Texture"):SetTexCoord(x1, x2, y1, y2);
				x = x * BattlefieldMinimap:GetWidth();
				y = -y * BattlefieldMinimap:GetHeight();
				battlefieldPOI:SetPoint("CENTER", "BattlefieldMinimap", "TOPLEFT", x, y );
				battlefieldPOI:SetWidth(DEFAULT_POI_ICON_SIZE * GetBattlefieldMapIconScale());
				battlefieldPOI:SetHeight(DEFAULT_POI_ICON_SIZE * GetBattlefieldMapIconScale());
				battlefieldPOI:Show();
			else
				battlefieldPOI:Hide();
			end
		end
	end

	if ( not BattlefieldMinimapOptions.showPlayers ) then
		for i=1, MAX_PARTY_MEMBERS do
			getglobal("BattlefieldMinimapParty"..i):Hide();
		end
		for i=1, MAX_RAID_MEMBERS do
			getglobal("BattlefieldMinimapRaid"..i):Hide();
		end
	else
		--Position groupmates
		local partyX, partyY, partyMemberFrame;
		local playerCount = 0;
		if ( GetNumRaidMembers() > 0 ) then
			for i=1, MAX_PARTY_MEMBERS do
				partyMemberFrame = getglobal("BattlefieldMinimapParty"..i);
				partyMemberFrame:Hide();
			end
			for i=1, MAX_RAID_MEMBERS do
				partyX, partyY = GetPlayerMapPosition("raid"..i);
				partyMemberFrame = getglobal("BattlefieldMinimapRaid"..playerCount + 1);
				if ( (partyX ~= 0 or partyY ~= 0) and not UnitIsUnit("raid"..i, "player") ) then
					partyX = partyX * BattlefieldMinimap:GetWidth();
					partyY = -partyY * BattlefieldMinimap:GetHeight();
					partyMemberFrame:SetPoint("CENTER", "BattlefieldMinimap", "TOPLEFT", partyX, partyY);
					partyMemberFrame.name = nil;
					partyMemberFrame:Show();
					playerCount = playerCount + 1;
				end
			end
		else
			for i=1, MAX_PARTY_MEMBERS do
				partyX, partyY = GetPlayerMapPosition("party"..i);
				partyMemberFrame = getglobal("BattlefieldMinimapParty"..i);
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
			partyX, partyY, name = GetBattlefieldPosition(i - playerCount);
			partyMemberFrame = getglobal("BattlefieldMinimapRaid"..i);
			if ( partyX == 0 and partyY == 0 ) then
				partyMemberFrame:Hide();
			else
				partyX = partyX * BattlefieldMinimap:GetWidth();
				partyY = -partyY * BattlefieldMinimap:GetHeight();
				partyMemberFrame:SetPoint("CENTER", "BattlefieldMinimap", "TOPLEFT", partyX, partyY);
				partyMemberFrame.name = name;
				partyMemberFrame:Show();
			end
		end

		-- Position flags
		local flagX, flagY, flagToken, flagFrame, flagTexture;
		local numFlags = GetNumBattlefieldFlagPositions();
		for i=1, NUM_WORLDMAP_FLAGS do
			flagFrame = getglobal("BattlefieldMinimapFlag"..i);
			if ( i <= numFlags ) then
				flagX, flagY, flagToken = GetBattlefieldFlagPosition(i);
				flagTexture = getglobal("BattlefieldMinimapFlag"..i.."Texture");
				if ( flagX == 0 and flagY == 0 ) then
					flagFrame:Hide();
				else
					flagX = flagX * BattlefieldMinimap:GetWidth();
					flagY = -flagY * BattlefieldMinimap:GetHeight();
					flagFrame:SetPoint("CENTER", "BattlefieldMinimap", "TOPLEFT", flagX, flagY);
					flagTexture:SetTexture("Interface\\WorldStateFrame\\"..flagToken);
					flagFrame:Show();
				end
			else
				flagFrame:Hide();
			end
		end
	end

	-- Fadein tab if mouse is over
	if ( MouseIsOver(BattlefieldMinimap, 45, -10, -5, 5) and not UIOptionsFrame:IsVisible()) then
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

function BattlefieldMinimap_ShowOpacity()
	OpacityFrame:ClearAllPoints();
	OpacityFrame:SetPoint("TOPRIGHT", "BattlefieldMinimap", "TOPLEFT", 0, 7);
	OpacityFrame.opacityFunc = BattlefieldMinimap_SetOpacity;
	OpacityFrame.saveOpacityFunc = BattlefieldMinimap_SaveOpacity;
	OpacityFrame:Show();
end

function BattlefieldMinimap_SetOpacity()
	local alpha = 1.0 - OpacityFrameSlider:GetValue();
	BattlefieldMinimapBackground:SetAlpha(alpha);
	for i=1, NUM_WORLDMAP_DETAIL_TILES do
		getglobal("BattlefieldMinimap"..i):SetAlpha(alpha);
	end
	if ( alpha >= 0.15 ) then
		alpha = alpha - 0.15;
	end
	for i=1, NUM_BATTLEFIELDMAP_OVERLAYS do
		getglobal("BattlefieldMinimapOverlay"..i):SetAlpha(alpha);
	end
	BattlefieldMinimapCloseButton:SetAlpha(alpha);
	BattlefieldMinimapCorner:SetAlpha(alpha);
end

function BattlefieldMinimap_SaveOpacity()
	BattlefieldMinimapOptions.opacity = OpacityFrameSlider:GetValue();
end

function BattlefieldMinimapDropDown_Initialize()
	local checked;
	local info = {};
	-- Show battlefield players
	if ( BattlefieldMinimapOptions.showPlayers ) then
		checked = 1;
	end
	info.text = SHOW_BATTLEFIELDMINIMAP_PLAYERS;
	info.func = BattlefieldMinimap_TogglePlayers;
	info.checked = checked;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
	
	-- Battlefield minimap lock
	checked = nil;
	if ( BattlefieldMinimapOptions.locked ) then
		checked = 1;
	end
	info.text = LOCK_BATTLEFIELDMINIMAP;
	info.func = BattlefieldMinimap_ToggleLock;
	info.checked = checked;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);

	-- Opacity
	info = {};
	info.text = BATTLEFIELDMINIMAP_OPACITY_LABEL;
	info.func = BattlefieldMinimap_ShowOpacity;
	UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL);
end

function BattlefieldMinimapTab_OnClick(button)
	-- If Rightclick bring up the options menu
	if ( button == "RightButton" ) then
		ToggleDropDownMenu(1, nil, BattlefieldMinimapTabDropDown, this:GetName(), 0, 0);
		return;
	end

	-- Close all dropdowns
	CloseDropDownMenus();

	-- If frame is not locked then allow the frame to be dragged or dropped
	if ( this:GetButtonState() == "PUSHED" ) then
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

function BattlefieldMinimap_ToggleLock()
	BattlefieldMinimapOptions.locked = not BattlefieldMinimapOptions.locked;
end

function BattlefieldMinimap_TogglePlayers()
	BattlefieldMinimapOptions.showPlayers = not BattlefieldMinimapOptions.showPlayers;
end

function BattlefieldMinimapUnit_OnEnter()
	-- Adjust the tooltip based on which side the unit button is on
	local x, y = this:GetCenter();
	local parentX, parentY = this:GetParent():GetCenter();
	if ( x > parentX ) then
		GameTooltip:SetOwner(this, "ANCHOR_LEFT");
	else
		GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
	end
	
	-- See which POI's are in the same region and include their names in the tooltip
	local unitButton;
	local newLineString = "";
	local tooltipText = "";
	
	-- Check party
	for i=1, MAX_PARTY_MEMBERS do
		unitButton = getglobal("BattlefieldMinimapParty"..i);
		if ( unitButton:IsVisible() and MouseIsOver(unitButton) ) then
			tooltipText = tooltipText..newLineString..UnitName(unitButton.unit);
			newLineString = "\n";
		end
	end
	--Check Raid
	for i=1, MAX_RAID_MEMBERS do
		unitButton = getglobal("BattlefieldMinimapRaid"..i);
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
	GameTooltip:SetText(tooltipText);
	GameTooltip:Show();
end
