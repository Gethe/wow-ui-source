local WowSurveyConstants =
{
	Tables =
	{
		{
			Name = "SurveyDeliveryMoment",
			Type = "Enumeration",
			NumValues = 4,
			MinValue = 0,
			MaxValue = 3,
			Fields =
			{
				{ Name = "Login", Type = "SurveyDeliveryMoment", EnumValue = 0 },
				{ Name = "ProfessionTable", Type = "SurveyDeliveryMoment", EnumValue = 1 },
				{ Name = "QuestTurnIn", Type = "SurveyDeliveryMoment", EnumValue = 2 },
				{ Name = "ChestLooted", Type = "SurveyDeliveryMoment", EnumValue = 3 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(WowSurveyConstants);