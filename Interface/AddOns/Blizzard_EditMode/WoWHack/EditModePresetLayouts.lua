MAIN_ACTION_BAR_OFFSET_Y = 40;
MAIN_ACTION_BAR_MANAGE_END_CAPS = true;
RIGHT_ACTION_BAR_DEFAULT_OFFSET_X = -5;
RIGHT_ACTION_BAR_DEFAULT_PADDING_X = 0;
RIGHT_ACTION_BAR_DEFAULT_OFFSET_Y = -77;
ACTION_BARS_SKIP_AUTOMATIC_POSITIONING = true;
RIGHT_CONTAINER_OFFSET_Y = -260;

EDIT_MODE_MODERN_SYSTEM_MAP =
{
	-- Main action bar (left side)
	[Enum.EditModeSystem.ActionBar] = {
		[Enum.EditModeActionBarSystemIndices.MainBar] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 4,
				[Enum.EditModeActionBarSetting.IconSize] = 9,
				[Enum.EditModeActionBarSetting.IconPadding] = 8,
				[Enum.EditModeActionBarSetting.HideBarArt] = 1,
				[Enum.EditModeActionBarSetting.HideBarScrolling] = 1,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "BOTTOMRIGHT",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = -72,
				offsetY = MAIN_ACTION_BAR_OFFSET_Y,
			},
		},

		-- Defensive Bar
		[Enum.EditModeActionBarSystemIndices.Bar2] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 3,
				[Enum.EditModeActionBarSetting.IconSize] = 5.5,
				[Enum.EditModeActionBarSetting.IconPadding] = 7,
				[Enum.EditModeActionBarSetting.HideBarArt] = 1,
				[Enum.EditModeActionBarSetting.VisibleSetting] = Enum.ActionBarVisibleSetting.Always,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "BOTTOMRIGHT",
				relativeTo = "WoWHackItemBar",
				relativePoint = "TOPRIGHT",
				offsetX = 79,
				offsetY = 22,
			},
		},

		[Enum.EditModeActionBarSystemIndices.Bar3] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 6,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 8,
				[Enum.EditModeActionBarSetting.VisibleSetting] = Enum.ActionBarVisibleSetting.Always,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = 150,
			},
		},

		[Enum.EditModeActionBarSystemIndices.RightBar1] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Vertical,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 8,
				[Enum.EditModeActionBarSetting.VisibleSetting] = Enum.ActionBarVisibleSetting.Always,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "RIGHT",
				relativeTo = "UIParent",
				relativePoint = "RIGHT",
				offsetX = RIGHT_ACTION_BAR_DEFAULT_OFFSET_X,
				offsetY = RIGHT_ACTION_BAR_DEFAULT_OFFSET_Y,
			},
		},

		[Enum.EditModeActionBarSystemIndices.RightBar2] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Vertical,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 8,
				[Enum.EditModeActionBarSetting.VisibleSetting] = Enum.ActionBarVisibleSetting.Always,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "RIGHT",
				relativeTo = "UIParent",
				relativePoint = "RIGHT",
				offsetX = RIGHT_ACTION_BAR_DEFAULT_OFFSET_X,
				offsetY = RIGHT_ACTION_BAR_DEFAULT_OFFSET_Y,
			},
		},

		-- Ultimate bar
		[Enum.EditModeActionBarSystemIndices.ExtraBar1] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 1,
				[Enum.EditModeActionBarSetting.IconSize] = 9,
				[Enum.EditModeActionBarSetting.IconPadding] = 8,
				[Enum.EditModeActionBarSetting.VisibleSetting] = Enum.ActionBarVisibleSetting.Always,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "LEFT",
				relativeTo = "MainActionBar",
				relativePoint = "RIGHT",
				offsetX = 40,
				offsetY = -1,
			},
		},

		[Enum.EditModeActionBarSystemIndices.ExtraBar2] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 2,
				[Enum.EditModeActionBarSetting.IconSize] = 9,
				[Enum.EditModeActionBarSetting.IconPadding] = 8,
				[Enum.EditModeActionBarSetting.HideBarArt] = 1,
				[Enum.EditModeActionBarSetting.VisibleSetting] = Enum.ActionBarVisibleSetting.Always,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "BOTTOMLEFT",
				relativeTo = "MainActionBar",
				relativePoint = "TOPLEFT",
				offsetX = 0,
				offsetY = 8,
			},
		},

		[Enum.EditModeActionBarSystemIndices.ExtraBar3] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 8,
				[Enum.EditModeActionBarSetting.VisibleSetting] = Enum.ActionBarVisibleSetting.Always,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "TOP",
				relativeTo = "UIParent",
				relativePoint = "CENTER",
				offsetX = 0,
				offsetY = -100,
			},
		},

		[Enum.EditModeActionBarSystemIndices.StanceBar] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 8,
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = MAIN_ACTION_BAR_OFFSET_Y,
			},
		},

		[Enum.EditModeActionBarSystemIndices.PetActionBar] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 8,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 0,
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = MAIN_ACTION_BAR_OFFSET_Y,
			},
		},

		[Enum.EditModeActionBarSystemIndices.PossessActionBar] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 8,
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = MAIN_ACTION_BAR_OFFSET_Y,
			},
		},
	},

	[Enum.EditModeSystem.CastBar] = {
		isInDefaultPosition = false,
		settings = {
			[Enum.EditModeCastBarSetting.BarSize] = 0,
			[Enum.EditModeCastBarSetting.LockToPlayerFrame] = 0,
			[Enum.EditModeCastBarSetting.ShowCastTime] = 0,
		},
		anchorInfo = {
			point = "BOTTOM",
			relativeTo = "UIParent",
			relativePoint = "BOTTOM",
			offsetX = 0,
			offsetY = 254,
		},
	},

	[Enum.EditModeSystem.UnitFrame] = {
		[Enum.EditModeUnitFrameSystemIndices.Player] = {
			settings = {
				[Enum.EditModeUnitFrameSetting.CastBarUnderneath] = 0,
				[Enum.EditModeUnitFrameSetting.FrameSize] = 0,
			},
			anchorInfo = {
				point = "BOTTOMRIGHT",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = -300,
				offsetY = 250,
			},
		},

		[Enum.EditModeUnitFrameSystemIndices.Target] = {
			settings = {
				[Enum.EditModeUnitFrameSetting.BuffsOnTop] = 0,
				[Enum.EditModeUnitFrameSetting.FrameSize] = 0,
			},
			anchorInfo = {
				point = "BOTTOMLEFT",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 300,
				offsetY = 278,
			},
		},

		[Enum.EditModeUnitFrameSystemIndices.Focus] = {
			settings = {
				[Enum.EditModeUnitFrameSetting.BuffsOnTop] = 0,
				[Enum.EditModeUnitFrameSetting.UseLargerFrame] = 0,
				[Enum.EditModeUnitFrameSetting.FrameSize] = 0,
			},
			anchorInfo = {
				point = "BOTTOMLEFT",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 520,
				offsetY = 265,
			},
		},

		[Enum.EditModeUnitFrameSystemIndices.Party] = {
			settings = {
				[Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames] = 0,
				[Enum.EditModeUnitFrameSetting.ShowPartyFrameBackground] = 0,
				[Enum.EditModeUnitFrameSetting.UseHorizontalGroups] = 0,
				[Enum.EditModeUnitFrameSetting.DisplayBorder] = 0,
				[Enum.EditModeUnitFrameSetting.FrameHeight] = 8,
				[Enum.EditModeUnitFrameSetting.FrameWidth] = 26,
				[Enum.EditModeUnitFrameSetting.FrameSize] = 0,
				[Enum.EditModeUnitFrameSetting.SortPlayersBy] = Enum.SortPlayersBy.Group,
			},
			anchorInfo = {
				point = "TOPLEFT",
				relativeTo = "CompactRaidFrameManager",
				relativePoint = "TOPRIGHT",
				offsetX = 0,
				offsetY = -7,
			},
		},

		[Enum.EditModeUnitFrameSystemIndices.Raid] = {
			settings = {
				[Enum.EditModeUnitFrameSetting.ViewRaidSize] = Enum.ViewRaidSize.Ten,
				[Enum.EditModeUnitFrameSetting.DisplayBorder] = 0,
				[Enum.EditModeUnitFrameSetting.RaidGroupDisplayType] = Enum.RaidGroupDisplayType.SeparateGroupsVertical,
				[Enum.EditModeUnitFrameSetting.SortPlayersBy] = Enum.SortPlayersBy.Role,
				[Enum.EditModeUnitFrameSetting.FrameHeight] = 8,
				[Enum.EditModeUnitFrameSetting.FrameWidth] = 26,
				[Enum.EditModeUnitFrameSetting.RowSize] = 5,
			},
			anchorInfo = {
				point = "TOPLEFT",
				relativeTo = "CompactRaidFrameManager",
				relativePoint = "TOPRIGHT",
				offsetX = 0,
				offsetY = -5,
			},
		},

		[Enum.EditModeUnitFrameSystemIndices.Boss] = {
			settings = {
				[Enum.EditModeUnitFrameSetting.UseLargerFrame] = 1,
				[Enum.EditModeUnitFrameSetting.CastBarOnSide] = 0,
				-- [Enum.EditModeUnitFrameSetting.ShowCastTime] = 0,
				[Enum.EditModeUnitFrameSetting.FrameSize] = 0,
				[Enum.EditModeUnitFrameSetting.UseHorizontalLayout] = 1,
				[Enum.EditModeUnitFrameSetting.GrowDirection] = Enum.BossFrameGrowDirection.Center,
			},
			anchorInfo = {
				point = "TOP",
				relativeTo = "UIParent",
				relativePoint = "TOP",
				offsetX = 0,
				offsetY = 0,
			},
		},

		[Enum.EditModeUnitFrameSystemIndices.Arena] = {
			settings = {
				[Enum.EditModeUnitFrameSetting.ViewArenaSize] = Enum.ViewArenaSize.Three,
				[Enum.EditModeUnitFrameSetting.FrameHeight] = 8,
				[Enum.EditModeUnitFrameSetting.FrameWidth] = 26,
				[Enum.EditModeUnitFrameSetting.DisplayBorder] = 0,
			},
			anchorInfo = {
				point = "RIGHT",
				relativeTo = "UIParent",
				relativePoint = "RIGHT",
				offsetX = 0,
				offsetY = 0,
			},
		},

		[Enum.EditModeUnitFrameSystemIndices.Pet] = {
			settings = {
				[Enum.EditModeUnitFrameSetting.FrameSize] = 0,
			},
			anchorInfo = {
				point = "CENTER",
				relativeTo = "UIParent",
				relativePoint = "CENTER",
				offsetX = 0,
				offsetY = 0,
			},
		},
	},

	[Enum.EditModeSystem.Minimap] = {
		settings = {
			[Enum.EditModeMinimapSetting.HeaderUnderneath] = 0,
			[Enum.EditModeMinimapSetting.RotateMinimap] = 0,
			[Enum.EditModeMinimapSetting.Size] = 5,
		},
		anchorInfo = {
			point = "TOPRIGHT",
			relativeTo = "UIParent",
			relativePoint = "TOPRIGHT",
			offsetX = -30,
			offsetY = 0,
		},
	},

	[Enum.EditModeSystem.EncounterBar] = {
		settings = {
		},
		anchorInfo = {
			point = "BOTTOM",
			relativeTo = "UIParent",
			relativePoint = "BOTTOM",
			offsetX = 0,
			offsetY = MAIN_ACTION_BAR_OFFSET_Y,
		},
	},

	[Enum.EditModeSystem.ExtraAbilities] = {
		settings = {
		},
		anchorInfo = {
			point = "BOTTOM",
			relativeTo = "UIParent",
			relativePoint = "BOTTOM",
			offsetX = 0,
			offsetY = MAIN_ACTION_BAR_OFFSET_Y,
		},
	},

	[Enum.EditModeSystem.AuraFrame] = {
		[Enum.EditModeAuraFrameSystemIndices.BuffFrame] = {
			settings = {
				[Enum.EditModeAuraFrameSetting.Orientation] = Enum.AuraFrameOrientation.Horizontal,
				[Enum.EditModeAuraFrameSetting.IconWrap] = Enum.AuraFrameIconWrap.Down,
				[Enum.EditModeAuraFrameSetting.IconDirection] = Enum.AuraFrameIconDirection.Left,
				[Enum.EditModeAuraFrameSetting.IconLimitBuffFrame] = 11,
				[Enum.EditModeAuraFrameSetting.IconSize] = 5,
				[Enum.EditModeAuraFrameSetting.IconPadding] = 5,
			},
			anchorInfo = {
				point = "TOPRIGHT",
				relativeTo = "UIParent",
				relativePoint = "TOPRIGHT",
				offsetX = -300,
				offsetY = -10,
			},
		},
		[Enum.EditModeAuraFrameSystemIndices.DebuffFrame] = {
			settings = {
				[Enum.EditModeAuraFrameSetting.Orientation] = Enum.AuraFrameOrientation.Horizontal,
				[Enum.EditModeAuraFrameSetting.IconWrap] = Enum.AuraFrameIconWrap.Down,
				[Enum.EditModeAuraFrameSetting.IconDirection] = Enum.AuraFrameIconDirection.Left,
				[Enum.EditModeAuraFrameSetting.IconLimitDebuffFrame] = 8,
				[Enum.EditModeAuraFrameSetting.IconSize] = 5,
				[Enum.EditModeAuraFrameSetting.IconPadding] = 5,
			},
			anchorInfo = {
				point = "TOPRIGHT",
				relativeTo = "UIParent",
				relativePoint = "TOPRIGHT",
				offsetX = -315,
				offsetY = -155,
			},
		},
	},

	[Enum.EditModeSystem.TalkingHeadFrame] = {
		isInDefaultPosition = false,
		settings = {
		},
		anchorInfo = {
			point = "TOP",
			relativeTo = "UIParent",
			relativePoint = "TOP",
			offsetX = 0,
			offsetY = -60,
		},
	},

	[Enum.EditModeSystem.ChatFrame] = {
		settings = {
			[Enum.EditModeChatFrameSetting.WidthHundreds] = 4,
			[Enum.EditModeChatFrameSetting.WidthTensAndOnes] = 60,
			[Enum.EditModeChatFrameSetting.HeightHundreds] = 1,
			[Enum.EditModeChatFrameSetting.HeightTensAndOnes] = 50,
		},
		anchorInfo = {
			point = "BOTTOMLEFT",
			relativeTo = "UIParent",
			relativePoint = "BOTTOMLEFT",
			offsetX = 35,
			offsetY = 100,
		},
	},

	[Enum.EditModeSystem.VehicleLeaveButton] = {
		settings = {
		},
		anchorInfo = {
			point = "BOTTOM",
			relativeTo = "UIParent",
			relativePoint = "BOTTOM",
			offsetX = 0,
			offsetY = MAIN_ACTION_BAR_OFFSET_Y,
		},
	},

	[Enum.EditModeSystem.LootFrame] = {
		settings = {
		},
		anchorInfo = {
			point = "TOPLEFT",
			relativeTo = "UIParent",
			relativePoint = "TOPLEFT",
			offsetX = 16,
			offsetY = -116,
		},
	},

	[Enum.EditModeSystem.HudTooltip] = {
		settings = {
		},
		anchorInfo = {
			point = "BOTTOMRIGHT",
			relativeTo = "UIParent",
			relativePoint = "BOTTOMRIGHT",
			offsetX = -9,
			offsetY = 85,
		},
	},

	[Enum.EditModeSystem.ObjectiveTracker] = {
		isInDefaultPosition = false,
		settings = {
			[Enum.EditModeObjectiveTrackerSetting.Height] = 40,
			[Enum.EditModeObjectiveTrackerSetting.Opacity] = 0,
			[Enum.EditModeObjectiveTrackerSetting.TextSize] = 0,
		},
		anchorInfo = {
			point = "TOPRIGHT",
			relativeTo = "UIParent",
			relativePoint = "TOPRIGHT",
			offsetX = -30,
			offsetY = -100,
		},
	},

	[Enum.EditModeSystem.MicroMenu] = {
		settings = {
			[Enum.EditModeMicroMenuSetting.Orientation] = Enum.MicroMenuOrientation.Horizontal,
			[Enum.EditModeMicroMenuSetting.Order] = Enum.MicroMenuOrder.Default,
			[Enum.EditModeMicroMenuSetting.Size] = 6,
		},
		anchorInfo = {
			point = "BOTTOMRIGHT",
			relativeTo = "MicroButtonAndBagsBar",
			relativePoint = "BOTTOMRIGHT",
			offsetX = 0,
			offsetY = 0,
		},
	},

	[Enum.EditModeSystem.Bags] = {
		settings = {
			[Enum.EditModeBagsSetting.Orientation] = Enum.BagsOrientation.Horizontal,
			[Enum.EditModeBagsSetting.Direction] = Enum.BagsDirection.Left,
			[Enum.EditModeBagsSetting.Size] = 5,
		},
		anchorInfo = {
			point = "TOPRIGHT",
			relativeTo = "MicroButtonAndBagsBar",
			relativePoint = "TOPRIGHT",
			offsetX = 0,
			offsetY = 10,
		},
	},

	[Enum.EditModeSystem.StatusTrackingBar] = {
		[Enum.EditModeStatusTrackingBarSystemIndices.StatusTrackingBar1] = {
			settings = {
				[Enum.EditModeStatusTrackingBarSetting.Size] = 10,
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "StatusTrackingBarManager",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = 0,
			},
		},
		[Enum.EditModeStatusTrackingBarSystemIndices.StatusTrackingBar2] = {
			settings = {
				[Enum.EditModeStatusTrackingBarSetting.Size] = 10,
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "StatusTrackingBarManager",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = 0,
			},
		},
	},

	[Enum.EditModeSystem.DurabilityFrame] = {
		settings = {
			[Enum.EditModeDurabilityFrameSetting.Size] = 5,
		},
		anchorInfo = {
			point = "RIGHT",
			relativeTo = "UIParent",
			relativePoint = "RIGHT",
			offsetX = 0,
			offsetY = 0,
		},
	},

	[Enum.EditModeSystem.TimerBars] = {
		settings = {
			[Enum.EditModeTimerBarsSetting.Size] = 0,
		},
		anchorInfo = {
			point = "TOP",
			relativeTo = "UIParent",
			relativePoint = "TOP",
			offsetX = 0,
			offsetY = -100,
		},
	},

	[Enum.EditModeSystem.VehicleSeatIndicator] = {
		settings = {
			[Enum.EditModeVehicleSeatIndicatorSetting.Size] = 10,
		},
		anchorInfo = {
			point = "RIGHT",
			relativeTo = "UIParent",
			relativePoint = "RIGHT",
			offsetX = 0,
			offsetY = 0,
		},
	},

	[Enum.EditModeSystem.ArchaeologyBar] = {
		settings = {
			[Enum.EditModeArchaeologyBarSetting.Size] = 0,
		},
		anchorInfo = {
			point = "BOTTOM",
			relativeTo = "UIParent",
			relativePoint = "BOTTOM",
			offsetX = 0,
			offsetY = 0,
		},
	},

	[Enum.EditModeSystem.CooldownViewer] = {
		[Enum.EditModeCooldownViewerSystemIndices.Essential] = {
			settings = {
				[Enum.EditModeCooldownViewerSetting.Orientation] = Enum.CooldownViewerOrientation.Horizontal,
				[Enum.EditModeCooldownViewerSetting.IconLimit] = 12,
				[Enum.EditModeCooldownViewerSetting.IconDirection] = Enum.CooldownViewerIconDirection.Right,
				[Enum.EditModeCooldownViewerSetting.IconSize] = 5,
				[Enum.EditModeCooldownViewerSetting.IconPadding] = 2,
				[Enum.EditModeCooldownViewerSetting.Opacity] = 100,
				[Enum.EditModeCooldownViewerSetting.VisibleSetting] = Enum.CooldownViewerVisibleSetting.Always,
				-- [Enum.EditModeCooldownViewerSetting.BarContent] = Enum.CooldownViewerBarContent.IconAndName,
				[Enum.EditModeCooldownViewerSetting.HideWhenInactive] = 1,
				[Enum.EditModeCooldownViewerSetting.ShowTimer] = 1,
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = 310,
			},
		},
		[Enum.EditModeCooldownViewerSystemIndices.Utility] = {
			settings = {
				[Enum.EditModeCooldownViewerSetting.Orientation] = Enum.CooldownViewerOrientation.Horizontal,
				[Enum.EditModeCooldownViewerSetting.IconLimit] = 7,
				[Enum.EditModeCooldownViewerSetting.IconDirection] = Enum.CooldownViewerIconDirection.Right,
				[Enum.EditModeCooldownViewerSetting.IconSize] = 5,
				[Enum.EditModeCooldownViewerSetting.IconPadding] = 2,
				[Enum.EditModeCooldownViewerSetting.Opacity] = 100,
				[Enum.EditModeCooldownViewerSetting.VisibleSetting] = Enum.CooldownViewerVisibleSetting.Always,
				-- [Enum.EditModeCooldownViewerSetting.BarContent] = Enum.CooldownViewerBarContent.IconAndName,
				[Enum.EditModeCooldownViewerSetting.HideWhenInactive] = 1,
				[Enum.EditModeCooldownViewerSetting.ShowTimer] = 1,
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = 240,
			},
		},
		[Enum.EditModeCooldownViewerSystemIndices.BuffIcon] = {
			settings = {
				[Enum.EditModeCooldownViewerSetting.Orientation] = Enum.CooldownViewerOrientation.Horizontal,
				[Enum.EditModeCooldownViewerSetting.IconLimit] = 1,
				[Enum.EditModeCooldownViewerSetting.IconDirection] = Enum.CooldownViewerIconDirection.Right,
				[Enum.EditModeCooldownViewerSetting.IconSize] = 5,
				[Enum.EditModeCooldownViewerSetting.IconPadding] = 5,
				[Enum.EditModeCooldownViewerSetting.Opacity] = 100,
				[Enum.EditModeCooldownViewerSetting.VisibleSetting] = Enum.CooldownViewerVisibleSetting.Always,
				-- [Enum.EditModeCooldownViewerSetting.BarContent] = Enum.CooldownViewerBarContent.IconAndName,
				[Enum.EditModeCooldownViewerSetting.HideWhenInactive] = 1,
				[Enum.EditModeCooldownViewerSetting.ShowTimer] = 1,
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = 370,
			},
		},
		[Enum.EditModeCooldownViewerSystemIndices.BuffBar] = {
			settings = {
				[Enum.EditModeCooldownViewerSetting.Orientation] = Enum.CooldownViewerOrientation.Vertical,
				[Enum.EditModeCooldownViewerSetting.IconLimit] = 1,
				[Enum.EditModeCooldownViewerSetting.IconDirection] = Enum.CooldownViewerIconDirection.Left,
				[Enum.EditModeCooldownViewerSetting.IconSize] = 5,
				[Enum.EditModeCooldownViewerSetting.IconPadding] = 5,
				[Enum.EditModeCooldownViewerSetting.Opacity] = 100,
				[Enum.EditModeCooldownViewerSetting.VisibleSetting] = Enum.CooldownViewerVisibleSetting.Always,
				[Enum.EditModeCooldownViewerSetting.BarContent] = Enum.CooldownViewerBarContent.IconAndName,
				[Enum.EditModeCooldownViewerSetting.HideWhenInactive] = 1,
				[Enum.EditModeCooldownViewerSetting.ShowTimer] = 1,
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 420,
				offsetY = 430,
			},
		},
	},

	[Enum.EditModeSystem.GroupFinder] = {
		settings = {
			[Enum.EditModeGroupFinderSetting.Size] = 10,
		},
		anchorInfo = {
			point = GROUP_FINDER_ANCHOR_POINT,
			relativeTo = GROUP_FINDER_RELATIVE_TO,
			relativePoint = GROUP_FINDER_RELATIVE_POINT,
			offsetX = GROUP_FINDER_OFFSET_X,
			offsetY = GROUP_FINDER_OFFSET_Y,
		},
	},

	[Enum.EditModeSystem.RaidWarning] = {
		settings = {
		},
		anchorInfo = {
			point = "TOP",
			relativeTo = "UIParent",
			relativePoint = "TOP",
			offsetX = 0,
			offsetY = -182,
		},
	},

	[Enum.EditModeSystem.LossOfControl] = {
		settings = {
			[Enum.EditModeLossOfControlSetting.Size] = 3,
		},
		anchorInfo = {
			point = "BOTTOM",
			relativeTo = "PersonalGrowingResourceDisplay",
			relativePoint = "TOP",
			offsetX = 0,
			offsetY = 10,
		},
	},
};