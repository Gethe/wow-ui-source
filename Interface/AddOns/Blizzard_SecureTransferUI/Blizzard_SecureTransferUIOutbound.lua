-- Outbound loads under the global environment but needs to put the outbound table into the secure environment
local secureEnv = GetCurrentEnvironment();
SwapToGlobalEnvironment();
local SecureTransferOutbound = {};
secureEnv.SecureTransferOutbound = SecureTransferOutbound;
secureEnv = nil;	--This file shouldn't be calling back into secure code.

function SecureTransferOutbound.UpdateSendMailButton()
    securecall("SendMailFrame_EnableSendMailButton");
end

function SecureTransferOutbound.GetAppropriateTopLevelParent()
	return securecall("GetAppropriateTopLevelParent");
end

function SecureTransferOutbound.GetCatalogShopTopUpFrame()
	return securecallfunction(CatalogShopTopUpFrame_GetFrame);
end

local function GetHearthsteelCurrencyCode()
	return Constants.CatalogShopVirtualCurrencyConstants.HEARTHSTEEL_VC_CURRENCY_CODE;
end

function SecureTransferOutbound.GetHearthsteelVirtualCurrencyCode()
	return securecallfunction(GetHearthsteelCurrencyCode);
end

function SecureTransferOutbound.HideCatalogShopTopUpFrame()
	if CatalogShopTopUpFlowInboundInterface then
		CatalogShopTopUpFlowInboundInterface.SetShown(false);
	end
end
