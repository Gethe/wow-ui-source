-- These are functions that were deprecated in 11.0.0 and will be removed before it ships.
-- Please upgrade to the updated APIs as soon as possible.

-- Notices
-- UIDropDownMenu has been deprecated. There are currently no plans to delete it, but it will no longer be used in any future implementations. For information on the replacement, please see Blizzard_Menu\11_0_0_MenuImplementationGuide.lua

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

	BOOKTYPE_SPELL = "spell";

	GetSpellBookItemName = function(index, bookType)
		local spellBank = (bookType == BOOKTYPE_SPELL) and Enum.SpellBookSpellBank.Player or Enum.SpellBookSpellBank.Pet;
		return C_SpellBook.GetSpellBookItemName(index, spellBank);
	end

	GetSpellTexture = function(spellID)
		return C_Spell.GetSpellTexture(spellID);
	end

	GetSpellCharges = function(spellID)
		local spellChargeInfo = C_Spell.GetSpellCharges(spellID);
		if spellChargeInfo then
			return spellChargeInfo.currentCharges, spellChargeInfo.maxCharges, spellChargeInfo.cooldownStartTime, spellChargeInfo.cooldownDuration, spellChargeInfo.chargeModRate;
		end
	end

	GetSpellDescription = function(spellID)
		return C_Spell.GetSpellDescription(spellID);
	end

	GetSpellCount = function(spellID)
		return C_Spell.GetSpellCastCount(spellID);
	end

	IsUsableSpell = function(spellID)
		return C_Spell.IsSpellUsable(spellID);
	end
end