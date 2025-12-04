CombatTextTypeInfo.REFLECT = { r = 1, g = 0.1, b = 0.1, cvar = "floatingCombatTextDodgeParryMiss" };
CombatTextTypeInfo.SPELL_DAMAGE_CRIT = { r = 0.79, g = 0.3, b = 0.85, show = 1 };
CombatTextTypeInfo.PERIODIC_ENERGIZE = { r = 0.1, g = 0.1, b = 1, cvar = "floatingCombatTextPeriodicEnergyGains" };
CombatTextTypeInfo.SPELL_AURA_END = { r = 0.1, g = 1, b = 0.1, cvar = "floatingCombatTextAuras" };
CombatTextTypeInfo.SPELL_AURA_END_HARMFUL = { r = 1, g = 0.1, b = 0.1, cvar = "floatingCombatTextAuras" };
CombatTextTypeInfo.DAMAGE_SHIELD = { r = 0.79, g = 0.3, b = 0.85, show = 1 };
CombatTextTypeInfo.PLUNDER_UPDATE = { r = 1, g = 1, b = 0, isStaggered = 1, show = 1 };

-- Mainline-specific event for Plunderstorm support.
CombatTextFrameEvents.CURRENCY_DISPLAY_UPDATE = true;
