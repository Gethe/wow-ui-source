local IslandsInfo =
{
	Name = "IslandsInfo",
	Type = "System",
	Namespace = "C_IslandsInfo",

	Functions =
	{
	},

	Events =
	{
		{
			Name = "IslandAzeriteGain",
			Type = "Event",
			LiteralName = "ISLAND_AZERITE_GAIN",
			Payload =
			{
				{ Name = "amount", Type = "number", Nilable = false },
				{ Name = "gainedByPlayer", Type = "bool", Nilable = false },
				{ Name = "factionIndex", Type = "number", Nilable = false },
				{ Name = "gainedBy", Type = "string", Nilable = false },
				{ Name = "gainedFrom", Type = "string", Nilable = false },
			},
		},
	},

	Tables =
	{
	},
};

APIDocumentation:AddDocumentationTable(IslandsInfo);