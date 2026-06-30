BaseHousingControlButtonMixin = {};

function BaseHousingControlButtonMixin:GetDefaultTexture()
	return self.iconDefault, true;
end

function BaseHousingControlButtonMixin:GetIconForState(state)
	-- Overrides BaseHousingActionButtonMixin
	local iconName = self.iconDefault;
	local isAtlas = true;

	if state.isEnabled then
		if state.isPressed then
			iconName = self.iconPressed;
		elseif state.isActive then
			iconName = self.iconActive;
		end
	end

	return iconName, isAtlas;
end

function BaseHousingControlButtonMixin:GetIconColorForState(state)
	-- Overrides BaseHousingActionButtonMixin
	return state.isEnabled and WHITE_FONT_COLOR or DARKGRAY_COLOR;
end

function BaseHousingControlButtonMixin:IsActive()
	if self.notYetImplemented then
		return false;
	end
	-- If implemented, this should be overriden
	assert(false);
end

function BaseHousingControlButtonMixin:CheckEnabled()
	if Kiosk.IsEnabled() then
		return false, ERR_SYSTEM_DISABLED;
	end

	if self.notYetImplemented then
		return false, self.nyiLabel;
	end
	-- If implemented, this should be overriden
	assert(false);
end

function BaseHousingControlButtonMixin:OnClick()
	if self.notYetImplemented then
		return;
	end

	if self:IsEnabled() and self.clickSoundKit then
		PlaySound(self.clickSoundKit);
	end

	BaseHousingModeButtonMixin.OnClick(self);
end

-- Inherits BaseHousingControlButtonMixin
HouseEditorButtonMixin = {};

function HouseEditorButtonMixin:CheckEnabled()
	local availabilityResult = C_HouseEditor.GetHouseEditorAvailability();
	if availabilityResult == Enum.HousingResult.Success then
		return true;
	end

	local errorText = HousingResultToErrorText[availabilityResult];
	if errorText then
		errorText = HOUSING_CONTROLS_EDITOR_UNAVAILABLE_FMT:format(errorText);
	else
		errorText = HOUSING_CONTROLS_EDITOR_UNAVAILABLE;
	end

	return false, errorText;
end

function HouseEditorButtonMixin:IsActive()
	return C_HouseEditor.IsHouseEditorActive();
end

function HouseEditorButtonMixin:EnterMode()
	local initialResult = C_HouseEditor.EnterHouseEditor();
	if initialResult ~= Enum.HousingResult.Success then
		local errorText = HousingResultToErrorText[initialResult];
		if errorText and errorText ~= "" then
			UIErrorsFrame:AddExternalErrorMessage(errorText);
		end
	end
end

function HouseEditorButtonMixin:LeaveMode()
	HousingFramesUtil.LeaveHouseEditor();
end

-- Inherits BaseHousingControlButtonMixin
HouseExitButtonMixin = {};

function HouseExitButtonMixin:OnClick()
	if Kiosk.IsEnabled() then
		return;
	end

	if self:IsEnabled() and self.clickSoundKit then
		PlaySound(self.clickSoundKit);
	end

	C_Housing.LeaveHouse();
end

function HouseExitButtonMixin:IsActive()
	return false;
end

function HouseExitButtonMixin:CheckEnabled()
	if Kiosk.IsEnabled() then
		return false, ERR_SYSTEM_DISABLED;
	end

	return C_Housing.IsInsideHouse() and not C_HouseEditor.IsHouseEditorActive();
end

-- Inherits BaseHousingControlButtonMixin
HousingBlueprintActionButtonMixin = {};

function HousingBlueprintActionButtonMixin:OnClick()
	if self:IsEnabled() and self.clickSoundKit then
		PlaySound(self.clickSoundKit);
	end

	MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
		rootDescription:SetTag("MENU_HOUSING_BLUEPRINT_ACTION");
		rootDescription:AddMenuAcquiredCallback(function(menuFrame)
			self.contextMenuIsOpen = true;
			-- Reevaluate tooltip so it's hidden
			if self:IsMouseMotionFocus() then
				self:OnEnter();
			end
		end);
		rootDescription:AddMenuReleasedCallback(function(menuFrame, closeReason)
			self.contextMenuIsOpen = false;
			-- Reevaluate tooltip so it's shown
			if self:IsMouseMotionFocus() then
				self:OnEnter();
			end
		end);

		if C_HousingBlueprint.GetImportAvailability() == Enum.HousingResult.Success then
			rootDescription:CreateButton(HOUSING_CONTROLS_BLUEPRINT_IMPORT, function()
				HousingFramesUtil.ShowBlueprintImport();
			end);
		end
		
		if C_HousingBlueprint.GetExportAvailability() == Enum.HousingResult.Success then
			rootDescription:CreateButton(HOUSING_CONTROLS_BLUEPRINT_EXPORT, function()
				HousingFramesUtil.ShowBlueprintExport();
			end);
		end
		
	end);
end

function HousingBlueprintActionButtonMixin:AddEnabledTooltipText(tooltip)
	-- Avoid showing tooltip text while the context menu is open
	if self.contextMenuIsOpen then
		return false;
	end
	GameTooltip_AddHighlightLine(tooltip, HOUSING_CONTROLS_BLUEPRINT_TOOLTIP);
	return true;
end

function HousingBlueprintActionButtonMixin:IsActive()
	return false;
end

function HousingBlueprintActionButtonMixin:CheckEnabled()
	if Kiosk.IsEnabled() then
		return false, ERR_SYSTEM_DISABLED;
	end

	local blueprintsAvailability = C_HousingBlueprint.GetFeatureAvailability();
	if blueprintsAvailability ~= Enum.HousingResult.Success then
		local errorText = HousingResultToErrorText[availabilityResult] or ERR_SYSTEM_DISABLED;
		return false, errorText;
	end

	if C_HouseEditor.IsHouseEditorActive() then
		return false, HOUSING_CONTROLS_BLUEPRINT_UNAVAILABLE_EDITOR;
	end

	if C_HousingBlueprint.GetExportAvailability() ~= Enum.HousingResult.Success and C_HousingBlueprint.GetImportAvailability() ~= Enum.HousingResult.Success then
		return false, HOUSING_CONTROLS_BLUEPRINT_UNAVAILABLE_PERMISSION;
	end

	return true;
end


-- Inherits BaseHousingControlButtonMixin
HouseInfoButtonMixin = {};

function HouseInfoButtonMixin:OnClick()
	C_AddOns.LoadAddOn("Blizzard_HousingCornerstone");

	if self:IsEnabled() and self.clickSoundKit then
		PlaySound(self.clickSoundKit);
	end

	ToggleUIPanel(HousingCornerstoneHouseInfoFrame);
end

function HouseInfoButtonMixin:CheckEnabled()
	return true;
end

function HouseInfoButtonMixin:IsActive()
	return HousingCornerstoneHouseInfoFrame and HousingCornerstoneHouseInfoFrame:IsShown();
end

-- Inherits BaseHousingControlButtonMixin
HouseInspectorButtonMixin = {};

function HouseInspectorButtonMixin:EnterMode()
	if not HousingInspectModeManagerFrame then
		C_AddOns.LoadAddOn("Blizzard_HousingInspectModeUI");
	end

	C_HousingInspectMode.EnterInspectMode();
end

function HouseInspectorButtonMixin:LeaveMode()
	C_HousingInspectMode.ExitInspectMode();
end

function HouseInspectorButtonMixin:CheckEnabled()
	-- Inspect mode cannot be entered if the HouseEditor is active
	if C_HouseEditor.IsHouseEditorActive() then
		return false, HOUSING_CONTROLS_INSPECT_UNAVAILABLE_EDITOR_ACTIVE;
	end

	return true;
end

function HouseInspectorButtonMixin:IsActive()
	return C_HousingInspectMode.IsInInspectMode();
end

-- Inherits HousingControlModeButtonMixin
HouseSettingsButtonMixin = {};

function HouseSettingsButtonMixin:EnterMode()
    if not HousingHouseSettingsFrame then
        C_AddOns.LoadAddOn("Blizzard_HousingHouseSettings");
    end
    ShowUIPanel(HousingHouseSettingsFrame);
end

function HouseSettingsButtonMixin:LeaveMode()
    HideUIPanel(HousingHouseSettingsFrame);
end

function HouseSettingsButtonMixin:IsActive()
	return HousingHouseSettingsFrame and HousingHouseSettingsFrame:IsShown();
end

function HouseSettingsButtonMixin:CheckEnabled()
	if Kiosk.IsEnabled() then
		return false, ERR_SYSTEM_DISABLED;
	end

	local editorPlayerType = C_HouseEditor.GetHouseEditorPlayerType();
	if editorPlayerType == Enum.HouseEditorPlayerType.Owner then
		return true;
	end

	return false, HOUSING_CONTROLS_SETTINGS_UNAVAILABLE;
end

