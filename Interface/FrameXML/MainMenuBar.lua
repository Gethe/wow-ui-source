local MAINMENU_SLIDETIME = 0.30;
local MAINMENU_GONEYPOS = 130;	--Distance off screen for MainMenuBar to be completely hidden
local MAINMENU_XPOS = 0;
MAIN_MENU_BAR_MARGIN = 75;		-- number of art pixels on one side, used by UIParent_ManageFramePositions. It's not the art's full size, don't care about the gryphon's tail.

MainMenuBarMixin = { };
function MainMenuBarMixin:OnStatusBarsUpdated()
	self:SetPositionForStatusBars();
end

function MainMenuBarMixin:OnLoad()
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("TRIAL_STATUS_UPDATE");
	self:RegisterEvent("DISPLAY_SIZE_CHANGED");
	self:RegisterEvent("UI_SCALE_CHANGED");

	CreateFrame("FRAME", "StatusTrackingBarManager", self, "StatusTrackingBarManagerTemplate");

	MAX_PLAYER_LEVEL = GetMaxLevelForPlayerExpansion();

	self.state = "player";
	MainMenuBarArtFrame.PageNumber:SetText(GetActionBarPage());
	MicroButtonAndBagsBar:SetFrameLevel(self:GetFrameLevel()+2);
end

function MainMenuBarMixin:OnShow()
	UpdateMicroButtonsParent(MainMenuBarArtFrame);
	MoveMicroButtons("BOTTOMLEFT", MicroButtonAndBagsBar, "BOTTOMLEFT", 6, 3, false);
end

function MainMenuBarMixin:SetYOffset(yOffset)
	self.yOffset = yOffset;
end

function MainMenuBarMixin:GetYOffset()
	return self.yOffset;
end

function MainMenuBarMixin:SetPositionForStatusBars()
	MainMenuBar:ClearAllPoints();
	MainMenuBarArtFrame.LeftEndCap:ClearAllPoints();
	MainMenuBarArtFrame.RightEndCap:ClearAllPoints();
	if ( StatusTrackingBarManager:GetNumberVisibleBars() == 2 ) then
		self:SetYOffset(19);
		MainMenuBarArtFrame.LeftEndCap:SetPoint("BOTTOMLEFT", MainMenuBar, -98, -19);
		MainMenuBarArtFrame.RightEndCap:SetPoint("BOTTOMRIGHT", MainMenuBar, 98, -19);
	elseif ( StatusTrackingBarManager:GetNumberVisibleBars() == 1 ) then
		self:SetYOffset(14);
		MainMenuBarArtFrame.LeftEndCap:SetPoint("BOTTOMLEFT", MainMenuBar, -98, -14);
		MainMenuBarArtFrame.RightEndCap:SetPoint("BOTTOMRIGHT", MainMenuBar, 98, -14);
	else
		self:SetYOffset(0);
		MainMenuBarArtFrame.LeftEndCap:SetPoint("BOTTOMLEFT", MainMenuBar, -98, 0);
		MainMenuBarArtFrame.RightEndCap:SetPoint("BOTTOMRIGHT", MainMenuBar, 98, 0);
	end
	if ( IsPlayerInWorld() ) then
		UIParent_ManageFramePositions();
	end
end

local firstEnteringWorld = true;
function MainMenuBarMixin:OnEvent(event, ...)
	if ( event == "ACTIONBAR_PAGE_CHANGED" ) then
		MainMenuBarArtFrame.PageNumber:SetText(GetActionBarPage());
	elseif ( event == "CURRENCY_DISPLAY_UPDATE" ) then
		local showTokenFrame = GetCVarBool("showTokenFrame");
		if ( not showTokenFrame ) then
			if ( C_CurrencyInfo.GetCurrencyListSize() > 0 ) then
				SetCVar("showTokenFrame", 1);
				if ( not CharacterFrame:IsVisible() ) then
					MicroButtonPulse(CharacterMicroButton, 60);
				end
				if ( not TokenFrame:IsVisible() ) then
					SetButtonPulse(CharacterFrameTab3, 60, 1);
				end
				TokenFrame_Update();
				BackpackTokenFrame_Update();
			else
				CharacterFrameTab3:Hide();
			end
		else
			TokenFrame_Update();
			BackpackTokenFrame_Update();
		end
	elseif ( event == "UNIT_LEVEL" ) then
		local unitToken = ...;
		if ( unitToken == "player" ) then
			UpdateMicroButtons();
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		local initialLogin, reloadingUI = ...;
		if ( initialLogin or reloadingUI ) then
			StatusTrackingBarManager:AddBarFromTemplate("FRAME", "ReputationStatusBarTemplate");
			StatusTrackingBarManager:AddBarFromTemplate("FRAME", "HonorStatusBarTemplate");
			StatusTrackingBarManager:AddBarFromTemplate("FRAME", "ArtifactStatusBarTemplate");
			StatusTrackingBarManager:AddBarFromTemplate("FRAME", "ExpStatusBarTemplate");
			StatusTrackingBarManager:AddBarFromTemplate("FRAME", "AzeriteBarTemplate");
			UIParent_ManageFramePositions();
		end
	elseif ( event == "TRIAL_STATUS_UPDATE" ) then
		UpdateMicroButtons();
	elseif ( event == "DISPLAY_SIZE_CHANGED" or event == "UI_SCALE_CHANGED" ) then
		self:ChangeMenuBarSizeAndPosition(SHOW_MULTI_ACTIONBAR_2 and IsNormalActionBarState());
	end

	self:SetPositionForStatusBars();
end

function MainMenuBarVehicleLeaveButton_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
	self:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE");
	self:RegisterEvent("UNIT_EXITED_VEHICLE");
	self:RegisterEvent("VEHICLE_UPDATE");
end

function MainMenuBarVehicleLeaveButton_OnEnter(self)
	if ( UnitOnTaxi("player") ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, TAXI_CANCEL);
		GameTooltip:AddLine(TAXI_CANCEL_DESCRIPTION, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		GameTooltip:Show();
	else
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip_SetTitle(GameTooltip, LEAVE_VEHICLE);
		GameTooltip:Show();
	end
end

function MainMenuBarVehicleLeaveButton_OnEvent(self, event, ...)
	MainMenuBarVehicleLeaveButton_Update();
end

function MainMenuBarVehicleLeaveButton_Update()
	if ( CanExitVehicle() and ActionBarController_GetCurrentActionBarState() == LE_ACTIONBAR_STATE_MAIN ) then
		MainMenuBarVehicleLeaveButton:ClearAllPoints();
		if ( IsPossessBarVisible() ) then
			MainMenuBarVehicleLeaveButton:SetPoint("LEFT", PossessButton2, "RIGHT", 30, 0);
		elseif ( GetNumShapeshiftForms() > 0 ) then
			MainMenuBarVehicleLeaveButton:SetPoint("LEFT", "StanceButton"..GetNumShapeshiftForms(), "RIGHT", 30, 0);
		elseif ( HasMultiCastActionBar() ) then
			MainMenuBarVehicleLeaveButton:SetPoint("LEFT", MultiCastActionBarFrame, "RIGHT", 30, 0);
		else
			MainMenuBarVehicleLeaveButton:SetPoint("LEFT", PossessBarFrame, "LEFT", 10, 0);
		end

		MainMenuBarVehicleLeaveButton:Show();
		MainMenuBarVehicleLeaveButton:Enable();
		ShowPetActionBar(true);
	else
		MainMenuBarVehicleLeaveButton:SetHighlightTexture([[Interface\Buttons\ButtonHilight-Square]], "ADD");
		MainMenuBarVehicleLeaveButton:UnlockHighlight();
		MainMenuBarVehicleLeaveButton:Hide();
		ShowPetActionBar(true);
	end

	UIParent_ManageFramePositions();
end

function MainMenuBarVehicleLeaveButton_OnClicked(self)
	if ( UnitOnTaxi("player") ) then
		TaxiRequestEarlyLanding();

		-- Show that the request for landing has been received.
		self:Disable();
		self:SetHighlightTexture([[Interface\Buttons\CheckButtonHilight]], "ADD");
		self:LockHighlight();
	else
		VehicleExit();
	end
end

-- latency bar

local NUM_ADDONS_TO_DISPLAY = 3;
local topAddOns = {}
for i=1, NUM_ADDONS_TO_DISPLAY do
	topAddOns[i] = { value = 0, name = "" };
end

-- These are movieID from the MOVIE database file.
local MovieList = {
  -- Movie sequence 1 = Wow Classic
  { 1, 2 },
  -- Movie sequence 2 = BC
  { 27 },
  -- Movie sequence 3 = LK
  { 18 },
  -- Movie sequence 4 = CC
  { 23 },
  -- Movie sequence 5 = MP
  { 115 },
  -- Movie sequence 6 = WoD
  -- TODO change movie ID when it is available
  { 115 },
}

function MainMenu_GetMovieDownloadProgress(id)
	local movieList = MovieList[id];
	if (not movieList) then return; end

	local anyInProgress = false;
	local allDownloaded = 0;
	local allTotal = 0;
	for _, movieId in ipairs(movieList) do
		local inProgress, downloaded, total = GetMovieDownloadProgress(movieId);
		anyInProgress = anyInProgress or inProgress;
		allDownloaded = allDownloaded + downloaded;
		allTotal = allTotal + total;
	end

	return anyInProgress, allDownloaded, allTotal;
end

local ipTypes = { "IPv4", "IPv6" }

function MainMenuBarPerformanceBarFrame_OnEnter(self)
	local string = "";
	local i, j, k = 0, 0, 0;

	GameTooltip_SetDefaultAnchor(GameTooltip, self);
	GameTooltip_SetTitle(GameTooltip, self.tooltipText);

	-- latency
	local bandwidthIn, bandwidthOut, latencyHome, latencyWorld = GetNetStats();
	string = format(MAINMENUBAR_LATENCY_LABEL, latencyHome, latencyWorld);
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
	GameTooltip:AddLine(" ");

	-- protocol types
	if ( GetCVarBool("useIPv6") ) then
		local ipTypeHome, ipTypeWorld = GetNetIpTypes();
		string = format(MAINMENUBAR_PROTOCOLS_LABEL, ipTypes[ipTypeHome or 0] or UNKNOWN, ipTypes[ipTypeWorld or 0] or UNKNOWN);
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
		GameTooltip:AddLine(" ");
	end

	-- framerate
	string = format(MAINMENUBAR_FPS_LABEL, GetFramerate());
	GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
	GameTooltip:AddLine(" ");

	string = format(MAINMENUBAR_BANDWIDTH_LABEL, GetAvailableBandwidth());
	GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
	GameTooltip:AddLine(" ");

	local percent = floor(GetDownloadedPercentage()*100+0.5);
	string = format(MAINMENUBAR_DOWNLOAD_PERCENT_LABEL, percent);
	GameTooltip:AddLine(string, 1.0, 1.0, 1.0);

	-- Downloaded cinematics
	local firstMovie = true;
	for i, movieList in next, MovieList do
		local inProgress, downloaded, total = MainMenu_GetMovieDownloadProgress(i);
		if ( inProgress ) then
			if ( firstMovie ) then
				GameTooltip:AddLine("   "..CINEMATICS, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
				firstMovie = false;
			end
			GameTooltip:AddLine("   "..format(CINEMATIC_DOWNLOAD_FORMAT, _G["CINEMATIC_NAME_"..i], downloaded/total*100), GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, true);
		end
	end

	-- AddOn mem usage
	for i=1, NUM_ADDONS_TO_DISPLAY, 1 do
		topAddOns[i].value = 0;
	end

	UpdateAddOnMemoryUsage();
	local totalMem = 0;

	for i=1, GetNumAddOns(), 1 do
		local mem = GetAddOnMemoryUsage(i);
		totalMem = totalMem + mem;
		for j=1, NUM_ADDONS_TO_DISPLAY, 1 do
			if( mem > topAddOns[j].value ) then
				for k=NUM_ADDONS_TO_DISPLAY, 1, -1 do
					if( k == j ) then
						topAddOns[k].value = mem;
						topAddOns[k].name = GetAddOnInfo(i);
						break;
					elseif( k ~= 1 ) then
						topAddOns[k].value = topAddOns[k-1].value;
						topAddOns[k].name = topAddOns[k-1].name;
					end
				end
				break;
			end
		end
	end

	if ( totalMem > 0 ) then
		if ( totalMem > 1000 ) then
			totalMem = totalMem / 1000;
			string = format(TOTAL_MEM_MB_ABBR, totalMem);
		else
			string = format(TOTAL_MEM_KB_ABBR, totalMem);
		end

		GameTooltip:AddLine("\n");
		GameTooltip:AddLine(string, 1.0, 1.0, 1.0);

		local size;
		for i=1, NUM_ADDONS_TO_DISPLAY, 1 do
			if ( topAddOns[i].value == 0 ) then
				break;
			end
			size = topAddOns[i].value;
			if ( size > 1000 ) then
				size = size / 1000;
				string = format(ADDON_MEM_MB_ABBR, size, topAddOns[i].name);
			else
				string = format(ADDON_MEM_KB_ABBR, size, topAddOns[i].name);
			end
			GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
		end
	end
	GameTooltip:Show();
end

function MainMenuBarMixin:ChangeMenuBarSizeAndPosition(rightMultiBarShowing)
	local atlasInfo;

	if( rightMultiBarShowing ) then
		atlasInfo = C_Texture.GetAtlasInfo("hud-MainMenuBar-large");
	else
		atlasInfo = C_Texture.GetAtlasInfo("hud-MainMenuBar-small");
	end

	local width = atlasInfo and atlasInfo.width or 0;
	local height = atlasInfo and atlasInfo.height or 0;
	self:SetSize(width, height);
	MainMenuBarArtFrame:SetSize(width, height);
	MainMenuBarArtFrameBackground:SetSize(width, height);
	MainMenuBarArtFrameBackground.BackgroundLarge:SetShown(rightMultiBarShowing);
	MainMenuBarArtFrameBackground.BackgroundSmall:SetShown(not rightMultiBarShowing);
	MainMenuBarArtFrame.PageNumber:ClearAllPoints();

	if rightMultiBarShowing then
		MainMenuBarArtFrame.PageNumber:SetPoint("CENTER", MainMenuBarArtFrameBackground, "CENTER", 138, -3);
	else
		MainMenuBarArtFrame.PageNumber:SetPoint("RIGHT", MainMenuBarArtFrameBackground, "RIGHT", -6, -3);
	end

	local isLargeSize = rightMultiBarShowing;
	StatusTrackingBarManager:SetBarSize(isLargeSize);
end

function MainMenuBarMixin:SetQuickKeybindModeEffectsShown(showEffects)
	local artFrameBG = self.ArtFrame.Background;
	local microBar = self.MicroButtonAndBagsBar;
	artFrameBG.QuickKeybindBottomShadow:SetShown(showEffects);
	local useLargeBackground = artFrameBG.BackgroundLarge:IsShown();
	artFrameBG.QuickKeybindGlowSmall:SetShown(not useLargeBackground and showEffects);
	artFrameBG.QuickKeybindGlowLarge:SetShown(useLargeBackground and showEffects);
	microBar.QuickKeybindsMicroBagBarGlow:SetShown(showEffects);
	local useRightShadow = MultiBarRight:IsShown();
	artFrameBG.QuickKeybindRightShadow:SetShown(useRightShadow and showEffects);
end