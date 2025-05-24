local StringUtil =
{
	Name = "StringUtil",
	Type = "System",

	Functions =
	{
		{
			Name = "StripHyperlinks",
			Type = "Function",

			Arguments =
			{
				{ Name = "text", Type = "cstring", Nilable = false },
				{ Name = "maintainColor", Type = "bool", Nilable = false, Default = false },
				{ Name = "maintainBrackets", Type = "bool", Nilable = false, Default = false },
				{ Name = "stripNewlines", Type = "bool", Nilable = false, Default = false },
				{ Name = "maintainAtlases", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "stripped", Type = "string", Nilable = false },
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

APIDocumentation:AddDocumentationTable(StringUtil);