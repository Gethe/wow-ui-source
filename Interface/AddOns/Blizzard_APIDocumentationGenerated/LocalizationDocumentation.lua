local Localization =
{
	Name = "Localization",
	Type = "System",
	Environment = "All",

	Functions =
	{
		{
			Name = "AbbreviateLargeNumbers",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "number", Type = "number", Nilable = false },
				{ Name = "options", Type = "NumberAbbrevOptions", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false },
			},
		},
		{
			Name = "AbbreviateNumbers",
			Type = "Function",
			SecretArguments = "AllowedWhenTainted",

			Arguments =
			{
				{ Name = "number", Type = "number", Nilable = false },
				{ Name = "options", Type = "NumberAbbrevOptions", Nilable = true },
			},

			Returns =
			{
				{ Name = "result", Type = "string", Nilable = false },
			},
		},
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
			Name = "CreateAbbreviateConfig",
			Type = "Function",
			SecretArguments = "NotAllowed",

			Arguments =
			{
				{ Name = "data", Type = "table", InnerType = "NumberAbbrevData", Nilable = false },
			},

			Returns =
			{
				{ Name = "config", Type = "AbbreviateConfig", Nilable = false },
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
		{
			Name = "NumberAbbrevOptions",
			Type = "Structure",
			Fields =
			{
				{ Name = "breakpointData", Type = "table", InnerType = "NumberAbbrevData", Nilable = true, Documentation = { "Order these from largest to smallest." } },
				{ Name = "locale", Type = "cstring", Nilable = true, Documentation = { "Locale controls whether standard asian abbreviation data will be used along with a small change in behavior for large number abbreviation when fractionDivisor is greater than zero." } },
				{ Name = "config", Type = "AbbreviateConfig", Nilable = true, Documentation = { "Provides a cached config object for optimal performance when calling abbreviation functions multiple times with the same options." } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Localization);