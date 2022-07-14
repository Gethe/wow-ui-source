

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
	BlackMarketScrollFrame.update = BlackMarketScrollFrame_Update;
	BlackMarketScrollFrame.scrollBar.doNotHide = true;
	self:RegisterEvent("BLACK_MARKET_ITEM_UPDATE");
	self:RegisterEvent("BLACK_MARKET_BID_RESULT");
	self:RegisterEvent("BLACK_MARKET_OUTBID");
	MoneyInputFrame_SetGoldOnly(BlackMarketBidPrice, true);

	BlackMarketBidPrice.gold:SetWidth(80);
	BlackMarketBidPrice.gold:SetMaxLetters(8);
	BlackMarketBidPrice.onValueChangedFunc = BlackMarketFrame_UpdateBidButton;
end

function BlackMarketFrame_OnEvent(self, event, ...)
	if ( event == "BLACK_MARKET_ITEM_UPDATE" ) then
		HybridScrollFrame_CreateButtons(BlackMarketScrollFrame, "BlackMarketItemTemplate", 5, -5);
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

-- Scroll Frame
function BlackMarketScrollFrame_Update()
	local numItems = C_BlackMarket.GetNumItems();
	
	if (not numItems) then
		numItems = 0;
	end
	
	local scrollFrame = BlackMarketScrollFrame;
	local offset = HybridScrollFrame_GetOffset(scrollFrame);
	local buttons = scrollFrame.buttons;
	local numButtons = #buttons;

	for i = 1, numButtons do
		local button = buttons[i];
		local index = offset + i; -- adjust index

		if ( index <= numItems ) then
			local name, texture, quantity, itemType, usable, level, levelType, sellerName, minBid, minIncrement, currBid, youHaveHighBid, numBids, timeLeft, link, marketID, quality = C_BlackMarket.GetItemInfoByIndex(index);
			
			if ( name ) then
				button.Name:SetText(name);
				
				button.Item.IconTexture:SetTexture(texture);
				if ( not usable ) then
					button.Item.IconTexture:SetVertexColor(1.0, 0.1, 0.1);
				else
					button.Item.IconTexture:SetVertexColor(1.0, 1.0, 1.0);
				end

				SetItemButtonQuality(button.Item, quality, link);

				if (quality and quality >= Enum.ItemQuality.Common and BAG_ITEM_QUALITY_COLORS[quality]) then
					button.Name:SetTextColor(BAG_ITEM_QUALITY_COLORS[quality].r, BAG_ITEM_QUALITY_COLORS[quality].g, BAG_ITEM_QUALITY_COLORS[quality].b);
				else
					button.Name:SetTextColor(1.0, 0.82, 0);
				end

				button.Item.Count:SetText(quantity);
				button.Item.Count:SetShown(quantity > 1);
			
				button.Type:SetText(itemType);
				
				button.Seller:SetText(sellerName);
				
				button.Level:SetText(level);

				local bidAmount = currBid;
				local minNextBid = currBid + minIncrement;
				if ( currBid == 0 ) then
					bidAmount = minBid;
					minNextBid = minBid;
				end
				MoneyFrame_Update(button.CurrentBid, bidAmount);
				
				button.minNextBid = minNextBid;
				button.YourBid:SetShown(youHaveHighBid);
				
				button.TimeLeft.Text:SetText(_G["AUCTION_TIME_LEFT"..timeLeft]);
				button.TimeLeft.tooltip = _G["AUCTION_TIME_LEFT"..timeLeft.."_DETAIL"];
				
				button.itemLink = link;
				button.marketID = marketID;
				if ( marketID == BlackMarketFrame.selectedMarketID ) then
					button.Selection:Show();
				else
					button.Selection:Hide();
				end

				button:Show();
			else
				button:Hide()
			end
		else
			button:Hide();
		end
	end
	
	local totalHeight = numItems * scrollFrame.buttonHeight;
	local displayedHeight = numButtons * scrollFrame.buttonHeight;
	HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight);
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
	local r, g, b = GetItemQualityColor(quality);
	local data = {	["texture"] = texture, ["name"] = name, ["color"] = {r, g, b, 1}, 
					["link"] = link, ["count"] = quantity,
					["bid"] = bid, ["auctionID"] = auctionID,
	};	
	StaticPopup_Show("BID_BLACKMARKET", GetMoneyString(bid), nil, data);
end

function BlackMarketItem_OnClick(self, button, down)
	MoneyInputFrame_SetCopper(BlackMarketBidPrice, self.minNextBid);
	BlackMarketFrame.selectedMarketID = self.marketID;
	BlackMarketScrollFrame_Update();
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

--[[
-- Rarity DropDown
function BlackMarket_RarityDropDown_OnLoad(self)
	UIDropDownMenu_SetWidth(self, 95);
	UIDropDownMenu_Initialize(self, BlackMarket_RarityDropDown_Initialize);
	UIDropDownMenu_SetSelectedValue(self, -1);
end

function BlackMarket_RarityDropDown_Initialize()
	local info = UIDropDownMenu_CreateInfo();
	info.text = ALL;
	info.value = -1;
	info.func = BlackMarket_RarityDropDown_OnClick;
	UIDropDownMenu_AddButton(info);
	for i=0, getn(ITEM_QUALITY_COLORS)-2  do
		info.text = _G["ITEM_QUALITY"..i.."_DESC"];
		info.value = i;
		info.func = BrowseDropDown_OnClick;
		info.checked = nil;
		UIDropDownMenu_AddButton(info);
	end
end

function BlackMarket_RarityDropDown_OnClick(self)
	UIDropDownMenu_SetSelectedValue(BlackMarket_RarityDropDown, self.value);
end
]]