local EditModeManagerShared =
{
	Tables =
	{
		{
			Name = "ActionBarOrientation",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Horizontal", Type = "ActionBarOrientation", EnumValue = 0 },
				{ Name = "Vertical", Type = "ActionBarOrientation", EnumValue = 1 },
			},
		},
		{
			Name = "ActionBarVisibleSetting",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Always", Type = "ActionBarVisibleSetting", EnumValue = 0 },
				{ Name = "InCombat", Type = "ActionBarVisibleSetting", EnumValue = 1 },
				{ Name = "OutOfCombat", Type = "ActionBarVisibleSetting", EnumValue = 2 },
			},
		},
		{
			Name = "CastBarSize",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Small", Type = "CastBarSize", EnumValue = 0 },
				{ Name = "Medium", Type = "CastBarSize", EnumValue = 1 },
				{ Name = "Large", Type = "CastBarSize", EnumValue = 2 },
			},
		},
		{
			Name = "EditModeAccountSetting",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 0,
			MaxValue = 9,
			Fields =
			{
				{ Name = "ShowGrid", Type = "EditModeAccountSetting", EnumValue = 0 },
				{ Name = "GridSpacing", Type = "EditModeAccountSetting", EnumValue = 1 },
				{ Name = "SettingsExpanded", Type = "EditModeAccountSetting", EnumValue = 2 },
				{ Name = "ShowTargetAndFocus", Type = "EditModeAccountSetting", EnumValue = 3 },
				{ Name = "ShowStanceBar", Type = "EditModeAccountSetting", EnumValue = 4 },
				{ Name = "ShowPetActionBar", Type = "EditModeAccountSetting", EnumValue = 5 },
				{ Name = "ShowPossessActionBar", Type = "EditModeAccountSetting", EnumValue = 6 },
				{ Name = "ShowCastBar", Type = "EditModeAccountSetting", EnumValue = 7 },
				{ Name = "ShowEncounterBar", Type = "EditModeAccountSetting", EnumValue = 8 },
				{ Name = "ShowExtraAbilities", Type = "EditModeAccountSetting", EnumValue = 9 },
			},
		},
		{
			Name = "EditModeActionBarSetting",
			Type = "Enumeration",
			NumValues = 10,
			MinValue = 0,
			MaxValue = 9,
			Fields =
			{
				{ Name = "Orientation", Type = "EditModeActionBarSetting", EnumValue = 0 },
				{ Name = "NumRows", Type = "EditModeActionBarSetting", EnumValue = 1 },
				{ Name = "NumIcons", Type = "EditModeActionBarSetting", EnumValue = 2 },
				{ Name = "IconSize", Type = "EditModeActionBarSetting", EnumValue = 3 },
				{ Name = "IconPadding", Type = "EditModeActionBarSetting", EnumValue = 4 },
				{ Name = "VisibleSetting", Type = "EditModeActionBarSetting", EnumValue = 5 },
				{ Name = "HideBarArt", Type = "EditModeActionBarSetting", EnumValue = 6 },
				{ Name = "SnapToSide", Type = "EditModeActionBarSetting", EnumValue = 7 },
				{ Name = "HideBarScrolling", Type = "EditModeActionBarSetting", EnumValue = 8 },
				{ Name = "AlwaysShowButtons", Type = "EditModeActionBarSetting", EnumValue = 9 },
			},
		},
		{
			Name = "EditModeActionBarSystemIndices",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 1,
			MaxValue = 13,
			Fields =
			{
				{ Name = "MainBar", Type = "EditModeActionBarSystemIndices", EnumValue = 1 },
				{ Name = "Bar2", Type = "EditModeActionBarSystemIndices", EnumValue = 2 },
				{ Name = "Bar3", Type = "EditModeActionBarSystemIndices", EnumValue = 3 },
				{ Name = "RightBar1", Type = "EditModeActionBarSystemIndices", EnumValue = 4 },
				{ Name = "RightBar2", Type = "EditModeActionBarSystemIndices", EnumValue = 5 },
				{ Name = "StanceBar", Type = "EditModeActionBarSystemIndices", EnumValue = 11 },
				{ Name = "PetActionBar", Type = "EditModeActionBarSystemIndices", EnumValue = 12 },
				{ Name = "PossessActionBar", Type = "EditModeActionBarSystemIndices", EnumValue = 13 },
			},
		},
		{
			Name = "EditModeCastBarSetting",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "BarSize", Type = "EditModeCastBarSetting", EnumValue = 0 },
				{ Name = "LockToPlayerFrame", Type = "EditModeCastBarSetting", EnumValue = 1 },
			},
		},
		{
			Name = "EditModeLayoutType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Preset", Type = "EditModeLayoutType", EnumValue = 0 },
				{ Name = "Account", Type = "EditModeLayoutType", EnumValue = 1 },
				{ Name = "Character", Type = "EditModeLayoutType", EnumValue = 2 },
			},
		},
		{
			Name = "EditModeMinimapSetting",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "HeaderUnderneath", Type = "EditModeMinimapSetting", EnumValue = 0 },
			},
		},
		{
			Name = "EditModePresetLayouts",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Modern", Type = "EditModePresetLayouts", EnumValue = 0 },
				{ Name = "Classic", Type = "EditModePresetLayouts", EnumValue = 1 },
			},
		},
		{
			Name = "EditModeSettingDisplayType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Dropdown", Type = "EditModeSettingDisplayType", EnumValue = 0 },
				{ Name = "Checkbox", Type = "EditModeSettingDisplayType", EnumValue = 1 },
				{ Name = "Slider", Type = "EditModeSettingDisplayType", EnumValue = 2 },
			},
		},
		{
			Name = "EditModeSystem",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "ActionBar", Type = "EditModeSystem", EnumValue = 0 },
				{ Name = "CastBar", Type = "EditModeSystem", EnumValue = 1 },
				{ Name = "Minimap", Type = "EditModeSystem", EnumValue = 2 },
				{ Name = "UnitFrame", Type = "EditModeSystem", EnumValue = 3 },
				{ Name = "EncounterBar", Type = "EditModeSystem", EnumValue = 4 },
				{ Name = "ExtraAbilities", Type = "EditModeSystem", EnumValue = 5 },
			},
		},
		{
			Name = "EditModeUnitFrameSetting",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "HidePortrait", Type = "EditModeUnitFrameSetting", EnumValue = 0 },
				{ Name = "CastBarUnderneath", Type = "EditModeUnitFrameSetting", EnumValue = 1 },
				{ Name = "BuffsOnTop", Type = "EditModeUnitFrameSetting", EnumValue = 2 },
				{ Name = "UseLargerFrame", Type = "EditModeUnitFrameSetting", EnumValue = 3 },
			},
		},
		{
			Name = "EditModeUnitFrameSystemIndices",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 1,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Player", Type = "EditModeUnitFrameSystemIndices", EnumValue = 1 },
				{ Name = "Target", Type = "EditModeUnitFrameSystemIndices", EnumValue = 2 },
				{ Name = "Focus", Type = "EditModeUnitFrameSystemIndices", EnumValue = 3 },
			},
		},
		{
			Name = "EditModeConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "EditModeDefaultGridSpacing", Type = "number", Value = 40 },
				{ Name = "EditModeMinGridSpacing", Type = "number", Value = 20 },
				{ Name = "EditModeMaxGridSpacing", Type = "number", Value = 80 },
				{ Name = "EditModeMaxLayoutsPerType", Type = "number", Value = 5 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EditModeManagerShared);