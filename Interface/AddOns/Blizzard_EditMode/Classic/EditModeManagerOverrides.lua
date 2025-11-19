--[[ Classic EditModeManagerOverrides ]]

function EditModeAccountSettingsMixin:PrepareSettingsCheckButtonVisibility()
	-- For Classic, default all settings to hide,
	-- then pick and choose what we want to show.
	for _, checkButton in pairs(self.settingsCheckButtons) do
		checkButton.shouldHide = true;
	end

	-- Classic settings to show.
	self.settingsCheckButtons.TargetAndFocus.shouldHide = false;
	self.settingsCheckButtons.PartyFrames.shouldHide = false;
	self.settingsCheckButtons.RaidFrames.shouldHide = false;
	self.settingsCheckButtons.StanceBar.shouldHide = false;
	self.settingsCheckButtons.PetActionBar.shouldHide = false;
	self.settingsCheckButtons.PossessActionBar.shouldHide = false;
	self.settingsCheckButtons.CastBar.shouldHide = false;
	self.settingsCheckButtons.BuffsAndDebuffs.shouldHide = false;
	self.settingsCheckButtons.StatusTrackingBar2.shouldHide = false;
	self.settingsCheckButtons.DurabilityFrame.shouldHide = false;
	self.settingsCheckButtons.PetFrame.shouldHide = false;
end

function EditModeAccountSettingsMixin:EditModeFrameSetup()
	self:SetupActionBar(StanceBar);
	self:SetupActionBar(PetActionBar);
	self:SetupActionBar(PossessActionBar);

	self:SetupStatusTrackingBar2();
	self:SetupDurabilityFrame();
	self:SetupPetFrame();

	self:RefreshTargetAndFocus();
	self:RefreshPartyFrames();
	self:RefreshRaidFrames()
	self:RefreshCastBar();
	self:RefreshBuffsAndDebuffs();
	self:RefreshStatusTrackingBar2();
	self:RefreshDurabilityFrame();
	self:RefreshPetFrame();
end

function EditModeAccountSettingsMixin:EditModeFrameReset()
	self:ResetTargetAndFocus();
	self:ResetPartyFrames();
	self:ResetRaidFrames();

	self:ResetActionBarShown(StanceBar);
	self:ResetActionBarShown(PetActionBar);
	self:ResetActionBarShown(PossessActionBar);
end

function EditModeManagerFrameMixin:GetRightActionBars()
	return { MultiBarRight, MultiBarLeft };
end

function EditModeManagerFrameMixin:GetRightActionBarTopLimit()
	return UIParent:GetTop();
end

function EditModeManagerFrameMixin:GetRightActionBarBottomLimit()
	return UIParent:GetBottom();
end

function EditModeManagerFrameMixin:GetBottomActionBars()
	-- Note: Classic's other bottom action bars are handled by UIParent_ManageFramePositions.
	-- MainActionBar is the only one that we want to consistently be in the default position.
	return { MainActionBar };
end
