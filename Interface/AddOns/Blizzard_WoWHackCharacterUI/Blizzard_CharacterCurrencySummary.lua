
local WOWHACK_CURRENCY_CATEGORY_ID = 267;

local CURRENCY_ICON_SIZE = 14;

local CURRENCY_SUMMARY_EVENTS = {
	"CURRENCY_DISPLAY_UPDATE",
};

local function MakeCurrencyTooltipCallback(currencyTypeID)
	return function(button)
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT");
		GameTooltip:SetCurrencyByID(currencyTypeID);
		GameTooltip:Show();
	end;
end

local function GatherCurrencyEntries(categoryID, entries)
	entries = entries or {};

	local categoryInfo = C_CurrencyInfo.GetPlayerCurrencyCategoryInfo(categoryID);
	for _, currencyTypeID in ipairs(categoryInfo.currencyTypes) do
		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyTypeID);
		local iconMarkup = CreateSimpleTextureMarkup(currencyInfo.iconFileID, CURRENCY_ICON_SIZE, CURRENCY_ICON_SIZE);
		table.insert(entries, {
			name = currencyInfo.name,
			value = currencyInfo.quantity .. " " .. iconMarkup,
			tooltipCallback = MakeCurrencyTooltipCallback(currencyTypeID),
		});
	end

	for _, childCategoryID in ipairs(categoryInfo.childCategories) do
		GatherCurrencyEntries(childCategoryID, entries);
	end

	return entries;
end

CharacterCurrencySummaryMixin = CreateFromMixins(CharacterSheetListMixin);

function CharacterCurrencySummaryMixin:OnLoad()
	CharacterSheetListMixin.OnLoad(self);
	FrameUtil.RegisterFrameForEvents(self, CURRENCY_SUMMARY_EVENTS);
end

function CharacterCurrencySummaryMixin:OnEvent(_event)
	self:Refresh();
end

function CharacterCurrencySummaryMixin:BuildElements()
	return GatherCurrencyEntries(WOWHACK_CURRENCY_CATEGORY_ID);
end

CharacterCurrencySectionMixin = {};

function CharacterCurrencySectionMixin:OnLoad()
	self.Header:SetHeaderText(WOWHACK_CHARACTER_SECTION_CURRENCY);
end
