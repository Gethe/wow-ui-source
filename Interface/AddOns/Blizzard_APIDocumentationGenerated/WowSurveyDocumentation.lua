local WowSurvey =
{
	Name = "WowSurvey",
	Type = "System",
	Namespace = "C_WowSurvey",

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
			SecretArguments = "AllowedWhenUntainted",

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
};

APIDocumentation:AddDocumentationTable(WowSurvey);