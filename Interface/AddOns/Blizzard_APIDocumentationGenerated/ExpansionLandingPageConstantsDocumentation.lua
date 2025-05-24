local ExpansionLandingPageConstants =
{
	Tables =
	{
		{
			Name = "ExpansionLandingPageType",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "None", Type = "ExpansionLandingPageType", EnumValue = 0 },
				{ Name = "Dragonflight", Type = "ExpansionLandingPageType", EnumValue = 1 },
				{ Name = "WarWithin", Type = "ExpansionLandingPageType", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ExpansionLandingPageConstants);