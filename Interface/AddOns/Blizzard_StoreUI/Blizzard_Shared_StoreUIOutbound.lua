-- Outbound loads under the global environment but needs to put the outbound table into the secure environment
local secureEnv = GetCurrentEnvironment();
SwapToGlobalEnvironment();
local StoreOutbound = {};
secureEnv.StoreOutbound = StoreOutbound;
secureEnv = nil;	--This file shouldn't be calling back into secure code.

function StoreOutbound.UpdateMicroButtons()
	securecall("UpdateMicroButtons");
end

function StoreOutbound.ShowPreviews(displayInfoEntries)
	securecall("StoreShowPreviews", displayInfoEntries);
end

function StoreOutbound.HidePreviewFrame()
	securecall("HidePreviewFrame");
end

function StoreOutbound.Logout()
	securecall("Logout");
end

function StoreOutbound.SetItemTooltip(itemID, left, top, point)
	securecall("StoreSetItemTooltip", itemID, left, top, point);
end

function StoreOutbound.ClearItemTooltip()
	securecall("GameTooltip_Hide");
end

function StoreOutbound.ConfirmClassTrialApplyToken(guid, boostType)
	securecall("ClassTrial_ConfirmApplyToken", guid, boostType);
end

function StoreOutbound.IsExpansionTrialUpgradeDialogShowing()
	return securecall("ClassTrial_IsExpansionTrialUpgradeDialogShowing");
end

function StoreOutbound.IsCharacterSelectVisible()
	return securecall("CharacterSelect_IsVisible");
end

function StoreOutbound.IsCharacterSelectUndeleting()
	return securecall("CharacterSelect_IsUndeleting");
end

function StoreOutbound.UpdateDialogs()
	securecall("GlueParent_UpdateDialogs");
end

function StoreOutbound.TryHideModelPreviewFrame()
	return securecall("ModelPreviewFrame_TryHide");
end

function StoreOutbound.CloseAllWindows()
	securecall("CloseAllWindows");
end

function StoreOutbound.TriggerHideEvent(contextKey)
	securecallfunction(SecureOutboundUtil_TriggerEvent, "Store.FrameHidden", contextKey);
end

function StoreOutbound.StoreFrameShowGlueDialog(text, guid, realmName, shouldHandle)
	securecall("StoreFrame_ShowGlueDialog", text, guid, realmName, shouldHandle);
end
