local SeasonsConstants =
{
	Tables =
	{
		{
			Name = "SeasonID",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "NoSeason", Type = "SeasonID", EnumValue = 0 },
				{ Name = "SeasonOfMastery", Type = "SeasonID", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(SeasonsConstants);