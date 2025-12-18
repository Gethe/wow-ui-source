RIGHT_ACTION_BAR_DEFAULT_OFFSET_X = -5;
RIGHT_ACTION_BAR_DEFAULT_OFFSET_Y = -77;
RIGHT_ACTION_BAR_DEFAULT_PADDING_X = 0;
RIGHT_CONTAINER_OFFSET_Y = -260;
ACTION_BARS_SKIP_AUTOMATIC_POSITIONING = false;

EDIT_MODE_MODERN_SYSTEM_MAP =
{
	[Enum.EditModeSystem.ActionBar] = {
		[Enum.EditModeActionBarSystemIndices.MainBar] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
				[Enum.EditModeActionBarSetting.HideBarArt] = 0,
				[Enum.EditModeActionBarSetting.HideBarScrolling] = 0,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
			},
		},

		[Enum.EditModeActionBarSystemIndices.Bar2] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
				[Enum.EditModeActionBarSetting.VisibleSetting] = Enum.ActionBarVisibleSetting.Always,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
			},
		},

		[Enum.EditModeActionBarSystemIndices.Bar3] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
				[Enum.EditModeActionBarSetting.VisibleSetting] = Enum.ActionBarVisibleSetting.Always,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = ACTION_BAR_3_ANCHOR_POINT,
				relativeTo = ACTION_BAR_3_RELATIVE_TO,
				relativePoint = ACTION_BAR_3_RELATIVE_POINT,
				offsetX = 0,
				offsetY = BOTTOM_ACTION_BARS_INITIAL_OFFSET_Y,
			},
		},

		[Enum.EditModeActionBarSystemIndices.RightBar1] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Vertical,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
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
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
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

		[Enum.EditModeActionBarSystemIndices.ExtraBar1] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
				[Enum.EditModeActionBarSetting.VisibleSetting] = Enum.ActionBarVisibleSetting.Always,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "TOP",
				relativeTo = "UIParent",
				relativePoint = "CENTER",
				offsetX = 0,
				offsetY = 0,
			},
		},

		[Enum.EditModeActionBarSystemIndices.ExtraBar2] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
				[Enum.EditModeActionBarSetting.VisibleSetting] = Enum.ActionBarVisibleSetting.Always,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "TOP",
				relativeTo = "UIParent",
				relativePoint = "CENTER",
				offsetX = 0,
				offsetY = -50,
			},
		},

		[Enum.EditModeActionBarSystemIndices.ExtraBar3] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
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
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
			},
		},

		[Enum.EditModeActionBarSystemIndices.PetActionBar] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 0,
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
			},
		},

		[Enum.EditModeActionBarSystemIndices.PossessActionBar] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
			},
		},
	},

	-- Note: The anchorInfo here doesn't actually get applied because cast bar is a bottom managed frame
	-- We still need to include it though, and if the player moves the cast bar it is updated and used
	[Enum.EditModeSystem.CastBar] = {
		settings = {
			[Enum.EditModeCastBarSetting.BarSize] = 0,
			[Enum.EditModeCastBarSetting.LockToPlayerFrame] = 0,
			[Enum.EditModeCastBarSetting.ShowCastTime] = 0,
		},
		anchorInfo = {
			point = "CENTER",
			relativeTo = "UIParent",
			relativePoint = "CENTER",
			offsetX = 0,
			offsetY = 0,
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
				offsetY = 250,
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
				[Enum.EditModeUnitFrameSetting.FrameHeight] = 6,
				[Enum.EditModeUnitFrameSetting.FrameWidth] = 18,
				[Enum.EditModeUnitFrameSetting.FrameSize] = 0,
				[Enum.EditModeUnitFrameSetting.SortPlayersBy] = Enum.SortPlayersBy.Group,
				[Enum.EditModeUnitFrameSetting.AuraOrganizationType] = Enum.RaidAuraOrganizationType.Legacy,
				[Enum.EditModeUnitFrameSetting.Opacity] = 100,
				[Enum.EditModeUnitFrameSetting.IconSize] = 5,
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
				[Enum.EditModeUnitFrameSetting.FrameHeight] = 6,
				[Enum.EditModeUnitFrameSetting.FrameWidth] = 18,
				[Enum.EditModeUnitFrameSetting.RowSize] = 5,
				[Enum.EditModeUnitFrameSetting.AuraOrganizationType] = Enum.RaidAuraOrganizationType.Legacy,
				[Enum.EditModeUnitFrameSetting.Opacity] = 100,
				[Enum.EditModeUnitFrameSetting.IconSize] = 5,
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
				[Enum.EditModeUnitFrameSetting.UseLargerFrame] = 0,
				[Enum.EditModeUnitFrameSetting.CastBarOnSide] = 1,
				-- [Enum.EditModeUnitFrameSetting.ShowCastTime] = 0,
				[Enum.EditModeUnitFrameSetting.FrameSize] = 0,
			},
			anchorInfo = {
				point = "RIGHT",
				relativeTo = "UIParent",
				relativePoint = "RIGHT",
				offsetX = 0,
				offsetY = 0,
			},
		},

		[Enum.EditModeUnitFrameSystemIndices.Arena] = {
			settings = {
				[Enum.EditModeUnitFrameSetting.ViewArenaSize] = Enum.ViewArenaSize.Three,
				[Enum.EditModeUnitFrameSetting.FrameHeight] = 6,
				[Enum.EditModeUnitFrameSetting.FrameWidth] = 18,
				[Enum.EditModeUnitFrameSetting.DisplayBorder] = 0,
				[Enum.EditModeUnitFrameSetting.AuraOrganizationType] = Enum.RaidAuraOrganizationType.Legacy,
				[Enum.EditModeUnitFrameSetting.Opacity] = 100,
				[Enum.EditModeUnitFrameSetting.IconSize] = 5,
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
			offsetX = 0,
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
			offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
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
			offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
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
				offsetX = -255,
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
				[Enum.EditModeAuraFrameSetting.ShowDispelType] = 1,
			},
			anchorInfo = {
				point = "TOPRIGHT",
				relativeTo = "UIParent",
				relativePoint = "TOPRIGHT",
				offsetX = -270,
				offsetY = -155,
			},
		},
		[Enum.EditModeAuraFrameSystemIndices.ExternalDefensivesFrame] = {
			settings = {
				[Enum.EditModeAuraFrameSetting.Orientation] = Enum.AuraFrameOrientation.Horizontal,
				[Enum.EditModeAuraFrameSetting.IconWrap] = Enum.AuraFrameIconWrap.Down,
				[Enum.EditModeAuraFrameSetting.IconDirection] = Enum.AuraFrameIconDirection.Right,
				[Enum.EditModeAuraFrameSetting.IconLimitBuffFrame] = 11,
				[Enum.EditModeAuraFrameSetting.IconSize] = 5,
				[Enum.EditModeAuraFrameSetting.IconPadding] = 5,
				[Enum.EditModeAuraFrameSetting.VisibleSetting] = Enum.AuraFrameVisibleSetting.Always,
				[Enum.EditModeAuraFrameSetting.Opacity] = 100,
			},
			anchorInfo = {
				point = "TOP",
				relativeTo = "UIParent",
				relativePoint = "TOP",
				offsetX = 0,
				offsetY = -25,
			},
		},
	},

	[Enum.EditModeSystem.TalkingHeadFrame] = {
		settings = {
		},
		anchorInfo = {
			point = "BOTTOM",
			relativeTo = "UIParent",
			relativePoint = "BOTTOM",
			offsetX = 0,
			offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
		},
	},

	[Enum.EditModeSystem.ChatFrame] = {
		settings = {
			[Enum.EditModeChatFrameSetting.WidthHundreds] = 4,
			[Enum.EditModeChatFrameSetting.WidthTensAndOnes] = 30,
			[Enum.EditModeChatFrameSetting.HeightHundreds] = 1,
			[Enum.EditModeChatFrameSetting.HeightTensAndOnes] = 70,
		},
		anchorInfo = {
			point = "BOTTOMLEFT",
			relativeTo = "UIParent",
			relativePoint = "BOTTOMLEFT",
			offsetX = 35,
			offsetY = CHAT_FRAME_ANCHOR_OFFSET_Y,
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
			offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
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
		settings = {
			[Enum.EditModeObjectiveTrackerSetting.Height] = 40,
			[Enum.EditModeObjectiveTrackerSetting.Opacity] = 0,
			[Enum.EditModeObjectiveTrackerSetting.TextSize] = 0,
		},
		anchorInfo = {
			point = "TOPRIGHT",
			relativeTo = "UIParent",
			relativePoint = "TOPRIGHT",
			offsetX = -110,
			offsetY = -275,
		},
	},

	[Enum.EditModeSystem.MicroMenu] = {
		settings = {
			[Enum.EditModeMicroMenuSetting.Orientation] = Enum.MicroMenuOrientation.Horizontal,
			[Enum.EditModeMicroMenuSetting.Order] = Enum.MicroMenuOrder.Default,
			[Enum.EditModeMicroMenuSetting.Size] = 6,
			[Enum.EditModeMicroMenuSetting.EyeSize] = 10,
		},
		anchorInfo = {
			point = MICRO_MENU_ANCHOR_POINT,
			relativeTo = MICRO_MENU_ANCHOR_RELATIVE_TO,
			relativePoint = MICRO_MENU_ANCHOR_RELATIVE_POINT,
			offsetX = MICRO_MENU_ANCHOR_OFFSET_X,
			offsetY = MICRO_MENU_ANCHOR_OFFSET_Y,
		},
	},

	[Enum.EditModeSystem.Bags] = {
		settings = {
			[Enum.EditModeBagsSetting.Orientation] = Enum.BagsOrientation.Horizontal,
			[Enum.EditModeBagsSetting.Direction] = Enum.BagsDirection.Left,
			[Enum.EditModeBagsSetting.Size] = 5,
		},
		anchorInfo = {
			point = BAGS_ANCHOR_POINT,
			relativeTo = BAGS_ANCHOR_RELATIVE_TO,
			relativePoint = BAGS_ANCHOR_RELATIVE_POINT,
			offsetX = BAGS_ANCHOR_OFFSET_X,
			offsetY = BAGS_ANCHOR_OFFSET_Y,
		},
	},

	[Enum.EditModeSystem.StatusTrackingBar] = {
		[Enum.EditModeStatusTrackingBarSystemIndices.StatusTrackingBar1] = {
			settings = {
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "StatusTrackingBarManager",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = STATUS_BAR_1_ANCHOR_OFFSET_Y,
			},
		},
		[Enum.EditModeStatusTrackingBarSystemIndices.StatusTrackingBar2] = {
			settings = {
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "StatusTrackingBarManager",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = STATUS_BAR_2_ANCHOR_OFFSET_Y,
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
				[Enum.EditModeCooldownViewerSetting.ShowTooltips] = 1,
				-- [Enum.EditModeCooldownViewerSetting.BarWidthScale] = 100,
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
				[Enum.EditModeCooldownViewerSetting.ShowTooltips] = 1,
				-- [Enum.EditModeCooldownViewerSetting.BarWidthScale] = 100,
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
				[Enum.EditModeCooldownViewerSetting.ShowTooltips] = 1,
				-- [Enum.EditModeCooldownViewerSetting.BarWidthScale] = 100,
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
				[Enum.EditModeCooldownViewerSetting.ShowTooltips] = 1,
				[Enum.EditModeCooldownViewerSetting.BarWidthScale] = 100,
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

	[Enum.EditModeSystem.PersonalResourceDisplay] = {
		settings = {
			[Enum.EditModePersonalResourceDisplaySetting.HideHealthAndPower] = 0,
			[Enum.EditModePersonalResourceDisplaySetting.OnlyShowInCombat] = 0,
		},
		anchorInfo = {
			point = "BOTTOM",
			relativeTo = "UIParent",
			relativePoint = "BOTTOM",
			offsetX = -410,
			offsetY = 380,
		},
	},

	[Enum.EditModeSystem.EncounterEvents] = {
		[Enum.EditModeEncounterEventsSystemIndices.Timeline] = {
			settings = {
				[Enum.EditModeEncounterEventsSetting.Orientation] = Enum.EncounterEventsOrientation.Vertical,
				[Enum.EditModeEncounterEventsSetting.IconDirection] = Enum.EncounterEventsIconDirection.Right,
				[Enum.EditModeEncounterEventsSetting.IconSize] = 5,
				[Enum.EditModeEncounterEventsSetting.OverallSize] = 5,
				[Enum.EditModeEncounterEventsSetting.Transparency] = 50,
				[Enum.EditModeEncounterEventsSetting.BackgroundTransparency] = 0,
				[Enum.EditModeEncounterEventsSetting.Visibility] = Enum.EncounterEventsVisibility.InEncounter,
				[Enum.EditModeEncounterEventsSetting.ShowSpellName] = 0,
				[Enum.EditModeEncounterEventsSetting.ShowTooltips] = 1,
				[Enum.EditModeEncounterEventsSetting.ShowTimer] = 1,
			},
			anchorInfo = {
				point = "BOTTOMRIGHT",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = -457,
				offsetY = 336,
			},
		},
		[Enum.EditModeEncounterEventsSystemIndices.CriticalWarnings] = {
			settings = {
				[Enum.EditModeEncounterEventsSetting.IconSize] = 5,
				[Enum.EditModeEncounterEventsSetting.OverallSize] = 5,
				[Enum.EditModeEncounterEventsSetting.Transparency] = 50,
				[Enum.EditModeEncounterEventsSetting.Visibility] = Enum.EncounterEventsVisibility.Always,
				[Enum.EditModeEncounterEventsSetting.ShowTooltips] = 1,
			},
			anchorInfo = {
				point = "TOP",
				relativeTo = "UIParent",
				relativePoint = "TOP",
				offsetX = 0,
				offsetY = -40,
			},
		},
		[Enum.EditModeEncounterEventsSystemIndices.MediumWarnings] = {
			settings = {
				[Enum.EditModeEncounterEventsSetting.IconSize] = 5,
				[Enum.EditModeEncounterEventsSetting.OverallSize] = 5,
				[Enum.EditModeEncounterEventsSetting.Transparency] = 50,
				[Enum.EditModeEncounterEventsSetting.Visibility] = Enum.EncounterEventsVisibility.Always,
				[Enum.EditModeEncounterEventsSetting.ShowTooltips] = 1,
			},
			anchorInfo = {
				point = "TOP",
				relativeTo = "UIParent",
				relativePoint = "TOP",
				offsetX = 0,
				offsetY = -90,
			},

		},
		[Enum.EditModeEncounterEventsSystemIndices.NormalWarnings] = {
			settings = {
				[Enum.EditModeEncounterEventsSetting.IconSize] = 5,
				[Enum.EditModeEncounterEventsSetting.OverallSize] = 5,
				[Enum.EditModeEncounterEventsSetting.Transparency] = 50,
				[Enum.EditModeEncounterEventsSetting.Visibility] = Enum.EncounterEventsVisibility.Always,
				[Enum.EditModeEncounterEventsSetting.ShowTooltips] = 1,
			},
			anchorInfo = {
				point = "TOP",
				relativeTo = "UIParent",
				relativePoint = "TOP",
				offsetX = 0,
				offsetY = -130,
			},
		},
	},

	[Enum.EditModeSystem.DamageMeter] = {
		settings = {
			[Enum.EditModeDamageMeterSetting.Visibility] = Enum.DamageMeterVisibility.Always,
			[Enum.EditModeDamageMeterSetting.Style] = Enum.DamageMeterStyle.Default,
			[Enum.EditModeDamageMeterSetting.Numbers] = Enum.DamageMeterNumbers.Compact,
			[Enum.EditModeDamageMeterSetting.FrameWidth] = 100,
			[Enum.EditModeDamageMeterSetting.FrameHeight] = 20,
			[Enum.EditModeDamageMeterSetting.BarHeight] = 1,
			[Enum.EditModeDamageMeterSetting.Padding] = 2,
			[Enum.EditModeDamageMeterSetting.Transparency] = 50,
			[Enum.EditModeDamageMeterSetting.ShowSpecIcon] = 1,
			[Enum.EditModeDamageMeterSetting.ShowClassColor] = 1,
			[Enum.EditModeDamageMeterSetting.TextSize] = 5,
			[Enum.EditModeDamageMeterSetting.BackgroundTransparency] = 50,
		},
		anchorInfo = {
			point = "TOPLEFT",
			relativeTo = "UIParent",
			relativePoint = "TOPLEFT",
			offsetX = 0,
			offsetY = 0,
		},
	},
};

EDIT_MODE_CLASSIC_SYSTEM_MAP =
{
	[Enum.EditModeSystem.ActionBar] = {
		[Enum.EditModeActionBarSystemIndices.MainBar] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
				[Enum.EditModeActionBarSetting.HideBarArt] = 0,
				[Enum.EditModeActionBarSetting.HideBarScrolling] = 0,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
			},
		},

		[Enum.EditModeActionBarSystemIndices.Bar2] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
				[Enum.EditModeActionBarSetting.VisibleSetting] = Enum.ActionBarVisibleSetting.Always,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
			},
		},

		[Enum.EditModeActionBarSystemIndices.Bar3] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
				[Enum.EditModeActionBarSetting.VisibleSetting] = Enum.ActionBarVisibleSetting.Always,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
			},
		},

		[Enum.EditModeActionBarSystemIndices.RightBar1] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Vertical,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
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
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
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

		[Enum.EditModeActionBarSystemIndices.ExtraBar1] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
				[Enum.EditModeActionBarSetting.VisibleSetting] = Enum.ActionBarVisibleSetting.Always,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "TOP",
				relativeTo = "UIParent",
				relativePoint = "CENTER",
				offsetX = 0,
				offsetY = 0,
			},
		},

		[Enum.EditModeActionBarSystemIndices.ExtraBar2] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
				[Enum.EditModeActionBarSetting.VisibleSetting] = Enum.ActionBarVisibleSetting.Always,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "TOP",
				relativeTo = "UIParent",
				relativePoint = "CENTER",
				offsetX = 0,
				offsetY = -50,
			},
		},

		[Enum.EditModeActionBarSystemIndices.ExtraBar3] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
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
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
			},
		},

		[Enum.EditModeActionBarSystemIndices.PetActionBar] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 0,
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
			},
		},

		[Enum.EditModeActionBarSystemIndices.PossessActionBar] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 2,
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
			},
		},
	},

	-- Note: The anchorInfo here doesn't actually get applied because cast bar is a bottom managed frame
	-- We still need to include it though, and if the player moves the cast bar it is updated and used
	[Enum.EditModeSystem.CastBar] = {
		settings = {
			[Enum.EditModeCastBarSetting.BarSize] = 0,
			[Enum.EditModeCastBarSetting.LockToPlayerFrame] = 0,
			[Enum.EditModeCastBarSetting.ShowCastTime] = 0,
		},
		anchorInfo = {
			point = "CENTER",
			relativeTo = "UIParent",
			relativePoint = "CENTER",
			offsetX = 0,
			offsetY = 0,
		},
	},

	[Enum.EditModeSystem.UnitFrame] = {
		[Enum.EditModeUnitFrameSystemIndices.Player] = {
			settings = {
				[Enum.EditModeUnitFrameSetting.CastBarUnderneath] = 0,
				[Enum.EditModeUnitFrameSetting.FrameSize] = 0,
			},
			anchorInfo = {
				point = "TOPLEFT",
				relativeTo = "UIParent",
				relativePoint = "TOPLEFT",
				offsetX = 4,
				offsetY = -4,
			},
		},

		[Enum.EditModeUnitFrameSystemIndices.Target] = {
			settings = {
				[Enum.EditModeUnitFrameSetting.BuffsOnTop] = 0,
				[Enum.EditModeUnitFrameSetting.FrameSize] = 0,
			},
			anchorInfo = {
				point = "TOPLEFT",
				relativeTo = "UIParent",
				relativePoint = "TOPLEFT",
				offsetX = 250,
				offsetY = -4,
			},
		},

		[Enum.EditModeUnitFrameSystemIndices.Focus] = {
			settings = {
				[Enum.EditModeUnitFrameSetting.BuffsOnTop] = 0,
				[Enum.EditModeUnitFrameSetting.UseLargerFrame] = 0,
				[Enum.EditModeUnitFrameSetting.FrameSize] = 0,
			},
			anchorInfo = {
				point = "TOPLEFT",
				relativeTo = "UIParent",
				relativePoint = "TOPLEFT",
				offsetX = 500,
				offsetY = -240,
			},
		},

		[Enum.EditModeUnitFrameSystemIndices.Party] = {
			settings = {
				[Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames] = 0,
				[Enum.EditModeUnitFrameSetting.ShowPartyFrameBackground] = 0,
				[Enum.EditModeUnitFrameSetting.UseHorizontalGroups] = 0,
				[Enum.EditModeUnitFrameSetting.DisplayBorder] = 0,
				[Enum.EditModeUnitFrameSetting.FrameHeight] = 6,
				[Enum.EditModeUnitFrameSetting.FrameWidth] = 18,
				[Enum.EditModeUnitFrameSetting.FrameSize] = 0,
				[Enum.EditModeUnitFrameSetting.SortPlayersBy] = Enum.SortPlayersBy.Group,
				[Enum.EditModeUnitFrameSetting.AuraOrganizationType] = Enum.RaidAuraOrganizationType.Legacy,
				[Enum.EditModeUnitFrameSetting.Opacity] = 100,
				[Enum.EditModeUnitFrameSetting.IconSize] = 5,
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
				[Enum.EditModeUnitFrameSetting.FrameHeight] = 6,
				[Enum.EditModeUnitFrameSetting.FrameWidth] = 18,
				[Enum.EditModeUnitFrameSetting.RowSize] = 5,
				[Enum.EditModeUnitFrameSetting.AuraOrganizationType] = Enum.RaidAuraOrganizationType.Legacy,
				[Enum.EditModeUnitFrameSetting.Opacity] = 100,
				[Enum.EditModeUnitFrameSetting.IconSize] = 5,
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
				[Enum.EditModeUnitFrameSetting.UseLargerFrame] = 0,
				[Enum.EditModeUnitFrameSetting.CastBarOnSide] = 1,
				-- [Enum.EditModeUnitFrameSetting.ShowCastTime] = 0,
				[Enum.EditModeUnitFrameSetting.FrameSize] = 0,
			},
			anchorInfo = {
				point = "RIGHT",
				relativeTo = "UIParent",
				relativePoint = "RIGHT",
				offsetX = 0,
				offsetY = 0,
			},
		},

		[Enum.EditModeUnitFrameSystemIndices.Arena] = {
			settings = {
				[Enum.EditModeUnitFrameSetting.ViewArenaSize] = Enum.ViewArenaSize.Three,
				[Enum.EditModeUnitFrameSetting.FrameHeight] = 6,
				[Enum.EditModeUnitFrameSetting.FrameWidth] = 18,
				[Enum.EditModeUnitFrameSetting.DisplayBorder] = 0,
				[Enum.EditModeUnitFrameSetting.AuraOrganizationType] = Enum.RaidAuraOrganizationType.Legacy,
				[Enum.EditModeUnitFrameSetting.Opacity] = 100,
				[Enum.EditModeUnitFrameSetting.IconSize] = 5,
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
			offsetX = 0,
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
			offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
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
			offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
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
				offsetX = -255,
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
				offsetX = -270,
				offsetY = -155,
			},
		},
		[Enum.EditModeAuraFrameSystemIndices.ExternalDefensivesFrame] = {
			settings = {
				[Enum.EditModeAuraFrameSetting.Orientation] = Enum.AuraFrameOrientation.Horizontal,
				[Enum.EditModeAuraFrameSetting.IconWrap] = Enum.AuraFrameIconWrap.Down,
				[Enum.EditModeAuraFrameSetting.IconDirection] = Enum.AuraFrameIconDirection.Left,
				[Enum.EditModeAuraFrameSetting.IconLimitBuffFrame] = 11,
				[Enum.EditModeAuraFrameSetting.IconSize] = 5,
				[Enum.EditModeAuraFrameSetting.IconPadding] = 5,
				[Enum.EditModeAuraFrameSetting.VisibleSetting] = Enum.AuraFrameVisibleSetting.Always,
				[Enum.EditModeAuraFrameSetting.Opacity] = 100,
			},
			anchorInfo = {
				point = "TOP",
				relativeTo = "UIParent",
				relativePoint = "TOP",
				offsetX = 0,
				offsetY = -25,
			},
		},
	},

	[Enum.EditModeSystem.TalkingHeadFrame] = {
		settings = {
		},
		anchorInfo = {
			point = "BOTTOM",
			relativeTo = "UIParent",
			relativePoint = "BOTTOM",
			offsetX = 0,
			offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
		},
	},

	[Enum.EditModeSystem.ChatFrame] = {
		settings = {
			[Enum.EditModeChatFrameSetting.WidthHundreds] = 4,
			[Enum.EditModeChatFrameSetting.WidthTensAndOnes] = 30,
			[Enum.EditModeChatFrameSetting.HeightHundreds] = 1,
			[Enum.EditModeChatFrameSetting.HeightTensAndOnes] = 20,
		},
		anchorInfo = {
			point = "BOTTOMLEFT",
			relativeTo = "UIParent",
			relativePoint = "BOTTOMLEFT",
			offsetX = 35,
			offsetY = CHAT_FRAME_ANCHOR_OFFSET_Y,
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
			offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
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
		settings = {
			[Enum.EditModeObjectiveTrackerSetting.Height] = 40,
			[Enum.EditModeObjectiveTrackerSetting.Opacity] = 0,
		},
		anchorInfo = {
			point = "TOPRIGHT",
			relativeTo = "UIParent",
			relativePoint = "TOPRIGHT",
			offsetX = -110,
			offsetY = -275,
		},
	},

	[Enum.EditModeSystem.MicroMenu] = {
		settings = {
			[Enum.EditModeMicroMenuSetting.Orientation] = Enum.MicroMenuOrientation.Horizontal,
			[Enum.EditModeMicroMenuSetting.Order] = Enum.MicroMenuOrder.Default,
			[Enum.EditModeMicroMenuSetting.Size] = 6,
			[Enum.EditModeMicroMenuSetting.EyeSize] = 10,
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
			},
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "StatusTrackingBarManager",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = 17,
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

	[Enum.EditModeSystem.CooldownViewer] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.CooldownViewer];

	[Enum.EditModeSystem.PersonalResourceDisplay] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.PersonalResourceDisplay];

	[Enum.EditModeSystem.EncounterEvents] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.EncounterEvents];

	[Enum.EditModeSystem.DamageMeter] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.DamageMeter];
};
