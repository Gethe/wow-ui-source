AudioOverrides = {}

function AudioOverrides.CreatePingSoundSettings(category, layout)
	if not IsOnGlueScreen() then
		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(PING_SYSTEM_LABEL));

		-- Enable Ping Sounds and Ping Volume
		local enableSetting = Settings.RegisterCVarSetting(category, "Sound_EnablePingSounds", Settings.VarType.Boolean, ENABLE_PING_SOUNDS);
		local volumeSetting = Settings.RegisterCVarSetting(category, "Sound_PingVolume", Settings.VarType.Number, PING_VOLUME);

		local minValue, maxValue, step = 0, 1, .05;
		local function Formatter(value)
			local roundToNearestInteger = true;
			return FormatPercentage(value, roundToNearestInteger);
		end
		local sliderOptions = Settings.CreateSliderOptions(minValue, maxValue, step);
		sliderOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, Formatter);

		local initializer = CreateSettingsCheckboxSliderInitializer(
				enableSetting, ENABLE_PING_SOUNDS, OPTION_TOOLTIP_ENABLE_PING_SOUNDS,
				volumeSetting, sliderOptions, PING_VOLUME, OPTION_TOOLTIP_PING_VOLUME);

		initializer:AddSearchTags(ENABLE_PING_SOUNDS);

		layout:AddInitializer(initializer);

		-- Mirror in PingSystem
		Settings.PingSoundsInitializer = initializer;

		-- Button which links to Ping System Settings
		local function onButtonClick()
			Settings.OpenToCategory(Settings.PINGSYSTEM_CATEGORY_ID, ENABLE_PINGS);
		end
		local addSearchTags = false;
		initializer = CreateSettingsButtonInitializer("", PING_SYSTEM_SETTINGS, onButtonClick, nil, addSearchTags);
		layout:AddInitializer(initializer);
	end
end