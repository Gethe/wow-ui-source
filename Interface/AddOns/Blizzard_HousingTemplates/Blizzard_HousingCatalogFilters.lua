HousingCatalogFiltersMixin = {};

function HousingCatalogFiltersMixin:Initialize(catalogSearcher)
	self.catalogSearcher = catalogSearcher;

	self.filterTagGroups = C_HousingCatalog.GetAllFilterTagGroups();
	self:ResetFiltersToDefault();

	self.FilterDropdown:SetIsDefaultCallback(function() return self:AreFiltersAtDefault(); end);
	self.FilterDropdown:SetDefaultCallback(function() self:ResetFiltersToDefault(); end);

	local function getCustomizableOnly()
		return self:TryCallSearcherFunc("IsCustomizableOnlyActive");
	end
	local function toggleCustomizableOnly() 
		self:TryCallSearcherFunc("ToggleCustomizableOnly");
	end

	local function getAllowedIndoors()
		return self:TryCallSearcherFunc("IsAllowedIndoorsActive");
	end
	local function toggleAllowedIndoors() 
		self:TryCallSearcherFunc("ToggleAllowedIndoors");
	end

	local function getAllowedOutdoors()
		return self:TryCallSearcherFunc("IsAllowedOutdoorsActive");
	end
	local function toggleAllowedOutdoors()
		self:TryCallSearcherFunc("ToggleAllowedOutdoors");
	end

	local function getCollected()
		return self:TryCallSearcherFunc("IsCollectedActive");
	end
	local function toggleCollected()
		self:TryCallSearcherFunc("ToggleCollected");
	end

	local function getUncollected()
		return self:TryCallSearcherFunc("IsUncollectedActive");
	end
	local function toggleUncollected()
		self:TryCallSearcherFunc("ToggleUncollected");
	end

	local function getFirstAcquisitionBonusOnly()
		return self:TryCallSearcherFunc("IsFirstAcquisitionBonusOnlyActive");
	end
	local function toggleFirstAcquisitionBonusOnly()
		self:TryCallSearcherFunc("ToggleFirstAcquisitionBonusOnly");
	end

	local function checkAllTagGroup(groupID)
		self:TryCallSearcherFunc("SetAllInFilterTagGroup", groupID, true);
		return MenuResponse.Refresh; -- Keeps menu open on click
	end
	local function unCheckAllTagGroup(groupID)
		self:TryCallSearcherFunc("SetAllInFilterTagGroup", groupID, false);
		return MenuResponse.Refresh; -- Keeps menu open on click
	end
	local function isFilterTagChecked(data)
		return self:TryCallSearcherFunc("GetFilterTagStatus", data.groupID, data.tagID);
	end
	local function toggleFilterTag(data)
		self:TryCallSearcherFunc("ToggleFilterTag", data.groupID, data.tagID);
	end

	local function IsSortTypeChecked(parameter)
		return self:TryCallSearcherFunc("GetSortType") == parameter;
	end

	local function SetSortTypeChecked(parameter)
		self:TryCallSearcherFunc("SetSortType", parameter);
	end

	self.FilterDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:CreateCheckbox(HOUSING_CATALOG_FILTERS_DYEABLE, getCustomizableOnly, toggleCustomizableOnly);
		rootDescription:CreateCheckbox(HOUSING_CATALOG_FILTERS_INDOORS, getAllowedIndoors, toggleAllowedIndoors);
		rootDescription:CreateCheckbox(HOUSING_CATALOG_FILTERS_OUTDOORS, getAllowedOutdoors, toggleAllowedOutdoors);

		if self.collectionFiltersAvailable then
			rootDescription:CreateCheckbox(HOUSING_CATALOG_FILTERS_COLLECTED, getCollected, toggleCollected);
			rootDescription:CreateCheckbox(HOUSING_CATALOG_FILTERS_UNCOLLECTED, getUncollected, toggleUncollected);
			rootDescription:CreateCheckbox(HOUSING_CATALOG_FILTERS_FIRST_ACQUISITION, getFirstAcquisitionBonusOnly, toggleFirstAcquisitionBonusOnly);
		end

		local sortBySubmenu = rootDescription:CreateButton(RAID_FRAME_SORT_LABEL);
		sortBySubmenu:CreateRadio(HOUSING_CHEST_SORT_TYPE_DATE_ADDED, IsSortTypeChecked, SetSortTypeChecked, Enum.HousingCatalogSortType.DateAdded);
		sortBySubmenu:CreateRadio(HOUSING_CHEST_SORT_TYPE_ALPHABETICAL, IsSortTypeChecked, SetSortTypeChecked, Enum.HousingCatalogSortType.Alphabetical);

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
