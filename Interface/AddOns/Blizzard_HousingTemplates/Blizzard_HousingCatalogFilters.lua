HousingCatalogFiltersMixin = {};

function HousingCatalogFiltersMixin:Initialize(catalogSearcher)
	self.catalogSearcher = catalogSearcher;

	self.filterTagGroups = C_HousingCatalog.GetAllFilterTagGroups();
	self.savedFilterStates = {};
	self:ResetFiltersToDefault();

	self.FilterDropdown:SetIsDefaultCallback(function() return self:AreFiltersAtDefault(); end);
	self.FilterDropdown:SetDefaultCallback(function()
		self:ResetFiltersToDefault();
		self:AutoSaveFilterState();
	end);

	local function getCustomizableOnly()
		return self:TryCallSearcherFunc("IsCustomizableOnlyActive");
	end
	local function toggleCustomizableOnly() 
		self:TryCallSearcherFunc("ToggleCustomizableOnly");
		self:AutoSaveFilterState();
	end

	local function setLocation(state)
		self:TryCallSearcherFunc("SetAllowedIndoors", state.indoors);
		self:TryCallSearcherFunc("SetAllowedOutdoors", state.outdoors);
		self:AutoSaveFilterState();
	end
	local function isLocationSet(state)
		return (self:TryCallSearcherFunc("IsAllowedIndoorsActive") == state.indoors) 
			and (self:TryCallSearcherFunc("IsAllowedOutdoorsActive") == state.outdoors);
	end

	local function setCollectionFilter(state)
		self:TryCallSearcherFunc("SetCollected", state.collected);
		self:TryCallSearcherFunc("SetUncollected", state.uncollected);
		self:AutoSaveFilterState();
	end
	local function isCollectionFilterSet(state)
		return (self:TryCallSearcherFunc("IsCollectedActive") == state.collected) 
			and (self:TryCallSearcherFunc("IsUncollectedActive") == state.uncollected);
	end

	local function getFirstAcquisitionBonusOnly()
		return self:TryCallSearcherFunc("IsFirstAcquisitionBonusOnlyActive");
	end
	local function toggleFirstAcquisitionBonusOnly()
		self:TryCallSearcherFunc("ToggleFirstAcquisitionBonusOnly");
		self:AutoSaveFilterState();
	end

	local function checkAllTagGroup(groupID)
		self:TryCallSearcherFunc("SetAllInFilterTagGroup", groupID, true);
		self:AutoSaveFilterState();
		return MenuResponse.Refresh; -- Keeps menu open on click
	end
	local function unCheckAllTagGroup(groupID)
		self:TryCallSearcherFunc("SetAllInFilterTagGroup", groupID, false);
		self:AutoSaveFilterState();
		return MenuResponse.Refresh; -- Keeps menu open on click
	end
	local function isFilterTagChecked(data)
		return self:TryCallSearcherFunc("GetFilterTagStatus", data.groupID, data.tagID);
	end
	local function toggleFilterTag(data)
		self:TryCallSearcherFunc("ToggleFilterTag", data.groupID, data.tagID);
		self:AutoSaveFilterState();
	end

	local function IsSortTypeChecked(parameter)
		return self:TryCallSearcherFunc("GetSortType") == parameter;
	end

	local function SetSortTypeChecked(parameter)
		self:TryCallSearcherFunc("SetSortType", parameter);
		self:AutoSaveFilterState();
	end

	self.FilterDropdown:SetupMenu(function(dropdown, rootDescription)
		local sortBySubmenu = rootDescription:CreateButton(HOUSING_CATALOG_SORT_LABEL);
		sortBySubmenu:CreateRadio(HOUSING_CHEST_SORT_TYPE_DATE_ADDED, IsSortTypeChecked, SetSortTypeChecked, Enum.HousingCatalogSortType.DateAdded);
		sortBySubmenu:CreateRadio(HOUSING_CHEST_SORT_TYPE_ALPHABETICAL, IsSortTypeChecked, SetSortTypeChecked, Enum.HousingCatalogSortType.Alphabetical);

		rootDescription:CreateDivider();

		rootDescription:CreateCheckbox(HOUSING_CATALOG_FILTERS_DYEABLE, getCustomizableOnly, toggleCustomizableOnly);

		if self.collectionFiltersAvailable then
			rootDescription:CreateCheckbox(HOUSING_CATALOG_FILTERS_FIRST_ACQUISITION, getFirstAcquisitionBonusOnly, toggleFirstAcquisitionBonusOnly);

			local collectionSubmenu = rootDescription:CreateButton(HOUSING_CATALOG_FILTERS_COLLECTION_LABEL);
			collectionSubmenu:CreateRadio(HOUSING_CATALOG_FILTERS_COLLECTION_BOTH, isCollectionFilterSet, setCollectionFilter, {collected = true, uncollected = true});
			collectionSubmenu:CreateRadio(HOUSING_CATALOG_FILTERS_COLLECTED, isCollectionFilterSet, setCollectionFilter, {collected = true, uncollected = false});
			collectionSubmenu:CreateRadio(HOUSING_CATALOG_FILTERS_UNCOLLECTED, isCollectionFilterSet, setCollectionFilter, {collected = false, uncollected = true});
		end

		local locationSubmenu = rootDescription:CreateButton(HOUSING_CATALOG_FILTERS_LOCATION_LABEL);
		locationSubmenu:CreateRadio(HOUSING_CATALOG_FILTERS_LOCATION_BOTH, isLocationSet, setLocation, {indoors = true, outdoors = true});
		locationSubmenu:CreateRadio(HOUSING_CATALOG_FILTERS_INDOORS, isLocationSet, setLocation, {indoors = true, outdoors = false});
		locationSubmenu:CreateRadio(HOUSING_CATALOG_FILTERS_OUTDOORS, isLocationSet, setLocation, {indoors = false, outdoors = true});

		rootDescription:CreateDivider();

		for groupIndex, tagGroup in ipairs(self.filterTagGroups) do
			if tagGroup.tags and TableHasAnyEntries(tagGroup.tags) then
				local groupSubmenu = rootDescription:CreateButton(tagGroup.groupName);
				groupSubmenu:SetGridMode(MenuConstants.VerticalGridDirection);

				groupSubmenu:CreateButton(CHECK_ALL, checkAllTagGroup, tagGroup.groupID);
				groupSubmenu:CreateButton(UNCHECK_ALL, unCheckAllTagGroup, tagGroup.groupID);

				for tagID, tagInfo in pairs(tagGroup.tags) do
					if tagInfo.anyAssociatedEntries then
						groupSubmenu:CreateCheckbox(tagInfo.tagName, isFilterTagChecked, toggleFilterTag, { groupID = tagGroup.groupID, tagID = tagInfo.tagID });
					end
				end
			end
		end
	end);
end

function HousingCatalogFiltersMixin:ClearSearcherReference()
	self.catalogSearcher = nil;
	self.FilterDropdown:CloseMenu();
end

function HousingCatalogFiltersMixin:TryCallSearcherFunc(funcName, ...)
	if not self.catalogSearcher then
		return nil;
	end
	return self.catalogSearcher[funcName](self.catalogSearcher, ...);
end

function HousingCatalogFiltersMixin:AreFiltersAtDefault()
	if not self.catalogSearcher then
		return true;
	end

	-- Don't show the reset button while disabled.
	if not self.FilterDropdown:IsEnabled() then
		return true;
	end

	if self.catalogSearcher:IsCustomizableOnlyActive() or self.catalogSearcher:IsFirstAcquisitionBonusOnlyActive() then
		return false;
	end
	if not self.catalogSearcher:IsAllowedIndoorsActive() or not self.catalogSearcher:IsAllowedOutdoorsActive() or
		not self.catalogSearcher:IsCollectedActive() or not self.catalogSearcher:IsUncollectedActive() then
		return false;
	end

	for groupIndex, tagGroup in ipairs(self.filterTagGroups) do
		for tagID, tagInfo in pairs(tagGroup.tags) do
			if not self.catalogSearcher:GetFilterTagStatus(tagGroup.groupID, tagInfo.tagID) then
				return false;
			end
		end
	end

	return true;
end

function HousingCatalogFiltersMixin:ResetFiltersToDefault()
	if not self.catalogSearcher then
		return;
	end

	self.catalogSearcher:SetCustomizableOnly(false);
	self.catalogSearcher:SetAllowedIndoors(true);
	self.catalogSearcher:SetAllowedOutdoors(true);
	self:ResetCollectionFilters();
	for _, tagGroup in ipairs(self.filterTagGroups) do
		self.catalogSearcher:SetAllInFilterTagGroup(tagGroup.groupID, true);
	end
	self.FilterDropdown:ValidateResetState();
end

function HousingCatalogFiltersMixin:SetEnabled(enabled)
	self.FilterDropdown:SetEnabled(enabled);
	self.FilterDropdown:ValidateResetState();
end

function HousingCatalogFiltersMixin:IsEnabled()
	return self.FilterDropdown:IsEnabled();
end

function HousingCatalogFiltersMixin:ResetCollectionFilters()
	self.catalogSearcher:SetCollected(true);
	self.catalogSearcher:SetUncollected(true);
	self.catalogSearcher:SetFirstAcquisitionBonusOnly(false);
end

function HousingCatalogFiltersMixin:SetCollectionFiltersAvailable(available)
	self.collectionFiltersAvailable = available;

	if not available then
		self:ResetCollectionFilters();
	end

	self.FilterDropdown:ValidateResetState();
end

function HousingCatalogFiltersMixin:SetSavedStateKey(key)
	self.savedStateKey = key;
end

function HousingCatalogFiltersMixin:AutoSaveFilterState()
	if self.savedStateKey then
		self:SaveFilterState(self.savedStateKey);
	end
end

function HousingCatalogFiltersMixin:SaveFilterState(key)
	if not self.catalogSearcher then
		return;
	end

	local savedTagStates = {};
	for _, tagGroup in ipairs(self.filterTagGroups) do
		savedTagStates[tagGroup.groupID] = {};
		for tagID, tagInfo in pairs(tagGroup.tags) do
			savedTagStates[tagGroup.groupID][tagInfo.tagID] = self.catalogSearcher:GetFilterTagStatus(tagGroup.groupID, tagInfo.tagID);
		end
	end

	self.savedFilterStates[key] = {
		sortType = self.catalogSearcher:GetSortType(),
		customizableOnly = self.catalogSearcher:IsCustomizableOnlyActive(),
		allowedIndoors = self.catalogSearcher:IsAllowedIndoorsActive(),
		allowedOutdoors = self.catalogSearcher:IsAllowedOutdoorsActive(),
		collected = self.catalogSearcher:IsCollectedActive(),
		uncollected = self.catalogSearcher:IsUncollectedActive(),
		firstAcquisitionBonusOnly = self.catalogSearcher:IsFirstAcquisitionBonusOnlyActive(),
		filterTagStates = savedTagStates,
	};
end

function HousingCatalogFiltersMixin:RestoreFilterState(key)
	if not self.catalogSearcher then
		return;
	end

	local savedState = self.savedFilterStates[key];
	if not savedState then
		self:ResetFiltersToDefault();
		return;
	end

	self.catalogSearcher:SetSortType(savedState.sortType);
	self.catalogSearcher:SetCustomizableOnly(savedState.customizableOnly);
	self.catalogSearcher:SetAllowedIndoors(savedState.allowedIndoors);
	self.catalogSearcher:SetAllowedOutdoors(savedState.allowedOutdoors);
	self.catalogSearcher:SetCollected(savedState.collected);
	self.catalogSearcher:SetUncollected(savedState.uncollected);
	self.catalogSearcher:SetFirstAcquisitionBonusOnly(savedState.firstAcquisitionBonusOnly);

	for groupID, tagStates in pairs(savedState.filterTagStates) do
		for tagID, isActive in pairs(tagStates) do
			self.catalogSearcher:SetFilterTagStatus(groupID, tagID, isActive);
		end
	end

	self.FilterDropdown:ValidateResetState();
end

HousingCatalogSearchBoxMixin = {};

function HousingCatalogSearchBoxMixin:OnLoad()
	SearchBoxTemplate_OnLoad(self);

	self.clearButton:SetScript("OnClick", function(btn)
		SearchBoxTemplateClearButton_OnClick(btn);
		self:UpdateTextSearch(self:GetText());
	end);
end

function HousingCatalogSearchBoxMixin:Initialize(onSearchTextUpdatedCallback)
	self.onSearchTextUpdatedCallback = onSearchTextUpdatedCallback;
end

function HousingCatalogSearchBoxMixin:OnTextChanged()
	SearchBoxTemplate_OnTextChanged(self);

	if self:HasFocus() then
		local currentText = self:GetText();
		local numSearchChars = strlenutf8(currentText);
		if numSearchChars >= MIN_CHARACTER_SEARCH then
			self:UpdateTextSearch(currentText);
		else
			self:UpdateTextSearch("");
		end
	end
end

function HousingCatalogSearchBoxMixin:UpdateTextSearch(text)
	if self.onSearchTextUpdatedCallback then
		self.onSearchTextUpdatedCallback(text);
	end
end
