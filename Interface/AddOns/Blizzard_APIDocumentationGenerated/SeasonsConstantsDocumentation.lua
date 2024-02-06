local SeasonsConstants =
{
	Tables =
	{
		{
			Name = "SeasonID",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "NoSeason", Type = "SeasonID", EnumValue = 0 },
				{ Name = "SeasonOfMastery", Type = "SeasonID", EnumValue = 1 },
				{ Name = "SeasonOfDiscovery", Type = "SeasonID", EnumValue = 2 },
				{ Name = "Hardcore", Type = "SeasonID", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SeasonsConstants);