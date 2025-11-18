function ClassTrial_IsExpansionTrialUpgradeDialogShowing() 
	return false;
end

-- Store UI entry point is shared among all Classic flavors
function ToggleStoreUI()
	if (Kiosk.IsEnabled()) then
		return;
	end

	local useNewCashShop = C_CatalogShop.IsShop2Enabled();
	if useNewCashShop then
		local wasShown = CatalogShopInboundInterface.IsShown();
		if ( not wasShown ) then
			--We weren't showing, now we are. We should hide all other panels.
			securecall("CloseAllWindows");
		end
		local contextKey = nil;		-- contextKey is for Mainline only
		CatalogShopInboundInterface.SetShown(not wasShown, contextKey);
	else
		local wasShown = StoreFrame_IsShown();
		if ( not wasShown ) then
			--We weren't showing, now we are. We should hide all other panels.
			securecall("CloseAllWindows");
		end
		StoreFrame_SetShown(not wasShown);
	end
end

function SetStoreUIShown(shown)
	if (Kiosk.IsEnabled()) then
		return;
	end

	local useNewCashShop = C_CatalogShop.IsShop2Enabled();
	if useNewCashShop then
		local wasShown = CatalogShopInboundInterface.IsShown();
		if ( not wasShown ) then
			--We weren't showing, now we are. We should hide all other panels.
			securecall("CloseAllWindows");
		end
		local contextKey = nil;		-- contextKey is for Mainline only
		CatalogShopInboundInterface.SetShown(not wasShown, contextKey);
	else
		local wasShown = StoreFrame_IsShown();
		if ( not wasShown and shown ) then
			--We weren't showing, now we are. We should hide all other panels.
			securecall("CloseAllWindows");
		end
		StoreFrame_SetShown(shown);
	end
end
