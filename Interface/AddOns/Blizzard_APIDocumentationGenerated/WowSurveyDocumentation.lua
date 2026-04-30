local WowSurvey =
{
	Name = "WowSurvey",
	Type = "System",
	Namespace = "C_WowSurvey",
	Environment = "All",

	Functions =
	{
		{
			Name = "OpenSurvey",
			Type = "Function",
			HasRestrictions = true,
		},
		{
			Name = "TriggerSurveyServe",
			Type = "Function",

			Arguments =
			{
				{ Name = "deliveryMoment", Type = "SurveyDeliveryMoment", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "SurveyDelivered",
			Type = "Event",
			LiteralName = "SURVEY_DELIVERED",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(WowSurvey);