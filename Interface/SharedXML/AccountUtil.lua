function GameLimitedMode_IsActive()
	return IsTrialAccount() or IsVeteranTrialAccount();
end

function GameLimitedMode_IsBankedXPActive()
	return GameLimitedMode_IsActive() or GetExpansionTrialInfo();
end

function GameLimitedMode_GetLevelLimit()
	if GetExpansionTrialInfo() then
		local level = GetMaxLevelForExpansionLevel(math.max(GetClampedCurrentExpansionLevel() - 1, 0) );
		return level;
	elseif GameLimitedMode_IsActive() then
		local level = GetRestrictedAccountData();
		return level;
	end

	local level = GetMaxLevelForPlayerExpansion();
	return level;
end

function GetClampedCurrentExpansionLevel()
	return math.min(GetClientDisplayExpansionLevel(), math.max(GetAccountExpansionLevel(), GetExpansionLevel()));
end

function IsValidEmailAddress(address)
	if address then
		local matchStart, matchEnd = string.find(address, ".+@.+%...+");
		return matchStart and matchEnd;
	end

	return false;
end