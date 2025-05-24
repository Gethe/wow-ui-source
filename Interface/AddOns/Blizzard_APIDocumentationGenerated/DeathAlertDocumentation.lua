local DeathAlert =
{
	Name = "DeathAlert",
	Type = "System",
	Namespace = "C_DeathAlert",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "HardcoreDeaths",
			Type = "Event",
			LiteralName = "HARDCORE_DEATHS",
			Payload =
			{
				{ Name = "memberName", Type = "cstring", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(DeathAlert);