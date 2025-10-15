local Localization =
{
	Name = "Localization",
	Type = "System",

	Functions =
	{
		{
			Name = "BreakUpLargeNumbers",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "gender", Type = "UnitSex", Nilable = true },
				{ Name = "declensionSet", Type = "luaIndex", Nilable = false },
			},

			Returns =
			{
				{ Name = "declinedNames", Type = "string", Nilable = false, StrideIndex = 1 },
			},
		},
		{
			Name = "FloorToNearestString",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "number", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false },
			},
		},
		{
			Name = "GetNumDeclensionSets",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "name", Type = "cstring", Nilable = false },
				{ Name = "gender", Type = "UnitSex", Nilable = true },
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
			SecretArguments = "AllowedWhenUntainted",

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
			Name = "RoundToNearestString",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "number", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false },
			},
		},
		{
			Name = "SetEuropeanNumbers",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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