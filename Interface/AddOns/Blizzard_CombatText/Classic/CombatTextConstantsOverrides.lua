-- Commented out types were disabled in Classic at the point of unforking.

-- CombatTextTypeInfo.REFLECT = { r = 1, g = 0.1, b = 0.1, cvar = "floatingCombatTextDodgeParryMiss_v2" };
-- CombatTextTypeInfo.SPELL_DAMAGE_CRIT = { r = 0.79, g = 0.3, b = 0.85, show = 1 };
-- CombatTextTypeInfo.PERIODIC_ENERGIZE = { r = 0.1, g = 0.1, b = 1, cvar = "floatingCombatTextEnergyGains_v2" };
CombatTextTypeInfo.SPELL_AURA_END = { r = 0.1, g = 1, b = 0.1, cvar = "floatingCombatTextAuraFade_v2" };
CombatTextTypeInfo.SPELL_AURA_END_HARMFUL = { r = 1, g = 0.1, b = 0.1, cvar = "floatingCombatTextAuraFade_v2" };
CombatTextTypeInfo.DAMAGE_SHIELD = { r = 1, g = 1, b = 1 };
CombatTextTypeInfo.PROC_RESISTED = { r = 1, g = 0.1, b = 0.1, cvar = "floatingCombatTextDamageReduction_v2" };

-- Both SPELL_AURA_END and SPELL_AURA_END_HARMFUL use a different CVar than mainline.
CombatTextCachableCVars.floatingCombatTextAuraFade_v2 = true;
