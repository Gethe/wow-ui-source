function GetPlayerGuid()
	return UnitGUID("player");
end

function IsPlayerGuid(guid)
	return guid == GetPlayerGuid();
end

function IsPlayerInitialSpec()
	if(GetSpecialization() == nil) then
		return false;
	end

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

PlayerUtil = {};

function PlayerUtil.GetCurrentSpecID()
	local currentSpecialization = GetSpecialization();
	if currentSpecialization then
		return GetSpecializationInfo(currentSpecialization);
	end

	return nil;
end

function PlayerUtil.GetSpecName()
	local playerSpecID = PlayerUtil.GetCurrentSpecID()
	if playerSpecID then
		local playerSex = UnitSex("player");
		if playerSpecID and playerSex then
			return select(2, GetSpecializationInfoByID(playerSpecID, playerSex));
		end
	end

	return "";
end

function PlayerUtil.GetSpecNameBySpecID(specID, playerSex)
	playerSex = playerSex or UnitSex("player");
	if playerSex then
		return select(2, GetSpecializationInfoByID(specID, playerSex));
	end

	return "";
end

function PlayerUtil.GetSpecIconBySpecID(specID, playerSex)
	playerSex = playerSex or UnitSex("player");
	if playerSex then
		return select(4, GetSpecializationInfoByID(specID, playerSex));
	end

	return nil;
end

function PlayerUtil.ShouldUseNativeFormInModelScene()
	local _, raceFilename = UnitRace("player");
	return (raceFilename and (raceFilename ~= "Dracthyr" and raceFilename ~= "Worgen")) or C_UnitAuras.WantsAlteredForm("player");
end

function PlayerUtil.GetClassID()
	local classID = select(3, UnitClass("player"));
	return classID;
end

function PlayerUtil.GetClassName()
	local className = UnitClass("player");
	return className;
end

function PlayerUtil.GetClassInfo()
	local classID = PlayerUtil.GetClassID();
	return C_CreatureInfo.GetClassInfo(classID);
end

function PlayerUtil.GetClassFile()
	local classInfo = PlayerUtil.GetClassInfo();
	return classInfo.classFile;
end

function PlayerUtil.GetClassColor()
	return C_ClassColor.GetClassColor(PlayerUtil.GetClassFile());
end

function PlayerUtil.CanUseClassTalents()
	return C_SpecializationInfo.CanPlayerUseTalentUI() and not IsPlayerInitialSpec();
end

function PlayerUtil.HasFriendlyReaction(unit)
    local reaction = UnitReaction("player", unit);

	-- Reaction 4 is neutral and less than 4 becomes increasingly more hostile.
    if reaction and reaction <= 4 then
        return false;
    end

	return true;
end