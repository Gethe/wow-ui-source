
-- TODO: Find a better place for this:
function AddTextOptionWithPreview(optionContainer, onEnterCallback, ...)
	local optionData = optionContainer:Add(...);
	optionData.onEnter = onEnterCallback;
end

function AddTextOptionsWithPreview(optionContainer, onEnterCallback, optionsTable)
	for index, optionDescription in ipairs(optionsTable) do
		AddTextOptionWithPreview(optionContainer, onEnterCallback, unpack(optionDescription));
	end

	return optionContainer:GetData();
end

-- END TODO

local function RegisterQuestTextContrast(category)
	local cvarName = "questTextContrast";
	if C_CVar.GetCVar(cvarName) == nil then
		return;
	end

	local function GetValue()
		return GetCVarNumberOrDefault(cvarName);
	end

	local function SetValue(value)
		SetCVar(cvarName, value);
	end

	local function OnOptionEnter(optionData)
		SettingsPanel.QuestTextPreview:UpdatePreview(optionData.value);
	end

	local function GetOptions()
		local options = {
			{ 0, QUEST_BG_DEFAULT },
			{ 1, QUEST_BG_LIGHT1 },
			{ 2, QUEST_BG_LIGHT2 },
			{ 3, QUEST_BG_LIGHT3 },
			{ 4, QUEST_BG_DARK },
		};

		return AddTextOptionsWithPreview(Settings.CreateControlTextContainer(), OnOptionEnter, options);
	end

	local defaultValue = 0;
	local setting = Settings.RegisterProxySetting(category, "PROXY_QUEST_TEXT_CONTRAST", Settings.VarType.Number, ENABLE_QUEST_TEXT_CONTRAST, defaultValue, GetValue, SetValue);
	local initializer = Settings.CreateDropdown(category, setting, GetOptions, OPTION_TOOLTIP_ENABLE_QUEST_TEXT_CONTRAST);

	SettingsPanel.QuestTextPreview:RegisterWithSettingInitializer(initializer);
	SettingsPanel.QuestTextPreview:SetValueAccessor(GetValue);
end

local function RegisterFontResize(category)
	local previewPanel = SettingsPanel.AccessibilityFontPreview;

	local function GetValue()
		return TextSizeManager:GetSettingValue();
	end

	local function SetValue(value)
		TextSizeManager:SetSettingValue(value);
	end

	local function OnOptionEnter(optionData)
		previewPanel:UpdatePreview(optionData.value);
	end

	local function GetOptions()
		local options = {
			{ 0.8571, ACCESSIBILITY_FONT_SIZE_SMALL_LABEL },		-- ~12
			{ 1.0000, ACCESSIBILITY_FONT_SIZE_MEDIUM_LABEL },		-- =14
			{ 1.1429, ACCESSIBILITY_FONT_SIZE_LARGE_LABEL },		-- ~16
			{ 1.4286, ACCESSIBILITY_FONT_SIZE_EXTRA_LARGE_LABEL }, 	-- ~20
			{ 1.7143, ACCESSIBILITY_FONT_SIZE_HUGE_LABEL }, 		-- ~24
			{ 2.0000, ACCESSIBILITY_FONT_SIZE_GIGANTIC_LABEL }, 	-- ~28
		};

		return AddTextOptionsWithPreview(Settings.CreateControlTextContainer(), OnOptionEnter, options);
	end

	local defaultValue = 1;
	local fontSizeSetting = Settings.RegisterProxySetting(category, "PROXY_ACCESSIBILITY_FONT_SIZE", Settings.VarType.Number, ACCESSIBILITY_FONT_SIZE_LABEL, defaultValue, GetValue, SetValue);

	Settings.SetOnValueChangedCallback(fontSizeSetting:GetVariable(), function(_o, _setting, value)
		SetValue(value);
	end);

	local initializer = Settings.CreateDropdown(category, fontSizeSetting, GetOptions, OPTION_TOOLTIP_ACCESSIBILITY_FONT_SIZE);
	previewPanel:RegisterWithSettingInitializer(initializer);
	previewPanel:SetValueAccessor(GetValue);
end

local function BeginNewSection(layout, section)
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(section));
end

local function RegisterTextSettings()
	local category, layout = Settings.RegisterVerticalLayoutCategory(ACCESSIBILITY_INTERFACE_LABEL);

	BeginNewSection(layout, ACCESSIBILITY_INTERFACE_SECTION_DISPLAY);

	RegisterFontResize(category);
	RegisterQuestTextContrast(category);

	Settings.RegisterCategory(category, SETTING_GROUP_ACCESSIBILITY);
end

SettingsRegistrar:AddRegistrant(RegisterTextSettings);
