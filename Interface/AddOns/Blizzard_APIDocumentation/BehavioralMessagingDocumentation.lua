local BehavioralMessaging =
{
	Name = "BehavioralMessaging",
	Type = "System",
	Namespace = "C_BehavioralMessaging",

	Functions =
	{
		{
			Name = "SendNotificationReceipt",
			Type = "Function",

			Arguments =
			{
				{ Name = "notificationType", Type = "string", Nilable = false },
			},
		},
		{
			Name = "TestNotification",
			Type = "Function",

			Arguments =
			{
				{ Name = "notificationType", Type = "string", Nilable = false },
			},
		},
	},

	Events =
	{
		{
			Name = "BehavioralNotification",
			Type = "Event",
			LiteralName = "BEHAVIORAL_NOTIFICATION",
			Payload =
			{
				{ Name = "notificationType", Type = "string", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(BehavioralMessaging);