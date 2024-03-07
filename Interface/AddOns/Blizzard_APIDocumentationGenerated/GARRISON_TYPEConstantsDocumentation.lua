local GARRISON_TYPEConstants =
{
	Tables =
	{
		{
			Name = "GarrisonType",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 2,
			MaxValue = 111,
			Fields =
			{
				{ Name = "Type_6_0_Garrison", Type = "GarrisonType", EnumValue = 2 },
				{ Name = "Type_7_0_Garrison", Type = "GarrisonType", EnumValue = 3 },
				{ Name = "Type_8_0_Garrison", Type = "GarrisonType", EnumValue = 9 },
				{ Name = "Type_9_0_Garrison", Type = "GarrisonType", EnumValue = 111 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(GARRISON_TYPEConstants);