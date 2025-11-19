local function Register()
	-- Advanced settings do not apply to non-standard game modes for now.
	if not C_GameRules.IsStandard() then
		return;
	end

	local category, layout = Settings.RegisterVerticalLayoutCategory(ADVANCED_OPTIONS_LABEL);
	Settings.ADVANCED_OPTIONS_CATEGORY_ID = category:GetID();

	-- Order set in GameplaySettingsGroup.lua
	category:SetOrder(CUSTOM_GAMEPLAY_SETTINGS_ORDER[ADVANCED_OPTIONS_LABEL]);

	-- Mirrored from Keybindings Panel
	if Settings.ClickCastInitializer then
		layout:AddMirroredInitializer(Settings.ClickCastInitializer);
	end

	-- Mirrored from Keybindings Panel
	if Settings.QuickKeybindInitializer then
		layout:AddMirroredInitializer(Settings.QuickKeybindInitializer);
	end

	-- Assisted Combat
	InterfaceOverrides.RunSettingsCallback(function()
		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(ASSISTED_COMBAT_LABEL));
	end);

	-- Assisted Rotation
	InterfaceOverrides.RunSettingsCallback(function()
		local tooltipFn = function()
			local isAvailable, failureReason = C_AssistedCombat.IsAvailable();
			if isAvailable then
				return ASSISTED_COMBAT_ROTATION_ACTION_BUTTON_HELPTIP;
			else
				return format("%s|n|n%s", ASSISTED_COMBAT_ROTATION_ACTION_BUTTON_HELPTIP, failureReason);
			end
		end

		local function OnButtonClick()
			SetCVarBitfield("closedInfoFramesAccountWide", LE_FRAME_TUTORIAL_ACCOUNT_ASSISTED_COMBAT_ROTATION_DRAG_SPELL, false);
			local skipTransitionBackToOpeningPanel = true;
			SettingsPanel:Close(skipTransitionBackToOpeningPanel);
			PlayerSpellsUtil.ToggleSpellBookFrame();
		end

		local addSearchTags = false;
		local initializer = CreateSettingsButtonInitializer(ASSISTED_COMBAT_ROTATION, ASSISTED_COMBAT_ROTATION_VIEW_SPELLBOOK, OnButtonClick, tooltipFn, addSearchTags, "ASSISTED_COMBAT_ROTATION");
		initializer:AddModifyPredicate(C_AssistedCombat.IsAvailable);
		initializer:SetKioskProtected();
		layout:AddInitializer(initializer);
	end);

	-- Assisted Highlight
	InterfaceOverrides.RunSettingsCallback(function()
		local tooltipFn = function()
			local isAvailable, failureReason = C_AssistedCombat.IsAvailable();
			if isAvailable then
				return OPTION_TOOLTIP_ASSISTED_COMBAT_HIGHLIGHT;
			else
				return format("%s|n|n%s", OPTION_TOOLTIP_ASSISTED_COMBAT_HIGHLIGHT, failureReason);
			end
		end
		local setting, initializer = Settings.SetupCVarCheckbox(category, "assistedCombatHighlight", ASSISTED_COMBAT_HIGHLIGHT_LABEL, tooltipFn);
		initializer:AddModifyPredicate(C_AssistedCombat.IsAvailable);

		local onClickFn = function(checked)
			if checked and not GetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ASSISTED_HIGHLIGHT_ENABLED_POPUP) then
				local systemPrefix = "SETTINGS";
				local notificationType = "ASSISTED_HIGHLIGHT";
				StaticPopup_ShowNotification(systemPrefix, notificationType, ASSISTED_COMBAT_HIGHLIGHT_DIALOG_WARNING);
				local OnSettingsPanelHide = function()
					EventRegistry:UnregisterCallback("SettingsPanel.OnHide", notificationType);
					StaticPopup_HideNotification(systemPrefix, notificationType);
				end
				EventRegistry:RegisterCallback("SettingsPanel.OnHide", OnSettingsPanelHide, notificationType);
				SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_ASSISTED_HIGHLIGHT_ENABLED_POPUP, true);
			end
			return false;
		end
		initializer:SetSettingIntercept(onClickFn);
	end);

	-- Combat Warnings
	InterfaceOverrides.RunSettingsCallback(function()
		local COMBAT_WARNINGS_ENABLED_CVAR = "combatWarningsEnabled";
		local ENCOUNTER_WARNINGS_ENABLED_CVAR = "encounterWarningsEnabled";
		local ENCOUNTER_TIMELINE_ENABLED_CVAR = "encounterTimelineEnabled";

		local subsectionInitializer;

		local _sectionTooltip = nil;
		local sectionNewTagID = "COMBAT_WARNINGS_LABEL";
		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(COMBAT_WARNINGS_LABEL, _sectionTooltip, sectionNewTagID));

		-- Enable Boss Warnings
		do
			local function GenerateTooltipText()
				local isAvailable = C_EncounterWarnings.IsFeatureAvailable() or C_EncounterTimeline.IsFeatureAvailable();
				if isAvailable then
					return COMBAT_WARNINGS_ENABLE_TOOLTIP;
				else
					return string.format("%s|n|n%s", COMBAT_WARNINGS_ENABLE_TOOLTIP, COMBAT_WARNINGS_NOT_AVAILABLE);
				end
			end

			local _setting, initializer = Settings.SetupCVarCheckbox(category, COMBAT_WARNINGS_ENABLED_CVAR, COMBAT_WARNINGS_ENABLE_LABEL, GenerateTooltipText);
			initializer:AddModifyPredicate(function() return C_EncounterWarnings.IsFeatureAvailable() or C_EncounterTimeline.IsFeatureAvailable(); end);
		end

		local function CanEnableBossWarningFeatures()
			return C_EncounterTimeline.IsFeatureAvailable() and C_CVar.GetCVarBool(COMBAT_WARNINGS_ENABLED_CVAR);
		end

		local function CanModifyTextWarningSettings()
			return CanEnableBossWarningFeatures() and C_EncounterWarnings.IsFeatureEnabled();
		end

		local function CanModifyBossTimelineSettings()
			return CanEnableBossWarningFeatures() and C_EncounterTimeline.IsFeatureEnabled();
		end

		-- Enable Text Warnings
		do
			local function GenerateTooltipText()
				local isAvailable = C_EncounterWarnings.IsFeatureAvailable();
				if isAvailable then
					return COMBAT_WARNINGS_ENABLE_ENCOUNTER_WARNINGS_TOOLTIP;
				else
					return string.format("%s|n|n%s", COMBAT_WARNINGS_ENABLE_ENCOUNTER_WARNINGS_TOOLTIP, COMBAT_WARNINGS_ENABLE_ENCOUNTER_WARNINGS_NOT_AVAILABLE);
				end
			end

			local function GetOptionData(options)
				local container = Settings.CreateControlTextContainer();
				container:Add(Enum.EncounterEventSeverity.Low, COMBAT_WARNINGS_TEXT_LEVEL_MINOR_LABEL, COMBAT_WARNINGS_TEXT_LEVEL_MINOR_TOOLTIP);
				container:Add(Enum.EncounterEventSeverity.Medium, COMBAT_WARNINGS_TEXT_LEVEL_MEDIUM_LABEL, COMBAT_WARNINGS_TEXT_LEVEL_MEDIUM_TOOLTIP);
				container:Add(Enum.EncounterEventSeverity.High, COMBAT_WARNINGS_TEXT_LEVEL_CRITICAL_LABEL, COMBAT_WARNINGS_TEXT_LEVEL_CRITICAL_TOOLTIP);
				return container:GetData();
			end

			local severitySelectionTexts = {
				[Enum.EncounterEventSeverity.High] = COMBAT_WARNINGS_TEXT_LEVEL_CRITICAL_SELECTION,
				[Enum.EncounterEventSeverity.Medium] = COMBAT_WARNINGS_TEXT_LEVEL_MEDIUM_SELECTION,
				[Enum.EncounterEventSeverity.Low] = COMBAT_WARNINGS_TEXT_LEVEL_MINOR_SELECTION,
			};

			local function GetSelectionText(selections)
				local selectedValue = selections[1] and selections[1].data.value;
				return severitySelectionTexts[selectedValue] or UNKNOWN;
			end

			local checkboxSetting = Settings.RegisterCVarSetting(category, ENCOUNTER_WARNINGS_ENABLED_CVAR, Settings.VarType.Boolean, COMBAT_WARNINGS_ENABLE_ENCOUNTER_WARNINGS_LABEL);
			local checkboxLabel = COMBAT_WARNINGS_ENABLE_ENCOUNTER_WARNINGS_LABEL;
			local checkboxTooltip = GenerateTooltipText;

			local dropdownSetting = Settings.RegisterCVarSetting(category, "encounterWarningsLevel", Settings.VarType.Number, COMBAT_WARNINGS_ENABLE_ENCOUNTER_WARNINGS_LABEL);
			local dropdownOptions = GetOptionData;
			local dropdownLabel = COMBAT_WARNINGS_ENABLE_ENCOUNTER_WARNINGS_LABEL;
			local dropdownTooltip = GenerateTooltipText;

			local initializer = CreateSettingsCheckboxDropdownInitializer(checkboxSetting, checkboxLabel, checkboxTooltip, dropdownSetting, dropdownOptions, dropdownLabel, dropdownTooltip);
			initializer.getSelectionTextFunc = GetSelectionText;
			initializer:AddModifyPredicate(CanEnableBossWarningFeatures);
			initializer:AddEvaluateStateCVar(COMBAT_WARNINGS_ENABLED_CVAR);
			initializer:AddSearchTags(COMBAT_WARNINGS_ENABLE_ENCOUNTER_WARNINGS_LABEL);
			layout:AddInitializer(initializer);
			subsectionInitializer = initializer;
		end

		do
			local _setting, initializer = Settings.SetupCVarCheckbox(category, "encounterWarningsHideIfNotTargetingPlayer", COMBAT_WARNINGS_HIDE_IF_NOT_TARGETING_PLAYER_LABEL, COMBAT_WARNINGS_HIDE_IF_NOT_TARGETING_PLAYER_TOOLTIP);
			initializer:SetParentInitializer(subsectionInitializer, CanModifyTextWarningSettings);
			initializer:AddEvaluateStateCVar(COMBAT_WARNINGS_ENABLED_CVAR);
			initializer:AddEvaluateStateCVar(ENCOUNTER_WARNINGS_ENABLED_CVAR);
		end

		-- Enable Boss Timeline
		do
			local function GenerateTooltipText()
				local isAvailable = C_EncounterTimeline.IsFeatureAvailable();
				if isAvailable then
					return COMBAT_WARNINGS_ENABLE_ENCOUNTER_TIMELINE_TOOLTIP;
				else
					return string.format("%s|n|n%s", COMBAT_WARNINGS_ENABLE_ENCOUNTER_TIMELINE_TOOLTIP, COMBAT_WARNINGS_ENABLE_ENCOUNTER_TIMELINE_NOT_AVAILABLE);
				end
			end

			local _setting, initializer = Settings.SetupCVarCheckbox(category, ENCOUNTER_TIMELINE_ENABLED_CVAR, COMBAT_WARNINGS_ENABLE_ENCOUNTER_TIMELINE_LABEL, GenerateTooltipText);
			initializer:AddModifyPredicate(CanEnableBossWarningFeatures);
			initializer:AddEvaluateStateCVar(COMBAT_WARNINGS_ENABLED_CVAR);
			subsectionInitializer = initializer;
		end

		-- Hide long countdowns
		do
			local _setting, initializer = Settings.SetupCVarCheckbox(category, "encounterTimelineHideLongCountdowns", COMBAT_WARNINGS_HIDE_LONG_COUNTDOWNS_LABEL, COMBAT_WARNINGS_HIDE_LONG_COUNTDOWNS_TOOLTIP);
			initializer:SetParentInitializer(subsectionInitializer);
			initializer:AddModifyPredicate(CanModifyBossTimelineSettings);
			initializer:AddEvaluateStateCVar(COMBAT_WARNINGS_ENABLED_CVAR);
			initializer:AddEvaluateStateCVar(ENCOUNTER_TIMELINE_ENABLED_CVAR);
		end

		-- Hide queued countdowns
		do
			local _setting, initializer = Settings.SetupCVarCheckbox(category, "encounterTimelineHideQueuedCountdowns", COMBAT_WARNINGS_HIDE_QUEUED_COUNTDOWNS_LABEL, COMBAT_WARNINGS_HIDE_QUEUED_COUNTDOWNS_TOOLTIP);
			initializer:SetParentInitializer(subsectionInitializer);
			initializer:AddModifyPredicate(CanModifyBossTimelineSettings);
			initializer:AddEvaluateStateCVar(COMBAT_WARNINGS_ENABLED_CVAR);
			initializer:AddEvaluateStateCVar(ENCOUNTER_TIMELINE_ENABLED_CVAR);
		end

		-- Hide countdowns for other roles
		do
			local _setting, initializer = Settings.SetupCVarCheckbox(category, "encounterTimelineHideForOtherRoles", COMBAT_WARNINGS_HIDE_FOR_OTHER_ROLES_LABEL, COMBAT_WARNINGS_HIDE_FOR_OTHER_ROLES_TOOLTIP);
			initializer:SetParentInitializer(subsectionInitializer);
			initializer:AddModifyPredicate(CanModifyBossTimelineSettings);
			initializer:AddEvaluateStateCVar(COMBAT_WARNINGS_ENABLED_CVAR);
			initializer:AddEvaluateStateCVar(ENCOUNTER_TIMELINE_ENABLED_CVAR);
		end

		-- Spell support iconography
		do
			local checkboxSetting = Settings.RegisterCVarSetting(category, EncounterTimelineIndicatorIconCVars.Enabled, Settings.VarType.Boolean, COMBAT_WARNINGS_SPELL_SUPPORT_ICONOGRAPHY_LABEL);
			local checkboxLabel = COMBAT_WARNINGS_SPELL_SUPPORT_ICONOGRAPHY_LABEL;
			local checkboxTooltip = COMBAT_WARNINGS_SPELL_SUPPORT_ICONOGRAPHY_TOOLTIP;

			-- The dropdown controls a bitmask CVar that stores the inverted
			-- state of individual checkboxes; Get/SetValue must pass values
			-- through TransformValue to correctly translate.

			local function TransformValue(mask)
				local invertedMask = 0;

				for iconSetIndex in pairs(EncounterTimelineIconSetMasks) do
					local iconSetBit = bit.lshift(1, (iconSetIndex - 1));

					if not FlagsUtil.IsSet(mask, iconSetBit) then
						invertedMask = bit.bor(invertedMask, iconSetBit);
					end
				end

				return invertedMask;
			end

			local function GetValue()
				local disabledIconSets = Settings.GetCVarMask(EncounterTimelineIndicatorIconCVars.HiddenIconMask, Enum.EncounterTimelineIconSet);
				local enabledIconSets = TransformValue(disabledIconSets);
				return enabledIconSets;
			end

			local function SetValue(enabledIconSets)
				local disabledIconSets = TransformValue(enabledIconSets);
				CVarCallbackRegistry:SetCVarBitfieldMask(EncounterTimelineIndicatorIconCVars.HiddenIconMask, disabledIconSets);
			end

			local function GetOptions()
				local container = Settings.CreateControlTextContainer();
				container:AddCheckbox(Enum.EncounterTimelineIconSet.TankAlert, COMBAT_WARNINGS_SPELL_SUPPORT_ICONOGRAPHY_OPTION_TANK_ALERT_LABEL);
				container:AddCheckbox(Enum.EncounterTimelineIconSet.HealerAlert, COMBAT_WARNINGS_SPELL_SUPPORT_ICONOGRAPHY_OPTION_HEALER_ALERT_LABEL);
				container:AddCheckbox(Enum.EncounterTimelineIconSet.DamageAlert, COMBAT_WARNINGS_SPELL_SUPPORT_ICONOGRAPHY_OPTION_DAMAGE_ALERT_LABEL);
				container:AddCheckbox(Enum.EncounterTimelineIconSet.Dispel, COMBAT_WARNINGS_SPELL_SUPPORT_ICONOGRAPHY_OPTION_DISPEL_LABEL);
				container:AddCheckbox(Enum.EncounterTimelineIconSet.Enrage, COMBAT_WARNINGS_SPELL_SUPPORT_ICONOGRAPHY_OPTION_ENRAGE_LABEL);
				container:AddCheckbox(Enum.EncounterTimelineIconSet.Deadly, COMBAT_WARNINGS_SPELL_SUPPORT_ICONOGRAPHY_OPTION_DEADLY_LABEL);
				return container:GetData();
			end

			local function GetSelectionText(selections)
				if #selections == Enum.EncounterTimelineIconSetMeta.NumValues then
					return COMBAT_WARNINGS_SPELL_SUPPORT_ICONOGRAPHY_OPTION_ALL;
				elseif #selections == 0 then
					return COMBAT_WARNINGS_SPELL_SUPPORT_ICONOGRAPHY_OPTION_NONE;
				else
					-- Use default text logic based on selections.
					return nil;
				end
			end

			local defaultValue = CVarCallbackRegistry:GetCVarBitfieldDefault(EncounterTimelineIndicatorIconCVars.HiddenIconMask);
			local dropdownSetting = Settings.RegisterProxySetting(category, "ENCOUNTER_TIMELINE_ICONOGRAPHY_SETS", Settings.VarType.Number, COMBAT_WARNINGS_SPELL_SUPPORT_ICONOGRAPHY_LABEL, defaultValue, GetValue, SetValue);
			local dropdownOptions = GetOptions;
			local dropdownLabel = COMBAT_WARNINGS_SPELL_SUPPORT_ICONOGRAPHY_LABEL;
			local dropdownTooltip = COMBAT_WARNINGS_SPELL_SUPPORT_ICONOGRAPHY_TOOLTIP;

			local initializer = CreateSettingsCheckboxDropdownInitializer(checkboxSetting, checkboxLabel, checkboxTooltip, dropdownSetting, dropdownOptions, dropdownLabel, dropdownTooltip);
			initializer.getSelectionTextFunc = GetSelectionText;
			initializer:SetParentInitializer(subsectionInitializer);
			initializer:AddModifyPredicate(CanModifyBossTimelineSettings);
			initializer:AddEvaluateStateCVar(COMBAT_WARNINGS_ENABLED_CVAR);
			initializer:AddEvaluateStateCVar(ENCOUNTER_TIMELINE_ENABLED_CVAR);
			layout:AddInitializer(initializer);
			subsectionInitializer = initializer;
		end
	end);

	-- Cooldown Viewer
	InterfaceOverrides.RunSettingsCallback(function()
		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(COOLDOWN_VIEWER_LABEL));
	end);

	InterfaceOverrides.RunSettingsCallback(function()
		local addSearchTags = false;

		-- Cooldown Viewer enable checkbox
		local function TooltipFn()
			local isAvailable, failureReason = C_CooldownViewer.IsCooldownViewerAvailable();
			if isAvailable then
				return ENABLE_COOLDOWN_VIEWER_TOOLTIP;
			else
				return format("%s|n|n%s", ENABLE_COOLDOWN_VIEWER_TOOLTIP, failureReason);
			end
		end

		Settings.SetupCVarCheckbox(category, "cooldownViewerEnabled", ENABLE_COOLDOWN_VIEWER, TooltipFn);

		local function ShowDesiredPanelFromSettingsPanel(panel)
			local skipTransitionBackToOpeningPanel = true;
			SettingsPanel:Close(skipTransitionBackToOpeningPanel);
			ShowUIPanel(panel);
		end

		-- Open Edit Mode
		local function OpenEditMode()
			ShowDesiredPanelFromSettingsPanel(EditModeManagerFrame);
		end
		local editModeInitializer = CreateSettingsButtonInitializer("", COOLDOWN_VIEWER_OPTIONS_OPEN_EDIT_MODE, OpenEditMode, nil, addSearchTags);
		layout:AddInitializer(editModeInitializer);

		-- Open Cooldown Manager
		local function OpenCooldownManager()
			ShowDesiredPanelFromSettingsPanel(CooldownViewerSettings);
		end

		local managerInitializer = CreateSettingsButtonInitializer("", HUD_EDIT_MODE_COOLDOWN_VIEWER_SETTINGS, OpenCooldownManager, nil, addSearchTags, "ADVANCED_COOLDOWN_SETTINGS");
		layout:AddInitializer(managerInitializer);
	end);

	-- External Defensives
	InterfaceOverrides.RunSettingsCallback(function()
		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(EXTERNAL_DEFENSIVES_LABEL));
	end);

	InterfaceOverrides.RunSettingsCallback(function()
		-- External Defensives enable checkbox
		Settings.SetupCVarCheckbox(category, "externalDefensivesEnabled", ENABLE_EXTERNAL_DEFENSIVES_VIEWER, ENABLE_EXTERNAL_DEFENSIVES_TOOLTIP);
	end);

	-- Damage Meter
	InterfaceOverrides.RunSettingsCallback(function()
		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(DAMAGE_METER_LABEL));
	end);

	InterfaceOverrides.RunSettingsCallback(function()
		-- Damage Meter enable checkbox
		local function TooltipFn()
			local isAvailable, failureReason = C_DamageMeter.IsDamageMeterAvailable();
			if isAvailable then
				return ENABLE_DAMAGE_METER_TOOLTIP;
			else
				return format("%s|n|n%s", ENABLE_DAMAGE_METER_TOOLTIP, failureReason);
			end
		end

		Settings.SetupCVarCheckbox(category, "damageMeterEnabled", ENABLE_DAMAGE_METER, TooltipFn);
	end);

	-- Spell Diminishing Returns
	if C_SpellDiminish.IsSystemSupported() then
		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(SPELL_DIMINISH_SECTION_HEADER_LABEL));

		local _pvpEnemiesEnabledSetting, pvpEnemiesEnabledInitializer = Settings.SetupCVarCheckbox(category, "spellDiminishPVPEnemiesEnabled", SPELL_DIMINISH_PVP_ENABLE_SETTING_LABEL, SPELL_DIMINISH_PVP_ENABLE_SETTING_TOOLTIP);

		local _onlyTriggerableByMeSetting, onlyTriggerableByMeInitializer = Settings.SetupCVarCheckbox(category, "spellDiminishPVPOnlyTriggerableByMe", SPELL_DIMINISH_PVP_ONLY_CAST_BY_ME_LABEL, SPELL_DIMINISH_PVP_ONLY_CAST_BY_ME_TOOLTIP);
		local function CanUpdateOnlyTriggerableByMe()
			return C_CVar.GetCVarBool("spellDiminishPVPEnemiesEnabled");
		end
		onlyTriggerableByMeInitializer:SetParentInitializer(pvpEnemiesEnabledInitializer, CanUpdateOnlyTriggerableByMe);
	end

	Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);
end

SettingsRegistrar:AddRegistrant(Register);
