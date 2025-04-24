-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
	GetTalentTabInfo = C_SpecializationInfo.GetSpecializationInfo;
	function C_SpecializationInfo.GetSpecializationInfo(specializationIndex, isInspect, isPet, groupIndex)
		local inspectTarget = nil;
		local sex = nil;
		local specId, name, description, icon, role, primaryStat, pointsSpent, background, previewPointsSpent, isUnlocked = C_SpecializationInfo.GetSpecializationInfo(specializationIndex, isInspect, isPet, inspectTarget, sex, groupIndex);
		return specId, name, description, icon, pointsSpent, background, previewPointsSpent, isUnlocked;
	end

	GetPrimaryTalentTree = C_SpecializationInfo.GetSpecialization;
	GetActiveTalentGroup = C_SpecializationInfo.GetActiveSpecGroup;

	GetTalentTreeMasterySpells = C_SpecializationInfo.GetSpecializationMasterySpells;
	function C_SpecializationInfo.GetSpecializationMasterySpells(specIndex, isInspect, isPet)
		local masterySpells = C_SpecializationInfo.GetSpecializationMasterySpells(specIndex, isInspect, isPet);
		local masterySpell1 = nil;
		local masterySpell2 = nil;
		if masterySpells[1] then
			masterySpell1 = masterySpells[1];
		end
		if masterySpells[2] then
			masterySpell2 = masterySpells[2];
		end
		return masterySpell1, masterySpell2;
	end
end
