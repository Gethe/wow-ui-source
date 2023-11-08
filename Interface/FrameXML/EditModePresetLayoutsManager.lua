EditModePresetLayoutManager = {};

EditModePresetLayoutManager.presetLayoutInfo =
{
	{
		layoutIndex = Enum.EditModePresetLayouts.Modern;
		layoutName = LAYOUT_STYLE_MODERN,
		layoutType = Enum.EditModeLayoutType.Preset,
		systems = EditModeSystemUtil.GetSystems(EDIT_MODE_MODERN_SYSTEM_MAP),
	},

	{
		layoutIndex = Enum.EditModePresetLayouts.Classic;
		layoutName = LAYOUT_STYLE_CLASSIC,
		layoutType = Enum.EditModeLayoutType.Preset,
		systems = EditModeSystemUtil.GetSystems(EDIT_MODE_CLASSIC_SYSTEM_MAP),
	},
};

EditModePresetLayoutManager.overrideLayoutInfo = EDIT_MODE_OVERRIDE_LAYOUTS or { };

local presetLayoutMapByLayoutIndex = {

	[Enum.EditModePresetLayouts.Modern] = EDIT_MODE_MODERN_SYSTEM_MAP,
	[Enum.EditModePresetLayouts.Classic] = EDIT_MODE_CLASSIC_SYSTEM_MAP,
}

local overrideLayoutMapByLayoutIndex = EDIT_MODE_OVERRIDE_LAYOUT_MAP or { };

function EditModePresetLayoutManager:GetCopyOfPresetLayouts()
	return CopyTable(self.presetLayoutInfo);
end

function EditModePresetLayoutManager:GetCopyOfOverrideLayouts()
	return CopyTable(self.overrideLayoutInfo);
end 

function EditModePresetLayoutManager:GetModernSystemMap()
	return EDIT_MODE_MODERN_SYSTEM_MAP;
end

function EditModePresetLayoutManager:GetModernSystems()
	return self.presetLayoutInfo[1].systems;
end

function EditModePresetLayoutManager:GetModernSystemAnchorInfo(system, systemIndex)
	local modernSystemInfo = systemIndex and EDIT_MODE_MODERN_SYSTEM_MAP[system][systemIndex] or EDIT_MODE_MODERN_SYSTEM_MAP[system];
	return CopyTable(modernSystemInfo.anchorInfo);
end

function EditModePresetLayoutManager:GetModernSystemAnchorInfo(system, systemIndex)
	local modernSystemInfo = systemIndex and EDIT_MODE_MODERN_SYSTEM_MAP[system][systemIndex] or EDIT_MODE_MODERN_SYSTEM_MAP[system];
	return CopyTable(modernSystemInfo.anchorInfo);
end

function EditModePresetLayoutManager:GetPresetLayoutMapByIndex(layoutIndex)
	return presetLayoutMapByLayoutIndex[layoutIndex]; 
end	

function EditModePresetLayoutManager:GetOverrideLayoutByMapIndex(layoutIndex)
	return overrideLayoutMapByLayoutIndex[layoutIndex];
end

local function GetAnchorInfoFromMap(layoutMap, system, systemIndex)
	if(not layoutMap) then 
		return nil
	end 
	local modernSystemInfo = systemIndex and layoutMap[system][systemIndex] or layoutMap[system];
	return CopyTable(modernSystemInfo.anchorInfo);
end	

function EditModePresetLayoutManager:GetPresetLayoutSystemAnchorInfo(layoutIndex, system, systemIndex)
	local layoutMap = self:GetPresetLayoutMapByIndex(layoutIndex); 
	return GetAnchorInfoFromMap(layoutMap, system, systemIndex);
end	

function EditModePresetLayoutManager:GetOverrideLayoutSystemAnchorInfo(layoutIndex, system, systemIndex)
	local layoutMap = self:GetOverrideLayoutByMapIndex(layoutIndex); 
	return GetAnchorInfoFromMap(layoutMap, system, systemIndex);
end 

C_AddOns.EnableAddOn("Blizzard_ObjectiveTracker");
C_AddOns.EnableAddOn("Blizzard_CompactRaidFrames");
