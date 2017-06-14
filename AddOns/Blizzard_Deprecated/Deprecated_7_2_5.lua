-- These are functions that were deprecated in 7.2.5, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if (not IsPublicBuild()) then
	return;
end

-- Constants

do
	-- Power Types
	SPELL_POWER_MANA = Enum.PowerType.Mana;
	SPELL_POWER_RAGE = Enum.PowerType.Rage;
	SPELL_POWER_FOCUS = Enum.PowerType.Focus;
	SPELL_POWER_ENERGY = Enum.PowerType.Energy;
	SPELL_POWER_COMBO_POINTS = Enum.PowerType.ComboPoints;
	SPELL_POWER_RUNES = Enum.PowerType.Runes;
	SPELL_POWER_RUNIC_POWER = Enum.PowerType.RunicPower;
	SPELL_POWER_SOUL_SHARDS = Enum.PowerType.SoulShards;
	SPELL_POWER_LUNAR_POWER = Enum.PowerType.LunarPower;
	SPELL_POWER_HOLY_POWER = Enum.PowerType.HolyPower;
	SPELL_POWER_ALTERNATE_POWER = Enum.PowerType.Alternate;
	SPELL_POWER_MAELSTROM = Enum.PowerType.Maelstrom;
	SPELL_POWER_CHI = Enum.PowerType.Chi;
	SPELL_POWER_INSANITY = Enum.PowerType.Insanity;
	SPELL_POWER_ARCANE_CHARGES = Enum.PowerType.ArcaneCharges;
	SPELL_POWER_FURY = Enum.PowerType.Fury;
	SPELL_POWER_PAIN = Enum.PowerType.Pain;

	-- Nothing should have been using these, but preserving since they actually existed
	SPELL_POWER_OBSOLETE = Enum.PowerType.Obsolete;
	SPELL_POWER_OBSOLETE2 = Enum.PowerType.Obsolete2;
end

-- Localization

do
	-- Just use the given text instead
	function TEXT(text)
		return text;
	end
end
