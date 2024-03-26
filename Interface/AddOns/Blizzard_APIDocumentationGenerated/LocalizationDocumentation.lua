local Localization =
{
	Name = "Localization",
	Type = "System",

	Functions =
	{
		{
			Name = "BreakUpLargeNumbers",
			Type = "Function",

			Arguments =
			{
				{ Name = "largeNumber", Type = "number", Nilable = false },
				{ Name = "natural", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false },
			},
		},
		{
			Name = "CaseAccentInsensitiveParse",
			Type = "Function",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false },
			},
		},
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
			Name = "LocalizedClassList",
			Type = "Function",

			Arguments =
			{
				{ Name = "isFemale", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "result", Type = "LuaValueVariant", Nilable = false },
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