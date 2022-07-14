ProfessionsCustomerOrdersBrowsePageMixin = {};

local ProfessionsCustomerOrdersBrowsePageEvents =
{
	"CRAFTINGORDERS_CUSTOMER_OPTIONS_PARSED",
};

function ProfessionsCustomerOrdersBrowsePageMixin:OnLoad()
	FrameUtil.RegisterFrameForEvents(self, ProfessionsCustomerOrdersBrowsePageEvents);

	-- Init search button
	self.SearchBar.SearchButton:SetScript("OnClick", function() self:StartSearch(); end);

	-- Init search box
	self.SearchBar.SearchBox:SetScript("OnEnterPressed", function(box)
		EditBox_ClearFocus(box);
		self:StartSearch();
	end);

	-- Init favorites button
	self.SearchBar.FavoritesSearchButton:SetAtlas("auctionhouse-icon-favorite");

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
end

function ProfessionsCustomerOrdersBrowsePageMixin:OnEvent(event, ...)
	if event == "CRAFTINGORDERS_CUSTOMER_OPTIONS_PARSED" then
		self.CategoryList:OnDataLoadFinished();
        self.SearchBar.SearchButton:Enable();
	end
end

function ProfessionsCustomerOrdersBrowsePageMixin:Init()
	self.SearchBar.SearchBox:SetText("");
    self.SearchBar.SearchButton:Disable();
	self.CategoryList:Init();
	self:SetupSortManager();
	self:SetupTable();

    C_CraftingOrders.ParseCustomerOptions();

	local dataProvider = CreateDataProvider();
	self.RecipeList.ScrollBox:SetDataProvider(dataProvider);
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

	local PTC = ProfessionsTableConstants;
	self.tableBuilder:AddFixedWidthColumn(self, PTC.NoPadding, PTC.ItemName.Width,
		PTC.ItemName.LeftCellPadding, PTC.ItemName.RightCellPadding, ProfessionsSortOrder.ItemName, "ProfessionsCustomerTableCellItemNameTemplate");

	if extraColumnType ~= nil and extraColumnType ~= Enum.AuctionHouseExtraColumn.None then
		self.tableBuilder:AddFixedWidthColumn(self, GetColumnInfoFromType(extraColumnType));
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
		return "iLvl";
	elseif extraColumnType == Enum.AuctionHouseExtraColumn.Slots then
		return "slots";
	elseif extraColumnType == Enum.AuctionHouseExtraColumn.Level then
		return "level";
	elseif extraColumnType == Enum.AuctionHouseExtraColumn.Skill then
		return "skill";
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
	if extraColumnField ~= nil then
		self.sortManager:InsertComparator(GetSortOrderFromType(extraColumnType), function(lhs, rhs)
			return SortUtil.CompareNumeric(lhs.option[extraColumnField], rhs.option[extraColumnField]);
		end);
	end

	-- Sort order needs to be assigned prior to the table builder generating rows.
	self:SetSortOrderInternal(ProfessionsSortOrder.ItemName);
end

function ProfessionsCustomerOrdersBrowsePageMixin:StartSearch()
    local categoryFilters = self.CategoryList:GetCategoryFilters();
	local searchBoxText = self.SearchBar.SearchBox:GetText();
    local searchText = searchBoxText ~= "" and searchBoxText or nil;

    local searchParams =
	{
		categoryFilters = categoryFilters,
		searchText = searchText,
	};

	local searchResults = C_CraftingOrders.GetCustomerOptions(searchParams);

	self:SetupSortManager(searchResults.extraColumnType)
	self:SetupTable(searchResults.extraColumnType);

	local dataProvider = CreateDataProvider();
	for _, option in ipairs(searchResults.options) do
		dataProvider:Insert({option = option});
	end
	dataProvider:SetSortComparator(self.sortManager:CreateComparator());
	self.RecipeList.ScrollBox:SetDataProvider(dataProvider);
end