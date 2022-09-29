EditModeSettingDisplayInfoManager = {};

local function showAsPercentage(value)
	local roundToNearestInteger = true;
	return FormatPercentage(value / 100, roundToNearestInteger);
end

local function ConvertValueDefault(self, value, forDisplay)
	if forDisplay then
		return self:ClampValue((value * self.stepSize) + self.minValue);
	else
		return (value - self.minValue) / self.stepSize;
	end
end

local function ConvertValueDiffFromMin(self, value, forDisplay)
	if forDisplay then
		return self:ClampValue(value + self.minValue);
	else
		return value - self.minValue;
	end
end

-- The ordering of the setting display info tables in here affects the order settings show in the system setting dialog
EditModeSettingDisplayInfoManager.systemSettingDisplayInfo = {
	-- Action Bar Settings
	[Enum.EditModeSystem.ActionBar] =
	{
		-- Orientation
		{
			setting = Enum.EditModeActionBarSetting.Orientation,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION,
			type = Enum.EditModeSettingDisplayType.Dropdown,
			options =
			{
				{value = Enum.ActionBarOrientation.Horizontal, text = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_HORIZONTAL},
				{value = Enum.ActionBarOrientation.Vertical, text = HUD_EDIT_MODE_SETTING_ACTION_BAR_ORIENTATION_VERTICAL},
			},
		},

		-- Num Rows/Columns
		{
			setting = Enum.EditModeActionBarSetting.NumRows,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS,
			altName = HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_COLUMNS,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 1,
			maxValue = 4,
		},

		-- Num Icons
		{
			setting = Enum.EditModeActionBarSetting.NumIcons,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ICONS,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 6,
			maxValue = 12,
		},

		-- Icon Size
		{
			setting = Enum.EditModeActionBarSetting.IconSize,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 50,
			maxValue = 200,
			stepSize = 10,
			ConvertValue = ConvertValueDefault,
			formatter = showAsPercentage,
		},

		-- Icon Padding
		{
			setting = Enum.EditModeActionBarSetting.IconPadding,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_PADDING,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 2,
			maxValue = 10,
			stepSize = 1,
		},

		-- Visible Setting
		{
			setting = Enum.EditModeActionBarSetting.VisibleSetting,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING,
			type = Enum.EditModeSettingDisplayType.Dropdown,
			options = 
			{
				{value = Enum.ActionBarVisibleSetting.Always, text = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_ALWAYS},
				{value = Enum.ActionBarVisibleSetting.InCombat, text = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT},
				{value = Enum.ActionBarVisibleSetting.OutOfCombat, text = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_OUT_OF_COMBAT},
				{value = Enum.ActionBarVisibleSetting.Hidden, text = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_HIDDEN},
			},
		},

		-- Always Show Buttons
		{
			setting = Enum.EditModeActionBarSetting.AlwaysShowButtons,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_ALWAYS_SHOW_BUTTONS,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},

		-- Bar Art Visible Setting
		{
			setting = Enum.EditModeActionBarSetting.HideBarArt,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_HIDE_BAR_ART,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},

		-- Bar Scrolling Visible Setting
		{
			setting = Enum.EditModeActionBarSetting.HideBarScrolling,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_HIDE_BAR_SCROLLING,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},
	},

	[Enum.EditModeSystem.Minimap] =
	{
		-- Header Underneath
		{
			setting = Enum.EditModeMinimapSetting.HeaderUnderneath,
			name = HUD_EDIT_MODE_SETTING_MINIMAP_HEADER_UNDERNEATH,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},

		-- Rotate Minimap
		{
			setting = Enum.EditModeMinimapSetting.RotateMinimap,
			name = HUD_EDIT_MODE_SETTING_MINIMAP_ROTATE_MINIMAP,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},
	},

	-- Cast Bar Settings
	[Enum.EditModeSystem.CastBar] =
	{
		-- Bar Size
		{
			setting = Enum.EditModeCastBarSetting.BarSize,
			name = HUD_EDIT_MODE_SETTING_CAST_BAR_SIZE,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 100,
			maxValue = 150,
			stepSize = 10,
			ConvertValue = ConvertValueDefault,
			formatter = showAsPercentage,
		},

		-- Lock To Player Frame
		{
			setting = Enum.EditModeCastBarSetting.LockToPlayerFrame,
			name = HUD_EDIT_MODE_SETTING_CAST_BAR_LOCK_TO_PLAYER_FRAME,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},
	},

	-- Unit Frame Settings
	[Enum.EditModeSystem.UnitFrame] =
	{
		-- Cast Bar Underneath
		{
			setting = Enum.EditModeUnitFrameSetting.CastBarUnderneath,
			name = HUD_EDIT_MODE_SETTING_UNIT_FRAME_CAST_BAR_UNDERNEATH,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},

		-- Use Larger Frame
		{
			setting = Enum.EditModeUnitFrameSetting.UseLargerFrame,
			name = HUD_EDIT_MODE_SETTING_UNIT_FRAME_USE_LARGER_FRAME,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},

		-- Buffs On Top
		{
			setting = Enum.EditModeUnitFrameSetting.BuffsOnTop,
			name = HUD_EDIT_MODE_SETTING_UNIT_FRAME_BUFFS_ON_TOP,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},

		-- Use Raid Style Party Frames
		{
			setting = Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames,
			name = HUD_EDIT_MODE_SETTING_UNIT_FRAME_RAID_STYLE_PARTY_FRAMES,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},

		-- Show Party Frame Background
		{
			setting = Enum.EditModeUnitFrameSetting.ShowPartyFrameBackground,
			name = HUD_EDIT_MODE_SETTING_UNIT_FRAME_SHOW_PARTY_FRAME_BACKGROUND,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},

		-- CastBarOnSide
		{
			setting = Enum.EditModeUnitFrameSetting.CastBarOnSide,
			name = HUD_EDIT_MODE_SETTING_UNIT_FRAME_CAST_BAR_ON_SIDE,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},

		-- ShowCastTime
		-- {
		-- 	setting = Enum.EditModeUnitFrameSetting.ShowCastTime,
		-- 	name = HUD_EDIT_MODE_SETTING_UNIT_FRAME_SHOW_CAST_TIME,
		-- 	type = Enum.EditModeSettingDisplayType.Checkbox,
		-- },

		-- View Raid Size
		{
			setting = Enum.EditModeUnitFrameSetting.ViewRaidSize,
			name = HUD_EDIT_MODE_SETTING_UNIT_FRAME_RAID_SIZE,
			type = Enum.EditModeSettingDisplayType.Dropdown,
			options = 
			{
				{value = Enum.ViewRaidSize.Ten, text = "10"},
				{value = Enum.ViewRaidSize.TwentyFive, text = "25"},
				{value = Enum.ViewRaidSize.Forty, text = "40"},
			},
		},

		-- Frame Width
		{
			setting = Enum.EditModeUnitFrameSetting.FrameWidth,
			name = HUD_EDIT_MODE_SETTING_UNIT_FRAME_WIDTH,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 72,
			maxValue = 144,
			stepSize = 2,
			ConvertValue = ConvertValueDiffFromMin,
			hideValue = true,
			minText = NARROW,
			maxText = WIDE,
		},

		-- Frame Height
		{
			setting = Enum.EditModeUnitFrameSetting.FrameHeight,
			name = HUD_EDIT_MODE_SETTING_UNIT_FRAME_HEIGHT,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 36,
			maxValue = 72,
			stepSize = 2,
			ConvertValue = ConvertValueDiffFromMin,
			hideValue = true,
			minText = SHORT,
			maxText = TALL,
		},

		-- Raid Group Display Type
		{
			setting = Enum.EditModeUnitFrameSetting.RaidGroupDisplayType,
			name = HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS,
			type = Enum.EditModeSettingDisplayType.Dropdown,
			options = 
			{
				{value = Enum.RaidGroupDisplayType.SeparateGroupsVertical, text = HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS_SEPARATE_GROUPS_VERTICAL},
				{value = Enum.RaidGroupDisplayType.SeparateGroupsHorizontal, text = HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS_SEPARATE_GROUPS_HORIZONTAL},
				{value = Enum.RaidGroupDisplayType.CombineGroupsVertical, text = HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS_COMBINE_GROUPS_VERTICAL},
				{value = Enum.RaidGroupDisplayType.CombineGroupsHorizontal, text = HUD_EDIT_MODE_SETTING_UNIT_FRAME_GROUPS_COMBINE_GROUPS_HORIZONTAL},
			},
		},

		-- Sort Players By
		{
			setting = Enum.EditModeUnitFrameSetting.SortPlayersBy,
			name = HUD_EDIT_MODE_SETTING_UNIT_FRAME_SORT_BY,
			type = Enum.EditModeSettingDisplayType.Dropdown,
			options = 
			{
				{value = Enum.SortPlayersBy.Role, text = HUD_EDIT_MODE_SETTING_UNIT_FRAME_SORT_BY_SETTING_ROLE},
				{value = Enum.SortPlayersBy.Group, text = HUD_EDIT_MODE_SETTING_UNIT_FRAME_SORT_BY_SETTING_GROUP},
				{value = Enum.SortPlayersBy.Alphabetical, text = HUD_EDIT_MODE_SETTING_UNIT_FRAME_SORT_BY_SETTING_ALPHABETICAL},
			},
		},

		-- Use Horizontal Groups
		{
			setting = Enum.EditModeUnitFrameSetting.UseHorizontalGroups,
			name = HUD_EDIT_MODE_SETTING_UNIT_FRAME_USE_HORIZONTAL_GROUPS,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},

		-- Display Border
		{
			setting = Enum.EditModeUnitFrameSetting.DisplayBorder,
			name = HUD_EDIT_MODE_SETTING_UNIT_FRAME_DISPLAY_BORDER,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},

		-- Row Size
		{
			setting = Enum.EditModeUnitFrameSetting.RowSize,
			name = HUD_EDIT_MODE_SETTING_UNIT_FRAME_ROW_SIZE,
			altName = HUD_EDIT_MODE_SETTING_UNIT_FRAME_COLUMN_SIZE,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 2,
			maxValue = 10,
			stepSize = 1,
		},
	},

	[Enum.EditModeSystem.EncounterBar] =
	{

	},

	[Enum.EditModeSystem.ExtraAbilities] =
	{

	},

	[Enum.EditModeSystem.AuraFrame] =
	{
		-- Orientation
		{
			setting = Enum.EditModeAuraFrameSetting.Orientation,
			name = HUD_EDIT_MODE_SETTING_AURA_FRAME_ORIENTATION,
			type = Enum.EditModeSettingDisplayType.Dropdown,
			options =
			{
				{value = Enum.AuraFrameOrientation.Horizontal, text = HUD_EDIT_MODE_SETTING_AURA_FRAME_ORIENTATION_HORIZONTAL},
				{value = Enum.AuraFrameOrientation.Vertical, text = HUD_EDIT_MODE_SETTING_AURA_FRAME_ORIENTATION_VERTICAL},
			},
		},

		-- IconWrap
		{
			setting = Enum.EditModeAuraFrameSetting.IconWrap,
			name = HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_WRAP,
			type = Enum.EditModeSettingDisplayType.Dropdown,
			options =
			{
				{value = Enum.AuraFrameIconDirection.Down, text = HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_WRAP_DOWN},
				{value = Enum.AuraFrameIconDirection.Up, text = HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_WRAP_UP},
			},
		},

		-- IconDirection
		{
			setting = Enum.EditModeAuraFrameSetting.IconDirection,
			name = HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION,
			type = Enum.EditModeSettingDisplayType.Dropdown,
			options =
			{
				{value = Enum.AuraFrameIconDirection.Left, text = HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_LEFT},
				{value = Enum.AuraFrameIconDirection.Right, text = HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_DIRECTION_RIGHT},
			},
		},

		-- IconSize
		{
			setting = Enum.EditModeAuraFrameSetting.IconSize,
			name = HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_SIZE,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 50,
			maxValue = 200,
			stepSize = 10,
			ConvertValue = ConvertValueDefault,
			formatter = showAsPercentage,
		},

		-- IconPadding
		{
			setting = Enum.EditModeAuraFrameSetting.IconPadding,
			name = HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_PADDING,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 5,
			maxValue = 15,
			stepSize = 1,
		},

		-- IconLimit
		{
			setting = Enum.EditModeAuraFrameSetting.IconLimitBuffFrame,
			name = HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_LIMIT,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 2,
			maxValue = 32,
			stepSize = 1,
		},
		{
			setting = Enum.EditModeAuraFrameSetting.IconLimitDebuffFrame,
			name = HUD_EDIT_MODE_SETTING_AURA_FRAME_ICON_LIMIT,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 1,
			maxValue = 16,
			stepSize = 1,
		},

		-- ShowFull
		{
			setting = Enum.EditModeAuraFrameSetting.ShowFull,
			name = HUD_EDIT_MODE_SETTING_AURA_FRAME_SHOW_FULL,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},

	},

	[Enum.EditModeSystem.TalkingHeadFrame] =
	{
	},

	[Enum.EditModeSystem.ChatFrame] =
	{
	},

	[Enum.EditModeSystem.VehicleLeaveButton] =
	{
	},

	[Enum.EditModeSystem.LootFrame] =
	{
	},

	[Enum.EditModeSystem.HudTooltip] =
	{
	},

	[Enum.EditModeSystem.ObjectiveTracker] =
	{
		-- Height
		{
			setting = Enum.EditModeObjectiveTrackerSetting.Height,
			name = HUD_EDIT_MODE_SETTING_OBJECTIVE_TRACKER_HEIGHT,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 400,
			maxValue = 1000,
			stepSize = 10,
			ConvertValue = ConvertValueDefault,
		},
	},
};

local DefaultSettingDisplayInfo = {};

function DefaultSettingDisplayInfo:ConvertValue(value, forDisplay)
	if forDisplay then
		return self:ClampValue(value);
	else
		return value;
	end
end

function DefaultSettingDisplayInfo:ClampValue(value)
	if self.type == Enum.EditModeSettingDisplayType.Dropdown then
		return Clamp(value, 0, #self.options - 1);
	elseif self.type == Enum.EditModeSettingDisplayType.Slider then
		return Clamp(value, self.minValue, self.maxValue);
	else
		return Clamp(value, 0, 1);
	end
end

function DefaultSettingDisplayInfo:ConvertValueForDisplay(value)
	local forDisplay = true;
	return self:ConvertValue(value, forDisplay);
end

-- Metatable used for all setting display info tables
-- This provides ClampValue and ConvertValueForDisplay methods, in addition to a default version of the ConvertValue method
local mt = {__index =  DefaultSettingDisplayInfo};

-- Create a map from system/setting to displayInfo for easy access
EditModeSettingDisplayInfoManager.displayInfoMap = {};
for system, systemDisplayInfo in pairs(EditModeSettingDisplayInfoManager.systemSettingDisplayInfo) do
	EditModeSettingDisplayInfoManager.displayInfoMap[system] = {};
	for _, settingDisplayInfo in ipairs(systemDisplayInfo) do
		-- Set the metatable on each of the display info tables
		setmetatable(settingDisplayInfo, mt);
		-- And then add it to the map
		EditModeSettingDisplayInfoManager.displayInfoMap[system][settingDisplayInfo.setting] = settingDisplayInfo;
	end
end

function EditModeSettingDisplayInfoManager:GetSystemSettingDisplayInfo(system)
	return self.systemSettingDisplayInfo[system];
end

function EditModeSettingDisplayInfoManager:GetSystemSettingDisplayInfoMap(system)
	return self.displayInfoMap[system];
end

local mirroredSettings = {
	-- CastBar-LockToPlayerFrame and PlayerFrame-CastBarUnderneath are mirrored
	{
		{system = Enum.EditModeSystem.CastBar, setting = Enum.EditModeCastBarSetting.LockToPlayerFrame},
		{system = Enum.EditModeSystem.UnitFrame, systemIndex = Enum.EditModeUnitFrameSystemIndices.Player, setting = Enum.EditModeUnitFrameSetting.CastBarUnderneath},
	}
};

-- Create a mirrored settings map for easy access
EditModeSettingDisplayInfoManager.mirroredSettingsMap = {};
for _, mirrors in ipairs(mirroredSettings) do
	for _, mirroredSetting in ipairs(mirrors) do
		if not EditModeSettingDisplayInfoManager.mirroredSettingsMap[mirroredSetting.system] then
			EditModeSettingDisplayInfoManager.mirroredSettingsMap[mirroredSetting.system] = {};
		end

		if mirroredSetting.systemIndex and not EditModeSettingDisplayInfoManager.mirroredSettingsMap[mirroredSetting.system][mirroredSetting.systemIndex] then
			EditModeSettingDisplayInfoManager.mirroredSettingsMap[mirroredSetting.system][mirroredSetting.systemIndex] = {};
		end

		local systemMirrors = mirroredSetting.systemIndex and EditModeSettingDisplayInfoManager.mirroredSettingsMap[mirroredSetting.system][mirroredSetting.systemIndex] or EditModeSettingDisplayInfoManager.mirroredSettingsMap[mirroredSetting.system];

		if not systemMirrors[mirroredSetting.setting] then
			systemMirrors[mirroredSetting.setting] = {};
		end

		for _, otherSetting in ipairs(mirrors) do
			if mirroredSetting ~= otherSetting then
				table.insert(systemMirrors[mirroredSetting.setting], otherSetting);
			end
		end
	end
end

function EditModeSettingDisplayInfoManager:GetMirroredSettings(system, systemIndex, setting)
	local systemMirrors;
	if systemIndex then
		systemMirrors = EditModeSettingDisplayInfoManager.mirroredSettingsMap[system] and EditModeSettingDisplayInfoManager.mirroredSettingsMap[system][systemIndex];
	else
		systemMirrors = EditModeSettingDisplayInfoManager.mirroredSettingsMap[system];
	end
	return systemMirrors and systemMirrors[setting];
end