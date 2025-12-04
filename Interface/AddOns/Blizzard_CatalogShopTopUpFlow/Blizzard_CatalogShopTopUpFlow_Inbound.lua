-- Inbound files need to load under the global environment
SwapToGlobalEnvironment();

--All of these functions should be safe to call by tainted code. They should only communicate with secure code via SetAttribute and GetAttribute.
CatalogShopTopUpFlowInboundInterface = {};

function CatalogShopTopUpFlowInboundInterface.SetShown(shown, parentFrame)
	local wasShown = CatalogShopTopUpFlowInboundInterface.IsShown();
	if shown then
		local frameToUse = parentFrame or GetAppropriateTopLevelParent();
		CatalogShopTopUpFrame:SetAttribute("parentframe", frameToUse);
	end
	CatalogShopTopUpFrame:SetAttribute("action", shown and "Show" or "Hide");
end

function CatalogShopTopUpFlowInboundInterface.IsShown()
	return CatalogShopTopUpFrame:GetAttribute("isshown");
end

function CatalogShopTopUpFlowInboundInterface.EscapePressed()
	CatalogShopTopUpFrame:SetAttribute("action", "EscapePressed");
	return CatalogShopTopUpFrame:GetAttribute("escaperesult");
end

function CatalogShopTopUpFlowInboundInterface.SetDesiredQuantity(quantity)
	CatalogShopTopUpFrame:SetAttribute("setdesiredquantity", quantity);
end
