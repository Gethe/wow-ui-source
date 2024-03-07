local EventUtils =
{
	Name = "EventUtils",
	Type = "System",
	Namespace = "C_EventUtils",

	Functions =
	{
		{
			Name = "IsEventValid",
			Type = "Function",

			Arguments =
			{
				{ Name = "eventName", Type = "cstring", Nilable = false },
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
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(EventUtils);