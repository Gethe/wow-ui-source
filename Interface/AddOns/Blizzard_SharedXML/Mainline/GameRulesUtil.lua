
function GameRulesUtil.ShouldOrderHallBeActive()
	return not PlayerIsTimerunning();
end

function GameRulesUtil.ShouldShowMythicPlusRating()
	return not PlayerIsTimerunning();
end

function GameRulesUtil.ScenariosEnabled()
	return PlayerGetTimerunningSeasonID() == Constants.TimerunningConsts.TIMERUNNING_SEASON_PANDARIA; 
end

function GameRulesUtil.IsTimerunningSeasonActive()
	local seasonID = TimerunningUtil.GetActiveTimerunningSeasonID();
	return seasonID and seasonID ~= Constants.TimerunningConsts.TIMERUNNING_SEASON_NONE; 
end
