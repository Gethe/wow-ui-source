ActionBarsOverrides = {}

function ActionBarsOverrides.CreateActionBarVisibilitySettings(category, ActionBarSettingsTogglesCache, ActionBarSettingsLastCacheTime, ActionBarSettingsCacheTimeout)
	-- Action Bars 1-4. Plunderstorm doesn't have usual action bars.
	if Settings.IsPlunderstorm() then
		return;
	end

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
			actionBars[index].initializer = Settings.CreateCheckbox(category, setting, data.tooltip);
		end
end

function ActionBarsOverrides.AdjustActionBarSettings(category, layout)
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
end

function ActionBarsOverrides.RunSettingsCallback(callback)
	if not Settings.IsPlunderstorm() then
		callback();
	end
end