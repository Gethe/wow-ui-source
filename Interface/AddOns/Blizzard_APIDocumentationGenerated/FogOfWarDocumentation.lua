local FogOfWar =
{
	Name = "FogOfWar",
	Type = "System",
	Namespace = "C_FogOfWar",

	Functions =
	{
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "FogOfWarInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "fogOfWarID", Type = "number", Nilable = false },
				{ Name = "backgroundAtlas", Type = "string", Nilable = false },
				{ Name = "maskAtlas", Type = "string", Nilable = false },
				{ Name = "maskScalar", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(FogOfWar);