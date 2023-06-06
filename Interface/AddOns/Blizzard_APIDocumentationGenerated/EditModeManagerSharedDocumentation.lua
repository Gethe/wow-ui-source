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
			Name = "BagsDirection",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Left", Type = "BagsDirection", EnumValue = 0 },
				{ Name = "Right", Type = "BagsDirection", EnumValue = 1 },
				{ Name = "Up", Type = "BagsDirection", EnumValue = 0 },
				{ Name = "Down", Type = "BagsDirection", EnumValue = 1 },
			},
		},
		{
			Name = "BagsOrientation",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Horizontal", Type = "BagsOrientation", EnumValue = 0 },
				{ Name = "Vertical", Type = "BagsOrientation", EnumValue = 1 },
			},
		},
		{
			Name = "EditModeAccountSetting",
			Type = "Enumeration",
			NumValues = 28,
			MinValue = 0,
			MaxValue = 27,
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
				{ Name = "ShowBuffsAndDebuffs", Type = "EditModeAccountSetting", EnumValue = 10 },
				{ Name = "DeprecatedShowDebuffFrame", Type = "EditModeAccountSetting", EnumValue = 11 },
				{ Name = "ShowPartyFrames", Type = "EditModeAccountSetting", EnumValue = 12 },
				{ Name = "ShowRaidFrames", Type = "EditModeAccountSetting", EnumValue = 13 },
				{ Name = "ShowTalkingHeadFrame", Type = "EditModeAccountSetting", EnumValue = 14 },
				{ Name = "ShowVehicleLeaveButton", Type = "EditModeAccountSetting", EnumValue = 15 },
				{ Name = "ShowBossFrames", Type = "EditModeAccountSetting", EnumValue = 16 },
				{ Name = "ShowArenaFrames", Type = "EditModeAccountSetting", EnumValue = 17 },
				{ Name = "ShowLootFrame", Type = "EditModeAccountSetting", EnumValue = 18 },
				{ Name = "ShowHudTooltip", Type = "EditModeAccountSetting", EnumValue = 19 },
				{ Name = "ShowStatusTrackingBar2", Type = "EditModeAccountSetting", EnumValue = 20 },
				{ Name = "ShowDurabilityFrame", Type = "EditModeAccountSetting", EnumValue = 21 },
				{ Name = "EnableSnap", Type = "EditModeAccountSetting", EnumValue = 22 },
				{ Name = "EnableAdvancedOptions", Type = "EditModeAccountSetting", EnumValue = 23 },
				{ Name = "ShowPetFrame", Type = "EditModeAccountSetting", EnumValue = 24 },
				{ Name = "ShowTimerBars", Type = "EditModeAccountSetting", EnumValue = 25 },
				{ Name = "ShowVehicleSeatIndicator", Type = "EditModeAccountSetting", EnumValue = 26 },
				{ Name = "ShowArchaeologyBar", Type = "EditModeAccountSetting", EnumValue = 27 },
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
			NumValues = 11,
			MinValue = 1,
			MaxValue = 13,
			Fields =
			{
				{ Name = "MainBar", Type = "EditModeActionBarSystemIndices", EnumValue = 1 },
				{ Name = "Bar2", Type = "EditModeActionBarSystemIndices", EnumValue = 2 },
				{ Name = "Bar3", Type = "EditModeActionBarSystemIndices", EnumValue = 3 },
				{ Name = "RightBar1", Type = "EditModeActionBarSystemIndices", EnumValue = 4 },
				{ Name = "RightBar2", Type = "EditModeActionBarSystemIndices", EnumValue = 5 },
				{ Name = "ExtraBar1", Type = "EditModeActionBarSystemIndices", EnumValue = 6 },
				{ Name = "ExtraBar2", Type = "EditModeActionBarSystemIndices", EnumValue = 7 },
				{ Name = "ExtraBar3", Type = "EditModeActionBarSystemIndices", EnumValue = 8 },
				{ Name = "StanceBar", Type = "EditModeActionBarSystemIndices", EnumValue = 11 },
				{ Name = "PetActionBar", Type = "EditModeActionBarSystemIndices", EnumValue = 12 },
				{ Name = "PossessActionBar", Type = "EditModeActionBarSystemIndices", EnumValue = 13 },
			},
		},
		{
			Name = "EditModeArchaeologyBarSetting",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "Size", Type = "EditModeArchaeologyBarSetting", EnumValue = 0 },
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
				{ Name = "DeprecatedShowFull", Type = "EditModeAuraFrameSetting", EnumValue = 7 },
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
			Name = "EditModeBagsSetting",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Orientation", Type = "EditModeBagsSetting", EnumValue = 0 },
				{ Name = "Direction", Type = "EditModeBagsSetting", EnumValue = 1 },
				{ Name = "Size", Type = "EditModeBagsSetting", EnumValue = 2 },
			},
		},
		{
			Name = "EditModeCastBarSetting",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "BarSize", Type = "EditModeCastBarSetting", EnumValue = 0 },
				{ Name = "LockToPlayerFrame", Type = "EditModeCastBarSetting", EnumValue = 1 },
				{ Name = "ShowCastTime", Type = "EditModeCastBarSetting", EnumValue = 2 },
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
			Name = "EditModeDurabilityFrameSetting",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "Size", Type = "EditModeDurabilityFrameSetting", EnumValue = 0 },
			},
		},
		{
			Name = "EditModeLayoutType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Preset", Type = "EditModeLayoutType", EnumValue = 0 },
				{ Name = "Account", Type = "EditModeLayoutType", EnumValue = 1 },
				{ Name = "Character", Type = "EditModeLayoutType", EnumValue = 2 },
				{ Name = "Override", Type = "EditModeLayoutType", EnumValue = 3 },
			},
		},
		{
			Name = "EditModeMicroMenuSetting",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Orientation", Type = "EditModeMicroMenuSetting", EnumValue = 0 },
				{ Name = "Order", Type = "EditModeMicroMenuSetting", EnumValue = 1 },
				{ Name = "Size", Type = "EditModeMicroMenuSetting", EnumValue = 2 },
				{ Name = "EyeSize", Type = "EditModeMicroMenuSetting", EnumValue = 3 },
			},
		},
		{
			Name = "EditModeMinimapSetting",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "HeaderUnderneath", Type = "EditModeMinimapSetting", EnumValue = 0 },
				{ Name = "RotateMinimap", Type = "EditModeMinimapSetting", EnumValue = 1 },
				{ Name = "Size", Type = "EditModeMinimapSetting", EnumValue = 2 },
			},
		},
		{
			Name = "EditModeObjectiveTrackerSetting",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Height", Type = "EditModeObjectiveTrackerSetting", EnumValue = 0 },
				{ Name = "Opacity", Type = "EditModeObjectiveTrackerSetting", EnumValue = 1 },
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
			Name = "EditModeStatusTrackingBarSetting",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Height", Type = "EditModeStatusTrackingBarSetting", EnumValue = 0 },
				{ Name = "Width", Type = "EditModeStatusTrackingBarSetting", EnumValue = 1 },
				{ Name = "TextSize", Type = "EditModeStatusTrackingBarSetting", EnumValue = 2 },
			},
		},
		{
			Name = "EditModeStatusTrackingBarSystemIndices",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 1,
			MaxValue = 2,
			Fields =
			{
				{ Name = "StatusTrackingBar1", Type = "EditModeStatusTrackingBarSystemIndices", EnumValue = 1 },
				{ Name = "StatusTrackingBar2", Type = "EditModeStatusTrackingBarSystemIndices", EnumValue = 2 },
			},
		},
		{
			Name = "EditModeSystem",
			Type = "Enumeration",
			NumValues = 20,
			MinValue = 0,
			MaxValue = 19,
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
				{ Name = "MicroMenu", Type = "EditModeSystem", EnumValue = 13 },
				{ Name = "Bags", Type = "EditModeSystem", EnumValue = 14 },
				{ Name = "StatusTrackingBar", Type = "EditModeSystem", EnumValue = 15 },
				{ Name = "DurabilityFrame", Type = "EditModeSystem", EnumValue = 16 },
				{ Name = "TimerBars", Type = "EditModeSystem", EnumValue = 17 },
				{ Name = "VehicleSeatIndicator", Type = "EditModeSystem", EnumValue = 18 },
				{ Name = "ArchaeologyBar", Type = "EditModeSystem", EnumValue = 19 },
			},
		},
		{
			Name = "EditModeTimerBarsSetting",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "Size", Type = "EditModeTimerBarsSetting", EnumValue = 0 },
			},
		},
		{
			Name = "EditModeUnitFrameSetting",
			Type = "Enumeration",
			NumValues = 18,
			MinValue = 0,
			MaxValue = 17,
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
				{ Name = "FrameSize", Type = "EditModeUnitFrameSetting", EnumValue = 16 },
				{ Name = "ViewArenaSize", Type = "EditModeUnitFrameSetting", EnumValue = 17 },
			},
		},
		{
			Name = "EditModeUnitFrameSystemIndices",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 1,
			MaxValue = 8,
			Fields =
			{
				{ Name = "Player", Type = "EditModeUnitFrameSystemIndices", EnumValue = 1 },
				{ Name = "Target", Type = "EditModeUnitFrameSystemIndices", EnumValue = 2 },
				{ Name = "Focus", Type = "EditModeUnitFrameSystemIndices", EnumValue = 3 },
				{ Name = "Party", Type = "EditModeUnitFrameSystemIndices", EnumValue = 4 },
				{ Name = "Raid", Type = "EditModeUnitFrameSystemIndices", EnumValue = 5 },
				{ Name = "Boss", Type = "EditModeUnitFrameSystemIndices", EnumValue = 6 },
				{ Name = "Arena", Type = "EditModeUnitFrameSystemIndices", EnumValue = 7 },
				{ Name = "Pet", Type = "EditModeUnitFrameSystemIndices", EnumValue = 8 },
			},
		},
		{
			Name = "EditModeVehicleSeatIndicatorSetting",
			Type = "Enumeration",
			NumValues = 1,
			MinValue = 0,
			MaxValue = 0,
			Fields =
			{
				{ Name = "Size", Type = "EditModeVehicleSeatIndicatorSetting", EnumValue = 0 },
			},
		},
		{
			Name = "MicroMenuOrder",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Default", Type = "MicroMenuOrder", EnumValue = 0 },
				{ Name = "Reverse", Type = "MicroMenuOrder", EnumValue = 1 },
			},
		},
		{
			Name = "MicroMenuOrientation",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Horizontal", Type = "MicroMenuOrientation", EnumValue = 0 },
				{ Name = "Vertical", Type = "MicroMenuOrientation", EnumValue = 1 },
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
			Name = "ViewArenaSize",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Two", Type = "ViewArenaSize", EnumValue = 0 },
				{ Name = "Three", Type = "ViewArenaSize", EnumValue = 1 },
				{ Name = "Five", Type = "ViewArenaSize", EnumValue = 2 },
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