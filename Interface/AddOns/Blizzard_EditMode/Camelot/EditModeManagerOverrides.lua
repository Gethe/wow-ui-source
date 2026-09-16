--[[ Camelot EditModeManagerOverrides ]]

function EditModeAccountSettingsMixin:PrepareSettingCheckButtonVisibilityForCamelotFlavor()
	self.settingsCheckButtons.ArchaeologyBar.shouldHide = true;
	self.settingsCheckButtons.ArenaFrames.shouldHide = true;
	self.settingsCheckButtons.EncounterEvents.shouldHide = true;
	self.settingsCheckButtons.TalkingHeadFrame.shouldHide = true;
	self.settingsCheckButtons.VehicleSeatIndicator.shouldHide = true;
end

function EditModeAccountSettingsMixin:EditModeFrameSetupForCamelotFlavor()
	self:SetupTotemActionBar();
	self:SetupSwingTimer();

	self:RefreshTotemActionBar();
	self:RefreshSwingTimer();
end

function EditModeAccountSettingsMixin:ResetArenaFrames()
	-- CompactArenaFrame doesn't exist in Camelot
end

function EditModeAccountSettingsMixin:RefreshArenaFrames()
	-- CompactArenaFrame doesn't exist in Camelot
end

function EditModeAccountSettingsMixin:SetArenaFramesMouseOver(...)
	-- CompactArenaFrame doesn't exist in Camelot
end
