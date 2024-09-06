AutoLootDropdownControlMixin = CreateFromMixins(SettingsDropdownControlMixin);

function AutoLootDropdownControlMixin:Init(initializer)
	SettingsDropdownControlMixin.Init(self, initializer);

	self.autoLootSetting = Settings.GetSetting("autoLootDefault");
	self:UpdateLabel();

	self.cbrHandles:SetOnValueChangedCallback("autoLootDefault", self.OnAutoLootChanged, self);
end

function AutoLootDropdownControlMixin:OnAutoLootChanged(setting, value)
	self:UpdateLabel();
end

function AutoLootDropdownControlMixin:UpdateLabel()
	local text = self.autoLootSetting:GetValue() and LOOT_KEY_TEXT or AUTO_LOOT_KEY_TEXT;
	self.Text:SetText(text);
end

function CreateAutoLootInitializer(setting)
	local options = Settings.CreateModifiedClickOptions({
		OPTION_TOOLTIP_AUTO_LOOT_ALT_KEY,
		OPTION_TOOLTIP_AUTO_LOOT_CTRL_KEY,
		OPTION_TOOLTIP_AUTO_LOOT_SHIFT_KEY,
		OPTION_TOOLTIP_AUTO_LOOT_NONE_KEY,
	});

	local data = Settings.CreateSettingInitializerData(setting, options, OPTION_TOOLTIP_AUTO_LOOT_KEY);
	local initializer = Settings.CreateSettingInitializer("AutoLootDropdownControlTemplate", data);
	initializer:AddSearchTags(LOOT_KEY_TEXT);
	return initializer;
end

local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(CONTROLS_LABEL);

	-- Order set in GameplaySettingsGroup.lua
	category:SetOrder(CUSTOM_GAMEPLAY_SETTINGS_ORDER[CONTROLS_LABEL]);

	---- Controls

	-- Sticky Targeting
	do
		local setting = Settings.SetupCVarCheckbox(category, "deselectOnClick", GAMEFIELD_DESELECT_TEXT, OPTION_TOOLTIP_GAMEFIELD_DESELECT);
		setting:NegateBoolean();
	end

	ControlsOverrides.SetupAutoDismountSetting(category);

	-- Auto Cancel AFK
	Settings.SetupCVarCheckbox(category, "autoClearAFK", CLEAR_AFK, OPTION_TOOLTIP_CLEAR_AFK);

	-- Interact on Left Click
	Settings.SetupCVarCheckbox(category, "interactOnLeftClick", INTERACT_ON_LEFT_CLICK_TEXT, OPTION_TOOLTIP_INTERACT_ON_LEFT_CLICK);

	ControlsOverrides.RunSettingsCallback(function()
		-- Open Loot Window at Mouse
		Settings.SetupCVarCheckbox(category, "lootUnderMouse", LOOT_UNDER_MOUSE_TEXT, OPTION_TOOLTIP_LOOT_UNDER_MOUSE);

		-- Auto Loot
		Settings.SetupCVarCheckbox(category, "autoLootDefault", AUTO_LOOT_DEFAULT_TEXT, OPTION_TOOLTIP_AUTO_LOOT_DEFAULT);

		-- Auto Loot Key
		local setting = Settings.RegisterModifiedClickSetting(category, "AUTOLOOTTOGGLE", AUTO_LOOT_KEY_TEXT, "SHIFT");
		local initializer = CreateAutoLootInitializer(setting);
		layout:AddInitializer(initializer);

		if C_CVar.GetCVar("combinedBags") then
			-- Use Combined Inventory Bags
			Settings.SetupCVarCheckbox(category, "combinedBags", USE_COMBINED_BAGS_TEXT, OPTION_TOOLTIP_USE_COMBINED_BAGS);
		end
	end);

	-- Enable Interact Key
	ControlsOverrides.RunSettingsCallback(function()
		local function GetValue()
			return tonumber(GetCVar("softTargetInteract")) == Enum.SoftTargetEnableFlags.Any;
		end

		local function SetValue(value)
			SetCVar("softTargetInteract", value and Enum.SoftTargetEnableFlags.Any or Enum.SoftTargetEnableFlags.Gamepad);
		end

		local defaultValue = false;
		local setting = Settings.RegisterProxySetting(category, "PROXY_ENABLE_INTERACT",
			Settings.VarType.Boolean, ENABLE_INTERACT_TEXT, defaultValue, GetValue, SetValue);
		Settings.CreateCheckbox(category, setting, OPTION_TOOLTIP_ENABLE_INTERACT);
	end);

	-- Interact Key
	do
		local action = "INTERACTTARGET";
		local bindingIndex = C_KeyBindings.GetBindingIndex(action);
		local initializer = CreateKeybindingEntryInitializer(bindingIndex, true);
		initializer:AddSearchTags(GetBindingName(action));
		layout:AddInitializer(initializer);
	end

	-- Enable Interact Key Sound
	Settings.SetupCVarCheckbox(category, "softTargettingInteractKeySound", ENABLE_INTERACT_SOUND_OPTION, ENABLE_INTERACT_SOUND_OPTION_TOOLTIP);

	---- Mouse
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(MOUSE_LABEL));

	-- Lock Cursor
	if SupportsClipCursor() then
		Settings.SetupCVarCheckbox(category, "ClipCursor", LOCK_CURSOR, OPTION_TOOLTIP_LOCK_CURSOR);
	end

	-- Invert Mouse
	Settings.SetupCVarCheckbox(category, "mouseInvertPitch", INVERT_MOUSE, OPTION_TOOLTIP_INVERT_MOUSE);

	local function GetFormatter1to10(minValue, maxValue)
		return function(value)
			return RoundToSignificantDigits(((value-minValue)/(maxValue-minValue) * 9) + 1, 1)
		end
	end

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
		local setting = Settings.RegisterProxySetting(category, "PROXY_MOUSE_LOOK_SPEED",
			Settings.VarType.Number, MOUSE_LOOK_SPEED, defaultValue, GetValue, SetValue);

		local minValue, maxValue, step = 90, 270, 10;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, GetFormatter1to10(minValue, maxValue));
		Settings.CreateSlider(category, setting, options, OPTION_TOOLTIP_MOUSE_LOOK_SPEED);
	end

	-- Enable Mouse Sensitivity
	do
		local cbSetting = Settings.RegisterCVarSetting(category, "enableMouseSpeed", Settings.VarType.Boolean, ENABLE_MOUSE_SPEED);
		local sliderSetting = Settings.RegisterCVarSetting(category, "mouseSpeed", Settings.VarType.Number, MOUSE_SENSITIVITY);

		local minValue, maxValue, step = 0.5, 1.4, .05;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, GetFormatter1to10(minValue, maxValue));

		local initializer = CreateSettingsCheckboxSliderInitializer(
				cbSetting, ENABLE_MOUSE_SPEED, OPTION_TOOLTIP_MOUSE_SENSITIVITY,
				sliderSetting, options, MOUSE_SENSITIVITY, OPTION_TOOLTIP_MOUSE_SENSITIVITY);
		layout:AddInitializer(initializer);
	end

	-- Click to Move
	do
		local cbSetting = Settings.RegisterCVarSetting(category, "autointeract", Settings.VarType.Boolean, CLICK_TO_MOVE);
		local dropdownSetting = Settings.RegisterCVarSetting(category, "cameraSmoothTrackingStyle", Settings.VarType.Number, CAMERA_CTM_FOLLOWING_STYLE);

		local function GetOptionData(options)
			local container = Settings.CreateControlTextContainer();
			container:Add(1, CAMERA_SMART, OPTION_TOOLTIP_CAMERA_SMART);
			container:Add(4, CAMERA_SMARTER, OPTION_TOOLTIP_CAMERA_SMARTER);
			container:Add(2, CAMERA_ALWAYS, OPTION_TOOLTIP_CAMERA_ALWAYS);
			container:Add(0, CAMERA_NEVER, OPTION_TOOLTIP_CAMERA_NEVER);
			return container:GetData();
		end

		local initializer = CreateSettingsCheckboxDropdownInitializer(
			cbSetting, CLICK_TO_MOVE, OPTION_TOOLTIP_CLICK_TO_MOVE,
			dropdownSetting, GetOptionData, CAMERA_CTM_FOLLOWING_STYLE, OPTION_TOOLTIP_CTM_CAMERA_FOLLOWING_STYLE);
		initializer:AddSearchTags(CLICK_TO_MOVE, CAMERA_CTM_FOLLOWING_STYLE);
		layout:AddInitializer(initializer);
	end

	---- Camera
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(CAMERA_LABEL));

	-- Water Collision
	Settings.SetupCVarCheckbox(category, "cameraWaterCollision", WATER_COLLISION, OPTION_TOOLTIP_WATER_COLLISION);

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
		local setting = Settings.RegisterProxySetting(category, "PROXY_CAMERA_SPEED",
			Settings.VarType.Number, AUTO_FOLLOW_SPEED, defaultValue, GetValue, SetValue);

		local minValue, maxValue, step = 90, 270, 10;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, GetFormatter1to10(minValue, maxValue));
		Settings.CreateSlider(category, setting, options, OPTION_TOOLTIP_AUTO_FOLLOW_SPEED);
	end

	-- Camera Following Style
	do
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(1, CAMERA_SMART, OPTION_TOOLTIP_CAMERA_SMART);
			container:Add(4, CAMERA_SMARTER, OPTION_TOOLTIP_CAMERA_SMARTER);
			container:Add(2, CAMERA_ALWAYS, OPTION_TOOLTIP_CAMERA_ALWAYS);
			container:Add(0, CAMERA_NEVER, OPTION_TOOLTIP_CAMERA3);
			return container:GetData();
		end
		Settings.SetupCVarDropdown(category, "cameraSmoothStyle", Settings.VarType.Number, GetOptions, CAMERA_FOLLOWING_STYLE, OPTION_TOOLTIP_CAMERA_FOLLOWING_STYLE);
	end

	ControlsOverrides.AdjustCameraSettings(category);

	Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);
end

SettingsRegistrar:AddRegistrant(Register);