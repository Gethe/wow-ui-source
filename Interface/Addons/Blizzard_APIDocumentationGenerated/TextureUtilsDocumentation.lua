local TextureUtils =
{
	Name = "TextureUtils",
	Type = "System",
	Namespace = "C_Texture",

	Functions =
	{
		{
			Name = "GetAtlasInfo",
			Type = "Function",

			Arguments =
			{
				{ Name = "atlas", Type = "string", Nilable = false },
			},

			Returns =
			{
				{ Name = "info", Type = "AtlasInfo", Nilable = false },
			},
		},
	},

	Events =
	{
	},

	Tables =
	{
		{
			Name = "AtlasInfo",
			Type = "Structure",
			Fields =
			{
				{ Name = "width", Type = "number", Nilable = false },
				{ Name = "height", Type = "number", Nilable = false },
				{ Name = "leftTexCoord", Type = "number", Nilable = false },
				{ Name = "rightTexCoord", Type = "number", Nilable = false },
				{ Name = "topTexCoord", Type = "number", Nilable = false },
				{ Name = "bottomTexCoord", Type = "number", Nilable = false },
				{ Name = "tilesHorizontally", Type = "bool", Nilable = false },
				{ Name = "tilesVertically", Type = "bool", Nilable = false },
				{ Name = "file", Type = "number", Nilable = true },
				{ Name = "filename", Type = "string", Nilable = true },
			},
		},
	},
};

APIDocumentation:AddDocumentationTable(TextureUtils);