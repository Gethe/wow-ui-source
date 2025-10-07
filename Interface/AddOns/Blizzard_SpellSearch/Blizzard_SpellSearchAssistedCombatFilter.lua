-- Spell search filter for finding Assisted Combat spells
SpellSearchAssistedCombatFilterMixin = CreateFromMixins(BaseSpellSearchFilterMixin);

-------------------------------- Derived Implementations -------------------------------

function SpellSearchAssistedCombatFilterMixin:DerivedGetMatchTypeForSpellBookItem(spellBookItemData)
	local spellBookItemResult = {};
	local spellBookItemInfo = spellBookItemData.spellBookItemInfo;
	if not spellBookItemData or not spellBookItemInfo then
		return spellBookItemResult;
	end

	if spellBookItemInfo.isPassive or spellBookItemInfo.isOffSpec then
		return spellBookItemResult;
	end

	if spellBookItemInfo.itemType == Enum.SpellBookItemType.FutureSpell then
		return spellBookItemResult;
	end

	local spellID = spellBookItemInfo.spellID;
	if AssistedCombatManager:IsRotationSpell(spellID) then
		spellBookItemResult.matchType = SpellSearchUtil.MatchType.AssistedCombat;
		spellBookItemResult.name = spellBookItemInfo.name;
		spellBookItemResult.icon = spellBookItemInfo.iconID;
	end

	return spellBookItemResult;
end
