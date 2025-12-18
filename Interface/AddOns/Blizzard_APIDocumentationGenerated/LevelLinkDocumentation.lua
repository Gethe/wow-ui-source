local LevelLink =
{
	Name = "LevelLink",
	Type = "System",
	Namespace = "C_LevelLink",
	Environment = "All",

	Functions =
	{
		{
			Name = "IsActionLocked",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "actionID", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "isLocked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSpellLocked",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "spellID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isLocked", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(LevelLink);