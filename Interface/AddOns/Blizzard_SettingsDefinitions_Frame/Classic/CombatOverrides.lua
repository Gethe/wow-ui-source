CombatOverrides = {}

function CombatOverrides.CreateRaidSelfHighlightSetting(category)
-- The get and set essentially perform bitwise operations with powers of 2 instead of bits
	local function GetValue()
		local circleOn = GetCVarBool("findYourselfModeCircle");
		local iconOn = GetCVarBool("findYourselfModeIcon");

		local value = (circleOn and 1 or 0) + (iconOn and 2 or 0);
		return value;
	end

	local function SetValue(value)
		local NUM_COMBINATIONS = 4;
		SetCVar("findYourselfAnywhere", value > 0 and value < NUM_COMBINATIONS);

		SetCVar("findYourselfModeIcon", value >= 2);
		if (value >= 2) then
			value = value - 2;
		end

		SetCVar("findYourselfModeCircle", value >= 1);
	end

	local function GetOptions()
		local container = Settings.CreateControlTextContainer();
		container:Add(1, SELF_HIGHLIGHT_MODE_CIRCLE);
		container:Add(2, SELF_HIGHLIGHT_MODE_ICON);
		container:Add(3, SELF_HIGHLIGHT_MODE_CIRCLE_AND_ICON);

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
	Settings.LoadAddOnCVarWatcher("enableFloatingCombatText", "Blizzard_CombatText");

	local function IsModifiable()
		return fctSetting:GetValue();
	end

	-- Combat Text Float Mode
	local function GetOptions()
		local container = Settings.CreateControlTextContainer();
		container:Add(1, COMBAT_TEXT_SCROLL_UP, OPTION_TOOLTIP_SCROLL_UP);
		container:Add(2, COMBAT_TEXT_SCROLL_DOWN, OPTION_TOOLTIP_SCROLL_DOWN);
		container:Add(3, COMBAT_TEXT_SCROLL_ARC, OPTION_TOOLTIP_SCROLL_ARC);
		return container:GetData();
	end

	local _, floatModeInitializer = Settings.SetupCVarDropdown(category, "floatingCombatTextFloatMode_v2", Settings.VarType.Number, GetOptions, COMBAT_TEXT_FLOAT_MODE_LABEL, OPTION_TOOLTIP_COMBAT_TEXT_MODE);
	floatModeInitializer:SetParentInitializer(fctInitializer, IsModifiable);
	Settings.SetOnValueChangedCallback("floatingCombatTextFloatMode_v2", UpdateFloatingCombatTextSafe);

	local _, lowHealthInitializer = Settings.SetupCVarCheckbox(category, "floatingCombatTextLowManaHealth_v2", COMBAT_TEXT_SHOW_LOW_HEALTH_MANA_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_LOW_HEALTH_MANA);
	lowHealthInitializer:SetParentInitializer(fctInitializer, IsModifiable);
	Settings.SetOnValueChangedCallback("floatingCombatTextLowManaHealth_v2", UpdateFloatingCombatTextSafe);

	local _, aurasInitializer = Settings.SetupCVarCheckbox(category, "floatingCombatTextAuras_v2", COMBAT_TEXT_SHOW_AURAS_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_AURAS);
	aurasInitializer:SetParentInitializer(fctInitializer, IsModifiable);
	Settings.SetOnValueChangedCallback("floatingCombatTextAuras_v2", UpdateFloatingCombatTextSafe);

	local _, fadeInitializer = Settings.SetupCVarCheckbox(category, "floatingCombatTextAuraFade_v2", COMBAT_TEXT_SHOW_AURA_FADE_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_AURA_FADE);
	fadeInitializer:SetParentInitializer(fctInitializer, IsModifiable);
	Settings.SetOnValueChangedCallback("floatingCombatTextAuraFade_v2", UpdateFloatingCombatTextSafe);

	local _, combatStateInitializer = Settings.SetupCVarCheckbox(category, "floatingCombatTextCombatState_v2", COMBAT_TEXT_SHOW_COMBAT_STATE_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_COMBAT_STATE);
	combatStateInitializer:SetParentInitializer(fctInitializer, IsModifiable);
	Settings.SetOnValueChangedCallback("floatingCombatTextCombatState_v2", UpdateFloatingCombatTextSafe);

	local _, dpmInitializer = Settings.SetupCVarCheckbox(category, "floatingCombatTextDodgeParryMiss_v2", COMBAT_TEXT_SHOW_DODGE_PARRY_MISS_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_DODGE_PARRY_MISS);
	dpmInitializer:SetParentInitializer(fctInitializer, IsModifiable);
	Settings.SetOnValueChangedCallback("floatingCombatTextDodgeParryMiss_v2", UpdateFloatingCombatTextSafe);

	local _, dmgReductionInitializer = Settings.SetupCVarCheckbox(category, "floatingCombatTextDamageReduction_v2", COMBAT_TEXT_SHOW_RESISTANCES_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_RESISTANCES);
	dmgReductionInitializer:SetParentInitializer(fctInitializer, IsModifiable);
	Settings.SetOnValueChangedCallback("floatingCombatTextDamageReduction_v2", UpdateFloatingCombatTextSafe);

	local _, repChangeInitializer = Settings.SetupCVarCheckbox(category, "floatingCombatTextRepChanges_v2", COMBAT_TEXT_SHOW_REPUTATION_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_REPUTATION);
	repChangeInitializer:SetParentInitializer(fctInitializer, IsModifiable);
	Settings.SetOnValueChangedCallback("floatingCombatTextRepChanges_v2", UpdateFloatingCombatTextSafe);

	local _, reactiveInitializer = Settings.SetupCVarCheckbox(category, "floatingCombatTextReactives_v2", COMBAT_TEXT_SHOW_REACTIVES_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_REACTIVES);
	reactiveInitializer:SetParentInitializer(fctInitializer, IsModifiable);
	Settings.SetOnValueChangedCallback("floatingCombatTextReactives_v2", UpdateFloatingCombatTextSafe);

	local _, friendlyHealerInitializer = Settings.SetupCVarCheckbox(category, "floatingCombatTextFriendlyHealers_v2", COMBAT_TEXT_SHOW_FRIENDLY_NAMES_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_FRIENDLY_NAMES);
	friendlyHealerInitializer:SetParentInitializer(fctInitializer, IsModifiable);
	Settings.SetOnValueChangedCallback("floatingCombatTextFriendlyHealers_v2", UpdateFloatingCombatTextSafe);

	local _, comboPointsInitializer = Settings.SetupCVarCheckbox(category, "floatingCombatTextComboPoints_v2", COMBAT_TEXT_SHOW_COMBO_POINTS_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_COMBO_POINTS);
	comboPointsInitializer:SetParentInitializer(fctInitializer, IsModifiable);
	Settings.SetOnValueChangedCallback("floatingCombatTextComboPoints_v2", UpdateFloatingCombatTextSafe);

	local _, energyInitializer = Settings.SetupCVarCheckbox(category, "floatingCombatTextEnergyGains_v2", COMBAT_TEXT_SHOW_ENERGIZE_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_ENERGIZE);
	energyInitializer:SetParentInitializer(fctInitializer, IsModifiable);
	Settings.SetOnValueChangedCallback("floatingCombatTextEnergyGains_v2", UpdateFloatingCombatTextSafe);

	local _, honorInitializer = Settings.SetupCVarCheckbox(category, "floatingCombatTextHonorGains_v2", COMBAT_TEXT_SHOW_HONOR_GAINED_TEXT, OPTION_TOOLTIP_COMBAT_TEXT_SHOW_HONOR_GAINED);
	honorInitializer:SetParentInitializer(fctInitializer, IsModifiable);
	Settings.SetOnValueChangedCallback("floatingCombatTextHonorGains_v2", UpdateFloatingCombatTextSafe);
end

function CombatOverrides.CreateOccludedSilhouettePlayerSetting(category)
end

function CombatOverrides.AdjustCombatSettings(category)
	do
		-- Target Damage
		local floatingDamageSetting, floatingDamageInitializer = Settings.SetupCVarCheckbox(category, "floatingCombatTextCombatDamage_v2", SHOW_DAMAGE_TEXT, OPTION_TOOLTIP_SHOW_DAMAGE);
		local function IsModifiable()
			return floatingDamageSetting:GetValue();
		end
		Settings.SetOnValueChangedCallback("floatingCombatTextCombatDamage_v2", UpdateFloatingCombatTextSafe);

		-- Periodic Damage
		local _, periodicDamageInitializer = Settings.SetupCVarCheckbox(category, "floatingCombatTextCombatLogPeriodicSpells_v2", LOG_PERIODIC_EFFECTS_TEXT, OPTION_TOOLTIP_LOG_PERIODIC_EFFECTS);
		periodicDamageInitializer:SetParentInitializer(floatingDamageInitializer, IsModifiable);
		Settings.SetOnValueChangedCallback("floatingCombatTextCombatLogPeriodicSpells_v2", UpdateFloatingCombatTextSafe);

		-- Pet Damage
		local _, petDamageInitializer = Settings.SetupCVarCheckbox(category, "floatingCombatTextPetMeleeDamage_v2", SHOW_PET_MELEE_DAMAGE_TEXT, OPTION_TOOLTIP_SHOW_PET_MELEE_DAMAGE);
		petDamageInitializer:SetParentInitializer(floatingDamageInitializer, IsModifiable);
		Settings.SetOnValueChangedCallback("floatingCombatTextPetMeleeDamage_v2", UpdateFloatingCombatTextSafe);
	end

	-- Healing
	Settings.SetupCVarCheckbox(category, "floatingCombatTextCombatHealing_v2", SHOW_COMBAT_HEALING_TEXT, OPTION_TOOLTIP_SHOW_COMBAT_HEALING);
	Settings.SetOnValueChangedCallback("floatingCombatTextCombatHealing_v2", UpdateFloatingCombatTextSafe);

	if ClassicExpansionAtLeast(LE_EXPANSION_BURNING_CRUSADE) and ClassicExpansionAtMost(LE_EXPANSION_CATACLYSM) then
		-- Auto Attack/Auto Shot
		Settings.SetupCVarCheckbox(category, "autoRangedCombat", AUTO_RANGED_COMBAT_TEXT, OPTION_TOOLTIP_AUTO_RANGED_COMBAT);
		Settings.SetOnValueChangedCallback("autoRangedCombat", UpdateFloatingCombatTextSafe);
	end

end

function CombatOverrides.RunSettingsCallback(callback)
	callback();
end

function UpdateFloatingCombatTextSafe()
	-- Fix for bug 106938. CombatText_UpdateDisplayedMessages only exists if the Blizzard_CombatText AddOn is loaded.
	-- We need CombatText options to have their setFunc actually _exist_, so this function is used instead of CombatText_UpdateDisplayedMessages.
	if ( CombatText_UpdateDisplayedMessages ) then
		CombatText_UpdateDisplayedMessages();
	end
end

function IsMouseoverCastSupported()
	return false;
end
