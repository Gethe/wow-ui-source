local function Register()
	if Kiosk.IsEnabled() then
		return;
	end

	local category, layout = Settings.RegisterVerticalLayoutCategory(NETWORK_LABEL);

	-- Optimize Net for Speed
	Settings.SetupCVarCheckbox(category, "disableServerNagle", OPTIMIZE_NETWORK_SPEED, OPTION_TOOLTIP_OPTIMIZE_NETWORK_SPEED);

	-- Enable IPV6
	Settings.SetupCVarCheckbox(category, "useIPv6", USEIPV6, OPTION_TOOLTIP_USEIPV6);

	-- Advanced Combat Logging
	Settings.SetupCVarCheckbox(category, "advancedCombatLogging", ADVANCED_COMBAT_LOGGING, OPTION_TOOLTIP_ADVANCED_COMBAT_LOGGING);

	Settings.RegisterCategory(category, SETTING_GROUP_SYSTEM);
end

SettingsRegistrar:AddRegistrant(Register);