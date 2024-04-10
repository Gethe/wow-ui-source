

UIPanelWindows["BlackMarketFrame"] = { area = "doublewide", pushable = 0, width = 890};

StaticPopupDialogs["BID_BLACKMARKET"] = {
	text = BLACK_MARKET_AUCTION_CONFIRMATION,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self)
		C_BlackMarket.ItemPlaceBid(self.data.auctionID, self.data.bid);
	end,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = 1,
	hasItemFrame = 1,
};

function BlackMarketFrame_Show()
	ShowUIPanel(BlackMarketFrame);
	if ( not BlackMarketFrame:IsShown() ) then
		C_BlackMarket.Close();
	end
	PlaySound(SOUNDKIT.AUCTION_WINDOW_OPEN)
end

function BlackMarketFrame_Hide()
	HideUIPanel(BlackMarketFrame);
	PlaySound(SOUNDKIT.AUCTION_WINDOW_CLOSE);
end

function BlackMarketFrame_OnLoad(self)
	self:RegisterEvent("BLACK_MARKET_ITEM_UPDATE");
	self:RegisterEvent("BLACK_MARKET_BID_RESULT");
	self:RegisterEvent("BLACK_MARKET_OUTBID");
	MoneyInputFrame_SetGoldOnly(BlackMarketBidPrice, true);

	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("BlackMarketItemTemplate", function(button, elementData)
		button:Init(elementData);
	end);
	view:SetPadding(4,4,4,4,0);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	BlackMarketBidPrice.gold:SetWidth(80);
	BlackMarketBidPrice.gold:SetMaxLetters(8);
	BlackMarketBidPrice.onValueChangedFunc = BlackMarketFrame_UpdateBidButton;
end

BlackMarketItemMixin = {};

function BlackMarketItemMixin:OnClick(buttonName, down)
	if ( IsModifiedClick() ) then
		HandleModifiedItemClick(self.itemLink);
	else
		MoneyInputFrame_SetCopper(BlackMarketBidPrice, self.minNextBid);
		
		local oldMarketID = BlackMarketFrame.selectedMarketID;
		if oldMarketID == self.marketID then
			return;
		end

		BlackMarketFrame.selectedMarketID = self.marketID;
		BlackMarketFrame.ScrollBox:ForEachFrame(function(button, elementData)
			button:SetSelected(button:ShouldSelect());
		end);
	end
end

function BlackMarketItemMixin:Init(elementData)
	local index = elementData.index;
	local name, texture, quantity, itemType, usable, level, levelType, sellerName, minBid, minIncrement, currBid, youHaveHighBid, numBids, timeLeft, link, marketID, quality = C_BlackMarket.GetItemInfoByIndex(index);
	
	self.Name:SetText(name);
		
	self.Item.IconTexture:SetTexture(texture);
	if ( not usable ) then
		self.Item.IconTexture:SetVertexColor(1.0, 0.1, 0.1);
	else
		self.Item.IconTexture:SetVertexColor(1.0, 1.0, 1.0);
	end

	SetItemButtonQuality(self.Item, quality, link);

	if (quality and quality >= Enum.ItemQuality.Common and BAG_ITEM_QUALITY_COLORS[quality]) then
		self.Name:SetTextColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
	else
		self.Name:SetTextColor(1.0, 0.82, 0);
	end

	self.Item.Count:SetText(quantity);
	self.Item.Count:SetShown(quantity > 1);

	self.Type:SetText(itemType);
	
	self.Seller:SetText(sellerName);
	
	self.Level:SetText(level);

	local bidAmount = currBid;
	local minNextBid = currBid + minIncrement;
	if ( currBid == 0 ) then
		bidAmount = minBid;
		minNextBid = minBid;
	end
	MoneyFrame_Update(self.CurrentBid, bidAmount);
	
	self.minNextBid = minNextBid;
	self.YourBid:SetShown(youHaveHighBid);
	
	self.TimeLeft.Text:SetText(_G["AUCTION_TIME_LEFT"..timeLeft]);
	self.TimeLeft.tooltip = _G["AUCTION_TIME_LEFT"..timeLeft.."_DETAIL"];
	
	self.itemLink = link;
	self.marketID = marketID;
	self:SetSelected(self:ShouldSelect());
end


function BlackMarketItemMixin:ShouldSelect(selected)
	return self.marketID == BlackMarketFrame.selectedMarketID;
end

function BlackMarketItemMixin:SetSelected(selected)
	self.Selection:SetShown(selected);
end

function BlackMarketFrame_OnEvent(self, event, ...)
	if ( event == "BLACK_MARKET_ITEM_UPDATE" ) then
		BlackMarketScrollFrame_Update();
	elseif ( event == "BLACK_MARKET_BID_RESULT" or event == "BLACK_MARKET_OUTBID" ) then
		if (self:IsShown()) then
			C_BlackMarket.RequestItems();
		end
	end

	-- do this on any event
	local numItems = C_BlackMarket.GetNumItems();
	self.Inset.NoItems:SetShown(not numItems or numItems <= 0);
	BlackMarketFrame_UpdateHotItem(self);
end

function BlackMarketFrame_OnShow(self)
	self.HotDeal:Hide();
	C_BlackMarket.RequestItems();
	MoneyInputFrame_SetCopper(BlackMarketBidPrice, 0);
	if( C_BlackMarket.IsViewOnly() ) then
		BlackMarketFrame.BidButton:Hide();
		BlackMarketBidPrice:Hide();
		BlackMarketMoneyFrame:Hide();
		BlackMarketFrame.MoneyFrameBorder:Hide();
	else
		BlackMarketFrame.BidButton:Show();
		BlackMarketBidPrice:Show();
		BlackMarketMoneyFrame:Show();
		BlackMarketFrame.MoneyFrameBorder:Show();
	end

	BlackMarketFrame.BidButton:Disable();
	PlaySound(SOUNDKIT.AUCTION_WINDOW_OPEN);
end

function BlackMarketFrame_OnHide(self)
	C_BlackMarket.Close();
	PlaySound(SOUNDKIT.AUCTION_WINDOW_CLOSE);
end

function BlackMarketFrame_UpdateHotItem(self)
	local name, texture, quantity, itemType, usable, level, levelType, sellerName, minBid, minIncrement, currBid, youHaveHighBid, numBids, timeLeft, link, marketID, quality = C_BlackMarket.GetHotItem();
	if ( name ) then
		self.HotDeal.Name:SetText(name);
		
		self.HotDeal.Item.IconTexture:SetTexture(texture);
		if ( not usable ) then
			self.HotDeal.Item.IconTexture:SetVertexColor(1.0, 0.1, 0.1);
		else
			self.HotDeal.Item.IconTexture:SetVertexColor(1.0, 1.0, 1.0);
		end

		SetItemButtonQuality(self.HotDeal.Item, quality, link);

		if (quality >= Enum.ItemQuality.Common and BAG_ITEM_QUALITY_COLORS[quality]) then
			self.HotDeal.Name:SetTextColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
		else
			self.HotDeal.Name:SetTextColor(1.0, 0.82, 0);
		end

		self.HotDeal.Item.Count:SetText(quantity);
		self.HotDeal.Item.Count:SetShown(quantity > 1);
	
		self.HotDeal.Type:SetText(itemType);
		
		self.HotDeal.Seller:SetText(sellerName);
		
		if (level > 1) then
			self.HotDeal.Level:SetText(level);
		else
			self.HotDeal.Level:SetText("");
		end
		
		local bidAmount = currBid;
		if ( currBid == 0 ) then
			bidAmount = minBid;
		end
		MoneyFrame_Update(HotItemCurrentBidMoneyFrame, bidAmount);

		self.HotDeal.TimeLeft.Text:SetText(format(BLACK_MARKET_HOT_ITEM_TIME_LEFT, _G["AUCTION_TIME_LEFT"..timeLeft]));
		self.HotDeal.TimeLeft.tooltip = _G["AUCTION_TIME_LEFT"..timeLeft.."_DETAIL"];
		self.HotDeal.itemLink = link;
		self.HotDeal.selectedMarketID = marketID;
		self.HotDeal.BlackMarketHotItemBidPrice.YourBid:SetShown(youHaveHighBid);
		self.HotDeal:Show();
	end
end

function BlackMarketScrollFrame_Update()
	local dataProvider = CreateDataProviderByIndexCount(C_BlackMarket.GetNumItems() or 0);
	BlackMarketFrame.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
end

function BlackMarketFrame_UpdateBidButton()
	local enabled = false;
	if ( BlackMarketFrame.selectedMarketID ) then
		local name, texture, quantity, itemType, usable, level, levelType, sellerName, minBid, minIncrement, currBid, youHaveHighBid, numBids, timeLeft, link, marketID, quality = C_BlackMarket.GetItemInfoByID(BlackMarketFrame.selectedMarketID);
		if ( timeLeft > 0 and not youHaveHighBid and GetMoney() >= MoneyInputFrame_GetCopper(BlackMarketBidPrice) ) then
			enabled = true;
		end
	end
	BlackMarketFrame.BidButton:SetEnabled(enabled);
end

function BlackMarketFrame_ConfirmBid(auctionID)
	local bid = MoneyInputFrame_GetCopper(BlackMarketBidPrice);
	local name, texture, quantity, _, _, _, _, _, _, _, _, _, _, _, link, _, quality = C_BlackMarket.GetItemInfoByID(auctionID);
	local r, g, b = C_Item.GetItemQualityColor(quality);
	local data = {	["texture"] = texture, ["name"] = name, ["color"] = {r, g, b, 1}, 
					["link"] = link, ["count"] = quantity,
					["bid"] = bid, ["auctionID"] = auctionID,
	};	
	StaticPopup_Show("BID_BLACKMARKET", GetMoneyString(bid), nil, data);
end

function BlackMarketHotItemBid_OnClick(self, button, down)
	if (BlackMarketFrame.HotDeal.selectedMarketID) then
		BlackMarketFrame_ConfirmBid(BlackMarketFrame.HotDeal.selectedMarketID);
	end
	self:Disable();
end

function BlackMarketBid_OnClick(self, button, down)
	if (BlackMarketFrame.selectedMarketID) then
		BlackMarketFrame_ConfirmBid(BlackMarketFrame.selectedMarketID);
	end
	self:Disable();
end