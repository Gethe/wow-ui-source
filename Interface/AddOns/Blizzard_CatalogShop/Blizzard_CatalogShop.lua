----------------------------------------------------------------------------------
-- CatalogShopMixin
----------------------------------------------------------------------------------
CatalogShopMixin = {};
function CatalogShopMixin.GetBaseProductInfo(productID)
	if productID == CHARACTER_TRANSFER_FACTION_BUNDLE_PRODUCT_ID then
		-- TODO fix this C_StoreSecure call
		return C_StoreSecure.GetProductInfo(CHARACTER_TRANSFER_PRODUCT_ID);
	elseif productID == GUILD_TRANSFER_FACTION_BUNDLE_PRODUCT_ID then
		-- TODO fix this C_StoreSecure call
		return C_StoreSecure.GetProductInfo(GUILD_TRANSFER_PRODUCT_ID);
	end
end

function CatalogShopMixin.GetBundleProductInfo(productID)
	if productID == CHARACTER_TRANSFER_PRODUCT_ID then
		-- TODO fix this C_StoreSecure call
		return C_StoreSecure.GetProductInfo(CHARACTER_TRANSFER_FACTION_BUNDLE_PRODUCT_ID);
	elseif productID == GUILD_TRANSFER_PRODUCT_ID then
		-- TODO fix this C_StoreSecure call
		return C_StoreSecure.GetProductInfo(GUILD_TRANSFER_FACTION_BUNDLE_PRODUCT_ID);
	end
end

----------------------------------------------------------------------------------
function CatalogShopMixin:OnLoad_CatalogShop()
	self:RegisterEvent("CATALOG_SHOP_DATA_REFRESH");
	self:RegisterEvent("CATALOG_SHOP_FETCH_SUCCESS");
	self:RegisterEvent("CATALOG_SHOP_FETCH_FAILURE");
	self:RegisterEvent("CATALOG_SHOP_SPECIFIC_PRODUCT_REFRESH");
	self:RegisterEvent("CATALOG_SHOP_PURCHASE_SUCCESS");
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("PRODUCT_DISTRIBUTIONS_UPDATED");
	self:RegisterEvent("STORE_PURCHASE_ERROR");
	self:RegisterEvent("STORE_ORDER_INITIATION_FAILED");
	self:RegisterEvent("AUTH_CHALLENGE_FINISHED");
	self:RegisterEvent("TOKEN_MARKET_PRICE_UPDATED");
	self:RegisterEvent("TOKEN_STATUS_CHANGED");
	self:RegisterEvent("STORE_BOOST_AUTO_CONSUMED");
	self:RegisterEvent("STORE_REFRESH");
	self:RegisterEvent("UI_MODEL_SCENE_INFO_UPDATED");
	self:RegisterEvent("CATALOG_SHOP_OPEN_SIMPLE_CHECKOUT");
	self:RegisterEvent("UPDATE_EXPANSION_LEVEL");
	self:RegisterEvent("TRIAL_STATUS_UPDATE");
	self:RegisterEvent("SIMPLE_CHECKOUT_CLOSED");
	self:RegisterEvent("SUBSCRIPTION_CHANGED_KICK_IMMINENT");
	self:RegisterEvent("LOGIN_STATE_CHANGED");
	self:RegisterEvent("CATALOG_SHOP_PMT_IMAGE_DOWNLOADED")
	-- RNM: Removed becuase this was no longer used in Shop 2.0 
	-- self:RegisterEvent("DYNAMIC_BUNDLE_PRICE_UPDATED");

	self:InitVariables();

	EventRegistry:RegisterCallback("CatalogShop.OnProductSelected", self.OnProductSelected, self);
	EventRegistry:RegisterCallback("CatalogShop.OnNoProductsSelected", self.OnNoProductsSelected, self);
	EventRegistry:RegisterCallback("CatalogShop.OnCategorySelected", self.OnCategorySelected, self);

	self:SetPortraitToAsset("Interface\\Icons\\WoW_Store");
	self:SetTitle(BLIZZARD_STORE);

	if ( C_Glue.IsOnGlueScreen() ) then
		self:SetFrameStrata("FULLSCREEN_DIALOG");
		-- block keys
		self:EnableKeyboard(true);
		self:SetScript("OnKeyDown",
			function(self, key)
				if ( key == "ESCAPE" ) then
					if not StoreOutbound.TryHideModelPreviewFrame() then
						StoreFrame:SetAttribute("action", "EscapePressed");
					end
				end
			end
		);
	end

	-- solve this later
	self:SetPoint("CENTER", nil, "CENTER", 0, 20); --Intentionally not anchored to UIParent.

	self.categoryIDs = C_CatalogShop.GetAvailableCategoryIDs();

	self.onCloseCallback = function()
		self:Hide(); 
		return false;
	end;

	self.tooltip = CatalogShopTooltip;
	if C_Glue.IsOnGlueScreen() then
		self.tooltip:SetParent(GlueParent);
	else
		self.tooltip:SetParent(UIParent);
	end

	self.JustFinishedOrdering = false;
	self.JustOrderedBoost = false;
	self.justPurchasedProductID = nil;
	local useNativeForm = true;
	self:SetUseNativeForm(useNativeForm);

	self.HeaderFrame:Init(self.categoryIDs);
	self.ProductContainerFrame:Init();
	self.ProductDetailsContainerFrame:Init();
	self.ModelSceneContainerFrame:Init();

	self.HeaderFrame.SearchBox:SetScript("OnTextChanged", GenerateClosure(self.OnSearchTextChanged, self));
end

function CatalogShopMixin:InitVariables()
	self.FormatCurrencyStringShort = nil;
	self.FormatCurrencyStringLong = nil;

	self.ModelSceneData =
	{
		CurrentModelSceneData =
		{
			modelScene = nil,
			modelSceneID = nil,
			overrideModelSceneID = nil,
		},
		CurrentCardModelSceneData =
		{
			modelScene = nil,
			modelSceneID = nil,
			overrideModelSceneID = nil,
		},
	};

	self.CachedModelSceneOnMouseDownFunc = self.ModelSceneContainerFrame.MainModelScene.OnMouseDown;
	self.CachedModelSceneOnMouseUpFunc = self.ModelSceneContainerFrame.MainModelScene.OnMouseUp;
	self.CachedModelSceneOnMouseWheelFunc = self.ModelSceneContainerFrame.MainModelScene.OnMouseWheel;
end

function CatalogShopMixin:SetCurrentActor(actor)
	self.currentActor = actor;
end

function CatalogShopMixin:GetCurrentActor()
	return self.currentActor;
end

function CatalogShopMixin:SetCurrentModelSceneData(currentModelScene, currentModelSceneID, overrideModelSceneID)
	self.ModelSceneData.CurrentModelSceneData.modelScene = currentModelScene;
	self.ModelSceneData.CurrentModelSceneData.modelSceneID = currentModelSceneID;
	self.ModelSceneData.CurrentModelSceneData.overrideModelSceneID = overrideModelSceneID;
end

function CatalogShopMixin:GetCurrentModelSceneData()
	return self.ModelSceneData.CurrentModelSceneData;
end

function CatalogShopMixin:SetCurrentCardModelSceneData(currentModelScene, currentModelSceneID, overrideModelSceneID)
	self.ModelSceneData.CurrentCardModelSceneData.modelScene = currentModelScene;
	self.ModelSceneData.CurrentCardModelSceneData.modelSceneID = currentModelSceneID;
	self.ModelSceneData.CurrentCardModelSceneData.overrideModelSceneID = overrideModelSceneID;
end

function CatalogShopMixin:GetCurrentCardModelSceneData()
	return self.ModelSceneData.CurrentCardModelSceneData;
end

function CatalogShopMixin:FetchCurrentModelSceneData()
	return self.ModelSceneData;
end


function CatalogShopMixin:ShowTooltip(name, description, isToken)
	local tooltip = CatalogShopTooltip;
	local STORETOOLTIP_MAX_WIDTH = isToken and 300 or 250;
	local stringMaxWidth = STORETOOLTIP_MAX_WIDTH - 20;
	tooltip.ProductName:SetWidth(stringMaxWidth);
	tooltip.Description:SetWidth(stringMaxWidth);

	tooltip:Show();
	tooltip.ProductName:SetText(name);

	if (isToken) then
		local price = C_WowTokenPublic.GetCurrentMarketPrice();
		if (price) then
			description = description .. string.format(BLIZZARD_STORE_TOKEN_CURRENT_MARKET_PRICE, GetSecureMoneyString(price));
		else
			description = description .. string.format(BLIZZARD_STORE_TOKEN_CURRENT_MARKET_PRICE, TOKEN_MARKET_PRICE_NOT_AVAILABLE);
		end
	end
	tooltip.Description:SetText(description);

	-- 10 pixel buffer between top, 10 between name and description, 10 between description and bottom
	local nheight, dheight = tooltip.ProductName:GetHeight(), tooltip.Description:GetHeight();
	local buffer = 11;

	local bufferCount = 2;
	if (not name or name == "") then
		tooltip.Description:ClearAllPoints();
		tooltip.Description:SetPoint("TOPLEFT", 10, -11);
	else
		tooltip.Description:ClearAllPoints();
		tooltip.Description:SetPoint("TOPLEFT", tooltip.ProductName, "BOTTOMLEFT", 0, -2);
	end

	if (not description or description == "") then
		dheight = 0;
	else
		dheight = dheight + 2;
	end

	local width = math.max(tooltip.ProductName:GetStringWidth(), tooltip.Description:GetStringWidth());
	if ((width + 20) < STORETOOLTIP_MAX_WIDTH) then
		tooltip:SetWidth(width + 20);
	else
		tooltip:SetWidth(STORETOOLTIP_MAX_WIDTH);
	end
	tooltip:SetHeight(buffer*bufferCount + nheight + dheight);
	local parent = tooltip:GetParent();
	local modelFrameLevel = 200; -- just a reasonable safe default value
	for card in StoreFrame.productCardPoolCollection:EnumerateActive() do -- luacheck: ignore 512 (loop is executed at most once)
		modelFrameLevel = card.ModelScene:GetFrameLevel() + 2;
		break;
	end
	tooltip:SetFrameLevel(modelFrameLevel);
end

function CatalogShopMixin:HideTooltip()
	local tooltip = CatalogShopTooltip;
	tooltip:Hide();
end

function CatalogShopMixin:HidePreviewFrames()
	self.WoWTokenContainerFrame:Hide();
	self.ToyContainerFrame:Hide();
	self.ModelSceneContainerFrame:Hide();
	self.ServicesContainerFrame:Hide();
end

function CatalogShopMixin:ShowLoadingScreen()
	if self.CatalogShopLoadingScreenFrame:IsShown() then
		return;
	end

	self.CatalogShopLoadingScreenFrame:Show();
	self.CatalogShopLoadingScreenFrame.Sign.StartLoad:Restart();
	self.CatalogShopLoadingScreenFrame.Sparkle.SparkleAnim:Restart();

	local shopGodRayTable = { effectID=186, offsetY=0, };
	self.CatalogShopLoadingScreenFrame.FxModelScene:AddDynamicEffect(shopGodRayTable, self);

	self.BackgroundContainer:Hide();
	self.ProductContainerFrame:Hide();
	self.HeaderFrame:Hide();
	self.CatalogShopDetailsFrame:Hide();
	self.ProductDetailsContainerFrame:Hide();
	self:HidePreviewFrames();
end

function CatalogShopMixin:HideLoadingScreen()
	if not self.CatalogShopLoadingScreenFrame:IsShown() then
		return;
	end
	self.CatalogShopLoadingScreenFrame:Hide();
	self.CatalogShopLoadingScreenFrame.FxModelScene:ClearEffects();

	self.BackgroundContainer:Show();
	self.ProductContainerFrame:Show();
	self.HeaderFrame:Show();
end

function CatalogShopMixin:OnEvent_CatalogShop(event, ...)
	if event == "CATALOG_SHOP_DATA_REFRESH" then
		--... handle it
		self.categoryIDs = C_CatalogShop.GetAvailableCategoryIDs();
		self.HeaderFrame:SetCategories(self.categoryIDs);
	elseif event == "CATALOG_SHOP_SPECIFIC_PRODUCT_REFRESH" then
		local productID = ...;
		--self.ProductContainerFrame:UpdateSpecificProduct(productID);
		if self.ProductDetailsContainerFrame:IsShown() then
			-- If the details frame is shown, update it with the specific product info
			self.ProductDetailsContainerFrame:UpdateSpecificProduct(productID);
		end
	elseif event =="CATALOG_SHOP_OPEN_SIMPLE_CHECKOUT" then
		--... handle it
	
	elseif event =="SIMPLE_CHECKOUT_CLOSED" then
		self:SetAlpha(1);

		if self.justPurchasedProductID then
			C_Timer.After(0.25, function ()
				EventRegistry:TriggerEvent("CatalogShop.CelebratePurchase", self.justPurchasedProductID);
				self.justPurchasedProductID = nil;
			end);
		end

	elseif event =="CATALOG_SHOP_FETCH_SUCCESS" then
		self:HideLoadingScreen();

	elseif event =="CATALOG_SHOP_FETCH_FAILURE" then
		-- handle error
		self:HideLoadingScreen();

	elseif event =="CATALOG_SHOP_PURCHASE_SUCCESS" then
		local justPurchasedProductID = ...;

		if SimpleCheckout:IsShown() then
			-- Celebrate when the shop is shown again after the checkout window has been closed
			self.justPurchasedProductID = justPurchasedProductID;
		elseif self:IsShown() then
			EventRegistry:TriggerEvent("CatalogShop.CelebratePurchase", justPurchasedProductID);
		end
	elseif event == "CATALOG_SHOP_RESULT_ERROR" then
		-- TODO fix this C_StoreSecure call
		local err, internalErr = C_StoreSecure.GetFailureInfo();
		self:OnError(err, true, internalErr);
	elseif ( event == "STORE_PURCHASE_ERROR" ) then
		-- TODO fix this C_StoreSecure call
		local err, internalErr = C_StoreSecure.GetFailureInfo();
		self:OnError(err, true, internalErr);
	elseif (event == "SUBSCRIPTION_CHANGED_KICK_IMMINENT") then
		if not SimpleCheckout:IsShown() then
			self:Hide();
			GlueDialog_Show("SUBSCRIPTION_CHANGED_KICK_WARNING");
		end
	elseif ( event == "TOKEN_MARKET_PRICE_UPDATED" ) then
		--local result = ...;
		--if (StoreFrame_GetSelectedCategoryID() == WOW_TOKEN_CATEGORY_ID) then
			--StoreFrame_SetCategory();
		--end
	elseif ( event == "TOKEN_STATUS_CHANGED" ) then
		--StoreFrame_CheckMarketPriceUpdates();
	elseif (event == "UI_SCALE_CHANGED") then
		FrameUtil.UpdateScaleForFitSpecific(self, self:GetWidth() + CatalogShopConstants.ScreenPadding.Horizontal, self:GetHeight() + CatalogShopConstants.ScreenPadding.Vertical);
	elseif (event == "CATALOG_SHOP_PMT_IMAGE_DOWNLOADED") then
		--	// Finish implementation when completing [WOW11-144188]
		--...handle it
	end
end

function CatalogShopMixin:IsLoading()
	-- TODO fix this C_StoreSecure call
	if ( not C_StoreSecure.HasProductList() ) then
		return true;
	end
	-- TODO fix this C_StoreSecure call
	if ( not C_StoreSecure.HasDistributionList() ) then
		return true;
	end
	-- can open the store UI while in queue, but in that state we don't ask for, nor need the purchase list
	-- TODO fix this C_StoreSecure call
	if ( not C_StoreSecure.HasPurchaseList() ) then
		if (C_Glue.IsOnGlueScreen()) then
			local _, _, wowConnectionState = C_Login.GetState();
			if ( wowConnectionState ~= LE_WOW_CONNECTION_STATE_IN_QUEUE ) then
				return true;
			end
		end
	end
	return false;
end

function CatalogShopMixin:OnShow()
	self:ShowLoadingScreen();
	self:SetAttribute("isshown", true);

	if ( not C_Glue.IsOnGlueScreen() ) then
		CatalogShopOutbound.UpdateMicroButtons();
	else
		GlueParent_AddModalFrame(self);
	end

	FrameUtil.UpdateScaleForFitSpecific(self, self:GetWidth() + CatalogShopConstants.ScreenPadding.Horizontal, self:GetHeight() + CatalogShopConstants.ScreenPadding.Vertical);

	C_CatalogShop.OpenCatalogShopInteraction();
end

function CatalogShopMixin:OnHide()
	self:SetAttribute("isshown", false);

	if ( not C_Glue.IsOnGlueScreen() ) then
		CatalogShopOutbound.UpdateMicroButtons();
	else
		GlueParent_RemoveModalFrame(self);
		CatalogShopOutbound.UpdateDialogs();
	end

	C_CatalogShop.CloseCatalogShopInteraction();
	SimpleCheckout:Hide();
	PlaySound(SOUNDKIT.CATALOG_SHOP_CLOSE_SHOP);
end

function CatalogShopMixin:GetUseNativeForm()
	return self.UseNativeForm;
end

function CatalogShopMixin:SetUseNativeForm(useNativeForm)
	self.UseNativeForm = useNativeForm;
end

function CatalogShopMixin:SetHideArmorSetting(playerArmorSetting)
	self.hidePlayerArmorSetting = playerArmorSetting;
end

function CatalogShopMixin:GetHideArmorSetting()
	return self.hidePlayerArmorSetting;
end

function CatalogShopMixin:OnAttributeChanged(name, value)
	--Note - Setting attributes is how the external UI should communicate with this frame. That way their taint won't be spread to this code.
	if ( name == "action" ) then
		if ( value == "Show" ) then
			self:Show();
		elseif ( value == "Hide" ) then
			self:Hide();
		elseif ( value == "EscapePressed" ) then
			local handled = false;
			if ( self:IsShown() ) then
				if ( self.CatalogShopErrorFrame:IsShown() or StoreConfirmationFrame:IsShown() ) then
					--We eat the click, but don't close anything. Make them explicitly press "Cancel".
					handled = true;
				else
					self:Hide();
					handled = true;
				end
			--elseif (ServicesLogoutPopup:IsShown()) then
				--ServicesLogoutPopup:Hide();
				--handled = true;
			end
			self:SetAttribute("escaperesult", handled);
		end
	end
end

function CatalogShopMixin:Leave()
	--... handle leaving
	self:Hide();
end

function CatalogShopMixin:IsProductCompletelyOwned(productInfo)
	-- TODO: convert this check
	return false;--entryInfo.sharedData.eligibility == Enum.PurchaseEligibility.Owned;
end

function CatalogShopMixin:ShowError(title, desc, urlIndex, needsAck)
	self.CatalogShopErrorFrame:ShowError(title, desc, urlIndex, needsAck);
end

function CatalogShopMixin:OnError(errorID, needsAck, internalErr)
	local title, msg, link = ErrorLookupInterface.GetErrorMessage(errorID);

	if ( IsGMClient() and not HideGMOnly() ) then
		self:ShowError(self, title.." ("..internalErr..")", msg, link, needsAck);
	else
		self:ShowError(self, title, msg, link, needsAck);
	end
end

function CatalogShopMixin:SetAlert(title, desc)
	self.Notice.Title:SetText(title);
	self.Notice.Description:SetText(desc);
	self.Notice:Show();

	if ( StoreConfirmationFrame ) then
		StoreConfirmationFrame:Raise(); --Make sure the confirmation is above this alert frame.
	end
end

function CatalogShopMixin:HideAlert()
	self.Notice:Hide();
end

function CatalogShopMixin:PurchaseProduct()
	local productInfo = self:GetSelectedProductInfo();

	local completelyOwned = self:IsProductCompletelyOwned(productInfo);
	if completelyOwned then
		self:OnError(Enum.StoreError.AlreadyOwned, false, "FakeOwned");
	elseif C_CatalogShop.PurchaseProduct(productInfo.catalogShopProductID) then
		-- TODO - fix this
	--else
		-- TODO - fix this
		--if (productInfo and productInfo.sharedData.productDecorator == Enum.BattlepayProductDecorator.Expansion) then
			--self:OnError(Enum.StoreError.AlreadyOwned, false, "Expansion");
		--end
	end
end

function CatalogShopMixin:HideProductDetails()
	local productInfo = self:GetSelectedProductInfo();
	local showDetails = false;
	self:ToggleProductDetails(showDetails, productInfo);
end

function CatalogShopMixin:ShowProductDetails()
	local productInfo = self:GetSelectedProductInfo();
	-- Dont show details if nothing is selected
	if not productInfo then
		return
	end
	local showDetails = true;
	self:ToggleProductDetails(showDetails, productInfo);
end

function CatalogShopMixin:AcceptError()
	if ( self.CatalogShopErrorFrame:ErrorNeedsAck() ) then
		-- TODO fix this C_StoreSecure call
		C_StoreSecure.AckFailure();
	end
	StoreFrame.CatalogShopErrorFrame:Hide();
	PlaySound(SOUNDKIT.CATALOG_SHOP_SELECT_GENERIC_UI_BUTTON);
end

function CatalogShopMixin:WebsiteError()
end

function CatalogShopMixin:OnProductSelected(data)
	local backgroundTexture = data and data.backgroundTexture or nil;
	self.BackgroundContainer:SetBackgroundTexture(backgroundTexture);

	-- Show the right side details frame if our product container frame is shown (enables purchase and details)
	self.CatalogShopDetailsFrame:SetShown(self.ProductContainerFrame:IsShown());
end

function CatalogShopMixin:OnNoProductsSelected()
	self.BackgroundContainer:SetBackgroundTexture(CatalogShopConstants.NoResults.BackgroundTexture);
	self:HidePreviewFrames();
	self.CatalogShopDetailsFrame:Hide();
end

function CatalogShopMixin:OnCategorySelected(categoryID)
	-- Close the details frame if it's open
	local showDetailsFrame = false;
	local productInfo = nil;
	self:ToggleProductDetails(showDetailsFrame, productInfo);

	self.ProductContainerFrame:OnCategorySelected(categoryID);
end

function CatalogShopMixin:ToggleProductDetails(showDetails, productInfo)
	self.ProductContainerFrame:SetShown(not showDetails);
	self.ProductDetailsContainerFrame:SetShown(showDetails);
	self.CatalogShopDetailsFrame:SetShown(not showDetails);
	if showDetails then
		self.ProductDetailsContainerFrame:UpdateProductInfo(productInfo);
	end
end

local RED_TEXT_SECONDS_THRESHOLD = 3600;
function CatalogShopMixin:FormatTimeLeft(secondsRemaining, formatter)
	local color = (secondsRemaining > RED_TEXT_SECONDS_THRESHOLD) and WHITE_FONT_COLOR or RED_FONT_COLOR;
	local text = formatter:Format(secondsRemaining);
	return color:WrapTextInColorCode(text);
end

function CatalogShopMixin:GetProductInfo(productID)
	local productInfo = C_CatalogShop.GetProductInfo(productID)
	if productInfo then
		local productDisplayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(productInfo.catalogShopProductID);
		if not productDisplayInfo then
			error("CatalogShopMixin:GetProductInfo : product display info not found!")
			return productInfo;
		end
		
		local defaultPreviewModelSceneID = productDisplayInfo.defaultPreviewModelSceneID;
		local overridePreviewModelSceneID = productDisplayInfo.overridePreviewModelSceneID or nil;
		local defaultCardModelSceneID = productDisplayInfo.defaultCardModelSceneID;
		local overrideCardModelSceneID = productDisplayInfo.overrideCardModelSceneID or nil;
		local defaultWideCardModelSceneID = productDisplayInfo.defaultWideCardModelSceneID;
		local overrideWideCardModelSceneID = productDisplayInfo.overrideWideCardModelSceneID or nil;

		-- get preview scene display data
		productInfo.sceneDisplayData = CatalogShopUtil.TranslateProductInfoToProductDisplayData(productDisplayInfo, defaultPreviewModelSceneID, overridePreviewModelSceneID);

		-- get small card display data - should always be here
		productInfo.cardDisplayData = CatalogShopUtil.TranslateProductInfoToProductDisplayData(productDisplayInfo, defaultCardModelSceneID, overrideCardModelSceneID);

		-- get wide card display data if set
		if defaultWideCardModelSceneID then
			productInfo.wideCardDisplayData = CatalogShopUtil.TranslateProductInfoToProductDisplayData(productDisplayInfo, defaultWideCardModelSceneID, overrideWideCardModelSceneID);
		end
				
		-- get bundle children display data
		if productDisplayInfo.productType == CatalogShopConstants.ProductCardType.Bundle then
			local childrenProductData = C_CatalogShop.GetProductIDsForBundle(productID);
			if productInfo.sceneDisplayData then
				productInfo.sceneDisplayData.bundleChildrenDisplayData = {};
			end
			if productInfo.cardDisplayData then
				productInfo.cardDisplayData.bundleChildrenDisplayData = {};
			end
			if productInfo.wideCardDisplayData then
				productInfo.wideCardDisplayData.bundleChildrenDisplayData = {};
			end
			for _, childData in ipairs(childrenProductData) do
				local childProductDisplayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(childData.childProductID)
				if productInfo.sceneDisplayData then
					local childProductData = CatalogShopUtil.TranslateProductInfoToProductDisplayData(childProductDisplayInfo, defaultPreviewModelSceneID, overridePreviewModelSceneID)
					childProductData.displayOrder = childData.displayOrder or 999;
					-- Special case for bundle children (reminder a product could be in a bundle AND not in a bundle in the storefront)
					-- We don't want to adjust the model scene's camera based on child data, so we are nilling it out of our childProductData
					childProductData.cameraDisplayData = nil;
					table.insert(productInfo.sceneDisplayData.bundleChildrenDisplayData, childProductData);
				end
				if productInfo.cardDisplayData then
					local childProductData = CatalogShopUtil.TranslateProductInfoToProductDisplayData(childProductDisplayInfo, defaultCardModelSceneID, overrideCardModelSceneID)
					childProductData.displayOrder = childData.displayOrder or 999;
					-- Special case for bundle children (reminder a product could be in a bundle AND not in a bundle in the storefront)
					-- We don't want to adjust the model scene's camera based on child data, so we are nilling it out of our childProductData
					childProductData.cameraDisplayData = nil;
					table.insert(productInfo.cardDisplayData.bundleChildrenDisplayData, childProductData);
				end
				if productInfo.wideCardDisplayData then
					local childProductData = CatalogShopUtil.TranslateProductInfoToProductDisplayData(childProductDisplayInfo, defaultWideCardModelSceneID, overrideWideCardModelSceneID)
					childProductData.displayOrder = childData.displayOrder or 999;
					-- Special case for bundle children (reminder a product could be in a bundle AND not in a bundle in the storefront)
					-- We don't want to adjust the model scene's camera based on child data, so we are nilling it out of our childProductData
					childProductData.cameraDisplayData = nil;
					table.insert(productInfo.wideCardDisplayData.bundleChildrenDisplayData, childProductData);
				end
			end
		end
	end
	return productInfo;
end

function CatalogShopMixin:GetSelectedProductInfo()
	return self.ProductContainerFrame:GetSelectedProductInfo();
end

function CatalogShopMixin:GetCurrencyInfo()
	-- TODO fix this C_StoreSecure call
	local currencyInfo = C_StoreSecure.GetCurrencyInfo();
	local info = {};
	if currencyInfo then
		local currencyRegion = currencyInfo.sharedData.regionID;
		self.FormatCurrencyStringShort = currencyInfo.sharedData.formatShort;
		self.FormatCurrencyStringLong = currencyInfo.sharedData.formatLong;
		info = currencySpecific[currencyRegion] or currencySpecific[REGION_US];
		if currencyInfo.sharedData.licenseAcceptText ~= "" then
			info.licenseAcceptText = currencyInfo.sharedData.licenseAcceptText;
		end;
		info.requireLicenseAccept = currencyInfo.sharedData.requireLicenseAccept;
		info.browseHasStar = currencyInfo.sharedData.browseHasStar;
		info.hideBrowseNotice = currencyInfo.sharedData.hideBrowseNotice;
		if info.hideBrowseNotice then
			info.browseNotice = ""
		end
		info.hideConfirmationBrowseNotice = currencyInfo.sharedData.hideConfirmationBrowseNotice;
	end
	
	return info;
end

function CatalogShopMixin:ShowPurchaseSent()
	self.PurchaseSentFrame.Title:SetText(BLIZZARD_STORE_PURCHASE_SENT);
	self.PurchaseSentFrame.OkayButton:SetText(OKAY);

	self.PurchaseSentFrame:Show();

	if ( StoreConfirmationFrame ) then
		StoreConfirmationFrame:Raise();
	end
end

function CatalogShopMixin:HidePurchaseSent()
	self.JustFinishedOrdering = false;
	self.PurchaseSentFrame:Hide();
end

function CatalogShopMixin:HasFreeBagSlots()
	for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local freeSlots, bagFamily = C_Container.GetContainerNumFreeSlots(i);
		if ( freeSlots > 0 and bagFamily == 0 ) then
			return true;
		end
	end
	return false;
end


function CatalogShopMixin:OnSearchTextChanged(editBox, userInput)
	SearchBoxTemplate_OnTextChanged(self.HeaderFrame.SearchBox);

	local initializing = (self.searchText == nil);

	local text = editBox:GetText();
	if text == self.searchText then
		return;
	end

	self.searchText = text;

	if initializing then
		return;
	end

	local resetSelection = text and string.len(text) > 0 or false;
	self.ProductContainerFrame:UpdateProducts(resetSelection);
end

function CatalogShopMixin:ClearSearchBox()
	self.HeaderFrame.SearchBox:SetText("");
end

----------------------------------------------------------------------------------
-- CatalogShopProductDetailsFrameMixin
----------------------------------------------------------------------------------
CatalogShopProductDetailsFrameMixin = {};
function CatalogShopProductDetailsFrameMixin:OnLoad()
	EventRegistry:RegisterCallback("CatalogShopModel.OnProductSelectedAfterModel", self.UpdateState, self);
	EventRegistry:RegisterCallback("CatalogShop.OnProductInfoChanged", self.OnProductInfoChanged, self);
end

function CatalogShopProductDetailsFrameMixin:UpdateState()
	CatalogShopFrame:HideLoadingScreen();
	CatalogShopFrame.CatalogShopDetailsFrame:SetShown(true);

	local selectedProductInfo = CatalogShopFrame:GetSelectedProductInfo();
	local displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(selectedProductInfo.catalogShopProductID);
	-- update state based on product info

	self.ProductName:SetText(selectedProductInfo.name);
	self.ProductDescription:SetText(CatalogShopUtil.GetDescriptionText(selectedProductInfo, displayInfo));
	
	self.ButtonContainer.PurchaseButton:SetText(selectedProductInfo.price);
	self.ButtonContainer.PurchaseButton:SetEnabled(not selectedProductInfo.purchased);
	self:MarkDirty();
end

function CatalogShopProductDetailsFrameMixin:OnProductInfoChanged(productInfo)
	local selectedProductInfo = CatalogShopFrame:GetSelectedProductInfo();

	-- if the selected product was changed, update state
	if productInfo and selectedProductInfo and (productInfo.catalogShopProductID == selectedProductInfo.catalogShopProductID) then
		self:UpdateState();
	end
end


----------------------------------------------------------------------------------
-- BackgroundContainerMixin
----------------------------------------------------------------------------------
BackgroundContainerMixin = {};
function BackgroundContainerMixin:OnLoad()
	self.Background_1:SetAlpha(1);
	self.Background_2:SetAlpha(0);

	self.currentBackground = self.Background_1;
	self.nextBackground = self.Background_2;
	self.nextFadeIn = self.FadeInBackground_2;

	self.FadeInBackground_1:SetScript("OnFinished", function()
		self.currentBackground = self.Background_1;
		self.nextBackground = self.Background_2;
		self.nextFadeIn = self.FadeInBackground_2;
	end);

	self.FadeInBackground_2:SetScript("OnFinished", function()
		self.currentBackground = self.Background_2;
		self.nextBackground = self.Background_1;
		self.nextFadeIn = self.FadeInBackground_1;
	end);
end

function BackgroundContainerMixin:SetBackgroundTexture(backgroundAtlas)
	if backgroundAtlas then
		self.currentBackground:SetDrawLayer("BACKGROUND", 1);
		self.nextBackground:SetDrawLayer("BACKGROUND", 2);
		self.nextBackground:SetAtlas(backgroundAtlas);
		self.nextFadeIn:Play();
	end
end
