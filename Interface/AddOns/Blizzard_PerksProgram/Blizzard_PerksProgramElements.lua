-- Perk Program Static Dialogs
local function PerksProgramPurchaseOnAccept(popup)
	PerksProgramFrame:Purchase(popup.data);
	EventRegistry:TriggerEvent("PerksProgram.RemoveItemFromCart", popup.data.product.perksVendorItemID);
end

local function PerksProgramPurchaseOnEvent(popup, event, ...)
	return event == "PERKS_PROGRAM_PURCHASE_SUCCESS";
end

StaticPopupDialogs["PERKS_PROGRAM_CONFIRM_PURCHASE"] = {
	text = PERKS_PROGRAM_CONFIRM_PURCHASE,
	button1 = PERKS_PROGRAM_PURCHASE,
	button2 = CANCEL,
	OnAccept = GenerateClosure(StaticPopup_OnAcceptWithSpinner, PerksProgramPurchaseOnAccept, PerksProgramPurchaseOnEvent, {"PERKS_PROGRAM_PURCHASE_SUCCESS"}, 0),
	timeout = 0,
	exclusive = 1,
	hasItemFrame = 1,
	fullScreenCover = true,
};

local function PerksProgramPurchaseCartOnAccept(popup)
	PerksProgramFrame:PurchaseCart(popup.data);
	EventRegistry:TriggerEvent("PerksProgram.ClearCart");
end

local function PerksProgramPurchaseCartOnEvent(popup, event, ...)
	return event == "PERKS_PROGRAM_PURCHASE_SUCCESS";
end

StaticPopupDialogs["PERKS_PROGRAM_CONFIRM_CART_PURCHASE"] = {
	text = PERKS_PROGRAM_CART_PURCHASE_POPUP_TEXT,
	button1 = PERKS_PROGRAM_PURCHASE,
	button2 = CANCEL,
	OnAccept = GenerateClosure(StaticPopup_OnAcceptWithSpinner, PerksProgramPurchaseCartOnAccept, PerksProgramPurchaseCartOnEvent, {"PERKS_PROGRAM_PURCHASE_SUCCESS"}, 0),
	timeout = 0,
	exclusive = 1,
	fullScreenCover = true,
};

local function PerksProgramRefundOnAccept(popup)
	PerksProgramFrame:Refund(popup.data);
end

local function PerksProgramRefundOnEvent(popup, event, ...)
	return event == "PERKS_PROGRAM_REFUND_SUCCESS";
end

StaticPopupDialogs["PERKS_PROGRAM_CONFIRM_REFUND"] = {
	text = PERKS_PROGRAM_CONFIRM_REFUND,
	button1 = PERKS_PROGRAM_REFUND,
	button2 = CANCEL,
	OnAccept = GenerateClosure(StaticPopup_OnAcceptWithSpinner, PerksProgramRefundOnAccept, PerksProgramRefundOnEvent, {"PERKS_PROGRAM_REFUND_SUCCESS"}, 0),
	timeout = 0,
	exclusive = 1,
	hasItemFrame = 1,
	fullScreenCover = true,
};

StaticPopupDialogs["PERKS_PROGRAM_SLOW_PURCHASE"] = {
	text = PERKS_PROGRAM_SLOW_PURCHASE,
	button1 = PERKS_PROGRAM_RETURN_TO_TRADING_POST,
	timeout = 0,
	exclusive = 1,
	fullScreenCover = true,
	hideOnEscape = true,
};

StaticPopupDialogs["PERKS_PROGRAM_SERVER_ERROR"] = {
	text = PERKS_PROGRAM_SERVER_ERROR,
	button1 = OKAY,
	timeout = 0,
	exclusive = 1,
	fullScreenCover = true,
	hideOnEscape = true,
};

StaticPopupDialogs["PERKS_PROGRAM_ITEM_PROCESSING_ERROR"] = {
	text = PERKS_PROGRAM_ITEM_PROCESSING_ERROR,
	button1 = OKAY,
	timeout = 0,
	exclusive = 1,
	fullScreenCover = true,
	hideOnEscape = true,
};

StaticPopupDialogs["PERKS_PROGRAM_CONFIRM_OVERRIDE_FROZEN_ITEM"] = {
	text = PERKS_PROGRAM_CONFIRM_OVERRIDE_FROZEN_ITEM,
	button1 = PERKS_PROGRAM_CONFIRM,
	button2 = CANCEL,
	OnShow = function(dialog, data) EventRegistry:TriggerEvent("PerksProgram.OnFrozenItemConfirmationShown"); end,
	OnAccept = function(dialog, data) EventRegistry:TriggerEvent("PerksProgram.OnFrozenItemConfirmationAccepted"); end,
	OnCancel = function(dialog, data) EventRegistry:TriggerEvent("PerksProgram.OnFrozenItemConfirmationCanceled"); end,
	OnHide = function(dialog, data) EventRegistry:TriggerEvent("PerksProgram.OnFrozenItemConfirmationHidden"); end,
	timeout = 0,
	exclusive = 1,
	hasItemFrame = 1,
	fullScreenCover = true,
	acceptDelay = 5,
};

StaticPopupDialogs["PERKS_PROGRAM_CLEAR_CART"] = {
	text = PERKS_PROGRAM_CART_CLEAR_POPUP_TEXT,
	button1 = PERKS_PROGRAM_CART_CLEAR_POPUP_CONFIRMATION,
	button2 = CANCEL,
	OnAccept = function(dialog, data) EventRegistry:TriggerEvent("PerksProgram.ClearCart"); end,
	timeout = 0,
	exclusive = 1,
	fullScreenCover = true,
};

local function AddPurchasePendingTooltipLines(tooltip)
	GameTooltip_AddHighlightLine(tooltip, PERKS_PROGRAM_PURCHASE_PENDING, wrap);
	GameTooltip_AddNormalLine(tooltip, PERKS_PROGRAM_PURCHASE_IN_PROGRESS, wrap);
end

local function IsPerksVendorCategoryTransmog(perksVendorCategoryID)
	return perksVendorCategoryID == Enum.PerksVendorCategoryType.Transmog or perksVendorCategoryID == Enum.PerksVendorCategoryType.Transmogset;
end

PerksRefundIconTooltipMixin = {};

function PerksRefundIconTooltipMixin:OnEnter()
	local productButtonFrameData = (self:GetParent():GetParent()).itemInfo;
	
	if not productButtonFrameData.refundable then
		return;
	end

	local refundTimeLeft = PERKS_PROGRAM_REFUND_TIME_LEFT:format(PerksProgramFrame:FormatTimeLeft(C_PerksProgram.GetVendorItemInfoRefundTimeLeft(productButtonFrameData.perksVendorItemID), PerksProgramFrame.TimeLeftFooterFormatter));
	PerksProgramFrame.PerksProgramTooltip:SetOwner(self, "ANCHOR_RIGHT");
	PerksProgramFrame.PerksProgramTooltip:SetText(refundTimeLeft);
	PerksProgramFrame.PerksProgramTooltip:Show();
end

function PerksRefundIconTooltipMixin:OnLeave()
	PerksProgramFrame.PerksProgramTooltip:Hide();
end

----------------------------------------------------------------------------------
-- PerksProductPriceMixin
----------------------------------------------------------------------------------

PerksProductPriceMixin = {};

function PerksProductPriceMixin:Init(price, salePrice)
	local itemOnSale = salePrice and salePrice < price;
	local playerCurrencyAmount = C_PerksProgram.GetCurrencyAmount();

	local priceText = "";
	local salePriceText = "";
	if playerCurrencyAmount then
		if itemOnSale then
			priceText = GRAY_FONT_COLOR:WrapTextInColorCode(price);
			
			if salePrice > playerCurrencyAmount then
				salePriceText = ORANGE_FONT_COLOR:WrapTextInColorCode(salePrice);
			else
				salePriceText = GREEN_FONT_COLOR:WrapTextInColorCode(salePrice);
			end
		else
			if price > playerCurrencyAmount then
				priceText = GRAY_FONT_COLOR:WrapTextInColorCode(price);
			else
				priceText = WHITE_FONT_COLOR:WrapTextInColorCode(price);
			end
		end
	end

	self.Price:SetText(priceText);
	self.Price:SetHeight(self.Price:GetStringHeight());

	self.SalePrice:SetShown(itemOnSale);

	if itemOnSale then
		self.SalePrice:SetText(salePriceText);
		self.SalePrice:SetHeight(self.SalePrice:GetStringHeight());
	else
		self.SalePrice:SetHeight(1);
	end

	self.PriceStrikethrough:SetShown(itemOnSale);
	self:Layout();
end

----------------------------------------------------------------------------------
-- PerksProgramProductButtonMixin
----------------------------------------------------------------------------------
PerksProgramProductButtonMixin = {};
function PerksProgramProductButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	EventRegistry:RegisterCallback("PerksProgram.CelebratePurchase", self.CelebratePurchase, self);
	EventRegistry:RegisterCallback("PerksProgram.OnProductInfoChanged", self.OnProductInfoChanged, self);
	EventRegistry:RegisterCallback("PerksProgram.AddItemToCart", self.OnAddItemToCart, self);
	EventRegistry:RegisterCallback("PerksProgram.RemoveItemFromCart", self.OnRemoveItemFromCart, self);
	EventRegistry:RegisterCallback("PerksProgram.ClearCart", self.OnClearCart, self);
	self:RegisterEvent("PERKS_PROGRAM_CURRENCY_REFRESH");

	self.tooltip = PerksProgramFrame.PerksProgramTooltip;
	local newFont = PerksProgramFrame:GetLabelFont();
	self.ContentsContainer.Label:SetFontObject(newFont);

	self.ContentsContainer.PurchasePendingSpinner:Init(
		function() self:OnEnter(); end,
		function() self:OnLeave(); end
		);
end

function PerksProgramProductButtonMixin:Init(onDragStartCallback)
	self.onDragStartCallback = onDragStartCallback;
end

function PerksProgramProductButtonMixin:SetItemInfo(itemInfo)
	local oldItemInfo = self.itemInfo;
	self.itemInfo = itemInfo;

	if not self.itemInfo or (oldItemInfo and (oldItemInfo.perksVendorItemID ~= self.itemInfo.perksVendorItemID)) then
		self.CelebrateAnimation:Hide();
		self.CelebrateAnimation.AlphaInAnimation:Stop();
	end

	local container = self.ContentsContainer;

	container.Label:SetText(self.itemInfo.name);

	self:UpdateItemPriceElement();
	self:UpdateTimeRemainingText();

	local iconTexture = C_Item.GetItemIconByID(self.itemInfo.itemID);
	container.Icon:SetTexture(iconTexture);

	local cartFrame = PerksProgramFrame.ProductsFrame.PerksProgramShoppingCartFrame;
	local itemIndex = cartFrame:FindItemIndex(itemInfo.perksVendorItemID);
	local isInCart = itemIndex ~= -1;
	self:UpdateCartState(isInCart);
	container.CartToggleButton:SetItemInfo(itemInfo, isInCart);
end

function PerksProgramProductButtonMixin:UpdateItemPriceElement()
	if self.itemInfo then
		local price = self.itemInfo.price;
		local salePrice = nil;

		if (self.itemInfo.originalPrice) then
			price = self.itemInfo.originalPrice;
			salePrice = self.itemInfo.price;
		end

		local container = self.ContentsContainer;
		local itemOnSale = salePrice and salePrice < price;
		local showDiscountContainer = itemOnSale and self.itemInfo.showSaleBanner;
		container.DiscountContainer:SetShown(showDiscountContainer);
		if showDiscountContainer then
			local salePercentage = itemOnSale and (((price - salePrice) / price) * 100) or 0;
			salePercentage = math.round(salePercentage);
			container.DiscountContainer.Text:SetText(string.format(PERKS_PROGRAM_SALE_PERCENT, salePercentage));
		end
		
		container.PriceContainer:Init(price, salePrice);

		local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CURRENCY_ID_PERKS_PROGRAM_DISPLAY_INFO);
		container.PriceIcon:SetTexture(currencyInfo.iconFileID);

		local showPrice = not self.itemInfo.purchased and not self.itemInfo.refundable and not self.itemInfo.isPurchasePending;
		container.PriceContainer:SetShown(showPrice);
		container.PriceIcon:SetShown(showPrice);
		container.PurchasePendingSpinner:SetShown(self.itemInfo.isPurchasePending);
		container.RefundIcon:SetShown(self.itemInfo.refundable);
		container.PurchasedIcon:SetShown(self.itemInfo.purchased and not self.itemInfo.refundable);
	end
end

function PerksProgramProductButtonMixin:OnEvent(event, ...)
	if event == "PERKS_PROGRAM_CURRENCY_REFRESH" then
		self:UpdateItemPriceElement();
	end
end

function PerksProgramProductButtonMixin:OnMouseDown()
	local container = self.ContentsContainer;
	container:SetPoint("TOPLEFT", 1, -1);
	container:SetPoint("BOTTOMRIGHT", 1, -1);
end

function PerksProgramProductButtonMixin:OnMouseUp()
	local container = self.ContentsContainer;
	container:SetPoint("TOPLEFT", 0, 0);
	container:SetPoint("BOTTOMRIGHT", 0, 0);
end

function PerksProgramProductButtonMixin:OnEnter()
	if self.itemInfo then
		self:UpdateTooltipState();

		local isPendingOrFrozen = self.isPendingFreezeItem or self.itemInfo.isFrozen;
		local cartableItem = not isPendingOrFrozen and not self.itemInfo.purchased and not self.itemInfo.refundable and not self.itemInfo.isPurchasePending;
		self.ContentsContainer.CartToggleButton:SetShown(cartableItem);
		self.ContentsContainer.TimeRemaining:SetShown(not cartableItem and not isPendingOrFrozen);
	end

	self.ContentsContainer.Label:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	self.ArtContainer.HighlightTexture:Show();

	PlaySound(SOUNDKIT.TRADING_POST_UI_ITEM_HOVER);
end

function PerksProgramProductButtonMixin:UpdateTooltipState()
	self.tooltip:SetOwner(self, "ANCHOR_RIGHT", -16, 0);
	local tooltipInfo = CreateBaseTooltipInfo("GetItemByID", self.itemInfo.itemID);
	tooltipInfo.excludeLines = {
			Enum.TooltipDataLineType.SellPrice,
	};
	self.tooltip:ProcessInfo(tooltipInfo);
	self.tooltip:Show();
end

function PerksProgramProductButtonMixin:OnLeave()
	if not self.isSelected then
		self.ContentsContainer.Label:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	end

	self.ArtContainer.HighlightTexture:Hide();
	self.tooltip:Hide();

	self.ContentsContainer.CartToggleButton:Hide();
	if not self.isPendingFreezeItem and self.itemInfo and not self.itemInfo.isFrozen then
		self.ContentsContainer.TimeRemaining:Show();
	end
end

function PerksProgramProductButtonMixin:OnDragStart()
	self.onDragStartCallback();
end

function PerksProgramProductButtonMixin:SetSelected(selected)
	local color = selected and WHITE_FONT_COLOR or NORMAL_FONT_COLOR;
	self.ContentsContainer.Label:SetTextColor(color:GetRGB());
	self.ArtContainer.SelectedTexture:SetShown(selected);
	self.isSelected = selected;
end

function PerksProgramProductButtonMixin:IsSelected()
	return self.isSelected;
end

function PerksProgramProductButtonMixin:GetItemInfo()
	return self.itemInfo;
end

function PerksProgramProductButtonMixin:IsSameItem(itemInfo)
	return self.itemInfo and self.itemInfo.perksVendorItemID == itemInfo.perksVendorItemID;
end

function PerksProgramProductButtonMixin:UpdateTimeRemainingText()
	self.itemInfo.timeRemaining = C_PerksProgram.GetTimeRemaining(self.itemInfo.perksVendorItemID);

	local text;
	if self.itemInfo.purchased or self.itemInfo.isPurchasePending then
		text = PERKS_PROGRAM_PURCHASED_TIME_REMAINING;
	elseif self.itemInfo.doesNotExpire or self.itemInfo.timeRemaining == 0 then
		text = PERKS_PROGRAM_DOES_NOT_EXPIRE_TIME_REMAINING;
	else
		text = PerksProgramFrame:FormatTimeLeft(self.itemInfo.timeRemaining, PerksProgramFrame.TimeLeftListFormatter);
	end

	self.ContentsContainer.TimeRemaining:SetText(text);
end

function PerksProgramProductButtonMixin:CelebratePurchase(itemInfo)
	if not self:IsSameItem(itemInfo) then
		return;
	end

	self.CelebrateAnimation:Show();
	self.CelebrateAnimation.AlphaInAnimation:Play();
end

function PerksProgramProductButtonMixin:OnProductInfoChanged(itemInfo)
	if not self:IsSameItem(itemInfo) then
		return;
	end

	self:SetItemInfo(itemInfo);
end

function PerksProgramProductButtonMixin:OnAddItemToCart(perksItem)
	if self.itemInfo and perksItem.perksVendorItemID == self.itemInfo.perksVendorItemID then
		self:UpdateCartState(true);
	end
end

function PerksProgramProductButtonMixin:OnRemoveItemFromCart(perksItemID)
	if self.itemInfo and perksItemID == self.itemInfo.perksVendorItemID then
		self:UpdateCartState(false);
	end
end

function PerksProgramProductButtonMixin:OnClearCart()
	self:UpdateCartState(false);
end

function PerksProgramProductButtonMixin:UpdateCartState(isInCart)
	self.isInCart = isInCart;

	local container = self.ContentsContainer;
	local showCartIcon = isInCart and self.itemInfo and not self.isPendingFreezeItem and not self.itemInfo.isFrozen;
	container.Icon:SetShown(not showCartIcon);
	container.CartIcon:SetShown(showCartIcon);
end

----------------------------------------------------------------------------------
-- ProductCartToggleButtonMixin
----------------------------------------------------------------------------------

ProductCartToggleButtonMixin = {};

function ProductCartToggleButtonMixin:OnLoad()
	EventRegistry:RegisterCallback("PerksProgram.AddItemToCart", self.OnAddItemToCart, self);
	EventRegistry:RegisterCallback("PerksProgram.RemoveItemFromCart", self.OnRemoveItemFromCart, self);
	EventRegistry:RegisterCallback("PerksProgram.ClearCart", self.OnClearCart, self);

	self.perksVendorItemInfo = {};
end

function ProductCartToggleButtonMixin:OnAddItemToCart(perksItem)
	if perksItem.perksVendorItemID == self.perksVendorItemInfo.perksVendorItemID then
		self:UpdateCartState(true);
	end
end

function ProductCartToggleButtonMixin:OnRemoveItemFromCart(perksItemID)
	if perksItemID == self.perksVendorItemInfo.perksVendorItemID then
		self:UpdateCartState(false);
	end
end

function ProductCartToggleButtonMixin:OnClearCart()
	self:UpdateCartState(false);
end

function ProductCartToggleButtonMixin:UpdateCartState(itemInCart)
	self.itemInCart = itemInCart;

	local textureKit = "128-redbutton-cart-" .. (itemInCart and "minus" or "add");
	self:SetNormalAtlas(textureKit);
	self:SetPushedAtlas(textureKit.."-pressed");
	self:SetDisabledAtlas(textureKit.."-disabled");
	self:SetHighlightAtlas(textureKit.."-highlight");

	self:UpdateTooltipState();
end

function ProductCartToggleButtonMixin:UpdateTooltipState()
	local tooltip = PerksProgramTooltip;
	if self.mouseOver then
		tooltip:SetOwner(self, "ANCHOR_LEFT", 0, 0);
		GameTooltip_AddHighlightLine(tooltip, self.itemInCart and PERKS_PROGRAM_CART_REMOVE or PERKS_PROGRAM_CART_ADD);
		tooltip:Show();
	end
end

function ProductCartToggleButtonMixin:SetItemInfo(itemInfo, isInCart)
	self.perksVendorItemInfo = itemInfo;
	self:UpdateCartState(isInCart);
end

function ProductCartToggleButtonMixin:OnClick()
	if self.itemInCart then
		EventRegistry:TriggerEvent("PerksProgram.RemoveItemFromCart", self.perksVendorItemInfo.perksVendorItemID);
	else
		EventRegistry:TriggerEvent("PerksProgram.AddItemToCart", self.perksVendorItemInfo);
	end
end

function ProductCartToggleButtonMixin:OnEnter()
	self.mouseOver = true;

	self:UpdateTooltipState();
end

function ProductCartToggleButtonMixin:OnLeave()
	self.mouseOver = false;

	local tooltip = PerksProgramTooltip;
	tooltip:Hide();
 
	self:GetParent():GetParent():UpdateTooltipState();
end

----------------------------------------------------------------------------------
-- PerksProgramFrozenProductButtonMixin
----------------------------------------------------------------------------------
PerksProgramFrozenProductButtonMixin = {};

function PerksProgramFrozenProductButtonMixin:FrozenProductButton_OnLoad()
	-- Frozen products can't be dragged
	self:SetScript("OnDragStart", nil);

	-- Hide TimeRemainingText since we don't show it for frozen items
	self.ContentsContainer.TimeRemaining:Hide();
end

function PerksProgramFrozenProductButtonMixin:Init(onSelectedCallback)
	local onDragStartCallback = nil; -- Frozen products can't be dragged so don't give a OnDragStartCallback
	PerksProgramProductButtonMixin.Init(self, onDragStartCallback);

	self.onSelectedCallback = onSelectedCallback;
end

function PerksProgramFrozenProductButtonMixin:OnClick()
	if self:HasDraggedItemToFreeze() then
		self:SetupFreezeDraggedItem();
		return;
	end

	self:SetSelected(true);
end

function PerksProgramFrozenProductButtonMixin:OnReceiveDrag()
	self:SetupFreezeDraggedItem();
end

function PerksProgramFrozenProductButtonMixin:SetSelected(selected)
	if selected then
		if not self.itemInfo or self.isSelected then
			return;
		end

		self.onSelectedCallback(self.itemInfo);
	end

	PerksProgramProductButtonMixin.SetSelected(self, selected);
end

function PerksProgramFrozenProductButtonMixin:SetItemInfo(itemInfo)
	local currentFrozenVendorItemInfo = PerksProgramFrame:GetFrozenPerksVendorItemInfo();
	local currentPerksVendorItemID = nil;
	if currentFrozenVendorItemInfo then
		currentPerksVendorItemID = currentFrozenVendorItemInfo.perksVendorItemID;
	end

	self.isPendingFreezeItem = itemInfo.perksVendorItemID ~= currentPerksVendorItemID;

	PerksProgramProductButtonMixin.SetItemInfo(self, itemInfo);
	self.ContentsContainer.Icon:Show();
	self.ContentsContainer.Label:Show();

	self:ShowItemFrozen(not self.isPendingFreezeItem);
	self:ShowItemGlow(self.isPendingFreezeItem);

	-- The frozen item UI could be showing an item that is pending to be frozen, but is not yet frozen (needing user confirmation).
	-- In that case, we do not want the text to say that it is currently frozen.
	if not self.isPendingFreezeItem then
		self.ContentsContainer.Label:SetText(format(PERKS_PROGRAM_FROZEN_ITEM_SET, self.itemInfo.name));
	end

	self.FrozenContentContainer.InstructionsText:Hide();
end

function PerksProgramFrozenProductButtonMixin:ClearItemInfo()
	self.itemInfo = nil;
	self.isPendingFreezeItem = false;

	self.CelebrateAnimation:Hide();
	self.CelebrateAnimation.AlphaInAnimation:Stop();

	local container = self.ContentsContainer;
	container.Label:Hide();
	container.PriceContainer:Hide();
	container.RefundIcon:Hide();
	container.PurchasedIcon:Hide();
	container.Icon:Hide();

	self.FrozenContentContainer.InstructionsText:Show();
end

function PerksProgramFrozenProductButtonMixin:HasDraggedItemToFreeze()
	local draggedVendorItemID = C_PerksProgram.GetDraggedPerksVendorItem();
	local frozenVendorItem = PerksProgramFrame:GetFrozenPerksVendorItemInfo();
	return draggedVendorItemID ~= 0 and (not frozenVendorItem or frozenVendorItem.perksVendorItemID ~= draggedVendorItemID);
end

function PerksProgramFrozenProductButtonMixin:SetupFreezeDraggedItem()
	if not self:HasDraggedItemToFreeze() then
		return;
	end

	if PerksProgramFrame:GetServerErrorState() then
		C_PerksProgram.ResetHeldItemDragAndDrop();
		PerksProgramFrame:ShowServerErrorDialog();
		return;
	end

	local draggedVendorItemID = C_PerksProgram.GetDraggedPerksVendorItem();
	local draggedVendorItemInfo = PerksProgramFrame:GetVendorItemInfo(draggedVendorItemID);
	local frozenVendorItem = PerksProgramFrame:GetFrozenPerksVendorItemInfo();

	if draggedVendorItemInfo.isPurchasePending or (frozenVendorItem and frozenVendorItem.isPurchasePending) then
		C_PerksProgram.ResetHeldItemDragAndDrop();
		StaticPopup_Show("PERKS_PROGRAM_ITEM_PROCESSING_ERROR");
		return;
	end

	-- User could trigger an override while the freeze anims are still playing out
	self.FrozenArtContainer.ConfirmedFreezeAnim:Stop();

	-- Update frozen slot to show icon/text of pending new frozen item
	-- Then show a popup asking if we want to override our existing frozen item
	self:SetItemInfo(draggedVendorItemInfo);

	-- If we don't have a frozen vendor item already then just instantly freeze the dragged item
	if not frozenVendorItem then
		self:FreezeDraggedItem();
		return;
	end

	local itemData = {};
	local _, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(frozenVendorItem.itemID);

	itemData.product = frozenVendorItem;
	itemData.link = itemLink;
	itemData.name = frozenVendorItem.name;
	itemData.tooltip = PerksProgramTooltip;
	itemData.texture = itemTexture;

	local colorData = ColorManager.GetColorDataForItemQuality(itemRarity);
	if colorData then
		itemData.color = {colorData.color:GetRGBA()};
	end

	EventRegistry:RegisterCallback("PerksProgram.OnFrozenItemConfirmationHidden", self.OnFrozenItemConfirmationHidden, self);
	EventRegistry:RegisterCallback("PerksProgram.OnFrozenItemConfirmationAccepted", self.FreezeDraggedItem, self);
	EventRegistry:RegisterCallback("PerksProgram.OnFrozenItemConfirmationCanceled", self.CancelPendingFreeze, self);
	EventRegistry:RegisterCallback("PerksProgram.CancelFrozenItemConfirmation", self.CancelPendingFreeze, self);

	StaticPopup_Show("PERKS_PROGRAM_CONFIRM_OVERRIDE_FROZEN_ITEM", nil, nil, itemData);
end

function PerksProgramFrozenProductButtonMixin:CancelPendingFreeze()
	if not self.isPendingFreezeItem then
		return;
	end

	StaticPopup_Hide("PERKS_PROGRAM_CONFIRM_OVERRIDE_FROZEN_ITEM");

	C_PerksProgram.ResetHeldItemDragAndDrop();

	-- Assign old item's icon to OverlayFrozenSlot so it can animate going away
	self.FrozenArtContainer.OverlayFrozenSlot:SetTexture(self.ContentsContainer.Icon:GetTexture());

	local frozenVendorItemInfo = PerksProgramFrame:GetFrozenPerksVendorItemInfo();
	self:SetItemInfo(frozenVendorItemInfo);

	self.FrozenArtContainer.CancelledFreezeAnim:Restart();
end

function PerksProgramFrozenProductButtonMixin:FreezeDraggedItem()
	if not self:HasDraggedItemToFreeze() then
		return;
	end

	self:SetSelected(true);
	self.FrozenArtContainer.ConfirmedFreezeAnim:Restart();
	PlaySound(SOUNDKIT.TRADING_POST_UI_ITEM_LOCKING);

	-- Can't purchase frozen items from the cart
	EventRegistry:TriggerEvent("PerksProgram.RemoveItemFromCart", self.itemInfo.perksVendorItemID);

	C_PerksProgram.SetFrozenPerksVendorItem();
end

-- Only pieces that stay visible once the related animation would be complete.
function PerksProgramFrozenProductButtonMixin:ShowItemGlow(show)
	self.FrozenArtContainer.ItemGlow:SetAlpha(show and 1 or 0);
end

-- Only pieces that stay visible once the related animation would be complete.
function PerksProgramFrozenProductButtonMixin:ShowItemFrozen(show)
	local alpha = show and 1 or 0;
	self.FrozenArtContainer.FrostFrame:SetAlpha(alpha);
	self.FrozenArtContainer.Frost1:SetAlpha(alpha);
	self.FrozenArtContainer.Frost2:SetAlpha(alpha);
	self.FrozenArtContainer.Frost3:SetAlpha(alpha);
end

function PerksProgramFrozenProductButtonMixin:OnFrozenItemConfirmationHidden()
	EventRegistry:UnregisterCallback("PerksProgram.OnFrozenItemConfirmationHidden", self);
	EventRegistry:UnregisterCallback("PerksProgram.CancelFrozenItemConfirmation", self);
	EventRegistry:UnregisterCallback("PerksProgram.OnFrozenItemConfirmationAccepted", self);
	EventRegistry:UnregisterCallback("PerksProgram.OnFrozenItemConfirmationCanceled", self);
end

----------------------------------------------------------------------------------
-- PerksProgramPurchasePendingSpinnerMixin
----------------------------------------------------------------------------------
PerksProgramPurchasePendingSpinnerMixin = {};

function PerksProgramPurchasePendingSpinnerMixin:Init(onEnterCallback, onLeaveCallback)
	self.onEnterCallback = onEnterCallback;
	self.onLeaveCallback = onLeaveCallback;
end

function PerksProgramPurchasePendingSpinnerMixin:OnEnter()
	self.onEnterCallback();

	PerksProgramTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0);
	AddPurchasePendingTooltipLines(PerksProgramTooltip);
	PerksProgramTooltip:Show();
end

function PerksProgramPurchasePendingSpinnerMixin:OnLeave()
	self.onLeaveCallback();

	if PerksProgramTooltip:GetOwner() == self then
		PerksProgramTooltip:Hide();
	end
end

----------------------------------------------------------------------------------
-- PerksProgramButtonMixin
----------------------------------------------------------------------------------
PerksProgramButtonMixin = {};
function PerksProgramButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	if self.perksProgramOnClickMethod then
		PerksProgramFrame[self.perksProgramOnClickMethod](PerksProgramFrame);
	end
end

function PerksProgramButtonMixin:OnEnter()
	-- Inheriting mixins should add a ShowTooltip method for showing their appropriate tooltip
	if self.ShowTooltip then
		self:ShowTooltip(PerksProgramTooltip);
	end
end

function PerksProgramButtonMixin:OnLeave()
	if PerksProgramTooltip:GetOwner() == self then
		PerksProgramTooltip:Hide();
	end
end

----------------------------------------------------------------------------------
-- PerksProgramPurchaseButtonMixin
----------------------------------------------------------------------------------
PerksProgramPurchaseButtonMixin = {};
function PerksProgramPurchaseButtonMixin:OnLoad()
	EventRegistry:RegisterCallback("PerksProgramModel.OnProductSelectedAfterModel", self.UpdateState, self);
	EventRegistry:RegisterCallback("PerksProgram.OnProductPurchasedStateChange", self.UpdateState, self);
	EventRegistry:RegisterCallback("PerksProgram.OnServerErrorStateChanged", self.UpdateState, self);

	self:RegisterEvent("PERKS_PROGRAM_CURRENCY_REFRESH");

	self.spinnerOffset = -3;
	self.spinnerWidth = self.Spinner:GetWidth();

	self.Spinner:SetPoint("RIGHT", self:GetFontString(), "LEFT", self.spinnerOffset, 0);
	self.Spinner:SetDesaturated(true);
end

function PerksProgramPurchaseButtonMixin:OnEvent(event, ...)
	if event == "PERKS_PROGRAM_CURRENCY_REFRESH" then
		self:UpdateState();
	end
end

function PerksProgramPurchaseButtonMixin:ShowTooltip(tooltip)
	tooltip:SetOwner(self, "ANCHOR_LEFT", 0, 0);

	if not self:IsEnabled() then
		local selectedProductInfo  = PerksProgramFrame:GetSelectedProduct();
		if selectedProductInfo and selectedProductInfo.isPurchasePending then
			AddPurchasePendingTooltipLines(tooltip);
		elseif selectedProductInfo and (C_PerksProgram.GetCurrencyAmount() < selectedProductInfo.price) then
			GameTooltip_AddNormalLine(tooltip, PERKS_PROGRAM_NOT_ENOUGH_CURRENCY, wrap);
		else
			GameTooltip_AddHighlightLine(tooltip, PERKS_PROGRAM_PURCHASING_UNAVAILABLE, wrap);
		end
	else
		GameTooltip_AddHighlightLine(tooltip, PERKS_PROGRAM_PURCHASE);
	end

	tooltip:Show();
end

function PerksProgramPurchaseButtonMixin:UpdateState()
	local selectedProductInfo  = PerksProgramFrame:GetSelectedProduct();

	local isPurchasePending = selectedProductInfo and selectedProductInfo.isPurchasePending;
	self:SetText(isPurchasePending and PERKS_PROGRAM_PENDING or "");
	self.Spinner:SetShown(isPurchasePending);

	local textFrame = self:GetFontString();
	textFrame:ClearAllPoints();
	if self.Spinner:IsShown() then
		-- Center the text and the spinner
		local extraOffset = -6; -- Noticed it looks better with this extra offset. This is probably due to spinner art having extra padding in it's textures.
		textFrame:SetPoint("CENTER", self, "CENTER", self.spinnerWidth + self.spinnerOffset + extraOffset, 0);
	else
		textFrame:SetPoint("CENTER", self, "CENTER");
	end

	local hasErrorOccurred = PerksProgramFrame:GetServerErrorState();
	local hasEnoughCurrency = selectedProductInfo and (C_PerksProgram.GetCurrencyAmount() >= selectedProductInfo.price);
	local enabled = not hasErrorOccurred and hasEnoughCurrency and not isPurchasePending;

	local priceContainer = self.PriceLayoutContainer.PriceContainer;
	local price = selectedProductInfo and selectedProductInfo.price or 0;
	-- In this case we don't currently want to display the original price
	local salePrice = nil;
	priceContainer:Init(price, salePrice);

	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CURRENCY_ID_PERKS_PROGRAM_DISPLAY_INFO);
	self.PriceLayoutContainer.PriceIcon:SetTexture(currencyInfo.iconFileID);

	self.PriceLayoutContainer:SetShown(not isPurchasePending);

	self:SetEnabled(enabled);

	if enabled then
		local offsetX, offsetY, width, height = 23.5, -0.5, nil, 95;
		GlowEmitterFactory:Show(self, GlowEmitterMixin.Anims.GreenGlow, offsetX, offsetY, width, height);
	else
		GlowEmitterFactory:Hide(self);
	end
end

----------------------------------------------------------------------------------
-- PerksProgramRefundButtonMixin
----------------------------------------------------------------------------------
PerksProgramRefundButtonMixin = {};
function PerksProgramRefundButtonMixin:ShowTooltip(tooltip)
	if not self:IsEnabled() then
		tooltip:SetOwner(self, "ANCHOR_LEFT", 0, 0);
		GameTooltip_AddHighlightLine(tooltip, PERKS_PROGRAM_REFUND_UNAVAILABLE, wrap);
		tooltip:Show();
	end
end

----------------------------------------------------------------------------------
-- PerksProgramTruncatedTextTooltipButtonMixin
----------------------------------------------------------------------------------

PerksProgramTruncatedTextTooltipButtonMixin = {};

function PerksProgramTruncatedTextTooltipButtonMixin:ShowTooltip(tooltip)
	local text = self:GetFontString();
	if text:IsTruncated() then
		tooltip:SetOwner(self, "ANCHOR_LEFT", 0, 0);
		GameTooltip_AddHighlightLine(tooltip, text:GetText(), wrap);
		tooltip:Show();
	end
end

function PerksProgramTruncatedTextTooltipButtonMixin:OnSizeChanged(width, height)
	local text = self:GetFontString();

	local margin = 12;
	text:SetWidth(width - margin * 2);
	text:SetHeight(height);
end

----------------------------------------------------------------------------------
-- PerksProgramViewCartButtonMixin
----------------------------------------------------------------------------------

PerksProgramViewCartButtonMixin = {};

function PerksProgramViewCartButtonMixin:ShowTooltip(tooltip)
	tooltip:SetOwner(self, "ANCHOR_LEFT", 0, 0);
	GameTooltip_AddHighlightLine(tooltip, PERKS_PROGRAM_CART_VIEW_TOOLTIP);
	tooltip:Show();
end

----------------------------------------------------------------------------------
-- PerksProgramDividerFrameMixin
----------------------------------------------------------------------------------
PerksProgramDividerFrameMixin = {};
function PerksProgramDividerFrameMixin:OnLoad()
	EventRegistry:RegisterCallback("PerksProgramModel.OnProductSelectedAfterModel", self.OnProductSelectedAfterModel, self);
end

function PerksProgramDividerFrameMixin:OnProductSelectedAfterModel(data)
	local count = data and data.creatureDisplays and #data.creatureDisplays or 0;
	local showDivider = count > 1;
	self:SetShown(showDivider);
end

local function PerksProgramProductDetails_ProcessLines(itemID, perksVendorCategoryID)
	local tooltipLineTypes = { Enum.TooltipDataLineType.RestrictedRaceClass,
								Enum.TooltipDataLineType.RestrictedFaction,
								Enum.TooltipDataLineType.RestrictedSkill,
								Enum.TooltipDataLineType.RestrictedPVPMedal,
								Enum.TooltipDataLineType.RestrictedReputation,
								Enum.TooltipDataLineType.RestrictedLevel, };

	if IsPerksVendorCategoryTransmog(perksVendorCategoryID) then
		table.insert(tooltipLineTypes, Enum.TooltipDataLineType.EquipSlot);
	end

	local result = TooltipUtil.FindLinesFromGetter(tooltipLineTypes, "GetItemByID", itemID);
	if not result then
		return "";
	end

	local equipSlotLines = {};
	local otherLines = {};
	for i, lineData in ipairs(result) do
		if lineData.type == Enum.TooltipDataLineType.EquipSlot then
			if lineData.rightText and lineData.leftText then
				local lineText = lineData.rightText.." ".."("..lineData.leftText..")";
				local color = (lineData.isValidItemType and lineData.isValidInvSlot) and WHITE_FONT_COLOR or RED_FONT_COLOR;
				lineText = color:WrapTextInColorCode(lineText);
				table.insert(equipSlotLines, lineText);
			elseif lineData.leftText then
				local lineText = lineData.leftColor:WrapTextInColorCode(lineData.leftText);
				table.insert(equipSlotLines, lineText);
			end
		else
			if lineData.leftText then
				local lineText = lineData.leftColor:WrapTextInColorCode(lineData.leftText);
				table.insert(otherLines, lineText);
			end
		end
	end

	local description = "\n";
	local function AddLinesToDescription(linesTable)
		for index, lineText in ipairs(linesTable) do
			description = description.."\n"..lineText;
		end
	end
	AddLinesToDescription(otherLines);
	AddLinesToDescription(equipSlotLines);
	return description;
end

----------------------------------------------------------------------------------
-- PerksProgramItemDetailsListMixin
----------------------------------------------------------------------------------

PerksProgramItemDetailsListMixin = {};

local function ConvertInvTypeToSelectionKey(invType)
	if invType == "INVTYPE_NON_EQUIP_IGNORE" then
		return "SELECTIONTYPE_OTHER";
	end

	if invType == "INVTYPE_SHIELD" or invType == "INVTYPE_WEAPONOFFHAND" or invType == "INVTYPE_HOLDABLE" then
		return "SELECTIONTYPE_OFFHAND";
	end

	if invType == "INVTYPE_2HWEAPON" or invType == "INVTYPE_RANGED" or invType == "INVTYPE_RANGEDRIGHT" or invType == "INVTYPE_THROWN" then
		return "SELECTIONTYPE_TWOHAND";
	end
	
	if invType == "INVTYPE_WEAPON" or invType == "INVTYPE_WEAPONMAINHAND" then
		return "SELECTIONTYPE_MAINHAND";
	end

	return string.gsub(invType, "INVTYPE", "SELECTIONTYPE");
end

local function DeselectItemByType(selectionList, selectionType)
	if selectionList[selectionType] then
		selectionList[selectionType].elementData.selected = false;
		selectionList[selectionType] = nil;
	end
end

local function SelectItem(selectionList, selectionType, itemToSelect)
	if selectionType == "SELECTIONTYPE_TWOHAND" then
		DeselectItemByType(selectionList, "SELECTIONTYPE_OFFHAND");
		DeselectItemByType(selectionList, "SELECTIONTYPE_MAINHAND");
	elseif selectionType == "SELECTIONTYPE_MAINHAND" or selectionType == "SELECTIONTYPE_OFFHAND" then
		DeselectItemByType(selectionList, "SELECTIONTYPE_TWOHAND");
	end

	DeselectItemByType(selectionList, selectionType)
	selectionList[selectionType] = itemToSelect;
end

function PerksProgramItemDetailsListMixin:OnLoad()
	-- Default to 3 if the KV isn't specified
	self.maxItemsToShow = self.maxItemsToShow or 3;

	local DefaultPad = 0;
	local DefaultSpacing = 1;
	local view = CreateScrollBoxListLinearView(DefaultPad, DefaultPad, DefaultPad, DefaultPad, DefaultSpacing);

	local function InitializeSetHeader(frame, setInfo)
		frame:InitHeader(setInfo);
	end

	local function InitializeItem(button, elementData)
		button:InitItem(elementData);
		button:SetScript("OnClick", function(button)
			self:OnItemSelected(button, elementData);
		end);

		-- This is done for special brace textures to stop popping
		if elementData.isSetItem then
			if elementData.isFirstSetItem then
				button.BackgroundTexture:SetPoint("TOPLEFT", button, "TOPLEFT", 0, -button.topMargin);
				button:SetHitRectInsets(0, 0, button.topMargin, 0);
			elseif elementData.isLastSetItem then
				button.BackgroundTexture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, button.bottomMargin);
				button:SetHitRectInsets(0, 0, 0, button.bottomMargin);
			end
		end
	end

	local function GetElementInitInfo(elementData)
		if elementData.isEnsembleHeaderInfo then
			return "PerksProgramSetDetailsScrollHeaderTemplate", InitializeSetHeader;
		elseif elementData.isItemInfo then
			local itemTemplate = "PerksProgramCartItemDetailsScrollButtonTemplate";
			if elementData.isSetItem then
				if elementData.isFirstSetItem then
					itemTemplate = "PerksProgramSetItemDetailsScrollButtonWithHeaderTemplate";
				elseif elementData.isLastSetItem then
					itemTemplate = "PerksProgramSetItemDetailsScrollButtonWithFooterTemplate";
				else
					itemTemplate = "PerksProgramSetItemDetailsScrollButtonTemplate";
				end
			end
			
			return itemTemplate, InitializeItem;
		end
	end

	view:SetElementFactory(function(factory, elementData)
		local template, initFunc = GetElementInitInfo(elementData);
		factory(template, initFunc);
	end);

	view:SetElementExtentCalculator(function(dataIndex, elementData)
		local template, _ = GetElementInitInfo(elementData);
		local templateInfo = C_XMLUtil.GetTemplateInfo(template);
		local height = templateInfo.height;
		
		if elementData.isSetItem then
			if elementData.isFirstSetItem then
				height = height + tonumber(templateInfo.keyValues[1]["value"]);
			elseif elementData.isLastSetItem then
				height = height + tonumber(templateInfo.keyValues[1]["value"]);
			end
		end

		return height;
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
end

function PerksProgramItemDetailsListMixin:PopulateItemList()
	-- Should be overriden by children
	self.itemList = {};
end

function PerksProgramItemDetailsListMixin:ClearData()
	self.data = {};
	self.selectedItems = {};
	self.itemList = {};
end

function PerksProgramItemDetailsListMixin:RefreshScrollElements()
	self.ScrollBox:ForEachFrame(function(element, elementData)
		if element.Refresh then
			element:Refresh();
		end
	end);
end

local function SetHasFooter(itemIndex, itemList)
	local lastItem = itemIndex == #itemList;
	if lastItem then
		return false;
	end

	local nextItem = itemList[itemIndex + 1];
	if not nextItem then
		return false;
	end
	local nextItemIsEnsemble = #nextItem.subItems ~= 0 and nextItem.subItemsLoaded;
	return not nextItemIsEnsemble;
end

function PerksProgramItemDetailsListMixin:Init(data)
	self:Show();

	if self.data and self.data.perksVendorItemID == data.perksVendorItemID then
		self:RefreshScrollElements();
		self:UpdateSelectedItems();

		return;
	end

	self.data = data;
	self.selectedItems = {};
	self:PopulateItemList();

	self.allItemsSelectionTypeOther = true;

	local dataProvider = CreateDataProvider();
	for itemIndex, item in ipairs(self.itemList) do
		self:AddItemToList(dataProvider, itemIndex, item);
	end

	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	self:UpdateScrollBar();
	self:RefreshScrollElements();

	if self.allItemsSelectionTypeOther and #self.itemList >= 1 then
		local firstItem = self.itemList[1];
		local firstItemFrame = self.ScrollBox:FindFrameByPredicate(function(_frame, otherElementData)
			return otherElementData.itemID == firstItem.itemID;
		end);
		
		self:OnItemSelected(firstItemFrame, firstItemFrame:GetElementData());
	end
	self.allItemsSelectionTypeOther = false;

	self:UpdateSelectedItems();

	local view = self.ScrollBox:GetView();
	local padding = view:GetPadding();
	local padSize = self.padSize or 12;
	self.spacingSize = self.spacingSize or 8;
	padding:SetTop(4);
	padding:SetLeft(padSize);
	padding:SetRight(padSize);
	padding:SetSpacing(self.spacingSize);
	self.ScrollBox:FullUpdate();
end

function PerksProgramItemDetailsListMixin:AddItemToList(dataProvider, itemIndex, item)
	if item.itemID then
		local isSetItem = self.isSetList;
		if item.perksVendorCategoryID == Enum.PerksVendorCategoryType.Transmogset then
			if #item.subItems ~= 0 and item.subItemsLoaded then
				isSetItem = true;

				local name = item.name;
				local colorData = ColorManager.GetColorDataForItemQuality(item.quality);
				if colorData then
					name = colorData.color:WrapTextInColorCode(item.name);
				end

				local setHeaderData = {
					enabled = true,
					isEnsembleHeaderInfo = true,
					perksVendorItemID = item.perksVendorItemID;
					name = name,
					price = item.price,
					originalPrice = item.originalPrice,
					numSubItems = #item.subItems,
				};
				dataProvider:Insert(setHeaderData);

				for subItemIndex, subItem in ipairs(item.subItems) do
					-- In this case, the top brace is on the header above
					local isFirstSetItem = false;
					local isLastSetItem = subItemIndex == #item.subItems;
					self:AddItemToDataProvider(dataProvider, subItem, isSetItem, isFirstSetItem, isLastSetItem);
				end
			end
		else
			local isFirstSetItem = itemIndex == 1;
			local isLastSetItem = itemIndex == #self.itemList;
			self:AddItemToDataProvider(dataProvider, item, isSetItem, isFirstSetItem, isLastSetItem);
		end
	end
end

function PerksProgramItemDetailsListMixin:UpdateScrollBar()
	-- Makes it so the ScrollBox resizes if there are less than max shown items in the list
	local topItemHeight = self.ScrollBox:GetElementExtent(1);
	local individualItemHeight = self.ScrollBox:GetElementExtent(2);
	local bottomItemHeight = self.ScrollBox:GetElementExtent(#self.itemList);

	local topPad = topItemHeight - individualItemHeight;
	local bottomPad = bottomItemHeight - individualItemHeight;

	local numMiddleItems = #self.itemList - 2;
	local totalScrollHeight = #self.itemList * individualItemHeight + (#self.itemList - 1) * self.spacingSize + individualItemHeight / 4;
	local maxScrollHeight = self.maxItemsToShow * individualItemHeight + (self.maxItemsToShow-1) * self.spacingSize + individualItemHeight / 2;

	totalScrollHeight = totalScrollHeight + topPad + bottomPad;
	maxScrollHeight = maxScrollHeight + topPad + bottomPad;

	self:SetHeight(min(totalScrollHeight, maxScrollHeight));
	if #self.itemList > self.maxItemsToShow then
		self.ScrollBar:Show();
		self.ScrollBox:SetPoint("TOPLEFT", -16, 0);
	else
		self.ScrollBar:Hide();
		self.ScrollBox:SetPoint("TOPLEFT", 0, 0);
	end
end

function PerksProgramItemDetailsListMixin:AddItemToDataProvider(dataProvider, item, isSetItem, isFirstSetItem, isLastSetItem)
	local tooltipLineTypes = { Enum.TooltipDataLineType.EquipSlot, };
	local result = TooltipUtil.FindLinesFromGetter(tooltipLineTypes, "GetItemByID", item.itemID);
	if not result or #result == 0 then
		result = {{ leftText = PerksProgramFrame:GetCategoryText(item.perksVendorCategoryID) }};
	end

	local name = item.name;
	local colorData = ColorManager.GetColorDataForItemQuality(item.quality);
	if colorData then
		name = colorData.color:WrapTextInColorCode(item.name);
	end

	local itemIcon = C_Item.GetItemIconByID(item.itemID);
	local selectionType = ConvertInvTypeToSelectionKey(item.invType);
	local selected = false;
	if selectionType == "SELECTIONTYPE_TWOHAND" then 
		selected = not self.selectedItems["SELECTIONTYPE_TWOHAND"] and not self.selectedItems["SELECTIONTYPE_MAINHAND"] and not self.selectedItems["SELECTIONTYPE_OFFHAND"];
	elseif selectionType == "SELECTIONTYPE_OTHER" then
		-- Don't default select a non-transmog item
		selected = false;
	else
		selected = not self.selectedItems[selectionType];
	end

	if selectionType ~= "SELECTIONTYPE_OTHER" then
		self.allItemsSelectionTypeOther = false;
	end

	local elementData = {
		 enabled = true,
		 isItemInfo = true,
		 isSetItem = isSetItem,
		 isFirstSetItem = isFirstSetItem,
		 isLastSetItem = isLastSetItem,
		 selected = selected,
		 itemName = name,
		 itemSlot = result[1],
		 itemIcon = itemIcon,
		 itemQuality = item.quality,
		 perksVendorItemID = item.perksVendorItemID,
		 perksVendorCategoryID = item.perksVendorCategoryID,
		 itemID = item.itemID,
		 itemModifiedAppearanceID = item.itemModifiedAppearanceID,
		 selectionType = selectionType,
		 price = item.price;
		 originalPrice = item.originalPrice;
	};

	dataProvider:Insert(elementData);

	if selected then
		SelectItem(self.selectedItems, selectionType, { itemID=item.itemID, elementData=elementData });
	end
end

function PerksProgramItemDetailsListMixin:OnItemSelected(element, elementData)
	if element and not element.enabled then
		-- If the override item exists, we want to forward our click to it to disable the override model scene
		local overrideItem = self.selectedItems["SELECTIONTYPE_OTHER"];
		if overrideItem then
			local overrideButton = self.ScrollBox:FindFrameByPredicate(function(frame, otherElementData)
				return otherElementData.itemID == overrideItem.itemID;
			end);
			
			if elementData.itemID ~= overrideItem.elementData.itemID then
				self:OnItemSelected(overrideButton, overrideItem.elementData);
			end

			-- If we're clicking from one other selection type to another, we want to also select the new one, not just deselect the old
			if elementData.selectionType ~= "SELECTIONTYPE_OTHER" then
				return;
			end
		end
	end

	for selectionType, selectedElementData in pairs(self.selectedItems) do
		if selectedElementData.itemID == elementData.itemID then
			if elementData.selected then
				DeselectItemByType(self.selectedItems, selectionType);

				if element then
					element:SetSelected(false);
				end

				self:UpdateSelectedItems();

				return;
			end

			break;
		end
	end

	SelectItem(self.selectedItems, elementData.selectionType, { itemID = elementData.itemID, elementData = elementData });

	if element then
		element:SetSelected(true);
	end

	self:RefreshScrollElements();
	self:UpdateSelectedItems();
end

function PerksProgramItemDetailsListMixin:UpdateSelectedItems()
	local selectedItemModifiedAppearances = {};
	for _, itemData in pairs(self.selectedItems) do
		tinsert(selectedItemModifiedAppearances, itemData.elementData.itemModifiedAppearanceID);
	end

	local perksVendorCategory = self.data and self.data.perksVendorCategoryID or Enum.PerksVendorCategoryType.Transmogset;
	EventRegistry:TriggerEvent("PerksProgram.OnItemSetSelectionUpdated", self.data, perksVendorCategory, selectedItemModifiedAppearances);
end

----------------------------------------------------------------------------------
-- PerksProgramSetDetailsListMixin
----------------------------------------------------------------------------------

PerksProgramSetDetailsListMixin = CreateFromMixins(PerksProgramItemDetailsListMixin);

function PerksProgramSetDetailsListMixin:PopulateItemList()
	self.itemList = self.data.subItems;
	self.isSetList = true;
end

function PerksProgramSetDetailsListMixin:Init(data)
	if not data or #data.subItems == 0 or not data.subItemsLoaded then
		self:ClearData();
		self:Hide();
		return;
	end

	self.spacingSize = 4;
	PerksProgramItemDetailsListMixin.Init(self, data);
end

----------------------------------------------------------------------------------
-- PerksProgramCartDetailsListMixin
----------------------------------------------------------------------------------

PerksProgramCartDetailsListMixin = CreateFromMixins(PerksProgramItemDetailsListMixin);

function PerksProgramCartDetailsListMixin:UpdateScrollBar()
	-- We don't want the parent functionality at all
	local scrollBoxAnchorsWithBar = {
		CreateAnchor("TOPLEFT", 0, 0),
		CreateAnchor("BOTTOMRIGHT", -8, 0);
	};
	local scrollBoxAnchorsWithoutBar = {
		CreateAnchor("TOPLEFT", 0, 0),
		CreateAnchor("BOTTOMRIGHT", 0, 0);
	};
	ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar);
end

function PerksProgramCartDetailsListMixin:PopulateItemList()
	local cartItems = self:GetParent():GetCartItems();
	self.itemList = {};
	for index, item in ipairs(cartItems) do
		table.insert(self.itemList, item);
	end
end

function PerksProgramCartDetailsListMixin:RemoveItemFromList(perksVendorItemID)
	local dataProvider = self.ScrollBox:GetDataProvider();

	local index, elementData = dataProvider:FindByPredicate(function(elementData)
		return elementData.perksVendorItemID == perksVendorItemID;
	end);

	if elementData then
		if elementData.selected then
			self.selectedItems[elementData.selectionType] = nil;
		end

		local numSubItems = elementData.numSubItems;
		if numSubItems then
			for subIndex = index, (index + numSubItems) do
				local subElementData = dataProvider:Find(subIndex);
				if subElementData.selected then
					self.selectedItems[subElementData.selectionType] = nil;
				end
			end
		end

		local itemListIndex = 0;
		for itemIndex, item in ipairs(self.itemList) do
			if item.perksVendorItemID == elementData.perksVendorItemID then
				itemListIndex = itemIndex;
				break;
			end
		end

		local lastIndex = index + (numSubItems and numSubItems or 0);
		dataProvider:RemoveIndexRange(index, lastIndex);

		table.remove(self.itemList, itemListIndex);

		self:UpdateSelectedItems();
	end
end

function PerksProgramCartDetailsListMixin:ClearItemList()
	local dataProvider = self.ScrollBox:GetDataProvider();
	if not dataProvider then
		return;
	end

	dataProvider:RemoveIndexRange(1, dataProvider:GetSize());

	self.selectedItems = {};

	self:UpdateSelectedItems();
end

function PerksProgramCartDetailsListMixin:UpdateSelectedItems()
	local selectedItemModifiedAppearances = {};
	local overrideItem = self.selectedItems["SELECTIONTYPE_OTHER"];
	local overrideData = nil;
	if overrideItem then
		for _, itemData in ipairs(self.itemList) do
			if overrideItem.itemID == itemData.itemID then
				overrideData = CopyTable(itemData);
			end
		end
	else	
		for _, itemData in pairs(self.selectedItems) do
			tinsert(selectedItemModifiedAppearances, itemData.elementData.itemModifiedAppearanceID);
		end
	end

	if not overrideData or self.data then
		for _, itemData in ipairs(self.itemList) do
			if itemData.perksVendorCategoryID == Enum.PerksVendorCategoryType.Transmogset or itemData.perksVendorCategoryID == Enum.PerksVendorCategoryType.Transmog then
				overrideData = CopyTable(itemData);
				overrideData.isCartData = true;

				-- Force default display data in the cart
				overrideData.displayData = self:GetParent():GetTransmogDisplayData();
				break;
			end
		end
	end

	self.ScrollBox:ForEachElementData(function(elementData)
		local overrideData = self.selectedItems["SELECTIONTYPE_OTHER"];
		if overrideData then
			elementData.enabled = overrideData.itemID == elementData.itemID;
		else
			elementData.enabled = true;
		end
	end);

	self.ScrollBox:ForEachFrame(function(element, elementData)
		if element.SetScrollItemDetailsEnabled then
			element:SetScrollItemDetailsEnabled(elementData.enabled);
		end
	end);

	local perksVendorCategory = overrideData;
	if perksVendorCategory then
		perksVendorCategory = overrideData.perksVendorCategoryID;
	else
		if self.data then 
			perksVendorCategory = self.data.perksVendorCategoryID;
		else
			perksVendorCategory = Enum.PerksVendorCategoryType.Transmogset;
		end
	end

	EventRegistry:TriggerEvent("PerksProgram.OnItemSetSelectionUpdated", overrideData or self.data, perksVendorCategory, selectedItemModifiedAppearances);
end

----------------------------------------------------------------------------------
-- PerksProgramDisableableScrollItemMixin
----------------------------------------------------------------------------------

PerksProgramDisableableScrollItemMixin = {}

function PerksProgramDisableableScrollItemMixin:SetScrollItemDetailsEnabled(enabled)
	self.enabled = enabled;

	local alpha = enabled and 1.0 or 0.7;
	local desaturation = enabled and 0.0 or 1.0;

	self:SetAlpha(alpha);
	self:DesaturateHierarchy(desaturation);
	
	if self.RemoveFromCartItemButton then
		-- Never desaturate the remove from cart button
		local removeFromCartDesaturation = 0.0;
		self.RemoveFromCartItemButton:DesaturateHierarchy(removeFromCartDesaturation);
	end

	if self.UpdatePreviewStatusIcon then
		self:UpdatePreviewStatusIcon();
	end
end

----------------------------------------------------------------------------------
-- RemoveFromCartItemButtonContainerMixin
----------------------------------------------------------------------------------

RemoveFromCartItemButtonContainerMixin = {}

function RemoveFromCartItemButtonContainerMixin:OnEnter()
	self.mouseOver = true;
	self.RemoveFromListButton:Show();
end

function RemoveFromCartItemButtonContainerMixin:OnLeave()
	self.mouseOver = false;
	if not self.RemoveFromListButton.mouseOver then
		self.RemoveFromListButton:Hide();
	end
end

----------------------------------------------------------------------------------
-- RemoveFromCartItemButtonMixin
----------------------------------------------------------------------------------

RemoveFromCartItemButtonMixin = {}

function RemoveFromCartItemButtonMixin:OnClick()
	local itemButton = self:GetParent():GetParent();
	EventRegistry:TriggerEvent("PerksProgram.RemoveItemFromCart", itemButton.perksVendorItemID);
end

function RemoveFromCartItemButtonMixin:OnEnter()
	self.mouseOver = true;
end

function RemoveFromCartItemButtonMixin:OnLeave()
	self.mouseOver = false;

	if not self:GetParent().mouseOver then
		self:Hide();
	end
end

----------------------------------------------------------------------------------
-- PerksProgramScrollItemDetailsMixin
----------------------------------------------------------------------------------

PerksProgramScrollItemDetailsMixin = {}

function PerksProgramScrollItemDetailsMixin:InitItem(elementData)
	self:Show();
	self.elementData = elementData;
	self:SetSelected(self.elementData.selected);
	self:SetScrollItemDetailsEnabled(self.elementData.enabled);

	self.Icon:SetTexture(self.elementData.itemIcon);
end

local function GetPreviewAtlasName(selected, hovered, enabled)
	if not enabled then
		return "perks-previewoff";
	end 

	if not selected then
		if hovered then
			return "Perks-PreviewOn-Gray"
		end

		return "perks-previewoff";
	end
	
	if selected and hovered then
		return "Perks-PreviewOn";
	end

	return nil;
end

function PerksProgramScrollItemDetailsMixin:UpdatePreviewStatusIcon()
	self.IconVignette:SetShown(not self.enabled or self.mouseHovered or not self.elementData.selected);
	
	self.PreviewStatusIcon:SetAtlas(GetPreviewAtlasName(self.elementData.selected, self.mouseHovered, self.enabled), TextureKitConstants.UseAtlasSize);

	local showGoldBorder = self.enabled and (self.elementData.selected);
	self.IconBorder:SetAtlas(showGoldBorder and "perks-border-square-gold" or "perks-border-square-gray");
end

function PerksProgramScrollItemDetailsMixin:Refresh()
	self.ItemName:SetText(self.elementData.itemName);
	self:SetScrollItemDetailsEnabled(self.enabled);

	self:UpdatePreviewStatusIcon();
end

function PerksProgramScrollItemDetailsMixin:SetSelected(selected)
	self.elementData.selected = selected;
	self:Refresh();
end

function PerksProgramScrollItemDetailsMixin:OnEnter()
	self.HighlightTexture:Show();

	PerksProgramTooltip:SetOwner(self, "ANCHOR_LEFT", -8, -20);
	local tooltipInfo = CreateBaseTooltipInfo("GetItemByID", self.elementData.itemID);
	tooltipInfo.excludeLines = {
		Enum.TooltipDataLineType.SellPrice,
	};
	PerksProgramTooltip:ProcessInfo(tooltipInfo);
	PerksProgramTooltip:Show();
	
	self.mouseHovered = true;
	self:UpdatePreviewStatusIcon();
end

function PerksProgramScrollItemDetailsMixin:OnLeave()
	self.HighlightTexture:Hide();
	PerksProgramTooltip:Hide();

	self.mouseHovered = false;
	self:UpdatePreviewStatusIcon();
end

----------------------------------------------------------------------------------
-- PerksProgramCartScrollItemDetailsMixin
----------------------------------------------------------------------------------

PerksProgramCartScrollItemDetailsMixin = {};

function PerksProgramCartScrollItemDetailsMixin:InitItem(elementData)
	PerksProgramScrollItemDetailsMixin.InitItem(self, elementData);

	self.perksVendorItemID = elementData.perksVendorItemID;

	local price = elementData.price;
	local salePrice = nil;

	if (elementData.originalPrice) then
		price = elementData.originalPrice;
		salePrice = elementData.price;
	end

	self.PriceContainer:Init(price, salePrice);

	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CURRENCY_ID_PERKS_PROGRAM_DISPLAY_INFO);
	self.PriceIcon:SetTexture(currencyInfo.iconFileID);

	local itemSlot = elementData.itemSlot;
	local leftText = itemSlot.leftText or "";
	local wrapLeftInColor = itemSlot.leftColor and not itemSlot.leftColor:IsRGBEqualTo(WHITE_FONT_COLOR);

	if wrapLeftInColor then
		leftText = itemSlot.leftColor:WrapTextInColorCode(itemSlot.leftText);
	end

	self.ItemSlotLeft:SetText(leftText);

	self.ItemName:SetPoint("TOPRIGHT", self.PriceContainer, "LEFT", -8, 0);
end

----------------------------------------------------------------------------------
-- PerksProgramSetScrollItemDetailsMixin
----------------------------------------------------------------------------------

PerksProgramSetScrollItemDetailsMixin = {};

function PerksProgramSetScrollItemDetailsMixin:InitItem(elementData)
	PerksProgramScrollItemDetailsMixin.InitItem(self, elementData);

	local itemSlot = elementData.itemSlot;
	local leftText = itemSlot.leftText or "";
	local rightText = itemSlot.rightText or "";

	local wrapLeftInColor = itemSlot.leftColor and not itemSlot.leftColor:IsRGBEqualTo(WHITE_FONT_COLOR);
	local wrapRightInColor = itemSlot.rightColor and not itemSlot.rightColor:IsRGBEqualTo(WHITE_FONT_COLOR);

	if wrapLeftInColor then
		leftText = itemSlot.leftColor:WrapTextInColorCode(itemSlot.leftText);
	end
	if wrapRightInColor then
		rightText = itemSlot.rightColor:WrapTextInColorCode(itemSlot.rightText);
	end

	self.ItemSlotLeft:SetText(leftText);
	self.ItemSlotRight:SetText(rightText);
	
	-- Want to reset to the initial widths everytime if it's been overriden once
	if self.initialRightWidth then
		self.ItemSlotRight:SetWidth(self.initialRightWidth);
		self.ItemSlotLeft:SetWidth(self.initialLeftWidth);
	end
	
	-- This code is allowing for the slot text to be longer if only the left or right text exist.
	-- I.E. (- is equivalent to empty space. | is the divide between left and right text)
	-- L&R text: One-hand--- | ----Sword
	-- L text:   One-hand---------------
	-- R text:   ------------------Sword
	if rightText == "" or leftText == "" then
		self.initialRightWidth = self.ItemSlotRight:GetWidth();
		self.initialLeftWidth = self.ItemSlotLeft:GetWidth();
		if rightText == "" then
			self.ItemSlotLeft:SetWidth(self.initialLeftWidth + self.initialRightWidth);
		else
			self.ItemSlotRight:SetWidth(self.initialLeftWidth + self.initialRightWidth);
		end
	end
end

----------------------------------------------------------------------------------
-- PerksProgramSetItemDetailsScrollHeaderMixin
----------------------------------------------------------------------------------

PerksProgramSetItemDetailsScrollHeaderMixin = {};

function PerksProgramSetItemDetailsScrollHeaderMixin:InitHeader(setInfo)
	self.perksVendorItemID = setInfo.perksVendorItemID;
	self.numSubItems = setInfo.numSubItems;
	self.SetName:SetText(setInfo.name);

	local price = setInfo.price;
	local salePrice = nil;

	if (setInfo.originalPrice) then
		price = setInfo.originalPrice;
		salePrice = setInfo.price;
	end

	self.PriceContainer:Init(price, salePrice);

	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CURRENCY_ID_PERKS_PROGRAM_DISPLAY_INFO);
	self.PriceIcon:SetTexture(currencyInfo.iconFileID);

	self:SetScrollItemDetailsEnabled(setInfo.enabled);
end

----------------------------------------------------------------------------------
-- PerksProgramCheckboxMixin
----------------------------------------------------------------------------------
PerksProgramCheckboxMixin = {};

function PerksProgramCheckboxMixin:OnLoad()
	if self.textString then
		self.Text:SetText(self.textString);
	end
end

function PerksProgramCheckboxMixin:OnShow()
	if self.perksProgramOnShowMethod then
		local isChecked = PerksProgramFrame[self.perksProgramOnShowMethod](PerksProgramFrame);
		self:SetChecked(isChecked);
	end
end

function PerksProgramCheckboxMixin:OnClick()
	if self.perksProgramOnClickMethod then
		local isChecked = self:GetChecked();
		PerksProgramFrame[self.perksProgramOnClickMethod](PerksProgramFrame, isChecked);
	end
end

----------------------------------------------------------------------------------
-- PerksProgramToyDetailsFrameMixin
----------------------------------------------------------------------------------
PerksProgramToyDetailsFrameMixin = {};
function PerksProgramToyDetailsFrameMixin:OnLoad()
	EventRegistry:RegisterCallback("PerksProgramModel.OnProductSelectedAfterModel", self.OnProductSelectedAfterModel, self);
end

function PerksProgramToyDetailsFrameMixin:OnShow()
	local newFont = PerksProgramFrame:GetLabelFont();
	self.DescriptionText:SetFontObject(newFont);
end

local restrictions = { Enum.TooltipDataLineType.ToyEffect, Enum.TooltipDataLineType.ToyDescription };
local function PerksProgramToy_ProcessLines(data)
	local result = TooltipUtil.FindLinesFromGetter(restrictions, "GetToyByItemID", data.itemID);
	local toyDescription, toyEffect;
	if result then
		for i, lineData in ipairs(result) do
			if lineData.leftText then
				local restrictionText = lineData.leftText;
				restrictionText = lineData.leftColor:WrapTextInColorCode(restrictionText);
				if lineData.type == Enum.TooltipDataLineType.ToyEffect then
					toyEffect = StripHyperlinks(restrictionText);
				elseif lineData.type == Enum.TooltipDataLineType.ToyDescription then				
					toyDescription = StripHyperlinks(restrictionText);
				end
			end
		end
	end
	return toyDescription, toyEffect;
end

function PerksProgramToyDetailsFrameMixin:OnProductSelectedAfterModel(data)
	self:UpdateDetails(data);
end

function PerksProgramToyDetailsFrameMixin:UpdateDetails(data)
	self.ProductNameText:SetText(data.name);
	
	local _, effectText = PerksProgramToy_ProcessLines(data);
	self.DescriptionText:SetText(effectText);
end

----------------------------------------------------------------------------------
-- PerksProgramProductDetailsFrameMixin
----------------------------------------------------------------------------------
PerksProgramProductDetailsFrameMixin = {};
function PerksProgramProductDetailsFrameMixin:OnLoad()
	EventRegistry:RegisterCallback("PerksProgramModel.OnProductSelectedAfterModel", self.OnProductSelectedAfterModel, self);
	EventRegistry:RegisterCallback("PerksProgram.OnProductInfoChanged", self.OnProductInfoChanged, self);
end

function PerksProgramProductDetailsFrameMixin:OnShow()
	local newFont = PerksProgramFrame:GetLabelFont();
	self.DescriptionText:SetFontObject(newFont);
end

function PerksProgramProductDetailsFrameMixin:SetData(data)
	self.data = data;

	local cartFrame = PerksProgramFrame.ProductsFrame.PerksProgramShoppingCartFrame;
	if not cartFrame:IsShown() then
		if #self.data.subItems > 0 then
			self:GetParent().SetDetailsScrollBoxContainer:Init(self.data);
		else
			self:GetParent().SetDetailsScrollBoxContainer:ClearData();
			self:GetParent().SetDetailsScrollBoxContainer:Hide();
		end
	end

	self:Refresh();
end

function PerksProgramProductDetailsFrameMixin:Refresh()
	if not self.data then
		return;
	end

	self.ProductNameText:SetText(self.data.name);

	local descriptionText;
	local perksVendorCategoryID = self.data.perksVendorCategoryID;
	if perksVendorCategoryID == Enum.PerksVendorCategoryType.Toy then		
		local toyDescription, toyEffect = PerksProgramToy_ProcessLines(self.data);
		if toyDescription and toyEffect then
			descriptionText = GREEN_FONT_COLOR:WrapTextInColorCode(toyEffect).."\n\n"..toyDescription;
		else
			descriptionText = toyDescription;
		end
	else
		local itemID = self.data.itemID;
		descriptionText = self.data.description..PerksProgramProductDetails_ProcessLines(itemID, self.data.perksVendorCategoryID);
	end
	self.DescriptionText:SetText(descriptionText);

	local categoryText = PerksProgramFrame:GetCategoryText(self.data.perksVendorCategoryID);
	if self.data.perksVendorCategoryID == Enum.PerksVendorCategoryType.Mount then
		categoryText = MOUNT_ABILITY_TYPE_FORMAT:format(self.data.mountTypeName, categoryText);
	end
	self.CategoryText:SetText(categoryText);

	local shouldShowTimeRemaining = not (self.data.doesNotExpire or self.data.timeRemaining == 0);
	self.TimeRemaining:SetShown(shouldShowTimeRemaining);
	if shouldShowTimeRemaining then
		local timeRemainingText;
		if self.data.isFrozen then
			timeRemainingText = format(WHITE_FONT_COLOR:WrapTextInColorCode(PERKS_PROGRAM_TIME_LEFT), PERKS_PROGRAM_FROZEN);
		elseif self.data.purchased then
			timeRemainingText = CreateAtlasMarkup("perks-owned-small", 18, 18).." "..GRAY_FONT_COLOR:WrapTextInColorCode(PERKS_PROGRAM_PURCHASED_TEXT);
		else
			local timeToShow = PerksProgramFrame:FormatTimeLeft(self.data.timeRemaining, PerksProgramFrame.TimeLeftDetailsFormatter);
			local timeTextColor = self.timeTextColor or WHITE_FONT_COLOR;
			local timeValueColor = self.timeValueColor or WHITE_FONT_COLOR;	
			timeRemainingText = format(timeTextColor:WrapTextInColorCode(PERKS_PROGRAM_TIME_LEFT), timeValueColor:WrapTextInColorCode(timeToShow));
		end
		self.TimeRemaining:SetText(timeRemainingText);
	end

	self:MarkDirty();
end

function PerksProgramProductDetailsFrameMixin:OnProductSelectedAfterModel(data)
	self:SetData(data);
end

function PerksProgramProductDetailsFrameMixin:OnProductInfoChanged(data)
	if self.data and self.data.perksVendorItemID == data.perksVendorItemID then
		self:SetData(data);
	end
end

----------------------------------------------------------------------------------
-- PerksProgramProductDetailsContainerMixin
----------------------------------------------------------------------------------

PerksProgramProductDetailsContainerMixin = {};

function PerksProgramProductDetailsContainerMixin:OnLoad()
	EventRegistry:RegisterCallback("PerksProgram.UpdateCartShown", self.OnUpdateCartShown, self);
end

function PerksProgramProductDetailsContainerMixin:OnUpdateCartShown(cartShown)
	self:SetShown(not cartShown);
end

----------------------------------------------------------------------------------
-- HeaderSortButtonMixin
----------------------------------------------------------------------------------
HeaderSortButtonMixin = {};
function HeaderSortButtonMixin:OnLoad()
	EventRegistry:RegisterCallback("PerksProgram.SortFieldSet", self.SortFieldSet, self);
	self.labelSet = false;
	if self.iconAtlas then
		self.Icon:Show();
		self.Icon:SetAtlas(self.iconAtlas, true);
	elseif self.labelText then
		self.Label:Show();
		self.Label:SetText(self.labelText);
		self.labelSet = true;
	end
	local color = self.normalColor or NORMAL_FONT_COLOR;
	self:UpdateColor(color);
	local arrowParent = self.labelSet and self.Label or self.Icon;
	self.Arrow:ClearAllPoints();
	self.Arrow:SetPoint("LEFT", arrowParent, "RIGHT", 0, 0);
end

function HeaderSortButtonMixin:UpdateArrow()	
	if self.sortField == PerksProgramFrame:GetSortField() then
		if PerksProgramFrame:GetSortAscending() then
			self.Arrow:SetTexCoord(0, 1, 1, 0);
		else
			self.Arrow:SetTexCoord(0, 1, 0, 1);
		end
		self.Arrow:Show();		
	else
		self.Arrow:Hide();
	end
	self:Layout();
end

function HeaderSortButtonMixin:OnShow()
	self:UpdateArrow();
end

function HeaderSortButtonMixin:SortFieldSet()
	self:UpdateArrow();
end

function HeaderSortButtonMixin:OnClick()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	PerksProgramFrame:SetSortField(self.sortField);
end

function HeaderSortButtonMixin:UpdateColor(color)
	if self.labelSet then
		self.Label:SetTextColor(color:GetRGB());
	else
		self.Icon:SetVertexColor(color:GetRGB());
	end
end

function HeaderSortButtonMixin:OnEnter()
	if not self:IsEnabled() then
		return;
	end

	local color = self.highlightColor or WHITE_FONT_COLOR;
	self:UpdateColor(color);
end

function HeaderSortButtonMixin:OnLeave()
	local color = self.normalColor or NORMAL_FONT_COLOR;
	self:UpdateColor(color);
end

----------------------------------------------------------------------------------
-- PerksModelSceneControlButtonMixin
----------------------------------------------------------------------------------
PerksModelSceneControlButtonMixin = {};
function PerksModelSceneControlButtonMixin:OnLoad()
	if self.iconAtlas then
		self.Icon:SetAtlas(self.iconAtlas, false);
	end	
end

function PerksModelSceneControlButtonMixin:SetModelScene(modelScene)
	self.modelScene = modelScene;
end

function PerksModelSceneControlButtonMixin:OnMouseDown()
	if ( not self.rotationIncrement ) then
		self.rotationIncrement = 0.03;
	end
	
	if self.modelScene then
		self.modelScene:AdjustCameraYaw(self.rotateDirection, self.rotationIncrement);
	end
	PlaySound(SOUNDKIT.IG_INVENTORY_ROTATE_CHARACTER);
	self.Icon:SetPoint("CENTER", 1, -1);
end

function PerksModelSceneControlButtonMixin:OnMouseUp()
	if self.modelScene then
		self.modelScene:StopCameraYaw();
	end
	self.Icon:SetPoint("CENTER", 0, 0);
end

PerksProgramUtil = {};
local firstWeaponCategory = Enum.TransmogCollectionType.Wand;
local lastWeaponCategory = Enum.TransmogCollectionType.Warglaives;
local function IsWeapon(categoryID)
	if categoryID and categoryID >= firstWeaponCategory and categoryID <= lastWeaponCategory then
		return true;
	end
	return false;
end

function PerksProgramUtil.ItemAppearancesHaveSameCategory(itemModifiedAppearanceIDs)
	local firstCategoryID = nil;

	-- weapons have multiple category slots and we want to treat them as a single slot for the purpose of 
	-- iterating over transmog items in a carousel.
	-- Example: a transmog set is all Enum.TransmogCollectionType.Back, we want to return TRUE so this will carousel
	-- or - this transmog set has ALL weapons (but different slots) - we want to return TRUE so this will carousel
	local usingWeaponBucket = false;

	for i, itemModifiedAppearanceID in ipairs(itemModifiedAppearanceIDs) do
		local categoryID = C_TransmogCollection.GetAppearanceSourceInfo(itemModifiedAppearanceID);
		if not firstCategoryID then
			firstCategoryID = categoryID;
			if IsWeapon(firstCategoryID) then
				usingWeaponBucket = true;
			end
		end

		if usingWeaponBucket then
			if not IsWeapon(categoryID) then
				return false;
			end
		else
			if firstCategoryID ~= categoryID then
				return false;
			end
		end
	end
	return true;
end

----------------------------------------------------------------------------------
-- PerksProgramClearCartButtonMixin
----------------------------------------------------------------------------------

PerksProgramClearCartButtonMixin = {};

function PerksProgramClearCartButtonMixin:ShowTooltip(tooltip)
	if self:IsEnabled() then
		tooltip:SetOwner(self, "ANCHOR_LEFT", 0, 0);
		GameTooltip_AddHighlightLine(tooltip, PERKS_PROGRAM_CART_CLEAR_TOOLTIP);
		tooltip:Show();
	end
end

----------------------------------------------------------------------------------
-- PerksProgramPurchaseCartButtonMixin
----------------------------------------------------------------------------------

PerksProgramPurchaseCartButtonMixin = {};

function PerksProgramPurchaseCartButtonMixin:OnLoad()
	EventRegistry:RegisterCallback("PerksProgramModel.OnProductSelectedAfterModel", self.UpdateState, self);
	EventRegistry:RegisterCallback("PerksProgram.OnProductPurchasedStateChange", self.UpdateState, self);
	EventRegistry:RegisterCallback("PerksProgram.OnServerErrorStateChanged", self.UpdateState, self);

	self:RegisterEvent("PERKS_PROGRAM_CURRENCY_REFRESH");

	self.spinnerOffset = -3;
	self.spinnerWidth = self.Spinner:GetWidth();

	self.Spinner:SetPoint("RIGHT", self:GetFontString(), "LEFT", 0, 0);
	self.Spinner:SetDesaturated(true);
end

function PerksProgramPurchaseCartButtonMixin:OnEvent(event, ...)
	if event == "PERKS_PROGRAM_CURRENCY_REFRESH" then
		self:UpdateState();
	end
end

function PerksProgramPurchaseCartButtonMixin:ShowTooltip(tooltip)
	tooltip:SetOwner(self, "ANCHOR_LEFT", 0, 0);

	if not self:IsEnabled() then
		if C_PerksProgram.GetCurrencyAmount() < self:GetParent().totalCartPrice then
			GameTooltip_AddNormalLine(tooltip, PERKS_PROGRAM_NOT_ENOUGH_CURRENCY);
		else
			GameTooltip_AddHighlightLine(tooltip, PERKS_PROGRAM_PURCHASING_UNAVAILABLE);
		end
	else
		GameTooltip_AddHighlightLine(tooltip, PERKS_PROGRAM_CART_PURCHASE_TOOLTIP);
	end

	tooltip:Show();
end

function PerksProgramPurchaseCartButtonMixin:UpdateState()
	local isPurchasePending = false;
	self.Spinner:SetShown(isPurchasePending);
	self.TextContainer:SetShown(not isPurchasePending);

	local hasErrorOccurred = PerksProgramFrame:GetServerErrorState();
	local hasEnoughCurrency = C_PerksProgram.GetCurrencyAmount() >= self:GetParent().totalCartPrice;
	local enabled = not hasErrorOccurred and hasEnoughCurrency and not isPurchasePending;

	self:SetEnabled(enabled);
end

----------------------------------------------------------------------------------
-- PerksProgramShoppingCartMixin
----------------------------------------------------------------------------------

local function CloseCart()
	local showCart = false;
	EventRegistry:TriggerEvent("PerksProgram.UpdateCartShown", showCart);
end

PerksProgramShoppingCartMixin = {};

function PerksProgramShoppingCartMixin:OnLoad()
	self.cartItems = {};

	self.CloseButton:SetScript("OnClick", CloseCart);

	EventRegistry:RegisterCallback("PerksProgram.UpdateCartShown", self.UpdateShown, self);
	EventRegistry:RegisterCallback("PerksProgram.AddItemToCart", self.AddToCart, self);
	EventRegistry:RegisterCallback("PerksProgram.RemoveItemFromCart", self.RemoveFromCart, self);
	EventRegistry:RegisterCallback("PerksProgram.UpdateCart", self.UpdateCart, self);
	EventRegistry:RegisterCallback("PerksProgram.ClearCart", self.ClearCart, self);
end

function PerksProgramShoppingCartMixin:InitCart()
	self.ItemList:Init(nil);
end

function PerksProgramShoppingCartMixin:UpdateShown(showCart)
	if showCart then
		self:InitCart();
		self:Show();
	else
		self:Hide();
	end
end

function PerksProgramShoppingCartMixin:GetCartItems()
	return self.cartItems;
end

function PerksProgramShoppingCartMixin:AddToCart(perksItem)
	-- Don't double add items to the cart
	for index, cartItem in ipairs(self.cartItems) do
		if cartItem.perksVendorItemID == perksItem.perksVendorItemID then
			return;
		end
	end

	table.insert(self.cartItems, perksItem);

	local dataProvider = self.ItemList.ScrollBox:GetDataProvider();
	if self:IsShown() then
		local itemList = self.ItemList.itemList;
		table.insert(itemList, perksItem);

		self.ItemList:AddItemToList(dataProvider, #itemList, perksItem);

		self.ItemList:UpdateSelectedItems();
	end

	EventRegistry:TriggerEvent("PerksProgram.UpdateCart", #self.cartItems);
end

function PerksProgramShoppingCartMixin:RemoveFromCart(perksVendorItemID)
	for index, cartItem in ipairs(self.cartItems) do
		if cartItem.perksVendorItemID == perksVendorItemID then
			table.remove(self.cartItems, index);

			-- Only need to do this if the cart is shown since cart will fully reinit upon showing
			if self:IsShown() then
				self.ItemList:RemoveItemFromList(perksVendorItemID);
			end

			EventRegistry:TriggerEvent("PerksProgram.UpdateCart", #self.cartItems);

			return;
		end
	end
end

function PerksProgramShoppingCartMixin:UpdateCart(numCartItems)
	if numCartItems == 0 then
		CloseCart();
	end

	self.Title:SetText(string.format(PERKS_PROGRAM_CART_TITLE_TEXT, numCartItems));
	
	self:UpdateTotalPrice();

	self.PurchaseCartButton:UpdateState();
end

function PerksProgramShoppingCartMixin:FindItemIndex(perksVendorItemID)
	for index, cartItem in ipairs(self.cartItems) do
		if cartItem.perksVendorItemID == perksVendorItemID then
			return index;
		end
	end

	return -1;
end

function PerksProgramShoppingCartMixin:ClearCart()
	self.cartItems = {};

	self.ItemList:ClearItemList();

	EventRegistry:TriggerEvent("PerksProgram.UpdateCart", #self.cartItems);
end

function PerksProgramShoppingCartMixin:UpdateTotalPrice()
	self.totalCartPrice = 0;
	self.originalTotalCartPrice = 0;

	for _, cartItem in ipairs(self.cartItems) do
		self.totalCartPrice = self.totalCartPrice + cartItem.price;
		self.originalTotalCartPrice = self.originalTotalCartPrice + (cartItem.originalPrice or cartItem.price);
	end

	local textContainer = self.PurchaseCartButton.TextContainer;
	local priceContainer = textContainer.PriceContainer;
	local price = self.totalCartPrice;
	-- In this case we don't currently want to display the original price
	local salePrice = nil;
	priceContainer:Init(price, salePrice);

	local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(Constants.CurrencyConsts.CURRENCY_ID_PERKS_PROGRAM_DISPLAY_INFO);
	textContainer.PriceIcon:SetTexture(currencyInfo.iconFileID);

	textContainer:Layout();
end

function PerksProgramShoppingCartMixin:GetSelectedCategoryID()
	local overrideItem = self.ItemList.selectedItems and self.ItemList.selectedItems["SELECTIONTYPE_OTHER"];
	if overrideItem then
		return overrideItem.elementData.perksVendorCategoryID;
	end

	return Enum.PerksVendorCategoryType.Transmog;
end

function PerksProgramShoppingCartMixin:GetTransmogDisplayData()
	if not self.defaultTransmogDisplayData then
		local perksVendorCategoryID = Enum.PerksVendorCategoryType.Transmog;
		local displayInfo = {
			overrideModelSceneID = nil,
			creatureDisplayInfoID = nil,
			mainHandItemModifiedAppearanceID = nil,
			offHandItemModifiedAppearanceID = nil,
		};
		displayInfo.defaultModelSceneID = PerksProgramFrame:GetDefaultModelSceneID(perksVendorCategoryID);
		-- Force default display data in the cart
		self.defaultTransmogDisplayData = PerksProgram_TranslateDisplayInfo(perksVendorCategoryID, displayInfo)
	end

	return self.defaultTransmogDisplayData;
end
