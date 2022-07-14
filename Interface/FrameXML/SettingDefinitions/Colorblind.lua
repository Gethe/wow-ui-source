ColorblindSelectorMixin = {};

function ColorblindSelectorMixin:OnLoad()
	local qualityIDs = 
	{
		Enum.ItemQuality.Uncommon,
		Enum.ItemQuality.Rare,
		Enum.ItemQuality.Epic,
		Enum.ItemQuality.Legendary,
		Enum.ItemQuality.Heirloom,
	};
	for index, qualityID in ipairs(qualityIDs) do
		local itemQuality = self.ColorblindExamples.ItemQualities[index];
		itemQuality:SetText(_G["ITEM_QUALITY"..qualityID.."_DESC"]);
		itemQuality:SetTextColor(ITEM_QUALITY_COLORS[qualityID].color:GetRGB());
	end

	self.cbrHandles = Settings.CreateCallbackHandleContainer();
end

function ColorblindSelectorMixin:Init(initializer)
	local settings = initializer.data.settings;
	
	local function GetOptions()
		local container = Settings.CreateDropDownTextContainer();
		container:Add(0, COLORBLIND_OPTION_NONE);
		container:Add(1, COLORBLIND_OPTION_PROTANOPIA);
		container:Add(2, COLORBLIND_OPTION_DEUTERANOPIA);
		container:Add(3, COLORBLIND_OPTION_TRITANOPIA);
		return container:GetData();
	end

	do
		local initTooltip = Settings.CreateDropDownInitTooltip(settings.colorblindSimulator, COLORBLIND_FILTER, OPTION_TOOLTIP_COLORBLIND_FILTER, GetOptions);

		function OnDropDownValueChanged(self, option)
			settings.colorblindSimulator:SetValue(option.value);
		end
	
		self.cbrHandles:RegisterCallback(self.ColorBlindFilterDropDown.Button, SelectionPopoutButtonMixin.Event.OnValueChanged, OnDropDownValueChanged);

		Settings.InitSelectionDropDown(self.ColorBlindFilterDropDown, settings.colorblindSimulator, GetOptions, 200, initTooltip);
	end

	do

		local minValue, maxValue, step = 0, 1, .05;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Min, OFF);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Max, HIGH);

		self.StrengthSliderWithSteppers:Init(settings.colorblindFactor:GetValue(), options.minValue, options.maxValue, options.steps, options.formatters);
		self.StrengthSliderWithSteppers:SetEnabled_(settings.colorblindSimulator:GetValue() > 0);

		self.cbrHandles:RegisterCallback(self.StrengthSliderWithSteppers, MinimalSliderWithSteppersMixin.Event.OnValueChanged, self.OnSliderValueChanged, self);
	end

	-- Defaults...
	local function OnDropDownSettingValueChanged(o, setting, value)
		local index = self.ColorBlindFilterDropDown.Button:FindIndex(function(data)
			return data.value == value;
		end);
		self.ColorBlindFilterDropDown.Button:SetSelectedIndex(index);

		self.StrengthSliderWithSteppers:SetEnabled_(value > 0);
	end

	self.cbrHandles:SetOnValueChangedCallback(settings.colorblindSimulator:GetVariable(), OnDropDownSettingValueChanged);

	local function OnSliderSettingValueChanged(o, setting, value)
		self.StrengthSliderWithSteppers:SetValue(value);
	end

	self.cbrHandles:SetOnValueChangedCallback(settings.colorblindFactor:GetVariable(), OnSliderSettingValueChanged);
end

function ColorblindSelectorMixin:OnDropDownValueChanged(option)
	local initializer = self:GetElementData();
	local settings = initializer.data.settings;
	settings.colorblindSimulator:SetValue(option.value);

	self.StrengthSliderWithSteppers:SetEnabled_(option.value > 0);
end

function ColorblindSelectorMixin:OnSliderValueChanged(value)
	local initializer = self:GetElementData();
	local settings = initializer.data.settings;
	settings.colorblindFactor:SetValue(value);
end

function ColorblindSelectorMixin:Release()
	self.cbrHandles:Unregister();
end

function ColorblindSelectorMixin:SetAlternateBackgroundShown(shown)
	self.Alternate:SetShown(shown);
end

local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(COLORBLIND_LABEL);

	-- Enable Colorblind Mode
	Settings.SetupCVarCheckBox(category, "colorblindMode", USE_COLORBLIND_MODE, OPTION_TOOLTIP_USE_COLORBLIND_MODE);

	-- Custom colorblind type and intensity
	do
		local settings = 
		{
			colorblindSimulator = Settings.RegisterCVarSetting(category, "colorblindSimulator", Settings.VarType.Number, COLORBLIND_FILTER),
			colorblindFactor = Settings.RegisterCVarSetting(category, "colorblindWeaknessFactor", Settings.VarType.Number, ADJUST_COLORBLIND_STRENGTH),
		};
		local data = { settings = settings };
		local initializer = Settings.CreatePanelInitializer("ColorblindSelectorTemplate", data);
		layout:AddInitializer(initializer);
	end

	Settings.RegisterCategory(category, SETTING_GROUP_ACCESSIBILITY);
end

SettingsRegistrar:AddRegistrant(Register);