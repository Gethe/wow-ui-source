-- These are functions that were deprecated and will be removed in the future.
-- Please upgrade to the updated APIs as soon as possible.

if not GetCVarBool("loadDeprecationFallbacks") then
	return;
end

do
	HUNTER_DISMISS_PET = Constants.SpellBookSpellIDs.SPELL_ID_DISMISS_PET;

	function IsPlayerSpell(spellID)
		local spellBank = Enum.SpellBookSpellBank.Player;
		return C_SpellBook.IsSpellKnown(spellID, spellBank);
	end

	function IsSpellKnown(spellID, isPet)
		local spellBank = isPet and Enum.SpellBookSpellBank.Pet or Enum.SpellBookSpellBank.Player;
		local includeOverrides = false;
		return C_SpellBook.IsSpellInSpellBook(spellID, spellBank, includeOverrides);
	end

	function IsSpellKnownOrOverridesKnown(spellID, isPet)
		local spellBank = isPet and Enum.SpellBookSpellBank.Pet or Enum.SpellBookSpellBank.Player;
		local includeOverrides = true;
		return C_SpellBook.IsSpellInSpellBook(spellID, spellBank, includeOverrides);
	end
end
