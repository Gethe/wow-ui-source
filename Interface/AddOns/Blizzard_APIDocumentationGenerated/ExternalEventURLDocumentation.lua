local ExternalEventURL =
{
	Name = "ExternalEventURL",
	Type = "System",
	Namespace = "C_ExternalEventURL",
	Environment = "All",

	Functions =
	{
		{
			Name = "HasURL",
			Type = "Function",

			Returns =
			{
				{ Name = "hasURL", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsNew",
			Type = "Function",

			Returns =
			{
				{ Name = "isNew", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "LaunchURL",
			Type = "Function",
			HasRestrictions = true,
		},
	},

	Events =
	{
		{
			Name = "ExternalEventLaunchUrlFailed",
			Type = "Event",
			LiteralName = "EXTERNAL_EVENT_LAUNCH_URL_FAILED",
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

APIDocumentation:AddDocumentationTable(ExternalEventURL);