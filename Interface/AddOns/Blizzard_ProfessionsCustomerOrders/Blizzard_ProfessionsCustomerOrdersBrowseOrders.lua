ProfessionsCustomerOrdersBrowsePageMixin = {};

local ProfessionsCustomerOrdersBrowsePageEvents =
{
	"CRAFTINGORDERS_CUSTOMER_OPTIONS_PARSED",
	"CRAFTINGORDERS_CUSTOMER_FAVORITES_CHANGED",
};

local defaultFilters = 
{
	[Enum.AuctionHouseFilter.UncollectedOnly] = false,
	[Enum.AuctionHouseFilter.UsableOnly] = false,
	[Enum.AuctionHouseFilter.UpgradesOnly] = false,
	[Enum.AuctionHouseFilter.PoorQuality] = true,
	[Enum.AuctionHouseFilter.CommonQuality] = true,
	[Enum.AuctionHouseFilter.UncommonQuality] = true,
	[Enum.AuctionHouseFilter.RareQuality] = true,
	[Enum.AuctionHouseFilter.EpicQuality] = true,
	[Enum.AuctionHouseFilter.LegendaryQuality] = true,
	[Enum.AuctionHouseFilter.ArtifactQuality] = true,
};

local categoryStrings =
{
	[Enum.AuctionHouseFilterCategory.Uncategorized] = "",
	[Enum.AuctionHouseFilterCategory.Equipment] = AUCTION_HOUSE_FILTER_CATEGORY_EQUIPMENT,
	[Enum.AuctionHouseFilterCategory.Rarity] = AUCTION_HOUSE_FILTER_CATEGORY_RARITY,
};

local function GetQualityFilterString(itemQuality)
	local hex = select(4, GetItemQualityColor(itemQuality));
	local text = _G["ITEM_QUALITY"..itemQuality.."_DESC"];
	return "|c"..hex..text.."|r";
end

local filterStrings = 
{
	[Enum.AuctionHouseFilter.UncollectedOnly] = AUCTION_HOUSE_FILTER_UNCOLLECTED_ONLY,
	[Enum.AuctionHouseFilter.UsableOnly] = AUCTION_HOUSE_FILTER_USABLE_ONLY,
	[Enum.AuctionHouseFilter.UpgradesOnly] = AUCTION_HOUSE_FILTER_UPGRADES_ONLY,
	[Enum.AuctionHouseFilter.PoorQuality] = GetQualityFilterString(Enum.ItemQuality.Poor),
	[Enum.AuctionHouseFilter.CommonQuality] = GetQualityFilterString(Enum.ItemQuality.Common),
	[Enum.AuctionHouseFilter.UncommonQuality] = GetQualityFilterString(Enum.ItemQuality.Uncommon),
	[Enum.AuctionHouseFilter.RareQuality] = GetQualityFilterString(Enum.ItemQuality.Rare),
	[Enum.AuctionHouseFilter.EpicQuality] = GetQualityFilterString(Enum.ItemQuality.Epic),
	[Enum.AuctionHouseFilter.LegendaryQuality] = GetQualityFilterString(Enum.ItemQuality.Legendary),
	[Enum.AuctionHouseFilter.ArtifactQuality] = GetQualityFilterString(Enum.ItemQuality.Artifact),
};

function ProfessionsCustomerOrdersBrowsePageMixin:GetFilterLevelRange()
	return self.SearchBar.FilterButton.LevelRangeFrame:GetLevelRange();
end

function ProfessionsCustomerOrdersBrowsePageMixin:SetDefaultFilters()
	self.filters = CopyTable(defaultFilters);
	self.SearchBar.FilterButton.LevelRangeFrame:Reset();
	self:UpdateFilterResetVisibility();
end

function ProfessionsCustomerOrdersBrowsePageMixin:IsUsingDefaultFilters()
	local minLevel, maxLevel = self:GetFilterLevelRange();
	if minLevel ~= 0 or maxLevel ~= 0 then
		return false;
	end

	if not tCompare(self.filters, defaultFilters) then
		return false;
	end

	return true;
end

function ProfessionsCustomerOrdersBrowsePageMixin:UpdateFilterResetVisibility()
	self.SearchBar.FilterButton.ClearFiltersButton:SetShown(not self:IsUsingDefaultFilters());
end

function ProfessionsCustomerOrdersBrowsePageMixin:InitFilterMenu()
	local info = UIDropDownMenu_CreateInfo();
	info.text = AUCTION_HOUSE_FILTER_DROP_DOWN_LEVEL_RANGE;
	info.isTitle = true;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);

	local info = UIDropDownMenu_CreateInfo();
	info.customFrame = self.SearchBar.FilterButton.LevelRangeFrame;
	UIDropDownMenu_AddButton(info);

	local filterGroups = C_AuctionHouse.GetFilterGroups();
	for i, filterGroup in ipairs(filterGroups) do
		local info = UIDropDownMenu_CreateInfo();
		info.text = categoryStrings[filterGroup.category];
		info.isTitle = true;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info);

		for j, filter in ipairs(filterGroup.filters) do
			local info = UIDropDownMenu_CreateInfo();
			info.text = filterStrings[filter];
			info.value = nil;
			info.isNotRadio = true;
			info.checked = self.filters[filter];
			info.keepShownOnClick = 1;
			info.func = function(button)
				self.filters[filter] = not self.filters[filter];
				self:UpdateFilterResetVisibility();
			end
			UIDropDownMenu_AddButton(info);
		end

		if i ~= #filterGroups then
			UIDropDownMenu_AddSpace();
		end
	end
end

function ProfessionsCustomerOrdersBrowsePageMixin:UpdateFavoritesButton()
	local hasFavorites = C_CraftingOrders.HasFavoriteCustomerOptions();
	self.SearchBar.FavoritesSearchButton:SetEnabled(hasFavorites);
	self.SearchBar.FavoritesSearchButton.Icon:SetDesaturated(not hasFavorites);
end

function ProfessionsCustomerOrdersBrowsePageMixin:InitContextMenu(dropDown, level)
	local recipeID = UIDROPDOWNMENU_MENU_VALUE;
	local info = UIDropDownMenu_CreateInfo();
	info.notCheckable = true;
	
	local currentlyFavorite = C_CraftingOrders.IsCustomerOptionFavorited(recipeID);
	info.text = currentlyFavorite and BATTLE_PET_UNFAVORITE or BATTLE_PET_FAVORITE;
	if not currentlyFavorite and C_CraftingOrders.GetNumFavoriteCustomerOptions() >= Constants.CraftingOrderConsts.MAX_CRAFTING_ORDER_FAVORITE_RECIPES then
		info.text = DISABLED_FONT_COLOR:WrapTextInColorCode(info.text);
		info.disabled = true;
		info.tooltipWhileDisabled = true;
		info.tooltipOnButton = true;
		info.tooltipTitle = "";
		info.tooltipWarning = PROFESSIONS_CRAFTING_ORDERS_FAVORITES_FULL;
	else
		info.func = GenerateClosure(C_CraftingOrders.SetCustomerOptionFavorited, recipeID, not currentlyFavorite);
	end

	UIDropDownMenu_AddButton(info, level);
end

function ProfessionsCustomerOrdersBrowsePageMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, ProfessionsCustomerOrdersBrowsePageEvents);

	-- Init search button
	self.SearchBar.SearchButton:SetScript("OnClick", function() self:StartSearch(false); end);

	-- Init search box
	self.SearchBar.SearchBox:SetScript("OnEnterPressed", function(box)
		EditBox_ClearFocus(box);
		self:StartSearch(false);
	end);

	-- Init favorites button
	self.SearchBar.FavoritesSearchButton.Icon:SetAtlas("auctionhouse-icon-favorite");
	self.SearchBar.FavoritesSearchButton:SetScript("OnClick", function() self:StartSearch(true); end);
	self.SearchBar.FavoritesSearchButton:SetScript("OnEnter", function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_RIGHT");
		GameTooltip_AddHighlightLine(GameTooltip, FAVORITES);
		if not C_CraftingOrders.HasFavoriteCustomerOptions() then
			GameTooltip_AddNormalLine(GameTooltip, PROFESSIONS_FAVORITES_SEARCH_TOOLTIP_NO_FAVORITES);
		end
		GameTooltip:Show();
	 end);
	self:UpdateFavoritesButton();

	-- Init categories list
	self.CategoryList:Init();

	-- Init item table
	self.tableBuilder = CreateTableBuilder(nil, ProfessionsTableBuilderMixin);
	self.tableBuilder:SetTableWidth(self.RecipeList.ScrollBox:GetWidth());
	local function ElementDataProvider(elementData)
		return elementData;
	end;
	self.tableBuilder:SetDataProvider(ElementDataProvider);

	local function ElementDataTranslator(elementData)
		return elementData;
	end;
	ScrollUtil.RegisterTableBuilder(self.RecipeList.ScrollBox, self.tableBuilder, ElementDataTranslator);

	-- Init filters
	self.SearchBar.FilterButton:SetScript("OnClick", function()
		ToggleDropDownMenu(1, nil, self.SearchBar.FilterButton.DropDown, self.SearchBar.FilterButton, 9, 3);
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end);
	self.SearchBar.FilterButton.ClearFiltersButton:SetScript("OnClick", function() self:SetDefaultFilters(); end);
	self.SearchBar.FilterButton.LevelRangeFrame:SetLevelRangeChangedCallback(function() self:UpdateFilterResetVisibility(); end);
	UIDropDownMenu_SetInitializeFunction(self.SearchBar.FilterButton.DropDown, function() self:InitFilterMenu(); end);
	UIDropDownMenu_SetDisplayMode(self.SearchBar.FilterButton.DropDown, "MENU");

	-- Init context menu
	UIDropDownMenu_SetInitializeFunction(self.RecipeList.ContextMenu, GenerateClosure(self.InitContextMenu, self));
	UIDropDownMenu_SetDisplayMode(self.RecipeList.ContextMenu, "MENU");
end

function ProfessionsCustomerOrdersBrowsePageMixin:OnEvent(event, ...)
	if event == "CRAFTINGORDERS_CUSTOMER_OPTIONS_PARSED" then
		self.CategoryList:OnDataLoadFinished();
        self.SearchBar.SearchButton:Enable();
		if C_CraftingOrders.HasFavoriteCustomerOptions() then
			self:StartSearch(true);
		else
			self.RecipeList.ResultsText:SetText(CUSTOMER_CRAFTING_ORDERS_BROWSE_FAVORITES_TIP);
			self.RecipeList.ResultsText:Show();
		end
	elseif event == "CRAFTINGORDERS_CUSTOMER_FAVORITES_CHANGED" then
		self:UpdateFavoritesButton();
	end
end

function ProfessionsCustomerOrdersBrowsePageMixin:Init()
	self.SearchBar.SearchBox:SetText("");
    self.SearchBar.SearchButton:Disable();
	self.CategoryList:Init();
	self:SetupSortManager();
	self:SetupTable();
	self:SetDefaultFilters();

	local dataProvider = CreateDataProvider();
	self.RecipeList.ScrollBox:SetDataProvider(dataProvider);

    C_CraftingOrders.ParseCustomerOptions();
end

local function GetSortOrderFromType(extraColumnType)
	if extraColumnType == Enum.AuctionHouseExtraColumn.Ilvl then
		return ProfessionsSortOrder.Ilvl;
	elseif extraColumnType == Enum.AuctionHouseExtraColumn.Slots then
		return ProfessionsSortOrder.Slots;
	elseif extraColumnType == Enum.AuctionHouseExtraColumn.Level then
		return ProfessionsSortOrder.Level;
	elseif extraColumnType == Enum.AuctionHouseExtraColumn.Skill then
		return ProfessionsSortOrder.Skill;
	end
end

local function GetColumnInfoFromType(extraColumnType)
	local PTC = ProfessionsTableConstants;
	local sortOrder = GetSortOrderFromType(extraColumnType);

	if extraColumnType == Enum.AuctionHouseExtraColumn.Ilvl then
		return PTC.NoPadding, PTC.Ilvl.Width, PTC.Ilvl.LeftCellPadding, PTC.Ilvl.RightCellPadding, sortOrder, "ProfessionsCustomerTableCellIlvlTemplate";
	elseif extraColumnType == Enum.AuctionHouseExtraColumn.Slots then
		return PTC.NoPadding, PTC.Slots.Width, PTC.Slots.LeftCellPadding, PTC.Slots.RightCellPadding, sortOrder, "ProfessionsCustomerTableCellSlotsTemplate";
	elseif extraColumnType == Enum.AuctionHouseExtraColumn.Level then
		return PTC.NoPadding, PTC.Level.Width, PTC.Level.LeftCellPadding, PTC.Level.RightCellPadding, sortOrder, "ProfessionsCustomerTableCellLevelTemplate";
	elseif extraColumnType == Enum.AuctionHouseExtraColumn.Skill then
		return PTC.NoPadding, PTC.Skill.Width, PTC.Skill.LeftCellPadding, PTC.Skill.RightCellPadding, sortOrder, "ProfessionsCustomerTableCellSkillTemplate";
	end
end

function ProfessionsCustomerOrdersBrowsePageMixin:SetupTable(extraColumnType)
	self.tableBuilder:Reset();
	self.tableBuilder:SetColumnHeaderOverlap(2);
	self.tableBuilder:SetHeaderContainer(self.RecipeList.HeaderContainer);
	self.tableBuilder:SetTableMargins(5, 5);

	local PTC = ProfessionsTableConstants;
	self.tableBuilder:AddFillColumn(self, PTC.NoPadding, 1.0,
		PTC.ItemName.LeftCellPadding, PTC.ItemName.RightCellPadding, ProfessionsSortOrder.ItemName, "ProfessionsCustomerTableCellItemNameTemplate");

	if extraColumnType ~= nil and extraColumnType ~= Enum.AuctionHouseExtraColumn.None then
		self.tableBuilder:AddFixedWidthColumn(self, GetColumnInfoFromType(extraColumnType));
		if extraColumnType == Enum.AuctionHouseExtraColumn.Ilvl then
			self:SetSortOrder(ProfessionsSortOrder.Ilvl);
		end
	end

	self.tableBuilder:Arrange();
end

function ProfessionsCustomerOrdersBrowsePageMixin:SetSortOrderInternal(sortOrder)
	if self.sortOrder == sortOrder then
		self.sortManager:ToggleSortAscending(sortOrder);
	else
		self.sortOrder = sortOrder;
		self.sortManager:SetSortAscending(sortOrder, true);
	end
end

function ProfessionsCustomerOrdersBrowsePageMixin:SetSortOrder(sortOrder)
	self:SetSortOrderInternal(sortOrder);

	for frame in self.tableBuilder:EnumerateHeaders() do
		frame:UpdateArrow();
	end

	self.RecipeList.ScrollBox:GetDataProvider():Sort();
end

function ProfessionsCustomerOrdersBrowsePageMixin:GetSortOrder()
	return self.sortOrder, self.sortManager:IsSortAscending(self.sortOrder);
end

local function GetCompareFieldFromType(extraColumnType)
	if extraColumnType == Enum.AuctionHouseExtraColumn.Ilvl then
		return "iLvlMax";
	elseif extraColumnType == Enum.AuctionHouseExtraColumn.Slots then
		return "slots";
	elseif extraColumnType == Enum.AuctionHouseExtraColumn.Level then
		return "level";
	elseif extraColumnType == Enum.AuctionHouseExtraColumn.Skill then
		return "skill";
	end
end

local function GetFallbackCompareFieldFromType(extraColumnType)
	if extraColumnType == Enum.AuctionHouseExtraColumn.Ilvl then
		return "iLvlMin";
	end
end

function ProfessionsCustomerOrdersBrowsePageMixin:SetupSortManager(extraColumnType)
	self.sortManager = SortUtil.CreateSortManager();
	self.sortManager:SetDefaultComparator(function(lhs, rhs)
		return lhs.option.itemID < rhs.option.itemID;
	end);
	self.sortManager:SetSortOrderFunc(function()
		return self.sortOrder;
	end);

	self.sortManager:InsertComparator(ProfessionsSortOrder.ItemName, function(lhs, rhs)
		return SortUtil.CompareUtf8i(lhs.option.itemName, rhs.option.itemName);
	end);

	local extraColumnField = extraColumnType and GetCompareFieldFromType(extraColumnType);
	local fallbackColumnFiled = extraColumnType and GetFallbackCompareFieldFromType(extraColumnType);
	if extraColumnField ~= nil then
		self.sortManager:InsertComparator(GetSortOrderFromType(extraColumnType), function(lhs, rhs)
			return SortUtil.CompareNumeric(lhs.option[extraColumnField] or lhs.option[fallbackColumnFiled], rhs.option[extraColumnField] or rhs.option[fallbackColumnFiled]);
		end);
	end

	-- Sort order needs to be assigned prior to the table builder generating rows.
	self:SetSortOrderInternal(ProfessionsSortOrder.ItemName);
end

function ProfessionsCustomerOrdersBrowsePageMixin:StartSearch(isFavoritesSearch)
    local categoryFilters = self.CategoryList:GetCategoryFilters();
	local searchBoxText = self.SearchBar.SearchBox:GetText();
    local searchText = searchBoxText ~= "" and searchBoxText or nil;
	local minLevel, maxLevel = self:GetFilterLevelRange();

    local searchParams =
	{
		isFavoritesSearch = isFavoritesSearch,
		-- All filters are ignored for favorites searches
		categoryFilters = categoryFilters,
		searchText = searchText,
		minLevel = minLevel,
		maxLevel = maxLevel,
		uncollectedOnly = self.filters[Enum.AuctionHouseFilter.UncollectedOnly],
		usableOnly = self.filters[Enum.AuctionHouseFilter.UsableOnly],
		upgradesOnly = self.filters[Enum.AuctionHouseFilter.UpgradesOnly],
		includePoor = self.filters[Enum.AuctionHouseFilter.PoorQuality],
		includeCommon = self.filters[Enum.AuctionHouseFilter.CommonQuality],
		includeUncommon = self.filters[Enum.AuctionHouseFilter.UncommonQuality],
		includeRare = self.filters[Enum.AuctionHouseFilter.RareQuality],
		includeEpic = self.filters[Enum.AuctionHouseFilter.EpicQuality],
		includeLegendary = self.filters[Enum.AuctionHouseFilter.LegendaryQuality],
		includeArtifact = self.filters[Enum.AuctionHouseFilter.ArtifactQuality],
	};

	local searchResults = C_CraftingOrders.GetCustomerOptions(searchParams);

	local anyResults = #searchResults.options > 0;
	self.RecipeList.ResultsText:SetShown(not anyResults);
	if not anyResults then
		self.RecipeList.ResultsText:SetText(CUSTOMER_CRAFTING_ORDERS_BROWSE_NO_RESULTS);
	end

	self:SetupSortManager(searchResults.extraColumnType)
	self:SetupTable(searchResults.extraColumnType);

	local dataProvider = CreateDataProvider();
	for _, option in ipairs(searchResults.options) do
		dataProvider:Insert({option = option, contextMenu = self.RecipeList.ContextMenu});
	end
	dataProvider:SetSortComparator(self.sortManager:CreateComparator());
	self.RecipeList.ScrollBox:SetDataProvider(dataProvider);
end