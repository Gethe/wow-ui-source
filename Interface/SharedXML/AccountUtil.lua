function GameLimitedMode_IsActive()
	return IsTrialAccount() or IsVeteranTrialAccount();
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