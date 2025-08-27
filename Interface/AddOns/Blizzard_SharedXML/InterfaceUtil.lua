function ReloadUI()
	C_UI.Reload();
end

function PrintToDebugWindow(msg)
	if C_Debug and C_Debug.PrintToDebugWindow then
		C_Debug.PrintToDebugWindow(msg);
	end
end

function ViewInDebugWindow(...)
	if C_Debug and C_Debug.ViewInDebugWindow then
		C_Debug.ViewInDebugWindow(...);
	end
end

StoreInterfaceUtil = {};

-- Returns true if there is a subscription product available and the store was toggled.
function StoreInterfaceUtil.OpenToSubscriptionProduct()
	local useNewCashShop = C_CatalogShop.IsShop2Enabled();
	if useNewCashShop then
		-- TODO: do we need to check for free game time to show:
		-- CatalogShopInboundInterface.SelectGameTimeProduct()
		-- vs.
		-- CatalogShopInboundInterface.SelectSubscriptionProduct()
		-- currently we just show Subs:
		CatalogShopInboundInterface.SelectSubscriptionProduct();
		ToggleStoreUI();
		return true;
	else
		if C_StorePublic.DoesGroupHavePurchaseableProducts(WOW_SUBSCRIPTION_CATEGORY_ID) then
			StoreFrame_SelectSubscriptionProduct()
			ToggleStoreUI();
			return true;
		elseif C_StorePublic.DoesGroupHavePurchaseableProducts(WOW_GAME_TIME_CATEGORY_ID) then
			StoreFrame_SelectGameTimeProduct()
			ToggleStoreUI();
			return true;
		end
	end
	PlaySound(SOUNDKIT.GS_LOGIN_NEW_ACCOUNT);
	LoadURLIndex(22);
	return false;
end
