local HouseChestAtlasMarkup = CreateAtlasMarkup("house-chest-icon", 16, 16);

----------------------------------------------------------------------------------
-- CatalogShopMixin
----------------------------------------------------------------------------------
CatalogShopMixin = {};

local CATALOG_SHOP_DYNAMIC_EVENTS = {
	"CATALOG_SHOP_REBUILD_SCROLL_BOX",
	"CATALOG_SHOP_SPECIFIC_PRODUCT_REFRESH",
	"CATALOG_SHOP_VIRTUAL_CURRENCY_BALANCE_UPDATE",
	"CATALOG_SHOP_REFUNDABLE_DECORS_UPDATED",
	"BULK_REFUND_RESULT_RECEIVED",
};

function CatalogShopMixin:ShowRewardsShop()
	self.isRewardsShopInteraction = true;
	self.shoppingSessionUUIDStr = C_CatalogShop.OpenCatalogShopInteractionFromRewards();
	self:Show();
end

function CatalogShopMixin:HideRewardsShop()
	self.isRewardsShopInteraction = false;
	self:Hide();
end

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
	self:RegisterEvent("CATALOG_SHOP_PURCHASE_SUCCESS");
	self:RegisterEvent("UI_SCALE_CHANGED");
	self:RegisterEvent("STORE_PURCHASE_ERROR");
	self:RegisterEvent("CATALOG_SHOP_RESULT_ERROR");
	self:RegisterEvent("TOKEN_MARKET_PRICE_UPDATED");
	self:RegisterEvent("TOKEN_STATUS_CHANGED");
	self:RegisterEvent("CATALOG_SHOP_OPEN_SIMPLE_CHECKOUT");
	self:RegisterEvent("SIMPLE_CHECKOUT_CLOSED");
	self:RegisterEvent("SET_SEEN_PRODUCTS");
	self:RegisterEvent("BULK_PURCHASE_RESULT_RECEIVED");
	self:RegisterEvent("BN_DISCONNECTED");
	self:InitVariables();
	EventRegistry:RegisterCallback("CatalogShop.OnProductSelected", self.OnProductSelected, self);
	EventRegistry:RegisterCallback("CatalogShop.OnNoProductsSelected", self.OnNoProductsSelected, self);
	EventRegistry:RegisterCallback("CatalogShop.OnCategorySelected", self.OnCategorySelected, self);

	self:SetPortraitToAsset("Interface\\Icons\\UI_Shop");
	self:SetTitle(BLIZZARD_STORE);

	if ( C_Glue.IsOnGlueScreen() ) then
		self:SetFrameStrata("FULLSCREEN");
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

	-- solve this later
	self:ClearAllPoints();
	self:SetPoint("CENTER", nil, "CENTER", 0, 20); -- Intentionally not anchored to the top-level parent.

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
	self.tooltip:SetFrameStrata("TOOLTIP");

	self.JustFinishedOrdering = false;
	self.JustOrderedBoost = false;
	self.justPurchasedProductID = nil;
	self.shoppingSessionUUIDStr = nil;
	self.failedLoad = false;
	local useNativeForm = true;
	self:SetUseNativeForm(useNativeForm);

	self.HeaderFrame:Init(self.categoryIDs);
	self.ProductContainerFrame:Init();
	self.ProductDetailsContainerFrame:Init();
	self.ProductBYOBContainerFrame:Init();
	self.ModelSceneContainerFrame:Init();

	self.HeaderFrame.SearchBox:SetScript("OnTextChanged", GenerateClosure(self.OnSearchTextChanged, self));
	self:InitializeGamepad();
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

function CatalogShopMixin:GetAppropriateTooltip()
	return self.tooltip;
end

function CatalogShopMixin:ShowTooltip(targetFrame, name, description, isToken)
	local tooltip = self:GetAppropriateTooltip();

	targetFrame = targetFrame or self;
	tooltip:SetOwner(targetFrame, "ANCHOR_BOTTOMLEFT", 0, 0);

	GameTooltip_AddNormalLine(tooltip, name);
	GameTooltip_AddBlankLineToTooltip(tooltip);
	GameTooltip_AddNormalLine(tooltip, description);

	tooltip:Show();
end

function CatalogShopMixin:HideTooltip()
	local tooltip = self:GetAppropriateTooltip();
	tooltip:Hide();
end

function CatalogShopMixin:HidePreviewFrames()
	self.WoWTokenContainerFrame:Hide();
	self.ToyContainerFrame:Hide();
	self.ModelSceneContainerFrame:Hide();
	self.ServicesContainerFrame:Hide();
	self.PMTImageContainerFrame:Hide();
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
	self.CatalogShopVCFrame:Hide();
	self.ProductDetailsContainerFrame:Hide();
	self.ProductBYOBContainerFrame:Hide();
	self.PersistentRefundContainerFrame:Hide();
	self:HidePreviewFrames();
end

function CatalogShopMixin:HideLoadingScreen(fromError)
	if not self.CatalogShopLoadingScreenFrame:IsShown() then
		return;
	end
	self.CatalogShopLoadingScreenFrame:Hide();
	self.CatalogShopLoadingScreenFrame.FxModelScene:ClearEffects();

	if not fromError then
		self.BackgroundContainer:Show();
		self.ProductContainerFrame:Show();
		self.HeaderFrame:Show();
		self.PersistentRefundContainerFrame:UpdateState();
	end
end

function CatalogShopMixin:ShowUnavailableScreen()
	if self.CatalogShopUnavailableScreenFrame:IsShown() then
		return;
	end
	local fromError = true;
	self:HideLoadingScreen(fromError);

	self.ProductContainerFrame:Hide();
	self.ProductDetailsContainerFrame:Hide();
	self.ProductBYOBContainerFrame:Hide();
	self.CatalogShopDetailsFrame:Hide();
	self.CatalogShopVCFrame:Hide();
	self.CatalogShopUnavailableScreenFrame:Show();
end

function CatalogShopMixin:HideUnavailableScreen()
	self.CatalogShopUnavailableScreenFrame:Hide();

	self.BackgroundContainer:Show();
	self.ProductContainerFrame:Show();
	self.CatalogShopDetailsFrame:Show();
	self.HeaderFrame:Show();
end

function CatalogShopMixin:ShowAfterCheckout()
	self:SetAlpha(1);
	self.ModelSceneContainerFrame:Show();
end

function CatalogShopMixin:HideForCheckout()
	self:SetAlpha(0);

	-- Some model scene effects may need to be explicitly hidden.
	self.ModelSceneContainerFrame:Hide();
end

function CatalogShopMixin:OnEvent_CatalogShop(event, ...)
	if event == "CATALOG_SHOP_DATA_REFRESH" then
		local shoppingSessionUUIDStr = ...;
		if shoppingSessionUUIDStr and (shoppingSessionUUIDStr ~= self.shoppingSessionUUIDStr) then
			return;
		end

		self.categoryIDs = C_CatalogShop.GetAvailableCategoryIDs();

		-- Empty list of categories makes the shop unusable
		if (self.categoryIDs == nil) or (#self.categoryIDs == 0) then
			self.failedLoad = true;
			self:HideLoadingScreen();
			self:ShowUnavailableScreen();
		end

		self.HeaderFrame:SetCategories(self.categoryIDs);
		EventRegistry:TriggerEvent("CatalogShop.DataRefreshed");
	elseif event == "CATALOG_SHOP_REBUILD_SCROLL_BOX" then
		local resetSelection = false;
		self.ProductContainerFrame:UpdateProducts(resetSelection);
	elseif event == "CATALOG_SHOP_SPECIFIC_PRODUCT_REFRESH" then
		if not self:IsShown() then
			return;
		end

		local productID = ...;
		if self.ProductContainerFrame:IsShown() then
			self.ProductContainerFrame:UpdateSpecificProduct(productID);
		elseif self.ProductDetailsContainerFrame:IsShown() then
			self.ProductDetailsContainerFrame:UpdateSpecificProduct(productID);
		elseif self.ProductBYOBContainerFrame:IsShown() then
			self.ProductBYOBContainerFrame:UpdateProductInfo(self:GetSelectedProductInfo());
		end
	elseif event == "CATALOG_SHOP_OPEN_SIMPLE_CHECKOUT" then
		--... handle it
	elseif event =="SIMPLE_CHECKOUT_CLOSED" then
		self:ShowAfterCheckout();

		if self.justPurchasedProductID then
			C_Timer.After(0.25, function ()
				EventRegistry:TriggerEvent("CatalogShop.CelebratePurchase", self.justPurchasedProductID);
				self.justPurchasedProductID = nil;
			end);
		end

	elseif event =="CATALOG_SHOP_FETCH_SUCCESS" then
		local shoppingSessionUUIDStr = ...;
		if shoppingSessionUUIDStr and (shoppingSessionUUIDStr ~= self.shoppingSessionUUIDStr) then
			return;
		end

		if self.failedLoad then
			return;
		end

		self:HideLoadingScreen();
		self:HideUnavailableScreen();

		if InputUtil.IsGamepadUIEnabled() then
			CatalogShopOutbound.SetupGamepad(self);
			CatalogShopOutbound.RefreshSmartNav(self);
		end
	elseif event =="CATALOG_SHOP_FETCH_FAILURE" then
		local shoppingSessionUUIDStr = ...;
		if shoppingSessionUUIDStr and (shoppingSessionUUIDStr ~= self.shoppingSessionUUIDStr) then
			return;
		end

		-- handle error
		self.failedLoad = true;
		self:HideLoadingScreen();
		self:ShowUnavailableScreen();
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
		--self:ShowUnavailableScreen();
		local err, internalErr = C_CatalogShop.GetFailureInfo();
		self:OnError(err, true, internalErr);
	elseif ( event == "STORE_PURCHASE_ERROR" ) then
		-- TODO fix this C_StoreSecure call
		--self:ShowUnavailableScreen();
		local err, internalErr = C_StoreSecure.GetFailureInfo();
		self:OnError(err, true, internalErr);
	elseif ( event == "TOKEN_MARKET_PRICE_UPDATED" ) then
		--local result = ...;
		--if (StoreFrame_GetSelectedCategoryID() == WOW_TOKEN_CATEGORY_ID) then
			--StoreFrame_SetCategory();
		--end
	elseif ( event == "TOKEN_STATUS_CHANGED" ) then
		--StoreFrame_CheckMarketPriceUpdates();
	elseif (event == "UI_SCALE_CHANGED") then
		FrameUtil.UpdateScaleForFitSpecific(self, self:GetWidth() + CatalogShopConstants.ScreenPadding.Horizontal, self:GetHeight() + CatalogShopConstants.ScreenPadding.Vertical);
	elseif (event == "CATALOG_SHOP_VIRTUAL_CURRENCY_BALANCE_UPDATE") then
		local currencyCode, balance = ...;
		if CatalogShopUtil.IsValidVC(currencyCode) then
			-- This updates the states that we use to keep from showing until we are ready. Should happen before CatalogShopVCFrame:OnShow().
			if self.CatalogShopVCFrame.vcInitState ~= Enum.VcInitState.VcIsInitialized and C_CatalogShop.IsFinishedLoadingVirtualCurrencies() then
				self.CatalogShopVCFrame.vcInitState = Enum.VcInitState.VcIsInitialized;
			end
			-- CatalogShopVCFrame:OnShow() will try to show the frame.
			-- This should happen regardless of if we initialized so we handle periodic updates.
			-- Due to this, I've moved all of the display logic into it.
			-- That will identify if we've initialized, what the current VC is, load the adequate balance, and then show.
			-- Specifically calling it since running CatalogShopVCFrame:SetShown(true) from here does not go through there.
			self.CatalogShopVCFrame:OnShow();
		end
	elseif (event == "CATALOG_SHOP_REFUNDABLE_DECORS_UPDATED") then
		self.PersistentRefundContainerFrame:UpdateState();

		-- TODO (WOW12-45327): Clean up this selected product logic
		local selectedProductInfo = self:GetSelectedProductInfo();
		if (selectedProductInfo) then
			self.CatalogShopDetailsFrame:UpdateState();
		end
	elseif (event == "SET_SEEN_PRODUCTS") then
		local productIds = ...;
		if not CatalogShopOutbound.SavedSet_HasAny() then
			CatalogShopOutbound.SavedSet_Set(productIds);
		end
	elseif (event == "BULK_PURCHASE_RESULT_RECEIVED") then
		local result, productResults, topUpProductID, purchaseAmount = ...;
		if (result == Enum.BulkPurchaseResult.ResultInsufficientFunds) then
			if self.CatalogShopVCFrame then
				local vcCurrencyCode = CatalogShopUtil.GetSelectedCurrencyCode() or Constants.CatalogShopVirtualCurrencyConstants.HEARTHSTEEL_VC_CURRENCY_CODE;
				-- The only virtual currency that we currently allow to be purchased, and so topped up, is HEARTHSTEEL_VC_CURRENCY_CODE.
				-- HandleInsufficientFunds only prepares the top up flow window which we don't want to show with other VC.
				if CatalogShopUtil.VCTopUpFrameEnabled(vcCurrencyCode) then
					self.CatalogShopVCFrame:HandleInsufficientFunds(topUpProductID, purchaseAmount, vcCurrencyCode);
				end
			end
		end
	elseif (event == "BULK_REFUND_RESULT_RECEIVED") then
		local result = ...;
		if (result == Enum.BulkRefundResult.ResultOk) then
			-- Refreshing all current VC on refund.
			C_CatalogShop.RefreshVirtualCurrencyBalance("");
		end
	elseif event == "BN_DISCONNECTED" then
		self:Hide();
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
			local loginState = C_Login.GetState();
			if ( loginState.wowConnectionState ~= LE_WOW_CONNECTION_STATE_IN_QUEUE ) then
				return true;
			end
		end
	end
	return false;
end

function CatalogShopMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CATALOG_SHOP_DYNAMIC_EVENTS);

	self:HideUnavailableScreen();
	self:ShowLoadingScreen();
	self:SetAttribute("isshown", true);

	if ( not C_Glue.IsOnGlueScreen() ) then
		CatalogShopOutbound.UpdateMicroButtons();
	else
		GlueParent_AddModalFrame(self);
	end
	FrameUtil.UpdateScaleForFitSpecific(self, self:GetWidth() + CatalogShopConstants.ScreenPadding.Horizontal, self:GetHeight() + CatalogShopConstants.ScreenPadding.Vertical);

	-- We may have already retrieved this when we were fired off from the rewards buttons.
	if not self.shoppingSessionUUIDStr then
		self.shoppingSessionUUIDStr = C_CatalogShop.OpenCatalogShopInteractionFromShop();
	end

	if CanAutoSetGamePadCursorControl(true) then
		SetGamePadCursorControl(true);
	end

	local isShown = true;
	CatalogShopOutbound.VisibilityUpdated(isShown);
	
	if InputUtil.IsGamepadUIEnabled() then
		CatalogShopOutbound.SetupGamepad(self);
		CatalogShopOutbound.HandleGamepadFrameShown(self);
	end
end

function CatalogShopMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CATALOG_SHOP_DYNAMIC_EVENTS);

	local wasRewardsShopInteraction = self.isRewardsShopInteraction;
	self.isRewardsShopInteraction = false;
	self:SetAttribute("isshown", false);

	if ( not C_Glue.IsOnGlueScreen() ) then
		CatalogShopOutbound.UpdateMicroButtons();
	else
		GlueParent_RemoveModalFrame(self);
		CatalogShopOutbound.UpdateDialogs();
	end

	local scrollBox = self.ProductContainerFrame.ProductsScrollBoxContainer.ScrollBox;
	if scrollBox then
		scrollBox:FlushDataProvider();
		self.ProductContainerFrame:SetSelectedProductInfo(nil);
	end

	scrollBox = self.ProductDetailsContainerFrame.DetailsProductContainerFrame.ProductsScrollBoxContainer.ScrollBox;
	if scrollBox then
		scrollBox:FlushDataProvider();
		self.ProductDetailsContainerFrame.DetailsProductContainerFrame:SetSelectedProductInfo(nil);
	end

	C_CatalogShop.CloseCatalogShopInteraction();
	if wasRewardsShopInteraction then
		C_PlayerInteractionManager.ClearInteraction(Enum.PlayerInteractionType.RewardsShop);
	end
	SimpleCheckout:Hide();
	self:HidePreviewFrames();
	self.ProductDetailsContainerFrame:Hide();
	self.ForegroundContainer:Hide();
	self:SetCatalogShopLinkTag(nil);
	self:HideLoadingScreen();
	self.shoppingSessionUUIDStr = nil;
	self.failedLoad = false;
	PlaySound(SOUNDKIT.CATALOG_SHOP_CLOSE_SHOP);

	local isShown = false;
	CatalogShopOutbound.VisibilityUpdated(isShown);

	if InputUtil.IsGamepadUIEnabled() then
		CatalogShopOutbound.HandleGamepadFrameHidden(self);
	end

	if CanAutoSetGamePadCursorControl(false) then
		SetGamePadCursorControl(false);
	end

	-- If we are closing the window we will want to reinit.
	self.CatalogShopVCFrame.vcInitState = Enum.VcInitState.VcIsReset;
	self.CatalogShopVCFrame.selectedVC = nil;
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

function CatalogShopMixin:GetCatalogShopLinkTag()
	return self.linkTag; -- ok to be nil
end

function CatalogShopMixin:SetCatalogShopLinkTag(linkTag)
	if self:IsShown() then
		self.HeaderFrame.CatalogShopNavBar:SelectCategoryByLinkTag(linkTag);
		self.linkTag = nil;
	else
		self.linkTag = linkTag;
	end
end

-- This is done in this way to keep the navigation mixin separate from as much of the internals of product linking as possible.
-- The goal of this function is to prime linkTag such that if we are linking to a product we can also use the category link flow
-- that works when we do simple category linking. See NavigationBarMixin:Init
function CatalogShopMixin:SetCatalogShopLinkTagForLinkProduct()
	if not self.linkProductID then
		return;
	end
	local categoryInfo = C_CatalogShop.GetFirstCategoryByProductID(self.linkProductID);
	if categoryInfo then
		self.linkTag = categoryInfo.linkTag;
	end
end

function CatalogShopMixin:GetCatalogShopLinkProductID()
	return self.linkProductID; -- can be nil
end

function CatalogShopMixin:SetCatalogShopLinkProductID(linkProductID)
	self.linkProductID = linkProductID;
end

function CatalogShopMixin:OnAttributeChanged(name, value)
	--Note - Setting attributes is how the external UI should communicate with this frame. That way their taint won't be spread to this code.
	if ( name == "action" ) then
		if ( value == "Show" ) then
			self:Show();
		elseif ( value == "Hide" ) then
			self:Hide();
		elseif ( value == "ShowRewardsShop" ) then
			self:ShowRewardsShop();
		elseif ( value == "HideRewardsShop" ) then
			self:HideRewardsShop();
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
			end
			self:SetAttribute("escaperesult", handled);
		end
	elseif ( name == "selectsubscription" ) then
		-- Subscriptions are now in the Game Upgrade Category
		self:SetCatalogShopLinkTag(CatalogShopConstants.CategoryLinks.GameUpgrades);
	elseif ( name == "selectgametime" ) then
		self:SetCatalogShopLinkTag(CatalogShopConstants.CategoryLinks.GameTime);
	elseif ( name == "settokencategory" ) then
		-- the WoW Token is in the Services Category
		self:SetCatalogShopLinkTag(CatalogShopConstants.CategoryLinks.Services);
	elseif ( name == "checkforfree" ) then
		-- legacy - this is no longer used
		--assertsafe(false, "ASSERT - for Cash Shop 2.0 this is a no-op.  If you get this error, contact the Shop Team Engineers.");
	elseif ( name == "opengamescategory" ) then
		self:Show();
		self:SetCatalogShopLinkTag(CatalogShopConstants.CategoryLinks.GameUpgrades);
	elseif ( name == "setgamescategory" ) then
		self:SetCatalogShopLinkTag(CatalogShopConstants.CategoryLinks.GameUpgrades);
	elseif ( name == "setservicescategory" ) then
		self:SetCatalogShopLinkTag(CatalogShopConstants.CategoryLinks.Services);
	elseif ( name == "selectboost") then
		self:SetCatalogShopLinkTag(CatalogShopConstants.CategoryLinks.Services);
	elseif ( name == "selectspecificproduct" ) then
		local productID = value;
		self:SetCatalogShopLinkProductID(productID);
	end
end

function CatalogShopMixin:Leave()
	--... handle leaving
	self:Hide();
end

function CatalogShopMixin:ShowError(title, desc, urlIndex, needsAck)
	self.CatalogShopErrorFrame:ShowError(title, desc, urlIndex, needsAck);
end

function CatalogShopMixin:OnError(errorID, needsAck, internalErr)
	local title, msg, link = ErrorLookupInterface.GetErrorMessage(errorID);

	if ( IsGMClient() and not HideGMOnly() ) then
		self:ShowError(title.." ("..internalErr..")", msg, link, needsAck);
	else
		self:ShowError(title, msg, link, needsAck);
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

	local completelyOwned = productInfo.isFullyOwned;
	if completelyOwned then
		self:OnError(Enum.StoreError.AlreadyOwned, false, "FakeOwned");
	else
		if productInfo.isVCProduct then
			local productIDList = {productInfo.catalogShopProductID};
			C_CatalogShop.ConfirmVCProductPurchase(productIDList);
		else
			C_CatalogShop.PurchaseProduct(productInfo.catalogShopProductID);
		end
	end
end

function CatalogShopMixin:PurchaseBYOB()
	local productInfo = self:GetSelectedProductInfo();
	if not productInfo then
		return;
	end

	if not BYOBInterface.AllChoicesCompleted() then
		return;
	end

	local selectedProductIDs = {};
	for _, selectionGroupChoices in pairs(BYOBInterface.SelectionGroupChoices) do
		for productID, isChecked in pairs(selectionGroupChoices) do
			if isChecked then
				table.insert(selectedProductIDs, productID);
			end
		end
	end

	C_CatalogShop.PurchaseProductWithSelectedProducts(productInfo.catalogShopProductID, selectedProductIDs);
end

function CatalogShopMixin:HideProductDetails()
	-- clear the product we had selected for the details frame
	self.ProductDetailsContainerFrame.DetailsProductContainerFrame:SetSelectedProductInfo(nil);
	local productInfo = self.ProductContainerFrame:GetSelectedProductInfo();
	self.showDetails = false;
	self:ToggleProductDetails(self.showDetails, productInfo);

	if InputUtil.IsGamepadUIEnabled() then
		CatalogShopOutbound.HideProductDetails(self);
	end
end

function CatalogShopMixin:HideProductBYOB()
	self.ProductBYOBContainerFrame.BYOBProductContainerFrame:SetSelectedProductInfo(nil);
	local productInfo = self.ProductContainerFrame:GetSelectedProductInfo();
	self.showBYOB = false;
	self:ToggleProductBYOB(self.showBYOB, productInfo);
end

function CatalogShopMixin:ShowProductDetails()
	local productInfo = self:GetSelectedProductInfo();
	-- Dont show details if nothing is selected
	if not productInfo then
		return;
	end

	if productInfo.cardDisplayData and productInfo.cardDisplayData.productType == CatalogShopConstants.ProductType.BYOB then
		self.showBYOB = true;
		self:ToggleProductBYOB(self.showBYOB, productInfo);
		return;
	end

	self.showDetails = true;
	self:ToggleProductDetails(self.showDetails, productInfo);

	if InputUtil.IsGamepadUIEnabled() then
		CatalogShopOutbound.ShowProductDetails(self);
	end
end

function CatalogShopMixin:ShowAllRefundableDecor()
	CatalogShopOutbound.ShowRefundFlow();
end

function CatalogShopMixin:ShowSelectedRefundableDecor()
	local selectedProductInfo = self:GetSelectedProductInfo();
	if not selectedProductInfo then
		return;
	end

	CatalogShopOutbound.ShowRefundFlow(selectedProductInfo.catalogShopProductID);
end

function CatalogShopMixin:AcceptError()
	if self.CatalogShopErrorFrame.ErrorNeedsAck then
		-- TODO fix this C_StoreSecure call
		C_StoreSecure.AckFailure();
	end
	self.CatalogShopErrorFrame:Hide();
	PlaySound(SOUNDKIT.CATALOG_SHOP_SELECT_GENERIC_UI_BUTTON);
end

function CatalogShopMixin:WebsiteError()
end

function CatalogShopMixin:OnProductSelected(data)
	-- Background texture fills the whole window and is behind everything
	local overrideURL = data and data.previewBGOverrideProductURL;
	if overrideURL then
		-- is there a full screen URL specified in PMT?
		self.BackgroundContainer:SetBackgroundTextureFromPMT(overrideURL);
	else
		-- if not, use the texture set in PMT attributes or the default
		local backgroundTexture = data and data.backgroundTexture or nil;
		if backgroundTexture and backgroundTexture ~= "" then
			self.BackgroundContainer:SetBackgroundTexture(backgroundTexture);
		else
			self.BackgroundContainer:SetBackgroundTexture(CatalogShopConstants.Default.PreviewBackgroundTexture);
		end
	end

	if data.isBundle then
		if data.cardDisplayData and data.cardDisplayData.productType == CatalogShopConstants.ProductType.BYOB then
			-- BYOB - do icon train
		else
			local bundleChildInfo = C_CatalogShop.GetProductIDsForBundle(data.catalogShopProductID);
			self.IconTrainFrame:Init(bundleChildInfo);
		end
	else
		self.IconTrainFrame:Hide();
	end

	local smallOverrideURL = data and data.previewSmallBGOverrideProductURL;
	if smallOverrideURL then
		-- do we want to show the small PMT image frame?
		local texture = CatalogShopFrame.PMTImageContainerFrame.PMTImageForNoModel;
		C_Texture.SetURLTexture(texture, smallOverrideURL);
		CatalogShopFrame.PMTImageContainerFrame:Show();
	end

	-- Foreground texture fills the whole window and is in front of the background texture
	local foregroundTexture = data and data.foregroundTexture or nil;
	if foregroundTexture and foregroundTexture ~= "" then
		self.ForegroundContainer.Foreground:SetAtlas(foregroundTexture);
		self.ForegroundContainer:Show();
	else
		self.ForegroundContainer:Hide();
	end

	-- Show the right side details frame if our product container frame is shown OR if the selected product is a bundle (enables purchase and details)
	local selectedProductInfo = CatalogShopFrame:GetSelectedProductInfo();
	local showDetails = self.ProductContainerFrame:IsShown() or (selectedProductInfo and selectedProductInfo.isBundle)
	self.CatalogShopDetailsFrame:SetShown(showDetails);

	local showVCFrame = selectedProductInfo and selectedProductInfo.isVCProduct;
	self.CatalogShopVCFrame:SetShown(showVCFrame);
end

function CatalogShopMixin:OnNoProductsSelected()
	self.BackgroundContainer:SetBackgroundTexture(CatalogShopConstants.NoResults.BackgroundTexture);
	self:HidePreviewFrames();
	self.CatalogShopDetailsFrame:Hide();
	self.CatalogShopVCFrame:Hide();
end

function CatalogShopMixin:OnCategorySelected(categoryID)
	-- Close the details and BYOB frames if either is open
	local showDetailsFrame = false;
	local productInfo = nil;
	self:ToggleProductDetails(showDetailsFrame, productInfo);
	self:ToggleProductBYOB(showDetailsFrame, productInfo);

	self.ProductContainerFrame:OnCategorySelected(categoryID);
	self.PersistentRefundContainerFrame:OnCategorySelected(categoryID);

	if self.showDetails then
		CatalogShopFrame:HideProductDetails();
	end
end

function CatalogShopMixin:ToggleProductDetails(showDetails, productInfo)
	self.ProductContainerFrame:SetShown(not showDetails);
	self.ProductDetailsContainerFrame:SetShown(showDetails);

	local showVCFrame = not showDetails and (productInfo and productInfo.isVCProduct);
	self.CatalogShopVCFrame:SetShown(showVCFrame);

	self.CatalogShopDetailsFrame:SetShown(not showDetails);
	self.CatalogShopDetailsFrame.ButtonContainer:SetShown(not showDetails);
	if showDetails then
		self.ProductDetailsContainerFrame:UpdateProductInfo(productInfo);
	elseif productInfo then
		self.ProductContainerFrame:TrySelectProduct(productInfo);
	end
	self.CatalogShopDetailsFrame:MarkDirty();
	self.PersistentRefundContainerFrame:UpdateState();
	self.PMTImageContainerFrame:SetDetailsShown(showDetails);
end

function CatalogShopMixin:ToggleProductBYOB(showBYOB, productInfo)
	self.ProductContainerFrame:SetShown(not showBYOB);
	self.ProductBYOBContainerFrame:SetShown(showBYOB);

	local showVCFrame = not showBYOB and (productInfo and productInfo.isVCProduct);
	self.CatalogShopVCFrame:SetShown(showVCFrame);

	self.CatalogShopDetailsFrame:SetShown(not showBYOB);
	self.CatalogShopDetailsFrame.ButtonContainer:SetShown(not showBYOB);
	if showBYOB then
		self.ProductBYOBContainerFrame:UpdateProductInfo(productInfo);
	elseif productInfo then
		self.ProductContainerFrame:TrySelectProduct(productInfo);
	end
	self.CatalogShopDetailsFrame:MarkDirty();
	self.PersistentRefundContainerFrame:UpdateState();
	self.PMTImageContainerFrame:SetDetailsShown(showBYOB);
end

function CatalogShopMixin:FormatTimeLeft(secondsRemaining, formatter)
	local text = formatter:Format(secondsRemaining);
	return WHITE_FONT_COLOR:WrapTextInColorCode(text);
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

function CatalogShopMixin:CanRotateCurrentProduct()
	return self.canRotateModelScene;
end

function CatalogShopMixin:InitializeGamepad()
	if not InputUtil.IsGamepadUIEnabled() then
		return;
	end

	CatalogShopFrameCloseButton:Hide();
	self.ProductDetailsContainerFrame.BackButton:Hide();
	self.CatalogShopDetailsFrame.ButtonContainer.PurchaseButton:Hide();
	self.CatalogShopDetailsFrame.ButtonContainer.DetailsButton:Hide();

	local carousel = self.CatalogShopDetailsFrame.CarouselContainer;
	carousel.CarouselLeftButton:Hide();
	carousel.CarouselRightButton:Hide();
end

function CatalogShopMixin:FocusGamepad()
	if not InputUtil.IsGamepadUIEnabled() then
		return;
	end

	CatalogShopOutbound.FocusGamepad(self);
end

function CatalogShopMixin:UnfocusGamepad()
	if not InputUtil.IsGamepadUIEnabled() then
		return;
	end

	CatalogShopOutbound.UnfocusGamepad(self);
end

----------------------------------------------------------------------------------
-- CatalogShopVCFrameMixin
----------------------------------------------------------------------------------
CatalogShopVCFrameMixin = {
	vcInitState = Enum.VcInitState.VcIsReset;
	selectedVC = nil;
};
function CatalogShopVCFrameMixin:OnLoad()
	-- Refreshing VC when data is loaded, this allows GetVirutalCurrencyBalance can be called safely OnShow
	EventRegistry:RegisterCallback("CatalogShop.DataRefreshed", self.RefreshAllVC, self);
	EventRegistry:RegisterCallback("CatalogShop.OnVCUpdated", self.OnVCUpdated, self);
end

function CatalogShopVCFrameMixin:OnVCUpdated(amount)
	amount = tonumber(amount);
	if amount then
		self.vcAmount:SetText(amount);
		LayoutMixin.Layout(self);
	end
end

function CatalogShopVCFrameMixin:RefreshVC(currencyCode)
	if currencyCode then
		C_CatalogShop.RefreshVirtualCurrencyBalance(currencyCode);
	else
		C_CatalogShop.RefreshVirtualCurrencyBalance(""); -- This will refresh the VC for all types.
	end
	-- Call to C_CatalogShop.RefreshVirtualCurrencyBalance will trigger CatalogShop.OnVCUpdated
end

function CatalogShopVCFrameMixin:RefreshAllVC()
	self:RefreshVC(nil);
end

function CatalogShopVCFrameMixin:CancelRefreshTicker()
	if self.periodicRefreshTicker then
		self.periodicRefreshTicker:Cancel();
		self.periodicRefreshTicker = nil;
	end
end

local VC_FRAME_LAYOUT_INFO = {
	[Constants.CatalogShopVirtualCurrencyConstants.HEARTHSTEEL_VC_CURRENCY_CODE] = {
		atlas = CatalogShopConstants.VCIcon.Hearthsteel,
		rightPadding = 0,
		vcPurchaseButtonShown = true,
	},
	[Constants.CatalogShopVirtualCurrencyConstants.TALEBOUND_VC_CURRENCY_CODE] = {
		atlas = CatalogShopConstants.VCIcon.Talebound,
		rightPadding = 13,
		vcPurchaseButtonShown = false,
	},
}

function CatalogShopVCFrameMixin:SetShown(show)
	if show then
		self:OnShow();
	else
		self:Hide();
	end
end

function CatalogShopVCFrameMixin:OnShow()
	-- I've added the following set of early exits to clean up the early display of the frame before the VC data has been loaded.
	-- When we open a shop frame we will load all of the products from the pop and prepare the set of VC currency codes (see RefreshAllVC).
	-- If we load on a product that using VC however this frame would load and display an invalid value until we update.
	-- To catch that, we're using a couple of bools to represent initing and init states which will early exit in a hidden state.
	-- To ensure we're displaying once we have the correct VC loaded, in the CATALOG_SHOP_VIRTUAL_CURRENCY_BALANCE_UPDATE event,
	--	I added IsFinishedLoadingVirtualCurrencies() which will check a set I've added to track the currencies we've requested.
	-- On the last VC returning we update the init vars, and come back to this method.
	-- If we had a VC product selected, this will happen if the first product when you open is a VC one, then we'll come through here
	--	and update it if it's not what's currently set and display.
	-- If that last run through here happens on a non VC product we just early exit since we won't have a selectedVC and so shouldn't display.
	-- Once we come back to here from changing tabs and selecting a product, we will already be initilaized, update the VC and display.

	if self.vcInitState == Enum.VcInitState.VcIsInitializing then
		-- If we're already initializing the VC let's just early exit.
		return;
	elseif self.vcInitState ~= Enum.VcInitState.VcIsInitialized then
		-- Let's mark ourselves as initializing as we made it here before we loaded VC currencies.
		self.vcInitState = Enum.VcInitState.VcIsInitializing;

		-- Hide until we've initialized.
		self:Hide();
		return;
	end

	-- We must have a product selected for this VC Frame to load.
	self.selectedVC = CatalogShopUtil.GetSelectedCurrencyCode();
	if not self.selectedVC then
		-- If we can not find a VC code then lets hide as we won't know what to display.
		self:Hide();
		return;
	end

	-- Make sure that we have a value before we display.
	local currentVCBalance = C_CatalogShop.GetVirtualCurrencyBalance(self.selectedVC);
	if not currentVCBalance then
		self:Hide();
		return;
	end

	-- Updating the formatting just before we need it.
	local layoutInfo = VC_FRAME_LAYOUT_INFO[self.selectedVC];
	self.vcIcon:SetAtlas(layoutInfo.atlas);
	self.vcIcon.rightPadding = layoutInfo.rightPadding;
	self.vcPurchaseButton:SetShown(layoutInfo.vcPurchaseButtonShown);

	-- Finally show it. Reordering to ensure the value is up to date before we show.
	self:OnVCUpdated(currentVCBalance);
	LayoutMixin.OnShow(self);
	self:CancelRefreshTicker();
	local refreshCurrencyTimeSeconds = 20;
	self.periodicRefreshTicker = C_Timer.NewTicker(refreshCurrencyTimeSeconds, function() self:RefreshVC(); end);
	self:Show();
end

function CatalogShopVCFrameMixin:OnHide()
	self:CancelRefreshTicker();
	EventRegistry:UnregisterCallback("CatalogShop.OnVCUpdated", self);
end

function CatalogShopVCFrameMixin:HandleInsufficientFunds(suggestedProductID, purchaseAmount, currencyCode)
	if CatalogShopTopUpFrame then
		local vcBalance = C_CatalogShop.GetVirtualCurrencyBalance(currencyCode);
		if vcBalance then
			if purchaseAmount then
				CatalogShopTopUpFrame:SetDesiredQuantity(purchaseAmount);
			end
			CatalogShopTopUpFrame:SetCurrentBalance(vcBalance);
		end
		if suggestedProductID then
			CatalogShopTopUpFrame:SetSuggestedProduct(suggestedProductID);
		end
		CatalogShopTopUpFrame:SetParentFrame(self:GetParent());
		CatalogShopTopUpFrame:Show();
	end
end

function CatalogShopVCFrameMixin:OpenTopUpFlow()
	if CatalogShopTopUpFrame then
		local hearthsteelBalance = C_CatalogShop.GetVirtualCurrencyBalance(Constants.CatalogShopVirtualCurrencyConstants.HEARTHSTEEL_VC_CURRENCY_CODE);
		if hearthsteelBalance then
			CatalogShopTopUpFrame:SetCurrentBalance(hearthsteelBalance);
		end

		local shouldShowWarning = C_CatalogShop.ShouldShowHousingWarning();
		CatalogShopTopUpFrame.TopUpProductContainerFrame.HousingWarningText:SetShown(shouldShowWarning);

		CatalogShopTopUpFrame:SetParentFrame(self:GetParent());
		CatalogShopTopUpFrame:Show();
	end
end

----------------------------------------------------------------------------------
-- CatalogShopProductDetailsFrameMixin
----------------------------------------------------------------------------------
CatalogShopProductDetailsFrameMixin = {};
function CatalogShopProductDetailsFrameMixin:OnLoad()
	EventRegistry:RegisterCallback("CatalogShopModel.OnProductSelectedAfterModel", self.SetDetailsFrameProductInfo, self);
	EventRegistry:RegisterCallback("CatalogShopModel.OnProductSelectEarlyOut", self.SetDetailsFrameProductInfo, self);
	EventRegistry:RegisterCallback("CatalogShop.OnProductInfoChanged", self.OnProductInfoChanged, self);
	EventRegistry:RegisterCallback("CatalogShop.OnBundleChildSelected", self.SetDetailsFrameProductInfo, self);
	self.currentProductInfo = nil;
end

function CatalogShopProductDetailsFrameMixin:SetDetailsFrameProductInfo(productInfo)
	self.currentProductInfo = productInfo;
	self:UpdateState();
end

function CatalogShopProductDetailsFrameMixin:GetDetailsFrameProductInfo()
	return self.currentProductInfo;
end


function CatalogShopProductDetailsFrameMixin:UpdateState()
	CatalogShopFrame:HideLoadingScreen();
	CatalogShopFrame.CatalogShopDetailsFrame:SetShown(true);

	local selectedProductInfo = self:GetDetailsFrameProductInfo();
	local displayInfo = C_CatalogShop.GetCatalogShopProductDisplayInfo(selectedProductInfo.catalogShopProductID);

	-- We were walking into here very frequently. If we've already done it and so are initalizing, don't again until it's initialized.
	if CatalogShopFrame.CatalogShopVCFrame.vcInitState ~= Enum.VcInitState.VcIsInitializing then
		local showVCFrame = selectedProductInfo and selectedProductInfo.isVCProduct;
		CatalogShopFrame.CatalogShopVCFrame:SetShown(showVCFrame);
	end

	-- do we need to show the housing decor warning?
	local containsHousingItem = selectedProductInfo.containsHousingItem;
	local showHousingWarning = containsHousingItem and C_CatalogShop.ShouldShowHousingWarning();
	self.HousingWarningText:SetShown(showHousingWarning);

	-- setup button container buttons
	local showBYOBButton = displayInfo.productType == CatalogShopConstants.ProductType.BYOB;

	self.ButtonContainer.PurchaseButton:SetShown(not showBYOBButton);
	self.ButtonContainer.DetailsButton:SetShown(not showBYOBButton);
	self.ButtonContainer.BYOBButton:SetShown(showBYOBButton);

	if showBYOBButton then
		local totalQuantity = 0;
		for _, selectionGroupInfo in ipairs(selectedProductInfo.selectionGroupInfos) do
			totalQuantity = totalQuantity + (selectionGroupInfo.quantity or 0);
		end

		local priceBYOBString = string.format(CATALOG_SHOP_BYOB_PRICE_FORMAT, totalQuantity, selectedProductInfo.price);
		self.ButtonContainer.BYOBButton:SetText(priceBYOBString);
		self.ButtonContainer.BYOBButton:SetEligible(selectedProductInfo.purchaseEligibility == Enum.CatalogShopPurchaseEligibility.Eligible);
	else
		if selectedProductInfo.isVCProduct then
			self.ButtonContainer.PurchaseButton:SetText(selectedProductInfo.price.." "..CatalogShopUtil.GetVCMarkupByProductInfo(selectedProductInfo));
		else
			self.ButtonContainer.PurchaseButton:SetText(selectedProductInfo.price);
		end
	end

	self.ProductName:SetText(selectedProductInfo.name);

	local descriptionStr = CatalogShopUtil.GetDescriptionText(selectedProductInfo);
	if (descriptionStr == "") then
		self.ProductDescription:SetShown(false);
	else
		self.ProductDescription:SetShown(true);
		self.ProductDescription:SetText(descriptionStr);
	end

	-- Let's prepare the string for display.
	if not selectedProductInfo.hasAllRequiredAchievements and selectedProductInfo.missingAchievementName then
		local achievementsString = selectedProductInfo.missingAchievementName;
		if achievementsString == "" then
			self.MissingAchievementWarningText:SetShown(false);
		else
			achievementsString = string.format(SERVER_VALIDATION_PRODUCT_MISSING_ACHIEVEMENT, achievementsString);
			if C_CatalogShop.BypassAchievementRequirement() then
				achievementsString = string.format(Constants.CatalogShopAchievementServerValidationConstants.SERVER_VALIDATION_BYPASS_FORMAT, achievementsString);
			end

			self.MissingAchievementWarningText:SetShown(true);
			self.MissingAchievementWarningText:SetText(achievementsString);
		end
	else
		self.MissingAchievementWarningText:SetShown(false);
	end

	if C_GameRules.IsGameRuleActive(Enum.GameRule.UsesTemporaryCharacters) and C_CatalogShop.ShouldDisplayUsesTemporaryCharactersWarningText(selectedProductInfo.catalogShopProductID) then
		self.UsesTemporaryCharactersWarningText:SetText(USES_TEMPORARY_CHARACTERS_WARNING_TEXT);
		self.UsesTemporaryCharactersWarningText:SetShown(true);
	else
		self.UsesTemporaryCharactersWarningText:SetShown(false);
	end

	local productTypeStr = CatalogShopUtil.GetTypeText(selectedProductInfo);
	if (productTypeStr) then
		self.ProductType:SetShown(true);
		self.ProductType:SetText(productTypeStr);
	else
		self.ProductType:SetShown(false);
	end

	if (selectedProductInfo.decorQuantity ~= nil) then
		local placedQuantity = selectedProductInfo.decorQuantity.placedQuantity;
		local storedQuantity = selectedProductInfo.decorQuantity.storedQuantity;
		local totalQuantity = placedQuantity + storedQuantity;

		if (selectedProductInfo.isBundle) then
			self.QuantityOwned:SetShown(totalQuantity > 0 and (not selectedProductInfo.isFullyOwned));
			self.QuantityOwned:SetText(HouseChestAtlasMarkup.." "..CATALOG_SHOP_DECOR_BUNDLE_OWNED);
			self.QuantityOwned.tooltip = {
				name = CATALOG_SHOP_DECOR_BUNDLE_OWNED,
				description = CATALOG_SHOP_DECOR_BUNDLE_OWNED_TOOLTIP,
			};
		else
			self.QuantityOwned:Show();
			self.QuantityOwned:SetText(HouseChestAtlasMarkup.." "..string.format(CATALOG_SHOP_DECOR_INDIVIDUAL_OWNED, totalQuantity));
			self.QuantityOwned.tooltip = {
				name = string.format(CATALOG_SHOP_DECOR_INDIVIDUAL_OWNED, totalQuantity),
				description = string.format(CATALOG_SHOP_DECOR_INDIVIDUAL_OWNED_TOOLTIP, placedQuantity, storedQuantity),
			};
		end
	else
		self.QuantityOwned:Hide();
	end

	local isBundleChild = selectedProductInfo.isBundleChild;
	local showLegal = not isBundleChild and not selectedProductInfo.doNotShowWebString;
	self.LegalDisclaimerText:SetShown(showLegal);

	local function onHyperlinkClicked(frame, link, text, button)
		C_CatalogShop.OnLegalDisclaimerClicked(selectedProductInfo.catalogShopProductID);
	end
	self:SetScript("OnHyperlinkClick", onHyperlinkClicked);

	self.ProductRefundContainer:SetProductID(selectedProductInfo.catalogShopProductID);

	local isTokenOnGlues = (C_Glue.IsOnGlueScreen() and displayInfo.productType == CatalogShopConstants.ProductType.Token);
	local isPurchasable = (not isTokenOnGlues and not selectedProductInfo.isFullyOwned and (selectedProductInfo.hasAllRequiredAchievements or C_CatalogShop.BypassAchievementRequirement()) and (C_StorePublic.IsEnabled() or not C_StorePublic.IsRewardsShopOverrideEnabled()));
	local shouldShowPendingPurchasesText = isPurchasable and selectedProductInfo.hasPendingOrders;
	local shouldShowDynamicBundleDiscountText = isPurchasable and (not shouldShowPendingPurchasesText) and selectedProductInfo.isDynamicallyDiscounted;

	if selectedProductInfo.isVCProduct then
		self.ButtonContainer.PurchaseButton:SetText(selectedProductInfo.price.." "..CatalogShopUtil.GetVCMarkupByProductInfo(selectedProductInfo));
	else
		self.ButtonContainer.PurchaseButton:SetText(selectedProductInfo.price);
	end
	self.ButtonContainer.PurchaseButton:SetEnabled(isPurchasable);

	if InputUtil.IsGamepadUIEnabled() then
		CatalogShopOutbound.RefreshGamepadPurchaseButton(CatalogShopFrame);
	end

	-- Adjust for text fields
	self.ButtonContainer.NoPriceInGlues:SetShown(isTokenOnGlues);
	self.ButtonContainer.PendingPurchasesText:SetShown(shouldShowPendingPurchasesText);
	self.ButtonContainer.DynamicBundleDiscountText:SetShown(shouldShowDynamicBundleDiscountText);
	if isTokenOnGlues then
		self.ButtonContainer:SetSize(320, 80);
	elseif shouldShowPendingPurchasesText or shouldShowDynamicBundleDiscountText then
		self.ButtonContainer:SetSize(320, 60);
	else
		self.ButtonContainer:SetSize(320, 50);
	end

	self:MarkDirty();
end

-- This function is called when the main frame's product changes, and we want to verify that we're being told to be set to that frame's product only in this function.
-- This may read a bit confusing but it's because elements outside this heirarchy affect the CatalogShopFrame's seleted product and this function reacts to events fired
-- by anyone so extra guards are necessary
function CatalogShopProductDetailsFrameMixin:OnProductInfoChanged(productInfo)
	local selectedProductInfo = CatalogShopFrame:GetSelectedProductInfo();

	-- if the catalog shop frame's selected product was changed, update ourself
	if productInfo and selectedProductInfo and (productInfo.catalogShopProductID == selectedProductInfo.catalogShopProductID) then
		self:SetDetailsFrameProductInfo(productInfo);
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

function BackgroundContainerMixin:SetBackgroundTextureFromPMT(imageURL)
	if imageURL then
		self.currentBackground:SetDrawLayer("BACKGROUND", 1);
		self.nextBackground:SetDrawLayer("BACKGROUND", 2);
		C_Texture.SetURLTexture(self.nextBackground, imageURL);
		self.nextFadeIn:Play();
	end
end

----------------------------------------------------------------------------------
-- QuantityOwnedMixin
----------------------------------------------------------------------------------
QuantityOwnedMixin = {};
function QuantityOwnedMixin:OnEnter()
	if (self:IsShown() and self.tooltip ~= nil) then
		CatalogShopFrame:ShowTooltip(self, self.tooltip.name, self.tooltip.description);
	end
end

function QuantityOwnedMixin:OnLeave()
	CatalogShopFrame:HideTooltip();
end
