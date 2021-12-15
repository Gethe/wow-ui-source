PVPMatchUtil = {
	RowColors = {
		CreateColor(0.52, 0.075, 0.18), -- Horde
		CreateColor(0.72, 0.37, 1.0),	-- Horde Alternate
		CreateColor(0.11, 0.26, 0.51),	-- Alliance
		CreateColor(0.85, 0.71, 0.26),	-- Alliance Alternate
	},
	CellColors = {
		CreateColor(1.0, 0.1, 0.1),		-- Horde
		CreateColor(0.72, 0.37, 1.0),	-- Horde Alternate
		CreateColor(0.0, 0.68, 0.94),	-- Alliance
		CreateColor(1.0, 0.82, 0.0),	-- Alliance Alternate
	},
};

PVPMatchUtil.MatchTimeFormatter = CreateFromMixins(SecondsFormatterMixin);
PVPMatchUtil.MatchTimeFormatter:Init(0, SecondsFormatter.Abbreviation.Truncate, true);

function PVPMatchUtil.InSoloShuffleBrawl()
	local brawlInfo = C_PvP.GetActiveBrawlInfo();
	return brawlInfo and brawlInfo.brawlID == 130;
end

function PVPMatchUtil.IsActiveMatchComplete()
	return C_PvP.GetActiveMatchState() == Enum.PvPMatchState.Complete;
end

function PVPMatchUtil.GetColorIndex(factionIndex, useAlternateColor)
	return (useAlternateColor and 2 or 1) + (factionIndex * 2);
end

function PVPMatchUtil.GetRowColor(factionIndex, useAlternateColor)
	local index = PVPMatchUtil.GetColorIndex(factionIndex, useAlternateColor);
	return PVPMatchUtil.RowColors[index];
end

function PVPMatchUtil.GetCellColor(factionIndex, useAlternateColor)
	local index = PVPMatchUtil.GetColorIndex(factionIndex, useAlternateColor);
	return PVPMatchUtil.CellColors[index];
end

function PVPMatchUtil.SetupTableButtonColors(factionIndex, isFactionalMatch, scrollFrame)
	local buttons = HybridScrollFrame_GetButtons(scrollFrame);
	
	if C_PvP.GetCustomVictoryStatID() == 0 then
		local useAlternateColor = not isFactionalMatch;
		for k, button in pairs(buttons) do
			button:SetUseAlternateColor(useAlternateColor);
		end
	else
		for k, button in pairs(buttons) do
			button:SetBackgroundColor(PVPMatchStyle.PurpleColor);
		end
	end
end

PVPMatchStyle = {};
PVPMatchStyle.PurpleColor = CreateColor(0.557, 0.0, 1.0);

PVPMatchStyle.PanelColors = {
	CreateColor(1.0, 0.0, 0.0),		-- Horde
	PVPMatchStyle.PurpleColor,		-- Horde Alternate
	CreateColor(0.0, .376, 1.0),	-- Alliance
	CreateColor(1.0, 0.824, 0.0),	-- Alliance Alternate
};

PVPMatchStyle.Theme = {
	Horde = {
		decoratorOffsetY = -37,
		decoratorTexture = "scoreboard-horde-header",
		nineSliceLayout = "BFAMissionHorde",
	},
	Alliance = {
		decoratorOffsetY = -28,
		decoratorTexture = "scoreboard-alliance-header",
		nineSliceLayout = "BFAMissionAlliance",
	},
	Neutral = {
		nineSliceLayout = "GenericMetal",
	},
};

function PVPMatchUtil.UpdateMatchmakingText(fontString)
	if (C_PvP.GetCustomVictoryStatID() == 0 and (C_PvP.IsRatedBattleground() or C_PvP.IsRatedArena() and (not IsArenaSkirmish()))) then
		local teamInfos = { 
			C_PvP.GetTeamInfo(0),
			C_PvP.GetTeamInfo(1), 
		};

		local factionIndex = GetBattlefieldArenaFaction();
		local enemyFactionIndex = (factionIndex+1) % 2;
		local yourMMR = BreakUpLargeNumbers(teamInfos[factionIndex+1].ratingMMR);
		local enemyMMR = BreakUpLargeNumbers(teamInfos[enemyFactionIndex+1].ratingMMR);
		local yourTeamString = MATCHMAKING_YOUR_AVG_RATING:format(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(yourMMR));
		local enemyTeamString = MATCHMAKING_ENEMY_AVG_RATING:format(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(enemyMMR));
		fontString:SetText(format("%s\n%s", yourTeamString, enemyTeamString));
		fontString:Show();
	else
		fontString:Hide();
	end
end

function PVPMatchUtil.UpdateTable(tableBuilder, scrollFrame)
	local buttons = HybridScrollFrame_GetButtons(scrollFrame);
	local buttonCount = #buttons;
	local displayCount = GetNumBattlefieldScores();
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local populateCount = math.min(buttonCount, displayCount);
	tableBuilder:Populate(offset, populateCount);
	
	for i = 1, buttonCount do
		local visible = i <= displayCount;
		buttons[i]:SetShown(visible);
	end

	local buttonHeight = buttons[1]:GetHeight();
	local visibleElementHeight = displayCount * buttonHeight;
	local regionHeight = scrollFrame:GetHeight();
	HybridScrollFrame_Update(scrollFrame, visibleElementHeight, regionHeight);
end

function PVPMatchStyle.GetTeamColor(factionIndex, useAlternateColor)
	local index = PVPMatchUtil.GetColorIndex(factionIndex, useAlternateColor);
	return PVPMatchStyle.PanelColors[index];
end

function PVPMatchStyle.GetLocalPlayerFactionTheme()
	local factionGroup = UnitFactionGroup("player");
	return PVPMatchStyle.GetFactionPanelTheme(factionGroup);
end

function PVPMatchStyle.GetFactionPanelTheme(factionGroup)
	local index = PLAYER_FACTION_GROUP[factionGroup];
	return GetFactionPanelThemeByIndex(index);
end

function PVPMatchStyle.GetFactionPanelThemeByIndex(index)
	if index == 0 then
		return PVPMatchStyle.Theme.Horde;
	elseif index == 1 then
		return PVPMatchStyle.Theme.Alliance;
	end
end

function PVPMatchStyle.GetNeutralPanelTheme()
	return PVPMatchStyle.Theme.Neutral;
end