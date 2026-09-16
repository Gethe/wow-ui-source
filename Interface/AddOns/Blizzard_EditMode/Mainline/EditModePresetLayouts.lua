RIGHT_ACTION_BAR_DEFAULT_OFFSET_X = -5;
RIGHT_ACTION_BAR_DEFAULT_OFFSET_Y = -77;
RIGHT_ACTION_BAR_DEFAULT_PADDING_X = 0;
RIGHT_CONTAINER_OFFSET_Y = -260;

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
				point = MAIN_ACTION_BAR_POINT,
				relativeTo = MAIN_ACTION_BAR_RELATIVE_TO,
				relativePoint = MAIN_ACTION_BAR_RELATIVE_POINT,
				offsetX = MAIN_ACTION_BAR_OFFSET_X,
				offsetY = MAIN_ACTION_BAR_OFFSET_Y,
				bottomBarOffsetX = 0,
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
				point = ACTION_BAR_2_ANCHOR_POINT,
				relativeTo = ACTION_BAR_2_RELATIVE_TO,
				relativePoint = ACTION_BAR_2_RELATIVE_POINT,
				offsetX = ACTION_BAR_2_OFFSET_X,
				offsetY = ACTION_BAR_2_OFFSET_Y,
				bottomBarOffsetX = ACTION_BAR_2_BOTTOM_BAR_OFFSET_X,
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
				offsetX = ACTION_BAR_3_OFFSET_X,
				offsetY = ACTION_BAR_3_OFFSET_Y,
				bottomBarOffsetX = ACTION_BAR_3_BOTTOM_BAR_OFFSET_X,
				bottomBarExcludeFromStackIncrement = ACTION_BAR_3_BOTTOM_BAR_EXCLUDE_FROM_STACK_INCREMENT,
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
				offsetY = MAIN_ACTION_BAR_OFFSET_Y,
				bottomBarOffsetX = BOTTOM_ACTION_BAR_DEFAULT_OFFSET_X,
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
				offsetY = MAIN_ACTION_BAR_OFFSET_Y,
				bottomBarOffsetX = BOTTOM_ACTION_BAR_DEFAULT_OFFSET_X,
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
				offsetY = MAIN_ACTION_BAR_OFFSET_Y,
				bottomBarOffsetX = BOTTOM_ACTION_BAR_DEFAULT_OFFSET_X,
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
				[Enum.EditModeUnitFrameSetting.FrameHeight] = 8,
				[Enum.EditModeUnitFrameSetting.FrameWidth] = 26,
				[Enum.EditModeUnitFrameSetting.FrameSize] = 0,
				[Enum.EditModeUnitFrameSetting.SortPlayersBy] = Enum.SortPlayersBy.Group,
				[Enum.EditModeUnitFrameSetting.AuraOrganizationType] = Enum.RaidAuraOrganizationType.Legacy,
				[Enum.EditModeUnitFrameSetting.Opacity] = 100,
				[Enum.EditModeUnitFrameSetting.DebuffIconSize] = 5,
				[Enum.EditModeUnitFrameSetting.BigDefensiveIconSize] = 5,
				[Enum.EditModeUnitFrameSetting.BuffIconSize] = 5,
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
				[Enum.EditModeUnitFrameSetting.FrameSize] = 0,
				[Enum.EditModeUnitFrameSetting.RowSize] = 5,
				[Enum.EditModeUnitFrameSetting.AuraOrganizationType] = Enum.RaidAuraOrganizationType.Legacy,
				[Enum.EditModeUnitFrameSetting.Opacity] = 100,
				[Enum.EditModeUnitFrameSetting.DebuffIconSize] = 5,
				[Enum.EditModeUnitFrameSetting.BigDefensiveIconSize] = 5,
				[Enum.EditModeUnitFrameSetting.BuffIconSize] = 5,
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
				[Enum.EditModeUnitFrameSetting.FrameHeight] = 8,
				[Enum.EditModeUnitFrameSetting.FrameWidth] = 26,
				[Enum.EditModeUnitFrameSetting.DisplayBorder] = 0,
				[Enum.EditModeUnitFrameSetting.AuraOrganizationType] = Enum.RaidAuraOrganizationType.Legacy,
				[Enum.EditModeUnitFrameSetting.Opacity] = 100,
				[Enum.EditModeUnitFrameSetting.DebuffIconSize] = 5,
				[Enum.EditModeUnitFrameSetting.BigDefensiveIconSize] = 5,
				[Enum.EditModeUnitFrameSetting.BuffIconSize] = 5,
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
			[Enum.EditModeMinimapSetting.IconScale] = 5,
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
			offsetY = MAIN_ACTION_BAR_OFFSET_Y,
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
			offsetY = MAIN_ACTION_BAR_OFFSET_Y,
			bottomBarOffsetX = BOTTOM_ACTION_BAR_DEFAULT_OFFSET_X,
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
				[Enum.EditModeStatusTrackingBarSetting.Size] = 10,
			},
			anchorInfo = {
				point = STATUS_BAR_1_ANCHOR_POINT,
				relativeTo = STATUS_BAR_1_ANCHOR_RELATIVE_TO,
				relativePoint = STATUS_BAR_1_ANCHOR_RELATIVE_POINT,
				offsetX = STATUS_BAR_1_ANCHOR_OFFSET_X,
				offsetY = STATUS_BAR_1_ANCHOR_OFFSET_Y,
			},
		},
		[Enum.EditModeStatusTrackingBarSystemIndices.StatusTrackingBar2] = {
			settings = {
				[Enum.EditModeStatusTrackingBarSetting.Size] = 10,
			},
			anchorInfo = {
				point = STATUS_BAR_2_ANCHOR_POINT,
				relativeTo = STATUS_BAR_2_ANCHOR_RELATIVE_TO,
				relativePoint = STATUS_BAR_2_ANCHOR_RELATIVE_POINT,
				offsetX = STATUS_BAR_2_ANCHOR_OFFSET_X,
				offsetY = STATUS_BAR_2_ANCHOR_OFFSET_Y,
				bottomBarExcludeFromStackIncrement = STATUS_BAR_2_BOTTOM_BAR_EXCLUDE_FROM_STACK_INCREMENT,
			},
		},
	},

	[Enum.EditModeSystem.MainActionBarEndCap] = {
		[Enum.EditModeMainActionBarEndCapSystemIndices.EndCapLeft] = {
			settings = {
				[Enum.EditModeMainActionBarEndCapSetting.Hidden] = 0,
			},
			anchorInfo = {
				point = "RIGHT",
				relativeTo = "MainActionBar",
				relativePoint = "LEFT",
				offsetX = 30,
				offsetY = 5,
			},
		},
		[Enum.EditModeMainActionBarEndCapSystemIndices.EndCapRight] = {
			settings = {
				[Enum.EditModeMainActionBarEndCapSetting.Hidden] = 0,
			},
			anchorInfo = {
				point = "LEFT",
				relativeTo = "BagsBar",
				relativePoint = "RIGHT",
				offsetX = -30,
				offsetY = 5,
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

	[Enum.EditModeSystem.SwingTimer] = {
		[Enum.EditModeSwingTimerSystemIndices.MainHand] = {
			settings = {
				[Enum.EditModeSwingTimerSetting.Scale] = 5,
				[Enum.EditModeSwingTimerSetting.Opacity] = 50,
				[Enum.EditModeSwingTimerSetting.Visibility] = Enum.EditModeSwingTimerVisibility.Always,
				[Enum.EditModeSwingTimerSetting.Width] = 213,
				[Enum.EditModeSwingTimerSetting.Height] = 15,
				[Enum.EditModeSwingTimerSetting.ShowBarTitle] = 1,
				[Enum.EditModeSwingTimerSetting.ShowTime] = 1,
			},
			-- Swing timers are stacked by the bottom managed frame container; these anchors only take effect once a bar is moved out of it.
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = 450,
			},
		},
		[Enum.EditModeSwingTimerSystemIndices.OffHand] = {
			settings = {
				[Enum.EditModeSwingTimerSetting.Scale] = 5,
				[Enum.EditModeSwingTimerSetting.Opacity] = 50,
				[Enum.EditModeSwingTimerSetting.Visibility] = Enum.EditModeSwingTimerVisibility.Always,
				[Enum.EditModeSwingTimerSetting.Width] = 213,
				[Enum.EditModeSwingTimerSetting.Height] = 15,
				[Enum.EditModeSwingTimerSetting.ShowBarTitle] = 1,
				[Enum.EditModeSwingTimerSetting.ShowTime] = 1,
			},
			-- Swing timers are stacked by the bottom managed frame container; these anchors only take effect once a bar is moved out of it.
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = 425,
			},
		},
		[Enum.EditModeSwingTimerSystemIndices.Ranged] = {
			settings = {
				[Enum.EditModeSwingTimerSetting.Scale] = 5,
				[Enum.EditModeSwingTimerSetting.Opacity] = 50,
				[Enum.EditModeSwingTimerSetting.Visibility] = Enum.EditModeSwingTimerVisibility.Always,
				[Enum.EditModeSwingTimerSetting.Width] = 213,
				[Enum.EditModeSwingTimerSetting.Height] = 15,
				[Enum.EditModeSwingTimerSetting.ShowBarTitle] = 1,
				[Enum.EditModeSwingTimerSetting.ShowTime] = 1,
			},
			-- Swing timers are stacked by the bottom managed frame container; these anchors only take effect once a bar is moved out of it.
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = 400,
			},
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

	[Enum.EditModeSystem.TotemActionBar] = {
		settings = {
		},
		anchorInfo = {
			point = "RIGHT",
			relativeTo = "UIParent",
			relativePoint = "BOTTOM",
			offsetX = -28,
			offsetY = 128,
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
			[Enum.EditModePersonalResourceDisplaySetting.HideHealth] = 0,
			[Enum.EditModePersonalResourceDisplaySetting.HidePower] = 0,
			[Enum.EditModePersonalResourceDisplaySetting.HideClassInfo] = 0,
			[Enum.EditModePersonalResourceDisplaySetting.HideClassInfoOnPlayerFrame] = 0,
			[Enum.EditModePersonalResourceDisplaySetting.VisibleSetting] = Enum.PersonalResourceDisplayVisibleSetting.Always,
			[Enum.EditModePersonalResourceDisplaySetting.HealthBarHeight] = 5,
			[Enum.EditModePersonalResourceDisplaySetting.PowerBarHeight] = 5,
			[Enum.EditModePersonalResourceDisplaySetting.Padding] = 0,
			[Enum.EditModePersonalResourceDisplaySetting.Opacity] = 100,
			[Enum.EditModePersonalResourceDisplaySetting.Size] = 3,
			[Enum.EditModePersonalResourceDisplaySetting.ShowClassColor] = 0,
			[Enum.EditModePersonalResourceDisplaySetting.BarWidth] = 5,
			[Enum.EditModePersonalResourceDisplaySetting.ShowBarText] = 0,
			[Enum.EditModePersonalResourceDisplaySetting.HideAltPower] = 0,
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
				[Enum.EditModeEncounterEventsSetting.ViewType] = Enum.EncounterEventsViewType.Timeline,
				[Enum.EditModeEncounterEventsSetting.Orientation] = Enum.EncounterEventsOrientation.Vertical,
				[Enum.EditModeEncounterEventsSetting.IconDirection] = Enum.EncounterEventsIconDirection.Right,
				[Enum.EditModeEncounterEventsSetting.IconSize] = 5,
				[Enum.EditModeEncounterEventsSetting.OverallSize] = 5,
				[Enum.EditModeEncounterEventsSetting.Transparency] = 50,
				[Enum.EditModeEncounterEventsSetting.BackgroundTransparency] = 0,
				[Enum.EditModeEncounterEventsSetting.Visibility] = Enum.EncounterEventsVisibility.InEncounter,
				[Enum.EditModeEncounterEventsSetting.ShowSpellName] = 0,
				[Enum.EditModeEncounterEventsSetting.TooltipAnchor] = Enum.EncounterEventsTooltipAnchor.Cursor,
				[Enum.EditModeEncounterEventsSetting.ShowTimer] = 1,
				[Enum.EditModeEncounterEventsSetting.FlipHorizontally] = 0,
				[Enum.EditModeEncounterEventsSetting.BarWidth] = 50,
				[Enum.EditModeEncounterEventsSetting.Padding] = 2,
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
				[Enum.EditModeEncounterEventsSetting.TooltipAnchor] = Enum.EncounterEventsTooltipAnchor.Cursor,
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
				[Enum.EditModeEncounterEventsSetting.TooltipAnchor] = Enum.EncounterEventsTooltipAnchor.Cursor,
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
				[Enum.EditModeEncounterEventsSetting.TooltipAnchor] = Enum.EncounterEventsTooltipAnchor.Cursor,
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
			[Enum.EditModeDamageMeterSetting.FrameWidth] = 200,
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

	[Enum.EditModeSystem.GroupFinder] = {
		settings = {
			[Enum.EditModeGroupFinderSetting.Size] = 10,
		},
		anchorInfo = {
			-- Modified in QueueStatusButtonMixin:UpdateDefaultAnchor.
			point = GROUP_FINDER_ANCHOR_POINT,
			relativeTo = GROUP_FINDER_RELATIVE_TO,
			relativePoint = GROUP_FINDER_RELATIVE_POINT,
			offsetX = GROUP_FINDER_OFFSET_X,
			offsetY = GROUP_FINDER_OFFSET_Y,
		},
	},

	[Enum.EditModeSystem.LossOfControl] = {
		settings = {
			[Enum.EditModeLossOfControlSetting.Size] = 5,
		},
		anchorInfo = {
			point = "CENTER",
			relativeTo = "UIParent",
			relativePoint = "CENTER",
			offsetX = 0,
			offsetY = 0,
		},
	},
};

EDIT_MODE_CLASSIC_SYSTEM_MAP =
{
	[Enum.EditModeSystem.ActionBar] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.ActionBar];

	[Enum.EditModeSystem.CastBar] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.CastBar];

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
				[Enum.EditModeUnitFrameSetting.FrameHeight] = 8,
				[Enum.EditModeUnitFrameSetting.FrameWidth] = 26,
				[Enum.EditModeUnitFrameSetting.FrameSize] = 0,
				[Enum.EditModeUnitFrameSetting.SortPlayersBy] = Enum.SortPlayersBy.Group,
				[Enum.EditModeUnitFrameSetting.AuraOrganizationType] = Enum.RaidAuraOrganizationType.Legacy,
				[Enum.EditModeUnitFrameSetting.Opacity] = 100,
				[Enum.EditModeUnitFrameSetting.DebuffIconSize] = 5,
				[Enum.EditModeUnitFrameSetting.BigDefensiveIconSize] = 5,
				[Enum.EditModeUnitFrameSetting.BuffIconSize] = 5,
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
				[Enum.EditModeUnitFrameSetting.FrameSize] = 0,
				[Enum.EditModeUnitFrameSetting.RowSize] = 5,
				[Enum.EditModeUnitFrameSetting.AuraOrganizationType] = Enum.RaidAuraOrganizationType.Legacy,
				[Enum.EditModeUnitFrameSetting.Opacity] = 100,
				[Enum.EditModeUnitFrameSetting.DebuffIconSize] = 5,
				[Enum.EditModeUnitFrameSetting.BigDefensiveIconSize] = 5,
				[Enum.EditModeUnitFrameSetting.BuffIconSize] = 5,
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
				[Enum.EditModeUnitFrameSetting.FrameHeight] = 8,
				[Enum.EditModeUnitFrameSetting.FrameWidth] = 26,
				[Enum.EditModeUnitFrameSetting.DisplayBorder] = 0,
				[Enum.EditModeUnitFrameSetting.AuraOrganizationType] = Enum.RaidAuraOrganizationType.Legacy,
				[Enum.EditModeUnitFrameSetting.Opacity] = 100,
				[Enum.EditModeUnitFrameSetting.DebuffIconSize] = 5,
				[Enum.EditModeUnitFrameSetting.BigDefensiveIconSize] = 5,
				[Enum.EditModeUnitFrameSetting.BuffIconSize] = 5,
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

	[Enum.EditModeSystem.Minimap] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.Minimap];

	[Enum.EditModeSystem.EncounterBar] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.EncounterBar];

	[Enum.EditModeSystem.ExtraAbilities] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.ExtraAbilities];

	[Enum.EditModeSystem.AuraFrame] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.AuraFrame];

	[Enum.EditModeSystem.TalkingHeadFrame] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.TalkingHeadFrame];

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

	[Enum.EditModeSystem.VehicleLeaveButton] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.VehicleLeaveButton];

	[Enum.EditModeSystem.LootFrame] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.LootFrame];

	[Enum.EditModeSystem.HudTooltip] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.HudTooltip];

	[Enum.EditModeSystem.ObjectiveTracker] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.ObjectiveTracker];

	[Enum.EditModeSystem.MicroMenu] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.MicroMenu];

	[Enum.EditModeSystem.Bags] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.Bags];

	[Enum.EditModeSystem.StatusTrackingBar] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.StatusTrackingBar];

	[Enum.EditModeSystem.MainActionBarEndCap] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.MainActionBarEndCap];

	[Enum.EditModeSystem.DurabilityFrame] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.DurabilityFrame];

	[Enum.EditModeSystem.TimerBars] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.TimerBars];

	[Enum.EditModeSystem.SwingTimer] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.SwingTimer];

	[Enum.EditModeSystem.VehicleSeatIndicator] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.VehicleSeatIndicator];

	[Enum.EditModeSystem.ArchaeologyBar] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.ArchaeologyBar];

	[Enum.EditModeSystem.TotemActionBar] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.TotemActionBar];

	[Enum.EditModeSystem.CooldownViewer] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.CooldownViewer];

	[Enum.EditModeSystem.PersonalResourceDisplay] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.PersonalResourceDisplay];

	[Enum.EditModeSystem.EncounterEvents] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.EncounterEvents];

	[Enum.EditModeSystem.DamageMeter] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.DamageMeter];

	[Enum.EditModeSystem.RaidWarning] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.RaidWarning];

	[Enum.EditModeSystem.GroupFinder] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.GroupFinder];

	[Enum.EditModeSystem.LossOfControl] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.LossOfControl];
};

EDIT_MODE_GAMEPAD_SYSTEM_MAP =
{
	[Enum.EditModeSystem.ActionBar] = {
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
				offsetY = MAIN_ACTION_BAR_OFFSET_Y,
				bottomBarOffsetX = BOTTOM_ACTION_BAR_DEFAULT_OFFSET_X,
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
				offsetY = MAIN_ACTION_BAR_OFFSET_Y,
				bottomBarOffsetX = BOTTOM_ACTION_BAR_DEFAULT_OFFSET_X,
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
				offsetY = MAIN_ACTION_BAR_OFFSET_Y,
				bottomBarOffsetX = BOTTOM_ACTION_BAR_DEFAULT_OFFSET_X,
			},
		},
	},

	[Enum.EditModeSystem.CastBar] = {
		settings = {
			[Enum.EditModeCastBarSetting.BarSize] = 0,
			[Enum.EditModeCastBarSetting.LockToPlayerFrame] = 0,
			[Enum.EditModeCastBarSetting.ShowCastTime] = 0,
		},
		anchorInfo = {
			point = "BOTTOM",
			relativeTo = "GamepadMainActionBarFrame",
			relativePoint = "TOP",
			offsetX = 0,
			offsetY = 46,
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
				offsetX = -185,
				offsetY = 295,
			},
		},

		[Enum.EditModeUnitFrameSystemIndices.Target] = {
			settings = {
				[Enum.EditModeUnitFrameSetting.BuffsOnTop] = 1,
				[Enum.EditModeUnitFrameSetting.FrameSize] = 0,
			},
			anchorInfo = {
				point = "BOTTOMLEFT",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 185,
				offsetY = 295,
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
				offsetX = 386,
				offsetY = 316,
			},
		},

		[Enum.EditModeUnitFrameSystemIndices.Party] = {
			settings = {
				[Enum.EditModeUnitFrameSetting.UseRaidStylePartyFrames] = 0,
				[Enum.EditModeUnitFrameSetting.ShowPartyFrameBackground] = 0,
				[Enum.EditModeUnitFrameSetting.UseHorizontalGroups] = 0,
				[Enum.EditModeUnitFrameSetting.DisplayBorder] = 0,
				[Enum.EditModeUnitFrameSetting.FrameHeight] = 0,
				[Enum.EditModeUnitFrameSetting.FrameWidth] = 0,
				[Enum.EditModeUnitFrameSetting.FrameSize] = 0,
				[Enum.EditModeUnitFrameSetting.SortPlayersBy] = Enum.SortPlayersBy.Group,
			},
			anchorInfo = {
				point = "TOPLEFT",
				relativeTo = "CompactRaidFrameManager",
				relativePoint = "TOPRIGHT",
				offsetX = 30,
				offsetY = -170,
			},
		},

		[Enum.EditModeUnitFrameSystemIndices.Raid] = {
			settings = {
				[Enum.EditModeUnitFrameSetting.ViewRaidSize] = Enum.ViewRaidSize.Ten,
				[Enum.EditModeUnitFrameSetting.DisplayBorder] = 0,
				[Enum.EditModeUnitFrameSetting.RaidGroupDisplayType] = Enum.RaidGroupDisplayType.SeparateGroupsVertical,
				[Enum.EditModeUnitFrameSetting.SortPlayersBy] = Enum.SortPlayersBy.Role,
				[Enum.EditModeUnitFrameSetting.FrameHeight] = 0,
				[Enum.EditModeUnitFrameSetting.FrameWidth] = 0,
				[Enum.EditModeUnitFrameSetting.RowSize] = 5,
			},
			anchorInfo = {
				point = "TOPLEFT",
				relativeTo = "CompactRaidFrameManager",
				relativePoint = "TOPRIGHT",
				offsetX = 30,
				offsetY = -150,
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
				[Enum.EditModeUnitFrameSetting.FrameHeight] = 0,
				[Enum.EditModeUnitFrameSetting.FrameWidth] = 0,
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
	},

	[Enum.EditModeSystem.TalkingHeadFrame] = {
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
			offsetX = 55,
			offsetY = 90,
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
			bottomBarOffsetX = BOTTOM_ACTION_BAR_DEFAULT_OFFSET_X,
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
			offsetY = 9,
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

	[Enum.EditModeSystem.MainActionBarEndCap] = {
		[Enum.EditModeMainActionBarEndCapSystemIndices.EndCapLeft] = {
			settings = {
				[Enum.EditModeMainActionBarEndCapSetting.Hidden] = 1,
			},
			anchorInfo = {
				point = "RIGHT",
				relativeTo = "MainActionBar",
				relativePoint = "LEFT",
				offsetX = 30,
				offsetY = 5,
			},
		},
		[Enum.EditModeMainActionBarEndCapSystemIndices.EndCapRight] = {
			settings = {
				[Enum.EditModeMainActionBarEndCapSetting.Hidden] = 1,
			},
			anchorInfo = {
				point = "LEFT",
				relativeTo = "BagsBar",
				relativePoint = "RIGHT",
				offsetX = -30,
				offsetY = 5,
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

	[Enum.EditModeSystem.SwingTimer] = {
		[Enum.EditModeSwingTimerSystemIndices.MainHand] = {
			settings = {
				[Enum.EditModeSwingTimerSetting.Scale] = 5,
				[Enum.EditModeSwingTimerSetting.Opacity] = 50,
				[Enum.EditModeSwingTimerSetting.Visibility] = Enum.EditModeSwingTimerVisibility.Always,
				[Enum.EditModeSwingTimerSetting.Width] = 120,
				[Enum.EditModeSwingTimerSetting.Height] = 6,
				[Enum.EditModeSwingTimerSetting.ShowBarTitle] = 1,
				[Enum.EditModeSwingTimerSetting.ShowTime] = 1,
			},
			-- Swing timers are stacked by the bottom managed frame container; these anchors only take effect once a bar is moved out of it.
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = 450,
			},
		},
		[Enum.EditModeSwingTimerSystemIndices.OffHand] = {
			settings = {
				[Enum.EditModeSwingTimerSetting.Scale] = 5,
				[Enum.EditModeSwingTimerSetting.Opacity] = 50,
				[Enum.EditModeSwingTimerSetting.Visibility] = Enum.EditModeSwingTimerVisibility.Always,
				[Enum.EditModeSwingTimerSetting.Width] = 120,
				[Enum.EditModeSwingTimerSetting.Height] = 6,
				[Enum.EditModeSwingTimerSetting.ShowBarTitle] = 1,
				[Enum.EditModeSwingTimerSetting.ShowTime] = 1,
			},
			-- Swing timers are stacked by the bottom managed frame container; these anchors only take effect once a bar is moved out of it.
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = 425,
			},
		},
		[Enum.EditModeSwingTimerSystemIndices.Ranged] = {
			settings = {
				[Enum.EditModeSwingTimerSetting.Scale] = 5,
				[Enum.EditModeSwingTimerSetting.Opacity] = 50,
				[Enum.EditModeSwingTimerSetting.Visibility] = Enum.EditModeSwingTimerVisibility.Always,
				[Enum.EditModeSwingTimerSetting.Width] = 120,
				[Enum.EditModeSwingTimerSetting.Height] = 6,
				[Enum.EditModeSwingTimerSetting.ShowBarTitle] = 1,
				[Enum.EditModeSwingTimerSetting.ShowTime] = 1,
			},
			-- Swing timers are stacked by the bottom managed frame container; these anchors only take effect once a bar is moved out of it.
			anchorInfo = {
				point = "BOTTOM",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = 400,
			},
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

	[Enum.EditModeSystem.GroupFinder] = EDIT_MODE_MODERN_SYSTEM_MAP[Enum.EditModeSystem.GroupFinder];
};
