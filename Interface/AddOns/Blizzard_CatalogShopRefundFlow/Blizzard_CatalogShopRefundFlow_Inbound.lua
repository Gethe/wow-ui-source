-- Inbound files need to load under the global environment
SwapToGlobalEnvironment();

-- All of these functions should be safe to call by tainted code. They should only communicate with secure code via SetAttribute and GetAttribute.
CatalogShopRefundFlowInboundInterface = {};

function CatalogShopRefundFlowInboundInterface.SetShown(shown, productID)
	CatalogShopRefundFrame:ClearAttribute("productid");

	if shown and (type(productID) == "number") then
		CatalogShopRefundFrame:SetAttribute("productid", productID);
	end
	CatalogShopRefundFrame:SetAttribute("action", shown and "Show" or "Hide");
end

function CatalogShopRefundFlowInboundInterface.IsShown()
	return CatalogShopRefundFrame:GetAttribute("isshown");
end

function CatalogShopRefundFlowInboundInterface.EscapePressed()
	CatalogShopRefundFrame:SetAttribute("action", "EscapePressed");
	return CatalogShopRefundFrame:GetAttribute("escaperesult");
end

-- Global function for handling calls from Shop 2.0
function CatalogShopRefundFlow_Show(productID)
	local shown = true;
	CatalogShopRefundFlowInboundInterface.SetShown(shown, productID);
end
