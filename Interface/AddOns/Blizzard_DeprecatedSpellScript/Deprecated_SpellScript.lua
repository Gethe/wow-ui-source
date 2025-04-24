-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
	TargetSpellReplacesBonusTree = C_Spell.TargetSpellReplacesBonusTree;
	GetMaxSpellStartRecoveryOffset = C_Spell.GetSpellQueueWindow;
	GetSpellQueueWindow = C_Spell.GetSpellQueueWindow;
	GetSchoolString = C_Spell.GetSchoolString;
end