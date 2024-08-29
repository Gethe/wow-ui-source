local QuestInfoShared =
{
	Tables =
	{
		{
			Name = "QuestClassification",
			Type = "Enumeration",
			NumValues = 11,
			MinValue = 0,
			MaxValue = 10,
			Fields =
			{
				{ Name = "Important", Type = "QuestClassification", EnumValue = 0 },
				{ Name = "Legendary", Type = "QuestClassification", EnumValue = 1 },
				{ Name = "Campaign", Type = "QuestClassification", EnumValue = 2 },
				{ Name = "Calling", Type = "QuestClassification", EnumValue = 3 },
				{ Name = "Meta", Type = "QuestClassification", EnumValue = 4 },
				{ Name = "Recurring", Type = "QuestClassification", EnumValue = 5 },
				{ Name = "Questline", Type = "QuestClassification", EnumValue = 6 },
				{ Name = "Normal", Type = "QuestClassification", EnumValue = 7 },
				{ Name = "BonusObjective", Type = "QuestClassification", EnumValue = 8 },
				{ Name = "Threat", Type = "QuestClassification", EnumValue = 9 },
				{ Name = "WorldQuest", Type = "QuestClassification", EnumValue = 10 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(QuestInfoShared);