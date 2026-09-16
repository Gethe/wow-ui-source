local TrainerConstants =
{
	Tables =
	{
		{
			Name = "TrainerType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "General", Type = "TrainerType", EnumValue = 0 },
				{ Name = "TalentsObsolete", Type = "TrainerType", EnumValue = 1 },
				{ Name = "Tradeskills", Type = "TrainerType", EnumValue = 2 },
				{ Name = "Pet", Type = "TrainerType", EnumValue = 3 },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(TrainerConstants);