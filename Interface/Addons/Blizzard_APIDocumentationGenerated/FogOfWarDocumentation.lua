local FogOfWar =
{
	Name = "FogOfWar",
	Type = "System",
	Namespace = "C_FogOfWar",

	Functions =
	{
		{
			Name = "GetFogOfWarForMap",
			Type = "Function",

			Arguments =
			{
				{ Name = "uiMapID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "fogOfWarID", Type = "number", Nilable = true },
			},
		},
		{
			Name = "GetFogOfWarInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "fogOfWarID", Type = "number", Nilable = false },
			},

			Returns =
			{
				{ Name = "fogOfWarInfo", Type = "FogOfWarInfo", Nilable = true },
			},
		},
	},

	Events =
	{
		{
			Name = "FogOfWarUpdated",
			Type = "Event",
			LiteralName = "FOG_OF_WAR_UPDATED",
		},
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