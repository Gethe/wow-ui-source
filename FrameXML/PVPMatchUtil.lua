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

function PVPMatchUtil.MatchTimeFormatter:GetDesiredUnitCount(seconds)
	return 2;
end

function PVPMatchUtil.MatchTimeFormatter:GetMinInterval(seconds)
	return SecondsFormatter.Interval.Seconds;
end

function PVPMatchUtil.IsActiveMatchComplete()
	return C_PvP.GetActiveMatchState() == Enum.PvpMatchState.Complete;
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

function PVPMatchUtil.IsRatedBattleground()
	return C_PvP.IsBattleground() and C_PvP.IsRatedMap();
end

function PVPMatchUtil.IsRatedArena()
	return C_PvP.IsArena() and C_PvP.IsRatedMap();
end

function PVPMatchUtil.GetOptionalCategories(isRated, isArena, isLFD)
	local categories = {};

	local isArenaOrLFD = isArena or isLFD;
	if not isRated and not isArenaOrLFD then
		categories.honorableKills = true;
	end	

	if not isArenaOrLFD then
		categories.deaths = true;
	end

	if isRated then
		categories.rating = true;
		categories.ratingChange = true;
	elseif not isArenaOrLFD then
		categories.honorGained = true;
	end

	return categories;
end

function PVPMatchUtil.ToggleScoreboardOrResults()
	local matchState = C_PvP.GetActiveMatchState();
	local isComplete = matchState == Enum.PvpMatchState.Complete;
	if isComplete then
		if PVPMatchResults:IsShown() then
			HideUIPanel(PVPMatchResults);
		else
			PVPMatchResults:BeginShow(C_PvP.GetActiveMatchWinner(), C_PvP.GetActiveMatchDuration());
		end
	else
		if ( PVPMatchScoreboard:IsShown() ) then
			HideUIPanel(PVPMatchScoreboard);
		else
			local isActive = matchState == Enum.PvpMatchState.Active;
			if isActive and not (IsActiveBattlefieldArena() or IsArenaSkirmish()) then
				PVPMatchScoreboard:BeginShow();
			end
		end
	end
end

PVPMatchStyle = {
	PanelColors = {
			CreateColor(1.0, 0.0, 0.0),		-- Horde
			CreateColor(0.557, 0.0, 1.0),	-- Horde Alternate
			CreateColor(0.0, .376, 1.0),	-- Alliance
			CreateColor(1.0, 0.824, 0.0),	-- Alliance Alternate
	},
	Theme = {
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
			nineSliceLayout = "BFAMissionNeutral",
		},
	},
}

function PVPMatchStyle.GetPanelColor(factionIndex, useAlternateColor)
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