local WowSurveyConstants =
{
	Tables =
	{
		{
			Name = "SurveyDeliveryMoment",
			Type = "Enumeration",
			NumValues = 5,
			MinValue = 0,
			MaxValue = 4,
			Fields =
			{
				{ Name = "Login", Type = "SurveyDeliveryMoment", EnumValue = 0 },
				{ Name = "ProfessionTable", Type = "SurveyDeliveryMoment", EnumValue = 1 },
				{ Name = "QuestTurnIn", Type = "SurveyDeliveryMoment", EnumValue = 2 },
				{ Name = "ChestLooted", Type = "SurveyDeliveryMoment", EnumValue = 3 },
				{ Name = "MythicPlusCompleted", Type = "SurveyDeliveryMoment", EnumValue = 4 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(WowSurveyConstants);