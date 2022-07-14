EditModeSettingDisplayInfoManager = {};

EditModeSettingDisplayInfoManager.systemSettingDisplayInfo = {
	-- Action Bar Settings
	[Enum.EditModeSystem.ActionBar] =
	{
		--Orientation
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

		--Num Rows/Columns
		{
			setting = Enum.EditModeActionBarSetting.NumRows,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ROWS,
			altName = HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_COLUMNS,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 1,
			maxValue = 4,
		},

		--Num Icons
		{
			setting = Enum.EditModeActionBarSetting.NumIcons,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_NUM_ICONS,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 6,
			maxValue = 12,
		},

		--Icon Size
		{
			setting = Enum.EditModeActionBarSetting.IconSize,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_SIZE,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 0,
			maxValue = 6,
			stepSize = 0,
		},

		--Icon Padding
		{
			setting = Enum.EditModeActionBarSetting.IconPadding,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_ICON_PADDING,
			type = Enum.EditModeSettingDisplayType.Slider,
			minValue = 3,
			maxValue = 10,
			stepSize = 1,
		},

		--Visible Setting
		{
			setting = Enum.EditModeActionBarSetting.VisibleSetting,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING,
			type = Enum.EditModeSettingDisplayType.Dropdown,
			options = 
			{
				{value = Enum.ActionBarVisibleSetting.Always, text = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_ALWAYS},
				{value = Enum.ActionBarVisibleSetting.InCombat, text = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_IN_COMBAT},
				{value = Enum.ActionBarVisibleSetting.OutOfCombat, text = HUD_EDIT_MODE_SETTING_ACTION_BAR_VISIBLE_SETTING_OUT_OF_COMBAT},
			},
		},

		--Bar Art Visible Setting
		{
			setting = Enum.EditModeActionBarSetting.HideBarArt,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_HIDE_BAR_ART,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},

		--Bar Scrolling Visible Setting
		{
			setting = Enum.EditModeActionBarSetting.HideBarScrolling,
			name = HUD_EDIT_MODE_SETTING_ACTION_BAR_HIDE_BAR_SCROLLING,
			type = Enum.EditModeSettingDisplayType.Checkbox,
		},

		--Snap To Side
		-- {
		-- 	setting = Enum.EditModeActionBarSetting.SnapToSide,
		-- 	name = HUD_EDIT_MODE_SETTING_ACTION_BAR_SNAP_TO_RIGHT_SIDE,
		-- 	type = Enum.EditModeSettingDisplayType.Checkbox,
		-- },
	}
};

function EditModeSettingDisplayInfoManager:GetSystemSettingDisplayInfo(system)
	return self.systemSettingDisplayInfo[system];
end
