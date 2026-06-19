SwapToGlobalEnvironment();

local function ToggleActiveStoreUI(contextKey)
	local useNewCashShop = C_CatalogShop.IsShop2Enabled();
	if useNewCashShop then
		local wasShown = CatalogShopInboundInterface.IsShown();
		if (not wasShown) then
			securecall("CloseAllWindows");
		end
		CatalogShopInboundInterface.SetShown(not wasShown, contextKey);
	else
		local wasShown = StoreFrame_IsShown();
		if (not wasShown) then
			securecall("CloseAllWindows");
		end
		StoreFrame_SetShown(not wasShown, contextKey);
	end
end

local function SetLegacyStoreUIShown(shown)
	local wasShown = StoreFrame_IsShown();
	if (not wasShown and shown) then
		securecall("CloseAllWindows");
	end
	StoreFrame_SetShown(shown);
end

local function ActiveStoreEscapePressed()
	if CatalogShopTopUpFlowInboundInterface and CatalogShopTopUpFlowInboundInterface.EscapePressed and CatalogShopTopUpFlowInboundInterface.EscapePressed() then
		return true;
	end

	if CatalogShopRefundFlowInboundInterface and CatalogShopRefundFlowInboundInterface.EscapePressed and CatalogShopRefundFlowInboundInterface.EscapePressed() then
		return true;
	end

	local useNewCashShop = C_CatalogShop.IsShop2Enabled();
	if useNewCashShop then
		return CatalogShopInboundInterface.EscapePressed and CatalogShopInboundInterface.EscapePressed();
	end

	return StoreFrame_EscapePressed and StoreFrame_EscapePressed();
end

function CheckActiveStoreForFree(event)
	local useNewCashShop = C_CatalogShop.IsShop2Enabled();
	if useNewCashShop then
		CatalogShopInboundInterface.CheckForFree(event);
	else
		StoreFrame_CheckForFree(event);
	end
end

function ToggleStoreUI(contextKey)
	if (Kiosk.IsEnabled() or DISALLOW_FRAME_TOGGLING) then
		return;
	end

	ToggleActiveStoreUI(contextKey);
end

function SetStoreUIShown(shown)
	if (Kiosk.IsEnabled() or DISALLOW_FRAME_TOGGLING) then
		return;
	end

	SetLegacyStoreUIShown(shown);
end

function StoreEscapePressed()
	if ActiveStoreEscapePressed() then
		return true;
	end

	return WowTokenRedemptionFrame_EscapePressed and WowTokenRedemptionFrame_EscapePressed();
end

RegisterGameMenuEscHandler(GameMenuEscPriority.AddOn, SimpleCheckout_EscapePressed);
RegisterGameMenuEscHandler(GameMenuEscPriority.AddOn, ModelPreviewFrame_TryHide);
RegisterGameMenuEscHandler(GameMenuEscPriority.AddOn, StoreEscapePressed);
