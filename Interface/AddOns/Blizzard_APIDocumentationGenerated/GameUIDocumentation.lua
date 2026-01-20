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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "visible", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetUIVisibility",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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