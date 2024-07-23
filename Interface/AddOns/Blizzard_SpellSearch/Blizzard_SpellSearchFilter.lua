-- Base mixin for different kinds of spell-specific search filters
BaseSpellSearchFilterMixin = {}

local function DefaultResultSort(reverseMatchTypeCompare, resultA, resultB)
	local matchTypeA = resultA.matchType;
	local matchTypeB = resultB.matchType;

	matchTypeA = matchTypeA and matchTypeA or -10;
	matchTypeB = matchTypeB and matchTypeB or -10;

	-- Default sort is in order of match type
	if matchTypeA ~= matchTypeB then
		if reverseMatchTypeCompare then
			return matchTypeA < matchTypeB;
		else
			return matchTypeA > matchTypeB;
		end
	end

	-- Then by name
	local nameCompare = strcmputf8i(resultA.name, resultB.name);
	if nameCompare ~= 0 then
		return nameCompare < 0;
	end

	-- Then by source type
	if resultA.sourceType ~= resultB.sourceType then
		return resultA.sourceType > resultB.sourceType;
	end

	-- Then finally fallback on id
	return resultA.resultID < resultB.resultID;
end

-------------------------------- Public Functions -------------------------------

function BaseSpellSearchFilterMixin:Init(searchController, enabled)
	self.searchController = searchController;
	self.enabled = enabled;
	self.reverseDefaultMatchTypeSort = false;
end

function BaseSpellSearchFilterMixin:SetEnabled(enabled)
	self.enabled = enabled;
	if not self.enabled and self.isActive then
		self:ClearSearchResults();
	end
end

function BaseSpellSearchFilterMixin:GetIsEnabled()
	return self.enabled;
end

function BaseSpellSearchFilterMixin:GetIsActive()
	return self.isActive;
end

function BaseSpellSearchFilterMixin:GetIsActiveAndEnabled()
	return self:GetIsActive() and self:GetIsEnabled();
end

function BaseSpellSearchFilterMixin:SetSearchParams(...)
	-- Take params into your derived mixin, then call base func.

	if not self:GetIsEnabled() then
		return;
	end

	self.isActive = true;
	self:UpdateSearchResults();
end

function BaseSpellSearchFilterMixin:UpdateSearchResults()
	-- Process search results in your derived mixin, then call base func.

	if not self:GetIsActiveAndEnabled() then
		return;
	end

	self.matchesBySourceType = {};
	self.resultsBySourceType = {};

	self:InternalSearchTraits();
	self:InternalSearchPvPTalents();
	self:InternalSearchSpellBookItems();
end

function BaseSpellSearchFilterMixin:ClearSearchResults()
	-- Clear search results in your derived mixin, then call base func.

	self.resultsBySourceType = {};
	
	self.isActive = false;
end

function BaseSpellSearchFilterMixin:GetAggregateMatchResults(customSortCompareFunc)
	if not self:GetIsActiveAndEnabled() then
		return nil;
	end

	local results = {};

	local traitResults = self.resultsBySourceType[SpellSearchUtil.SourceType.Trait];
	if traitResults then
		for nodeID, resultInfo in pairs(traitResults) do
			if resultInfo.entryResults then
				for entryID, entryResult in pairs(resultInfo.entryResults) do
					if entryResult.matchType then
						table.insert(results, {
							resultID = entryID,
							name = entryResult.name,
							icon = entryResult.icon,
							sourceType = SpellSearchUtil.SourceType.Trait,
							matchType = entryResult.matchType,
							nodeID = nodeID,
						});
					end
				end
			end
		end
	end

	local pvpTalentResults = self.resultsBySourceType[SpellSearchUtil.SourceType.PvPTalent];
	if pvpTalentResults then
		for pvpTalentID, resultInfo in pairs(pvpTalentResults) do
			if resultInfo.matchType then
				table.insert(results, {
					resultID = pvpTalentID,
					name = resultInfo.name,
					icon = resultInfo.icon,
					sourceType = SpellSearchUtil.SourceType.PvPTalent,
					matchType = resultInfo.matchType,
				});
			end
		end
	end

	local spellBookItemResultsBySpellBank = self.resultsBySourceType[SpellSearchUtil.SourceType.SpellBookItem];
	if spellBookItemResultsBySpellBank then
		for spellBank, spellBankResults in pairs(spellBookItemResultsBySpellBank) do
			if spellBankResults then
				for slotIndex, resultInfo in pairs(spellBankResults) do
					if resultInfo.matchType then
						table.insert(results, {
							resultID = slotIndex,
							name = resultInfo.name,
							icon = resultInfo.icon,
							sourceType = SpellSearchUtil.SourceType.SpellBookItem,
							matchType = resultInfo.matchType,
							spellBank = spellBank,
							spellBookItemInfo = resultInfo.spellBookItemInfo,
						});
					end
				end
			end
		end
	end

	local sortFunc = customSortCompareFunc or self:GetDefaultResultSorter();
	table.sort(results, sortFunc);

	return results;
end

function BaseSpellSearchFilterMixin:GetMatchTypeForSourceTypeEntry(sourceType, ...)
	if not self:GetIsActiveAndEnabled() then
		return nil;
	end

	if not self:GetSearchSourceByType(sourceType) then
		return nil;
	end

	if sourceType == SpellSearchUtil.SourceType.Trait then
		return self:InternalGetMatchTypeForTrait(...);
	elseif sourceType == SpellSearchUtil.SourceType.PvPTalent then
		return self:InternalGetMatchTypeForPvPTalent(...);
	elseif sourceType == SpellSearchUtil.SourceType.SpellBookItem then
		return self:InternalGetMatchTypeForSpellBookItem(...);
	end
	return nil;
end

-------------------------------- Internal Helper Functions -------------------------------

function BaseSpellSearchFilterMixin:GetDefaultResultSorter()
	return GenerateClosure(DefaultResultSort, self.reverseDefaultMatchTypeSort);
end

function BaseSpellSearchFilterMixin:GetSearchSourceByType(sourceType)
	return self.searchController:GetSearchSourceByType(sourceType);
end

function BaseSpellSearchFilterMixin:GetAllSourceDataEntriesByType(sourceType)
	local searchSource = self:GetSearchSourceByType(sourceType);
	return searchSource and searchSource:GetAllSourceDataEntries() or nil;
end

-------------------------------- Internal Single Spell Search Functions -------------------------------

function BaseSpellSearchFilterMixin:InternalGetMatchTypeForTrait(traitNodeID, traitNodeEntryID)
	if not traitNodeID then
		return nil;
	end

	local cachedResults = self.resultsBySourceType[SpellSearchUtil.SourceType.Trait] or {};
	if not cachedResults[traitNodeID] then
		local searchSource = self:GetSearchSourceByType(SpellSearchUtil.SourceType.Trait);
		local nodeInfo = searchSource and searchSource:GetSourceDataEntry(traitNodeID);

		if nodeInfo then
			cachedResults[traitNodeID] = self:DerivedGetMatchTypeForTraitNode(nodeInfo);
			self.resultsBySourceType[SpellSearchUtil.SourceType.Trait] = cachedResults;
		end
	end

	if cachedResults[traitNodeID] then
		local resultInfo = cachedResults[traitNodeID];
		if traitNodeEntryID then
			return resultInfo.entryResults[traitNodeEntryID].matchType or nil;
		else
			return resultInfo.matchType or nil;
		end
	end

	return nil;
end

function BaseSpellSearchFilterMixin:InternalGetMatchTypeForPvPTalent(pvpTalentID, pvpTalentInfo)
	if not pvpTalentID then
		return nil;
	end

	local cachedResults = self.resultsBySourceType[SpellSearchUtil.SourceType.PvPTalent] or {};
	if not cachedResults[pvpTalentID] then
		if not pvpTalentInfo then
			local searchSource = self:GetSearchSourceByType(SpellSearchUtil.SourceType.PvPTalent);
			pvpTalentInfo = searchSource and searchSource:GetSourceDataEntry(pvpTalentID);
		end
		if pvpTalentInfo then
			local matchType, name = self:DerivedGetMatchTypeForPvPTalent(pvpTalentID, pvpTalentInfo);
			cachedResults[pvpTalentID] = { matchType = matchType, name = name };
			self.resultsBySourceType[SpellSearchUtil.SourceType.PvPTalent] = cachedResults;
		end
	end
	
	return cachedResults[pvpTalentID] and cachedResults[pvpTalentID].matchType or nil;
end

function BaseSpellSearchFilterMixin:InternalGetMatchTypeForSpellBookItem(slotIndex, spellBank)
	if not slotIndex or not spellBank then
		return nil;
	end

	local cachedResults = self.resultsBySourceType[SpellSearchUtil.SourceType.SpellBookItem] or {};
	local cachedResultsBySpellBank = cachedResults and cachedResults[spellBank] or {};
	if not cachedResultsBySpellBank[slotIndex] then
		local searchSource = self:GetSearchSourceByType(SpellSearchUtil.SourceType.SpellBookItem);
		local spellBookItemData = searchSource and searchSource:GetSourceDataEntry(slotIndex, spellBank);

		if spellBookItemData then
			local resultInfo = self:DerivedGetMatchTypeForSpellBookItem(spellBookItemData);
			resultInfo.spellBookItemInfo = spellBookItemData.spellBookItemInfo;

			cachedMatchesBySpellBank[slotIndex] = resultInfo;
			cachedResults[spellBank] = cachedResultsBySpellBank;
			self.resultsBySourceType[SpellSearchUtil.SourceType.SpellBookItem] = cachedResults;
		end
	end

	return cachedResultsBySpellBank[slotIndex] and cachedResultsBySpellBank[slotIndex].matchType or nil;
end

-------------------------------- Internal Collection Search Functions -------------------------------

function BaseSpellSearchFilterMixin:InternalSearchTraits()
	local allNodeInfos = self:GetAllSourceDataEntriesByType(SpellSearchUtil.SourceType.Trait);
	if not allNodeInfos then
		self.resultsBySourceType[SpellSearchUtil.SourceType.Trait] = nil;
		return;
	end

	local traitResults = {};

	for _, nodeInfo in pairs(allNodeInfos) do
		traitResults[nodeInfo.ID] = self:DerivedGetMatchTypeForTraitNode(nodeInfo);
	end

	self.resultsBySourceType[SpellSearchUtil.SourceType.Trait] = traitResults;
end

function BaseSpellSearchFilterMixin:InternalSearchPvPTalents()
	local allPvpTalents = self:GetAllSourceDataEntriesByType(SpellSearchUtil.SourceType.PvPTalent);
	if not allPvpTalents then
		self.resultsBySourceType[SpellSearchUtil.SourceType.PvPTalent] = nil;
		return;
	end

	local pvpTalentResults = {};
	local selectedPvpTalents = C_SpecializationInfo.GetAllSelectedPvpTalentIDs();

	for pvpTalentID, pvpTalentInfo in pairs(allPvpTalents) do
		pvpTalentResults[pvpTalentID] = self:DerivedGetMatchTypeForPvPTalent(pvpTalentID, pvpTalentInfo, selectedPvpTalents);
	end

	self.resultsBySourceType[SpellSearchUtil.SourceType.PvPTalent] = pvpTalentResults;
end

function BaseSpellSearchFilterMixin:InternalSearchSpellBookItems()
	local allSpellBookItems = self:GetAllSourceDataEntriesByType(SpellSearchUtil.SourceType.SpellBookItem);
	if not allSpellBookItems then
		self.resultsBySourceType[SpellSearchUtil.SourceType.SpellBookItem] = nil;
		return;
	end

	local spellBookItemResults = {};

	for _, spellBookItemData in ipairs(allSpellBookItems) do
		local spellBankResults = spellBookItemResults[spellBookItemData.spellBank];
		if not spellBankResults then
			spellBookItemResults[spellBookItemData.spellBank] = {};
			spellBankResults = spellBookItemResults[spellBookItemData.spellBank];
		end

		local cachedResult = self:DerivedGetMatchTypeForSpellBookItem(spellBookItemData);
		cachedResult.spellBookItemInfo = spellBookItemData.spellBookItemInfo;
		spellBankResults[spellBookItemData.slotIndex] = cachedResult;
	end

	self.resultsBySourceType[SpellSearchUtil.SourceType.SpellBookItem] = spellBookItemResults;
end

-------------------------------- Expected Derived Functions -------------------------------

function BaseSpellSearchFilterMixin:DerivedGetMatchTypeForTraitNode(traitNodeInfo)
	-- Required
	assert(false);
end

function BaseSpellSearchFilterMixin:DerivedGetMatchTypeForTraitNodeEntry(traideNodeInfo, traitNodeEntryID)
	-- Required
	assert(false);
end

function BaseSpellSearchFilterMixin:DerivedGetMatchTypeForPvPTalent(pvpTalentID, pvpTalentInfo, selectedPvpTalents)
	-- Required
	assert(false);
end

function BaseSpellSearchFilterMixin:DerivedGetMatchTypeForSpellBookItem(spellBookItemData)
	-- Required
	assert(false);
end