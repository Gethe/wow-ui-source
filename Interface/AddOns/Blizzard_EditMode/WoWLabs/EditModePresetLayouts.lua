MAIN_ACTION_BAR_DEFAULT_OFFSET_Y = 60;
RIGHT_ACTION_BAR_DEFAULT_OFFSET_X = -5;
RIGHT_ACTION_BAR_DEFAULT_OFFSET_Y = -77;

local MainBarOffsetX = -249;
local Bar2OffsetX = -84;
local Bar3OffsetX = 52;

local function GetMainMenuBar() 
	return "MainMenuBar";
end

EDIT_MODE_MODERN_SYSTEM_MAP =
{
	[Enum.EditModeSystem.ActionBar] = {
		[Enum.EditModeActionBarSystemIndices.MainBar] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 2,
				[Enum.EditModeActionBarSetting.IconSize] = 9,
				[Enum.EditModeActionBarSetting.IconPadding] = 3,
				[Enum.EditModeActionBarSetting.HideBarArt] = 1,
				[Enum.EditModeActionBarSetting.HideBarScrolling] = 1,
			},
			anchorInfo = {
				point = "BOTTOMLEFT",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = MainBarOffsetX,
				offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
			},
		},

		[Enum.EditModeActionBarSystemIndices.Bar2] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 2,
				[Enum.EditModeActionBarSetting.IconSize] = 9,
				[Enum.EditModeActionBarSetting.IconPadding] = 3,
				[Enum.EditModeActionBarSetting.VisibleSetting] = Enum.ActionBarVisibleSetting.Always,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "BOTTOMLEFT",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = Bar2OffsetX,
				offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
			},
		},

		[Enum.EditModeActionBarSystemIndices.Bar3] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 2,
				[Enum.EditModeActionBarSetting.IconSize] = 9,
				[Enum.EditModeActionBarSetting.IconPadding] = 3,
				[Enum.EditModeActionBarSetting.VisibleSetting] = Enum.ActionBarVisibleSetting.Always,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "BOTTOMLEFT",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = Bar3OffsetX,
				offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
			},
		},

		[Enum.EditModeActionBarSystemIndices.RightBar1] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Vertical,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 3,
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
				point = "TOPRIGHT",
				relativeTo = "MultiBarRight",
				relativePoint = "TOPLEFT",
				offsetX = -5,
				offsetY = 0,
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
				relativeTo = "MultiBar5",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = 0,
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
				relativeTo = "MultiBar6",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = 0,
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
				point = "BOTTOMLEFT",
				relativeTo = "MainMenuBar",
				relativePoint = "TOPLEFT",
				offsetX = 0,
				offsetY = 5,
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
				point = "BOTTOMLEFT",
				relativeTo = "MainMenuBar",
				relativePoint = "TOPLEFT",
				offsetX = 0,
				offsetY = 5,
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
				point = "BOTTOMLEFT",
				relativeTo = "MainMenuBar",
				relativePoint = "TOPLEFT",
				offsetX = 0,
				offsetY = 5,
			},
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

	-- Note: The anchorInfo here doesn't actually get applied because cast bar is a bottom managed frame
	-- We still need to include it though, and if the player moves the cast bar it is updated and used
	[Enum.EditModeSystem.CastBar] = {
		settings = {
			[Enum.EditModeCastBarSetting.BarSize] = 0,
			[Enum.EditModeCastBarSetting.LockToPlayerFrame] = 0,
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
				point = "LEFT",
				relativeTo = "TargetFrame",
				relativePoint = "RIGHT",
				offsetX = -10,
				offsetY = 0,
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
				[Enum.EditModeUnitFrameSetting.FrameHeight] = 0,
				[Enum.EditModeUnitFrameSetting.FrameWidth] = 0,
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
	},

	[Enum.EditModeSystem.Minimap] = {
		settings = {
			[Enum.EditModeMinimapSetting.HeaderUnderneath] = 0,
			[Enum.EditModeMinimapSetting.RotateMinimap] = 0,
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
			relativeTo = "MainMenuBar",
			relativePoint = "TOP",
			offsetX = 0,
			offsetY = 5,
		},
	},

	[Enum.EditModeSystem.ExtraAbilities] = {
		settings = {
		},
		anchorInfo = {
			point = "BOTTOMLEFT",
			relativeTo = "MainMenuBar",
			relativePoint = "TOPLEFT",
			offsetX = 0,
			offsetY = 5,
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
				relativeTo = "MinimapCluster",
				relativePoint = "TOPLEFT",
				offsetX = -10,
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
				relativeTo = "BuffFrame",
				relativePoint = "BOTTOMRIGHT",
				offsetX = -13,
				offsetY = -15,
			},
		},
	},

	[Enum.EditModeSystem.TalkingHeadFrame] = {
		settings = {
		},
		anchorInfo = {
			point = "BOTTOMLEFT",
			relativeTo = "ChatFrame1Tab",
			relativePoint = "TOPLEFT",
			offsetX = 20,
			offsetY = 150,
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
			offsetY = 50,
		},
	},

	[Enum.EditModeSystem.VehicleLeaveButton] = {
		settings = {
		},
		anchorInfo = {
			point = "BOTTOMLEFT",
			relativeTo = "PlayerFrame",
			relativePoint = "TOPRIGHT",
			offsetX = -55,
			offsetY = -16,
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
			[Enum.EditModeMicroMenuSetting.Size] = 0,
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
			offsetY = 0,
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
				offsetY = 20,
			},
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
				point = "BOTTOMLEFT",
				relativeTo = "MainMenuBar",
				relativePoint = "TOPLEFT",
				offsetX = 0,
				offsetY = 5,
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
				point = "BOTTOMLEFT",
				relativeTo = "MultiBarBottomLeft",
				relativePoint = "TOPLEFT",
				offsetX = 0,
				offsetY = 5,
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
				point = "TOPRIGHT",
				relativeTo = "MultiBarRight",
				relativePoint = "TOPLEFT",
				offsetX = -5,
				offsetY = 0,
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
				relativeTo = "MultiBar5",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = 0,
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
				relativeTo = "MultiBar6",
				relativePoint = "BOTTOM",
				offsetX = 0,
				offsetY = 0,
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
				point = "BOTTOMLEFT",
				relativeTo = "MainMenuBar",
				relativePoint = "TOPLEFT",
				offsetX = 0,
				offsetY = 5,
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
				point = "BOTTOMLEFT",
				relativeTo = "MainMenuBar",
				relativePoint = "TOPLEFT",
				offsetX = 0,
				offsetY = 5,
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
				point = "BOTTOMLEFT",
				relativeTo = "MainMenuBar",
				relativePoint = "TOPLEFT",
				offsetX = 0,
				offsetY = 5,
			},
		},
	},

	-- Note: The anchorInfo here doesn't actually get applied because cast bar is a bottom managed frame
	-- We still need to include it though, and if the player moves the cast bar it is updated and used
	[Enum.EditModeSystem.CastBar] = {
		settings = {
			[Enum.EditModeCastBarSetting.BarSize] = 0,
			[Enum.EditModeCastBarSetting.LockToPlayerFrame] = 0,
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
				relativeTo = "TargetFrame",
				relativePoint = "TOPLEFT",
				offsetX = 250,
				offsetY = -240,
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
				[Enum.EditModeUnitFrameSetting.FrameHeight] = 0,
				[Enum.EditModeUnitFrameSetting.FrameWidth] = 0,
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
	},

	[Enum.EditModeSystem.Minimap] = {
		settings = {
			[Enum.EditModeMinimapSetting.HeaderUnderneath] = 0,
			[Enum.EditModeMinimapSetting.RotateMinimap] = 0,
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
			relativeTo = "MainMenuBar",
			relativePoint = "TOP",
			offsetX = 0,
			offsetY = 5,
		},
	},

	[Enum.EditModeSystem.ExtraAbilities] = {
		settings = {
		},
		anchorInfo = {
			point = "BOTTOMLEFT",
			relativeTo = "MainMenuBar",
			relativePoint = "TOPLEFT",
			offsetX = 0,
			offsetY = 5,
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
				relativeTo = "MinimapCluster",
				relativePoint = "TOPLEFT",
				offsetX = -10,
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
				relativeTo = "BuffFrame",
				relativePoint = "BOTTOMRIGHT",
				offsetX = -13,
				offsetY = -15,
			},
		},
	},

	[Enum.EditModeSystem.TalkingHeadFrame] = {
		settings = {
		},
		anchorInfo = {
			point = "BOTTOMLEFT",
			relativeTo = "ChatFrame1Tab",
			relativePoint = "TOPLEFT",
			offsetX = 20,
			offsetY = 150,
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
			offsetY = 50,
		},
	},

	[Enum.EditModeSystem.VehicleLeaveButton] = {
		settings = {
		},
		anchorInfo = {
			point = "BOTTOMLEFT",
			relativeTo = "MainMenuBar",
			relativePoint = "TOPLEFT",
			offsetX = 0,
			offsetY = 5,
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
			[Enum.EditModeMicroMenuSetting.Size] = 0,
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
			offsetY = 0,
		},
	},
};

local spectateModeSystemMap =
{
	[Enum.EditModeSystem.ActionBar] = {
		[Enum.EditModeActionBarSystemIndices.MainBar] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 2,
				[Enum.EditModeActionBarSetting.IconSize] = 9,
				[Enum.EditModeActionBarSetting.IconPadding] = 3,
				[Enum.EditModeActionBarSetting.HideBarArt] = 1,
				[Enum.EditModeActionBarSetting.HideBarScrolling] = 1,
			},
			anchorInfo = {
				point = "BOTTOMLEFT",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = MainBarOffsetX,
				offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
			},
		},

		[Enum.EditModeActionBarSystemIndices.Bar2] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 2,
				[Enum.EditModeActionBarSetting.IconSize] = 9,
				[Enum.EditModeActionBarSetting.IconPadding] = 3,
				[Enum.EditModeActionBarSetting.VisibleSetting] = Enum.ActionBarVisibleSetting.Always,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "BOTTOMLEFT",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = Bar2OffsetX,
				offsetY = MAIN_ACTION_BAR_DEFAULT_OFFSET_Y,
			},
		},

		[Enum.EditModeActionBarSystemIndices.Bar3] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 2,
				[Enum.EditModeActionBarSetting.IconSize] = 9,
				[Enum.EditModeActionBarSetting.IconPadding] = 3,
				[Enum.EditModeActionBarSetting.VisibleSetting] = Enum.ActionBarVisibleSetting.Always,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "BOTTOMLEFT",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = Bar3OffsetX,
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
		[Enum.EditModeUnitFrameSystemIndices.Target] = {
			settings = {
				[Enum.EditModeUnitFrameSetting.BuffsOnTop] = 0,
				[Enum.EditModeUnitFrameSetting.FrameSize] = 3,
			},
			anchorInfo = {
				point = "BOTTOMRIGHT",
				relativeTo = "UIParent",
				relativePoint = "BOTTOM",
				offsetX = -300,
				offsetY = 250,
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
				[Enum.EditModeUnitFrameSetting.FrameHeight] = 0,
				[Enum.EditModeUnitFrameSetting.FrameWidth] = 0,
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

	},

	[Enum.EditModeSystem.Minimap] = {
		settings = {
			[Enum.EditModeMinimapSetting.HeaderUnderneath] = 0,
			[Enum.EditModeMinimapSetting.RotateMinimap] = 0,
		},
		anchorInfo = {
			point = "TOPRIGHT",
			relativeTo = "UIParent",
			relativePoint = "TOPRIGHT",
			offsetX = 0,
			offsetY = 0,
		},
	},

	[Enum.EditModeSystem.MicroMenu] = {
		settings = {
			[Enum.EditModeMicroMenuSetting.Orientation] = Enum.MicroMenuOrientation.Horizontal,
			[Enum.EditModeMicroMenuSetting.Order] = Enum.MicroMenuOrder.Default,
			[Enum.EditModeMicroMenuSetting.Size] = 0,
		},
		anchorInfo = {
			point = "BOTTOMRIGHT",
			relativeTo = "MicroButtonAndBagsBar",
			relativePoint = "BOTTOMRIGHT",
			offsetX = 0,
			offsetY = 0,
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

	[Enum.EditModeSystem.EncounterBar] = {
		settings = {
		},
		anchorInfo = {
			point = "BOTTOM",
			relativeTo = "MainMenuBar",
			relativePoint = "TOP",
			offsetX = 0,
			offsetY = 5,
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
			offsetY = 50,
		},
	},
};

EDIT_MODE_OVERRIDE_LAYOUTS = {
	{
		layoutIndex = 1;
		layoutName = "",
		layoutType = Enum.EditModeLayoutType.Override,
		systems = EditModeSystemUtil.GetSystems(spectateModeSystemMap),
	},
}

EDIT_MODE_OVERRIDE_LAYOUT_MAP = 
{
	[1] = spectateModeSystemMap; 
}