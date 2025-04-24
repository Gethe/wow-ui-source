local ActionBarSettingsTogglesCache = nil;
local ActionBarSettingsLastCacheTime = 0;
local ActionBarSettingsCacheTimeout = 10;

local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(ACTIONBARS_LABEL);
	Settings.ACTION_BAR_CATEGORY_ID = category:GetID();

	-- Order set in GameplaySettingsGroup.lua
	category:SetOrder(CUSTOM_GAMEPLAY_SETTINGS_ORDER[ACTIONBARS_LABEL]);

	ActionBarsOverrides.CreateActionBarVisibilitySettings(category, ActionBarSettingsTogglesCache, ActionBarSettingsLastCacheTime, ActionBarSettingsCacheTimeout);

	-- Lock Action Bars
	do
		local cbSetting = Settings.RegisterCVarSetting(category, "lockActionBars", Settings.VarType.Boolean, LOCK_ACTIONBAR_TEXT);

		local tooltips = {
			OPTION_TOOLTIP_PICKUP_ACTION_ALT_KEY,
			OPTION_TOOLTIP_PICKUP_ACTION_CTRL_KEY,
			OPTION_TOOLTIP_PICKUP_ACTION_SHIFT_KEY,
			OPTION_TOOLTIP_PICKUP_ACTION_NONE_KEY,
		};
		local options = Settings.CreateModifiedClickOptions(tooltips);
		local dropdownSetting = Settings.RegisterModifiedClickSetting(category, "PICKUPACTION", PICKUP_ACTION_KEY_TEXT, "SHIFT");

		local initializer = CreateSettingsCheckboxDropdownInitializer(
			cbSetting, LOCK_ACTIONBAR_TEXT, OPTION_TOOLTIP_LOCK_ACTIONBAR,
			dropdownSetting, options, PICKUP_ACTION_KEY_TEXT, OPTION_TOOLTIP_PICKUP_ACTION_KEY_TEXT);
		initializer:AddSearchTags(LOCK_ACTIONBAR_TEXT);
		layout:AddInitializer(initializer);
	end

	-- Show Numbers for Cooldowns
	ActionBarsOverrides.RunSettingsCallback(function()
	Settings.SetupCVarCheckbox(category, "countdownForCooldowns", COUNTDOWN_FOR_COOLDOWNS_TEXT, OPTION_TOOLTIP_COUNTDOWN_FOR_COOLDOWNS);
	end);

	ActionBarsOverrides.AdjustActionBarSettings(category, layout);

	Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);
end

SettingsRegistrar:AddRegistrant(Register);