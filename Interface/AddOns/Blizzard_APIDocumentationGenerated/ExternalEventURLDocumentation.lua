local ExternalEventURL =
{
	Name = "ExternalEventURL",
	Type = "System",
	Namespace = "C_ExternalEventURL",
	Environment = "All",

	Functions =
	{
		{
			Name = "CanShow",
			Type = "Function",

			Returns =
			{
				{ Name = "canShow", Type = "bool", Nilable = false },
			},
		},
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
			Name = "ExternalEventLaunchUrlResult",
			Type = "Event",
			LiteralName = "EXTERNAL_EVENT_LAUNCH_URL_RESULT",
			SynchronousEvent = true,
			Payload =
			{
				{ Name = "result", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "ExternalEventUrlChanged",
			Type = "Event",
			LiteralName = "EXTERNAL_EVENT_URL_CHANGED",
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