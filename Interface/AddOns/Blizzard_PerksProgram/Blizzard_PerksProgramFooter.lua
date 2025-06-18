----------------------------------------------------------------------------------
-- PerksProgramFooterFrameMixin
----------------------------------------------------------------------------------
PerksProgramFooterFrameMixin = {};

function PerksProgramFooterFrameMixin:OnLoad()
	EventRegistry:RegisterCallback("PerksProgram.OnProductPurchasedStateChange", self.OnProductPurchasedStateChange, self);
	EventRegistry:RegisterCallback("PerksProgramModel.OnProductSelectedAfterModel", self.OnProductSelected, self);
	EventRegistry:RegisterCallback("PerksProgram.OnModelSceneChanged", self.OnModelSceneChanged, self);
	EventRegistry:RegisterCallback("PerksProgram.OnServerErrorStateChanged", self.OnServerErrorStateChanged, self);
	EventRegistry:RegisterCallback("PerksProgram.UpdateCartShown", self.OnShoppingCartVisibilityUpdate, self);
	EventRegistry:RegisterCallback("PerksProgram.UpdateCart", self.UpdateCartButtons, self);
	EventRegistry:RegisterCallback("PerksProgram.OnItemSetSelectionUpdated", self.OnItemSetSelectionUpdated, self);

	self.LeaveButton:SetText(PERKS_PROGRAM_LEAVE:format(CreateAtlasMarkup("perks-backarrow", 8, 13, 0, 0)));
end

local CHECKBOX_PADDING = 22;
local function GetCheckboxCenteringOffset(checkboxes)
	local centeringOffset = 0;
	for _, checkbox in pairs(checkboxes) do
		centeringOffset = centeringOffset + checkbox:GetWidth() + checkbox.Text:GetWidth() - CHECKBOX_PADDING;
	end

	return -centeringOffset / 2;
end

function PerksProgramFooterFrameMixin:OnShoppingCartVisibilityUpdate(cartShown)
	if cartShown then
		self:OnShoppingCartShown();
	end
end

function PerksProgramFooterFrameMixin:OnShoppingCartShown()
	self.selectedProductInfo = nil;

	local shoppingCartShown = true;

	self.PurchaseButton:SetShown(not shoppingCartShown);
	self.RefundButton:SetShown(not shoppingCartShown);

	self.ViewCartButton:SetShown(not shoppingCartShown);
	self.AddToCartButton:SetShown(not shoppingCartShown);
	self.RemoveFromCartButton:SetShown(not shoppingCartShown);

	local historyFrame = self.PurchasedHistoryFrame;
	historyFrame:SetShown(not shoppingCartShown);
	historyFrame.PurchasedText:SetShown(not shoppingCartShown);
	historyFrame.PurchasedIcon:SetShown(not shoppingCartShown);
	historyFrame.RefundText:SetShown(not shoppingCartShown);
	historyFrame.RefundIcon:SetShown(not shoppingCartShown);

	local cartFrame = PerksProgramFrame.ProductsFrame.PerksProgramShoppingCartFrame;
	local categoryID = cartFrame:GetSelectedCategoryID();
	local newProduct = true;
	local displayData = cartFrame:GetTransmogDisplayData();
	self:UpdateMountControls(categoryID, newProduct);
	self:UpdateTransmogControls(categoryID, newProduct, displayData);
end

function PerksProgramFooterFrameMixin:OnItemSetSelectionUpdated(data, perksVendorCategoryID, selectedItems)
	local cartFrame = PerksProgramFrame.ProductsFrame.PerksProgramShoppingCartFrame;
	local newProduct = true;
	self:UpdateMountControls(perksVendorCategoryID, newProduct);
	self:UpdateTransmogControls(perksVendorCategoryID, newProduct, data and data.displayData or {});
end

function PerksProgramFooterFrameMixin:UpdateCartButtons(numCartItems)
	local cartFrame = PerksProgramFrame.ProductsFrame.PerksProgramShoppingCartFrame;
	local cartShown = cartFrame:IsShown();

	if not self.selectedProductInfo then
		return;
	end

	local itemInCart = cartFrame:FindItemIndex(self.selectedProductInfo.perksVendorItemID) ~= -1;
	local cartableItem = not self.selectedProductInfo.isFrozen and not self.selectedProductInfo.purchased and not self.selectedProductInfo.refundable and not self.selectedProductInfo.isPurchasePending;

	numCartItems = numCartItems or #(cartFrame:GetCartItems());
	self.ViewCartButton:SetShown(not cartShown);
	self.ViewCartButton:SetEnabled(numCartItems > 0);
	self.ViewCartButton.ItemCountText:SetText(numCartItems);
	
	self.AddToCartButton:SetShown(not cartShown and cartableItem and not itemInCart);
	self.RemoveFromCartButton:SetShown(not cartShown and cartableItem and itemInCart);
end

function PerksProgramFooterFrameMixin:OnProductSelected(data)
	local newProduct = not self.selectedProductInfo or self.selectedProductInfo.perksVendorItemID ~= data.perksVendorItemID or self.selectedProductInfo.isCartData;
	self.selectedProductInfo = data;

	self:UpdateCartButtons();

	local historyFrame = self.PurchasedHistoryFrame;
	local isPurchased = self.selectedProductInfo.purchased;
	local isRefundable = self.selectedProductInfo.refundable;

	local cartFrame = PerksProgramFrame.ProductsFrame.PerksProgramShoppingCartFrame;
	local cartShown = cartFrame:IsShown();

	self.PurchaseButton:SetShown(not cartShown and not isPurchased);
	self.RefundButton:SetShown(not cartShown and isRefundable);

	historyFrame:SetShown(not cartShown and isPurchased);
	historyFrame.PurchasedText:SetShown(isPurchased and not isRefundable);
	historyFrame.PurchasedIcon:SetShown(isPurchased and not isRefundable);
	historyFrame.RefundText:SetShown(isRefundable);
	historyFrame.RefundIcon:SetShown(isRefundable);

	if isRefundable then
		local refundTimeLeft = PERKS_PROGRAM_REFUND_TIME_LEFT:format(PerksProgramFrame:FormatTimeLeft(C_PerksProgram.GetVendorItemInfoRefundTimeLeft(self.selectedProductInfo.perksVendorItemID), PerksProgramFrame.TimeLeftFooterFormatter));
		historyFrame.RefundText:SetText(refundTimeLeft);
	end

	local categoryID = self.selectedProductInfo.perksVendorCategoryID;
	self:UpdateMountControls(categoryID, newProduct);
	self:UpdateTransmogControls(categoryID, newProduct, data.displayData);
end

function PerksProgramFooterFrameMixin:UpdateMountControls(categoryID, newProduct)
	local showMountCheckboxToggles = categoryID == Enum.PerksVendorCategoryType.Mount;
	self.TogglePlayerPreview:SetShown(showMountCheckboxToggles);

	if newProduct then
		local mountSpecialCheckboxEnabled = C_PerksProgram.IsMountSpecialAnimToggleEnabled();
		local showMountSpecialCheckbox = showMountCheckboxToggles and mountSpecialCheckboxEnabled;
		self.ToggleMountSpecial:SetShown(showMountSpecialCheckbox);
		if showMountSpecialCheckbox then
			self.TogglePlayerPreview:SetPoint("LEFT", self.RotateButtonContainer, "LEFT", GetCheckboxCenteringOffset({self.TogglePlayerPreview, self.ToggleMountSpecial}), 0);
		else
			self.TogglePlayerPreview:SetPoint("LEFT", self.RotateButtonContainer, "LEFT", -18, 0);
		end

		if mountSpecialCheckboxEnabled then
			PerksProgramFrame:SetMountSpecialPreviewOnClick(showMountSpecialCheckbox);
			self.ToggleMountSpecial:SetChecked(showMountSpecialCheckbox);
		else
			PerksProgramFrame:SetMountSpecialPreviewOnClick(false);
			self.ToggleMountSpecial:SetChecked(false);
		end
	end
end

function PerksProgramFooterFrameMixin:UpdateTransmogControls(categoryID, newProduct, displayData)
	local showTransmogCheckboxes = categoryID == Enum.PerksVendorCategoryType.Transmog or categoryID == Enum.PerksVendorCategoryType.Transmogset;
	self.ToggleHideArmor:SetShown(showTransmogCheckboxes);

	local showAttackAnimation = showTransmogCheckboxes and (displayData.animationKitID or (displayData.animation and displayData.animation > 0));
	local attackCheckboxEnabled = C_PerksProgram.IsAttackAnimToggleEnabled();
	if newProduct then
		showAttackAnimation = showAttackAnimation and attackCheckboxEnabled;
		if showAttackAnimation then
			self.ToggleHideArmor:SetPoint("LEFT", self.RotateButtonContainer, "LEFT", GetCheckboxCenteringOffset({self.ToggleHideArmor, self.ToggleAttackAnimation}), 0);
		else
			self.ToggleHideArmor:SetPoint("LEFT", self.RotateButtonContainer, "LEFT", -18, 0);
		end
		self.ToggleAttackAnimation:SetShown(showAttackAnimation);
	end

	if showTransmogCheckboxes then
		local hideArmor = not(displayData.autodress);
		local hideArmorSetting = PerksProgramFrame:GetHideArmorSetting();
		if hideArmorSetting ~= nil then
			hideArmor = hideArmorSetting;
		end
		self.ToggleHideArmor:SetChecked(hideArmor);

		if attackCheckboxEnabled and showAttackAnimation then
			if newProduct then
				PerksProgramFrame:PlayerSetAttackAnimationOnClick(showAttackAnimation);
				self.ToggleAttackAnimation:SetChecked(showAttackAnimation);
			else
				local attackAnimationSetting = PerksProgramFrame:GetAttackAnimationSetting();
				PerksProgramFrame:PlayerSetAttackAnimationOnClick(attackAnimationSetting);
			end
		end
	end
end

function PerksProgramFooterFrameMixin:OnProductPurchasedStateChange(data)
	if self.selectedProductInfo and self.selectedProductInfo.perksVendorItemID == data.perksVendorItemID then
		self:OnProductSelected(data);
	end
end

function PerksProgramFooterFrameMixin:Init()
end

function PerksProgramFooterFrameMixin:OnModelSceneChanged(modelScene)
	local showRotateButtons = modelScene and true or false;
	local buttonContainer = self.RotateButtonContainer;
	buttonContainer.RotateLeftButton:SetModelScene(modelScene);
	buttonContainer.RotateRightButton:SetModelScene(modelScene);
	buttonContainer.RotateLeftButton:SetShown(showRotateButtons);
	buttonContainer.RotateRightButton:SetShown(showRotateButtons);
end

function PerksProgramFooterFrameMixin:OnServerErrorStateChanged()
	local hasErrorOccurred = PerksProgramFrame:GetServerErrorState();
	self.ErrorIndicator:SetShown(hasErrorOccurred);
	self.RefundButton:SetEnabled(not hasErrorOccurred);
end

PerksProgramErrorIndicatorMixin = {};

function PerksProgramErrorIndicatorMixin:OnEnter()
	PerksProgramTooltip:SetOwner(self, "ANCHOR_RIGHT", -5, -5);
	GameTooltip_AddNormalLine(PerksProgramTooltip, PERKS_PROGRAM_ERROR_INDICATOR, wrap);
	PerksProgramTooltip:Show();
end

function PerksProgramErrorIndicatorMixin:OnLeave()
	PerksProgramTooltip:Hide();
end