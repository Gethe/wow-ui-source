local SeasonsConstants =
{
	Tables =
	{
		{
			Name = "SeasonID",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 12,
			Fields =
			{
				{ Name = "NoSeason", Type = "SeasonID", EnumValue = 0 },
				{ Name = "SeasonOfMastery", Type = "SeasonID", EnumValue = 1 },
				{ Name = "SeasonOfDiscovery", Type = "SeasonID", EnumValue = 2 },
				{ Name = "Hardcore", Type = "SeasonID", EnumValue = 3 },
				{ Name = "Fresh", Type = "SeasonID", EnumValue = 11 },
				{ Name = "FreshHardcore", Type = "SeasonID", EnumValue = 12 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SeasonsConstants);