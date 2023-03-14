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
	OnAccept = function(self) PerksProgramFrame:OverrideFrozenItem(); end,
	OnCancel = function(self) PerksProgramFrame:ResetDragAndDrop(); end,
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
	self.tooltip = PerksProgramFrame.PerksProgramTooltip;
	local newFont = PerksProgramFrame:GetLabelFont();
	self.ContentsContainer.Label:SetFontObject(newFont);
end

function PerksProgramProductButtonMixin:Init(elementData, currencyIconMarkup, isSelected, playerCurrencyAmount)
	local container = self.ContentsContainer;

	self.CelebrateAnimation:Hide();
	self.CelebrateAnimation.AlphaInAnimation:Stop();

	self.perksVendorItemID = elementData.perksVendorItemID;
	container.Label:SetText(elementData.name);

	local price = elementData.price;
	if playerCurrencyAmount then
		if elementData.price > playerCurrencyAmount then
			price = GRAY_FONT_COLOR:WrapTextInColorCode(price);
		else
			price = WHITE_FONT_COLOR:WrapTextInColorCode(price);
		end
	end
	container.Price:SetText(format(PERKS_PROGRAM_PRICE_FORMAT, price, currencyIconMarkup));

	self.purchased = elementData.purchased;
	container.Price:SetShown(not self.purchased);
	container.Purchased:SetShown(self.purchased);

	elementData.timeRemaining = C_PerksProgram.GetTimeRemaining(elementData.perksVendorItemID);
	local endTime = elementData.isFrozen and "" or PerksProgramFrame:FormatTimeLeft(elementData.timeRemaining, PerksProgramFrame.TimeLeftListFormatter);
	container.TimeRemaining:SetText(endTime);
	container.FrozenIcon:SetShown(elementData.isFrozen);

	self.itemID = elementData.itemID;
	local iconTexture = C_Item.GetItemIconByID(self.itemID);
	container.Icon:SetTexture(iconTexture);
	self.isSelected = isSelected;
	self:SetSelection(isSelected);
end

function PerksProgramProductButtonMixin:OnEvent(event, ...)
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
	self.tooltip:SetOwner(self, "ANCHOR_RIGHT", -16, 0);
	self.tooltip:SetItemByID(self.itemID);
	self.tooltip:Show();

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
	if not self.purchased then
		C_PerksProgram.PickupPerksVendorItem(self.perksVendorItemID);
	end
end

function PerksProgramProductButtonMixin:SetSelection(selected)
	local color = selected and WHITE_FONT_COLOR or NORMAL_FONT_COLOR;
	self.ContentsContainer.Label:SetTextColor(color:GetRGB());
	self.ArtContainer.SelectedTexture:SetShown(selected);
	self.isSelected = selected;
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
	local items;

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
	end
	self:SetShown(showCarousel);
end

----------------------------------------------------------------------------------
-- PerksProgramFrameFrozenItemMixin
----------------------------------------------------------------------------------
PerksProgramFrameFrozenItemMixin = {};
function PerksProgramFrameFrozenItemMixin:OnLoad()
	self:RegisterEvent("PERKS_PROGRAM_SET_FROZEN_ITEM");
	self:RegisterEvent("PERKS_PROGRAM_DATA_SPECIFIC_ITEM_REFRESH");
	local frozenVendorItemInfo = C_PerksProgram.GetFrozenPerksVendorItemInfo();
	self:SetupFrozenVendorItem(frozenVendorItemInfo);
end

function PerksProgramFrameFrozenItemMixin:OnEvent(event, ...)
	if event == "PERKS_PROGRAM_DATA_SPECIFIC_ITEM_REFRESH" or event == "PERKS_PROGRAM_SET_FROZEN_ITEM" then
		local updatedVendorItemID = ...;
		local frozenVendorItemInfo = C_PerksProgram.GetFrozenPerksVendorItemInfo();
		self:SetupFrozenVendorItem(frozenVendorItemInfo);
	end
end

function PerksProgramFrameFrozenItemMixin:SetupFrozenVendorItem(frozenVendorItemInfo)
	local itemID = frozenVendorItemInfo and frozenVendorItemInfo.itemID or nil;
	if itemID and itemID > 0 then
		local iconTexture = C_Item.GetItemIconByID(itemID);
		self.FrozenButton.FrozenSlot:SetTexture(iconTexture);
		self.FrozenButton.HighlightTexture:SetTexture(iconTexture);

		-- The frozen item UI could be showing an item that is pending to be frozen, but is not yet frozen (needing user confirmation).
		-- In that case, we do not want the text to say that it is currently frozen.
		local currentFrozenVendorItemInfo = C_PerksProgram.GetFrozenPerksVendorItemInfo();
		local currentFrozenItemID = currentFrozenVendorItemInfo and currentFrozenVendorItemInfo.itemID or nil;
		local frozenText = NORMAL_FONT_COLOR:WrapTextInColorCode(frozenVendorItemInfo.name);
		if itemID == currentFrozenItemID then
			frozenText = format(PERKS_PROGRAM_FROZEN_ITEM_SET, NORMAL_FONT_COLOR:WrapTextInColorCode(frozenVendorItemInfo.name));
			self.FrozenButton:ShowItemFrozen(true);
			self:ShowFreezeBG(true);
		else
			self.FrozenButton:ShowItemFrozen(false);
			self:ShowFreezeBG(false);
		end

		self.Label:SetText(frozenText);
	else
		-- Check to see if we are going from a frozen item to no frozen item.  If so play the 'unfreeze' fx for the transition.
		if self.FrozenButton.itemID then
			self.FrozenButton.UnfrozenSlot:SetTexture(self.FrozenButton.FrozenSlot:GetTexture());
			self.UnfreezeAnim:Restart();
		else
			self.FrozenButton:ShowItemFrozen(false);
			self:ShowFreezeBG(false);
		end

		self.FrozenButton.FrozenSlot:SetAtlas("perks-slot-empty", TextureKitConstants.UseAtlasSize);
		self.FrozenButton.HighlightTexture:SetAtlas("perks-slot-empty", TextureKitConstants.UseAtlasSize);

		self.Label:SetText(PERKS_PROGRAM_FREEZE_ITEM_INSTRUCTIONS);
	end
	self.FrozenButton.itemID = itemID;
end

function PerksProgramFrameFrozenItemMixin:SetupConfirmOverrideFrozenItem()
	-- User could trigger an override while the freeze anims are still playing out.
	self.FrozenButton.ConfirmedFreezeAnim:Stop();
	self.ConfirmedBackgroundFreezeAnim:Stop();

	self.FrozenButton:ShowItemGlow(true);
	self.FrozenButton:ShowItemFrozen(false);
	self:ShowFreezeBG(false);
	self.PendingFreezeAnim:Restart();

	-- Update frozen slot to show icon/text of potential new frozen item.
	local draggedVendorItemID = C_PerksProgram.GetDraggedPerksVendorItem();
	local draggedVendorItemInfo = C_PerksProgram.GetVendorItemInfo(draggedVendorItemID);
	self:SetupFrozenVendorItem(draggedVendorItemInfo);

	PerksProgramFrame:ConfirmOverrideFrozenItem();
end

function PerksProgramFrameFrozenItemMixin:TriggerFreezeItem()
	self.FrozenButton:ShowItemGlow(false);
	self.FrozenButton.ConfirmedFreezeAnim:Restart();
	self.ConfirmedBackgroundFreezeAnim:Restart();
end

-- Only pieces that stay visible once the related animation would be complete.
function PerksProgramFrameFrozenItemMixin:ShowFreezeBG(show)
	self.FrostBG:SetAlpha(show and .35 or 0);
	self.FrostLabelBG:SetAlpha(show and .22 or 0);
end

----------------------------------------------------------------------------------
-- PerksProgramFrameDragDropMixin
----------------------------------------------------------------------------------
PerksProgramFrameDragDropMixin = {};
function PerksProgramFrameDragDropMixin:OnLoad()
	self:RegisterForDrag("LeftButton");
	self.tooltip = PerksProgramFrame.PerksProgramTooltip;
end

function PerksProgramFrameDragDropMixin:OnEnter()
	if self.itemID then
		self.tooltip:SetOwner(self, "ANCHOR_RIGHT", -16, 0);
		self.tooltip:SetItemByID(self.itemID);
		self.tooltip:Show();
	end
end

function PerksProgramFrameDragDropMixin:OnLeave()
	self.tooltip:Hide();
end

function PerksProgramFrameDragDropMixin:OnClick(button, down)
	self:TriggerConfirmOverrideFrozenItem();
end

function PerksProgramFrameDragDropMixin:OnReceiveDrag()
	self:TriggerConfirmOverrideFrozenItem();
end

function PerksProgramFrameDragDropMixin:TriggerConfirmOverrideFrozenItem()
	local currentFrozenVendorItemInfo = C_PerksProgram.GetFrozenPerksVendorItemInfo();
	local draggedVendorItemID = C_PerksProgram.GetDraggedPerksVendorItem();

	if draggedVendorItemID == 0 then
		return;
	end

	if not currentFrozenVendorItemInfo or currentFrozenVendorItemInfo.itemID ~= draggedVendorItemID then
		PerksProgramFrame.ProductsFrame.ProductsScrollBoxContainer.PerksProgramHoldFrame.FrozenItemFrame:SetupConfirmOverrideFrozenItem();
	end
end

function PerksProgramFrameDragDropMixin:TriggerCancelFrozenItem()
	self:ShowItemGlow(false);
	self.OverlayFrozenSlot:SetTexture(self.FrozenSlot:GetTexture());
	self.CancelledFreezeAnim:Restart();
end

-- Only pieces that stay visible once the related animation would be complete.
function PerksProgramFrameDragDropMixin:ShowItemGlow(show)
	self.ItemGlow:SetAlpha(show and 1 or 0);
end

-- Only pieces that stay visible once the related animation would be complete.
function PerksProgramFrameDragDropMixin:ShowItemFrozen(show)
	local alpha = show and 1 or 0;
	self.FrostFrame:SetAlpha(alpha);
	self.Frost1:SetAlpha(alpha);
	self.Frost2:SetAlpha(alpha);
	self.Frost3:SetAlpha(alpha);
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
-- PerksProgramProductDetailsFrameMixin
----------------------------------------------------------------------------------
PerksProgramProductDetailsFrameMixin = {};
function PerksProgramProductDetailsFrameMixin:OnLoad()
	EventRegistry:RegisterCallback("PerksProgramModel.OnProductSelectedAfterModel", self.OnProductSelectedAfterModel, self);
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

function PerksProgramProductDetailsFrameMixin:OnProductSelectedAfterModel(data)
	self.ProductNameText:SetText(data.name);
	
	local descriptionText = PerksProgramProductDetails_ProcessLines(data);
	self.DescriptionText:SetText(descriptionText);

	local categoryText = PerksProgramFrame:GetCategoryText(data.perksVendorCategoryID);
	self.CategoryText:SetText(categoryText);

	local timeToShow = PerksProgramFrame:FormatTimeLeft(data.timeRemaining, PerksProgramFrame.TimeLeftDetailsFormatter);
	local timeTextColor = self.timeTextColor or WHITE_FONT_COLOR;
	local timeValueColor = self.timeValueColor or WHITE_FONT_COLOR;	
	local timeText = format(timeTextColor:WrapTextInColorCode(PERKS_PROGRAM_TIME_LEFT), timeValueColor:WrapTextInColorCode(timeToShow));
	self.TimeRemaining:SetText(timeText);
	self:MarkDirty();
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
function PerksProgramUtil.ItemAppearancesHaveSameCategory(itemModifiedAppearanceIDs)
	local firstCategoryID = nil;	
	for i, itemModifiedAppearanceID in ipairs(itemModifiedAppearanceIDs) do
		local categoryID = C_TransmogCollection.GetAppearanceSourceInfo(itemModifiedAppearanceID);
		if not firstCategoryID then
			firstCategoryID = categoryID;
		end

		if firstCategoryID ~= categoryID then
			return false;
		end
	end
	return true;
end
