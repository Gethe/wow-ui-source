
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
	LayoutMixin.OnLoad(self);
	AuctionHouseBackgroundMixin.OnLoad(self);

	self.ItemDisplay.NineSlice:Hide();

	self.QuantityInput.MaxButton:Hide();

	self.ItemDisplay:SetAuctionHouseFrame(self:GetAuctionHouseFrame());
	
	local function QuantityInputChanged()
		self:GetAuctionHouseFrame():TriggerEvent(AuctionHouseFrameMixin.Event.CommoditiesQuantitySelectionChanged, self.QuantityInput:GetQuantity());
	end

	self.QuantityInput:SetInputChangedCallback(QuantityInputChanged);

	local function CommoditiesQuantitySelectionChangedCallback(event, quantity)
		local suppressEvent = true;
		self:SetQuantitySelected(quantity, suppressEvent);
	end

	self.quantitySelectionChangedCallback = CommoditiesQuantitySelectionChangedCallback;
end

function AuctionHouseCommoditiesBuyDisplayMixin:OnShow()
	self:RegisterEvent("COMMODITY_PURCHASE_SUCCEEDED");
	
	self:Layout();

	self:GetAuctionHouseFrame():RegisterCallback(AuctionHouseFrameMixin.Event.CommoditiesQuantitySelectionChanged, self.quantitySelectionChangedCallback);
end

function AuctionHouseCommoditiesBuyDisplayMixin:SetItemIDAndPrice(itemID, minPrice)
	if itemID then
		self.ItemDisplay:SetItem(itemID);
		self:SetQuantitySelected(1);
		self.UnitPrice:SetAmount(minPrice);
		self.TotalPrice:SetAmount(minPrice);
	else
		self.ItemDisplay:SetItem(nil);
		self:SetQuantitySelected(0);
		self.UnitPrice:SetAmount(0);
		self.TotalPrice:SetAmount(0);
	end
end

function AuctionHouseCommoditiesBuyDisplayMixin:GetItemID()
	return self.ItemDisplay:GetItemID();
end

function AuctionHouseCommoditiesBuyDisplayMixin:OnHide()
	self:RegisterEvent("COMMODITY_PURCHASE_SUCCEEDED");

	self:GetAuctionHouseFrame():UnregisterCallback(AuctionHouseFrameMixin.Event.CommoditiesQuantitySelectionChanged, self.quantitySelectionChangedCallback);
end

function AuctionHouseCommoditiesBuyDisplayMixin:OnEvent(event)
	if event == "COMMODITY_PURCHASE_SUCCEEDED" then
		self.QuantityInput:SetQuantity(1);
		self:GetAuctionHouseFrame():TriggerEvent(AuctionHouseFrameMixin.Event.CommoditiesQuantitySelectionChanged, self.QuantityInput:GetQuantity());
	end
end

function AuctionHouseCommoditiesBuyDisplayMixin:SetQuantitySelected(quantity)
	local totalQuantity = 1;
	local totalPrice = 0;
	local commodityItemKey = C_AuctionHouse.MakeItemKey(self:GetItemID());
	if C_AuctionHouse.HasSearchResults(commodityItemKey) then
		-- Total quantity will be restricted to at most the entire amount available on the auction house.
		-- This means the user is prevented from entering an amount to buy greater than the available supply.
		totalQuantity, totalPrice = AuctionHouseUtil.AggregateSearchResultsByQuantity(self:GetItemID(), quantity);
		if totalQuantity == 0 then
			self.QuantityInput:SetQuantity(0);
			self.UnitPrice:SetAmount(0);
			self.TotalPrice:SetAmount(0);
			return;
		end
	end

	self.QuantityInput:SetQuantity(totalQuantity);

	local unitPrice = math.ceil(totalPrice / totalQuantity);
	self.UnitPrice:SetAmount(unitPrice);
	self.TotalPrice:SetAmount(totalPrice);
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
	self:GetAuctionHouseFrame():StartCommoditiesPurchase(itemID, quantity, unitPrice);
end

function AuctionHouseCommoditiesBuyDisplayMixin:GetAuctionHouseFrame()
	return self:GetParent():GetAuctionHouseFrame();
end


AuctionHouseCommoditiesBuyFrameMixin = CreateFromMixins(AuctionHouseSortOrderSystemMixin);

function AuctionHouseCommoditiesBuyFrameMixin:OnLoad()
	AuctionHouseSortOrderSystemMixin.OnLoad(self);
	
	self:SetSearchContext(AuctionHouseSearchContext.BuyCommodities);

	self.ItemList:SetSelectionCallback(function(auctionData)
		self:OnAuctionSelected(auctionData);
	end);
end

function AuctionHouseCommoditiesBuyFrameMixin:GetItemID()
	return self.BuyDisplay:GetItemID();
end

function AuctionHouseCommoditiesBuyFrameMixin:OnAuctionSelected(searchResultInfo)
	local totalQuantity = AuctionHouseUtil.AggregateCommoditySearchResultsByMaxPrice(self:GetItemID(), searchResultInfo.unitPrice);
	self:GetAuctionHouseFrame():TriggerEvent(AuctionHouseFrameMixin.Event.CommoditiesQuantitySelectionChanged, totalQuantity);
end

function AuctionHouseCommoditiesBuyFrameMixin:SetItemIDAndPrice(itemID, price)
	self.BuyDisplay:SetItemIDAndPrice(itemID, price);
	self.ItemList:SetItemID(itemID);
end
