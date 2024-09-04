ActionBarsOverrides = {}

function ActionBarsOverrides.CreateActionBarVisibilitySettings(category, ActionBarSettingsTogglesCache, ActionBarSettingsLastCacheTime, ActionBarSettingsCacheTimeout)
		local actionBars = 
		{
			{variable = "PROXY_SHOW_ACTIONBAR_2", label = OPTION_SHOW_ACTION_BAR:format(2), tooltip = OPTION_TOOLTIP_SHOW_MULTIBAR1 },
			{variable = "PROXY_SHOW_ACTIONBAR_3", label = OPTION_SHOW_ACTION_BAR:format(3), tooltip = OPTION_TOOLTIP_SHOW_MULTIBAR2 },
			{variable = "PROXY_SHOW_ACTIONBAR_4", label = OPTION_SHOW_ACTION_BAR:format(4), tooltip = OPTION_TOOLTIP_SHOW_MULTIBAR3 },
			{variable = "PROXY_SHOW_ACTIONBAR_5", label = OPTION_SHOW_ACTION_BAR:format(5), tooltip = OPTION_TOOLTIP_SHOW_MULTIBAR4 },
		};

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
			MultiActionBar_Update();
		end

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

			-- For the Right Bars, you can't turn on 4 if you don't have 3 enabled
			if(index == 4) then
				local function IsModifiable()
					return actionBars[index-1].setting:GetValue();
				end
				actionBars[index].initializer:SetParentInitializer(actionBars[index-1].initializer, IsModifiable);
			end
		end
end

function ActionBarsOverrides.AdjustActionBarSettings(category)
	-- Always Show Action Bars
	local setting = Settings.SetupCVarCheckbox(category, "alwaysShowActionBars", ALWAYS_SHOW_MULTIBARS_TEXT, OPTION_TOOLTIP_ALWAYS_SHOW_MULTIBARS);
	setting:SetValueChangedCallback(function(value)
		MultiActionBar_UpdateGridVisibility();
	end);
end
function ActionBarsOverrides.RunSettingsCallback(callback)
	callback();
end