--[[
	Names native types for clarity of use as function arguments.
	RegisterSetting(..., nil, "boolean", true);
	RegisterSetting(..., Settings.VarType.Bool, Settings.Defaults.True)
--]]
Settings = 
{
	CannotDefault = nil,
};

Settings.VarType = 
{
	Boolean = "boolean",
	String = "string",
	Number = "number",
};

Settings.Default = 
{
	True = true,
	False = false,
};

Settings.CategorySet = EnumUtil.MakeEnum("Game", "AddOns");

Settings.CommitFlag = FlagsUtil.MakeFlags(
	"ClientRestart", 
	"GxRestart", 
	"UpdateWindow", 
	"SaveBindings", 
	"Revertable", 
	"Apply",
	"IgnoreApply"
);
Settings.CommitFlag.None = 0;

SettingsCallbackRegistry = CreateFromMixins(CallbackRegistryMixin);
SettingsCallbackRegistry:SetUndefinedEventsAllowed(true);
SettingsCallbackRegistry:GenerateCallbackEvents(
	{
		"OnValueChanged",
	}
);
SettingsCallbackRegistry:OnLoad();

SettingsSearchableElementMixin = {};

function SettingsSearchableElementMixin:AddSearchTags(...)
	if not self.searchTags then
		self.searchTags = {};
	end

	for index = 1, select("#", ...) do
		local tag = select(index, ...);
		if type(tag) == "string" and tag ~= "" then
			table.insert(self.searchTags, tag:upper());
		end
	end
end

function SettingsSearchableElementMixin:MatchesSearchTags(words)
	if self.searchTags then
		for _, val1 in ipairs(words) do
			for _, val2 in ipairs(self.searchTags) do
				local first, last = string.find(val2, val1, nil, true);
				if first and last then
					return last - first;
				end
			end
		end
	end
	return nil;
end

function SettingsSearchableElementMixin:SetSearchIgnoredInLayout(layout)
	if not self.searchIgnoredLayouts then
		self.searchIgnoredLayouts = {};
	end

	table.insert(self.searchIgnoredLayouts, layout);
end

function SettingsSearchableElementMixin:IsSearchIgnoredInLayout(layout)
	if not self.searchIgnoredLayouts then
		return false;
	end

	return tContains(self.searchIgnoredLayouts, layout);
end

function SettingsSearchableElementMixin:AddShownPredicate(func)
	if not self.shownPredicates then
		self.shownPredicates = {};
	end
	table.insert(self.shownPredicates, func);
end

function SettingsSearchableElementMixin:GetShownPredicates()
	return self.shownPredicates;
end

function SettingsSearchableElementMixin:ShouldShow()
	local prereqs = self:GetShownPredicates();
	if prereqs then
		for index, prereq in ipairs(prereqs) do
			if not prereq() then
				return false;
			end
		end
	end
	return true;
end

function Settings.CreateCategory(name)
	local category = CreateFromMixins(SettingsCategoryMixin);
	category:Init(name);
	return category;
end

function Settings.AssignLayoutToCategory(category, layout)
	SettingsInbound.AssignLayoutToCategory(category, layout);
end

function Settings.RegisterCategory(category, group)
	local addon = false;
	SettingsInbound.RegisterCategory(category, group, addon);
end

function Settings.RegisterAddOnCategory(category)
	local addon = true;
	local group = nil;
	SettingsInbound.RegisterCategory(category, group, addon);
end

function Settings.SetKeybindingsCategory(category)
	SettingsInbound.SetKeybindingsCategory(category);
end

function Settings.OpenToCategory(categoryID, scrollToElementName)
	return SettingsInbound.OpenToCategory(categoryID, scrollToElementName);
end

function Settings.SafeLoadBindings(bindingSet)
	if not IsOnGlueScreen() then
		LoadBindings(bindingSet);
	end
end

function Settings.RegisterVerticalLayoutCategory(name)
	return SettingsInbound.RegisterVerticalLayoutCategory(name);
end

function Settings.RegisterVerticalLayoutSubcategory(parentCategory, name)
	return SettingsInbound.RegisterVerticalLayoutSubcategory(parentCategory, name);
end

function Settings.RegisterCanvasLayoutCategory(frame, name)
	return SettingsInbound.RegisterCanvasLayoutCategory(frame, name);
end

function Settings.RegisterCanvasLayoutSubcategory(parentCategory, frame, name)
	return SettingsInbound.RegisterCanvasLayoutSubcategory(parentCategory, frame, name);
end

function Settings.RegisterInitializer(category, initializer)
	SettingsInbound.RegisterInitializer(category, initializer);
end

function Settings.RegisterAddOnSetting(categoryTbl, variable, variableKey, variableTbl, variableType, name, defaultValue)
	return SettingsInbound.CreateAddOnSetting(categoryTbl, name, variable, variableKey, variableTbl, variableType, defaultValue);
end

function Settings.RegisterProxySetting(categoryTbl, variable, variableType, name, defaultValue, getValue, setValue)
	return SettingsInbound.CreateProxySetting(categoryTbl, name, variable, variableType, defaultValue, getValue, setValue);
end

function Settings.RegisterCVarSetting(categoryTbl, variable, variableType, name)
	local setting = CreateAndInitFromMixin(CVarSettingMixin, name, variable, variableType);
	SettingsInbound.RegisterSetting(categoryTbl, setting);
	return setting;
end

function Settings.RegisterModifiedClickSetting(categoryTbl, variable, name, defaultValue)
	local setting = CreateAndInitFromMixin(ModifiedClickSettingMixin, name, variable, defaultValue);
	SettingsInbound.RegisterSetting(categoryTbl, setting);
	return setting;
end

function Settings.AssignTutorialToCategory(category, tooltip, callback)
	SettingsInbound.AssignTutorialToCategory(category, tooltip, callback);
end

function Settings.GetCategory(name)
	return SettingsPanel:GetCategory(name);
end

function Settings.GetSetting(variable)
	return SettingsPanel:GetSetting(variable);
end

function Settings.NotifyUpdate(variable)
	local setting = Settings.GetSetting(variable);
	if setting then
		setting:NotifyUpdate();
	end
end

function Settings.GetValue(variable)
	local setting = Settings.GetSetting(variable);
	if setting then
		return setting:GetValue();
	-- Uncomment to find any code accessing settings before they've been registered.
	-- Unretrievable values are not necessarily an error, depend on race conditions, and need
	-- to be evaluated on a case by case basis.
	--else
	--	error(string.format("Setting for variable '%s' did not exist.", variable))
	end
	return nil;
end

function Settings.SetValue(variable, value, force)
	local setting = Settings.GetSetting(variable);
	if setting then
		setting:SetValue(value, force);
	else
		error(string.format("Setting for variable '%s' did not exist.", variable))
	end
end

local SettingsControlTextContainerMixin = {};

function SettingsControlTextContainerMixin:Init()
	self.data = {};
end

function SettingsControlTextContainerMixin:GetData()
	return self.data;
end

function SettingsControlTextContainerMixin:Add(value, label, tooltip)
	local data = {text = label, label = label, tooltip = tooltip, value = value};
	table.insert(self.data, data);
	return data;
end

function Settings.CreateControlTextContainer()
	local container = CreateFromMixins(SettingsControlTextContainerMixin);
	container:Init();
	return container;
end

function Settings.WrapTooltipWithBinding(tooltipString, action)
	return function()
		local bindingKey = GetBindingKey(action);
		if bindingKey and bindingKey ~= "" then
			local bindingText = NORMAL_FONT_COLOR:WrapTextInColorCode(GetBindingText(bindingKey));
			return string.format("%s (%s)", tooltipString, bindingText);
		end
		return tooltipString;
	end
end

function Settings.InitTooltip(name, tooltip)
	GameTooltip_AddHighlightLine(SettingsTooltip, name);
	if tooltip then
		if type(tooltip) == "function" then
			GameTooltip_AddNormalLine(SettingsTooltip, tooltip());
		else
			GameTooltip_AddNormalLine(SettingsTooltip, tooltip);
		end
	end
end

SettingsSliderOptionsMixin = {};

function SettingsSliderOptionsMixin:SetLabelFormatter(labelType, value)	
	if not self.formatters then
		self.formatters = {};
	end
	self.formatters[labelType] =  CreateMinimalSliderFormatter(labelType, value);
end

function Settings.CreateSliderOptions(minValue, maxValue, rate)
	local options = CreateFromMixins(SettingsSliderOptionsMixin);
	options.minValue = minValue or 0;
	options.maxValue = maxValue or 1;
	options.steps = (rate and (maxValue - minValue) / rate) or 100;
	return options;
end

function Settings.CreateModifiedClickOptions(tooltips, mustChooseKey)
	local function GetOptions(options)
		local container = Settings.CreateControlTextContainer();
		container:Add("ALT", ALT_KEY, tooltips[1]);
		container:Add("CTRL", CTRL_KEY, tooltips[2]);
		container:Add("SHIFT", SHIFT_KEY, tooltips[3]);
		if not mustChooseKey then
			container:Add("NONE", NONE_KEY, tooltips[4]);
		end
		return container:GetData();
	end
	return GetOptions;
end

function Settings.CreateSettingInitializerData(setting, options, tooltip)
	local data = 
	{
		setting = setting,
		name = setting:GetName(),
		options = options or {},
		tooltip = tooltip,
	};
	return data;
end

function Settings.CreateElementInitializer(frameTemplate, data)
	local initializer = CreateFromMixins(SettingsListElementInitializer);
	initializer:Init(frameTemplate, data);
	return initializer;
end

function Settings.CreateSettingInitializer(frameTemplate, data)
	return SettingsInbound.CreateSettingInitializer(frameTemplate, data);
end

function Settings.CreatePanelInitializer(frameTemplate, data)
	local initializer = CreateFromMixins(SettingsListPanelInitializer);
	initializer:Init(frameTemplate);
	initializer.data = data;
	local settings = data.settings;
	if settings then
		local tags = {};
		for _, setting in pairs(settings) do
			table.insert(tags, setting:GetName());
		end
		initializer:AddSearchTags(unpack(tags));
	end
	return initializer;
end

function Settings.CreateControlInitializer(frameTemplate, setting, options, tooltip)
	local data = Settings.CreateSettingInitializerData(setting, options, tooltip);
	return Settings.CreateSettingInitializer(frameTemplate, data);
end

function Settings.CreateCheckboxInitializer(setting, options, tooltip)
	assert(setting:GetVariableType() == "boolean");
	return Settings.CreateControlInitializer("SettingsCheckboxControlTemplate", setting, options, tooltip);
end

function Settings.CreateSliderInitializer(setting, options, tooltip)
	assert((setting:GetVariableType() == "number") and (options ~= nil));
	return Settings.CreateControlInitializer("SettingsSliderControlTemplate", setting, options, tooltip);
end

function Settings.CreateDropdownInitializer(setting, options, tooltip)
	assert(options ~= nil);
	return Settings.CreateControlInitializer("SettingsDropdownControlTemplate", setting, options, tooltip);
end

local function AddInitializerToLayout(category, initializer)
	local layout = SettingsPanel:GetLayout(category);
	layout:AddInitializer(initializer);
end

function Settings.CreateCheckbox(category, setting, tooltip)
	return Settings.CreateCheckboxWithOptions(category, setting, nil, tooltip);
end

function Settings.CreateCheckboxWithOptions(category, setting, options, tooltip)
	local initializer = Settings.CreateCheckboxInitializer(setting, options, tooltip);
	AddInitializerToLayout(category, initializer);
	return initializer;
end

function Settings.CreateSlider(category, setting, options, tooltip)
	local initializer = Settings.CreateSliderInitializer(setting, options, tooltip);
	AddInitializerToLayout(category, initializer);
	return initializer;
end

function Settings.CreateDropdown(category, setting, options, tooltip)
	local initializer = Settings.CreateDropdownInitializer(setting, options, tooltip);
	AddInitializerToLayout(category, initializer);
	return initializer;
end

function Settings.CreateOptionsInitTooltip(setting, name, tooltip, options)
	local function InitTooltip()
		Settings.InitTooltip(name, tooltip);

		local optionData = type(options) == 'function' and options() or options;
		local default = setting:GetDefaultValue();
		local warningOption = nil;
		local defaultOption = nil;
		for _, option in ipairs(optionData) do
			local isDefault = option.value == default;
			if isDefault then
				defaultOption = option;
			end
			
			if option.warning then
				warningOption = option;
			end

			if option.tooltip or option.disabled then
				GameTooltip_AddBlankLineToTooltip(SettingsTooltip);

				local optionTooltip = nil;

				local optionLabel = nil;
				if option.disabled then
					optionLabel = DISABLED_FONT_COLOR:WrapTextInColorCode(option.label);
				else
					optionLabel = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(option.label);
				end

				if option.tooltip then
					if option.disabled then
						optionTooltip = DISABLED_FONT_COLOR:WrapTextInColorCode(option.tooltip);
					elseif isDefault and option.recommend then
						optionTooltip = GREEN_FONT_COLOR:WrapTextInColorCode(option.tooltip);
					else
						optionTooltip = NORMAL_FONT_COLOR:WrapTextInColorCode(option.tooltip);
					end
					GameTooltip_AddDisabledLine(SettingsTooltip, string.format("%s: %s", optionLabel, optionTooltip));
				else
					GameTooltip_AddDisabledLine(SettingsTooltip, string.format("%s:", optionLabel));
				end

				if option.disabled then
					GameTooltip_AddErrorLine(SettingsTooltip, option.disabled);
				end
			end
		end

		if defaultOption and defaultOption.recommend then
			GameTooltip_AddBlankLineToTooltip(SettingsTooltip);
			local coloredLabel =  GREEN_FONT_COLOR:WrapTextInColorCode(defaultOption.label);
			GameTooltip_AddHighlightLine(SettingsTooltip, string.format("%s: %s", VIDEO_OPTIONS_RECOMMENDED, coloredLabel));
		end
		
		if warningOption and warningOption.value == setting:GetValue() then
			GameTooltip_AddBlankLineToTooltip(SettingsTooltip);
			GameTooltip_AddNormalLine(SettingsTooltip, WARNING_FONT_COLOR:WrapTextInColorCode(warningOption.warning));
		end
		
		if setting:HasCommitFlag(Settings.CommitFlag.ClientRestart) then
			GameTooltip_AddBlankLineToTooltip(SettingsTooltip);
			GameTooltip_AddErrorLine(SettingsTooltip, VIDEO_OPTIONS_NEED_CLIENTRESTART);
		end
	end
	return InitTooltip;
end

function Settings.CreateDropdownButton(optionDescription, optionData, isSelected, setSelected)
	local truncated = false;

	local function OnEnter(button)
		button.HighlightBGTex:SetAlpha(0.15);

		local description = button:GetElementDescription();
		if description:IsEnabled() and not description:IsSelected() then
			button.Text:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB());
		end

		if truncated then
			MenuUtil.ShowTooltip(button, function(tooltip)
				GameTooltip_SetTitle(tooltip, optionData.label);
			end);
		end

		if optionData.onEnter then
			optionData.onEnter(optionData);
		end
	end

	local function OnLeave(button)
		button.HighlightBGTex:SetAlpha(0);

		local description = button:GetElementDescription();
		if description:IsEnabled() and not description:IsSelected() then
			button.Text:SetTextColor(VERY_LIGHT_GRAY_COLOR:GetRGB());
		end

		MenuUtil.HideTooltip(button);
	end

	optionDescription:AddInitializer(function(button, description, menu)
		button:SetScript("OnClick", function(button, buttonName)
			description:Pick(MenuInputContext.MouseButton, buttonName);
		end);

		-- This button template is modified in Languages.lua to hide the text and display
		-- a texture for each locale, so we need to redisplay the text. We don't have to worry
		-- about that texture here because it is managed by the compositor.
		button.Text:Show();
		button.Text:SetTextToFit(optionData.label);
		button.Text:SetWidth(button.Text:GetWidth() + 10);

		button.HighlightBGTex:SetAlpha(0);

		local fontColor = nil;
		if description:IsSelected() then
			button.Text:SetTextColor(NORMAL_FONT_COLOR:GetRGBA());
		elseif description:IsEnabled() then
			button.Text:SetTextColor(VERY_LIGHT_GRAY_COLOR:GetRGB());
		else
			button.Text:SetTextColor(DISABLED_FONT_COLOR:GetRGB());
		end

		truncated = button.Text:IsTruncated();

		button:Layout();
	end);

	MenuUtil.SetElementText(optionDescription, optionData.text);
	optionDescription:SetIsSelected(isSelected);
	optionDescription:SetResponder(setSelected);
	optionDescription:SetOnEnter(OnEnter); 
	optionDescription:SetOnLeave(OnLeave);
	optionDescription:SetRadio(true);
	optionDescription:SetData(optionData);
end

function Settings.CreateDropdownOptionInserter(options)
	local function Inserter(rootDescription, isSelected, setSelected)
		for index, optionData in ipairs(options()) do
			local optionDescription = rootDescription:CreateTemplate("SettingsDropdownButtonTemplate");
			Settings.CreateDropdownButton(optionDescription, optionData, isSelected, setSelected);
		end
	end
	return Inserter;
end

function Settings.InitDropdown(dropdown, setting, elementInserter, initTooltip)
	-- The setting may have been backed by a lazy initializer that doesn't return correctly
	-- the first time it is called, so it's called again.
	local settingValue = setting:GetValue();
	if settingValue == nil then
		settingValue = setting:GetValue();
	end
	assertsafe(settingValue ~= nil, ("Missing value for setting '%s'"):format(setting:GetName()));
	
	local function IsSelected(optionData)
		return setting:GetValue() == optionData.value;
	end
	
	local function OnSelect(optionData)
		return setting:SetValue(optionData.value);
	end

	dropdown:SetDefaultText(CUSTOM);
	dropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetGridMode(MenuConstants.VerticalGridDirection);

		-- Settings.CreateDropdownOptionInserter
		elementInserter(rootDescription, IsSelected, OnSelect);
	end);
	
	dropdown:SetTooltipFunc(initTooltip);
	dropdown:SetDefaultTooltipAnchors();
	
	dropdown:SetScript("OnEnter", function()
		ButtonStateBehaviorMixin.OnEnter(dropdown);
		DefaultTooltipMixin.OnEnter(dropdown);
	end);
	
	dropdown:SetScript("OnLeave", function()
		ButtonStateBehaviorMixin.OnLeave(dropdown);
		DefaultTooltipMixin.OnLeave(dropdown);
	end);
end

function Settings.SetupCVarCheckbox(category, variable, label, tooltip)
	local setting = Settings.RegisterCVarSetting(category, variable, "boolean", label);
	local initializer = Settings.CreateCheckbox(category, setting, tooltip);
	return setting, initializer;
end

function Settings.SetupCVarSlider(category, variable, options, label, tooltip)
	local setting = Settings.RegisterCVarSetting(category, variable, "number", label);
	local initializer = Settings.CreateSlider(category, setting, options, tooltip);
	return setting, initializer;
end

function Settings.SetupCVarDropdown(category, variable, variableType, options, label, tooltip)
	local setting = Settings.RegisterCVarSetting(category, variable, variableType, label);
	local initializer = Settings.CreateDropdown(category, setting, options, tooltip);
	return setting, initializer;
end

function Settings.SetupModifiedClickDropdown(category, variable, defaultKey, label, tooltips, tooltip, mustChooseKey)
	local options = Settings.CreateModifiedClickOptions(tooltips, mustChooseKey);
	local setting = Settings.RegisterModifiedClickSetting(category, variable, label, defaultKey);
	local initializer = Settings.CreateDropdown(category, setting, options, tooltip);
	return setting, initializer;
end

function Settings.CreateCVarAccessorClosures(cvar, variableType)
	local cvarAccessor = CreateCVarAccessor(cvar, variableType);
	local getValue = GenerateClosure(cvarAccessor.GetValue, cvarAccessor);
	local setValue = GenerateClosure(cvarAccessor.SetValue, cvarAccessor);
	local getDefaultValue = GenerateClosure(cvarAccessor.GetDefaultValue, cvarAccessor);
	return getValue, setValue, getDefaultValue;
end

function Settings.SelectAccountBindings()
	LoadBindings(Enum.BindingSet.Account);
	SaveBindings(Enum.BindingSet.Account);
end

function Settings.SelectCharacterBindings()
	-- Save the account settings so that they're correctly copied over to character.
	SaveBindings(Enum.BindingSet.Account);
	-- Load the character bindings.
	LoadBindings(Enum.BindingSet.Character);
	-- Save the copy of the character settings so that the current binding set is updated.
	SaveBindings(Enum.BindingSet.Character);
end

function Settings.TryChangeBindingSet(checkbox)
	if not checkbox:GetChecked() then
		checkbox:SetChecked(true);

		StaticPopup_Show("CONFIRM_DELETING_CHARACTER_SPECIFIC_BINDINGS");
		return true;
	end

	Settings.SetValue("PROXY_CHARACTER_SPECIFIC_BINDINGS", true);
	return false;
end

function Settings.GetOrCreateSettingsGroup(groupID, order)
	local group = SettingsPanel:GetOrCreateGroup(groupID);
	group.order = order;
end

function Settings.LoadAddOnCVarWatcher(cvar, addOn)
	if Settings.GetValue(cvar) then
		UIParentLoadAddOn(addOn);
	else
		local function OnValueChanged(o, setting, value)
			UIParentLoadAddOn(addOn);
		end
		Settings.SetOnValueChangedCallback(cvar, OnValueChanged);
	end
end

function Settings.SetOnValueChangedCallback(variable, callback, owner)
	return SettingsCallbackRegistry:RegisterCallbackWithHandle(variable, callback, owner);
end

-- Alternative to listening for the SETTINGS_LOADED event.
function Settings.CallWhenRegistered(variable, callback, owner)
	local setting = Settings.GetSetting(variable);
	if setting then
		callback(setting:GetValue());
	else
		local handle = nil;
		local function OnInitialized(o, value)
			if handle then
				handle:Unregister();
			end
			callback(value);
		end
		handle = Settings.SetOnValueChangedCallback(variable, OnInitialized, owner);
	end
end

SettingsCallbackHandleContainerMixin = CreateFromMixins(CallbackHandleContainerMixin);

function SettingsCallbackHandleContainerMixin:Init()
	CallbackHandleContainerMixin.Init(self);
end

function SettingsCallbackHandleContainerMixin:SetOnValueChangedCallback(variable, callback, owner, ...)
	self:AddHandle(Settings.SetOnValueChangedCallback(variable, callback, owner, ...));
end

function Settings.CreateCallbackHandleContainer()
	local cbrHandles = CreateFromMixins(SettingsCallbackHandleContainerMixin);
	cbrHandles:Init();
	return cbrHandles;
end