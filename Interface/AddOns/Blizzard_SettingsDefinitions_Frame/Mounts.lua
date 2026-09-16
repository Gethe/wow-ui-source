local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(ACCESSIBILITY_MOUNT_LABEL);

	---- Dynamic Flight
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(ACCESSIBILITY_ADV_FLY_LABEL));

	-- Dynamic Flight Motion Sickness
	if C_CVar.GetCVar("motionSicknessFocalCircle") and C_CVar.GetCVar("motionSicknessLandscapeDarkening") then
		local function GetValue()
			local focalCircle = GetCVarBool("motionSicknessFocalCircle");
			local landscapeDarkening = GetCVarBool("motionSicknessLandscapeDarkening");
			if focalCircle and not landscapeDarkening then
				return 1;
			elseif not focalCircle and landscapeDarkening then
				return 2;
			elseif focalCircle and landscapeDarkening then
				return 3;
			elseif not focalCircle and not landscapeDarkening then
				return 4;
			end
		end
		
		local function SetValue(value)
			if value == 1 then
				SetCVar("motionSicknessFocalCircle", "1");
				SetCVar("motionSicknessLandscapeDarkening", "0");
			elseif value == 2 then
				SetCVar("motionSicknessFocalCircle", "0");
				SetCVar("motionSicknessLandscapeDarkening", "1");
			elseif value == 3 then
				SetCVar("motionSicknessFocalCircle", "1");
				SetCVar("motionSicknessLandscapeDarkening", "1");
			elseif value == 4 then
				SetCVar("motionSicknessFocalCircle", "0");
				SetCVar("motionSicknessLandscapeDarkening", "0");
			end
		end
		
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(4, DEFAULT);
			container:Add(2, MOTION_SICKNESS_DRAGONRIDING_LANDSCAPE_DARKENING);			
			container:Add(1, MOTION_SICKNESS_DRAGONRIDING_FOCAL_CIRCLE);
			container:Add(3, MOTION_SICKNESS_DRAGONRIDING_BOTH);
			return container:GetData();
		end

		local defaultValue = 4;
		local setting = Settings.RegisterProxySetting(category, "PROXY_DRAGONRIDING_SICKNESS",
			Settings.VarType.Number, MOTION_SICKNESS_DRAGONRIDING, defaultValue, GetValue, SetValue);
		Settings.CreateDropdown(category, setting, GetOptions, OPTION_TOOLTIP_MOTION_SICKNESS_DRAGONRIDING);
	end

	-- Dynamic Flight High Speed Motion Sickness Option
	if C_CVar.GetCVar("DisableAdvancedFlyingFullScreenEffects") then
		local setting, initializer = Settings.SetupCVarCheckbox(category, "DisableAdvancedFlyingFullScreenEffects", MOTION_SICKNESS_DRAGONRIDING_SCREEN_EFFECTS, MOTION_SICKNESS_DRAGONRIDING_SCREEN_EFFECTS_TOOLTIP);
		setting:NegateBoolean();
		initializer:AddSearchTags(MOTION_SICKNESS_CHECKBOX);
	end

	-- Dynamic Flight High Speed Motion Sickness Option
	if C_CVar.GetCVar("DisableAdvancedFlyingVelocityVFX") then
		local setting, initializer = Settings.SetupCVarCheckbox(category, "DisableAdvancedFlyingVelocityVFX", MOTION_SICKNESS_DRAGONRIDING_SPEED_EFFECTS, MOTION_SICKNESS_DRAGONRIDING_SPEED_EFFECTS_TOOLTIP);
		setting:NegateBoolean();
		initializer:AddSearchTags(MOTION_SICKNESS_CHECKBOX);
	end

	-- Dynamic Flight Pitch Control
	if C_CVar.GetCVar("advFlyPitchControl") then
		local function GetValue()
			local pitchControl = tonumber(GetCVar("advFlyPitchControl"));
			if ApproximatelyEqual(pitchControl, 1) then
				return 1;
			elseif ApproximatelyEqual(pitchControl, 2) then
				return 2;
			end
			return 3;
		end
		
		local function SetValue(value)
			if value == 1 then
				SetCVar("advFlyPitchControl", "1");
			elseif value == 2 then
				SetCVar("advFlyPitchControl", "2");
			elseif value == 3 then
				SetCVar("advFlyPitchControl", "3");
			end
		end
		
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(3, DEFAULT);
			container:Add(2, ADV_FLY_PITCH_CONTROL_BACKWARD_UP);			
			container:Add(1, ADV_FLY_PITCH_CONTROL_FORWARD_UP);
			return container:GetData();
		end

		local defaultValue = 3;
		local setting = Settings.RegisterProxySetting(category, "PROXY_ADV_FLY_PITCH_CONTROL",
			Settings.VarType.Number, ADV_FLY_PITCH_CONTROL, defaultValue, GetValue, SetValue);
		Settings.CreateDropdown(category, setting, GetOptions, OPTION_TOOLTIP_ADV_FLY_PITCH_CONTROL);
	end

	-- Dynamic Flight Pitch Control Ground Debouncing
	Settings.SetupCVarCheckbox(category, "advFlyPitchControlGroundDebounce", ADV_FLY_PITCH_CONTROL_GROUND_DEBOUNCE, OPTION_TOOLTIP_ADV_FLY_PITCH_CONTROL_GROUND_DEBOUNCE);

	-- Dynamic Flight Camera Pitch Chase
	local minValueCamera, maxValueCamera, stepCamera = 10, 30, 1;
	local optionsCamera = Settings.CreateSliderOptions(minValueCamera, maxValueCamera, stepCamera);
	optionsCamera:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
	Settings.SetupCVarSlider(category, "advFlyPitchControlCameraChase", optionsCamera, ADV_FLY_CAMERA_PITCH_CHASE_TEXT, OPTION_TOOLTIP_ADV_FLY_CAMERA_PITCH_CHASE);

	-- Dynamic Flight Keyboard Input Sliders
	local minValueKeyboard, maxValueKeyboard, stepKeyboard = 1, 10, 0.5;
	local optionsKeyboard = Settings.CreateSliderOptions(minValueKeyboard, maxValueKeyboard, stepKeyboard);
	optionsKeyboard:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
	Settings.SetupCVarSlider(category, "advFlyKeyboardMinPitchFactor", optionsKeyboard, ADV_FLY_MINIMUM_PITCH_TEXT, OPTION_TOOLTIP_ADV_FLY_MINIMUM_PITCH);
	Settings.SetupCVarSlider(category, "advFlyKeyboardMaxPitchFactor", optionsKeyboard, ADV_FLY_MAXIMUM_PITCH_TEXT, OPTION_TOOLTIP_ADV_FLY_MAXIMUM_PITCH);
	Settings.SetupCVarSlider(category, "advFlyKeyboardMinTurnFactor", optionsKeyboard, ADV_FLY_MINIMUM_TURN_TEXT, OPTION_TOOLTIP_ADV_FLY_MINIMUM_TURN);
	Settings.SetupCVarSlider(category, "advFlyKeyboardMaxTurnFactor", optionsKeyboard, ADV_FLY_MAXIMUM_TURN_TEXT, OPTION_TOOLTIP_ADV_FLY_MAXIMUM_TURN);

	Settings.RegisterCategory(category, SETTING_GROUP_ACCESSIBILITY);
end

SettingsRegistrar:AddRegistrant(Register);
