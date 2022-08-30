local QuestLineInfo =
{
	Name = "QuestLineUI",
	Type = "System",
	Namespace = "C_QuestLine",

	Functions =
	{
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "QuestLineFloorLocation",
			Type = "Enumeration",
			NumValues = 3,
			MinValue = 0,
			MaxValue = 2,
			Fields =
			{
				{ Name = "Above", Type = "QuestLineFloorLocation", EnumValue = 0 },
				{ Name = "Below", Type = "QuestLineFloorLocation", EnumValue = 1 },
				{ Name = "Same", Type = "QuestLineFloorLocation", EnumValue = 2 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(QuestLineInfo);