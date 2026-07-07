local CraftInfo =
{
	Name = "CraftInfo",
	Type = "System",
	Namespace = "C_CraftInfo",
	Environment = "All",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "CraftClose",
			Type = "Event",
			LiteralName = "CRAFT_CLOSE",
			UniqueEvent = true,
		},
		{
			Name = "CraftShow",
			Type = "Event",
			LiteralName = "CRAFT_SHOW",
			UniqueEvent = true,
		},
		{
			Name = "CraftUpdate",
			Type = "Event",
			LiteralName = "CRAFT_UPDATE",
			UniqueEvent = true,
		},
	},

	Tables =
	{
	},
	Predicates =
	{
	},
};

APIDocumentation:AddDocumentationTable(CraftInfo);