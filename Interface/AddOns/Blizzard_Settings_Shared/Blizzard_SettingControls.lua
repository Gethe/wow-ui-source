local indentSize = 15;

DefaultTooltipMixin = {};

function DefaultTooltipMixin:InitDefaultTooltipScriptHandlers()
	self:SetScript("OnEnter", self.OnEnter);
	self:SetScript("OnLeave", self.OnLeave);
end

function DefaultTooltipMixin:OnLoad()
	self:SetDefaultTooltipAnchors();
	self:InitDefaultTooltipScriptHandlers();
end

function DefaultTooltipMixin:SetDefaultTooltipAnchors()
	self.tooltipAnchorParent = nil;
	self.tooltipAnchoring = "ANCHOR_RIGHT";
	self.tooltipXOffset = -10;
	self.tooltipYOffset = 0;
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

	if self.HoverBackground then
		self.HoverBackground:Show();
	end
end

function DefaultTooltipMixin:OnLeave()
	SettingsTooltip:Hide();

	if self.HoverBackground then
		self.HoverBackground:Hide();
	end
end

function DefaultTooltipMixin:SetCustomTooltipAnchoring(parent, anchoring, xOffset, yOffset)
	self.tooltipAnchorParent = parent;
	self.tooltipAnchoring = anchoring;
	self.tooltipXOffset = xOffset;
	self.tooltipYOffset = yOffset;
end

local function InitializeSettingTooltip(initializer)
	Settings.InitTooltip(initializer:GetName(), initializer:GetTooltip());
end

SettingsListSectionHeaderMixin = CreateFromMixins(DefaultTooltipMixin);

function SettingsListSectionHeaderMixin:OnLoad()
	DefaultTooltipMixin.OnLoad(self);
end

function SettingsListSectionHeaderMixin:Init(initializer)
	local data = initializer:GetData();
	self.Title:SetTextToFit(data.name);

	self:SetCustomTooltipAnchoring(self.Title, "ANCHOR_RIGHT");

	self:SetTooltipFunc(GenerateClosure(InitializeSettingTooltip, initializer));
end

function CreateSettingsListSectionHeaderInitializer(name, tooltip)
	local data = {name = name, tooltip = tooltip};
	return Settings.CreateElementInitializer("SettingsListSectionHeaderTemplate", data);
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
	self.data.indent = indentSize;
end

function SettingsListElementInitializer:IsParentInitializerInLayout()
	local parentInitializer = self:GetParentInitializer();
	if not parentInitializer then
		return false;
	end

	local currentLayout = SettingsPanel:GetCurrentLayout();
	if not currentLayout then
		return false;
	end

	for _, initializer in currentLayout:EnumerateInitializers() do
		if initializer == parentInitializer then
			return true;
		end
	end

	return false;
end

function SettingsListElementInitializer:GetIndent()
	return (self.data.indent or self:IsParentInitializerInLayout()) and indentSize or 0;
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
	local setting = self:GetSetting();
	return setting and IsNewSettingInCurrentVersion(setting:GetVariable());
end

function SettingsListElementInitializer:SetSettingIntercept(interceptFunction)
	self.settingIntercept = interceptFunction;
end

function SettingsListElementInitializer:GetSettingIntercept()
	return self.settingIntercept;
end

function SettingsListElementInitializer:SetParentInitializer(parentInitializer, modifyPredicate)
	SettingsElementHierarchyMixin.SetParentInitializer(self, parentInitializer, modifyPredicate);
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

	local font = initializer:IsParentInitializerInLayout() and "GameFontNormalSmall" or "GameFontNormal";
	self.Text:SetFontObject(font);
	self.Text:SetText(initializer:GetName());
	self.Text:SetPoint("LEFT", (self:GetIndent() + 37), 0);
	self.Text:SetPoint("RIGHT", self, "CENTER", -85, 0);

	if initializer.hideText then
		self.Text:Hide();
	end

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

function SettingsControlMixin:SetValue(value)
	-- Implement in derived
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

SettingsCheckboxMixin = CreateFromMixins(CallbackRegistryMixin, DefaultTooltipMixin);
SettingsCheckboxMixin:GenerateCallbackEvents(
	{
		"OnValueChanged",
	}
);

function SettingsCheckboxMixin:OnLoad()
	CallbackRegistryMixin.OnLoad(self);
	DefaultTooltipMixin.OnLoad(self);
	self.tooltipXOffset = 0;
end

function SettingsCheckboxMixin:Init(value, initTooltip)
	self:SetValue(value);
	self:SetTooltipFunc(initTooltip);

	self:SetScript("OnClick", function(button, buttonName, down)
		self:TriggerEvent(SettingsCheckboxMixin.Event.OnValueChanged, button:GetChecked());
	end);
end

function SettingsCheckboxMixin:Release()
	self:SetScript("OnClick", nil);
end

function SettingsCheckboxMixin:SetValue(value)
	self:SetChecked(value);
end

SettingsCheckboxControlMixin = CreateFromMixins(SettingsControlMixin);

function SettingsCheckboxControlMixin:OnLoad()
	SettingsControlMixin.OnLoad(self);

	self.Checkbox = CreateFrame("CheckButton", nil, self, "SettingsCheckboxTemplate");
	self.Checkbox:SetPoint("LEFT", self, "CENTER", -80, 0);

	self.Tooltip:SetScript("OnMouseUp", function()
		if self.Checkbox:IsEnabled() then
			self.Checkbox:Click();
		end
	end);
end

function SettingsCheckboxControlMixin:Init(initializer)
	SettingsControlMixin.Init(self, initializer);

	local setting = self:GetSetting();
	local options = initializer:GetOptions();
	local initTooltip = Settings.CreateOptionsInitTooltip(setting, initializer:GetName(), initializer:GetTooltip(), options);

	self.Checkbox:Init(setting:GetValue(), initTooltip);
	
	self.cbrHandles:RegisterCallback(self.Checkbox, SettingsCheckboxMixin.Event.OnValueChanged, self.OnCheckboxValueChanged, self);

	self:EvaluateState();
end

function SettingsCheckboxControlMixin:OnSettingValueChanged(setting, value)
	SettingsControlMixin.OnSettingValueChanged(self, setting, value);

	self.Checkbox:SetChecked(value);
end

function SettingsCheckboxControlMixin:OnCheckboxValueChanged(value)
	if self:ShouldInterceptSetting(value) then
		self.Checkbox:SetChecked(not value);
	else
		self:GetSetting():SetValue(value);
	end
end

function SettingsCheckboxControlMixin:SetValue(value)
	self.Checkbox:SetChecked(value);
	if value then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else 
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
end

function SettingsCheckboxControlMixin:EvaluateState()
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

	self.Checkbox:SetEnabled(enabled);
	self:DisplayEnabled(enabled);
end

function SettingsCheckboxControlMixin:Release()
	self.Checkbox:Release();
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
	self.SliderWithSteppers:SetEnabled(enabled);
	self:DisplayEnabled(enabled);
end

SettingsDropdownControlMixin = CreateFromMixins(SettingsControlMixin);

function SettingsDropdownControlMixin:OnLoad()
	SettingsControlMixin.OnLoad(self);
	
	local dropdownType = self.dropdownType or "SettingsDropdownWithButtonsTemplate";
	self.Control = CreateFrame("Frame", nil, self, dropdownType);
	self.Control:SetPoint("LEFT", self, "CENTER", -48, 3);
	self.Control.Dropdown:SetWidth(220);

	local function OnShow()
		local initializer = self:GetElementData();
		if initializer.OnShow then
			initializer.OnShow();
		end
	end

	local function OnHide()
		local initializer = self:GetElementData();
		if initializer.OnHide then
			initializer.OnHide();
		end
	end

	self.Control.Dropdown:RegisterCallback(DropdownButtonMixin.Event.OnMenuOpen, OnShow);
	self.Control.Dropdown:RegisterCallback(DropdownButtonMixin.Event.OnMenuClose, OnHide);

	Mixin(self.Control.Dropdown, DefaultTooltipMixin);
end

function SettingsDropdownControlMixin:Init(initializer)
	SettingsControlMixin.Init(self, initializer);

	self:InitDropdown();
	self:EvaluateState();
end

function SettingsDropdownControlMixin:InitDropdown()
	local setting = self:GetSetting();
	local initializer = self:GetElementData();
	local options = initializer:GetOptions();
	local initTooltip = Settings.CreateOptionsInitTooltip(setting, initializer:GetName(), initializer:GetTooltip(), options);
	self:SetupDropdownMenu(self.Control.Dropdown, setting, options, initTooltip);
end

function SettingsDropdownControlMixin:SetupDropdownMenu(button, setting, options, initTooltip)
	local inserter = Settings.CreateDropdownOptionInserter(options);
	Settings.InitDropdown(self.Control.Dropdown, setting, inserter, initTooltip);
end

function SettingsDropdownControlMixin:Release()
	SettingsControlMixin.Release(self);
end

function SettingsDropdownControlMixin:OnSettingValueChanged(setting, value)
	SettingsControlMixin.OnSettingValueChanged(self, setting, value);
	
	local initializer = self:GetElementData();
	if initializer.reinitializeOnValueChanged then
		self:InitDropdown();
	end
end

function SettingsDropdownControlMixin:SetValue(value)
	self:InitDropdown();
end

function SettingsDropdownControlMixin:EvaluateState()
	SettingsListElementMixin.EvaluateState(self);
	local enabled = SettingsControlMixin.IsEnabled(self);
	self.Control.Dropdown:SetEnabled(enabled);

	self:DisplayEnabled(enabled);
	return enabled;
end

SettingsButtonControlMixin = CreateFromMixins(SettingsListElementMixin);

function SettingsButtonControlMixin:OnLoad()
	SettingsListElementMixin.OnLoad(self);

	self.Button = CreateFrame("Button", nil, self, "UIPanelButtonTemplate");
	self.Button:SetWidth(200, 26);
	
	Mixin(self.Button, DefaultTooltipMixin);
	DefaultTooltipMixin.OnLoad(self.Button);

	self.Button.New = CreateFrame("Frame", nil, self, "NewFeatureLabelTemplate");
	self.Button.New:SetPoint("CENTER", self.Button, "TOPRIGHT", 0, -2);
	self.Button.New:SetScale(.8);
end

function SettingsButtonControlMixin:Init(initializer)
	SettingsListElementMixin.Init(self, initializer);

	self.Button:SetText(self.data.buttonText);
	self.Button:SetScript("OnClick", self.data.buttonClick);
	self.Button:SetTooltipFunc(GenerateClosure(InitializeSettingTooltip, initializer));
	
	if self.data.name == "" then
		self.Button:SetPoint("LEFT", self.Text, "LEFT", 0, 0);
		self.Tooltip:Hide();
	else
		self.Button:SetPoint("LEFT", self, "CENTER", -40, 0);
		self.Tooltip:Show();
	end

	self.Button.New:SetShown(initializer.showNew);
end

function SettingsButtonControlMixin:Release()
	self.Button:SetScript("OnClick", nil);
	SettingsListElementMixin.Release(self);
end

function CreateSettingsButtonInitializer(name, buttonText, buttonClick, tooltip, addSearchTags)
	local data = {name = name, buttonText = buttonText, buttonClick = buttonClick, tooltip = tooltip};
	local initializer = Settings.CreateElementInitializer("SettingButtonControlTemplate", data);

	-- Some settings buttons, like ones that open to a setting category, should not show up in search.
	assert(addSearchTags ~= nil);
	if addSearchTags then
		initializer:AddSearchTags(name);
		initializer:AddSearchTags(buttonText);
	end

	return initializer;
end

SettingsCheckboxWithButtonControlMixin = CreateFromMixins(SettingsControlMixin);

function SettingsCheckboxWithButtonControlMixin:OnLoad()
	SettingsControlMixin.OnLoad(self);

	self.Checkbox = CreateFrame("CheckButton", nil, self, "SettingsCheckboxTemplate");
	self.Checkbox:SetPoint("LEFT", self, "CENTER", -80, 0);

	self.Button = CreateFrame("Button", nil, self, "UIPanelButtonTemplate");
	self.Button:SetWidth(200, 26);
	self.Button:SetPoint("LEFT", self.Checkbox, "RIGHT", 5, 0);

	self.Tooltip:SetScript("OnMouseUp", function()
		if self.Checkbox:IsEnabled() then
			self.Checkbox:Click();
		end
	end);
end

function SettingsCheckboxWithButtonControlMixin:Init(initializer)
	SettingsControlMixin.Init(self, initializer);

	local setting = self:GetSetting();
	local initTooltip = GenerateClosure(InitializeSettingTooltip, initializer);
	
	self.Checkbox:Init(setting:GetValue(), initTooltip);
	self.cbrHandles:RegisterCallback(self.Checkbox, SettingsCheckboxMixin.Event.OnValueChanged, self.OnCheckboxValueChanged, self);

	self.Button:SetText(self.data.buttonText);
	self.Button:SetScript("OnClick", self.data.OnButtonClick);
	
	self:EvaluateState();
end

function SettingsCheckboxWithButtonControlMixin:OnCheckboxValueChanged(value)
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

function SettingsCheckboxWithButtonControlMixin:Release()
	self.Checkbox:Release();
	self.Button:SetScript("OnClick", nil);
	SettingsControlMixin.Release(self);
end

function SettingsCheckboxWithButtonControlMixin:SetButtonState(enabled)
	self.Button:SetEnabled(enabled);
end

function SettingsCheckboxWithButtonControlMixin:OnSettingValueChanged(setting, value)
	SettingsControlMixin.OnSettingValueChanged(self, setting, value);

	self:EvaluateState();
end

function SettingsCheckboxWithButtonControlMixin:SetValue(value)
	self.Checkbox:SetChecked(value);
	if value then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else 
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
end

function SettingsCheckboxWithButtonControlMixin:EvaluateState()
	SettingsListElementMixin.EvaluateState(self);
	local enabled = SettingsControlMixin.IsEnabled(self);
	
	local clickEnabled = enabled;
	if self.data.clickRequiresSet and not self:GetSetting():GetValue() then
		clickEnabled = false;
	end

	self:SetButtonState(clickEnabled);
	self:DisplayEnabled(enabled);
end

function CreateSettingsCheckboxWithButtonInitializer(setting, buttonText, buttonClick, clickRequiresSet, tooltip)
	local data = Settings.CreateSettingInitializerData(setting, nil, tooltip);
	data.buttonText = buttonText;
	data.OnButtonClick = buttonClick;
	data.clickRequiresSet = clickRequiresSet;
	local initializer = Settings.CreateSettingInitializer("SettingsCheckboxWithButtonControlTemplate", data);
	initializer:AddSearchTags(buttonText);
	return initializer;
end

SettingsCheckboxSliderControlMixin = CreateFromMixins(SettingsListElementMixin);

function SettingsCheckboxSliderControlMixin:OnLoad()
	SettingsListElementMixin.OnLoad(self);

	self.Checkbox = CreateFrame("CheckButton", nil, self, "SettingsCheckboxTemplate");
	self.Checkbox:SetPoint("LEFT", self, "CENTER", -80, 0);

	self.SliderWithSteppers = CreateFrame("Frame", nil, self, "MinimalSliderWithSteppersTemplate");
	self.SliderWithSteppers:SetWidth(214);
	self.SliderWithSteppers:SetPoint("LEFT", self.Checkbox, "RIGHT", 5, 0);

	Mixin(self.SliderWithSteppers.Slider, DefaultTooltipMixin);
	self.SliderWithSteppers.Slider:InitDefaultTooltipScriptHandlers();
	self.SliderWithSteppers.Slider:SetCustomTooltipAnchoring(self.SliderWithSteppers.Slider, "ANCHOR_RIGHT", 20, 0);

	self.Tooltip:SetScript("OnMouseUp", function()
		if self.Checkbox:IsEnabled() then
			self.Checkbox:Click();
		end
	end);
end

function SettingsCheckboxSliderControlMixin:Init(initializer)
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

	self.Checkbox:Init(cbSetting:GetValue(), cbInitTooltip);
	self.cbrHandles:RegisterCallback(self.Checkbox, SettingsCheckboxMixin.Event.OnValueChanged, self.OnCheckboxValueChanged, self);

	self.SliderWithSteppers.Slider:SetTooltipFunc(GenerateClosure(Settings.InitTooltip, sliderLabel, sliderTooltip));

	self.SliderWithSteppers:Init(sliderSetting:GetValue(), sliderOptions.minValue, sliderOptions.maxValue, sliderOptions.steps, sliderOptions.formatters);
	self.cbrHandles:RegisterCallback(self.SliderWithSteppers, MinimalSliderWithSteppersMixin.Event.OnValueChanged, self.OnSliderValueChanged, self);

	-- Defaults...
	local function OnCheckboxSettingValueChanged(o, setting, value)
		self.Checkbox:SetValue(value);
		self:EvaluateState();
	end
	self.cbrHandles:SetOnValueChangedCallback(cbSetting:GetVariable(), OnCheckboxSettingValueChanged);

	local function OnSliderSettingValueChanged(o, setting, value)
		self.SliderWithSteppers:SetValue(value);
	end
	self.cbrHandles:SetOnValueChangedCallback(sliderSetting:GetVariable(), OnSliderSettingValueChanged);

	self:EvaluateState();
end

function SettingsCheckboxSliderControlMixin:OnCheckboxValueChanged(value)
	local initializer = self:GetElementData();
	local cbSetting = initializer.data.cbSetting;
	cbSetting:SetValue(value);
	if value then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else 
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end

	self:EvaluateState();
end

function SettingsCheckboxSliderControlMixin:OnSliderValueChanged(value)
	local initializer = self:GetElementData();
	local sliderSetting = initializer.data.sliderSetting;
	sliderSetting:SetValue(value);
end

function SettingsCheckboxSliderControlMixin:EvaluateState()
	SettingsListElementMixin.EvaluateState(self);
	local enabled = SettingsControlMixin.IsEnabled(self);
	self.Checkbox:SetEnabled(enabled);
	self.SliderWithSteppers:SetEnabled(enabled and self.Checkbox:GetChecked());
	self:DisplayEnabled(enabled);
end

function SettingsCheckboxSliderControlMixin:Release()
	self.Checkbox:Release();
	self.SliderWithSteppers:Release();
	SettingsListElementMixin.Release(self);
end

function CreateSettingsCheckboxSliderInitializer(cbSetting, cbLabel, cbTooltip, sliderSetting, sliderOptions, sliderLabel, sliderTooltip)
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
	local initializer = Settings.CreateSettingInitializer("SettingsCheckboxSliderControlTemplate", data);
	initializer:AddSearchTags(cbLabel, sliderLabel);
	return initializer;
end

SettingsCheckboxDropdownControlMixin = CreateFromMixins(SettingsListElementMixin);

function SettingsCheckboxDropdownControlMixin:OnLoad()
	SettingsListElementMixin.OnLoad(self);

	self.Checkbox = CreateFrame("CheckButton", nil, self, "SettingsCheckboxTemplate");
	self.Checkbox:SetPoint("LEFT", self, "CENTER", -80, 0);

	self.Control = CreateFrame("Frame", nil, self, "SettingsDropdownWithButtonsTemplate");
	self.Control:SetPoint("LEFT", self.Checkbox, "RIGHT", 32, 0);
	self.Control.Dropdown:SetWidth(220);

	Mixin(self.Control.Dropdown, DefaultTooltipMixin);

	self.Tooltip:SetScript("OnMouseUp", function()
		if self.Checkbox:IsEnabled() then
			self.Checkbox:Click();
		end
	end);
end

function SettingsCheckboxDropdownControlMixin:Init(initializer)
	SettingsListElementMixin.Init(self, initializer);

	local cbSetting = initializer.data.cbSetting;
	local cbLabel = initializer.data.cbLabel;
	local cbTooltip = initializer.data.cbTooltip;
	local dropdownSetting = initializer.data.dropdownSetting;
	local dropdownOptions = initializer.data.dropdownOptions;
	local dropDownLabel = initializer.data.dropDownLabel;
	local dropDownTooltip = initializer.data.dropDownTooltip;

	local initCheckboxTooltip = GenerateClosure(Settings.InitTooltip, cbLabel, cbTooltip);
	self:SetTooltipFunc(initCheckboxTooltip);

	self.Checkbox:Init(cbSetting:GetValue(), initCheckboxTooltip);
	self.cbrHandles:RegisterCallback(self.Checkbox, SettingsCheckboxMixin.Event.OnValueChanged, self.OnCheckboxValueChanged, self);

	local inserter = Settings.CreateDropdownOptionInserter(dropdownOptions);
	local initDropdownTooltip = Settings.CreateOptionsInitTooltip(dropdownSetting, initializer:GetName(), initializer:GetTooltip(), dropdownOptions);
	Settings.InitDropdown(self.Control.Dropdown, dropdownSetting, inserter, initDropdownTooltip);

	self.Control:SetEnabled(cbSetting:GetValue());
end

function SettingsCheckboxDropdownControlMixin:OnCheckboxValueChanged(value)
	local initializer = self:GetElementData();
	local cbSetting = initializer.data.cbSetting;
	cbSetting:SetValue(value);
	if value then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else 
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end

	self.Control:SetEnabled(value);
end

function SettingsCheckboxDropdownControlMixin:Release()
	self.Checkbox:Release();
	SettingsListElementMixin.Release(self);
end

function CreateSettingsCheckboxDropdownInitializer(cbSetting, cbLabel, cbTooltip, dropdownSetting, dropdownOptions, dropDownLabel, dropDownTooltip)
	local data =
	{
		name = cbLabel,
		tooltip = cbTooltip,
		cbSetting = cbSetting,
		cbLabel = cbLabel,
		cbTooltip = cbTooltip,
		dropdownSetting = dropdownSetting,
		dropdownOptions = dropdownOptions,
		dropDownLabel = dropDownLabel,
		dropDownTooltip = dropDownTooltip,
	};
	return Settings.CreateSettingInitializer("SettingsCheckboxDropdownControlTemplate", data);
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

function CreateSettingsAddOnDisabledLabelInitializer()
	local data = {};
	return Settings.CreateElementInitializer("SettingsAddOnDisabledLabelTemplate", data);
end