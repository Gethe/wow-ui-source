local MAINMENU_SLIDETIME = 0.30;
local MAINMENU_GONEYPOS = 130;	--Distance off screen for MainMenuBar to be completely hidden
local MAINMENU_XPOS = 0;
local MAINMENU_VEHICLE_ENDCAPPOS = 548;

function MainMenuExpBar_Update()
	local currXP = UnitXP("player");
	local nextXP = UnitXPMax("player");
	MainMenuExpBar:SetMinMaxValues(min(0, currXP), nextXP);
	MainMenuExpBar:SetValue(currXP);
end

local function MainMenuBar_GetAnimPos(self, fraction)	
	return "BOTTOM", UIParent, "BOTTOM", MAINMENU_XPOS, (sin(fraction*90+90)-1) * MAINMENU_GONEYPOS;
end

local function MainMenuBar_GetRightABPos(self, fraction)

	local finaloffset;
	if ( SHOW_MULTI_ACTIONBAR_3 and SHOW_MULTI_ACTIONBAR_4 ) then
		finaloffset = 100;
	else
		finaloffset = 62;
	end
	
	return "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", (sin(fraction*90)) * finaloffset, 98;
end

local function MainMenuBar_GetSeatIndicatorPos(self, fraction)

	local finaloffset;
	if ( SHOW_MULTI_ACTIONBAR_3 and SHOW_MULTI_ACTIONBAR_4 ) then
		finaloffset = -100;
	elseif ( SHOW_MULTI_ACTIONBAR_3 ) then
		finaloffset = -62;
	else
		finaloffset = 0;
	end
	
	return "TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", (cos(fraction*90)) * finaloffset, -13;
end

function MainMenuBar_AnimFinished(self)
	MainMenuBar.busy = false;
	if ( GetBonusBarOffset() > 0 ) then
		ShowBonusActionBar(true);
	else
		HideBonusActionBar(true);
	end
	MainMenuBar_UpdateArt(self);
end

function MainMenuBar_UnlockAB(self)
	MultiBarRight.ignoreFramePositionManager = nil;
end

function MainMenuBar_UpdateArt(self)
	if ( MainMenuBar.animComplete and not MainMenuBar.busy) then
		if ( UnitHasVehicleUI("player") ) then
			MainMenuBar_ToVehicleArt(self);
		else
			if ( MainMenuBar.state ~= "player" ) then
				MainMenuBar_ToPlayerArt(self)
			else
				MainMenuBarVehicleLeaveButton_Update();
			end
		end
	end
end

local AnimDataTable = {
	MenuBar_Slide = {
		totalTime = MAINMENU_SLIDETIME,
		updateFunc = "SetPoint",
		getPosFunc = MainMenuBar_GetAnimPos,
	},
	ActionBar_Slide = {
		totalTime = MAINMENU_SLIDETIME,
		updateFunc = "SetPoint",
		getPosFunc = MainMenuBar_GetRightABPos,
	},
	SeatIndicator_Slide = {
		totalTime = MAINMENU_SLIDETIME,
		updateFunc = "SetPoint",
		getPosFunc = MainMenuBar_GetSeatIndicatorPos,
	},
}

function MainMenuBar_ToVehicleArt(self)
	MainMenuBar.state = "vehicle";
	
	SetUpAnimation(VehicleMenuBar, AnimDataTable.MenuBar_Slide, nil, true);
	
	MultiBarLeft:Hide();
	MultiBarRight:Hide();
	MultiBarBottomLeft:Hide();
	MultiBarBottomRight:Hide();
	
	MainMenuBar:Hide();
	VehicleMenuBar:SetPoint(MainMenuBar_GetAnimPos(VehicleMenuBar, 1))
	VehicleMenuBar:Show();
	PossessBar_Update(true);
	ShowBonusActionBar(true);	--Now, when we are switching to vehicle art we will ALWAYS be using the BonusActionBar
	UIParent_ManageFramePositions();	--This is called in PossessBar_Update, but it doesn't actually do anything but change an attribute, so it is worth keeping	
	
	VehicleMenuBar_SetSkin(VehicleMenuBar.skin, IsVehicleAimAngleAdjustable());
end

function MainMenuBar_ToPlayerArt(self)
	MainMenuBar.state = "player";
	
	MultiActionBar_Update();
	
	MultiBarRight:SetPoint(MainMenuBar_GetRightABPos(MultiBarRight, 1));
	
	SetUpAnimation(MainMenuBar, AnimDataTable.MenuBar_Slide, nil, true);
	SetUpAnimation(MultiBarRight, AnimDataTable.ActionBar_Slide, MainMenuBar_UnlockAB, true);
	SetUpAnimation(VehicleSeatIndicator, AnimDataTable.SeatIndicator_Slide, nil, true);
	
	
	
	VehicleMenuBar:Hide();
	
	
	MainMenuBar:Show();

	PossessBar_Update(true);
	if ( GetBonusBarOffset() > 0 ) then
		ShowBonusActionBar(true);
	else
		HideBonusActionBar(true);
	end
	--UIParent_ManageFramePositions()	--This is called in PossessBar_Update
	MainMenuBarVehicleLeaveButton_Update();
	
	VehicleMenuBar_MoveMicroButtons();
	VehicleMenuBar_ReleaseSkins();
end

function MainMenuBarVehicleLeaveButton_OnLoad(self)
	self:RegisterEvent("UPDATE_BONUS_ACTIONBAR");
	self:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR");
	self:RegisterEvent("VEHICLE_UPDATE");
end

function MainMenuBarVehicleLeaveButton_OnEvent(self, event, ...)
	MainMenuBarVehicleLeaveButton_Update();
end

function MainMenuBarVehicleLeaveButton_Update()
	if ( CanExitVehicle() ) then
		MainMenuBarVehicleLeaveButton:ClearAllPoints();
		if ( IsPossessBarVisible() ) then
			MainMenuBarVehicleLeaveButton:SetPoint("LEFT", PossessButton2, "RIGHT", 30, 0);
		elseif ( GetNumShapeshiftForms() > 0 ) then
			MainMenuBarVehicleLeaveButton:SetPoint("LEFT", "ShapeshiftButton"..GetNumShapeshiftForms(), "RIGHT", 30, 0);
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

function MainMenuBar_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("BAG_UPDATE");
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED");
	self:RegisterEvent("KNOWN_CURRENCY_TYPES_UPDATE");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	self:RegisterEvent("ADDON_LOADED");
	self:RegisterEvent("UNIT_ENTERING_VEHICLE");
	self:RegisterEvent("UNIT_ENTERED_VEHICLE");
	self:RegisterEvent("UNIT_EXITING_VEHICLE");
	self:RegisterEvent("UNIT_EXITED_VEHICLE");
	
	MainMenuBar.state = "player";
	MainMenuBarPageNumber:SetText(GetActionBarPage());
end

local firstEnteringWorld = true;
function MainMenuBar_OnEvent(self, event, ...)
	local arg1, arg2, arg3, arg4, arg5 = ...;
	if ( event == "ACTIONBAR_PAGE_CHANGED" ) then
		MainMenuBarPageNumber:SetText(GetActionBarPage());
	elseif ( event == "KNOWN_CURRENCY_TYPES_UPDATE" or event == "CURRENCY_DISPLAY_UPDATE" ) then
		local showTokenFrame, showTokenFrameHonor = GetCVarBool("showTokenFrame"), GetCVarBool("showTokenFrameHonor");
		if ( not showTokenFrame or not showTokenFrameHonor ) then
			local name, isHeader, isExpanded, isUnused, isWatched, count, icon, extraCurrencyType;
			local hasPVPTokens, hasNormalTokens;
			for index=1, GetCurrencyListSize() do
				name, isHeader, isExpanded, isUnused, isWatched, count, extraCurrencyType, icon = GetCurrencyListInfo(index);
				if ( (not isHeader) and (extraCurrencyType > 0) and (count>0) ) then
					hasPVPTokens = true;
				elseif ( (not isHeader) and (extraCurrencyType <= 0) and (count>0) ) then
					hasNormalTokens = true;
				end
			end
			if ( (not showTokenFrame) and (hasNormalTokens) ) then
				SetCVar("showTokenFrame", 1);
				if ( not CharacterFrame:IsVisible() ) then
					SetButtonPulse(CharacterMicroButton, 60, 1);
				end
				if ( not TokenFrame:IsVisible() ) then
					SetButtonPulse(CharacterFrameTab5, 60, 1);
				end
			end
			if ( (not showTokenFrameHonor) and (hasPVPTokens) ) then
				SetCVar("showTokenFrameHonor", 1);
				if ( not CharacterFrame:IsVisible() ) then
					SetButtonPulse(CharacterMicroButton, 60, 1);
				end
				if ( not TokenFrame:IsVisible() ) then
					SetButtonPulse(CharacterFrameTab5, 60, 1);
				end
			end
			if ( hasNormalTokens or hasPVPTokens or showTokenFrame or showTokenFrameHonor ) then
				TokenFrame_LoadUI();
				TokenFrame_Update();
				BackpackTokenFrame_Update();
			else
				CharacterFrameTab5:Hide();
			end
		else
			TokenFrame_LoadUI();
			TokenFrame_Update();
			BackpackTokenFrame_Update();
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		MainMenuBar_UpdateKeyRing();
		if ( not firstEnteringWorld ) then
			MainMenuBar_ToPlayerArt();
		end
		firstEnteringWorld = false;
	elseif ( event == "BAG_UPDATE" ) then
		if ( not GetCVarBool("showKeyring") ) then
			if ( HasKey() ) then
				-- Show Tutorial and flash keyring
				SetButtonPulse(KeyRingButton, 60, 1);
				SetCVar("showKeyring", 1);
			end
			MainMenuBar_UpdateKeyRing();
		end
	elseif ( (event == "UNIT_ENTERED_VEHICLE") and (arg1=="player") ) then
		MainMenuBar.animComplete = true;
		MainMenuBar_UpdateArt(self);
	elseif ( (event == "UNIT_EXITED_VEHICLE") and (arg1=="player") )then
		MainMenuBar.animComplete = true;
		MainMenuBar_UpdateArt(self);
	elseif ( (event == "UNIT_ENTERING_VEHICLE") and (arg1=="player") ) then
		MainMenuBar.busy = true;
		MainMenuBar.animComplete = false;
		VehicleMenuBar.skin = arg3;
		if ( arg2 ) then	--We are going to show a vehicle UI
			if ( MainMenuBar.state == "vehicle" ) then
				MultiBarRight.ignoreFramePositionManager = true;
				SetUpAnimation(VehicleMenuBar, AnimDataTable.MenuBar_Slide, MainMenuBar_AnimFinished, false);
			else
				MainMenuBar.state = "vehicle";
				MultiBarRight.ignoreFramePositionManager = true;
				SetUpAnimation(MultiBarRight, AnimDataTable.ActionBar_Slide, nil, false);
				SetUpAnimation(MainMenuBar, AnimDataTable.MenuBar_Slide, MainMenuBar_AnimFinished, false);
				SetUpAnimation(VehicleSeatIndicator, AnimDataTable.SeatIndicator_Slide, nil, false);
			end
		else
			if ( MainMenuBar.state == "vehicle" ) then
				MultiBarRight.ignoreFramePositionManager = true;
				SetUpAnimation(VehicleMenuBar, AnimDataTable.MenuBar_Slide, MainMenuBar_AnimFinished, false);
				--MainMenuBar_SetUpAnimation(MultiBarRight, true, MAINMENU_SLIDETIME, MainMenuBar_GetRightABPos, nil, true);
			else
				MainMenuBar.busy = false;
				MainMenuBar.animComplete = true;
				MainMenuBarVehicleLeaveButton_Update();
			end
		end
	elseif ( (event == "UNIT_EXITING_VEHICLE") and (arg1=="player") ) then
		if ( MainMenuBar.state ~= "player" ) then
			MainMenuBar.busy = true;
			MainMenuBar.animComplete = false;
			MultiBarRight.ignoreFramePositionManager = true;
			SetUpAnimation(VehicleMenuBar, AnimDataTable.MenuBar_Slide, MainMenuBar_AnimFinished, false);
		else
			if ( GetBonusBarOffset() > 0 ) then
				ShowBonusActionBar();
			else
				HideBonusActionBar();
			end
		end
		
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

	local XPText = format( XP_TEXT, currXP, nextXP, percentXP );
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

--KeyRing Functions

function MainMenuBar_UpdateKeyRing()
	if ( GetCVarBool("showKeyring") ) then
		MainMenuBarTexture3:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-KeyRing");
		MainMenuBarTexture3:SetTexCoord(0, 1, 0.1640625, 0.5);
		MainMenuBarTexture2:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-KeyRing");
		MainMenuBarTexture2:SetTexCoord(0, 1, 0.6640625, 1);
		KeyRingButton:Show();
	end
end

-- latency bar

local NUM_ADDONS_TO_DISPLAY = 3;
local topAddOns = {}
for i=1, NUM_ADDONS_TO_DISPLAY do
	topAddOns[i] = { value = 0, name = "" };
end

function MainMenuBarPerformanceBarFrame_OnEnter(self)
	local string = "";
	local i, j, k = 0, 0, 0;

	GameTooltip_SetDefaultAnchor(GameTooltip, self);
	
	GameTooltip_AddNewbieTip(self, self.tooltipText, 1.0, 1.0, 1.0, self.newbieText);

	-- latency
	local bandwidthIn, bandwidthOut, latency = GetNetStats();
	string = format(MAINMENUBAR_LATENCY_LABEL, latency);
	GameTooltip:AddLine("\n");
	GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
	if ( SHOW_NEWBIE_TIPS == "1" ) then
		GameTooltip:AddLine(NEWBIE_TOOLTIP_LATENCY, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
	end
	GameTooltip:AddLine("\n");

	-- framerate
	string = format(MAINMENUBAR_FPS_LABEL, GetFramerate());
	GameTooltip:AddLine(string, 1.0, 1.0, 1.0);
	if ( SHOW_NEWBIE_TIPS == "1" ) then
		GameTooltip:AddLine(NEWBIE_TOOLTIP_FRAMERATE, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1);
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
