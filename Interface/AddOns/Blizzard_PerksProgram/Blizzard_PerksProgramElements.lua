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
	OnAccept = GenerateClosure(StaticPopup_OnAcceptWithSpinner, PerksProgramPurchaseOnAccept, PerksProgramPurchaseOnEvent, {"PERKS_PROGRAM_PURCHASE_SUCCESS"}),
	timeout = 0,
	exclusive = 1,
	hasItemFrame = 1,
	fullScreenCover = true,
	enterClicksFirstButton = true,
	hideOnEscape = true,
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
	OnAccept = GenerateClosure(StaticPopup_OnAcceptWithSpinner, PerksProgramRefundOnAccept, PerksProgramRefundOnEvent, {"PERKS_PROGRAM_REFUND_SUCCESS"}),
	timeout = 0,
	exclusive = 1,
	hasItemFrame = 1,
	fullScreenCover = true,
	enterClicksFirstButton = true,
	hideOnEscape = true,
};

StaticPopupDialogs["PERKS_PROGRAM_SERVER_ERROR"] = {
	text = PERKS_PROGRAM_SERVER_ERROR,
	button1 = OKAY,
	timeout = 0,
	exclusive = 1,
	fullScreenCover = true,
	enterClicksFirstButton = true,
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
	enterClicksFirstButton = true,
	hideOnEscape = true,
};

----------------------------------------------------------------------------------
-- PerksProgramProductButtonMixin
----------------------------------------------------------------------------------
PerksProgramProductButtonMixin = {};
function PerksProgramProductButtonMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	EventRegistry:RegisterCallback("PerksProgram.CelebratePurchase", self.CelebratePurchase, self);
	EventRegistry:RegisterCallback("PerksProgram.OnProductInfoChanged", self.OnProductInfoChanged, self);

	self.tooltip = PerksProgramFrame.PerksProgramTooltip;
	local newFont = PerksProgramFrame:GetLabelFont();
	self.ContentsContainer.Label:SetFontObject(newFont);
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

	local price = self.itemInfo.price;
	local playerCurrencyAmount = C_PerksProgram.GetCurrencyAmount();
	if playerCurrencyAmount then
		if self.itemInfo.price > playerCurrencyAmount then
			price = GRAY_FONT_COLOR:WrapTextInColorCode(price);
		else
			price = WHITE_FONT_COLOR:WrapTextInColorCode(price);
		end
	end
	container.Price:SetText(format(PERKS_PROGRAM_PRICE_FORMAT, price, PerksProgramFrame:GetCurrencyIconMarkup()));
	container.Price:SetShown(not self.itemInfo.purchased);
	container.RefundIcon:SetShown(self.itemInfo.purchased and self.itemInfo.refundable);
	container.PurchasedIcon:SetShown(self.itemInfo.purchased and not self.itemInfo.refundable);

	self:UpdateTimeRemainingText();

	local iconTexture = C_Item.GetItemIconByID(self.itemInfo.itemID);
	container.Icon:SetTexture(iconTexture);
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
	if self.itemInfo.purchased then
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

	-- User could trigger an override while the freeze anims are still playing out
	self.FrozenArtContainer.ConfirmedFreezeAnim:Stop();

	-- Update frozen slot to show icon/text of pending new frozen item
	-- Then show a popup asking if we want to override our existing frozen item
	local draggedVendorItemID = C_PerksProgram.GetDraggedPerksVendorItem();
	local draggedVendorItemInfo = PerksProgramFrame:GetVendorItemInfo(draggedVendorItemID);
	self:SetItemInfo(draggedVendorItemInfo);

	-- If we don't have a frozen vendor item already then just instantly freeze the dragged item
	local frozenVendorItem = PerksProgramFrame:GetFrozenPerksVendorItemInfo();
	if not frozenVendorItem then
		self:FreezeDraggedItem();
		return;
	end

	local itemData = {};
	local _, itemLink, itemRarity, _, _, _, _, _, _, itemTexture = GetItemInfo(frozenVendorItem.itemID);
	itemData.product = frozenVendorItem;
	itemData.link = itemLink;
	itemData.name = frozenVendorItem.name;
	itemData.color = {ITEM_QUALITY_COLORS[itemRarity].color:GetRGBA()};
	itemData.tooltip = PerksProgramTooltip;
	itemData.texture = itemTexture;

	EventRegistry:RegisterCallback("PerksProgram.OnFrozenItemConfirmationHidden", self.OnFrozenItemConfirmationHidden, self);
	EventRegistry:RegisterCallback("PerksProgram.CancelFrozenItemConfirmation", self.CancelFrozenItemConfirmation, self);
	EventRegistry:RegisterCallback("PerksProgram.OnFrozenItemConfirmationAccepted", self.OnFrozenItemConfirmationAccepted, self);
	EventRegistry:RegisterCallback("PerksProgram.OnFrozenItemConfirmationCanceled", self.OnFrozenItemConfirmationCanceled, self);

	StaticPopup_Show("PERKS_PROGRAM_CONFIRM_OVERRIDE_FROZEN_ITEM", nil, nil, itemData);
end

function PerksProgramFrozenProductButtonMixin:CancelPendingFreeze()
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

function PerksProgramFrozenProductButtonMixin:CancelFrozenItemConfirmation()
	StaticPopup_Hide("PERKS_PROGRAM_CONFIRM_OVERRIDE_FROZEN_ITEM");

	self:CancelPendingFreeze();
end

function PerksProgramFrozenProductButtonMixin:OnFrozenItemConfirmationAccepted()
	self:FreezeDraggedItem();
end

function PerksProgramFrozenProductButtonMixin:OnFrozenItemConfirmationCanceled()
	self:CancelPendingFreeze();
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

PerksProgramPurchaseButtonMixin = CreateFromMixins(PerksProgramButtonMixin);
function PerksProgramPurchaseButtonMixin:OnLoad()
	self.tooltip = PerksProgramFrame.PerksProgramTooltip;
end

function PerksProgramPurchaseButtonMixin:OnEnter()
	if not self:IsEnabled() then
		self.tooltip:SetOwner(self, "ANCHOR_LEFT", 0, 0);
		GameTooltip_AddNormalLine(self.tooltip, PERKS_PROGRAM_NOT_ENOUGH_CURRENCY, wrap);
		self.tooltip:Show();
	end
end

function PerksProgramPurchaseButtonMixin:OnLeave()
	self.tooltip:Hide();
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

----------------------------------------------------------------------------------
-- PerksProgramCarouselFrameMixin
----------------------------------------------------------------------------------
PerksProgramCarouselFrameMixin = {};
function PerksProgramCarouselFrameMixin:OnLoad()
	EventRegistry:RegisterCallback("PerksProgramModel.OnProductSelectedAfterModel", self.OnProductSelectedAfterModel, self);

	local function OnCarouselButtonClick(button, buttonName, down)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		self.carouselIndex = self.carouselIndex + button.incrementAmount;
		self.carouselIndex = Clamp(self.carouselIndex, 1, #self.items);
		self:UpdateCarousel();
		EventRegistry:TriggerEvent("PerksProgram.OnCarouselUpdated", self.data, self.perksVendorCategoryID, self.carouselIndex);
	end
	self.IncrementButton.incrementAmount = 1;
	self.IncrementButton:SetScript("OnClick", OnCarouselButtonClick );
	self.DecrementButton.incrementAmount = -1;
	self.DecrementButton:SetScript("OnClick", OnCarouselButtonClick );
end

function PerksProgramCarouselFrameMixin:OnProductSelectedAfterModel(data)	
	local perksVendorCategoryID = data.perksVendorCategoryID;
	local items = nil;

	if perksVendorCategoryID == Enum.PerksVendorCategoryType.Mount then
		items = data.creatureDisplays;
	elseif perksVendorCategoryID == Enum.PerksVendorCategoryType.Pet then
		items = nil; -- not yet
	elseif perksVendorCategoryID == Enum.PerksVendorCategoryType.Toy then
		items = nil; -- not yet
	elseif perksVendorCategoryID == Enum.PerksVendorCategoryType.Transmog or perksVendorCategoryID == Enum.PerksVendorCategoryType.Transmogset then
		local itemModifiedAppearanceIDs = data and C_TransmogSets.GetAllSourceIDs(data.transmogSetID);
		if itemModifiedAppearanceIDs and PerksProgramUtil.ItemAppearancesHaveSameCategory(itemModifiedAppearanceIDs) then				
			items = itemModifiedAppearanceIDs;
		end
	end
	self:SetCarouselItems(data, items, perksVendorCategoryID);
end

function PerksProgramCarouselFrameMixin:UpdateCarouselText()
	local carouselText = format(PERKS_PROGRAM_CAROUSEL_INDEX, self.carouselIndex, #self.items);
	self.CarouselText:SetText(carouselText);
end

function PerksProgramCarouselFrameMixin:UpdateCarouselButtons()
	local count = #self.items;
	local enablePreviousButton = self.carouselIndex > 1;
	local enableNextButton = self.carouselIndex < count;
	self.DecrementButton:SetEnabled(enablePreviousButton);
	self.IncrementButton:SetEnabled(enableNextButton);
end

function PerksProgramCarouselFrameMixin:UpdateCarousel()
	self:UpdateCarouselText();
	self:UpdateCarouselButtons();
end

function PerksProgramCarouselFrameMixin:SetCarouselItems(data, items, perksVendorCategoryID)
	self.carouselIndex = 1;	
	self.data = data;
	self.items = items;
	self.perksVendorCategoryID = perksVendorCategoryID;
	local count = items and #items or 0;
	local showCarousel = count > 1;

	if showCarousel then
		self:UpdateCarousel();
		EventRegistry:TriggerEvent("PerksProgram.OnCarouselUpdated", self.data, self.perksVendorCategoryID, self.carouselIndex);
	end
	self:SetShown(showCarousel);
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

local restrictions = { Enum.TooltipDataLineType.RestrictedRaceClass, Enum.TooltipDataLineType.RestrictedFaction, Enum.TooltipDataLineType.RestrictedSkill,
						Enum.TooltipDataLineType.RestrictedPVPMedal, Enum.TooltipDataLineType.RestrictedReputation, Enum.TooltipDataLineType.RestrictedSpellKnown,
						Enum.TooltipDataLineType.RestrictedLevel, Enum.TooltipDataLineType.EquipSlot};
local function PerksProgramProductDetails_ProcessLines(data)
	local newDescription = data.description;
	local result = TooltipUtil.FindLinesFromGetter(restrictions, "GetItemByID", data.itemID);
	if result then
		for i, lineData in ipairs(result) do
			if lineData.type == Enum.TooltipDataLineType.EquipSlot then

				if not lineData.isValidInvSlot or not lineData.isValidItemType then
					if lineData.rightText and lineData.leftText then
						local slotText = lineData.leftText;
						local itemText = lineData.rightText;

						itemText = lineData.rightColor:WrapTextInColorCode(itemText);
						newDescription = newDescription.."\n"..itemText;

						slotText = "("..slotText..")";
						slotText = lineData.leftColor:WrapTextInColorCode(slotText);
						newDescription = newDescription.." "..slotText;
					end
				end
			else
				if lineData.leftText then
					local restrictionText = lineData.leftText;
					restrictionText = lineData.leftColor:WrapTextInColorCode(restrictionText);
					newDescription = newDescription.."\n\n"..restrictionText;
				end
			end
		end
	end
	return newDescription;
end

function PerksProgramProductDetailsFrameMixin:SetData(data)
	self.data = data;

	self.ProductNameText:SetText(self.data.name);

	local descriptionText;
	local perksVendorCategoryID = self.data.perksVendorCategoryID;
	if perksVendorCategoryID == Enum.PerksVendorCategoryType.Toy then		
		local toyDescription, toyEffect = PerksProgramToy_ProcessLines(self.data);
		if toyDescription and toyEffect then
			descriptionText = toyDescription.."\n\n"..toyEffect;
		else
			descriptionText = toyDescription;
		end
	else
		descriptionText = PerksProgramProductDetails_ProcessLines(self.data);
	end
	self.DescriptionText:SetText(descriptionText);

	local categoryText = PerksProgramFrame:GetCategoryText(self.data.perksVendorCategoryID);
	self.CategoryText:SetText(categoryText);

	if self.data.isFrozen then
		local timeText = format(WHITE_FONT_COLOR:WrapTextInColorCode(PERKS_PROGRAM_TIME_LEFT), PERKS_PROGRAM_FROZEN);
		self.TimeRemaining:SetText(timeText);
	else
		local timeToShow = PerksProgramFrame:FormatTimeLeft(self.data.timeRemaining, PerksProgramFrame.TimeLeftDetailsFormatter);
		local timeTextColor = self.timeTextColor or WHITE_FONT_COLOR;
		local timeValueColor = self.timeValueColor or WHITE_FONT_COLOR;	
		local timeText = format(timeTextColor:WrapTextInColorCode(PERKS_PROGRAM_TIME_LEFT), timeValueColor:WrapTextInColorCode(timeToShow));
		self.TimeRemaining:SetText(timeText);
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
