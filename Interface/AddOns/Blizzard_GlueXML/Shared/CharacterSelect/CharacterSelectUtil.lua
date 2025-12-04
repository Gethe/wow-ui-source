
CharacterSelectUtil = {};

function CharacterSelectUtil.GetCharacterInfoTable(characterIndex)
	local characterGuid = GetCharacterGUID(characterIndex);

	if not characterGuid then
		return nil;
	end

	local characterInfo = GetBasicCharacterInfo(characterGuid);
	if not characterInfo.name then
		return nil;
	end

	local serviceCharacterInfo = GetServiceCharacterInfo(characterGuid);
	MergeTable(characterInfo, serviceCharacterInfo);

	return characterInfo;
end
