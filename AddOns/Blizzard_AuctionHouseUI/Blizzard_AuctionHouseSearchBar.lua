
local DEFAULT_FILTERS = {
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

AUCTION_HOUSE_FILTER_CATEGORY_STRINGS = {
	[Enum.AuctionHouseFilterCategory.Uncategorized] = "",
	[Enum.AuctionHouseFilterCategory.Equipment] = AUCTION_HOUSE_FILTER_CATEGORY_EQUIPMENT,
	[Enum.AuctionHouseFilterCategory.Rarity] = AUCTION_HOUSE_FILTER_CATEGORY_RARITY,
};

local function GetFilterCategoryName(category)
	return AUCTION_HOUSE_FILTER_CATEGORY_STRINGS[category] or "";
end

local function GetFilterName(filter)
	return AUCTION_HOUSE_FILTER_STRINGS[filter] or "";
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

local function AuctionHouseFilterDropDownMenu_Initialize(self)
	local filterButton = self:GetParent();

	local info = UIDropDownMenu_CreateInfo();
	info.text = AUCTION_HOUSE_FILTER_DROP_DOWN_LEVEL_RANGE;
	info.isTitle = true;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);

	local info = UIDropDownMenu_CreateInfo();
	info.customFrame = filterButton.LevelRangeFrame;
	UIDropDownMenu_AddButton(info);

	local filterGroups = C_AuctionHouse.GetFilterGroups();
	for i, filterGroup in ipairs(filterGroups) do
		local info = UIDropDownMenu_CreateInfo();
		info.text = GetFilterCategoryName(filterGroup.category);
		info.isTitle = true;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info);

		for j, filter in ipairs(filterGroup.filters) do
			local info = UIDropDownMenu_CreateInfo();
			info.text = GetFilterName(filter);
			info.value = nil;
			info.isNotRadio = true;
			info.checked = filterButton.filters[filter];
			info.keepShownOnClick = 1;
			info.func = function(button)
				filterButton:ToggleFilter(filter);
			end
			UIDropDownMenu_AddButton(info);
		end

		if i ~= #filterGroups then
			UIDropDownMenu_AddSpace();
		end
	end
end

function AuctionHouseFilterButtonMixin:OnLoad()
	self:Reset();
	UIDropDownMenu_SetInitializeFunction(self.DropDown, AuctionHouseFilterDropDownMenu_Initialize);
	UIDropDownMenu_SetDisplayMode(self.DropDown, "MENU");
end

function AuctionHouseFilterButtonMixin:OnClick()
	local level = 1;
	local value = nil;
	ToggleDropDownMenu(1, nil, self.DropDown, self, 9, 3);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function AuctionHouseFilterButtonMixin:ToggleFilter(filter)
	self.filters[filter] = not self.filters[filter];

	self:GetParent():OnFilterToggled();
end

function AuctionHouseFilterButtonMixin:Reset()
	self.filters = CopyTable(DEFAULT_FILTERS);
	self.LevelRangeFrame:Reset();
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
	return self.LevelRangeFrame:GetLevelRange();
end


AuctionHouseLevelRangeEditBoxMixin = {};

function AuctionHouseLevelRangeEditBoxMixin:OnTextChanged()
	self:GetParent():OnLevelRangeChanged();
end


AuctionHouseLevelRangeFrameMixin = {};

function AuctionHouseLevelRangeFrameMixin:OnLoad()
	self.MinLevel.nextEditBox = self.MaxLevel;
	self.MaxLevel.nextEditBox = self.MinLevel;
end

function AuctionHouseLevelRangeFrameMixin:OnHide()
	self:FixLevelRange();
end

function AuctionHouseLevelRangeFrameMixin:SetLevelRangeChangedCallback(levelRangeChangedCallback)
	self.levelRangeChangedCallback = levelRangeChangedCallback;
end

function AuctionHouseLevelRangeFrameMixin:OnLevelRangeChanged()
	if self.levelRangeChangedCallback then
		self.levelRangeChangedCallback();
	end
end

function AuctionHouseLevelRangeFrameMixin:FixLevelRange()
	local minLevel = self.MinLevel:GetNumber();
	local maxLevel = self.MaxLevel:GetNumber();

	if maxLevel ~= 0 and minLevel > maxLevel then
		self.MinLevel:SetNumber(maxLevel);
	end
end

function AuctionHouseLevelRangeFrameMixin:Reset()
	self.MinLevel:SetText("");
	self.MaxLevel:SetText("");
end

function AuctionHouseLevelRangeFrameMixin:GetLevelRange()
	return self.MinLevel:GetNumber(), self.MaxLevel:GetNumber();
end


AuctionHouseClearFiltersButtonMixin = {};

function AuctionHouseClearFiltersButtonMixin:OnClick()
	self:GetParent():Reset();
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
	local function LevelRangeChangedCallback()
		self:OnLevelRangeChanged();
	end

	self.FilterButton.LevelRangeFrame:SetLevelRangeChangedCallback(LevelRangeChangedCallback)
end

function AuctionHouseSearchBarMixin:OnShow()
	self.SearchBox:Reset();
	self.FilterButton:Reset();
end

function AuctionHouseSearchBarMixin:OnFilterToggled()
	self:UpdateClearFiltersButton();
end

function AuctionHouseSearchBarMixin:OnLevelRangeChanged()
	self:UpdateClearFiltersButton();
end

function AuctionHouseSearchBarMixin:UpdateClearFiltersButton()
	local areFiltersDefault = tCompare(self.FilterButton:GetFilters(), DEFAULT_FILTERS);
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
	self:GetAuctionHouseFrame():QueryAll(AuctionHouseSearchContext.AllFavorites);
end