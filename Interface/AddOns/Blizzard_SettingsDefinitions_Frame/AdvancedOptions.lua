local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(ADVANCED_OPTIONS_LABEL);
	Settings.ADVANCED_OPTIONS_CATEGORY_ID = category:GetID();

	-- Order set in GameplaySettingsGroup.lua
	category:SetOrder(CUSTOM_GAMEPLAY_SETTINGS_ORDER[ADVANCED_OPTIONS_LABEL]);

	-- Cooldown Viewer
	InterfaceOverrides.RunSettingsCallback(function()
		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(COOLDOWN_VIEWER_LABEL));
	end);

	InterfaceOverrides.RunSettingsCallback(function()
		Settings.SetupCVarCheckbox(category, "cooldownViewerEnabled", ENABLE_COOLDOWN_VIEWER, ENABLE_COOLDOWN_VIEWER_TOOLTIP);
	end);

	Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);
end

SettingsRegistrar:AddRegistrant(Register);
