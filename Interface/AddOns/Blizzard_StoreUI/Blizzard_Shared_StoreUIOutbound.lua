--If any of these functions call out of this file, they should be using securecall. Be very wary of using return values.
local _, tbl = ...;
local Outbound = {};
tbl.Outbound = Outbound;
tbl = nil;	--This file shouldn't be calling back into secure code.

function Outbound.UpdateMicroButtons()
	securecall("UpdateMicroButtons");
end

function Outbound.ShowPreviews(displayInfoEntries)
	securecall("StoreShowPreviews", displayInfoEntries);
end

function Outbound.HidePreviewFrame()
	securecall("HidePreviewFrame");
end

function Outbound.Logout()
	securecall("Logout");
end

function Outbound.SetItemTooltip(itemID, left, top, point)
	securecall("StoreSetItemTooltip", itemID, left, top, point);
end

function Outbound.ClearItemTooltip()
	securecall("GameTooltip_Hide");
end

function Outbound.ConfirmClassTrialApplyToken(guid, boostType)
	securecall("ClassTrial_ConfirmApplyToken", guid, boostType)
end

function Outbound.IsExpansionTrialUpgradeDialogShowing()
	return securecall("ClassTrial_IsExpansionTrialUpgradeDialogShowing");
end

function Outbound.CloseAllWindows()
	securecall("CloseAllWindows");
end
