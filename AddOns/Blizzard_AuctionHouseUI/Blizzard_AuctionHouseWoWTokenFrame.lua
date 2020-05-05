
StaticPopupDialogs["TOKEN_NONE_FOR_SALE"] = {
	text = TOKEN_NONE_FOR_SALE,
	button1 = OKAY,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = true,
}

StaticPopupDialogs["TOKEN_AUCTIONABLE_TOKEN_OWNED"] = {
	text = TOKEN_AUCTIONABLE_TOKEN_OWNED,
	button1 = OKAY,
	timeout = 0,
	exclusive = 1,
	hideOnEscape = true,
}


function BrowseWowTokenResults_OnLoad(self)
	AuctionHouseBackgroundMixin.OnLoad(self);
	
	self:RegisterEvent("TOKEN_MARKET_PRICE_UPDATED");
	self:RegisterEvent("TOKEN_STATUS_CHANGED");
	self:RegisterEvent("TOKEN_BUY_RESULT");
	self:RegisterEvent("PLAYER_MONEY");

	self.TokenDisplay:SetItem(WOW_TOKEN_ITEM_ID);
	self.TokenDisplay.NineSlice:Hide();
end

function BrowseWowTokenResults_OnShow(self)
	self.disabled = not C_WowTokenPublic.GetCommerceSystemStatus();

	AuctionWowToken_UpdateMarketPrice();
	BrowseWowTokenResults_Update(self);
end

function BrowseWowTokenResults_OnHide(self)
	self.GameTimeTutorial:Hide();
end

function BrowseWowTokenResults_OnUpdate(self, elapsed)
	local now = GetTime();

	local remaining = 60 - (now - self.timeStarted);
	if (remaining < 1) then
		GameTooltip:Hide();
		self:SetScript("OnUpdate", nil);
		self.noneForSale = false;
		self.timeStarted = nil;
		self.Buyout.tooltip = nil;
	else
		self.Buyout.tooltip = TOKEN_TRY_AGAIN_LATER:format(INT_SPELL_DURATION_SEC:format(math.floor(remaining)));
		if (GameTooltip:GetOwner() == self.Buyout) then
			GameTooltip:SetText(self.Buyout.tooltip);
		end
	end
	BrowseWowTokenResults_Update(self);
end

function BrowseWowTokenResults_OnEvent(self, event, ...)
	if (event == "TOKEN_MARKET_PRICE_UPDATED") then
		local result = ...;
		if (result == LE_TOKEN_RESULT_ERROR_DISABLED) then
			self.disabled = true;
		end
		BrowseWowTokenResults_Update(self);
	elseif (event == "TOKEN_STATUS_CHANGED") then
		self.disabled = not C_WowTokenPublic.GetCommerceSystemStatus();
		AuctionWowToken_UpdateMarketPrice();
		BrowseWowTokenResults_Update(self);
	elseif (event == "TOKEN_BUY_RESULT") then
		local result = ...;
		if (result == LE_TOKEN_RESULT_ERROR_DISABLED) then
			self.disabled = true;
		elseif (result == LE_TOKEN_RESULT_ERROR_NONE_FOR_SALE) then
			self.noneForSale = true;
			StaticPopup_Show("TOKEN_NONE_FOR_SALE");
			self.timeStarted = GetTime();
			self:SetScript("OnUpdate", BrowseWowTokenResults_OnUpdate);
		elseif (result == LE_TOKEN_RESULT_ERROR_AUCTIONABLE_TOKEN_OWNED) then
			StaticPopup_Show("TOKEN_AUCTIONABLE_TOKEN_OWNED");
		elseif (result == LE_TOKEN_RESULT_ERROR_TOO_MANY_TOKENS) then
			UIErrorsFrame:AddMessage(SPELL_FAILED_TOO_MANY_OF_ITEM, 1.0, 0.1, 0.1, 1.0);
		elseif (result == LE_TOKEN_RESULT_ERROR_TRIAL_RESTRICTED) then
			UIErrorsFrame:AddMessage(ERR_RESTRICTED_ACCOUNT_TRIAL, 1.0, 0.1, 0.1, 1.0);
		elseif (result ~= LE_TOKEN_RESULT_SUCCESS) then
			UIErrorsFrame:AddMessage(ERR_AUCTION_DATABASE_ERROR, 1.0, 0.1, 0.1, 1.0);
		else
			local info = ChatTypeInfo["SYSTEM"];
			local itemName = GetItemInfo(WOW_TOKEN_ITEM_ID);
			DEFAULT_CHAT_FRAME:AddMessage(ERR_AUCTION_WON_S:format(itemName), info.r, info.g, info.b, info.id);
			C_WowTokenPublic.UpdateTokenCount();
		end
	elseif ( event == "PLAYER_MONEY" ) then
		BrowseWowTokenResults_Update(self);
	end
end

local function GetFormattedWoWTokenPrice(price)
	local gold = price / COPPER_PER_GOLD;
	if ( ENABLE_COLORBLIND_MODE == "1" ) then
		return FormatLargeNumber(gold)..GOLD_AMOUNT_SYMBOL;
	else
		local xOffset = 2;
		return FormatLargeNumber(gold)..CreateAtlasMarkup("auctionhouse-icon-coin-gold", nil, nil, xOffset);
	end
end

function BrowseWowTokenResults_Update(self)
	if (not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GAME_TIME_AUCTION_HOUSE) and C_WowTokenPublic.GetCommerceSystemStatus()) then
		self.GameTimeTutorial:Show();
		SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GAME_TIME_AUCTION_HOUSE, true);
	end
	local marketPrice;
	if (WowToken_IsWowTokenAuctionDialogShown()) then
		marketPrice = C_WowTokenPublic.GetGuaranteedPrice();
	else
		marketPrice = C_WowTokenPublic.GetCurrentMarketPrice();
	end

	if (self.disabled) then
		self.BuyoutPrice:SetText(TOKEN_AUCTIONS_UNAVAILABLE);
		self.BuyoutPrice:SetFontObject(GameFontRed);
		self.InvisiblePriceFrame:Hide();
		self.Buyout:SetEnabled(false);
	elseif (not marketPrice) then
		self.BuyoutPrice:SetText(TOKEN_MARKET_PRICE_NOT_AVAILABLE);
		self.BuyoutPrice:SetFontObject(GameFontRed);
		self.InvisiblePriceFrame:Hide();
		self.Buyout:SetEnabled(false);
	elseif (self.noneForSale) then
		self.BuyoutPrice:SetText(GetFormattedWoWTokenPrice(marketPrice));
		self.BuyoutPrice:SetFontObject(PriceFontWhite);
		self.InvisiblePriceFrame:Show();
		self.Buyout:SetEnabled(false);
	else
		self.BuyoutPrice:SetText(GetFormattedWoWTokenPrice(marketPrice));
		self.BuyoutPrice:SetFontObject(PriceFontWhite);
		self.InvisiblePriceFrame:Show();
		if (GetMoney() < marketPrice) then
			self.Buyout:SetEnabled(false);
			self.Buyout.tooltip = ERR_NOT_ENOUGH_GOLD;
		else
			self.Buyout:SetEnabled(true);
			self.Buyout.tooltip = nil;
		end
	end
end

function BrowseWowTokenResultsBuyout_OnClick(self)
	C_WowTokenPublic.BuyToken();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
end

function BrowseWowTokenResultsBuyout_OnEnter(self)
	if (self.tooltip) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltip);
		GameTooltip:Show();
	end
end


WoWTokenSellFrameMixin = CreateFromMixins(AuctionHouseSystemMixin);

function WoWTokenSellFrameMixin:OnLoad()
	AuctionHouseBackgroundMixin.OnLoad(self);

	self.ItemDisplay:SetOnItemChangedCallback(function(item)
		if item == nil then
			self:GetAuctionHouseFrame():SetDisplayMode(AuctionHouseFrameDisplayMode.ItemSell);
		else
			self:GetAuctionHouseFrame():SetPostItem(item);
		end
	end);

	self:RegisterEvent("TOKEN_MARKET_PRICE_UPDATED");
	self:RegisterEvent("TOKEN_STATUS_CHANGED");
	self:RegisterEvent("TOKEN_SELL_RESULT");
	self:RegisterEvent("TOKEN_AUCTION_SOLD");
	self:RegisterEvent("TOKEN_SELL_CONFIRMED");

	self.DummyRefreshButton:SetEnabledState(false);
end

function WoWTokenSellFrameMixin:OnShow()
	self.disabled = not C_WowTokenPublic.GetCommerceSystemStatus();
	self:Refresh();
end

function WoWTokenSellFrameMixin:OnEvent(event, ...)
	if (event == "TOKEN_MARKET_PRICE_UPDATED") then
		local result = ...;
		if (result == LE_TOKEN_RESULT_ERROR_DISABLED) then
			self.disabled = true;
		end
		self:Refresh();
	elseif (event == "TOKEN_STATUS_CHANGED") then
		AuctionWowToken_UpdateMarketPrice();
		self.disabled = not C_WowTokenPublic.GetCommerceSystemStatus();
		self:Refresh();
	elseif (event == "TOKEN_SELL_RESULT") then
		local result = ...;
		if (result == LE_TOKEN_RESULT_ERROR_DISABLED) then
			UIErrorsFrame:AddMessage(TOKEN_AUCTIONS_UNAVAILABLE, 1.0, 0.1, 0.1, 1.0);
		elseif (result ~= LE_TOKEN_RESULT_SUCCESS) then
			UIErrorsFrame:AddMessage(ERR_AUCTION_DATABASE_ERROR, 1.0, 0.1, 0.1, 1.0);
		else
			C_WowTokenPublic.UpdateListedAuctionableTokens();
			
			local info = ChatTypeInfo["SYSTEM"];
			DEFAULT_CHAT_FRAME:AddMessage(ERR_AUCTION_STARTED, info.r, info.g, info.b, info.id);
		end
	elseif (event == "TOKEN_AUCTION_SOLD") then
		C_WowTokenPublic.UpdateListedAuctionableTokens();
	elseif (event == "TOKEN_SELL_CONFIRMED") then
		self:SetItem(nil);
	end
end

function WoWTokenSellFrameMixin:SetItem(itemLocation)
	if itemLocation then
		C_WowTokenPublic.UpdateTokenCount();
	end

	local skipCallback = true;
	self.ItemDisplay:SetItemLocation(itemLocation, skipCallback);

	local itemIsValid = itemLocation and C_Item.DoesItemExist(itemLocation);
	self.PostButton:SetEnabled(itemIsValid);
end

function WoWTokenSellFrameMixin:GetItem()
	return self.ItemDisplay:GetItemLocation();
end

function WoWTokenSellFrameMixin:GetSellToken(itemLocation)
	local itemLocation = self.ItemDisplay:GetItemLocation();
	local itemIsValid = itemLocation and C_Item.DoesItemExist(itemLocation);
	return itemIsValid and C_Item.GetItemGUID(itemLocation) or nil;
end

function WoWTokenSellFrameMixin:Refresh()
	local price, duration = C_WowTokenPublic.GetCurrentMarketPrice();
	if (WowToken_IsWowTokenAuctionDialogShown()) then
		price = C_WowTokenPublic.GetGuaranteedPrice();
	end

	local enabled = price and not self.disabled;
	self.InvisiblePriceFrame:SetShown(enabled);
	self.PostButton:SetEnabled(enabled);
	self.MarketPrice:SetFontObject(enabled and PriceFontWhite or GameFontRed);
	if (enabled) then
		self.MarketPrice:SetText(GetMoneyString(price, true));
		local timeToSellString = _G[("AUCTION_TIME_LEFT%d_DETAIL"):format(duration)];
		self.TimeToSell:SetText(timeToSellString);
	else
		self.MarketPrice:SetText(TOKEN_MARKET_PRICE_NOT_AVAILABLE);
		self.TimeToSell:SetText(UNKNOWN);
	end
end

local WowTokenUpdateInfo = {};

function WowTokenUpdateInfo.AreWowTokenResultsVisible()
	return AuctionHouseFrame:GetDisplayMode() == AuctionHouseFrameDisplayMode.WoWTokenBuy;
end

function WowTokenUpdateInfo.IsWowTokenAuctionFrameVisible()
	return AuctionHouseFrame:GetDisplayMode() == AuctionHouseFrameDisplayMode.WoWTokenSell;
end


function AuctionWowToken_UpdateMarketPriceCallback()
	if (C_WowTokenPublic.GetCommerceSystemStatus() 
		and ((WowTokenUpdateInfo.AreWowTokenResultsVisible() or WowTokenUpdateInfo.IsWowTokenAuctionFrameVisible()) and not WowToken_IsWowTokenAuctionDialogShown())) then
		WowTokenUpdateInfo.lastMarketPriceUpdate = GetTime();
		C_WowTokenPublic.UpdateMarketPrice();
	elseif (not (WowTokenUpdateInfo.AreWowTokenResultsVisible() or WowTokenUpdateInfo.IsWowTokenAuctionFrameVisible())) then
		AuctionWowToken_CancelUpdateTicker();
	end
end

function AuctionWowToken_ShouldUpdatePrice()
	local now = GetTime();
	local enabled, pollTimeSeconds = C_WowTokenPublic.GetCommerceSystemStatus();
	if (not enabled) then
		return false;
	elseif (not C_WowTokenPublic.GetCurrentMarketPrice()) then
		return true;
	elseif (not WowTokenUpdateInfo.lastMarketPriceUpdate) then
		return true;
	elseif (now - WowTokenUpdateInfo.lastMarketPriceUpdate > pollTimeSeconds) then
		return true;
	end
	return false;
end

function AuctionWowToken_UpdateMarketPrice()
	if (AuctionWowToken_ShouldUpdatePrice()) then	
		WowTokenUpdateInfo.lastMarketPriceUpdate = GetTime();
		C_WowTokenPublic.UpdateMarketPrice();
	end
	if ((WowTokenUpdateInfo.AreWowTokenResultsVisible() or WowTokenUpdateInfo.IsWowTokenAuctionFrameVisible()) and not WowToken_IsWowTokenAuctionDialogShown()) then
		local _, pollTimeSeconds = C_WowTokenPublic.GetCommerceSystemStatus();
		if (not WowTokenUpdateInfo.priceUpdateTimer or pollTimeSeconds ~= WowTokenUpdateInfo.priceUpdateTimer.pollTimeSeconds) then
			if (WowTokenUpdateInfo.priceUpdateTimer) then
				WowTokenUpdateInfo.priceUpdateTimer:Cancel();
			end
			WowTokenUpdateInfo.priceUpdateTimer = C_Timer.NewTicker(pollTimeSeconds, AuctionWowToken_UpdateMarketPriceCallback);
			WowTokenUpdateInfo.priceUpdateTimer.pollTimeSeconds = pollTimeSeconds;
		end
	end
end

function AuctionWowToken_CancelUpdateTicker()
	if (WowTokenUpdateInfo.priceUpdateTimer) then
		WowTokenUpdateInfo.priceUpdateTimer:Cancel();
		WowTokenUpdateInfo.priceUpdateTimer = nil;
	end
end

function WoWTokenGameTimeTutorial_OnLoad(self)
	ButtonFrameTemplate_HidePortrait(self);
	ButtonFrameTemplate_HideAttic(self);
	ButtonFrameTemplate_HideButtonBar(self);
	self.TitleText:SetText(TUTORIAL_TOKEN_ABOUT_TOKENS);
end

function WoWTokenGameTimeTutorial_OnShow(self)
	local balanceEnabled = select(3, C_WowTokenPublic.GetCommerceSystemStatus());
	self.LeftDisplay.Tutorial3:SetIndentedWordWrap(true);
	if (balanceEnabled) then
		self.LeftDisplay.Tutorial3:SetText(TUTORIAL_TOKEN_GAME_TIME_STEP_2_BALANCE:format(WowTokenRedemptionFrame_GetBalanceString()));
	else
		self.LeftDisplay.Tutorial3:SetText(TUTORIAL_TOKEN_GAME_TIME_STEP_2);
	end
end

function WowTokenGameTimeTutorialStoreButton_OnEvent(self, event)
	if event == "TRIAL_STATUS_UPDATE" then
		WowTokenGameTimeTutorialStoreButton_UpdateState(self);
	end
end

function WowTokenGameTimeTutorialStoreButton_UpdateState(self)
	if GameLimitedMode_IsActive() then
		self.tooltip = ERR_FEATURE_RESTRICTED_TRIAL;
		self:Disable();
	else
		self.tooltip = nil;
		self:Enable();
	end
end

function WowTokenGameTimeTutorialStoreButton_OnLoad(self)
	local fontString = self:GetFontString();
	fontString:SetPoint("CENTER", 8, 2);
	self.Logo:ClearAllPoints();
	self.Logo:SetPoint("RIGHT", fontString, "LEFT", -2, 0);
	WowTokenGameTimeTutorialStoreButton_UpdateState(self);
	self:RegisterEvent("TRIAL_STATUS_UPDATE");
end

