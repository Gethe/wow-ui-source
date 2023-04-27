local SeasonsConstants =
{
	Tables =
	{
		{
			Name = "SeasonID",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "NoSeason", Type = "SeasonID", EnumValue = 0 },
				{ Name = "SeasonOfMastery", Type = "SeasonID", EnumValue = 1 },
				{ Name = "Placeholder", Type = "SeasonID", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SeasonsConstants);