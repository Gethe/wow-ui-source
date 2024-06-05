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

	self:Reset();

	self.ClearFiltersButton:SetScript("OnClick", function()
		self:Reset();
	end);
end

function AuctionHouseFilterButtonMixin:ToggleFilter(filter)
	self.filters[filter] = not self.filters[filter];

	self:GetParent():OnFilterToggled();
end

function AuctionHouseFilterButtonMixin:Reset()
	self.filters = CopyTable(AUCTION_HOUSE_DEFAULT_FILTERS);
	self.minLevel = 0;
	self.maxLevel = 0;
	self.ClearFiltersButton:Hide();
end

function AuctionHouseFilterButtonMixin:GetFilters()
	return self.filters;
end

function AuctionHouseFilterButtonMixin:CalculateFiltersArray()
	local filtersArray = {};
	for key, value in pairs(self.filters) do
		if value then
			table.insert(filtersArray, key);
		end
	end
	return filtersArray;
end

function AuctionHouseFilterButtonMixin:GetLevelRange()
	return self.minLevel, self.maxLevel;
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
		return self.FilterButton.filters[filter];
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

			local minLevel = self.FilterButton.minLevel;
			if minLevel > 0 then
				frame:SetMinLevel(minLevel);
			end

			local maxLevel = self.FilterButton.maxLevel;
			if maxLevel > 0 then
				frame:SetMaxLevel(maxLevel);
			end

			frame:SetLevelRangeChangedCallback(function(minLevel, maxLevel)
				self.FilterButton.minLevel, self.FilterButton.maxLevel = minLevel, maxLevel;
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
	self.FilterButton:Reset();
end

function AuctionHouseSearchBarMixin:OnFilterToggled()
	self:UpdateClearFiltersButton();
end

function AuctionHouseSearchBarMixin:UpdateClearFiltersButton()
	local areFiltersDefault = tCompare(self.FilterButton:GetFilters(), AUCTION_HOUSE_DEFAULT_FILTERS);
	local minLevel, maxLevel = self.FilterButton:GetLevelRange();
	self.FilterButton.ClearFiltersButton:SetShown(not areFiltersDefault or minLevel ~= 0 or maxLevel ~= 0);
end

function AuctionHouseSearchBarMixin:SetSearchText(searchText)
	self.SearchBox:SetText(searchText);
end

function AuctionHouseSearchBarMixin:GetLevelFilterRange()
	return self.FilterButton:GetLevelRange();
end

function AuctionHouseSearchBarMixin:StartSearch()
	local searchString = self.SearchBox:GetSearchString();
	local minLevel, maxLevel = self:GetLevelFilterRange();
	local filtersArray = self.FilterButton:CalculateFiltersArray();
	self:GetAuctionHouseFrame():SendBrowseQuery(searchString, minLevel, maxLevel, filtersArray);
end

function AuctionHouseSearchBarMixin:StartFavoritesSearch()
	self:GetParent():GetCategoriesList():SetSelectedCategory(nil);
	self:GetAuctionHouseFrame():QueryAll(AuctionHouseSearchContext.AllFavorites);
end