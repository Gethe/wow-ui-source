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

	self.FilterDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:CreateCheckbox(HOUSING_CATALOG_FILTERS_DYEABLE, getCustomizableOnly, toggleCustomizableOnly);
		rootDescription:CreateCheckbox(HOUSING_CATALOG_FILTERS_INDOORS, getAllowedIndoors, toggleAllowedIndoors);
		rootDescription:CreateCheckbox(HOUSING_CATALOG_FILTERS_OUTDOORS, getAllowedOutdoors, toggleAllowedOutdoors);

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

	if self.catalogSearcher:IsCustomizableOnlyActive() then 
		return false;
	end
	if not self.catalogSearcher:IsAllowedIndoorsActive() or not self.catalogSearcher:IsAllowedOutdoorsActive() then 
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
	for _, tagGroup in ipairs(self.filterTagGroups) do
		self.catalogSearcher:SetAllInFilterTagGroup(tagGroup.groupID, true);
	end
	self.FilterDropdown:ValidateResetState();
end

function HousingCatalogFiltersMixin:SetEnabled(enabled)
	self.FilterDropdown:SetEnabled(enabled);
end