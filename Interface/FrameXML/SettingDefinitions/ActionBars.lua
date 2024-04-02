local ActionBarSettingsTogglesCache = nil;
local ActionBarSettingsLastCacheTime = 0;
local ActionBarSettingsCacheTimeout = 10;

local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(ACTIONBARS_LABEL);
	Settings.ACTION_BAR_CATEGORY_ID = category:GetID();

	-- Order set in GameplaySettingsGroup.lua
	category:SetOrder(CUSTOM_GAMEPLAY_SETTINGS_ORDER[ACTIONBARS_LABEL]);

	-- Action Bars 1-4. Plunderstorm doesn't have usual action bars.
	if not Settings.IsPlunderstorm() then
		ActionBarsOverrides.CreateActionBarVisibilitySettings(category, ActionBarSettingsTogglesCache, ActionBarSettingsLastCacheTime, ActionBarSettingsCacheTimeout);
	end

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
		local dropDownSetting = Settings.RegisterModifiedClickSetting(category, "PICKUPACTION", PICKUP_ACTION_KEY_TEXT, "SHIFT");

		local initializer = CreateSettingsCheckBoxDropDownInitializer(
			cbSetting, LOCK_ACTIONBAR_TEXT, OPTION_TOOLTIP_LOCK_ACTIONBAR,
			dropDownSetting, options, PICKUP_ACTION_KEY_TEXT, OPTION_TOOLTIP_PICKUP_ACTION_KEY_TEXT);
		initializer:AddSearchTags(LOCK_ACTIONBAR_TEXT);
		layout:AddInitializer(initializer);
	end

	-- Show Numbers for Cooldowns
	if not Settings.IsPlunderstorm() then
		Settings.SetupCVarCheckBox(category, "countdownForCooldowns", COUNTDOWN_FOR_COOLDOWNS_TEXT, OPTION_TOOLTIP_COUNTDOWN_FOR_COOLDOWNS);
	end

	-- Add mirrors of these keybindings for easy access
	if Settings.IsPlunderstorm() then
		local actions = { "WOWLABS_ACTIONBUTTON1", "WOWLABS_ACTIONBUTTON2", "WOWLABS_MULTIACTIONBAR1BUTTON1", "WOWLABS_MULTIACTIONBAR1BUTTON2", 
						"WOWLABS_MULTIACTIONBAR2BUTTON1", "WOWLABS_MULTIACTIONBAR2BUTTON2", "WOWLABS_ITEM1" };
		for _, action in pairs(actions) do
			local bindingIndex = C_KeyBindings.GetBindingIndex(action);
			if bindingIndex then
				local initializer = CreateKeybindingEntryInitializer(bindingIndex, true);
				initializer:AddSearchTags(GetBindingName(action));
				layout:AddInitializer(initializer);
			end
		end
	end

	ActionBarsOverrides.AdjustActionBarSettings(category);

	Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);
end

SettingsRegistrar:AddRegistrant(Register);