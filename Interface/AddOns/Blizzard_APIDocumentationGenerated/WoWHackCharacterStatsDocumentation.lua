local WoWHackCharacterStats =
{
	Name = "WoWHackCharacterStats",
	Type = "System",
	Namespace = "C_WoWHackCharacterStats",
	Environment = "All",

	Functions =
	{
		{
			Name = "AddPendingStatPointsFromConfig",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",
			Documentation = { "Call right after C_Traits.CommitConfig succeeds. Predicts stat point increases from the config's staged purchases until the server updates the stat auras." },

			Arguments =
			{
				{ Name = "configID", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ClearPendingStatPoints",
			Type = "Function",
			Documentation = { "Discards predicted stat point increases, e.g. when a trait commit fails." },
		},
		{
			Name = "GetStatPointsBySpellID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "estimatedPoints", Type = "number", Nilable = false },
			},
		},
		{
			Name = "GetStatPointsChangeBySpellID",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "statSpellID", Type = "number", Nilable = false },
				{ Name = "increaseSpellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "estimatedPointsChange", Type = "number", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "WoWHackStatPointsChanged",
			Type = "Event",
			LiteralName = "WOW_HACK_STAT_POINTS_CHANGED",
			UniqueEvent = true,
			Documentation = { "Fires when the points on a WoWHack stat aura change. These auras are hidden from UNIT_AURA." },
		},
	},

	Tables =
	{
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(WoWHackCharacterStats);