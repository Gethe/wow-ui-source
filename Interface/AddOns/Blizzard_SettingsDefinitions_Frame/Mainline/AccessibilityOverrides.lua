AccessibilityOverrides = {}

function AccessibilityOverrides.CreateArachnophobiaSetting(category, layout)
	local setting = Settings.RegisterCVarSetting(category, "arachnophobiaMode", Settings.VarType.Boolean, ARACHNOPHOBIA_MODE_CHECKBOX);
	local options = nil;
	local data = Settings.CreateSettingInitializerData(setting, options, ARACHNOPHOBIA_MODE_CHECKBOX_TOOLTIP);
	local initializer = Settings.CreateSettingInitializer("ArachnophobiaTemplate", data);

	layout:AddInitializer(initializer);
end
