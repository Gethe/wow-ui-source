local MAINMENU_SLIDETIME = 0.30;
local MAINMENU_GONEYPOS = 130;	--Distance off screen for MainMenuBar to be completely hidden
local MAINMENU_XPOS = 0;

function ExpBar_Update()
	local currXP = UnitXP("player");
	local nextXP = UnitXPMax("player");
	MainMenuExpBar:SetMinMaxValues(min(0, currXP), nextXP);
	MainMenuExpBar:SetValue(currXP);
end


function MainMenuBar_OnLoad(self)
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("UNIT_LEVEL");
	
	MainMenuBar.state = "player";
	MainMenuBarPageNumber:SetText(GetActionBarPage());
end

local firstEnteringWorld = true;
function MainMenuBar_OnEvent(self, event, ...)
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7 = ...;
	if ( event == "ACTIONBAR_PAGE_CHANGED" ) then
		MainMenuBarPageNumber:SetText(GetActionBarPage());
	elseif ( event == "CURRENCY_DISPLAY_UPDATE" ) then
		local showTokenFrame, showTokenFrameHonor = GetCVarBool("showTokenFrame"), GetCVarBool("showTokenFrameHonor");
		if ( not showTokenFrame or not showTokenFrameHonor ) then
			local name, isHeader, isExpanded, isUnused, isWatched, count, icon;
			local hasNormalTokens;
			for index=1, GetCurrencyListSize() do
				name, isHeader, isExpanded, isUnused, isWatched, count, icon = GetCurrencyListInfo(index);
				if ( (not isHeader) and (count>0) ) then
					hasNormalTokens = true;
				end
			end
			if ( (not showTokenFrame) and (hasNormalTokens) ) then
				SetCVar("showTokenFrame", 1);
				if ( not CharacterFrame:IsVisible() ) then
					MicroButtonPulse(CharacterMicroButton, 60);
				end
				if ( not TokenFrame:IsVisible() ) then
					SetButtonPulse(CharacterFrameTab4, 60, 1);
				end
			end
			
			if ( hasNormalTokens or showTokenFrame or showTokenFrameHonor ) then
				TokenFrame_LoadUI();
				TokenFrame_Update();
				BackpackTokenFrame_Update();
			else
				CharacterFrameTab4:Hide();
			end
		else
			TokenFrame_LoadUI();
			TokenFrame_Update();
			BackpackTokenFrame_Update();
		end
	elseif ( event == "UNIT_LEVEL" and arg1 == "player" ) then
		UpdateMicroButtons();
	end
end

function MainMenuBarVehicleLeaveButton_OnLoad(self)
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
	self:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE");
	self:RegisterEvent("UNIT_EXITED_VEHICLE");
	self:RegisterEvent("VEHICLE_UPDATE");
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
		ShowPetActionBar(true);
	else
		MainMenuBarVehicleLeaveButton:Hide();
		ShowPetActionBar(true);
	end

	UIParent_ManageFramePositions();
end

function ExhaustionTick_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("PLAYER_XP_UPDATE");
	self:RegisterEvent("UPDATE_EXHAUSTION");
	self:RegisterEvent("PLAYER_LEVEL_UP");
	self:RegisterEvent("PLAYER_UPDATE_RESTING");
end

function ExhaustionTick_OnEvent(self, event, ...)
	if ((event == "PLAYER_ENTERING_WORLD") or (event == "PLAYER_XP_UPDATE") or (event == "UPDATE_EXHAUSTION") or (event == "PLAYER_LEVEL_UP")) then
		local playerCurrXP = UnitXP("player");
		local playerMaxXP = UnitXPMax("player");
		--local exhaustionCurrXP, exhaustionMaxXP;
		--exhaustionCurrXP, exhaustionMaxXP = GetXPExhaustion();
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
--			local exhaustionTotalXP = playerCurrXP + (exhaustionMaxXP - exhaustionCurrXP);
--			local exhaustionTickSet = (exhaustionTotalXP / playerMaxXP) * MainMenuExpBar:GetWidth();
			ExhaustionTick:ClearAllPoints();
			if (exhaustionTickSet > MainMenuExpBar:GetWidth() or MainMenuBarMaxLevelBar:IsShown()) then
				ExhaustionTick:Hide();
				ExhaustionLevelFillBar:Hide();
				-- Saving this code in case we want to always leave the exhaustion tick onscreen
--				ExhaustionTick:SetPoint("CENTER", "MainMenuExpBar", "RIGHT", 0, 0);
--				ExhaustionLevelFillBar:SetPoint("TOPRIGHT", "MainMenuExpBar", "TOPRIGHT", 0, 0);
			else
				ExhaustionTick:Show();
				ExhaustionTick:SetPoint("CENTER", "MainMenuExpBar", "LEFT", exhaustionTickSet, 0);
				ExhaustionLevelFillBar:Show();
				ExhaustionLevelFillBar:SetPoint("TOPRIGHT", "MainMenuExpBar", "TOPLEFT", exhaustionTickSet, 0);
			end
		end

		-- Hide exhaustion tick if player is max level or XP is turned off
		if ( UnitLevel("player") == MAX_PLAYER_LEVEL or IsXPUserDisabled() ) then
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
	-- If showing newbie tips then only show the explanation
	--[[if ( SHOW_NEWBIE_TIPS == "1" ) then
		return;
	end
	]]

	if ( SHOW_NEWBIE_TIPS ~= "1" ) then
		local x,y;
		x,y = ExhaustionTick:GetCenter();
		if ( ExhaustionTick:IsShown() ) then
			if ( x >= ( GetScreenWidth() / 2 ) ) then
				GameTooltip:SetOwner(ExhaustionTick, "ANCHOR_LEFT");
			else
				GameTooltip:SetOwner(ExhaustionTick, "ANCHOR_RIGHT");
			end
		else
			GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
		end
	end
	
	local exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier;
	exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier = GetRestState();

	-- Saving this code in case we want to display xp to next rest state
	local exhaustionCurrXP, exhaustionMaxXP;
	local exhaustionThreshold = GetXPExhaustion();
--	local exhaustionXPDifference;
--	if (exhaustionMaxXP) then
--		exhaustionXPDifference = (exhaustionMaxXP - exhaustionCurrXP) * exhaustionStateMultiplier;
--	else
--		exhaustionXPDifference = 0;
--	end

	exhaustionStateMultiplier = exhaustionStateMultiplier * 100;
	local exhaustionCountdown = nil;
	if ( GetTimeToWellRested() ) then
		exhaustionCountdown = GetTimeToWellRested() / 60;
	end
	
	local currXP = UnitXP("player");
	local nextXP = UnitXPMax("player");
	local percentXP = math.ceil(currXP/nextXP*100);
	local XPText = format( XP_TEXT, BreakUpLargeNumbers(currXP), BreakUpLargeNumbers(nextXP), percentXP );
	local tooltipText = XPText..format(EXHAUST_TOOLTIP1, exhaustionStateName, exhaustionStateMultiplier);
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

	if ( SHOW_NEWBIE_TIPS ~= "1" ) then
		GameTooltip:SetText(tooltipText);
	else
		if ( GameTooltip.canAddRestStateLine ) then
			GameTooltip:AddLine("\n"..tooltipText);
			GameTooltip:Show();
			GameTooltip.canAddRestStateLine = nil;
		end
	end

--[[
	if ((exhaustionStateID == 1) and (IsResting()) and (not exhaustionThreshold)) then
		GameTooltip:SetText(format(EXHAUST_TOOLTIP1, exhaustionStateName, exhaustionStateMultiplier));
	elseif ((exhaustionStateID == 1) and (IsResting())) then
		GameTooltip:SetText(format(EXHAUST_TOOLTIP1,exhaustionStateName,exhaustionStateMultiplier) .. format(EXHAUST_TOOLTIP4,exhaustionCountdown));
	elseif ((exhaustionStateID == 2) and (IsResting())) then
		GameTooltip:SetText(format(EXHAUST_TOOLTIP1,exhaustionStateName,exhaustionStateMultiplier) .. format(EXHAUST_TOOLTIP4,exhaustionCountdown));
	elseif ((exhaustionStateID == 3) and (IsResting())) then
		GameTooltip:SetText(format(EXHAUST_TOOLTIP1,exhaustionStateName,exhaustionStateMultiplier) .. format(EXHAUST_TOOLTIP4,exhaustionCountdown));
	elseif ((exhaustionStateID == 4) and (IsResting())) then
		GameTooltip:SetText(format(EXHAUST_TOOLTIP1,exhaustionStateName,exhaustionStateMultiplier) .. format(EXHAUST_TOOLTIP4,exhaustionCountdown));
	elseif ((exhaustionStateID == 5) and (IsResting())) then
		GameTooltip:SetText(format(EXHAUST_TOOLTIP1,exhaustionStateName,exhaustionStateMultiplier) .. format(EXHAUST_TOOLTIP4,exhaustionCountdown));
	elseif (exhaustionStateID <= 3) then
		GameTooltip:SetText(format(EXHAUST_TOOLTIP1,exhaustionStateName,exhaustionStateMultiplier));
	elseif (exhaustionStateID == 4) then
		GameTooltip:SetText(format(EXHAUST_TOOLTIP1,exhaustionStateName,exhaustionStateMultiplier) .. EXHAUST_TOOLTIP2);
	elseif (exhaustionStateID == 5) then
		GameTooltip:SetText(format(EXHAUST_TOOLTIP1,exhaustionStateName,exhaustionStateMultiplier) .. EXHAUST_TOOLTIP2);
	end
]]
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

-- We want to save which movies were downloading when the player logged in so that we can continue to show
-- those movies after the download finishes
for i, movieList in next, MovieList do
	local inProgress = MainMenu_GetMovieDownloadProgress(i);
	movieList.inProgress = inProgress;
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
	if ( SHOW_NEWBIE_TIPS == "1" ) then
		GameTooltip:AddLine(NEWBIE_TOOLTIP_LATENCY, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
	end
	GameTooltip:AddLine(" ");
	
	-- protocol types
	if GetCVarBool("useIPv6") then
		local ipTypeHome, ipTypeWorld = GetNetIpTypes();
		string = format(MAINMENUBAR_PROTOCOLS_LABEL, ipTypes[ipTypeHome or 0] or UNKNOWN, ipTypes[ipTypeWorld or 0] or UNKNOWN);
		GameTooltip:AddLine(" ");
		GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
		if ( SHOW_NEWBIE_TIPS == "1" ) then
			GameTooltip:AddLine(NEWBIE_TOOLTIP_PROTOCOLS, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
		end
		GameTooltip:AddLine(" ");
	end

	-- framerate
	string = format(MAINMENUBAR_FPS_LABEL, GetFramerate());
	GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
	if ( SHOW_NEWBIE_TIPS == "1" ) then
		GameTooltip:AddLine(NEWBIE_TOOLTIP_FRAMERATE, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
	end
	GameTooltip:AddLine(" ");

	string = format(MAINMENUBAR_BANDWIDTH_LABEL, GetAvailableBandwidth());
	GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
	if ( SHOW_NEWBIE_TIPS == "1" ) then
		GameTooltip:AddLine(NEWBIE_TOOLTIP_BANDWIDTH, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
	end
	GameTooltip:AddLine(" ");

	local percent = floor(GetDownloadedPercentage()*100+0.5);
	string = format(MAINMENUBAR_DOWNLOAD_PERCENT_LABEL, percent);
	GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
	if ( SHOW_NEWBIE_TIPS == "1" ) then
		GameTooltip:AddLine(NEWBIE_TOOLTIP_DOWNLOAD_PERCENT, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
	end
	
	-- Downloaded cinematics
	local firstMovie = true;
	for i, movieList in next, MovieList do
		if (movieList.inProgress) then
			if (firstMovie) then
				if ( SHOW_NEWBIE_TIPS == "1" ) then
					-- The "Cinematics" header looks bad when it's next to the newbie tooltip text, so add an extra line break
					GameTooltip:AddLine(" ");
				end
				GameTooltip:AddLine("   "..CINEMATICS, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
				firstMovie = false;
			end
			local inProgress, downloaded, total = MainMenu_GetMovieDownloadProgress(i);
			if (inProgress) then
				GameTooltip:AddLine("   "..format(CINEMATIC_DOWNLOAD_FORMAT, _G["CINEMATIC_NAME_"..i], downloaded/total*100), GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b, 1);
			else
				GameTooltip:AddLine("   "..format(CINEMATIC_DOWNLOAD_FORMAT, _G["CINEMATIC_NAME_"..i], downloaded/total*100), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1);
			end
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
		if ( SHOW_NEWBIE_TIPS == "1" ) then
			GameTooltip:AddLine(NEWBIE_TOOLTIP_MEMORY, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
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



function MainMenuExpBar_SetWidth(width)
	MainMenuXPBarTextureMid:SetWidth(width-28);
	
	local divWidth = width/20;
	local xpos = divWidth - 4.5;	
	for i=1,19 do
		local texture = _G["MainMenuXPBarDiv"..i];
		if not texture then
			texture = MainMenuExpBar:CreateTexture("MainMenuXPBarDiv"..i, "OVERLAY");
			texture:SetTexture("Interface\\MainMenuBar\\UI-XP-Bar");
			texture:SetSize(9,9);
			texture:SetTexCoord( 0.01562500, 0.15625000, 0.01562500, 0.17187500);
		end
		local xalign = floor(xpos);
		texture:SetPoint("LEFT", xalign, 1);
		xpos = xpos + divWidth;
	end		
	MainMenuExpBar:SetWidth(width);
	if ExhaustionTick then
		ExhaustionTick_OnEvent(ExhaustionTick, "UPDATE_EXHAUSTION");
	end
end