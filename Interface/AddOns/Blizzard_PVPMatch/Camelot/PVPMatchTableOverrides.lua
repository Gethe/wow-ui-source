-- In Camelot the honorLevel in the score data is the player's PvP rank.
local ALLIANCE_FACTION_INDEX = 1;

local function GetRankTitle(rowData)
	local factionAffix = (rowData.faction == ALLIANCE_FACTION_INDEX) and "_1" or "_0";
	return GetText("PVP_RANK_" .. (Enum.PvPRanks.Rank_1 + rowData.honorLevel - 1) .. factionAffix, rowData.gender);
end

function PVPCellHonorLevelMixin:GetIconAtlas(rowData)
	local rankLevel = rowData.honorLevel;
	if rankLevel and rankLevel > 0 then
		local rankAtlas = string.format("UI-Character-Info-Honor-Icon-%d", rankLevel);
		if C_Texture.GetAtlasInfo(rankAtlas) then
			return rankAtlas;
		end
	end

	return nil;
end

function PVPCellHonorLevelMixin:GetIconTexture(rowData)
	return nil;
end

function PVPCellHonorLevelMixin:GetTooltipText(rowData)
	local rankLevel = rowData.honorLevel;
	if rankLevel and rankLevel > 0 then
		return PVP_RANK_NUMBER_AND_TITLE:format(rankLevel, GetRankTitle(rowData));
	end

	return nil;
end
