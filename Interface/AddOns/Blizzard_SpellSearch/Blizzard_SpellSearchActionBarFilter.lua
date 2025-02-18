-- Spell search filter for finding spells not currently on an active action bar
SpellSearchActionBarFilterMixin = CreateFromMixins(BaseSpellSearchFilterMixin);

-------------------------------- Public Functions -------------------------------

function SpellSearchActionBarFilterMixin:Init(searchController, enabled)
	BaseSpellSearchFilterMixin.Init(self, searchController, enabled);

	-- Reverse order from default - we want "not on any bar" above "on an unseen bar"
	self.reverseDefaultMatchTypeSort = true;
end

function SpellSearchActionBarFilterMixin:GetResultSorter()
	-- Overrides BaseSpellSearchFilterMixin
	return ActionBarResultSorter;
end

-------------------------------- Derived Implementations -------------------------------

function SpellSearchActionBarFilterMixin:DerivedGetMatchTypeForTraitNode(traitNodeInfo)
	local traitResult = { matchType = nil, entryResults = {} };

	if not traitNodeInfo or not traitNodeInfo.entryIDs then
		return traitResult;
	end

	-- Go through all entries in the node
	-- Nodes themselves should use the selected entry's match type, but also indicate matched inactive entries if selected doesn't match (ie due to uncommitted changes)
	for _, entryID in ipairs(traitNodeInfo.entryIDs) do
		local entryResult = self:DerivedGetMatchTypeForTraitNodeEntry(traitNodeInfo, entryID);
		traitResult.entryResults[entryID] = entryResult;

		if traitNodeInfo.activeEntry and traitNodeInfo.activeEntry.entryID == entryID then
			traitResult.matchType = entryResult.matchType;
			traitResult.name = entryResult.name;
			traitResult.icon = entryResult.icon;
		end
	end

	return traitResult;
end

function SpellSearchActionBarFilterMixin:DerivedGetMatchTypeForTraitNodeEntry(traitNodeInfo, nodeEntryID)
	local entryResult = {};
	local traitSearchSource = self:GetSearchSourceByType(SpellSearchUtil.SourceType.Trait);
	local definitionInfo = traitSearchSource:GetEntryDefinitionInfo(nodeEntryID);
	local spellID = definitionInfo and definitionInfo.spellID or nil;

	if not spellID then
		return entryResult;
	end

	local actionBarStatus = SpellSearchUtil.GetActionBarStatusForTraitNodeEntry(nodeEntryID, traitNodeInfo, spellID);
	entryResult.matchType = SpellSearchUtil.ActionBarStatusMatchTypes[actionBarStatus];
	entryResult.name = TalentUtil.GetTalentNameFromInfo(definitionInfo);
	entryResult.icon = TalentButtonUtil.CalculateIconTexture(definitionInfo);

	return entryResult;
end

function SpellSearchActionBarFilterMixin:DerivedGetMatchTypeForPvPTalent(pvpTalentID, pvpTalentInfo, selectedPvpTalents)
	local pvpTalentResult = {};

	if not pvpTalentInfo then
		return pvpTalentResult;
	end

	-- Non-selected PvP talents are "unlearned", don't evaluate
	if not selectedPvpTalents or not tContains(selectedPvpTalents, pvpTalentID) then
		return pvpTalentResult;
	end

	local actionBarStatus = SpellSearchUtil.GetActionbarStatusForSpell(pvpTalentInfo.spellID);
	pvpTalentResult.matchType = SpellSearchUtil.ActionBarStatusMatchTypes[actionBarStatus];
	pvpTalentResult.name = pvpTalentInfo.name;
	pvpTalentResult.icon = pvpTalentInfo.icon;

	return pvpTalentResult;
end

function SpellSearchActionBarFilterMixin:DerivedGetMatchTypeForSpellBookItem(spellBookItemData)
	local spellBookItemResult = {};
	if not spellBookItemData or not spellBookItemData.spellBookItemInfo then
		return spellBookItemResult;
	end

	local actionBarStatus = SpellSearchUtil.GetActionbarStatusForSpellBookItemInfo(spellBookItemData.spellBookItemInfo);
	spellBookItemResult.matchType = SpellSearchUtil.ActionBarStatusMatchTypes[actionBarStatus];
	spellBookItemResult.name = spellBookItemData.spellBookItemInfo.name;
	spellBookItemResult.icon = spellBookItemData.spellBookItemInfo.iconID;

	return spellBookItemResult;
end