AccessibilityOverrides = {}

function AccessibilityOverrides.CreatePhotosensitivitySetting(category)
	local setting, initializer = Settings.SetupCVarCheckbox(category, "overrideScreenFlash", ALTERNATE_SCREEN_EFFECTS, OPTION_TOOLTIP_ALTERNATE_SCREEN_EFFECTS);
	initializer:AddSearchTags(ALTERNATE_SCREEN_EFFECTS_SEARCH_TAG);
	initializer:AddSearchTags(MOTION_SICKNESS_CHECKBOX);
end