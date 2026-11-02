local function CreateSelectionTextFunction(text)
	return function(selections)
		if #selections == 0 then
			return text;
		end

		-- Returning nil to use default behavior in DropdownSelectionTextMixin:UpdateToMenuSelections.
		return nil;
	end
end

function CreateHDSDToggleOptions(category, layout)
	if (not C_GameRules.IsSDHDToggleEnabled()) then 
		return;
	end

	local function GetOptions()
		local container = Settings.CreateControlTextContainer();
		container:Add(true, STANDARD_DEFINITION, STANDARD_DEFINITION_TOOLTIP);
		container:Add(false, HIGH_DEFINITION, HIGH_DEFINITION_TOOLTIP);
		return container:GetData();
	end

	local function GetValue()
		if C_GameRules.IsSDHDToggleEnabled() then
			return C_GameRules.AccountHasSDEnabled();
		end
		return false;
	end

	local function SetValue(value)
		if C_GameRules.IsSDHDToggleEnabled() then
			C_GameRules.SetSDHDToggleValue(value, Enum.SdToggleUsageLocationUI.OptionsMenu);
		end
	end

	local function GetDefaultValue()
		-- If we want Classic as the default, then we should return true.
		-- If we want Modern as the default, return false.
		return C_GameRules.GetForeverExperiencePreset() == Enum.ForeverExperiencePreset.Classic;
	end

	local setting = Settings.RegisterProxySetting(category, "PROXY_CHARACTER_MODELS_TOGGLE", 
		Settings.VarType.Boolean, CHARACTER_MODELS, GetDefaultValue, GetValue, SetValue);

	local initializer = Settings.CreateDropdown(category, setting, GetOptions, OPTION_TOOLTIP_CHARACTER_MODELS);
	initializer:AddShownPredicate(C_GameRules.IsSDHDToggleEnabled);
	initializer:AddModifyPredicate(C_GameRules.IsSDHDToggleEnabled);
	initializer:AddSearchTags(SD_SEARCH_TAG);
	initializer:AddSearchTags(HD_SEARCH_TAG);
	initializer:AddSearchTags(STANDARD_DEFINITION);
	initializer:AddSearchTags(HIGH_DEFINITION);
end

local function Register()
	if (InGlue()) then
		return;
	end

	local category, layout = Settings.RegisterVerticalLayoutCategory(PRESET_LABEL);

	local function GetCurrentSettingTitleString()
		local experiencePreset = C_GameRules.GetForeverExperiencePreset();
		if (experiencePreset == Enum.ForeverExperiencePreset.Classic) then
			return CURRENT_SETTING_TEXT_CLASSIC_LABEL;
		elseif (experiencePreset == Enum.ForeverExperiencePreset.Enhanced) then
			return CURRENT_SETTING_TEXT_ENHANCED_LABEL;
		end
	end
	
	-- Current Setting Text
	local headerInitializer = CreateSettingsListSectionHeaderInitializer(GetCurrentSettingTitleString(), "", "");
	headerInitializer.customNameUpdateFunc = GetCurrentSettingTitleString;
	layout:AddInitializer(headerInitializer);

	-- Buttons to Swap Experience Preset
	local function SetClassicExperiencePreset()
		C_GameRules.SetForeverExperiencePresetPostLogin(Enum.ForeverExperiencePreset.Classic);
	end

	local function SetEnhancedExperiencePreset()
		C_GameRules.SetForeverExperiencePresetPostLogin(Enum.ForeverExperiencePreset.Enhanced);
	end

	local addSearchTags = true;
	local classicButtonInitializer = CreateSettingsButtonInitializer("", SET_PRESET_OPTION_BUTTON_CLASSIC_LABEL, SetClassicExperiencePreset, "", addSearchTags);
	classicButtonInitializer:AddSearchTags(PRESET);
	layout:AddInitializer(classicButtonInitializer);

	local enhancedButtonInitializer = CreateSettingsButtonInitializer("", SET_PRESET_OPTION_BUTTON_ENHANCED_LABEL, SetEnhancedExperiencePreset, "", addSearchTags);
	enhancedButtonInitializer:AddSearchTags(PRESET);
	layout:AddInitializer(enhancedButtonInitializer);

	if (C_CVar.GetCVar("combinedBags")) then
		-- Use Combined Inventory Bags
		Settings.SetupCVarCheckbox(category, "combinedBags", USE_COMBINED_BAGS_TEXT, OPTION_TOOLTIP_USE_COMBINED_BAGS);
	end

	if (C_CVar.GetCVar("questPOI")) then
		-- Quest POIs and Blobs
		Settings.SetupCVarCheckbox(category, "questPOI", OPTIONS_MENU_QUEST_POIS_TEXT, OPTIONS_MENU_QUEST_POIS_TOOLTIP);
	end

	if (C_CVar.GetCVar("showToastWindow")) then
		-- Toast window
		Settings.SetupCVarCheckbox(category, "showToastWindow", SHOW_TOAST_WINDOW_TEXT, OPTION_TOOLTIP_SHOW_TOAST_WINDOW);
	end

	-- Interface toasts types
	local toastTypesTable =
	{
		{SHOW_ITEM_TOASTS, OPTION_TOOLTIP_SHOW_ITEM_TOASTS, "enableLootToasts"},
		{SHOW_COLLECTION_TOASTS, OPTION_TOOLTIP_SHOW_COLLECTION_TOASTS, "enableCollectionToasts"},
		{SHOW_LEARNED_RECIPE_TOASTS, OPTION_TOOLTIP_SHOW_LEARNED_RECIPE_TOASTS, "enableLearnedRecipeToasts"}
	};

	local function GetSelfValue()
		local mask = 0;
		for index, fctValues in ipairs(toastTypesTable) do
			local cvarName = fctValues[3];
			if (GetCVarBool(cvarName)) then
				mask = bit.bor(mask, bit.lshift(1, index - 1));
			end
		end
		return mask;
	end

	local function SetSelfValue(mask)
		for index, fctValues in ipairs(toastTypesTable) do
			local cvarName = fctValues[3];
			if (bit.band(mask, bit.lshift(1, index - 1)) ~= 0) then
				SetCVar(cvarName, 1);
			else
				SetCVar(cvarName, 0);
			end
		end
		UpdateFloatingCombatTextSafe();
	end

	local function GetSelfDefaultMask()
		local mask = 0;
		for index, fctValues in ipairs(toastTypesTable) do
			local cvarName = fctValues[3];
			if (GetCVarDefault(cvarName) == "1") then
				mask = bit.bor(mask, bit.lshift(1, index - 1));
			end
		end
		return mask;
	end

	local function GetSelfOptions()
		local container = Settings.CreateControlTextContainer();
		for index, fctValues in ipairs(toastTypesTable) do
			local nameText, tooltipText = fctValues[1], fctValues[2];
			container:AddCheckbox(index, nameText, tooltipText);
		end
		return container:GetData();
	end

	local toastTypesDefaultValue = GetSelfDefaultMask();
	local toastTypesSetting = Settings.RegisterProxySetting(category, OPTIONS_MENU_INTERFACE_TOASTS_TEXT, Settings.VarType.Number, OPTIONS_MENU_INTERFACE_TOASTS_TOOLTIP, toastTypesDefaultValue, GetSelfValue, SetSelfValue);
	local toastTypesInitializer = Settings.CreateDropdown(category, toastTypesSetting, GetSelfOptions);
	toastTypesInitializer.getSelectionTextFunc = CreateSelectionTextFunction(NONE);

	for index, fctValues in ipairs(toastTypesTable) do
		local nameText = fctValues[1];
		toastTypesInitializer:AddSearchTags(nameText);
	end

	-- Turn/Strafe Style Buttons
	local function SetClassicTurnStrafeStyle()
		C_KeyBindings.SetTurnStrafeStyle(Enum.TurnStrafeStyle.Legacy);
		SaveBindings(GetCurrentBindingSet());
	end

	local function SetEnhancedTurnStrafeStyle()
		C_KeyBindings.SetTurnStrafeStyle(Enum.TurnStrafeStyle.Modern);
		SaveBindings(GetCurrentBindingSet());
	end

	local classicTurnStrafeButtonInitializer = CreateSettingsButtonInitializer("", CLASSIC_TURN_STRAFE_KEYBINDINGS_BUTTON_TEXT, SetClassicTurnStrafeStyle, "", addSearchTags);
	layout:AddInitializer(classicTurnStrafeButtonInitializer);

	local enhancedTurnStrafeButtonInitializer = CreateSettingsButtonInitializer("", ENHANCED_TURN_STRAFE_KEYBINDINGS_BUTTON_TEXT, SetEnhancedTurnStrafeStyle, "", addSearchTags);
	layout:AddInitializer(enhancedTurnStrafeButtonInitializer);

	-- Character Model Toggle
	CreateHDSDToggleOptions(category, layout);

	Settings.RegisterCategory(category, SETTING_GROUP_SYSTEM);
end

SettingsRegistrar:AddRegistrant(Register);
