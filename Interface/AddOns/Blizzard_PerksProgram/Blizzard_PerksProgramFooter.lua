----------------------------------------------------------------------------------
-- PerksProgramFooterFrameMixin
----------------------------------------------------------------------------------
PerksProgramFooterFrameMixin = {};
function PerksProgramFooterFrameMixin:OnLoad()
	self:RegisterEvent("PERKS_PROGRAM_CURRENCY_REFRESH");
	EventRegistry:RegisterCallback("PerksProgram.OnProductPurchasedStateChange", self.OnProductSelected, self);
	EventRegistry:RegisterCallback("PerksProgramModel.OnProductSelectedAfterModel", self.OnProductSelected, self);
	EventRegistry:RegisterCallback("PerksProgram.OnModelSceneChanged", self.OnModelSceneChanged, self);
	self.LeaveButton:SetText(PERKS_PROGRAM_LEAVE:format(CreateAtlasMarkup("perks-backarrow", 8, 13, 0, 0)));
end

function PerksProgramFooterFrameMixin:OnShow()
	self:RegisterEvent("PERKS_PROGRAM_CURRENCY_REFRESH");
end

function PerksProgramFooterFrameMixin:OnHide()
	self:UnregisterEvent("PERKS_PROGRAM_CURRENCY_REFRESH");
end

function PerksProgramFooterFrameMixin:OnEvent(event, ...)
	if event == "PERKS_PROGRAM_CURRENCY_REFRESH" then
		local selectedProduct = PerksProgramFrame:GetSelectedProduct();
		self.purchaseButtonEnabled = C_PerksProgram.GetCurrencyAmount() >= selectedProduct.price;
		self.PurchaseButton:SetEnabled(self.purchaseButtonEnabled);
		if self.purchaseButtonEnabled then
			GlowEmitterFactory:SetHeight(95);
			GlowEmitterFactory:SetOffset(23.5, -0.5);

			GlowEmitterFactory:Show(self.PurchaseButton, GlowEmitterMixin.Anims.GreenGlow);
		else
			GlowEmitterFactory:Hide(self.PurchaseButton);
		end
	end
end

function PerksProgramFooterFrameMixin:OnProductSelected(data)

	local historyFrame = self.PurchasedHistoryFrame;
	local isPurchased = data.purchased;
	local isRefundable = isPurchased and data.refundable;

	self.PurchaseButton:SetShown(not isPurchased);
	self.RefundButton:SetShown(isRefundable);
	
	historyFrame:SetShown(isPurchased);
	historyFrame.PurchasedText:SetShown(isPurchased and not isRefundable);
	historyFrame.PurchasedIcon:SetShown(isPurchased and not isRefundable);
	historyFrame.RefundText:SetShown(isRefundable);
	historyFrame.RefundIcon:SetShown(isRefundable);

	if isRefundable then
		local refundTimeLeft = PERKS_PROGRAM_REFUND_TIME_LEFT:format(PerksProgramFrame:FormatTimeLeft(C_PerksProgram.GetVendorItemInfoRefundTimeLeft(data.perksVendorItemID), PerksProgramFrame.TimeLeftFooterFormatter));
		historyFrame.RefundText:SetText(refundTimeLeft);
	end

	local categoryID = data.perksVendorCategoryID;
	local showPlayerPreview = categoryID == Enum.PerksVendorCategoryType.Mount;
	self.TogglePlayerPreview:SetShown(showPlayerPreview);

	local showHideArmor = categoryID == Enum.PerksVendorCategoryType.Transmog or categoryID == Enum.PerksVendorCategoryType.Transmogset;
	self.ToggleHideArmor:SetShown(showHideArmor);
	if showHideArmor then
		local hideArmor = not(data.displayData.autodress);
		local hideArmorSetting = PerksProgramFrame:GetHideArmorSetting();
		if hideArmorSetting ~= nil then
			hideArmor = hideArmorSetting;
		end
		self.ToggleHideArmor:SetChecked(hideArmor);
	end

	self.purchaseButtonEnabled = C_PerksProgram.GetCurrencyAmount() >= data.price;
	self.PurchaseButton:SetEnabled(self.purchaseButtonEnabled);
	if self.purchaseButtonEnabled then
		GlowEmitterFactory:SetHeight(95);
		GlowEmitterFactory:SetOffset(23.5, -0.5);

		GlowEmitterFactory:Show(self.PurchaseButton, GlowEmitterMixin.Anims.GreenGlow);
	else
		GlowEmitterFactory:Hide(self.PurchaseButton);
	end
end

function PerksProgramFooterFrameMixin:OnProductPurchasedStateChange(data)
	self:OnProductSelected(data);
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
