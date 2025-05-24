AccessibilityOverrides = {}

function AccessibilityOverrides.CreatePhotosensitivitySetting(category)
	local setting, initializer = Settings.SetupCVarCheckbox(category, "overrideScreenFlash", ALTERNATE_SCREEN_EFFECTS, OPTION_TOOLTIP_ALTERNATE_SCREEN_EFFECTS);
	initializer:AddSearchTags(ALTERNATE_SCREEN_EFFECTS_SEARCH_TAG);
	initializer:AddSearchTags(MOTION_SICKNESS_CHECKBOX);
end

function AccessibilityOverrides.CreateArachnophobiaSetting(category, layout)
	local setting = Settings.RegisterCVarSetting(category, "arachnophobiaMode", Settings.VarType.Boolean, ARACHNOPHOBIA_MODE_CHECKBOX);
	local options = nil;
	local data = Settings.CreateSettingInitializerData(setting, options, ARACHNOPHOBIA_MODE_CHECKBOX_TOOLTIP);
	local initializer = Settings.CreateSettingInitializer("ArachnophobiaTemplate", data);

	layout:AddInitializer(initializer);
end