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

	-- Nameplates (Hook for Classic. Names and Nameplates options Have been moved to Nameplates.lua for 12.0.)
	InterfaceOverrides.AdjustNameplateSettings(category, layout);

	----Display
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(DISPLAY_LABEL));

	InterfaceOverrides.RunSettingsCallback(function()
		if C_CVar.GetCVar("showInGameNavigation") then
			-- In Game Navigation
			Settings.SetupCVarCheckbox(category, "showInGameNavigation", SHOW_IN_GAME_NAVIGATION, OPTION_TOOLTIP_SHOW_IN_GAME_NAVIGATION);
		end
	end);

		-- Tutorials
		-- FIXME DISABLE BUTTON BEHAVIOR
	InterfaceOverrides.RunSettingsCallback(function()
		local setting = Settings.RegisterCVarSetting(category, "showTutorials", Settings.VarType.Boolean, SHOW_TUTORIALS);
		local function OnButtonClick(button, buttonName, down)
			InterfaceOverrides.ShowTutorialsOnButtonClick();

			button:Disable();

			setting:SetValue(true);
		end;

		local initializer = CreateSettingsCheckboxWithButtonInitializer(setting, RESET_TUTORIALS, OnButtonClick, false, OPTION_TOOLTIP_SHOW_TUTORIALS);
		layout:AddInitializer(initializer);
	end);

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

		Settings.SetupCVarDropdown(category, "Outline", Settings.VarType.Number, GetOptions, OBJECT_NPC_OUTLINE, OPTION_TOOLTIP_OBJECT_NPC_OUTLINE);
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
		local setting = Settings.RegisterProxySetting(category, "PROXY_STATUS_TEXT",
			Settings.VarType.Number, STATUSTEXT_LABEL, defaultValue, GetValue, SetValue);
		Settings.CreateDropdown(category, setting, GetOptions, OPTION_TOOLTIP_STATUS_TEXT_DISPLAY);
	end


	InterfaceOverrides.RunSettingsCallback(function()
		-- Chat Bubbles
		local chatBubblesSetting, chatBubblesInitializer = Settings.SetupCVarCheckbox(category, "chatBubbles", CHAT_BUBBLES_TEXT, OPTION_TOOLTIP_CHAT_BUBBLES);

		-- Party Chat Bubbles
		local chatBubblesPartySetting, chatBubblesPartyInitializer = Settings.SetupCVarCheckbox(category, "chatBubblesParty", PARTY_CHAT_BUBBLES_TEXT, OPTION_TOOLTIP_PARTY_CHAT_BUBBLES);
		chatBubblesPartyInitializer:Indent();
		chatBubblesPartyInitializer:SetParentInitializer(chatBubblesInitializer);

		-- Raid Chat Bubbles
		local chatBubblesRaidSetting, chatBubblesRaidInitializer = Settings.SetupCVarCheckbox(category, "chatBubblesRaid", RAID_CHAT_BUBBLES_TEXT, OPTION_TOOLTIP_RAID_CHAT_BUBBLES);
		chatBubblesRaidInitializer:Indent();
		chatBubblesRaidInitializer:SetParentInitializer(chatBubblesInitializer);
	end);

	InterfaceOverrides.RunSettingsCallback(function()
		-- ReplaceOtherPlayerPortraits
		if C_CVar.GetCVar("ReplaceOtherPlayerPortraits") then
			Settings.SetupCVarCheckbox(category, "ReplaceOtherPlayerPortraits", REPLACE_OTHER_PLAYER_PORTRAITS, OPTION_TOOLTIP_REPLACE_OTHER_PLAYER_PORTRAITS);
		end

		-- ReplaceMyPlayerPortrait
		if C_CVar.GetCVar("ReplaceMyPlayerPortrait") then
			Settings.SetupCVarCheckbox(category, "ReplaceMyPlayerPortrait", REPLACE_MY_PLAYER_PORTRAIT, OPTION_TOOLTIP_REPLACE_MY_PLAYER_PORTRAIT);
		end
	end);

	-- Quest Settings
	do
		InterfaceOverrides.CreateQuestSettings(category, layout);
	end

	InterfaceOverrides.AdjustDisplaySettings(category);

	InterfaceOverrides.RunSettingsCallback(function()
		layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(RAID_FRAMES_LABEL));

		-- Some 3rd party addons like to disable this addon. Don't initialize the settings for it and display a "disabled" label in its place if it is disabled.
		if (C_AddOns.IsAddOnLoaded("Blizzard_CUFProfiles") ) then
			InterfaceOverrides.CreateRaidFrameSettings(category, layout)
		else
			layout:AddInitializer(CreateSettingsAddOnDisabledLabelInitializer());
		end

		InterfaceOverrides.CreatePvpFrameSettings(category, layout);
	end);

	Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);
end

SettingsRegistrar:AddRegistrant(Register);
