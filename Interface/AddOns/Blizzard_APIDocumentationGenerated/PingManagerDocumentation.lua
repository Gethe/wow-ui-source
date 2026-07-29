local PingManager =
{
	Name = "PingManager",
	Type = "System",
	Namespace = "C_Ping",
	Environment = "All",

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
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(PingManager);