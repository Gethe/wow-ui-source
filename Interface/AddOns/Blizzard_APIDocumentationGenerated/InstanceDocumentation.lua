local Instance =
{
	Name = "Instance",
	Type = "System",

	Functions =
	{
		{
			Name = "CanChangePlayerDifficulty",
			Type = "Function",

			Returns =
			{
				{ Name = "canChange", Type = "bool", Nilable = false },
				{ Name = "notOnCooldown", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanMapChangeDifficulty",
			Type = "Function",

			Arguments =
			{
				{ Name = "mapID", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "canChange", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "CanShowResetInstances",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetDifficultyInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "difficultyID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "instanceType", Type = "cstring", Nilable = false },
				{ Name = "isHeroic", Type = "bool", Nilable = false },
				{ Name = "isChallengeMode", Type = "bool", Nilable = false },
				{ Name = "displayHeroic", Type = "bool", Nilable = false },
				{ Name = "displayMythic", Type = "bool", Nilable = false },
				{ Name = "toggleDifficultyID", Type = "number", Nilable = true },
				{ Name = "isLFR", Type = "bool", Nilable = false },
				{ Name = "minPlayers", Type = "number", Nilable = true },
				{ Name = "maxPlayers", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetDungeonDifficultyID",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetInstanceBootTimeRemaining",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetInstanceInfo",
			Type = "Function",

			Returns =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "instanceType", Type = "cstring", Nilable = false },
				{ Name = "difficultyID", Type = "number", Nilable = false },
				{ Name = "difficultyName", Type = "cstring", Nilable = false },
				{ Name = "maxPlayers", Type = "number", Nilable = false },
				{ Name = "dynamicDifficulty", Type = "number", Nilable = false },
				{ Name = "isDynamic", Type = "bool", Nilable = true },
				{ Name = "instanceID", Type = "number", Nilable = false },
				{ Name = "instanceGroupSize", Type = "number", Nilable = false },
				{ Name = "lfgDungeonID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetInstanceLockTimeRemaining",
			Type = "Function",

			Returns =
			{
				{ Name = "timeLeft", Type = "number", Nilable = false },
				{ Name = "extending", Type = "bool", Nilable = false },
				{ Name = "encountersTotal", Type = "number", Nilable = false },
				{ Name = "encountersCompleted", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetInstanceLockTimeRemainingEncounter",
			Type = "Function",

			Arguments =
			{
				{ Name = "encounterIndex", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "encounterName", Type = "cstring", Nilable = false },
				{ Name = "texture", Type = "cstring", Nilable = false },
				{ Name = "isKilled", Type = "bool", Nilable = false },
				{ Name = "ineligible", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetLegacyRaidDifficultyID",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetRaidDifficultyID",
			Type = "Function",

			Returns =
			{
				{ Name = "result", Type = "number", Nilable = true },
			},
		},
		{
			Name = "IsInInstance",
			Type = "Function",

			Returns =
			{
				{ Name = "isInInstance", Type = "bool", Nilable = false },
				{ Name = "instanceType", Type = "cstring", Nilable = false },
			},
		},
		{
			Name = "IsLegacyDifficulty",
			Type = "Function",

			Arguments =
			{
				{ Name = "difficultyID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "bool", Nilable = true },
			},
		},
		{
			Name = "ResetInstances",
			Type = "Function",
		},
		{
			Name = "SetDungeonDifficultyID",
			Type = "Function",

			Arguments =
			{
				{ Name = "difficultyID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "SetLegacyRaidDifficultyID",
			Type = "Function",

			Arguments =
			{
				{ Name = "difficultyID", Type = "number", Nilable = false },
				{ Name = "force", Type = "bool", Nilable = false, Default = false },
			},
		},
		{
			Name = "SetRaidDifficultyID",
			Type = "Function",

			Arguments =
			{
				{ Name = "difficultyID", Type = "number", Nilable = false },
				{ Name = "force", Type = "bool", Nilable = false, Default = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "DifficultyInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "instanceType", Type = "cstring", Nilable = false },
				{ Name = "isHeroic", Type = "bool", Nilable = false },
				{ Name = "isChallengeMode", Type = "bool", Nilable = false },
				{ Name = "displayHeroic", Type = "bool", Nilable = false },
				{ Name = "displayMythic", Type = "bool", Nilable = false },
				{ Name = "toggleDifficultyID", Type = "number", Nilable = true },
				{ Name = "isLFR", Type = "bool", Nilable = false },
				{ Name = "minPlayers", Type = "number", Nilable = true },
				{ Name = "maxPlayers", Type = "number", Nilable = true },
			},
		},
		{
			Name = "DungeonEncounterInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "encounterName", Type = "cstring", Nilable = false },
				{ Name = "texture", Type = "cstring", Nilable = false },
				{ Name = "isKilled", Type = "bool", Nilable = false },
				{ Name = "ineligible", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "InstanceInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "instanceType", Type = "cstring", Nilable = false },
				{ Name = "difficultyID", Type = "number", Nilable = false },
				{ Name = "difficultyName", Type = "cstring", Nilable = false },
				{ Name = "maxPlayers", Type = "number", Nilable = false },
				{ Name = "dynamicDifficulty", Type = "number", Nilable = false },
				{ Name = "isDynamic", Type = "bool", Nilable = true },
				{ Name = "instanceID", Type = "number", Nilable = false },
				{ Name = "instanceGroupSize", Type = "number", Nilable = false },
				{ Name = "lfgDungeonID", Type = "number", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Instance);