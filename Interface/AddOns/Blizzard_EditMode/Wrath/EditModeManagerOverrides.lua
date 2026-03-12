--[[ Wrath EditModeManagerOverrides ]]

function EditModeAccountSettingsMixin:PrepareSettingCheckButtonVisibilityForClassicFlavor()
	self.settingsCheckButtons.VehicleSeatIndicator.shouldHide = false;
end

function EditModeAccountSettingsMixin:EditModeFrameSetupForClassicFlavor()
	self:SetupVehicleSeatIndicator();
	self:RefreshVehicleSeatIndicator();
end
