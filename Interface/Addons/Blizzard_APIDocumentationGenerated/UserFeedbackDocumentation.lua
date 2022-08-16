local UserFeedback =
{
	Name = "UserFeedback",
	Type = "System",
	Namespace = "C_UserFeedback",

	Functions =
	{
		{
			Name = "SubmitBug",
			Type = "Function",

			Arguments =
			{
				{ Name = "bugInfo", Type = "string", Nilable = false },
				{ Name = "suppressNotification", Type = "bool", Nilable = false, Default = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "SubmitSuggestion",
			Type = "Function",

			Arguments =
			{
				{ Name = "suggestion", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "success", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(UserFeedback);