local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(INTERFACE_LABEL);

	-- My name
	Settings.SetupCVarCheckBox(category, "UnitNameOwn", UNIT_NAME_OWN, OPTION_TOOLTIP_UNIT_NAME_OWN);

	-- NPC Names
	do
		local function GetValue()
			if GetCVarBool("UnitNameNPC") then
				return 4;
			else
				local specialNPCName = GetCVarBool("UnitNameFriendlySpecialNPCName");
				local hostileNPCName = GetCVarBool("UnitNameHostleNPC");
				local specialAndHostile = specialNPCName and hostileNPCName;
				if specialAndHostile and GetCVarBool("UnitNameInteractiveNPC") then
					return 3;
				elseif specialAndHostile then
					return 2;
				elseif specialNPCName then
					return 1;
				end
			end
			
			return 5;
		end
		
		local function SetValue(value)
			if value == 1 then
				SetCVar("UnitNameFriendlySpecialNPCName", "1");
				SetCVar("UnitNameNPC", "0");
				SetCVar("UnitNameHostleNPC", "0");
				SetCVar("UnitNameInteractiveNPC", "0");
				SetCVar("ShowQuestUnitCircles", "0");
			elseif value == 2 then
				SetCVar("UnitNameFriendlySpecialNPCName", "1");
				SetCVar("UnitNameHostleNPC", "1");
				SetCVar("UnitNameInteractiveNPC", "0");
				SetCVar("UnitNameNPC", "0");
				SetCVar("ShowQuestUnitCircles", "1");
			elseif value == 3 then
				SetCVar("UnitNameFriendlySpecialNPCName", "1");
				SetCVar("UnitNameHostleNPC", "1");
				SetCVar("UnitNameInteractiveNPC", "1");
				SetCVar("UnitNameNPC", "0");
				SetCVar("ShowQuestUnitCircles", "1");
			elseif value == 4 then
				SetCVar("UnitNameFriendlySpecialNPCName", "0");
				SetCVar("UnitNameHostleNPC", "0");
				SetCVar("UnitNameInteractiveNPC", "0");
				SetCVar("UnitNameNPC", "1");
				SetCVar("ShowQuestUnitCircles", "1");
			else
				SetCVar("UnitNameFriendlySpecialNPCName", "0");
				SetCVar("UnitNameHostleNPC", "0");
				SetCVar("UnitNameInteractiveNPC", "0");
				SetCVar("UnitNameNPC", "0");
				SetCVar("ShowQuestUnitCircles", "1");
			end
		end

		local function GetOptions()
			local container = Settings.CreateDropDownTextContainer();
			container:Add(1, NPC_NAMES_DROPDOWN_TRACKED, NPC_NAMES_DROPDOWN_TRACKED_TOOLTIP);
			container:Add(2, NPC_NAMES_DROPDOWN_HOSTILE, NPC_NAMES_DROPDOWN_HOSTILE_TOOLTIP);
			container:Add(3, NPC_NAMES_DROPDOWN_INTERACTIVE, NPC_NAMES_DROPDOWN_INTERACTIVE_TOOLTIP);
			container:Add(4, NPC_NAMES_DROPDOWN_ALL, NPC_NAMES_DROPDOWN_ALL_TOOLTIP);
			container:Add(5, NPC_NAMES_DROPDOWN_NONE, NPC_NAMES_DROPDOWN_NONE_TOOLTIP);
			return container:GetData();
		end

		local defaultValue = 2;
		local setting = Settings.RegisterProxySetting(category, "PROXY_NPC_NAMES", Settings.DefaultVarLocation,
			Settings.VarType.Number, SHOW_NPC_NAMES, defaultValue, GetValue, SetValue);
		Settings.CreateDropDown(category, setting, GetOptions, OPTION_TOOLTIP_NPC_NAMES_DROPDOWN);
	end

	-- Critters and Companions
	Settings.SetupCVarCheckBox(category, "UnitNameNonCombatCreatureName", UNIT_NAME_NONCOMBAT_CREATURE, OPTION_TOOLTIP_UNIT_NAME_NONCOMBAT_CREATURE);

	-- Friendly Players
	do
		local friendlyPlayerNameSetting, friendlyPlayerNameInitializer = Settings.SetupCVarCheckBox(category, "UnitNameFriendlyPlayerName", UNIT_NAME_FRIENDLY, OPTION_TOOLTIP_UNIT_NAME_FRIENDLY);

		-- Minions
		local setting, initializer = Settings.SetupCVarCheckBox(category, "UnitNameFriendlyMinionName", UNIT_NAME_FRIENDLY_MINIONS, OPTION_TOOLTIP_UNIT_NAME_FRIENDLY_MINIONS);
		initializer:Indent();
		initializer:SetParentInitializer(friendlyPlayerNameInitializer);
	end
	
	-- Enemy Players
	do
		local enemyPlayerNameSetting, enemyPlayerNameInitializer = Settings.SetupCVarCheckBox(category, "UnitNameEnemyPlayerName", UNIT_NAME_ENEMY, OPTION_TOOLTIP_UNIT_NAME_ENEMY);

		-- Minions
		local setting, initializer = Settings.SetupCVarCheckBox(category, "UnitNameEnemyMinionName", UNIT_NAME_ENEMY_MINIONS, OPTION_TOOLTIP_UNIT_NAME_ENEMY_MINIONS);
		initializer:Indent();
		initializer:SetParentInitializer(enemyPlayerNameInitializer);
	end

	-- Always Show Nameplates
	do
		Settings.SetupCVarCheckBox(category, "nameplateShowAll", UNIT_NAMEPLATES_AUTOMODE, OPTION_TOOLTIP_UNIT_NAMEPLATES_AUTOMODE);
	end

	-- Personal Resource Display
	do
		Settings.SetupCVarCheckBox(category, "nameplateShowSelf", DISPLAY_PERSONAL_RESOURCE, OPTION_TOOLTIP_DISPLAY_PERSONAL_RESOURCE);
	end

	-- Show Special Resources
	do
		Settings.SetupCVarCheckBox(category, "nameplateResourceOnTarget", DISPLAY_PERSONAL_RESOURCE_ON_ENEMY, OPTION_TOOLTIP_DISPLAY_PERSONAL_RESOURCE_ON_ENEMY);
	end

	-- Larger Nameplates
	do
		local normalScale = 1.0;
		local function GetValue()
			local hScale = tonumber(GetCVar("NamePlateHorizontalScale"));
			local vScale = tonumber(GetCVar("NamePlateVerticalScale"));
			local cScale = tonumber(GetCVar("NamePlateClassificationScale"));
			return not (ApproximatelyEqual(hScale, normalScale) and ApproximatelyEqual(vScale, normalScale) and ApproximatelyEqual(cScale, normalScale));
		end
		
		local function SetValue(value)
			if value then
				SetCVar("NamePlateHorizontalScale", 1.4);
				SetCVar("NamePlateVerticalScale", 2.7);
				SetCVar("NamePlateClassificationScale", 1.25);
			else
				SetCVar("NamePlateHorizontalScale", normalScale);
				SetCVar("NamePlateVerticalScale", normalScale);
				SetCVar("NamePlateClassificationScale", normalScale);
			end
		end

		local defaultValue = false;
		local setting = Settings.RegisterProxySetting(category, "PROXY_LARGER_SETTINGS", Settings.DefaultVarLocation, 
			Settings.VarType.Boolean, UNIT_NAMEPLATES_MAKE_LARGER, defaultValue, GetValue, SetValue);
		local initializer = Settings.CreateCheckBox(category, setting, OPTION_TOOLTIP_UNIT_NAMEPLATES_MAKE_LARGER);
		initializer:AddModifyPredicate(function()
			return not C_Commentator.IsSpectating();
		end);
	end

	-- Enemy Units
	do
		local enemyTooltip = Settings.WrapTooltipWithBinding(OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_ENEMIES, "NAMEPLATES");
		local enemyUnitSetting, enemyUnitInitializer = Settings.SetupCVarCheckBox(category, "nameplateShowEnemies", UNIT_NAMEPLATES_SHOW_ENEMIES, enemyTooltip);

		-- Minions
		do
			local setting, initializer = Settings.SetupCVarCheckBox(category, "nameplateShowEnemyMinions", UNIT_NAMEPLATES_SHOW_ENEMY_MINIONS, OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_ENEMY_MINIONS);
			initializer:Indent();
			initializer:SetParentInitializer(enemyUnitInitializer);
		end

		-- Minor
		do
			local setting, initializer = Settings.SetupCVarCheckBox(category, "nameplateShowEnemyMinus", UNIT_NAMEPLATES_SHOW_ENEMY_MINUS, OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_ENEMY_MINUS);
			initializer:Indent();
			initializer:SetParentInitializer(enemyUnitInitializer);
		end
	end

	-- Friendly Players
	do
		local friendlyTooltip = Settings.WrapTooltipWithBinding(OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_FRIENDS, "FRIENDNAMEPLATES");
		local friendUnitSetting, friendUnitInitializer = Settings.SetupCVarCheckBox(category, "nameplateShowFriends", UNIT_NAMEPLATES_SHOW_FRIENDS, friendlyTooltip);

		-- Minions
		local setting, initializer = Settings.SetupCVarCheckBox(category, "nameplateShowFriendlyMinions", UNIT_NAMEPLATES_SHOW_FRIENDLY_MINIONS, OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_FRIENDLY_MINIONS);
		initializer:Indent();
		initializer:SetParentInitializer(friendUnitInitializer);
	end

	-- Flash on Agro Loss
	Settings.SetupCVarCheckBox(category, "ShowNamePlateLoseAggroFlash", SHOW_NAMEPLATE_LOSE_AGGRO_FLASH, OPTION_TOOLTIP_SHOW_NAMEPLATE_LOSE_AGGRO_FLASH);

	-- Nameplate Motion Type
	do
		local function GetOptions()
			local container = Settings.CreateDropDownTextContainer();
			for index = 1, C_NamePlate.GetNumNamePlateMotionTypes() do
				local label = _G["UNIT_NAMEPLATES_TYPE_"..index];
				local tooltip = _G["UNIT_NAMEPLATES_TYPE_TOOLTIP_"..index];
				container:Add(index-1, label, tooltip);
			end
			return container:GetData();
		end

		Settings.SetupCVarDropDown(category, "nameplateMotion", Settings.VarType.Number, GetOptions, UNIT_NAMEPLATES_TYPES, OPTION_TOOLTIP_UNIT_NAMEPLATES_TYPES);
	end
	
	---ActionBars
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(ACTIONBARS_LABEL));

	-- Action Bars 1-4
	do
		local function GetActionBarToggle(index)
			return select(index, GetActionBarToggles());
		end
		
		local function SetActionBarToggle(index, value)
			local toggles = {GetActionBarToggles()};
			toggles[index] = value;
			SetActionBarToggles(unpack(toggles));
		end
		
		local actionBars = 
		{
			{variable = "PROXY_SHOW_MULTI_ACTIONBAR_1", label = SHOW_MULTIBAR1_TEXT, tooltip = OPTION_TOOLTIP_SHOW_MULTIBAR1},
			{variable = "PROXY_SHOW_MULTI_ACTIONBAR_2", label = SHOW_MULTIBAR2_TEXT, tooltip = OPTION_TOOLTIP_SHOW_MULTIBAR2},
			{variable = "PROXY_SHOW_MULTI_ACTIONBAR_3", label = SHOW_MULTIBAR3_TEXT, tooltip = OPTION_TOOLTIP_SHOW_MULTIBAR3},
			{variable = "PROXY_SHOW_MULTI_ACTIONBAR_4", label = SHOW_MULTIBAR4_TEXT, tooltip = OPTION_TOOLTIP_SHOW_MULTIBAR4},
		};

		for index, data in ipairs(actionBars) do
			local function GetValue()
				return GetActionBarToggle(index);
			end
			
			local function SetValue(value)
				SetActionBarToggle(index, value);
			end
		
			local defaultValue = true;
			local setting = Settings.RegisterProxySetting(category, data.variable, Settings.DefaultVarLocation,
				Settings.VarType.Boolean, data.label, defaultValue, GetValue, SetValue);
			actionBars[index].setting = setting;
			actionBars[index].initializer = Settings.CreateCheckBox(category, setting, data.tooltip);
		end

		local actionBar1Setting = actionBars[1].setting;
		local actionBar1Initializer = actionBars[1].initializer;
		local actionBar2Initializer = actionBars[2].initializer;
		local function IsModifiableActionBar1Setting()
			return actionBar1Setting:GetValue();
		end
		actionBar2Initializer:SetParentInitializer(actionBar1Initializer, IsModifiableActionBar1Setting);

		local actionBar3Setting = actionBars[3].setting;
		local actionBar3Initializer = actionBars[3].initializer;
		local actionBar4Initializer = actionBars[4].initializer;
		local function IsModifiableActionBar3Setting()
			return actionBar3Setting:GetValue();
		end
		actionBar4Initializer:SetParentInitializer(actionBar3Initializer, IsModifiableActionBar3Setting);
	end

	-- Lock Action Bars
	do

		local cbSetting = Settings.RegisterCVarSetting(category, "lockActionBars", Settings.VarType.Boolean, LOCK_ACTIONBAR_TEXT);

		local tooltips = {
			OPTION_TOOLTIP_PICKUP_ACTION_ALT_KEY,
			OPTION_TOOLTIP_PICKUP_ACTION_CTRL_KEY,
			OPTION_TOOLTIP_PICKUP_ACTION_SHIFT_KEY,
			OPTION_TOOLTIP_PICKUP_ACTION_NONE_KEY,
		};
		local options = Settings.CreateModifiedClickOptions(tooltips);
		local dropDownSetting = Settings.RegisterModifiedClickSetting(category, "PICKUPACTION", PICKUP_ACTION_KEY_TEXT, "SHIFT");

		local initializer = CreateSettingsCheckBoxDropDownInitializer(
			cbSetting, LOCK_ACTIONBAR_TEXT, OPTION_TOOLTIP_LOCK_ACTIONBAR,
			dropDownSetting, options, PICKUP_ACTION_KEY_TEXT, OPTION_TOOLTIP_PICKUP_ACTION_KEY_TEXT);
		initializer:AddSearchTags(LOCK_ACTIONBAR_TEXT);
		layout:AddInitializer(initializer);
	end

	-- Show Numbers for Cooldowns
	Settings.SetupCVarCheckBox(category, "countdownForCooldowns", COUNTDOWN_FOR_COOLDOWNS_TEXT, OPTION_TOOLTIP_COUNTDOWN_FOR_COOLDOWNS);

	----Combat
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(COMBAT_LABEL));

	-- Target of Target
	Settings.SetupCVarCheckBox(category, "showTargetOfTarget", SHOW_TARGET_OF_TARGET_TEXT, OPTION_TOOLTIP_SHOW_TARGET_OF_TARGET);

	-- Low Agro Flash
	Settings.SetupCVarCheckBox(category, "doNotFlashLowHealthWarning", FLASH_LOW_HEALTH_WARNING, OPTION_TOOLTIP_FLASH_LOW_HEALTH_WARNING);

	-- Loss of Control Alerts
	Settings.SetupCVarCheckBox(category, "lossOfControl", LOSS_OF_CONTROL, OPTION_TOOLTIP_LOSS_OF_CONTROL);

	-- Scrolling Combat Text
	do
		Settings.SetupCVarCheckBox(category, "enableFloatingCombatText", SHOW_COMBAT_TEXT_TEXT, OPTION_TOOLTIP_SHOW_COMBAT_TEXT);
		Settings.LoadAddOnCVarWatcher("enableFloatingCombatText", "Blizzard_CombatText");
	end

	-- Mouseover Cast control
	do

		local cbSetting = Settings.RegisterCVarSetting(category, "enableMouseoverCast", Settings.VarType.Boolean, ENABLE_MOUSEOVER_CAST);

		local tooltips = {
			OPTION_TOOLTIP_MOUSEOVER_CAST_CTRL_KEY,
			OPTION_TOOLTIP_MOUSEOVER_CAST_SHIFT_KEY,
			OPTION_TOOLTIP_MOUSEOVER_CAST_ALT_KEY,
			OPTION_TOOLTIP_MOUSEOVER_CAST_NONE_KEY,
		};
		local options = Settings.CreateModifiedClickOptions(tooltips);
		local dropDownSetting = Settings.RegisterModifiedClickSetting(category, "MOUSEOVERCAST", MOUSEOVER_CAST_KEY, "NONE");

		local initializer = CreateSettingsCheckBoxDropDownInitializer(
			cbSetting, ENABLE_MOUSEOVER_CAST, OPTION_TOOLTIP_ENABLE_MOUSEOVER_CAST,
			dropDownSetting, options, MOUSEOVER_CAST_KEY, OPTION_TOOLTIP_MOUSEOVER_CAST_KEY_TEXT);
		layout:AddInitializer(initializer);
	end

	-- Auto Self Cast
	Settings.SetupCVarCheckBox(category, "autoSelfCast", AUTO_SELF_CAST_TEXT, OPTION_TOOLTIP_AUTO_SELF_CAST);

	-- Spell Alert Opacity
	do
		local minValue, maxValue, step = 0, 1, .05;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, FormatPercentage);

		local setting = Settings.SetupCVarSlider(category, "spellActivationOverlayOpacity", options, SPELL_ALERT_OPACITY, OPTION_TOOLTIP_SPELL_ALERT_OPACITY);
		local function OnValueChanged(o, setting, value)
			SetCVar("displaySpellActivationOverlays", value > 0);
		end
		Settings.SetOnValueChangedCallback("spellActivationOverlayOpacity", OnValueChanged);
	end

	----Display
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(DISPLAY_LABEL));

	-- Rotate Minimap
	Settings.SetupCVarCheckBox(category, "rotateMinimap", ROTATE_MINIMAP, OPTION_TOOLTIP_ROTATE_MINIMAP);

	-- Hide Adventure Guide Alerts
	Settings.SetupCVarCheckBox(category, "hideAdventureJournalAlerts", HIDE_ADVENTURE_JOURNAL_ALERTS, OPTION_TOOLTIP_HIDE_ADVENTURE_JOURNAL_ALERTS);

	-- In Game Navigation
	Settings.SetupCVarCheckBox(category, "showInGameNavigation", SHOW_IN_GAME_NAVIGATION, OPTION_TOOLTIP_SHOW_IN_GAME_NAVIGATION);

	-- Tutorials
	-- FIXME DISABLE BUTTON BEHAVIOR
	do
		local setting = Settings.RegisterCVarSetting(category, "showTutorials", Settings.VarType.Boolean, SHOW_TUTORIALS);
		local function OnButtonClick(button, buttonName, down)
			SetCVar("closedInfoFrames", ""); -- reset the help plates too
			SetCVar("closedInfoFramesAccountWide", "");
			SetCVar("showNPETutorials", "1");
			ResetTutorials();
			TutorialFrame_ClearQueue();
			NPETutorial_AttemptToBegin();
			TriggerTutorial(1);

			button:Disable();

			setting:SetValue(true);
		end;

		local initializer = CreateSettingsCheckBoxWithButtonInitializer(setting, RESET_TUTORIALS, OnButtonClick, false, OPTION_TOOLTIP_SHOW_TUTORIALS);
		layout:AddInitializer(initializer);
	end

	-- Outline
	do 
		local function GetOptions()
			local container = Settings.CreateDropDownTextContainer();
			container:Add(0, OBJECT_NPC_OUTLINE_DISABLED);
			container:Add(1, OBJECT_NPC_OUTLINE_MODE_ONE);
			container:Add(2, OBJECT_NPC_OUTLINE_MODE_TWO);
			container:Add(3, OBJECT_NPC_OUTLINE_MODE_THREE);
			return container:GetData();
		end

		Settings.SetupCVarDropDown(category, "Outline", Settings.VarType.Number, GetOptions, OBJECT_NPC_OUTLINE, OPTION_TOOLTIP_OBJECT_NPC_OUTLINE);
	end

	-- Self highlight
	do
		local function GetOptions()
			local container = Settings.CreateDropDownTextContainer();
			container:Add(0, SELF_HIGHLIGHT_MODE_CIRCLE);
			container:Add(2, SELF_HIGHLIGHT_MODE_OUTLINE);
			container:Add(1, SELF_HIGHLIGHT_MODE_CIRCLE_AND_OUTLINE);
			container:Add(-1, OFF);
			return container:GetData();
		end

		Settings.SetupCVarDropDown(category, "findYourselfMode", Settings.VarType.Number, GetOptions, SELF_HIGHLIGHT_OPTION, OPTION_TOOLTIP_SELF_HIGHLIGHT);
	end

	-- Status text 
	do
		local CVAR_VALUE_NUMERIC = "NUMERIC";
		local CVAR_VALUE_PERCENT = "PERCENT";
		local CVAR_VALUE_BOTH = "BOTH";
		local CVAR_VALUE_NONE = "NONE";

		local function GetValue()
			local statusTextDisplay = C_CVar.GetCVar("statusTextDisplay");
			if statusTextDisplay == CVAR_VALUE_NUMERIC then
				return 1;
			elseif statusTextDisplay == CVAR_VALUE_PERCENT then
				return 2;
			elseif statusTextDisplay == CVAR_VALUE_BOTH then
				return 3;
			elseif statusTextDisplay == CVAR_VALUE_NONE then
				return 4;
			end
		end
		
		local function SetValue(value)
			if value == 1 then
				SetCVar("statusTextDisplay", CVAR_VALUE_NUMERIC);
				SetCVar("statusText", "1");
			elseif value == 2 then
				SetCVar("statusTextDisplay", CVAR_VALUE_PERCENT);
				SetCVar("statusText", "1");
			elseif value == 3 then
				SetCVar("statusTextDisplay", CVAR_VALUE_BOTH);
				SetCVar("statusText", "1");
			elseif value == 4 then
				SetCVar("statusTextDisplay", CVAR_VALUE_NONE);
				SetCVar("statusText", "0");
			end
		end
		
		local function GetOptions()
			local container = Settings.CreateDropDownTextContainer();
			container:Add(1, STATUS_TEXT_VALUE);
			container:Add(2, STATUS_TEXT_PERCENT);
			container:Add(3, STATUS_TEXT_BOTH);
			container:Add(4, NONE);
			return container:GetData();
		end

		local defaultValue = 4;
		local setting = Settings.RegisterProxySetting(category, "PROXY_STATUS_TEXT", Settings.DefaultVarLocation, 
			Settings.VarType.Number, STATUSTEXT_LABEL, defaultValue, GetValue, SetValue);
		Settings.CreateDropDown(category, setting, GetOptions, OPTION_TOOLTIP_STATUS_TEXT_DISPLAY);
	end


	-- Chat bubbles
	do
		local function GetValue()
			local chatBubbles = C_CVar.GetCVarBool("chatBubbles");
			local chatBubblesParty = C_CVar.GetCVarBool("chatBubblesParty");
			if chatBubbles and chatBubblesParty then
				return 1;
			elseif not chatBubbles and not chatBubblesParty then
				return 2;
			elseif chatBubbles and not chatBubblesParty then
				return 3;
			end
		end
		
		local function SetValue(value)
			if value == 1 then
				SetCVar("chatBubbles", "1");
				SetCVar("chatBubblesParty", "1");
			elseif value == 2 then
				SetCVar("chatBubbles", "0");
				SetCVar("chatBubblesParty", "0");
			elseif value == 3 then
				SetCVar("chatBubbles", "1");
				SetCVar("chatBubblesParty", "0");
			end
		end
		
		local function GetOptions()
			local container = Settings.CreateDropDownTextContainer();
			container:Add(1, ALL);
			container:Add(2, NONE);
			container:Add(3, CHAT_BUBBLES_EXCLUDE_PARTY_CHAT);
			return container:GetData();
		end

		local defaultValue = 1;
		local setting = Settings.RegisterProxySetting(category, "PROXY_CHAT_BUBBLES", Settings.DefaultVarLocation, 
			Settings.VarType.Number, CHAT_BUBBLES_TEXT, defaultValue, GetValue, SetValue);
		Settings.CreateDropDown(category, setting, GetOptions, OPTION_TOOLTIP_CHAT_BUBBLES);
	end

	Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);
end

SettingsRegistrar:AddRegistrant(Register);