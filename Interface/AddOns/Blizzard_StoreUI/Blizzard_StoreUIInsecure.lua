-- DO NOT PUT ANY SENSITIVE CODE IN THIS FILE
-- This file does not have access to the secure (forbidden) code.  It is only called via Outbound and no function in this file should ever return values.

function StoreShowPreview(name, modelID, modelSceneID)
	local frame = ModelPreviewFrame;
	ModelPreviewFrame_ShowModel(modelID, modelSceneID, false);
	frame.Display.Name:SetText(name);
end

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
				if (data.guid and GetServerName() == data.realmName) then
					-- We're about to throw out the character list,
					-- so if we want to try to select a character, it has to be now.
					CharacterSelect_SelectCharacterByGUID(data.guid);
				end
				VASCharacterGUID = nil;
				GetCharacterListUpdate(); -- Request a new character list from the server.
				return;
			end

			if (GetServerName() ~= data.realmName) then
				-- For Classic, we don't like how this is behaving with FCM. Disabling for now.
				-- CharacterSelect_SetAutoSwitchRealm(true);
				-- C_StoreGlue.ChangeRealmByCharacterGUID(data.guid);
				VASCharacterGUID = nil;
			else
				UpdateCharacterList(true);
				VASCharacterGUID = data.guid;
			end
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