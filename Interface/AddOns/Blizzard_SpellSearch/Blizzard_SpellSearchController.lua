SpellSearchControllerMixin = {}

-- Initializes search controller instance with the provided SpellSearchSource instances
function SpellSearchControllerMixin:Init(searchSourceInstances)
	if self:IsInitialized() then
		return;
	end

	self.searchSources = searchSourceInstances;

	local textSearchEnabled = true;
	local actionBarSearchEnabled = false;

	self.searchFilters = {};
	local textFilterEnabled = true;
	local actionBarFilterEnabled = false; -- Default to opt-in by so that search contexts acknowledge they're focusing known player spells
	local nameFilterEnabled = true;
	self.searchFilters[SpellSearchUtil.FilterType.Text] = CreateAndInitFromMixin(SpellSearchTextFilterMixin, self, textFilterEnabled);
	self.searchFilters[SpellSearchUtil.FilterType.ActionBar] = CreateAndInitFromMixin(SpellSearchActionBarFilterMixin, self, actionBarFilterEnabled);
	self.searchFilters[SpellSearchUtil.FilterType.Name] = CreateAndInitFromMixin(SpellSearchNameFilterMixin, self, nameFilterEnabled);

	self.disabledFilters = {};

	self.isInitialized = true;

	self:UpdateEnabledSearchTypes();
end

function SpellSearchControllerMixin:IsInitialized()
	return self.isInitialized;
end

function SpellSearchControllerMixin:IsFilterEnabled(filterType)
	return self.searchFilters[filterType] and self.searchFilters[filterType]:GetIsEnabled();
end

function SpellSearchControllerMixin:SetFilterDisabled(filterType, disabled, forceClearSearchState)
	if disabled then
		self.disabledFilters[filterType] = true;
	else
		self.disabledFilters[filterType] = nil;
	end

	self:UpdateEnabledSearchTypes(forceClearSearchState);
end

-- Runs a specified search filter without deactivating any currently active filter, and returns the results
-- Note this should NOT be the currently active filter
function SpellSearchControllerMixin:RunFilterOnce(filterTypeToRun, customSortCompareFunc, ...)
	local filterToRun = self.searchFilters[filterTypeToRun];
	if not filterToRun or not filterToRun:GetIsEnabled() then
		return nil;
	end

	local activeSearchFilter = self:GetActiveSearchFilter();

	if activeSearchFilter and activeSearchFilter == filterToRun then
		assertsafe(false, "Cannot use the currently active search filter for a one-time search run")
		return nil;
	end

	filterToRun:SetSearchParams(...);
	local results = filterToRun:GetAggregateMatchResults(customSortCompareFunc);
	filterToRun:ClearSearchResults();

	return results;
end

-- Activates the specified filter and passes it the provided initial search params
function SpellSearchControllerMixin:ActivateSearchFilter(filterTypeToActivate, ...)
	-- Clear previously active mixin
	local newSearchMixin = self.searchFilters[filterTypeToActivate];

	local activeSearchMixin = self:GetActiveSearchFilter();
	if activeSearchMixin and activeSearchMixin ~= newSearchMixin then
		activeSearchMixin:ClearSearchResults();
	end

	-- Set new mixin
	if newSearchMixin then
		newSearchMixin:SetSearchParams(...);
	end
end

-- sourceType: SpellSearchUtil.SourceType
-- ...: Type-specific identifier params
function SpellSearchControllerMixin:GetMatchTypeForSourceTypeEntry(sourceType, ...)
	local activeFilter = self:GetActiveSearchFilter();
	if not activeFilter then
		return nil;
	end

	return activeFilter:GetMatchTypeForSourceTypeEntry(sourceType, ...);
end

function SpellSearchControllerMixin:UpdateEnabledSearchTypes(forceClearSearchState)
	local activeSearchDisabled = false;

	for filterType, filterMixin in pairs(self.searchFilters) do
		local wasFilterEnabled = filterMixin:GetIsEnabled();
		local isFilterEnabled = self.disabledFilters[filterType] ~= true;

		local didUpdateEnabled = wasFilterEnabled ~= isFilterEnabled;
		if didUpdateEnabled then
			filterMixin:SetEnabled(isFilterEnabled);

			if filterMixin:GetIsActive() then
				activeSearchDisabled = true;
			end
		end
	end

	if forceClearSearchState or activeSearchDisabled then
		self:ClearActiveSearchResults();
	end
end

function SpellSearchControllerMixin:GetActiveSearchFilter()
	for _, mixin in pairs(self.searchFilters) do
		if mixin:GetIsActive() then
			return mixin;
		end
	end
	return nil;
end

function SpellSearchControllerMixin:GetActiveSearchFilterType()
	for type, mixin in pairs(self.searchFilters) do
		if mixin:GetIsActive() then
			return type;
		end
	end
	return nil;
end

function SpellSearchControllerMixin:UpdateActiveSearchResults()
	local activeSearchMixin = self:GetActiveSearchFilter();
	if activeSearchMixin then
		activeSearchMixin:UpdateSearchResults();
	end
end

function SpellSearchControllerMixin:GetActiveSearchResults(customSortCompareFunc)
	local activeSearchFilter = self:GetActiveSearchFilter();
	if not activeSearchFilter then
		return nil;
	end

	return activeSearchFilter:GetAggregateMatchResults(customSortCompareFunc);
end

function SpellSearchControllerMixin:ClearActiveSearchResults()
	local activeSearchMixin = self:GetActiveSearchFilter();
	if activeSearchMixin then
		activeSearchMixin:ClearSearchResults();
	end
end

function SpellSearchControllerMixin:GetActiveSearchResultsSorter()
	local activeSearchFilter = self:GetActiveSearchFilter();
	if not activeSearchFilter then
		return nil;
	end

	return activeSearchFilter:GetResultSorter();
end

function SpellSearchControllerMixin:GetSearchSourceByType(sourceType)
	return self.searchSources[sourceType];
end