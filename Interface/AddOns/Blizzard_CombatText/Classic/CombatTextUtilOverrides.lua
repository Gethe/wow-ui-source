function CombatTextUtil.GetFormattedBlockMessage(existingMessage, _damageReductionAmount)
	-- Classic doesn't format block messages, so return the original unaltered.
	return existingMessage;
end

function CombatTextUtil.GetBasicPowerTypeColor(existingColor, _powerType)
	-- Classic doesn't color "basic" power types like MANA, ENERGY, etc.
	return existingColor;
end

local COMBAT_TEXT_RUNE = {};
COMBAT_TEXT_RUNE[1] = COMBAT_TEXT_RUNE_BLOOD;
COMBAT_TEXT_RUNE[2] = COMBAT_TEXT_RUNE_UNHOLY;
COMBAT_TEXT_RUNE[3] = COMBAT_TEXT_RUNE_FROST;
COMBAT_TEXT_RUNE[4] = COMBAT_TEXT_RUNE_DEATH;

local COMBAT_TEXT_RUNE_COLOR = {};
COMBAT_TEXT_RUNE_COLOR[1] = COMBAT_TEXT_RUNE_BLOOD_COLOR;
COMBAT_TEXT_RUNE_COLOR[2] = COMBAT_TEXT_RUNE_UNHOLY_COLOR;
COMBAT_TEXT_RUNE_COLOR[3] = COMBAT_TEXT_RUNE_FROST_COLOR;
COMBAT_TEXT_RUNE_COLOR[4] = COMBAT_TEXT_RUNE_DEATH_COLOR;

function CombatTextUtil.GetRunePowerUpdateMessage(runeIndex, outColor)
	-- Classic displays runes differently based upon their type.
	local runeType = GetRuneType(runeIndex);
	local color = COMBAT_TEXT_RUNE_COLOR[runeType];
	local message = COMBAT_TEXT_RUNE[runeType];

	if color then
		outColor.r = color.r;
		outColor.g = color.g;
		outColor.b = color.b;
	end

	return message;
end
