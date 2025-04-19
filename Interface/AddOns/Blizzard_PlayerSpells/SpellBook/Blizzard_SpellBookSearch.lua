local NotOnActionBarSearchText = SPELLBOOK_SEARCH_NOT_ON_ACTIONBAR;

-- The order of sections in this table is the order they will be on the frame (if multiple are shown)
local ResultSections = {
	{
		headerText = SPELLBOOK_SEARCH_HEADER_EXACT,
		matchTypes = { SpellSearchUtil.MatchType.ExactMatch },
	},
	{
		headerText = SPELLBOOK_SEARCH_HEADER_RELATED,
		matchTypes = { SpellSearchUtil.MatchType.RelatedMatch },
	},
	{
		headerText = SPELLBOOK_SEARCH_HEADER_NAME,
		matchTypes = { SpellSearchUtil.MatchType.NameMatch	},
	},
	{
		headerText = SPELLBOOK_SEARCH_HEADER_DESCRIPTION,
		matchTypes = { SpellSearchUtil.MatchType.DescriptionMatch },
	},
	{
		headerText = SPELLBOOK_SEARCH_HEADER_GENERIC,
		matchTypes = {
			SpellSearchUtil.MatchType.NotOnActionBar,
			SpellSearchUtil.MatchType.OnInactiveBonusBar,
			SpellSearchUtil.MatchType.OnDisabledActionBar,
		},
	},
};

local ResultSectionIndexByMatchType = {};
do
	-- Compiles sections into a runtime helper table to easily look up which section to use per matchType
	for index, section in ipairs(ResultSections) do
		for _, matchType in ipairs(section.matchTypes) do
			ResultSectionIndexByMatchType[matchType] = index;
		end
	end
end

local function PreviewSearchResultSort(resultInfoA, resultInfoB)
	-- Sort by match type first
	if resultInfoA.matchType ~= resultInfoB.matchType then
		return resultInfoA.matchType > resultInfoB.matchType;
	end

	-- Then by Spell Bank
	if resultInfoA.spellBank ~= resultInfoB.spellBank then
		return resultInfoA.spellBank < resultInfoB.spellBank;
	end

	-- Then by resultID (slotIndex)
	return resultInfoA.resultID < resultInfoB.resultID;
end

local function FullSearchResultSort(reverseMatchTypeCompare, resultInfoA, resultInfoB)
	-- Sort by match type first
	if resultInfoA.matchType ~= resultInfoB.matchType then
		if reverseMatchTypeCompare then
			return resultInfoA.matchType < resultInfoB.matchType;
		else
			return resultInfoA.matchType > resultInfoB.matchType;
		end
	end

	local spellBookItemInfoA = resultInfoA.spellBookItemInfo;
	local spellBookItemInfoB = resultInfoB.spellBookItemInfo;

	-- Then by non-offspec
	if spellBookItemInfoA.isOffSpec ~= spellBookItemInfoB.isOffSpec then
		return not spellBookItemInfoA.isOffSpec;
	end

	-- Then by non-future spell
	local itemTypeA = spellBookItemInfoA.itemType;
	local itemTypeB = spellBookItemInfoB.itemType;
	if itemTypeA ~= itemTypeB and (itemTypeA == Enum.SpellBookItemType.FutureSpell or itemTypeB == Enum.SpellBookItemType.FutureSpell) then
		return itemTypeA ~= Enum.SpellBookItemType.FutureSpell;
	end

	-- Then by non-passive
	if spellBookItemInfoA.isPassive ~= spellBookItemInfoB.isPassive then
		return not spellBookItemInfoA.isPassive;
	end

	-- Then by spell bank
	if resultInfoA.spellBank ~= resultInfoB.spellBank then
		return resultInfoA.spellBank < resultInfoB.spellBank;
	end

	-- Then by resultID (slotIndex)
	return resultInfoA.resultID < resultInfoB.resultID;
end

-------------------------------- SpellBookSearch Mixin -------------------------------

SpellBookSearchMixin = {};

function SpellBookSearchMixin:InitializeSearch()
	local searchSources = {};

	-- Setup search source for our search controller to use
	local allSpellBookItemsGetter = GenerateClosure(self.GetAllDisplayableSpellBookItems, self);
	searchSources[SpellSearchUtil.SourceType.SpellBookItem] = CreateAndInitFromMixin(SpellBookItemSearchSourceMixin, allSpellBookItemsGetter);

	-- Initialize search controller
	self.searchController = CreateAndInitFromMixin(SpellSearchControllerMixin, searchSources);

	self.searchController:SetFilterDisabled(SpellSearchUtil.FilterType.ActionBar, false);
	self.SearchPreviewContainer:SetDefaultResultButton(NotOnActionBarSearchText, GenerateClosure(self.OnNotOnActionBarButtonClicked, self));

	self.isInSearchResultsMode = false;
end

function SpellBookSearchMixin:IsSearchInitialized()
	return self.searchController and self.searchController:IsInitialized();
end

function SpellBookSearchMixin:IsInSearchResultsMode()
	return self:IsSearchInitialized() and self.isInSearchResultsMode;
end

function SpellBookSearchMixin:SetPreviewResultSearch(previewSearchText)
	if not self:IsSearchInitialized() then
		return;
	end

	if not previewSearchText then
		-- Show default action bar preview button
		self.SearchPreviewContainer:SetPreviewResults(nil);
		self.SearchPreviewContainer:Show();
		return;
	end

	local previewResults = self.searchController:RunFilterOnce(SpellSearchUtil.FilterType.Name, PreviewSearchResultSort, previewSearchText);
	if previewResults and #previewResults > 0 then
		for _, previewResult in ipairs(previewResults) do
			-- Show Future and offspec preview specs as desaturated to help differentiate between active/learned results
			local itemInfo = previewResult.spellBookItemInfo;
			if itemInfo.isOffSpec or itemInfo.itemType == Enum.SpellBookItemType.FutureSpell then
				previewResult.desaturate = true;		
			end
		end

		self.SearchPreviewContainer:SetPreviewResults(previewResults);
		self.SearchPreviewContainer:Show();
	else
		self:HidePreviewResultSearch();
	end
end

function SpellBookSearchMixin:HidePreviewResultSearch()
	self.SearchPreviewContainer:Hide();
	self.SearchPreviewContainer:ClearResults();
end

function SpellBookSearchMixin:OnPreviewSearchResultClicked(resultInfo)
	if not resultInfo or not resultInfo.name then
		return;
	end

	-- Override the search box text to the selected autocomplete result's name
	self.SearchBox:ClearFocus();
	self.SearchBox:SetText(resultInfo.name);
	self.SearchPreviewContainer:Hide();

	-- Show the results of searching for that result's name
	self:SetFullResultSearch(resultInfo.name);
end

function SpellBookSearchMixin:SetFullResultSearch(searchText)
	if searchText and SpellSearchUtil.DoStringsMatch(searchText, NotOnActionBarSearchText) then
		self:ActivateSearchFilter(SpellSearchUtil.FilterType.ActionBar);
	elseif searchText then
		self:ActivateSearchFilter(SpellSearchUtil.FilterType.Text, searchText);
	else
		local skipTabReset = false;
		self:ClearActiveSearchState(skipTabReset);
	end
end

function SpellBookSearchMixin:ActivateSearchFilter(filterType, ...)
	self.cachedSpellBookItems = nil;
	if not self:IsInSearchResultsMode() then
		self:EnableSearchResultsMode();
	end

	self.searchController:ActivateSearchFilter(filterType, ...);
	self:DisplayFullSearchResults();
end

function SpellBookSearchMixin:UpdateFullSearchResults()
	self.cachedSpellBookItems = nil;
	self.searchController:UpdateActiveSearchResults();
	self:DisplayFullSearchResults();
end

function SpellBookSearchMixin:DisplayFullSearchResults()
	local isActionBarSearch = self.searchController:GetActiveSearchFilterType() == SpellSearchUtil.FilterType.ActionBar;
	local reverseMatchTypeSort = isActionBarSearch;
	local resultSortFunc = GenerateClosure(FullSearchResultSort, reverseMatchTypeSort);

	local fullSearchResults = self.searchController:GetActiveSearchResults(resultSortFunc);
	if not fullSearchResults or #fullSearchResults == 0 then
		self:ClearActiveSearchState();
		return;
	end

	local resultGroupsBySectionIndex = {};

	for index, resultInfo in ipairs(fullSearchResults) do
		local elementData = nil;
		-- Figure out which category this item belongs to and have that category generate elementData for displaying it
		for catIndex, categoryMixin in ipairs(self.categoryMixins) do
			if categoryMixin:IsAvailable() and categoryMixin:ContainsSlot(resultInfo.resultID, resultInfo.spellBank) then
				elementData = categoryMixin:GetElementDataForItem(resultInfo.resultID, resultInfo.spellBank);
				elementData.matchType = resultInfo.matchType;
				break;
			end
		end

		-- If the current search is ActionBar filter and this item's data group doesn't display action bar statuses, clear out and don't include it
		if elementData and isActionBarSearch and not elementData.showActionBarStatus then
			elementData = nil;
		end

		if elementData then
			-- Place the element into a results section based on its match type
			local sectionIndex = ResultSectionIndexByMatchType[resultInfo.matchType];
			if not resultGroupsBySectionIndex[sectionIndex] then
				resultGroupsBySectionIndex[sectionIndex] = {
					header = { templateKey = "HEADER", text = ResultSections[sectionIndex].headerText },
					elements = {}
				};
			end
			table.insert(resultGroupsBySectionIndex[sectionIndex].elements, elementData);
		end
	end

	local resultGroups = {};
	-- Flatten the group mat into an array so it can be iterated over correctly without holes
	for index, sectionGroup in pairs(resultGroupsBySectionIndex) do
		table.insert(resultGroups, sectionGroup);
	end

	local displayDataProvider = CreateDataProvider(resultGroups);
	self.PagedSpellsFrame:SetDataProvider(displayDataProvider);
end

function SpellBookSearchMixin:ClearActiveSearchState(skipTabReset)
	local wasInSearchResultsMode = self:IsInSearchResultsMode();
	self.cachedSpellBookItems = nil;
	self.searchController:ClearActiveSearchResults();
	self.SearchBox:ClearFocus();
	self.SearchBox:SetText("");
	self:HidePreviewResultSearch();

	if wasInSearchResultsMode then
		self:DisableSearchResultsMode(skipTabReset);
	end
end

function SpellBookSearchMixin:EnableSearchResultsMode()
	self.isInSearchResultsMode = true;
	-- Clear our active tab
	self:SetTab(nil);
	-- Disable "Hide Passives" toggle while in search mode
	self.HidePassivesCheckButton:SetControlEnabled(false);
	self.HidePassivesCheckButton:SetTooltipText(SPELLBOOK_SEARCH_HIDE_PASSIVES_DISABLED);
end

function SpellBookSearchMixin:DisableSearchResultsMode(skipTabReset)
	self.isInSearchResultsMode = false;
	-- Re-enable "Hide Passives" toggle
	self.HidePassivesCheckButton:SetControlEnabled(true);
	self.HidePassivesCheckButton:SetTooltipText(nil);
	if not skipTabReset then
		self:ResetToFirstAvailableTab();
	end
end

function SpellBookSearchMixin:OnNotOnActionBarButtonClicked()
	self.SearchBox:ClearFocus();
	self.SearchBox:SetText(NotOnActionBarSearchText);
	self.SearchPreviewContainer:Hide();

	self:ActivateSearchFilter(SpellSearchUtil.FilterType.ActionBar);
end

function SpellBookSearchMixin:GetSearchPreviewContainer()
	return self.SearchPreviewContainer;
end

function SpellBookSearchMixin:GetAllDisplayableSpellBookItems()
	if self.cachedSpellBookItems then
		return self.cachedSpellBookItems;
	end

	self.cachedSpellBookItems = {};
	local byDataGroup = false;
	local filterFunc = self:GetSpellBookItemFilterInstance();

	for _, categoryMixin in ipairs(self.categoryMixins) do
		if categoryMixin:IsAvailable() then
			categoryMixin:GetSpellBookItemData(byDataGroup, filterFunc, self.cachedSpellBookItems);
		end
	end

	-- Add cached SpellBookItemInfo to avoid a lot of repeat C_SpellBook API calls throughout the search process
	for _, spellBookItemData in ipairs(self.cachedSpellBookItems) do
		spellBookItemData.spellBookItemInfo = C_SpellBook.GetSpellBookItemInfo(spellBookItemData.slotIndex, spellBookItemData.spellBank);
	end

	return self.cachedSpellBookItems;
end