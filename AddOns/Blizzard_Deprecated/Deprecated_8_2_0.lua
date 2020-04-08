-- These are functions that were deprecated in 8.2.0, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not IsPublicBuild() then
	return;
end

do
	-- Use C_PvP.IsRatedBattleground() instead
	IsRatedBattleground = C_PvP.IsRatedBattleground;
	-- Use C_PvP.IsRatedArena() instead
	IsRatedArena = C_PvP.IsRatedArena;
	-- Use C_PvP.IsRatedMap() instead
	IsRatedMap =  C_PvP.IsRatedMap;

	--GetNumBattlefieldStats is no longer supported, addons must use C_PvP.GetMatchPVPStatIDs() instead.
	GetNumBattlefieldStats = function()
		local pvpStatIDs = C_PvP.GetMatchPVPStatIDs();
		return #pvpStatIDs;
	end
	-- GetBattlefieldStatInfo is no longer supported, addons must use C_PvP.GetMatchPVPStatColumn(pvpStatID) instead.
	GetBattlefieldStatInfo = function(index)
		local pvpStatIDs = C_PvP.GetMatchPVPStatIDs();
		local pvpStatID = pvpStatIDs[index];
		if pvpStatID then
			local statColumn = C_PvP.GetMatchPVPStatColumn(pvpStatID);
			if statColumn then
				return statColumn.name, nil, statColumn.tooltip;
			else
				return "", nil, "";
			end
		end
	end
end

-- Report system update
do
	--C_ChatInfo.ReportPlayer is no longer supported, addons must use C_ReportSystem.OpenReportPlayerDialog(complaintType, reportedPlayerName, reportedPlayerLocation) now
	C_ChatInfo.ReportPlayer = function(complaintType, playerLocation, comment)
	end
end

-- Guild News Info
do
	-- Use C_GuildInfo.GetGuildNewsInfo instead.
	function GetGuildNewsInfo(newsIndex)
		local newsInfo = C_GuildInfo.GetGuildNewsInfo(newsIndex);
		if newsInfo then
			return newsInfo.isSticky, newsInfo.isHeader, newsInfo.newsType, newsInfo.whoText, newsInfo.whatText, newsInfo.newsDataID, newsInfo.data[1], newsInfo.data[2], newsInfo.weekday, newsInfo.day, newsInfo.month, newsInfo.year, newsInfo.guildMembersPresent;
		end
	end
end

--Guild Info
do
	-- Use C_GuildInfo.GuildRoster instead
	GuildRoster = C_GuildInfo.GuildRoster;
	-- Use C_GuildInfo.CanEditOfficerNote instead
	CanEditOfficerNote = C_GuildInfo.CanEditOfficerNote;
	-- Use C_GuildInfo.CanViewOfficerNote instead
	CanViewOfficerNote = C_GuildInfo.CanViewOfficerNote;
end

-- Time formatting
do
	-- Use SecondsToClock instead.
	function GetTimeStringFromSeconds(timeAmount, asMs, dropZeroHours)
		local seconds = asMs and floor(timeAmount / 1000) or timeAmount;
		local displayZeroHours = not (dropZeroHours and hours == 0);
		return SecondsToClock(seconds, displayZeroHours)
	end
end