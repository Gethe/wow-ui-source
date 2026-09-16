function PaperDollFrame_SetHaste(statFrame, unit)
	if ( unit ~= "player" ) then
		statFrame:Hide();
		return;
	end

	local haste = GetHaste();
	local rating = CR_HASTE_MELEE;

	local hasteFormatString;
	if (haste < 0 and not GetPVPGearStatRules()) then
		hasteFormatString = RED_FONT_COLOR_CODE.."%s"..FONT_COLOR_CODE_CLOSE;
	else
		hasteFormatString = "%s";
	end

	PaperDollFrame_SetLabelAndText(statFrame, STAT_HASTE, format(hasteFormatString, format("%d%%", haste + 0.5)), false, haste);
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_HASTE)..FONT_COLOR_CODE_CLOSE;

	local _, class = UnitClass(unit);
	statFrame.tooltip2 = _G["STAT_HASTE_"..class.."_TOOLTIP"];
	if (not statFrame.tooltip2) then
		statFrame.tooltip2 = STAT_HASTE_TOOLTIP;
	end
	statFrame.tooltip2 = statFrame.tooltip2 .. format(STAT_HASTE_BASE_TOOLTIP, BreakUpLargeNumbers(GetCombatRating(rating)), GetCombatRatingBonus(rating));

	statFrame:Show();

	return haste;
end

function PaperDollFrame_SetStatTooltip(statFrame, statName, stat, effectiveStatDisplay, posBuff, negBuff)
	local tooltipText = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, statName).." ";

	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		statFrame.tooltip = tooltipText..effectiveStatDisplay..FONT_COLOR_CODE_CLOSE;
	else
		tooltipText = tooltipText..effectiveStatDisplay;
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText.." ("..BreakUpLargeNumbers(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 ) then
			tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..BreakUpLargeNumbers(posBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( negBuff < 0 ) then
			tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..BreakUpLargeNumbers(negBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
		end
		statFrame.tooltip = tooltipText;
	end
end

function PaperDollFrame_SetStatTooltip2(statFrame, statName, statIndex, effectiveStat, unit)
	statFrame.tooltip2 = _G["DEFAULT_STAT"..statIndex.."_TOOLTIP"];

	if (unit == "player") then
		local _, unitClass = UnitClass("player");
		unitClass = strupper(unitClass);

		local primaryStat, spec, role;
		spec = C_SpecializationInfo.GetSpecialization();
		if (spec) then
			role = GetSpecializationRole(spec);
			primaryStat = select(6, C_SpecializationInfo.GetSpecializationInfo(spec, false, false, nil, UnitSex("player")));
		end
		-- Strength
		if ( statIndex == LE_UNIT_STAT_STRENGTH ) then
			local attackPower = GetAttackPowerForStat(statIndex,effectiveStat);
			if (HasAPEffectsSpellPower()) then
				statFrame.tooltip2 = STAT_TOOLTIP_BONUS_AP_SP;
			end
			if (not primaryStat or primaryStat == LE_UNIT_STAT_STRENGTH) then
				statFrame.tooltip2 = format(statFrame.tooltip2, BreakUpLargeNumbers(attackPower));
				if ( role == "TANK" ) then
					local increasedParryChance = GetParryChanceFromAttribute();
					if ( increasedParryChance > 0 ) then
						statFrame.tooltip2 = statFrame.tooltip2.."|n|n"..format(CR_PARRY_BASE_STAT_TOOLTIP, increasedParryChance);
					end
				end
			else
				statFrame.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
			end
		-- Agility
		elseif ( statIndex == LE_UNIT_STAT_AGILITY ) then
			if (not primaryStat or primaryStat == LE_UNIT_STAT_AGILITY) then
				statFrame.tooltip2 = HasAPEffectsSpellPower() and STAT_TOOLTIP_BONUS_AP_SP or STAT_TOOLTIP_BONUS_AP;
				if ( role == "TANK" ) then
					local increasedDodgeChance = GetDodgeChanceFromAttribute();
					if ( increasedDodgeChance > 0 ) then
						statFrame.tooltip2 = statFrame.tooltip2.."|n|n"..format(CR_DODGE_BASE_STAT_TOOLTIP, increasedDodgeChance);
					end
				end
			else
				statFrame.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
			end
		-- Stamina
		elseif ( statIndex == LE_UNIT_STAT_STAMINA ) then
			statFrame.tooltip2 = format(statFrame.tooltip2, BreakUpLargeNumbers(((effectiveStat*UnitHPPerStamina("player")))*GetUnitMaxHealthModifier("player")));
		-- Intellect
		elseif ( statIndex == LE_UNIT_STAT_INTELLECT ) then
			if ( HasAPEffectsSpellPower() ) then
				statFrame.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
			elseif ( HasSPEffectsAttackPower() ) then
					statFrame.tooltip2 = STAT_TOOLTIP_BONUS_AP_SP;
			elseif ( not primaryStat or primaryStat == LE_UNIT_STAT_INTELLECT ) then
				statFrame.tooltip2 = format(statFrame.tooltip2, max(0, effectiveStat));
			else
				statFrame.tooltip2 = STAT_NO_BENEFIT_TOOLTIP;
			end
		end
	end
end

function PaperDollFrame_SetDodgeTooltip(statFrame, dodgeChance)
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, DODGE_CHANCE).." "..string.format("%.2F", dodgeChance).."%"..FONT_COLOR_CODE_CLOSE;
end

function PaperDollFrame_SetDodgeTooltip2(statFrame)
	statFrame.tooltip2 = format(CR_DODGE_TOOLTIP, GetCombatRating(CR_DODGE), GetCombatRatingBonus(CR_DODGE));
end

function PaperDollFrame_SetParryTooltip(statFrame, parryChance)
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE..format(PAPERDOLLFRAME_TOOLTIP_FORMAT, PARRY_CHANCE).." "..string.format("%.2F", parryChance).."%"..FONT_COLOR_CODE_CLOSE;
end

function PaperDollFrame_SetParryTooltip2(statFrame)
	statFrame.tooltip2 = format(CR_PARRY_TOOLTIP, GetCombatRating(CR_PARRY), GetCombatRatingBonus(CR_PARRY));
end

function PaperDollFrame_ShowFlightSpeed()
	return true;
end
