-- Outbound loads under the global environment but needs to put the outbound table into the secure environment
local secureEnv = GetCurrentEnvironment();
SwapToGlobalEnvironment();
local CatalogShopRefundFlowOutboundInterface = {};
secureEnv.CatalogShopRefundFlowOutbound = CatalogShopRefundFlowOutboundInterface;
secureEnv = nil;	--This file shouldn't be calling back into secure code.

function CatalogShopRefundFlowOutboundInterface.ShowBulkRefundError(errorMessage)
	securecall("StaticPopup_Show", "CATALOG_SHOP_BULK_REFUND_ERROR", errorMessage);
end

function CatalogShopRefundFlowOutboundInterface.GetAppropriateTopLevelParent()
	return securecall("GetAppropriateTopLevelParent");
end
