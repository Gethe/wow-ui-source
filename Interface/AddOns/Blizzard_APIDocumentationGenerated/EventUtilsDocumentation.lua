local EventUtils =
{
	Name = "EventUtils",
	Type = "System",
	Namespace = "C_EventUtils",

	Functions =
	{
		{
			Name = "IsCallbackEvent",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "eventName", Type = "stringView", Nilable = false },
			},

			Returns =
			{
				{ Name = "isCallbackEvent", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "IsEventValid",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

			Arguments =
			{
				{ Name = "eventName", Type = "stringView", Nilable = false },
			},

			Returns =
			{
				{ Name = "valid", Type = "bool", Nilable = false },
			},
		},
		{
			Name = "NotifySettingsLoaded",
			Type = "Function",
		},
	},

	Events =
	{
		{
			Name = "SettingsLoaded",
			Type = "Event",
			LiteralName = "SETTINGS_LOADED",
			SynchronousEvent = true,
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(EventUtils);