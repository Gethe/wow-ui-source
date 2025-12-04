ArachnophobiaMixin = {};

function ArachnophobiaMixin:OnLoad()
	SettingsCheckboxControlMixin.OnLoad(self);

	self.SubTextContainer:SetPoint("TOPLEFT", self.Checkbox, "TOPRIGHT", 0, 0);
	self.SubTextContainer.SubText:ClearAllPoints();
	self.SubTextContainer.SubText:SetPoint("LEFT", self.Checkbox, "RIGHT", 8, 0);
end

local function RegisterMinimumCharacterNameSize(category)
	local cvarName = "WorldTextMinSize";
	local minValue, maxValue, step = 0, 64, 2;

	local function CanModifySetting()
		return not C_Glue.IsOnGlueScreen() and C_CVar.GetCVar(cvarName) ~= nil;
	end

	local function GetValue()
		if CanModifySetting() then
			GetCVarNumberOrDefault(cvarName);
		end

		return 0;
	end

	local function SetValue(value)
		SetCVar(cvarName, value);
	end

	local setting = Settings.RegisterProxySetting(category, "PROXY_MINIMUM_CHARACTER_NAME_SIZE", Settings.VarType.Number, MINIMUM_CHARACTER_NAME_SIZE_TEXT, 0, GetValue, SetValue);

	local options = Settings.CreateSliderOptions(minValue, maxValue, step);
	options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);

	local initializer = Settings.CreateSlider(category, setting, options, OPTION_TOOLTIP_MINIMUM_CHARACTER_NAME_SIZE);
	initializer:AddModifyPredicate(CanModifySetting);
end

local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(ACCESSIBILITY_GENERAL_LABEL);

	-- Move Pad
	Settings.SetupCVarCheckbox(category, "enableMovePad", MOVE_PAD, OPTION_TOOLTIP_MOVE_PAD);
	Settings.LoadAddOnCVarWatcher("enableMovePad", "Blizzard_MovePad");

	-- Alternate Full Screen Effects
	AccessibilityOverrides.CreatePhotosensitivitySetting(category);

	-- Minimum Name Size
	RegisterMinimumCharacterNameSize(category);

	-- Motion Sickness
	do
		local function GetValue()
			return not GetCVarBool("CameraKeepCharacterCentered")
				and GetCVarBool("CameraReduceUnexpectedMovement");
		end

		local function SetValue(value)
			SetCVar("CameraKeepCharacterCentered", not value);
			SetCVar("CameraReduceUnexpectedMovement", value);
		end

		local defaultValue = false;
		local setting = Settings.RegisterProxySetting(category, "PROXY_SICKNESS",
			Settings.VarType.Boolean, MOTION_SICKNESS_CHECKBOX, defaultValue, GetValue, SetValue);
		local initializer = Settings.CreateCheckbox(category, setting, OPTION_TOOLTIP_MOTION_SICKNESS_CHECKBOX);
		initializer:AddSearchTags(MOTION_SICKNESS_CHECKBOX);
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

		local defaultValue = 2;
		local setting = Settings.RegisterProxySetting(category, "PROXY_SICKNESS_SHAKE",
			Settings.VarType.Number, ADJUST_MOTION_SICKNESS_SHAKE, defaultValue, GetValue, SetValue);
		local initializer = Settings.CreateDropdown(category, setting, GetOptions, OPTION_TOOLTIP_ADJUST_MOTION_SICKNESS_SHAKE);
		initializer:AddSearchTags(MOTION_SICKNESS_CHECKBOX);
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
		Settings.CreateDropdown(category, setting, GetOptions, CURSOR_SIZE_TOOLTIP);
	end

	-- Enable Raid Self Highlight (Source in Combat)
	layout:AddMirroredInitializer(Settings.RaidSelfHighlightInitializer);

	-- Show Silhouette when Obscured (Source in Combat)
	layout:AddMirroredInitializer(Settings.OccludedSilhouettePlayerInitializer);

	-- Enable Spell Alert Opacity (Source in Combat)
	if C_CVar.GetCVar("spellActivationOverlayOpacity") then
		layout:AddMirroredInitializer(Settings.SpellAlertOpacityInitializer);
	end

	-- Enable Hold Button (Source in Combat)
	if C_CVar.GetCVar("ActionButtonUseKeyHeldSpell") then
		layout:AddMirroredInitializer(Settings.PressAndHoldCastingInitializer);
	end

	-- Enable Dracthyr Tap Controls (Source in Combat)
	if C_CVar.GetCVar("empowerTapControls") then
		layout:AddMirroredInitializer(Settings.EmpoweredTapControlsInitializer);
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
		local setting = Settings.RegisterProxySetting(category, "PROXY_TARGET_TOOLTIP",
			Settings.VarType.Boolean, TARGET_TOOLTIP_OPTION, defaultValue, GetValue, SetValue);
		Settings.CreateCheckbox(category, setting, OPTION_TOOLTIP_TARGET_TOOLTIP);
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

		local defaultValue = 1;
		local setting = Settings.RegisterProxySetting(category, "PROXY_INTERACT_ICONS",
			Settings.VarType.Number, INTERACT_ICONS_OPTION, defaultValue, GetValue, SetValue);
		Settings.CreateDropdown(category, setting, GetOptions, OPTION_TOOLTIP_INTERACT_ICONS);
	end

	-- Arachnophobia
	do
		AccessibilityOverrides.CreateArachnophobiaSetting(category, layout);
	end

	Settings.RegisterCategory(category, SETTING_GROUP_ACCESSIBILITY);
end

SettingsRegistrar:AddRegistrant(Register);
