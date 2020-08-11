function GetPlayerGuid()
	return UnitGUID("player");
end

function IsPlayerGuid(guid)
	return guid == GetPlayerGuid();
end

function IsPlayerInitialSpec()
	return GetSpecialization() > GetNumSpecializations();
end