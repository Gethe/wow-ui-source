-- Very similar search filter to SpellSearchTextFilterMixin, but super slimmed down as it only evaluates names
SpellSearchNameFilterMixin = CreateFromMixins(BaseSpellSearchFilterMixin);

-------------------------------- Public Functions -------------------------------

function SpellSearchNameFilterMixin:SetSearchParams(searchText)
	-- Overrides BaseSpellSearchFilterMixin
	if SpellSearchUtil.DoStringsMatch(self.searchString, searchText) then
		return;
	end

	self.searchString = searchText;
	BaseSpellSearchFilterMixin.SetSearchParams(self, searchText);
end

function SpellSearchNameFilterMixin:ClearSearchResults()
	-- Overrides BaseSpellSearchFilterMixin
	self.searchString = nil;
	BaseSpellSearchFilterMixin.ClearSearchResults(self);
end

function SpellSearchNameFilterMixin:UpdateSearchResults()
	-- Overrides BaseSpellSearchFilterMixin
	if not self:GetIsActiveAndEnabled() then
		return;
	end

	if not self.searchString or self.searchString == "" then
		self:ClearSearchResults();
		return;
	end

	BaseSpellSearchFilterMixin.UpdateSearchResults(self);
end

-------------------------------- Derived Implementations -------------------------------

function SpellSearchNameFilterMixin:GetMatchTypeForName(spellName)
	-- Exact Match -> search matches name exactly
	if SpellSearchUtil.DoStringsMatch(spellName, self.searchString) then
		return SpellSearchUtil.MatchType.ExactMatch;
	-- Name Match -> search is in name
	elseif SpellSearchUtil.DoesStringContain(spellName, self.searchString) then
		return SpellSearchUtil.MatchType.NameMatch;
	end
	
	-- No Match
	return nil;
end

function SpellSearchNameFilterMixin:DerivedGetMatchTypeForTraitNode(traitNodeInfo)
	local traitSearchResult = { matchType = nil, entryResults = {} };

	if not traitNodeInfo or not traitNodeInfo.entryIDs then
		return traitSearchResult;
	end

	-- Go through all entries in the node
	-- Nodes should use the best match type out of all of their Entries
	for _, entryID in ipairs(traitNodeInfo.entryIDs) do
		local entryResult = self:DerivedGetMatchTypeForTraitNodeEntry(entryID);
		traitSearchResult.entryResults[entryID] = entryResult;

		if entryResult.matchType and (not traitSearchResult.matchType or entryResult.matchType > traitSearchResult.matchType) then
			traitSearchResult.matchType = entryResult.matchType;
			traitSearchResult.name = entryResult.name;
			traitSearchResult.icon = entryResult.icon;
		end
	end

	return traitSearchResult;
end

function SpellSearchNameFilterMixin:DerivedGetMatchTypeForTraitNodeEntry(entryID)
	local entryResult = {};
	local traitSearchSource = self:GetSearchSourceByType(SpellSearchUtil.SourceType.Trait);

	-- Entries may have either a SubTree or a Definition associated depending on the node type
	local subTreeInfo = traitSearchSource:GetEntrySubTreeInfo(entryID);
	local definitionInfo = traitSearchSource:GetEntryDefinitionInfo(entryID);

	local entryName = (subTreeInfo and subTreeInfo.name) or (definitionInfo and TalentUtil.GetTalentNameFromInfo(definitionInfo)) or nil;

	if not entryName then
		return entryResult;
	end

	entryResult.matchType = self:GetMatchTypeForName(entryName);

	entryResult.name = entryName;
	entryResult.icon = TalentButtonUtil.CalculateIconTextureFromInfo(definitionInfo, subTreeInfo);

	return entryResult;
end

function SpellSearchNameFilterMixin:DerivedGetMatchTypeForPvPTalent(pvpTalentID, pvpTalentInfo)
	local pvpTalentResult = {};

	local pvpTalentName = pvpTalentInfo and pvpTalentInfo.name or nil;
	if not pvpTalentName then
		return pvpTalentResult;
	end

	pvpTalentResult.matchType = self:GetMatchTypeForName(pvpTalentName);

	pvpTalentResult.name = pvpTalentName;
	pvpTalentResult.icon = pvpTalentInfo.icon;

	return pvpTalentResult;
end

function SpellSearchNameFilterMixin:DerivedGetMatchTypeForSpellBookItem(spellBookItemData)
	local spellBookItemResult = {};
	local spellBookItemInfo = spellBookItemData.spellBookItemInfo;
	if not spellBookItemInfo or not spellBookItemInfo.name then
		return spellBookItemResult;
	end

	local name = spellBookItemInfo.name;
	local subName = spellBookItemInfo.subName;

	local flyoutMatchType, flyoutMatchName, flyoutMatchIcon = nil, nil, nil;
	-- If this is a flyout, check the spells inside it for matches
	if spellBookItemInfo.itemType == Enum.SpellBookItemType.Flyout then
		flyoutMatchType, flyoutMatchName, flyoutMatchIcon = self:DerivedGetMatchTypeForFlyout(spellBookItemInfo.actionID);
	end

	spellBookItemResult.matchType = self:GetMatchTypeForName(name);

	-- If top level item didn't have a match or its flyout had a better one, use that
	if flyoutMatchType and (not spellBookItemResult.matchType or flyoutMatchType > spellBookItemResult.matchType) then
		spellBookItemResult.matchType = flyoutMatchType;
		spellBookItemResult.name = flyoutMatchName;
		spellBookItemResult.icon = flyoutMatchIcon;
	elseif spellBookItemResult.matchType then
		spellBookItemResult.name = name;
		spellBookItemResult.icon = spellBookItemInfo.iconID;
	end

	return spellBookItemResult;
end

function SpellSearchNameFilterMixin:DerivedGetMatchTypeForFlyout(flyoutID)
	local numSlots = select(3, GetFlyoutInfo(flyoutID));
	if not numSlots or numSlots == 0 then
		return nil;
	end

	local bestMatchType, bestMatchName, bestMatchIcon = nil, nil, nil;
	for flyoutIndex = 1, numSlots do
		local spellID, _, isKnown, spellName = GetFlyoutSlotInfo(flyoutID, flyoutIndex);

		if isKnown then
			local slotMatchType = self:GetMatchTypeForName(spellName);

			if slotMatchType and (not bestMatchType or slotMatchType > bestMatchType) then
				bestMatchType = slotMatchType;
				bestMatchName = spellName;
				bestMatchIcon = C_Spell.GetSpellTexture(spellID);
			end
		end
	end

	return bestMatchType, bestMatchName, bestMatchIcon;
end