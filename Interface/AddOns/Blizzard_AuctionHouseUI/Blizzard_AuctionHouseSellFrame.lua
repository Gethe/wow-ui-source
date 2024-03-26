
AuctionHouseSellFrameAlignedControlMixin = {};

function AuctionHouseSellFrameAlignedControlMixin:OnLoad()
	self:SetLabel(self.labelText);
end

function AuctionHouseSellFrameAlignedControlMixin:SetLabel(text)
	self.Label:SetText(text or "");
	self.LabelTitle:SetText(text or "");
end

function AuctionHouseSellFrameAlignedControlMixin:SetSubtext(text)
	self.Subtext:SetText(text);

	local hasSubtext = text ~= nil;
	self.Label:SetShown(not hasSubtext);
	self.LabelTitle:SetShown(hasSubtext);
	self.Subtext:SetShown(hasSubtext);
end

function AuctionHouseSellFrameAlignedControlMixin:SetLabelColor(color)
	self.Label:SetTextColor(color:GetRGB());
	self.LabelTitle:SetTextColor(color:GetRGB());
end


AuctionHouseAlignedQuantityInputBoxMixin = {};

function AuctionHouseAlignedQuantityInputBoxMixin:OnEditFocusLost()
	EditBox_ClearHighlight(self);

	if self:GetNumber() < 1 then
		self:Reset();

		local inputChangedCallback = self:GetInputChangedCallback();
		if inputChangedCallback then
			inputChangedCallback();
		end
	end
end

function AuctionHouseAlignedQuantityInputBoxMixin:SetNextEditBox(nextEditBox)
	self.nextEditBox = nextEditBox;

	if nextEditBox then
		nextEditBox.previousEditBox = self;
	end
end


AuctionHouseQuantityInputMaxButtonMixin = {};

function AuctionHouseQuantityInputMaxButtonMixin:OnClick()
	self:GetParent():GetParent():SetToMaxQuantity();
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end


AuctionHouseAlignedQuantityInputFrameMixin = {};

function AuctionHouseAlignedQuantityInputFrameMixin:GetQuantity()
	return self.InputBox:GetNumber();
end

function AuctionHouseAlignedQuantityInputFrameMixin:SetQuantity(quantity)
	self.InputBox:SetNumber(quantity);
end

function AuctionHouseAlignedQuantityInputFrameMixin:SetInputChangedCallback(callback)
	self.InputBox:SetInputChangedCallback(callback);
end

function AuctionHouseAlignedQuantityInputFrameMixin:Reset()
	self.InputBox:Reset();
end

function AuctionHouseAlignedQuantityInputFrameMixin:SetNextEditBox(nextEditBox)
	self.InputBox:SetNextEditBox(nextEditBox);
end


AuctionHouseAlignedPriceInputFrameMixin = {};

function AuctionHouseAlignedPriceInputFrameMixin:OnLoad()
	AuctionHouseSellFrameAlignedControlMixin.OnLoad(self);
end

function AuctionHouseAlignedPriceInputFrameMixin:SetNextEditBox(nextEditBox)
	self.MoneyInputFrame:SetNextEditBox(nextEditBox);
end

function AuctionHouseAlignedPriceInputFrameMixin:Clear()
	self.MoneyInputFrame:Clear();
end

function AuctionHouseAlignedPriceInputFrameMixin:SetAmount(amount)
	if amount == 0 then
		self.MoneyInputFrame:Clear();
	else
		self.MoneyInputFrame:SetAmount(amount);
	end
end

function AuctionHouseAlignedPriceInputFrameMixin:GetAmount()
	return self.MoneyInputFrame:GetAmount();
end

function AuctionHouseAlignedPriceInputFrameMixin:SetOnValueChangedCallback(callback)
	return self.MoneyInputFrame:SetOnValueChangedCallback(callback);
end

function AuctionHouseAlignedPriceInputFrameMixin:SetErrorTooltip(tooltip)
	self.PriceError:SetTooltip(tooltip);
end

function AuctionHouseAlignedPriceInputFrameMixin:SetErrorShown(shown)
	self.PriceError:SetShown(shown);
end


AuctionHousePriceErrorFrameMixin = {};

function AuctionHousePriceErrorFrameMixin:OnEnter()
	if self.tooltip then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		local wrap = true;
		GameTooltip_AddColoredLine(GameTooltip, self.tooltip, RED_FONT_COLOR, wrap);
		GameTooltip:Show();
	end
end

function AuctionHousePriceErrorFrameMixin:OnLeave()
	GameTooltip_Hide();
end

function AuctionHousePriceErrorFrameMixin:SetTooltip(tooltip)
	self.tooltip = tooltip;
end


AuctionHouseDurationDropDownMixin = {};

function AuctionHouseDurationDropDownMixin:OnLoad()
	UIDropDownMenu_SetWidth(self, 80, 40);

	self.Text:SetFontObject(Number12Font);
end

function AuctionHouseDurationDropDownMixin:OnShow()
	UIDropDownMenu_Initialize(self, AuctionHouseDurationDropDownMixin.Initialize);

	if self.durationValue == nil then
		self:SetDuration(tonumber(GetCVar("auctionHouseDurationDropdown")));
	end
end

local AUCTION_DURATIONS = {
	AUCTION_DURATION_ONE,
	AUCTION_DURATION_TWO,
	AUCTION_DURATION_THREE,
};

function AuctionHouseDurationDropDownMixin:Initialize()
	local function AuctionHouseDurationDropDownButton_OnClick(button)
		self:SetDuration(button.value);
		SetCVar("auctionHouseDurationDropdown", button.value);
	end

	for i, durationText in ipairs(AUCTION_DURATIONS) do
		local info = UIDropDownMenu_CreateInfo();
		info.fontObject = Number12Font;
		info.text = durationText;
		info.minWidth = 108;
		info.value = i;
		info.checked = nil;
		info.func = AuctionHouseDurationDropDownButton_OnClick;
		UIDropDownMenu_AddButton(info);
	end
end

function AuctionHouseDurationDropDownMixin:SetDuration(durationValue)
	self.durationValue = durationValue;
	UIDropDownMenu_SetSelectedValue(self, durationValue);
	self:GetParent():OnDurationUpdated();
end

function AuctionHouseDurationDropDownMixin:GetDuration()
	return self.durationValue or tonumber(GetCVar("auctionHouseDurationDropdown"));
end


AuctionHouseAlignedDurationDropDownMixin = {};

function AuctionHouseAlignedDurationDropDownMixin:OnDurationUpdated()
	self:GetParent():OnDurationUpdated();
end

function AuctionHouseAlignedDurationDropDownMixin:GetDuration()
	return self.DropDown:GetDuration();
end


AuctionHouseAlignedPriceDisplayMixin = {};

function AuctionHouseAlignedPriceDisplayMixin:GetAmount(amount)
	return self.MoneyDisplayFrame:GetAmount();
end

function AuctionHouseAlignedPriceDisplayMixin:SetAmount(amount)
	self.MoneyDisplayFrame:SetAmount(amount);
end


AuctionHouseSellFramePostButtonMixin = {};

function AuctionHouseSellFramePostButtonMixin:OnClick()
	self:GetParent():PostItem();
	PlaySound(SOUNDKIT.LOOT_WINDOW_COIN_SOUND);
end

function AuctionHouseSellFramePostButtonMixin:OnEnter()
	if self.tooltip then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		local wrap = true;
		GameTooltip_AddColoredLine(GameTooltip, self.tooltip, RED_FONT_COLOR, wrap);
		GameTooltip:Show();
	end
end

function AuctionHouseSellFramePostButtonMixin:OnLeave()
	GameTooltip_Hide();
end

function AuctionHouseSellFramePostButtonMixin:SetTooltip(tooltip)
	self.tooltip = tooltip;
end


AuctionHouseSellFrameOverlayMixin = {};

function AuctionHouseSellFrameOverlayMixin:OnEnter()
	self:GetParent():OnOverlayEnter();
end

function AuctionHouseSellFrameOverlayMixin:OnLeave()
	self:GetParent():OnOverlayLeave();
end

function AuctionHouseSellFrameOverlayMixin:OnClick()
	self:GetParent():OnOverlayClick();
end

function AuctionHouseSellFrameOverlayMixin:OnReceiveDrag()
	self:GetParent():OnOverlayReceiveDrag();
end


AuctionHouseSellFrameItemDisplayMixin = {};

function AuctionHouseSellFrameItemDisplayMixin:OnLoad()
	AuctionHouseInteractableItemDisplayMixin.OnLoad(self);

	self.NineSlice:Hide();
end


AuctionHouseSellFrameMixin = CreateFromMixins(AuctionHouseSortOrderSystemMixin);

local AUCTION_HOUSE_SELL_FRAME_EVENTS = {
	"CURSOR_CHANGED",
	"AUCTION_HOUSE_THROTTLED_SYSTEM_READY",
	"AUCTION_HOUSE_THROTTLED_MESSAGE_SENT",
}

function AuctionHouseSellFrameMixin:OnLoad()
	AuctionHouseBackgroundMixin.OnLoad(self);
	AuctionHouseSortOrderSystemMixin.OnLoad(self);

	self.ItemDisplay:SetAuctionHouseFrame(self:GetAuctionHouseFrame());

	self.ItemDisplay:SetOnItemChangedCallback(function(item)
		if item == nil then
			local fromItemDisplay = true;
			self:SetItem(item, fromItemDisplay);
		else
			self:GetAuctionHouseFrame():SetPostItem(item);
		end
	end);

	self.ItemDisplay:SetItemValidationFunction(function(itemDisplay)
		local itemLocation = itemDisplay:GetItemLocation();
		return itemLocation == nil or C_AuctionHouse.IsSellItemValid(itemLocation);
	end);

	self.ItemDisplay.ItemButton.Highlight:ClearAllPoints();
	self.ItemDisplay.ItemButton.Highlight:SetPoint("TOPLEFT", self.ItemDisplay.ItemButton, "TOPLEFT");
	self.ItemDisplay.ItemButton.Highlight:SetPoint("BOTTOMRIGHT", self.ItemDisplay.ItemButton, "BOTTOMRIGHT");

	self.QuantityInput:SetInputChangedCallback(function()
		local maxQuantity = self:GetMaxQuantity();
		if self.QuantityInput:GetQuantity() > maxQuantity then
			self.QuantityInput:SetQuantity(maxQuantity);
		end

		self:UpdatePostState();
	end);

	self.PriceInput:SetOnValueChangedCallback(function()
		self:UpdatePostState();
	end);

	self:UpdateFocusTabbing();
end

function AuctionHouseSellFrameMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, AUCTION_HOUSE_SELL_FRAME_EVENTS);
	self.fixedWidth = self:GetWidth();
	self.fixedHeight = self:GetHeight();
	self:Layout();
end

function AuctionHouseSellFrameMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, AUCTION_HOUSE_SELL_FRAME_EVENTS);
end

function AuctionHouseSellFrameMixin:OnEvent(event, ...)
	if event == "CURSOR_CHANGED" then
		if self.Overlay:IsMouseOver() then
			self:OnOverlayEnter();
		end
	elseif event == "AUCTION_HOUSE_THROTTLED_SYSTEM_READY" or event == "AUCTION_HOUSE_THROTTLED_MESSAGE_SENT" then
		self:UpdatePostButtonState();
	end
end

function AuctionHouseSellFrameMixin:SetSearchResultPrice(searchResultPrice)
	self.searchResultPrice = searchResultPrice;
end

function AuctionHouseSellFrameMixin:ClearSearchResultPrice()
	self.searchResultPrice = nil;
end

function AuctionHouseSellFrameMixin:GetSearchResultPrice()
	return self.searchResultPrice;
end

function AuctionHouseSellFrameMixin:UpdatePostState()
	self:UpdateDeposit();
	self:UpdateTotalPrice();
	self:UpdatePostButtonState();

	local quantity = self.QuantityInput:GetQuantity();
	self.QuantityInput.MaxButton:SetEnabled(quantity < self:GetMaxQuantity());

	local price = self.PriceInput:GetAmount();
	local searchResultPrice = self:GetSearchResultPrice();
	if searchResultPrice and price == (searchResultPrice - COPPER_PER_SILVER) then
		self:ShowHelpTip();
	else
		self:HideHelpTip();
	end
end

function AuctionHouseSellFrameMixin:UpdateFocusTabbing()
	self.QuantityInput:SetNextEditBox(self.PriceInput.MoneyInputFrame.GoldBox);
	self.PriceInput:SetNextEditBox(self.QuantityInput:IsShown() and self.QuantityInput.InputBox or nil);
end

function AuctionHouseSellFrameMixin:OnDurationUpdated()
	self:UpdatePostState();
end

function AuctionHouseSellFrameMixin:SetToMaxQuantity()
	self.QuantityInput:SetQuantity(self:GetMaxQuantity());
	self:UpdatePostState();
end

function AuctionHouseSellFrameMixin:GetMaxQuantity()
	local itemLocation = self.ItemDisplay:GetItemLocation();
	return itemLocation and C_AuctionHouse.GetAvailablePostCount(itemLocation) or 1;
end

function AuctionHouseSellFrameMixin:SetItem(itemLocation, fromItemDisplay)
	if itemLocation ~= nil then
		if not C_AuctionHouse.IsSellItemValid(itemLocation) then
			return false;
		end
	end

	local itemKey = itemLocation and C_AuctionHouse.GetItemKeyFromItem(itemLocation);
	local itemKeyInfo = itemKey and C_AuctionHouse.GetItemKeyInfo(itemKey);
	self.ItemDisplay:SetItemLevelShown(itemKeyInfo and itemKeyInfo.isEquipment);

	self.itemLocation = itemLocation;

	if not fromItemDisplay then
		local skipCallback = true;
		self.ItemDisplay:SetItemLocation(itemLocation, skipCallback);
	end

	self.QuantityInput:Reset();
	self.PriceInput:SetAmount(self:GetDefaultPrice());
	self:UpdatePostState();

	local showQuantity = self:GetMaxQuantity() > 1;
	self.QuantityInput:SetShown(showQuantity);

	-- Hack fix for a spacing problem: Without this line, the edit box would be scrolled to
	-- the left and the text would not be visible. This seems to be a problem with setting
	-- the text on the edit box and showing it in the same frame.
	self.QuantityInput.InputBox:SetCursorPosition(0);

	self:MarkDirty();

	self:UpdateFocusTabbing();

	return true;
end

function AuctionHouseSellFrameMixin:GetItem()
	return self.itemLocation;
end

function AuctionHouseSellFrameMixin:GetDefaultPrice()
	local itemLocation = self:GetItem();
	if itemLocation and itemLocation:IsValid() then
		local itemLink = C_Item.GetItemLink(itemLocation);
		local defaultPrice = COPPER_PER_SILVER;
		if LinkUtil.IsLinkType(itemLink, "item") then
			local vendorPrice = select(11, C_Item.GetItemInfo(itemLink));
			defaultPrice = vendorPrice ~= nil and (vendorPrice * Constants.AuctionConstants.DEFAULT_AUCTION_PRICE_MULTIPLIER) or COPPER_PER_SILVER;
			defaultPrice = defaultPrice + (COPPER_PER_SILVER - (defaultPrice % COPPER_PER_SILVER)); -- AH prices must be in silver increments.
		end
		return math.max(defaultPrice, COPPER_PER_SILVER);
	end

	return COPPER_PER_SILVER;
end

function AuctionHouseSellFrameMixin:GetDuration()
	return self.DurationDropDown:GetDuration();
end

function AuctionHouseSellFrameMixin:GetQuantity()
	return self.QuantityInput:GetQuantity();
end

function AuctionHouseSellFrameMixin:OnOverlayEnter()
	local item = C_Cursor.GetCursorItem();
	if item then
		self.ItemDisplay:SetHighlightLocked(true);
	end
end

function AuctionHouseSellFrameMixin:OnOverlayLeave()
	self.ItemDisplay:SetHighlightLocked(false);
end

function AuctionHouseSellFrameMixin:OnOverlayClick()
	local item = C_Cursor.GetCursorItem();
	if item then
		self.ItemDisplay:SwitchItemWithCursor();
	end
end

function AuctionHouseSellFrameMixin:OnOverlayReceiveDrag()
	self:OnOverlayClick();
end

function AuctionHouseSellFrameMixin:UpdatePostButtonState()
	local canPostItem, reasonTooltip = self:CanPostItem();
	self.PostButton:SetEnabled(canPostItem);
	self.PostButton:SetTooltip(reasonTooltip);
end

function AuctionHouseSellFrameMixin:CanPostItem()
	local item = self:GetItem();
	if item == nil then
		return false, AUCTION_HOUSE_SELL_FRAME_ERROR_ITEM;
	end

	local hasEnoughMoneyForDeposit = GetMoney() >= self:GetDepositAmount();
	if not hasEnoughMoneyForDeposit then
		return false, AUCTION_HOUSE_SELL_FRAME_ERROR_DEPOSIT;
	end

	local quantity = self:GetQuantity();
	if quantity < 1 then
		return false, AUCTION_HOUSE_SELL_FRAME_ERROR_QUANTITY;
	end

	if not C_AuctionHouse.IsThrottledMessageSystemReady() then
		return false, ERR_GENERIC_THROTTLE;
	end

	return true, nil;
end

function AuctionHouseSellFrameMixin:UpdateDeposit()
	local depositCost = self:GetDepositAmount();
	depositCost = math.ceil(depositCost / COPPER_PER_SILVER) * COPPER_PER_SILVER;
	self.Deposit:SetAmount(depositCost);
end

function AuctionHouseSellFrameMixin:UpdateTotalPrice()
	self.TotalPrice:SetAmount(self:GetTotalPrice());
end

function AuctionHouseSellFrameMixin:ShowHelpTip()
	local helpTipInfo = {
		text = AUCTION_HOUSE_UNDERCUT_TUTORIAL,
		buttonStyle = HelpTip.ButtonStyle.GotIt,
		targetPoint = HelpTip.Point.RightEdgeCenter,
		alignment = HelpTip.Alignment.CENTER,
		offsetX = -6,
		offsetY = 2,
	};

	HelpTip:Show(self, helpTipInfo, self.PriceInput.MoneyInputFrame);
end

function AuctionHouseSellFrameMixin:HideHelpTip()
	HelpTip:Acknowledge(self, AUCTION_HOUSE_UNDERCUT_TUTORIAL);
end

function AuctionHouseSellFrameMixin:GetDepositAmount()
	-- Implement in your derived mixin.
end

function AuctionHouseSellFrameMixin:GetTotalPrice()
	-- Implement in your derived mixin.
end

function AuctionHouseSellFrameMixin:PostItem()
	-- Implement in your derived mixin.
end
