local WowSurveyConstants =
{
	Tables =
	{
		{
			Name = "SurveyDeliveryFlags",
			Type = "Enumeration",
			NumValues = 6,
			MinValue = 0,
			MaxValue = 16,
			Fields =
			{
				{ Name = "None", Type = "SurveyDeliveryFlags", EnumValue = 0 },
				{ Name = "EncounterSucccessOnly", Type = "SurveyDeliveryFlags", EnumValue = 1 },
				{ Name = "PvPRatedOnly", Type = "SurveyDeliveryFlags", EnumValue = 2 },
				{ Name = "PvPUnratedOnly", Type = "SurveyDeliveryFlags", EnumValue = 4 },
				{ Name = "PvPWinOnly", Type = "SurveyDeliveryFlags", EnumValue = 8 },
				{ Name = "PvPLossOnly", Type = "SurveyDeliveryFlags", EnumValue = 16 },
			},
		},
		{
			Name = "SurveyDeliveryMoment",
			Type = "Enumeration",
			NumValues = 8,
			MinValue = 0,
			MaxValue = 7,
			Fields =
			{
				{ Name = "Login", Type = "SurveyDeliveryMoment", EnumValue = 0 },
				{ Name = "ProfessionTable", Type = "SurveyDeliveryMoment", EnumValue = 1 },
				{ Name = "QuestTurnIn", Type = "SurveyDeliveryMoment", EnumValue = 2 },
				{ Name = "ChestLooted", Type = "SurveyDeliveryMoment", EnumValue = 3 },
				{ Name = "MythicPlusCompleted", Type = "SurveyDeliveryMoment", EnumValue = 4 },
				{ Name = "EncounterEnd", Type = "SurveyDeliveryMoment", EnumValue = 5 },
				{ Name = "AchievementCompleted", Type = "SurveyDeliveryMoment", EnumValue = 6 },
				{ Name = "BattlegroundEnd", Type = "SurveyDeliveryMoment", EnumValue = 7 },
			},
		},
	},

	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(WowSurveyConstants);