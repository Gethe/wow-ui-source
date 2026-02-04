local RaidLocks =
{
	Name = "RaidLocks",
	Type = "System",
	Namespace = "C_RaidLocks",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetRedirectedDifficultyID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "difficultyID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "redirectedDifficultyID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsEncounterComplete",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = false },
				{ Name = "encounterID", Type = "number", Nilable = false },
				{ Name = "difficultyID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "encounterIsComplete", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsRaidLockExtendFeatureEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "raidLockExtendFeatureEnabled", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(RaidLocks);