local format = string.format;

CombatLogUtil = {};

function CombatLogUtil.WrapTextInColor(text, color)
	local r = color.r * 255;
	local g = color.g * 255;
	local b = color.b * 255;

	return ("|cff%02x%02x%02x%s|r"):format(r, g, b, text);
end

do
	local DefaultColorArray = CreateColor(0.5, 0.5, 0.5, 1.0);

	function CombatLogUtil.GetColorByEventType(event, settings)
		return settings.colors.eventColoring[event] or DefaultColorArray;
	end

	function CombatLogUtil.GetColorByUnitType(unitFlags, settings)
		for mask, unitColor in pairs(settings.colors.unitColoring) do
			if C_CombatLog.DoesObjectMatchFilter(unitFlags, mask) then
				return unitColor;
			end
		end

		return DefaultColorArray;
	end
end

function CombatLogUtil.GetColorBySchool(school, settings)
	if not school then
		return settings.colors.schoolColoring.default;
	end

	return settings.colors.schoolColoring[school] or settings.colors.defaults.spell;
end

do
	local HighlightMultiplier = 1.5;
	local s_highlightColorTable = {};

	function CombatLogUtil.HighlightColor(colorArray)
		s_highlightColorTable.r = math.min(colorArray.r * HighlightMultiplier, 1);
		s_highlightColorTable.g = math.min(colorArray.g * HighlightMultiplier, 1);
		s_highlightColorTable.b = math.min(colorArray.b * HighlightMultiplier, 1);
		s_highlightColorTable.a = colorArray.a;

		return s_highlightColorTable;
	end
end

do
	local RaidTargetIcons = {
		[Enum.CombatLogObjectTarget.Raidtarget1] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1.blp:0|t";
		[Enum.CombatLogObjectTarget.Raidtarget2] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2.blp:0|t";
		[Enum.CombatLogObjectTarget.Raidtarget3] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3.blp:0|t";
		[Enum.CombatLogObjectTarget.Raidtarget4] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4.blp:0|t";
		[Enum.CombatLogObjectTarget.Raidtarget5] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5.blp:0|t";
		[Enum.CombatLogObjectTarget.Raidtarget6] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6.blp:0|t";
		[Enum.CombatLogObjectTarget.Raidtarget7] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7.blp:0|t";
		[Enum.CombatLogObjectTarget.Raidtarget8] = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8.blp:0|t";
	};

	function CombatLogUtil.GetRaidTargetIcon(raidTarget)
		return RaidTargetIcons[raidTarget];
	end

	function CombatLogUtil.GetUnitIcon(unitFlags, direction)
		local raidTarget = bit.band(unitFlags, Constants.CombatLogObjectTargetMasks.COMBATLOG_OBJECT_RAID_TARGET_MASK);

		if raidTarget == 0 then
			return "";
		end

		local iconString = "";
		local icon = RaidTargetIcons[raidTarget];

		if icon then
			if direction == "source" then
				iconString = format(TEXT_MODE_A_STRING_SOURCE_ICON, raidTarget, icon);
			else
				iconString = format(TEXT_MODE_A_STRING_DEST_ICON, raidTarget, icon);
			end
		end

		return iconString;
	end
end

do
	local RaidTargetBraceCodes = {
		[Enum.CombatLogObjectTarget.Raidtarget1] = "{"..string.lower(RAID_TARGET_1).."}",
		[Enum.CombatLogObjectTarget.Raidtarget2] = "{"..string.lower(RAID_TARGET_2).."}",
		[Enum.CombatLogObjectTarget.Raidtarget3] = "{"..string.lower(RAID_TARGET_3).."}",
		[Enum.CombatLogObjectTarget.Raidtarget4] = "{"..string.lower(RAID_TARGET_4).."}",
		[Enum.CombatLogObjectTarget.Raidtarget5] = "{"..string.lower(RAID_TARGET_5).."}",
		[Enum.CombatLogObjectTarget.Raidtarget6] = "{"..string.lower(RAID_TARGET_6).."}",
		[Enum.CombatLogObjectTarget.Raidtarget7] = "{"..string.lower(RAID_TARGET_7).."}",
		[Enum.CombatLogObjectTarget.Raidtarget8] = "{"..string.lower(RAID_TARGET_8).."}",
	};

	function CombatLogUtil.GetRaidTargetBraceCode(raidTarget)
		return RaidTargetBraceCodes[raidTarget] or "";
	end
end

do
	local AlternatePowerEnumValue = Enum.PowerType.Alternate; -- Upvalue for marginally faster access.

	function CombatLogUtil.GetPowerTypeString(powerType, amount, alternatePowerType)
		-- Previous behavior was specifically returning an empty string in this case
		if ( not powerType ) then
			return "";
		end

		if ( powerType == AlternatePowerEnumValue and alternatePowerType ) then
			local name, tooltip, cost = GetUnitPowerBarStringsByID(alternatePowerType);
			return cost; --cost could be nil if we didn't get the alternatePowerType for some reason (e.g. target out of AOI)
		end

		-- Previous behavior was returning nil if powerType didn't match one of the explicitly checked types
		return COMBAT_LOG_POWER_TYPE_STRINGS[powerType];
	end
end

function CombatLogUtil.GetSpellSchoolString(school)
	if ( not school or school == COMBAT_LOG_SCHOOL_MASK_NONE ) then
		return STRING_SCHOOL_UNKNOWN;
	end

	local schoolString = C_Spell.GetSchoolString(school);
	return schoolString or STRING_SCHOOL_UNKNOWN;
end

do
	local function CreateStringBuilder()
		local buffer = {};
		local size = 0;

		local builder = {};

		function builder:Clear()
			size = 0;
		end

		function builder:GetSize()
			return size;
		end

		function builder:IsEmpty()
			return size == 0;
		end

		function builder:AddString(text)
			size = size + 1;
			buffer[size] = text;
		end

		function builder:AddFormattedString(format, ...)
			size = size + 1;
			buffer[size] = (format):format(...);
		end

		function builder:Build()
			local result = table.concat(buffer, " ", 1, size);
			size = 0;
			return result;
		end

		return builder;
	end

	local s_damageStringBuilder = CreateStringBuilder();

	function CombatLogUtil.GenerateDamageResultString(resisted, blocked, absorbed, critical, glancing, crushing, overhealing, textMode, spellID, overkill, overenergize)
		if resisted then
			if resisted < 0 then
				s_damageStringBuilder:AddFormattedString(TEXT_MODE_A_STRING_RESULT_VULNERABILITY, BreakUpLargeNumbers(-resisted));
			else
				s_damageStringBuilder:AddFormattedString(TEXT_MODE_A_STRING_RESULT_RESIST, BreakUpLargeNumbers(resisted));
			end
		end

		if blocked then
			s_damageStringBuilder:AddFormattedString(TEXT_MODE_A_STRING_RESULT_BLOCK, BreakUpLargeNumbers(blocked));
		end

		if absorbed and absorbed > 0 then
			s_damageStringBuilder:AddFormattedString(TEXT_MODE_A_STRING_RESULT_ABSORB, BreakUpLargeNumbers(absorbed));
		end

		if glancing then
			s_damageStringBuilder:AddString(TEXT_MODE_A_STRING_RESULT_GLANCING);
		end

		if crushing then
			s_damageStringBuilder:AddString(TEXT_MODE_A_STRING_RESULT_CRUSHING);
		end

		if overhealing and overhealing > 0 then
			s_damageStringBuilder:AddFormattedString(TEXT_MODE_A_STRING_RESULT_OVERHEALING, BreakUpLargeNumbers(overhealing));
		end

		if overkill and overkill > 0 then
			s_damageStringBuilder:AddFormattedString(TEXT_MODE_A_STRING_RESULT_OVERKILLING, BreakUpLargeNumbers(overkill));
		end

		if overenergize and overenergize > 0 then
			s_damageStringBuilder:AddFormattedString(TEXT_MODE_A_STRING_RESULT_OVERENERGIZE, BreakUpLargeNumbers(overenergize));
		end

		if critical then
			if spellID then
				s_damageStringBuilder:AddString(TEXT_MODE_A_STRING_RESULT_CRITICAL_SPELL);
			else
				s_damageStringBuilder:AddString(TEXT_MODE_A_STRING_RESULT_CRITICAL);
			end
		end

		if s_damageStringBuilder:IsEmpty() then
			return nil;
		end

		return s_damageStringBuilder:Build();
	end
end
