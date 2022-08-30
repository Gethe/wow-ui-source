local Platform =
{
	Name = "Platform",
	Type = "System",
	Namespace = "C_Platform",

	Functions =
	{
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "ClientPlatformType",
			Type = "Enumeration",
			NumValues = 2,
			MinValue = 0,
			MaxValue = 1,
			Fields =
			{
				{ Name = "Windows", Type = "ClientPlatformType", EnumValue = 0 },
				{ Name = "Macintosh", Type = "ClientPlatformType", EnumValue = 1 },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(Platform);