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
