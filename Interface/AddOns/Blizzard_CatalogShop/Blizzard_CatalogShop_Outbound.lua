-- Outbound loads under the global environment but needs to put the outbound table into the secure environment
local secureEnv = GetCurrentEnvironment();
SwapToGlobalEnvironment();
local CatalogShopOutboundInterface = {};
secureEnv.CatalogShopOutbound = CatalogShopOutboundInterface;
secureEnv = nil;	--This file shouldn't be calling back into secure code.

function CatalogShopOutboundInterface.UpdateMicroButtons()
	securecall("UpdateMicroButtons");
end

function CatalogShopOutboundInterface.SetItemTooltip(itemID, left, top, point)
	securecall("StoreSetItemTooltip", itemID, left, top, point);
end

function CatalogShopOutboundInterface.ClearItemTooltip()
	securecall("GameTooltip_Hide");
end

function CatalogShopOutboundInterface.UpdateDialogs()
	securecall("GlueParent_UpdateDialogs");
end

function CatalogShopOutboundInterface.SavedSet_IsLoaded()
	return C_AddOns.IsAddOnLoaded("Blizzard_SavedSets") and securecall("SavedSet_IsLoaded");
end

function CatalogShopOutboundInterface.SavedSet_HasAny()
	return securecall("SavedSet_HasAny");
end

function CatalogShopOutboundInterface.SavedSet_Set(idOrTable)
	return securecall("SavedSet_Set", idOrTable);
end

function CatalogShopOutboundInterface.SavedSet_Check(idOrTable)
	return securecall("SavedSet_Check", idOrTable);
end

function CatalogShopOutboundInterface.NotificationUtil_AcquireLargeNotification(point, parent, relativePoint, offsetX, offsetY)
	return securecall("NotificationUtil_AcquireLargeNotification", point, parent, relativePoint, offsetX, offsetY);
end

function CatalogShopOutboundInterface.NotificationUtil_ReleaseNotification(frame)
	return securecall("NotificationUtil_ReleaseNotification", frame);
end

function CatalogShopOutboundInterface.ShowRefundFlow(productID)
	securecall("CatalogShopRefundFlow_Show", productID);
end

function CatalogShopOutboundInterface.VisibilityUpdated(isShown)
	securecall("CatalogShopVisibilityUpdated", isShown);
end

function CatalogShopOutboundInterface.HandleGamepadFrameShown(frame, isPopup, shouldFocusFrame)
	securecallfunction(function()
		GamepadMode.FrameControlsManager:FrameShown(frame, isPopup, shouldFocusFrame);
	end);
end

function CatalogShopOutboundInterface.HandleGamepadFrameHidden(frame)
	securecallfunction(function()
		GamepadMode.FrameControlsManager:FrameHidden(frame);
	end);
end

function CatalogShopOutboundInterface.SetupGamepad(frame)
	securecall("CatalogShopSetupGamepad", frame);
end

function CatalogShopOutboundInterface.FocusGamepad(frame)
	securecall("CatalogShopFocusGamepad", frame);
end

function CatalogShopOutboundInterface.UnfocusGamepad(frame)
	securecall("CatalogShopUnfocusGamepad", frame);
end

function CatalogShopOutboundInterface.RefreshSmartNav(frame)
	securecall("CatalogShopRefreshSmartNav", frame);
end

function CatalogShopOutboundInterface.ShowProductDetails(frame)
	securecall("CatalogShopShowProductDetails", frame);
end

function CatalogShopOutboundInterface.HideProductDetails(frame)
	securecall("CatalogShopHideProductDetails", frame);
end

function CatalogShopOutboundInterface.RefreshGamepadPurchaseButton(frame)
	securecall("CatalogShopRefreshGamepadPurchaseButton", frame);
end
