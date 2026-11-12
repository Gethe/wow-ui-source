-- Overrides base behavior
function InterfaceOverrides.AdjustInGameNavigationSettings()
end

function InterfaceOverrides.RegisterOutlineSettings(category)
end

function InterfaceOverrides.CreateQuestSettings(category, layout)
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(QUEST_SETTINGS_LABEL));

	local function SetQuestTracking(filter, value)
		local filterIndex = MinimapUtil.GetFilterIndexForFilterID(filter);
		if filterIndex then
			C_Minimap.SetTracking(filterIndex, value);
		end
	end

	-- Trivial quest filter
	local function SetTrivialQuestTracking(value)
		SetQuestTracking(Enum.MinimapTrackingFilter.TrivialQuests, value);
	end

	local function IsTrackingTrivialQuests()
		return not C_Minimap.IsFilteredOut(Enum.MinimapTrackingFilter.TrivialQuests);
	end

	local trivialQuestFilterSetting = Settings.RegisterProxySetting(category, "PROXY_TRIVIAL_QUEST_FILTERING",
		Settings.VarType.Boolean, SETTINGS_TRIVIAL_QUEST_FILTER, Settings.Default.False, IsTrackingTrivialQuests, SetTrivialQuestTracking);
	Settings.CreateCheckbox(category, trivialQuestFilterSetting);
end

function InterfaceOverrides.CreateHousingSettings(category, layout)

end

function InterfaceOverrides.CreatePvpFrameSettings(category, layout)

end

function InterfaceOverrides.HasAssistedCombat()
	return false;
end

function InterfaceOverrides.HasBossWarnings()
	return false;
end

function InterfaceOverrides.HasExternalDefensives()
	return false;
end

function InterfaceOverrides.HasCooldownViewer()
	return true;
end

function InterfaceOverrides.HasSwingTimer()
	return true;
end

function InterfaceOverrides.CanResetTutorials()
	return true;
end

function InterfaceOverrides.AdjustDisplaySettings(category)
	
	-- Loading Screen Tips
	Settings.SetupCVarCheckbox(category, "showLoadingScreenTips", SHOW_TIPOFTHEDAY_TEXT, OPTION_TOOLTIP_SHOW_TIPOFTHEDAY);
	
	-- Instant Quest Text
	Settings.SetupCVarCheckbox(category, "instantQuestText", SHOW_QUEST_FADING_TEXT, OPTION_TOOLTIP_SHOW_QUEST_FADING);

	-- Show Free Bag Space
	Settings.SetupCVarCheckbox(category, "displayFreeBagSlots", DISPLAY_FREE_BAG_SLOTS, OPTION_TOOLTIP_DISPLAY_FREE_BAG_SLOTS);

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

end

function InterfaceOverrides.CreateToastSettings(category, layout)
	-- We don't have this in interface anymore; it's in Preset
end
