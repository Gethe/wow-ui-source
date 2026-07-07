CombatTextConstants =
{
	NumCombatTextLines = 20,
	MessageScrollSpeed = 1.9,
	MessageFadeOutTime = 1.3,
	MessageHeight = 25,
	CriticalHitMaxHeight = 60,
	CriticalHitMinHeight = 30,
	CriticalHitScaleTime = 0.05,
	CriticalHitShrinkTime = 0.2,
	StaggerRange = 20,
	LowHealthThreshold = 0.2,
	LowManaThreshold = 0.2,
};

--[[
List of CombatTextTypeInfo attributes
======================================================
r, g, b = [floats]  --  The floating text color
show = [nil, 1]  --  Display this message type in the UI
isStaggered = [nil, 1]  --  Randomly stagger these messages from left to right
cvar = [nil, 1]  --  This messageType is shown if this variable resolves to "1"
]]
CombatTextTypeInfo =
{
	INTERRUPT = { r = 1, g = 1, b = 1 },
	DAMAGE_CRIT = { r = 1, g = 0.1, b = 0.1, show = 1 },
	DAMAGE = { r = 1, g = 0.1, b = 0.1, isStaggered = 1, show = 1 },
	MISS = { r = 1, g = 0.1, b = 0.1, isStaggered = 1, cvar = "floatingCombatTextDodgeParryMiss_v2" },
	DODGE = { r = 1, g = 0.1, b = 0.1, isStaggered = 1, cvar = "floatingCombatTextDodgeParryMiss_v2" },
	PARRY = { r = 1, g = 0.1, b = 0.1, isStaggered = 1, cvar = "floatingCombatTextDodgeParryMiss_v2" },
	EVADE = { r = 1, g = 0.1, b = 0.1, isStaggered = 1, cvar = "floatingCombatTextDodgeParryMiss_v2" },
	IMMUNE = { r = 1, g = 0.1, b = 0.1, cvar = "floatingCombatTextDodgeParryMiss_v2" },
	DEFLECT = { r = 1, g = 0.1, b = 0.1, cvar = "floatingCombatTextDodgeParryMiss_v2" },
	RESIST = { r = 1, g = 0.1, b = 0.1, cvar = "floatingCombatTextDamageReduction_v2" },
	BLOCK = { r = 1, g = 0.1, b = 0.1, cvar = "floatingCombatTextDamageReduction_v2" },
	ABSORB = { r = 1, g = 0.1, b = 0.1, cvar = "floatingCombatTextDamageReduction_v2" },
	SPELL_DAMAGE = { r = 0.79, g = 0.3, b = 0.85, show = 1 },
	SPELL_MISS = { r = 1, g = 1, b = 1, cvar = "floatingCombatTextDodgeParryMiss_v2" },
	SPELL_DODGE = { r = 1, g = 1, b = 1, cvar = "floatingCombatTextDodgeParryMiss_v2" },
	SPELL_PARRY = { r = 1, g = 1, b = 1, cvar = "floatingCombatTextDodgeParryMiss_v2" },
	SPELL_EVADE = { r = 1, g = 1, b = 1, cvar = "floatingCombatTextDodgeParryMiss_v2" },
	SPELL_IMMUNE = { r = 1, g = 1, b = 1, cvar = "floatingCombatTextDodgeParryMiss_v2" },
	SPELL_DEFLECT = { r = 1, g = 1, b = 1, cvar = "floatingCombatTextDodgeParryMiss_v2" },
	SPELL_REFLECT = { r = 1, g = 1, b = 1, cvar = "floatingCombatTextDodgeParryMiss_v2" },
	SPELL_RESIST = { r = 0.79, g = 0.3, b = 0.85, cvar = "floatingCombatTextDamageReduction_v2" },
	SPELL_BLOCK = { r = 1, g = 1, b = 1, cvar = "floatingCombatTextDamageReduction_v2" },
	SPELL_ABSORB = { r = 0.79, g = 0.3, b = 0.85, cvar = "floatingCombatTextDamageReduction_v2" },
	PERIODIC_HEAL = { r = 0.1, g = 1, b = 0.1, show = 1 },
	ENERGIZE = { r = 0.1, g = 0.1, b = 1, cvar = "floatingCombatTextEnergyGains_v2" },
	SPELL_CAST = { r = 0.1, g = 1, b = 0.1, show = 1 },
	SPELL_AURA_START = { r = 0.1, g = 1, b = 0.1, cvar = "floatingCombatTextAuras_v2" },
	SPELL_AURA_START_HARMFUL = { r = 1, g = 0.1, b = 0.1, cvar = "floatingCombatTextAuras_v2" },
	SPELL_ACTIVE = { r = 1, g = 0.82, b = 0, cvar = "floatingCombatTextReactives_v2" },
	FACTION = { r = 0.1, g = 0.1, b = 1, cvar = "floatingCombatTextRepChanges_v2" },
	HEAL_CRIT = { r = 0.1, g = 1, b = 0.1, show = 1 },
	HEAL = { r = 0.1, g = 1, b = 0.1, show = 1 },
	SPELL_DISPELLED = { r = 1, g = 1, b = 1 },
	EXTRA_ATTACKS = { r = 1, g = 1, b = 1 },
	SPLIT_DAMAGE = { r = 1, g = 1, b = 1, show = 1 },
	HONOR_GAINED = { r = 0.1, g = 0.1, b = 1, cvar = "floatingCombatTextHonorGains_v2" },
	HEALTH_LOW = { r = 1, g = 0.1, b = 0.1, cvar = "floatingCombatTextLowManaHealth_v2" },
	MANA_LOW = { r = 1, g = 0.1, b = 0.1, cvar = "floatingCombatTextLowManaHealth_v2" },
	ENTERING_COMBAT = { r = 1, g = 0.1, b = 0.1, cvar = "floatingCombatTextCombatState_v2" },
	LEAVING_COMBAT = { r = 1, g = 0.1, b = 0.1, cvar = "floatingCombatTextCombatState_v2" },
	COMBO_POINTS = { r = 0.1, g = 0.1, b = 1, cvar = "floatingCombatTextComboPoints_v2" },
	RUNE = { r = 0.1, g = 0.1, b = 1, cvar = "floatingCombatTextEnergyGains_v2" },
	PERIODIC_HEAL_ABSORB = { r = 0.1, g = 1, b = 0.1, show = 1 },
	PERIODIC_HEAL_CRIT = { r = 0.1, g = 1, b = 0.1, show = 1 },
	HEAL_CRIT_ABSORB = { r = 0.1, g = 1, b = 0.1, show = 1 },
	HEAL_ABSORB = { r = 0.1, g = 1, b = 0.1, show = 1 },
	ABSORB_ADDED = { r = 0.1, g = 1, b = 0.1, show = 1 },
};

CombatTextPowerEnumFromEnergizeStringLookup =
{
	MANA = Enum.PowerType.Mana,
	RAGE = Enum.PowerType.Rage,
	FOCUS = Enum.PowerType.Focus,
	ENERGY = Enum.PowerType.Energy,
	RUNES = Enum.PowerType.Runes,
	RUNIC_POWER = Enum.PowerType.RunicPower,
	SOUL_SHARDS = Enum.PowerType.SoulShards,
	LUNAR_POWER = Enum.PowerType.LunarPower,
	HOLY_POWER = Enum.PowerType.HolyPower,
	ALTERNATE = Enum.PowerType.Alternate,
	MAELSTROM = Enum.PowerType.Maelstrom,
	CHI = Enum.PowerType.Chi,
	ARCANE_CHARGES = Enum.PowerType.ArcaneCharges,
	FURY = Enum.PowerType.Fury,
	PAIN = Enum.PowerType.Pain,
	INSANITY = Enum.PowerType.Insanity,
	COMBO_POINTS = Enum.PowerType.ComboPoints,
	HAPPINESS = Enum.PowerType.Happiness,
};

CombatTextFrameEvents =
{
	COMBAT_TEXT_UPDATE = true,
	UNIT_HEALTH = true,
	UNIT_POWER_UPDATE = true,
	PLAYER_REGEN_DISABLED = true,
	PLAYER_REGEN_ENABLED = true,
	RUNE_POWER_UPDATE = true,
	UNIT_ENTERED_VEHICLE = true,
	UNIT_EXITING_VEHICLE = true,
};

CombatTextCachableCVars =
{
	floatingCombatTextLowManaHealth_v2 = true,
	floatingCombatTextAuras_v2 = true,
	floatingCombatTextCombatState_v2 = true,
	floatingCombatTextDodgeParryMiss_v2 = true,
	floatingCombatTextDamageReduction_v2 = true,
	floatingCombatTextRepChanges_v2 = true,
	floatingCombatTextReactives_v2 = true,
	floatingCombatTextFriendlyHealers_v2 = true,
	floatingCombatTextComboPoints_v2 = true,
	floatingCombatTextEnergyGains_v2 = true,
	floatingCombatTextPeriodicEnergyGains_v2 = true,
	floatingCombatTextFloatMode_v2 = true,
	floatingCombatTextHonorGains_v2 = true,
};
