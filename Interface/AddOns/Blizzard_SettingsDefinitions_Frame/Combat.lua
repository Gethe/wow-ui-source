SELF_CAST_SETTING_VALUES = {
	NONE = 1,
	AUTO = 2,
	KEY_PRESS = 3,
	AUTO_AND_KEY_PRESS = 4,
};

local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(COMBAT_LABEL);

	-- Order set in GameplaySettingsGroup.lua
	category:SetOrder(CUSTOM_GAMEPLAY_SETTINGS_ORDER[COMBAT_LABEL]);

	-- Personal Resource Display
	if C_CVar.GetCVar("nameplateShowSelf") then
		local nameplateSetting, nameplateInitializer = Settings.SetupCVarCheckbox(category, "nameplateShowSelf", DISPLAY_PERSONAL_RESOURCE, OPTION_TOOLTIP_DISPLAY_PERSONAL_RESOURCE);

		local function IsModifiable()
			return nameplateSetting:GetValue();
		end

		-- Hide Health and Power Bars
		local hideSetting, hideInitializer = Settings.SetupCVarCheckbox(category, "nameplateHideHealthAndPower", NAMEPLATE_HIDE_HEALTH_AND_POWER, OPTION_TOOLTIP_NAMEPLATE_HIDE_HEALTH_AND_POWER);
		hideInitializer:SetParentInitializer(nameplateInitializer, IsModifiable);

		-- Show Special Resources
		local resourceSetting, resourceInitializer = Settings.SetupCVarCheckbox(category, "nameplateResourceOnTarget", DISPLAY_PERSONAL_RESOURCE_ON_ENEMY, OPTION_TOOLTIP_DISPLAY_PERSONAL_RESOURCE_ON_ENEMY);
		resourceInitializer:SetParentInitializer(nameplateInitializer, IsModifiable);

		-- Show Personal Cooldowns
		CombatOverrides.RunSettingsCallback(function()
		local cooldownSetting, cooldownInitializer = Settings.SetupCVarCheckbox(category, "nameplateShowPersonalCooldowns", DISPLAY_PERSONAL_COOLDOWNS, OPTION_TOOLTIP_DISPLAY_PERSONAL_COOLDOWNS);
		cooldownInitializer:SetParentInitializer(nameplateInitializer, IsModifiable);
		end);

		-- Show Friendly Buffs
		local buffsSetting, buffsInitializer = Settings.SetupCVarCheckbox(category, "nameplateShowFriendlyBuffs", DISPLAY_PERSONAL_FRIENDLY_BUFFS, OPTION_TOOLTIP_DISPLAY_PERSONAL_FRIENDLY_BUFFS);
		buffsInitializer:SetParentInitializer(nameplateInitializer, IsModifiable);
	end

	-- Self Highlight
	do
		local setting, initializer = CombatOverrides.CreateRaidSelfHighlightSetting(category)
		Settings.RaidSelfHighlightInitializer = initializer;
	end

	-- Show Silhouette when Obscured
	do
		local setting, initializer = CombatOverrides.CreateOccludedSilhouettePlayerSetting(category);
		Settings.OccludedSilhouettePlayerInitializer = initializer;
	end

	-- Target of Target
	Settings.SetupCVarCheckbox(category, "showTargetOfTarget", SHOW_TARGET_OF_TARGET_TEXT, OPTION_TOOLTIP_SHOW_TARGET_OF_TARGET);

	-- Low Agro Flash
	Settings.SetupCVarCheckbox(category, "doNotFlashLowHealthWarning", FLASH_LOW_HEALTH_WARNING, OPTION_TOOLTIP_FLASH_LOW_HEALTH_WARNING);

	if C_CVar.GetCVar("lossOfControl") then
		-- Loss of Control Alerts
		Settings.SetupCVarCheckbox(category, "lossOfControl", LOSS_OF_CONTROL, OPTION_TOOLTIP_LOSS_OF_CONTROL);
	end

	-- Scrolling Combat Text
	do
		CombatOverrides.CreateFloatingCombatTextSetting(category);
	end

	-- Mouseover Cast control
	if C_CVar.GetCVar("enableMouseoverCast") then
		local cbSetting = Settings.RegisterCVarSetting(category, "enableMouseoverCast", Settings.VarType.Boolean, ENABLE_MOUSEOVER_CAST);

		local tooltips = {
			OPTION_TOOLTIP_MOUSEOVER_CAST_ALT_KEY,
			OPTION_TOOLTIP_MOUSEOVER_CAST_CTRL_KEY,
			OPTION_TOOLTIP_MOUSEOVER_CAST_SHIFT_KEY,
			OPTION_TOOLTIP_MOUSEOVER_CAST_NONE_KEY,
		};
		local options = Settings.CreateModifiedClickOptions(tooltips);
		local dropdownSetting = Settings.RegisterModifiedClickSetting(category, "MOUSEOVERCAST", MOUSEOVER_CAST_KEY, "NONE");

		local initializer = CreateSettingsCheckboxDropdownInitializer(
			cbSetting, ENABLE_MOUSEOVER_CAST, OPTION_TOOLTIP_ENABLE_MOUSEOVER_CAST,
			dropdownSetting, options, MOUSEOVER_CAST_KEY, OPTION_TOOLTIP_MOUSEOVER_CAST_KEY_TEXT);
		initializer:AddSearchTags(ENABLE_MOUSEOVER_CAST);
		layout:AddInitializer(initializer);
	end

	-- Self Cast
	do
		local function GetValue()
			local hasSelfCastKey = GetModifiedClick("SELFCAST") ~= "NONE";
			local autoSelfCast = GetCVarBool("autoSelfCast");
			if not hasSelfCastKey and not autoSelfCast then
				return 1;
			elseif autoSelfCast then
				return 2;
			elseif hasSelfCastKey then
				return 3;
			end
			
			return 4;
		end
		
		local function SetValue(value)
			local selfCastKeySetting = Settings.GetSetting("SELFCAST");

			local autoSelfCast = false;
			local selfCastKey = selfCastKeySetting:GetValue();

			if value == 1 or value == 2 then
				selfCastKey = "NONE";
			else
				if selfCastKey == "NONE" then
					selfCastKey = "ALT";
				end
			end

			if value == 2 or value == 4 then
				autoSelfCast = true;
			else
				autoSelfCast = false;
			end

			SetCVar("autoSelfCast", autoSelfCast);
			selfCastKeySetting:SetValue(selfCastKey);
		end

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(SELF_CAST_SETTING_VALUES.NONE, NONE, OPTIONS_TOOLTIP_SELF_CAST_NONE);
			container:Add(SELF_CAST_SETTING_VALUES.AUTO, SELF_CAST_AUTO, OPTIONS_TOOLTIP_SELF_CAST_AUTO);
			container:Add(SELF_CAST_SETTING_VALUES.KEY_PRESS, SELF_CAST_KEY_PRESS, OPTIONS_TOOLTIP_SELF_CAST_KEY_PRESS);
			container:Add(SELF_CAST_SETTING_VALUES.AUTO_AND_KEY_PRESS, SELF_CAST_AUTO_AND_KEY_PRESS, OPTIONS_TOOLTIP_SELF_CAST_AUTO_AND_KEY_PRESS);
			return container:GetData();
		end

		local defaultValue = 4;
		local selfCastSetting = Settings.RegisterProxySetting(category, "PROXY_SELF_CAST",
			Settings.VarType.Number, SELF_CAST, defaultValue, GetValue, SetValue);
		local selfCastInitializer = Settings.CreateDropdown(category, selfCastSetting, GetOptions, OPTION_TOOLTIP_AUTO_SELF_CAST);
		
		-- Self Cast Key
		local tooltips = {
			OPTION_TOOLTIP_AUTO_SELF_CAST_ALT_KEY,
			OPTION_TOOLTIP_AUTO_SELF_CAST_CTRL_KEY,
			OPTION_TOOLTIP_AUTO_SELF_CAST_SHIFT_KEY,
		};
		local mustChooseKey = true;
		local selfCastKeySetting, selfCastKeyInitializer = Settings.SetupModifiedClickDropdown(category, "SELFCAST", "ALT", AUTO_SELF_CAST_KEY_TEXT, tooltips, OPTION_TOOLTIP_AUTO_SELF_CAST_KEY_TEXT, mustChooseKey);

		local function IsUsingKeyPress()
			local value = selfCastSetting:GetValue();
			return value == 3 or value == 4;
		end

		selfCastKeyInitializer:SetParentInitializer(selfCastInitializer, IsUsingKeyPress);
	end

	-- Focus Cast Key
	do
		local tooltips = {
			OPTION_TOOLTIP_FOCUS_CAST_ALT_KEY,
			OPTION_TOOLTIP_FOCUS_CAST_CTRL_KEY,
			OPTION_TOOLTIP_FOCUS_CAST_SHIFT_KEY,
			OPTION_TOOLTIP_FOCUS_CAST_NONE_KEY,
		};
		Settings.SetupModifiedClickDropdown(category, "FOCUSCAST", "ALT", FOCUS_CAST_KEY_TEXT, tooltips, OPTION_TOOLTIP_FOCUS_CAST_KEY_TEXT);
	end

	-- Enable Dracthyr Tap Controls
	if C_CVar.GetCVar("empowerTapControls") then
		local function GetTapControlOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(0, SETTING_EMPOWERED_SPELL_INPUT_HOLD_OPTION, SETTING_EMPOWERED_SPELL_INPUT_HOLD_OPTION_TOOLTIP);
			container:Add(1, SETTING_EMPOWERED_SPELL_INPUT_TAP_OPTION, SETTING_EMPOWERED_SPELL_INPUT_TAP_OPTION_TOOLTIP);
			return container:GetData();
		end
		local setting, initializer = Settings.SetupCVarDropdown(category, "empowerTapControls", Settings.VarType.Number, GetTapControlOptions, SETTING_EMPOWERED_SPELL_INPUT, SETTING_EMPOWERED_SPELL_INPUT_TOOLTIP);
		-- Mirrored in Accessibility
		Settings.EmpoweredTapControlsInitializer = initializer;
	end

	-- Spell Alert Opacity
	if C_CVar.GetCVar("spellActivationOverlayOpacity") then
		local minValue, maxValue, step = 0, 1, .05;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatPercentage);

		local setting, initializer = Settings.SetupCVarSlider(category, "spellActivationOverlayOpacity", options, SPELL_ALERT_OPACITY, OPTION_TOOLTIP_SPELL_ALERT_OPACITY);
		local function OnValueChanged(o, setting, value)
			SetCVar("displaySpellActivationOverlays", value > 0);
		end
		Settings.SetOnValueChangedCallback("spellActivationOverlayOpacity", OnValueChanged);

		Settings.SpellAlertOpacityInitializer = initializer;
	end

	-- Hold Button
	if C_CVar.GetCVar("ActionButtonUseKeyHeldSpell") then
		local setting, initializer = Settings.SetupCVarCheckbox(category, "ActionButtonUseKeyHeldSpell", PRESS_AND_HOLD_CASTING_OPTION, PRESS_AND_HOLD_CASTING_OPTION_TOOLTIP);
		Settings.PressAndHoldCastingInitializer = initializer;
	end

	-- Enable Action Targeting
	CombatOverrides.RunSettingsCallback(function()
		local function GetValue()
			return tonumber(GetCVar("softTargetEnemy")) == Enum.SoftTargetEnableFlags.Any;
		end
		
		local function SetValue(value)
			SetCVar("softTargetEnemy", value and Enum.SoftTargetEnableFlags.Any or Enum.SoftTargetEnableFlags.Gamepad);
		end
		
		local defaultValue = false;
		local setting = Settings.RegisterProxySetting(category, "PROXY_ACTION_TARGETING",
			Settings.VarType.Boolean, ACTION_TARGETING_OPTION, defaultValue, GetValue, SetValue);
		Settings.CreateCheckbox(category, setting, OPTION_TOOLTIP_ACTION_TARGETING);
	end);

	CombatOverrides.AdjustCombatSettings(category);

	Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);
end

SettingsRegistrar:AddRegistrant(Register);