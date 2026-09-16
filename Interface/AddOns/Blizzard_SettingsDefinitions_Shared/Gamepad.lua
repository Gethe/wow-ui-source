local function CreateCVarSlider(category, cvar, variable, label, tooltip, type, default, bounds)
	local min = bounds.min;
	local max = bounds.max;
	local step = bounds.step;

	local function GetValue()
		return tonumber(GetCVar(cvar));
	end

	local function SetValue(value)
		SetCVar(cvar, value);
	end

	local function FormatterFunction(value)
		return RoundToSignificantDigits(value, 5)
	end

	local setting = Settings.RegisterProxySetting(category, variable,
		type, label, default, GetValue, SetValue);

	local options = Settings.CreateSliderOptions(min, max, step);
	options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatterFunction);
	return Settings.CreateSlider(category, setting, options, tooltip);
end

local function PercentageFormatter(value)
	local roundToNearestInteger = true;
	return FormatPercentage(value, roundToNearestInteger);
end

local function RegisterGamepadCameraSettings(category, layout)
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(CAMERA_LABEL));

	CreateCVarSlider(category, "GamePadCameraYawSpeed", "PROXY_GAMEPAD_CAMERA_YAW_SPEED",
					 GAMEPAD_YAW_SPEED, GAMEPAD_YAW_SPEED_TOOLTIP,
					 Settings.VarType.Number, 1.3, { min=0.5, max=5, step=0.1 });

	CreateCVarSlider(category, "GamePadCameraPitchSpeed", "PROXY_GAMEPAD_CAMERA_PITCH_SPEED",
					 GAMEPAD_PITCH_SPEED, GAMEPAD_PITCH_SPEED_TOOLTIP,
					 Settings.VarType.Number, 1, { min=0.5, max=5, step=0.1 });

	Settings.SetupCVarCheckbox(category, "gamepadInvertYaw", INVERT_GAMEPAD_YAW, OPTION_TOOLTIP_INVERT_GAMEPAD_YAW);

	Settings.SetupCVarCheckbox(category, "gamepadInvertPitch", INVERT_GAMEPAD_PITCH, OPTION_TOOLTIP_INVERT_GAMEPAD_PITCH);

	-- Gamepad Follower Cam
	do
		local function GetValue()
			return C_CVar.GetCVarBool("GamepadCameraFollowOnStick");
		end
		local function SetValue(value)
			if value then
				SetCVar("GamepadCameraFollowOnStick", true);
			else
				SetCVar("GamepadCameraFollowOnStick", false);
			end
		end
		local defaultValue = false;
		local setting = Settings.RegisterProxySetting(category, "PROXY_GAMEPAD_CAMERA_FOLLOW_ON_STICK",
			Settings.VarType.Boolean, GAMEPAD_FOLLOW_CAMERA, defaultValue, GetValue, SetValue);
		Settings.CreateCheckbox(category, setting, OPTION_TOOLTIP_GAMEPAD_FOLLOW_CAMERA);
	end

	do
		local followCamPitchOffsetSlider = CreateCVarSlider(category, "GamepadCameraFollowPitchOffset", "PROXY_GAMEPAD_FOLLOW_PITCH_OFFSET",
			GAMEPAD_FOLLOW_CAMERA_PITCH_OFFSET,
			OPTION_TOOLTIP_GAMEPAD_FOLLOW_CAMERA_PITCH_OFFSET,
			Settings.VarType.Number, 15, { min=0, max=45, step=1});

		local function ShownPredicate()
			return C_CVar.GetCVarBool("GamepadCameraFollowOnStick");
		end
		followCamPitchOffsetSlider:AddShownPredicate(ShownPredicate);
	end

	-- Gamepad Turn With Camera
	do
		local GAMEPAD_TURN_WITH_CAMERA_CVAR = "GamePadTurnWithCamera";

		local function GetValue()
			local v = C_CVar.GetCVar(GAMEPAD_TURN_WITH_CAMERA_CVAR);
			return tonumber(v);
		end

		local function SetValue(value)
			C_CVar.SetCVar(GAMEPAD_TURN_WITH_CAMERA_CVAR, tostring(value));
		end

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(0, GAMEPAD_TURN_WITH_CAMERA_OPTION_MOVING);
			container:Add(1, GAMEPAD_TURN_WITH_CAMERA_OPTION_MOVING_COMBAT);
			container:Add(3, GAMEPAD_TURN_WITH_CAMERA_OPTION_MOVING_COMBAT_CASTING);
			container:Add(2, GAMEPAD_TURN_WITH_CAMERA_OPTION_ALWAYS);

			return container:GetData();
		end

		local setting = Settings.RegisterProxySetting(category, "PROXY_GAMEPAD_TURN_WITH_CAMERA",
		Settings.VarType.Number, GAMEPAD_TURN_WITH_CAMERA, 3, GetValue, SetValue);
		Settings.CreateDropdown(category, setting, GetOptions);
	end

	CreateCVarSlider(category, "GamePadFaceMovementMaxAngle", "PROXY_GAMEPAD_FACE_MOVEMENT_MAX_ANGLE",
		GAMEPAD_MOVEMENT_FACE_ANGLE,
		OPTION_TOOLTIP_GAMEPAD_MOVEMENT_FACE_ANGLE,
		Settings.VarType.Number, 0, { min=0, max=180, step=1 });

	CreateCVarSlider(category, "GamePadFaceMovementMaxAngleCombat", "PROXY_GAMEPAD_FACE_MOVEMENT_MAX_ANGLE_COMBAT",
		GAMEPAD_MOVEMENT_FACE_ANGLE_COMBAT,
		OPTION_TOOLTIP_GAMEPAD_MOVEMENT_FACE_ANGLE_COMBAT,
		Settings.VarType.Number, 105, { min=0, max=180, step=1 });

	CreateCVarSlider(category, "GamePadBackPedalThreshold", "PROXY_GAMEPAD_BACK_PEDAL_STICK_THRESHOLD",
		GAMEPAD_BACK_PEDAL_THRESHOLD,
		OPTION_TOOLTIP_GAMEPAD_BACK_PEDAL_THRESHOLD,
		Settings.VarType.Number, 0.6, { min=0, max=1, step=0.05 });

	CreateCVarSlider(category, "GamePadRunThreshold", "PROXY_GAMEPAD_RUN_THRESHOLD",
		GAMEPAD_RUN_THRESHOLD,
		OPTION_TOOLTIP_GAMEPAD_RUN_THRESHOLD,
		Settings.VarType.Number, 0.5, { min=0, max=1, step=0.1 });

	Settings.SetupCVarCheckbox(category, "GamePadFaceMovementMount",
		GAMEPAD_FACE_MOVEMENT_MOUNTED,
		OPTION_TOOLTIP_GAMEPAD_FACE_MOVEMENT_MOUNTED);

	Settings.SetupCVarCheckbox(category, "GamePadFaceMovementSwimming",
		GAMEPAD_FACE_MOVEMENT_SWIMMING,
		OPTION_TOOLTIP_GAMEPAD_FACE_MOVEMENT_SWIMMING);

	Settings.SetupCVarCheckbox(category, "GamePadFaceMovementFreeFlying",
		GAMEPAD_FACE_MOVEMENT_GLIDING,
		OPTION_TOOLTIP_GAMEPAD_FACE_MOVEMENT_GLIDING);
end

local function RegisterGamepadSettings(category, layout)

	-- Show persistent controls information on screen.
	Settings.SetupCVarCheckbox(category, "GamepadShowPersistentInputLegend", GAMEPAD_SHOW_LEGEND, OPTION_TOOLTIP_GAMEPAD_SHOW_LEGEND);

	RegisterGamepadCameraSettings(category, layout);

	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(GAMEPAD_MODIFIER_LABEL));
	do
		Settings.SetupCVarCheckbox(
			category,
			"GamepadHudModifierUsesToggle",
			GAMEPAD_MODIFIER_TOGGLE,
			OPTIONS_TOOLTIP_GAMEPAD_MODIFIER_TOGGLE
		);
	end

	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(FOCUS_MODIFICATIONS_HEADER));
	do
		local function GetFocusGlowColorOptions()
			local container = Settings.CreateControlTextContainer();

			container:Add(1, COLOR_GOLD);
			container:Add(2, COLOR_BLACK);
			container:Add(3, COLOR_BLUE);

			return container:GetData();
		end

		Settings.SetupCVarDropdown(
			category,
			"GamepadFocusStateColor",
			Settings.VarType.Number,
			GetFocusGlowColorOptions,
			FOCUS_GLOW_COLOR,
			OPTION_TOOLTIP_FOCUS_GLOW_COLOR
		);

		-- Glow Alpha
		local minValue, maxValue, step = 0.0, 1.0, .1;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);

		local function RoundToOneTenth(value)
			return RoundToSignificantDigits(value, 1);
		end

		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, RoundToOneTenth);
		Settings.SetupCVarSlider(category, "GamepadFocusStateOpacity", options, FOCUS_OPACITY, OPTION_TOOLTIP_FOCUS_OPACITY);
	end

	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(ACTIONBARS_LABEL));
	do
		Settings.SetupCVarCheckbox(
			category,
			"GamepadShowActionBarButtonPrompts",
			GAMEPAD_ACTION_BAR_INPUT_PROMPT_TOGGLE,
			OPTIONS_TOOLTIP_GAMEPAD_ACTION_BAR_INPUT_PROMPT_TOGGLE
		);

		Settings.SetupCVarCheckbox(
			category,
			"GamepadShowActionBarHighlight",
			GAMEPAD_ACTION_BAR_HIGHLIGHT_TOGGLE,
			OPTIONS_TOOLTIP_GAMEPAD_ACTION_BAR_HIGHLIGHT_TOGGLE
		);

		Settings.SetupCVarCheckbox(
			category,
			"GamepadShowActionBarScaling",
			GAMEPAD_ACTION_BAR_SCALING_TOGGLE,
			OPTIONS_TOOLTIP_GAMEPAD_ACTION_BAR_SCALING_TOGGLE
		);

		-- Show action bars even when empty.
		Settings.SetupCVarCheckbox(category, "GamepadShowEmptyActionbars", GAMEPAD_SHOW_EMPTY_ACTIONBARS, OPTION_TOOLTIP_GAMEPAD_SHOW_EMPTY_ACTIONBARS);

		local function GetGamepadPossessBarOverrideOptions()
			local container = Settings.CreateControlTextContainer();

			-- Order should match the GamepadPossessBarOverride enum in GamepadUI.tag
			container:Add(1, GAMEPAD_POSSESS_BAR_SPECIAL_PAGE);
			container:Add(2, GAMEPAD_BAR_PAGE1_LEFT);
			container:Add(3, GAMEPAD_BAR_PAGE1_RIGHT);
			container:Add(4, GAMEPAD_BAR_PAGE1_BOTTOM);
			container:Add(5, GAMEPAD_BAR_PAGE2_TOP);
			container:Add(6, GAMEPAD_BAR_PAGE2_LEFT);
			container:Add(7, GAMEPAD_BAR_PAGE2_RIGHT);
			container:Add(8, GAMEPAD_BAR_PAGE2_BOTTOM);
			container:Add(9, GAMEPAD_BAR_PAGE3_TOP);
			container:Add(10, GAMEPAD_BAR_PAGE3_LEFT);
			container:Add(11, GAMEPAD_BAR_PAGE3_RIGHT);
			container:Add(12, GAMEPAD_BAR_PAGE3_BOTTOM);

			return container:GetData();
		end

		Settings.SetupCVarDropdown(
			category,
			"GamepadPossessBarOverride",
			Settings.VarType.Number,
			GetGamepadPossessBarOverrideOptions,
			GAMEPAD_POSSESS_BAR_OVERRIDE,
			OPTIONS_TOOLTIP_GAMEPAD_POSSESS_BAR_OVERRIDE
		);

		local function GetGamepadStanceBarOverrideOptions()
			local container = Settings.CreateControlTextContainer();

			-- Order should match the GamepadStanceBarOverride enum in GamepadUI.tag
			container:Add(1, GAMEPAD_STANCE_BAR_NONE);
			container:Add(2, GAMEPAD_BAR_PAGE1_LEFT);
			container:Add(3, GAMEPAD_BAR_PAGE1_RIGHT);
			container:Add(4, GAMEPAD_BAR_PAGE1_BOTTOM);
			container:Add(5, GAMEPAD_BAR_PAGE2_TOP);
			container:Add(6, GAMEPAD_BAR_PAGE2_LEFT);
			container:Add(7, GAMEPAD_BAR_PAGE2_RIGHT);
			container:Add(8, GAMEPAD_BAR_PAGE2_BOTTOM);
			container:Add(9, GAMEPAD_BAR_PAGE3_TOP);
			container:Add(10, GAMEPAD_BAR_PAGE3_LEFT);
			container:Add(11, GAMEPAD_BAR_PAGE3_RIGHT);
			container:Add(12, GAMEPAD_BAR_PAGE3_BOTTOM);

			return container:GetData();
		end

		Settings.SetupCVarDropdown(
			category,
			"GamepadStanceBarOverride",
			Settings.VarType.Number,
			GetGamepadStanceBarOverrideOptions,
			GAMEPAD_STANCE_BAR_OVERRIDE,
			OPTIONS_TOOLTIP_GAMEPAD_STANCE_BAR_OVERRIDE
		);
	end
end

local function RegisterRaidSettings(category, layout)
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(RAID_TARGETING_OPTIONS));

	Settings.SetupCVarCheckbox(
		category,
		"GamepadRaidTargetingHoverMode",
		RAID_TARGETING_OPTIONS_HOVER_MODE,
		OPTIONS_TOOLTIP_RAID_TARGETING_OPTIONS_HOVER_MODE
	);
end

local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(GAMEPAD_LABEL);

	if (not C_Glue.IsOnGlueScreen()) then
		category:SetOrder(CUSTOM_GAMEPLAY_SETTINGS_ORDER[GAMEPAD_LABEL]);
	end

	-- Gamepad UI
	do
		local function GetValue()
			return InputUtil.IsGamepadUIEnabled();
		end
		local function SetValue(value)
			local toSet = Enum.InputDeviceInterfaceType.Mkb;
			if (value) then
				toSet = Enum.InputDeviceInterfaceType.Gamepad;
			end
			SetCVar("InputDeviceInterfaceStyle", toSet);

		end
		local defaultValue = PlatformIsHandheld();
		local setting = Settings.RegisterProxySetting(category, "GAMEPAD_INTERFACE_TOGGLE",
			Settings.VarType.Boolean, ENABLE_GAMEPAD_UI, defaultValue, GetValue, SetValue);
		Settings.CreateCheckbox(category, setting, OPTION_TOOLTIP_ENABLE_GAMEPAD_UI);
	end

	if (not C_Glue.IsOnGlueScreen()) then
		RegisterGamepadSettings(category, layout);
		RegisterRaidSettings(category, layout);
	end

	if (C_Glue.IsOnGlueScreen()) then
		Settings.RegisterCategory(category, SETTING_GROUP_SYSTEM);
	else
		Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);
	end
end

if InputUtil.IsGamepadUISupported() then
	SettingsRegistrar:AddRegistrant(Register);
end
