function MainMenuExpBar_Update()
	local currXP = UnitXP("player");
	local nextXP = UnitXPMax("player");
	MainMenuExpBar:SetMinMaxValues(min(0, currXP), nextXP);
	MainMenuExpBar:SetValue(currXP);
end

function ExhaustionTick_OnLoad()
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
	this:RegisterEvent("PLAYER_XP_UPDATE");
	this:RegisterEvent("UPDATE_EXHAUSTION");
	this:RegisterEvent("PLAYER_LEVEL_UP");
	this:RegisterEvent("PLAYER_UPDATE_RESTING");
end

function ExhaustionTick_Update()
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

		-- Hide exhaustion tick if player is max level and the reputation watch bar is shown
		if ( UnitLevel("player") == MAX_PLAYER_LEVEL and ReputationWatchBar:IsShown() ) then
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
	if ( ReputationWatchBar:IsShown() and not MainMenuExpBar:IsShown() ) then
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

function ExhaustionTick_OnUpdate(elapsed)
	if ( ExhaustionTick.timer ) then
		if ( ExhaustionTick.timer < 0 ) then
			ExhaustionToolTipText();
			ExhaustionTick.timer = nil;
		else
			ExhaustionTick.timer = ExhaustionTick.timer - elapsed;
		end
	end
end

--KeyRing Functions

function MainMenuBar_UpdateKeyRing()
	if ( SHOW_KEYRING == 1 ) then
		MainMenuBarTexture3:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-KeyRing");
		MainMenuBarTexture3:SetTexCoord(0, 1, 0.1640625, 0.5);
		MainMenuBarTexture2:SetTexture("Interface\\MainMenuBar\\UI-MainMenuBar-KeyRing");
		MainMenuBarTexture2:SetTexCoord(0, 1, 0.6640625, 1);
		MainMenuBarPerformanceBarFrame:SetPoint("BOTTOMRIGHT", MainMenuBar, "BOTTOMRIGHT", -235, -10);
		KeyRingButton:Show();
	end
end

-- latency bar

local NUM_ADDONS_TO_DISPLAY = 3;
local topAddOns = {}
for i=1, NUM_ADDONS_TO_DISPLAY do
	topAddOns[i] = { value = 0, name = "" };
end

function MainMenuBarPerformanceBarFrame_OnEnter()
	local string = "";
	local i=0; j=0; k=0;

	GameTooltip_SetDefaultAnchor(GameTooltip, this);

	-- latency
	local bandwidthIn, bandwidthOut, latency = GetNetStats();
	string = format(MAINMENUBAR_LATENCY_LABEL, latency);
	GameTooltip:SetText(string, 1.0, 1.0, 1.0);
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
