--[[
	Names native types for clarity of use as function arguments.
	RegisterSetting(..., nil, "boolean", true);
	RegisterSetting(..., Settings.DefaultVarLocation, Settings.VarType.Bool, Settings.Defaults.True)
--]]
Settings = 
{
	DefaultVarLocation = nil,
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

SettingsInitializedRegistry = CreateFromMixins(CallbackRegistryMixin);
SettingsInitializedRegistry:SetUndefinedEventsAllowed(true);
SettingsInitializedRegistry:OnLoad();

SettingsSearchableElementMixin = {};

function SettingsSearchableElementMixin:AddSearchTags(...)
	if not self.searchTags then
		self.searchTags = {};
	end

	for index = 1, select("#", ...) do
		local tag = select(index, ...);
		if type(tag) == "string" then
			table.insert(self.searchTags, tag:upper());
		end
	end
end

function SettingsSearchableElementMixin:MatchesSearchTags(words)
	if self.searchTags then
		for _, val1 in ipairs(words) do
			if strlen(val1) >= 3 then
				for _, val2 in ipairs(self.searchTags) do
					if string.find(val2, val1, nil, true) then
						return true;
					end
				end
			end
		end
	end
	return false;
end

function Settings.CreateCanvasMixin()
	local canvas = CreateFromMixins(SettingsCanvasMixin);
	return canvas;
end

function Settings.CreateCategory(name)
	local category = CreateFromMixins(SettingsCategoryMixin);
	category:Init(name);
	return category;
end

function Settings.AssignLayoutToCategory(category, layout)
	SettingsPanel:AssignLayoutToCategory(category, layout);
end

function Settings.RegisterCategory(category, group)
	local addon = false;
	SettingsPanel:RegisterCategory(category, group, addon);
end

function Settings.RegisterAddOnCategory(category)
	local addon = true;
	SettingsPanel:RegisterCategory(category, nil, addon);
end

function Settings.SetKeybindingsCategory(category)
	SettingsPanel:SetKeybindingsCategory(category);
end

function Settings.OpenToCategory(categoryNameOrFrame, scrollToElementName)
	return SettingsPanel:OpenToCategory(categoryNameOrFrame, scrollToElementName);
end

function Settings.SafeLoadBindings(bindingSet)
	if not IsOnGlueScreen() then
		LoadBindings(bindingSet);
	end
end

function Settings.RegisterVerticalLayoutCategory(name)
	local category = Settings.CreateCategory(name);
	local layout = CreateVerticalLayout(category);
	Settings.AssignLayoutToCategory(category, layout);
	return category, layout;
end

function Settings.RegisterVerticalLayoutSubcategory(parentCategory, name)
	local subcategory = parentCategory:CreateSubcategory(name);
	local layout = CreateVerticalLayout(subcategory);
	Settings.AssignLayoutToCategory(subcategory, layout);
	return subcategory, layout;
end

function Settings.RegisterCanvasLayoutCategory(frame, name)
	local category = Settings.CreateCategory(name);
	local layout = CreateCanvasLayout(frame);
	Settings.AssignLayoutToCategory(category, layout);
	return category, layout;
end

function Settings.RegisterCanvasLayoutSubcategory(parentCategory, frame, name)
	local subcategory = parentCategory:CreateSubcategory(name);
	local layout = CreateCanvasLayout(frame);
	Settings.AssignLayoutToCategory(subcategory, layout);
	return subcategory, layout;
end

function Settings.RegisterInitializer(category, initializer)
	SettingsPanel:RegisterInitializer(category, initializer);
end

function Settings.RegisterGroups(...)
	SettingsPanel:RegisterGroups(...);
end

function Settings.RegisterProxySetting(categoryTbl, variable, variableTbl, variableType, name, defaultValue, getValue, setValue, commitValue)
	local setting = CreateAndInitFromMixin(ProxySettingMixin, name, variable, variableTbl, variableType, defaultValue, getValue, setValue, commitValue);
	SettingsPanel:RegisterSetting(categoryTbl, setting);
	return setting;
end

function Settings.RegisterCVarSetting(categoryTbl, variable, variableType, name)
	local setting = CreateAndInitFromMixin(CVarSettingMixin, name, variable, variableType);
	SettingsPanel:RegisterSetting(categoryTbl, setting);
	return setting;
end

function Settings.RegisterModifiedClickSetting(categoryTbl, variable, name, defaultValue)
	local setting = CreateAndInitFromMixin(ModifiedClickSettingMixin, name, variable, defaultValue);
	SettingsPanel:RegisterSetting(categoryTbl, setting);
	return setting;
end

function Settings.GetCategory(name)
	return SettingsPanel:GetCategory(name);
end

function Settings.GetSetting(variable)
	return SettingsPanel:GetSetting(variable);
end

function Settings.GetValue(variable)
	local setting = Settings.GetSetting(variable);
	if setting then
		return setting:GetValue();
	-- Uncomment to find any code accessing settings before they've been registered.
	-- Must be resolved before launch and will require mainline setting definitions to be
	-- converted from addon to shared code.
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

local SettingsDropDownTextContainerMixin = {};

function SettingsDropDownTextContainerMixin:Init()
	self.data = {};
end

function SettingsDropDownTextContainerMixin:GetData()
	return self.data;
end

function SettingsDropDownTextContainerMixin:Add(value, label, tooltip)
	local data = {label = label, tooltip = tooltip, value = value};
	table.insert(self.data, data);
	return data;
end

function Settings.CreateDropDownTextContainer()
	local container = CreateFromMixins(SettingsDropDownTextContainerMixin);
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
	GameTooltip_AddNormalLine(SettingsTooltip, name);
	if tooltip then
		if type(tooltip) == "function" then
			GameTooltip_AddHighlightLine(SettingsTooltip, tooltip());
		else
			GameTooltip_AddHighlightLine(SettingsTooltip, tooltip);
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

function Settings.CreateModifiedClickOptions(tooltips)
	local function GetOptions(options)
		local container = Settings.CreateDropDownTextContainer();
		container:Add("ALT", ALT_KEY, tooltips[1]);
		container:Add("CTRL", CTRL_KEY, tooltips[2]);
		container:Add("SHIFT", SHIFT_KEY, tooltips[3]);
		container:Add("NONE", NONE_KEY, tooltips[4]);
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
	local initializer = CreateFromMixins(SettingsListElementInitializer);
	initializer:Init(frameTemplate, data);
	local setting = initializer:GetSetting();
	if setting then
		initializer:AddSearchTags(setting:GetName());
	end
	return initializer;
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

function Settings.CreateCheckBoxInitializer(setting, tooltip)
	assert(setting:GetVariableType() == "boolean");
	local options = nil;
	return Settings.CreateControlInitializer("SettingsCheckBoxControlTemplate", setting, options, tooltip);
end

function Settings.CreateSliderInitializer(setting, options, tooltip)
	assert((setting:GetVariableType() == "number") and (options ~= nil));
	return Settings.CreateControlInitializer("SettingsSliderControlTemplate", setting, options, tooltip);
end

function Settings.CreateDropDownInitializer(setting, options, tooltip)
	assert(options ~= nil);
	return Settings.CreateControlInitializer("SettingsTextDropDownControlTemplate", setting, options, tooltip);
end

local function AddInitializerToLayout(category, initializer)
	local layout = SettingsPanel:GetLayout(category);
	layout:AddInitializer(initializer);
end

function Settings.CreateCheckBox(category, setting, tooltip)
	local initializer = Settings.CreateCheckBoxInitializer(setting, tooltip);
	AddInitializerToLayout(category, initializer);
	return initializer;
end

function Settings.CreateSlider(category, setting, options, tooltip)
	local initializer = Settings.CreateSliderInitializer(setting, options, tooltip);
	AddInitializerToLayout(category, initializer);
	return initializer;
end

function Settings.CreateDropDown(category, setting, options, tooltip)
	local initializer = Settings.CreateDropDownInitializer(setting, options, tooltip);
	AddInitializerToLayout(category, initializer);
	return initializer;
end

function Settings.CreateDropDownInitTooltip(setting, name, tooltip, options)
	local function InitTooltip()
		Settings.InitTooltip(name, tooltip);

		local optionData = options();
		local default = setting:GetDefaultValue();
		local warningOption = nil;
		local defaultOption = nil;
		for index, option in ipairs(optionData) do
			local default = option.value == default;
			if default then
				defaultOption = option;
			end
			
			if option.warning then
				warningOption = option;
			end

			if option.tooltip then
				GameTooltip_AddBlankLineToTooltip(SettingsTooltip);

				local optionTooltip = nil;

				local optionLabel = nil;
				if option.disabled then
					optionLabel = DISABLED_FONT_COLOR:WrapTextInColorCode(option.label);
				else
					optionLabel = NORMAL_FONT_COLOR:WrapTextInColorCode(option.label);
				end

				if option.disabled then
					optionTooltip = DISABLED_FONT_COLOR:WrapTextInColorCode(option.tooltip);
				elseif default and option.recommend then
					optionTooltip = GREEN_FONT_COLOR:WrapTextInColorCode(option.tooltip);
				else
					optionTooltip = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(option.tooltip);
				end
				GameTooltip_AddDisabledLine(SettingsTooltip, string.format("%s: %s", optionLabel, optionTooltip));

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

function Settings.InitSelectionDropDown(selectionDropDown, setting, getOptions, width, initTooltip)
	local options = getOptions();
	local settingValue = setting:GetValue();
	if not settingValue then
		-- In case the setting get value was a lazy initializer, attempt once again.
		settingValue = setting:GetValue();
	end
	assert(settingValue ~= nil);

	local selectionIndex = FindInTableIf(options, function(data)
		return data.value == settingValue;
	end);
	
	local result = selectionDropDown:SetupSelections(options, selectionIndex);
	selectionDropDown.Button:SetTooltipFunc(initTooltip);

	-- Temporary to be removed once a bug has been fixed.
	if not result then
		UIErrorsFrame:AddExternalWarningMessage(("Failed to setup setting '%s'"):format(setting:GetName()), settingValue);
		print(("Failed to setup setting '%s'"):format(setting:GetName()), settingValue);
		Dump(options);
	end
	return selectionIndex;
end

function Settings.SetupCVarCheckBox(category, variable, label, tooltip)
	local setting = Settings.RegisterCVarSetting(category, variable, "boolean", label);
	local initializer = Settings.CreateCheckBox(category, setting, tooltip);
	return setting, initializer;
end

function Settings.SetupCVarSlider(category, variable, options, label, tooltip)
	local setting = Settings.RegisterCVarSetting(category, variable, "number", label);
	local initializer = Settings.CreateSlider(category, setting, options, tooltip);
	return setting, initializer;
end

function Settings.SetupCVarDropDown(category, variable, variableType, options, label, tooltip)
	local setting = Settings.RegisterCVarSetting(category, variable, variableType, label);
	local initializer = Settings.CreateDropDown(category, setting, options, tooltip);
	return setting, initializer;
end

function Settings.SetupModifiedClickDropDown(category, variable, defaultKey, label, tooltips, tooltip)
	local options = Settings.CreateModifiedClickOptions(tooltips);
	local setting = Settings.RegisterModifiedClickSetting(category, variable, label, defaultKey);
	local initializer = Settings.CreateDropDown(category, setting, options, tooltip);
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

function Settings.TryChangeBindingSet(checkBox)
	if not checkBox:GetChecked() then
		checkBox:SetChecked(true);

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