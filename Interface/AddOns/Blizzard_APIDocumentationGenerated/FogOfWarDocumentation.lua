local FogOfWar =
{
	Name = "FogOfWar",
	Type = "System",
	Namespace = "C_FogOfWar",
	Environment = "All",

	Functions =
	{
		{
			Name = "GetFogOfWarForMap",
			Type = "Function",
			SecretArguments = "AllowedWhenUntainted",

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
			SecretArguments = "AllowedWhenUntainted",

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
			UniqueEvent = true,
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
				{ Name = "backgroundAtlas", Type = "textureAtlas", Nilable = false },
				{ Name = "maskAtlas", Type = "textureAtlas", Nilable = false },
				{ Name = "maskScalar", Type = "number", Nilable = false },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(FogOfWar);