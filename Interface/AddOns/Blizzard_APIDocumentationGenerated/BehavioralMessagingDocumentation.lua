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
				{ Name = "dbId", Type = "NotificationDbId", Nilable = false },
				{ Name = "openTimeSeconds", Type = "number", Nilable = false },
				{ Name = "readTimeSeconds", Type = "number", Nilable = false },
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
				{ Name = "dbId", Type = "NotificationDbId", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(BehavioralMessaging);