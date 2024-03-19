-- Perk Program Static Dialogs
local function PerksProgramPurchaseOnAccept(popup)
	PerksProgramFrame:Purchase(popup.data);
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
	OnShow = function(self) EventRegistry:TriggerEvent("PerksProgram.OnFrozenItemConfirmationShown"); end,
	OnAccept = function(self) EventRegistry:TriggerEvent("PerksProgram.OnFrozenItemConfirmationAccepted"); end,
	OnCancel = function(self) EventRegistry:TriggerEvent("PerksProgram.OnFrozenItemConfirmationCanceled"); end,
	OnHide = function(self) EventRegistry:TriggerEvent("PerksProgram.OnFrozenItemConfirmationHidden"); end,
	timeout = 0,
	exclusive = 1,
	hasItemFrame = 1,
	fullScreenCover = true,
	acceptDelay = 5,
};


local function AddPurchasePendingTooltipLines(tooltip)
	GameTooltip_AddHighlightLine(tooltip, PERKS_PROGRAM_PURCHASE_PENDING, wrap);
	GameTooltip_AddNormalLine(tooltip, PERKS_PROGRAM_PURCHASE_IN_PROGRESS, wrap);
end

local function IsPerksVendorCategoryTransmog(perksVendorCategoryID)
	return perksVendorCategoryID == Enum.PerksVendorCategoryType.Transmog or perksVendorCategoryID == Enum.PerksVendorCategoryType.Transmogset;
end

----------------------------------------------------------------------------------
-- PerksProgramProductButtonMixin
----------------------------------------------------------------------------------
PerksProgramProductButtonMixin = {};
function PerksProgramProductButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	EventRegistry:RegisterCallback("PerksProgram.CelebratePurchase", self.CelebratePurchase, self);
	EventRegistry:RegisterCallback("PerksProgram.OnProductInfoChanged", self.OnProductInfoChanged, self);

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
	self.itemInfo = itemInfo;

	self.CelebrateAnimation:Hide();
	self.CelebrateAnimation.AlphaInAnimation:Stop();

	local container = self.ContentsContainer;

	container.Label:SetText(self.itemInfo.name);

	self:UpdateItemPriceElement();
	self:UpdateTimeRemainingText();

	local iconTexture = C_Item.GetItemIconByID(self.itemInfo.itemID);
	container.Icon:SetTexture(iconTexture);
end

function PerksProgramProductButtonMixin:UpdateItemPriceElement()
	if self.itemInfo then
		local price = self.itemInfo.price;
		local playerCurrencyAmount = C_PerksProgram.GetCurrencyAmount();
		if playerCurrencyAmount then
			if self.itemInfo.price > playerCurrencyAmount then
				price = GRAY_FONT_COLOR:WrapTextInColorCode(price);
			else
				price = WHITE_FONT_COLOR:WrapTextInColorCode(price);
			end
		end

		local container = self.ContentsContainer;

		container.Price:SetText(format(PERKS_PROGRAM_PRICE_FORMAT, price, PerksProgramFrame:GetCurrencyIconMarkup()));

		container.Price:SetShown(not self.itemInfo.purchased and not self.itemInfo.refundable and not self.itemInfo.isPurchasePending);
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
		self.tooltip:SetOwner(self, "ANCHOR_RIGHT", -16, 0);
		self.tooltip:SetItemByID(self.itemInfo.itemID);
		self.tooltip:Show();
	end

	self.ContentsContainer.Label:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
	self.ArtContainer.HighlightTexture:Show();

	PlaySound(SOUNDKIT.TRADING_POST_UI_ITEM_HOVER);
end

function PerksProgramProductButtonMixin:OnLeave()
	if not self.isSelected then
		self.ContentsContainer.Label:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	end

	self.ArtContainer.HighlightTexture:Hide();
	self.tooltip:Hide();
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
	container.Price:Hide();
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
	local frozenVendorItem = PerksProgramFrame:GetFrozenPerksVendorItemInfo();
	if not frozenVendorItem then
		self:FreezeDraggedItem();
		return;
	end

	local itemData = {};
	local _, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = C_Item.GetItemInfo(frozenVendorItem.itemID);
	itemData.product = frozenVendorItem;
	itemData.link = itemLink;
	itemData.name = frozenVendorItem.name;
	itemData.color = {ITEM_QUALITY_COLORS[itemRarity].color:GetRGBA()};
	itemData.tooltip = PerksProgramTooltip;
	itemData.texture = itemTexture;

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
-- FilterDropDownContainerMixin
----------------------------------------------------------------------------------
FilterDropDownContainerMixin = {};
function FilterDropDownContainerMixin:OnLoad()
	UIDropDownMenu_Initialize(FilterDropDown, GenerateClosure(self.InitializeDropDown, self), "MENU");
end

local function IsSortAscending()
	return PerksProgramFrame:GetSortAscending();
end

local function SetSortAscending()
	PerksProgramFrame:SetSortAscending(not PerksProgramFrame:GetSortAscending());
	EventRegistry:TriggerEvent("PerksProgram.SortFieldSet");
end

local function IsSortFieldSet(filterInfo)
	return PerksProgramFrame:GetSortField() == filterInfo;
end

local function SetSortField(value, filterInfo)
	PerksProgramFrame:SetSortField(filterInfo);
end

local function SetFilterState(value, filterInfo)
	PerksProgramFrame:SetFilterState(filterInfo, not PerksProgramFrame:GetFilterState(filterInfo));
end

local function IsFilterStateChecked(filterInfo)
	return PerksProgramFrame:GetFilterState(filterInfo);
end

function FilterDropDownContainerMixin:InitializeDropDown(self, level)
	local categories = PerksProgramFrame:GetCategories();
	

	local categoryFilters = {};
	if categories then
		for i, category in ipairs(categories) do
			table.insert(categoryFilters, { type=FilterComponent.Checkbox, filter=category.ID, text=category.displayName, isSet=IsFilterStateChecked, set=function(value) SetFilterState(value, category.ID); end } );
		end
	end
	
	local filterSystem = {
		onUpdate = MountJournalResetFiltersButton_UpdateVisibility,
		filters = {
			{ type=FilterComponent.Checkbox, text=PERKS_PROGRAM_COLLECTED, filter="collected", isSet=IsFilterStateChecked, set=function(value) SetFilterState(value, "collected"); end },
			{ type=FilterComponent.Checkbox, text=PERKS_PROGRAM_NOT_COLLECTED, filter="uncollected", isSet=IsFilterStateChecked, set=function(value) SetFilterState(value, "uncollected"); end },
			{ type=FilterComponent.Checkbox, text=PERKS_PROGRAM_USEABLE_ONLY, filter="useable", isSet=IsFilterStateChecked, set=function(value) SetFilterState(value, "useable"); end },
			{ type=FilterComponent.Space },
			{ type=FilterComponent.Submenu, text=PERKS_PROGRAM_TYPE, value=1, childrenInfo={
					filters = categoryFilters
				}
			},
			{ type=FilterComponent.Submenu, text=PERKS_PROGRAM_SORT_BY, value=2, childrenInfo={ 
					filters = {
						{ type=FilterComponent.Checkbox, text=PERKS_PROGRAM_ASCENDING, isSet=IsSortAscending, set=SetSortAscending},
						{ type=FilterComponent.Space },
						{ type=FilterComponent.Radio, text=PERKS_PROGRAM_NAME, set=function(value) SetSortField(value, "name"); end, isSet=IsSortFieldSet, filter="name" },
						{ type=FilterComponent.Radio, text=PERKS_PROGRAM_PRICE, set=function(value) SetSortField(value, "price"); end, isSet=IsSortFieldSet, filter="price" },
						{ type=FilterComponent.Radio, text=PERKS_PROGRAM_TIME_REMAINING, set=function(value) SetSortField(value, "timeRemaining"); end, isSet=IsSortFieldSet, filter="timeRemaining" },
					}
				}
			},
		},
	};
	FilterDropDownSystem.Initialize(self, filterSystem, level);
end

function FilterDropDownContainerMixin:SetFilterData(options)
	self.options = options;
end

----------------------------------------------------------------------------------
-- FilterDropDownButtonMixin
----------------------------------------------------------------------------------
FilterDropDownButtonMixin = {};
function FilterDropDownButtonMixin:OnMouseDown(button)
	if self:IsEnabled() then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		ToggleDropDownMenu(1, nil, FilterDropDown, self, 74, 15);
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
	if not self:IsEnabled() then
		tooltip:SetOwner(self, "ANCHOR_LEFT", 0, 0);

		local selectedProductInfo  = PerksProgramFrame:GetSelectedProduct();
		if selectedProductInfo and selectedProductInfo.isPurchasePending then
			AddPurchasePendingTooltipLines(tooltip);
		elseif selectedProductInfo and (C_PerksProgram.GetCurrencyAmount() < selectedProductInfo.price) then
			GameTooltip_AddNormalLine(tooltip, PERKS_PROGRAM_NOT_ENOUGH_CURRENCY, wrap);
		else
			GameTooltip_AddHighlightLine(tooltip, PERKS_PROGRAM_PURCHASING_UNAVAILABLE, wrap);
		end

		tooltip:Show();
	end
end

function PerksProgramPurchaseButtonMixin:UpdateState()
	local selectedProductInfo  = PerksProgramFrame:GetSelectedProduct();

	local isPurchasePending = selectedProductInfo and selectedProductInfo.isPurchasePending;
	self:SetText(isPurchasePending and PERKS_PROGRAM_PENDING or PERKS_PROGRAM_PURCHASE);
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

	self:SetEnabled(enabled);

	if enabled then
		GlowEmitterFactory:SetHeight(95);
		GlowEmitterFactory:SetOffset(23.5, -0.5);

		GlowEmitterFactory:Show(self, GlowEmitterMixin.Anims.GreenGlow);
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
-- PerksProgramSetDetailsListMixin
----------------------------------------------------------------------------------

PerksProgramSetDetailsListMixin = {}

local function ConvertInvTypeToSelectionKey(invType)
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

function PerksProgramSetDetailsListMixin:OnLoad()
	local DefaultPad = 0;
	local DefaultSpacing = 1;
	local view = CreateScrollBoxListLinearView(DefaultPad, DefaultPad, DefaultPad, DefaultPad, DefaultSpacing);
	view:SetElementInitializer("PerksProgramDetailsFrameScrollButtonTemplate", function(button, elementData)
		button:InitItem(elementData);
		button:SetScript("OnClick", function(button, buttonName, down)
			self:OnItemSelected(button, elementData);
		end);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);
	--local scrollBoxAnchorsWithBar = {
	--	CreateAnchor("TOPLEFT", -16, 0),
	--	CreateAnchor("BOTTOMRIGHT", 0, 0);
	--};
	--local scrollBoxAnchorsWithoutBar = {
	--	CreateAnchor("TOPLEFT", 0, 0),
	--	CreateAnchor("BOTTOMRIGHT", 0, 0);
	--};
	--ScrollUtil.AddManagedScrollBarVisibilityBehavior(self.ScrollBox, self.ScrollBar, scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar);
end

function PerksProgramSetDetailsListMixin:ClearData()
	self.data = {};
	self.setID = 0;
	self.perksVendorCategoryID = 0;
	self.selectedItems = {};
	self.subItems = {};
end

function PerksProgramSetDetailsListMixin:Init(data)
	if not data or not #data.subItems == 0 or not data.subItemsLoaded then
		self:ClearData();
		self:Hide();
		return;
	end

	self:Show();

	if self.data and self.data.perksVendorItemID == data.perksVendorItemID then
		self:RefreshItems();
		self:UpdateSelectedAppearances();

		return;
	end

	self.data = data;
	self.setID = data.transmogSetID;
	self.perksVendorCategoryID = data.perksVendorCategoryID;
	self.selectedItems = {};
	self.subItems = data.subItems;

	local dataProvider = CreateDataProvider();
	for index, subItem in ipairs(self.subItems) do
		if subItem.itemID then
			local tooltipLineTypes = { Enum.TooltipDataLineType.EquipSlot, };
			local result = TooltipUtil.FindLinesFromGetter(tooltipLineTypes, "GetItemByID", subItem.itemID);
			if result and #result ~= 0 then
				local coloredItemName = ITEM_QUALITY_COLORS[subItem.quality].color:WrapTextInColorCode(subItem.name);
			
				local itemIcon = C_Item.GetItemIconByID(subItem.itemID);
				local selectionType = ConvertInvTypeToSelectionKey(subItem.invType);

				local selected = false;
				if selectionType == "SELECTIONTYPE_TWOHAND" then 
					selected = not self.selectedItems["SELECTIONTYPE_TWOHAND"] and not self.selectedItems["SELECTIONTYPE_MAINHAND"] and not self.selectedItems["SELECTIONTYPE_OFFHAND"];
				else
					selected = not self.selectedItems[selectionType];
				end

				local elementData = {
					 selected = selected,
					 itemName = coloredItemName, 
					 itemSlot = result[1],
					 itemIcon = itemIcon,
					 itemQuality = subItem.quality,
					 itemOverlay = "CosmeticIconFrame",
					 itemID = subItem.itemID,
					 itemModifiedAppearanceID = subItem.itemAppearanceID,
					 selectionType = selectionType,
				};

				dataProvider:Insert(elementData);

				if selected then
					SelectItem(self.selectedItems, selectionType, { itemID=subItem.itemID, elementData=elementData });
				end
			end
		end
	end

	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	-- Makes it so the ScrollBox resizes if there are less than 3 elements in the list
	local individualItemHeight = self.ScrollBox:GetElementExtent(1);
	self:SetHeight(min(#self.subItems * individualItemHeight + #self.subItems, 3 * individualItemHeight + individualItemHeight / 2 + 3));

	if #self.subItems > 3 then
		self.ScrollBar:Show();
		self.ScrollBox:SetPoint("TOPLEFT", -16, 0);
	else
		self.ScrollBar:Hide();
		self.ScrollBox:SetPoint("TOPLEFT", 0, 0);
	end

	self:RefreshItems();
	self:UpdateSelectedAppearances();
end

function PerksProgramSetDetailsListMixin:OnItemSelected(element, elementData)
	for selectionType, selectedElementData in pairs(self.selectedItems) do
		if selectedElementData.itemID == elementData.itemID then
			if elementData.selected then
				self.selectedItems[selectionType] = nil;
				element:SetSelected(false);
				self:UpdateSelectedAppearances();

				return;
			end

			break;
		end
	end

	SelectItem(self.selectedItems, elementData.selectionType, { itemID = elementData.itemID, elementData = elementData });
	element:SetSelected(true);
	self:RefreshItems();
	self:UpdateSelectedAppearances();
end

function PerksProgramSetDetailsListMixin:RefreshItems()
	self.ScrollBox:ForEachFrame(function(element, elementData)
		element:Refresh();
	end);
end

function PerksProgramSetDetailsListMixin:UpdateSelectedAppearances()
	local selectedItemModifiedAppearances = {};
	for _, itemData in pairs(self.selectedItems) do
		tinsert(selectedItemModifiedAppearances, itemData.elementData.itemModifiedAppearanceID);
	end

	EventRegistry:TriggerEvent("PerksProgram.OnItemSetSelectionUpdated", self.data, self.perksVendorCategoryID, selectedItemModifiedAppearances);
end

----------------------------------------------------------------------------------
-- PerksProgramSetDetailsItemMixin
----------------------------------------------------------------------------------
PerksProgramSetDetailsItemMixin = {}

function PerksProgramSetDetailsItemMixin:InitItem(elementData)
	self:Show();
	self.elementData = elementData;
	self:SetSelected(self.elementData.selected);

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

	self.Icon:SetTexture(elementData.itemIcon);
	self.IconBorder:SetAtlas(LOOT_BORDER_BY_QUALITY[elementData.itemQuality] or LOOT_BORDER_BY_QUALITY[Enum.ItemQuality.Uncommon]);
	self.IconOverlay:SetAtlas(elementData.itemOverlay);
end

function PerksProgramSetDetailsItemMixin:Refresh()
	self.SelectedTexture:SetShown(self.elementData.selected);
	self.ItemName:SetText(self.elementData.itemName);
end

function PerksProgramSetDetailsItemMixin:SetSelected(selected)
	self.elementData.selected = selected;
	self:Refresh();
end

function PerksProgramSetDetailsItemMixin:OnEnter()
	self.HighlightTexture:Show();

	PerksProgramTooltip:SetOwner(self, "ANCHOR_LEFT", -8, -20);
	PerksProgramTooltip:SetItemByID(self.elementData.itemID);
	PerksProgramTooltip:Show();
end

function PerksProgramSetDetailsItemMixin:OnLeave()
	self.HighlightTexture:Hide();
	PerksProgramTooltip:Hide();
end

----------------------------------------------------------------------------------
-- PerksDetailsScrollBarMixin
----------------------------------------------------------------------------------

PerksDetailsScrollBarMixin = {}

function PerksDetailsScrollBarMixin:OnShow()
	EventRegistry:TriggerEvent("PerksProgram.SetDetailsScrollShownUpdated", true);
end

function PerksDetailsScrollBarMixin:OnHide()
	EventRegistry:TriggerEvent("PerksProgram.SetDetailsScrollShownUpdated", false);
end

----------------------------------------------------------------------------------
-- PerksDetailsScrollBoxFadeMixin
----------------------------------------------------------------------------------

PerksDetailsScrollBoxFadeMixin = {}

function PerksDetailsScrollBoxFadeMixin:OnLoad()
	EventRegistry:RegisterCallback("PerksProgram.SetDetailsScrollShownUpdated", self.UpdateShown, self);
end

function PerksDetailsScrollBoxFadeMixin:UpdateShown(shown)
	self:SetShown(shown);
end

----------------------------------------------------------------------------------
-- PerksProgramCheckBoxMixin
----------------------------------------------------------------------------------
PerksProgramCheckBoxMixin = {};

function PerksProgramCheckBoxMixin:OnLoad()
	if self.textString then
		self.Text:SetText(self.textString);
	end
end

function PerksProgramCheckBoxMixin:OnShow()
	if self.perksProgramOnShowMethod then
		local isChecked = PerksProgramFrame[self.perksProgramOnShowMethod](PerksProgramFrame);
		self:SetChecked(isChecked);
	end
end

function PerksProgramCheckBoxMixin:OnClick()
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

	if #self.data.subItems > 0 then
		self:GetParent().SetDetailsScrollBoxContainer:Init(self.data);
	else
		self:GetParent().SetDetailsScrollBoxContainer:ClearData();
		self:GetParent().SetDetailsScrollBoxContainer:Hide();
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
	self.CategoryText:SetText(categoryText);

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
