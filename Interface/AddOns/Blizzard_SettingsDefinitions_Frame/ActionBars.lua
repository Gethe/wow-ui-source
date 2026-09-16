local ActionBarSettingsTogglesCache = nil;
local ActionBarSettingsLastCacheTime = 0;
local ActionBarSettingsCacheTimeout = 10;

ActionBarsOverrides = {}

function ActionBarsOverrides.CreateActionBarVisibilitySettings(category, ActionBarSettingsTogglesCache, ActionBarSettingsLastCacheTime, ActionBarSettingsCacheTimeout)
	local function GetActionBarToggle(index)
		return select(index, GetActionBarToggles());
	end

	local function SetActionBarToggle(index, value)
		-- Use local cache instead of GetActionBarToggles since it could lead to inconsistencies between UI and server state.
		-- If SetActionBarToggle is called multiple times before the server has mirrored the data back to the client, the client will send an outdated mask to the server and clear out values that were just set.
		-- Timeout the cache so we use latest mirror data after a period of time. This is incase actionbar toggles are set through macros or other addons, we need to make sure the settings still syncs with mirror data.
		if ( (ActionBarSettingsTogglesCache == nil) or (GetTime() - ActionBarSettingsLastCacheTime > ActionBarSettingsCacheTimeout) ) then
			ActionBarSettingsTogglesCache = {GetActionBarToggles()};
		end

		-- reset cache timeout each time set actionbar is called so that it doesnt timeout while toggling quickly
		ActionBarSettingsLastCacheTime = GetTime();

		ActionBarSettingsTogglesCache[index] = value;
		SetActionBarToggles(unpack(ActionBarSettingsTogglesCache));
	end

	local actionBars = 
	{
		{variable = "PROXY_SHOW_ACTIONBAR_2", label = OPTION_SHOW_ACTION_BAR:format(2), tooltip = OPTION_SHOW_ACTION_BAR2_TOOLTIP},
		{variable = "PROXY_SHOW_ACTIONBAR_3", label = OPTION_SHOW_ACTION_BAR:format(3), tooltip = OPTION_SHOW_ACTION_BAR3_TOOLTIP},
		{variable = "PROXY_SHOW_ACTIONBAR_4", label = OPTION_SHOW_ACTION_BAR:format(4), tooltip = OPTION_SHOW_ACTION_BAR4_TOOLTIP},
		{variable = "PROXY_SHOW_ACTIONBAR_5", label = OPTION_SHOW_ACTION_BAR:format(5), tooltip = OPTION_SHOW_ACTION_BAR5_TOOLTIP},
		{variable = "PROXY_SHOW_ACTIONBAR_6", label = OPTION_SHOW_ACTION_BAR:format(6), tooltip = OPTION_SHOW_ACTION_BAR6_TOOLTIP},
		{variable = "PROXY_SHOW_ACTIONBAR_7", label = OPTION_SHOW_ACTION_BAR:format(7), tooltip = OPTION_SHOW_ACTION_BAR7_TOOLTIP},
		{variable = "PROXY_SHOW_ACTIONBAR_8", label = OPTION_SHOW_ACTION_BAR:format(8), tooltip = OPTION_SHOW_ACTION_BAR8_TOOLTIP},
	};

	for index, data in ipairs(actionBars) do
		local function GetValue()
			return GetActionBarToggle(index);
		end

		local function SetValue(value)
			SetActionBarToggle(index, value);
		end

		local defaultValue = false;
		local setting = Settings.RegisterProxySetting(category, data.variable,
			Settings.VarType.Boolean, data.label, defaultValue, GetValue, SetValue);
		actionBars[index].setting = setting;

		if not C_GameRules.IsMultiActionBarVisibilityForced() then
			actionBars[index].initializer = Settings.CreateCheckbox(category, setting, data.tooltip);
		end
	end
end

function ActionBarsOverrides.AdjustActionBarSettings(category, layout)
	-- Add mirrors of these keybindings for easy access
	if C_GameRules.IsPlunderstorm() then
		local actions = { "WOWLABS_ACTIONBUTTON1", "WOWLABS_ACTIONBUTTON2", "WOWLABS_MULTIACTIONBAR1BUTTON1", "WOWLABS_MULTIACTIONBAR1BUTTON2", 
						"WOWLABS_MULTIACTIONBAR2BUTTON1", "WOWLABS_MULTIACTIONBAR2BUTTON2", "WOWLABS_ITEM1", "WOWLABS_SWAP_OFFENSIVES", "WOWLABS_SWAP_UTILITIES" };
		for _, action in pairs(actions) do
			local bindingIndex = C_KeyBindings.GetBindingIndex(action);
			if bindingIndex then
				local initializer = CreateKeybindingEntryInitializer(bindingIndex, true);
				initializer:AddSearchTags(GetBindingName(action));
				layout:AddInitializer(initializer);
			end
		end
	end	
end

function ActionBarsOverrides.RunSettingsCallback(callback)
	if not C_GameRules.IsPlunderstorm() then
		callback();
	end
end

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
