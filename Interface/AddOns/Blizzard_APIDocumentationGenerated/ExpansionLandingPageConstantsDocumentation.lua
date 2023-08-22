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
				{ Name = "Dragonflight", Type = "ExpansionLandingPageType", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(ExpansionLandingPageConstants);