local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(CONTROLS_LABEL);

	---- Controls

	-- Sticky Targeting
	do
		local function GetValue()
			return not GetCVarBool("deselectOnClick");
		end
		
		local function SetValue(value)
			SetCVar("deselectOnClick", not value);
		end
		
		local defaultValue = false;
		local setting = Settings.RegisterProxySetting(category, "PROXY_DESELECT_ON_CLICK", Settings.DefaultVarLocation, 
			Settings.VarType.Boolean, GAMEFIELD_DESELECT_TEXT, defaultValue, GetValue, SetValue);
		Settings.CreateCheckBox(category, setting, OPTION_TOOLTIP_GAMEFIELD_DESELECT);
	end

	-- Auto Dismount
	Settings.SetupCVarCheckBox(category, "autoDismountFlying", AUTO_DISMOUNT_FLYING_TEXT, OPTION_TOOLTIP_AUTO_DISMOUNT_FLYING);

	-- Auto Cancel AFK
	Settings.SetupCVarCheckBox(category, "autoClearAFK", CLEAR_AFK, OPTION_TOOLTIP_CLEAR_AFK);

	-- Interact on Left Click
	Settings.SetupCVarCheckBox(category, "interactOnLeftClick", INTERACT_ON_LEFT_CLICK_TEXT, OPTION_TOOLTIP_INTERACT_ON_LEFT_CLICK);

	-- Open Loot Window at Mouse
	Settings.SetupCVarCheckBox(category, "lootUnderMouse", LOOT_UNDER_MOUSE_TEXT, OPTION_TOOLTIP_LOOT_UNDER_MOUSE);

	-- Use Combined Inventory Bags
	Settings.SetupCVarCheckBox(category, "combinedBags", USE_COMBINED_BAGS_TEXT, OPTION_TOOLTIP_USE_COMBINED_BAGS);

	-- Enable Dracthyr Tap Controls (Mirrored in Accessibility)
	do
		local function GetTapControlOptions()
			local container = Settings.CreateDropDownTextContainer();
			container:Add(0, SETTING_EMPOWERED_SPELL_INPUT_HOLD_OPTION, SETTING_EMPOWERED_SPELL_INPUT_HOLD_OPTION_TOOLTIP);
			container:Add(1, SETTING_EMPOWERED_SPELL_INPUT_TAP_OPTION, SETTING_EMPOWERED_SPELL_INPUT_TAP_OPTION_TOOLTIP);
			return container:GetData();
		end
		Settings.SetupCVarDropDown(category, "empowerTapControls", Settings.VarType.Number, GetTapControlOptions, SETTING_EMPOWERED_SPELL_INPUT, SETTING_EMPOWERED_SPELL_INPUT_TOOLTIP);
	end

	---- Mouse
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(MOUSE_LABEL));

	-- Lock Cursor
	if SupportsClipCursor() then
		Settings.SetupCVarCheckBox(category, "ClipCursor", LOCK_CURSOR, OPTION_TOOLTIP_LOCK_CURSOR);
	end

	-- Invert Mouse
	Settings.SetupCVarCheckBox(category, "mouseInvertPitch", INVERT_MOUSE, OPTION_TOOLTIP_INVERT_MOUSE);

	-- Mouse Look Speed
	do
		local function GetValue()
			return tonumber(C_CVar.GetCVar("cameraYawMoveSpeed"));
		end
		
		local function SetValue(value)
			SetCVar("cameraYawMoveSpeed", value);
			SetCVar("cameraPitchMoveSpeed", value / 2);
		end
		
		local defaultValue = 180;
		local setting = Settings.RegisterProxySetting(category, "PROXY_MOUSE_LOOK_SPEED", Settings.DefaultVarLocation, 
			Settings.VarType.Number, MOUSE_LOOK_SPEED, defaultValue, GetValue, SetValue);
		
		local minValue, maxValue, step = 90, 270, 10;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Min, SLOW);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Max, FAST);
		Settings.CreateSlider(category, setting, options, OPTION_TOOLTIP_MOUSE_LOOK_SPEED);
	end
	
	-- Enable Mouse Sensitivity
	do
		local cbSetting = Settings.RegisterCVarSetting(category, "enableMouseSpeed", Settings.VarType.Boolean, ENABLE_MOUSE_SPEED);
		local sliderSetting = Settings.RegisterCVarSetting(category, "mouseSpeed", Settings.VarType.Number, MOUSE_SENSITIVITY);

		local minValue, maxValue, step = 0.5, 1.5, .05;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Min, LOW);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Max, HIGH);

		local initializer = CreateSettingsCheckBoxSliderInitializer(
				cbSetting, ENABLE_MOUSE_SPEED, OPTION_TOOLTIP_ENABLE_MOUSE_SPEED,
				sliderSetting, options, MOUSE_SENSITIVITY, OPTION_TOOLTIP_MOUSE_SENSITIVITY);
		layout:AddInitializer(initializer);
	end

	-- Click to Move
	do
		local cbSetting = Settings.RegisterCVarSetting(category, "autointeract", Settings.VarType.Boolean, CLICK_TO_MOVE);
		local dropDownSetting = Settings.RegisterCVarSetting(category, "cameraSmoothStyle", Settings.VarType.Number, CAMERA_CTM_FOLLOWING_STYLE);
	
		local function GetOptionData(options)
			local container = Settings.CreateDropDownTextContainer();
			container:Add(1, CAMERA_SMART, OPTION_TOOLTIP_CAMERA_SMART);
			container:Add(4, CAMERA_SMARTER, OPTION_TOOLTIP_CAMERA_SMARTER);
			container:Add(2, CAMERA_ALWAYS, OPTION_TOOLTIP_CAMERA_ALWAYS);
			container:Add(0, CAMERA_NEVER, OPTION_TOOLTIP_CAMERA_NEVER);
			return container:GetData();
		end

		local initializer = CreateSettingsCheckBoxDropDownInitializer(
			cbSetting, CLICK_TO_MOVE, OPTION_TOOLTIP_CLICK_TO_MOVE,
			dropDownSetting, GetOptionData, CAMERA_CTM_FOLLOWING_STYLE, OPTION_TOOLTIP_CTM_CAMERA_FOLLOWING_STYLE);
		initializer:AddSearchTags(CLICK_TO_MOVE, CAMERA_CTM_FOLLOWING_STYLE);
		layout:AddInitializer(initializer);
	end

	---- Camera
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(CAMERA_LABEL));

	-- Water Collision
	Settings.SetupCVarCheckBox(category, "cameraWaterCollision", WATER_COLLISION, OPTION_TOOLTIP_WATER_COLLISION);

	-- Auto Follow Speed
	do
		local function GetValue()
			return tonumber(C_CVar.GetCVar("cameraYawSmoothSpeed"));
		end
		
		local function SetValue(value)
			SetCVar("cameraYawSmoothSpeed", value);
			SetCVar("cameraPitchSmoothSpeed", value / 4);
		end
		
		local defaultValue = 180;
		local setting = Settings.RegisterProxySetting(category, "PROXY_CAMERA_SPEED", Settings.DefaultVarLocation, 
			Settings.VarType.Number, AUTO_FOLLOW_SPEED, defaultValue, GetValue, SetValue);

		local minValue, maxValue, step = 90, 270, 10;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Min, SLOW);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Max, FAST);
		Settings.CreateSlider(category, setting, options, OPTION_TOOLTIP_AUTO_FOLLOW_SPEED);
	end
	
	-- Camera Following Style
	do
		local function GetOptions()
			local container = Settings.CreateDropDownTextContainer();
			container:Add(1, CAMERA_SMART, OPTION_TOOLTIP_CAMERA_SMART);
			container:Add(4, CAMERA_SMARTER, OPTION_TOOLTIP_CAMERA_SMARTER);
			container:Add(2, CAMERA_ALWAYS, OPTION_TOOLTIP_CAMERA_ALWAYS);
			container:Add(0, CAMERA_NEVER, OPTION_TOOLTIP_CAMERA3);
			return container:GetData();
		end
		Settings.SetupCVarDropDown(category, "cameraSmoothStyle", Settings.VarType.Number, GetOptions, CAMERA_FOLLOWING_STYLE, OPTION_TOOLTIP_CAMERA_FOLLOWING_STYLE);
	end

	Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);
end

SettingsRegistrar:AddRegistrant(Register);