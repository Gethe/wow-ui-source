MinimapUtil = {};

local MINIMAP_FILTER_SETTINGS_ENTRY = {
	[Enum.MinimapTrackingFilter.AccountCompletedQuests] = "PROXY_ACCOUNT_COMPLETED_QUEST_FILTERING",
	[Enum.MinimapTrackingFilter.TrivialQuests] = "PROXY_TRIVIAL_QUEST_FILTERING",
};

local function HasSettingsEntry(filterID)
	return MINIMAP_FILTER_SETTINGS_ENTRY[filterID] ~= nil;
end

local function SetSettingsEntry(filterID, selected)
    local settingsEntry = MINIMAP_FILTER_SETTINGS_ENTRY[filterID];
	if not settingsEntry or not Settings.GetSetting(settingsEntry) then
		return;
	end

	Settings.SetValue(settingsEntry, selected);
end

function MinimapUtil.GetFilterIndexForFilterID(filterID)
    for filterIndex = 1, C_Minimap.GetNumTrackingTypes() do
        local trackingFilter = C_Minimap.GetTrackingFilter(filterIndex);
        if trackingFilter and trackingFilter.filterID == filterID then
            return filterIndex;
        end
    end
end

function MinimapUtil.SetTrackingFilterByFilterID(filterID, set)
    -- Some filters have dedicated entries in the "Options" panel
    -- In those cases we should go through the Settings system instead to ensure it is properly updated
    if HasSettingsEntry(filterID) then
		SetSettingsEntry(filterID, set);
        return;
	end

    local filterIndex = MinimapUtil.GetFilterIndexForFilterID(filterID);
    if filterIndex then
        C_Minimap.SetTracking(filterIndex, set);
    end
end

function MinimapUtil.SetTrackingFilterByFilterIndex(filterIndex, set)
    local filter = C_Minimap.GetTrackingFilter(filterIndex);
    if filter and filter.filterID and HasSettingsEntry(filter.filterID) then
        SetSettingsEntry(filter.filterID, set);
    end

    C_Minimap.SetTracking(filterIndex, set);
end