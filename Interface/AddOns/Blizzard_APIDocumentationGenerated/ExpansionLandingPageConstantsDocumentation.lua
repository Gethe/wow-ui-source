local ExpansionLandingPageConstants =
{
	Tables =
	{
		{
			Name = "ExpansionLandingPageType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "None", Type = "ExpansionLandingPageType", EnumValue = 0 },
				{ Name = "Midnight", Type = "ExpansionLandingPageType", EnumValue = 1 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(ExpansionLandingPageConstants);