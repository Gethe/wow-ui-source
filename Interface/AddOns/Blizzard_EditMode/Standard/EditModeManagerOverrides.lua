--[[ Standard EditModeManagerOverrides ]]

function EditModeAccountSettingsMixin:PrepareSettingCheckButtonVisibilityForStandardFlavor()
	self.settingsCheckButtons.TotemActionBar.shouldHide = true;
	self.settingsCheckButtons.SwingTimer.shouldHide = true;
end

function EditModeAccountSettingsMixin:EditModeFrameSetupForStandardFlavor()
	self:SetupEncounterBar();

	self:RefreshEncounterEvents();
	self:RefreshRaidWarning();
end
