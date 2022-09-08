local LevelSquish =
{
	Name = "LevelSquish",
	Type = "System",
	Namespace = "C_LevelSquish",

	Functions =
	{
		{
			Name = "ConvertFollowerLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "level", Type = "number", Nilable = false },
				{ Name = "maxFollowerLevel", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "squishedLevel", Type = "number", Nilable = false },
			},
		},
		{
			Name = "ConvertPlayerLevel",
			Type = "Function",

			Arguments =
			{
				{ Name = "level", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "squishedLevel", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(LevelSquish);