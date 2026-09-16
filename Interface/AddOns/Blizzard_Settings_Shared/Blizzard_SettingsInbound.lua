local select = select;
local error = error;
local type = type;
local securecallfunction = securecallfunction;
local unpack = unpack;
local CreateAndInitFromMixin = CreateAndInitFromMixin;
local CreateFromMixins = CreateFromMixins;
local PrivateSettingsCategoryMixin = CreateSecureMixinCopy(SettingsCategoryMixin);
local PrivateAddOnSettingMixin = CreateSecureMixinCopy(AddOnSettingMixin);
local PrivateProxySettingMixin = CreateSecureMixinCopy(ProxySettingMixin);
local PrivateSettingsListElementInitializer = CreateSecureMixinCopy(SettingsListElementInitializer);
local CreateVerticalLayout = CreateVerticalLayout;
local CreateCanvasLayout = CreateCanvasLayout;
local GenerateClosure = GenerateClosure;

local AttributeDelegate = CreateFrame("Frame");

local function ErrorIfFunctionArgs(...)
	for i = 1, select("#", ...) do
		if type(select(i, ...)) == "function" then
			error("Function values are not allowed for settings APIs");
			return nil;
		end
	end

	return ...;
end

local function SecureUnpackArgs(argTable, expectedNumArgs)
	return ErrorIfFunctionArgs(securecallfunction(unpack, argTable, 1, expectedNumArgs));
end

-- Allows function args, but only to be used if a function arg is explicitly expected (use SecureUnpackArgs by default in all other cases).
-- If a function is expected, ensure that it is wrapped in a closure prior to being assigned to the attribute so that taint is properly restored
-- before executing the wrapped function. This is also important to insecure references to secure functions from being washed of taint when
-- processed by the attribute handler.
local function UnpackArgs(argTable, expectedNumArgs)
	return securecallfunction(unpack, argTable, 1, expectedNumArgs);
end

-- Pass in function args to have them automatically wrapped in a closure. These wrapped functions are returned back in the same order they were passed in
-- IMPORTANT: Pass ALL arguments to settings that could potentially be functions through here. This ensures that taint state is captured correctly, preventing taint-laundering exploits
local function SecureWrapFunctionArgs(...)
	local wrappedArgs = {};

	local numArgs = select("#", ...);
	for i = 1, numArgs do
		local arg = select(i, ...);
		if type(arg) == "function" then
			wrappedArgs[i] = GenerateClosure(arg);
		else
			wrappedArgs[i] = arg;
		end
	end

	return unpack(wrappedArgs, 1, numArgs);
end

SettingsInbound = {};

SettingsInbound.AssignLayoutToCategoryAttribute = "assign-layout-to-category";
SettingsInbound.AssignTutorialToCategoryAttribute = "assign-tutorial-to-category";
SettingsInbound.CreateAddOnSettingAttribute = "create-add-on-setting";
SettingsInbound.CreateProxySettingAttribute = "create-proxy-setting";
SettingsInbound.CreateElementInitializerAttribute = "create-element-initializer";
SettingsInbound.CreateSettingInitializerAttribute = "create-setting-initializer";
SettingsInbound.CreatePanelInitializerAttribute = "create-panel-initializer";
SettingsInbound.OnSettingValueChangedAttribute = "on-setting-value-changed";
SettingsInbound.RegisterCanvasLayoutCategoryAttribute = "register-canvas-layout-category";
SettingsInbound.RegisterCanvasLayoutSubcategoryAttribute = "register-canvas-layout-subcategory";
SettingsInbound.RegisterCategoryAttribute = "register-category";
SettingsInbound.RegisterInitializerAttribute = "register-initializer";
SettingsInbound.RegisterSettingAttribute = "register-setting";
SettingsInbound.RegisterVerticalLayoutCategoryAttribute = "register-vertical-layout-category";
SettingsInbound.RegisterVerticalLayoutSubcategoryAttribute = "register-vertical-layout-subcategory";
SettingsInbound.RepairDisplayAttribute = "repair-display";
SettingsInbound.SetCurrentLayoutAttribute = "set-current-layout";
SettingsInbound.SetKeybindingsCategoryAttribute = "set-keybindings-category";

function SettingsInbound.RegisterCategory(category, group, addon)
	AttributeDelegate:SetAttribute(SettingsInbound.RegisterCategoryAttribute, { category, group, addon, });
end

function SettingsInbound.RegisterVerticalLayoutCategory(name)
	AttributeDelegate:SetAttribute(SettingsInbound.RegisterVerticalLayoutCategoryAttribute, name);
	return AttributeDelegate:GetSecureAttributeResults();
end

function SettingsInbound.RegisterVerticalLayoutSubcategory(parentCategory, name)
	AttributeDelegate:SetAttribute(SettingsInbound.RegisterVerticalLayoutSubcategoryAttribute, { parentCategory, name, });
	return AttributeDelegate:GetSecureAttributeResults();
end

function SettingsInbound.RegisterCanvasLayoutCategory(frame, name)
	AttributeDelegate:SetAttribute(SettingsInbound.RegisterCanvasLayoutCategoryAttribute, { frame, name, });
	return AttributeDelegate:GetSecureAttributeResults();
end

function SettingsInbound.RegisterCanvasLayoutSubcategory(parentCategory, frame, name)
	AttributeDelegate:SetAttribute(SettingsInbound.RegisterCanvasLayoutSubcategoryAttribute, { parentCategory, frame, name, });
	return AttributeDelegate:GetSecureAttributeResults();
end

function SettingsInbound.AssignLayoutToCategory(category, layout)
	AttributeDelegate:SetAttribute(SettingsInbound.AssignLayoutToCategoryAttribute, { category, layout, });
end

function SettingsInbound.SetKeybindingsCategory(category)
	AttributeDelegate:SetAttribute(SettingsInbound.SetKeybindingsCategoryAttribute, category);
end

function SettingsInbound.CreateAddOnSetting(categoryTbl, name, variable, variableKey, variableTbl, variableType, defaultValue)
	AttributeDelegate:SetAttribute(SettingsInbound.CreateAddOnSettingAttribute, { categoryTbl, name, variable, variableKey, variableTbl, variableType, defaultValue, });
	return AttributeDelegate:GetSecureAttributeResults();
end

function SettingsInbound.CreateProxySetting(categoryTbl, nameValue, variable, variableType, defaultValue, getValue, setValue)
	-- Function args must be wrapped. See comment above UnpackArgs.
	nameValue, variable, variableType, defaultValue, getValue, setValue = SecureWrapFunctionArgs(nameValue, variable, variableType, defaultValue, getValue, setValue);

	AttributeDelegate:SetAttribute(SettingsInbound.CreateProxySettingAttribute, { categoryTbl, nameValue, variable, variableType, defaultValue, getValue, setValue, });
	return AttributeDelegate:GetSecureAttributeResults();
end

function SettingsInbound.RegisterSetting(categoryTbl, setting)
	AttributeDelegate:SetAttribute(SettingsInbound.RegisterSettingAttribute, { categoryTbl, setting, });
end

local function SettingsInboundValueChangedCallback(unused_registrant, setting, value)
	AttributeDelegate:SetAttribute(SettingsInbound.OnSettingValueChangedAttribute, { setting, value });
end

function SettingsInbound.RegisterOnSettingValueChanged(variable)
	Settings.SetOnValueChangedCallback(variable, SettingsInboundValueChangedCallback, SettingsInbound);
end

function SettingsInbound.CreateElementInitializer(frameTemplate, data)
	AttributeDelegate:SetAttribute(SettingsInbound.CreateElementInitializerAttribute, { frameTemplate, data, });
	return AttributeDelegate:GetSecureAttributeResults();
end

function SettingsInbound.CreateSettingInitializer(frameTemplate, data)
	AttributeDelegate:SetAttribute(SettingsInbound.CreateSettingInitializerAttribute, { frameTemplate, data, });
	return AttributeDelegate:GetSecureAttributeResults();
end

function SettingsInbound.CreatePanelInitializer(frameTemplate, data)
	AttributeDelegate:SetAttribute(SettingsInbound.CreatePanelInitializerAttribute, { frameTemplate, data, });
	return AttributeDelegate:GetSecureAttributeResults();
end

function SettingsInbound.RegisterInitializer(category, initializer)
	AttributeDelegate:SetAttribute(SettingsInbound.RegisterInitializerAttribute, { category, initializer, });
end

function SettingsInbound.RepairDisplay()
	local dummy = true;
	AttributeDelegate:SetAttribute(SettingsInbound.RepairDisplayAttribute, dummy);
end

function SettingsInbound.SetCurrentLayout(layout)
	AttributeDelegate:SetAttribute(SettingsInbound.SetCurrentLayoutAttribute, layout);
end

function SettingsInbound.AssignTutorialToCategory(category, tooltip, callback)
	-- Function args must be wrapped. See comment above UnpackArgs.
	tooltip, callback = SecureWrapFunctionArgs(tooltip, callback);

	AttributeDelegate:SetAttribute(SettingsInbound.AssignTutorialToCategoryAttribute, { category, tooltip, callback, });
end

function AttributeDelegate:OnAttributeChanged(name, value)
	if name == SettingsInbound.RegisterCategoryAttribute then
		local category, group, addon = SecureUnpackArgs(value, 3);
		SettingsPanel:RegisterCategory(category, group, addon);
	elseif name == SettingsInbound.RegisterVerticalLayoutCategoryAttribute then
		local category = CreateAndInitFromMixin(PrivateSettingsCategoryMixin, value);
		local layout = CreateVerticalLayout();
		SettingsPanel:AssignLayoutToCategory(category, layout);
		self:SetSecureAttributeResults(category, layout);
	elseif name == SettingsInbound.RegisterVerticalLayoutSubcategoryAttribute then
		local parentCategory, categoryName = SecureUnpackArgs(value);

		-- Use PrivateSettingsCategoryMixin.CreateSubcategory to avoid taint.
		local subcategory = securecallfunction(PrivateSettingsCategoryMixin.CreateSubcategory, parentCategory, categoryName);
		local layout = CreateVerticalLayout();
		SettingsPanel:AssignLayoutToCategory(subcategory, layout);
		self:SetSecureAttributeResults(subcategory, layout);
	elseif name == SettingsInbound.RegisterCanvasLayoutCategoryAttribute then
		local frame, categoryName = SecureUnpackArgs(value);
		local category = CreateAndInitFromMixin(PrivateSettingsCategoryMixin, categoryName);
		local layout = CreateCanvasLayout(frame);
		SettingsPanel:AssignLayoutToCategory(category, layout);
		self:SetSecureAttributeResults(category, layout);
	elseif name == SettingsInbound.RegisterCanvasLayoutSubcategoryAttribute then
		local parentCategory, frame, categoryName = SecureUnpackArgs(value);

		-- Use PrivateSettingsCategoryMixin.CreateSubcategory to avoid taint.
		local subcategory = securecallfunction(PrivateSettingsCategoryMixin.CreateSubcategory, parentCategory, categoryName);
		local layout = CreateCanvasLayout(frame);
		SettingsPanel:AssignLayoutToCategory(subcategory, layout);
		self:SetSecureAttributeResults(subcategory, layout);
	elseif name == SettingsInbound.AssignLayoutToCategoryAttribute then
		local category, layout = SecureUnpackArgs(value);
		SettingsPanel:AssignLayoutToCategory(category, layout);
	elseif name == SettingsInbound.SetKeybindingsCategoryAttribute then
		SettingsPanel:SetKeybindingsCategory(value);
	elseif name == SettingsInbound.CreateAddOnSettingAttribute then
		local categoryTbl, settingName, variable, variableKey, variableTbl, variableType, defaultValue = SecureUnpackArgs(value);
		local setting = CreateAndInitFromMixin(PrivateAddOnSettingMixin, settingName, variable, variableKey, variableTbl, variableType, defaultValue);
		SettingsPanel:RegisterSetting(categoryTbl, setting);
		self:SetSecureAttributeResults(setting);
	elseif name == SettingsInbound.CreateProxySettingAttribute then
		local categoryTbl, settingName, variable, variableType, defaultValue, getValue, setValue = UnpackArgs(value);
		local setting = CreateAndInitFromMixin(PrivateProxySettingMixin, settingName, variable, variableType, defaultValue, getValue, setValue);
		SettingsPanel:RegisterSetting(categoryTbl, setting);
		self:SetSecureAttributeResults(setting);
	elseif name == SettingsInbound.RegisterSettingAttribute then
		local categoryTbl, setting = SecureUnpackArgs(value);
		SettingsPanel:RegisterSetting(categoryTbl, setting);
	elseif name == SettingsInbound.RegisterInitializerAttribute then
		local category, initializer = SecureUnpackArgs(value);
		SettingsPanel:RegisterInitializer(category, initializer);
	elseif name == SettingsInbound.CreateElementInitializerAttribute then
		local frameTemplate, data = SecureUnpackArgs(value);
		local initializer = CreateFromMixins(SettingsListElementInitializer);
		initializer:Init(frameTemplate, data);
		self:SetSecureAttributeResults(initializer);
	elseif name == SettingsInbound.CreateSettingInitializerAttribute then
		local frameTemplate, data = SecureUnpackArgs(value);
		local initializer = CreateFromMixins(PrivateSettingsListElementInitializer);
		initializer:Init(frameTemplate, data);
		
		local setting = securecallfunction(PrivateSettingsListElementInitializer.GetSetting, initializer);
		if setting then
			local settingName = securecallfunction(setting.GetName, setting);
			initializer:AddSearchTags(settingName);
		end

		self:SetSecureAttributeResults(initializer);
	elseif name == SettingsInbound.CreatePanelInitializerAttribute then
		local frameTemplate, data = SecureUnpackArgs(value);
		local initializer = CreateFromMixins(SettingsListPanelInitializer);
		initializer:Init(frameTemplate, data);

		local settings = data.settings;
		if settings then
			local tags = {};
			for _, setting in pairs(settings) do
				table.insert(tags, setting:GetName());
			end
			initializer:AddSearchTags(unpack(tags));
		end

		self:SetSecureAttributeResults(initializer);
	elseif name == SettingsInbound.OnSettingValueChangedAttribute then
		local setting, newValue = SecureUnpackArgs(value);
		SettingsPanel:OnSettingValueChanged(setting, newValue);
	elseif name == SettingsInbound.RepairDisplayAttribute then
		SettingsPanel:RepairDisplay();
	elseif name == SettingsInbound.SetCurrentLayoutAttribute then
		SettingsPanel:SetCurrentLayout(value);
	elseif name == SettingsInbound.AssignTutorialToCategoryAttribute then
		local category, tooltip, callback = UnpackArgs(value);
		if category then
			category:SetCategoryTutorialInfo(tooltip, callback);
		end
	end
end

function AttributeDelegate:SetSecureAttributeResults(...)
	self.secureAttributeResults = { ... };
end

function AttributeDelegate:GetSecureAttributeResults()
	return unpack(self.secureAttributeResults);
end

AttributeDelegate:SetScript("OnAttributeChanged", AttributeDelegate.OnAttributeChanged);
AttributeDelegate:SetForbidden();
