local modernSystemMap =
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
				offsetY = 25,
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
				relativeTo = "MainMenuBar",
				relativePoint = "TOP",
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
				point = "BOTTOM",
				relativeTo = "MultiBarBottomLeft",
				relativePoint = "TOP",
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
				[Enum.EditModeActionBarSetting.SnapToSide] = 1,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "RIGHT",
				relativeTo = "UIParent",
				relativePoint = "RIGHT",
				offsetX = -55,
				offsetY = -77,
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
				[Enum.EditModeActionBarSetting.SnapToSide] = 1,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "RIGHT",
				relativeTo = "UIParent",
				relativePoint = "RIGHT",
				offsetX = -5,
				offsetY = -77,
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
				[Enum.EditModeUnitFrameSetting.HidePortrait] = 0,
				[Enum.EditModeUnitFrameSetting.CastBarUnderneath] = 0,
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
			},
			anchorInfo = {
				point = "LEFT",
				relativeTo = "TargetFrame",
				relativePoint = "RIGHT",
				offsetX = 10,
				offsetY = 0,
			},
		},
	},

	[Enum.EditModeSystem.Minimap] = {
		settings = {
			[Enum.EditModeMinimapSetting.HeaderUnderneath] = 0,
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
};

local classicSystemMap =
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
				offsetY = 25,
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
				relativeTo = "MainMenuBar",
				relativePoint = "TOP",
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
				point = "BOTTOM",
				relativeTo = "MultiBarBottomLeft",
				relativePoint = "TOP",
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
				[Enum.EditModeActionBarSetting.SnapToSide] = 1,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "RIGHT",
				relativeTo = "MultiBarRight",
				relativePoint = "LEFT",
				offsetX = -5,
				offsetY = 0,
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
				[Enum.EditModeActionBarSetting.SnapToSide] = 1,
				[Enum.EditModeActionBarSetting.AlwaysShowButtons] = 1,
			},
			anchorInfo = {
				point = "RIGHT",
				relativeTo = "UIParent",
				relativePoint = "RIGHT",
				offsetX = -5,
				offsetY = -77,
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
				[Enum.EditModeUnitFrameSetting.HidePortrait] = 0,
				[Enum.EditModeUnitFrameSetting.CastBarUnderneath] = 0,
			},
			anchorInfo = {
				point = "TOPLEFT",
				relativeTo = "UIParent",
				relativePoint = "TOPLEFT",
				offsetX = -19,
				offsetY = -4,
			},
		},

		[Enum.EditModeUnitFrameSystemIndices.Target] = {
			settings = {
				[Enum.EditModeUnitFrameSetting.BuffsOnTop] = 0,
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
			},
			anchorInfo = {
				point = "TOPLEFT",
				relativeTo = "TargetFrame",
				relativePoint = "TOPLEFT",
				offsetX = 250,
				offsetY = -240,
			},
		},
	},

	[Enum.EditModeSystem.Minimap] = {
		settings = {
			[Enum.EditModeMinimapSetting.HeaderUnderneath] = 0,
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
};

local function AddSystem(systems, system, systemIndex, anchorInfo, settings)
	anchorInfo.isDefaultPosition = true;

	table.insert(systems, {
		system = system,
		systemIndex = systemIndex,
		anchorInfo = anchorInfo,
		settings = {},
	});

	local settingsTable = systems[#systems].settings;
	for setting, value in pairs(settings) do
		table.insert(settingsTable, { setting = setting, value = value });
	end
end

local function GetSystems(systemsMap)
	local systems = {};
	for system, systemInfo in pairs(systemsMap) do
		if systemInfo.settings ~= nil then
			-- This system has no systemIndices, just add it
			AddSystem(systems, system, nil, systemInfo.anchorInfo, systemInfo.settings);
		else
			-- This system has systemIndices, so we need to loop through each one and add them one at a time
			for systemIndex, subSystemInfo in pairs(systemInfo) do
				AddSystem(systems, system, systemIndex, subSystemInfo.anchorInfo, subSystemInfo.settings);
			end
		end
	end
	return systems;
end

EditModePresetLayoutManager = {};

EditModePresetLayoutManager.presetLayoutInfo = 
{
	{
		layoutIndex = Enum.EditModePresetLayouts.Modern;
		layoutName = LAYOUT_STYLE_MODERN,
		layoutType = Enum.EditModeLayoutType.Preset,
		systems = GetSystems(modernSystemMap),
	},

	{
		layoutIndex = Enum.EditModePresetLayouts.Classic;
		layoutName = LAYOUT_STYLE_CLASSIC,
		layoutType = Enum.EditModeLayoutType.Preset,
		systems = GetSystems(classicSystemMap),
	},
};

function EditModePresetLayoutManager:GetCopyOfPresetLayouts()
	return CopyTable(self.presetLayoutInfo);
end

function EditModePresetLayoutManager:GetModernSystemMap()
	return modernSystemMap;
end

function EditModePresetLayoutManager:GetModernSystems()
	return self.presetLayoutInfo[1].systems;
end