-- Helpers for non-Housing code needing to make housing-related API calls while relevant Housing addons may not be loaded (ex: Keybindings)
HousingFramesUtil = {};

function HousingFramesUtil.IsHousingMarketShopAvailable()
	return C_Housing.IsHousingMarketShopEnabled() and C_StorePublic.IsEnabled() and C_HousingCatalog.HasFeaturedEntries();
end

StaticPopupDialogs["CONFIRM_DESTROY_PREVIEW_DECOR"] = {
	text = HOUSING_PREVIEW_DECOR_WARNING,
	button1 = OKAY,
	button2 = CANCEL,
	hideOnEscape = 1,
	timeout = 0,
	exclusive = 1,
	whileDead = 1,

	OnShow = function(dialog, _data)
		if not HousingFramesUtil.IsHousingMarketShopAvailable() then
			dialog:SetText(HOUSING_PREVIEW_DECOR_WARNING_AR_ONLY);
		else
			dialog:SetText(HOUSING_PREVIEW_DECOR_WARNING);
		end
	end,

	OnAccept = function(dialog, cb)
		cb();
	end
}

--TODO: eventually we want a more robust "confirm leaving mode" system
--See HouseEditorUI.cpp
function HousingFramesUtil.LeaveHouseEditor()
	if C_HousingDecor.GetNumPreviewDecor() > 0 then
		StaticPopup_Show("CONFIRM_DESTROY_PREVIEW_DECOR", nil, nil, function()
			local clearCartEvent = string.format("%s.%s", HOUSING_MARKET_EVENT_NAMESPACE, ShoppingCartDataServices.ClearCart);
			local requiresConfirmation = false;
			EventRegistry:TriggerEvent(clearCartEvent, requiresConfirmation);

			C_HouseEditor.LeaveHouseEditor();
		end);
	else
		C_HouseEditor.LeaveHouseEditor();
	end
end

function HousingFramesUtil.ToggleHouseEditor()
	if C_HouseEditor.IsHouseEditorActive() then
		HousingFramesUtil.LeaveHouseEditor();
	else
		local initialResult = C_HouseEditor.EnterHouseEditor();
		if initialResult ~= Enum.HousingResult.Success then
			local errorText = HousingResultToErrorText[initialResult];
			if errorText and errorText ~= "" then
				UIErrorsFrame:AddExternalErrorMessage(errorText);
			end
		end
	end
end

function HousingFramesUtil.IsHouseEditorModeAvailable(mode)
	if C_HousingDecor.IsModeDisabledForPreviewState(mode) then
		return false;
	end

	local modeAvailability = C_HouseEditor.GetHouseEditorModeAvailability(mode);
	if modeAvailability ~= Enum.HousingResult.Success then
		return false;
	end

	if not HousingTutorialUtil.HousingQuestTutorialComplete() and not HousingTutorialUtil.IsModeValidForTutorial(mode) then
		return false;
	end

	return true;
end

function HousingFramesUtil.ActivateHouseEditorMode(mode)
	if not HousingFramesUtil.IsHouseEditorModeAvailable(mode) then
		return;
	end

	PlaySound(SOUNDKIT.HOUSING_PRIMARY_MENU_BUTTON_SHORTCUT);

	if C_HouseEditor.IsHouseEditorModeActive(mode) then
		return;
	end

	C_HouseEditor.ActivateHouseEditorMode(mode);
end

function HousingFramesUtil.SetExpertDecorSubmode(submode)
	local expertMode = Enum.HouseEditorMode.ExpertDecor;

	if C_HouseEditor.GetHouseEditorModeAvailability(expertMode) ~= Enum.HousingResult.Success then
		return;
	end

	PlaySound(SOUNDKIT.HOUSING_EXPERTMODE_SUB_MENU_BUTTON_TOGGLE_SHORTCUT);

	if not C_HouseEditor.IsHouseEditorModeActive(expertMode) then
		C_HouseEditor.ActivateHouseEditorMode(expertMode);
	end

	local activeSubmode = C_HousingExpertMode.GetPrecisionSubmode();
	if activeSubmode == submode then
		return;
	end

	C_HousingExpertMode.SetPrecisionSubmode(submode);
end

function HousingFramesUtil.ToggleHousingDashboard()
	if (PlayerIsTimerunning() or not C_Housing.IsHousingServiceEnabled()) then
		return;
	end

	if not HousingDashboardFrame then
		C_AddOns.LoadAddOn("Blizzard_HousingDashboard");
	end

	if (C_PlayerInfo.IsPlayerNPERestricted()) then
		return;
	end

	ToggleFrame(HousingDashboardFrame);
end

function HousingFramesUtil.SetGridVisible(gridVisible)
	if C_HousingDecor.IsDecorSelected() then
		PlaySound(SOUNDKIT.HOUSING_DECOR_EDIT_OPTION_TOGGLE_GRID);
	end

	C_HousingDecor.SetGridVisible(gridVisible);
end

function HousingFramesUtil.RemoveSelectedDecor()
	if C_HousingDecor.IsDecorSelected() then
		PlaySound(SOUNDKIT.HOUSING_DECOR_EDIT_OPTION_REMOVE_ITEM);
		C_HousingDecor.RemoveSelectedDecor();
	end
end

function HousingFramesUtil.SetGridSnapEnabled(gridSnapEnabled)
	PlaySound(SOUNDKIT.HOUSING_PRIMARY_SUB_MENU_BUTTON_TOGGLE_SHORTCUT);
	C_HousingBasicMode.SetGridSnapEnabled(gridSnapEnabled);
end

function HousingFramesUtil.SetFreePlaceEnabled(freeplaceEnabled)
	PlaySound(SOUNDKIT.HOUSING_PRIMARY_SUB_MENU_BUTTON_TOGGLE_SHORTCUT);
	C_HousingBasicMode.SetFreePlaceEnabled(freeplaceEnabled);
end

function HousingFramesUtil.ZoomLayoutCamera(zoom)
	local zoomChanged = C_HousingLayout.ZoomLayoutCamera(zoom);

	if zoomChanged then
		PlaySound(zoom and SOUNDKIT.HOUSING_LAYOUT_ZOOM_IN or SOUNDKIT.HOUSING_LAYOUT_ZOOM_OUT);
	end
end

function HousingFramesUtil.RotateBasicDecorSelection(direction)
	if C_HousingBasicMode.IsDecorSelected() then
		C_HousingBasicMode.RotateDecor(direction);
	elseif C_HousingBasicMode.IsHouseExteriorSelected() then
		C_HousingBasicMode.RotateHouseExterior(direction);
	else
		-- Nothing selected, early out & avoid playing sound
		return;
	end

	PlaySound(SOUNDKIT.HOUSING_ROTATE_ITEM);
end

function HousingFramesUtil.PreviewHousingCatalogEntryInfo(entryInfo)
	if not entryInfo then
		return false;
	end
	if not HousingModelPreviewFrame then
		C_AddOns.LoadAddOn("Blizzard_HousingModelPreview");
	end
	if HousingModelPreviewFrame then
		HousingModelPreviewFrame:ShowCatalogEntryInfo(entryInfo);
		return true;
	end

	return false;
end

function HousingFramesUtil.PreviewHousingCatalogEntryID(entryID)
	if not C_HousingCatalog or not entryID then
		return false;
	end

	local catalogEntryInfo = C_HousingCatalog.GetCatalogEntryInfo(entryID);
	return HousingFramesUtil.PreviewHousingCatalogEntryInfo(catalogEntryInfo);
end

function HousingFramesUtil.PreviewHousingDecorID(decorID)
	if not C_HousingCatalog or not decorID then
		return false;
	end

	local tryGetOwnedInfo = true;
	local catalogEntryInfo = C_HousingCatalog.GetCatalogEntryInfoByRecordID(Enum.HousingCatalogEntryType.Decor, decorID, tryGetOwnedInfo);
	return HousingFramesUtil.PreviewHousingCatalogEntryInfo(catalogEntryInfo);
end

-- Preview the model for a catalog entry by its corresponding Item
-- itemIdentifier can be an item id, name, or link
function HousingFramesUtil.PreviewHousingItem(itemIdentifier)
	if not C_HousingCatalog or not itemIdentifier then
		return false;
	end

	local tryGetOwnedInfo = true;
	local catalogEntryInfo = C_HousingCatalog.GetCatalogEntryInfoByItem(itemIdentifier, tryGetOwnedInfo);
	return HousingFramesUtil.PreviewHousingCatalogEntryInfo(catalogEntryInfo);
end

function HousingFramesUtil.HandleRotateBasicDecorSelectionLeftKeybind(keystate)
	if C_HousingBasicMode.IsDecorSelected() or C_HousingBasicMode.IsHouseExteriorSelected() then
		if keystate == "down" then
			HousingFramesUtil.RotateBasicDecorSelection(1);
		end
	else
		local key = GetBindingKey("HOUSING_BASICDECOR_ROTATELEFT");
		local baseBinding = C_KeyBindings.GetBindingByKey(key, Enum.BindingContext.None);
		if baseBinding ~= "NONE" then
			RunBinding(baseBinding, keystate);
		end
	end
end

function HousingFramesUtil.HandleRotateBasicDecorSelectionRightKeybind(keystate)
	if C_HousingBasicMode.IsDecorSelected() or C_HousingBasicMode.IsHouseExteriorSelected() then
		if keystate == "down" then
			HousingFramesUtil.RotateBasicDecorSelection(-1);
		end
	else
		local key = GetBindingKey("HOUSING_BASICDECOR_ROTATERIGHT");
		local baseBinding = C_KeyBindings.GetBindingByKey(key, Enum.BindingContext.None);
		if baseBinding ~= "NONE" then
			RunBinding(baseBinding, keystate);
		end
	end
end

function HousingFramesUtil.OpenFrameToTaskID(taskID)
	if not HousingDashboardFrame or not HousingDashboardFrame:IsShown() then
		HousingFramesUtil.ToggleHousingDashboard();
	end
	if HousingDashboardFrame then
		HousingDashboardFrame:OpenInitiativesFrameToTaskID(taskID);
	end
end

-- Handler for events that may fire while relevant Housing addons may not be loaded
HousingEventHandlerMixin = {}

function HousingEventHandlerMixin:Init()

end

function HousingEventHandlerMixin:OnPlotEntered()
	if not HousingControlsFrame then
		C_AddOns.LoadAddOn("Blizzard_HousingControls");
	end
end

function HousingEventHandlerMixin:OnEditorModeChanged(...)
	if not HouseEditorFrame then
		C_AddOns.LoadAddOn("Blizzard_HouseEditor");
		HouseEditorFrame:OnEvent("HOUSE_EDITOR_MODE_CHANGED", ...);
	end
end

-- Handler for this is here rather than in HouseEditorFrame since the failure may be preventing the HouseEditor from even being activated
function HousingEventHandlerMixin:OnEditorModeChangeFailed(...)
	local result = ...;
	if result ~= Enum.HousingResult.Success then
		local errorMessage = ERR_HOUSE_EDITOR_MODE_FAILED;

		local resultText = HousingResultToErrorText[result];
		if resultText and resultText ~= "" then
			errorMessage = ERR_HOUSE_EDITOR_MODE_FAILED_FMT:format(resultText);
		end
		UIErrorsFrame:AddExternalErrorMessage(errorMessage);
	end
end

function HousingEventHandlerMixin:OpenCornerstone()
	if not HousingCornerstoneFrame then
		C_AddOns.LoadAddOn("Blizzard_HousingCornerstone");
	end

	local plotPurchaseable = C_HousingNeighborhood.IsPlotAvailableForPurchase();
	local plotMine = C_HousingNeighborhood.IsPlotOwnedByPlayer();

	if plotPurchaseable then
		ShowUIPanel(HousingCornerstonePurchaseFrame);
	elseif plotMine then
		--ShowUIPanel(HousingCornerstoneFrame);
		ShowUIPanel(HousingCornerstoneVisitorFrame);
	else
		ShowUIPanel(HousingCornerstoneVisitorFrame);
	end
end

function HousingEventHandlerMixin:OpenCharter(neighborhoodInfo, signatures, numSignaturesRequired)
	if not HousingCharterFrame then
		C_AddOns.LoadAddOn("Blizzard_HousingCharter");
	end
	HousingCharterFrame:SetCharterInfo(neighborhoodInfo, signatures, numSignaturesRequired);
	ShowUIPanel(HousingCharterFrame);
end

function HousingEventHandlerMixin:OpenCharterSignatureRequest(neighborhoodInfo)
	if not HousingCharterRequestSignatureDialog then
		C_AddOns.LoadAddOn("Blizzard_HousingCharter");
	end
	HousingCharterRequestSignatureDialog:SetNeighborhoodInfo(neighborhoodInfo);
	StaticPopupSpecial_Show(HousingCharterRequestSignatureDialog);
end

function HousingEventHandlerMixin:OpenCreateGuildNeighborhoodUI(locationName)
	if not HousingCreateGuildNeighborhoodFrame then
		C_AddOns.LoadAddOn("Blizzard_HousingCreateNeighborhood");
	end
	HousingCreateGuildNeighborhoodFrame:SetActiveLocationAndGuild(locationName);
	ShowUIPanel(HousingCreateGuildNeighborhoodFrame);
end

function HousingEventHandlerMixin:OpenCreateCharterNeighborhoodUI(locationName)
	if not HousingCreateNeighborhoodCharterFrame then
		C_AddOns.LoadAddOn("Blizzard_HousingCreateNeighborhood");
	end
	HousingCreateNeighborhoodCharterFrame:SetActiveLocation(locationName);
	ShowUIPanel(HousingCreateNeighborhoodCharterFrame);
end

function HousingEventHandlerMixin:OpenCreateCharterNeighborhoodConfirmation(neighborhoodName, locationName)
	if not HousingCreateCharterNeighborhoodConfirmationFrame then
		C_AddOns.LoadAddOn("Blizzard_HousingCreateNeighborhood");
	end
	HousingCreateCharterNeighborhoodConfirmationFrame:SetCharterInfo(neighborhoodName, locationName);
	ShowUIPanel(HousingCreateCharterNeighborhoodConfirmationFrame);
end

StaticPopupDialogs["HOUSING_BULLETIN_EVICTED_CONFIRMATION"] = {
	text = HOUSING_BULLETINBOARD_EVICTED_CONFIRMATION_TEXT,
	button1 = HOUSING_BULLETINBOARD_EVICT_CONFIRMATION_CONFIRM,
};

function HousingEventHandlerMixin:ShowPlayerEvictedConfirmation()
	StaticPopup_Show("HOUSING_BULLETIN_EVICTED_CONFIRMATION");
end

StaticPopupDialogs["HOUSING_TRANSFER_OWNER_REQUEST_CONFIRMATION"] = {
	text = HOUSING_TRANSFER_OWNERSHIP_REQUEST_DIALOG,
	button1 = HOUSING_TRANSFER_OWNERSHIP_CONFIRM,
	button2 = HOUSING_TRANSFER_OWNERSHIP_REJECT,
	OnAccept = function(self)
		C_Housing.AcceptNeighborhoodOwnership();
		self:Hide();
	end,
	OnCancel = function (self)
		C_Housing.DeclineNeighborhoodOwnership();
		self:Hide();
	end,
};

function HousingEventHandlerMixin:ShowOwnershipTransferRequestConfirmation(neighborhoodName, currentOwnerName)
	StaticPopup_Show("HOUSING_TRANSFER_OWNER_REQUEST_CONFIRMATION", currentOwnerName, neighborhoodName);
end

StaticPopupDialogs["HOUSING_LAYOUT_STAIRS_DIRECTION_CONFIRM"] = {
	text = HOUSING_LAYOUT_STAIRS_CONFIRMATION,
	button1 = HOUSING_LAYOUT_STAIRS_UP,
	button2 = HOUSING_LAYOUT_STAIRS_DOWN,
	selectCallbackByIndex = true,
	closeButton = true,
	closeButtonIsHide = true,

	OnButton1 = function(self, data)
		C_HousingLayout.ConfirmStairChoice(Enum.HousingLayoutStairDirection.Up);
		self:Hide();
	end,
	OnButton2 = function(self, data)
		C_HousingLayout.ConfirmStairChoice(Enum.HousingLayoutStairDirection.Down);
		self:Hide();
	end,
	OnCloseClicked = function (self)
		C_HousingLayout.ConfirmStairChoice(nil);
		self:Hide();
	end,
	hideOnEscape = 0,
};

function HousingEventHandlerMixin:ShowStairDirectionConfirmation()
	StaticPopup_Show("HOUSING_LAYOUT_STAIRS_DIRECTION_CONFIRM");
end

function HousingEventHandlerMixin:ShowHousingItemAcquiredAlert(itemType, itemName, icon)
	local rewardData = {};
	rewardData.itemType = itemType;
	rewardData.itemName = itemName;
	rewardData.icon = icon;

	HousingItemEarnedAlertFrameSystem:AddAlert(rewardData);
end

local HousingEventHandler = CreateAndInitFromMixin(HousingEventHandlerMixin);
EventRegistry:RegisterFrameEventAndCallback("HOUSE_PLOT_ENTERED", HousingEventHandler.OnPlotEntered, HousingEventHandler);
EventRegistry:RegisterFrameEventAndCallback("HOUSE_EDITOR_MODE_CHANGED", HousingEventHandler.OnEditorModeChanged, HousingEventHandler);
EventRegistry:RegisterFrameEventAndCallback("HOUSE_EDITOR_MODE_CHANGE_FAILURE", HousingEventHandler.OnEditorModeChangeFailed, HousingEventHandler);
EventRegistry:RegisterFrameEventAndCallback("OPEN_PLOT_CORNERSTONE", HousingEventHandler.OpenCornerstone, HousingEventHandler);
EventRegistry:RegisterFrameEventAndCallback("OPEN_NEIGHBORHOOD_CHARTER", HousingEventHandler.OpenCharter, HousingEventHandler);
EventRegistry:RegisterFrameEventAndCallback("OPEN_NEIGHBORHOOD_CHARTER_SIGNATURE_REQUEST", HousingEventHandler.OpenCharterSignatureRequest, HousingEventHandler);
EventRegistry:RegisterFrameEventAndCallback("OPEN_CREATE_GUILD_NEIGHBORHOOD_UI", HousingEventHandler.OpenCreateGuildNeighborhoodUI, HousingEventHandler);
EventRegistry:RegisterFrameEventAndCallback("OPEN_CREATE_CHARTER_NEIGHBORHOOD_UI", HousingEventHandler.OpenCreateCharterNeighborhoodUI, HousingEventHandler);
EventRegistry:RegisterFrameEventAndCallback("OPEN_CHARTER_CONFIRMATION_UI", HousingEventHandler.OpenCreateCharterNeighborhoodConfirmation, HousingEventHandler);
EventRegistry:RegisterFrameEventAndCallback("SHOW_PLAYER_EVICTED_DIALOG", HousingEventHandler.ShowPlayerEvictedConfirmation, HousingEventHandler);
EventRegistry:RegisterFrameEventAndCallback("SHOW_NEIGHBORHOOD_OWNERSHIP_TRANSFER_DIALOG", HousingEventHandler.ShowOwnershipTransferRequestConfirmation, HousingEventHandler);
EventRegistry:RegisterFrameEventAndCallback("SHOW_STAIR_DIRECTION_CONFIRMATION", HousingEventHandler.ShowStairDirectionConfirmation, HousingEventHandler);
EventRegistry:RegisterFrameEventAndCallback("NEW_HOUSING_ITEM_ACQUIRED", HousingEventHandler.ShowHousingItemAcquiredAlert, HousingEventHandler);
