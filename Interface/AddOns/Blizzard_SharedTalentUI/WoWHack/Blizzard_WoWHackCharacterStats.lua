-- Single source of truth for the WoWHack character stat lines shown in the character sheet and the scenario tracker.

WoWHackCharacterStats = {};

WoWHackCharacterStats.DeltaSource = {
	Health = "health",
	AttackPower = "maxStatChange",
	CritPercent = "critPercent",
	DodgePercent = "meleeHitChanceTakenChange",
};

local SPELL_TOOLTIP_ID_HEALTH = 1249560;
local SPELL_TOOLTIP_ID_MANA = 1249563;
local SPELL_TOOLTIP_ID_ENERGY = 1249561;
local SPELL_TOOLTIP_ID_ABILITY_POWER = 1249572;
local SPELL_TOOLTIP_ID_CRITICAL_STRIKE_CHANCE = 1249568;
local SPELL_TOOLTIP_ID_CRITICAL_STRIKE_DAMAGE = 1249411;
local SPELL_TOOLTIP_ID_GUARD = 1249564;
local SPELL_TOOLTIP_ID_ABSORB = 1249573;
local SPELL_TOOLTIP_ID_DODGE_CHANCE = 1249570;
local SPELL_TOOLTIP_ID_EVADE_CHARGES = 1249571;

local function FormatPercent(value)
	return format("%d%%", value);
end

local function GetHealth()
	return UnitHealthMax("player");
end

local function GetMana()
	return UnitPowerMax("player", Enum.PowerType.Mana);
end

local function GetEnergy()
	return UnitPowerMax("player", Enum.PowerType.Energy);
end

local function GetAbilityPower()
	return UnitAttackPower("player");
end

local function GetCriticalStrikeChanceRaw()
	return math.ceil(GetCritChance());
end

local function GetCriticalStrikeChance()
	return FormatPercent(GetCriticalStrikeChanceRaw());
end

-- WoWHack dodge is melee hit avoidance.
local function GetDodgeRaw()
	return math.ceil(-GetMeleeHitChanceTakenModifier());
end

local function GetDodge()
	return FormatPercent(GetDodgeRaw());
end

local function GetStatPoints(spellID)
	return C_WoWHackCharacterStats.GetStatPointsBySpellID(spellID);
end

local function GetCriticalStrikeDamageRaw()
	return GetStatPoints(SPELL_TOOLTIP_ID_CRITICAL_STRIKE_DAMAGE);
end

local function GetCriticalStrikeDamage()
	return FormatPercent(GetCriticalStrikeDamageRaw());
end

local function GetGuard()
	return GetStatPoints(SPELL_TOOLTIP_ID_GUARD);
end

local function GetAbsorb()
	return GetStatPoints(SPELL_TOOLTIP_ID_ABSORB);
end

local function GetEvadeCharges()
	return GetStatPoints(SPELL_TOOLTIP_ID_EVADE_CHARGES);
end

local function MakeStatLineEntry(statName, spellTooltipID, valueCallback, deltaSource, rawValueCallback, formatCallback)
	return {
		name = statName,
		spellTooltipID = spellTooltipID,
		valueCallback = valueCallback,
		deltaSource = deltaSource,
		rawValueCallback = rawValueCallback,
		formatCallback = formatCallback,
	};
end

local function MakePowerDeltaSource(powerType)
	return { source = "power", key = powerType };
end

-- Stats stored as the points of a player aura; key is that aura's spell ID.
local function MakeStatPointsDeltaSource(auraSpellID)
	return { source = "statPoints", key = auraSpellID };
end

local DeltaSource = WoWHackCharacterStats.DeltaSource;

WoWHackCharacterStats.Entries = {
	MakeStatLineEntry(WOWHACK_STAT_LINE_HEALTH, SPELL_TOOLTIP_ID_HEALTH, GetHealth, DeltaSource.Health),
	MakeStatLineEntry(WOWHACK_STAT_LINE_ABSORB, SPELL_TOOLTIP_ID_ABSORB, GetAbsorb, MakeStatPointsDeltaSource(SPELL_TOOLTIP_ID_ABSORB)),
	MakeStatLineEntry(WOWHACK_STAT_LINE_ABILITY_POWER, SPELL_TOOLTIP_ID_ABILITY_POWER, GetAbilityPower, DeltaSource.AttackPower),
	MakeStatLineEntry(WOWHACK_STAT_LINE_ENERGY, SPELL_TOOLTIP_ID_ENERGY, GetEnergy, MakePowerDeltaSource(Enum.PowerType.Energy)),
	MakeStatLineEntry(WOWHACK_STAT_LINE_MANA, SPELL_TOOLTIP_ID_MANA, GetMana, MakePowerDeltaSource(Enum.PowerType.Mana)),
	MakeStatLineEntry(WOWHACK_STAT_LINE_EVADE_CHARGES, SPELL_TOOLTIP_ID_EVADE_CHARGES, GetEvadeCharges, MakeStatPointsDeltaSource(SPELL_TOOLTIP_ID_EVADE_CHARGES)),
	MakeStatLineEntry(WOWHACK_STAT_LINE_GUARD, SPELL_TOOLTIP_ID_GUARD, GetGuard, MakeStatPointsDeltaSource(SPELL_TOOLTIP_ID_GUARD)),
	MakeStatLineEntry(WOWHACK_STAT_LINE_DODGE_CHANCE, SPELL_TOOLTIP_ID_DODGE_CHANCE, GetDodge, DeltaSource.DodgePercent, GetDodgeRaw, FormatPercent),
	MakeStatLineEntry(WOWHACK_STAT_LINE_CRITICAL_STRIKE_CHANCE, SPELL_TOOLTIP_ID_CRITICAL_STRIKE_CHANCE, GetCriticalStrikeChance, DeltaSource.CritPercent, GetCriticalStrikeChanceRaw, FormatPercent),
	MakeStatLineEntry(WOWHACK_STAT_LINE_CRITICAL_STRIKE_DAMAGE, SPELL_TOOLTIP_ID_CRITICAL_STRIKE_DAMAGE, GetCriticalStrikeDamage, MakeStatPointsDeltaSource(SPELL_TOOLTIP_ID_CRITICAL_STRIKE_DAMAGE), GetCriticalStrikeDamageRaw, FormatPercent),
};
