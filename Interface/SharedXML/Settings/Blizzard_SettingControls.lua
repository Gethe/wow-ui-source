local function InitializeSettingTooltip(initializer)
	Settings.InitTooltip(initializer:GetName(), initializer:GetTooltip());
end

SettingsListSectionHeaderMixin = {};

function SettingsListSectionHeaderMixin:Init(initializer)
	local data = initializer:GetData();
	self.Title:SetText(data.name);
end

function CreateSettingsListSectionHeaderInitializer(name)
	local data = {name = name};
	return Settings.CreateElementInitializer("SettingsListSectionHeaderTemplate", data);
end

DefaultTooltipMixin = {};

function DefaultTooltipMixin:InitDefaultTooltipScriptHandlers()
	self:SetScript("OnEnter", self.OnEnter);
	self:SetScript("OnLeave", self.OnLeave);
end

function DefaultTooltipMixin:OnLoad()
	self.tooltipAnchorParent = nil;
	self.tooltipAnchoring = "ANCHOR_RIGHT";
	self.tooltipXOffset = -10;
	self.tooltipYOffset = 0;

	self:InitDefaultTooltipScriptHandlers();
end

function DefaultTooltipMixin:SetTooltipFunc(tooltipFunc)
	self.tooltipFunc = tooltipFunc;
end

function DefaultTooltipMixin:OnEnter()
	if self.tooltipAnchorParent then
		SettingsTooltip:SetOwner(self.tooltipAnchorParent, self.tooltipAnchoring, self.tooltipXOffset, self.tooltipYOffset);
	else
		SettingsTooltip:SetOwner(self, self.tooltipAnchoring, self.tooltipXOffset, self.tooltipYOffset);
	end

	if self.tooltipFunc then
		self.tooltipFunc();
	elseif self.tooltipText then
		SettingsTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true);
	end
	SettingsTooltip:Show();
end

function DefaultTooltipMixin:OnLeave()
	SettingsTooltip:Hide();
end

function DefaultTooltipMixin:SetCustomTooltipAnchoring(parent, anchoring, xOffset, yOffset)
	self.tooltipAnchorParent = parent;
	self.tooltipAnchoring = anchoring;
	self.tooltipXOffset = xOffset;
	self.tooltipYOffset = yOffset;
end

SettingsElementHierarchyMixin = {};

function SettingsElementHierarchyMixin:SetParentInitializer(parentInitializer, modifyPredicate)
	assert(parentInitializer);
	if parentInitializer == self then
		error("SettingsListElementInitializer:SetParentInitializer initializer cannot be self.")
	end

	self.parentInitializer = parentInitializer;

	if modifyPredicate then
		self:AddModifyPredicate(modifyPredicate);
	end
end

function SettingsElementHierarchyMixin:GetParentInitializer()
	return self.parentInitializer;
end

function SettingsElementHierarchyMixin:AddModifyPredicate(func)
	if not self.modifyPredicates then
		self.modifyPredicates = {};
	end
	table.insert(self.modifyPredicates, func);
end

function SettingsElementHierarchyMixin:GetModifyPredicates()
	return self.modifyPredicates;
end

function SettingsElementHierarchyMixin:GetEvaluateStateFrameEvents()
	return self.evaluateStateFrameEvents;
end

function SettingsElementHierarchyMixin:AddEvaluateStateFrameEvent(event)
	if not self.evaluateStateFrameEvents then
		self.evaluateStateFrameEvents = {};
	end
	table.insert(self.evaluateStateFrameEvents, event);
end

SettingsListPanelInitializer = CreateFromMixins(ScrollBoxFactoryInitializerMixin, SettingsSearchableElementMixin);

SettingsListElementInitializer = CreateFromMixins(ScrollBoxFactoryInitializerMixin, SettingsElementHierarchyMixin, SettingsSearchableElementMixin);

function SettingsListElementInitializer:Init(frameTemplate, data)
	ScrollBoxFactoryInitializerMixin.Init(self, frameTemplate);

	self.data = data or {};
end

function SettingsListElementInitializer:Indent()
	self.data.indent = 15;
end

function SettingsListElementInitializer:GetIndent()
	return self.data.indent or 0;
end

function SettingsListElementInitializer:GetData()
	return self.data;
end

function SettingsListElementInitializer:GetName()
	return self.data.name;
end

function SettingsListElementInitializer:GetTooltip()
	return self.data.tooltip;
end

function SettingsListElementInitializer:GetOptions()
	return self.data.options;
end

function SettingsListElementInitializer:SetSetting(setting)
	self.data.setting = setting;
end

function SettingsListElementInitializer:GetSetting()
	return self.data.setting;
end

function SettingsListElementInitializer:IsNewTagShown()
	return self.newTagShown;
end

function SettingsListElementInitializer:SetNewTagShown(shown)
	self.newTagShown = shown;
end

function SettingsListElementInitializer:SetSettingIntercept(interceptFunction)
	self.settingIntercept = interceptFunction;
end

function SettingsListElementInitializer:GetSettingIntercept()
	return self.settingIntercept;
end

function SettingsListElementInitializer:SetParentInitializer(parentInitializer, modifyPredicate)
	SettingsElementHierarchyMixin.SetParentInitializer(self, parentInitializer, modifyPredicate);

	self:Indent();
end

SettingsListElementMixin = {};

function SettingsListElementMixin:OnLoad()
	self.cbrHandles = Settings.CreateCallbackHandleContainer();
end

function SettingsListElementMixin:DisplayEnabled(enabled)
	local color = enabled and NORMAL_FONT_COLOR or GRAY_FONT_COLOR;
	self.Text:SetTextColor(color:GetRGB());
	self:DesaturateHierarchy(enabled and 0 or 1);
end

function SettingsListElementMixin:GetIndent()
	local initializer = self:GetElementData();
	return initializer:GetIndent();
end

function SettingsListElementMixin:SetTooltipFunc(tooltipFunc)
	DefaultTooltipMixin.SetTooltipFunc(self.Tooltip, tooltipFunc);
end

function SettingsListElementMixin:Init(initializer)
	assert(self.cbrHandles:IsEmpty());
	self.data = initializer.data;
	
	local parentInitializer = initializer:GetParentInitializer();
	if parentInitializer then
		local setting = parentInitializer:GetSetting();
		if setting then
			self.cbrHandles:SetOnValueChangedCallback(setting:GetVariable(), self.OnParentSettingValueChanged, self);
		end
	end

	local font = (parentInitializer ~= nil) and "GameFontNormalSmall" or "GameFontNormal";
	self.Text:SetFontObject(font);
	self.Text:SetText(initializer:GetName());
	self.Text:SetPoint("LEFT", (self:GetIndent() + 37), 0);
	self.Text:SetPoint("RIGHT", self, "CENTER", -85, 0);

	self:SetTooltipFunc(GenerateClosure(InitializeSettingTooltip, initializer));

	self.NewFeature:SetShown(initializer:IsNewTagShown());
end

function SettingsListElementMixin:Release()
	self.cbrHandles:Unregister();
	self.data = nil;
end

function SettingsListElementMixin:OnSettingValueChanged(setting, value)
end

function SettingsListElementMixin:OnParentSettingValueChanged(setting, value)
	self:EvaluateState();
end

function SettingsListElementMixin:EvaluateState()
	local initializer = self:GetElementData();
	self:SetShown(initializer:ShouldShow());
end

SettingsControlMixin = CreateFromMixins(SettingsListElementMixin);

function SettingsControlMixin:OnLoad()
	SettingsListElementMixin.OnLoad(self);
end

function SettingsControlMixin:Init(initializer)
	SettingsListElementMixin.Init(self, initializer);
	self.cbrHandles:SetOnValueChangedCallback(self:GetSetting():GetVariable(), self.OnSettingValueChanged, self);

	local evaluateStateFrameEvents = initializer:GetEvaluateStateFrameEvents();
	if evaluateStateFrameEvents then
		for index, event in ipairs(evaluateStateFrameEvents) do
			self.cbrHandles:AddHandle(EventRegistry:RegisterFrameEventAndCallbackWithHandle(event, self.EvaluateState, self));
		end
	end
end

function SettingsControlMixin:Release()
	SettingsListElementMixin.Release(self);
end

function SettingsControlMixin:GetSetting()
	return self.data.setting;
end

function SettingsControlMixin:OnSettingValueChanged(setting, value)
	self:SetValue(value);
end

function SettingsControlMixin:IsEnabled()
	local initializer = self:GetElementData();
	local prereqs = initializer:GetModifyPredicates();
	if prereqs then
		for index, prereq in ipairs(prereqs) do
			if not prereq() then
				return false;
			end
		end
	end
	return true;
end

function SettingsControlMixin:ShouldInterceptSetting(value)
	local initializer = self:GetElementData();
	local intercept = initializer:GetSettingIntercept();
	if intercept then
		local result = intercept(value);
		assert(result ~= nil);
		return result;
	end
	return false;
end

SettingsCheckBoxMixin = CreateFromMixins(CallbackRegistryMixin, DefaultTooltipMixin);
SettingsCheckBoxMixin:GenerateCallbackEvents(
	{
		"OnValueChanged",
	}
);

function SettingsCheckBoxMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	DefaultTooltipMixin.OnLoad(self);
	self.tooltipXOffset = 0;
end

function SettingsCheckBoxMixin:Init(value, initTooltip)
	self:SetValue(value);
	self:SetTooltipFunc(initTooltip);

	self:SetScript("OnClick", function(button, buttonName, down)
		self:TriggerEvent(SettingsCheckBoxMixin.Event.OnValueChanged, button:GetChecked());
	end);
end

function SettingsCheckBoxMixin:Release()
	self:SetScript("OnClick", nil);
end

function SettingsCheckBoxMixin:SetValue(value)
	self:SetChecked(value);
end

SettingsCheckBoxControlMixin = CreateFromMixins(SettingsControlMixin);

function SettingsCheckBoxControlMixin:OnLoad()
	SettingsControlMixin.OnLoad(self);

	self.CheckBox = CreateFrame("CheckButton", nil, self, "SettingsCheckBoxTemplate");
	self.CheckBox:SetPoint("LEFT", self, "CENTER", -80, 0);

	self.Tooltip:SetScript("OnMouseUp", function()
		if self.CheckBox:IsEnabled() then
			self.CheckBox:Click();
		end
	end);
end

function SettingsCheckBoxControlMixin:Init(initializer)
	SettingsControlMixin.Init(self, initializer);

	local setting = self:GetSetting();
	local options = initializer:GetOptions();
	local initTooltip = Settings.CreateOptionsInitTooltip(setting, initializer:GetName(), initializer:GetTooltip(), options);

	self.CheckBox:Init(setting:GetValue(), initTooltip);
	
	self.cbrHandles:RegisterCallback(self.CheckBox, SettingsCheckBoxMixin.Event.OnValueChanged, self.OnCheckBoxValueChanged, self);

	self:EvaluateState();
end

function SettingsCheckBoxControlMixin:OnSettingValueChanged(setting, value)
	SettingsControlMixin.OnSettingValueChanged(self, setting, value);

	self.CheckBox:SetChecked(value);
end

function SettingsCheckBoxControlMixin:OnCheckBoxValueChanged(value)
	if self:ShouldInterceptSetting(value) then
		self.CheckBox:SetChecked(not value);
	else
		self:GetSetting():SetValue(value);
	end
end

function SettingsCheckBoxControlMixin:SetValue(value)
	self.CheckBox:SetChecked(value);
	if value then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else 
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
end

function SettingsCheckBoxControlMixin:EvaluateState()
	SettingsListElementMixin.EvaluateState(self);
	local enabled = SettingsControlMixin.IsEnabled(self);

	local initializer = self:GetElementData();
	local options = initializer:GetOptions();
	if options then
		local optionData = type(options) == 'function' and options() or options;
		local value = self:GetSetting():GetValue();
		for index, option in ipairs(optionData) do
			if option.disabled and option.value ~= value then
				enabled = false;
			end
		end
	end

	self.CheckBox:SetEnabled(enabled);
	self:DisplayEnabled(enabled);
end

function SettingsCheckBoxControlMixin:Release()
	self.CheckBox:Release();
	SettingsControlMixin.Release(self);
end

SettingsSliderControlMixin = CreateFromMixins(SettingsControlMixin);

function SettingsSliderControlMixin:OnLoad()
	SettingsControlMixin.OnLoad(self);

	self.SliderWithSteppers = CreateFrame("Frame", nil, self, "MinimalSliderWithSteppersTemplate");
	self.SliderWithSteppers:SetWidth(250);
	self.SliderWithSteppers:SetPoint("LEFT", self, "CENTER", -80, 3);

	Mixin(self.SliderWithSteppers.Slider, DefaultTooltipMixin);
	self.SliderWithSteppers.Slider:InitDefaultTooltipScriptHandlers();
	self.SliderWithSteppers.Slider:SetCustomTooltipAnchoring(self.SliderWithSteppers.Slider, "ANCHOR_RIGHT", 20, 0);
end

function SettingsSliderControlMixin:Init(initializer)
	SettingsControlMixin.Init(self, initializer);

	local setting = self:GetSetting();
	local options = initializer:GetOptions();
	self.SliderWithSteppers:Init(setting:GetValue(), options.minValue, options.maxValue, options.steps, options.formatters);
	
	self.SliderWithSteppers.Slider:SetTooltipFunc(GenerateClosure(InitializeSettingTooltip, initializer));

	self.cbrHandles:RegisterCallback(self.SliderWithSteppers, MinimalSliderWithSteppersMixin.Event.OnValueChanged, self.OnSliderValueChanged, self);

	self:EvaluateState();
end

function SettingsSliderControlMixin:Release()
	self.SliderWithSteppers:Release();
	SettingsControlMixin.Release(self);
end

function SettingsSliderControlMixin:OnSliderValueChanged(value)
	self:GetSetting():SetValue(value);
end

function SettingsSliderControlMixin:OnSettingValueChanged(setting, value)
	SettingsControlMixin.OnSettingValueChanged(self, setting, value);
	
	local initializer = self:GetElementData();
	if initializer.reinitializeOnValueChanged then
		self.SliderWithSteppers:FormatValue(self:GetSetting():GetValue());
	end
end

function SettingsSliderControlMixin:SetValue(value)
	self.SliderWithSteppers:SetValue(value);
end

function SettingsSliderControlMixin:EvaluateState()
	SettingsListElementMixin.EvaluateState(self);
	local enabled = SettingsControlMixin.IsEnabled(self);
	self.SliderWithSteppers:SetEnabled_(enabled);
	self:DisplayEnabled(enabled);
end

SettingsDropDownControlMixin = CreateFromMixins(SettingsControlMixin);

function SettingsDropDownControlMixin:OnLoad()
	SettingsControlMixin.OnLoad(self);
	
	self.DropDown = CreateFrame(self.dropDownType, nil, self, self.dropDownTemplate);
	self.DropDown:SetPoint("LEFT", self, "CENTER", -40, 3);
	self.DropDown.Button:SetPopoutStrata("FULLSCREEN_DIALOG");
end

function SettingsDropDownControlMixin:Init(initializer)
	SettingsControlMixin.Init(self, initializer);

	self:InitDropDown();
	self:EvaluateState();
end

function SettingsDropDownControlMixin:InitDropDown()
	local setting = self:GetSetting();
	local initializer = self:GetElementData();
	local options = initializer:GetOptions();
	local initTooltip = Settings.CreateOptionsInitTooltip(setting, initializer:GetName(), initializer:GetTooltip(), options);
	
	function OnDropDownValueChanged(o, option)
		setting:SetValue(option.value);
	end

	self.DropDown.Button.selectedDataFunc = initializer.data.selectedDataFunc;
	self.cbrHandles:RegisterCallback(self.DropDown.Button, SelectionPopoutButtonMixin.Event.OnValueChanged, OnDropDownValueChanged);

	local selectionIndex = Settings.InitSelectionDropDown(self.DropDown, setting, options, 200, initTooltip);
	if not initializer.skipAssertMissingOption then
		-- Retained for debugging
		--assertsafe(selectionIndex ~= nil, ("Failed to matching option matching value '%s' for setting name '%s'"):format(
			--tostring(setting:GetValue()), setting:GetName()));
	end
end

function SettingsDropDownControlMixin:Release()
	SettingsControlMixin.Release(self);
end

function SettingsDropDownControlMixin:OnSettingValueChanged(setting, value)
	SettingsControlMixin.OnSettingValueChanged(self, setting, value);
	
	local initializer = self:GetElementData();
	if initializer.reinitializeOnValueChanged then
		self:InitDropDown();
	end

	self:SetValue(value);

	self.DropDown.Button:Update();
end

function SettingsDropDownControlMixin:SetValue(value)
	local index = self.DropDown.Button:FindIndex(function(data)
		return data.value == value;
	end);
	self.DropDown.Button:SetSelectedIndex(index);
end

function SettingsDropDownControlMixin:EvaluateState()
	SettingsListElementMixin.EvaluateState(self);
	local enabled = SettingsControlMixin.IsEnabled(self);
	self.DropDown:SetEnabled_(enabled);

	self:DisplayEnabled(enabled);
	return enabled;
end

SettingsButtonControlMixin = CreateFromMixins(SettingsListElementMixin);

function SettingsButtonControlMixin:OnLoad()
	SettingsListElementMixin.OnLoad(self);

	self.Button = CreateFrame("Button", nil, self, "UIPanelButtonTemplate");
	self.Button:SetWidth(200, 26);
end

function SettingsButtonControlMixin:Init(initializer)
	SettingsListElementMixin.Init(self, initializer);

	self.Button:SetText(self.data.buttonText);
	self.Button:SetScript("OnClick", self.data.buttonClick);

	if self.data.name == "" then
		self.Button:SetPoint("LEFT", self.Text, "LEFT", 0, 0);
		self.Tooltip:Hide();
	else
		self.Button:SetPoint("LEFT", self, "CENTER", -40, 0);
		self.Tooltip:Show();
	end
end

function SettingsButtonControlMixin:Release()
	self.Button:SetScript("OnClick", nil);
	SettingsListElementMixin.Release(self);
end

function CreateSettingsButtonInitializer(name, buttonText, buttonClick, tooltip)
	local data = {name = name, buttonText = buttonText, buttonClick = buttonClick, tooltip = tooltip};
	local initializer = Settings.CreateElementInitializer("SettingButtonControlTemplate", data);
	initializer:AddSearchTags(name);
	initializer:AddSearchTags(buttonText);
	return initializer;
end

SettingsCheckBoxWithButtonControlMixin = CreateFromMixins(SettingsControlMixin);

function SettingsCheckBoxWithButtonControlMixin:OnLoad()
	SettingsControlMixin.OnLoad(self);

	self.CheckBox = CreateFrame("CheckButton", nil, self, "SettingsCheckBoxTemplate");
	self.CheckBox:SetPoint("LEFT", self, "CENTER", -80, 0);

	self.Button = CreateFrame("Button", nil, self, "UIPanelButtonTemplate");
	self.Button:SetWidth(200, 26);
	self.Button:SetPoint("LEFT", self.CheckBox, "RIGHT", 5, 0);

	self.Tooltip:SetScript("OnMouseUp", function()
		if self.CheckBox:IsEnabled() then
			self.CheckBox:Click();
		end
	end);
end

function SettingsCheckBoxWithButtonControlMixin:Init(initializer)
	SettingsControlMixin.Init(self, initializer);

	local setting = self:GetSetting();
	local initTooltip = GenerateClosure(InitializeSettingTooltip, initializer);
	
	self.CheckBox:Init(setting:GetValue(), initTooltip);
	self.cbrHandles:RegisterCallback(self.CheckBox, SettingsCheckBoxMixin.Event.OnValueChanged, self.OnCheckBoxValueChanged, self);

	self.Button:SetText(self.data.buttonText);
	self.Button:SetScript("OnClick", self.data.OnButtonClick);
	
	self:EvaluateState();
end

function SettingsCheckBoxWithButtonControlMixin:OnCheckBoxValueChanged(value)
	local initializer = self:GetElementData();
	local setting = initializer:GetSetting();
	setting:SetValue(value);
	if value then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else 
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end

	self:GetSetting():SetValue(value);
end

function SettingsCheckBoxWithButtonControlMixin:Release()
	self.CheckBox:Release();
	self.Button:SetScript("OnClick", nil);
	SettingsControlMixin.Release(self);
end

function SettingsCheckBoxWithButtonControlMixin:SetButtonState(enabled)
	self.Button:SetEnabled(enabled);
end

function SettingsCheckBoxWithButtonControlMixin:OnSettingValueChanged(setting, value)
	SettingsControlMixin.OnSettingValueChanged(self, setting, value);

	self:EvaluateState();
end

function SettingsCheckBoxWithButtonControlMixin:SetValue(value)
	self.CheckBox:SetChecked(value);
	if value then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else 
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
end

function SettingsCheckBoxWithButtonControlMixin:EvaluateState()
	SettingsListElementMixin.EvaluateState(self);
	local enabled = SettingsControlMixin.IsEnabled(self);
	
	local clickEnabled = enabled;
	if self.data.clickRequiresSet and not self:GetSetting():GetValue() then
		clickEnabled = false;
	end

	self:SetButtonState(clickEnabled);
	self:DisplayEnabled(enabled);
end

function CreateSettingsCheckBoxWithButtonInitializer(setting, buttonText, buttonClick, clickRequiresSet, tooltip)
	local data = Settings.CreateSettingInitializerData(setting, nil, tooltip);
	data.buttonText = buttonText;
	data.OnButtonClick = buttonClick;
	data.clickRequiresSet = clickRequiresSet;
	return Settings.CreateSettingInitializer("SettingsCheckBoxWithButtonControlTemplate", data);
end

SettingsCheckBoxSliderControlMixin = CreateFromMixins(SettingsListElementMixin);

function SettingsCheckBoxSliderControlMixin:OnLoad()
	SettingsListElementMixin.OnLoad(self);

	self.CheckBox = CreateFrame("CheckButton", nil, self, "SettingsCheckBoxTemplate");
	self.CheckBox:SetPoint("LEFT", self, "CENTER", -80, 0);

	self.SliderWithSteppers = CreateFrame("Frame", nil, self, "MinimalSliderWithSteppersTemplate");
	self.SliderWithSteppers:SetWidth(214);
	self.SliderWithSteppers:SetPoint("LEFT", self.CheckBox, "RIGHT", 5, 0);

	Mixin(self.SliderWithSteppers.Slider, DefaultTooltipMixin);
	self.SliderWithSteppers.Slider:InitDefaultTooltipScriptHandlers();
	self.SliderWithSteppers.Slider:SetCustomTooltipAnchoring(self.SliderWithSteppers.Slider, "ANCHOR_RIGHT", 20, 0);

	self.Tooltip:SetScript("OnMouseUp", function()
		if self.CheckBox:IsEnabled() then
			self.CheckBox:Click();
		end
	end);
end

function SettingsCheckBoxSliderControlMixin:Init(initializer)
	SettingsListElementMixin.Init(self, initializer);

	local cbSetting = initializer.data.cbSetting;
	local cbLabel = initializer.data.cbLabel;
	local cbTooltip = initializer.data.cbTooltip;
	local sliderSetting = initializer.data.sliderSetting;
	local sliderOptions = initializer.data.sliderOptions;
	local sliderLabel = initializer.data.sliderLabel;
	local sliderTooltip = initializer.data.sliderTooltip;

	local cbInitTooltip = GenerateClosure(Settings.InitTooltip, cbLabel, cbTooltip);
	self:SetTooltipFunc(cbInitTooltip);
	
	self.CheckBox:Init(cbSetting:GetValue(), cbInitTooltip);
	self.cbrHandles:RegisterCallback(self.CheckBox, SettingsCheckBoxMixin.Event.OnValueChanged, self.OnCheckBoxValueChanged, self);

	self.SliderWithSteppers.Slider:SetTooltipFunc(GenerateClosure(Settings.InitTooltip, sliderLabel, sliderTooltip));

	self.SliderWithSteppers:Init(sliderSetting:GetValue(), sliderOptions.minValue, sliderOptions.maxValue, sliderOptions.steps, sliderOptions.formatters);
	self.SliderWithSteppers:SetEnabled_(cbSetting:GetValue());
	self.cbrHandles:RegisterCallback(self.SliderWithSteppers, MinimalSliderWithSteppersMixin.Event.OnValueChanged, self.OnSliderValueChanged, self);

	-- Defaults...
	local function OnCheckBoxSettingValueChanged(o, setting, value)
		self.CheckBox:SetValue(value);
		self.SliderWithSteppers:SetEnabled_(value);
	end
	self.cbrHandles:SetOnValueChangedCallback(cbSetting:GetVariable(), OnCheckBoxSettingValueChanged);

	local function OnSliderSettingValueChanged(o, setting, value)
		self.SliderWithSteppers:SetValue(value);
	end
	self.cbrHandles:SetOnValueChangedCallback(sliderSetting:GetVariable(), OnSliderSettingValueChanged);
end

function SettingsCheckBoxSliderControlMixin:OnCheckBoxValueChanged(value)
	local initializer = self:GetElementData();
	local cbSetting = initializer.data.cbSetting;
	cbSetting:SetValue(value);
	if value then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else 
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end

	self.SliderWithSteppers:SetEnabled_(value);
end

function SettingsCheckBoxSliderControlMixin:OnSliderValueChanged(value)
	local initializer = self:GetElementData();
	local sliderSetting = initializer.data.sliderSetting;
	sliderSetting:SetValue(value);
end

function SettingsCheckBoxSliderControlMixin:Release()
	self.CheckBox:Release();
	self.SliderWithSteppers:Release();
	SettingsListElementMixin.Release(self);
end

function CreateSettingsCheckBoxSliderInitializer(cbSetting, cbLabel, cbTooltip, sliderSetting, sliderOptions, sliderLabel, sliderTooltip)
	local data =
	{
		name = cbLabel,
		tooltip = cbTooltip,
		cbSetting = cbSetting,
		cbLabel = cbLabel,
		cbTooltip = cbTooltip,
		sliderSetting = sliderSetting,
		sliderOptions = sliderOptions,
		sliderLabel = sliderLabel,
		sliderTooltip = sliderTooltip,
	};
	return Settings.CreateSettingInitializer("SettingsCheckBoxSliderControlTemplate", data);
end

SettingsCheckBoxDropDownControlMixin = CreateFromMixins(SettingsListElementMixin);

function SettingsCheckBoxDropDownControlMixin:OnLoad()
	SettingsListElementMixin.OnLoad(self);

	self.CheckBox = CreateFrame("CheckButton", nil, self, "SettingsCheckBoxTemplate");
	self.CheckBox:SetPoint("LEFT", self, "CENTER", -80, 0);

	self.DropDown = CreateFrame("Frame", nil, self, "SettingsSelectionPopoutWithButtonsTemplate");
	self.DropDown:SetPoint("LEFT", self.CheckBox, "RIGHT", 50, 0);

	self.Tooltip:SetScript("OnMouseUp", function()
		if self.CheckBox:IsEnabled() then
			self.CheckBox:Click();
		end
	end);
end

function SettingsCheckBoxDropDownControlMixin:Init(initializer)
	SettingsListElementMixin.Init(self, initializer);

	local cbSetting = initializer.data.cbSetting;
	local cbLabel = initializer.data.cbLabel;
	local cbTooltip = initializer.data.cbTooltip;
	local dropDownSetting = initializer.data.dropDownSetting;
	local dropDownOptions = initializer.data.dropDownOptions;
	local dropDownLabel = initializer.data.dropDownLabel;
	local dropDownTooltip = initializer.data.dropDownTooltip;

	local initTooltip = GenerateClosure(Settings.InitTooltip, cbLabel, cbTooltip);
	self:SetTooltipFunc(initTooltip);

	self.CheckBox:Init(cbSetting:GetValue(), initTooltip);
	self.cbrHandles:RegisterCallback(self.CheckBox, SettingsCheckBoxMixin.Event.OnValueChanged, self.OnCheckBoxValueChanged, self);

	function OnDropDownValueChanged(self, option)
		dropDownSetting:SetValue(option.value);
	end

	self.cbrHandles:RegisterCallback(self.DropDown.Button, SelectionPopoutButtonMixin.Event.OnValueChanged, OnDropDownValueChanged);

	local initTooltip = Settings.CreateOptionsInitTooltip(dropDownSetting, initializer:GetName(), initializer:GetTooltip(), dropDownOptions);
	Settings.InitSelectionDropDown(self.DropDown, dropDownSetting, dropDownOptions, 200, initTooltip);

	self.DropDown:SetEnabled_(cbSetting:GetValue());

	-- Defaults...
	local function OnCheckBoxSettingValueChanged(o, setting, value)
		self.CheckBox:SetValue(value);
		self.DropDown:SetEnabled_(value);
	end
	self.cbrHandles:SetOnValueChangedCallback(cbSetting:GetVariable(), OnCheckBoxSettingValueChanged);

	local function OnDropDownSettingValueChanged(o, setting, value)
		local index = self.DropDown.Button:FindIndex(function(data)
			return data.value == value;
		end);
		self.DropDown.Button:SetSelectedIndex(index);
	end
	self.cbrHandles:SetOnValueChangedCallback(dropDownSetting:GetVariable(), OnDropDownSettingValueChanged);
end

function SettingsCheckBoxDropDownControlMixin:OnCheckBoxValueChanged(value)
	local initializer = self:GetElementData();
	local cbSetting = initializer.data.cbSetting;
	cbSetting:SetValue(value);
	if value then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else 
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end

	self.DropDown:SetEnabled_(value);
end

function SettingsCheckBoxDropDownControlMixin:OnDropDownValueChanged(option)
	local initializer = self:GetElementData();
	local dropDownSetting = initializer.data.dropDownSetting;
	dropDownSetting:SetValue(option.value);
end

function SettingsCheckBoxDropDownControlMixin:Release()
	self.CheckBox:Release();
	SettingsListElementMixin.Release(self);
end

function CreateSettingsCheckBoxDropDownInitializer(cbSetting, cbLabel, cbTooltip, dropDownSetting, dropDownOptions, dropDownLabel, dropDownTooltip)
	local data =
	{
		name = cbLabel,
		tooltip = cbTooltip,
		cbSetting = cbSetting,
		cbLabel = cbLabel,
		cbTooltip = cbTooltip,
		dropDownSetting = dropDownSetting,
		dropDownOptions = dropDownOptions,
		dropDownLabel = dropDownLabel,
		dropDownTooltip = dropDownTooltip,
	};
	return Settings.CreateSettingInitializer("SettingsCheckBoxDropDownControlTemplate", data);
end

SettingsSelectionPopoutEntryMixin = CreateFromMixins(SelectionPopoutEntryMixin);

function SettingsSelectionPopoutEntryMixin:GetTooltipText()
	return self.SelectionDetails:GetTooltipText();
end

function SettingsSelectionPopoutEntryMixin:OnEnter()
	SelectionPopoutEntryMixin.OnEnter(self);
	
	self.HighlightBGTex:SetAlpha(0.15);

	if not self.isSelected then
		if self.selectionData.disabled == nil then
			self.SelectionDetails.SelectionName:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		end
	end

	self.parentButton:OnEntryMouseEnter(self);
end

function SettingsSelectionPopoutEntryMixin:OnLeave()
	SelectionPopoutEntryMixin.OnLeave(self);
	
	self.HighlightBGTex:SetAlpha(0);

	if not self.isSelected then
		local fontColor = nil;
		if self.selectionData.disabled == nil then
			fontColor = VERY_LIGHT_GRAY_COLOR;
		else
			fontColor = DISABLED_FONT_COLOR;
		end
		self.SelectionDetails.SelectionName:SetTextColor(fontColor:GetRGB());
	end

	self.parentButton:OnEntryMouseLeave(self);
end

function SettingsSelectionPopoutEntryMixin:OnClick()
	if self.selectionData.disabled == nil then
		SelectionPopoutEntryMixin.OnClick(self);
	end
end

SettingsSelectionPopoutDetailsMixin = {};

function SettingsSelectionPopoutDetailsMixin:GetTooltipText()
	if self.SelectionName:IsShown() and self.SelectionName:IsTruncated() then
		return self.label;
	end

	return nil;
end

function SettingsSelectionPopoutDetailsMixin:AdjustWidth(multipleColumns, defaultWidth)
	if multipleColumns then
		self:SetWidth(Round(defaultWidth / 2));
	else
		local nameWidth = self.SelectionName:GetUnboundedStringWidth() + self.selectionNamePadding;
		self:SetWidth(Round(math.max(nameWidth, defaultWidth)));
		self.SelectionName:SetWidth(nameWidth);
	end
end

function SettingsSelectionPopoutDetailsMixin:SetupDetails(selectionData, index, isSelected, hasAFailedReq, hasALockedChoice)
	self.label = selectionData.label;

	self.SelectionName:Show();
	self.SelectionName:SetText(selectionData.label);

	if isSelected ~= nil then
		local fontColor = nil;
		if isSelected then
			fontColor = NORMAL_FONT_COLOR;
		elseif selectionData.disabled then
			fontColor = DISABLED_FONT_COLOR;
		else
			fontColor = VERY_LIGHT_GRAY_COLOR;
		end
		self.SelectionName:SetTextColor(fontColor:GetRGB());
	end

	local maxNameWidth = 200;
	if self.SelectionName:GetWidth() > maxNameWidth then
		self.SelectionName:SetWidth(maxNameWidth);
	end
end

function SettingsSelectionPopoutDetailsMixin:SetupCustomDetails()
	self.label = CUSTOM;

	self.SelectionName:Show();
	self.SelectionName:SetText(self.label);
	self.SelectionName:SetTextColor(VERY_LIGHT_GRAY_COLOR:GetRGB());

	local maxNameWidth = 200;
	if self.SelectionName:GetWidth() > maxNameWidth then
		self.SelectionName:SetWidth(maxNameWidth);
	end
end

function CreateSettingsSelectionCustomSelectedData(data, label)
	data.selectedDataFunc = function()
		return {label = label};
	end;
end

SettingsSelectionPopoutButtonMixin = CreateFromMixins(SelectionPopoutButtonMixin, DefaultTooltipMixin);

function SettingsSelectionPopoutButtonMixin:OnLoad()
	SelectionPopoutButtonMixin.OnLoad(self);
	DefaultTooltipMixin.OnLoad(self);

	self:SetScript("OnMouseWheel", nil);
end

function SettingsSelectionPopoutButtonMixin:OnEnter()
	SelectionPopoutButtonMixin.OnEnter(self);
	DefaultTooltipMixin.OnEnter(self);
end

function SettingsSelectionPopoutButtonMixin:OnLeave()
	SelectionPopoutButtonMixin.OnLeave(self);
	DefaultTooltipMixin.OnLeave(self);
end

function SettingsSelectionPopoutButtonMixin:SetEnabled_(enabled)
	SelectionPopoutButtonMixin.SetEnabled_(self, enabled);
	
	if enabled then
		self.SelectionDetails.SelectionName:SetTextColor(NORMAL_FONT_COLOR:GetRGB());
	else
		self.SelectionDetails.SelectionName:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
	end
end

function SettingsSelectionPopoutButtonMixin:IsDataMatch(data1, data2)
	return data1.value == data2.value;
end

function SettingsSelectionPopoutButtonMixin:UpdateButtonDetails()
	local currentSelectedData = self:GetCurrentSelectedData();
	if not currentSelectedData and self.selectedDataFunc then
		currentSelectedData = self.selectedDataFunc();
	end

	if currentSelectedData then
		self.SelectionDetails:SetupDetails(currentSelectedData, self.selectedIndex);
	else
		self.SelectionDetails:SetupCustomDetails();
	end
	return currentSelectedData ~= nil;
end

SettingsExpandableSectionMixin = {};

function SettingsExpandableSectionMixin:OnLoad()
	self.Button:SetScript("OnClick", function(button, buttonName, down)
		local initializer = self:GetElementData();
		local data = initializer.data;
		data.expanded = not data.expanded;
		
		self:SetHeight(self:CalculateHeight());

		self:OnExpandedChanged(data.expanded);
	end);
end

function SettingsExpandableSectionMixin:OnExpandedChanged(expanded)
	error("Implement OnExpandedChanged");
end

function SettingsExpandableSectionMixin:Init(initializer)
	local data = initializer.data;
	self.Button.Text:SetText(data.name);
end

SettingsExpandableSectionInitializer = CreateFromMixins(ScrollBoxFactoryInitializerMixin, SettingsSearchableElementMixin);

function SettingsExpandableSectionInitializer:GetExtent()
	error("Implement GetExtent");
end

function CreateSettingsExpandableSectionInitializer(name)
	local initializer = CreateFromMixins(SettingsExpandableSectionInitializer);
	initializer:Init("SettingsExpandableSectionTemplate");
	initializer.data = {name = name};
	return initializer;
end