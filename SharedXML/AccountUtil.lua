function GameLimitedMode_IsActive()
	return IsTrialAccount() or IsVeteranTrialAccount();
end

function GetClampedCurrentExpansionLevel()
	return math.min(GetClientDisplayExpansionLevel(), math.max(GetAccountExpansionLevel(), GetExpansionLevel()));
end