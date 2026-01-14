function UIParent_OnShow(self)
	if ( self.firstTimeLoaded ~= 1 ) then
		CloseAllWindows();
		self.firstTimeLoaded = nil;
	end

	if ( LowHealthFrame ) then
		LowHealthFrame:EvaluateVisibleState();
	end

	if ( UIParentBottomManagedFrameContainer ) then
		UIParentBottomManagedFrameContainer:UpdateManagedFrames();
	end
	if ( UIParentRightManagedFrameContainer ) then
		UIParentRightManagedFrameContainer:UpdateManagedFrames();
	end
end

function UIParent_OnHide(self)
	if ( LowHealthFrame ) then
		LowHealthFrame:EvaluateVisibleState();
	end

	if ( UIParentBottomManagedFrameContainer ) then
		UIParentBottomManagedFrameContainer:ClearManagedFrames();
	end
	if ( UIParentRightManagedFrameContainer ) then
		UIParentRightManagedFrameContainer:ClearManagedFrames();
	end
end

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

function AllowChatFramesToShow(chatFrame)
	-- this is InGame - and we always show while InGame.  chatFrame is not referenced, only Glues
	return true;
end
