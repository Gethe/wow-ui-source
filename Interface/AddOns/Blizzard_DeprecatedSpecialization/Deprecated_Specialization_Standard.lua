-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
	-- Use C_SpecializationInfo.GetNumSpecializationsForClassID instead.
	GetNumSpecializationsForClassID = C_SpecializationInfo.GetNumSpecializationsForClassID;

	-- Use C_SpecializationInfo.GetSpecializationInfo instead.
	GetSpecializationInfo = C_SpecializationInfo.GetSpecializationInfo;

	-- Use C_SpecializationInfo.GetSpecialization instead.
	GetSpecialization = C_SpecializationInfo.GetSpecialization;

	-- Use C_SpecializationInfo.GetActiveSpecGroup instead.
	GetActiveSpecGroup = C_SpecializationInfo.GetActiveSpecGroup;

	-- Use C_SpecializationInfo.GetSpecializationMasterySpells instead.
	GetSpecializationMasterySpells = function(specIndex, isInspect, isPet)
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

	-- Use C_SpecializationInfo.GetTalentInfo instead.
	GetTalentInfo = function(talentTier, talentColumn, specGroupIndex, isInspect, target)
		local talentInfoQuery = {};
		talentInfoQuery.tier = talentTier;
		talentInfoQuery.column = talentColumn;
		talentInfoQuery.groupIndex = specGroupIndex;
		talentInfoQuery.isInspect = isInspect;
		talentInfoQuery.target = target;
		local talentInfo = C_SpecializationInfo.GetTalentInfo(talentInfoQuery);
		if not talentInfo then
			return nil;
		end

		return talentInfo.talentID, talentInfo.name, talentInfo.icon, talentInfo.selected,
			talentInfo.available, talentInfo.spellID, talentInfo.isPVPTalentUnlocked, talentInfo.tier,
			talentInfo.column, talentInfo.known, talentInfo.isGrantedByAura;
	end
end
