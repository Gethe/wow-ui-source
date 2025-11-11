
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
					CatalogShopFrame:SetAttribute("action", "EscapePressed");
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
	if ( not C_Glue.IsOnGlueScreen() ) then

	else

	end
	self:ShowCoverFrame();
	FrameUtil.UpdateScaleForFitSpecific(self, self:GetWidth() + ScreenPadding.Horizontal, self:GetHeight() + ScreenPadding.Vertical);
end

function CatalogShopTopUpFrameMixin:OnHide()
	self:SetAttribute("isshown", false);

	if ( not C_Glue.IsOnGlueScreen() ) then

	else

	end

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

function CatalogShopTopUpFrameMixin:SetContextKey(contextKey)
	self.contextKey = contextKey;
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
	elseif (name == "contextkey") then
		self:SetContextKey(value);
	end
end

function CatalogShopTopUpFrameMixin:Leave()
	--... handle leaving
	self:Hide();
end

function CatalogShopTopUpFrameMixin:PurchaseProduct()
	local productInfo = self:GetSelectedProductInfo();

	local completelyOwned = productInfo.isFullyOwned;
	if completelyOwned then
		self:OnError(Enum.StoreError.AlreadyOwned, false, "FakeOwned");
	elseif C_CatalogShop.PurchaseProduct(productInfo.catalogShopProductID) then

	end
end

function CatalogShopTopUpFrameMixin:OnProductSelected(data)
	local selectedProductInfo = self:GetSelectedProductInfo();
end

function CatalogShopTopUpFrameMixin:GetSelectedProductInfo()
	return self.ProductContainerFrame:GetSelectedProductInfo();
end
