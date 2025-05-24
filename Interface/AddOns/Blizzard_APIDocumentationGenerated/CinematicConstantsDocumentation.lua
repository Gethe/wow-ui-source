local CinematicConstants =
{
	Tables =
	{
		{
			Name = "CinematicType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "GlueMovie", Type = "CinematicType", EnumValue = 0 },
				{ Name = "GameMovie", Type = "CinematicType", EnumValue = 1 },
				{ Name = "GameClientScene", Type = "CinematicType", EnumValue = 2 },
				{ Name = "GameCinematicSequence", Type = "CinematicType", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(CinematicConstants);