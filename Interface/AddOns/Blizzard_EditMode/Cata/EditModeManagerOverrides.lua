--[[ Cata EditModeManagerOverrides ]]

function EditModeAccountSettingsMixin:PrepareSettingCheckButtonVisibilityForClassicFlavor()
	self.settingsCheckButtons.VehicleSeatIndicator.shouldHide = false;
	self.settingsCheckButtons.TotemActionBar.shouldHide = false;
	self.settingsCheckButtons.ExtraAbilities.shouldHide = false;
end

function EditModeAccountSettingsMixin:EditModeFrameSetupForClassicFlavor()
	self:SetupVehicleSeatIndicator();
	self:SetupTotemActionBar();
	self:RefreshVehicleSeatIndicator();
	self:RefreshTotemActionBar();
	self:RefreshExtraAbilities();
end
