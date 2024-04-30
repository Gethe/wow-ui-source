
SettingsInbound = {};

SettingsInbound.OpenToCategoryAttribute = "open-to-category";

SettingsInbound.RegisterCategoryAttribute = "register-category";

SettingsInbound.RegisterVerticalLayoutCategoryAttribute = "register-vertical-layout-category";
SettingsInbound.RegisterVerticalLayoutSubcategoryAttribute = "register-vertical-layout-subcategory";
SettingsInbound.RegisterCanvasLayoutCategoryAttribute = "register-canvas-layout-category";
SettingsInbound.RegisterCanvasLayoutSubcategoryAttribute = "register-canvas-layout-subcategory";

SettingsInbound.AssignLayoutToCategoryAttribute = "assign-layout-to-category";
SettingsInbound.SetKeybindingsCategoryAttribute = "set-keybindings-category";

SettingsInbound.CreateAddOnSettingAttribute = "create-add-on-setting";
SettingsInbound.RegisterSettingAttribute = "register-setting";
SettingsInbound.OnSettingValueChangedAttribute = "on-setting-value-changed";

SettingsInbound.CreateSettingInitializerAttribute = "create-initializer";
SettingsInbound.RegisterInitializerAttribute = "register-initializer";

SettingsInbound.RepairDisplayAttribute = "repair-display";
SettingsInbound.SetCurrentLayoutAttribute = "set-current-layout";

SettingsInbound.AssignTutorialToCategoryAttribute = "assign-tutorial-to-category";

function SettingsInbound.OpenToCategory(categoryID, scrollToElementName)
	SettingsPanel:SetAttribute(SettingsInbound.OpenToCategoryAttribute, { categoryID, scrollToElementName, });
	return SettingsPanel:GetSecureAttributeResults();
end

function SettingsInbound.RegisterCategory(category, group, addon)
	SettingsPanel:SetAttribute(SettingsInbound.RegisterCategoryAttribute, { category, group, addon, });
end

function SettingsInbound.RegisterVerticalLayoutCategory(name)
	SettingsPanel:SetAttribute(SettingsInbound.RegisterVerticalLayoutCategoryAttribute, name);
	return SettingsPanel:GetSecureAttributeResults();
end

function SettingsInbound.RegisterVerticalLayoutSubcategory(parentCategory, name)
	SettingsPanel:SetAttribute(SettingsInbound.RegisterVerticalLayoutSubcategoryAttribute, { parentCategory, name, });
	return SettingsPanel:GetSecureAttributeResults();
end

function SettingsInbound.RegisterCanvasLayoutCategory(frame, name)
	SettingsPanel:SetAttribute(SettingsInbound.RegisterCanvasLayoutCategoryAttribute, { frame, name, });
	return SettingsPanel:GetSecureAttributeResults();
end

function SettingsInbound.RegisterCanvasLayoutSubcategory(parentCategory, frame, name)
	SettingsPanel:SetAttribute(SettingsInbound.RegisterCanvasLayoutSubcategoryAttribute, { parentCategory, frame, name, });
	return SettingsPanel:GetSecureAttributeResults();
end

function SettingsInbound.AssignLayoutToCategory(category, layout)
	SettingsPanel:SetAttribute(SettingsInbound.AssignLayoutToCategoryAttribute, { category, layout, });
end

function SettingsInbound.SetKeybindingsCategory(category)
	SettingsPanel:SetAttribute(SettingsInbound.SetKeybindingsCategoryAttribute, category);
end

function SettingsInbound.CreateAddOnSetting(categoryTbl, name, variable, variableType, defaultValue)
	SettingsPanel:SetAttribute(SettingsInbound.CreateAddOnSettingAttribute, { categoryTbl, name, variable, variableType, defaultValue, });
	return SettingsPanel:GetSecureAttributeResults();
end

function SettingsInbound.RegisterSetting(categoryTbl, setting)
	SettingsPanel:SetAttribute(SettingsInbound.RegisterSettingAttribute, { categoryTbl, setting, });
end

local function SettingsInboundValueChangedCallback(unused_registrant, setting, value, oldValue, originalValue)
	SettingsPanel:SetAttribute(SettingsInbound.OnSettingValueChangedAttribute, { setting, value, oldValue, originalValue, });
end

function SettingsInbound.RegisterOnSettingValueChanged(variable)
	Settings.SetOnValueChangedCallback(variable, SettingsInboundValueChangedCallback, SettingsInbound);
end

function SettingsInbound.CreateSettingInitializer(frameTemplate, data)
	SettingsPanel:SetAttribute(SettingsInbound.CreateSettingInitializerAttribute, { frameTemplate, data, });
	return SettingsPanel:GetSecureAttributeResults();
end

function SettingsInbound.RegisterInitializer(category, initializer)
	SettingsPanel:SetAttribute(SettingsInbound.RegisterInitializerAttribute, { category, initializer, });
end

function SettingsInbound.RepairDisplay()
	local dummy = true;
	SettingsPanel:SetAttribute(SettingsInbound.RepairDisplayAttribute, dummy);
end

function SettingsInbound.SetCurrentLayout(layout)
	SettingsPanel:SetAttribute(SettingsInbound.SetCurrentLayoutAttribute, layout);
end

function SettingsInbound.AssignTutorialToCategory(category, tooltip, callback)
	SettingsPanel:SetAttribute(SettingsInbound.AssignTutorialToCategoryAttribute, { category, tooltip, callback, });
end