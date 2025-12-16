
TopUpFlowConstants = 
{
	TestProductIDs = {
		{productID=2023433},
		{productID=2023434},
		{productID=2023435},
		{productID=2023432},
		{productID=2023431},
		{productID=2023436},
	},
}

local ScreenPadding =
{
	Horizontal = 100,
	Vertical = 100,
};

----------------------------------------------------------------------------------
-- CatalogShopTopUpFrameMixin
----------------------------------------------------------------------------------
CatalogShopTopUpFrameMixin = {};
function CatalogShopTopUpFrameMixin:OnLoad()
	if ( C_Glue.IsOnGlueScreen() ) then
		self:SetFrameStrata("FULLSCREEN_DIALOG");
		-- block keys
		self:EnableKeyboard(true);
		self:SetScript("OnKeyDown",
			function(self, key)
				if ( key == "ESCAPE" ) then
					CatalogShopTopUpFrame:SetAttribute("action", "EscapePressed");
				end
			end
		);
	end

	self.onCloseCallback = function()
		self:Hide();
		return false;
	end;
end

function CatalogShopTopUpFrameMixin:OnEvent(event, ...)
end

function CatalogShopTopUpFrameMixin:OnShow()
	self:SetAttribute("isshown", true);

	self.TopUpProductContainerFrame:Init();
	if C_Glue.IsOnGlueScreen() then
		FrameUtil.SetParentMaintainRenderLayering(self, CatalogShopFrame);
		self:SetFrameStrata("FULLSCREEN_DIALOG", CatalogShopFrame:GetFrameLevel() + 100)
	end
	self:ShowCoverFrame();
	FrameUtil.UpdateScaleForFitSpecific(self, self:GetWidth() + ScreenPadding.Horizontal, self:GetHeight() + ScreenPadding.Vertical);
end

function CatalogShopTopUpFrameMixin:OnHide()
	self:SetAttribute("isshown", false);

	local scrollBox = self.TopUpProductContainerFrame.ScrollBox;
	if scrollBox then
		scrollBox:FlushDataProvider();
		self.TopUpProductContainerFrame:SetSelectedProductInfo(nil);
	end
	self:HideCoverFrame();
	PlaySound(SOUNDKIT.CATALOG_SHOP_CLOSE_SHOP);
end

function CatalogShopTopUpFrameMixin:ShowCoverFrame()
	local coverFrameParent = GetAppropriateTopLevelParent();
	self.CoverFrame:ClearAllPoints();
	self.CoverFrame:SetPoint("TOPLEFT", coverFrameParent, "TOPLEFT");
	self.CoverFrame:SetPoint("BOTTOMRIGHT", coverFrameParent, "BOTTOMRIGHT");
	self.CoverFrame:SetShown(true);
end

function CatalogShopTopUpFrameMixin:HideCoverFrame()
	self.CoverFrame:SetShown(false);
end

function CatalogShopTopUpFrameMixin:OnAttributeChanged(name, value)
	--Note - Setting attributes is how the external UI should communicate with this frame. That way their taint won't be spread to this code.
	if ( name == "action" ) then
		if ( value == "Show" ) then
			self:Show();
		elseif ( value == "Hide" ) then
			self:Hide();
		elseif ( value == "EscapePressed" ) then
			local handled = false;
			if ( self:IsShown() ) then
				self:Hide();
				handled = true;
			end
			self:SetAttribute("escaperesult", handled);
		end
	elseif (name == "parentframe") then
		if value then
			FrameUtil.SetParentMaintainRenderLayering(self, value);
		end
	elseif (name == "setdesiredquantity") then
		self.desiredQuantity = tonumber(value);
		if self.desiredQuantity then
			self.PurchaseTotal:SetText(string.format(CATALOG_SHOP_TOPUPFLOW_PURCHASE, self.desiredQuantity));
		end
	elseif (name == "setcurrentbalance") then
		self.currentBalance = tonumber(value);
		if self.currentBalance then
			self.CurrentBalance:SetText(string.format(CATALOG_SHOP_TOPUPFLOW_CURRENT_BALANCE, self.currentBalance));
		end
	end
end

function CatalogShopTopUpFrameMixin:Leave()
	--... handle leaving
	self:Hide();
end

function CatalogShopTopUpFrameMixin:PurchaseProduct(productID)
	local productInfo = C_CatalogShop.GetProductInfo(productID);
	if not productInfo then
		self:Hide();
		return;
	end

	local completelyOwned = productInfo.isFullyOwned;
	if completelyOwned then
		self:OnError(Enum.StoreError.AlreadyOwned, false, "FakeOwned");
	else
		local vcAmount = self:GetVirtualCurrencyAmountForProduct(productInfo.catalogShopProductID);
		local currentBalance = self.currentBalance or 0;
		local desiredQuantity = self.desiredQuantity or 0;

		if currentBalance + vcAmount < desiredQuantity then
			C_CatalogShop.StartHousingVCPurchaseConfirmation(productInfo.catalogShopProductID);
		else
			C_CatalogShop.PurchaseProduct(productInfo.catalogShopProductID);
			self:Hide();
		end
	end
end

function CatalogShopTopUpFrameMixin:GetVirtualCurrencyAmountForProduct(productID)
	local productInfo = C_CatalogShop.GetProductInfo(productID);
	if productInfo and productInfo.virtualCurrencies and #productInfo.virtualCurrencies > 0 then
		local virtualCurrency = productInfo.virtualCurrencies[1];
		if virtualCurrency.currencyCode == Constants.CatalogShopVirtualCurrencyConstants.HEARTHSTEEL_VC_CURRENCY_CODE then
			return virtualCurrency.amount;
		end
	end

	return 0;
end
