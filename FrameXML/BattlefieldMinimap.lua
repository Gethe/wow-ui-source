BATTLEFIELD_TAB_SHOW_DELAY = 0.2;
BATTLEFIELD_TAB_FADE_TIME = 0.15;
DEFAULT_BATTLEFIELD_TAB_ALPHA = 0.75;
BATTLEFIELD_TAB_OFFSET_Y = nil;

function BattlefieldMinimap_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("WORLD_MAP_UPDATE");

	CreateMiniWorldMapArrowFrame("BattlefieldMinimap");

	BATTLEFIELDMINIMAP_OPACITY = 0.7;
	RegisterForSave("BATTLEFIELDMINIMAP_OPACITY");

	BATTLEFIELDMINIMAP_LOCKED = 1;
	RegisterForSave("BATTLEFIELDMINIMAP_LOCKED");
end

function BattlefieldMinimap_OnEvent()
	if ( event == "VARIABLES_LOADED" ) then
		OpacityFrameSlider:SetValue(BATTLEFIELDMINIMAP_OPACITY);
		BattlefieldMinimap_SetOpacity();
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		local status, mapName, instanceID = GetBattlefieldStatus();
		if ( status ~= "active" ) then
			HideUIPanel(BattlefieldMinimap);
		end
	elseif ( event == "WORLD_MAP_UPDATE" and BattlefieldMinimap:IsVisible() ) then
		BattlefieldMinimap_Update();
	end
end

function BattlefieldMinimap_Update()
	-- Fill in map tiles
	local mapFileName, textureHeight = GetMapInfo();
	for i=1, NUM_WORLDMAP_DETAIL_TILES do
		getglobal("BattlefieldMinimap"..i):SetTexture("Interface\\WorldMap\\"..mapFileName.."\\"..mapFileName..i);
	end

	-- Setup the POI's
	local numPOIs = GetNumMapLandmarks();
	local name, description, textureIndex, x, y;
	local battlefieldPOI;
	local x1, x2, y1, y2;
	if ( GetCVar("errors") ~= "0" ) then
		if ( numPOIs > NUM_WORLDMAP_POIS ) then
			message("Not enough POI buttons, add more to the XML");
		end
	end
	for i=1, NUM_WORLDMAP_POIS, 1 do
		battlefieldPOI = getglobal("BattlefieldMinimapPOI"..i);
		if ( i <= numPOIs ) then
			name, description, textureIndex, x, y = GetMapLandmarkInfo(i);
			x1, x2, y1, y2 = WorldMap_GetPOITextureCoords(textureIndex);
			getglobal(battlefieldPOI:GetName().."Texture"):SetTexCoord(x1, x2, y1, y2);
			x = x * BattlefieldMinimap:GetWidth();
			y = -y * BattlefieldMinimap:GetHeight();
			battlefieldPOI:SetPoint("CENTER", "BattlefieldMinimap", "TOPLEFT", x, y );
			battlefieldPOI:Show();
		else
			battlefieldPOI:Hide();
		end
	end

	-- Overlay stuff
	local numOverlays = GetNumMapOverlays();
	local textureName, textureWidth, textureHeight, offsetX, offsetY, mapPointX, mapPointY;
	local textureCount = 1;
	local texture;
	local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight;
	local numTexturesWide, numTexturesTall;
	-- Use this value to scale the texture sizes and offsets
	local battlefieldMinimapScale = 56/256;
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
				texture:ClearAllPoints();
				texture:SetPoint("TOPLEFT", "BattlefieldMinimap", "TOPLEFT", (offsetX + (256 * (k-1)))*battlefieldMinimapScale, -((offsetY + (256 * (j - 1)))*battlefieldMinimapScale));
				texture:SetTexture(textureName..(((j - 1) * numTexturesWide) + k));
				texture:Show();
				textureCount = textureCount +1;
			end
		end
	end
	for i=textureCount, NUM_WORLDMAP_OVERLAYS do
		getglobal("BattlefieldMinimapOverlay"..i):Hide();
	end
end

function BattlefieldMinimap_OnUpdate(elapsed)
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

	-- Fadein map if mouse is over
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
			-- If the hover delay has been reached or the user is dragging a chat frame over the dock show the tab
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
		-- If the chatframe's alpha was less than the current default, then fade it back out to the oldAlpha
		if ( BattlefieldMinimap.hasBeenFaded and BattlefieldMinimap.oldAlpha and BattlefieldMinimap.oldAlpha < DEFAULT_BATTLEFIELD_TAB_ALPHA ) then
			UIFrameFadeOut(BattlefieldMinimapTab, BATTLEFIELD_TAB_FADE_TIME, DEFAULT_BATTLEFIELD_TAB_ALPHA, BattlefieldMinimap.oldAlpha);
			BattlefieldMinimap.hover = nil;
			BattlefieldMinimap.hasBeenFaded = nil;
		end
		BattlefieldMinimap.hoverTime = 0;
	end	
end

function BattlefieldMinimap_ShowOpacity()
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
	for i=1, NUM_WORLDMAP_OVERLAYS do
		getglobal("BattlefieldMinimapOverlay"..i):SetAlpha(alpha);
	end
	BattlefieldMinimapCloseButton:SetAlpha(alpha);
	BattlefieldMinimapCorner:SetAlpha(alpha);
end

function BattlefieldMinimap_SaveOpacity()
	BATTLEFIELDMINIMAP_OPACITY = OpacityFrameSlider:GetValue();
end

function BattlefieldMinimapDropDown_Initialize()
	local checked;
	local info = {};
	-- Battlefield minimap lock
	if ( BATTLEFIELDMINIMAP_LOCKED == "1" ) then
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
		if ( BATTLEFIELDMINIMAP_LOCKED == "1" ) then
			return;
		else
			BattlefieldMinimapTab:StartMoving();
		end
	end
end

function BattlefieldMinimap_ToggleLock()
	if ( BATTLEFIELDMINIMAP_LOCKED == "1" ) then
		BATTLEFIELDMINIMAP_LOCKED = "0";
	else
		BATTLEFIELDMINIMAP_LOCKED = "1";
	end
end

function ToggleBattlefieldMinimap()
	if ( BattlefieldMinimap:IsVisible() ) then
		HideUIPanel(BattlefieldMinimap);
	else
		local status, mapName, instanceID = GetBattlefieldStatus();
		if ( status == "active" ) then
			ShowUIPanel(BattlefieldMinimap);
		end
	end
end