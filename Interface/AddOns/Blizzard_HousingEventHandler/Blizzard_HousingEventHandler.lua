-- Helpers for non-Housing code needing to make housing-related API calls while relevant Housing addons may not be loaded (ex: Keybindings)
HousingFramesUtil = {};

function HousingFramesUtil.ToggleHouseEditor()
	if C_HouseEditor.IsHouseEditorActive() then
		C_HouseEditor.LeaveHouseEditor();
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

function HousingFramesUtil.ActivateHouseEditorMode(mode)
	local modeAvailability = C_HouseEditor.GetHouseEditorModeAvailability(mode);
	if modeAvailability ~= Enum.HousingResult.Success or (not HousingTutorialUtil.HousingQuestTutorialComplete() and not HousingTutorialUtil.IsModeValidForTutorial(mode)) then
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

function HousingFramesUtil.DeleteDecor()
	if C_HousingDecor.IsDecorSelected() then
		PlaySound(SOUNDKIT.HOUSING_DECOR_EDIT_OPTION_REMOVE_ITEM);
	end

	C_HousingDecor.DeleteDecor();
end

function HousingFramesUtil.SetGridSnapEnabled(gridSnapEnabled)
	PlaySound(SOUNDKIT.HOUSING_PRIMARY_SUB_MENU_BUTTON_TOGGLE_SHORTCUT);
	C_HousingBasicMode.SetGridSnapEnabled(gridSnapEnabled);
end

function HousingFramesUtil.SetNudgeEnabled(nudgeEnabled)
	PlaySound(SOUNDKIT.HOUSING_PRIMARY_SUB_MENU_BUTTON_TOGGLE_SHORTCUT);
	C_HousingBasicMode.SetNudgeEnabled(nudgeEnabled);
end

function HousingFramesUtil.ZoomLayoutCamera(zoom)
	PlaySound(zoom and SOUNDKIT.HOUSING_LAYOUT_ZOOM_IN or SOUNDKIT.HOUSING_LAYOUT_ZOOM_OUT);
	C_HousingLayout.ZoomLayoutCamera(zoom);
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
