local GameUI =
{
	Name = "GameUI",
	Type = "System",

	Functions =
	{
		{
			Name = "GetLevelUpInstances",
			Type = "Function",

			Arguments =
			{
				{ Name = "currPlayerLevel", Type = "number", Nilable = false },
				{ Name = "isRaid", Type = "bool", Nilable = false },
			},

			Returns =
			{
				{ Name = "instances", Type = "table", InnerType = "number", Nilable = false },
			},
		},
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