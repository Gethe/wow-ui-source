---------------
--NOTE - Please do not change this section without talking to Jacob
--We usually don't want to call out of this environment from this file. Calls should usually go through Outbound
local _, tbl = ...;

tbl.SecureCapsuleGet = SecureCapsuleGet;
--Debug
tbl.CreateForbiddenFrame = CreateFrame;
--End debug
setfenv(1, tbl);
----------------

--Future locals
local CurrentGroupIndex = 1;
local CurrentGroupID = nil;
local CurrentProductID = nil;
local ShopFrame;

local function Import(name)
	tbl[name] = SecureCapsuleGet(name);
end

--Imports
--Import("C_PurchaseAPI");
Import("math");

--GlobalStrings
Import("BLIZZARD_STORE");
Import("BLIZZARD_STORE_ON_SALE");
Import("BLIZZARD_STORE_BUY");
Import("BLIZZARD_STORE_PLUS_TAX");
Import("BLIZZARD_STORE_PRODUCT_INDEX");

--Code
function ShopFrame_OnLoad(self)
	ShopFrame = self;	--Save off a reference for us
	self:RegisterEvent("SHOP_PRODUCTS_UPDATED");
	C_PurchaseAPI.GetProductList();

	self.Title:SetText(BLIZZARD_STORE);
	self.Browse.ProductDescription:SetPoint("BOTTOM", self.Browse.QuantitySelection, "TOP", 0, 5);
	self.Browse.BuyButton:SetText(BLIZZARD_STORE_BUY);
	self.Browse.PlusTax:SetText(BLIZZARD_STORE_PLUS_TAX);
end

function ShopFrame_OnEvent(self, event, ...)
	if ( event == "SHOP_PRODUCTS_UPDATED" ) then
		local numGroups = C_PurchaseAPI.GetNumProductGroups();
		if ( numGroups > 0 ) then
			ShopFrameBrowse_InferCurrentIndex(self.Browse);
			ShopFrameBrowse_Update(self.Browse);
			self.Browse:Show();
		else
			--Display something about us not having products
		end
	end
end

function ShopFrameBrowseNextItem_OnClick(self)
	ShopFrameBrowse_Advance(self:GetParent(), 1);
end

function ShopFrameBrowsePrevItem_OnClick(self)
	ShopFrameBrowse_Advance(self:GetParent(), -1);
end

function ShopFrameBrowse_InferCurrentIndex(self)
	for i=1, C_PurchaseAPI.GetNumProductGroups() do
		local id, name, description, icon, normalPrice, currentPrice = C_PurchaseAPI.GetProductGroupInfo(CurrentGroupIndex);
		if ( id == CurrentGroupID ) then
			CurrentGroupIndex = i;
			return;
		end
	end

	--Didn't find anything matching our ID, so just make sure we're in range.
	ShopFrameBrowse_Advance(self, 0);
end

function ShopFrameBrowse_Advance(self, amount)
	local numItems = C_PurchaseAPI.GetNumProductGroups();

	CurrentGroupIndex = CurrentGroupIndex + amount;
	if ( CurrentGroupIndex > numItems ) then
		CurrentGroupIndex = 1;
	elseif ( CurrentGroupIndex < 1 ) then
		CurrentGroupIndex = numItems;
	end

	CurrentProductID = nil;	--Update fills out the product ID with the first value in the group

	ShopFrameBrowse_Update(self)

	self.ProductIndex:SetFormattedText(BLIZZARD_STORE_PRODUCT_INDEX, CurrentGroupIndex, numItems);
end

function ShopFrameBrowse_Update(self)
	local id, name, description, icon = C_PurchaseAPI.GetProductGroupInfo(CurrentGroupIndex);
	CurrentGroupID = id;
	self.ProductName:SetText(name);
	self.ProductDescription:SetText(description);
	self.Icon:SetTexture(icon);

	if ( not CurrentProductID ) then
		CurrentProductID = C_PurchaseAPI.GetProductInfo(id, 1);
	end
	ShopFrameBrowse_UpdateQuantitySelection(self);
end

function ShopFrameBrowse_SetSale(self, normalPrice, currentPrice)
	self.NormalPriceFrame:Hide();
	
	self.SaleFrame.SalePrice:SetText(currentPrice.."*");
	self.SaleFrame.NormalPrice:SetText(normalPrice);

	self.SaleFrame:Show();
end

function ShopFrameBrowse_SetNormalPrice(self, price)
	self.SaleFrame:Hide();

	self.NormalPriceFrame.Price:SetText(price.."*");

	self.NormalPriceFrame:Show();
end

function ShopFrameBrowse_UpdateQuantitySelection(self)
	local numProducts = C_PurchaseAPI.GetNumProducts(CurrentGroupID);
	local quant = self.QuantitySelection;

	for i=1, numProducts do
		local button = quant.buttons[i];
		if ( not button ) then
			quant.buttons[i] = CreateForbiddenFrame("CheckButton", nil, quant, "ShopQuantitySelectionTemplate");
			button = quant.buttons[i];
			button:SetScript("OnClick", ShopFrameBrowseQuantitySelectButton_OnClick);

			if ( i % 2 == 0 ) then
				button:SetPoint("LEFT", quant.buttons[i-1], "RIGHT", 140, 0);
			else
				button:SetPoint("TOP", quant.buttons[i-2], "BOTTOM", 0, -5);
			end
		end

		local id, title, normalPrice, currentPrice = C_PurchaseAPI.GetProductInfo(CurrentGroupID, i);
		button:SetID(id);
		button.Title:SetText(title);
		button.Price:SetText(currentPrice);
		button:SetChecked(id == CurrentProductID);
		button:SetEnabled(id ~= CurrentProductID);
		button:Show();

		if ( id == CurrentProductID ) then
			if ( normalPrice == currentPrice ) then
				ShopFrameBrowse_SetNormalPrice(self, currentPrice);
			else
				ShopFrameBrowse_SetSale(self, normalPrice, currentPrice);
			end
		end
	end

	for i=numProducts + 1, #quant.buttons do
		quant.buttons[i]:Hide();
	end

	if ( numProducts == 1 ) then
		quant:SetHeight(1);
		quant:Hide();
	else
		quant:SetHeight(20 * math.ceil(numProducts / 2) + 5);
		quant:Show();
	end
end

function ShopFrameBrowseQuantitySelectButton_OnClick(self)
	CurrentProductID = self:GetID();
	ShopFrameBrowse_UpdateQuantitySelection(ShopFrame.Browse);
end

function ShopFrameCloseButton_OnClick(self)
	ShopFrame:Hide();
end

function ShopFrameBuyButton_OnClick(self)
	ShopFrame_BeginPurchase(CurrentGroupID, CurrentProductID);
end

