-- These are functions that were deprecated in 11.0.0 and will be removed before it ships.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
	GetSpellInfo = function(spellID)
		if not spellID then
			return nil;
		end

		local spellInfo = C_Spell.GetSpellInfo(spellID);
		if spellInfo then
			return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID, spellInfo.originalIconID;
		end
	end

	GetNumSpellTabs = C_SpellBook.GetNumSpellBookSkillLines;

	GetSpellTabInfo = function(index)
		local skillLineInfo = C_SpellBook.GetSpellBookSkillLineInfo(index);
		if skillLineInfo then
			return	skillLineInfo.name, 
					skillLineInfo.iconID, 
					skillLineInfo.itemIndexOffset, 
					skillLineInfo.numSpellBookItems, 
					skillLineInfo.isGuild, 
					skillLineInfo.offSpecID,
					skillLineInfo.shouldHide,
					skillLineInfo.specID;
		end
	end

	GetSpellCooldown = function(spellID)
		local spellCooldownInfo = C_Spell.GetSpellCooldown(spellID);
		if spellCooldownInfo then
			return spellCooldownInfo.startTime, spellCooldownInfo.duration, spellCooldownInfo.isEnabled, spellCooldownInfo.modRate;
		end
	end
end