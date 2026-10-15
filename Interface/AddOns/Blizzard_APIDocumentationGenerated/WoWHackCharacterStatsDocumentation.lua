local WoWHackCharacterStats =
{
	Name = "WoWHackCharacterStats",
	Type = "System",
	Namespace = "C_WoWHackCharacterStats",
	Environment = "All",

	Functions =
	{
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
	},

	Events =
	{
	},

	Tables =
	{
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(WoWHackCharacterStats);