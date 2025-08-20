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
