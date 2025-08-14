-- Inbound files need to load under the global environment
SwapToGlobalEnvironment();

--All of these functions should be safe to call by tainted code. They should only communicate with secure code via SetAttribute and GetAttribute.
CatalogShopInboundInterface = {};

function CatalogShopInboundInterface.SetShown(shown, contextKey)
	local wasShown = CatalogShopInboundInterface.IsShown();
	local contextKeyString = contextKey and tostring(contextKey) or nil;
	if shown then
		CatalogShopFrame:SetAttribute("contextkey", contextKeyString);
	end
	-- Notify the store that shown was toggled
	if wasShown ~= shown then
		C_StorePublic.EventStoreUISetShown(shown, contextKeyString);
	end
	CatalogShopFrame:SetAttribute("action", shown and "Show" or "Hide");
end

function CatalogShopInboundInterface.IsShown()
	return CatalogShopFrame:GetAttribute("isshown");
end

function CatalogShopInboundInterface.EscapePressed()
	CatalogShopFrame:SetAttribute("action", "EscapePressed");
	return CatalogShopFrame:GetAttribute("escaperesult");
end
