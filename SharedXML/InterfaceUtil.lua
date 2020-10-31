function ReloadUI()
	C_UI.Reload();
end


StoreInterfaceUtil = {};

-- Returns true if there is a subscription product available and the store was toggled.
function StoreInterfaceUtil.OpenToSubscriptionProduct()
	if C_StorePublic.DoesGroupHavePurchaseableProducts(WOW_SUBSCRIPTION_CATEGORY_ID) then
		StoreFrame_SelectSubscriptionProduct()
		ToggleStoreUI();
		return true;
	elseif C_StorePublic.DoesGroupHavePurchaseableProducts(WOW_GAME_TIME_CATEGORY_ID) then
		StoreFrame_SelectGameTimeProduct()
		ToggleStoreUI();
		return true;
	end

	PlaySound(SOUNDKIT.GS_LOGIN_NEW_ACCOUNT);
	LoadURLIndex(22);
	return false;
end