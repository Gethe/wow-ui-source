local MAINMENU_SLIDETIME = 0.30;
local MAINMENU_GONEYPOS = 130;	--Distance off screen for MainMenuBar to be completely hidden
local MAINMENU_XPOS = 0;

function ExpBar_Update()
	local currXP = UnitXP("player");
	local nextXP = UnitXPMax("player");
	local level = UnitLevel("player");

	local isCapped = false;
	if (GameLimitedMode_IsActive()) then
		local rLevel = GetRestrictedAccountData();
		if UnitLevel("player") >= rLevel then
			isCapped = true;
			MainMenuExpBar:SetMinMaxValues(0,1);
			MainMenuExpBar:SetValue(1)
			MainMenuExpBar:SetStatusBarColor(0.58, 0.0, 0.55, 1.0);
		end
	end
	if (not isCapped) then
		local min, max = math.min(0, currXP), nextXP;
		MainMenuExpBar:SetMinMaxValues(min,max);
		MainMenuExpBar:SetValue(currXP)
	end
end

function ExpBar_UpdateTextString() 
	TextStatusBar_UpdateTextString(MainMenuExpBar);
	if (GameLimitedMode_IsActive()) then
		local rLevel = GetRestrictedAccountData();
		if (UnitLevel("player") >= rLevel) then
			local nextXP = UnitXPMax("player");
			local trialXP = UnitTrialXP("player");
			MainMenuExpBar.TextString:SetText(MainMenuExpBar.prefix.." "..trialXP.." / "..nextXP);
		end
	end
end

function ExpBar_OnEnter(self)
	ShowTextStatusBarText(self);
	ExpBar_UpdateTextString();
	local label = XPBAR_LABEL;
	if (GameLimitedMode_IsActive()) then
		local rLevel = GetRestrictedAccountData();
		if UnitLevel("player") >= rLevel then
			local trialXP = UnitTrialXP("player");
			local bankedLevels = UnitTrialBankedLevels("player");
			if (trialXP > 0) then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
				local text = TRIAL_CAP_BANKED_XP_TOOLTIP;
				if (bankedLevels > 0) then
					text = TRIAL_CAP_BANKED_LEVELS_TOOLTIP:format(bankedLevels);
				end
				GameTooltip:SetText(text, nil, nil, nil, nil, true);
				GameTooltip:Show();
				return
			else
				label = label.." "..RED_FONT_COLOR_CODE..CAP_REACHED_TRIAL.."|r";
			end
		end
	end						
	ExhaustionTick.timer = 1;

	GameTooltip_AddNewbieTip(self, label, 1.0, 1.0, 1.0, NEWBIE_TOOLTIP_XPBAR, 1);
	GameTooltip.canAddRestStateLine = 1;
end

function MainMenuBar_OnLoad(self)
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
	self:RegisterEvent("UNIT_LEVEL");
	self:RegisterEvent("TRIAL_STATUS_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("VARIABLES_LOADED");
	self:RegisterEvent("BAG_UPDATE");

	MainMenuBar.state = "player";
	MainMenuBarPageNumber:SetText(GetActionBarPage());
end


local firstEnteringWorld = true;
function MainMenuBar_OnEvent(self, event, ...)
	if ( event == "ACTIONBAR_PAGE_CHANGED" ) then
		MainMenuBarPageNumber:SetText(GetActionBarPage());
	elseif ( event == "UNIT_LEVEL" ) then
		local unitToken = ...;
		if ( unitToken == "player" ) then
			UpdateMicroButtons();
		end
	elseif ( event == "TRIAL_STATUS_UPDATE" ) then
		UpdateMicroButtons();
	elseif ( event == "PLAYER_ENTERING_WORLD" or event == "VARIABLES_LOADED" or event == "BAG_UPDATE" ) then
		if( HasKey() ) then
			if(not GetCVarBool("showKeyring")) then
				-- Show Tutorial and flash keyring
				TriggerTutorial(50); --TUTORIAL_KEYRING
				SetButtonPulse(KeyRingButton, 60, 1);
				SetCVar("showKeyring", 1);
			end
		end
		MainMenuBar_UpdateKeyRing();
	end
end

function MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, artifactXP, artifactTier)
	local numPoints = 0;
	local xpForNextPoint = C_ArtifactUI.GetCostForPointAtRank(pointsSpent, artifactTier);
	while artifactXP >= xpForNextPoint and xpForNextPoint > 0 do
		artifactXP = artifactXP - xpForNextPoint;

		pointsSpent = pointsSpent + 1;
		numPoints = numPoints + 1;

		xpForNextPoint = C_ArtifactUI.GetCostForPointAtRank(pointsSpent, artifactTier);
	end
	return numPoints, artifactXP, xpForNextPoint;
end

function MainMenuBar_UpdateExperienceBars(newLevel)
	local name, reaction, min, max, value, factionID = GetWatchedFactionInfo();
	local visibilityChanged = nil;
	if ( not newLevel ) then
		newLevel = UnitLevel("player");
	end
	local showXP = newLevel < GetMaxPlayerLevel();
	local showRep = name;
	local numBarsShowing = 0;
	--******************* EXPERIENCE **************************************
	if ( showXP ~= MainMenuExpBar:IsShown() ) then
		visibilityChanged = true;
	end
	if ( showXP ) then
		MainMenuExpBar:Show();
		MainMenuExpBar.pauseUpdates = nil;
		numBarsShowing = numBarsShowing + 1;
	else
		MainMenuExpBar:Hide();
		MainMenuExpBar.pauseUpdates = true;
		ExhaustionTick:Hide();
	end
	--******************* REPUTATION **************************************
	if ( showRep and numBarsShowing < 2 ) then
		local colorIndex = reaction;
		-- if it's a different faction, save possible friendship id
		if ( ReputationWatchBar.factionID ~= factionID ) then
			ReputationWatchBar.factionID = factionID;
			ReputationWatchBar.friendshipID = nil;--GetFriendshipReputation(factionID);
			ReputationWatchBar.StatusBar:Reset();
		end

		local isCapped;
		-- do something different for friendships
		local level;
		if ( ReputationWatchBar.friendshipID ) then
			local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID);
			level = GetFriendshipReputationRanks(factionID);
			if ( nextFriendThreshold ) then
				min, max, value = friendThreshold, nextFriendThreshold, friendRep;
			else
				-- max rank, make it look like a full bar
				min, max, value = 0, 1, 1;
				isCapped = true;
			end
			colorIndex = 5;		-- always color friendships green
		else
			level = reaction;
		end

		-- See if it was already shown or not
		if ( not ReputationWatchBar:IsShown() ) then
			visibilityChanged = true;
		end
		
		-- Normalize values
		max = max - min;
		value = value - min;
		if ( isCapped and max == 0 ) then
			max = 1;
			value = 1;
		end
		min = 0;
		local statusBar = ReputationWatchBar.StatusBar;
		statusBar:SetMinMaxValues(min,max);
		statusBar:SetValue(value);
		if ( isCapped ) then
			ReputationWatchBar.OverlayFrame.Text:SetText(name);
		else
			ReputationWatchBar.OverlayFrame.Text:SetText(name.." "..value.." / "..max);
		end
		local color = FACTION_BAR_COLORS[colorIndex];
		statusBar:SetStatusBarColor(color.r, color.g, color.b);
		ReputationWatchBar:Show();
		MainMenuTrackingBar_Configure(ReputationWatchBar, numBarsShowing > 0);
		numBarsShowing = numBarsShowing + 1;
	else
		if ( ReputationWatchBar:IsShown() ) then
			visibilityChanged = true;
		end
		ReputationWatchBar:Hide();	
	end
	if ( numBarsShowing > 0 ) then
		MainMenuBarMaxLevelBar:Hide();
	else
		MainMenuBarMaxLevelBar:Show();
	end

	-- update the xp bar
	ExpBar_UpdateTextString();	
	ExpBar_Update();
	
	if ( visibilityChanged ) then
		UIParent_ManageFramePositions();
		UpdateContainerFrameAnchors();
	end
end

function MainMenuTrackingBar_Configure(frame, isOnTop)
	local statusBar = frame.StatusBar;
	statusBar:SetFrameLevel(MainMenuBarArtFrame:GetFrameLevel()-1);
	if ( isOnTop ) then
		statusBar:SetHeight(8);
		frame:ClearAllPoints();
		frame:SetPoint("BOTTOM", MainMenuBar, "TOP", 0, -3);
		frame.OverlayFrame.Text:SetPoint("CENTER", frame.OverlayFrame, "CENTER", 0, 3);
		statusBar.WatchBarTexture0:Show();
		statusBar.WatchBarTexture1:Show();
		statusBar.WatchBarTexture2:Show();
		statusBar.WatchBarTexture3:Show();

		statusBar.XPBarTexture0:Hide();
		statusBar.XPBarTexture1:Hide();
		statusBar.XPBarTexture2:Hide();
		statusBar.XPBarTexture3:Hide();	
	else
		statusBar:SetHeight(13);
		frame:ClearAllPoints();
		frame:SetPoint("TOP", MainMenuBar, "TOP", 0, 0);
		frame.OverlayFrame.Text:SetPoint("CENTER", frame.OverlayFrame, "CENTER", 0, 1);
		statusBar.WatchBarTexture0:Hide();
		statusBar.WatchBarTexture1:Hide();
		statusBar.WatchBarTexture2:Hide();
		statusBar.WatchBarTexture3:Hide();

		statusBar.XPBarTexture0:Show();
		statusBar.XPBarTexture1:Show();
		statusBar.XPBarTexture2:Show();
		statusBar.XPBarTexture3:Show();
	end
end

function MainMenuBarVehicleLeaveButton_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
end

function MainMenuBarVehicleLeaveButton_OnEnter(self)
	if ( UnitOnTaxi("player") ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(TAXI_CANCEL, 1, 1, 1);
		GameTooltip:AddLine(TAXI_CANCEL_DESCRIPTION, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		GameTooltip:Show();
	else
		GameTooltip_AddNewbieTip(self, LEAVE_VEHICLE, 1.0, 1.0, 1.0, nil);
	end
end

function MainMenuBarVehicleLeaveButton_OnEvent(self, event, ...)
	MainMenuBarVehicleLeaveButton_Update();
end

function MainMenuBarVehicleLeaveButton_Update()
	if ( UnitOnTaxi("player") and ActionBarController_GetCurrentActionBarState() == LE_ACTIONBAR_STATE_MAIN ) then
		MainMenuBarVehicleLeaveButton:ClearAllPoints();
		if ( GetNumShapeshiftForms() > 0 ) then
			MainMenuBarVehicleLeaveButton:SetPoint("LEFT", "StanceButton"..GetNumShapeshiftForms(), "RIGHT", 30, 0);
		else
			MainMenuBarVehicleLeaveButton:SetPoint("LEFT", StanceBarFrame, "LEFT", 10, 0);
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
	end
end

function ExhaustionTick_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_XP_UPDATE");
	self:RegisterEvent("UPDATE_EXHAUSTION");
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("PLAYER_UPDATE_RESTING");
end

function ExhaustionTick_OnEvent(self, event, ...)
	if (IsRestrictedAccount()) then
		local rlevel = GetRestrictedAccountData();
		if (UnitLevel("player") >= rlevel) then
			MainMenuExpBar:SetStatusBarColor(0.0, 0.39, 0.88, 1.0);
			ExhaustionTick:Hide();
			ExhaustionLevelFillBar:Hide();
			self:UnregisterAllEvents();	
			return;
		end
	end
	if ((event == "PLAYER_ENTERING_WORLD") or (event == "PLAYER_XP_UPDATE") or (event == "UPDATE_EXHAUSTION") or (event == "PLAYER_LEVEL_UP")) then
		local playerCurrXP = UnitXP("player");
		local playerMaxXP = UnitXPMax("player");
		local exhaustionThreshold = GetXPExhaustion();
		local exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier;
		exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier = GetRestState();
		if (exhaustionStateID >= 3) then
			ExhaustionTick:SetPoint("CENTER", "MainMenuExpBar", "RIGHT", 0, 0);
		end

		if (not exhaustionThreshold) then
			ExhaustionTick:Hide();
			ExhaustionLevelFillBar:Hide();
		else
			local exhaustionTickSet = max(((playerCurrXP + exhaustionThreshold) / playerMaxXP) * MainMenuExpBar:GetWidth(), 0);
			ExhaustionTick:ClearAllPoints();
			if (exhaustionTickSet > MainMenuExpBar:GetWidth() or MainMenuBarMaxLevelBar:IsShown()) then
				ExhaustionTick:Hide();
				ExhaustionLevelFillBar:Hide();
			else
				ExhaustionTick:Show();
				ExhaustionTick:SetPoint("CENTER", "MainMenuExpBar", "LEFT", exhaustionTickSet, 0);
				ExhaustionLevelFillBar:Show();
				ExhaustionLevelFillBar:SetPoint("TOPRIGHT", "MainMenuExpBar", "TOPLEFT", exhaustionTickSet, 0);
			end
		end

		-- Hide exhaustion tick if player is max level or XP is turned off
		if ( UnitLevel("player") == GetMaxPlayerLevel() ) then
			ExhaustionTick:Hide();
		end
	end
	if ((event == "PLAYER_ENTERING_WORLD") or (event == "UPDATE_EXHAUSTION")) then
		local exhaustionStateID = GetRestState();
		if (exhaustionStateID == 1) then
			MainMenuExpBar:SetStatusBarColor(0.0, 0.39, 0.88, 1.0);
			ExhaustionLevelFillBar:SetVertexColor(0.0, 0.39, 0.88, 0.15);
			ExhaustionTickHighlight:SetVertexColor(0.0, 0.39, 0.88);
		elseif (exhaustionStateID == 2) then
			MainMenuExpBar:SetStatusBarColor(0.58, 0.0, 0.55, 1.0);
			ExhaustionLevelFillBar:SetVertexColor(0.58, 0.0, 0.55, 0.15);
			ExhaustionTickHighlight:SetVertexColor(0.58, 0.0, 0.55);
		end

	end
	if ( not MainMenuExpBar:IsShown() ) then
		ExhaustionTick:Hide();
	end
end

function ExhaustionToolTipText()
	if ( GetCVar("showNewbieTips") ~= "1" ) then
		local x,y = ExhaustionTick:GetCenter();
		if ( ExhaustionTick:IsVisible() ) then
			if ( x >= ( GetScreenWidth() / 2 ) ) then
				GameTooltip:SetOwner(ExhaustionTick, "ANCHOR_LEFT");
			else
				GameTooltip:SetOwner(ExhaustionTick, "ANCHOR_RIGHT");
			end
		else
			GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
		end
	end

	local exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier = GetRestState();

	local exhaustionThreshold = GetXPExhaustion();
	exhaustionStateMultiplier = exhaustionStateMultiplier * 100;
	local exhaustionCountdown = nil;
	if ( GetTimeToWellRested() ) then
		exhaustionCountdown = GetTimeToWellRested() / 60;
	end
	
	local tooltipText = format(EXHAUST_TOOLTIP1, exhaustionStateName, exhaustionStateMultiplier);
	local append = nil;
	if ( IsResting() ) then
		if ( exhaustionThreshold and exhaustionCountdown ) then
			append = format(EXHAUST_TOOLTIP4, exhaustionCountdown);
		end
	elseif ( (exhaustionStateID == 4) or (exhaustionStateID == 5) ) then
		append = EXHAUST_TOOLTIP2;
	end

	if ( append ) then
		tooltipText = tooltipText..append;
	end

	if ( GetCVar("showNewbieTips") ~= "1" ) then
		GameTooltip:SetText(tooltipText);
	else
		if ( GameTooltip.canAddRestStateLine ) then
			GameTooltip:AddLine("\n"..tooltipText);
			GameTooltip:Show();
			GameTooltip.canAddRestStateLine = nil;
		end
	end
end

function ExhaustionTick_OnUpdate(self, elapsed)
	if ( self.timer ) then
		if ( self.timer < 0 ) then
			ExhaustionToolTipText();
			self.timer = nil;
		else
			self.timer = self.timer - elapsed;
		end
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
	
	GameTooltip_AddNewbieTip(self, self.tooltipText, 1.0, 1.0, 1.0, self.newbieText);
	
	-- latency
	local bandwidthIn, bandwidthOut, latencyHome, latencyWorld = GetNetStats();
	string = format(MAINMENUBAR_LATENCY_LABEL, latencyHome, latencyWorld);
	GameTooltip:AddLine(" ");
	GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
	if ( GetCVar("showNewbieTips") == "1" ) then
		GameTooltip:AddLine(NEWBIE_TOOLTIP_LATENCY, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	end
	GameTooltip:AddLine(" ");
	
	-- protocol types
	if GetCVarBool("useIPv6") then
		local ipTypeHome, ipTypeWorld = GetNetIpTypes();
		string = format(MAINMENUBAR_PROTOCOLS_LABEL, ipTypes[ipTypeHome or 0] or UNKNOWN, ipTypes[ipTypeWorld or 0] or UNKNOWN);
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
		if ( GetCVar("showNewbieTips") == "1" ) then
			GameTooltip:AddLine(NEWBIE_TOOLTIP_PROTOCOLS, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		end
		GameTooltip:AddLine(" ");
	end

	-- framerate
	string = format(MAINMENUBAR_FPS_LABEL, GetFramerate());
	GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
	if ( GetCVar("showNewbieTips") == "1" ) then
		GameTooltip:AddLine(NEWBIE_TOOLTIP_FRAMERATE, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	end
	GameTooltip:AddLine(" ");

	string = format(MAINMENUBAR_BANDWIDTH_LABEL, GetAvailableBandwidth());
	GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
	if ( GetCVar("showNewbieTips") == "1" ) then
		GameTooltip:AddLine(NEWBIE_TOOLTIP_BANDWIDTH, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	end
	GameTooltip:AddLine(" ");

	local percent = floor(GetDownloadedPercentage()*100+0.5);
	string = format(MAINMENUBAR_DOWNLOAD_PERCENT_LABEL, percent);
	GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
	if ( GetCVar("showNewbieTips") == "1" ) then
		GameTooltip:AddLine(NEWBIE_TOOLTIP_DOWNLOAD_PERCENT, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
	end
	
	-- Downloaded cinematics
	local firstMovie = true;
	for i, movieList in next, MovieList do
		local inProgress, downloaded, total = MainMenu_GetMovieDownloadProgress(i);
		if (inProgress) then
			if (firstMovie) then
				if ( GetCVar("showNewbieTips") == "1" ) then
					-- The "Cinematics" header looks bad when it's next to the newbie tooltip text, so add an extra line break
					GameTooltip:AddLine(" ");
				end
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
			if(mem > topAddOns[j].value) then
				for k=NUM_ADDONS_TO_DISPLAY, 1, -1 do
					if(k == j) then
						topAddOns[k].value = mem;
						topAddOns[k].name = GetAddOnInfo(i);
						break;
					elseif(k ~= 1) then
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
		if ( GetCVar("showNewbieTips") == "1" ) then
			GameTooltip:AddLine(NEWBIE_TOOLTIP_MEMORY, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
		end
		
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

function ShowWatchBarText(bar, lock)
	if ( lock ) then
		bar.cvarLocked = lock;
	end
	if ( bar:IsShown() ) then
		bar.OverlayFrame.Text:Show();
		bar.textLocked = 1;
	else
		HideWatchBarText(bar);
	end
end

function HideWatchBarText(bar, unlock)
	if ( unlock or not bar.cvarLocked ) then
		bar.cvarLocked = nil;
		bar.OverlayFrame.Text:Hide();
		bar.textLocked = nil;
	end
end

function MainMenuBar_UpdateKeyRing()
	if ( GetCVarBool("showKeyring") ) then
		MainMenuBarTexture3:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-KeyRing");
		MainMenuBarTexture3:SetTexCoord(0, 1, 0.1640625, 0.5);
		MainMenuBarTexture2:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-KeyRing");
		MainMenuBarTexture2:SetTexCoord(0, 1, 0.6640625, 1);
		MainMenuBarPerformanceBarFrame:SetPoint("BOTTOMRIGHT", MainMenuBar, "BOTTOMRIGHT", -235, -10);
		KeyRingButton:Show();
	end
end
