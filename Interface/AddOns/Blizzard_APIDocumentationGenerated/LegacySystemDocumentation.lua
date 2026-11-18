local LegacySystem =
{
	Name = "LegacySystemUI",
	Type = "System",
	Namespace = "C_LegacySystem",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetCurrentLegacyPoints",
			Type = "Function",

			Returns =
			{
				{ Name = "level", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetLegacyRewardTrackData",
			Type = "Function",

			Returns =
			{
				{ Name = "data", Type = "LegacyRewardTrackData", Nilable = false },
			},
		},
		{
			Name = "GetLegacyRewardTrackLevels",
			Type = "Function",

			Returns =
			{
				{ Name = "levels", Type = "table", InnerType = "LegacyRewardTrackLevelInfo", Nilable = false },
			},
		},
		{
			Name = "GetLegacyRewardTrackRewardsForLevel",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "level", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "rewards", Type = "table", InnerType = "LegacyRewardTrackRewardInfo", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "LegacyRewardTrackData",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "renownLevel", Type = "number", Nilable = false },
				{ Name = "maxLevel", Type = "number", Nilable = false },
				{ Name = "textureKit", Type = "textureKit", Nilable = false },
				{ Name = "factionFontColor", Type = "DBColorExport", Nilable = true },
			},
		},
		{
			Name = "LegacyRewardTrackLevelInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "locked", Type = "bool", Nilable = false },
				{ Name = "isMilestone", Type = "bool", Nilable = false },
				{ Name = "isCapstone", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LegacyRewardTrackRewardInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "itemID", Type = "number", Nilable = true },
				{ Name = "icon", Type = "fileID", Nilable = true },
				{ Name = "name", Type = "cstring", Nilable = true },
				{ Name = "description", Type = "cstring", Nilable = true },
				{ Name = "rewardType", Type = "number", Nilable = true },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(LegacySystem);