local EventUtils =
{
	Name = "EventUtils",
	Type = "System",
	Namespace = "C_EventUtils",
	Environment = "All",

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
	},

	Events =
	{
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(EventUtils);