local Localization =
{
	Name = "Localization",
	Type = "System",

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
		{
			Name = "NumberAbbrevData",
			Type = "Structure",
			Fields =
			{
				{ Name = "breakpoint", Type = "number", Nilable = false, Documentation = { "Breakpoints should generally be specified as pairs, with one at the named order (1,000) with fractionDivisor = 10, and one a single order higher (eg. 10,000) with fractionDivisor = 1., This ruleset means numbers like '1234' will be abbreviated to '1.2k' and numbers like '12345' to '12k'." } },
				{ Name = "abbreviation", Type = "cstring", Nilable = false, Documentation = { "Abbreviation name to be looked up as a global string." } },
				{ Name = "significandDivisor", Type = "number", Nilable = false, Documentation = { "significandDivisor and fractionDivisor should multiply such that they become equal to a named order of magnitude, such as thousands or  millions." } },
				{ Name = "fractionDivisor", Type = "number", Nilable = false },
			},
		},
		{
			Name = "NumberAbbrevOptions",
			Type = "Structure",
			Fields =
			{
				{ Name = "breakpointData", Type = "table", InnerType = "NumberAbbrevData", Nilable = true, Documentation = { "Order these from largest to smallest." } },
				{ Name = "locale", Type = "cstring", Nilable = true, Documentation = { "Locale controls whether standard asian abbreviation data will be used along with a small change in behavior for large number abbreviation when fractionDivisor is greater than zero." } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Localization);