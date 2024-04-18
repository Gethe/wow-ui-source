----------------------------------------------------------------------------------
-- PerksProgramFooterFrameMixin
----------------------------------------------------------------------------------
PerksProgramFooterFrameMixin = {};

function PerksProgramFooterFrameMixin:OnLoad()
	EventRegistry:RegisterCallback("PerksProgram.OnProductPurchasedStateChange", self.OnProductPurchasedStateChange, self);
	EventRegistry:RegisterCallback("PerksProgramModel.OnProductSelectedAfterModel", self.OnProductSelected, self);
	EventRegistry:RegisterCallback("PerksProgram.OnModelSceneChanged", self.OnModelSceneChanged, self);
	EventRegistry:RegisterCallback("PerksProgram.OnServerErrorStateChanged", self.OnServerErrorStateChanged, self);

	self.LeaveButton:SetText(PERKS_PROGRAM_LEAVE:format(CreateAtlasMarkup("perks-backarrow", 8, 13, 0, 0)));
end

local CHECKBOX_PADDING = 22;
local function GetCheckBoxCenteringOffset(checkboxes)
	local centeringOffset = 0;
	for _, checkbox in pairs(checkboxes) do
		centeringOffset = centeringOffset + checkbox:GetWidth() + checkbox.Text:GetWidth() - CHECKBOX_PADDING;
	end

	return -centeringOffset / 2;
end

function PerksProgramFooterFrameMixin:OnProductSelected(data)
	self.selectedProductInfo = data;

	local historyFrame = self.PurchasedHistoryFrame;
	local isPurchased = self.selectedProductInfo.purchased;
	local isRefundable = self.selectedProductInfo.refundable;

	self.PurchaseButton:SetShown(not isPurchased);

	self.RefundButton:SetShown(isRefundable);

	historyFrame:SetShown(isPurchased);
	historyFrame.PurchasedText:SetShown(isPurchased and not isRefundable);
	historyFrame.PurchasedIcon:SetShown(isPurchased and not isRefundable);
	historyFrame.RefundText:SetShown(isRefundable);
	historyFrame.RefundIcon:SetShown(isRefundable);

	if isRefundable then
		local refundTimeLeft = PERKS_PROGRAM_REFUND_TIME_LEFT:format(PerksProgramFrame:FormatTimeLeft(C_PerksProgram.GetVendorItemInfoRefundTimeLeft(self.selectedProductInfo.perksVendorItemID), PerksProgramFrame.TimeLeftFooterFormatter));
		historyFrame.RefundText:SetText(refundTimeLeft);
	end

	local categoryID = self.selectedProductInfo.perksVendorCategoryID;
	local showMountCheckboxToggles = categoryID == Enum.PerksVendorCategoryType.Mount;
	self.TogglePlayerPreview:SetShown(showMountCheckboxToggles);
	self.TogglePlayerPreview:SetPoint("CENTER", self.RotateButtonContainer, "CENTER", GetCheckBoxCenteringOffset({self.TogglePlayerPreview, self.ToggleMountSpecial}), 0);
	
	self.ToggleMountSpecial:SetShown(showMountCheckboxToggles);
	PerksProgramFrame:SetMountSpecialPreviewOnClick(showMountCheckboxToggles);
	self.ToggleMountSpecial:SetChecked(showMountCheckboxToggles);

	local showTransmogCheckBoxes = categoryID == Enum.PerksVendorCategoryType.Transmog or categoryID == Enum.PerksVendorCategoryType.Transmogset;
	self.ToggleHideArmor:SetShown(showTransmogCheckBoxes);

	local displayData = data.displayData;
	local showAttackAnimation = showTransmogCheckBoxes and (displayData.animationKitID or (displayData.animation and displayData.animation > 0));
	
	if showAttackAnimation then
		self.ToggleHideArmor:SetPoint("LEFT", self.RotateButtonContainer, "LEFT", GetCheckBoxCenteringOffset({self.ToggleHideArmor, self.ToggleAttackAnimation}), 0);
	else
		self.ToggleHideArmor:SetPoint("LEFT", self.RotateButtonContainer, "LEFT", -18, 0);
	end
	self.ToggleAttackAnimation:SetShown(showAttackAnimation);

	if showTransmogCheckBoxes then
		local hideArmor = not(self.selectedProductInfo.displayData.autodress);
		local hideArmorSetting = PerksProgramFrame:GetHideArmorSetting();
		if hideArmorSetting ~= nil then
			hideArmor = hideArmorSetting;
		end
		self.ToggleHideArmor:SetChecked(hideArmor);

		PerksProgramFrame:PlayerSetAttackAnimationOnClick(showAttackAnimation);
		self.ToggleAttackAnimation:SetChecked(showAttackAnimation);
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