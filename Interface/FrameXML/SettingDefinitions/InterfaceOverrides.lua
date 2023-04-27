InterfaceOverrides = {}

function InterfaceOverrides.CreateLargerNameplateSetting(category)
	--no setting in Classic
end

function InterfaceOverrides.AdjustNameplateSettings(category)
	do
		-- Nameplate Distance
		local minValue, maxValue, step = 20, 41, 1;
		local options = Settings.CreateSliderOptions(minValue, maxValue, step);
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, IncrementByOne);
		Settings.SetupCVarSlider(category, "nameplateMaxDistance", options, UNIT_NAMEPLATES_MAX_DISTANCE, OPTION_TOOLTIP_UNIT_NAMEPLATES_MAX_DISTANCE);
	end
end

function InterfaceOverrides.AdjustDisplaySettings(category)
	do
		-- Show Helm
		local function GetValue()
			return ShowingHelm();
		end
		
		local function SetValue(value)
			ShowHelm(value);
		end
		
		local defaultValue = true;
		local setting = Settings.RegisterProxySetting(category, "PROXY_SHOW_HELM", Settings.DefaultVarLocation, 
			Settings.VarType.Boolean, SHOW_HELM, defaultValue, GetValue, SetValue);
		Settings.CreateCheckBox(category, setting, OPTION_TOOLTIP_SHOW_HELM);
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
		local setting = Settings.RegisterProxySetting(category, "PROXY_SHOW_CLOAK", Settings.DefaultVarLocation, 
			Settings.VarType.Boolean, SHOW_CLOAK, defaultValue, GetValue, SetValue);
		Settings.CreateCheckBox(category, setting, OPTION_TOOLTIP_SHOW_CLOAK);
	end

	-- Instant Quest Text
	Settings.SetupCVarCheckBox(category, "instantQuestText", SHOW_QUEST_FADING_TEXT, OPTION_TOOLTIP_SHOW_QUEST_FADING);

	-- Automatic Quest Tracking
	Settings.SetupCVarCheckBox(category, "autoQuestWatch", AUTO_QUEST_WATCH_TEXT, OPTION_TOOLTIP_AUTO_QUEST_PROGRESS);

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
		Settings.SetupCVarCheckBox(category, "displayFreeBagSlots", DISPLAY_FREE_BAG_SLOTS, nil);
		CVarCallbackRegistry:RegisterCVarChangedCallback(CVarChangedCB, nil);
	end

	do
		-- Consolidate Buffs
		local function CVarChangedCB()
			BuffFrame_Update();
		end

		Settings.SetupCVarCheckBox(category, "consolidateBuffs", CONSOLIDATE_BUFFS_TEXT, nil);
		CVarCallbackRegistry:RegisterCVarChangedCallback(CVarChangedCB, nil);
	end

	-- Hide Zone Objective Tracker
	Settings.SetupCVarCheckBox(category, "hideOutdoorWorldState", HIDE_OUTDOOR_WORLD_STATE_TEXT, OPTION_TOOLTIP_HIDE_OUTDOOR_WORLD_STATE);

	do
		-- Rotate Minimap
		local function CVarChangedCB()
			Minimap_UpdateRotationSetting();
		end

		Settings.SetupCVarCheckBox(category, "rotateMinimap", ROTATE_MINIMAP, nil);
		CVarCallbackRegistry:RegisterCVarChangedCallback(CVarChangedCB, nil);
	end

	do
		-- Show Minimap Clock
		local function CVarChangedCB()
			if (IsAddOnLoaded("Blizzard_TimeManager")) then
				TimeManagerClockButton_UpdateShowClockSetting();
			end
		end

		Settings.SetupCVarCheckBox(category, "showMinimapClock", SHOW_MINIMAP_CLOCK, nil);
		CVarCallbackRegistry:RegisterCVarChangedCallback(CVarChangedCB, nil);
	end

	-- Beginner Tooltips
	Settings.SetupCVarCheckBox(category, "showNewbieTips", SHOW_NEWBIE_TIPS_TEXT, OPTION_TOOLTIP_SHOW_NEWBIE_TIPS);

	-- Loading Screen Tips
	Settings.SetupCVarCheckBox(category, "showLoadingScreenTips", SHOW_TIPOFTHEDAY_TEXT, OPTION_TOOLTIP_SHOW_TIPOFTHEDAY);

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

		Settings.SetupCVarDropDown(category, "threatWarning", Settings.VarType.Number, GetOptions, AGGRO_WARNING_DISPLAY, nil);
	end

	--Show Aggro Percentages
	Settings.SetupCVarCheckBox(category, "threatShowNumeric", SHOW_AGGRO_PERCENTAGES, OPTION_TOOLTIP_SHOW_NUMERIC_THREAT);

	if ClassicExpansionAtLeast(LE_EXPANSION_WRATH_OF_THE_LICH_KING) then
		do
			-- Use Equipment Manager
			local function CVarChangedCB()
				local equipmentManager = C_CVar.GetCVarBool("equipmentManager");
				if ( equipmentManager ) then 
					GearManagerToggleButton:Show() 
				else 
					GearManagerToggleButton:Hide() 
				end 
			end
			
			Settings.SetupCVarCheckBox(category, "equipmentManager", USE_EQUIPMENT_MANAGER, OPTION_USE_EQUIPMENT_MANAGER_DESCRIPTION);
			CVarCallbackRegistry:RegisterCVarChangedCallback(CVarChangedCB, nil);
		end

		-- Preview Talent Changes
		Settings.SetupCVarCheckBox(category, "previewTalents", PREVIEW_TALENT_CHANGES, OPTION_PREVIEW_TALENT_CHANGES_DESCRIPTION);
	end
end