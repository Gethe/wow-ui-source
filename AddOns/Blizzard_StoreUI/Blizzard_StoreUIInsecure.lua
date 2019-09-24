-- DO NOT PUT ANY SENSITIVE CODE IN THIS FILE
-- This file does not have access to the secure (forbidden) code.  It is only called via Outbound and no function in this file should ever return values.

function StoreShowPreviews(displayInfoEntries)
	ModelPreviewFrame_ShowModels(displayInfoEntries, false);
end

function StoreSetItemTooltip(itemID, left, top, point)
	GameTooltip:SetOwner(UIParent, "ANCHOR_NONE");
	GameTooltip:SetPoint(point, UIParent, "BOTTOMLEFT", left, top);
	GameTooltip:SetItemByID(itemID);
	GameTooltip:Show();
end

function StorePreviewFrame_OnShow()
	StoreFrame_PreviewFrameIsShown(true);
end

function StorePreviewFrame_OnHide()
	StoreFrame_PreviewFrameIsShown(false);
end

function HidePreviewFrame()
	ModelPreviewFrame:Hide();
end

if (InGlue()) then
	VASCharacterGUID = nil;
	GlueDialogTypes["VAS_PRODUCT_DELIVERED"] = {
		button1 = OKAY,
		escapeHides = true,
		OnAccept = function()
			local data = GlueDialog.data;

			if (not data.shouldHandle) then
				VASCharacterGUID = nil;
				GetCharacterListUpdate();
				return;
			end

			if (GetServerName() ~= data.realmName) then
				CharacterSelect_SetAutoSwitchRealm(true);
				C_StoreGlue.ChangeRealmByCharacterGUID(data.guid);
			else
				UpdateCharacterList(true);
			end

			VASCharacterGUID = data.guid;
		end
	}

	function StoreFrame_WaitingForCharacterListUpdate()
		return VASCharacterGUID ~= nil or C_StoreGlue.GetVASProductReady();
	end

	function StoreFrame_OnCharacterListUpdate()
		if (C_StoreGlue.GetVASProductReady()) then
			local productID, guid, realmName, shouldHandle = C_StoreSecure.GetVASCompletionInfo();
			C_StoreGlue.ClearVASProductReady();

			if (not shouldHandle) then
				VASCharacterGUID = nil;
				GetCharacterListUpdate();
				return;
			end

			VASCharacterGUID = guid;

			if (GetServerName() ~= realmName or StoreFrame_IsVASTransferProduct(productID)) then
				CharacterSelect_SetAutoSwitchRealm(true);
				C_StoreGlue.ChangeRealmByCharacterGUID(guid);
		    else
				UpdateCharacterList(true);
		    end
			return;
		end

		if (VASCharacterGUID) then
			CharacterSelect_SelectCharacterByGUID(VASCharacterGUID);
			VASCharacterGUID = nil;
		end
	end

	function StoreFrame_ShowGlueDialog(text, guid, realmName, shouldHandle)
		GlueDialog_Show("VAS_PRODUCT_DELIVERED", text, { ["guid"] = guid, ["realmName"] = realmName, ["shouldHandle"] = shouldHandle });
	end
end