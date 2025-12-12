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
