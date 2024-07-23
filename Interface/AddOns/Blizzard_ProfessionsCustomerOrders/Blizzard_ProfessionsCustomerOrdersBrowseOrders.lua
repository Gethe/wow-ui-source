ProfessionsCustomerOrdersBrowsePageMixin = {};

local ProfessionsCustomerOrdersBrowsePageEvents =
{
	"CRAFTINGORDERS_CUSTOMER_OPTIONS_PARSED",
	"CRAFTINGORDERS_CUSTOMER_FAVORITES_CHANGED",
};

local function GetQualityFilterString(itemQuality)
	local hex = select(4, C_Item.GetItemQualityColor(itemQuality));
	local text = _G["ITEM_QUALITY"..itemQuality.."_DESC"];
	return "|c"..hex..text.."|r";
end

local function GetFilterName(filter)
	if filter == Enum.AuctionHouseFilter.LegendaryCraftedItemOnly then
		return "";
	end

	return GetAHFilterName(filter);
end

function ProfessionsCustomerOrdersBrowsePageMixin:SetDefaultFilters()
	local filterDropdown = self.SearchBar.FilterDropdown;
	filterDropdown.filters = CopyTable(AUCTION_HOUSE_DEFAULT_FILTERS);
	filterDropdown.minLevel = 0;
	filterDropdown.maxLevel = 0;
end

function ProfessionsCustomerOrdersBrowsePageMixin:UpdateFavoritesButton()
	local hasFavorites = C_CraftingOrders.HasFavoriteCustomerOptions();
	self.SearchBar.FavoritesSearchButton:SetEnabled(hasFavorites);
	self.SearchBar.FavoritesSearchButton.Icon:SetDesaturated(not hasFavorites);
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

	self:InitContextMenu();
end

function ProfessionsCustomerOrdersBrowsePageMixin:InitFilterDropdown()
	local filterDropdown = self.SearchBar.FilterDropdown;
	filterDropdown:SetDefaultCallback(function()
		filterDropdown.filters = CopyTable(AUCTION_HOUSE_DEFAULT_FILTERS);
		filterDropdown.minLevel = 0;
		filterDropdown.maxLevel = 0;
	end);

	filterDropdown:SetIsDefaultCallback(function()
		if filterDropdown.minLevel ~= 0 or filterDropdown.minLevel ~= 0 then
			return false;
		end

		return tCompare(filterDropdown.filters, AUCTION_HOUSE_DEFAULT_FILTERS);
	end);

	local function IsSelected(filter)
		return filterDropdown.filters[filter];
	end

	local function SetSelected(filter)
		filterDropdown.filters[filter] = not filterDropdown.filters[filter];
	end

	filterDropdown:SetWidth(93);
	filterDropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_PROFESSIONS_CUSTOMER_ORDER_BROWSE");

		rootDescription:CreateTitle(AUCTION_HOUSE_FILTER_DROP_DOWN_LEVEL_RANGE);

		local levelRangeFrame = rootDescription:CreateTemplate("LevelRangeFrameTemplate");
		levelRangeFrame:AddInitializer(function(frame, elementDescription, menu)
			frame:Reset();

			local minLevel = filterDropdown.minLevel;
			if minLevel > 0 then
				frame:SetMinLevel(minLevel);
			end

			local maxLevel = filterDropdown.maxLevel;
			if maxLevel > 0 then
				frame:SetMaxLevel(maxLevel);
			end

			frame:SetLevelRangeChangedCallback(function(minLevel, maxLevel)
				filterDropdown.minLevel, filterDropdown.maxLevel = minLevel, maxLevel;
				filterDropdown:ValidateResetState();
			end);
		end);

		for index, filterGroup in ipairs(C_AuctionHouse.GetFilterGroups()) do
			rootDescription:CreateTitle(GetAHFilterCategoryName(filterGroup.category));

			for _, filter in ipairs(filterGroup.filters) do
				rootDescription:CreateCheckbox(GetFilterName(filter), IsSelected, SetSelected, filter);
			end

			rootDescription:QueueSpacer();
		end
	end);
end

function ProfessionsCustomerOrdersBrowsePageMixin:InitContextMenu()
	-- SetContextMenuGenerator assigns the context menu handler in Blizzard_ProfessionsCustomerOrdersRecipeList.lua,
	-- suitable to any context menu only requiring the recipe ID.
	self.RecipeList:SetContextMenuGenerator(function(owner, rootDescription, recipeID)
		local currentlyFavorite = C_CraftingOrders.IsCustomerOptionFavorited(recipeID);
		local cannotFavorite = not currentlyFavorite and C_CraftingOrders.GetNumFavoriteCustomerOptions() >= Constants.CraftingOrderConsts.MAX_CRAFTING_ORDER_FAVORITE_RECIPES;
		if cannotFavorite then
			local button = rootDescription:CreateButton(DISABLED_FONT_COLOR:WrapTextInColorCode(text), nop);
			button:SetEnabled(false);
			button:SetTooltip(function(tooltip, elementDescription)
				GameTooltip_AddErrorLine(tooltip, PROFESSIONS_CRAFTING_ORDERS_FAVORITES_FULL);
			end);
		else
			local text = currentlyFavorite and BATTLE_PET_UNFAVORITE or BATTLE_PET_FAVORITE;
			rootDescription:CreateButton(text, function()
				C_CraftingOrders.SetCustomerOptionFavorited(recipeID, not currentlyFavorite);
			end);
		end
	end);
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
	self:InitFilterDropdown();

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
	local filterDropdown = self.SearchBar.FilterDropdown;
	local minLevel, maxLevel = filterDropdown.minLevel, filterDropdown.maxLevel;

    local searchParams =
	{
		isFavoritesSearch = isFavoritesSearch,
		-- All filters are ignored for favorites searches
		categoryFilters = categoryFilters,
		searchText = searchText,
		minLevel = minLevel,
		maxLevel = maxLevel,
		uncollectedOnly = filterDropdown.filters[Enum.AuctionHouseFilter.UncollectedOnly],
		usableOnly = filterDropdown.filters[Enum.AuctionHouseFilter.UsableOnly],
		upgradesOnly = filterDropdown.filters[Enum.AuctionHouseFilter.UpgradesOnly],
		currentExpansionOnly = filterDropdown.filters[Enum.AuctionHouseFilter.CurrentExpansionOnly],
		includePoor = filterDropdown.filters[Enum.AuctionHouseFilter.PoorQuality],
		includeCommon = filterDropdown.filters[Enum.AuctionHouseFilter.CommonQuality],
		includeUncommon = filterDropdown.filters[Enum.AuctionHouseFilter.UncommonQuality],
		includeRare = filterDropdown.filters[Enum.AuctionHouseFilter.RareQuality],
		includeEpic = filterDropdown.filters[Enum.AuctionHouseFilter.EpicQuality],
		includeLegendary = filterDropdown.filters[Enum.AuctionHouseFilter.LegendaryQuality],
		includeArtifact = filterDropdown.filters[Enum.AuctionHouseFilter.ArtifactQuality],
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
		dataProvider:Insert({option = option});
	end
	dataProvider:SetSortComparator(self.sortManager:CreateComparator());
	self.RecipeList.ScrollBox:SetDataProvider(dataProvider);
end