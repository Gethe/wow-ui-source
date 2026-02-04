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

do
	function SpellIsPriorityAura(spellID)
		return C_Spell.IsPriorityAura(spellID);
	end
	
	function SpellIsSelfBuff(spellID)
		return C_Spell.IsSelfBuff(spellID);
	end

	local visiblityTypeLookup = {
		RAID_INCOMBAT = Enum.SpellAuraVisibilityType.RaidInCombat,
		RAID_OUTOFCOMBAT = Enum.SpellAuraVisibilityType.RaidOutOfCombat,
		ENEMY_TARGET = Enum.SpellAuraVisibilityType.EnemyTarget,
	};
	
	function SpellGetVisibilityInfo(spellID, visiblityTypeName)
		local visiblityType = visiblityTypeLookup[visiblityTypeName];
		return C_Spell.GetVisibilityInfo(spellID, visiblityType);
	end
end
