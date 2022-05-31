function GetPlayerGuid()
	return UnitGUID("player");
end

function IsPlayerGuid(guid)
	return guid == GetPlayerGuid();
end

function IsPlayerInitialSpec()
	return GetSpecialization() > GetNumSpecializations();
end

function GetNameAndServerNameFromGUID(unitGUID)
	local _, _, _, _, _, name, normalizedRealmName = GetPlayerInfoByGUID(unitGUID);
	return name, normalizedRealmName;
end

function ConcatinateServerNameToPlayerName(unitGUID)
	local name, serverName = GetNameAndServerNameFromGUID(unitGUID);
	if (serverName ~= "") then
		serverName = "-"..serverName
	end
	return name..serverName;
end