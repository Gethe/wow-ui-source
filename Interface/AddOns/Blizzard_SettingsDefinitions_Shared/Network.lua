local function Register()
	if Kiosk.IsEnabled() then
		return;
	end

	local category, layout = Settings.RegisterVerticalLayoutCategory(NETWORK_LABEL);

	-- Advanced Combat Logging
	local setting = Settings.SetupCVarCheckbox(category, "advancedCombatLogging", ADVANCED_COMBAT_LOGGING, OPTION_TOOLTIP_ADVANCED_COMBAT_LOGGING);
	setting:SetCommitFlags(Settings.CommitFlag.KioskProtected);

	if not GetBuildOption("DisableNagleAndIPV6Options") then
		-- Optimize Net for Speed
		setting = Settings.SetupCVarCheckbox(category, "disableServerNagle", OPTIMIZE_NETWORK_SPEED, OPTION_TOOLTIP_OPTIMIZE_NETWORK_SPEED);
		setting:SetCommitFlags(Settings.CommitFlag.KioskProtected);

		-- Enable IPV6
		setting = Settings.SetupCVarCheckbox(category, "useIPv6", USEIPV6, OPTION_TOOLTIP_USEIPV6);
		setting:SetCommitFlags(Settings.CommitFlag.KioskProtected);
	end

	Settings.RegisterCategory(category, SETTING_GROUP_SYSTEM);
end

SettingsRegistrar:AddRegistrant(Register);
