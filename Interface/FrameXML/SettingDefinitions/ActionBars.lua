local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(ACTIONBARS_LABEL);

	-- Order set in GameplaySettingsGroup.lua
	category:SetOrder(CUSTOM_GAMEPLAY_SETTINGS_ORDER[ACTIONBARS_LABEL]);

	-- Action Bars 1-4
	do
		local function GetActionBarToggle(index)
			return select(index, GetActionBarToggles());
		end
		
		local function SetActionBarToggle(index, value)
			local toggles = {GetActionBarToggles()};
			toggles[index] = value;
			SetActionBarToggles(unpack(toggles));
		end
		
		local actionBars = 
		{
			{variable = "PROXY_SHOW_ACTIONBAR_2", label = OPTION_SHOW_ACTION_BAR:format(2), tooltip = OPTION_SHOW_ACTION_BAR2_TOOLTIP},
			{variable = "PROXY_SHOW_ACTIONBAR_3", label = OPTION_SHOW_ACTION_BAR:format(3), tooltip = OPTION_SHOW_ACTION_BAR3_TOOLTIP},
			{variable = "PROXY_SHOW_ACTIONBAR_4", label = OPTION_SHOW_ACTION_BAR:format(4), tooltip = OPTION_SHOW_ACTION_BAR4_TOOLTIP},
			{variable = "PROXY_SHOW_ACTIONBAR_5", label = OPTION_SHOW_ACTION_BAR:format(5), tooltip = OPTION_SHOW_ACTION_BAR5_TOOLTIP},
		};

		for index, data in ipairs(actionBars) do
			local function GetValue()
				return GetActionBarToggle(index);
			end
			
			local function SetValue(value)
				SetActionBarToggle(index, value);
			end
		
			local defaultValue = true;
			local setting = Settings.RegisterProxySetting(category, data.variable, Settings.DefaultVarLocation,
				Settings.VarType.Boolean, data.label, defaultValue, GetValue, SetValue);
			actionBars[index].setting = setting;
			actionBars[index].initializer = Settings.CreateCheckBox(category, setting, data.tooltip);
		end

		local actionBar1Setting = actionBars[1].setting;
		local actionBar1Initializer = actionBars[1].initializer;
		local actionBar2Initializer = actionBars[2].initializer;
		local function IsModifiableActionBar1Setting()
			return actionBar1Setting:GetValue();
		end
		actionBar2Initializer:SetParentInitializer(actionBar1Initializer, IsModifiableActionBar1Setting);

		local actionBar3Setting = actionBars[3].setting;
		local actionBar3Initializer = actionBars[3].initializer;
		local actionBar4Initializer = actionBars[4].initializer;
		local function IsModifiableActionBar3Setting()
			return actionBar3Setting:GetValue();
		end
		actionBar4Initializer:SetParentInitializer(actionBar3Initializer, IsModifiableActionBar3Setting);
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
	Settings.SetupCVarCheckBox(category, "countdownForCooldowns", COUNTDOWN_FOR_COOLDOWNS_TEXT, OPTION_TOOLTIP_COUNTDOWN_FOR_COOLDOWNS);

	Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);
end

SettingsRegistrar:AddRegistrant(Register);