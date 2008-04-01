function MainMenuExpBar_Update()
	local currXP = UnitXP("player");
	local nextXP = UnitXPMax("player");
	MainMenuExpBar:SetMinMaxValues(min(0, currXP), nextXP);
	MainMenuExpBar:SetValue(currXP);
end

function ExhaustionTick_OnLoad()
	this:RegisterEvent("PLAYER_XP_UPDATE");
	this:RegisterEvent("UPDATE_EXHAUSTION");
	this:RegisterEvent("PLAYER_LEVEL_UP");
	this:RegisterEvent("PLAYER_UPDATE_RESTING");
	this:RegisterEvent("PLAYER_ENTERING_WORLD");
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
			ExhaustionTick:Show();
			ExhaustionLevelFillBar:Show();
--			local exhaustionTotalXP = playerCurrXP + (exhaustionMaxXP - exhaustionCurrXP);
--			local exhaustionTickSet = (exhaustionTotalXP / playerMaxXP) * MainMenuExpBar:GetWidth();
			ExhaustionTick:ClearAllPoints();
			if (exhaustionTickSet > MainMenuExpBar:GetWidth()) then
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
end

function ExhaustionToolTipText()
	-- If showing newbie tips then only show the explanation
	if ( SHOW_NEWBIE_TIPS == "1" ) then
		return;
	end

	local x,y;
	x,y = ExhaustionTick:GetCenter();
	if ( ExhaustionTick:IsVisible() ) then
		if ( x >= ( GetScreenWidth() / 2 ) ) then
			GameTooltip:SetOwner(ExhaustionTick, "ANCHOR_LEFT");
		else
			GameTooltip:SetOwner(ExhaustionTick, "ANCHOR_RIGHT");
		end
	else
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
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

	GameTooltip:SetText(tooltipText);

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