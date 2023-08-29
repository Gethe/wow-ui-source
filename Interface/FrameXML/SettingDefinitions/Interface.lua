RaidFramePreviewMixin = { };

function RaidFramePreviewMixin:OnLoad()
	CompactUnitFrame_SetUpFrame(self.RaidFrame, DefaultCompactUnitFrameSetup);
	CompactUnitFrame_SetUnit(self.RaidFrame, "player");
end

local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(INTERFACE_LABEL);
	Settings.INTERFACE_CATEGORY_ID = category:GetID();

	-- Order set in GameplaySettingsGroup.lua
	category:SetOrder(CUSTOM_GAMEPLAY_SETTINGS_ORDER[INTERFACE_LABEL]);

	-- Names
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(NAMES_LABEL));

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
			local container = Settings.CreateControlTextContainer();
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

	-- Nameplates
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(NAMEPLATES_LABEL));

	-- Always Show Nameplates
	do
		Settings.SetupCVarCheckBox(category, "nameplateShowAll", UNIT_NAMEPLATES_AUTOMODE, OPTION_TOOLTIP_UNIT_NAMEPLATES_AUTOMODE);
	end

	-- Larger Nameplates
	do
		InterfaceOverrides.CreateLargerNameplateSetting(category);
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

	-- Friendly nameplates
	do
		local friendlyTooltip = Settings.WrapTooltipWithBinding(OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_FRIENDS, "FRIENDNAMEPLATES");
		local friendUnitSetting, friendUnitInitializer = Settings.SetupCVarCheckBox(category, "nameplateShowFriends", UNIT_NAMEPLATES_SHOW_FRIENDS, friendlyTooltip);

		-- Minions
		local setting, initializer = Settings.SetupCVarCheckBox(category, "nameplateShowFriendlyMinions", UNIT_NAMEPLATES_SHOW_FRIENDLY_MINIONS, OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_FRIENDLY_MINIONS);
		initializer:Indent();
		initializer:SetParentInitializer(friendUnitInitializer);
	end

	if C_CVar.GetCVar("ShowNamePlateLoseAggroFlash") then
		-- Flash on Agro Loss
		Settings.SetupCVarCheckBox(category, "ShowNamePlateLoseAggroFlash", SHOW_NAMEPLATE_LOSE_AGGRO_FLASH, OPTION_TOOLTIP_SHOW_NAMEPLATE_LOSE_AGGRO_FLASH);
	end

	-- Nameplate Motion Type
	do
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			for index = 1, C_NamePlate.GetNumNamePlateMotionTypes() do
				local label = _G["UNIT_NAMEPLATES_TYPE_"..index];
				local tooltip = _G["UNIT_NAMEPLATES_TYPE_TOOLTIP_"..index];
				container:Add(index-1, label, tooltip);
			end
			return container:GetData();
		end

		Settings.SetupCVarDropDown(category, "nameplateMotion", Settings.VarType.Number, GetOptions, UNIT_NAMEPLATES_TYPES, OPTION_TOOLTIP_UNIT_NAMEPLATES_TYPES);
	end

	InterfaceOverrides.AdjustNameplateSettings(category);

	----Display
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(DISPLAY_LABEL));

	if C_CVar.GetCVar("ShowNamePlateLoseAggroFlash") then
		-- Hide Adventure Guide Alerts
		Settings.SetupCVarCheckBox(category, "hideAdventureJournalAlerts", HIDE_ADVENTURE_JOURNAL_ALERTS, OPTION_TOOLTIP_HIDE_ADVENTURE_JOURNAL_ALERTS);
	end

	if C_CVar.GetCVar("showInGameNavigation") then
		-- In Game Navigation
		Settings.SetupCVarCheckBox(category, "showInGameNavigation", SHOW_IN_GAME_NAVIGATION, OPTION_TOOLTIP_SHOW_IN_GAME_NAVIGATION);
	end

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
	if C_CVar.GetCVar("Outline") then
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add(0, OBJECT_NPC_OUTLINE_DISABLED);
			container:Add(1, OBJECT_NPC_OUTLINE_MODE_ONE);
			container:Add(2, OBJECT_NPC_OUTLINE_MODE_TWO);
			container:Add(3, OBJECT_NPC_OUTLINE_MODE_THREE);
			return container:GetData();
		end

		Settings.SetupCVarDropDown(category, "Outline", Settings.VarType.Number, GetOptions, OBJECT_NPC_OUTLINE, OPTION_TOOLTIP_OBJECT_NPC_OUTLINE);
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
			local container = Settings.CreateControlTextContainer();
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
			elseif not chatBubbles then
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
			local container = Settings.CreateControlTextContainer();
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

	-- ReplaceOtherPlayerPortraits
	if C_CVar.GetCVar("ReplaceOtherPlayerPortraits") then
		Settings.SetupCVarCheckBox(category, "ReplaceOtherPlayerPortraits", REPLACE_OTHER_PLAYER_PORTRAITS, OPTION_TOOLTIP_REPLACE_OTHER_PLAYER_PORTRAITS);
	end

	-- ReplaceMyPlayerPortrait
	if C_CVar.GetCVar("ReplaceMyPlayerPortrait") then
		Settings.SetupCVarCheckBox(category, "ReplaceMyPlayerPortrait", REPLACE_MY_PLAYER_PORTRAIT, OPTION_TOOLTIP_REPLACE_MY_PLAYER_PORTRAIT);
	end

	InterfaceOverrides.AdjustDisplaySettings(category);

	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(RAID_FRAMES_LABEL));

	-- Some 3rd party addons like to disable this addon. Don't initialize the settings for it and display a "disabled" label in its place if it is disabled.
	if (IsAddOnLoaded("Blizzard_CUFProfiles") ) then
		InterfaceOverrides.CreateRaidFrameSettings(category, layout)
	else
		layout:AddInitializer(CreateSettingsAddOnDisabledLabelInitializer());
	end
	
	InterfaceOverrides.CreatePvpFrameSettings(category, layout);
	
	Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);
end

SettingsRegistrar:AddRegistrant(Register);