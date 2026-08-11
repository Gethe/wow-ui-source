local SocialQueueSystemStatus =
{
	Name = "SocialQueueSystemStatus",
	Type = "System",
	Namespace = "C_SocialQueue",
	Environment = "All",

	Functions =
	{
		{
			Name = "IsSystemEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isSystemEnabled", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsSystemSupported",
			Type = "Function",

			Returns =
			{
				{ Name = "isSystemSupported", Type = "bool", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "SocialUISocialQueueSystemStatusUpdated",
			Type = "Event",
			LiteralName = "SOCIAL_UI_SOCIAL_QUEUE_SYSTEM_STATUS_UPDATED",
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

APIDocumentation:AddDocumentationTable(SocialQueueSystemStatus);