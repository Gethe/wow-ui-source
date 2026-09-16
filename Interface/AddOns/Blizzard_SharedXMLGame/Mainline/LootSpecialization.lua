function PrintLootSpecialization()
	local specID = GetLootSpecialization();
	local sex = UnitSex("player");
	local lootSpecChoice;
	if ( specID and specID > 0 ) then
		local id, name = GetSpecializationInfoByID(specID, sex);
		lootSpecChoice = format(ERR_LOOT_SPEC_CHANGED_S, name);
	end
	if ( lootSpecChoice ) then
		ChatFrameUtil.AddSystemMessage(lootSpecChoice);
	end
end
