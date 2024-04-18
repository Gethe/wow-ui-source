local RaidSettingsEnabledCVar = "RAIDsettingsEnabled";
local ErrorMessages =
{
	VRN_ILLEGAL,
	VRN_UNSUPPORTED,
	VRN_GRAPHICS,
	VRN_DUALCORE,
	VRN_QUADCORE,
	VRN_CPUMEM_2GB,
	VRN_CPUMEM_4GB,
	VRN_CPUMEM_8GB,
	VRN_NEEDS_5_0,
	VRN_NEEDS_6_0,
	VRN_NEEDS_RT,
	VRN_NEEDS_DX12,
	VRN_NEEDS_DX12_VRS2,
	VRN_NEEDS_APPLE_GPU,
	VRN_NEEDS_AMD_GPU,
	VRN_NEEDS_INTEL_GPU,
	VRN_NEEDS_NVIDIA_GPU,
	VRN_NEEDS_QUALCOMM_GPU,
	VRN_NEEDS_MACOS_10_13,
	VRN_NEEDS_MACOS_10_14,
	VRN_NEEDS_MACOS_10_15,
	VRN_NEEDS_MACOS_11_0,
	VRN_NEEDS_MACOS_12_0,
	VRN_NEEDS_MACOS_13_0,
	VRN_NEEDS_WINDOWS_10,
	VRN_NEEDS_WINDOWS_11,
	VRN_MACOS_UNSUPPORTED,
	VRN_WINDOWS_UNSUPPORTED,
	VRN_LEGACY_UNSUPPORTED,
	VRN_DX11_UNSUPPORTED,
	VRN_DX12_WIN7_UNSUPPORTED,
	VRN_REMOTE_DESKTOP_UNSUPPORTED,
	VRN_WINE_UNSUPPORTED,
	VRN_NVAPI_WINE_UNSUPPORTED,
	VRN_APPLE_UNSUPPORTED,
	VRN_AMD_UNSUPPORTED,
	VRN_INTEL_UNSUPPORTED,
	VRN_NVIDIA_UNSUPPORTED,
	VRN_QUALCOMM_UNSUPPORTED,
	VRN_GPU_DRIVER,
};

local function IncrementByOne(value)
	return value + 1;
end

local function FormatScreenResolution(width, height)
	return (math.floor(width).."x"..math.floor(height));
end

local function ExtractSizeFromFormattedSize(formattedSize)
	local x, y = formattedSize:match("([^,]+)x([^,]+)");
	return tonumber(x), tonumber(y);
end

local function CreateAdvancedQualitySetting(category, cvar, name, proxyName, minQualityValue)
	local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures(cvar, Settings.VarType.Number);
	local commitValue = setValue;
	local setting = Settings.RegisterProxySetting(category, proxyName, Settings.DefaultVarLocation, Settings.VarType.Number, name, getDefaultValue(), getValue, nil, commitValue);
	setting:SetCommitFlags(Settings.CommitFlag.Apply);
	setting.minQualityValue = minQualityValue or -1;
	return setting;
end

local function CreateQualitySliderSetting(cvar, label, proxyName, tooltip)
	local getValue, setValue = Settings.CreateCVarAccessorClosures(cvar, Settings.VarType.Number);
	local commitValue = setValue;
	local defaultValue = tonumber(GetCVarDefault(cvar));
	local setting = Settings.RegisterProxySetting(category, proxyName, Settings.DefaultVarLocation,
		Settings.VarType.Number, label, defaultValue, getValue, nil, commitValue);

	local minValue, maxValue, step = 0, 9, 1;
	local options = Settings.CreateSliderOptions(minValue, maxValue, step);
	options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, IncrementByOne);

	local initializer = Settings.CreateSlider(category, setting, options, tooltip);
	return {setting = setting, initializer = initializer, cvar = cvar};
end

SettingsAdvancedQualityControlsMixin = {};

function SettingsAdvancedQualityControlsMixin:Init(settings, raid, cbrHandles)

	self.cbrHandles = cbrHandles;

	local function AddRecommended(container, cvar)
		local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures(cvar, Settings.VarType.Number);
		local defaultValue = getDefaultValue();

		for index, data in ipairs(container:GetData()) do
			if data.value == defaultValue then
				data.recommend = true;
			end
		end
	end

	local function AddValidatedSettingOption(container, cvar, raid, value, label, tooltip)
		local data = container:Add(value, label, tooltip);
		local error = IsGraphicsSettingValueSupported(cvar, value, raid);
		data.disabled = ErrorMessages[error];
		return data;
	end

	local settingGraphicsQuality = settings["graphicsQuality"] or settings["raidGraphicsQuality"];
	local settingShadowQuality = settings["graphicsShadowQuality"] or settings["raidGraphicsShadowQuality"];
	local settingLiquidDetail = settings["graphicsLiquidDetail"] or settings["raidGraphicsLiquidDetail"];
	local settingParticleDensity = settings["graphicsParticleDensity"] or settings["raidGraphicsParticleDensity"];
	local settingSSAO = settings["graphicsSSAO"] or settings["raidGraphicsSSAO"];
	local settingDepthEffects = settings["graphicsDepthEffects"] or settings["raidGraphicsDepthEffects"];
	local settingComputeEffects = settings["graphicsComputeEffects"] or settings["raidGraphicsComputeEffects"];
	local settingOutlineMode = settings["graphicsOutlineMode"] or settings["raidGraphicsOutlineMode"];
	local settingTextureResolution = settings["graphicsTextureResolution"] or settings["raidGraphicsTextureResolution"];
	local settingSpellDensity = settings["graphicsSpellDensity"] or settings["raidGraphicsSpellDensity"];
	local settingProjectedTextures = settings["graphicsProjectedTextures"] or settings["raidGraphicsProjectedTextures"];
	local settingViewDistance = settings["graphicsViewDistance"] or settings["raidGraphicsViewDistance"];
	local settingEnvironmentDetail = settings["graphicsEnvironmentDetail"] or settings["raidGraphicsEnvironmentDetail"];
	local settingGroundClutter = settings["graphicsGroundClutter"] or settings["raidGraphicsGroundClutter"];

	local function GetShadowQualityOptions()
		local container = Settings.CreateControlTextContainer();
		local variable = settingShadowQuality:GetVariable();
		AddValidatedSettingOption(container, variable, raid, 0, VIDEO_OPTIONS_LOW, VIDEO_OPTIONS_SHADOW_QUALITY_LOW);
		AddValidatedSettingOption(container, variable, raid, 1, VIDEO_OPTIONS_FAIR, VIDEO_OPTIONS_SHADOW_QUALITY_FAIR);
		AddValidatedSettingOption(container, variable, raid, 2, VIDEO_OPTIONS_MEDIUM, VIDEO_OPTIONS_SHADOW_QUALITY_MEDIUM);
		AddValidatedSettingOption(container, variable, raid, 3, VIDEO_OPTIONS_HIGH, VIDEO_OPTIONS_SHADOW_QUALITY_HIGH);
		AddValidatedSettingOption(container, variable, raid, 4, VIDEO_OPTIONS_ULTRA, VIDEO_OPTIONS_SHADOW_QUALITY_ULTRA);
		AddValidatedSettingOption(container, variable, raid, 5, VIDEO_OPTIONS_ULTRA_HIGH, VIDEO_OPTIONS_SHADOW_QUALITY_ULTRA_HIGH);
		AddRecommended(container, variable);
		return container:GetData();
	end

	local function GetLiquidDetailOptions()
		local container = Settings.CreateControlTextContainer();
		local variable = settingLiquidDetail:GetVariable();
		AddValidatedSettingOption(container, variable, raid, 0, VIDEO_OPTIONS_LOW, VIDEO_OPTIONS_LIQUID_DETAIL_LOW);
		AddValidatedSettingOption(container, variable, raid, 1, VIDEO_OPTIONS_FAIR, VIDEO_OPTIONS_LIQUID_DETAIL_FAIR);
		AddValidatedSettingOption(container, variable, raid, 2, VIDEO_OPTIONS_MEDIUM, VIDEO_OPTIONS_LIQUID_DETAIL_MEDIUM);
		AddValidatedSettingOption(container, variable, raid, 3, VIDEO_OPTIONS_HIGH, VIDEO_OPTIONS_LIQUID_DETAIL_ULTRA);
		AddRecommended(container, variable);
		return container:GetData();
	end

	local function GetParticleDensityOptions()
		local container = Settings.CreateControlTextContainer();
		local variable = settingParticleDensity:GetVariable();
		local data = AddValidatedSettingOption(container, variable, raid, 0, WARNING_FONT_COLOR:WrapTextInColorCode(VIDEO_OPTIONS_DISABLED));
		data.warning = WARNING_FONT_COLOR:WrapTextInColorCode(VIDEO_OPTIONS_COMBAT_CUES_DISABLED_WARNING);
		AddValidatedSettingOption(container, variable, raid, 1, VIDEO_OPTIONS_LOW);
		AddValidatedSettingOption(container, variable, raid, 2, VIDEO_OPTIONS_FAIR);
		AddValidatedSettingOption(container, variable, raid, 3, VIDEO_OPTIONS_MEDIUM);
		AddValidatedSettingOption(container, variable, raid, 4, VIDEO_OPTIONS_HIGH);
		AddValidatedSettingOption(container, variable, raid, 5, VIDEO_OPTIONS_ULTRA);
		AddRecommended(container, variable);
		return container:GetData();
	end

	local function GetSSAOOptions()
		local container = Settings.CreateControlTextContainer();
		local variable = settingSSAO:GetVariable();
		AddValidatedSettingOption(container, variable, raid, 0, VIDEO_OPTIONS_DISABLED);
		AddValidatedSettingOption(container, variable, raid, 1, VIDEO_OPTIONS_LOW);
		AddValidatedSettingOption(container, variable, raid, 2, VIDEO_OPTIONS_MEDIUM);
		AddValidatedSettingOption(container, variable, raid, 3, VIDEO_OPTIONS_HIGH);
		AddValidatedSettingOption(container, variable, raid, 4, VIDEO_OPTIONS_ULTRA);
		AddRecommended(container, variable);
		return container:GetData();
	end

	local function GetDepthEffectOptions()
		local container = Settings.CreateControlTextContainer();
		local variable = settingDepthEffects:GetVariable();
		AddValidatedSettingOption(container, variable, raid, 0, VIDEO_OPTIONS_DISABLED, VIDEO_OPTIONS_DEPTH_EFFECTS_DISABLED);
		AddValidatedSettingOption(container, variable, raid, 1, VIDEO_OPTIONS_LOW, VIDEO_OPTIONS_DEPTH_EFFECTS_LOW);
		AddValidatedSettingOption(container, variable, raid, 2, VIDEO_OPTIONS_MEDIUM, VIDEO_OPTIONS_DEPTH_EFFECTS_MEDIUM);
		AddValidatedSettingOption(container, variable, raid, 3, VIDEO_OPTIONS_HIGH, VIDEO_OPTIONS_DEPTH_EFFECTS_HIGH);
		AddRecommended(container, variable);
		return container:GetData();
	end

	local function GetComputeEffectOptions()
		local container = Settings.CreateControlTextContainer();
		local variable = settingComputeEffects:GetVariable();
		AddValidatedSettingOption(container, variable, raid, 0, VIDEO_OPTIONS_DISABLED, VIDEO_OPTIONS_COMPUTE_EFFECTS_DISABLED);
		AddValidatedSettingOption(container, variable, raid, 1, VIDEO_OPTIONS_LOW, VIDEO_OPTIONS_COMPUTE_EFFECTS_LOW);
		AddValidatedSettingOption(container, variable, raid, 2, VIDEO_OPTIONS_MEDIUM, VIDEO_OPTIONS_COMPUTE_EFFECTS_MEDIUM);
		AddValidatedSettingOption(container, variable, raid, 3, VIDEO_OPTIONS_HIGH, VIDEO_OPTIONS_COMPUTE_EFFECTS_HIGH);
		AddValidatedSettingOption(container, variable, raid, 4, VIDEO_OPTIONS_ULTRA, VIDEO_OPTIONS_COMPUTE_EFFECTS_ULTRA);
		AddRecommended(container, variable);
		return container:GetData();
	end

	local function GetOutlineModeOptions()
		local container = Settings.CreateControlTextContainer();
		local variable = settingOutlineMode:GetVariable();
		AddValidatedSettingOption(container, variable, raid, 0, VIDEO_OPTIONS_DISABLED);
		AddValidatedSettingOption(container, variable, raid, 1, VIDEO_OPTIONS_MEDIUM);
		AddValidatedSettingOption(container, variable, raid, 2, VIDEO_OPTIONS_HIGH);
		AddRecommended(container, variable);
		return container:GetData();
	end

	local function GetSpellDensityOptions()
		local container = Settings.CreateControlTextContainer();
		local variable = settingSpellDensity:GetVariable();
		AddValidatedSettingOption(container, variable, raid, 0, VIDEO_OPTIONS_ONLY_ESSENTIAL, VIDEO_OPTIONS_SPELL_DENSITY_ONLY_ESSENTIAL);
		AddValidatedSettingOption(container, variable, raid, 1, VIDEO_OPTIONS_SOME, VIDEO_OPTIONS_SPELL_DENSITY_SOME);
		AddValidatedSettingOption(container, variable, raid, 2, VIDEO_OPTIONS_HALF, VIDEO_OPTIONS_SPELL_DENSITY_HALF);
		AddValidatedSettingOption(container, variable, raid, 3, VIDEO_OPTIONS_MOST, VIDEO_OPTIONS_SPELL_DENSITY_MOST);
		AddValidatedSettingOption(container, variable, raid, 4, VIDEO_OPTIONS_DYNAMIC, VIDEO_OPTIONS_SPELL_DENSITY_DYNAMIC);
		AddValidatedSettingOption(container, variable, raid, 5, VIDEO_OPTIONS_EVERYTHING, VIDEO_OPTIONS_SPELL_DENSITY_EVERYTHING);
		AddRecommended(container, variable);
		return container:GetData();
	end

	local function GetProjectedTexturesOptions()
		local container = Settings.CreateControlTextContainer();
		local variable = settingProjectedTextures:GetVariable();
		local data = AddValidatedSettingOption(container, variable, raid, 0, WARNING_FONT_COLOR:WrapTextInColorCode(VIDEO_OPTIONS_DISABLED));
		data.warning = WARNING_FONT_COLOR:WrapTextInColorCode(VIDEO_OPTIONS_COMBAT_CUES_DISABLED_WARNING);
		AddValidatedSettingOption(container, variable, raid, 1, VIDEO_OPTIONS_ENABLED);
		AddRecommended(container, variable);
		return container:GetData();
	end

	local function InitControlDropDown(control, setting, name, tooltip, options)
		if not setting then
			control:Hide();
			return
		end

		local dropDown = control.DropDown;
		control.Text:SetText(name);

		local function OnDropDownValueChanged(self, option)
			setting:SetValue(option.value);
		end

		self.cbrHandles:RegisterCallback(dropDown.Button, SelectionPopoutButtonMixin.Event.OnValueChanged, OnDropDownValueChanged);

		local initTooltip = Settings.CreateOptionsInitTooltip(setting, name, tooltip, options);
		Settings.InitSelectionDropDown(dropDown, setting, options, 200, initTooltip);

		local tooltipFunc = GenerateClosure(Settings.InitTooltip, name, tooltip);
		control:SetTooltipFunc(tooltipFunc);

		local function OnSettingValueChanged(o, setting, value)
			local index = dropDown.Button:FindIndex(function(data)
				return data.value == value;
			end);
			dropDown.Button:SetSelectedIndex(index);
		end

		self.cbrHandles:SetOnValueChangedCallback(setting:GetVariable(), OnSettingValueChanged);
	end

	local function InitControlSlider(control, setting, name, tooltip, options)
		if not setting then
			control:Hide();
			return
		end

		control.Text:SetText(name);

		local function OnSliderValueChanged(o, value)
			setting:SetValue(value);
		end

		local sliderWithSteppers = control.SliderWithSteppers;
		sliderWithSteppers:Init(setting:GetValue(), options.minValue, options.maxValue, options.steps, options.formatters);

		local initTooltip = GenerateClosure(Settings.InitTooltip, name, tooltip);
		sliderWithSteppers.Slider:SetTooltipFunc(initTooltip);
		control:SetTooltipFunc(initTooltip);

		self.cbrHandles:RegisterCallback(sliderWithSteppers, MinimalSliderWithSteppersMixin.Event.OnValueChanged, OnSliderValueChanged);

		local function OnSettingValueChanged(o, setting, value)
			sliderWithSteppers:SetValue(value);
		end

		self.cbrHandles:SetOnValueChangedCallback(setting:GetVariable(), OnSettingValueChanged);
	end

	local function InitControlCheckBoxSlider(control, cbSetting, sliderSetting, cbName, cbTooltip, name, tooltip, options)
		InitControlSlider(control, sliderSetting, name, tooltip, options);

		function OnCheckBoxValueChanged(o, value)
			cbSetting:SetValue(value);

			if value then
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
			else
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
			end

			control.SliderWithSteppers:SetEnabled_(value);
		end

		local cbInitTooltip = GenerateClosure(Settings.InitTooltip, cbName, cbTooltip);
		control.CheckBox:Init(cbSetting:GetValue(), cbInitTooltip);
		control:SetTooltipFunc(cbInitTooltip);
		control:SetCustomTooltipAnchoring(self.CheckBox, "ANCHOR_TOP", 0, 0);
		self.cbrHandles:RegisterCallback(control.CheckBox, SettingsCheckBoxMixin.Event.OnValueChanged, OnCheckBoxValueChanged);
	end

	do
		local function SetControlsEnabled(enabled)
			for _, control in pairs(self.Controls) do
				if control.DropDown then
					control.DropDown:SetEnabled_(enabled);
				end
				if control.SliderWithSteppers then
					control.SliderWithSteppers:SetEnabled_(enabled);
				end
			end
		end

		if raid then
			SetControlsEnabled(Settings.GetValue(RaidSettingsEnabledCVar));

			local function OnSettingValueChanged(o, setting, value)
				SetControlsEnabled(value);
			end
			self.cbrHandles:SetOnValueChangedCallback(RaidSettingsEnabledCVar, OnSettingValueChanged);
		else
			SetControlsEnabled(true);
		end
	end

	local minValue, maxValue, step = 0, 9, 1;
	local options = Settings.CreateSliderOptions(minValue, maxValue, step);
	options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, IncrementByOne);

	if raid then
		InitControlCheckBoxSlider(self.GraphicsQuality, Settings.GetSetting(RaidSettingsEnabledCVar), settingGraphicsQuality, SETTINGS_RAID_GRAPHICS_QUALITY, RAID_SETTINGS_ENABLED_TOOLTIP, SETTINGS_RAID_GRAPHICS_QUALITY, OPTION_TOOLTIP_RAID_GRAPHICS_QUALITY, options);
	else
		InitControlSlider(self.GraphicsQuality, settingGraphicsQuality, BASE_GRAPHICS_QUALITY, OPTION_TOOLTIP_GRAPHICS_QUALITY, options);
	end
	self.GraphicsQuality:SetCustomTooltipAnchoring(self.GraphicsQuality, "ANCHOR_TOP", 0, 0);
	self.GraphicsQuality.SliderWithSteppers.Slider:SetCustomTooltipAnchoring(self.GraphicsQuality.SliderWithSteppers, "ANCHOR_TOP", 0, 0);

	InitControlDropDown(self.ShadowQuality, settingShadowQuality, SHADOW_QUALITY, OPTION_TOOLTIP_SHADOW_QUALITY, GetShadowQualityOptions);
	InitControlDropDown(self.LiquidDetail, settingLiquidDetail, LIQUID_DETAIL, OPTION_TOOLTIP_LIQUID_DETAIL, GetLiquidDetailOptions);
	InitControlDropDown(self.ParticleDensity, settingParticleDensity, PARTICLE_DENSITY, OPTION_TOOLTIP_PARTICLE_DENSITY, GetParticleDensityOptions);
	InitControlDropDown(self.SSAO, settingSSAO,	SSAO_LABEL, OPTION_TOOLTIP_SSAO, GetSSAOOptions);
	InitControlDropDown(self.DepthEffects, settingDepthEffects, DEPTH_EFFECTS, OPTION_TOOLTIP_DEPTH_EFFECTS, GetDepthEffectOptions);
	InitControlDropDown(self.ComputeEffects, settingComputeEffects, COMPUTE_EFFECTS, OPTION_TOOLTIP_COMPUTE_EFFECTS, GetComputeEffectOptions);
	InitControlDropDown(self.OutlineMode, settingOutlineMode, OUTLINE_MODE, OPTION_TOOLTIP_OUTLINE_MODE, GetOutlineModeOptions);
	InitControlDropDown(self.TextureResolution, settingTextureResolution, TEXTURE_DETAIL, OPTION_TOOLTIP_TEXTURE_DETAIL, GenerateClosure(GraphicsOverrides.GetTextureResolutionOptions, settingTextureResolution, AddValidatedSettingOption, AddRecommended));
	InitControlDropDown(self.SpellDensity, settingSpellDensity, SPELL_DENSITY, OPTION_TOOLTIP_SPELL_DENSITY, GetSpellDensityOptions);
	InitControlDropDown(self.ProjectedTextures, settingProjectedTextures, PROJECTED_TEXTURES, OPTION_TOOLTIP_PROJECTED_TEXTURES, GetProjectedTexturesOptions);
	InitControlSlider(	self.ViewDistance, settingViewDistance, FARCLIP, OPTION_TOOLTIP_FARCLIP, options);
	InitControlSlider(	self.EnvironmentDetail, settingEnvironmentDetail,	ENVIRONMENT_DETAIL, OPTION_TOOLTIP_ENVIRONMENT_DETAIL, options);
	InitControlSlider(	self.GroundClutter, settingGroundClutter,	GROUND_CLUTTER, OPTION_TOOLTIP_GROUND_CLUTTER, options);

	GraphicsOverrides.AdjustAdvancedQualityControls(self, settings, raid, InitControlDropDown, AddValidatedSettingOption, AddRecommended);
end

SettingsAdvancedQualitySectionMixin = CreateFromMixins(SettingsExpandableSectionMixin);

function SettingsAdvancedQualitySectionMixin:OnLoad()
	self.tabsGroup = CreateRadioButtonGroup();
	self.tabsGroup:AddButtons({self.BaseTab, self.RaidTab});
	self.tabsGroup:SelectAtIndex(1);
	self.tabsGroup:RegisterCallback(ButtonGroupBaseMixin.Event.Selected, self.OnTabSelected, self);

	EventRegistry:RegisterCallback("Settings.CategoryChanged", function()
		self.tabsGroup:SelectAtIndex(1);
	end);
end

function SettingsAdvancedQualitySectionMixin:Init(initializer)
	local data = initializer.data;
	local raid = data.raid;
	local settings = data.settings;
	local raidSettings = data.raidSettings;

	self.cbrHandles = Settings.CreateCallbackHandleContainer();

	self.BaseQualityControls:Init(settings, false, self.cbrHandles);
	self.RaidQualityControls:Init(raidSettings, true, self.cbrHandles);

	self:EvaluateVisibility(self.BaseTab);
end

function SettingsAdvancedQualitySectionMixin:Release(initializer)
	self.cbrHandles:Unregister();
end

function SettingsAdvancedQualitySectionMixin:CalculateHeight()
	local initializer = self:GetElementData();
	return initializer:GetExtent();
end

function SettingsAdvancedQualitySectionMixin:OnTabSelected(tab, tabIndex)
	self:EvaluateVisibility(tab);
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_TAB);
end

function SettingsAdvancedQualitySectionMixin:EvaluateVisibility(tab)
	self.BaseQualityControls:SetShown(tab == self.BaseTab);
	self.RaidQualityControls:SetShown(tab == self.RaidTab);
end

SettingsAdvancedSliderMixin = CreateFromMixins(DefaultTooltipMixin);

function SettingsAdvancedSliderMixin:OnLoad()
	Mixin(self.SliderWithSteppers.Slider, DefaultTooltipMixin);
	DefaultTooltipMixin.OnLoad(self);
	self:SetCustomTooltipAnchoring(self.SliderWithSteppers, "ANCHOR_TOPLEFT", -40, 0);

	self.SliderWithSteppers.Slider:InitDefaultTooltipScriptHandlers();
end

SettingsAdvancedCheckBoxSliderMixin = CreateFromMixins(DefaultTooltipMixin);

function SettingsAdvancedCheckBoxSliderMixin:OnLoad()
	Mixin(self.SliderWithSteppers.Slider, DefaultTooltipMixin);
	DefaultTooltipMixin.OnLoad(self);
	self:SetCustomTooltipAnchoring(self.SliderWithSteppers, "ANCHOR_TOPLEFT", -40, 0);

	self.SliderWithSteppers.Slider:InitDefaultTooltipScriptHandlers();
end

SettingsAdvancedDropdownMixin = CreateFromMixins(DefaultTooltipMixin);

function SettingsAdvancedDropdownMixin:OnLoad()
	DefaultTooltipMixin.OnLoad(self);
	self:SetCustomTooltipAnchoring(self.DropDown, "ANCHOR_TOPLEFT", -40, 0);

	self.DropDown.Button:InitDefaultTooltipScriptHandlers();
end

local SettingsAdvancedQualitySectionInitializer = CreateFromMixins(ScrollBoxFactoryInitializerMixin, SettingsSearchableElementMixin);

function SettingsAdvancedQualitySectionInitializer:GetExtent()
	local reservedHeight = 65;
	local templateHeight = 26;
	local spacing = 10;
	local count = 0;
	for _, setting in pairs(self.data.settings) do
		count = count + 1;
	end
	return reservedHeight + (templateHeight * count) + ((count - 1) * spacing);
end

function CreateAdvancedQualitySectionInitializer(name, settings, raidSettings)
	local initializer = CreateFromMixins(SettingsAdvancedQualitySectionInitializer, SettingsElementHierarchyMixin);
	initializer:Init("SettingsAdvancedQualitySectionTemplate");
	initializer.data = {name=name, settings=settings, raidSettings=raidSettings};
	initializer:AddSearchTags(BASE_GRAPHICS_QUALITY, SETTINGS_RAID_GRAPHICS_QUALITY, SHADOW_QUALITY, LIQUID_DETAIL, PARTICLE_DENSITY, SSAO_LABEL, DEPTH_EFFECTS, COMPUTE_EFFECTS,
		OUTLINE_MODE, TEXTURE_DETAIL, SPELL_DENSITY, PROJECTED_TEXTURES, FARCLIP, ENVIRONMENT_DETAIL, GROUND_CLUTTER);
	return initializer;
end

local function Register()
	if Kiosk.IsEnabled() then
		return;
	end

	local function AddValidatedCVarOption(container, cvar, value, label, tooltip)
		local data = container:Add(value, label, tooltip);
		local error = IsGraphicsCVarValueSupported(cvar, value);
		data.disabled = ErrorMessages[error];
		return data;
	end

	local category, layout = Settings.RegisterVerticalLayoutCategory(GRAPHICS_LABEL);

	-- Monitor
	local monitorSetting = nil;
	do
		local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures("gxMonitor", Settings.VarType.Number);
		local commitValue = setValue;
		local DEFAULT_MONITOR_VALUE = getDefaultValue();
		assert(DEFAULT_MONITOR_VALUE == 0);

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();

			local name = GetMonitorName(DEFAULT_MONITOR_VALUE + 1) or VIDEO_OPTIONS_MONITOR_PRIMARY;
			container:Add(DEFAULT_MONITOR_VALUE, name);

			for index = 2, GetMonitorCount() do
				local value = index - 1;
				local label = GetMonitorName(index) or string.format(VIDEO_OPTIONS_MONITOR, value);
				container:Add(value, label);
			end
			return container:GetData();
		end

		monitorSetting = Settings.RegisterProxySetting(category, "PROXY_PRIMARY_MONITOR", Settings.DefaultVarLocation,
			Settings.VarType.Number, PRIMARY_MONITOR, DEFAULT_MONITOR_VALUE, getValue, nil, commitValue);
		monitorSetting:SetCommitFlags(Settings.CommitFlag.Apply, Settings.CommitFlag.UpdateWindow, Settings.CommitFlag.Revertable);

		Settings.CreateDropDown(category, monitorSetting, GetOptions, OPTION_TOOLTIP_PRIMARY_MONITOR);

		local function UpdateSettingFromCVar()
			monitorSetting:SetValue(getValue());
		end
		CVarCallbackRegistry:RegisterCallback("gxMonitor", UpdateSettingFromCVar);
	end

	-- Display Mode
	local displayModeSetting = nil;
	do
		local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures("gxMaximize", Settings.VarType.Boolean);
		local commitValue = setValue;

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(true, VIDEO_OPTIONS_WINDOWED_FULLSCREEN);
			container:Add(false, VIDEO_OPTIONS_WINDOWED);
			return container:GetData();
		end

		displayModeSetting = Settings.RegisterProxySetting(category, "PROXY_DISPLAY_MODE", Settings.DefaultVarLocation,
			Settings.VarType.Boolean, DISPLAY_MODE, getDefaultValue(), getValue, nil, commitValue);
		displayModeSetting:SetCommitFlags(Settings.CommitFlag.Apply, Settings.CommitFlag.UpdateWindow, Settings.CommitFlag.Revertable);
		Settings.CreateDropDown(category, displayModeSetting, GetOptions, OPTION_TOOLTIP_DISPLAY_MODE);
	end

	-- Perf. May invalidate on device change.
	local cachedResolutions = {};
	local function GetGameWindowSizes(monitor, fullscreen)
		if not cachedResolutions[monitor] then
			cachedResolutions[monitor] = {};
		end

		if not cachedResolutions[monitor][fullscreen] then
			cachedResolutions[monitor][fullscreen] = C_VideoOptions.GetGameWindowSizes(monitor, fullscreen);
		end

		return cachedResolutions[monitor][fullscreen];
		-- Breaks custom res in dropdown, but we probably wont use it.
		--return C_VideoOptions.GetGameWindowSizes(monitor, fullscreen);
	end

	-- Resolution
	local resolutionSetting = nil;
	local resolutionInitializer = nil;
	do
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			local monitor = monitorSetting:GetValue();
			local fullscreen = displayModeSetting:GetValue();

			if fullscreen then
				local autoSizeValue = FormatScreenResolution(0, 0);
				container:Add(autoSizeValue, DEFAULT);
			end

			local sizes = GetGameWindowSizes(monitor, fullscreen);
			for index, size in ipairs(sizes) do
				local value = FormatScreenResolution(size.x, size.y);
				container:Add(value, value);
			end
			return container:GetData();
		end

		local function GetValue()
			local monitor = monitorSetting:GetValue();
			local fullscreen = displayModeSetting:GetValue();
			local size = C_VideoOptions.GetCurrentGameWindowSize(monitor, fullscreen);
			local value = FormatScreenResolution(size.x, size.y);
			return value;
		end

		local function CommitValue(value)
			local x, y = ExtractSizeFromFormattedSize(value);
			C_VideoOptions.SetGameWindowSize(x, y);
		end

		local defaultValue = FormatScreenResolution(0,0);
		resolutionSetting = Settings.RegisterProxySetting(category, "PROXY_RESOLUTION", Settings.DefaultVarLocation,
			Settings.VarType.String, WINDOW_SIZE, defaultValue, GetValue, nil, CommitValue);
		resolutionSetting:SetCommitFlags(Settings.CommitFlag.Apply, Settings.CommitFlag.UpdateWindow, Settings.CommitFlag.Revertable);
		resolutionSetting:SetCommitOrder(1);

		resolutionInitializer = Settings.CreateDropDown(category, resolutionSetting, GetOptions, OPTION_TOOLTIP_WINDOW_SIZE);
		CreateSettingsSelectionCustomSelectedData(resolutionInitializer.data, CUSTOM);
		resolutionInitializer.reinitializeOnValueChanged = true;
		resolutionInitializer.skipAssertMissingOption = true;

		local function OnDisplayModeValueChanged(o, s, value)
			if value then
				resolutionSetting:ReinitializeValue(defaultValue);
			else
				local newValue = GetValue();
				resolutionSetting:ReinitializeValue(newValue);
			end
		end;
		Settings.SetOnValueChangedCallback(displayModeSetting:GetVariable(), OnDisplayModeValueChanged);

		local function OnMonitorValueChanged(o, s, value)
			local newValue = GetValue();
			resolutionSetting:ReinitializeValue(newValue);
		end;
		Settings.SetOnValueChangedCallback(monitorSetting:GetVariable(), OnMonitorValueChanged);
	end

	-- Resolution/Render Scale
	do
		local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures("RenderScale", Settings.VarType.Number);
		local commitValue = setValue;
		local setting = Settings.RegisterProxySetting(category, "PROXY_RESOLUTION_RENDER_SCALE", Settings.DefaultVarLocation,
			Settings.VarType.Number, RENDER_SCALE, getDefaultValue(), getValue, nil, commitValue);
		setting:SetCommitFlags(Settings.CommitFlag.Apply);

		local function FormatDisplayableResolution(value)
			local x, y = ExtractSizeFromFormattedSize(resolutionSetting:GetValue());
			if x == 0 or y == 0 then
				local size = C_VideoOptions.GetDefaultGameWindowSize(monitorSetting:GetValue());
				x, y = size.x, size.y;
			end
			return FormatScreenResolution(x * value, y * value);
		end

		local function RenderScaleFormat(value)
			return string.format("%s (%s)", FormatDisplayableResolution(value), FormatPercentage(value));
		end

		local minValue, maxValue = GetMinRenderScale(), GetMaxRenderScale();
		local options = Settings.CreateSliderOptions(minValue, maxValue);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, RenderScaleFormat);

		local initializer = Settings.CreateSlider(category, setting, options, OPTION_TOOLTIP_RENDER_SCALE);
		initializer:SetParentInitializer(resolutionInitializer);
		initializer.reinitializeOnValueChanged = true;

		local function OnValueChanged(o, s, value)
			-- We're leveraging the setting value changed event to force the slider to update as the resolution is changed.
			setting:ReinitializeValue(setting:GetValue());
		end;
		Settings.SetOnValueChangedCallback(resolutionSetting:GetVariable(), OnValueChanged);
	end

	-- Vertical Sync
	do
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(false, VIDEO_OPTIONS_DISABLED);
			container:Add(true, VIDEO_OPTIONS_ENABLED);
			return container:GetData();
		end

		local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures("vsync", Settings.VarType.Boolean);
		local commitValue = setValue;
		local setting = Settings.RegisterProxySetting(category, "PROXY_VERTICAL_SYNC", Settings.DefaultVarLocation,
			Settings.VarType.Boolean, VERTICAL_SYNC, getDefaultValue(), getValue, nil, commitValue);
		setting:SetCommitFlags(Settings.CommitFlag.Apply, Settings.CommitFlag.UpdateWindow);

		Settings.CreateDropDown(category, setting, GetOptions, OPTION_TOOLTIP_VERTICAL_SYNC);
	end

	-- Notch Mode
	if (C_UI.DoesAnyDisplayHaveNotch()) then
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(0, NOTCH_MODE_OVERLAP, VIDEO_OPTIONS_NOTCH_MODE_OVERLAP);
			container:Add(1, NOTCH_MODE_SHIFT_UI, VIDEO_OPTIONS_NOTCH_MODE_SHIFT_UI);
			container:Add(2, NOTCH_MODE_WINDOW_BELOW, VIDEO_OPTIONS_NOTCH_MODE_WINDOW_BELOW);

			return container:GetData();
		end

		local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures("NotchedDisplayMode", Settings.VarType.Number);
		local commitValue = setValue;
		local setting = Settings.RegisterProxySetting(category, "PROXY_NOTCHED_DISPLAY_MODE", Settings.DefaultVarLocation,
			Settings.VarType.Number, NOTCH_MODE, getDefaultValue(), getValue, nil, commitValue);
		setting:SetCommitFlags(Settings.CommitFlag.Apply, Settings.CommitFlag.UpdateWindow);

		Settings.CreateDropDown(category, setting, GetOptions, OPTION_TOOLTIP_NOTCH_MODE);
	end

	-- Low Latency Mode
	do
		local cvar = "LowLatencyMode";

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			AddValidatedCVarOption(container, cvar, 0, VIDEO_OPTIONS_DISABLED);
			AddValidatedCVarOption(container, cvar, 1, VIDEO_OPTIONS_BUILTIN);
			AddValidatedCVarOption(container, cvar, 2, VIDEO_OPTIONS_NVIDIA_REFLEX);
			AddValidatedCVarOption(container, cvar, 3, VIDEO_OPTIONS_NVIDIA_REFLEX_BOOST);
			return container:GetData();
		end

		Settings.SetupCVarDropDown(category, cvar, Settings.VarType.Number, GetOptions, LOW_LATENCY_MODE, OPTION_TOOLTIP_LOW_LATENCY_MODE);
	end

	do
		local function SplitMSAA(msaa)
			local msaa, coverage = strsplit(",", msaa);
			return tonumber(msaa), coverage or 0;
		end

		local function SplitMSAACVar()
			return SplitMSAA(GetCVar("MSAAQuality"));
		end

		local AA_NONE = 0;
		local AA_IMAGE = 1;
		local AA_MULTISAMPLE = 2;
		local AA_ADVANCED = 3;

		-- Antialiasing
		local aaSettings = {};
		local aaSetting = nil;
		local aaInitializer = nil;
		do
			local function GetValue()
				local fxaa = tonumber(GetCVar("ffxAntiAliasingMode"));
				local msaa, coverage = SplitMSAACVar();
				if fxaa == 0 and msaa == 0 then
					return AA_NONE;
				elseif fxaa > 0 and msaa == 0 then
					return AA_IMAGE;
				elseif fxaa == 0 and msaa > 0 then
					return AA_MULTISAMPLE;
				elseif fxaa > 0 and msaa > 0 then
					return 3;
				end
			end

			local function SetValue(value)
				if value == AA_NONE then
					aaSettings.fxaa:SetValue(0);
					aaSettings.msaa:SetValue(0);
				elseif value == AA_IMAGE then
					aaSettings.msaa:SetValue(0);
				elseif value == AA_MULTISAMPLE then
					aaSettings.fxaa:SetValue(0);
				end
			end

			local function GetOptions()
				local container = Settings.CreateControlTextContainer();
				container:Add(AA_NONE, VIDEO_OPTIONS_NONE);
				container:Add(AA_IMAGE, FXAA_CMAA_LABEL);
				container:Add(AA_MULTISAMPLE, MSAA_LABEL);
				container:Add(AA_ADVANCED, ADVANCED_LABEL);
				return container:GetData();
			end

			local defaultValue = AA_NONE;
			aaSetting = Settings.RegisterProxySetting(category, "PROXY_ANTIALIASING", Settings.DefaultVarLocation,
				Settings.VarType.Number, ANTIALIASING, defaultValue, GetValue, SetValue);
			aaSetting:SetCommitFlags(Settings.CommitFlag.Apply);

			aaInitializer = Settings.CreateDropDown(category, aaSetting, GetOptions, OPTION_TOOLTIP_ANTIALIASING);
		end

		-- Image Based
		do
			local function GetOptions()
				local container = Settings.CreateControlTextContainer();
				container:Add(0, VIDEO_OPTIONS_NONE);
				container:Add(1, ANTIALIASING_FXAA_LOW);
				container:Add(2, ANTIALIASING_FXAA_HIGH);
				local fxaa, cmaa, cmaa2 = AntiAliasingSupported();
				if cmaa then
					container:Add(3, ANTIALIASING_CMAA);
				end
				if cmaa2 then
					container:Add(4, ANTIALIASING_CMAA2);
				end
				return container:GetData();
			end

			local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures("ffxAntiAliasingMode", Settings.VarType.Number);
			local commitValue = setValue;
			local setting = Settings.RegisterProxySetting(category, "PROXY_FXAA", Settings.DefaultVarLocation,
				Settings.VarType.Number, FXAA_CMAA_LABEL, getDefaultValue(), getValue, nil, commitValue);
			setting:SetCommitFlags(Settings.CommitFlag.Apply);
			aaSettings.fxaa = setting;

			local initializer = Settings.CreateDropDown(category, setting, GetOptions, OPTION_TOOLTIP_ANTIALIASING_FXAA);
			local function IsModifiable()
				local value = aaSetting:GetValue();
				return value == AA_IMAGE or value == AA_ADVANCED;
			end
			initializer:SetParentInitializer(aaInitializer, IsModifiable);
		end

		-- Multisample
		do

			local function GetValue()
				local msaa, coverage = SplitMSAACVar();
				return msaa;
			end

			local function CommitValue(value)
				SetCVar("MSAAQuality", value);
			end

			local function GetOptions()
				local container = Settings.CreateControlTextContainer();
				container:Add(0, VIDEO_OPTIONS_NONE);

				local function GenerateMSAAOptions(container, ...)
					for i = 1, select("#", ...), 3 do
						local msaaQuality, sampleCount, coverageCount = select(i, ...);
						local value = SplitMSAA(msaaQuality);
						local label = ADVANCED_ANTIALIASING_MSAA_FORMAT:format(sampleCount, coverageCount);
						container:Add(value, label);
					end
				end

				GenerateMSAAOptions(container, MultiSampleAntiAliasingSupported());
				return container:GetData();
			end

			local defaultValue = 0;
			local setting = Settings.RegisterProxySetting(category, "PROXY_MSAA", Settings.DefaultVarLocation,
				Settings.VarType.Number, MSAA_LABEL, defaultValue, GetValue, nil, CommitValue);
			setting:SetCommitFlags(Settings.CommitFlag.Apply);
			aaSettings.msaa = setting;

			local initializer = Settings.CreateDropDown(category, setting, GetOptions, OPTION_TOOLTIP_ADVANCED_MSAA);
			local function IsModifiable()
				local value = aaSetting:GetValue();
				return value == AA_MULTISAMPLE or value == AA_ADVANCED;
			end
			initializer:SetParentInitializer(aaInitializer, IsModifiable);
		end

		-- Multisample Alpha Test
		do
			local cvar = "msaaAlphaTest";
			local normalScale = 1.0;
			local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures(cvar, Settings.VarType.Boolean);
			local commitValue = setValue;
			local setting = Settings.RegisterProxySetting(category, "PROXY_MSAA_ALPHA", Settings.DefaultVarLocation,
				Settings.VarType.Boolean, MULTISAMPLE_ALPHA_TEST, getDefaultValue(), getValue, nil, commitValue);
			setting:SetCommitFlags(Settings.CommitFlag.Apply);
			aaSettings.msaaAlpha = setting;

			local function GetOptions()
				local container = Settings.CreateControlTextContainer();
				AddValidatedCVarOption(container, cvar, 0, VIDEO_OPTIONS_DISABLED);
				AddValidatedCVarOption(container, cvar, 1, VIDEO_OPTIONS_ENABLED);
				return container:GetData();
			end

			local initializer = Settings.CreateCheckBoxWithOptions(category, setting, GetOptions, OPTION_TOOLTIP_MULTISAMPLE_ALPHA_TEST);
			local function IsModifiable()
				local value = aaSetting:GetValue();
				return value == AA_MULTISAMPLE or value == AA_ADVANCED;
			end
			initializer:SetParentInitializer(aaInitializer, IsModifiable);
		end
	end

	-- Camera FOV
	if C_CVar.GetCVar("cameraFov") then
		do
			local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures("cameraFov", Settings.VarType.Number);
			local commitValue = setValue;
			local _, minValue, maxValue = GetCameraFOVDefaults();
			local setting = Settings.RegisterProxySetting(category, "PROXY_CAMERA_FOV", Settings.DefaultVarLocation,
				Settings.VarType.Number, CAMERA_FOV, getDefaultValue(), getValue, nil, commitValue);
			setting:SetCommitFlags(Settings.CommitFlag.Apply);

			local step = 5;
			local options = Settings.CreateSliderOptions(minValue, maxValue, step);
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
			Settings.CreateSlider(category, setting, options, OPTION_TOOLTIP_CAMERA_FOV);
		end
	end

	local function FormatPercentageRounded(value)
		local roundToNearestInteger = true;
		return FormatPercentage(value, roundToNearestInteger);
	end

	-- UI Scale
	if not IsOnGlueScreen() then
		do
			-- Use UI Scale
			local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures("useUiScale", Settings.VarType.Boolean);
			local commitValue = setValue;
			local useUIScaleSetting = Settings.RegisterProxySetting(category, "PROXY_USE_UI_SCALE", Settings.DefaultVarLocation,
				Settings.VarType.Boolean, RENDER_SCALE, getDefaultValue(), getValue, nil, commitValue);
			useUIScaleSetting:SetCommitFlags(Settings.CommitFlag.Apply, Settings.CommitFlag.Revertable);

			-- Resolution Scale
			local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures("uiscale", Settings.VarType.Number);
			local commitValue = setValue;
			local uiScaleSliderSetting = Settings.RegisterProxySetting(category, "PROXY_UI_SCALE", Settings.DefaultVarLocation,
				Settings.VarType.Number, RENDER_SCALE, getDefaultValue(), getValue, nil, commitValue);
			uiScaleSliderSetting:SetCommitFlags(Settings.CommitFlag.Apply, Settings.CommitFlag.Revertable);

			local minValue, maxValue, step = .65, 1.15, .01;
			local options = Settings.CreateSliderOptions(minValue, maxValue, step);
			options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatPercentageRounded)

			local initializer = CreateSettingsCheckBoxSliderInitializer(
				useUIScaleSetting, USE_UISCALE, OPTION_TOOLTIP_USE_UISCALE,
				uiScaleSliderSetting, options, UI_SCALE, OPTION_TOOLTIP_UI_SCALE);
			initializer:AddSearchTags(USE_UISCALE, UI_SCALE);
			layout:AddInitializer(initializer);
		end
	end

	-- Graphics Quality
	function AddAdvancedQualitySetting(settings, category, cvar, name, proxyName, minQualityValue)
		settings[cvar] = CreateAdvancedQualitySetting(category, cvar, name, proxyName, minQualityValue);
	end

	local advSettings = GraphicsOverrides.CreateAdvancedSettingsTable(category, AddAdvancedQualitySetting);
	local advRaidSettings = GraphicsOverrides.CreateAdvancedRaidSettingsTable(category, AddAdvancedQualitySetting);

	local raidSetting = Settings.RegisterCVarSetting(category, RaidSettingsEnabledCVar, Settings.VarType.Boolean, RAID_SETTINGS_ENABLED);
	local raidGraphicsSetting = Settings.GetSetting("PROXY_RAID_GRAPHICS_QUALITY");
	-- Graphics setting must be applied last to prevent the OnGCChanged callback from
	-- overwriting any child settings that have yet to been applied.
	raidGraphicsSetting:SetCommitOrder(1);

	local advInitializer = CreateAdvancedQualitySectionInitializer(GRAPHICS_QUALITY, advSettings, advRaidSettings);
	layout:AddInitializer(advInitializer);

	local function OnGCChanged(settings, value, raid)
		for cvar, setting in pairs(settings) do
			local variable = setting:GetVariable();
			if cvar ~= "graphicsQuality" and cvar ~= "raidGraphicsQuality" then
				local newIndex = GetGraphicsCVarValueForQualityLevel(cvar, value, raid);
				newIndex = setting.minQualityValue > newIndex and setting.minQualityValue or newIndex;
				setting:SetValue(newIndex);
			end
		end
	end;

	local graphicsSetting = Settings.GetSetting("PROXY_GRAPHICS_QUALITY");
	-- Graphics setting must be applied last to prevent the OnGCChanged callback from
	-- overwriting any child settings that have yet to been applied.
	graphicsSetting:SetCommitOrder(1);

	local function OnGraphicsQualityChanged(o, s, value)
		local raid = false;
		OnGCChanged(advSettings, value, raid);
	end;

	Settings.SetOnValueChangedCallback(graphicsSetting:GetVariable(), OnGraphicsQualityChanged);

	local function OnRaidGraphicsQualityChanged(o, s, value)
		local raid = true;
		OnGCChanged(advRaidSettings, value, raid);
	end;
	Settings.SetOnValueChangedCallback(raidGraphicsSetting:GetVariable(), OnRaidGraphicsQualityChanged);

	-- Advanced
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(ADVANCED_LABEL));

	-- Triple Buffering
	do
		local FRAME_LATENCY_DISABLED = 2;
		local FRAME_LATENCY_ENABLED = 3;
		local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures("gxMaxFrameLatency", Settings.VarType.Number);

		local function GetValue()
			return getValue() == FRAME_LATENCY_ENABLED;
		end

		local SetValue = nil;

		local function CommitValue(value)
			setValue(value and FRAME_LATENCY_ENABLED or FRAME_LATENCY_DISABLED);
		end

		local defaultValue = true;
		local setting = Settings.RegisterProxySetting(category, "PROXY_TRIPLE_BUFFERING", Settings.DefaultVarLocation,
			Settings.VarType.Boolean, TRIPLE_BUFFER, defaultValue, GetValue, SetValue, CommitValue);
		setting:SetCommitFlags(Settings.CommitFlag.Apply, Settings.CommitFlag.GxRestart);
		Settings.CreateCheckBox(category, setting, OPTION_TOOLTIP_TRIPLE_BUFFER);
	end

	-- Texture Filtering
	do
		local cvar = "textureFilteringMode";

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			AddValidatedCVarOption(container, cvar, 0, VIDEO_OPTIONS_BILINEAR);
			AddValidatedCVarOption(container, cvar, 1, VIDEO_OPTIONS_TRILINEAR);
			AddValidatedCVarOption(container, cvar, 2, VIDEO_OPTIONS_2XANISOTROPIC);
			AddValidatedCVarOption(container, cvar, 3, VIDEO_OPTIONS_4XANISOTROPIC);
			AddValidatedCVarOption(container, cvar, 4, VIDEO_OPTIONS_8XANISOTROPIC);
			AddValidatedCVarOption(container, cvar, 5, VIDEO_OPTIONS_16XANISOTROPIC);
			return container:GetData();
		end

		Settings.SetupCVarDropDown(category, cvar, Settings.VarType.Number, GetOptions, ANISOTROPIC, OPTION_TOOLTIP_ANISOTROPIC);
	end

	-- Ray Traced Shadows
	do
		local cvar = "shadowrt";

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			AddValidatedCVarOption(container, cvar, 0, VIDEO_OPTIONS_DISABLED);
			AddValidatedCVarOption(container, cvar, 1, VIDEO_OPTIONS_FAIR, VIDEO_OPTIONS_RT_SHADOW_QUALITY_FAIR);
			AddValidatedCVarOption(container, cvar, 2, VIDEO_OPTIONS_MEDIUM, VIDEO_OPTIONS_RT_SHADOW_QUALITY_MEDIUM);
			AddValidatedCVarOption(container, cvar, 3, VIDEO_OPTIONS_HIGH, VIDEO_OPTIONS_RT_SHADOW_QUALITY_HIGH);
			return container:GetData();
		end

		Settings.SetupCVarDropDown(category, cvar, Settings.VarType.Number, GetOptions, RT_SHADOW_QUALITY, OPTION_TOOLTIP_RT_SHADOW_QUALITY);
	end

	-- Ambient Occlusion Type
	do
		local cvar = "ResolvedSSAOType";

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			AddValidatedCVarOption(container, cvar, 0, GX_ADAPTER_AUTO_DETECT);
			AddValidatedCVarOption(container, cvar, 1, SSAO_TYPE_ASSAO);
			AddValidatedCVarOption(container, cvar, 2, SSAO_TYPE_CACAO);
			return container:GetData();
		end

		Settings.SetupCVarDropDown(category, cvar, Settings.VarType.Number, GetOptions, SSAO_TYPE_LABEL, OPTION_TOOLTIP_SSAO);
	end

	-- Resample Quality
	do
		local cvar = "ResampleQuality";

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(0, RESAMPLE_QUALITY_POINT, VIDEO_OPTIONS_RESAMPLE_QUALITY_POINT);
			container:Add(1, RESAMPLE_QUALITY_BILINEAR, VIDEO_OPTIONS_RESAMPLE_QUALITY_BILINEAR);
			container:Add(2, RESAMPLE_QUALITY_BICUBIC, VIDEO_OPTIONS_RESAMPLE_QUALITY_BICUBIC);
			container:Add(3, RESAMPLE_QUALITY_FSR, VIDEO_OPTIONS_RESAMPLE_QUALITY_FSR);
			return container:GetData();
		end

		Settings.SetupCVarDropDown(category, cvar, Settings.VarType.Number, GetOptions, RESAMPLE_QUALITY, OPTION_TOOLTIP_RESAMPLE_QUALITY);
	end

	-- Variable Rate Shading (VRS)
	do
		local cvar = "vrsValar";

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			AddValidatedCVarOption(container, cvar, 0, VIDEO_OPTIONS_DISABLED);
			AddValidatedCVarOption(container, cvar, 1, VIDEO_OPTIONS_STANDARD, OPTION_TOOLTIP_VRS_STANDARD);
			AddValidatedCVarOption(container, cvar, 2, VIDEO_OPTIONS_AGGRESSIVE, OPTION_TOOLTIP_VRS_AGGRESSIVE);
			return container:GetData();
		end

		Settings.SetupCVarDropDown(category, cvar, Settings.VarType.Number, GetOptions, VRS_MODE, OPTION_TOOLTIP_VRS_MODE);
	end

	-- Graphics API
	do
		-- here, CVar("gxapi") refers to the current requested api

		local apis = {GetGraphicsAPIs()};
		for index, api in ipairs(apis) do
			apis[index] = string.lower(api);
		end

		local function GetValue()
			local gxapi = string.lower(GetCVar("gxapi"));
			local found = tIndexOf(apis, gxapi);
			return apis[found or #apis];
		end

		local SetValue = nil;

		local function CommitValue(value)
			SetCVar("gxapi", value);
		end

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			local currentApiCvar = GetCurrentGraphicsAPI();
			local requestedApi = GetCVar("gxapi");
			for index, api in ipairs(apis) do

				local tooltip = nil;
				local name =  _G["GXAPI_"..strupper(api)];

				if (strupper(api) == strupper("auto")) then
					if (strupper(api) == strupper(requestedApi)) then
						tooltip = GXAPI_TOOLTIP_AUTO_SELECTED; --"Selected Graphics API. Auto-detect best available Graphics API.";
					--else
						--Omitting as the tooltip appears un-necessarily verbose
						--tooltip = GXAPI_TOOLTIP_AUTO; --"Auto-detect best available Graphics API."
					end
				elseif (strupper(api) == strupper(currentApiCvar)) then
					tooltip = GXAPI_TOOLTIP_CURRENT_API; --"Current Graphics API.";
				elseif (strupper(api) == strupper(requestedApi) and strupper(api) ~= strupper("auto")) then
					tooltip = GXAPI_TOOLTIP_FAILED_SELECTED; --"Selected Graphics API. Failed to load, next attempt of restart.";
				end

				if (nil == name) then
					DeveloperConsole:AddMessage("GXAPI_"..strupper(api).." not found");
				elseif (nil == tooltip) then
					container:Add(api, name);
				else
					container:Add(api, name, tooltip);
				end

			end
			return container:GetData();
		end

		local defaultValue = apis[#apis];
		local setting = Settings.RegisterProxySetting(category, "PROXY_GRAPHICS_API", Settings.DefaultVarLocation,
			Settings.VarType.String, GXAPI, defaultValue, GetValue, SetValue, CommitValue);
		setting:SetCommitFlags(Settings.CommitFlag.Apply, Settings.CommitFlag.GxRestart);

		-- Mike A note, CVar callbacks do not work in the start-screen menu, so need the more focused approach
		-- of watching for a GX_RESTARTED event.
		-- Note, a restart triggerred from the console will not effect the state of the Apply flag.
		local function OnGxRestart(self, addonName, showTool)
			setting:SetValue(GetValue());
		end

		EventRegistry:RegisterFrameEvent("GX_RESTARTED");
		EventRegistry:RegisterCallback("GX_RESTARTED", OnGxRestart);

		Settings.CreateDropDown(category, setting, GetOptions, OPTION_TOOLTIP_GXAPI);
	end

	-- Physics Interaction
	if C_CVar.GetCVar("physicsLevel") then
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(0, NO_ENVIRONMENT_INTERACTION);
			container:Add(1, PLAYER_ONLY_INTERACTION);
			container:Add(2, PLAYER_AND_NPC_INTERACTION);
			return container:GetData();
		end

		local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures("physicsLevel", Settings.VarType.Number);
		local commitValue = setValue;
		local setting = Settings.RegisterProxySetting(category, "PROXY_PHYSICS_LEVEL", Settings.DefaultVarLocation,
			Settings.VarType.Number, PHYSICS_INTERACTION, getDefaultValue(), getValue, nil, commitValue);
		setting:SetCommitFlags(Settings.CommitFlag.ClientRestart);

		Settings.CreateDropDown(category, setting, GetOptions, OPTION_PHYSICS_OPTIONS);
	end

	-- Graphics Card
	do
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add("", GX_ADAPTER_AUTO_DETECT);

			for index, adapter in ipairs(C_VideoOptions.GetGxAdapterInfo()) do
				local name = nil;
				if ( adapter.isExternal ) then
					name = string.format(GX_ADAPTER_EXTERNAL, adapter.name);
				elseif ( adapter.isLowPower ) then
					name = string.format(GX_ADAPTER_LOW_POWER, adapter.name);
				else
					name = adapter.name;
				end
				container:Add(adapter.name, name);
			end

			return container:GetData();
		end

		local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures("gxAdapter", Settings.VarType.String);
		local commitValue = setValue;
		local setting = Settings.RegisterProxySetting(category, "PROXY_GX_ADAPTER", Settings.DefaultVarLocation,
			Settings.VarType.String, GRAPHICS_CARD, getDefaultValue(), getValue, nil, commitValue);
		setting:SetCommitFlags(Settings.CommitFlag.Apply, Settings.CommitFlag.GxRestart);

		Settings.CreateDropDown(category, setting, GetOptions, OPTION_TOOLTIP_GRAPHICS_CARD);
	end

	local function FormatFPS(value)
		return SETTINGS_FMT_FPS:format(value);
	end

	-- Max foreground FPS
	do
		local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures("useMaxFPS", Settings.VarType.Boolean);
		local fpsSetting = Settings.RegisterProxySetting(category, "PROXY_FOREGROUND_FPS_ENABLED", Settings.DefaultVarLocation,
			Settings.VarType.Boolean, MAXFPS_CHECK, getDefaultValue(), getValue, setValue);

		local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures("maxFPS", Settings.VarType.Number);
		local commitValue = setValue;
		local fpsSliderSetting = Settings.RegisterProxySetting(category, "PROXY_FOREGROUND_FPS", Settings.DefaultVarLocation,
			Settings.VarType.Number, MAXFPS, getDefaultValue(), getValue, nil, commitValue);

		local minValue, maxValue, step = 8, 200, 1;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatFPS);

		local initializer = CreateSettingsCheckBoxSliderInitializer(
			fpsSetting, MAXFPS, OPTION_MAXFPS_CHECK,
			fpsSliderSetting, options, MAXFPS, OPTION_MAXFPS_CHECK);
		initializer:AddSearchTags(MAXFPS);
		layout:AddInitializer(initializer);
	end

	-- Max background FPS
	do
		local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures("useMaxFPSBk", Settings.VarType.Boolean);
		local fpsSetting = Settings.RegisterProxySetting(category, "PROXY_BACKGROUND_FPS_ENABLED", Settings.DefaultVarLocation,
			Settings.VarType.Boolean, MAXFPSBK_CHECK, getDefaultValue(), getValue, setValue);

		local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures("maxFPSBk", Settings.VarType.Number);
		local commitValue = setValue;
		local fpsSliderSetting = Settings.RegisterProxySetting(category, "PROXY_BACKGROUND_FPS", Settings.DefaultVarLocation,
			Settings.VarType.Number, MAXFPSBK, getDefaultValue(), getValue, nil, commitValue);

		local minValue, maxValue, step = 8, 200, 1;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatFPS);

		local initializer = CreateSettingsCheckBoxSliderInitializer(
			fpsSetting, MAXFPSBK, OPTION_MAXFPSBK_CHECK,
			fpsSliderSetting, options, MAXFPSBK, OPTION_MAXFPSBK_CHECK);
		initializer:AddSearchTags(MAXFPSBK);
		layout:AddInitializer(initializer);
	end

	-- Max Target FPS
	do
		local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures("useTargetFPS", Settings.VarType.Boolean);
		local fpsSetting = Settings.RegisterProxySetting(category, "PROXY_TARGET_FPS_ENABLED", Settings.DefaultVarLocation,
			Settings.VarType.Boolean, TARGETFPS, getDefaultValue(), getValue, setValue);

		local getValue, setValue, getDefaultValue = Settings.CreateCVarAccessorClosures("targetFPS", Settings.VarType.Number);
		local commitValue = setValue;
		local fpsSliderSetting = Settings.RegisterProxySetting(category, "PROXY_TARGET_FPS", Settings.DefaultVarLocation,
			Settings.VarType.Number, TARGETFPS, getDefaultValue(), getValue, nil, commitValue);

		local minValue, maxValue, step = 8, 200, 1;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatFPS);

		local initializer = CreateSettingsCheckBoxSliderInitializer(
			fpsSetting, TARGETFPS, OPTION_TARGETFPS_CHECK,
			fpsSliderSetting, options, TARGETFPS, OPTION_TARGETFPS_CHECK);
		layout:AddInitializer(initializer);
	end

	local function FormatScaledPercentage(value)
		return FormatPercentage(value/100);
	end

	local function RoundToOneTenth(value)
		return RoundToSignificantDigits(value, 1);
	end

	-- Resample Sharpness
	do
		local minValue, maxValue, step = 0.0, 2.0, .1;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);

		-- Override formatter, getValue, setValue, defaultValue to reverse the bar direction
		-- so that the maxValue is on the left and the minValue is on the right, by subtracting value from maxValue.
		local function RoundToOneTenthReversed(value)
			return RoundToOneTenth(maxValue - value);
		end

		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, RoundToOneTenthReversed);

		local cvar = "ResampleSharpness";
		local getValue, setValue = Settings.CreateCVarAccessorClosures(cvar, Settings.VarType.Number);

		local getValueReversed = function() return maxValue - getValue(); end;
		local commitValueReversed = function(value) return setValue(maxValue - value) end;
		local defaultValueReversed = maxValue - tonumber(GetCVarDefault(cvar));

		local setting = Settings.RegisterProxySetting(category, "PROXY_RESAMPLE_SHARPNESS", Settings.DefaultVarLocation,
			Settings.VarType.Number, RESAMPLE_SHARPNESS, defaultValueReversed, getValueReversed, nil, commitValueReversed);

		Settings.CreateSlider(category, setting, options, OPTION_TOOLTIP_SHARPNESS);
	end

	-- Contrast
	do
		local minValue, maxValue, step = 0, 100, 1;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatScaledPercentage);
		Settings.SetupCVarSlider(category, "Contrast", options, OPTION_CONTRAST, OPTION_TOOLTIP_CONTRAST);
	end

	-- Brightness
	do
		local minValue, maxValue, step = 0, 100, 1;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatScaledPercentage);
		Settings.SetupCVarSlider(category, "Brightness", options, OPTIONS_BRIGHTNESS, OPTION_TOOLTIP_BRIGHTNESS);
	end

	-- Gamma
	do
		local minValue, maxValue, step = .3, 2.8, .1;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, RoundToOneTenth);
		Settings.SetupCVarSlider(category, "Gamma", options, GAMMA, OPTION_TOOLTIP_GAMMA);
	end

	do
		local monitorCVar = CreateCVarAccessor("gxMonitor", Settings.VarType.Number);
		local displayModeCVar = CreateCVarAccessor("gxMaximize", Settings.VarType.Boolean);
		local listener = Mixin(CreateFrame("Frame"));
		listener:RegisterEvent("DISPLAY_SIZE_CHANGED");
		listener:SetScript("OnEvent", function(self, event, ...)
			if event == "DISPLAY_SIZE_CHANGED" then
				local resSetting = Settings.GetSetting("PROXY_RESOLUTION");
				local resScaleSetting = Settings.GetSetting("PROXY_RESOLUTION_RENDER_SCALE");
				resSetting:SetIgnoreApplyOverride(true);
				resScaleSetting:SetIgnoreApplyOverride(true);

				local size = C_VideoOptions.GetCurrentGameWindowSize(monitorCVar:GetValue(), displayModeCVar:GetValue());
				Settings.SetValue("PROXY_RESOLUTION", FormatScreenResolution(size.x, size.y));

				resSetting:SetIgnoreApplyOverride(false);
				resScaleSetting:SetIgnoreApplyOverride(false);
			end
		end);
	end

	Settings.RegisterCategory(category, SETTING_GROUP_SYSTEM);
end

SettingsRegistrar:AddRegistrant(Register);