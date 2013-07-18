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

--Local references to frames
local StoreFrame;
local StoreConfirmationFrame

--Local variables (here instead of as members on frames for now)
local CurrentGroupID = nil;
local CurrentProductID = nil;
local JustOrderedProduct = false;
local WaitingOnConfirmation = false;

local function Import(name)
	tbl[name] = SecureCapsuleGet(name);
end

--Imports
Import("C_PurchaseAPI");
Import("math");
Import("pairs");

--GlobalStrings
Import("BLIZZARD_STORE");
Import("BLIZZARD_STORE_ON_SALE");
Import("BLIZZARD_STORE_BUY");
Import("BLIZZARD_STORE_PLUS_TAX");
Import("BLIZZARD_STORE_PRODUCT_INDEX");
Import("BLIZZARD_STORE_CANCEL_PURCHASE");
Import("BLIZZARD_STORE_FINAL_BUY");
Import("BLIZZARD_STORE_CONFIRMATION_TITLE");
Import("BLIZZARD_STORE_CONFIRMATION_INSTRUCTION");
Import("BLIZZARD_STORE_FINAL_PRICE_LABEL");
Import("BLIZZARD_STORE_PAYMENT_METHOD");
Import("BLIZZARD_STORE_PAYMENT_METHOD_EXTRA");
Import("BLIZZARD_STORE_LOADING");
Import("BLIZZARD_STORE_PLEASE_WAIT");
Import("BLIZZARD_STORE_NO_ITEMS");
Import("BLIZZARD_STORE_CHECK_BACK_LATER");
Import("BLIZZARD_STORE_TRANSACTION_IN_PROGRESS");
Import("BLIZZARD_STORE_CONNECTING");

--Code
local function getIndex(tbl, value)
	for k, v in pairs(tbl) do
		if ( v == value ) then
			return k;
		end
	end
end

function StoreFrame_OnLoad(self)
	StoreFrame = self;	--Save off a reference for us
	self:RegisterEvent("STORE_PRODUCTS_UPDATED");
	self:RegisterEvent("STORE_PURCHASE_LIST_UPDATED");
	C_PurchaseAPI.GetProductList();
	C_PurchaseAPI.GetPurchaseList();
	C_PurchaseAPI.GetDistributionList();

	self.Title:SetText(BLIZZARD_STORE);
	self.Browse.ProductDescription:SetPoint("BOTTOM", self.Browse.QuantitySelection, "TOP", 0, 5);
	self.Browse.BuyButton:SetText(BLIZZARD_STORE_BUY);
	self.Browse.PlusTax:SetText(BLIZZARD_STORE_PLUS_TAX);
	self.Notice.NopButton:SetText(BLIZZARD_STORE_BUY);
	self.Notice.NopButton:Disable();

	self:SetPoint("CENTER", nil, "CENTER", 0, 77); --Intentionally not anchored to UIParent.

	StoreFrame_UpdateActivePanel(self);
end

function StoreFrame_OnEvent(self, event, ...)
	if ( event == "STORE_PRODUCTS_UPDATED" ) then
		StoreFrame_UpdateActivePanel(self);
	elseif ( event == "STORE_PURCHASE_LIST_UPDATED" ) then
		JustOrderedProduct = false;
		StoreFrame_UpdateActivePanel(self);
	end
end

function StoreFrame_OnShow(self)
	WaitingOnConfirmation = false;
	StoreFrame_UpdateActivePanel(self);
end

function StoreFrame_OnAttributeChanged(self, name, value)
	--Note - Setting attributes is how the external UI should communicate with this frame. That way, their taint won't be spread to this code.
	if ( name == "action" ) then
		if ( value == "Show" ) then
			self:Show();
		elseif ( value == "Hide" ) then
			self:Hide();
		end
	end
end

function StoreFrame_UpdateActivePanel(self)
	if ( WaitingOnConfirmation ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_CONNECTING, BLIZZARD_STORE_PLEASE_WAIT);
	elseif ( JustOrderedProduct ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_TRANSACTION_IN_PROGRESS, BLIZZARD_STORE_CHECK_BACK_LATER);
	elseif ( C_PurchaseAPI.HasPurchaseInProgress() ) then --Even if we don't have every list, if we know we have something in progress, we can display that.
		StoreFrame_SetAlert(self, BLIZZARD_STORE_TRANSACTION_IN_PROGRESS, BLIZZARD_STORE_CHECK_BACK_LATER);
	elseif ( not C_PurchaseAPI.HasPurchaseList() or not C_PurchaseAPI.HasProductList() or not C_PurchaseAPI.HasDistributionList() ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_LOADING, BLIZZARD_STORE_PLEASE_WAIT);
	elseif ( #C_PurchaseAPI.GetProductGroups() == 0 ) then
		StoreFrame_SetAlert(self, BLIZZARD_STORE_NO_ITEMS, BLIZZARD_STORE_CHECK_BACK_LATER);
	else
		StoreFrame_SetBrowse(self);
	end
end

function StoreFrame_SetBrowse(self)
	self.Notice:Hide();
	StoreFrameBrowse_Advance(self.Browse, 0); --Advancing by 0 will just make sure that we have a valid group selected.
	StoreFrameBrowse_Update(self.Browse);
	self.Browse:Show();
end

function StoreFrame_SetAlert(self, title, desc)
	self.Browse:Hide();
	self.Notice.Title:SetText(title);
	self.Notice.Description:SetText(desc);
	self.Notice:Show();
end

function StoreFrameBrowseNextItem_OnClick(self)
	StoreFrameBrowse_Advance(self:GetParent(), 1);
end

function StoreFrameBrowsePrevItem_OnClick(self)
	StoreFrameBrowse_Advance(self:GetParent(), -1);
end

function StoreFrameBrowse_Advance(self, amount)
	local groups = C_PurchaseAPI.GetProductGroups();

	local nextIndex = getIndex(groups, CurrentGroupID);
	if ( nextIndex ) then
		nextIndex = nextIndex + amount;
	else
		nextIndex = 1;
	end

	if ( nextIndex > #groups ) then
		nextIndex = 1;
	elseif ( nextIndex < 1 ) then
		nextIndex = #groups;
	end

	CurrentGroupID = groups[nextIndex];
	CurrentProductID = nil;	--Update fills out the product ID with the first value in the group

	StoreFrameBrowse_Update(self)

	self.ProductIndex:SetFormattedText(BLIZZARD_STORE_PRODUCT_INDEX, nextIndex, #groups);
end

function StoreFrameBrowse_Update(self)
	local id, name, description, icon = C_PurchaseAPI.GetProductGroupInfo(CurrentGroupID);
	self.ProductName:SetText(name);
	self.ProductDescription:SetText(description);
	self.Icon:SetTexture(icon);

	StoreFrameBrowse_UpdateQuantitySelection(self);
end

function StoreFrameBrowse_SetSale(self, normalPrice, currentPrice)
	self.NormalPriceFrame:Hide();
	
	self.SaleFrame.SalePrice:SetText(currentPrice.."*");
	self.SaleFrame.NormalPrice:SetText(normalPrice);

	self.SaleFrame:Show();
end

function StoreFrameBrowse_SetNormalPrice(self, price)
	self.SaleFrame:Hide();

	self.NormalPriceFrame.Price:SetText(price.."*");

	self.NormalPriceFrame:Show();
end

function StoreFrameBrowse_UpdateQuantitySelection(self)
	local products = C_PurchaseAPI.GetProducts(CurrentGroupID);
	local quant = self.QuantitySelection;

	if ( not CurrentProductID or not getIndex(products, CurrentProductID) ) then
		CurrentProductID = products[1];
	end

	for i=1, #products do
		local button = quant.buttons[i];
		if ( not button ) then
			quant.buttons[i] = CreateForbiddenFrame("CheckButton", nil, quant, "StoreQuantitySelectionTemplate");
			button = quant.buttons[i];
			button:SetScript("OnClick", StoreFrameBrowseQuantitySelectButton_OnClick);

			if ( i % 2 == 0 ) then
				button:SetPoint("LEFT", quant.buttons[i-1], "RIGHT", 140, 0);
			else
				button:SetPoint("TOP", quant.buttons[i-2], "BOTTOM", 0, -5);
			end
		end

		local id, title, normalPrice, currentPrice = C_PurchaseAPI.GetProductInfo(products[i]);
		button:SetID(id);
		button.Title:SetText(title);
		button.Price:SetText(currentPrice);
		button:SetChecked(id == CurrentProductID);
		button:SetEnabled(id ~= CurrentProductID);
		button:Show();

		if ( id == CurrentProductID ) then
			if ( normalPrice == currentPrice ) then
				StoreFrameBrowse_SetNormalPrice(self, currentPrice);
			else
				StoreFrameBrowse_SetSale(self, normalPrice, currentPrice);
			end
		end
	end

	for i=#products + 1, #quant.buttons do
		quant.buttons[i]:Hide();
	end

	if ( #products == 1 ) then
		quant:SetHeight(1);
		quant:Hide();
	else
		quant:SetHeight(20 * math.ceil(#products / 2) + 5);
		quant:Show();
	end
end

function StoreFrameBrowseQuantitySelectButton_OnClick(self)
	CurrentProductID = self:GetID();
	StoreFrameBrowse_UpdateQuantitySelection(StoreFrame.Browse);
end

function StoreFrameCloseButton_OnClick(self)
	StoreFrame:Hide();
end

function StoreFrameBuyButton_OnClick(self)
	StoreFrame_BeginPurchase(CurrentProductID);
end

function StoreFrame_BeginPurchase(productID)
	WaitingOnConfirmation = true;
	StoreFrame_UpdateActivePanel(StoreFrame);
	C_PurchaseAPI.PurchaseProduct(productID);
end

------------------------------------------
function StoreConfirmationFrame_OnLoad(self)
	StoreConfirmationFrame = self;

	self:RegisterEvent("STORE_CONFIRM_PURCHASE");

	self.Title:SetText(BLIZZARD_STORE_CONFIRMATION_TITLE);
	self.Instruction:SetText(BLIZZARD_STORE_CONFIRMATION_INSTRUCTION);
	self.CancelButton:SetText(BLIZZARD_STORE_CANCEL_PURCHASE);
	self.FinalBuyButton:SetText(BLIZZARD_STORE_FINAL_BUY);
	self.FinalPriceLabel:SetText(BLIZZARD_STORE_FINAL_PRICE_LABEL);
	self.PaymentMethod:SetText(BLIZZARD_STORE_PAYMENT_METHOD);
	self.PaymentMethodExtra:SetText(BLIZZARD_STORE_PAYMENT_METHOD_EXTRA);
end

function StoreConfirmationFrame_OnEvent(self, event, ...)
	if ( event == "STORE_CONFIRM_PURCHASE" ) then
		WaitingOnConfirmation = false;
		StoreFrame_UpdateActivePanel(StoreFrame);
		if ( StoreFrame:IsShown() ) then
			StoreConfirmationFrame_Update(self);
			self:Show();
		else
			C_PurchaseAPI.PurchaseProductConfirm(false);
		end
	end
end

function StoreConfirmationFrame_OnShow(self)
	StoreFrame.Cover:Show();
	self:Raise();
end

function StoreConfirmationFrame_OnHide(self)
	StoreFrame.Cover:Hide();
end

function StoreConfirmationFrame_Update(self)
	local productID = C_PurchaseAPI.GetConfirmationInfo();
	if ( not productID ) then
		self:Hide(); --May want to show an error message
		return;
	end

	local id, title, normalPrice, currentPrice, groupID = C_PurchaseAPI.GetProductInfo(productID);
	if ( not groupID ) then
		self:Hide(); --Should never happen, but may want to handle and throw an error message.
		return;
	end

	local id, name, description, icon = C_PurchaseAPI.GetProductGroupInfo(groupID);
	self.Icon:SetTexture(icon);
	self.GroupName:SetText(name);
	self.FinalPrice:SetText(currentPrice);
end

function StoreConfirmationCancel_OnClick(self)
	C_PurchaseAPI.PurchaseProductConfirm(false);
	StoreConfirmationFrame:Hide();
end

function StoreConfirmationFinalBuy_OnClick(self)
	JustOrderedProduct = true;
	C_PurchaseAPI.PurchaseProductConfirm(true);
	StoreFrame_UpdateActivePanel(StoreFrame);
	StoreConfirmationFrame:Hide();
end
