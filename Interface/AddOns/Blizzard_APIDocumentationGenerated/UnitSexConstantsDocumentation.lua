local UnitSexConstants =
{
	Tables =
	{
		{
			Name = "UnitSex",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Male", Type = "UnitSex", EnumValue = 0 },
				{ Name = "Female", Type = "UnitSex", EnumValue = 1 },
				{ Name = "None", Type = "UnitSex", EnumValue = 2 },
				{ Name = "Both", Type = "UnitSex", EnumValue = 3 },
				{ Name = "Neutral", Type = "UnitSex", EnumValue = 4 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UnitSexConstants);