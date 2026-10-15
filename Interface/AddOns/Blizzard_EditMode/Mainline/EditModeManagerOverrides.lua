--[[ Mainline EditModeManagerOverrides ]]

function EditModeAccountSettingsMixin:PrepareSettingsCheckButtonVisibility()
	-- As a default, do not hide any settings.
	for _, checkButton in pairs(self.settingsCheckButtons) do
		checkButton.shouldHide = false;
	end

	self:PrepareSettingCheckButtonVisibilityForCamelotFlavor();
	self:PrepareSettingCheckButtonVisibilityForStandardFlavor();
end

function EditModeAccountSettingsMixin:PrepareSettingCheckButtonVisibilityForCamelotFlavor()
	-- Overridden
end

function EditModeAccountSettingsMixin:PrepareSettingCheckButtonVisibilityForStandardFlavor()
	-- Overridden
end

function EditModeAccountSettingsMixin:EditModeFrameSetup()
	self:SetupActionBar(StanceBar);
	self:SetupActionBar(PetActionBar);
	self:SetupActionBar(PossessActionBar);

	self:SetupStatusTrackingBar2();
	self:SetupDurabilityFrame();
	self:SetupPetFrame();
	self:SetupTimerBars();
	self:SetupVehicleSeatIndicator();
	self:SetupArchaeologyBar();

	self:RefreshTargetAndFocus();
	self:RefreshPartyFrames();
	self:RefreshRaidFrames()
	self:RefreshCastBar();
	self:RefreshEncounterBar();
	self:RefreshExtraAbilities();
	self:RefreshBuffsAndDebuffs();
	self:RefreshExternalDefensives();
	self:RefreshTalkingHeadFrame();
	self:RefreshVehicleLeaveButton();
	self:RefreshBossFrames();
	self:RefreshArenaFrames();
	self:RefreshLootFrame();
	self:RefreshHudTooltip();
	self:RefreshStatusTrackingBar2();
	self:RefreshDurabilityFrame();
	self:RefreshPetFrame();
	self:RefreshTimerBars();
	self:RefreshVehicleSeatIndicator();
	self:RefreshArchaeologyBar();
	self:RefreshCooldownViewer();
	self:RefreshPersonalResourceDisplay();
	self:RefreshDamageMeter();
	self:RefreshGroupFinder();
	self:RefreshLossOfControl();

	self:EditModeFrameSetupForCamelotFlavor();
	self:EditModeFrameSetupForStandardFlavor();
end

function EditModeAccountSettingsMixin:EditModeFrameSetupForCamelotFlavor()
	-- Overridden
end

function EditModeAccountSettingsMixin:EditModeFrameSetupForStandardFlavor()
	-- Overridden
end

function EditModeAccountSettingsMixin:EditModeFrameReset()
	self:ResetTargetAndFocus();
	self:ResetPartyFrames();
	self:ResetRaidFrames();
	self:ResetArenaFrames();
	self:ResetHudTooltip();
	self:ResetRaidWarning();

	self:ResetActionBarShown(StanceBar);
	self:ResetActionBarShown(PetActionBar);
	self:ResetActionBarShown(PossessActionBar);
end

function EditModeManagerFrameMixin:GetRightActionBars()
	return { MultiBarRight, MultiBarLeft };
end

function EditModeManagerFrameMixin:GetRightActionBarTopLimit()
	return MinimapCluster:IsInDefaultPosition() and (MinimapCluster:GetBottom() - 10) or UIParent:GetTop();
end

function EditModeManagerFrameMixin:GetRightActionBarBottomLimit()
	return MicroButtonAndBagsBar:GetTop() + 24;
end
