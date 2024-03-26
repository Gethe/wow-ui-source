local WorldLootObject =
{
	Name = "WorldLootObject",
	Type = "System",
	Namespace = "C_WorldLootObject",

	Functions =
	{
		{
			Name = "IsWorldLootObject",
			Type = "Function",

			Arguments =
			{
				{ Name = "nameplateString", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "isWorldLootObject", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "OnWorldLootObjectClick",
			Type = "Function",

			Arguments =
			{
				{ Name = "nameplateString", Type = "cstring", Nilable = false },
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

APIDocumentation:AddDocumentationTable(WorldLootObject);