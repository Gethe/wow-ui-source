PVPMatchUtil = {
	RowColors = {
		PVP_SCOREBOARD_HORDE_ROW_COLOR,
		PVP_SCOREBOARD_HORDE_ALT_ROW_COLOR,
		PVP_SCOREBOARD_ALLIANCE_ROW_COLOR,
		PVP_SCOREBOARD_ALLIANCE_ALT_ROW_COLOR,
	},
	CellColors = {
		PVP_SCOREBOARD_HORDE_CELL_COLOR,
		PVP_SCOREBOARD_HORDE_ALT_CELL_COLOR,
		PVP_SCOREBOARD_ALLIANCE_CELL_COLOR,
		PVP_SCOREBOARD_ALLIANCE_ALT_CELL_COLOR,
	},
};

PVPMatchUtil.MatchTimeFormatter = CreateFromMixins(SecondsFormatterMixin);
PVPMatchUtil.MatchTimeFormatter:Init(0, SecondsFormatter.Abbreviation.Truncate, true);

function PVPMatchUtil.InSoloShuffleBrawl()
	local brawlInfo = C_PvP.GetActiveBrawlInfo();
	return brawlInfo and brawlInfo.brawlID == 130;
end

function PVPMatchUtil.ModeUsesPvpRatingTiers()
	-- Arena skirmishes and brawls like Solo Shuffle/Battleground Blitz only use rating for matchmaking purposes
	-- They do not have rating tiers (Combatant, Challenger, Rival, etc.) or tier rewards
	if IsArenaSkirmish() or C_PvP.IsBrawlSoloShuffle() or C_PvP.IsBrawlSoloRBG() then
		return false;
	end

	return C_PvP.IsRatedMap() or C_PvP.IsRatedSoloRBG();
end

function PVPMatchUtil.IsActiveMatchComplete()
	return C_PvP.IsMatchComplete();
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

PVPMatchStyle = {};
PVPMatchStyle.PurpleColor = CreateColor(0.557, 0.0, 1.0);

PVPMatchStyle.PanelColors = {
	CreateColor(1.0, 0.0, 0.0),		-- Horde
	PVPMatchStyle.PurpleColor,					-- Horde Alternate
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

local function ShouldShowMatchmakingText()
	if C_PvP.IsRatedSoloShuffle() then
		return true;
	end

	-- Ignore modes with a custom victory condition (aside from Rated Solo Shuffle)
	if C_PvP.GetCustomVictoryStatID() ~= 0 then
		return false;
	end

	return  C_PvP.IsSoloRBG() or
			C_PvP.IsRatedBattleground() or
			(C_PvP.IsRatedArena() and not IsArenaSkirmish());
end

function PVPMatchUtil.UpdateMatchmakingText(fontString)
	if ShouldShowMatchmakingText() then
		local teamInfos = { 
			C_PvP.GetTeamInfo(0),
			C_PvP.GetTeamInfo(1), 
		};

		local yourTeamString, enemyTeamString;
		if C_PvP.IsRatedSoloShuffle() then
			if PVPMatchUtil.IsActiveMatchComplete() then
				local localPlayerScoreInfo = C_PvP.GetScoreInfoByPlayerGuid(GetPlayerGuid());
				local prematchMMR = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(BreakUpLargeNumbers(localPlayerScoreInfo.prematchMMR));
				local postmatchMMR = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(BreakUpLargeNumbers(localPlayerScoreInfo.postmatchMMR));
				yourTeamString = MATCHMAKING_YOUR_UPDATED_MATCHMAKING_VALUE:format(prematchMMR, postmatchMMR);
			else
				yourTeamString = BATTLEGROUND_YOUR_PERSONAL_RATING:format(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(BreakUpLargeNumbers(teamInfos[1].ratingMMR)));
			end

			-- For Rated Solo Shuffle the "enemy MMR" we receive is the average MMR of all players with your LFG role.
			local roleAverageMMR = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(BreakUpLargeNumbers(teamInfos[2].ratingMMR));
			enemyTeamString = BATTLEGROUND_ROLE_AVERAGE_MMV:format(roleAverageMMR);
		else
			local factionIndex = GetBattlefieldArenaFaction();
			local enemyFactionIndex = (factionIndex+1) % 2;
			yourTeamString = MATCHMAKING_YOUR_AVG_RATING:format(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(BreakUpLargeNumbers(teamInfos[factionIndex+1].ratingMMR)));
			enemyTeamString = MATCHMAKING_ENEMY_AVG_RATING:format(HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(BreakUpLargeNumbers(teamInfos[enemyFactionIndex+1].ratingMMR)));
		end

		fontString:SetText(format("%s\n%s", yourTeamString, enemyTeamString));
		fontString:Show();
	else
		fontString:Hide();
	end
end

function PVPMatchUtil.UpdateDataProvider(scrollBox, forceNewDataProvider)
	local scores = GetNumBattlefieldScores();
	if scrollBox:GetDataProviderSize() ~= scores or forceNewDataProvider then
		local useAlternateColor = not C_PvP.IsMatchFactional();
		local dataProvider = CreateDataProvider();

		if C_PvP.GetCustomVictoryStatID() == 0 then
			for index = 1, scores do 
				dataProvider:Insert({index=index, useAlternateColor=useAlternateColor});
			end
		else
			local isMatchComplete = PVPMatchUtil.IsActiveMatchComplete();
			for index = 1, scores do 
				if isMatchComplete then
					local scoreInfo = C_PvP.GetScoreInfo(index);
					local isLocalPlayer = scoreInfo and IsPlayerGuid(scoreInfo.guid);
					local backgroundColor = isLocalPlayer and PVP_SCOREBOARD_ALLIANCE_ALT_ROW_COLOR or PVP_SCOREBOARD_HORDE_ALT_ROW_COLOR;
					dataProvider:Insert({index=index, backgroundColor=backgroundColor});
				else
					dataProvider:Insert({index=index, useAlternateColor=useAlternateColor});
				end
			end
		end

		local retainScrollPosition = not forceNewDataProvider;
		scrollBox:SetDataProvider(dataProvider, retainScrollPosition);
	end
end

function PVPMatchUtil.InitScrollBox(scrollBox, scrollBar, tableBuilder)
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("PVPTableRowTemplate", function(button, elementData)
		if elementData.backgroundColor then
			button:SetBackgroundColor(elementData.backgroundColor);
		else
			button:SetUseAlternateColor(elementData.useAlternateColor);
		end
	end);
	view:SetElementResetter(function(button)
		button.backgroundColor = nil;	
	end);
	ScrollUtil.InitScrollBoxListWithScrollBar(scrollBox, scrollBar, view);

	local function ElementDataTranslator(elementData)
		return elementData.index;
	end
	ScrollUtil.RegisterTableBuilder(scrollBox, tableBuilder, ElementDataTranslator);
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