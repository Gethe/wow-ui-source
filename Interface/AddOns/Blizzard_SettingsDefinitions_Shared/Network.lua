local function Register()
	if Kiosk.IsEnabled() then
		return;
	end

	local category, layout = Settings.RegisterVerticalLayoutCategory(NETWORK_LABEL);

	-- Optimize Net for Speed
	local setting = Settings.SetupCVarCheckbox(category, "disableServerNagle", OPTIMIZE_NETWORK_SPEED, OPTION_TOOLTIP_OPTIMIZE_NETWORK_SPEED);
	setting:SetCommitFlags(Settings.CommitFlag.KioskProtected);

	-- Enable IPV6
	setting = Settings.SetupCVarCheckbox(category, "useIPv6", USEIPV6, OPTION_TOOLTIP_USEIPV6);
	setting:SetCommitFlags(Settings.CommitFlag.KioskProtected);

	-- Advanced Combat Logging
	setting = Settings.SetupCVarCheckbox(category, "advancedCombatLogging", ADVANCED_COMBAT_LOGGING, OPTION_TOOLTIP_ADVANCED_COMBAT_LOGGING);
	setting:SetCommitFlags(Settings.CommitFlag.KioskProtected);

	Settings.RegisterCategory(category, SETTING_GROUP_SYSTEM);
end

SettingsRegistrar:AddRegistrant(Register);
