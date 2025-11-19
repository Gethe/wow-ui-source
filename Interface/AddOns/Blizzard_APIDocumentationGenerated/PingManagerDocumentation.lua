local PingManager =
{
	Name = "PingManager",
	Type = "System",
	Namespace = "C_Ping",

	Functions =
	{
		{
			Name = "IsPingSystemEnabled",
			Type = "Function",

			Returns =
			{
				{ Name = "isEnabled", Type = "bool", Nilable = false },
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

APIDocumentation:AddDocumentationTable(PingManager);