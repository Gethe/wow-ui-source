local GameRules =
{
	Name = "GameRules",
	Type = "System",
	Namespace = "C_GameRules",

	Functions =
	{
		{
			Name = "IsHardcoreActive",
			Type = "Function",

			Returns =
			{
				{ Name = "active", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(GameRules);