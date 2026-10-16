CombatOverrides = {}

function CombatOverrides.CreateRaidSelfHighlightSetting(category)
	-- The get and set essentially perform bitwise operations with powers of 2 instead of bits 
	local function GetValue()
		local circleOn = GetCVarBool("findYourselfModeCircle");
		local outlineOn = GetCVarBool("findYourselfModeOutline");
		local iconOn = GetCVarBool("findYourselfModeIcon");

		local value = (circleOn and 1 or 0) + (outlineOn and 2 or 0) + (iconOn and 4 or 0); 
		return value;
	end
	
	local function SetValue(value)
		local NUM_COMBINATIONS = 8;
		SetCVar("findYourselfAnywhere", value > 0 and value < NUM_COMBINATIONS);

		SetCVar("findYourselfModeIcon", value >= 4);
		if (value >= 4) then
			value = value - 4;
		end

		SetCVar("findYourselfModeOutline", value >= 2);
		if (value >= 2) then
			value = value - 2;
		end

		SetCVar("findYourselfModeCircle", value >= 1);
	end

	local function GetOptions()
		local container = Settings.CreateControlTextContainer();
		container:Add(1, SELF_HIGHLIGHT_MODE_CIRCLE);
		container:Add(2, SELF_HIGHLIGHT_MODE_OUTLINE);
		container:Add(4, SELF_HIGHLIGHT_MODE_ICON);
		container:Add(3, SELF_HIGHLIGHT_MODE_CIRCLE_AND_OUTLINE);
		container:Add(5, SELF_HIGHLIGHT_MODE_CIRCLE_AND_ICON);
		container:Add(6, SELF_HIGHLIGHT_MODE_OUTLINE_AND_ICON);
		container:Add(7, SELF_HIGHLIGHT_MODE_CIRCLE_OUTLINE_AND_ICON);

		container:Add(0, OFF);
		return container:GetData();
	end

	local defaultValue = 0;
	local setting = Settings.RegisterProxySetting(category, "PROXY_SELF_HIGHLIGHT",
		Settings.VarType.Number, SELF_HIGHLIGHT_OPTION, defaultValue, GetValue, SetValue);
	return setting, Settings.CreateDropdown(category, setting, GetOptions, OPTION_TOOLTIP_SELF_HIGHLIGHT);
end

function CombatOverrides.CreateFloatingCombatTextSetting(category)
	local fctSetting, fctInitializer = Settings.SetupCVarCheckbox(category, "enableFloatingCombatText", SHOW_COMBAT_TEXT_TEXT, OPTION_TOOLTIP_SHOW_COMBAT_TEXT);
	Settings.LoadAddOnCVarWatcher("enableFloatingCombatText", CombatText_LoadUI);

	if(GetCVar("classicStyleWorldText") == "0") then
		local function IsModifiable()
			return fctSetting:GetValue();
		end

		-- Combat Text Float Mode
		local function GetFloatModeOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(1, COMBAT_TEXT_SCROLL_UP, OPTION_TOOLTIP_SCROLL_UP);
			container:Add(2, COMBAT_TEXT_SCROLL_DOWN, OPTION_TOOLTIP_SCROLL_DOWN);
			container:Add(3, COMBAT_TEXT_SCROLL_ARC, OPTION_TOOLTIP_SCROLL_ARC);
			return container:GetData();
		end

		local _, floatModeInitializer = Settings.SetupCVarDropdown(category, "floatingCombatTextFloatMode_v2", Settings.VarType.Number, GetFloatModeOptions, COMBAT_TEXT_FLOAT_MODE_LABEL, OPTION_TOOLTIP_COMBAT_TEXT_MODE);
		floatModeInitializer:SetParentInitializer(fctInitializer, IsModifiable);
		Settings.SetOnValueChangedCallback("floatingCombatTextFloatMode_v2", UpdateFloatingCombatTextSafe);

		local textOnMeTypesTable =
		{
			{COMBAT_TEXT_SHOW_DODGE_PARRY_MISS_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_DODGE_PARRY_MISS, "floatingCombatTextDodgeParryMiss_v2"},
			{COMBAT_TEXT_SHOW_RESISTANCES_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_RESISTANCES, "floatingCombatTextDamageReduction_v2"},
			{COMBAT_TEXT_SHOW_REPUTATION_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_REPUTATION, "floatingCombatTextRepChanges_v2"},
			{COMBAT_TEXT_SHOW_REACTIVES_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_REACTIVES, "floatingCombatTextReactives_v2"},
			{COMBAT_TEXT_SHOW_FRIENDLY_NAMES_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_FRIENDLY_NAMES, "floatingCombatTextFriendlyHealers_v2"},
			{COMBAT_TEXT_SHOW_COMBAT_STATE_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_COMBAT_STATE, "floatingCombatTextCombatState_v2"},
			{SHOW_COMBAT_HEALING_ABSORB_SELF, OPTION_TOOLTIP_SHOW_COMBAT_HEALING_ABSORB_SELF, "floatingCombatTextCombatHealingAbsorbSelf_v2"},
			{COMBAT_TEXT_SHOW_COMBO_POINTS_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_COMBO_POINTS, "floatingCombatTextComboPoints_v2"},
			{COMBAT_TEXT_SHOW_LOW_HEALTH_MANA_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_LOW_HEALTH_MANA, "floatingCombatTextLowManaHealth_v2"},
			{COMBAT_TEXT_SHOW_ENERGIZE_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_ENERGIZE, "floatingCombatTextEnergyGains_v2"},
			{COMBAT_TEXT_SHOW_PERIODIC_ENERGIZE_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_PERIODIC_ENERGIZE, "floatingCombatTextPeriodicEnergyGains_v2"},
			{COMBAT_TEXT_SHOW_HONOR_GAINED_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_HONOR_GAINED, "floatingCombatTextHonorGains_v2"},
			{COMBAT_TEXT_SHOW_AURAS_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_AURAS, "floatingCombatTextAuras_v2"},
		};

		local function GetSelfValue()
			local mask = 0;
			for index, fctValues in ipairs(textOnMeTypesTable) do
				local cvarName = fctValues[3];
				if (GetCVarBool(cvarName)) then
					mask = bit.bor(mask, bit.lshift(1, index - 1));
				end
			end
			return mask;
		end

		local function SetSelfValue(mask)
			for index, fctValues in ipairs(textOnMeTypesTable) do
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
			for index, fctValues in ipairs(textOnMeTypesTable) do
				local cvarName = fctValues[3];
				if (GetCVarDefault(cvarName) == "1") then
					mask = bit.bor(mask, bit.lshift(1, index - 1));
				end
			end
			return mask;
		end

		local function GetSelfOptions()
			local container = Settings.CreateControlTextContainer();
			for index, fctValues in ipairs(textOnMeTypesTable) do
				local nameText, tooltipText = fctValues[1], fctValues[2];
				local optionData = container:AddCheckbox(index, nameText, tooltipText);
				optionData.displayCheckboxTooltip = true;
			end
			return container:GetData();
		end

		local textOnMeDefaultValue = GetSelfDefaultMask();
		local textOnMeSetting = Settings.RegisterProxySetting(category, "", Settings.VarType.Number, "", textOnMeDefaultValue, GetSelfValue, SetSelfValue);
		local textOnMeInitializer = Settings.CreateDropdown(category, textOnMeSetting, GetSelfOptions);
		textOnMeInitializer:SetParentInitializer(fctInitializer, IsModifiable);
		textOnMeInitializer.getSelectionTextFunc = function() return FLOATING_COMBAT_TEXT_ON_ME_DROPDOWN_LABEL; end;
		textOnMeInitializer.noTooltip = true;

		textOnMeInitializer:AddSearchTags(FLOATING_COMBAT_TEXT_ON_ME_DROPDOWN_LABEL);
		for index, fctValues in ipairs(textOnMeTypesTable) do
			local nameText = fctValues[1];
			textOnMeInitializer:AddSearchTags(nameText);
		end

		local textOnTargetSetting = Settings.RegisterProxySetting(category, " ", Settings.VarType.Number, "", 0, function() return 0; end, function() end);
		local textOnTargetInitializer = Settings.CreateDropdown(category, textOnTargetSetting, function() end);

		textOnTargetInitializer.customMenuGenerator = function(dropdown, rootDescription)
			rootDescription:SetTag("FLOATING_COMBAT_TEXT_ON_TARGET_DROPDOWN_LABEL");
		
			local function IsRadioSelected(data)
				return GetCVarBool(data.cvarName) == data.value;
			end
		
			local function SetRadioSelected(data)
				SetCVar(data.cvarName, data.value);
				UpdateFloatingCombatTextSafe();
				return MenuResponse.Refresh;
			end

			local function IsCheckboxSelected(data)
				return GetCVarBool(data.cvarName);
			end
		
			local function SetCheckboxSelected(data)
				SetCVar(data.cvarName, not GetCVarBool(data.cvarName));
				UpdateFloatingCombatTextSafe();
				return MenuResponse.Refresh;
			end

			-- Move selectors in options dropdowns a bit further from the left side of the dropdown than normal.
			local function SelectorInitializer(frame, description, menu)
				frame.leftTexture1:SetPoint("LEFT", frame, "LEFT", 4, 0);
			end

			-- Move titles in options dropdowns a bit further from the left side of the dropdown than normal.
			local function TitleInitializer(frame, description, menu)
				frame.fontString:SetPoint("LEFT", frame, "LEFT", 4, 0);
			end
		
			local cBox1 = rootDescription:CreateCheckbox(SHOW_DAMAGE_TEXT, IsCheckboxSelected, SetCheckboxSelected, { cvarName = "floatingCombatTextCombatDamage_v2" });
			cBox1:AddInitializer(SelectorInitializer);

			rootDescription:CreateDivider();
			local title1 = rootDescription:CreateTitle(LOG_PERIODIC_EFFECTS);
			title1:AddInitializer(TitleInitializer);

			local radio1 = rootDescription:CreateRadio(TEXT_ON_TARGET_ON_LABEL, IsRadioSelected, SetRadioSelected, { cvarName = "floatingCombatTextCombatLogPeriodicSpells_v2", value = true });
			radio1:AddInitializer(SelectorInitializer);

			local radio2 = rootDescription:CreateRadio(TEXT_ON_TARGET_OFF_LABEL, IsRadioSelected, SetRadioSelected, { cvarName = "floatingCombatTextCombatLogPeriodicSpells_v2", value = false });
			radio2:AddInitializer(SelectorInitializer);

			rootDescription:CreateSpacer(17);
		
			local cBox2 = rootDescription:CreateCheckbox(SHOW_COMBAT_HEALING, IsCheckboxSelected, SetCheckboxSelected, { cvarName = "floatingCombatTextCombatHealing_v2" });
			cBox2:AddInitializer(SelectorInitializer);

			rootDescription:CreateDivider();
			local title2 = rootDescription:CreateTitle(SHOW_COMBAT_HEALING_ABSORB_TARGET);
			title2:AddInitializer(TitleInitializer);

			local radio3 = rootDescription:CreateRadio(TEXT_ON_TARGET_ON_LABEL, IsRadioSelected, SetRadioSelected, { cvarName = "floatingCombatTextCombatHealingAbsorbTarget_v2", value = true });
			radio3:AddInitializer(SelectorInitializer);

			local radio4 = rootDescription:CreateRadio(TEXT_ON_TARGET_OFF_LABEL, IsRadioSelected, SetRadioSelected, { cvarName = "floatingCombatTextCombatHealingAbsorbTarget_v2", value = false });
			radio4:AddInitializer(SelectorInitializer);

			rootDescription:CreateSpacer(17);
		
			local cBox3 = rootDescription:CreateCheckbox(SHOW_TARGET_EFFECTS, IsCheckboxSelected, SetCheckboxSelected, { cvarName = "floatingCombatTextSpellMechanics_v2" });
			cBox3:AddInitializer(SelectorInitializer);

			rootDescription:CreateDivider();
			local title3 = rootDescription:CreateTitle(SHOW_OTHER_TARGET_EFFECTS);
			title3:AddInitializer(TitleInitializer);

			local radio5 = rootDescription:CreateRadio(TEXT_ON_TARGET_ON_LABEL, IsRadioSelected, SetRadioSelected, { cvarName = "floatingCombatTextSpellMechanicsOther_v2", value = true });
			radio5:AddInitializer(SelectorInitializer);

			local radio6 = rootDescription:CreateRadio(TEXT_ON_TARGET_OFF_LABEL, IsRadioSelected, SetRadioSelected, { cvarName = "floatingCombatTextSpellMechanicsOther_v2", value = false });
			radio6:AddInitializer(SelectorInitializer);
		end
		
		textOnTargetInitializer:SetParentInitializer(fctInitializer, IsModifiable);
		textOnTargetInitializer.getSelectionTextFunc = function() return FLOATING_COMBAT_TEXT_ON_TARGET_DROPDOWN_LABEL; end;
		textOnTargetInitializer.noTooltip = true;
		
		textOnTargetInitializer:AddSearchTags(FLOATING_COMBAT_TEXT_ON_TARGET_DROPDOWN_LABEL);
		textOnTargetInitializer:AddSearchTags(SHOW_DAMAGE_TEXT);
		textOnTargetInitializer:AddSearchTags(LOG_PERIODIC_EFFECTS);
		textOnTargetInitializer:AddSearchTags(SHOW_COMBAT_HEALING);
		textOnTargetInitializer:AddSearchTags(SHOW_COMBAT_HEALING_ABSORB_TARGET);
		textOnTargetInitializer:AddSearchTags(SHOW_TARGET_EFFECTS);
		textOnTargetInitializer:AddSearchTags(SHOW_OTHER_TARGET_EFFECTS);
	end
end

function CombatOverrides.CreateOccludedSilhouettePlayerSetting(category)
	return Settings.SetupCVarCheckbox(category, "occludedSilhouettePlayer", SHOW_SILHOUETTE_OPTION, OPTION_TOOLTIP_SHOW_SILHOUETTE);
end

function CombatOverrides.AdjustCombatSettings(category)
end

function CombatOverrides.RunSettingsCallback(callback)
	if not C_GameRules.IsPlunderstorm() then
		callback();
	end
end

function UpdateFloatingCombatTextSafe()
	-- Fix for bug 106938. CombatText_UpdateDisplayedMessages only exists if the Blizzard_CombatText AddOn is loaded.
	-- We need CombatText options to have their setFunc actually _exist_, so this function is used instead of CombatText_UpdateDisplayedMessages.
	if ( CombatText_UpdateDisplayedMessages ) then
		CombatText_UpdateDisplayedMessages();
	end
end

function IsMouseoverCastSupported()
	return true;
end
