-- Inbound files need to load under the global environment
SwapToGlobalEnvironment();

--All of these functions should be safe to call by tainted code. They should only communicate with secure code via SetAttribute and GetAttribute.
CatalogShopRefundFlowInboundInterface = {};

function CatalogShopRefundFlowInboundInterface.SetShown(shown, contextKey)
	local wasShown = CatalogShopRefundFlowInboundInterface.IsShown();
	local contextKeyString = contextKey and tostring(contextKey) or nil;
	if shown then
		CatalogShopRefundFrame:SetAttribute("contextkey", contextKeyString);
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

