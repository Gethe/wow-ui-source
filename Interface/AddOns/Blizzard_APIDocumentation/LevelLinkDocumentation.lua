local LevelLink =
{
	Name = "LevelLink",
	Type = "System",
	Namespace = "C_LevelLink",

	Functions =
	{
		{
			Name = "IsActionLocked",
			Type = "Function",

			Arguments =
			{
				{ Name = "actionID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isLocked", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSpellLocked",
			Type = "Function",

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