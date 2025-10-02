
AuctionHouseCommoditiesBackButtonMixin = {};

function AuctionHouseCommoditiesBackButtonMixin:OnClick()
	self:GetParent():GetAuctionHouseFrame():SetDisplayMode(AuctionHouseFrameDisplayMode.Buy);
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end


AuctionHouseCommoditiesBuyButtonMixin = {};

function AuctionHouseCommoditiesBuyButtonMixin:OnClick()
	self:GetParent():StartCommoditiesPurchase();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end


AuctionHouseCommoditiesBuyDisplayMixin = {};

function AuctionHouseCommoditiesBuyDisplayMixin:OnLoad()
	AuctionHouseBackgroundMixin.OnLoad(self);

	self.ItemDisplay.NineSlice:Hide();

	self.QuantityInput.MaxButton:Hide();

	self.ItemDisplay:SetAuctionHouseFrame(self:GetAuctionHouseFrame());

	local function QuantityInputChanged()
		self:GetAuctionHouseFrame():TriggerEvent(AuctionHouseFrameMixin.Event.CommoditiesQuantitySelectionChanged, self.QuantityInput:GetQuantity());
	end

	self.QuantityInput:SetInputChangedCallback(QuantityInputChanged);

	self.quantitySelectionChangedCallback = CommoditiesQuantitySelectionChangedCallback;
end

function AuctionHouseCommoditiesBuyDisplayMixin:OnShow()
	self:RegisterEvent("COMMODITY_PURCHASE_SUCCEEDED");
	self:RegisterEvent("COMMODITY_SEARCH_RESULTS_RECEIVED");

	self.resultsLoaded = false;

	self:Layout();

	self:GetAuctionHouseFrame():RegisterCallback(AuctionHouseFrameMixin.Event.CommoditiesQuantitySelectionChanged, self.OnQuantitySelectionChanged, self);
end

function AuctionHouseCommoditiesBuyDisplayMixin:OnQuantitySelectionChanged(quantity)
	local suppressEvent = true;
	self:SetQuantitySelected(quantity, suppressEvent);
end

function AuctionHouseCommoditiesBuyDisplayMixin:UpdateBuyButton()
	if self.TotalPrice:GetAmount() > GetMoney() then
		self.BuyButton:SetDisableTooltip(AUCTION_HOUSE_TOOLTIP_TITLE_NOT_ENOUGH_MONEY);
	elseif self.QuantityInput:GetQuantity() <= 0 then
		self.BuyButton:SetDisableTooltip(AUCTION_HOUSE_TOOLTIP_TITLE_NONE_AVAILABLE);
	else
		self.BuyButton:SetDisableTooltip(nil);
	end
end

function AuctionHouseCommoditiesBuyDisplayMixin:SetItemIDAndPrice(itemID, minPrice)
	if itemID then
		self.ItemDisplay:SetItem(itemID);
		self:SetQuantitySelected(1);
		self:SetPrice(minPrice, minPrice);
	else
		self.ItemDisplay:SetItem(nil);
		self:SetQuantitySelected(0);
		self:SetPrice(0, 0);
	end
end

function AuctionHouseCommoditiesBuyDisplayMixin:SetPrice(unitPrice, totalPrice)
	self.UnitPrice:SetAmount(unitPrice);
	self.TotalPrice:SetAmount(totalPrice);

	self:UpdateBuyButton();
end

function AuctionHouseCommoditiesBuyDisplayMixin:GetItemID()
	return self.ItemDisplay:GetItemID();
end

function AuctionHouseCommoditiesBuyDisplayMixin:OnHide()
	self:UnregisterEvent("COMMODITY_PURCHASE_SUCCEEDED");
	self:UnregisterEvent("COMMODITY_SEARCH_RESULTS_RECEIVED");

	self:GetAuctionHouseFrame():UnregisterCallback(AuctionHouseFrameMixin.Event.CommoditiesQuantitySelectionChanged, self);
end

function AuctionHouseCommoditiesBuyDisplayMixin:OnEvent(event, ...)
	if event == "COMMODITY_PURCHASE_SUCCEEDED" then
		self.QuantityInput:SetQuantity(1);
		self:GetAuctionHouseFrame():TriggerEvent(AuctionHouseFrameMixin.Event.CommoditiesQuantitySelectionChanged, self.QuantityInput:GetQuantity());
	elseif event == "COMMODITY_SEARCH_RESULTS_RECEIVED" then
		self.resultsLoaded = true;
	end
end

function AuctionHouseCommoditiesBuyDisplayMixin:SetQuantitySelected(quantity)
	local totalQuantity = 1;
	local totalPrice = 0;
	local commodityItemKey = C_AuctionHouse.MakeItemKey(self:GetItemID());
	if C_AuctionHouse.HasSearchResults(commodityItemKey) and self.resultsLoaded then
		-- Total quantity will be restricted to at most the entire amount available on the auction house.
		-- This means the user is prevented from entering an amount to buy greater than the available supply.
		totalQuantity, totalPrice = AuctionHouseUtil.AggregateSearchResultsByQuantity(self:GetItemID(), quantity);
		if totalQuantity == 0 then
			self.QuantityInput:SetQuantity(0);
			self:SetPrice(0, 0);
			return;
		end
	end

	if self.oldQuantitySelected ~= quantity then
		self.QuantityInput:SetQuantity(self.resultsLoaded and totalQuantity or quantity);
		self.oldQuantitySelected = quantity;
	end
	
	local unitPrice = AuctionHouseUtil.SanitizeAuctionHousePrice(totalPrice / totalQuantity);
	self:SetPrice(unitPrice, totalPrice);
end

function AuctionHouseCommoditiesBuyDisplayMixin:GetQuantitySelected()
	return self.QuantityInput:GetQuantity();
end

function AuctionHouseCommoditiesBuyDisplayMixin:StartCommoditiesPurchase()
	local itemID = self:GetItemID();
	if not itemID then
		return;
	end

	local quantity = self:GetQuantitySelected();
	local unitPrice = self.UnitPrice:GetAmount();
	local totalPrice = self.TotalPrice:GetAmount();
	self:GetAuctionHouseFrame():StartCommoditiesPurchase(itemID, quantity, unitPrice, totalPrice);
end

function AuctionHouseCommoditiesBuyDisplayMixin:GetAuctionHouseFrame()
	return self:GetParent():GetAuctionHouseFrame();
end


AuctionHouseCommoditiesBuyFrameMixin = CreateFromMixins(AuctionHouseSortOrderSystemMixin);

function AuctionHouseCommoditiesBuyFrameMixin:OnLoad()
	AuctionHouseSortOrderSystemMixin.OnLoad(self);

	self:SetSearchContext(AuctionHouseSearchContext.BuyCommodities);

	self.ItemList:SetSelectionCallback(AuctionHouseUtil.GenerateRowSelectedCallbackWithLink(self, self.OnAuctionSelected));
end

function AuctionHouseCommoditiesBuyFrameMixin:GetItemID()
	return self.BuyDisplay:GetItemID();
end

function AuctionHouseCommoditiesBuyFrameMixin:OnAuctionSelected(searchResultInfo)
	local totalQuantity = AuctionHouseUtil.AggregateCommoditySearchResultsByMaxPrice(self:GetItemID(), searchResultInfo.unitPrice);
	self:GetAuctionHouseFrame():TriggerEvent(AuctionHouseFrameMixin.Event.CommoditiesQuantitySelectionChanged, totalQuantity);
	return true;
end

function AuctionHouseCommoditiesBuyFrameMixin:SetItemIDAndPrice(itemID, price)
	self.BuyDisplay:SetItemIDAndPrice(itemID, price);
	self.ItemList:SetItemID(itemID);
end
