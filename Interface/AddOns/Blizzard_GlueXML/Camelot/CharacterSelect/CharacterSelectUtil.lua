function CharacterSelectUtil.SetTooltipForCharacterInfo(characterInfo, characterID)
	if not characterInfo then
		return false;
	end

	local config = CharacterSelectUtil.GetConfig();
	if not config[CharacterSelectUtil.ConfigParam.CharacterTooltips] then
		return false;
	end

	-- Block 1
	local name = characterInfo.fullName;
	local realmName = characterInfo.realmName;

	-- Block 2
	local level = characterInfo.experienceLevel;
	local className = characterInfo.className;
	local areaName = characterInfo.areaName;

	-- Block 3
	local professionName0, professionName1 = CharacterSelectUtil.GetProfessionNames(characterInfo);

	-- Block 4
	local realmAddress = characterInfo.realmAddress;
	local money = CharacterSelectUtil.IsSameRealmAsCurrent(realmAddress) and characterInfo.money or 0;

	-- Block 5
	local catchupAvailable = characterID and IsRPEBoostEligible(characterID);

	GameTooltip_AddColoredLine(GlueTooltip, name, WHITE_FONT_COLOR);
	if showDebugTooltipInfo then
		GameTooltip_AddColoredLine(GlueTooltip, characterInfo.guid, GRAY_FONT_COLOR);
	end

	GameTooltip_AddBlankLineToTooltip(GlueTooltip);
	if className then
		local color = CreateColor(GetClassColor(characterInfo.classFilename));
		GameTooltip_AddColoredLine(GlueTooltip, color:WrapTextInColorCode(className), BLUE_FONT_COLOR);
	end

	GameTooltip_AddColoredLine(GlueTooltip, CHARACTER_SELECT_LEVEL_TOOLTIP:format(level), WHITE_FONT_COLOR);

	if areaName then
		GameTooltip_AddColoredLine(GlueTooltip, areaName, GRAY_FONT_COLOR);
	end

	-- Add a blank line only if we have populated fields for the next section.
	if professionName0 or professionName1 then
		GameTooltip_AddBlankLineToTooltip(GlueTooltip);

		if professionName0 and professionName1 then
			GameTooltip_AddColoredLine(GlueTooltip, CHARACTER_SELECT_PROFESSIONS:format(professionName0, professionName1), WHITE_FONT_COLOR);
		elseif professionName0 then
			GameTooltip_AddColoredLine(GlueTooltip, professionName0, WHITE_FONT_COLOR);
		elseif professionName1 then
			GameTooltip_AddColoredLine(GlueTooltip, professionName1, WHITE_FONT_COLOR);
		end
	end

	-- Add a blank line only if we have populated fields for the next section.
	if money and money > 0 then
		GameTooltip_AddBlankLineToTooltip(GlueTooltip);
		GameTooltip_AddColoredLine(GlueTooltip, MoneyFormatterUtil.FormatMoney(money, MoneyFormatterPresets.Compact), WHITE_FONT_COLOR);
	end
	
	-- Add a blank line only if we have populated fields for the next section.
	if catchupAvailable then
		GameTooltip_AddBlankLineToTooltip(GlueTooltip);

		GameTooltip_AddNormalLine(GlueTooltip, RPE_CATCH_UP_AVAILABLE);
	end

	return true;
end
