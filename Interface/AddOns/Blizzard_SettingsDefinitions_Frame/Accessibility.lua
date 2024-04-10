QuestTextPreviewMixin = { };

function QuestTextPreviewMixin:OnShow()
	self:UpdatePreview(GetCVarNumberOrDefault("QuestTextContrast"));
end

function QuestTextPreviewMixin:UpdatePreview(value)
	local atlas = QuestUtil.GetQuestBackgroundAtlas(value)
	local useLightText = QuestUtil.ShouldQuestTextContrastSettingUseLightText(value)

	self.Background:SetAtlas(atlas);

	local textColor, titleTextColor = GetMaterialTextColors("Parchment");
	if useLightText then
		textColor, titleTextColor = GetMaterialTextColors("Stone");
	end
	self.TitleText:SetTextColor(titleTextColor[1], titleTextColor[2], titleTextColor[3]);
	self.BodyText:SetTextColor(textColor[1], textColor[2], textColor[3]);
end

local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(ACCESSIBILITY_GENERAL_LABEL);

	-- Move Pad
	Settings.SetupCVarCheckBox(category, "enableMovePad", MOVE_PAD, OPTION_TOOLTIP_MOVE_PAD);
	Settings.LoadAddOnCVarWatcher("enableMovePad", "Blizzard_MovePad");

	--Cinematic Subtitles
	Settings.SetupCVarCheckBox(category, "movieSubtitle", CINEMATIC_SUBTITLES, OPTION_TOOLTIP_CINEMATIC_SUBTITLES);
	
	-- Alternate Full Screen Effects
	AccessibilityOverrides.CreatePhotosensitivitySetting(category);

	-- Quest Text Contrast
	if C_CVar.GetCVar("questTextContrast") then
		do
			local function GetValue()
				return GetCVarNumberOrDefault("questTextContrast");
			end
			
			local function SetValue(value)
				SetCVar("questTextContrast", value);
			end

			local function OnEntryEnter(value)
				SettingsPanel.QuestTextPreview:UpdatePreview(value);
			end
		
			local function GetOptions()
				local container = Settings.CreateControlTextContainer();
				container:Add(0, QUEST_BG_DEFAULT);
				container:Add(1, QUEST_BG_LIGHT1);
				container:Add(2, QUEST_BG_LIGHT2);
				container:Add(3, QUEST_BG_LIGHT3);
				container:Add(4, QUEST_BG_DARK);
				local data = container:GetData();
				for index, entryData in ipairs(data) do
					entryData.OnEnter = OnEntryEnter;
				end
				return data;
			end

			local function OnShow()
				SettingsPanel.QuestTextPreview:Show();
			end

			local function OnHide()
				SettingsPanel.QuestTextPreview:Hide();
			end
			
			local defaultValue = 0;
			local setting = Settings.RegisterProxySetting(category, "PROXY_QUEST_TEXT_CONTRAST", Settings.DefaultVarLocation,
				Settings.VarType.Number, ENABLE_QUEST_TEXT_CONTRAST, defaultValue, GetValue, SetValue);
			setting.OnShow = OnShow;
			setting.OnHide = OnHide;
			Settings.CreateDropDown(category, setting, GetOptions, OPTION_TOOLTIP_ENABLE_QUEST_TEXT_CONTRAST);
		end
	end

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
			return not GetCVarBool("CameraKeepCharacterCentered") 
				and GetCVarBool("CameraReduceUnexpectedMovement");
		end
		
		local function SetValue(value)
			SetCVar("CameraKeepCharacterCentered", not value);
			SetCVar("CameraReduceUnexpectedMovement", value);
		end

		local defaultValue = false;
		local setting = Settings.RegisterProxySetting(category, "PROXY_SICKNESS", Settings.DefaultVarLocation, 
			Settings.VarType.Boolean, MOTION_SICKNESS_CHECKBOX, defaultValue, GetValue, SetValue);
		local initializer = Settings.CreateCheckBox(category, setting, OPTION_TOOLTIP_MOTION_SICKNESS_CHECKBOX);
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

		local defaultValue = 3;
		local setting = Settings.RegisterProxySetting(category, "PROXY_SICKNESS_SHAKE", Settings.DefaultVarLocation,
			Settings.VarType.Number, ADJUST_MOTION_SICKNESS_SHAKE, defaultValue, GetValue, SetValue);
		local initializer = Settings.CreateDropDown(category, setting, GetOptions, OPTION_TOOLTIP_ADJUST_MOTION_SICKNESS_SHAKE);
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
		Settings.CreateDropDown(category, setting, GetOptions, CURSOR_SIZE_TOOLTIP);
	end

	-- Enable Raid Self Highlight (Source in Combat)
	layout:AddMirroredInitializer(Settings.RaidSelfHighlightInitializer);

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