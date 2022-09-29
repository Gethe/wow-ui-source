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
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Always", Type = "ActionBarVisibleSetting", EnumValue = 0 },
				{ Name = "InCombat", Type = "ActionBarVisibleSetting", EnumValue = 1 },
				{ Name = "OutOfCombat", Type = "ActionBarVisibleSetting", EnumValue = 2 },
				{ Name = "Hidden", Type = "ActionBarVisibleSetting", EnumValue = 3 },
			},
		},
		{
			Name = "AuraFrameIconDirection",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Down", Type = "AuraFrameIconDirection", EnumValue = 0 },
				{ Name = "Up", Type = "AuraFrameIconDirection", EnumValue = 1 },
				{ Name = "Left", Type = "AuraFrameIconDirection", EnumValue = 0 },
				{ Name = "Right", Type = "AuraFrameIconDirection", EnumValue = 1 },
			},
		},
		{
			Name = "AuraFrameIconWrap",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Down", Type = "AuraFrameIconWrap", EnumValue = 0 },
				{ Name = "Up", Type = "AuraFrameIconWrap", EnumValue = 1 },
				{ Name = "Left", Type = "AuraFrameIconWrap", EnumValue = 0 },
				{ Name = "Right", Type = "AuraFrameIconWrap", EnumValue = 1 },
			},
		},
		{
			Name = "AuraFrameOrientation",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Horizontal", Type = "AuraFrameOrientation", EnumValue = 0 },
				{ Name = "Vertical", Type = "AuraFrameOrientation", EnumValue = 1 },
			},
		},
		{
			Name = "EditModeAccountSetting",
			Type = "Enumeration",
			NumValues = 21,
			MinValue = 0,
			MaxValue = 20,
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
				{ Name = "ShowBuffFrame", Type = "EditModeAccountSetting", EnumValue = 10 },
				{ Name = "ShowDebuffFrame", Type = "EditModeAccountSetting", EnumValue = 11 },
				{ Name = "ShowPartyFrames", Type = "EditModeAccountSetting", EnumValue = 12 },
				{ Name = "ShowRaidFrames", Type = "EditModeAccountSetting", EnumValue = 13 },
				{ Name = "ShowTalkingHeadFrame", Type = "EditModeAccountSetting", EnumValue = 14 },
				{ Name = "ShowVehicleLeaveButton", Type = "EditModeAccountSetting", EnumValue = 15 },
				{ Name = "ShowBossFrames", Type = "EditModeAccountSetting", EnumValue = 16 },
				{ Name = "ShowArenaFrames", Type = "EditModeAccountSetting", EnumValue = 17 },
				{ Name = "ShowLootFrame", Type = "EditModeAccountSetting", EnumValue = 18 },
				{ Name = "ShowHudTooltip", Type = "EditModeAccountSetting", EnumValue = 19 },
				{ Name = "EnableSnap", Type = "EditModeAccountSetting", EnumValue = 20 },
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
				{ Name = "DeprecatedSnapToSide", Type = "EditModeActionBarSetting", EnumValue = 7 },
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
			Name = "EditModeAuraFrameSetting",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 0,
			MaxValue = 7,
			Fields =
			{
				{ Name = "Orientation", Type = "EditModeAuraFrameSetting", EnumValue = 0 },
				{ Name = "IconWrap", Type = "EditModeAuraFrameSetting", EnumValue = 1 },
				{ Name = "IconDirection", Type = "EditModeAuraFrameSetting", EnumValue = 2 },
				{ Name = "IconLimitBuffFrame", Type = "EditModeAuraFrameSetting", EnumValue = 3 },
				{ Name = "IconLimitDebuffFrame", Type = "EditModeAuraFrameSetting", EnumValue = 4 },
				{ Name = "IconSize", Type = "EditModeAuraFrameSetting", EnumValue = 5 },
				{ Name = "IconPadding", Type = "EditModeAuraFrameSetting", EnumValue = 6 },
				{ Name = "ShowFull", Type = "EditModeAuraFrameSetting", EnumValue = 7 },
			},
		},
		{
			Name = "EditModeAuraFrameSystemIndices",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 1,
			MaxValue = 2,
			Fields =
			{
				{ Name = "BuffFrame", Type = "EditModeAuraFrameSystemIndices", EnumValue = 1 },
				{ Name = "DebuffFrame", Type = "EditModeAuraFrameSystemIndices", EnumValue = 2 },
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
			Name = "EditModeChatFrameSetting",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "WidthHundreds", Type = "EditModeChatFrameSetting", EnumValue = 0 },
				{ Name = "WidthTensAndOnes", Type = "EditModeChatFrameSetting", EnumValue = 1 },
				{ Name = "HeightHundreds", Type = "EditModeChatFrameSetting", EnumValue = 2 },
				{ Name = "HeightTensAndOnes", Type = "EditModeChatFrameSetting", EnumValue = 3 },
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
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "HeaderUnderneath", Type = "EditModeMinimapSetting", EnumValue = 0 },
				{ Name = "RotateMinimap", Type = "EditModeMinimapSetting", EnumValue = 1 },
			},
		},
		{
			Name = "EditModeObjectiveTrackerSetting",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "Height", Type = "EditModeObjectiveTrackerSetting", EnumValue = 0 },
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
			NumValues = 13,
			MinValue = 0,
			MaxValue = 12,
			Fields =
			{
				{ Name = "ActionBar", Type = "EditModeSystem", EnumValue = 0 },
				{ Name = "CastBar", Type = "EditModeSystem", EnumValue = 1 },
				{ Name = "Minimap", Type = "EditModeSystem", EnumValue = 2 },
				{ Name = "UnitFrame", Type = "EditModeSystem", EnumValue = 3 },
				{ Name = "EncounterBar", Type = "EditModeSystem", EnumValue = 4 },
				{ Name = "ExtraAbilities", Type = "EditModeSystem", EnumValue = 5 },
				{ Name = "AuraFrame", Type = "EditModeSystem", EnumValue = 6 },
				{ Name = "TalkingHeadFrame", Type = "EditModeSystem", EnumValue = 7 },
				{ Name = "ChatFrame", Type = "EditModeSystem", EnumValue = 8 },
				{ Name = "VehicleLeaveButton", Type = "EditModeSystem", EnumValue = 9 },
				{ Name = "LootFrame", Type = "EditModeSystem", EnumValue = 10 },
				{ Name = "HudTooltip", Type = "EditModeSystem", EnumValue = 11 },
				{ Name = "ObjectiveTracker", Type = "EditModeSystem", EnumValue = 12 },
			},
		},
		{
			Name = "EditModeUnitFrameSetting",
			Type = "Enumeration",
			NumValues = 16,
			MinValue = 0,
			MaxValue = 15,
			Fields =
			{
				{ Name = "HidePortrait", Type = "EditModeUnitFrameSetting", EnumValue = 0 },
				{ Name = "CastBarUnderneath", Type = "EditModeUnitFrameSetting", EnumValue = 1 },
				{ Name = "BuffsOnTop", Type = "EditModeUnitFrameSetting", EnumValue = 2 },
				{ Name = "UseLargerFrame", Type = "EditModeUnitFrameSetting", EnumValue = 3 },
				{ Name = "UseRaidStylePartyFrames", Type = "EditModeUnitFrameSetting", EnumValue = 4 },
				{ Name = "ShowPartyFrameBackground", Type = "EditModeUnitFrameSetting", EnumValue = 5 },
				{ Name = "UseHorizontalGroups", Type = "EditModeUnitFrameSetting", EnumValue = 6 },
				{ Name = "CastBarOnSide", Type = "EditModeUnitFrameSetting", EnumValue = 7 },
				{ Name = "ShowCastTime", Type = "EditModeUnitFrameSetting", EnumValue = 8 },
				{ Name = "ViewRaidSize", Type = "EditModeUnitFrameSetting", EnumValue = 9 },
				{ Name = "FrameWidth", Type = "EditModeUnitFrameSetting", EnumValue = 10 },
				{ Name = "FrameHeight", Type = "EditModeUnitFrameSetting", EnumValue = 11 },
				{ Name = "DisplayBorder", Type = "EditModeUnitFrameSetting", EnumValue = 12 },
				{ Name = "RaidGroupDisplayType", Type = "EditModeUnitFrameSetting", EnumValue = 13 },
				{ Name = "SortPlayersBy", Type = "EditModeUnitFrameSetting", EnumValue = 14 },
				{ Name = "RowSize", Type = "EditModeUnitFrameSetting", EnumValue = 15 },
			},
		},
		{
			Name = "EditModeUnitFrameSystemIndices",
			Type = "Enumeration",
			NumValues = 7,
			MinValue = 1,
			MaxValue = 7,
			Fields =
			{
				{ Name = "Player", Type = "EditModeUnitFrameSystemIndices", EnumValue = 1 },
				{ Name = "Target", Type = "EditModeUnitFrameSystemIndices", EnumValue = 2 },
				{ Name = "Focus", Type = "EditModeUnitFrameSystemIndices", EnumValue = 3 },
				{ Name = "Party", Type = "EditModeUnitFrameSystemIndices", EnumValue = 4 },
				{ Name = "Raid", Type = "EditModeUnitFrameSystemIndices", EnumValue = 5 },
				{ Name = "Boss", Type = "EditModeUnitFrameSystemIndices", EnumValue = 6 },
				{ Name = "Arena", Type = "EditModeUnitFrameSystemIndices", EnumValue = 7 },
			},
		},
		{
			Name = "RaidGroupDisplayType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "SeparateGroupsVertical", Type = "RaidGroupDisplayType", EnumValue = 0 },
				{ Name = "SeparateGroupsHorizontal", Type = "RaidGroupDisplayType", EnumValue = 1 },
				{ Name = "CombineGroupsVertical", Type = "RaidGroupDisplayType", EnumValue = 2 },
				{ Name = "CombineGroupsHorizontal", Type = "RaidGroupDisplayType", EnumValue = 3 },
			},
		},
		{
			Name = "SortPlayersBy",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Role", Type = "SortPlayersBy", EnumValue = 0 },
				{ Name = "Group", Type = "SortPlayersBy", EnumValue = 1 },
				{ Name = "Alphabetical", Type = "SortPlayersBy", EnumValue = 2 },
			},
		},
		{
			Name = "ViewRaidSize",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Ten", Type = "ViewRaidSize", EnumValue = 0 },
				{ Name = "TwentyFive", Type = "ViewRaidSize", EnumValue = 1 },
				{ Name = "Forty", Type = "ViewRaidSize", EnumValue = 2 },
			},
		},
		{
			Name = "EditModeConsts",
			Type = "Constants",
			Values =
			{
				{ Name = "EditModeDefaultGridSpacing", Type = "number", Value = 100 },
				{ Name = "EditModeMinGridSpacing", Type = "number", Value = 20 },
				{ Name = "EditModeMaxGridSpacing", Type = "number", Value = 300 },
				{ Name = "EditModeMaxLayoutsPerType", Type = "number", Value = 5 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(EditModeManagerShared);