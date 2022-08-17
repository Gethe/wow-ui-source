local UnitSexConstants =
{
	Tables =
	{
		{
			Name = "UnitSex",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Male", Type = "UnitSex", EnumValue = 0 },
				{ Name = "Female", Type = "UnitSex", EnumValue = 1 },
				{ Name = "None", Type = "UnitSex", EnumValue = 2 },
				{ Name = "Both", Type = "UnitSex", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(UnitSexConstants);