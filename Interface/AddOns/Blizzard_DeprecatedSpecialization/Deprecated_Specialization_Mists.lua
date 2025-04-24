-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
	-- Use C_SpecializationInfo.SetActiveSpecGroup instead.
	SetActiveTalentGroup = C_SpecializationInfo.SetActiveSpecGroup;

	-- Use C_SpecializationInfo.GetSpecializationInfo instead.
	GetTalentTabInfo = function(specializationIndex, isInspect, isPet, groupIndex)
		local inspectTarget = nil;
		local sex = nil;

		-- Note: groupIndex is not a supported parameter in 5.5.x and onward.
		local specId, name, description, icon, role, primaryStat, pointsSpent, background, previewPointsSpent, isUnlocked = C_SpecializationInfo.GetSpecializationInfo(specializationIndex, isInspect, isPet, inspectTarget, sex);

		-- Note: pointsSpent, background, previewPointsSpent, and isUnlocked are not supported outputs in 5.5.x and onward.
		-- They have default values not reflective of actual system state.
		-- role and primaryStat are new supported outputs in 5.5.x and onward.
		return specId, name, description, icon;
	end

	-- Use C_SpecializationInfo.GetSpecialization instead.
	GetPrimaryTalentTree = C_SpecializationInfo.GetSpecialization;

	-- Use C_SpecializationInfo.GetActiveSpecGroup instead.
	GetActiveTalentGroup = C_SpecializationInfo.GetActiveSpecGroup;

	-- Use C_SpecializationInfo.GetSpecializationMasterySpells instead.
	GetTalentTreeMasterySpells = function(specIndex, isInspect, isPet)
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
