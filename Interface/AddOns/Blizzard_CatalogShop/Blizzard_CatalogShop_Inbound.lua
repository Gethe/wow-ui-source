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

function CatalogShopInboundInterface.SelectSubscriptionProduct()
	CatalogShopFrame:SetAttribute("selectsubscription", true);
end

function CatalogShopInboundInterface.SetTokenCategory()
	CatalogShopFrame:SetAttribute("settokencategory");
end

function CatalogShopInboundInterface.CheckForFree(event)
	CatalogShopFrame:SetAttribute("checkforfree", event);
end

function CatalogShopInboundInterface.OpenGamesCategory()
	CatalogShopFrame:SetAttribute("opengamescategory");
end

function CatalogShopInboundInterface.SetGamesCategory()
	CatalogShopFrame:SetAttribute("setgamescategory");
end

function CatalogShopInboundInterface.SetServicesCategory()
	CatalogShopFrame:SetAttribute("setservicescategory");
end

function CatalogShopInboundInterface.SelectBoost(boostType, reason, guid)
	local data = {};
	data.boostType = boostType;
	data.reason = reason;
	data.guid = guid;
	CatalogShopFrame:SetAttribute("selectboost", data);
end

function CatalogShopInboundInterface.SelectGameTimeProduct()
	CatalogShopFrame:SetAttribute("selectgametime", true);
end
