local LocalizationShared =
{
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
				{ Name = "abbreviationIsGlobal", Type = "bool", Nilable = false, Default = true, Documentation = { "Defaults to true. Set to false to skip the global string lookup and use the raw abbreviation string when formatting results" } },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(LocalizationShared);