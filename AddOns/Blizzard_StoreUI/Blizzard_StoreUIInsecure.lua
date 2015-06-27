-- DO NOT PUT ANY SENSITIVE CODE IN THIS FILE
-- This file does not have access to the secure (forbidden) code.  It is only called via Outbound and no function in this file should ever return values.

function StoreShowPreview(name, modelID)
	local frame = ModelPreviewFrame;
	ModelPreviewFrame_ShowModel(modelID, false);
	frame.Display.Name:SetText(name);
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

			if (GetServerName() ~= data.realmName) then
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
			local _, guid, realmName = C_PurchaseAPI.GetVASCompletionInfo();
			VASCharacterGUID = guid;

		    if (GetServerName() ~= realmName) then
			    C_StoreGlue.ChangeRealmByCharacterGUID(guid);
		    else
			    UpdateCharacterList(true);
		    end
			C_StoreGlue.ClearVASProductReady();
			return;
		end

		if (VASCharacterGUID) then
			CharacterSelect_SelectCharacterByGUID(VASCharacterGUID);
			VASCharacterGUID = nil;
		end
	end

	function StoreFrame_ShowGlueDialog(text, guid, realmName)
		GlueDialog_Show("VAS_PRODUCT_DELIVERED", text, { ["guid"] = guid, ["realmName"] = realmName });
	end
end