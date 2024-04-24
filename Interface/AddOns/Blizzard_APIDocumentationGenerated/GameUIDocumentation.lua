local GameUI =
{
	Name = "GameUI",
	Type = "System",

	Functions =
	{
		{
			Name = "SetInWorldUIVisibility",
			Type = "Function",

			Arguments =
			{
				{ Name = "visible", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetUIVisibility",
			Type = "Function",

			Arguments =
			{
				{ Name = "visible", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(GameUI);