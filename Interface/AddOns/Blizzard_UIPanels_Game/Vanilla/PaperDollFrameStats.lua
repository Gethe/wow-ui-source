function PaperDollFrame_SetStatTooltip(statFrame, statName, stat, effectiveStatDisplay, posBuff, negBuff)
	-- Set the tooltip text
	local tooltipText = HIGHLIGHT_FONT_COLOR_CODE .. statName .. " ";

	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		statFrame.tooltip = tooltipText..effectiveStatDisplay..FONT_COLOR_CODE_CLOSE;
	else 
		tooltipText = tooltipText..effectiveStatDisplay;
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText.." ("..(stat - posBuff - negBuff)..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 ) then
			tooltipText = tooltipText..FONT_COLOR_CODE_CLOSE..GREEN_FONT_COLOR_CODE.."+"..posBuff..FONT_COLOR_CODE_CLOSE;
		end
		if ( negBuff < 0 ) then
			tooltipText = tooltipText..RED_FONT_COLOR_CODE.." "..negBuff..FONT_COLOR_CODE_CLOSE;
		end
		if ( posBuff > 0 or negBuff < 0 ) then
			tooltipText = tooltipText..HIGHLIGHT_FONT_COLOR_CODE..")"..FONT_COLOR_CODE_CLOSE;
		end
		statFrame.tooltip = tooltipText;
	end
end

function PaperDollFrame_SetStatTooltip2(statFrame, statName, statIndex, effectiveStat, unit)
	-- Get class specific tooltip for that stat
	local _, classFileName = UnitClass("player");
	local classStatText = _G[strupper(classFileName).."_"..strupper(statName).."_".."TOOLTIP"];
	-- If can't find one use the default
	if ( not classStatText ) then
		classStatText = _G["DEFAULT".."_"..strupper(statName).."_".."TOOLTIP"];
	end

	if ( ( posBuff == 0 ) and ( negBuff == 0 ) ) then
		statFrame.tooltip2 = classStatText;
	else 
		statFrame.tooltip2= classStatText;
	end
end

function PaperDollFrame_SetResistanceTooltips(statFrame, nameToken, effectiveResistance, unit, damageClass)
	statFrame.tooltip = HIGHLIGHT_FONT_COLOR_CODE .. nameToken.." "..effectiveResistance .. FONT_COLOR_CODE_CLOSE;

	local unitLevel = UnitLevel(unit);
	local MIN_UNIT_LEVEL = 20;
	unitLevel = max(unitLevel, MIN_UNIT_LEVEL);
	local magicResistanceNumber = effectiveResistance/unitLevel;
	local resistanceLevel;
	if ( magicResistanceNumber > 5 ) then
		resistanceLevel = RESISTANCE_EXCELLENT;
	elseif ( magicResistanceNumber > 3.75 ) then
		resistanceLevel = RESISTANCE_VERYGOOD;
	elseif ( magicResistanceNumber > 2.5 ) then
		resistanceLevel = RESISTANCE_GOOD;
	elseif ( magicResistanceNumber > 1.25 ) then
		resistanceLevel = RESISTANCE_FAIR;
	elseif ( magicResistanceNumber > 0 ) then
		resistanceLevel = RESISTANCE_POOR;
	else
		resistanceLevel = RESISTANCE_NONE;
	end
	statFrame.tooltip2 = format(RESISTANCE_TOOLTIP_SUBTEXT, _G["RESISTANCE_TYPE"..damageClass], unitLevel, resistanceLevel);
end
