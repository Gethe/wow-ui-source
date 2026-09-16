-- Spell search filter for finding spells based on evaluating search text against names and descriptions
SpellSearchTextFilterMixin = CreateFromMixins(BaseSpellSearchFilterMixin);

-------------------------------- Public Functions -------------------------------

function SpellSearchTextFilterMixin:SetSearchParams(searchText)
	-- Overrides BaseSpellSearchFilterMixin
	if SpellSearchUtil.DoStringsMatch(self.searchString, searchText) then
		return;
	end

	self.searchString = searchText;
	self.searchStringExactMatchDescription = nil;

	BaseSpellSearchFilterMixin.SetSearchParams(self, searchText);
end

function SpellSearchTextFilterMixin:ClearSearchResults()
	-- Overrides BaseSpellSearchFilterMixin
	self.searchString = nil;
	self.searchStringExactMatchDescription = nil;
	BaseSpellSearchFilterMixin.ClearSearchResults(self);
end

function SpellSearchTextFilterMixin:UpdateSearchResults()
	-- Overrides BaseSpellSearchFilterMixin
	if not self:GetIsActiveAndEnabled() then
		return;
	end

	if not self.searchString or self.searchString == "" then
		self:ClearSearchResults();
		return;
	end

	-- Get the description of any "Exact Match" data so it can be used to find Related Match data
	self.searchStringExactMatchDescription = self:InternalGetExactSearchMatchDescription();
	BaseSpellSearchFilterMixin.UpdateSearchResults(self);
end

-------------------------------- Internal Functions -------------------------------

function SpellSearchTextFilterMixin:InternalGetExactSearchMatchDescription()
	-- Find any available spell whose name matches the search string exactly and, if found, return its description

	-- Search Trait nodes, if available
	local allNodeInfos = self:GetAllSourceDataEntriesByType(SpellSearchUtil.SourceType.Trait);
	if allNodeInfos then
		local traitSearchSource = self:GetSearchSourceByType(SpellSearchUtil.SourceType.Trait);
		for _, nodeInfo in pairs(allNodeInfos) do
			if nodeInfo and nodeInfo.entryIDs then
				-- Evaluating every entryID as some nodes have multiple choice entries
				for _, entryID in ipairs(nodeInfo.entryIDs) do
					local entryName, entryDescription = nil, nil;
					local subTreeInfo = traitSearchSource:GetEntrySubTreeInfo(entryID);
					if subTreeInfo then
						entryName = subTreeInfo.name;
						entryDescription = subTreeInfo.description;
					else
						local definitionInfo = traitSearchSource:GetEntryDefinitionInfo(entryID);
						if definitionInfo then
							entryName = TalentUtil.GetTalentNameFromInfo(definitionInfo);
							entryDescription = TalentUtil.GetTalentDescriptionFromInfo(definitionInfo);
						end
					end

					if entryName and SpellSearchUtil.DoStringsMatch(entryName, self.searchString) then
						return entryDescription;
					end
				end
			end
		end
	end

	-- Search PvP Talents, if available
	local allPvpTalentInfos = self:GetAllSourceDataEntriesByType(SpellSearchUtil.SourceType.PvPTalent);
	if allPvpTalentInfos then
		for _, pvpTalentInfo in pairs(allPvpTalentInfos) do
			if pvpTalentInfo and SpellSearchUtil.DoStringsMatch(pvpTalentInfo.name, self.searchString) then
				local spellDescription = C_Spell.GetSpellDescription(pvpTalentInfo.spellID) or "";
				return spellDescription;
			end
		end
	end
	
	-- Search SpellBookItems, if available
	local allSpellBookItems = self:GetAllSourceDataEntriesByType(SpellSearchUtil.SourceType.SpellBookItem);
	if allSpellBookItems then
		for _, spellBookItem in ipairs(allSpellBookItems) do
			if spellBookItem.spellBookItemInfo and SpellSearchUtil.DoStringsMatch(spellBookItem.spellBookItemInfo.name, self.searchString) then
				return C_SpellBook.GetSpellBookItemDescription(spellBookItem.slotIndex, spellBookItem.spellBank);
			end
		end
	end

	return nil;
end

-------------------------------- Derived Implementations -------------------------------

function SpellSearchTextFilterMixin:GetMatchTypeForText(spellName, extraSpellName, getSpellDescriptionFunc)
	-- Exact Match -> search matches name exactly
	if SpellSearchUtil.DoStringsMatch(spellName, self.searchString) then
		return SpellSearchUtil.MatchType.ExactMatch;
	-- Name Match -> search is in name
	elseif SpellSearchUtil.DoesStringContain(spellName, self.searchString) or (extraSpellName and SpellSearchUtil.DoesStringContain(extraSpellName, self.searchString)) then
		return SpellSearchUtil.MatchType.NameMatch;
	end
	
	-- Delay getting spell description until we know we're going to check it, because that can tend to be expensive
	local spellDescription = getSpellDescriptionFunc();

	-- Description Match -> search is in description
	if spellDescription and SpellSearchUtil.DoesStringContain(spellDescription, self.searchString) then
		return SpellSearchUtil.MatchType.DescriptionMatch;
	-- Related Match -> name is in exact match description
	elseif self.searchStringExactMatchDescription and SpellSearchUtil.DoesStringContain(self.searchStringExactMatchDescription, spellName) then
		return SpellSearchUtil.MatchType.RelatedMatch;
	end
	
	-- No Match
	return nil;
end

function SpellSearchTextFilterMixin:DerivedGetMatchTypeForTraitNode(traitNodeInfo)
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

function SpellSearchTextFilterMixin:DerivedGetMatchTypeForTraitNodeEntry(entryID)
	local entryResult = {};
	local traitSearchSource = self:GetSearchSourceByType(SpellSearchUtil.SourceType.Trait);

	local entryName, getDescriptionFunc, entryReplacesName = nil, nil, nil;

	-- Entries may have either a SubTree or a Definition associated depending on the node type
	local subTreeInfo = traitSearchSource:GetEntrySubTreeInfo(entryID) or nil;
	local definitionInfo = traitSearchSource:GetEntryDefinitionInfo(entryID) or nil;
	if subTreeInfo then
		entryName = subTreeInfo.name;
		getDescriptionFunc = function() return subTreeInfo.description; end;
	elseif definitionInfo then
		entryName = TalentUtil.GetTalentNameFromInfo(definitionInfo);
		getDescriptionFunc = function() return TalentUtil.GetTalentDescriptionFromInfo(definitionInfo); end;
		entryReplacesName = TalentUtil.GetReplacesSpellNameFromInfo(definitionInfo);
	end

	if not entryName then
		return entryResult;
	end

	entryResult.matchType = self:GetMatchTypeForText(entryName, entryReplacesName, getDescriptionFunc);

	entryResult.name = entryName;
	entryResult.icon = TalentButtonUtil.CalculateIconTextureFromInfo(definitionInfo, subTreeInfo);

	return entryResult;
end

function SpellSearchTextFilterMixin:DerivedGetMatchTypeForPvPTalent(pvpTalentID, pvpTalentInfo)
	local pvpTalentResult = {};

	local pvpTalentName = pvpTalentInfo and pvpTalentInfo.name or nil;
	if not pvpTalentName then
		return pvpTalentResult;
	end

	local getDescriptionFunc = function() return C_Spell.GetSpellDescription(pvpTalentInfo.spellID); end
	pvpTalentResult.matchType = self:GetMatchTypeForText(pvpTalentName, nil, getDescriptionFunc);

	pvpTalentResult.name = pvpTalentName;
	pvpTalentResult.icon = pvpTalentInfo.icon;

	return pvpTalentResult;
end

function SpellSearchTextFilterMixin:DerivedGetMatchTypeForSpellBookItem(spellBookItemData)
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

	local getDescriptionFunc = function() return C_SpellBook.GetSpellBookItemDescription(spellBookItemData.slotIndex, spellBookItemData.spellBank); end
	spellBookItemResult.matchType = self:GetMatchTypeForText(name, subName, getDescriptionFunc);

	-- If top level item didn't have a match or its flyout had a better one, use that
	if flyoutMatchType and (not spellBookItemResult.matchType or flyoutMatchType > spellBookItemResult.matchType) then
		spellBookItemResult.matchType = flyoutMatchType;
		spellBookItemResult.name = flyoutMatchName;
		spellBookItemResult.icon = flyoutMatchIcon;
	elseif spellBookItemResult.matchType then
		spellBookItemResult.name = spellBookItemInfo.name;
		spellBookItemResult.icon = spellBookItemInfo.iconID;
	end

	return spellBookItemResult;
end

function SpellSearchTextFilterMixin:DerivedGetMatchTypeForFlyout(flyoutID)
	local numSlots = select(3, GetFlyoutInfo(flyoutID));
	if not numSlots or numSlots == 0 then
		return nil;
	end

	local bestMatchType, bestMatchName, bestMatchIcon = nil, nil, nil;
	for flyoutIndex = 1, numSlots do
		local spellID, _, isKnown, spellName = GetFlyoutSlotInfo(flyoutID, flyoutIndex);

		if isKnown then
			local getDescriptionFunc = function() return C_Spell.GetSpellDescription(spellID); end
			local slotMatchType = self:GetMatchTypeForText(spellName, nil, getDescriptionFunc);

			if slotMatchType and (not bestMatchType or slotMatchType > bestMatchType) then
				bestMatchType = slotMatchType;
				bestMatchName = spellName;
				bestMatchIcon = C_Spell.GetSpellTexture(spellID);
			end
		end
	end

	return bestMatchType, bestMatchName, bestMatchIcon;
end