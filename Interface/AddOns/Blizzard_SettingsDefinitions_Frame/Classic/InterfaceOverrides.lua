InterfaceOverrides = {}

function InterfaceOverrides.AdjustDisplaySettings(category)
	if (not C_TransmogOutfitInfo.IsTransmogEnabled()) then
		do
			-- Show Helm
			local function GetValue()
				return ShowingHelm();
			end
			
			local function SetValue(value)
				ShowHelm(value);
			end
			
			local defaultValue = true;
			local setting = Settings.RegisterProxySetting(category, "PROXY_SHOW_HELM",
				Settings.VarType.Boolean, SHOW_HELM, defaultValue, GetValue, SetValue);
			Settings.CreateCheckbox(category, setting, OPTION_TOOLTIP_SHOW_HELM);
		end
	
		do
			-- Show Cloak
			local function GetValue()
				return ShowingCloak();
			end
			
			local function SetValue(value)
				ShowCloak(value);
			end
			
			local defaultValue = true;
			local setting = Settings.RegisterProxySetting(category, "PROXY_SHOW_CLOAK",
				Settings.VarType.Boolean, SHOW_CLOAK, defaultValue, GetValue, SetValue);
			Settings.CreateCheckbox(category, setting, OPTION_TOOLTIP_SHOW_CLOAK);
		end
	end

	if (C_GameRules.IsHardcoreActive()) then
		do
			-- What sort of messages to filter in the "HardcoreDeaths" channel
			local function GetOptions()
				local container = Settings.CreateControlTextContainer();
				container:Add(0, HARDCORE_ANNOUNCE_DEATH_GUILD, OPTION_TOOLTIP_HARDCORE_ANNOUNCE_DEATH_DISPLAY1);
				container:Add(1, HARDCORE_ANNOUNCE_DEATH_ALL, OPTION_TOOLTIP_HARDCORE_ANNOUNCE_DEATH_DISPLAY2);
				return container:GetData();
			end
	
			Settings.SetupCVarDropdown(category, "hardcoreDeathChatType", Settings.VarType.Number, GetOptions, HARDCORE_ANNOUNCE_DEATH, nil);
		end
		do
			-- What sort of messages to announce as a raid-style warning
			local function GetOptions()
				local container = Settings.CreateControlTextContainer();
				container:Add(0, NEVER, OPTION_TOOLTIP_HARDCORE_ANNOUNCE_DEATH_ALERT_DISPLAY1);
				container:Add(1, HARDCORE_ANNOUNCE_DEATH_GUILD, OPTION_TOOLTIP_HARDCORE_ANNOUNCE_DEATH_ALERT_DISPLAY2);
				container:Add(2, HARDCORE_ANNOUNCE_DEATH_ALL, OPTION_TOOLTIP_HARDCORE_ANNOUNCE_DEATH_ALERT_DISPLAY3);
				return container:GetData();
			end
	
			Settings.SetupCVarDropdown(category, "hardcoreDeathAlertType", Settings.VarType.Number, GetOptions, HARDCORE_ANNOUNCE_DEATH_ALERT, nil);
		end

		Settings.SetupCVarCheckbox(category, "showMaxLevelAnnouncements", SHOW_MAX_LEVEL_ANNOUNCEMENT, SHOW_MAX_LEVEL_ANNOUNCEMENT_TOOLTIP);
	end

	-- Instant Quest Text
	Settings.SetupCVarCheckbox(category, "instantQuestText", SHOW_QUEST_FADING_TEXT, OPTION_TOOLTIP_SHOW_QUEST_FADING);

	-- Automatic Quest Tracking
	Settings.SetupCVarCheckbox(category, "autoQuestWatch", AUTO_QUEST_WATCH_TEXT, OPTION_TOOLTIP_AUTO_QUEST_PROGRESS);

	do
		local function CVarChangedCB()
			local displayFreeBagSlots = C_CVar.GetCVarBool("displayFreeBagSlots");
			if ( displayFreeBagSlots ) then
				MainMenuBarBackpackButtonCount:Show();
			else
				MainMenuBarBackpackButtonCount:Hide();
			end
			MainMenuBarBackpackButton_UpdateFreeSlots();
		end

		-- Show Free Bag Space
		Settings.SetupCVarCheckbox(category, "displayFreeBagSlots", DISPLAY_FREE_BAG_SLOTS, OPTION_TOOLTIP_DISPLAY_FREE_BAG_SLOTS);
		CVarCallbackRegistry:RegisterCallback("displayFreeBagSlots", CVarChangedCB, nil);
	end

	do
		-- Consolidate Buffs
		Settings.SetupCVarCheckbox(category, "consolidateBuffs", CONSOLIDATE_BUFFS_TEXT, OPTION_TOOLTIP_CONSOLIDATE_BUFFS);
	end

	do
		-- Show Minimap Clock
		local function CVarChangedCB()
			if (C_AddOns.IsAddOnLoaded("Blizzard_TimeManager")) then
				TimeManagerClockButton_UpdateShowClockSetting();
			end
		end

		Settings.SetupCVarCheckbox(category, "showMinimapClock", SHOW_MINIMAP_CLOCK, OPTION_TOOLTIP_SHOW_MINIMAP_CLOCK);
		CVarCallbackRegistry:RegisterCallback("showMinimapClock", CVarChangedCB, nil);
	end

	-- Beginner Tooltips
	Settings.SetupCVarCheckbox(category, "showNewbieTips", SHOW_NEWBIE_TIPS_TEXT, OPTION_TOOLTIP_SHOW_NEWBIE_TIPS);

	-- Loading Screen Tips
	Settings.SetupCVarCheckbox(category, "showLoadingScreenTips", SHOW_TIPOFTHEDAY_TEXT, OPTION_TOOLTIP_SHOW_TIPOFTHEDAY);

	if ClassicExpansionAtLeast(LE_EXPANSION_WRATH_OF_THE_LICH_KING) then
		do
			-- Display Aggro Warning
			local function GetOptions()
				local container = Settings.CreateControlTextContainer();
				container:Add(0, NEVER, OPTION_TOOLTIP_AGGRO_WARNING_DISPLAY1);
				container:Add(1, AGGRO_WARNING_IN_INSTANCE, OPTION_TOOLTIP_AGGRO_WARNING_DISPLAY2);
				container:Add(2, AGGRO_WARNING_IN_PARTY, OPTION_TOOLTIP_AGGRO_WARNING_DISPLAY3);
				container:Add(3, ALWAYS, OPTION_TOOLTIP_AGGRO_WARNING_DISPLAY4);
				return container:GetData();
			end

			Settings.SetupCVarDropdown(category, "threatWarning", Settings.VarType.Number, GetOptions, AGGRO_WARNING_DISPLAY, nil);
		end

		--Show Aggro Percentages
		Settings.SetupCVarCheckbox(category, "threatShowNumeric", SHOW_AGGRO_PERCENTAGES, OPTION_TOOLTIP_SHOW_NUMERIC_THREAT);
	end

	--Show Enemy Castbars
	Settings.SetupCVarCheckbox(category, "showTargetCastbar", SHOW_ENEMY_CASTBARS, OPTION_TOOLTIP_SHOW_ENEMY_CASTBARS);

	--Show active player debuffs larger on target
	Settings.SetupCVarCheckbox(category, "showDynamicBuffSize", SHOW_DYNAMIC_BUFF_SIZE, OPTION_TOOLTIP_SHOW_DYNAMIC_BUFF_SIZE);

	Settings.SetupCVarCheckbox(category, "unitFramesDisplayIncomingHeals", UNIT_FRAMES_DISPLAY_INCOMING_HEALS, OPTION_TOOLTIP_UNIT_FRAMES_DISPLAY_INCOMING_HEALS);

	if C_Engraving.IsEngravingEnabled() then
		Settings.SetupCVarCheckbox(category, "alwaysShowRuneIcons", ALWAYS_SHOW_RUNE_ICONS, OPTION_TOOLTIP_ALWAYS_SHOW_RUNE_ICONS);		
	end

	if GetClassicExpansionLevel() <= LE_EXPANSION_WRATH_OF_THE_LICH_KING then
		Settings.SetupCVarCheckbox(category, "useClassicGuildUI", CLASSIC_GUILD_UI_TEXT, OPTION_TOOLTIP_CLASSIC_GUILD_UI);
	end

	if ClassicExpansionAtLeast(LE_EXPANSION_WRATH_OF_THE_LICH_KING) then
		do
			-- Use Equipment Manager
			local function CVarChangedCB()
				local equipmentManager = C_CVar.GetCVarBool("equipmentManager");
				
				local toggleButton;
				if GetClassicExpansionLevel() == LE_EXPANSION_WRATH_OF_THE_LICH_KING then
					toggleButton = GearManagerToggleButton;
				else
					toggleButton = PaperDollSidebarTab3;
				end
				
				if ( equipmentManager ) then 
					toggleButton:Show() 
				else 
					toggleButton:Hide() 
				end 
			end
			
			CVarCallbackRegistry:RegisterCallback("equipmentManager", CVarChangedCB, nil);
		end

		-- Preview Talent Changes
		Settings.SetupCVarCheckbox(category, "previewTalentsOption", PREVIEW_TALENT_CHANGES, OPTION_PREVIEW_TALENT_CHANGES_DESCRIPTION);
	end
end

local function RevertSetting(name)
	local setting = Settings.GetSetting(name);
	securecallfunction(setting.Revert, setting);
end

function InterfaceOverrides.CreateRaidFrameSettings(category, layout)
	-- Raid Frame Preview
	do
		local data = { };
		local initializer = Settings.CreatePanelInitializer("RaidFramePreviewTemplate", data);
		layout:AddInitializer(initializer);
	end

	-- Incoming Heals
	if C_CVar.GetCVar("raidFramesDisplayIncomingHeals") then
		Settings.SetupCVarCheckbox(category, "raidFramesDisplayIncomingHeals", COMPACT_UNIT_FRAME_PROFILE_DISPLAYHEALPREDICTION, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYHEALPREDICTION);
	end

	-- Power Bars
	local raidFramesDisplayPowerBarsSetting, raidFramesDisplayPowerBarsInitializer = Settings.SetupCVarCheckbox(category, "raidFramesDisplayPowerBars", COMPACT_UNIT_FRAME_PROFILE_DISPLAYPOWERBAR, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYPOWERBAR);

	local _, raidFramesDisplayOnlyHealerPowerBarsInitializer = Settings.SetupCVarCheckbox(category, "raidFramesDisplayOnlyHealerPowerBars", COMPACT_UNIT_FRAME_PROFILE_DISPLAYONLYHEALERPOWERBARS, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYONLYHEALERPOWERBARS);
	local function EnableRaidFramesDisplayOnlyHealerPowerBarsSetting()
		return raidFramesDisplayPowerBarsSetting:GetValue();
	end
	raidFramesDisplayOnlyHealerPowerBarsInitializer:SetParentInitializer(raidFramesDisplayPowerBarsInitializer, EnableRaidFramesDisplayOnlyHealerPowerBarsSetting);

	-- Aggro Highlight
	if C_CVar.GetCVar("raidFramesDisplayAggroHighlight") then
		Settings.SetupCVarCheckbox(category, "raidFramesDisplayAggroHighlight", COMPACT_UNIT_FRAME_PROFILE_DISPLAYAGGROHIGHLIGHT, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYAGGROHIGHLIGHT);
	end

	-- Class Colors
	Settings.SetupCVarCheckbox(category, "raidFramesDisplayClassColor", COMPACT_UNIT_FRAME_PROFILE_USECLASSCOLORS, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_USECLASSCOLORS);

	-- Pets
	Settings.SetupCVarCheckbox(category, "raidOptionDisplayPets", COMPACT_UNIT_FRAME_PROFILE_DISPLAYPETS, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYPETS);

	-- Main Tank and Assist
	Settings.SetupCVarCheckbox(category, "raidOptionDisplayMainTankAndAssist", COMPACT_UNIT_FRAME_PROFILE_DISPLAYMAINTANKANDASSIST, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYMAINTANKANDASSIST);

	do
		-- Debuffs
		local debuffSetting, debuffInitializer = Settings.SetupCVarCheckbox(category, "raidFramesDisplayDebuffs", COMPACT_UNIT_FRAME_PROFILE_DISPLAYNONBOSSDEBUFFS, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYNONBOSSDEBUFFS);

		-- Only Dispellable Debuffs
		local function IsModifiable()
			return debuffSetting:GetValue();
		end

		local _, initializer = Settings.SetupCVarCheckbox(category, "raidFramesDisplayOnlyDispellableDebuffs", COMPACT_UNIT_FRAME_PROFILE_DISPLAYONLYDISPELLABLEDEBUFFS, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_DISPLAYONLYDISPELLABLEDEBUFFS);
		initializer:SetParentInitializer(debuffInitializer, IsModifiable);
	end

	-- Health Text
	do 
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add("none", COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_NONE);
			container:Add("health", COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_HEALTH);
			container:Add("losthealth", COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_LOSTHEALTH);
			container:Add("perc", COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT_PERC);
			return container:GetData();
		end

		Settings.SetupCVarDropdown(category, "raidFramesHealthText", Settings.VarType.String, GetOptions, COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT, OPTION_TOOLTIP_COMPACT_UNIT_FRAME_PROFILE_HEALTHTEXT);
	end
end

function InterfaceOverrides.CreatePvpFrameSettings(category, layout)
	--No setting in Classic
end

function InterfaceOverrides.CreateHousingSettings(category, layout)
	--No setting in Classic
end

function InterfaceOverrides.ShowTutorialsOnButtonClick()
		SetCVar("closedInfoFrames", ""); -- reset the help plates too
		SetCVar("showTutorials", "1");
		ResetTutorials();
		TutorialFrame_HideAllAlerts();
end
function InterfaceOverrides.RunSettingsCallback(callback)
	callback();
end


function InterfaceOverrides.CreateQuestSettings(category, layout)
	--No settings in Classic
end
