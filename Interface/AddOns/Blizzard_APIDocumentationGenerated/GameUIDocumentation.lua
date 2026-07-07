local GameUI =
{
	Name = "GameUI",
	Type = "System",
	Environment = "All",

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
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(GameUI);