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
	local canActivate, errorText = HousingControlsUtil.CanActivateHousingControls(availabilityResult);
	if not canActivate then
		if errorText then
			errorText = HOUSING_CONTROLS_EDITOR_UNAVAILABLE_FMT:format(errorText);
		else
			errorText = HOUSING_CONTROLS_EDITOR_UNAVAILABLE;
		end
	end

	return canActivate, errorText;
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
	C_HouseEditor.LeaveHouseEditor();
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

	return C_Housing.IsInsideHouse();
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

	-- TODO: in the future when non-owners can edit a house, we need to check for ownership properly.
	-- For now we're just going to assume the same availability applies.
	local availabilityResult = C_HouseEditor.GetHouseEditorAvailability();
	local canActivate, errorText = HousingControlsUtil.CanActivateHousingControls(availabilityResult);
	if not canActivate then
		if errorText then
			errorText = HOUSING_CONTROLS_SETTINGS_UNAVAILABLE_FMT:format(errorText);
		else
			errorText = HOUSING_CONTROLS_SETTINGS_UNAVAILABLE;
		end
	end

	return canActivate, errorText;
end
