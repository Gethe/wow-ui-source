function ToggleGuildFrame()
	if Kiosk.IsEnabled() then
		return;
	end

	if C_CVar.GetCVarBool("useClassicGuildUI") then
		ToggleFriendsFrame(FRIEND_TAB_GUILD);
		return;
	end

	if UnitFactionGroup("player") == "Neutral" then
		return;
	end

	if IsCommunitiesUIDisabledByTrialAccount() then
		UIErrorsFrame:AddMessage(ERR_RESTRICTED_ACCOUNT_TRIAL, 1.0, 0.1, 0.1, 1.0);
	elseif C_Club.IsEnabled() then
		if not BNConnected() then
			UIErrorsFrame:AddMessage(ERR_GUILD_AND_COMMUNITIES_UNAVAILABLE, 1.0, 0.1, 0.1, 1.0);
		elseif C_Club.IsRestricted() == Enum.ClubRestrictionReason.None then
			ToggleCommunitiesFrame();
		end
	end
end

local function IsStoreUIShown()
	if C_CatalogShop.IsShop2Enabled() then
		return CatalogShopInboundInterface.IsShown();
	end
	return StoreFrame_IsShown();
end

-- Store UI entry point is shared among all Classic flavors
function SetStoreUIShown(shown)
	if Kiosk.IsEnabled() then
		return;
	end

	local useNewCashShop = C_CatalogShop.IsShop2Enabled();
	if useNewCashShop then
		local wasShown = CatalogShopInboundInterface.IsShown();
		if not wasShown then
			--We weren't showing, now we are. We should hide all other panels.
			securecall("CloseAllWindows");
		end
		local contextKey = nil;		-- contextKey is for Mainline only
		CatalogShopInboundInterface.SetShown(not wasShown, contextKey);
	else
		local wasShown = StoreFrame_IsShown();
		if not wasShown and shown then
			--We weren't showing, now we are. We should hide all other panels.
			securecall("CloseAllWindows");
		end
		StoreFrame_SetShown(shown);
	end
end

function ToggleStoreUI()
	SetStoreUIShown(not IsStoreUIShown());
end
