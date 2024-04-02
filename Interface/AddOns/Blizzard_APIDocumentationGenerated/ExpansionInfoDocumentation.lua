local ExpansionInfo =
{
	Name = "ExpansionInfo",
	Type = "System",

	Functions =
	{
		{
			Name = "ClassicExpansionAtLeast",
			Type = "Function",

			Arguments =
			{
				{ Name = "expansionLevel", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "isAtLeast", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "GetClassicExpansionLevel",
			Type = "Function",

			Returns =
			{
				{ Name = "expansionLevel", Type = "number", Nilable = false },
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

APIDocumentation:AddDocumentationTable(ExpansionInfo);