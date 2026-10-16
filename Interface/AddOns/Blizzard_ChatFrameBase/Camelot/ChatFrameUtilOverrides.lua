function ChatFrameUtil.DisplayLevelUp(chatFrame, level, ...)
	-- Level up
	local info = ChatTypeInfo["SYSTEM"];
	-- Blank arg is numNewPvpTalentSlots (always 0 in Classic).
	local health, mana, talentPoints, _, strength, agility, stamina, intellect, spirit = ...;

	local string = LEVEL_UP:format(level, level);
	chatFrame:AddMessage(string, info.r, info.g, info.b, info.id);

	if ( mana > 0 ) then
		string = LEVEL_UP_HEALTH_MANA:format(health, mana);
	else
		string = LEVEL_UP_HEALTH:format(health);
	end
	chatFrame:AddMessage(string, info.r, info.g, info.b, info.id);

	if ( talentPoints > 0 ) then
		string = format(GetText("LEVEL_UP_CHAR_POINTS", nil, talentPoints), talentPoints);
		chatFrame:AddMessage(string, info.r, info.g, info.b, info.id);
	end

	if ( strength > 0 ) then
		string = format(LEVEL_UP_STAT, SPELL_STAT1_NAME, strength);
		chatFrame:AddMessage(string, info.r, info.g, info.b, info.id);
	end
	if ( agility > 0 ) then
		string = format(LEVEL_UP_STAT, SPELL_STAT2_NAME, agility);
		chatFrame:AddMessage(string, info.r, info.g, info.b, info.id);
	end
	if ( stamina > 0 ) then
		string = format(LEVEL_UP_STAT, SPELL_STAT3_NAME, stamina);
		chatFrame:AddMessage(string, info.r, info.g, info.b, info.id);
	end
	if ( intellect > 0 ) then
		string = format(LEVEL_UP_STAT, SPELL_STAT4_NAME, intellect);
		chatFrame:AddMessage(string, info.r, info.g, info.b, info.id);
	end
	if ( spirit > 0 ) then
		string = format(LEVEL_UP_STAT, SPELL_STAT5_NAME, spirit);
		chatFrame:AddMessage(string, info.r, info.g, info.b, info.id);
	end
end
