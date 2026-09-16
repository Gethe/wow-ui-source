g_auctionHouseFilters = g_auctionHouseFilters or nil;

local DefaultFiltersSavedVars =
{
	minLevel = 0,
	maxLevel = 0,
	filters = CopyTable(AUCTION_HOUSE_DEFAULT_FILTERS),
};

local function SetSavedVarsToDefault()
	local shallow = false;
	g_auctionHouseFilters = CopyTable(DefaultFiltersSavedVars, shallow);
end

if not g_auctionHouseFilters then
	-- No existing vars. Create the defaults.
	SetSavedVarsToDefault();
end

AuctionHouseSearchButtonMixin = {};

function AuctionHouseSearchButtonMixin:OnClick()
	self:GetParent():StartSearch();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end


AuctionHouseFavoritesSearchButtonMixin = {};

local AUCTION_HOUSE_FAVORITES_SEARCH_BUTTON_EVENTS = {
	"AUCTION_HOUSE_FAVORITES_UPDATED",
};

function AuctionHouseFavoritesSearchButtonMixin:OnLoad()
	local function FavoriteSearchOnClickHandler()
		self:GetParent():StartFavoritesSearch();
	end

	self:SetOnClickHandler(FavoriteSearchOnClickHandler);
	self:SetAtlas("auctionhouse-icon-favorite");

	SquareIconButtonMixin.OnLoad(self);
end

function AuctionHouseFavoritesSearchButtonMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, AUCTION_HOUSE_FAVORITES_SEARCH_BUTTON_EVENTS);

	self:UpdateState();
end

function AuctionHouseFavoritesSearchButtonMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, AUCTION_HOUSE_FAVORITES_SEARCH_BUTTON_EVENTS);
end

function AuctionHouseFavoritesSearchButtonMixin:OnEvent(event, ...)
	self:UpdateState();
end

function AuctionHouseFavoritesSearchButtonMixin:OnEnter()
	local hasFavorites = C_AuctionHouse.HasFavorites();
	self:SetTooltipInfo(AUCTION_HOUSE_FAVORITES_SEARCH_TOOLTIP_TITLE, not hasFavorites and AUCTION_HOUSE_FAVORITES_SEARCH_TOOLTIP_NO_FAVORITES or nil);

	SquareIconButtonMixin.OnEnter(self);
end

function AuctionHouseFavoritesSearchButtonMixin:UpdateState()
	local hasFavorites = C_AuctionHouse.HasFavorites();
	self:SetEnabled(hasFavorites);
	self.Icon:SetDesaturated(not hasFavorites);
end


AuctionHouseFilterButtonMixin = {};

function AuctionHouseFilterButtonMixin:OnLoad()
	WowStyle1FilterDropdownMixin.OnLoad(self);

	self.ClearFiltersButton:SetScript("OnClick", function()
		self:Reset();
	end);
end

function AuctionHouseFilterButtonMixin:ToggleFilter(filter)
	g_auctionHouseFilters.filters[filter] = not g_auctionHouseFilters.filters[filter];

	self:GetParent():OnFilterToggled();
end

function AuctionHouseFilterButtonMixin:Reset()
	SetSavedVarsToDefault();
	self.ClearFiltersButton:Hide();
end

function AuctionHouseFilterButtonMixin:GetFilters()
	return g_auctionHouseFilters.filters;
end

function AuctionHouseFilterButtonMixin:CalculateFiltersArray()
	local filtersArray = {};
	for key, value in pairs(g_auctionHouseFilters.filters) do
		if value then
			table.insert(filtersArray, key);
		end
	end
	return filtersArray;
end

function AuctionHouseFilterButtonMixin:GetLevelRange()
	return g_auctionHouseFilters.minLevel, g_auctionHouseFilters.maxLevel;
end

AuctionHouseSearchBoxMixin = {};

function AuctionHouseSearchBoxMixin:OnEnterPressed()
	EditBox_ClearFocus(self);
	self:GetParent():StartSearch();
end

function AuctionHouseSearchBoxMixin:Reset()
	self:SetText("");
end

function AuctionHouseSearchBoxMixin:GetSearchString()
	return self:GetText();
end


AuctionHouseSearchBarMixin = CreateFromMixins(AuctionHouseSystemMixin);

function AuctionHouseSearchBarMixin:OnLoad()
	local function IsSelected(filter)
		return g_auctionHouseFilters.filters[filter];
	end

	local function SetSelected(filter)
		self.FilterButton:ToggleFilter(filter);
	end

	self.FilterButton:SetWidth(93);
	self.FilterButton:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_AUCTION_HOUSE_SEARCH_FILTER");

		rootDescription:CreateTitle(AUCTION_HOUSE_FILTER_DROP_DOWN_LEVEL_RANGE);

		local levelRangeFrame = rootDescription:CreateTemplate("LevelRangeFrameTemplate");
		levelRangeFrame:AddInitializer(function(frame, elementDescription, menu)
			frame:Reset();

			local minLevel = g_auctionHouseFilters.minLevel;
			if minLevel > 0 then
				frame:SetMinLevel(minLevel);
			end

			local maxLevel = g_auctionHouseFilters.maxLevel;
			if maxLevel > 0 then
				frame:SetMaxLevel(maxLevel);
			end

			frame:SetLevelRangeChangedCallback(function(minLevel, maxLevel)
				g_auctionHouseFilters.minLevel, g_auctionHouseFilters.maxLevel = minLevel, maxLevel;
				self:UpdateClearFiltersButton();
			end);
		end);

		for index, filterGroup in ipairs(C_AuctionHouse.GetFilterGroups()) do
			rootDescription:CreateTitle(GetAHFilterCategoryName(filterGroup.category));

			for _, filter in ipairs(filterGroup.filters) do
				rootDescription:CreateCheckbox(GetAHFilterName(filter), IsSelected, SetSelected, filter);
			end

			rootDescription:QueueSpacer();
		end
	end);
end

function AuctionHouseSearchBarMixin:OnShow()
	self.SearchBox:Reset();
	local compareDepth = 2;
	local savedVarsAreDefault = tCompare(DefaultFiltersSavedVars, g_auctionHouseFilters, compareDepth);
	self.FilterButton.ClearFiltersButton:SetShown(not savedVarsAreDefault);
end

function AuctionHouseSearchBarMixin:OnFilterToggled()
	self:UpdateClearFiltersButton();
end

function AuctionHouseSearchBarMixin:UpdateClearFiltersButton()
	local areFiltersDefault = tCompare(self.FilterButton:GetFilters(), AUCTION_HOUSE_DEFAULT_FILTERS);
	g_auctionHouseFilters.minLevel, g_auctionHouseFilters.maxLevel = self.FilterButton:GetLevelRange();
	self.FilterButton.ClearFiltersButton:SetShown(not areFiltersDefault or g_auctionHouseFilters.minLevel ~= 0 or g_auctionHouseFilters.maxLevel ~= 0);
end

function AuctionHouseSearchBarMixin:SetSearchText(searchText)
	self.SearchBox:SetText(searchText);
end

function AuctionHouseSearchBarMixin:GetLevelFilterRange()
	return self.FilterButton:GetLevelRange();
end

function AuctionHouseSearchBarMixin:StartSearch()
	local searchString = self.SearchBox:GetSearchString();
	g_auctionHouseFilters.minLevel, g_auctionHouseFilters.maxLevel = self:GetLevelFilterRange();
	local filtersArray = self.FilterButton:CalculateFiltersArray();
	self:GetAuctionHouseFrame():SendBrowseQuery(searchString, g_auctionHouseFilters.minLevel, g_auctionHouseFilters.maxLevel, filtersArray);
end

function AuctionHouseSearchBarMixin:StartFavoritesSearch()
	self:GetParent():GetCategoriesList():SetSelectedCategory(nil);
	self:GetAuctionHouseFrame():QueryAll(AuctionHouseSearchContext.AllFavorites);
end
