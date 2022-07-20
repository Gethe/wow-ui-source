local modernSystemMap =
{
	[Enum.EditModeSystem.CastBar] = {
		settings = {
			[Enum.EditModeCastBarSetting.BarSize] = Enum.CastBarSize.Small,
		},
		anchorInfo = {
			point = "CENTER",
			relativeTo = "UIParent",
			relativePoint = "CENTER",
			offsetX = 0,
			offsetY = 100,
		},
	},

	[Enum.EditModeSystem.ActionBar] = {
		[1] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 3,
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

		[2] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 3,
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

		[3] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Horizontal,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 3,
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

		[4] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Vertical,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 3,
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

		[5] = {
			settings = {
				[Enum.EditModeActionBarSetting.Orientation] = Enum.ActionBarOrientation.Vertical,
				[Enum.EditModeActionBarSetting.NumRows] = 1,
				[Enum.EditModeActionBarSetting.NumIcons] = 12,
				[Enum.EditModeActionBarSetting.IconSize] = 5,
				[Enum.EditModeActionBarSetting.IconPadding] = 3,
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
	},
};

local function AddSystem(systems, system, systemIndex, anchorInfo, settings)
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

	-- TODO: Update to new settings once we decide on them. For now this is a dupe of the Modern preset
	{
		layoutIndex = Enum.EditModePresetLayouts.Classic;
		layoutName = LAYOUT_STYLE_CLASSIC,
		layoutType = Enum.EditModeLayoutType.Preset,
		systems = GetSystems(modernSystemMap),
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