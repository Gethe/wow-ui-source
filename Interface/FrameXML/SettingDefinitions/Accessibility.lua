local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(ACCESSIBILITY_GENERAL_LABEL);

	-- Move Pad
	Settings.SetupCVarCheckBox(category, "enableMovePad", MOVE_PAD, OPTION_TOOLTIP_MOVE_PAD);
	Settings.LoadAddOnCVarWatcher("enableMovePad", "Blizzard_MovePad");

	--Cinematic Subtitles
	Settings.SetupCVarCheckBox(category, "movieSubtitle", CINEMATIC_SUBTITLES, OPTION_TOOLTIP_CINEMATIC_SUBTITLES);
	
	-- Alternate Full Screen Effects
	do
		local setting, initializer = Settings.SetupCVarCheckBox(category, "overrideScreenFlash", ALTERNATE_SCREEN_EFFECTS, OPTION_TOOLTIP_ALTERNATE_SCREEN_EFFECTS);
		initializer:AddSearchTags(ALTERNATE_SCREEN_EFFECTS_SEARCH_TAG);
	end

	-- Quest Text Contrast
	Settings.SetupCVarCheckBox(category, "questTextContrast", ENABLE_QUEST_TEXT_CONTRAST, OPTION_TOOLTIP_ENABLE_QUEST_TEXT_CONTRAST);

	-- Minimum Character Name Size
	do
		local minValue, maxValue, step = 0, 64, 2;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);

		Settings.SetupCVarSlider(category, "WorldTextMinSize", options, MINIMUM_CHARACTER_NAME_SIZE_TEXT, OPTION_TOOLTIP_MINIMUM_CHARACTER_NAME_SIZE);
	end

	-- Motion Sickness
	do
		local function GetValue()
			local keepCentered = GetCVarBool("CameraKeepCharacterCentered");
			local reducedMovement = GetCVarBool("CameraReduceUnexpectedMovement");
			if keepCentered and not reducedMovement then
				return 1;
			elseif not keepCentered and reducedMovement then
				return 2;
			elseif keepCentered and reducedMovement then
				return 3;
			elseif not keepCentered and not reducedMovement then
				return 4;
			end
		end
		
		local function SetValue(value)
			if value == 1 then
				SetCVar("CameraKeepCharacterCentered", "1");
				SetCVar("CameraReduceUnexpectedMovement", "0");
			elseif value == 2 then
				SetCVar("CameraKeepCharacterCentered", "0");
				SetCVar("CameraReduceUnexpectedMovement", "1");
			elseif value == 3 then
				SetCVar("CameraKeepCharacterCentered", "1");
				SetCVar("CameraReduceUnexpectedMovement", "1");
			elseif value == 4 then
				SetCVar("CameraKeepCharacterCentered", "0");
				SetCVar("CameraReduceUnexpectedMovement", "0");
			end
		end
		
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(1, MOTION_SICKNESS_CHARACTER_CENTERED);
			container:Add(2, MOTION_SICKNESS_REDUCE_CAMERA_MOTION);
			container:Add(3, MOTION_SICKNESS_BOTH);
			container:Add(4, MOTION_SICKNESS_NONE);
			return container:GetData();
		end

		local defaultValue = 1;
		local setting = Settings.RegisterProxySetting(category, "PROXY_SICKNESS", Settings.DefaultVarLocation,
			Settings.VarType.Number, MOTION_SICKNESS_DROPDOWN, defaultValue, GetValue, SetValue);
		Settings.CreateDropDown(category, setting, GetOptions, OPTION_TOOLTIP_MOTION_SICKNESS);
	end

	-- Camera Shake
	do
		local INTENSITY_NONE = 0;
		local INTENSITY_REDUCED = .25;
		local INTENSITY_FULL = 1;
	
		local function GetValue()
			local shakeStrengthCamera = tonumber(GetCVar("ShakeStrengthCamera"))
			local shakeStrengthUI = tonumber(GetCVar("ShakeStrengthUI"));
			if ApproximatelyEqual(shakeStrengthCamera, INTENSITY_NONE) and ApproximatelyEqual(shakeStrengthUI, INTENSITY_NONE) then
				return 1;
			elseif ApproximatelyEqual(shakeStrengthCamera, INTENSITY_FULL) and ApproximatelyEqual(shakeStrengthUI, INTENSITY_FULL) then
				return 2;
			end
			return 3;
		end
		
		local function SetValue(value)
			if value == 1 then
				SetCVar("ShakeStrengthCamera", INTENSITY_NONE);
				SetCVar("ShakeStrengthUI", INTENSITY_NONE);
			elseif value == 2 then
				SetCVar("ShakeStrengthCamera", INTENSITY_FULL);
				SetCVar("ShakeStrengthUI", INTENSITY_FULL);
			elseif value == 3 then
				SetCVar("ShakeStrengthCamera", INTENSITY_REDUCED);
				SetCVar("ShakeStrengthUI", INTENSITY_REDUCED);
			end
		end
	
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(1, SHAKE_INTENSITY_NONE);
			container:Add(3, SHAKE_INTENSITY_REDUCED);
			container:Add(2, SHAKE_INTENSITY_FULL);
			return container:GetData();
		end

		local defaultValue = 3;
		local setting = Settings.RegisterProxySetting(category, "PROXY_SICKNESS_SHAKE", Settings.DefaultVarLocation,
			Settings.VarType.Number, ADJUST_MOTION_SICKNESS_SHAKE, defaultValue, GetValue, SetValue);
		Settings.CreateDropDown(category, setting, GetOptions, OPTION_TOOLTIP_ADJUST_MOTION_SICKNESS_SHAKE);
	end

	-- Cursor Size
	do
		local function FormatCursorSize(extent)
			return (extent.."x"..extent);
		end

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(-1, CURSOR_SIZE_DEFAULT);
			container:Add(0, FormatCursorSize(32));
			container:Add(1, FormatCursorSize(48));
			container:Add(2, FormatCursorSize(64));
			container:Add(3, FormatCursorSize(96));
			container:Add(4, FormatCursorSize(128));
			return container:GetData();
		end
		local setting = Settings.RegisterCVarSetting(category, "cursorSizePreferred", Settings.VarType.Number, CURSOR_SIZE);
		Settings.CreateDropDown(category, setting, GetOptions, CURSOR_SIZE_TOOLTIP);
	end

	-- Enable Dracthyr Tap Controls (Mirrored in Controls)
	do
		local function GetTapControlOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(0, SETTING_EMPOWERED_SPELL_INPUT_HOLD_OPTION, SETTING_EMPOWERED_SPELL_INPUT_HOLD_OPTION_TOOLTIP);
			container:Add(1, SETTING_EMPOWERED_SPELL_INPUT_TAP_OPTION, SETTING_EMPOWERED_SPELL_INPUT_TAP_OPTION_TOOLTIP);
			return container:GetData();
		end
		Settings.SetupCVarDropDown(category, "empowerTapControls", Settings.VarType.Number, GetTapControlOptions, SETTING_EMPOWERED_SPELL_INPUT, SETTING_EMPOWERED_SPELL_INPUT_TOOLTIP);
	end

	-- Show Target Tooltip
	do
		local function GetValue()
			return GetCVarBool("SoftTargetTooltipEnemy") and GetCVarBool("SoftTargetTooltipInteract");
		end
		
		local function SetValue(value)
			SetCVar("SoftTargetTooltipEnemy", value);
			SetCVar("SoftTargetTooltipInteract", value);
		end
		
		local defaultValue = false;
		local setting = Settings.RegisterProxySetting(category, "PROXY_TARGET_TOOLTIP", Settings.DefaultVarLocation, 
			Settings.VarType.Boolean, TARGET_TOOLTIP_OPTION, defaultValue, GetValue, SetValue);
		Settings.CreateCheckBox(category, setting, OPTION_TOOLTIP_TARGET_TOOLTIP);
	end

	-- Interact Key Icons
	do
		local function GetValue()
			local enemy = GetCVarBool("SoftTargetIconEnemy");
			local interact = GetCVarBool("SoftTargetIconInteract");
			local gameObject = GetCVarBool("SoftTargetIconGameObject");
			local lowPriority = GetCVarBool("SoftTargetLowPriorityIcons");
			if enemy and interact and gameObject and lowPriority then
				return 2;
			elseif not enemy and not interact and not gameObject and not lowPriority then
				return 3;
			else
				return 1;
			end
		end
		
		local function SetValue(value)
			if value == 1 then
				SetCVar("SoftTargetIconEnemy",			"0");
				SetCVar("SoftTargetIconInteract",		"1");
				SetCVar("SoftTargetIconGameObject",		"0");
				SetCVar("SoftTargetLowPriorityIcons",	"0");
			elseif value == 2 then
				SetCVar("SoftTargetIconEnemy",			"1");
				SetCVar("SoftTargetIconInteract",		"1");
				SetCVar("SoftTargetIconGameObject",		"1");
				SetCVar("SoftTargetLowPriorityIcons",	"1");
			elseif value == 3 then
				SetCVar("SoftTargetIconEnemy",			"0");
				SetCVar("SoftTargetIconInteract",		"0");
				SetCVar("SoftTargetIconGameObject",		"0");
				SetCVar("SoftTargetLowPriorityIcons",	"0");
			end
		end
	
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(1, INTERACT_ICONS_DEFAULT);
			container:Add(2, INTERACT_ICONS_SHOW_ALL);
			container:Add(3, INTERACT_ICONS_SHOW_NONE);
			return container:GetData();
		end

		local defaultValue = 3;
		local setting = Settings.RegisterProxySetting(category, "PROXY_INTERACT_ICONS", Settings.DefaultVarLocation,
			Settings.VarType.Number, INTERACT_ICONS_OPTION, defaultValue, GetValue, SetValue);
		Settings.CreateDropDown(category, setting, GetOptions, OPTION_TOOLTIP_INTERACT_ICONS);
	end

	Settings.RegisterCategory(category, SETTING_GROUP_ACCESSIBILITY);
end

SettingsRegistrar:AddRegistrant(Register);