local Localization =
{
	Name = "Localization",
	Type = "System",

	Functions =
	{
		{
			Name = "DeclineName",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "gender", Type = "number", Nilable = true },
				{ Name = "declensionSet", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "declinedNames", Type = "string", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "GetNumDeclensionSets",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "gender", Type = "number", Nilable = true },
			},

			Returns =
			{
				{ Name = "numDeclensionSets", Type = "number", Nilable = false },
			},
		},
		{
			Name = "IsEuropeanNumbers",
			Type = "Function",

			Returns =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SetEuropeanNumbers",
			Type = "Function",

			Arguments =
			{
				{ Name = "enabled", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(Localization);