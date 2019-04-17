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
PVPMatchUtil.MatchTimeFormatter:OnLoad(0, SecondsFormatter.Abbreviation.Truncate, true);
function PVPMatchUtil.MatchTimeFormatter:GetDesiredUnitCount(seconds)
	return 2;
end
function PVPMatchUtil.MatchTimeFormatter:GetMinInterval(seconds)
	return SecondsFormatter.Interval.Seconds;
end

function PVPMatchUtil.IsActiveMatchComplete()
	return C_PvP.GetActiveMatchState() == Enum.PvpMatchState.Complete;
end
function PVPMatchUtil.GetColorIndex(faction, useAlternateColor)
	return (useAlternateColor and 2 or 1) + (faction * 2);
end
function PVPMatchUtil.GetRowColor(faction, useAlternateColor)
	local index = PVPMatchUtil.GetColorIndex(faction, useAlternateColor);
	return PVPMatchUtil.RowColors[index];
end
function PVPMatchUtil.GetCellColor(faction, useAlternateColor)
	local index = PVPMatchUtil.GetColorIndex(faction, useAlternateColor);
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