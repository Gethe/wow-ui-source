-- Outbound loads under the global environment but needs to put the outbound table into the secure environment
local secureEnv = GetCurrentEnvironment();
SwapToGlobalEnvironment();
local CatalogShopOutboundInterface = {};
secureEnv.CatalogShopOutbound = CatalogShopOutboundInterface;
secureEnv = nil;	--This file shouldn't be calling back into secure code.

function CatalogShopOutboundInterface.UpdateMicroButtons()
	securecall("UpdateMicroButtons");
end

function CatalogShopOutboundInterface.IsCharacterSelectVisible()
	return securecall("CharacterSelect_IsVisible");
end

function CatalogShopOutboundInterface.StoreFrameShowGlueDialog(text, guid, realmName, shouldHandle)
	securecall("StoreFrame_ShowGlueDialog", text, guid, realmName, shouldHandle);
end

function CatalogShopOutboundInterface.ConfirmClassTrialApplyToken(guid, boostType)
	securecall("ClassTrial_ConfirmApplyToken", guid, boostType);
end

function CatalogShopOutboundInterface.IsCharacterSelectUndeleting()
	return securecall("CharacterSelect_IsUndeleting");
end

function CatalogShopOutboundInterface.IsExpansionTrialUpgradeDialogShowing()
	return securecall("ClassTrial_IsExpansionTrialUpgradeDialogShowing");
end

function CatalogShopOutboundInterface.UpdateDialogs()
	securecall("GlueParent_UpdateDialogs");
end