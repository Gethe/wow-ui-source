
local REMAINING_QUOTE_DURATION_THRESHOLD = 10; -- seconds


AuctionHouseBuyDialogNotificationFrameMixin = {};

function AuctionHouseBuyDialogNotificationFrameMixin:SetNotificationText(notificationText, fontObject, showNotificationIcon)
	self.Button:SetShown(showNotificationIcon);

	self.Text:SetText(notificationText);
	self.Text:SetFontObject(fontObject);
	self.Text:ClearAllPoints();
	self.Text:SetPoint("BOTTOM");
	if showNotificationIcon then
		self.Text:SetPoint("CENTER", -15, 0);
	end
end

function AuctionHouseBuyDialogNotificationFrameMixin:SetPriceIncreases(unitPriceIncrease, totalPriceIncrease)
	self.unitPriceIncrease = unitPriceIncrease;
	self.totalPriceIncrease = totalPriceIncrease;
end

function AuctionHouseBuyDialogNotificationFrameMixin:GetPriceIncreases()
	return self.unitPriceIncrease, self.totalPriceIncrease;
end


AuctionHouseBuyDialogNotificationButtonMixin = {};

function AuctionHouseBuyDialogNotificationButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");

	-- Use normal size font for the title line.
	GameTooltipTextLeft1:SetFontObject(GameTooltipText);
	GameTooltipTextRight1:SetFontObject(GameTooltipText);

	local normalR, normalG, normalB = NORMAL_FONT_COLOR:GetRGB();
	local unitPriceIncrease, totalPriceIncrease = self:GetParent():GetPriceIncreases();
	GameTooltip:AddDoubleLine(AUCTION_HOUSE_DIALOG_PER_UNIT_INCREASE, GetMoneyString(unitPriceIncrease), normalR, normalG, normalB, HIGHLIGHT_FONT_COLOR:GetRGB());
	GameTooltip:AddDoubleLine(AUCTION_HOUSE_DIALOG_TOTAL_INCREASE, GetMoneyString(totalPriceIncrease), normalR, normalG, normalB, HIGHLIGHT_FONT_COLOR:GetRGB());
	GameTooltip:Show();
end

function AuctionHouseBuyDialogNotificationButtonMixin:OnLeave()
	GameTooltipTextLeft1:SetFontObject(GameTooltipHeaderText);
	GameTooltipTextRight1:SetFontObject(GameTooltipHeaderText);

	GameTooltip:Hide();
end


AuctionHouseBuyDialogButtonMixin = {};

function AuctionHouseBuyDialogButtonMixin:OnClick()
	-- Implement in your derived mixin.
end


AuctionHouseBuyDialogBuyNowButtonMixin = CreateFromMixins(AuctionHouseBuyDialogButtonMixin);

function AuctionHouseBuyDialogBuyNowButtonMixin:OnClick()
	self:GetParent():BuyNow();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end


AuctionHouseBuyDialogCancelButtonMixin = CreateFromMixins(AuctionHouseBuyDialogButtonMixin);

function AuctionHouseBuyDialogCancelButtonMixin:OnClick()
	self:GetParent():Cancel();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end


AuctionHouseBuyDialogOkayButtonMixin = CreateFromMixins(AuctionHouseBuyDialogButtonMixin);

function AuctionHouseBuyDialogOkayButtonMixin:OnClick()
	self:GetParent():Cancel();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end


AuctionHouseBuyDialogMixin = {};

local AUCTION_HOUSE_BUY_DIALOG_EVENTS = {
	"COMMODITY_PRICE_UPDATED",
	"COMMODITY_PRICE_UNAVAILABLE",
	"COMMODITY_PURCHASE_SUCCEEDED",
	"COMMODITY_PURCHASE_FAILED",
};

local BuyState = {
	WaitingForQuote = 1,
	PriceConfirmed = 2,
	PriceUpdated = 3,
	PriceUnavailable = 4,
	Purchasing = 5,
};

function AuctionHouseBuyDialogMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, AUCTION_HOUSE_BUY_DIALOG_EVENTS);
end

function AuctionHouseBuyDialogMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, AUCTION_HOUSE_BUY_DIALOG_EVENTS);

	C_AuctionHouse.CancelCommoditiesPurchase();

	C_AuctionHouse.RefreshCommoditySearchResults(self.itemID);
end

function AuctionHouseBuyDialogMixin:OnUpdate()
	self.quoteDurationRemaining = C_AuctionHouse.GetQuoteDurationRemaining();
	if self.quoteDurationRemaining == 0 then
		self:Hide();
		return;
	end

	self:UpdateTimeLeft();
end

function AuctionHouseBuyDialogMixin:UpdateTimeLeft()
	local showQuoteDuration = self.quoteDurationRemaining <= REMAINING_QUOTE_DURATION_THRESHOLD;
	self.TimeLeftText:SetShown(showQuoteDuration);
	if showQuoteDuration then
		self.TimeLeftText:SetText(self.quoteDurationRemaining);
	end
end

function AuctionHouseBuyDialogMixin:OnEvent(event, ...)
	if event == "COMMODITY_PRICE_UPDATED" then
		local updatedUnitPrice, updatedTotalPrice = ...;
		local currentUnitPrice = self.unitPricePreview;

		if updatedUnitPrice > currentUnitPrice then
			local currentTotalPrice = self.unitPricePreview * self.quantity;
			self.Notification:SetPriceIncreases(updatedUnitPrice - currentUnitPrice, updatedTotalPrice - currentTotalPrice);
			self:SetState(BuyState.PriceUpdated);
		else
			self:SetState(BuyState.PriceConfirmed);
		end
	elseif event == "COMMODITY_PRICE_UNAVAILABLE" then
		self:SetState(BuyState.PriceUnavailable);
	elseif event == "COMMODITY_PURCHASE_SUCCEEDED" then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		self:Hide();
	elseif event == "COMMODITY_PURCHASE_FAILED" then
		self:SetState(BuyState.PriceUnavailable);
	end
end

function AuctionHouseBuyDialogMixin:SetState(buyState)
	local itemDisplayShown = false;
	local buyNowShown = false;
	local buyNowEnabled = false;
	local okayShown = false;
	local notificationText = nil;
	local notificationFontObject = Number13FontYellow;
	local showNotificationIcon = false;
	local notificationAnchor = { "CENTER" };
	local dialogHeight = 95;
	if buyState == BuyState.WaitingForQuote then
		itemDisplayShown = true;
		buyNowShown = true;
	elseif buyState == BuyState.PriceConfirmed then
		itemDisplayShown = true;
		buyNowShown = true;
		buyNowEnabled = true;
	elseif buyState == BuyState.PriceUpdated then
		dialogHeight = 126;
		itemDisplayShown = true;
		buyNowShown = true;
		buyNowEnabled = true;
		notificationText = AUCTION_HOUSE_DIALOG_PRICE_UPDATED;
		showNotificationIcon = true;
		notificationAnchor = { "BOTTOM", self.OkayButton, "TOP", 0, 13 };
	elseif buyState == BuyState.PriceUnavailable then
		okayShown = true;
		dialogHeight = 80;
		notificationText = AUCTION_HOUSE_DIALOG_PRICE_UNAVAILABLE;
		notificationFontObject = Number13FontWhite;

		local topOffset = 20;
		local bottomOffset = self.OkayButton:GetTop() - self:GetBottom();
		local yOffset = (dialogHeight - (bottomOffset + topOffset)) / 2;
		notificationAnchor = { "CENTER", self.OkayButton, "TOP", 0, yOffset };
	elseif buyState == BuyState.Purchasing then
		buyNowShown = true;
		itemDisplayShown = true;
	else
		self:Cancel();
	end

	self.ItemDisplay:SetShown(itemDisplayShown);
	self.PriceFrame:SetShown(itemDisplayShown);
	self.BuyNowButton:SetShown(buyNowShown);
	self.CancelButton:SetShown(buyNowShown);
	self.BuyNowButton:SetEnabled(buyNowEnabled);
	self.CancelButton:SetEnabled(buyNowEnabled);
	self.OkayButton:SetShown(okayShown);
	self.Notification:SetShown(notificationText ~= nil);
	self.Notification:SetNotificationText(notificationText or "", notificationFontObject, showNotificationIcon);
	self.Notification:ClearAllPoints();
	self.Notification:SetPoint(unpack(notificationAnchor));
	self:SetHeight(dialogHeight);

	local quoteTimeoutActive = buyState == BuyState.PriceConfirmed or buyState == BuyState.PriceUpdated;
	self:SetScript("OnUpdate", quoteTimeoutActive and AuctionHouseBuyDialogMixin.OnUpdate or nil);
end

function AuctionHouseBuyDialogMixin:SetItemID(itemID, quantity, unitPricePreview)
	self.itemID = itemID;
	self.quantity = quantity;
	self.unitPricePreview = unitPricePreview;

	local itemName = C_Item.GetItemNameByID(itemID);
	local itemQuality = C_Item.GetItemQualityByID(itemID);
	if itemName and itemQuality then
		local itemQualityColor = ITEM_QUALITY_COLORS[quality or LE_ITEM_QUALITY_COMMON];
		local itemDisplayText = itemQualityColor.color:WrapTextInColorCode(itemName or "");
		self.ItemDisplay.ItemText:SetText(AUCTION_HOUSE_DIALOG_ITEM_FORMAT:format(itemDisplayText, quantity));
	end

	self.PriceFrame:SetAmount(quantity * unitPricePreview);

	self:SetState(BuyState.WaitingForQuote);
end

function AuctionHouseBuyDialogMixin:BuyNow()
	self:SetState(BuyState.Purchasing);
	C_AuctionHouse.ConfirmCommoditiesPurchase(self.itemID, self.quantity);
end

function AuctionHouseBuyDialogMixin:Cancel()
	self:Hide();
end
