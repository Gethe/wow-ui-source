local WowSurveyConstants =
{
	Tables =
	{
		{
			Name = "SurveyDeliveryFlags",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "None", Type = "SurveyDeliveryFlags", EnumValue = 0 },
				{ Name = "EncounterSucccessOnly", Type = "SurveyDeliveryFlags", EnumValue = 1 },
			},
		},
		{
			Name = "SurveyDeliveryMoment",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 5,
			Fields =
			{
				{ Name = "Login", Type = "SurveyDeliveryMoment", EnumValue = 0 },
				{ Name = "ProfessionTable", Type = "SurveyDeliveryMoment", EnumValue = 1 },
				{ Name = "QuestTurnIn", Type = "SurveyDeliveryMoment", EnumValue = 2 },
				{ Name = "ChestLooted", Type = "SurveyDeliveryMoment", EnumValue = 3 },
				{ Name = "MythicPlusCompleted", Type = "SurveyDeliveryMoment", EnumValue = 4 },
				{ Name = "EncounterEnd", Type = "SurveyDeliveryMoment", EnumValue = 5 },
			},
		},
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(WowSurveyConstants);