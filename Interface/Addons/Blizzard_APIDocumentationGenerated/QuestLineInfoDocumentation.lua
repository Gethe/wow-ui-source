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
		{
			Name = "QuestLineInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "questLineName", Type = "cstring", Nilable = false },
				{ Name = "questName", Type = "cstring", Nilable = false },
				{ Name = "questLineID", Type = "number", Nilable = false },
				{ Name = "questID", Type = "number", Nilable = false },
				{ Name = "x", Type = "number", Nilable = false },
				{ Name = "y", Type = "number", Nilable = false },
				{ Name = "isHidden", Type = "bool", Nilable = false },
				{ Name = "isLegendary", Type = "bool", Nilable = false },
				{ Name = "floorLocation", Type = "QuestLineFloorLocation", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(QuestLineInfo);